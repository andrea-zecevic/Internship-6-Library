CREATE TABLE Countries (
    CountryId SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Population INT,
    AverageSalary DECIMAL
)

CREATE TYPE GENDERS AS ENUM ('MALE', 'FEMALE', 'UNKNOWN', 'OTHER');

CREATE TABLE Authors (
    AuthorId SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Surname VARCHAR(100),
    Gender GENDERS,
    BirthDate DATE,
    CountryId INT REFERENCES Countries(CountryId)
)

CREATE TABLE Libraries (
    LibraryId SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(100),
    WorkingHours VARCHAR(100)
)

CREATE TYPE GENRES AS ENUM ('school reading', 'artistic', 'scientific', 'biography', 'professional');

CREATE TABLE Books (
    BookId SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    PublicationDate DATE,
    Genre GENRES,
    NumberOfPages INTEGER,
    Price DECIMAL(10, 2)
)

ALTER TABLE Books
ALTER COLUMN Title TYPE VARCHAR(255);

CREATE TYPE TypesOfAuthorship AS ENUM('Main', 'Secondary')

CREATE TABLE Authorship (
    BookId INT REFERENCES Books(BookId),
    AuthorId INT REFERENCES Authors(AuthorId),
    TypeOfAuthorship TypesOfAuthorship,
    PRIMARY KEY (BookId, AuthorId)
)

CREATE TABLE Users (
    UserId SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Surname VARCHAR(100),
    Email VARCHAR(150),
    Password VARCHAR(255)
)

CREATE TABLE Copies (
    CopyId SERIAL PRIMARY KEY,
    BookId INT REFERENCES Books(BookId),
    LibraryId INT REFERENCES Libraries(LibraryId),
    Code VARCHAR(50)
)

CREATE TABLE Borrowings (
    BorrowingId SERIAL PRIMARY KEY,
    CopyId INT REFERENCES Copies(CopyId),
    UserId INT REFERENCES Users(UserId),
    BorrowingDate DATE,
    ReturningDate DATE
)

CREATE TABLE Employee (
    EmployeeId SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Surname VARCHAR(100),
    Email VARCHAR(150),
    Password VARCHAR(255),
    Role VARCHAR(50),
	LibraryId INT REFERENCES Libraries(LibraryId)
)

CREATE TABLE Orders (
    OrderId SERIAL PRIMARY KEY,
    UserId INT REFERENCES Users(UserId),
    BookId INT REFERENCES Books(BookId),
	LibraryId INT REFERENCES Libraries(LibraryId),
    OrderDate DATE
)

CREATE TABLE Payments (
    PaymentId SERIAL PRIMARY KEY,
    OrderId INT REFERENCES Orders(OrderId),
    PaymentDate DATE,
    Amount DECIMAL(10, 2)
)


-- Function 
CREATE OR REPLACE FUNCTION BorrowBook(CopyId INT, UserId INT)
RETURNS VOID AS $$
DECLARE
    MaxBorrowings INT := 3;
    BorrowDuration INTERVAL := '20 days';
    CurrentBorrowingsCount INT;
BEGIN
    -- Check number of borrowings
    SELECT COUNT(*)
    INTO CurrentBorrowingsCount
    FROM Borrowings
    WHERE UserId = UserId AND ReturningDate IS NULL;

    IF CurrentBorrowingsCount >= MaxBorrowings THEN
        RAISE EXCEPTION 'User already has the max number of borrowings.';
    END IF;

    -- Insert new borrowing
    INSERT INTO Borrowings (CopyId, UserId, BorrowingDate, ReturningDate)
    VALUES (CopyId, UserId, CURRENT_DATE, CURRENT_DATE + BorrowDuration);
END;
$$ LANGUAGE plpgsql;



-- Constraints
ALTER TABLE Countries 
ADD CONSTRAINT CheckSalary 
CHECK (AverageSalary >= 0)

ALTER TABLE Books 
ADD CONSTRAINT CheckPages 
CHECK (NumberOfPages > 0)

ALTER TABLE Authors 
ADD CONSTRAINT CheckBirthdate
CHECK (BirthDate <= CURRENT_DATE)

ALTER TABLE Books 
ADD CONSTRAINT PricePositive 
CHECK (Price > 0)

ALTER TABLE Libraries 
ADD CONSTRAINT WorkingHoursNotNull 
CHECK (WorkingHours IS NOT NULL AND WorkingHours <> '')

ALTER TABLE Books 
ADD CONSTRAINT PublicationDate 
CHECK (PublicationDate <= CURRENT_DATE)

ALTER TABLE Libraries 
ADD CONSTRAINT AddressNotNull 
CHECK (Address IS NOT NULL AND Address <> '')





