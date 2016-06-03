C     Last change:  ERB  10 Jul 2002   12:25 pm
      SUBROUTINE GWF1GHB6AL(ISUM,LCBNDS,MXBND,NBOUND,IN,IOUT,IGHBCB,
     1     NGHBVL,IGHBAL,IFREFM,NPGHB,IGHBPB,NNPGHB,NOPRGB)
C
C-----VERSION 11JAN2000 GWF1GHB6AL
C     ******************************************************************
C     ALLOCATE ARRAY STORAGE FOR GHBS
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      COMMON /GHBCOM/GHBAUX(5)
      CHARACTER*16 GHBAUX
      CHARACTER*200 LINE
C     ------------------------------------------------------------------
C
C1------IDENTIFY PACKAGE AND INITIALIZE NBOUND.
      WRITE(IOUT,1)IN
    1 FORMAT(1X,/1X,'GHB6 -- GHB PACKAGE, VERSION 6, 1/11/2000',
     1' INPUT READ FROM UNIT ',I4)
      NBOUND=0
      NNPGHB=0
C
C2------READ MAXIMUM NUMBER OF GHB'S AND UNIT OR FLAG FOR
C2------CELL-BY-CELL FLOW TERMS.
      CALL URDCOM(IN,IOUT,LINE)
      CALL UPARLSTAL(IN,IOUT,LINE,NPGHB,MXPB)
      IF(IFREFM.EQ.0) THEN
         READ(LINE,'(2I10)') MXACTB,IGHBCB
         LLOC=21
      ELSE
         LLOC=1
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,MXACTB,R,IOUT,IN)
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IGHBCB,R,IOUT,IN)
      END IF
      WRITE(IOUT,3) MXACTB
    3 FORMAT(1X,'MAXIMUM OF ',I6,' ACTIVE GHB CELLS AT ONE TIME')
      IF(IGHBCB.LT.0) WRITE(IOUT,7)
    7 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE PRINTED WHEN ICBCFL NOT 0')
      IF(IGHBCB.GT.0) WRITE(IOUT,8) IGHBCB
    8 FORMAT(1X,'CELL-BY-CELL FLOWS WILL BE SAVED ON UNIT ',I4)
C
C3------READ AUXILIARY VARIABLES AND CBC ALLOCATION OPTION.
      IGHBAL=0
      NAUX=0
      NOPRGB = 0
   10 CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
      IF(LINE(ISTART:ISTOP).EQ.'CBCALLOCATE' .OR.
     1   LINE(ISTART:ISTOP).EQ.'CBC') THEN
         IGHBAL=1
         WRITE(IOUT,11)
   11    FORMAT(1X,'MEMORY IS ALLOCATED FOR CELL-BY-CELL BUDGET TERMS')
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'AUXILIARY' .OR.
     1        LINE(ISTART:ISTOP).EQ.'AUX') THEN
         CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,IN)
         IF(NAUX.LT.5) THEN
            NAUX=NAUX+1
            GHBAUX(NAUX)=LINE(ISTART:ISTOP)
            WRITE(IOUT,12) GHBAUX(NAUX)
   12       FORMAT(1X,'AUXILIARY GHB VARIABLE: ',A)
         END IF
         GO TO 10
      ELSE IF(LINE(ISTART:ISTOP).EQ.'NOPRINT') THEN
         WRITE(IOUT,13)
   13    FORMAT(1X,'LISTS OF GENERAL-HEAD BOUNDARY CELLS WILL NOT BE',
     &          ' PRINTED')
         NOPRGB = 1
         GO TO 10
      END IF
      NGHBVL=5+NAUX+IGHBAL
C
C4------ALLOCATE SPACE IN THE RX ARRAY FOR THE BNDS ARRAY.
      IGHBPB=MXACTB+1
      MXBND=MXACTB+MXPB
      ISOLD=ISUM
      LCBNDS=ISUM
      ISUM=ISUM+NGHBVL*MXBND
C
C5------PRINT AMOUNT OF SPACE USED BY GHB PACKAGE.
      ISP=ISUM-ISOLD
      WRITE (IOUT,14)ISP
   14 FORMAT(1X,I10,' ELEMENTS IN RX ARRAY ARE USED BY GHB')
C
C6------RETURN.
      RETURN
      END
      SUBROUTINE GWF1GHB6RQ(IN,IOUT,NGHBVL,IGHBAL,NCOL,NROW,NLAY,NPGHB,
     1            BNDS,IGHBPB,MXBND,IFREFM,ITERP,INAMLOC,NOPRGB)
C
C-----VERSION 20011108 GWF1GHB6RQ
C     ******************************************************************
C     READ GHB PARAMETERS
C     ******************************************************************
C     Modified 11/8/2001 to support parameter instances - ERB
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION BNDS(NGHBVL,MXBND)
      COMMON /GHBCOM/GHBAUX(5)
      CHARACTER*16 GHBAUX
C     ------------------------------------------------------------------
C
C-------READ NAMED PARAMETERS.
      IF (ITERP.EQ.1) WRITE(IOUT,1000) NPGHB
 1000 FORMAT(1X,//1X,I5,' GHB parameters')
      IF(NPGHB.GT.0) THEN
        NAUX=NGHBVL-5-IGHBAL
        LSTSUM=IGHBPB
        ITERPU = ITERP
        IF (NOPRGB .EQ.1) ITERPU = 99
        DO 20 K=1,NPGHB
          LSTBEG=LSTSUM
          CALL UPARLSTRP(LSTSUM,MXBND,IN,IOUT,IP,'GHB','GHB',ITERP,
     &                  NUMINST,INAMLOC)
          NLST=LSTSUM-LSTBEG
          IF (NUMINST.GT.1) NLST = NLST/NUMINST
C         ASSIGN STARTING INDEX FOR READING INSTANCES
          IF (NUMINST.EQ.0) THEN
            IB=0
          ELSE
            IB=1
          ENDIF
C         READ LIST(S) OF CELLS, PRECEDED BY INSTANCE NAME IF NUMINST>0
          LB=LSTBEG
          DO 10 I=IB,NUMINST
            IF (I.GT.0) THEN
              CALL UINSRP(I,IN,IOUT,IP,ITERP)
            ENDIF
            CALL ULSTRD(NLST,BNDS,LB,NGHBVL,MXBND,IGHBAL,IN,IOUT,
     &      'BOUND. NO. LAYER   ROW   COL     STAGE    STRESS FACTOR',
     &      GHBAUX,5,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,ITERPU)
            LB=LB+NLST
   10     CONTINUE
   20   CONTINUE
      END IF
C
C6------RETURN
      RETURN
      END
      SUBROUTINE GWF1GHB6RP(BNDS,NBOUND,MXBND,IN,IOUT,NGHBVL,IGHBAL,
     1       IFREFM,NCOL,NROW,NLAY,NNPGHB,NPGHB,IGHBPB,NOPRGB)
C
C-----VERSION 11JAN2000 GWF1GHB6RP
C     ******************************************************************
C     READ GHB HEAD, CONDUCTANCE AND BOTTOM ELEVATION
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION BNDS(NGHBVL,MXBND)
      COMMON /GHBCOM/GHBAUX(5)
      CHARACTER*16 GHBAUX
C     ------------------------------------------------------------------
C
C1------READ ITMP (NUMBER OF GHB'S OR FLAG TO REUSE DATA) AND
C1------NUMBER OF PARAMETERS.
      IF(NPGHB.GT.0) THEN
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(2I10)') ITMP,NP
         ELSE
            READ(IN,*) ITMP,NP
         END IF
      ELSE
         NP=0
         IF(IFREFM.EQ.0) THEN
            READ(IN,'(I10)') ITMP
         ELSE
            READ(IN,*) ITMP
         END IF
      END IF
C
C------CALCULATE SOME CONSTANTS
      NAUX=NGHBVL-5-IGHBAL
      ITERPU = 1
      IOUTU = IOUT
      IF (NOPRGB.EQ.1) THEN
        ITERPU = 99
        IOUTU = -1
      ENDIF
C
C2------DETERMINE THE NUMBER OF NON-PARAMETER GHB'S.
      IF(ITMP.LT.0) THEN
         WRITE(IOUT,7)
    7    FORMAT(1X,/1X,
     1   'REUSING NON-PARAMETER GHB CELLS FROM LAST STRESS PERIOD')
      ELSE
         NNPGHB=ITMP
      END IF
C
C3------IF THERE ARE NEW NON-PARAMETER GHB'S, READ THEM.
      MXACTB=IGHBPB-1
      IF(ITMP.GT.0) THEN
         IF(NNPGHB.GT.MXACTB) THEN
            WRITE(IOUT,99) NNPGHB,MXACTB
   99       FORMAT(1X,/1X,'THE NUMBER OF ACTIVE GHB CELLS (',I6,
     1                     ') IS GREATER THAN MXACTB(',I6,')')
            STOP
         END IF
         CALL ULSTRD(NNPGHB,BNDS,1,NGHBVL,MXBND,IGHBAL,IN,IOUT,
     1      'BOUND. NO. LAYER   ROW   COL     STAGE      CONDUCTANCE',
     2      GHBAUX,5,NAUX,IFREFM,NCOL,NROW,NLAY,5,5,ITERPU)
      END IF
      NBOUND=NNPGHB
C
C1C-----IF THERE ARE ACTIVE GHB PARAMETERS, READ THEM AND SUBSTITUTE
      CALL PRESET('GHB')
      IF(NP.GT.0) THEN
         NREAD=NGHBVL-IGHBAL
         DO 30 N=1,NP
         CALL UPARLSTSUB(IN,'GHB',IOUTU,'GHB',BNDS,NGHBVL,MXBND,NREAD,
     1                MXACTB,NBOUND,5,5,
     2      'BOUND. NO. LAYER   ROW   COL     STAGE      CONDUCTANCE',
     3            GHBAUX,5,NAUX)
   30    CONTINUE
      END IF
C
C3------PRINT NUMBER OF GHB'S IN CURRENT STRESS PERIOD.
      WRITE (IOUT,101) NBOUND
  101 FORMAT(1X,/1X,I6,' GHB CELLS')
C
C8------RETURN.
  260 RETURN
      END
      SUBROUTINE GWF1GHB6FM(NBOUND,MXBND,BNDS,HCOF,RHS,IBOUND,
     1              NCOL,NROW,NLAY,NGHBVL)
C
C-----VERSION 11JAN2000 GWF1GHB6FM
C     ******************************************************************
C     ADD GHB TERMS TO RHS AND HCOF
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION BNDS(NGHBVL,MXBND),HCOF(NCOL,NROW,NLAY),
     1         RHS(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------IF NBOUND<=0 THEN THERE ARE NO GENERAL HEAD BOUNDS. RETURN.
      IF(NBOUND.LE.0) RETURN
C
C2------PROCESS EACH ENTRY IN THE GENERAL HEAD BOUND LIST (BNDS).
      DO 100 L=1,NBOUND
C
C3------GET COLUMN, ROW AND LAYER OF CELL CONTAINING BOUNDARY.
      IL=BNDS(1,L)
      IR=BNDS(2,L)
      IC=BNDS(3,L)
C
C4------IF THE CELL IS EXTERNAL THEN SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 100
C
C5------SINCE THE CELL IS INTERNAL GET THE BOUNDARY DATA.
      HB=BNDS(4,L)
      C=BNDS(5,L)
C
C6------ADD TERMS TO RHS AND HCOF.
      HCOF(IC,IR,IL)=HCOF(IC,IR,IL)-C
      RHS(IC,IR,IL)=RHS(IC,IR,IL)-C*HB
  100 CONTINUE
C
C7------RETURN.
      RETURN
      END
      SUBROUTINE GWF1GHB6BD(NBOUND,MXBND,VBNM,VBVL,MSUM,BNDS,DELT,HNEW,
     1   NCOL,NROW,NLAY,IBOUND,KSTP,KPER,IGHBCB,ICBCFL,BUFF,IOUT,
     2   PERTIM,TOTIM,NGHBVL,IGHBAL,IAUXSV)
C-----VERSION 05JUNE2000 GWF1GHB6BD
C     ******************************************************************
C     CALCULATE VOLUMETRIC BUDGET FOR GHB
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
      COMMON /GHBCOM/GHBAUX(5)
      CHARACTER*16 GHBAUX
      CHARACTER*16 VBNM(MSUM),TEXT
      DOUBLE PRECISION HNEW,CC,CHB,RATIN,RATOUT,RRATE
      DIMENSION VBVL(4,MSUM),BNDS(NGHBVL,MXBND),HNEW(NCOL,NROW,NLAY),
     1           IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY)
C
      DATA TEXT /' HEAD DEP BOUNDS'/
C     ------------------------------------------------------------------
C
C1------INITIALIZE CELL-BY-CELL FLOW TERM FLAG (IBD) AND
C1------ACCUMULATORS (RATIN AND RATOUT).
      ZERO=0.
      RATOUT=ZERO
      RATIN=ZERO
      IBD=0
      IF(IGHBCB.LT.0 .AND. ICBCFL.NE.0) IBD=-1
      IF(IGHBCB.GT.0) IBD=ICBCFL
      IBDLBL=0
C
C2------IF CELL-BY-CELL FLOWS WILL BE SAVED AS A LIST, WRITE HEADER.
      IF(IBD.EQ.2) THEN
         NAUX=NGHBVL-5-IGHBAL
         IF(IAUXSV.EQ.0) NAUX=0
         CALL UBDSV4(KSTP,KPER,TEXT,NAUX,GHBAUX,IGHBCB,NCOL,NROW,NLAY,
     1          NBOUND,IOUT,DELT,PERTIM,TOTIM,IBOUND)
      END IF
C
C3------CLEAR THE BUFFER.
      DO 50 IL=1,NLAY
      DO 50 IR=1,NROW
      DO 50 IC=1,NCOL
      BUFF(IC,IR,IL)=ZERO
50    CONTINUE
C
C4------IF NO BOUNDARIES, SKIP FLOW CALCULATIONS.
      IF(NBOUND.EQ.0) GO TO 200
C
C5------LOOP THROUGH EACH BOUNDARY CALCULATING FLOW.
      DO 100 L=1,NBOUND
C
C5A-----GET LAYER, ROW AND COLUMN OF EACH GENERAL HEAD BOUNDARY.
      IL=BNDS(1,L)
      IR=BNDS(2,L)
      IC=BNDS(3,L)
      RATE=ZERO
C
C5B-----IF CELL IS NO-FLOW OR CONSTANT-HEAD, THEN IGNORE IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 99
C
C5C-----GET PARAMETERS FROM BOUNDARY LIST.
      HB=BNDS(4,L)
      C=BNDS(5,L)
      CC=C
C
C5D-----CALCULATE THE FOW RATE INTO THE CELL.
      CHB=C*HB
      RRATE=CHB - CC*HNEW(IC,IR,IL)
      RATE=RRATE
C
C5E-----PRINT THE INDIVIDUAL RATES IF REQUESTED(IGHBCB<0).
      IF(IBD.LT.0) THEN
         IF(IBDLBL.EQ.0) WRITE(IOUT,61) TEXT,KPER,KSTP
   61    FORMAT(1X,/1X,A,'   PERIOD ',I4,'   STEP ',I3)
         WRITE(IOUT,62) L,IL,IR,IC,RATE
   62    FORMAT(1X,'BOUNDARY ',I6,'   LAYER ',I3,'   ROW ',I5,'   COL ',
     1       I5,'   RATE ',1PG15.6)
         IBDLBL=1
      END IF
C
C5F-----ADD RATE TO BUFFER.
      BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+RATE
C
C5G-----SEE IF FLOW IS INTO AQUIFER OR OUT OF AQUIFER.
      IF(RATE)94,99,96
C
C5H------FLOW IS OUT OF AQUIFER SUBTRACT RATE FROM RATOUT.
94    RATOUT=RATOUT-RRATE
      GO TO 99
C
C5I-----FLOW IS INTO AQIFER; ADD RATE TO RATIN.
96    RATIN=RATIN+RRATE
C
C5J-----IF SAVING CELL-BY-CELL FLOWS IN LIST, WRITE FLOW.  OR IF
C5J-----RETURNING THE FLOW IN THE BNDS ARRAY, COPY FLOW TO BNDS.
99    IF(IBD.EQ.2) CALL UBDSVB(IGHBCB,NCOL,NROW,IC,IR,IL,RATE,
     1                  BNDS(1,L),NGHBVL,NAUX,6,IBOUND,NLAY)
      IF(IGHBAL.NE.0) BNDS(NGHBVL,L)=RATE
100   CONTINUE
C
C6------IF CELL-BY-CELL TERMS WILL BE SAVED AS A 3-D ARRAY, THEN CALL
C6------UTILITY MODULE UBUDSV TO SAVE THEM.
      IF(IBD.EQ.1) CALL UBUDSV(KSTP,KPER,TEXT,IGHBCB,BUFF,NCOL,NROW,
     1                          NLAY,IOUT)
C
C7------MOVE RATES, VOLUMES AND LABELS INTO ARRAYS FOR PRINTING.
  200 RIN=RATIN
      ROUT=RATOUT
      VBVL(3,MSUM)=RIN
      VBVL(1,MSUM)=VBVL(1,MSUM)+RIN*DELT
      VBVL(4,MSUM)=ROUT
      VBVL(2,MSUM)=VBVL(2,MSUM)+ROUT*DELT
      VBNM(MSUM)=TEXT
C
C8------INCREMENT THE BUDGET TERM COUNTER.
      MSUM=MSUM+1
C
C9------RETURN.
      RETURN
      END
