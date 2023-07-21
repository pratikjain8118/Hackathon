       program-id. db2sp.

       environment division.
       configuration section.

       data division.
       working-storage section.

       01  SQLDA-ID pic 9(4) comp-5.
       01  SQLDSIZE pic 9(4) comp-5.
       01  SQL-STMT-ID pic 9(4) comp-5.
       01  SQLVAR-INDEX pic 9(4) comp-5.
       01  SQL-DATA-TYPE pic 9(4) comp-5.
       01  SQL-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-LITERAL pic X(258).
       01  SQL-LITERAL1 pic X(130).
       01  SQL-LITERAL2 pic X(130).
       01  SQL-LITERAL3 pic X(130).
       01  SQL-LITERAL4 pic X(130).
       01  SQL-LITERAL5 pic X(130).
       01  SQL-LITERAL6 pic X(130).
       01  SQL-LITERAL7 pic X(130).
       01  SQL-LITERAL8 pic X(130).
       01  SQL-LITERAL9 pic X(130).
       01  SQL-LITERAL10 pic X(130).
       01  SQL-IS-LITERAL pic 9(4) comp-5 value 1.
       01  SQL-IS-INPUT-HVAR pic 9(4) comp-5 value 2.
       01  SQL-CALL-TYPE pic 9(4) comp-5.
       01  SQL-SECTIONUMBER pic 9(4) comp-5.
       01  SQL-INPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-OUTPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQLA-PROGRAM-ID.
           05 SQL-PART1 pic 9(4) COMP-5 value 172.
           05 SQL-PART2 pic X(6) value "AEAUAI".
           05 SQL-PART3 pic X(24) value "qA4nXRIg01111 2         ".
           05 SQL-PART4 pic 9(4) COMP-5 value 8.
           05 SQL-PART5 pic X(8) value "AJIT    ".
           05 SQL-PART6 pic X(120) value LOW-VALUES.
           05 SQL-PART7 pic 9(4) COMP-5 value 8.
           05 SQL-PART8 pic X(8) value "DB2SP   ".
           05 SQL-PART9 pic X(120) value LOW-VALUES.
                               

         
      *exec sql include sqlca end-exec
      * SQL Communication Area - SQLCA
       COPY 'sqlca.cbl'.

                                         

      *> -------------------------------------------
      *> COBOL HOST VARIABLES FOR TABLE EMPLOYEE
      *> -------------------------------------------
         
      *EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DCLEMPLOYEE.
           03 EMPLOYEE-EMPNO                  PIC X(6).
           03 EMPLOYEE-FIRSTNME               PIC X(12).
           03 EMPLOYEE-MIDINIT                PIC X(1).
           03 EMPLOYEE-LASTNAME               PIC X(15).
           03 EMPLOYEE-WORKDEPT               PIC X(3).
           03 EMPLOYEE-PHONENO                PIC X(4).
           03 EMPLOYEE-HIREDATE               PIC X(10).
           03 EMPLOYEE-JOB                    PIC X(8).
           03 EMPLOYEE-EDLEVEL                PIC S9(04)  COMP-5.
           03 EMPLOYEE-SEX                    PIC X(1).
           03 EMPLOYEE-BIRTHDATE              PIC X(10).
           03 EMPLOYEE-SALARY                 PIC S9(7)V9(2)  COMP-3.
           03 EMPLOYEE-BONUS                  PIC S9(7)V9(2)  COMP-3.
           03 EMPLOYEE-COMM                   PIC S9(7)V9(2)  COMP-3.

       01  DCLEMPLOYEE-NULL.
           03 EMPLOYEE-MIDINIT-NULL           PIC S9(04)  COMP-5.
           03 EMPLOYEE-WORKDEPT-NULL          PIC S9(04)  COMP-5.
           03 EMPLOYEE-PHONENO-NULL           PIC S9(04)  COMP-5.
           03 EMPLOYEE-HIREDATE-NULL          PIC S9(04)  COMP-5.
           03 EMPLOYEE-JOB-NULL               PIC S9(04)  COMP-5.
           03 EMPLOYEE-SEX-NULL               PIC S9(04)  COMP-5.
           03 EMPLOYEE-BIRTHDATE-NULL         PIC S9(04)  COMP-5.
           03 EMPLOYEE-SALARY-NULL            PIC S9(04)  COMP-5.
           03 EMPLOYEE-BONUS-NULL             PIC S9(04)  COMP-5.
           03 EMPLOYEE-COMM-NULL              PIC S9(04)  COMP-5.     
       
      *EXEC SQL END DECLARE SECTION END-EXEC
                                             

       linkage section.
       01  LS-EMPNO           PIC X(6).
       *>  Under Windows INT and SMALL parameters must be
       *>  defined as COMP-5 variables since getting data
       *>  from DB2 LUW
       01  LS-SQLCD           PIC S9(9) COMP-5.
       01  LS-FIRST           PIC X(12).
       01  LS-LAST            PIC X(15).
       01  LS-HIRE            PIC X(10).
       01  LS-SALARY          PIC S9(7)V99 COMP-3.

       procedure division using ls-empno,
                                ls-sqlcd,
                                ls-first,
                                ls-last,
                                ls-hire,
                                ls-salary.

           move ls-empno     to   employee-empno
           move spaces       to   ls-first ls-last ls-hire
           move 0            to   ls-salary

           
      *EXEC SQL SELECT 
      *             A.FIRSTNME
      *            ,A.LASTNAME
      *            ,A.HIREDATE
      *            ,A.SALARY
      *      INTO 
      *             :EMPLOYEE-FIRSTNME
      *            ,:EMPLOYEE-LASTNAME
      *            ,:EMPLOYEE-HIREDATE:EMPLOYEE-HIREDATE-NULL
      *            ,:EMPLOYEE-SALARY:EMPLOYEE-SALARY-NULL
      *        FROM EMPLOYEE A
      *       WHERE (A.EMPNO = :EMPLOYEE-EMPNO)
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA

           MOVE 1 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 6 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE EMPLOYEE-EMPNO
            OF
            DCLEMPLOYEE
            BY VALUE 0
                     0

           MOVE 2 TO SQL-STMT-ID 
           MOVE 4 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 12 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE EMPLOYEE-FIRSTNME
            OF
            DCLEMPLOYEE
            BY VALUE 0
                     0

           MOVE 15 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE EMPLOYEE-LASTNAME
            OF
            DCLEMPLOYEE
            BY VALUE 0
                     0

           MOVE 10 TO SQL-HOST-VAR-LENGTH
           MOVE 453 TO SQL-DATA-TYPE
           MOVE 2 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE EMPLOYEE-HIREDATE
            OF
            DCLEMPLOYEE
                         EMPLOYEE-HIREDATE-NULL
            OF
            DCLEMPLOYEE-NULL
            BY VALUE 0

           MOVE 521 TO SQL-HOST-VAR-LENGTH
           MOVE 485 TO SQL-DATA-TYPE
           MOVE 3 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE EMPLOYEE-SALARY
            OF
            DCLEMPLOYEE
                         EMPLOYEE-SALARY-NULL
            OF
            DCLEMPLOYEE-NULL
            BY VALUE 0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                    

           move sqlcode                to   ls-sqlcd
           if sqlcode = 0
              move employee-firstnme   to   ls-first
              move employee-lastname   to   ls-last
              move employee-hiredate   to   ls-hire
              move employee-salary     to   ls-salary
           end-if 

           move "LEE" to  employee-firstnme 

           
      *EXEC SQL declare csr1 cursor for
      *      SELECT 
      *             A.FIRSTNME
      *            ,A.LASTNAME
      *            ,A.HIREDATE
      *            ,A.SALARY
      *        FROM EMPLOYEE A
      *     END-EXEC
                    

          
      *exec sql open csr1 end-exec
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 2 TO SQL-SECTIONUMBER 
           MOVE 26 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                               
          goback.

       end program db2sp.