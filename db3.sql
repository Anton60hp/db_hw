-- Задание 1
select 
	c."name",
	c.email,
	c.phone,
	count(distinct h.id_hotel) as hotel_count,
	count(b.id_booking) as booking_count, 
	STRING_AGG(distinct h."name", ', ') as hotel_list,
	AVG(b.check_out_date - b.check_in_date) as avg_stay
from customer c 
join booking b on c.id_customer = b.id_customer
join room r on b.id_room = r.id_room
join hotel h on r.id_hotel = h.id_hotel 
group by c.id_customer
having 
	count(distinct h.id_hotel) > 1 and
	count(b.id_booking) > 2
order by booking_count




-- Задание 2
with s1 as (
	select 
		c.id_customer, 
		c."name",
		count(distinct b.id_booking) as bookings_count,
		count(distinct h.id_hotel) as hotels_count,
		sum(r.price * (b.check_out_date - b.check_in_date)) as spent
	from customer c 
	join booking b on c.id_customer = b.id_customer
	join room r on b.id_room = r.id_room
	join hotel h on r.id_hotel = h.id_hotel 
	group by c.id_customer
),
s2 as (
	select 
		c.id_customer, 
		c."name",
		sum(r.price * (b.check_out_date - b.check_in_date)) as spent,
		count(distinct b.id_booking) as bookings_count
	from customer c 
	join booking b on c.id_customer = b.id_customer
	join room r on b.id_room = r.id_room
	group by c.id_customer
	having sum(r.price * (b.check_out_date - b.check_in_date)) > 500
)
select 
    s1.id_customer,
    s1.name,
    s1.bookings_count,
    s1.spent,
    s1.hotels_count
from s1
where exists (
    select 1 
    from s2 
    where s2.id_customer = s1.id_customer
)
order by s1.spent asc;

-- Задание 3
with hotel_categories as (
    -- Категоризация отелей
    select 
        h.id_hotel,
        h.name as hotel,
        h.location,
        avg(r.price) as avg_price,
        case 
            when avg(r.price) < 175 then 'Дешевый'
            when avg(r.price) between 175 and 300 then 'Средний'
            else 'Дорогой'
        end as hotel_category
    from 
        hotel h
        join room r on h.id_hotel = r.id_hotel
    group by 
        h.id_hotel, h.name, h.location
),

customer_preferences as (
    -- Анализ предпочтений клиентов.
    select 
        c.id_customer,
        c.name,
        case 
            when max(case when hc.hotel_category = 'Дорогой' then 3 
                          when hc.hotel_category = 'Средний' then 2
                          else 1 end) = 3 then 'Дорогой'
            when max(case when hc.hotel_category = 'Средний' then 2
                          else 1 end) = 2 then 'Средний'
            else 'Дешевый'
        end as preferred_hotel_type,
        STRING_AGG(distinct hc.hotel, ', ' order by hc.hotel) as visited_hotels
    from 
        customer c
        join booking b on c.id_customer = b.id_customer
        join room r on b.id_room = r.id_room
        join hotel_categories hc on r.id_hotel = hc.id_hotel
    group by 
        c.id_customer, c.name
)

-- Вывод информации
select 
    id_customer,
    name,
    preferred_hotel_type,
    visited_hotels
from 
    customer_preferences cp
order by 
    case preferred_hotel_type
        when 'Дешевый' then 1
        when 'Средний' then 2
        when 'Дорогой' then 3
    end,
    name;

