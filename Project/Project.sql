Create database Dada_Apartment
--drop database Dada_Apartment
use Dada_Apartment

----------------------------------------------- Entities/Tables with Attributes/Columns ------------------------------------------

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT,
    StartDate DATE DEFAULT GETDATE(),
    EndDate DATE,
    CHECK (StartDate <= EndDate)
);
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(255) NOT NULL UNIQUE,
    Description TEXT
);
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(101,1), 
    Username VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    ContactInfo VARCHAR(255),
    RoleID INT FOREIGN KEY REFERENCES Roles(RoleID),
    CONSTRAINT CHK_PasswordLength CHECK (LEN(Password) >= 6)
);
CREATE TABLE Tenants (
    TenantID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    ContactInfo VARCHAR(255),
    Status VARCHAR(50) NOT NULL DEFAULT 'Active',
    CONSTRAINT CHK_TenantStatus CHECK (Status IN ('Active', 'Inactive', 'Terminated'))
);
CREATE TABLE Apartments (
    ApartmentID INT PRIMARY KEY IDENTITY(1,1),
    Floor INT CHECK (Floor > 0),
    ProjectID INT FOREIGN KEY REFERENCES Projects(ProjectID),
    TenantID INT FOREIGN KEY REFERENCES Tenants(TenantID),
    Status VARCHAR(50) DEFAULT 'Available'
);
CREATE TABLE Contracts (
    ContractID INT PRIMARY KEY IDENTITY(1000,5),
    ApartmentID INT FOREIGN KEY REFERENCES Apartments(ApartmentID),
    TenantID INT FOREIGN KEY REFERENCES Tenants(TenantID),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    MonthlyRent DECIMAL(10, 2) CHECK (MonthlyRent > 0),
    SecurityDeposit DECIMAL(10, 2) CHECK (SecurityDeposit >= 0),
    RentDueDate DATE,
    CONSTRAINT CHK_ContractDates CHECK (StartDate <= EndDate)
);
ALTER TABLE Tenants ADD  ApartmentID INT FOREIGN KEY REFERENCES Apartments(ApartmentID),
						 ContractID INT FOREIGN KEY REFERENCES Contracts(ContractID);

CREATE TABLE RentPayments (
    PaymentID INT PRIMARY KEY IDENTITY(1000,2),
    ContractID INT FOREIGN KEY REFERENCES Contracts(ContractID),
    PaymentAmount DECIMAL(10, 2) CHECK (PaymentAmount > 0),
    PaymentDate DATE NOT NULL DEFAULT GETDATE(),
    PaymentMethod VARCHAR(50) NOT NULL,
    Status VARCHAR(50) DEFAULT 'Pending',
    CONSTRAINT CHK_PaymentStatus CHECK (Status IN ('Pending', 'Paid', 'Overdue'))
);
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Balance DECIMAL(10, 2) CHECK (Balance >= 0),
    AccountType VARCHAR(50) CHECK (AccountType IN ('Savings', 'Checking', 'Credit')),
    LastUpdated DATE DEFAULT GETDATE()
);
CREATE TABLE Vouchers (
    VoucherID INT PRIMARY KEY IDENTITY(1,1),
    VoucherType VARCHAR(50) CHECK (VoucherType IN ('Discount', 'Gift', 'Refund')),
    Amount DECIMAL(10, 2) CHECK (Amount > 0),
    Date DATE DEFAULT GETDATE(),
    AccountID INT FOREIGN KEY REFERENCES Accounts(AccountID)
);
CREATE TABLE Reports (
    ReportID INT PRIMARY KEY IDENTITY(1,1),
    ReportType VARCHAR(50) NOT NULL,
    DateGenerated DATE DEFAULT GETDATE(),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Content TEXT,
    CONSTRAINT CHK_ReportType CHECK (ReportType IN ('Financial', 'Maintenance', 'Inspection'))
);
CREATE TABLE Disbursements (
    DisbursementID INT PRIMARY KEY IDENTITY(1,1),
    Amount DECIMAL(10, 2) CHECK (Amount > 0),
    DisbursementDate DATE DEFAULT GETDATE(),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Status VARCHAR(50) DEFAULT 'Pending',
    CONSTRAINT CHK_DisbursementStatus CHECK (Status IN ('Pending', 'Completed', 'Cancelled'))
);
CREATE TABLE UtilityBills (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    ApartmentID INT FOREIGN KEY REFERENCES Apartments(ApartmentID),
    BillAmount DECIMAL(10, 2) CHECK (BillAmount > 0),
    DueDate DATE,
    Status VARCHAR(50) DEFAULT 'Unpaid',
    CONSTRAINT CHK_BillStatus CHECK (Status IN ('Unpaid', 'Paid', 'Overdue'))
);
CREATE TABLE Inventory (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(255) NOT NULL,
    Quantity INT CHECK (Quantity >= 0),
    Location VARCHAR(255),
    Status VARCHAR(50) DEFAULT 'Available',
    CONSTRAINT CHK_ItemStatus CHECK (Status IN ('Available', 'Out of Stock', 'Discontinued'))
);
CREATE TABLE MaintenanceRequests (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    ApartmentID INT FOREIGN KEY REFERENCES Apartments(ApartmentID),
    TenantID INT FOREIGN KEY REFERENCES Tenants(TenantID),
    Description TEXT NOT NULL,
    RequestedDate DATE DEFAULT GETDATE(),
    Status VARCHAR(50) DEFAULT 'Pending',
    CONSTRAINT CHK_RequestStatus CHECK (Status IN ('Pending', 'In Progress', 'Completed'))
);
CREATE TABLE Inspections (
    InspectionID INT PRIMARY KEY IDENTITY(1,1),
    ApartmentID INT FOREIGN KEY REFERENCES Apartments(ApartmentID),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    InspectionDate DATE DEFAULT GETDATE(),
    Results TEXT,
    Notes TEXT,
    CONSTRAINT CHK_InspectionDate CHECK (InspectionDate <= GETDATE())
);
CREATE TABLE Vendors (
    VendorID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(255),
    ContactInfo VARCHAR(255),
    CONSTRAINT CHK_VendorCategory CHECK (Category IN ('Plumber', 'Electrician', 'Contractor'))
);
CREATE TABLE ComplaintRequests (
    ComplaintID INT PRIMARY KEY IDENTITY(1,1),
    TenantID INT FOREIGN KEY REFERENCES Tenants(TenantID),
    Description TEXT NOT NULL,
    Status VARCHAR(50) DEFAULT 'Open',
    ComplaintDate DATE DEFAULT GETDATE(),
    CONSTRAINT CHK_ComplaintStatus CHECK (Status IN ('Open', 'In Progress', 'Resolved'))
);
CREATE TABLE SatisfactionSurveys (
    SurveyID INT PRIMARY KEY IDENTITY(1,1),
    TenantID INT FOREIGN KEY REFERENCES Tenants(TenantID),
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comments TEXT,
    SurveyDate DATE DEFAULT GETDATE()
);

------------------------------------------------------- Insert Records/Row -------------------------------------------------------

------------ Projects table ------------------------
INSERT INTO Projects (ProjectName, Description, StartDate, EndDate)
VALUES
('Luxury Apartments', 'A project for high-end residential apartments.', '2024-01-01', '2025-01-01'),
('Affordable Housing', 'A project focused on affordable housing for low-income families.', '2024-03-15', '2026-03-15'),
('Business Complex', 'A commercial project for office spaces and retail.', '2024-06-01', '2026-06-01');

---------- Roles table ------------------
INSERT INTO Roles (RoleName, Description)
VALUES 
('Admin', 'Administrator with full access rights'),
('Manager', 'Manager responsible for overseeing projects and tenants'),
('Tenant', 'Tenant who rents apartments'),
('Maintenance', 'Maintenance staff for property upkeep'),
('Inspector', 'Inspector for apartment condition evaluation');

----------- Users table -------------------
INSERT INTO Users (Username, Password, ContactInfo, RoleID)
VALUES 
('adminuser', 'admin123', 'admin@example.com', 1),
('manageruser', 'manager123', 'manager@example.com', 2),
('tenantuser', 'tenant123', 'tenant@example.com', 3),
('maintuser', 'maint123', 'maint@example.com', 4),
('inspectuser', 'inspect123', 'inspect@example.com', 5);

------------ Apartments table -----------------
INSERT INTO Apartments (Floor, ProjectID, Status)
VALUES  
(1, 1, 'Available'),
(2, 1, 'Occupied'),
(3, 2, 'Occupied'),
(4, 2, 'Occupied'),
(5, 3, 'Available');
select * from Apartments

----------------- Contracts table ---------------
INSERT INTO Contracts (ApartmentID, StartDate, EndDate, MonthlyRent, SecurityDeposit, RentDueDate)
VALUES 
(1, '2024-01-01', '2025-01-01', 1200.00, 1000.00, '2024-01-01'),
(2, '2024-02-01', '2025-02-01', 800.00, 800.00, '2024-02-01'),
(3, '2024-03-01', '2025-03-01', 1500.00, 1200.00, '2024-03-01'),
(4, '2024-04-01', '2025-04-01', 1100.00, 1000.00, '2024-04-01'),
(5, '2024-05-01', '2025-05-01', 1000.00, 800.00, '2024-05-01');
select * from Contracts

--------------- Tenants table --------------------
INSERT INTO Tenants (Name, ContactInfo, Status, ApartmentID, ContractID)
VALUES 
('Umer', 'umer@example.com', 'Active', 1, 1000),
('Usman', 'usman@example.com', 'Inactive', 2, 1005),
('Shumail', 'shumail@example.com', 'Active', 3, 1010),
('Bakar', 'bakar@example.com', 'Active', 4, 1015),
('Talha', 'talha@example.com', 'Inactive', 5, 1020);
select * from Tenants

--drop table Tenants

update Apartments set TenantID  = case
						when ApartmentID  = 1 then 1
						when ApartmentID  = 2 then 2
						when ApartmentID  = 3 then 3
						when ApartmentID  = 4 then 4
						when ApartmentID  = 5 then 5
						else TenantID 
end;
update Contracts set TenantID  = case
						when ApartmentID = 1 then 1
						when ApartmentID = 2 then 2
						when ApartmentID = 3 then 3
						when ApartmentID = 4 then 4
						when ApartmentID = 5 then 5
						else TenantID 
end;

------------------ RentPayments table -----------------
INSERT INTO RentPayments (ContractID, PaymentAmount, PaymentDate, PaymentMethod, Status)
VALUES 
(1000, 1200.00, '2024-01-01', 'Bank Transfer', 'Paid'),
(1005, 800.00, '2024-02-01', 'Cash', 'Pending'),
(1010, 1500.00, '2024-03-01', 'Credit Card', 'Paid'),
(1015, 1100.00, '2024-04-01', 'Bank Transfer', 'Pending'),
(1020, 1000.00, '2024-05-01', 'Cash', 'Paid');
select * from RentPayments

------------------- Accounts table------------------ 
INSERT INTO Accounts (UserID, Balance, AccountType)
VALUES 
(101, 5000.00, 'Checking'),
(102, 3000.00, 'Savings'),
(103, 1500.00, 'Checking'),
(104, 2000.00, 'Credit'),
(105, 2500.00, 'Savings');

-------------------- Vouchers table -------------------
INSERT INTO Vouchers (VoucherType, Amount, Date, AccountID)
VALUES 
('Discount', 50.00, '2024-01-01', 1),
('Gift', 100.00, '2024-02-01', 2),
('Refund', 200.00, '2024-03-01', 3),
('Discount', 30.00, '2024-04-01', 4),
('Gift', 150.00, '2024-05-01', 5);

------------------- Reports table ------------------
INSERT INTO Reports (ReportType, UserID, Content)
VALUES 
('Financial', 101, 'January 2024 Financial Report'),
('Maintenance', 102, 'Maintenance Status Report for February 2024'),
('Inspection', 103, 'Inspection Report for March 2024'),
('Financial', 104, 'April 2024 Financial Overview'),
('Maintenance', 105, 'Maintenance Update for May 2024');

----------------- Disbursements table ----------------
INSERT INTO Disbursements (Amount, DisbursementDate, UserID, Status)
VALUES 
(1000.00, '2024-01-10', 101, 'Completed'),
(500.00, '2024-02-05', 102, 'Pending'),
(750.00, '2024-03-05', 103, 'Completed'),
(300.00, '2024-04-05', 104, 'Pending'),
(450.00, '2024-05-05', 105, 'Completed');

--------------------- UtilityBills table ----------------
INSERT INTO UtilityBills (ApartmentID, BillAmount, DueDate, Status)
VALUES 
(1, 150.00, '2024-01-15', 'Unpaid'),
(2, 120.00, '2024-02-15', 'Paid'),
(3, 180.00, '2024-03-15', 'Unpaid'),
(4, 200.00, '2024-04-15', 'Paid'),
(5, 220.00, '2024-05-15', 'Overdue');

------------------------ Inventory table -------------------
INSERT INTO Inventory (ItemName, Quantity, Location, Status)
VALUES 
('Washing Machine', 10, 'Building A', 'Available'),
('Air Conditioner', 5, 'Building B', 'Out of Stock'),
('Microwave Oven', 15, 'Building C', 'Available'),
('Refrigerator', 8, 'Building A', 'Available'),
('Dishwasher', 3, 'Building B', 'Discontinued');

-------------- Maintenance Requests table -------------------------
INSERT INTO MaintenanceRequests (ApartmentID, TenantID, Description, Status)
VALUES 
(1, 1, 'Leaking faucet in kitchen.', 'Pending'),
(2, 2, 'Broken window in living room.', 'In Progress'),
(3, 3, 'No hot water in shower.', 'Pending'),
(4, 4, 'Clogged sink in kitchen.', 'Completed'),
(5, 5, 'Air conditioning not working.', 'Pending');

---------------- Inspections table --------------------------------
INSERT INTO Inspections (ApartmentID, UserID, InspectionDate, Results, Notes)
VALUES 
(1, 101, '2024-01-05', 'Everything is in good condition.', 'No issues found.'),
(2, 102, '2024-02-05', 'Minor repairs needed.', 'Repaint walls in the kitchen.'),
(3, 103, '2024-03-05', 'No issues found.', 'Inspection completed successfully.'),
(4, 104, '2024-04-05', 'Refrigerator needs replacement.', 'Check with vendor for replacement.');

---------------- Vendors table --------------------------------
INSERT INTO Vendors (Name, Category, ContactInfo)
VALUES 
('Ubad', 'Plumber', 'ubad_plumbing@example.com'),
('Ahmad', 'Plumber', 'ahmad_electric@example.com'),
('Bob', 'Electrician', 'bob_landscaper@example.com'),
('Niazi', 'Contractor', 'niazi_moving@example.com'),
('ABC', 'Electrician', 'abc_cleaners@example.com');

---------------- Complaint Requests table --------------------------------
INSERT INTO ComplaintRequests (TenantID, Description, Status)
VALUES 
(1, 'Loud noise from neighbors.', 'Open'),
(2, 'Broken elevator.', 'Resolved'),
(3, 'Water leak in bathroom.', 'Open'),
(4, 'Lack of parking spaces.', 'Resolved'),
(5, 'Heating system malfunction.', 'In Progress');

---------------- Satisfaction Surveys table --------------------------------
INSERT INTO SatisfactionSurveys (TenantID, Rating, Comments)
VALUES 
(1, 5, 'Very satisfied with the apartment and services.'),
(2, 3, 'The apartment is fine, but maintenance could improve.'),
(3, 4, 'Good apartment, but noise levels can be disturbing.'),
(4, 5, 'Great experience. The staff is very helpful.'),
(5, 2, 'The apartment is nice, but the heating system needs work.');

------------------------------------------------------- Views --------------------------------------------------------------------

--------- For Tenant Details with Apartment and Contract Information ----------------------
CREATE OR ALTER VIEW vw_TenantDetails with encryption AS
SELECT 
	T.TenantID, T.Name AS TenantName, T.ContactInfo AS TenantContact, T.Status AS TenantStatus, 
	A.ApartmentID, A.Floor, A.Status AS ApartmentStatus, 
	C.ContractID, C.StartDate AS ContractStartDate, C.EndDate AS ContractEndDate, C.MonthlyRent, C.SecurityDeposit
FROM 
    Tenants T LEFT JOIN Apartments A ON T.ApartmentID = A.ApartmentID
LEFT JOIN Contracts C ON T.ContractID = C.ContractID;

------------ For Maintenance Requests by Apartment -----------------------------------
CREATE OR ALTER VIEW vw_MaintenanceRequests AS
SELECT 
	MR.RequestID, MR.ApartmentID, MR.TenantID, MR.Status AS MaintenanceStatus, 
	MR.Description AS MaintenanceIssue, MR.RequestedDate,
    A.Floor,
    T.Name AS TenantName
FROM 
    MaintenanceRequests MR LEFT JOIN Apartments A ON MR.ApartmentID = A.ApartmentID
LEFT JOIN Tenants T ON MR.TenantID = T.TenantID;

--------------------- For Rent Payments with Contract Details ---------------------------
CREATE OR ALTER VIEW vw_RentPayments AS
SELECT 
    RP.PaymentID, RP.ContractID, RP.PaymentAmount, RP.PaymentDate, RP.PaymentMethod, RP.Status AS PaymentStatus,
    C.ApartmentID, C.TenantID, C.MonthlyRent,
    T.Name AS TenantName
FROM 
    RentPayments RP LEFT JOIN Contracts C ON RP.ContractID = C.ContractID
LEFT JOIN Tenants T ON C.TenantID = T.TenantID;

-------------------- For Inspection Results -------------------------------------
CREATE OR ALTER VIEW vw_InspectionResults AS
SELECT 
    I.InspectionID, I.ApartmentID, I.UserID, I.InspectionDate, I.Results, I.Notes,
    A.Floor,
    U.Username AS InspectorName
FROM 
    Inspections I LEFT JOIN Apartments A ON I.ApartmentID = A.ApartmentID
LEFT JOIN Users U ON I.UserID = U.UserID;

-------------------- For Pending Utility Bills ----------------------------------
CREATE OR ALTER VIEW vw_PendingUtilityBills AS
SELECT
	UB.BillID, UB.ApartmentID, UB.BillAmount, UB.DueDate, UB.Status AS BillStatus,
    A.Floor
FROM 
    UtilityBills UB LEFT JOIN Apartments A ON UB.ApartmentID = A.ApartmentID
WHERE 
    UB.Status = 'Unpaid' OR UB.Status = 'Overdue';

---------------------- For Financial Reports by User ----------------------------------
CREATE OR ALTER VIEW vw_FinancialReports AS
SELECT 
    R.ReportID, R.ReportType, R.DateGenerated, R.UserID, R.Content,
    U.Username
FROM 
    Reports R LEFT JOIN Users U ON R.UserID = U.UserID
WHERE 
    R.ReportType = 'Financial';

------------------- For Satisfaction Surveys with Tenant Details -------------------------
CREATE OR ALTER VIEW vw_SatisfactionSurveys AS
SELECT 
    SS.SurveyID, SS.TenantID, SS.Rating, SS.Comments, SS.SurveyDate,
    T.Name AS TenantName, T.ContactInfo AS TenantContact
FROM 
    SatisfactionSurveys SS LEFT JOIN Tenants T ON SS.TenantID = T.TenantID;


------------------- For Complaints with Tenant Information ---------------------------
CREATE OR ALTER VIEW vw_TenantComplaints AS
SELECT 
    CR.ComplaintID, CR.TenantID, CR.Description AS ComplaintDetails, CR.Status AS ComplaintStatus, CR.ComplaintDate,
    T.Name AS TenantName
FROM 
    ComplaintRequests CR LEFT JOIN Tenants T ON CR.TenantID = T.TenantID;


SELECT * FROM vw_TenantDetails;
SELECT * FROM vw_MaintenanceRequests;
SELECT * FROM vw_RentPayments;
SELECT * FROM vw_InspectionResults;
SELECT * FROM vw_PendingUtilityBills;
SELECT * FROM vw_FinancialReports;
SELECT * FROM vw_SatisfactionSurveys;
SELECT * FROM vw_TenantComplaints;

SELECT * FROM vw_TenantDetails WHERE TenantStatus = 'Active';
SELECT * FROM vw_RentPayments WHERE PaymentStatus = 'Pending';

------------------------------------------------------------------ Functions ------------------------------------------------

--------------------- Get Tenant Status --------------------------------
CREATE or ALTER FUNCTION GetTenantStatus(@TenantID INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Status VARCHAR(50);
		SELECT @Status = Status FROM Tenants WHERE TenantID = @TenantID;
		RETURN @Status;
END;
SELECT dbo.GetTenantStatus(1) AS TenantStatus;

--------------------- Get Vendor Details -------------------------
CREATE or ALTER FUNCTION GetVendorDetails(@Category VARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT VendorID, Name, ContactInfo FROM Vendors WHERE Category = @Category
);
SELECT * FROM dbo.GetVendorDetails('Plumber');

-------------------------------------------------------------- Procedure -----------------------------------------------------

------------------ Add New Tenant ---------------------------
CREATE or ALTER PROCEDURE AddNewTenant(
    @Name NVARCHAR(50),
    @ContactInfo NVARCHAR(15),
    @Status NVARCHAR(50) = 'Active', 
	@ApartmentID int,
	@contractID int)
AS
BEGIN
    INSERT INTO Tenants (Name, ContactInfo, Status, ApartmentID, ContractID) VALUES 
	(@Name, @ContactInfo, @Status, @ApartmentID, @contractID);
    PRINT 'New tenant added successfully.';
END;
EXEC AddNewTenant 'Doe', 'doe@example.com', 'Terminated', 3, 1000;

---------------------------------------------------------- Transactions ----------------------------------------------------

------------------- Handle Bulk Payment Processing ----------------------------
BEGIN TRANSACTION BulkPaymentTransaction
BEGIN TRY
    -- Tenant 1 Payment
    INSERT INTO RentPayments (ContractID, PaymentAmount, PaymentDate, Status) VALUES 
	(1001, 1200.00, '2024-11-22', 'Paid');
    -- Tenant 2 Payment
    INSERT INTO RentPayments (ContractID, PaymentAmount, PaymentDate, Status) VALUES 
	(1002, 1500.00, '2024-11-22', 'Paid');
    -- Update Contract Status
    UPDATE RentPayments SET Status = 'Paid' WHERE ContractID IN (1001, 1002);
    COMMIT TRANSACTION
    PRINT 'Bulk payments processed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION BulkPaymentTransaction;
    PRINT Error_Message();
END CATCH;

------------------------------------------------------- Triggers ---------------------------------------------------------

CREATE TABLE BackupTenants (
    ID INT,
    Name VARCHAR(225),
    Info VARCHAR(225),
    Status VARCHAR(50),
    ApartID int,
	ContID int,
    DeletedDate DATETIME DEFAULT GETDATE()
);
CREATE OR ALTER TRIGGER TenantDeleteBackup
ON Tenants
AFTER DELETE
AS
BEGIN
    INSERT INTO BackupTenants (ID, Name, Info, Status, ApartID, ContID)
    SELECT TenantID, Name, ContactInfo, Status, ApartmentID, ContractID
    FROM DELETED;

    PRINT 'Tenant data moved to backup after deletion.';
END;

insert into Tenants (Name, ContactInfo, Status, ApartmentID, ContractID) values 
('Bilal', 'Bilal@example.com', 'Inactive', 5, 1000);

--select * from Tenants;
--Delete from Tenants Where TenantID = 10;
select * from BackupTenants;

--------------------------------------- Reteriving Data in Entities -----------------------------------------
SELECT * FROM Projects;
SELECT * FROM Roles;
SELECT * FROM Users;
SELECT * FROM Tenants;
SELECT * FROM Apartments;
SELECT * FROM Contracts;
SELECT * FROM RentPayments;
SELECT * FROM Accounts;
SELECT * FROM Vouchers;
SELECT * FROM Reports;
SELECT * FROM Disbursements;
SELECT * FROM UtilityBills;
SELECT * FROM Inventory;
SELECT * FROM MaintenanceRequests;
SELECT * FROM Inspections;
SELECT * FROM Vendors;
SELECT * FROM ComplaintRequests;
SELECT * FROM SatisfactionSurveys;
SELECT * FROM BackupTenants;





