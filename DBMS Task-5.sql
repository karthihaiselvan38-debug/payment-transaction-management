

create database  payment_db;
use payment_db;

create table customers (
    customer_id int primary key,
    customer_name varchar(100) not null,
    email varchar(100) unique,
    phone varchar(15)
);

create table orders (
    order_id int primary key,
    customer_id int not null,
    order_date date not null,
    total_amount decimal(10,2) not null,
    order_status varchar(30) not null,
    foreign key (customer_id) references customers(customer_id),
    check (total_amount >= 0)
);

create table payment (
    payment_id int primary key auto_increment,
    order_id int not null unique,
    payment_date datetime not null default current_timestamp,
    payment_mode varchar(30) not null,
    payment_status varchar(20) not null default 'pending',
    transaction_amount decimal(10,2) not null,

    foreign key (order_id) references orders(order_id),

    check (payment_mode in (
        'upi',
        'credit card',
        'debit card',
        'net banking',
        'cash on delivery'
    )),

    check (payment_status in (
        'pending',
        'success',
        'failed'
    )),

    check (transaction_amount > 0)
);

insert into customers
values
(1, 'arun', 'arun@gmail.com', '9876543210'),
(2, 'bala', 'bala@gmail.com', '9876543211'),
(3, 'divya', 'divya@gmail.com', '9876543212'),
(4, 'kumar', 'kumar@gmail.com', '9876543213'),
(5, 'priya', 'priya@gmail.com', '9876543214');

insert into orders
values
(101, 1, '2026-10-20', 1500.00, 'confirmed'),
(102, 2, '2026-10-21', 2500.00, 'confirmed'),
(103, 3, '2026-10-22', 1000.00, 'pending'),
(104, 4, '2026-10-23', 3000.00, 'confirmed'),
(105, 5, '2026-10-24', 2000.00, 'pending'),
(106, 1, '2026-10-25', 500.00, 'confirmed'),
(107, 2, '2026-10-26', 1200.00, 'confirmed'),
(108, 3, '2026-10-27', 1800.00, 'pending');

insert into payment
(order_id, payment_date, payment_mode, payment_status, transaction_amount)
values
(101, '2026-10-20 10:00:00', 'upi', 'success', 1500.00),
(102, '2026-10-21 11:00:00', 'credit card', 'success', 2500.00),
(103, '2026-10-22 12:00:00', 'debit card', 'failed', 1000.00),
(104, '2026-10-23 13:00:00', 'net banking', 'success', 3000.00),
(105, '2026-10-24 14:00:00', 'cash on delivery', 'pending', 2000.00),
(106, '2026-10-25 15:00:00', 'upi', 'success', 500.00),
(107, '2026-10-26 16:00:00', 'credit card', 'failed', 1200.00),
(108, '2026-10-27 17:00:00', 'debit card', 'pending', 1800.00);

select * from payment;

insert into orders
values (109, 4, '2026-10-27', 750.00, 'pending');

insert into payment
(order_id, payment_mode, payment_status, transaction_amount)
values
(109, 'upi', 'pending', 750.00);

update payment
set payment_mode = 'credit card'
where payment_id = 1;

update payment
set payment_status = 'success',
    payment_date = current_timestamp
where payment_id = 3;

update payment
set payment_status = 'failed'
where payment_id = 5;

update payment
set payment_status = 'pending'
where payment_id = 5;

update payment
set payment_status = 'success',
    payment_date = current_timestamp
where payment_id = 3
and payment_status in ('failed', 'pending');

select *
from payment
where payment_status = 'success';

select *
from payment
where payment_status = 'failed';

select *
from payment
where payment_status = 'pending';

select *
from payment
where order_id = 101;

select count(*) as successful_payments
from payment
where payment_status = 'success';

select count(*) as failed_payments
from payment
where payment_status = 'failed';

select count(*) as pending_payments
from payment
where payment_status = 'pending';

select payment_status, count(*) as total_transactions
from payment
group by payment_status;

select
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.order_status,
    p.payment_id,
    p.payment_date,
    p.payment_mode,
    p.payment_status,
    p.transaction_amount
from customers c
join orders o on c.customer_id = o.customer_id
join payment p on o.order_id = p.order_id;

select payment_mode, count(*) as total_transactions
from payment
group by payment_mode;

select payment_mode, count(*) as total_transactions
from payment
group by payment_mode
order by total_transactions desc
limit 1;

select sum(transaction_amount) as total_revenue
from payment
where payment_status = 'success';

select
    payment_mode,
    sum(transaction_amount) as total_revenue
from payment
where payment_status = 'success'
group by payment_mode;

select round(avg(transaction_amount), 2) as average_amount
from payment;

select round(avg(transaction_amount), 2) as average_successful_amount
from payment
where payment_status = 'success';

select
    c.customer_id,
    c.customer_name,
    o.order_id,
    p.payment_id,
    p.payment_date,
    p.payment_mode,
    p.payment_status,
    p.transaction_amount
from customers c
join orders o on c.customer_id = o.customer_id
join payment p on o.order_id = p.order_id
order by c.customer_id, p.payment_date;

select
    sum(case when payment_status = 'success' then 1 else 0 end)
        as successful_transactions,
    sum(case when payment_status = 'failed' then 1 else 0 end)
        as failed_transactions,
    sum(case when payment_status = 'pending' then 1 else 0 end)
        as pending_transactions
from payment;

select
    o.order_id,
    c.customer_name,
    o.total_amount,
    p.payment_mode,
    p.payment_status
from orders o
join customers c on o.customer_id = c.customer_id
join payment p on o.order_id = p.order_id
where p.payment_status in ('failed', 'pending');

select
    o.order_id,
    c.customer_name,
    o.total_amount
from orders o
join customers c on o.customer_id = c.customer_id
left join payment p on o.order_id = p.order_id
where p.payment_id is null;

select
    payment_status,
    sum(transaction_amount) as total_amount
from payment
group by payment_status;

select
    c.customer_id,
    c.customer_name,
    sum(p.transaction_amount) as successful_revenue
from customers c
join orders o on c.customer_id = o.customer_id
join payment p on o.order_id = p.order_id
where p.payment_status = 'success'
group by c.customer_id, c.customer_name;

select *
from payment
order by transaction_amount desc;

select *
from payment
where payment_mode = 'upi';

select *
from payment
where payment_date between '2026-10-20 00:00:00'
and '2026-10-27 23:59:59';

select * from payment;
