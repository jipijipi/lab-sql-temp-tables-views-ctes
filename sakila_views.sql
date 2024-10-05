USE sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
DROP VIEW IF EXISTS customer_rental_summary;
CREATE VIEW customer_rental_summary AS
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM 
    customer
JOIN 
    rental ON customer.customer_id =rental.customer_id
GROUP BY 
    customer.customer_id;
    
-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    customer_rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM 
    customer_rental_summary
JOIN 
    payment ON customer_rental_summary.customer_id = payment.customer_id
GROUP BY 
    customer_rental_summary.customer_id;

SELECT * FROM customer_payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary AS (
    SELECT 
        customer_rental_summary.first_name,
        customer_rental_summary.last_name,
        customer_rental_summary.email,
        customer_rental_summary.rental_count,
        customer_payment_summary.total_paid
    FROM 
        customer_rental_summary customer_rental_summary
    JOIN 
        customer_payment_summary customer_payment_summary ON customer_rental_summary.customer_id = customer_payment_summary.customer_id
)
SELECT 
    first_name,
    last_name,
    email,
    rental_count,
    total_paid,
    total_paid / rental_count AS average_payment_per_rental
FROM 
    customer_summary;

