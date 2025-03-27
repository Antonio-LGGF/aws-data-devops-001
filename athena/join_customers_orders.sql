SELECT 
  c.customer_id, 
  c.name, 
  o.order_id, 
  o.amount
FROM 
  "data_lake_db"."customers" c
JOIN 
  "data_lake_db"."orders" o 
ON 
  c.customer_id = o.customer_id
LIMIT 10;
