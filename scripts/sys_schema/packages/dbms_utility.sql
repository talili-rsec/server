DROP PACKAGE IF EXISTS dbms_utility;

SET @old_sql_mode = @@session.sql_mode, @@session.sql_mode = oracle;

DELIMITER $$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE dbms_utility
  SQL SECURITY INVOKER
  COMMENT 'Collection of utility routines'
  AS
    FUNCTION format_error_backtrace RETURN VARCHAR(65532)
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              This procedure displays the call stack at the point where an exception was raised, even if the procedure is called from an exception handler in an outer scope.

              Raises
              ------

              '
    ;
    FUNCTION format_error_stack RETURN VARCHAR(65532)
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              This function formats the current error stack. It can be used in exception handlers to look at the full error stack

              Raises
              ------

              '
    ;
    FUNCTION get_time RETURN INT
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
    FUNCTION format_error_backtrace RETURN VARCHAR(65532)
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
      DECLARE
        backtrace_str VARCHAR(65532);
      BEGIN
        RETURN @@backtrace_str;
      END;
    END;
    FUNCTION truncate_to_2000_bytes(input TEXT)
    RETURN TEXT
    DETERMINISTIC
    IS
    BEGIN
        DECLARE i INT DEFAULT 1;
        result TEXT DEFAULT '';
        moji TEXT;
        byte_len INT DEFAULT 0;

        BEGIN
            <<label>>
            WHILE i <= CHAR_LENGTH(input) LOOP
              SET moji = SUBSTRING(input, i, 1);
              SET byte_len = byte_len + LENGTH(moji);
              IF byte_len > 2000 THEN
                  LEAVE label;
              END IF;
              SET result = CONCAT(result, moji);
              SET i = i + 1;
            END LOOP label;
            RETURN result;    
        END;

    END;
    FUNCTION format_error_stack RETURN VARCHAR(65532)
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          This function formats the current error stack. It can be used in exception handlers to look at the full error stack

          Raises
          ------

      '
    AS
    BEGIN
      RETURN @@errstack_str;
      #RETURN truncate_to_2000_bytes(@@errstack_str);
    END;
    FUNCTION get_time RETURN INT
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
      RETURN UNIX_TIMESTAMP(CURRENT_TIMESTAMP(2));
    END;
END
$$

DELIMITER ;

SET @@session.sql_mode = @old_sql_mode;
