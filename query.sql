-- 1. Top 10 najbardziej dochodowych filmów
-- Cel: pokazać, które tytuły generują największy przychód.


	SELECT 
		f.title, 
		SUM(p.amount) AS revenue 
	FROM film f 
	JOIN inventory inv ON inv.film_id = f.film_id
	JOIN rental r ON inv.inventory_id = r.inventory_id
	JOIN payment p ON p.rental_id = r.rental_id
	GROUP BY 1
	ORDER BY revenue DESC
	LIMIT 10


-- 2. Przychody w podziale na kategorie filmów
-- Cel: porównać, które gatunki filmów są najbardziej opłacalne.


	SELECT 
		cat.name, 
		ROUND(SUM(p.amount),0) AS revenue 
	FROM category cat 
	JOIN film_category fc ON fc.category_id = cat.category_id
	JOIN film f ON f.film_id = fc.film_id
	JOIN inventory inv ON inv.film_id = f.film_id
	JOIN rental r ON inv.inventory_id = r.inventory_id
	JOIN payment p ON p.rental_id = r.rental_id
	GROUP BY 1
	ORDER BY revenue DESC


-- 3. Ranking klientów wg łącznej kwoty wydanej na wypożyczenia
-- Cel: zidentyfikować najcenniejszych klientów (ang. Top Value Customers).


	SELECT 
		c.customer_id, 
		c.first_name, 
		SUM(p.amount) AS suma 
	FROM customer c
	JOIN rental r ON r.customer_id = c.customer_id
	JOIN payment p ON p.rental_id = r.rental_id
	GROUP BY 1,2
	ORDER BY 3 DESC

-- 4. Przychody miesięczne (analiza trendów w czasie)
-- Cel: sprawdzić sezonowość – w których miesiącach wypożyczalnia zarabia najwięcej.


	SELECT 
		EXTRACT(YEAR FROM p.payment_date) as year, 
		EXTRACT(MONTH FROM p.payment_date) as month, 
		SUM(amount) AS revenue FROM payment p
	GROUP BY 1,2
	ORDER BY 3 DESC



-- 5. Najbardziej aktywni pracownicy
-- Cel: ranking pracowników wg liczby obsłużonych transakcji.


	SELECT 
		s.staff_id, 
		s.first_name, 
		s.last_name, 
		COUNT(p.payment_id) AS activity 
	FROM staff s
	JOIN payment p ON p.staff_id = s.staff_id
	GROUP BY 1,2,3
	ORDER BY activity DESC

-- 6. Średnia długość wypożyczenia w dniach dla każdego filmu
-- Cel: ocenić, które filmy są “dłużej trzymane” przez klientów.

	SELECT 
		f.title, 
		ROUND(AVG(EXTRACT(DAY FROM (r.return_date - r.rental_date))), 2) AS avg_rental_days
	FROM film f 
	JOIN inventory inv ON inv.film_id = f.film_id
	JOIN rental r ON inv.inventory_id = r.inventory_id
	JOIN payment p ON p.rental_id = r.rental_id
	GROUP BY 1
	ORDER BY avg_rental_days DESC





-- 7. Udział procentowy przychodów poszczególnych sklepów (CTE + window function)
-- Cel: porównanie efektywności sklepów.

	WITH STORE_REVENUE AS 
	(
		SELECT 
			s.store_id,
			ROUND(SUM(p.amount), 2) AS total_revenue
		FROM payment p
		JOIN staff s ON s.staff_id = p.staff_id
		JOIN store st ON st.store_id = s.store_id
		GROUP BY s.store_id
	)
	SELECT 
		store_id,
		total_revenue,
		ROUND(((100*total_revenue)/SUM(total_revenue) OVER ()),2) AS percentage
	FROM STORE_REVENUE


