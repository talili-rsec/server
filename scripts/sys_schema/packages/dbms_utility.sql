DROP PACKAGE IF EXISTS dbms_utility;

SET @old_sql_mode = @@session.sql_mode, @@session.sql_mode = oracle;

DELIMITER $$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE dbms_utility
  SQL SECURITY INVOKER
  COMMENT 'Collection of utility routines'
  AS
    FUNCTION format_error_backtrace RETURN varchar(65532)
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              This procedure displays the call stack at the point where an exception was raised, even if the procedure is called from an exception handler in an outer scope.
  
              Raises
              ------
  
              '
    ;
    FUNCTION format_error_stack RETURN varchar(65532)
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              This function formats the current error stack. It can be used in exception handlers to look at the full error stack
  
              Raises
              ------
  
              '
    ;
    FUNCTION get_time RETURN int
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              This function returns a measure of current time in hundredths of a second
  
              Raises
              ------
  
              '
    ;
END
$$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE BODY dbms_utility
  SQL SECURITY INVOKER
  AS
    FUNCTION format_error_backtrace RETURN varchar(65532)
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          This procedure displays the call stack at the point where an exception was raised, even if the procedure is called from an exception handler in an outer scope.
  
          Raises
          ------
  
      '
    IS
    BEGIN
      SELECT SESSION_Value FROM INFORMATION_SCHEMA.SYSTEM_VARIABLES WHERE VARIABLE_NAME LIKE 'backtrace_str' INTO @orig_seed1;
      return @orig_seed1;
    END;
    FUNCTION format_error_stack RETURN varchar(65532)
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          This function formats the current error stack. It can be used in exception handlers to look at the full error stack
  
          Raises
          ------
  
      '
    IS
    BEGIN
      return @@errstack_str;
    END;
    FUNCTION get_time RETURN int
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          This function returns a measure of current time in hundredths of a second
  
          Raises
          ------
  
      '
    IS
    BEGIN
      return unix_timestamp(current_timestamp(2));
    END;
END
$$

DELIMITER ;

SET @@session.sql_mode = @old_sql_mode;
