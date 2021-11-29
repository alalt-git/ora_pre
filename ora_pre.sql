


CREATE TABLE TR_PRE
(
  NNUM        NUMBER(17),
  SCLOB       CLOB,
  SSTR        VARCHAR2(4000 BYTE),
  SUSER       VARCHAR2(2000 BYTE),
  STRANS      VARCHAR2(4000 BYTE),
  TTIMESTAMP  TIMESTAMP(6),
  NVER        NUMBER(17),
  SCOM0       VARCHAR2(2000 BYTE),
  SCOM1       VARCHAR2(2000 BYTE),
  SCOM2       VARCHAR2(2000 BYTE),
  DDATE       DATE
)
nologing;

/


CREATE OR REPLACE package PRE is

  function BT
  /* Return format_error_stack + format_error_backtrace */
  return varchar2;

 procedure E
 /* Exception BOOLEAN  */
 (bVAL     in boolean,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure E
 /* Exception NUMBER  */
 (nVAL     in number,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure E
 /* Exception VARCHAR  */
 (sVAL     in varchar2,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure E
 /* Exception DATE */
 (dVAL     in date,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure S
 /* Сохранить NUMBER  */
 (nVAL     in number,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure S
 /* Сохранить VARCHAR */
 (sVAL     in varchar2,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure S
 /* Сохранить DATE  */
 (dVAL     in date,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );

 procedure S
 /* Сохранить CLOB  */
 (cVAL     in clob,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  );



end PRE;

/

CREATE OR REPLACE package body PRE is


  function BT
  /* Return format_error_stack + format_error_backtrace */
  return varchar2
  as
  BEGIN
    return chr(10)||
           'TRACE:'||chr(10)||
           '==============================================================================================='||chr(10)||
           (dbms_utility.format_error_stack||dbms_utility.format_error_backtrace)||chr(10)||
           '===============================================================================================';
  END;



 procedure E
 /* Exception BOOLEAN  */
 (bVAL     in boolean,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'b/'||chr(10)||
    case bVAL
      when true then 'true'
      when false then 'false'
      else 'else hz'
    end
    ||case
        when sCOM0 is null then (null)
        else (chr(10)||' sCOM0 > '||sCOM0)
      end
    ||case
        when sCOM1 is null then (null)
        else (chr(10)||' sCOM1 > '||sCOM1)
      end
    ||case
        when sCOM2 is null then (null)
        else (chr(10)||' sCOM2 > '||sCOM2)
      end
    );
  END;


 procedure E
 /* Exception NUMBER  */
 (nVAL     in number,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'n/'||chr(10)||to_char(nVAL)
    ||case
        when sCOM0 is null then (null)
        else (chr(10)||' sCOM0 > '||sCOM0)
      end
    ||case
        when sCOM1 is null then (null)
        else (chr(10)||' sCOM1 > '||sCOM1)
      end
    ||case
        when sCOM2 is null then (null)
        else (chr(10)||' sCOM2 > '||sCOM2)
      end
      );
  END;

 procedure E
 /* Exception VARCHAR  */
 (sVAL     in varchar2,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'s/'||chr(10)||sVAL
    ||case
        when sCOM0 is null then (null)
        else (chr(10)||' sCOM0 > '||sCOM0)
      end
    ||case
        when sCOM1 is null then (null)
        else (chr(10)||' sCOM1 > '||sCOM1)
      end
    ||case
        when sCOM2 is null then (null)
        else (chr(10)||' sCOM2 > '||sCOM2)
      end
      );
  END;

 procedure E
 /* Exception DATE */
 (dVAL     in date,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'d/'||chr(10)||to_char(dVAL,'dd.mm.yyyy')
    ||case
        when sCOM0 is null then (null)
        else (chr(10)||' sCOM0 > '||sCOM0)
      end
    ||case
        when sCOM1 is null then (null)
        else (chr(10)||' sCOM1 > '||sCOM1)
      end
    ||case
        when sCOM2 is null then (null)
        else (chr(10)||' sCOM2 > '||sCOM2)
      end
      );
  END;

--=====================================================
/* Сохраняем значение, с версией по транзакциям  */

 procedure S
 /* Сохранить NUMBER  */
 (nVAL     in number,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
 as
 pragma autonomous_transaction;
 v_nVER    number:=0;
 BEGIN
   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     group by t.nver;
     exception
       when NO_DATA_FOUND then begin
                                 select   nvl(max(t.nver),0)+1
                                 into     v_nVER
                                 from     TR_PRE   t
                                 where    t.suser  = USER;
                               end;
   end;

   begin
     insert into TR_PRE(NNUM,SUSER,STRANS,TTIMESTAMP,NVER,SCOM0,SCOM1,SCOM2)
     values            (nVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM0,sCOM1,sCOM2);
   end;
   commit;
 END;


 procedure S
 /* Сохранить VARCHAR */
 (sVAL     in varchar2,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
 as
 pragma autonomous_transaction;
 v_nVER    number:=0;
 BEGIN

   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     group by t.nver;
     exception
       when NO_DATA_FOUND then begin
                                 select   nvl(max(t.nver),0)+1
                                 into     v_nVER
                                 from     TR_PRE   t
                                 where    t.suser  = USER;
                               end;
   end;
   begin
     case
       /* Если длинна строки больше 4000 - пишем в клоб  */
       when length(sVAL) > 4000 then
         insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM0,SCOM1,SCOM2)
         values            (sVAL,'TO CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM0,sCOM1,sCOM2);
         commit;
       else
         /* Иначе строка */
         insert into TR_PRE(SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM0,SCOM1,SCOM2)
         values            (sVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM0,sCOM1,sCOM2);
         commit;
     end case;
   end;
 END;

 procedure S
 /* Сохранить DATE  */
 (dVAL     in date,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
 as
 pragma autonomous_transaction;
 v_nVER    number:=0;
 BEGIN


   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     group by t.nver;
     exception
       when NO_DATA_FOUND then begin
                                 select   nvl(max(t.nver),0)+1
                                 into     v_nVER
                                 from     TR_PRE   t
                                 where    t.suser  = USER;
                               end;
   end;
   begin
     insert into TR_PRE(DDATE,SUSER,STRANS,TTIMESTAMP,NVER,SCOM0,SCOM1,SCOM2)
     values            (dVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM0,sCOM1,sCOM2);
   end;
   commit;
 END;


 procedure S
 /* Сохранить CLOB  */
 (cVAL     in clob,
  sCOM0     in varchar2 default null,
  sCOM1    in varchar2 default null,
  sCOM2    in varchar2 default null
  )
 as
 pragma autonomous_transaction;
 v_nVER    number:=0;
 BEGIN


   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     group by t.nver;
     exception
       when NO_DATA_FOUND then begin
                                 select   nvl(max(t.nver),0)+1
                                 into     v_nVER
                                 from     TR_PRE   t
                                 where    t.suser  = USER;
                               end;
   end;
   begin
     insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM0,SCOM1,SCOM2)
     values            (cVAL,'IN CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM0,sCOM1,sCOM2);
   end;
   commit;
 END;



end PRE;

/