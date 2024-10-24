-- What are the top 5 brands by receipts scanned among users 21 and over?

with cte1 as (

select p.BRAND, 
	count(distinct t.RECEIPT_ID) as receipt_cnt
from transaction as t
join user
	on t.USER_ID=user.ID and BIRTH_DATE <= date('now', '-21 years') -- Only keep the users who are over 21
join product as p
	on p.BARCODE=t.BARCODE
where p.BRAND is not null -- Don't consider null brand
group by p.BRAND
)

, cte2 as (

select BRAND, receipt_cnt,
	rank () over (order by receipt_cnt desc) as ranking -- Get ranking using window function
from cte1
)

select BRAND
from cte2
where ranking <=5;

-- Result:
-- BRAND
-- DOVE
-- NERDS CANDY
-- COCA-COLA
-- HERSHEY'S
-- SOUR PATCH KIDS


-- What are the top 5 brands by sales among users that have had their account for at least six months?

with cte1 as (
	select p.BRAND, 
	sum(t.FINAL_SALE) as total_sales -- Calculate total sales by brand
from transaction as t
join user
	on t.USER_ID=user.ID and CREATED_DATE <= date('now', '-6 months') -- Users who had account for more than 6 months

join product as p
	on p.BARCODE=t.BARCODE
where p.BRAND is not null
group by p.BRAND
)
, cte2 as (select BRAND, total_sales,
	rank () over (order by total_sales desc) as ranking
from cte1)

select BRAND
from cte2
where ranking <=5;

-- Result:
-- BRAND
-- COCA-COLA
-- ANNIE'S HOMEGROWN GROCERY
-- DOVE
-- BAREFOOT
-- ORIBE

-- Which is the leading brand in the Dips & Salsa category?
-- Assumption: Many records don't have a brand, while it is informative, we are looking for a specific brand name.

with cte1 as (
	select distinct BRAND
		, sum(t.FINAL_SALE) as total_sale -- Total sales amount
		, sum(t.final_QUANtity) as total_quantity -- Total sold quantity
		, count(distinct t.receipt_id) as receipt_scanned -- How many times users are buying 
	from product as p
	join transaction as t
		on p.BARCODE=t.BARCODE
	where p.CATEGORY_2 = 'Dips & Salsa' and brand is not null -- Many brand appears as null, so remove those to get a specific brand name
	group by BRAND
	)
	, cte2 as ( -- Rank all three factors to evaluate those brands
	select BRAND,
		total_sale,
		total_quantity,
		receipt_scanned,
		rank () over (order by total_sale desc) as sale_rank,
		rank() over (order by total_quantity desc) as quantity_rank,
		rank() over (order by receipt_scanned desc) as receipt_rank
	from cte1

	)
	select brand 
	from cte2 
	where sale_rank<=5 and quantity_rank<=5 and receipt_rank<=5;-- Since we are looking for a leading brand, want to make sure that it is doing good in all three rankings.

-- BRAND
-- TOSTITOS
-- FRITOS
