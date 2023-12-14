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
