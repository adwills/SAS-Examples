/*TEST DATA SET*/
DATA MAILING;
	ID=1; EMAIL=""; SUBJECT="HELLO"; SALUTATION="ANDREW";
		PART1="YOUR ORDER IS ALMOST READY.";  PART2="PLEASE PICK UP TOMORROW."; PART3="CHEERS, NOODLES"; OUTPUT;
	ID=2; EMAIL=""; SUBJECT="HELLO ADWILLS"; SALUTATION="ANDREW";
		PART1="YOUR ORDER IS READY.";  PART2="PLEASE PICK UP ASAP."; PART3="CHEERS, PANERA"; OUTPUT;
RUN;

/*CREATE MACRO*/
%MACRO EMAILNOTE;

/*CREATE SET OF MACROS FOR EACH ID*/
/*THESE CONTAIN THE INFORMATION TO GO INTO THE EMAIL*/
DATA _NULL_;
	SET MAILING END=LAST;
	CALL SYMPUT(COMPRESS('EMAIL'||ID),STRIP(EMAIL));
	CALL SYMPUT(COMPRESS('SUBJECT'||ID),STRIP(SUBJECT));
	CALL SYMPUT(COMPRESS('SALUTATION'||ID),STRIP(SALUTATION));
	CALL SYMPUT(COMPRESS('PART1'||ID),STRIP(PART1));
	CALL SYMPUT(COMPRESS('PART2'||ID),STRIP(PART2));
	CALL SYMPUT(COMPRESS('PART3'||ID),STRIP(PART3));
	IF LAST THEN CALL SYMPUT('TOT',STRIP(_N_));
RUN;

/*ITERATE OVER EACH INDIVIDUAL*/
%DO I=1 %TO &TOT;

/*CREATE PDF REPORT*/
%LET FN=C:\Users\anddwi\Downloads\;
FILENAME RX "&FN.RX.PDF";
%LET PATH=%SYSFUNC(PATHNAME(RX));

ODS PDF FILE=RX;
PROC PRINT DATA=MAILING;
	WHERE ID=&I;
RUN;
ODS PDF CLOSE;

/*CONNECT TO EMAIL SERVER*/
OPTIONS EMAILSYS=SMTP EMAILHOST=;

/*INSTRUCTIONS FOR SENDING EMAIL*/
FILENAME MYMAIL EMAIL TO="&&EMAIL&I" SUBJECT="&&SUBJECT&I" ATTACH="&PATH" SENDER="" FROM="";

/*USE DATA STEP TO WRITE IN BODY OF EMAIL*/
/*SLASHES AT THE END OF PUT STATEMENTS CREATE LINEBREAKS*/
/*CAN EASILY HAVE MULTIPLE MACRO VARIABLES REFERENCED IN A PUT STATEMENT*/
DATA _NULL_;
	FILE MYMAIL;
	PUT "&&SALUTATION&I,"/;
	PUT "&&PART1&I"/;
	PUT "&&PART2&I"/;
	PUT "&&PART3&I"/;
RUN;

%END;

%MEND;

%EMAILNOTE;



/*EXPERIMENTING WITH OPTIONS OUTSIDE OF MACRO*/
OPTIONS EMAILSYS=SMTP EMAILHOST=;

/*INSTRUCTIONS FOR SENDING EMAIL*/
FILENAME MYMAIL EMAIL TO="" SUBJECT="New Test" SENDER="" FROM="";

/*USE DATA STEP TO WRITE IN BODY OF EMAIL*/
/*SLASHES AT THE END OF PUT STATEMENTS CREATE LINEBREAKS*/
/*CAN EASILY HAVE MULTIPLE MACRO VARIABLES REFERENCED IN A PUT STATEMENT*/
DATA _NULL_;
	FILE MYMAIL;
	PUT "Fixed the reply to issue."/;
	PUT "Sent from SAS."/;
RUN;