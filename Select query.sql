-- ime, prezime, spol,ime države i  prosječna plaća u toj državi svakom autoru
SELECT a.Name, a.Surname, a.Gender, c.Name AS CountryName, c.AverageSalary
FROM Authors a
JOIN Countries c ON a.CountryId = c.CountryId;

-- naziv i datum objave svake znanstvene knjige zajedno s imenima glavnih autora koji su na njoj radili, pri čemu imena autora moraju biti u jednoj ćeliji i u obliku Prezime, I.
SELECT b.Title, b.PublicationDate, STRING_AGG(a.Surname || ', ' || LEFT(a.Name, 1), '; ') AS Authors
FROM Books b
JOIN Authorship ash ON b.BookId = ash.BookId
JOIN Authors a ON ash.AuthorId = a.AuthorId
WHERE b.Genre = 'scientific' AND ash.TypeOfAuthorship = 'Main'
GROUP BY b.BookId;

-- sve kombinacije (naslova) knjiga i posudbi istih u prosincu 2023.; u slučaju da neka nije ni jednom posuđena u tom periodu, prikaži je samo jednom (a na mjestu posudbe neka piše null)
SELECT b.Title, COALESCE(TO_CHAR(br.BorrowingDate, 'YYYY-MM-DD'), 'null') AS BorrowingDate
FROM Books b
LEFT JOIN Copies c ON b.BookId = c.BookId
LEFT JOIN Borrowings br ON c.CopyId = br.CopyId AND br.BorrowingDate BETWEEN '2023-12-01' AND '2023-12-31'
WHERE (br.BorrowingDate BETWEEN '2023-12-01' AND '2023-12-31' OR br.BorrowingDate IS NULL);


--top 3 knjižnice s najviše primjeraka knjiga
SELECT l.Name, COUNT(*) AS NumberOfCopies
FROM Libraries l
JOIN Copies c ON l.LibraryId = c.LibraryId
GROUP BY l.LibraryId
ORDER BY NumberOfCopies DESC
LIMIT 3;

-- po svakoj knjizi broj ljudi koji su je pročitali (korisnika koji posudili bar jednom)
SELECT b.Title, COUNT(DISTINCT br.UserId) AS ReadersCount
FROM Books b
JOIN Copies c ON b.BookId = c.BookId
JOIN Borrowings br ON c.CopyId = br.CopyId
GROUP BY b.BookId;

-- imena svih korisnika koji imaju trenutno posuđenu knjigu
SELECT DISTINCT u.Name, u.Surname
FROM Users u
JOIN Borrowings br ON u.UserId = br.UserId
WHERE br.ReturningDate IS NULL;

-- sve autore kojima je bar jedna od knjiga izašla između 2019. i 2022.
SELECT DISTINCT a.Name, a.Surname
FROM Authors a
JOIN Authorship ash ON a.AuthorId = ash.AuthorId
JOIN Books b ON ash.BookId = b.BookId
WHERE b.PublicationDate BETWEEN '2019-01-01' AND '2022-12-31';


--ime države i broj umjetničkih knjiga po svakoj (ako su dva autora iz iste države, računa se kao jedna knjiga), gdje su države sortirane po broju živih autora od najveće ka najmanjoj 
SELECT c.Name, COUNT(DISTINCT b.BookId) AS ArtisticBooksCount
FROM Countries c
JOIN Authors a ON c.CountryId = a.CountryId
JOIN Authorship ash ON a.AuthorId = ash.AuthorId
JOIN Books b ON ash.BookId = b.BookId
WHERE b.Genre = 'artistic'
GROUP BY c.CountryId
ORDER BY COUNT(DISTINCT a.AuthorId) DESC;

-- po svakoj kombinaciji autora i žanra (ukoliko postoji) broj posudbi knjiga tog autora u tom žanru
SELECT a.Name, a.Surname, b.Genre, COUNT(br.BorrowingId) AS NumberOfBorrowings
FROM Authors a
JOIN Authorship ash ON a.AuthorId = ash.AuthorId
JOIN Books b ON ash.BookId = b.BookId
JOIN Copies c ON b.BookId = c.BookId
JOIN Borrowings br ON c.CopyId = br.CopyId
GROUP BY a.AuthorId, b.Genre;

-- po svakom članu koliko trenutno duguje zbog kašnjenja; u slučaju da ne duguje ispiši “ČISTO”
SELECT u.Name, u.Surname, CASE 
  WHEN br.ReturningDate < CURRENT_DATE THEN 'Duguje'
  ELSE 'ČISTO'
END AS Status
FROM Users u
JOIN Borrowings br ON u.UserId = br.UserId;

-- autora i ime prve objavljene knjige istog
SELECT a.Name, a.Surname, b.Title AS FirstBook
FROM Authors a
JOIN Authorship ash ON a.AuthorId = ash.AuthorId
JOIN Books b ON ash.BookId = b.BookId
WHERE b.PublicationDate = (
  SELECT MIN(b2.PublicationDate)
  FROM Books b2
  JOIN Authorship ash2 ON b2.BookId = ash2.BookId
  WHERE ash2.AuthorId = a.AuthorId
)
GROUP BY a.AuthorId, b.BookId;


-- državu i ime druge objavljene knjige iste


-- knjige i broj aktivnih posudbi, gdje se one s manje od 10 aktivnih ne prikazuju
SELECT b.Title, COUNT(br.BorrowingId) AS ActiveBorrowings
FROM Books b
JOIN Copies c ON b.BookId = c.BookId
JOIN Borrowings br ON c.CopyId = br.CopyId
WHERE br.ReturningDate IS NULL
GROUP BY b.BookId
HAVING COUNT(br.BorrowingId) > 10;


--broj autora (koji su objavili više od 5 knjiga) po struci, desetljeću rođenja i spolu; u slučaju da je broj autora manji od 10, ne prikazuj kategoriju; poredaj prikaz po desetljeću rođenja
SELECT EXTRACT(DECADE FROM a.BirthDate) AS BirthDecade, a.Gender, COUNT(a.AuthorId) AS AuthorCount
FROM Authors a
JOIN Authorship ash ON a.AuthorId = ash.AuthorId
GROUP BY EXTRACT(DECADE FROM a.BirthDate), a.Gender
HAVING COUNT(a.AuthorId) > 5
ORDER BY BirthDecade;


-- 	10 najbogatijih autora
