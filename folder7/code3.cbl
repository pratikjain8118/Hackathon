IDENTIFICATION DIVISION.
PROGRAM-ID. SampleProgram.
AUTHOR. YourName.
DATE-WRITTEN. TodaysDate.

DATA DIVISION.
FILE SECTION.
FD InputFile.
01 InputRecord.
   05 Field1 PIC X(10).
   05 Field2 PIC 9(5).
   05 Field3 PIC X(20).

FD OutputFile.
01 OutputRecord.
   05 ResultField1 PIC X(10).
   05 ResultField2 PIC 9(5).
   05 ResultField3 PIC X(20).

WORKING-STORAGE SECTION.
01 ErrorMessage PIC X(100).

PROCEDURE DIVISION.
MAIN-PARAGRAPH.
    OPEN INPUT InputFile
         OUTPUT OutputFile.

    PERFORM READ-INPUT-RECORD
        UNTIL InputRecord = "EOF"

    CLOSE InputFile
          OutputFile.

    STOP RUN.

READ-INPUT-RECORD.
    READ InputFile
        AT END
            MOVE "EOF" TO InputRecord
        NOT AT END
            PERFORM PROCESS-DATA.

PROCESS-DATA.
    MOVE Field1 TO ResultField1.
    MOVE Field2 TO ResultField2.
    MOVE Field3 TO ResultField3.

    WRITE OutputRecord.

    READ-INPUT-RECORD.
