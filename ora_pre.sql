
-- Create table
create table TR_PRE
(
  nnum       NUMBER(17),
  sclob      CLOB,
  sstr       VARCHAR2(4000),
  suser      VARCHAR2(2000),
  strans     VARCHAR2(4000),
  ttimestamp TIMESTAMP(6),
  nver       NUMBER(17),
  scom       VARCHAR2(2000),
  scom2      VARCHAR2(2000),
  scom3      VARCHAR2(2000),
  ddate      DATE
)

nologging;
-- Grant/Revoke object privileges 
grant select on TR_PRE to PUBLIC;


/

create or replace package PRE is

function HAVING_CALL_S
  (sWHO  in varchar2)
  return varchar2;
  
  
 function mr
  /* many rows в строку */
 (sTABLE         in varchar2,  --таблица или представление
  sWHERE_COL     in varchar2,  --колонка идентификатор
  nIDENT         in number default null,    -- идентификатор NUMBER
  sIDENT         in varchar2 default null, -- идентификатор varchar
  sRETURN_COL    in varchar2,  -- вернуть из колонки
  nCNTROWS       in number default 3, -- кол-во строк макс.
  sDELIM         in varchar2 default '; '
  )
  return varchar2;

 procedure E
 /* Exception BOOLEAN  */
 (bVAL     in boolean,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure E
 /* Exception NUMBER  */
 (nVAL     in number,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure E
 /* Exception VARCHAR  */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure E
 /* Exception DATE */
 (dVAL     in date,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure S
 /* Сохранить NUMBER  */
 (nVAL     in number,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure S
 /* Сохранить VARCHAR */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure S
 /* Сохранить DATE  */
 (dVAL     in date,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure S
 /* Сохранить CLOB  */
 (cVAL     in clob,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );


 procedure SAC
 /* Сохранить CHAR  */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

 procedure SAC
 /* Сохранить CLOB  */
 (cVAL     in clob,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  );

  function BT
  /* Return format_error_stack + format_error_backtrace */
  return varchar2;

end PRE;

/

create or replace package body PRE is


function HAVING_CALL_S
  (sWHO  in varchar2)
  return varchar2
  as
  sRES varchar2(2000);
  sINFO  varchar2(2000);
  BEGIN
    begin
      SELECT 'HOST='||SYS_CONTEXT('USERENV','HOST')||'; IP='||SYS_CONTEXT('USERENV','IP_ADDRESS')||'; OSUSER='||SYS_CONTEXT('USERENV','OS_USER')
      into   sINFO
      FROM dual;
      exception
        when OTHERS then pre.sac(BT||'','ERROR IN CALL SYS_CONTEXT from HAVING_CALL_S');
        sINFO := 'ERROR in SYS_CONTEXT';
    end;
    begin
      SAC(sVAL => sWHO,
          sCOM => 'CHECK_CALL_S',
          sCOM2 => sINFO,
          sCOM3 => '');
      exception
        when others then pre.sac(BT||'','ERROR IN CALL SAC from HAVING_CALL_S');
    end;
    /* return '$' for replace in calling object */
    return '$';
  END;
  


 function mr
  /* many rows в строку */
 (sTABLE         in varchar2,  --таблица или представление
  sWHERE_COL     in varchar2,  --колонка идентификатор
  nIDENT         in number default null,    -- идентификатор NUMBER
  sIDENT         in varchar2 default null, -- идентификатор varchar
  sRETURN_COL    in varchar2,  -- вернуть из колонки
  nCNTROWS       in number default 3, -- кол-во строк макс.
  sDELIM         in varchar2 default '; '
  )
  return varchar2
  as
  sRES varchar2(2000);
  --

  /* Колонки*/
  TYPE T_COL IS RECORD
  (sTEXT varchar2(2000));
  /* Массив */
  --TYPE T_MS is TABLE of T_COL index by binary_integer;
  TYPE T_MS is TABLE of varchar2(2000);

  v_tbl T_MS;
  --
  sSQL varchar2(4000);
  sCH  varchar2(10);

  BEGIN
    if nIDENT is null and sIDENT is null then
      pre.E('Идентификаторы пустые');
    end if;

    sSQL := 'select to_char(t.'||sRETURN_COL||') from '||sTABLE||' t where t.'||sWHERE_COL||' = '||
             case
             when nIDENT is not null then nIDENT
             when sIDENT is not null then sIDENT
             end;

    begin
      execute immediate sSQL BULK COLLECT into v_tbl;
    end;

    if v_tbl.count() > 0 then
      for c in v_tbl.first..v_tbl.last
        loop
          sRES := sRES ||sCH|| v_tbl(c);

          if nCNTROWS = c then exit;
          end if;

          sCH := sDELIM;
        end loop;
    end if;

    return ''||sRES;
  END;

 procedure E
 /* Exception BOOLEAN  */
 (bVAL     in boolean,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'b/'||chr(10)||
    case bVAL
      when true then 'true'
      when false then 'false'
      else 'else hz'
    end
    );
  END;


 procedure E
 /* Exception NUMBER  */
 (nVAL     in number,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'n/'||chr(10)||to_char(nVAL));
  END;

 procedure E
 /* Exception VARCHAR  */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'s/'||chr(10)||sVAL);
  END;

 procedure E
 /* Exception DATE */
 (dVAL     in date,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
  as
  BEGIN
    raise_application_error(-20999,'d/'||chr(10)||to_char(dVAL,'dd.mm.yyyy'));
  END;

--=====================================================
/* Сохраняем значение, с версией по транзакциям  */

 procedure S
 /* Сохранить NUMBER  */
 (nVAL     in number,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 v_nVER    number:=0;
 BEGIN
   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
     insert into TR_PRE(NNUM,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
     values            (nVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
   end;
 END;


 procedure S
 /* Сохранить VARCHAR */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 v_nVER    number:=0;
 BEGIN

   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
         insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
         values            (sVAL,'TO CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
         commit;
       else
         /* Иначе строка */
         insert into TR_PRE(SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
         values            (sVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
         commit;
     end case;
   end;
 END;

 procedure S
 /* Сохранить DATE  */
 (dVAL     in date,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 v_nVER    number:=0;
 BEGIN


   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
     insert into TR_PRE(DDATE,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
     values            (dVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
   end;
 END;


 procedure S
 /* Сохранить CLOB  */
 (cVAL     in clob,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 v_nVER    number:=0;
 BEGIN


   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
     insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
     values            (cVAL,'IN CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
   end;
 END;


--=====================================================
/* Сохраняем значение, с версией по транзакциям + автономный коммит COMMIT  */
 procedure SAC
 /* Сохранить VARCHAR */
 (sVAL     in varchar2,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 PRAGMA AUTONOMOUS_TRANSACTION;

 v_nVER    number:=0;
 BEGIN

   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
         insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
         values            (sVAL,'TO CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
         commit;
       else
         /* Иначе строка */
         insert into TR_PRE(SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
         values            (sVAL,USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
         commit;
     end case;
   end;
 END;

 procedure SAC
 /* Сохранить CLOB + COMMIT  */
 (cVAL     in clob,
  sCOM     in varchar2 default null,
  sCOM2    in varchar2 default null,
  sCOM3    in varchar2 default null
  )
 as
 /* !!!!!!!!!!!!!!!!!!!!!!!!!! */
 PRAGMA AUTONOMOUS_TRANSACTION;

 v_nVER    number:=0;
 BEGIN


   begin
     select   t.nver
     into     v_nVER
     from     TR_PRE   t
     where    t.suser  = USER
     and      t.strans = DBMS_TRANSACTION.LOCAL_TRANSACTION_ID
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
     insert into TR_PRE(SCLOB,SSTR,SUSER,STRANS,TTIMESTAMP,NVER,SCOM,SCOM2,SCOM3)
     values            (cVAL,'IN CLOB',USER,DBMS_TRANSACTION.LOCAL_TRANSACTION_ID,CURRENT_TIMESTAMP,v_nVER,sCOM,sCOM2,sCOM3);
     commit;
   end;

 END;



--<<<<<<<<< MCRD SETTINGS <<<<<<<<<<<<<<

  function BT
  /* Return format_error_stack + format_error_backtrace */
  return varchar2
  as
  BEGIN
    return chr(10)||
           (dbms_utility.format_error_stack||dbms_utility.format_error_backtrace)||chr(10);
  END;


end PRE;
