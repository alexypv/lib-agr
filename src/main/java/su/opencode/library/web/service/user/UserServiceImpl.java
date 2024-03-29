package su.opencode.library.web.service.user;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import su.opencode.library.web.model.entities.*;
import su.opencode.library.web.repositories.*;
import su.opencode.library.web.secure.JwtTokenProvider;
import su.opencode.library.web.secure.JwtUser;
import su.opencode.library.web.secure.resolutions.create.user.CreateUserResolution;
import su.opencode.library.RepositoriesService;
import su.opencode.library.web.service.ticket.TicketService;
import su.opencode.library.web.utils.JsonObject.RoleJson;
import su.opencode.library.web.utils.JsonObject.UserJson;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserServiceImpl extends RepositoriesService implements UserService {

    private final JwtTokenProvider jwtTokenProvider;
    private final TicketService ticketService;

    public UserServiceImpl(BookCrudRepository bookRepository, CatalogCrudRepository catalogRepository, LibraryCrudRepository libraryRepository, OrderPositionCrudRepository orderPositionRepository, OrdersCrudRepository ordersRepository, RoleCrudRepository roleRepository, TicketCrudRepository ticketRepository, UserCrudRepository userRepository, UserImageCrudRepository userImageRepository, JwtTokenProvider jwtTokenProvider, TicketService ticketService) {
        super(bookRepository, catalogRepository, libraryRepository, orderPositionRepository, ordersRepository, roleRepository, ticketRepository, userRepository, userImageRepository);
        this.jwtTokenProvider = jwtTokenProvider;
        this.ticketService = ticketService;
    }


    @Override
    public UserEntity getUserById(int user_id) {
        return userRepository.findById(user_id).get();
    }

    @Override
    public UserEntity getUserByUsername(String username) {
        return userRepository.findUserEntityByUsername(username);
    }


    @Override
    public String createUser(String username, String password, String surname, String name, String secondName, int library_id, int role_id, int creator_id, String creatorRole) throws AccessDeniedException {
        RoleEntity roleEntity = roleRepository.findById(role_id).get();
        LibraryEntity libraryEntity = new LibraryEntity(library_id);
        UserEntity creator = new UserEntity(creator_id);
        List<RoleEntity> list = new ArrayList<>();
        list.add(roleEntity);
        // Создаю юзера со всеми параметрами
        if ((creatorRole.equals("[ROLE_GLOBAL]") && CreateUserResolution.getAdminRes().stream().anyMatch(e -> e.toString().contains(roleEntity.getName()))) ||
                (creatorRole.equals("[ROLE_ADMIN]") && CreateUserResolution.getAdminRes().stream().anyMatch(e -> e.toString().contains(roleEntity.getName()))) ||
                (creatorRole.equals("[ROLE_LIBRARIER]") && CreateUserResolution.getLibRes().stream().anyMatch(e -> e.toString().contains(roleEntity.getName())))) {
            UserEntity userEntity = new UserEntity(username, jwtTokenProvider.passwordEncoder().encode(password), surname, name, secondName, libraryEntity, list, creator);
            userEntity.setAuditParamsForCreation(creator);
            // Сохраняю юзера
            userRepository.save(userEntity);
            //Связываю роль и пользователя
            //Создаю читательский билет и возвращаю его номер
            return ticketService.createTicket(getUserByUsername(username), creator);
        } else throw new AccessDeniedException("Access denied");
    }


    @Override
    public void changeUserInfo(int id, String username, String password, String surname, String name, String secondname, JwtUser jwtUser) {
        JwtTokenProvider jwtTokenProvider = new JwtTokenProvider();
        UserEntity userEntity = getUserById(id);
        if (!username.isEmpty() && !username.equals(jwtUser.getUsername())) {
            userEntity.setUsername(username);
        }
        if (!surname.isEmpty() && !surname.equals(jwtUser.getSurname())) {
            userEntity.setSurname(surname);
        }
        if (!name.isEmpty() && !name.equals(jwtUser.getName())) {
            userEntity.setName(name);
        }
        if (!secondname.isEmpty() && !secondname.equals(jwtUser.getSecondname())) {
            userEntity.setSecondName(secondname);
        }
        if (!password.isEmpty() && !jwtTokenProvider.passwordEncoder().encode(password).equals(userEntity.getPassword())) {
            userEntity.setPassword(jwtTokenProvider.passwordEncoder().encode(password));
        }
        // Ставлю себя в качестве того, кто обновил информацию, и сохраняю в базе объект
        userEntity.setAuditParamsForUpdate(userEntity);
        userRepository.save(userEntity);
    }

    @Override
    public ModelMap getUsersByRolesAndLibrary(int role_id, Pageable pageable, int library_id) {
        try {
            List<UserJson> result = new ArrayList<>();
            RoleEntity roleEntity = new RoleEntity();
            LibraryEntity libraryEntity = new LibraryEntity(library_id);
            roleEntity.setId(role_id);
            List<UserEntity> usersList = userRepository.findUserEntityByRolesAndLibraryEntity(roleEntity, libraryEntity, pageable).getContent();
            for (int count = 0; count < usersList.size(); count++) {
                UserJson userJson = new UserJson();
                UserJson user = userJson.convertUserEntityToUserJson(usersList.get(count));
                try {
                    user.setTicketCode(ticketRepository.findTicketEntityByUserEntity(usersList.get(count)).getCode());
                } catch (NullPointerException e) {
                    user.setTicketCode("-");
                }
                result.add(user);
            }
            ModelMap map = new ModelMap();
            map.addAttribute("usersList", result);
            map.addAttribute("countPages", userRepository.findUserEntityByRolesAndLibraryEntity(roleEntity, libraryEntity, pageable).getTotalPages());
            RoleJson roleJson = new RoleJson();
            map.addAttribute("currentCatalog", roleJson.convertRoleEntityToRoleJson(roleRepository.findById(role_id).get()));
            map.addAttribute("currentLibraryId", library_id);
            return map;

        } catch (Exception e) {
            e.printStackTrace();
            ModelMap map = new ModelMap();
            map.addAttribute("error", "Каталог не найден!");
            return map;
        }
    }


    @Override
    @Transactional
    public void uploadImage(int user_id, byte[] file) {
        UserEntity userEntity = getUserById(user_id);
        if (userImageRepository.findUserImageEntityByUserEntity(userEntity) != null) {
            userImageRepository.deleteUserImageEntityByUserEntity(userEntity);
        }
        userImageRepository.save(new UserImageEntity("userimage", "image/png", file, userEntity));
    }

    @Override
    public UserImageEntity getImage(int user_id) {

        UserEntity userEntity = getUserById(user_id);
        return userImageRepository.findUserImageEntityByUserEntity(userEntity);
    }

    @Override
    @Transactional
    public void deleteUserImage(int user_id) {

        UserEntity userEntity = getUserById(user_id);
        userImageRepository.deleteUserImageEntityByUserEntity(userEntity);
    }

    @Override
    public Page<UserEntity> searchUser(String searchValue, int library_id, int role_id, Pageable pageable) {
        return userRepository.findUserEntitiesByAllParameter(searchValue, library_id, role_id, pageable);
    }

}
