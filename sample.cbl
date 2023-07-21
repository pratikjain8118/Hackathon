IDENTIFICATION DIVISION.
PROGRAM-ID. InventoryManagement.
DATA DIVISION.
WORKING-STORAGE SECTION.
  01 Item-Record.
    05 Item-Code      PIC 9(5).
    05 Item-Name      PIC X(30).
    05 Item-Quantity  PIC 9(5).
  01 Error-Message    PIC X(50).
  01 Inventory-Limit  PIC 9(5) VALUE 1000.

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "Welcome to the Inventory Management System!".
    PERFORM INPUT-ITEM-DETAILS.
    PERFORM PROCESS-INVENTORY.
    PERFORM DISPLAY-INVENTORY.
    STOP RUN.

INPUT-ITEM-DETAILS.
    DISPLAY "Enter Item Code: ".
    ACCEPT Item-Code.
    DISPLAY "Enter Item Name: ".
    ACCEPT Item-Name.
    DISPLAY "Enter Item Quantity: ".
    ACCEPT Item-Quantity.

PROCESS-INVENTORY.
    IF Item-Quantity > Inventory-Limit
        MOVE "Inventory limit exceeded! Cannot add item." TO Error-Message
        DISPLAY Error-Message
    ELSE
        ADD Item-Quantity TO Item-Record(Item-Code)
        DISPLAY "Item added to inventory successfully!"
    END-IF.

DISPLAY-INVENTORY.
    DISPLAY "Current Inventory:".
    DISPLAY "Item Code    Item Name                     Quantity".
    PERFORM VARYING Item-Code FROM 1 BY 1 UNTIL Item-Code > 99999
        IF Item-Record(Item-Code) NOT = 0
            DISPLAY Item-Code "          " Item-Name(Item-Code) "          " Item-Record(Item-Code)
        END-IF
    END-PERFORM.
