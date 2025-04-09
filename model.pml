#define PRICE_1 75
#define PRICE_2 50

mtype = { IDLE, SELECT_1, SELECT_2, PAY, DISPENSE };

chan user_input = [0] of { mtype }; // Канал для ввода пользователя
chan payment = [0] of { int };     // Канал для оплаты
chan dispense = [0] of { mtype };  // Канал для выдачи товара

// Переменные для количества товаров и баланса пользователя
int item_1_count = 10; // Начальное количество товара 1
int item_2_count = 10; // Начальное количество товара 2
int user_balance = 100; // Начальный баланс пользователя

active proctype User() {
    mtype choice;

    do
    :: atomic {
        // Пользователь выбирает товар 1 или 2
        if
        :: choice = SELECT_1; user_input!SELECT_1
        :: choice = SELECT_2; user_input!SELECT_2
        fi;
        // Пользователь производит оплату
        if
        :: choice == SELECT_1 -> payment!PRICE_1
        :: choice == SELECT_2 -> payment!PRICE_2
        fi;
        // Ожидание выдачи товара
        dispense?_;
        printf("Пользователь получил товар %d\n", choice);
    }
    od
}

active proctype Controller() {
    mtype selected_item;
    int price;

    do
    :: user_input?selected_item -> // Ожидание выбора товара
        if
        :: selected_item == SELECT_1 -> price = PRICE_1
        :: selected_item == SELECT_2 -> price = PRICE_2
        fi;
        payment?price -> // Ожидание оплаты
        if
        :: selected_item == SELECT_1 && item_1_count > 0 && user_balance >= price -> item_1_count--; // Уменьшаем количество товара 1
            dispense!selected_item; // Выдача товара
        :: selected_item == SELECT_2 && item_2_count > 0 && user_balance >= price -> item_2_count--; // Уменьшаем количество товара 2
            dispense!selected_item; // Выдача товара
        fi;
    od
}

active proctype Dispenser() {
    mtype item;

    do
    :: dispense?item -> // Ожидание команды на выдачу
        // Выдача товара
        printf("Товар %d выдан\n", item);
    od
}

// Свойства LTL для верификации
ltl property1 { [] (user_input == SELECT_1 -> X payment == PRICE_1) && (user_input == SELECT_2 -> X payment == PRICE_2) }
ltl property2 { [] (payment == PRICE_1 -> X dispense == SELECT_1) && (payment == PRICE_2 -> X dispense == SELECT_2) }
ltl property3 { [] (item_1_count >= 0 && item_2_count >= 0) } // Количество товаров не может быть отрицательным