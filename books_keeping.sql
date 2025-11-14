create database library_db;
use library_db;
CREATE TABLE books (
book_id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(100) NOT NULL,
author VARCHAR(50) NOT NULL,
category VARCHAR(50),
price DECIMAL(8,2),
publish_date DATE
);
CREATE TABLE borrowers (
borrow_id INT PRIMARY KEY AUTO_INCREMENT,
book_id INT,
borrower_name VARCHAR(50) NOT NULL,
borrow_date DATE,
return_date DATE,
rating DECIMAL(5,2),
fine DECIMAL(6,2),
FOREIGN KEY (book_id) REFERENCES books(book_id)
);

select * from books;

INSERT INTO books (title, author, category, price, publish_date) VALUES
('The Lost Kingdom', 'Arun Menon', 'Fiction', 450.00, '2022-05-12'),
('Science Wonders', 'Riya Nair', 'Science', 620.50, '2023-08-01'),
('Python Basics', 'Jenish L', 'Technology', 550.00, '2024-01-10'),
('Life of Stars', 'Anu George', 'Science', 700.75, '2022-12-05'),
('The Ancient Tales', 'Ramesh Iyer', 'History', 480.00, '2021-03-15'),
('Future AI', 'Meera Das', 'Technology', 890.00, '2024-06-19'),
('Cooking Magic', 'Asha Kumar', 'Cooking', 350.00, '2020-09-09'),
('World Geography', 'Kiran Babu', 'Education', 500.00, '2019-11-23'),
('Dream Life', 'Sana Ali', 'Fiction', 300.00, '2023-02-18'),
('Space Time', 'Dr. Rajesh', 'Science', 920.00, '2024-09-01');
INSERT INTO borrowers (book_id, borrower_name, borrow_date, return_date, rating,
fine) VALUES
(1, 'Akhil Joseph', '2024-04-01', '2024-05-10', 8.5, 0.00),
(2, 'Beena Thomas', '2024-06-05', '2024-07-15', 9.0, NULL),
(3, 'Cyril Mathew', '2024-08-10', '2024-08-25', NULL, 10.00),
(4, 'Deepa Anil', '2024-03-20', '2024-05-22', 7.5, 15.00),
(6, 'Anjali Menon', '2024-09-02', '2024-09-20', 9.3, 0.00),
(9, 'Arjun Lal', '2024-05-11', '2024-06-30', NULL, 5.00),
(10, 'Suhail K', '2024-09-10', '2024-10-01', 8.0, NULL),
(5, 'Neethu P', '2024-02-15', '2024-03-01', 7.8, 20.00);

select * from borrowers;

SELECT * FROM books WHERE category = 'Fiction';
SELECT * FROM books WHERE price > 500;
SELECT * FROM borrowers WHERE return_date > '2024-05-01';
SELECT * FROM borrowers WHERE borrower_name LIKE '%A%';
SELECT * FROM books WHERE publish_date < '2023-01-01';

SELECT UPPER(title) AS upper_title, LOWER(author) AS lower_author FROM books;

SELECT title, LENGTH(title) AS title_length FROM books;

SELECT borrower_name, LENGTH(borrower_name) AS name_length FROM borrowers;

SELECT CONCAT(borrower_name, ' borrowed ', title) AS borrow_info
FROM borrowers b JOIN books bk ON b.book_id = bk.book_id;

SELECT borrower_name, ABS(fine - rating) AS abs_diff FROM borrowers;

SELECT title, ROUND(price) AS round_price FROM books;

SELECT borrower_name, ROUND(rating) AS round_rating FROM borrowers;

select category, count(*) as total_books from books group by category;

select category, avg(price) as avg_price from books group by category;

select max(rating) as highest_rating, sum(fine) as total_fines from borrowers;

select count(*) as top_rated_borrowers from borrowers where rating >= 8;


select b.borrower_name, bk.title, bk.author, b.rating
from borrowers b inner join books bk on b.book_id = bk.book_id;

select bk.title, b.borrower_name
from books bk left join borrowers b on bk.book_id = b.book_id;

select b.borrower_name, bk.title
from books bk right join borrowers b on bk.book_id = b.book_id;

select bk.title, b.borrower_name
from books bk left join borrowers b on bk.book_id = b.book_id
union
select b.borrower_name, bk.title
from books bk right join borrowers b on bk.book_id = b.book_id;

select borrower_name, sum(fine) as total_fine from borrowers group by borrower_name;

select bk.category, avg(b.rating) as avg_rating from books bk left join borrowers b on bk.book_id = b.book_id
group by bk.category;

SET SQL_SAFE_UPDATES = 1;
update borrowers set fine = 25.00 where borrower_name = 'Cyril Mathew';
delete from borrowers where borrower_name = 'Neethu P';
truncate table borrowers;

select borrower_name, sum(fine) as total_fine
from borrowers group by borrower_name having total_fine > 50;

select * from books
where category in ('Fiction', 'Science') and publish_date > '2022-01-01';

DELIMITER //
CREATE PROCEDURE show_all_books()
BEGIN
SELECT * FROM books;
END //
DELIMITER ;
CALL show_all_books();

DELIMITER //
CREATE PROCEDURE get_borrower_by_name(IN borrower VARCHAR(50))
BEGIN
SELECT * FROM borrowers WHERE borrower_name = borrower;
END //
DELIMITER ;
call get_borrower_by_name('Beena Thomas');

CREATE VIEW view_borrower_books AS
SELECT b.borrower_name, bk.title, bk.author, b.rating, b.fine
FROM borrowers b JOIN books bk ON b.book_id = bk.book_id;

select * from view_borrower_books;

CREATE VIEW view_books_borrow_count AS
SELECT bk.title, bk.category, COUNT(b.borrow_id) AS times_borrowed
FROM books bk LEFT JOIN borrowers b ON bk.book_id = b.book_id
GROUP BY bk.title, bk.category;

SELECT * FROM view_borrower_books;
SELECT * FROM view_books_borrow_count;

CREATE TABLE borrow_log(
log_id int AUTO_INCREMENT PRIMARY KEY,
borrower_name VARCHAR(50),
action VARCHAR(50),
log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
CREATE TRIGGER after_borrow_insert
AFTER INSERT ON borrowers
FOR EACH ROW
BEGIN
INSERT INTO borrow_log (borrower_name, action)
VALUES (new.borrower_name, 'Borrowed');
END //
DELIMITER //;

DELIMITER //
CREATE TRIGGER after_borrow_delete
AFTER DELETE ON borrowers
FOR EACH ROW
BEGIN
INSERT INTO borrow_log (borrower_name, action)
VALUES (OLD.borrower_name, 'Deleted');
END //
DELIMITER ;
SELECT * FROM borrow_log;

CREATE INDEX idx_category on books(category);
CREATE INDEX idx_borrower_name on borrowers(borrower_name);

CREATE USER 'lib_user'@'localhost' IDENTIFIED by 'lib123';
GRANT SELECT, INSERT, UPDATE on library_db.* to 'lib_user'@'localhost';
REVOKE delete on library_db.* FROM 'lib_user'@'localhost';
DROP user 'lib_user'@'localhost';


START TRANSACTION;
UPDATE borrowers SET fine = fine + 10 WHERE fine IS NOT NULL;
SAVEPOINT before_reset;
UPDATE borrowers SET fine = 0 WHERE borrower_name = 'Akhil Joseph';
ROLLBACK TO before_reset;
COMMIT;












