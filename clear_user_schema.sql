purge recyclebin;

SET SERVEROUTPUT ON;

declare
    -- FK first, then unique, then PK
    -- C    Check on a table           Column
    -- O    Read Only on a view        Object
    -- P    Primary Key                Object
    -- R    Referential (Foreign Key)  Column
    -- U    Unique Key                 Column
    -- V    Check Option on a view     Object
    
    cursor cursor_constraints is select table_name, constraint_name
                              from user_constraints
                              where constraint_type in ('P', 'R', 'U')
                              order by decode(constraint_type, 'R', 0, 'U', 1, 'P', 2, 3);
                        
--    cursor cursor_fk_constraints is select table_name, constraint_name
--                          from user_constraints
--                         where constraint_type = 'R' and status = 'ENABLED';
--                        order by decode(constraint_type, 'R', 0, 'U', 1, 'P', 2, 3);
                        
    cursor cursor_objects is select object_name,object_type 
                          from user_objects 
                          order by decode(OBJECT_TYPE, 'VIEW',        0,
                                                      'INDEX',        1,
                                                      'TABLE',        2,
                                                      'SYNONYM',      3,
                                                      'SEQUENCE',     4,
                                                      'PACKAGE',      5,
                                                      'PROCEDURE',    6,
                                                      'FUNCTION',     7,
                                                      'QUEUE',        8,
                                                      'TYPE',         9,
                                                      'LOB',          10, 11 );
                                                                                                          
--    cursor cursor_views is select view_name from user_views;
--    cursor cursor_tables is select table_name from user_tables;
--    cursor cursor_synonyms is select synonym_name from user_synonyms;
--    cursor cursor_sequences is select sequence_name from user_sequences;
--    cursor cursor_package_body is select package_body_name from user_;

begin
  
--    for current_val in cursor_fk_constraints
--    loop
--        execute immediate 'alter table ' || current_val.table_name || ' modify constraint ' || current_val.constraint_name ||' DISABLE';
--    end loop;

    for current_val in cursor_constraints
    loop
    begin
        execute immediate 'alter table ' || current_val.table_name || ' drop constraint ' || current_val.constraint_name || ' cascade';
      EXCEPTION 
        when others then
      dbms_output.put_line('Same error in drop constraints!');
    end;
    end loop;
    
    for current_val in cursor_objects
    loop
      begin 
          execute  immediate 'drop ' || current_val.object_type || ' ' || current_val.object_name;
        EXCEPTION
          when others then
        dbms_output.put_line('Same error in drop objects!');
      end;
    end loop;
    
end;
/
quit;
--/
--select DISTINCT object_type from user_objects;
--/
--select object_name from SYS.USER_OBJECTS where OBJECT_TYPE='TRIGGER';
--/
--select object_type from user_objects;
--/
select * from user_objects;
--/
--select 'alter table '||table_name||' disable constraint '||constraint_name||';' from user_constraints where constraint_type = 'R';
--/
