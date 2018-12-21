USE `DFdcelitt`;
DROP procedure IF EXISTS `dataqa`;

DELIMITER $$
USE `DFdcelitt`$$
CREATE DEFINER=`tbnguyen3`@`%` PROCEDURE `dataqa`(IN uploadid_set INT,IN uploadid_subset INT)

##### 12/20/2018
##NOTE:
##how to run:  call DFdcelitt.dataqa(set,subset);
##Goal: check if subet is indeed subset of the set.
##example: call DFdcelitt.dataqa(102,108)
## if excelUpload 102 it is not subset, it will list the extra columns that does not belong to the set
#######
BEGIN
  DECLARE header1 varchar(32766);
  DECLARE header2 varchar(32766);
  DECLARE temp varchar(32766);
  DECLARE len INT;
  DECLARE i int default 0;
  DECLARE is_error INT default 0;
  ## assign excel header to variables headerX accordingly (header 1=set, header2=subset)
  SELECT header INTO header1 FROM ClinicalStudies.excelUpload where header is not null and uploadID = uploadid_set;
  SELECT header INTO header2 FROM ClinicalStudies.excelUpload where header is not null and uploadID = uploadid_subset;
  
  #initially empty array 
  SET @array = JSON_ARRAY();
  
  select JSON_LENGTH (header2) INTO len;
  #loop through subset and check if there is outside element
  WHILE i < len DO
    SELECT JSON_CONTAINS(header1, JSON_EXTRACT (header2, CONCAT('$[',i,']') ) ) INTO temp;
    #if there is outsider, append to array and show error output
    if temp = 0 THEN
      SET is_error = 1;
      SELECT JSON_ARRAY_APPEND ( @array, '$', JSON_EXTRACT (header2, CONCAT('$[',i,']')) ) into @array;
      
    END IF;
    SET i = i + 1;
  END WHILE;

  #signal error when it is not subset
  if is_error = 1 THEN  
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = @array;  
  END IF;
  
END$$

DELIMITER ;

