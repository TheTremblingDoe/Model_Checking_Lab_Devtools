---------- MODULE model ----------
EXTENDS Integers, TLC

CONSTANTS SELECT_1, SELECT_2, NONE

VARIABLES 
    client_state, 
    client_choice,
    transaction_payment,
    transaction_balance,
    dispense_item,
    amount_1,
    amount_2,
    dispense_amount

Init == 
    /\ client_state = "IDLE"
    /\ client_choice = NONE
    /\ transaction_payment = 0
    /\ transaction_balance = 100
    /\ dispense_item = NONE
    /\ amount_1 \in 10..1000
    /\ amount_2 \in 10..1000
    /\ dispense_amount = 5

TypeOK == 
    /\ client_state \in {"IDLE", "PAY", "DISPENSE"}
    /\ client_choice \in {SELECT_1, SELECT_2, NONE}
    /\ (client_state = "IDLE" => client_choice = NONE)
    /\ (client_state \in {"PAY", "DISPENSE"} => client_choice \in {SELECT_1, SELECT_2})
    /\ transaction_balance >= 0
    /\ amount_1 >= 0 /\ amount_2 >= 0

UserChoose ==
    /\ client_state = "IDLE"
    /\ client_choice = NONE
    /\ client_choice' \in {SELECT_1, SELECT_2}
    /\ client_state' = "PAY"
    /\ UNCHANGED <<transaction_payment, transaction_balance, dispense_item, amount_1, amount_2, dispense_amount>>

ProcessTransaction ==
    /\ client_state = "PAY"
    /\ client_choice \in {SELECT_1, SELECT_2}  \* явна€ проверка
    /\ IF client_choice = SELECT_1 THEN
        /\ transaction_balance >= 75
        /\ amount_1 >= dispense_amount
        /\ transaction_payment' = 75
        /\ transaction_balance' = transaction_balance - 75
        /\ dispense_item' = SELECT_1
        /\ amount_1' = amount_1 - dispense_amount
        /\ amount_2' = amount_2
        ELSE
        /\ transaction_balance >= 50
        /\ amount_2 >= dispense_amount
        /\ transaction_payment' = 50
        /\ transaction_balance' = transaction_balance - 50
        /\ dispense_item' = SELECT_2
        /\ amount_2' = amount_2 - dispense_amount
        /\ amount_1' = amount_1
    /\ client_state' = "DISPENSE"
    /\ client_choice' = client_choice  \* —охран€ем значение
    /\ dispense_amount' = dispense_amount

ProcessFailure ==
    /\ client_state = "PAY"
    /\ client_choice \in {SELECT_1, SELECT_2}  \* явна€ проверка
    /\ \/ (client_choice = SELECT_1 /\ (transaction_balance < 75 \/ amount_1 < dispense_amount))
       \/ (client_choice = SELECT_2 /\ (transaction_balance < 50 \/ amount_2 < dispense_amount))
    /\ client_state' = "IDLE"
    /\ client_choice' = NONE  \* явный сброс
    /\ dispense_item' = NONE
    /\ UNCHANGED <<transaction_payment, transaction_balance, amount_1, amount_2, dispense_amount>>

UserReturnToIdle ==
    /\ client_state = "DISPENSE"
    /\ client_choice \in {SELECT_1, SELECT_2}  \* явна€ проверка
    /\ client_state' = "IDLE"
    /\ client_choice' = NONE  \* явный сброс
    /\ dispense_item' = NONE
    /\ transaction_payment' = 0
    /\ UNCHANGED <<transaction_balance, amount_1, amount_2, dispense_amount>>

Next ==
    \/ UserChoose
    \/ ProcessTransaction
    \/ ProcessFailure
    \/ UserReturnToIdle

(* ”силенные свойства *)
PaymentConsistency == 
    [](\/ transaction_payment = 0
       \/ (transaction_payment = 75 /\ dispense_item = SELECT_1)
       \/ (transaction_payment = 50 /\ dispense_item = SELECT_2))

BalanceOK == [](transaction_balance >= 0)
InventoryOK == [](amount_1 >= 0 /\ amount_2 >= 0)

====