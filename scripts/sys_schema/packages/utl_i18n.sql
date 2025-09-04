DROP PACKAGE IF EXISTS utl_i18n;

SET @old_sql_mode = @@session.sql_mode, @@session.sql_mode = oracle;

DELIMITER $$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE utl_i18n
  SQL SECURITY INVOKER
  COMMENT 'Collection of routines to manipulate RAW data'
  AS
    FUNCTION transliterate(val VARCHAR2(255) CHARACTER SET ANY_CS, name VARCHAR2(255)) RETURN VARCHAR2(255) CHARACTER SET ANY_CS
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function performs script transliteration.

              Parameters
              -----------

              val (VARCHAR2):
                Specifies the data to be converted.
              name (VARCHAR2):
                Specifies the transliteration name string.
              
              Returns
              -------

                The converted string.
              '
    ;
    FUNCTION raw_to_char(jc RAW, charset_or_collation VARCHAR(255)) RETURN VARCHAR2
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function converts RAW data from a valid character set to a
              VARCHAR2 string in the database character set. 

              Parameters
              -----------

              jc (RAW):
                Specifies the RAW data to be converted to a VARCHAR2 string
              charset_or_collation (VARCHAR):
                Specifies the character set that the RAW data was derived from.
              
              Returns
              -------

                the VARCHAR2 string equivalent in the database character set of
                the RAWA data. 
              '
    ;
    FUNCTION string_to_raw(jc VARCHAR2, charset_or_collation VARCHAR(255)) RETURN RAW
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function converts a VARCHAR2 string to another valid
              character set and returns the result as RAW data.

              Parameters
              -----------

              jc (VARCHAR2):
                Specifies the VARCHAR2 or NVARCHAR2 string to convert.
              charset_or_collation (VARCHAR):
                Specifies the destination character set.
              
              Returns
              -------

                RAW data representation of the input string in the new character set
              '
    ;
END
$$

CREATE DEFINER='mariadb.sys'@'localhost' PACKAGE BODY utl_i18n
  SQL SECURITY INVOKER
  AS
    FUNCTION transliterate(val VARCHAR2(255) CHARACTER SET ANY_CS, name VARCHAR2(255)) RETURN VARCHAR2(255) CHARACTER SET ANY_CS
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function performs script transliteration.

              Parameters
              -----------

              val (VARCHAR2):
                Specifies the data to be converted.
              name (VARCHAR2):
                Specifies the transliteration name string.
              
              Returns
              -------

                The converted string.
              '
    AS
    BEGIN
      RETURN transliterate(val, name);
    END;

    FUNCTION raw_to_char(jc RAW, charset_or_collation VARCHAR(255)) RETURN VARCHAR2
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function converts RAW data from a valid character set to a
              VARCHAR2 string in the database character set. 

              Parameters
              -----------

              jc (RAW):
                Specifies the RAW data to be converted to a VARCHAR2 string
              charset_or_collation (VARCHAR):
                Specifies the character set that the RAW data was derived from.
              
              Returns
              -------

                the VARCHAR2 string equivalent in the database character set of
                the RAWA data. 
        '
    IS
    BEGIN
      SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.SESSION_VARIABLES WHERE VARIABLE_NAME = 'character_set_results' into @dst_charset; 
      #SET @query_string = CONCAT('SELECT CAST(CONVERT(\'', jc, '\' USING \'', charset_or_collation, '\') AS VARCHAR2) INTO @converted_string'); 
      #PREPARE stmt FROM @query_string; 
      #EXECUTE stmt; 
      #DEALLOCATE PREPARE stmt; 
      #select @converted_string;

      #SET @query_string2 = CONCAT('SELECT CONVERT(\'', @converted_string, '\' USING \'', @dst_charset, '\') INTO @converted_string2'); 
      #PREPARE stmt2 FROM @query_string2; 
      #EXECUTE stmt2; 
      #DEALLOCATE PREPARE stmt2; 
      #select @converted_string2;
      
      CASE charset_or_collation
        WHEN 'utf8' THEN
          CASE @dst_charset
            WHEN 'utf8mb3' THEN
              Set @sjis_str = CAST(CONVERT(jc USING utf8) AS VARCHAR2);
              SET @s = CONVERT(@sjis_str USING utf8mb3);
            ELSE
              RETURN NULL;
          END CASE;
        WHEN 'utf8mb3' THEN
          CASE @dst_charset
            WHEN 'utf8mb4' THEN
              Set @sjis_str = CAST(CONVERT(jc USING utf8mb3) AS VARCHAR2);
              SET @s = CONVERT(@sjis_str USING utf8mb4);
            ELSE
              RETURN NULL;
          END CASE;
        ELSE
          RETURN NULL;
      END CASE;
      
      set @t = UNHEX(HEX(@s)); 

      CASE @dst_charset
        WHEN 'utf8mb3' THEN
          RETURN CONVERT(@t USING utf8mb3);
        WHEN 'utf8mb4' THEN
          RETURN CONVERT(@t USING utf8mb4);
      END CASE;
      
      #SET @query_string3 = CONCAT('SELECT CONVERT(\'', @t, '\' USING \'', @dst_charset, '\') AS original_string INTO @converted_string3'); 
      #PREPARE stmt3 FROM @query_string3; 
      #EXECUTE stmt3; 
      #DEALLOCATE PREPARE stmt3; 
      #select @converted_string3;
    END;

    FUNCTION string_to_raw(jc VARCHAR2, charset_or_collation VARCHAR(255)) RETURN RAW
      SQL SECURITY INVOKER
      COMMENT '
              Description
              -----------

              This function converts a VARCHAR2 string to another valid
              character set and returns the result as RAW data.

              Parameters
              -----------

              jc (VARCHAR2):
                Specifies the VARCHAR2 or NVARCHAR2 string to convert.
              charset_or_collation (VARCHAR):
                Specifies the destination character set.
              
              Returns
              -------

                RAW data representation of the input string in the new character set
              '
    AS
    BEGIN
      CASE charset_or_collation
        WHEN 'utf8' THEN
          RETURN CAST(CONVERT(jc USING utf8mb4) AS BINARY);
        WHEN 'ucs2' THEN
          RETURN CAST(CONVERT(jc USING ucs2) AS BINARY);
        ELSE
          RETURN NULL;
      END CASE;
    END;

    
END
$$

DELIMITER ;

SET @@session.sql_mode = @old_sql_mode;
