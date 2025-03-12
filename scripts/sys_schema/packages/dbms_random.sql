DROP PACKAGE IF EXISTS dbms_random;

SET @old_sql_mode = @@session.sql_mode, @@session.sql_mode = oracle;

DELIMITER $$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE dbms_random
  SQL SECURITY INVOKER
  COMMENT 'Collection of random routines'
  AS
    PROCEDURE initialize (input INT) 
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              Initializes the seed
  
              Raises
              ------
  
              '
    ;
    PROCEDURE terminate
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              Terminates package
  
              Raises
              ------
  
              '
    ;
    FUNCTION value (low decimal, high decimal) RETURN decimal(65,38)
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              Gets a random Oracle Database number x, where x is greater than 
              or equal to a specified lower limit and less than a specified 
              higher limit
  
              Raises
              ------
  
              '
    ;
    FUNCTION random RETURN int
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------
              Generates a random number
  
              Raises
              ------
  
              '
    ;
END
$$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE BODY dbms_random
  SQL SECURITY INVOKER
  AS
    PROCEDURE initialize (input INT)
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          Initializes the seed
  
          Raises
          ------
  
      '
    IS
    BEGIN
      SET SESSION rand_seed1 = input;
    END;
    PROCEDURE terminate
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          Terminates package
  
          Raises
          ------
  
      '
    IS
    BEGIN
    END;
    FUNCTION value (low decimal, high decimal) RETURN decimal(65,38)
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          Gets a random Oracle Database number x, where x is greater than 
          or equal to a specified lower limit and less than a specified 
          higher limit
  
          Raises
          ------
  
      '
    IS
    BEGIN
      if low >= high then 
        SIGNAL SQLSTATE 'HY000' set mysql_errno=3047, message_text='2nd argument must be greater than the 1st'; 
      end if;

      return rand() * (cast(high as decimal(65, 38)) - cast(low as decimal(65, 38))) + cast(low as decimal(65, 38));
    END;
    FUNCTION random RETURN int
      SQL SECURITY INVOKER
      COMMENT '
          Description
          -----------
          Generates a random number
  
          Raises
          ------
  
      '
    IS
    BEGIN
      return convert(dbms_random.value(-pow(2, 31), pow(2, 31) - 1), decimal(65, 0));
    END;
END
$$

DELIMITER ;

SET @@session.sql_mode = @old_sql_mode;
