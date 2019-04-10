CREATE FUNCTION temporary.merge_payments(myId INT) RETURNS VOID AS
$$
DECLARE
iterator integer := 1;
BEGIN
	WHILE iterator <= 5 LOOP
		BEGIN
			INSERT INTO public.smart_payment (company_id, payment_method, amount, ticket_id, db_id, reference_id, date_time, created_at, updated_at)
	  			SELECT company_id, payment_method, amount, ticket_id, db_id, reference_id, date_time, created_at, updated_at
        		FROM temporary.temp_payment 
				WHERE id = myId;
		
	 		UPDATE temporary.temp_payment
	 			SET migration_status='inserted',
		    		migration_count = iterator
	 		WHERE id = myId; 
			RETURN;
		EXCEPTION
      		WHEN integrity_constraint_violation THEN
	  		BEGIN
        		UPDATE public.smart_payment
					SET company_id = subquery.company_id, 
       					payment_method = subquery.payment_method, 
	   					amount = subquery.amount, 
	   					ticket_id = subquery.ticket_id, 
	   					db_id = subquery.db_id, 
	   					reference_id = subquery.reference_id, 
	   					date_time = subquery.date_time, 
	   					created_at = subquery.created_at, 
	   					updated_at = subquery.updated_at
				FROM (SELECT * FROM  temporary.temp_payment WHERE id = myId) AS subquery
				WHERE public.smart_payment.company_id = subquery.company_id AND  public.smart_payment.ticket_id = subquery.ticket_id;
			
				UPDATE temporary.temp_payment
	 				SET migration_status='updated',
				    migration_count = iterator
	 			WHERE id = myId;
			
				RETURN;
			END;
			WHEN OTHERS THEN
			BEGIN
				IF iterator == 5 THEN
				UPDATE temporary.temp_payment
	 				SET migration_status='error',
						migration_error='Some error',
						migration_count = iterator
	 			WHERE id = myId;
			
				RETURN;
				END IF;
			END;
		END;
      END LOOP;
END;
$$
LANGUAGE plpgsql;