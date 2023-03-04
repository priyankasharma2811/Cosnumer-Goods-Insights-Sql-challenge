
-- 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region

select market 
from dim_customer 
where customer='Atliq Exclusive' AND region = 'APAC';

-- output
/* 
India
Indonesia
Japan
Philiphines
South Korea
Australia
Newzealand
Bangladesh
 */


/* 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields,
 unique_products_2020, unique_products_2021, percentage_chg */
 
 
select  
(select   count(distinct product_code) from fact_sales_monthly where fiscal_year='2020' )as unique_products_2020 ,
(select   count(distinct product_code) from fact_sales_monthly where fiscal_year='2021' )as unique_products_2021,
(select  (( unique_products_2021-unique_products_2020)/unique_products_2020)*100)as pct_change;

/* output

unique_products_2020	unique_products_2021	pct_change
245						334						36.3265
*/



/* 3.  Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields, segment,product_count*/

SELECT segment,COUNT(DISTINCT product_code) as product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

/* output

segment		product_count
Notebook	129
Accessories	116
Peripherals	84
Desktop		32
Storage		27
Networking	9

*/





/* 4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference */

select seg, product_count_2020, product_count_2021,difference
from
(select p_2020.seg as seg, p_2020.product_count_2020, p_2021.product_count_2021, 
        (p_2021.product_count_2021 - p_2020.product_count_2020) as difference
from
	(select p.segment as 'seg', s.fiscal_year, count(distinct s.product_code) as product_count_2020
	from fact_sales_monthly as s 
    left join dim_product as p on p.product_code=s.product_code 
	where s.fiscal_year=2020
    group by p.segment, s.fiscal_year 
    ) as p_2020
	inner join
    (select  p.segment as 'seg', s.fiscal_year, count(distinct s.product_code)  as product_count_2021
    from fact_sales_monthly s 
    left join dim_product p on p.product_code=s.product_code
	where s.fiscal_year=2021
	group by p.segment,s.fiscal_year
    ) as p_2021
    on p_2020.seg = p_2021.seg
) as t1;

/* output

Segment		product_count_2020 	product_count_2021 	difference
Accessories	69					103					34
Desktop		7					22					15
Networking	6					9					3
Notebook	92					108					16
Peripherals	59					75					16
Storage		12					17					5

*/





/* 5.  Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost*/

select m.product_code,p.product,m.manufacturing_cost from fact_manufacturing_cost m join dim_product p 
on m.product_code=p.product_code where m.manufacturing_cost=(select max(manufacturing_cost) from fact_manufacturing_cost)
union
select m.product_code,p.product,m.manufacturing_cost from fact_manufacturing_cost m join dim_product p 
on m.product_code=p.product_code where m.manufacturing_cost=(select min(manufacturing_cost) from fact_manufacturing_cost);

/* output

product_code	product					manufacturing_cost
A6120110206		AQ HOME Allin1 Gen 2	240.5364
A2118150101		AQ Master wired x1 Ms	0.8920
*/



/* 6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage
*/

SELECT c.customer, c.customer_code,avg(i.pre_invoice_discount_pct) as Avg_discount_pct
 FROM fact_pre_invoice_deductions i 
 inner join dim_customer c on i.customer_code=c.customer_code
 where c.market='India' and i.fiscal_year=2021
 group by c.customer,c.customer_code
 order by Avg_discount_pct desc
 limit 5;

/* Output

customer	custoemr_code	Avg_discount_pct
Flipkart	90002009		0.30830000
Viveks		90002006		0.30380000
Ezone		90002003		0.30280000
Croma		90002002		0.30250000
Amazon 		90002016		0.29330000
*/

/* 7.  Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount 
*/

select EXTRACT(MONTH from s.date) AS Month, s.fiscal_year as Year,
sum(g.gross_price * s.sold_quantity) as gross_sales_amount 
FROM fact_sales_monthly s join fact_gross_price g 
on  s.product_code=g.product_code
join dim_customer c on c.customer_code=s.customer_code
where c.customer='Atliq Exclusive'
group by month,s. fiscal_year
order by s.fiscal_year,month;


/* Output

Month	Year	gross_sales_amount
	1	2020	9584951.9393
	2	2020	8083995.5479
	3	2020	766976.4531
	4	2020	800071.9543
	5	2020	1586964.4768
	6	2020	3429736.5712
	7	2020	5151815.4020
	8	2020	5638281.8287
	9	2020	9092670.3392
	10	2020	10378637.5961
	11	2020	15231894.9669
	12	2020	9755795.0577
	1	2021	19570701.7102
	2	2021	15986603.8883
	3	2021	19149624.9239
	4	2021	11483530.3032
	5	2021	19204309.4095
	6	2021	15457579.6626
	7	2021	19044968.8164
	8	2021	11324548.3409
	9	2021	19530271.3028
	10	2021	21016218.2095
	11	2021	32247289.7946
	12	2021	20409063.1769

*/

/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity */

select 
case when date>='2019-09-01' and date<='2019-11-30' then 'Quarter 1 of 2020'
when date>='2019-12-01' and date<='2020-02-29' then 'Quarter 2 of 2020'
when date>='2020-03-01' and date<='2020-05-31' then 'Quarter 3 of 2020'
when date>='2020-06-01' and date<='2020-08-31' then 'Quarter 4 of 2020'
end as Quarters,sum(sold_quantity) as total_sales_quantity
from fact_sales_monthly
where fiscal_year=2020
group by Quarters
order by total_sales_quantity desc;

/* Output

Quarters			total_sales_quantitiy
Quarter 1 of 2020	7005619
Quarter 2 of 2020	6649642
Quarter 4 of 2020	5042541
Quarter 3 of 2020	2075087

*/

/* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage */



with t as
		(SELECT
		  c.channel as channel,
		  sum(g.gross_price * s.sold_quantity) as gross_sales_mln
		FROM fact_sales_monthly s 
		inner join fact_gross_price g on  s.product_code=g.product_code
		inner join dim_customer c on c.customer_code=s.customer_code
		where s.fiscal_year=2021
		group by c.channel)
select 
	t.channel, round(t.gross_sales_mln) as gross_sales, round((t.gross_sales_mln)*100/t2.total_gross_sales_mln,2) as 'contribution(%)'
FROM t 
join
(SELECT 
	sum(gross_sales_mln) as total_gross_sales_mln
FROM t
) t2;

/* Output

Channel 	Gross_sales 	Contribution(%)
Direct		406686874		15.47
Distributor	297175880		11.31
Retailer	1924170398		73.22

*/




/* 10.  Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
codebasics.io
product
total_sold_quantity
rank_order */



select
 t.* 
from 
(SELECT p.division,p.product_code,p.product,sum(s.sold_quantity ) as total_sold_quantity ,
RANK() over (partition by p.division order by 
sum(s.sold_quantity )desc) as rank_order 
from dim_product p join fact_sales_monthly s
on p.product_code=s.product_code
where fiscal_year=2021
group by p.division,p.product_code,p.product) t
where t.rank_order <=3;




/* output
Division Product_code   Product					Sold_quantity 	Rank_order
N & S	A6720160103	    AQ Pen Drive 2 IN 1		701373		  	1
N & S	A6818160202		AQ 	Pen Drive DRC		688003			2
N & S	A6819160203		AQ  Pen Drive DRC		676245			3
P & A	A2319150302		AQ  Gamers Ms			428498			1
P & A	A2520150501		AQ  Maxima Ms			419865			2
P & A	A2520150504		AQ  Maxima Ms			419471			3
PC	    A4218110202		AQ 	Digit				17434			1
PC	    A4319110306		AQ Velocity				17280			2
PC	    A4218110208		AQ Digit				17275			3

*/




