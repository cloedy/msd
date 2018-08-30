-- this file is recorded trying using multiple cursors to resolve problems 
-- will optimize it later

DROP PROCEDURE IF EXISTS p1;
delimiter //
CREATE PROCEDURE  p1()
BEGIN
    DECLARE done1,done2,done3 INT DEFAULT 0;
    DECLARE vuc_id INT DEFAULT 0;
    DECLARE collect_cursor CURSOR FOR \
    SELECT id  FROM vws_user_collect WHERE invoice_status > 0 and id in(2771, 2772);
    DECLARE EXIT HANDLER FOR NOT FOUND SET done1 = 1;

    OPEN collect_cursor;
    loop1: LOOP
        IF done1 THEN
            leave loop1;
        END IF;
        fetch collect_cursor into vuc_id;
        select vuc_id;
        BEGIN
            DECLARE vuci_cid, vuci_img_type INT DEFAULT 0;
            DECLARE vuci_filepath char(100) DEFAULT '';
            DECLARE collectimg_cursor CURSOR FOR \
            SELECT collect_id, img_type, filepath FROM vws_user_collect_img WHERE status = 1 and collect_id = vuc_id;
            DECLARE EXIT HANDLER FOR NOT FOUND SET done2 = 1;

            OPEN collectimg_cursor;
            loop2: LOOP
                IF done2 THEN
                    leave loop2;
                END IF;
                fetch collectimg_cursor into vuci_cid, vuci_img_type, vuci_filepath;
                IF vuci_cid THEN
                    BEGIN
                        DECLARE vcl_id int DEFAULT 0;
                        DECLARE cooperate_cursor CURSOR FOR SELECT coid FROM vws_cooperate_log WHERE collect_id = vuci_cid;
                        DECLARE EXIT HANDLER FOR NOT FOUND SET done3 = 1;

                        OPEN cooperate_cursor;
                        loop3: LOOP
                            IF done3 THEN
                                leave loop3;
                            END IF;
                            fetch cooperate_cursor into vcl_id;
                            IF vcl_id THEN
                                set @cc := (select count(*) from vws_cooperate_img where coid = vcl_id and img = vuci_filepath and type = vuci_img_type);
                                IF @cc = 0 THEN
                                    insert into vws_cooperate_img (coid, img, type, is_show, create_time) values (vcl_id, vuci_filepath, vuci_img_type, 1, unix_timestamp());
                                    select last_insert_id();
                                END IF;
                            END IF;
                        END LOOP;
                        close cooperate_cursor;
                    END;
                END IF;
            END LOOP;
            close collectimg_cursor;
        END;
    END LOOP;
    close collect_cursor;
END//
delimiter ;


