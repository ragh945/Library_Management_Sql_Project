CREATE DATABASE IF NOT EXISTS  LIBRARY;
USE LIBRARY;

CREATE TABLE IF NOT EXISTS PUBLISHER (
    publisher_publisherName VARCHAR(255),
    publisher_publisherAddress VARCHAR(255),
    publisher_PublisherPhone VARCHAR(255),
    PRIMARY KEY (publisher_publisherName)
);

CREATE TABLE IF NOT EXISTS BORROWER (
    borrower_cardno INT,
    borrower_borrowerName VARCHAR(255),
    borrower_borrowerAddress VARCHAR(255),
    borrower_borrowerPhone VARCHAR(255),
    PRIMARY KEY (borrower_cardno)
);
                      
CREATE TABLE  IF NOT EXISTS LIBRARYBRANCH (
    library_branch_id INT AUTO_INCREMENT,
    library_branch_branchname VARCHAR(255),
    library_branch_branchaddress VARCHAR(255),
    PRIMARY KEY (library_branch_id)
);
                      
CREATE TABLE IF NOT EXISTS BOOK (
    book_bookid INT,
    book_title VARCHAR(255),
    book_publishername VARCHAR(255),
    PRIMARY KEY (book_bookid),
    FOREIGN KEY (book_publishername)
        REFERENCES publisher (publisher_publishername)
        ON DELETE CASCADE
);
                      
CREATE TABLE IF NOT EXISTS BOOKAUTHORS (
    book_authors_authorid INT AUTO_INCREMENT,
    book_authors_bookid INT,
    book_authors_authorname VARCHAR(255),
    PRIMARY KEY (book_authors_authorid),
    FOREIGN KEY (book_authors_bookid)
        REFERENCES book (book_bookid)
        ON DELETE CASCADE
);
                         
	CREATE TABLE IF NOT EXISTS BOOKLOANS (
    book_loans_loansid INT AUTO_INCREMENT,
    book_loans_bookid INT,
    book_loans_branchid INT,
    book_loans_cardno INT,
    book_loans_dateout DATE,
    book_loans_duedate DATE,
    PRIMARY KEY (book_loans_loansid),
    FOREIGN KEY (book_loans_bookid)
        REFERENCES book (book_bookid)
        ON DELETE CASCADE,
    FOREIGN KEY (book_loans_branchid)
        REFERENCES librarybranch (library_branch_id)
        ON DELETE CASCADE,
    FOREIGN KEY (book_loans_cardno)
        REFERENCES borrower (borrower_cardno)
        ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS BOOKCOPIES (
    book_copies_copiesid INT AUTO_INCREMENT,
    book_copies_bookid INT,
    book_copies_branchid INT,
    book_copies_no_of_copies INT,
    PRIMARY KEY (book_copies_copiesid),
    FOREIGN KEY (book_copies_bookid)
        REFERENCES book (book_bookid)
        ON DELETE CASCADE,
    FOREIGN KEY (book_copies_branchid)
        REFERENCES librarybranch (library_branch_id)
        ON DELETE CASCADE
);
                      
-- Displaying tables in library database
SELECT * FROM PUBLISHER;
SELECT * FROM BORROWER;
SELECT * FROM LIBRARYBRANCH;
SELECT * FROM BOOK;
SELECT * FROM BOOKLOANS;
SELECT * FROM BOOKAUTHORS;
SELECT * FROM BOOKCOPIES;

-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
SELECT 
    BOOK_TITLE,
    LIBRARY_BRANCH_BRANCHNAME,
    book_copies_no_of_copies
FROM
    BOOK
        JOIN
    BOOKCOPIES ON BOOK.BOOK_BOOKID = BOOKCOPIES.BOOK_COPIES_BOOKID
        JOIN
    LIBRARYBRANCH ON BOOKCOPIES.BOOK_COPIES_BRANCHID = LIBRARYBRANCH.LIBRARY_BRANCH_ID
GROUP BY BOOK_TITLE , LIBRARY_BRANCH_BRANCHNAME,book_copies_no_of_copies
HAVING BOOK_TITLE = 'THE LOST TRIBE'
    AND LIBRARY_BRANCH_BRANCHNAME = 'SHARPSTOWN';
    desc bookloans;
    
    
-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?
SELECT BOOK_TITLE,
    LIBRARY_BRANCH_BRANCHNAME,
book_copies_no_of_copies
FROM
    BOOK
        JOIN
    BOOKCOPIES ON BOOK.BOOK_BOOKID = BOOKCOPIES.BOOK_COPIES_BOOKID
        JOIN
    LIBRARYBRANCH ON BOOKCOPIES.BOOK_COPIES_BRANCHID = LIBRARYBRANCH.LIBRARY_BRANCH_ID
GROUP BY  LIBRARY_BRANCH_BRANCHNAME,BOOK_TITLE,book_copies_no_of_copies
HAVING BOOK_TITLE="THE LOST TRIBE" ;



-- 3.Retrieve the names of all borrowers who do not have any books checked out.
SELECT 
    *
FROM
    borrower b
WHERE
    borrower_CardNo NOT IN (SELECT 
            book_loans_CardNo
        FROM
            bookloans);






-- 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address-- 
WITH CTE_ AS (SELECT * FROM BORROWER
JOIN BOOKLOANS 
ON BORROWER.BORROWER_CARDNO=BOOKLOANS.BOOK_LOANS_CARDNO
JOIN LIBRARYBRANCH
ON BOOKLOANS.BOOK_LOANS_BRANCHID=LIBRARYBRANCH.LIBRARY_BRANCH_ID
WHERE BOOK_LOANS_DUEDATE="0002-03-18" AND LIBRARY_BRANCH_BRANCHNAME="SHARPSTOWN")
SELECT BOOK_TITLE,BORROWER_BORROWERNAME,BORROWER_BORROWERADDRESS,LIBRARY_BRANCH_BRANCHNAME,BOOK_LOANS_DUEDATE FROM CTE_
JOIN BOOK
ON CTE_.BOOK_LOANS_LOANSID=BOOK.BOOK_BOOKID;


-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT LIBRARY_BRANCH_BRANCHNAME,COUNT(BOOK_LOANS_LOANSID) AS TOTAL from librarybranch LB
join bookloans BL
on LB.LIBRARY_BRANCH_ID=BL.BOOK_LOANS_BRANCHID
JOIN BOOK B
ON BL.BOOK_LOANS_BOOKID=B.BOOK_BOOKID
GROUP BY LIBRARY_BRANCH_BRANCHNAME
order by total desc;


-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
WITH CTE_ AS(SELECT BORROWER_BORROWERNAME,BORROWER_BORROWERADDRESS,COUNT(BOOK_LOANS_BOOKID) AS TOTAL FROM BORROWER BR
JOIN BOOKLOANS BL
ON BR.BORROWER_CARDNO=BL.BOOK_LOANS_CARDNO
GROUP BY BORROWER_BORROWERNAME,BORROWER_BORROWERADDRESS)
SELECT * FROM CTE_
WHERE TOTAL>5
ORDER BY TOTAL DESC;

-- 7.For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
WITH CTE_ AS (SELECT BOOK_AUTHORS_AUTHORNAME,LIBRARY_BRANCH_BRANCHNAME,BOOK_TITLE,BOOK_COPIES_NO_of_copies AS TOTALCOPIES FROM BOOKAUTHORS A
JOIN BOOK B
ON A.BOOK_AUTHORS_BOOKID=B.BOOK_BOOKID
JOIN BOOKCOPIES BC
ON B.BOOK_BOOKID=BC.BOOK_COPIES_BOOKID
JOIN LIBRARYBRANCH LB
ON BC.BOOK_COPIES_BRANCHID=LB.LIBRARY_BRANCH_ID
GROUP BY LIBRARY_BRANCH_BRANCHNAME,BOOK_TITLE,BOOK_AUTHORS_AUTHORNAME,BOOK_COPIES_NO_of_copies
HAVING BOOK_AUTHORS_AUTHORNAME="STEPHEN KING")
SELECT * FROM CTE_
WHERE LIBRARY_BRANCH_BRANCHNAME="CENTRAL" ;
