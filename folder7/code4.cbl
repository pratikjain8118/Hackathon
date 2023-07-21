IDENTIFICATION DIVISION.
PROGRAM-ID. PayrollSystem.
AUTHOR. YourName.
DATE-WRITTEN. TodaysDate.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 Employee-Record.
   05 Employee-Name        PIC X(50).
   05 Employee-ID          PIC 9(6).
   05 Hours-Worked         PIC 9(5).
   05 Hourly-Rate          PIC 9(5)V99.
   05 Gross-Pay            PIC 9(8)V99.
   
01 Total-Gross-Pay         PIC 9(10)V99.
01 Employee-Count          PIC 9(5) VALUE 0.

01 ErrorMessage            PIC X(100).
   
01 EOF-Flag                PIC X(1) VALUE 'N'.

FILE SECTION.
FD EmployeeFile.
01 EmployeeFile-Record.
   05 Employee-Name-FD     PIC X(50).
   05 Employee-ID-FD       PIC 9(6).
   05 Hours-Worked-FD      PIC 9(5).
   05 Hourly-Rate-FD       PIC 9(5)V99.

WORKING-STORAGE SECTION.
01 WS-Employee-Record       PIC X(100).
01 WS-Hours-Worked          PIC 9(5).
01 WS-Hourly-Rate           PIC 9(5)V99.

PROCEDURE DIVISION.
MAIN-PARAGRAPH.
    OPEN INPUT EmployeeFile
    PERFORM READ-EMPLOYEE-RECORD
    PERFORM CALCULATE-GROSS-PAY
    PERFORM DISPLAY-PAYROLL-REPORT
    CLOSE EmployeeFile
    STOP RUN.

READ-EMPLOYEE-RECORD.
    READ EmployeeFile
        AT END
            MOVE 'Y' TO EOF-Flag
        NOT AT END
            PERFORM PROCESS-EMPLOYEE-RECORD.

PROCESS-EMPLOYEE-RECORD.
    MOVE EmployeeFile-Record TO WS-Employee-Record
    UNSTRING WS-Employee-Record DELIMITED BY ',' INTO
        Employee-Name
        Employee-ID-FD
        Hours-Worked-FD
        Hourly-Rate-FD
    MOVE Employee-ID-FD TO Employee-ID
    MOVE Hours-Worked-FD TO WS-Hours-Worked
    MOVE Hourly-Rate-FD TO WS-Hourly-Rate.

CALCULATE-GROSS-PAY.
    COMPUTE Gross-Pay = WS-Hours-Worked * WS-Hourly-Rate.

DISPLAY-PAYROLL-REPORT.
    ADD Gross-Pay TO Total-Gross-Pay
    ADD 1 TO Employee-Count.

    DISPLAY 'Employee Name: ' Employee-Name
    DISPLAY 'Employee ID: ' Employee-ID
    DISPLAY 'Gross Pay: ' Gross-Pay
    DISPLAY '---------------------------'.

    PERFORM READ-EMPLOYEE-RECORD UNTIL EOF-Flag = 'Y'.

    DISPLAY 'Total Gross Pay: ' Total-Gross-Pay
    DISPLAY 'Total Employees: ' Employee-Count.
