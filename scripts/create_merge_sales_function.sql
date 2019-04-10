CREATE FUNCTION temporary.merge_sales(myId INT) RETURNS VOID AS
$$
DECLARE
iterator integer := 1;
BEGIN
	WHILE iterator <= 5 LOOP
		BEGIN
			INSERT INTO public.smart_sale (db_id, uid, type, company_id, reference_id, payed, category_uid, product_uid, inventory_uid, ticket_id, strain, weight, date_time, created_at, updated_at, price_post_everything, tax_collected, price_adjusted_for_ticket_discounts, tax_excise, tax_breakdown_hist, tax_collected_excise, is_medical)
	  			SELECT db_id, uid, type, company_id, reference_id, payed, category_uid, product_uid, inventory_uid, ticket_id, strain, weight, date_time, created_at, updated_at, price_post_everything, tax_collected, price_adjusted_for_ticket_discounts, tax_excise, tax_breakdown_hist, tax_collected_excise, is_medical
        		FROM temporary.temp_sale
				WHERE id = myId;
		
	 		UPDATE temporary.temp_sale
	 			SET migration_status='inserted',
		    		migration_count = iterator
	 		WHERE id = myId; 
			RETURN;
		EXCEPTION
      		WHEN integrity_constraint_violation THEN
	  		BEGIN
        		UPDATE public.smart_sale
					SET db_id = subquery.db_id, 
					uid = subquery.uid, 
					type = subquery.type, 
					company_id = subquery.company_id, 
					reference_id = subquery.reference_id, 
					payed = subquery.payed, 
					category_uid = subquery.category_uid, 
					product_uid = subquery.product_uid, 
					inventory_uid = subquery.inventory_uid, 
					ticket_id = subquery.ticket_id, 
					strain = subquery.strain, 
					weight = subquery.weight, 
					date_time = subquery.date_time, 
					created_at = subquery.created_at, 
					updated_at = subquery.updated_at, 
					price_post_everything = subquery.price_post_everything, 
					tax_collected = subquery.tax_collected, 
					price_adjusted_for_ticket_discounts = subquery.price_adjusted_for_ticket_discounts, 
					tax_excise = subquery.tax_excise, 
					tax_breakdown_hist = subquery.tax_breakdown_hist, 
					tax_collected_excise = subquery.tax_collected_excise, 
					is_medical = subquery.is_medical
				FROM (SELECT * FROM  temporary.temp_sale WHERE id = myId) AS subquery
				WHERE public.smart_sale.company_id = subquery.company_id AND  public.smart_sale.ticket_id = subquery.ticket_id;
			
				UPDATE temporary.temp_sale
	 				SET migration_status='updated',
				    migration_count = iterator
	 			WHERE id = myId;
			
				RETURN;
			END;
			WHEN OTHERS THEN
			BEGIN
				IF iterator == 5 THEN
				UPDATE temporary.temp_sale
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