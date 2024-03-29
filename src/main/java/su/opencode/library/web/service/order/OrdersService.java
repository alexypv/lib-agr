package su.opencode.library.web.service.order;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import su.opencode.library.web.model.entities.BookOrderEntity;
import su.opencode.library.web.model.entities.LibraryEntity;
import su.opencode.library.web.model.entities.TicketEntity;
import su.opencode.library.web.model.entities.UserEntity;

import java.util.Date;

public interface OrdersService {

    /**
     * Создает предварительный заказ. В методе формируются позиции заказа.
     * Статус заказа при этом становится Preliminary. ID читательского билета так же не проставляется.
     *
     * @param books_id Массив ID-ов книг, которые будут занесены в заказ.
     */
    String createOrder(int[] books_id, int creator_id, Date giveDate, Date returnDate, TicketEntity ticketEntity, LibraryEntity libraryEntity);

    Page<BookOrderEntity> getOrdersByTicket(TicketEntity ticketEntity, Pageable pageable);

    Page<BookOrderEntity> getOrdersByLibrary(LibraryEntity libraryEntity, Pageable pageable);

    Page<BookOrderEntity> getAllOrders(Pageable pageable);

    Page<BookOrderEntity> searchOrder(String searchValue, String ticketCode, Pageable pageable);

    void returnOrder(int orderID, UserEntity returner);
}
