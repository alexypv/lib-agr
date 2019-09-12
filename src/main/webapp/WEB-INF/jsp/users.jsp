<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css"/>

    <link type="text/css" rel="stylesheet" href="resources/css/simplePagination.css"/>

    <link type="text/css" rel="stylesheet" href="resources/css/userspage.css"/>
    <script src="resources/js/jquery/3.3.1/jquery.min.js"></script>
    <script src="resources/js/bootstrap/3.4.0/bootstrap.min.js"></script>

    <script type="text/javascript" src="resources/js/administration/users/users.table-pagination.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/roles.load.all.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/users.create-user.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/users.refresh-table.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/users.edit-user.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/users.get-history.js"></script>
    <script type="text/javascript" src="resources/js/administration/users/users.open-user.js" async></script>
    <script type="text/javascript" src="resources/js/administration/users/users.get-user-by-JwtLib.js" async></script>
    <script type="text/javascript" src="resources/js/search/search.users.js"></script>
    <script type="text/javascript" src="resources/js/search/search.orders.js"></script>


    <title>Пользователи</title>
</head>

<body onload="loadRoles();">

<div id="snackbar"></div>
<nav class="navbar-default">
    <div class="container-fluid">
        <div class="navbar-header">
            <a class="navbar-brand" href="home">Главная</a>
        </div>
        <ul class="nav navbar-nav">
            <li><a href="directory">Каталог книг</a></li>
            <li><a href="users" class="active">Пользователи</a></li>
            <li><a href="#">Журнал выдачи книг</a></li>
        </ul>
        <ul class="nav navbar-nav navbar-right">
            <li><a href="profile"><span class="glyphicon glyphicon-user"></span>${username}</a></li>
            <li><a href="logout"><span class="glyphicon glyphicon-log-in"></span> Выйти</a></li>
        </ul>
    </div>
</nav>

<div id="sidebar"></div>
<div id="content"></div>
<div id="buttonPanel"></div>

<div class="modal fade" id="createReaderWindow" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <div style="text-align: center;"><h4 class="modal-title">Создать пользователя</h4>
                </div>
            </div>
            <div class="modal-body">
                <form id = "createUserForm" name="createUserForm">

                    <label for="newUsername">Новое имя пользователя:</label>
                    <input id="newUsername" value="" class="form-control" placeholder="Введите имя пользователя" name="newUsername" type="text" aria-required="true"></input>
                    <label for="newPassword">Новый пароль:</label>
                    <input id="newPassword" value="" class="form-control" placeholder="Введите пароль" name="newPassword" type="password" aria-required="true"></input>
                    <label for="newSurname">Фамилия пользователя:</label>
                    <input id="newSurname" class="form-control" name="newSurname"
                           placeholder="Введите фамилию автора" type="text" aria-required="true"></input>
                    <label for="newName">Имя пользователя:</label>
                    <input id="newName" class="form-control" name="newName"
                           placeholder="Введите имя автора" type="text" aria-required="true"></input>
                    <label for="newSecondName">Отчество пользователя:</label>
                    <input id="newSecondName" class="form-control" name="newSecondName"
                           placeholder="Введите отчество автора" type="text" aria-required="true"></input>

                    <label for="roleName">Тип:</label>
                    <input id="roleName" class="form-control" name="roleName"
                           value="" type="text" aria-required="true" disabled></input>

                    <input id="newRole" class="form-control" name="newRole" type="hidden"></input>
                    <input id="newLibrary" class="form-control" name="newLibrary" type="hidden"></input>
                </form>
            </div>
            <div class="modal-footer">
                <button onclick="createUser()" class="btn btn-success">Создать</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="userInfoWindow" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <div style="text-align: center;"><h4 class="modal-title">Информация о пользователе</h4></div>
            </div>
            <div id="userInfoField" class="modal-body"></div>
            <div class="modal-footer">
                <button id="getUserHistory" value="1" type="button" class="btn btn-primary" style="float:left" onclick = "getHistory(1)">Посмотреть историю заказов</button>
                <button id="editUserButton" type="button" class="btn btn-success">Изменить</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmActionWindow" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <center><h4 class="modal-title">Подтверждение действия</h4></center>
            </div>
            <div class="modal-body">
                <div style="text-align: center;"><p id="confirmAnswer"></p>
                    <p id="confirmDescription"></p>
                    <div id="confirmContent"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button id="confirmActionButton" type="button" class="btn btn-primary">Ок</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="resultWindow" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title" id="resultAction"></h4>
            </div>
            <div class="modal-body">
                <p id="feedback"></p>
                <div id="feedbackDescription"></div>
            </div>
            <div class="modal-footer">
                <button id="closeButtonResultWindow" type="button" class="btn btn-default" data-dismiss="modal">
                    Закрыть
                </button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="historyWindow" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title" id="historyHeader"></h4>
                <div class="modal-body">

                    <div style="width: 100%; float: left; margin-bottom: 10px;">
                        <input id="searchHistoryField" type="text" class="form-control" placeholder="Введите информацию о заказе"  style="float: left; width: 95%;">
                        <div class="input-group-append">
                            <button class="btn btn-success" type="submit"  style="float: left; width: 5%;" onclick="searchHistory(1)">&#128270;</button>
                        </div>
                    </div>

                    <div id="ordersContent">
                        <table id="historyTable" class="table table-bordered table-sm">
                            <thead>
                            <tr class="header">
                                <th style="width:5%;" onclick="sortTable(0)">ID</th>
                                <th style="width:10%;" onclick="sortTable(0)">Код</th>
                                <th style="width:10%;" onclick="sortTable(1)">Кто выдал</th>
                                <th style="width:20%;" onclick="sortTable(0)">Дата выдачи</th>
                                <th style="width:20%;" onclick="sortTable(0)">Вернуть до</th>
                                <th style="width:20%;" onclick="sortTable(0)">Дата возврата</th>
                                <th style="width:10%;" onclick="sortTable(0)">Возврат принял</th>
                            </tr>
                            </thead>
                            <tbody id="historyTableContent">
                            </tbody>
                        </table>
                        <div id="light-pagination-history" class="pagination"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Закрыть</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).on('change', '.checkboxBooks', function () {
        if (this.checked) {
            var arr = $('#selectedBooks').val().split(',');
            if ($('#selectedBooks').val() === '') {
                delete arr[0];
            }
            arr = arr.filter(function () {
                return true
            });
            arr.push($(this).val());
            arr = Array.from(new Set(arr));
            $('#selectedBooks').val(arr);
            $('#choosenBooksCount').html('Отмечено книг (' + arr.length + ')');
        } else {
            var arr = $('#selectedBooks').val().split(',');
            var index = arr.indexOf($(this).val());
            if (index >= 0) arr.splice(index, 1);
            arr = Array.from(new Set(arr));
            $('#selectedBooks').val(arr);
            $('#choosenBooksCount').html('Отмечено книг (' + arr.length + ')');

        }

    });

    function selectAllBooks(obj) {
        var items = document.getElementsByClassName("checkboxBooks"),
            len, i;
        for (i = 0, len = items.length; i < len; i += 1) {
            if (items.item(i).type && items.item(i).type === "checkbox") {
                if (obj.checked) {
                    items.item(i).checked = true;
                    var arr = $('#selectedBooks').val().split(',');
                    if ($('#selectedBooks').val() === '') {
                        delete arr[0];
                    }
                    arr = arr.filter(function () {
                        return true
                    });
                    arr.push($(items.item(i)).val());
                    arr = Array.from(new Set(arr));
                    $('#selectedBooks').val(arr);
                    $('#choosenBooksCount').html('Отмечено книг (' + arr.length + ')');
                } else {
                    items.item(i).checked = false;
                    var arr = $('#selectedBooks').val().split(',');
                    var index = arr.indexOf($(items.item(i)).val());
                    if (index >= 0) arr.splice(index, 1);
                    arr = Array.from(new Set(arr));
                    $('#selectedBooks').val(arr);
                    $('#choosenBooksCount').html('Отмечено книг (' + arr.length + ')');
                }

            }
        }
    }
</script>

<script type="text/javascript">
    function validateNumericField(evt) {
        var theEvent = evt || window.event;
        var key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        var regex = /[0-9]|\./;
        if (!regex.test(key)) {
            theEvent.returnValue = false;
            if (theEvent.preventDefault) theEvent.preventDefault();
        }
    }
</script>

<script type="text/javascript">
    function validateName(evt) {
        var theEvent = evt || window.event;
        var key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        var regex = /[А-Яа-яЁё ]|\./;
        if (!regex.test(key)) {
            theEvent.returnValue = false;
            if (theEvent.preventDefault) theEvent.preventDefault();
        }
    }
</script>

<script type="text/javascript">
    function getCheckedBooksInOrderForm() {
        var selectedCheckBoxes = document.querySelectorAll('input.checkboxBooksInOrder:checked');
        var checkedValues = Array.from(selectedCheckBoxes).map(cb => cb.value);
        return checkedValues;
    }
</script>

</body>
</html>