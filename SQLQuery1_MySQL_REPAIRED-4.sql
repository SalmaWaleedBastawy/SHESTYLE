-- ============================================================
-- SHESTYLE - repaired MySQL / MariaDB database
-- Source: SQLQuery1.sql
-- ============================================================
-- Preserved:
--   * table/column names
--   * final product data (623 products)
--   * supplied image URLs and local image paths (622 image records)
--   * supporting user/cart/order/review/coupon data
-- Converted:
--   * IDENTITY -> AUTO_INCREMENT
--   * BIT -> TINYINT(1)
--   * DATETIME2 -> DATETIME
--   * GETDATE() -> CURRENT_TIMESTAMP
--   * DATEADD(MONTH,...) -> DATE_ADD(...)
--   * SQL Server GO/schema syntax removed
-- Fixed:
--   * SQL Server (VALUES...) derived tables converted to MySQL-safe data inserts
--   * Products.SubcategoryID added with its foreign key
--   * duplicate product block and duplicate image block are not imported twice
-- ============================================================

CREATE DATABASE IF NOT EXISTS `shestyle`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `shestyle`;

SET FOREIGN_KEY_CHECKS = 0;

-- Remove any previous partial/failed import
DROP TABLE IF EXISTS `productsections`;
DROP TABLE IF EXISTS `contactmessages`;
DROP TABLE IF EXISTS `couponusage`;
DROP TABLE IF EXISTS `coupons`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `orderitems`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `wishlist`;
DROP TABLE IF EXISTS `cartitems`;
DROP TABLE IF EXISTS `cart`;
DROP TABLE IF EXISTS `productvariants`;
DROP TABLE IF EXISTS `productsizes`;
DROP TABLE IF EXISTS `productcolors`;
DROP TABLE IF EXISTS `productimages`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `subcategories`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;

-- Create tables

CREATE TABLE Users
(
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    Role VARCHAR(20) NOT NULL DEFAULT 'User'
);

CREATE TABLE Categories
(
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Subcategories
(
    SubcategoryID INT AUTO_INCREMENT PRIMARY KEY,

    SubcategoryName VARCHAR(100) NOT NULL,

    CategoryID INT NOT NULL,

    CONSTRAINT FK_Subcategories_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Subcategories_Category
        UNIQUE (CategoryID, SubcategoryName)
);

CREATE TABLE Products
(
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Description VARCHAR(1000),
    Price DECIMAL(10,2) NOT NULL,
    OriginalPrice DECIMAL(10,2),
    Stock INT NOT NULL DEFAULT 0,
    CategoryID INT NOT NULL,
    SubcategoryID INT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Subcategories
        FOREIGN KEY (SubcategoryID)
        REFERENCES Subcategories(SubcategoryID)
);

CREATE TABLE ProductImages
(
    ImageID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL VARCHAR(500) NOT NULL,
    IsMain TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductImages_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE ProductColors
(
    ColorID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    ColorName VARCHAR(50) NOT NULL,
    ColorCode VARCHAR(20),

    CONSTRAINT FK_ProductColors_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE ProductSizes
(
    SizeID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    SizeName VARCHAR(20) NOT NULL,

    CONSTRAINT FK_ProductSizes_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE ProductVariants
(
    VariantID INT AUTO_INCREMENT PRIMARY KEY,

    ProductID INT NOT NULL,
    ColorID INT,
    SizeID INT,

    Stock INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductVariants_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_ProductVariants_Colors
        FOREIGN KEY (ColorID)
        REFERENCES ProductColors(ColorID),

    CONSTRAINT FK_ProductVariants_Sizes
        FOREIGN KEY (SizeID)
        REFERENCES ProductSizes(SizeID),

    CONSTRAINT UQ_ProductVariants
        UNIQUE (ProductID, ColorID, SizeID)
);

CREATE TABLE Cart
(
    CartID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,

    CONSTRAINT FK_Cart_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);

CREATE TABLE CartItems
(
    CartItemID INT AUTO_INCREMENT PRIMARY KEY,
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_CartItems_Cart
        FOREIGN KEY (CartID)
        REFERENCES Cart(CartID),

    CONSTRAINT FK_CartItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT UQ_CartItems_Cart_Product
        UNIQUE (CartID, ProductID)
);

CREATE TABLE Wishlist
(
    WishlistID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,

    CONSTRAINT FK_Wishlist_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Wishlist_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT UQ_Wishlist_User_Product
        UNIQUE (UserID, ProductID)
);

CREATE TABLE Orders
(
    OrderID INT AUTO_INCREMENT PRIMARY KEY,

    OrderNumber VARCHAR(30) NOT NULL UNIQUE,

    UserID INT NOT NULL,

    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    Status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Phone VARCHAR(20),

    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20),

    Subtotal DECIMAL(10,2) NOT NULL,
    ShippingCost DECIMAL(10,2) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,

    PaymentMethod VARCHAR(30),
    PaymentStatus VARCHAR(30) NOT NULL DEFAULT 'Pending',

    CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);

CREATE TABLE OrderItems
(
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,

    OrderID INT NOT NULL,
    ProductID INT NOT NULL,

    ProductName VARCHAR(150) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    Quantity INT NOT NULL,
    LineTotal DECIMAL(10,2) NOT NULL,

    ColorName VARCHAR(50),
    SizeName VARCHAR(20),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

CREATE TABLE Payments
(
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,

    OrderID INT NOT NULL,

    PaymentMethod VARCHAR(30) NOT NULL,
    PaymentStatus VARCHAR(30) NOT NULL DEFAULT 'Pending',

    TransactionID VARCHAR(100),

    PaymentDate DATETIME,

    Amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT UQ_Payments_Order
        UNIQUE (OrderID)
);

CREATE TABLE Addresses
(
    AddressID INT AUTO_INCREMENT PRIMARY KEY,

    UserID INT NOT NULL,

    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,

    AddressLine VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20),

    IsDefault TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT FK_Addresses_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);

CREATE TABLE Reviews
(
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,

    UserID INT NOT NULL,
    ProductID INT NOT NULL,

    Rating INT NOT NULL,
    Comment VARCHAR(1000),

    ReviewDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    IsApproved TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT FK_Reviews_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Reviews_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_Reviews_Rating
        CHECK (Rating BETWEEN 1 AND 5),

    CONSTRAINT UQ_Reviews_User_Product
        UNIQUE (UserID, ProductID)
);

CREATE TABLE Coupons
(
    CouponID INT AUTO_INCREMENT PRIMARY KEY,

    CouponCode VARCHAR(50) NOT NULL UNIQUE,

    DiscountType VARCHAR(20) NOT NULL,

    DiscountValue DECIMAL(10,2) NOT NULL,

    StartDate DATETIME NOT NULL,

    EndDate DATETIME NOT NULL,

    MinimumAmount DECIMAL(10,2) DEFAULT 0,

    UsageLimit INT,

    UsedCount INT NOT NULL DEFAULT 0,

    IsActive TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE CouponUsage
(
    CouponUsageID INT AUTO_INCREMENT PRIMARY KEY,

    CouponID INT NOT NULL,
    UserID INT NOT NULL,
    OrderID INT NOT NULL,

    UsedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_CouponUsage_Coupons
        FOREIGN KEY (CouponID)
        REFERENCES Coupons(CouponID),

    CONSTRAINT FK_CouponUsage_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_CouponUsage_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT UQ_CouponUsage_User_Coupon
        UNIQUE (CouponID, UserID)
);

CREATE TABLE ContactMessages
(
    MessageID INT AUTO_INCREMENT PRIMARY KEY,

    UserID INT NULL,

    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,

    Subject VARCHAR(200),
    Message VARCHAR(2000) NOT NULL,

    SentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    Status VARCHAR(20) NOT NULL DEFAULT 'Unread',

    CONSTRAINT FK_ContactMessages_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
);

CREATE TABLE ProductSections
(
    ProductSectionID INT AUTO_INCREMENT PRIMARY KEY,

    ProductID INT NOT NULL,

    SectionName VARCHAR(50) NOT NULL,

    CONSTRAINT FK_ProductSections_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT UQ_ProductSections
        UNIQUE (ProductID, SectionName)
);

-- Final category data
INSERT INTO Categories (CategoryName)
VALUES
('Women'),
('Men'),
('Kids'),
('Baby & Maternity'),
('Beauty & Health'),
('Bags & Luggage'),
('Accessories'),
('Shoes'),
('Office & School Supplies');

-- Subcategories
INSERT INTO Subcategories (SubcategoryName, CategoryID) VALUES
('Dresses', 1),
('Tops', 1),
('Jeans', 1),
('Pants', 1),
('Shirts', 2),
('T-Shirts', 2),
('Jeans', 2),
('Pants', 2),
('Toys', 3),
('Kids Clothing', 3),
('Baby Clothing', 4),
('Maternity Clothing', 4),
('Makeup', 5),
('Skincare', 5),
('Bags', 6),
('Luggage', 6),
('Jewelry', 7),
('Shoes', 7),
('Belts', 7);

-- Final product data (623 rows)
INSERT INTO Products (ProductName, Price, OriginalPrice, Stock, CategoryID, IsActive) VALUES
('Puff Sleeve Dress',29.99,NULL,50,1,1),
('Floral Print Top',19.99,25.99,50,1,1),
('High-Waist Jeans',34.99,NULL,50,1,1),
('Ribbed Tank Top',14.99,NULL,50,1,1),
('Oversized Blazer',39.99,54.99,50,1,1),
('Pleated Skirt',24.99,NULL,50,1,1),
('Men''s Oxford Shirt',27.99,NULL,50,2,1),
('Men''s Slim Chinos',32.99,NULL,50,2,1),
('Men''s Bomber Jacket',44.99,59.99,50,2,1),
('Kids Graphic Tee',12.99,NULL,50,3,1),
('Kids Jogger Pants',16.99,NULL,50,3,1),
('Mini Tote Bag',24.99,NULL,50,7,1),
('Leather Belt',15.99,NULL,50,7,1),
('Silk Scarf',18.99,24.99,50,7,1),
('Classic Sneakers',58.99,NULL,50,8,1),
('Chunky Sneakers',21.99,NULL,50,8,1),
('Strappy Sneakers',36.99,NULL,50,8,1),
('Platform Sneakers',25.99,NULL,50,8,1),
('Woven Sneakers',37.99,NULL,50,8,1),
('Pointed-Toe Sneakers',71.99,NULL,50,8,1),
('Slip-On Sneakers',62.99,NULL,50,8,1),
('Lace-Up Sneakers',33.99,NULL,50,8,1),
('Block Heel Sneakers',74.99,NULL,50,8,1),
('Knit Sneakers',34.99,NULL,50,8,1),
('Suede-Look Sneakers',49.99,NULL,50,8,1),
('Patent Sneakers',51.99,NULL,50,8,1),
('Metallic Sneakers',29.99,NULL,50,8,1),
('Two-Tone Sneakers',56.99,NULL,50,8,1),
('Studded Sneakers',72.99,NULL,50,8,1),
('Quilted Sneakers',27.99,NULL,50,8,1),
('Buckle Sneakers',62.99,NULL,50,8,1),
('Pearl-Trim Sneakers',23.99,NULL,50,8,1),
('Ribbon-Tie Sneakers',71.99,NULL,50,8,1),
('Croc-Embossed Sneakers',31.99,NULL,50,8,1),
('Glossy Sneakers',23.99,NULL,50,8,1),
('Textured Sneakers',36.99,NULL,50,8,1),
('Sporty Sneakers',78.99,NULL,50,8,1),
('Minimalist Sneakers',79.99,NULL,50,8,1),
('Classic Sandals',33.99,NULL,50,8,1),
('Chunky Sandals',75.99,NULL,50,8,1),
('Strappy Sandals',27.99,NULL,50,8,1),
('Platform Sandals',51.99,NULL,50,8,1),
('Woven Sandals',47.99,NULL,50,8,1),
('Pointed-Toe Sandals',72.99,NULL,50,8,1),
('Slip-On Sandals',35.99,NULL,50,8,1),
('Lace-Up Sandals',50.99,NULL,50,8,1),
('Block Heel Sandals',58.99,NULL,50,8,1),
('Knit Sandals',52.99,NULL,50,8,1),
('Suede-Look Sandals',32.99,NULL,50,8,1),
('Patent Sandals',21.99,NULL,50,8,1),
('Metallic Sandals',33.99,NULL,50,8,1),
('Two-Tone Sandals',78.99,NULL,50,8,1),
('Studded Sandals',54.99,NULL,50,8,1),
('Quilted Sandals',43.99,NULL,50,8,1),
('Buckle Sandals',57.99,NULL,50,8,1),
('Pearl-Trim Sandals',27.99,NULL,50,8,1),
('Ribbon-Tie Sandals',45.99,NULL,50,8,1),
('Croc-Embossed Sandals',59.99,NULL,50,8,1),
('Glossy Sandals',21.99,NULL,50,8,1),
('Textured Sandals',49.99,NULL,50,8,1),
('Sporty Sandals',47.99,NULL,50,8,1),
('Minimalist Sandals',68.99,NULL,50,8,1),
('Classic Heels',65.99,NULL,50,8,1),
('Chunky Heels',39.99,NULL,50,8,1),
('Strappy Heels',39.99,NULL,50,8,1),
('Platform Heels',37.99,NULL,50,8,1),
('Woven Heels',21.99,NULL,50,8,1),
('Pointed-Toe Heels',59.99,NULL,50,8,1),
('Slip-On Heels',47.99,NULL,50,8,1),
('Lace-Up Heels',23.99,NULL,50,8,1),
('Block Heel Heels',29.99,NULL,50,8,1),
('Knit Heels',77.99,NULL,50,8,1),
('Suede-Look Heels',43.99,NULL,50,8,1),
('Patent Heels',40.99,NULL,50,8,1),
('Metallic Heels',58.99,NULL,50,8,1),
('Two-Tone Heels',36.99,NULL,50,8,1),
('Studded Heels',40.99,NULL,50,8,1),
('Quilted Heels',62.99,NULL,50,8,1),
('Buckle Heels',61.99,NULL,50,8,1),
('Pearl-Trim Heels',59.99,NULL,50,8,1),
('Ribbon-Tie Heels',36.99,NULL,50,8,1),
('Croc-Embossed Heels',36.99,NULL,50,8,1),
('Glossy Heels',38.99,NULL,50,8,1),
('Textured Heels',72.99,NULL,50,8,1),
('Sporty Heels',69.99,NULL,50,8,1),
('Minimalist Heels',53.99,NULL,50,8,1),
('Classic Ankle Boots',79.99,NULL,50,8,1),
('Chunky Ankle Boots',34.99,NULL,50,8,1),
('Strappy Ankle Boots',62.99,NULL,50,8,1),
('Platform Ankle Boots',58.99,NULL,50,8,1),
('Woven Ankle Boots',61.99,NULL,50,8,1),
('Pointed-Toe Ankle Boots',56.99,NULL,50,8,1),
('Slip-On Ankle Boots',74.99,NULL,50,8,1),
('Lace-Up Ankle Boots',60.99,NULL,50,8,1),
('Block Heel Ankle Boots',35.99,NULL,50,8,1),
('Knit Ankle Boots',41.99,NULL,50,8,1),
('Suede-Look Ankle Boots',27.99,NULL,50,8,1),
('Patent Ankle Boots',47.99,NULL,50,8,1),
('Metallic Ankle Boots',34.99,NULL,50,8,1),
('Two-Tone Ankle Boots',76.99,NULL,50,8,1),
('Studded Ankle Boots',40.99,NULL,50,8,1),
('Quilted Ankle Boots',71.99,NULL,50,8,1),
('Buckle Ankle Boots',77.99,NULL,50,8,1),
('Pearl-Trim Ankle Boots',72.99,NULL,50,8,1),
('Ribbon-Tie Ankle Boots',42.99,NULL,50,8,1),
('Croc-Embossed Ankle Boots',46.99,NULL,50,8,1),
('Glossy Ankle Boots',37.99,NULL,50,8,1),
('Textured Ankle Boots',57.99,NULL,50,8,1),
('Sporty Ankle Boots',73.99,NULL,50,8,1),
('Minimalist Ankle Boots',61.99,NULL,50,8,1),
('Classic Flats',54.99,NULL,50,8,1),
('Chunky Flats',69.99,NULL,50,8,1),
('Strappy Flats',57.99,NULL,50,8,1),
('Platform Flats',64.99,NULL,50,8,1),
('Woven Flats',74.99,NULL,50,8,1),
('Pointed-Toe Flats',78.99,NULL,50,8,1),
('Slip-On Flats',55.99,NULL,50,8,1),
('Lace-Up Flats',58.99,NULL,50,8,1),
('Block Heel Flats',26.99,NULL,50,8,1),
('Knit Flats',73.99,NULL,50,8,1),
('Suede-Look Flats',77.99,NULL,50,8,1),
('Patent Flats',25.99,NULL,50,8,1),
('Metallic Flats',24.99,NULL,50,8,1),
('Two-Tone Flats',52.99,NULL,50,8,1),
('Studded Flats',30.99,NULL,50,8,1),
('Quilted Flats',55.99,NULL,50,8,1),
('Buckle Flats',79.99,NULL,50,8,1),
('Pearl-Trim Flats',23.99,NULL,50,8,1),
('Ribbon-Tie Flats',25.99,NULL,50,8,1),
('Croc-Embossed Flats',43.99,NULL,50,8,1),
('Glossy Flats',25.99,NULL,50,8,1),
('Textured Flats',41.99,NULL,50,8,1),
('Sporty Flats',32.99,NULL,50,8,1),
('Minimalist Flats',33.99,NULL,50,8,1),
('Classic Loafers',75.99,NULL,50,8,1),
('Chunky Loafers',32.99,NULL,50,8,1),
('Strappy Loafers',65.99,NULL,50,8,1),
('Platform Loafers',65.99,NULL,50,8,1),
('Woven Loafers',79.99,NULL,50,8,1),
('Pointed-Toe Loafers',49.99,NULL,50,8,1),
('Slip-On Loafers',46.99,NULL,50,8,1),
('Lace-Up Loafers',77.99,NULL,50,8,1),
('Block Heel Loafers',46.99,NULL,50,8,1),
('Knit Loafers',50.99,NULL,50,8,1),
('Suede-Look Loafers',31.99,NULL,50,8,1),
('Patent Loafers',46.99,NULL,50,8,1),
('Metallic Loafers',57.99,NULL,50,8,1),
('Two-Tone Loafers',69.99,NULL,50,8,1),
('Studded Loafers',46.99,NULL,50,8,1),
('Quilted Loafers',78.99,NULL,50,8,1),
('Buckle Loafers',29.99,NULL,50,8,1),
('Pearl-Trim Loafers',53.99,NULL,50,8,1),
('Ribbon-Tie Loafers',27.99,NULL,50,8,1),
('Croc-Embossed Loafers',41.99,NULL,50,8,1),
('Glossy Loafers',70.99,NULL,50,8,1),
('Textured Loafers',29.99,NULL,50,8,1),
('Sporty Loafers',78.99,NULL,50,8,1),
('Minimalist Loafers',42.99,NULL,50,8,1),
('Classic Mules',28.99,NULL,50,8,1),
('Chunky Mules',36.99,NULL,50,8,1),
('Strappy Mules',43.99,NULL,50,8,1),
('Platform Mules',67.99,NULL,50,8,1),
('Woven Mules',32.99,NULL,50,8,1),
('Pointed-Toe Mules',34.99,NULL,50,8,1),
('Slip-On Mules',34.99,NULL,50,8,1),
('Lace-Up Mules',51.99,NULL,50,8,1),
('Block Heel Mules',58.99,NULL,50,8,1),
('Knit Mules',66.99,NULL,50,8,1),
('Suede-Look Mules',23.99,NULL,50,8,1),
('Patent Mules',79.99,NULL,50,8,1),
('Metallic Mules',36.99,NULL,50,8,1),
('Two-Tone Mules',42.99,NULL,50,8,1),
('Studded Mules',26.99,NULL,50,8,1),
('Quilted Mules',46.99,NULL,50,8,1),
('Buckle Mules',77.99,NULL,50,8,1),
('Pearl-Trim Mules',41.99,NULL,50,8,1),
('Ribbon-Tie Mules',28.99,NULL,50,8,1),
('Croc-Embossed Mules',51.99,NULL,50,8,1),
('Glossy Mules',71.99,NULL,50,8,1),
('Textured Mules',73.99,NULL,50,8,1),
('Sporty Mules',34.99,NULL,50,8,1),
('Minimalist Mules',79.99,NULL,50,8,1),
('Classic Slides',40.99,NULL,50,8,1),
('Chunky Slides',29.99,NULL,50,8,1),
('Strappy Slides',36.99,NULL,50,8,1),
('Navy Co-ord Suit Set',59.99,NULL,50,2,1),
('Oversized Paris Print Tee',19.99,NULL,50,2,1),
('Charcoal Suit & Turtleneck Set',64.99,NULL,50,2,1),
('Ribbed Zip Polo Shirt',24.99,NULL,50,2,1),
('Sky Blue Blazer & Trouser Set',69.99,NULL,50,2,1),
('Slim Fit Suit with Turtleneck',67.99,NULL,50,2,1),
('Wide Leg Denim Jeans',36.99,NULL,50,2,1),
('Grey Casual Suit Set',59.99,NULL,50,2,1),
('Brown Knit Polo & Trouser Set',42.99,NULL,50,2,1),
('Classic Grey Suit',54.99,NULL,50,2,1),
('Grey Fleece Tracksuit',39.99,NULL,50,2,1),
('Oversized Grey Tracksuit',37.99,NULL,50,2,1),
('Black Sweatshirt Set',34.99,NULL,50,2,1),
('Grey Blazer & Trouser Set',58.99,NULL,50,2,1),
('Ribbed Polo & White Pants Set',32.99,NULL,50,2,1),
('Beige Blazer & Trouser Co-ord',62.99,NULL,50,2,1),
('Navy Ribbed Polo Shirt',23.99,NULL,50,2,1),
('Cargo Pants & Sweatshirt Combo',46.99,NULL,50,2,1),
('Acid Wash Baggy Jeans',38.99,NULL,50,2,1),
('Grey Herringbone Jacket & Pants Set',52.99,NULL,50,2,1),
('Burgundy Polo & Chino Pants',34.99,NULL,50,2,1),
('Balance Colorblock Tracksuit',36.99,NULL,50,2,1),
('Paris Print Oversized Set',33.99,NULL,50,2,1);

INSERT INTO Products (ProductName, Price, OriginalPrice, Stock, CategoryID, IsActive) VALUES
('Textured Tee & Cream Pants Set',37.99,NULL,50,2,1),
('Eagle Logo Tee & Jogger Set',31.99,NULL,50,2,1),
('White Polo & Grey Trousers',29.99,NULL,50,2,1),
('Henley Polo & Taupe Pants Set',39.99,NULL,50,2,1),
('Brown Half-Zip Sweater & White Pants',41.99,NULL,50,2,1),
('Olive Shirt & Cream Pants Set',44.99,NULL,50,2,1),
('Cream Textured Shirt & Pants Set',47.99,NULL,50,2,1),
('Beige Jacket & Wide Leg Pants Set',49.99,NULL,50,2,1),
('Navy Shirt Jacket & Jogger Set',43.99,NULL,50,2,1),
('Grey Zip Jacket & Trouser Set',46.99,NULL,50,2,1),
('Bomber Jacket & Turtleneck Combo',54.99,NULL,50,2,1),
('Beige Utility Jacket & Pants Set',48.99,NULL,50,2,1),
('Grey Overshirt & Black Pants Set',35.99,NULL,50,2,1),
('Brown Wool Jacket & Black Pants Set',56.99,NULL,50,2,1),
('Navy Polo Shirt',36.99,NULL,50,2,1),
('Olive Polo Shirt',54.99,NULL,50,2,1),
('Charcoal Polo Shirt',49.99,NULL,50,2,1),
('Sand Polo Shirt',32.99,NULL,50,2,1),
('Ivory Polo Shirt',32.99,NULL,50,2,1),
('Sunny Yellow Graphic Tee',12.99,NULL,50,3,1),
('Rainbow Graphic Tee',19.99,NULL,50,3,1),
('Dino Print Graphic Tee',13.99,NULL,50,3,1),
('Floral Graphic Tee',17.99,NULL,50,3,1),
('Polka Dot Graphic Tee',22.99,NULL,50,3,1),
('Striped Graphic Tee',12.99,NULL,50,3,1),
('Star Print Graphic Tee',20.99,NULL,50,3,1),
('Pastel Graphic Tee',13.99,NULL,50,3,1),
('Camo Graphic Tee',22.99,NULL,50,3,1),
('Unicorn Graphic Tee',15.99,NULL,50,3,1),
('Cloud Print Graphic Tee',20.99,NULL,50,3,1),
('Sporty Graphic Tee',24.99,NULL,50,3,1),
('Cherry Print Graphic Tee',17.99,NULL,50,3,1),
('Denim Graphic Tee',9.99,NULL,50,3,1),
('Cozy Graphic Tee',11.99,NULL,50,3,1),
('Playful Graphic Tee',18.99,NULL,50,3,1),
('Cartoon Print Graphic Tee',19.99,NULL,50,3,1),
('Two-Tone Graphic Tee',9.99,NULL,50,3,1),
('Sunny Yellow Jogger Set',11.99,NULL,50,3,1),
('Rainbow Jogger Set',21.99,NULL,50,3,1),
('Dino Print Jogger Set',18.99,NULL,50,3,1),
('Floral Jogger Set',24.99,NULL,50,3,1),
('Polka Dot Jogger Set',11.99,NULL,50,3,1),
('Striped Jogger Set',21.99,NULL,50,3,1),
('Star Print Jogger Set',9.99,NULL,50,3,1),
('Pastel Jogger Set',20.99,NULL,50,3,1),
('Camo Jogger Set',11.99,NULL,50,3,1),
('Unicorn Jogger Set',18.99,NULL,50,3,1),
('Cloud Print Jogger Set',16.99,NULL,50,3,1),
('Sporty Jogger Set',11.99,NULL,50,3,1),
('Cherry Print Jogger Set',10.99,NULL,50,3,1),
('Denim Jogger Set',21.99,NULL,50,3,1),
('Cozy Jogger Set',15.99,NULL,50,3,1),
('Playful Jogger Set',9.99,NULL,50,3,1),
('Cartoon Print Jogger Set',18.99,NULL,50,3,1),
('Two-Tone Jogger Set',20.99,NULL,50,3,1),
('Sunny Yellow Overall Romper',10.99,NULL,50,3,1),
('Rainbow Overall Romper',17.99,NULL,50,3,1),
('Dino Print Overall Romper',22.99,NULL,50,3,1),
('Floral Overall Romper',15.99,NULL,50,3,1),
('Polka Dot Overall Romper',18.99,NULL,50,3,1),
('Striped Overall Romper',14.99,NULL,50,3,1),
('Star Print Overall Romper',10.99,NULL,50,3,1),
('Pastel Overall Romper',12.99,NULL,50,3,1),
('Camo Overall Romper',16.99,NULL,50,3,1),
('Unicorn Overall Romper',24.99,NULL,50,3,1),
('Cloud Print Overall Romper',22.99,NULL,50,3,1),
('Sporty Overall Romper',13.99,NULL,50,3,1),
('Cherry Print Overall Romper',22.99,NULL,50,3,1),
('Denim Overall Romper',16.99,NULL,50,3,1),
('Cozy Overall Romper',18.99,NULL,50,3,1),
('Playful Overall Romper',17.99,NULL,50,3,1),
('Cartoon Print Overall Romper',23.99,NULL,50,3,1),
('Two-Tone Overall Romper',15.99,NULL,50,3,1),
('Sunny Yellow Denim Overalls',20.99,NULL,50,3,1),
('Rainbow Denim Overalls',19.99,NULL,50,3,1),
('Dino Print Denim Overalls',22.99,NULL,50,3,1),
('Floral Denim Overalls',10.99,NULL,50,3,1),
('Polka Dot Denim Overalls',10.99,NULL,50,3,1),
('Striped Denim Overalls',19.99,NULL,50,3,1),
('Star Print Denim Overalls',20.99,NULL,50,3,1),
('Pastel Denim Overalls',21.99,NULL,50,3,1),
('Camo Denim Overalls',18.99,NULL,50,3,1),
('Unicorn Denim Overalls',21.99,NULL,50,3,1),
('Cloud Print Denim Overalls',18.99,NULL,50,3,1),
('Sporty Denim Overalls',9.99,NULL,50,3,1),
('Cherry Print Denim Overalls',11.99,NULL,50,3,1),
('Denim Denim Overalls',12.99,NULL,50,3,1),
('Cozy Denim Overalls',17.99,NULL,50,3,1),
('Playful Denim Overalls',18.99,NULL,50,3,1),
('Cartoon Print Denim Overalls',18.99,NULL,50,3,1),
('Two-Tone Denim Overalls',16.99,NULL,50,3,1),
('Sunny Yellow Hoodie Dress',14.99,NULL,50,3,1),
('Rainbow Hoodie Dress',16.99,NULL,50,3,1),
('Dino Print Hoodie Dress',22.99,NULL,50,3,1),
('Floral Hoodie Dress',14.99,NULL,50,3,1),
('Polka Dot Hoodie Dress',12.99,NULL,50,3,1),
('Striped Hoodie Dress',14.99,NULL,50,3,1),
('Star Print Hoodie Dress',20.99,NULL,50,3,1),
('Pastel Hoodie Dress',21.99,NULL,50,3,1),
('Camo Hoodie Dress',24.99,NULL,50,3,1),
('Unicorn Hoodie Dress',10.99,NULL,50,3,1),
('Cloud Print Hoodie Dress',13.99,NULL,50,3,1),
('Sporty Hoodie Dress',11.99,NULL,50,3,1),
('Cherry Print Hoodie Dress',16.99,NULL,50,3,1),
('Denim Hoodie Dress',22.99,NULL,50,3,1),
('Cozy Hoodie Dress',9.99,NULL,50,3,1),
('Playful Hoodie Dress',9.99,NULL,50,3,1),
('Cartoon Print Hoodie Dress',23.99,NULL,50,3,1),
('Two-Tone Hoodie Dress',15.99,NULL,50,3,1),
('Sunny Yellow Puffer Jacket',16.99,NULL,50,3,1),
('Rainbow Puffer Jacket',10.99,NULL,50,3,1),
('Dino Print Puffer Jacket',21.99,NULL,50,3,1),
('Floral Puffer Jacket',12.99,NULL,50,3,1),
('Polka Dot Puffer Jacket',17.99,NULL,50,3,1),
('Striped Puffer Jacket',20.99,NULL,50,3,1),
('Star Print Puffer Jacket',16.99,NULL,50,3,1),
('Pastel Puffer Jacket',12.99,NULL,50,3,1),
('Camo Puffer Jacket',22.99,NULL,50,3,1),
('Unicorn Puffer Jacket',20.99,NULL,50,3,1),
('Cloud Print Puffer Jacket',13.99,NULL,50,3,1),
('Sporty Puffer Jacket',12.99,NULL,50,3,1),
('Cherry Print Puffer Jacket',23.99,NULL,50,3,1),
('Denim Puffer Jacket',10.99,NULL,50,3,1),
('Cozy Puffer Jacket',16.99,NULL,50,3,1),
('Playful Puffer Jacket',13.99,NULL,50,3,1),
('Cartoon Print Puffer Jacket',24.99,NULL,50,3,1),
('Two-Tone Puffer Jacket',9.99,NULL,50,3,1),
('Sunny Yellow Striped Leggings',10.99,NULL,50,3,1),
('Rainbow Striped Leggings',22.99,NULL,50,3,1),
('Dino Print Striped Leggings',21.99,NULL,50,3,1),
('Floral Striped Leggings',14.99,NULL,50,3,1),
('Polka Dot Striped Leggings',21.99,NULL,50,3,1),
('Striped Striped Leggings',19.99,NULL,50,3,1),
('Star Print Striped Leggings',24.99,NULL,50,3,1),
('Pastel Striped Leggings',15.99,NULL,50,3,1),
('Camo Striped Leggings',14.99,NULL,50,3,1),
('Unicorn Striped Leggings',18.99,NULL,50,3,1),
('Cloud Print Striped Leggings',19.99,NULL,50,3,1),
('Sporty Striped Leggings',12.99,NULL,50,3,1),
('Cherry Print Striped Leggings',19.99,NULL,50,3,1),
('Denim Striped Leggings',12.99,NULL,50,3,1),
('Cozy Striped Leggings',17.99,NULL,50,3,1),
('Playful Striped Leggings',16.99,NULL,50,3,1),
('Cartoon Print Striped Leggings',14.99,NULL,50,3,1),
('Two-Tone Striped Leggings',9.99,NULL,50,3,1),
('Sunny Yellow Tutu Skirt',15.99,NULL,50,3,1),
('Rainbow Tutu Skirt',18.99,NULL,50,3,1),
('Dino Print Tutu Skirt',16.99,NULL,50,3,1),
('Floral Tutu Skirt',14.99,NULL,50,3,1),
('Polka Dot Tutu Skirt',21.99,NULL,50,3,1),
('Striped Tutu Skirt',20.99,NULL,50,3,1),
('Star Print Tutu Skirt',23.99,NULL,50,3,1),
('Pastel Tutu Skirt',14.99,NULL,50,3,1),
('Camo Tutu Skirt',22.99,NULL,50,3,1),
('Unicorn Tutu Skirt',24.99,NULL,50,3,1),
('Cloud Print Tutu Skirt',14.99,NULL,50,3,1),
('Sporty Tutu Skirt',21.99,NULL,50,3,1),
('Cherry Print Tutu Skirt',17.99,NULL,50,3,1),
('Denim Tutu Skirt',23.99,NULL,50,3,1),
('Cozy Tutu Skirt',16.99,NULL,50,3,1),
('Playful Tutu Skirt',12.99,NULL,50,3,1),
('Cartoon Print Tutu Skirt',13.99,NULL,50,3,1),
('Two-Tone Tutu Skirt',15.99,NULL,50,3,1),
('Sunny Yellow Sneakers',18.99,NULL,50,3,1),
('Rainbow Sneakers',18.99,NULL,50,3,1),
('Dino Print Sneakers',20.99,NULL,50,3,1),
('Floral Sneakers',21.99,NULL,50,3,1),
('Polka Dot Sneakers',10.99,NULL,50,3,1),
('Striped Sneakers',9.99,NULL,50,3,1),
('Star Print Sneakers',22.99,NULL,50,3,1),
('Pastel Sneakers',23.99,NULL,50,3,1),
('Camo Sneakers',18.99,NULL,50,3,1),
('Unicorn Sneakers',13.99,NULL,50,3,1),
('Cloud Print Sneakers',19.99,NULL,50,3,1),
('Sporty Sneakers',22.99,NULL,50,3,1),
('Cherry Print Sneakers',19.99,NULL,50,3,1),
('Denim Sneakers',10.99,NULL,50,3,1),
('Cozy Sneakers',21.99,NULL,50,3,1),
('Playful Sneakers',14.99,NULL,50,3,1),
('Cartoon Print Sneakers',14.99,NULL,50,3,1),
('Two-Tone Sneakers',13.99,NULL,50,3,1),
('Sunny Yellow Raincoat',9.99,NULL,50,3,1),
('Rainbow Raincoat',20.99,NULL,50,3,1),
('Dino Print Raincoat',23.99,NULL,50,3,1),
('Floral Raincoat',15.99,NULL,50,3,1),
('Polka Dot Raincoat',14.99,NULL,50,3,1),
('Striped Raincoat',17.99,NULL,50,3,1),
('Star Print Raincoat',11.99,NULL,50,3,1),
('Matte Lipstick Set',15.99,NULL,50,5,1),
('Hydrating Face Serum',22.99,NULL,50,5,1),
('Vitamin C Cleanser',18.99,NULL,50,5,1),
('Rose Body Lotion',13.99,NULL,50,5,1),
('Hydrating Lipstick Set',15.99,NULL,50,5,1),
('Matte Lipstick Set',33.99,NULL,50,5,1),
('Vitamin C Lipstick Set',33.99,NULL,50,5,1),
('Rose Lipstick Set',31.99,NULL,50,5,1),
('Glow Lipstick Set',20.99,NULL,50,5,1),
('Radiant Lipstick Set',21.99,NULL,50,5,1),
('Nourishing Lipstick Set',24.99,NULL,50,5,1),
('Silky Lipstick Set',28.99,NULL,50,5,1),
('Everyday Lipstick Set',23.99,NULL,50,5,1),
('Travel-Size Lipstick Set',26.99,NULL,50,5,1),
('Botanical Lipstick Set',15.99,NULL,50,5,1),
('Soothing Lipstick Set',11.99,NULL,50,5,1),
('Brightening Lipstick Set',11.99,NULL,50,5,1),
('Refreshing Lipstick Set',32.99,NULL,50,5,1),
('Hydrating Face Serum',25.99,NULL,50,5,1),
('Matte Face Serum',11.99,NULL,50,5,1);

INSERT INTO Products (ProductName, Price, OriginalPrice, Stock, CategoryID, IsActive) VALUES
('Vitamin C Face Serum',26.99,NULL,50,5,1),
('Rose Face Serum',27.99,NULL,50,5,1),
('Glow Face Serum',21.99,NULL,50,5,1),
('Radiant Face Serum',27.99,NULL,50,5,1),
('Nourishing Face Serum',22.99,NULL,50,5,1),
('Silky Face Serum',21.99,NULL,50,5,1),
('Everyday Face Serum',12.99,NULL,50,5,1),
('Travel-Size Face Serum',17.99,NULL,50,5,1),
('Botanical Face Serum',10.99,NULL,50,5,1),
('Soothing Face Serum',21.99,NULL,50,5,1),
('Brightening Face Serum',21.99,NULL,50,5,1),
('Refreshing Face Serum',17.99,NULL,50,5,1),
('Hydrating Cleanser',25.99,NULL,50,5,1),
('Matte Cleanser',9.99,NULL,50,5,1),
('Vitamin C Cleanser',24.99,NULL,50,5,1),
('Rose Cleanser',12.99,NULL,50,5,1),
('Glow Cleanser',13.99,NULL,50,5,1),
('Radiant Cleanser',10.99,NULL,50,5,1),
('Nourishing Cleanser',14.99,NULL,50,5,1),
('Silky Cleanser',28.99,NULL,50,5,1),
('Everyday Cleanser',22.99,NULL,50,5,1),
('Travel-Size Cleanser',15.99,NULL,50,5,1),
('Botanical Cleanser',23.99,NULL,50,5,1),
('Soothing Cleanser',10.99,NULL,50,5,1),
('Brightening Cleanser',32.99,NULL,50,5,1),
('Refreshing Cleanser',33.99,NULL,50,5,1),
('Hydrating Body Lotion',13.99,NULL,50,5,1),
('Matte Body Lotion',34.99,NULL,50,5,1),
('Vitamin C Body Lotion',27.99,NULL,50,5,1),
('Rose Body Lotion',20.99,NULL,50,5,1),
('Glow Body Lotion',17.99,NULL,50,5,1),
('Radiant Body Lotion',33.99,NULL,50,5,1),
('Nourishing Body Lotion',26.99,NULL,50,5,1),
('Silky Body Lotion',10.99,NULL,50,5,1),
('Everyday Body Lotion',21.99,NULL,50,5,1),
('Travel-Size Body Lotion',12.99,NULL,50,5,1),
('Botanical Body Lotion',21.99,NULL,50,5,1),
('Soothing Body Lotion',20.99,NULL,50,5,1),
('Brightening Body Lotion',8.99,NULL,50,5,1),
('Refreshing Body Lotion',20.99,NULL,50,5,1),
('Hydrating Eyeshadow Palette',20.99,NULL,50,5,1),
('Matte Eyeshadow Palette',11.99,NULL,50,5,1),
('Vitamin C Eyeshadow Palette',14.99,NULL,50,5,1),
('Rose Eyeshadow Palette',15.99,NULL,50,5,1),
('Glow Eyeshadow Palette',23.99,NULL,50,5,1),
('Radiant Eyeshadow Palette',24.99,NULL,50,5,1),
('Nourishing Eyeshadow Palette',12.99,NULL,50,5,1),
('Silky Eyeshadow Palette',19.99,NULL,50,5,1),
('Soft Cotton Onesie',14.99,NULL,50,4,1),
('Maternity Wrap Dress',32.99,NULL,50,4,1),
('Baby Sun Hat',9.99,NULL,50,4,1),
('Nursing Cover',17.99,NULL,50,4,1),
('Soft Cotton Onesie',28.99,NULL,50,4,1),
('Organic Onesie',9.99,NULL,50,4,1),
('Cozy Onesie',28.99,NULL,50,4,1),
('Gentle Onesie',27.99,NULL,50,4,1),
('Breathable Onesie',19.99,NULL,50,4,1),
('Cloud Soft Onesie',11.99,NULL,50,4,1),
('Pastel Onesie',10.99,NULL,50,4,1),
('Striped Onesie',12.99,NULL,50,4,1),
('Muslin Onesie',26.99,NULL,50,4,1),
('Fleece-Lined Onesie',26.99,NULL,50,4,1),
('Lightweight Onesie',19.99,NULL,50,4,1),
('Snug Onesie',22.99,NULL,50,4,1),
('Soft Cotton Wrap Dress',25.99,NULL,50,4,1),
('Organic Wrap Dress',14.99,NULL,50,4,1),
('Cozy Wrap Dress',11.99,NULL,50,4,1),
('Gentle Wrap Dress',14.99,NULL,50,4,1),
('Breathable Wrap Dress',15.99,NULL,50,4,1),
('Cloud Soft Wrap Dress',18.99,NULL,50,4,1),
('Pastel Wrap Dress',22.99,NULL,50,4,1),
('Striped Wrap Dress',22.99,NULL,50,4,1),
('Muslin Wrap Dress',19.99,NULL,50,4,1),
('Fleece-Lined Wrap Dress',13.99,NULL,50,4,1),
('Lightweight Wrap Dress',26.99,NULL,50,4,1),
('Snug Wrap Dress',29.99,NULL,50,4,1),
('Soft Cotton Sun Hat',20.99,NULL,50,4,1),
('Organic Sun Hat',20.99,NULL,50,4,1),
('Cozy Sun Hat',25.99,NULL,50,4,1),
('Gentle Sun Hat',18.99,NULL,50,4,1),
('Breathable Sun Hat',15.99,NULL,50,4,1),
('Cloud Soft Sun Hat',18.99,NULL,50,4,1),
('Pastel Sun Hat',20.99,NULL,50,4,1),
('Striped Sun Hat',9.99,NULL,50,4,1),
('Muslin Sun Hat',22.99,NULL,50,4,1),
('Fleece-Lined Sun Hat',23.99,NULL,50,4,1),
('Lightweight Sun Hat',11.99,NULL,50,4,1),
('Snug Sun Hat',24.99,NULL,50,4,1),
('Soft Cotton Nursing Cover',14.99,NULL,50,4,1),
('Organic Nursing Cover',15.99,NULL,50,4,1),
('Cozy Nursing Cover',28.99,NULL,50,4,1),
('Gentle Nursing Cover',27.99,NULL,50,4,1),
('Breathable Nursing Cover',13.99,NULL,50,4,1),
('Cloud Soft Nursing Cover',14.99,NULL,50,4,1),
('Pastel Nursing Cover',22.99,NULL,50,4,1),
('Structured Tote Bag',29.99,NULL,50,6,1),
('Crossbody Bag',24.99,NULL,50,6,1),
('Carry-On Suitcase',59.99,NULL,50,6,1),
('Weekender Duffel',34.99,NULL,50,6,1),
('Structured Tote Bag',19.99,NULL,50,6,1),
('Woven Tote Bag',65.99,NULL,50,6,1),
('Quilted Tote Bag',38.99,NULL,50,6,1),
('Vintage Tote Bag',61.99,NULL,50,6,1),
('Minimalist Tote Bag',20.99,NULL,50,6,1),
('Lightweight Tote Bag',52.99,NULL,50,6,1),
('Water-Resistant Tote Bag',23.99,NULL,50,6,1),
('Two-Tone Tote Bag',65.99,NULL,50,6,1),
('Compact Tote Bag',54.99,NULL,50,6,1),
('Classic Tote Bag',60.99,NULL,50,6,1),
('Textured Tote Bag',25.99,NULL,50,6,1),
('Bold Tote Bag',52.99,NULL,50,6,1),
('Structured Crossbody Bag',36.99,NULL,50,6,1),
('Woven Crossbody Bag',53.99,NULL,50,6,1),
('Quilted Crossbody Bag',54.99,NULL,50,6,1),
('Vintage Crossbody Bag',23.99,NULL,50,6,1),
('Minimalist Crossbody Bag',21.99,NULL,50,6,1),
('Lightweight Crossbody Bag',48.99,NULL,50,6,1),
('Water-Resistant Crossbody Bag',28.99,NULL,50,6,1),
('Two-Tone Crossbody Bag',17.99,NULL,50,6,1),
('Compact Crossbody Bag',23.99,NULL,50,6,1),
('Classic Crossbody Bag',57.99,NULL,50,6,1),
('Textured Crossbody Bag',21.99,NULL,50,6,1),
('Bold Crossbody Bag',38.99,NULL,50,6,1),
('Structured Suitcase',63.99,NULL,50,6,1),
('Woven Suitcase',58.99,NULL,50,6,1),
('Quilted Suitcase',28.99,NULL,50,6,1),
('Vintage Suitcase',60.99,NULL,50,6,1),
('Minimalist Suitcase',64.99,NULL,50,6,1),
('Lightweight Suitcase',26.99,NULL,50,6,1),
('Water-Resistant Suitcase',46.99,NULL,50,6,1),
('Two-Tone Suitcase',63.99,NULL,50,6,1),
('Compact Suitcase',57.99,NULL,50,6,1),
('Classic Suitcase',57.99,NULL,50,6,1),
('Textured Suitcase',15.99,NULL,50,6,1),
('Bold Suitcase',16.99,NULL,50,6,1),
('Structured Duffel Bag',57.99,NULL,50,6,1),
('Woven Duffel Bag',45.99,NULL,50,6,1),
('Quilted Duffel Bag',17.99,NULL,50,6,1),
('Vintage Duffel Bag',53.99,NULL,50,6,1),
('Minimalist Duffel Bag',20.99,NULL,50,6,1),
('Lightweight Duffel Bag',65.99,NULL,50,6,1),
('Water-Resistant Duffel Bag',21.99,NULL,50,6,1),
('Two-Tone Duffel Bag',32.99,NULL,50,6,1),
('Compact Duffel Bag',68.99,NULL,50,6,1),
('Classic Duffel Bag',24.99,NULL,50,6,1),
('Textured Duffel Bag',31.99,NULL,50,6,1),
('Bold Duffel Bag',59.99,NULL,50,6,1),
('Structured Backpack',25.99,NULL,50,6,1),
('Woven Backpack',61.99,NULL,50,6,1),
('Quilted Backpack',27.99,NULL,50,6,1),
('Vintage Backpack',51.99,NULL,50,6,1),
('Minimalist Backpack',22.99,NULL,50,6,1),
('Lightweight Backpack',62.99,NULL,50,6,1),
('Water-Resistant Backpack',27.99,NULL,50,6,1),
('Two-Tone Backpack',16.99,NULL,50,6,1),
('Compact Backpack',40.99,NULL,50,6,1),
('Classic Backpack',64.99,NULL,50,6,1),
('Textured Backpack',67.99,NULL,50,6,1),
('Leather Notebook',11.99,NULL,50,9,1),
('Desk Organizer Set',19.99,NULL,50,9,1),
('Ceramic Pen Set',9.99,NULL,50,9,1),
('Canvas Backpack',27.99,NULL,50,9,1),
('Leather Notebook',18.99,NULL,50,9,1),
('Ceramic Notebook',13.99,NULL,50,9,1),
('Canvas Notebook',6.99,NULL,50,9,1),
('Minimalist Notebook',11.99,NULL,50,9,1),
('Colorful Notebook',18.99,NULL,50,9,1),
('Kraft Notebook',19.99,NULL,50,9,1),
('Compact Notebook',24.99,NULL,50,9,1),
('Recycled Notebook',10.99,NULL,50,9,1),
('Aesthetic Notebook',11.99,NULL,50,9,1),
('Classic Notebook',24.99,NULL,50,9,1),
('Pastel Notebook',23.99,NULL,50,9,1),
('Sleek Notebook',18.99,NULL,50,9,1),
('Leather Desk Organizer',15.99,NULL,50,9,1),
('Ceramic Desk Organizer',8.99,NULL,50,9,1),
('Canvas Desk Organizer',7.99,NULL,50,9,1),
('Minimalist Desk Organizer',23.99,NULL,50,9,1),
('Colorful Desk Organizer',19.99,NULL,50,9,1),
('Kraft Desk Organizer',12.99,NULL,50,9,1),
('Compact Desk Organizer',20.99,NULL,50,9,1),
('Recycled Desk Organizer',6.99,NULL,50,9,1),
('Aesthetic Desk Organizer',15.99,NULL,50,9,1),
('Classic Desk Organizer',12.99,NULL,50,9,1),
('Pastel Desk Organizer',9.99,NULL,50,9,1),
('Sleek Desk Organizer',20.99,NULL,50,9,1),
('Leather Pen Set',19.99,NULL,50,9,1),
('Ceramic Pen Set',19.99,NULL,50,9,1),
('Canvas Pen Set',24.99,NULL,50,9,1),
('Minimalist Pen Set',21.99,NULL,50,9,1),
('Colorful Pen Set',11.99,NULL,50,9,1),
('Kraft Pen Set',15.99,NULL,50,9,1),
('Compact Pen Set',12.99,NULL,50,9,1),
('Recycled Pen Set',7.99,NULL,50,9,1),
('Aesthetic Pen Set',17.99,NULL,50,9,1),
('Classic Pen Set',14.99,NULL,50,9,1),
('Pastel Pen Set',7.99,NULL,50,9,1),
('Sleek Pen Set',10.99,NULL,50,9,1),
('Leather Backpack',19.99,NULL,50,9,1),
('Ceramic Backpack',16.99,NULL,50,9,1),
('Canvas Backpack',6.99,NULL,50,9,1),
('Minimalist Backpack',9.99,NULL,50,9,1),
('Colorful Backpack',20.99,NULL,50,9,1),
('Kraft Backpack',13.99,NULL,50,9,1),
('Compact Backpack',10.99,NULL,50,9,1),
('Recycled Backpack',11.99,NULL,50,9,1),
('Aesthetic Backpack',14.99,NULL,50,9,1);

-- All image data supplied by the source (622 rows)
INSERT INTO ProductImages (ProductID, ImageURL, IsMain) VALUES
(1, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=900&auto=format&fit=crop', 1),
(2, 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=900&auto=format&fit=crop', 1),
(3, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=900&auto=format&fit=crop', 1),
(4, 'https://images.unsplash.com/photo-1554568218-0f1715e72254?q=80&w=900&auto=format&fit=crop', 1),
(5, 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?q=80&w=900&auto=format&fit=crop', 1),
(6, 'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?q=80&w=900&auto=format&fit=crop', 1),
(7, 'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=900&auto=format&fit=crop', 1),
(8, 'https://images.unsplash.com/photo-1602293589930-45aad59ba3ab?q=80&w=900&auto=format&fit=crop', 1),
(9, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=900&auto=format&fit=crop', 1),
(10, 'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop', 1),
(11, 'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop', 1),
(12, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=900&auto=format&fit=crop', 1),
(13, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=900&auto=format&fit=crop', 1),
(15, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.44%20AM%20%283%29.jpeg', 1),
(16, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM%20%281%29.jpeg', 1),
(17, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM%20%282%29.jpeg', 1),
(18, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM%20%284%29.jpeg', 1),
(19, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM%20%285%29.jpeg', 1),
(20, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM.jpeg', 1),
(21, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM%20%281%29.jpeg', 1),
(22, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM%20%282%29.jpeg', 1),
(23, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM%20%283%29.jpeg', 1),
(24, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM%20%284%29.jpeg', 1),
(25, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM%20%285%29.jpeg', 1),
(26, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.46%20AM.jpeg', 1),
(27, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%281%29.jpeg', 1),
(28, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%282%29.jpeg', 1),
(29, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%283%29.jpeg', 1),
(30, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%284%29.jpeg', 1),
(31, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%285%29.jpeg', 1),
(32, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%286%29.jpeg', 1),
(33, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%287%29.jpeg', 1),
(34, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM%20%288%29.jpeg', 1),
(35, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.47%20AM.jpeg', 1),
(36, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%281%29.jpeg', 1),
(37, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%282%29.jpeg', 1),
(38, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%283%29.jpeg', 1),
(39, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%284%29.jpeg', 1),
(40, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%285%29.jpeg', 1),
(41, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%286%29.jpeg', 1),
(42, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%287%29.jpeg', 1),
(43, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM%20%288%29.jpeg', 1),
(44, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.48%20AM.jpeg', 1),
(45, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%281%29.jpeg', 1),
(46, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%282%29.jpeg', 1),
(47, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%283%29.jpeg', 1),
(48, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%284%29.jpeg', 1),
(49, 'photo/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM.jpeg', 1),
(50, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.37%20AM%20%282%29.jpeg', 1),
(51, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.38%20AM.jpeg', 1),
(52, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.39%20AM%20%281%29.jpeg', 1),
(53, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.39%20AM.jpeg', 1),
(54, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.40%20AM%20%281%29.jpeg', 1),
(55, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.40%20AM%20%282%29.jpeg', 1),
(56, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.40%20AM.jpeg', 1),
(57, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.41%20AM.jpeg', 1),
(58, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.42%20AM%20%281%29.jpeg', 1),
(59, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.42%20AM.jpeg', 1),
(60, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.43%20AM%20%281%29.jpeg', 1),
(61, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.43%20AM.jpeg', 1),
(62, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.44%20AM.jpeg', 1),
(63, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.45%20AM%20%281%29.jpeg', 1),
(64, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.45%20AM.jpeg', 1),
(65, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.46%20AM.jpeg', 1),
(66, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.47%20AM%20%281%29.jpeg', 1),
(67, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.47%20AM%20%282%29.jpeg', 1),
(68, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.47%20AM.jpeg', 1),
(69, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.48%20AM%20%281%29.jpeg', 1),
(70, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.48%20AM%20%282%29.jpeg', 1),
(71, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.48%20AM%20%283%29.jpeg', 1),
(72, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.48%20AM.jpeg', 1),
(73, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.49%20AM%20%281%29.jpeg', 1),
(74, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.49%20AM%20%283%29.jpeg', 1),
(75, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.49%20AM%20%284%29.jpeg', 1),
(76, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.49%20AM.jpeg', 1),
(77, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.50%20AM%20%281%29.jpeg', 1),
(78, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.50%20AM.jpeg', 1),
(79, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.54%20AM.jpeg', 1),
(80, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.56%20AM.jpeg', 1),
(81, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.57%20AM%20%281%29.jpeg', 1),
(82, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.57%20AM%20%282%29.jpeg', 1),
(83, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.57%20AM%20%283%29.jpeg', 1),
(84, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.57%20AM.jpeg', 1),
(85, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.58%20AM.jpeg', 1),
(86, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.59%20AM%20%281%29.jpeg', 1),
(87, 'photo/WhatsApp%20Image%202026-09-06%20at%206.13.59%20AM.jpeg', 1),
(88, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.00%20AM%20%281%29.jpeg', 1),
(89, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.00%20AM%20%282%29.jpeg', 1),
(90, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.00%20AM%20%283%29.jpeg', 1),
(91, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.00%20AM.jpeg', 1),
(92, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.25%20AM.jpeg', 1),
(93, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.26%20AM%20%281%29.jpeg', 1),
(94, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.26%20AM.jpeg', 1),
(95, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.27%20AM%20%282%29.jpeg', 1),
(96, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.28%20AM%20%281%29.jpeg', 1),
(97, 'photo/WhatsApp%20Image%202026-09-06%20at%206.14.28%20AM.jpeg', 1),
(98, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.42%20AM%20%281%29.jpeg', 1),
(99, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.44%20AM.jpeg', 1),
(100, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.45%20AM.jpeg', 1),
(101, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.46%20AM.jpeg', 1),
(102, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.47%20AM%20%281%29.jpeg', 1),
(103, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.47%20AM.jpeg', 1),
(104, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.48%20AM.jpeg', 1),
(105, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.49%20AM%20%281%29.jpeg', 1),
(106, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.49%20AM.jpeg', 1),
(107, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.50%20AM%20%281%29.jpeg', 1),
(108, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.50%20AM.jpeg', 1),
(109, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.51%20AM%20%281%29.jpeg', 1),
(110, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.51%20AM%20%282%29.jpeg', 1),
(111, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.51%20AM.jpeg', 1),
(112, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.52%20AM%20%281%29.jpeg', 1),
(113, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.52%20AM%20%282%29.jpeg', 1),
(114, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.52%20AM.jpeg', 1),
(115, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.53%20AM%20%281%29.jpeg', 1),
(116, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.53%20AM%20%282%29.jpeg', 1),
(117, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.53%20AM.jpeg', 1),
(118, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.54%20AM%20%281%29.jpeg', 1),
(119, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.54%20AM%20%282%29.jpeg', 1),
(120, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.54%20AM%20%283%29.jpeg', 1),
(121, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.54%20AM.jpeg', 1),
(122, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.55%20AM%20%281%29.jpeg', 1),
(123, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.55%20AM%20%282%29.jpeg', 1),
(124, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.55%20AM.jpeg', 1),
(125, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.56%20AM%20%281%29.jpeg', 1),
(126, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.56%20AM%20%282%29.jpeg', 1),
(127, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.56%20AM%20%283%29.jpeg', 1),
(128, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.56%20AM.jpeg', 1),
(129, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.57%20AM%20%281%29.jpeg', 1),
(130, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.57%20AM%20%282%29.jpeg', 1),
(131, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.57%20AM.jpeg', 1),
(132, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.58%20AM%20%281%29.jpeg', 1),
(133, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.58%20AM%20%282%29.jpeg', 1),
(134, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.37.58%20AM.jpeg', 1),
(135, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.00%20AM%20%282%29.jpeg', 1),
(136, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.00%20AM.jpeg', 1),
(137, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.01%20AM%20%281%29.jpeg', 1),
(138, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.01%20AM%20%282%29.jpeg', 1),
(139, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.01%20AM%20%283%29.jpeg', 1),
(140, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.01%20AM%20%284%29.jpeg', 1),
(141, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.01%20AM.jpeg', 1),
(142, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.02%20AM%20%281%29.jpeg', 1),
(143, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.02%20AM%20%282%29.jpeg', 1),
(144, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.02%20AM%20%283%29.jpeg', 1),
(145, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.02%20AM.jpeg', 1),
(146, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.03%20AM%20%281%29.jpeg', 1),
(147, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.03%20AM%20%282%29.jpeg', 1),
(148, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.03%20AM%20%283%29.jpeg', 1),
(149, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.03%20AM.jpeg', 1),
(150, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.04%20AM%20%281%29.jpeg', 1),
(151, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.04%20AM%20%282%29.jpeg', 1),
(152, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.04%20AM%20%283%29.jpeg', 1),
(153, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.04%20AM%20%284%29.jpeg', 1),
(154, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.04%20AM.jpeg', 1),
(155, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.05%20AM%20%281%29.jpeg', 1),
(156, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.05%20AM%20%282%29.jpeg', 1),
(157, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.05%20AM%20%283%29.jpeg', 1),
(158, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.05%20AM.jpeg', 1),
(159, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.06%20AM%20%281%29.jpeg', 1),
(160, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.06%20AM%20%282%29.jpeg', 1),
(161, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.06%20AM.jpeg', 1),
(162, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.07%20AM%20%283%29.jpeg', 1),
(163, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.07%20AM.jpeg', 1),
(164, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.09%20AM%20%281%29.jpeg', 1),
(165, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.09%20AM.jpeg', 1),
(166, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.10%20AM%20%281%29.jpeg', 1),
(167, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.10%20AM%20%282%29.jpeg', 1),
(168, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.10%20AM%20%283%29.jpeg', 1),
(169, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.10%20AM%20%284%29.jpeg', 1),
(170, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.10%20AM.jpeg', 1),
(171, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.11%20AM.jpeg', 1),
(172, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.12%20AM%20%281%29.jpeg', 1),
(173, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.12%20AM%20%282%29.jpeg', 1),
(174, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.12%20AM%20%283%29.jpeg', 1),
(175, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.12%20AM.jpeg', 1),
(176, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.13%20AM%20%281%29.jpeg', 1),
(177, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.13%20AM%20%282%29.jpeg', 1),
(178, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.13%20AM%20%283%29.jpeg', 1),
(179, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.13%20AM.jpeg', 1),
(180, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.14%20AM%20%281%29.jpeg', 1),
(181, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.14%20AM%20%282%29.jpeg', 1),
(182, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.14%20AM%20%283%29.jpeg', 1),
(183, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.14%20AM.jpeg', 1),
(184, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.15%20AM%20%281%29.jpeg', 1),
(185, 'photo/WhatsApp%20Image%202026-09-07%20at%2012.39.15%20AM.jpeg', 1),
(186, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.26%20AM%20%282%29.jpeg', 1),
(187, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.27%20AM%20%281%29.jpeg', 1),
(188, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.27%20AM.jpeg', 1),
(189, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.29%20AM%20%281%29.jpeg', 1),
(190, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.29%20AM%20%282%29.jpeg', 1),
(191, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.29%20AM%20%283%29.jpeg', 1),
(192, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.29%20AM.jpeg', 1),
(193, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.30%20AM%20%281%29.jpeg', 1),
(194, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.30%20AM.jpeg', 1),
(195, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.31%20AM.jpeg', 1),
(196, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.32%20AM%20%281%29.jpeg', 1),
(197, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.32%20AM%20%282%29.jpeg', 1),
(198, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.32%20AM%20%283%29.jpeg', 1),
(199, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.32%20AM.jpeg', 1),
(200, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.33%20AM%20%281%29.jpeg', 1),
(201, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.33%20AM%20%282%29.jpeg', 1),
(202, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.33%20AM.jpeg', 1),
(203, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.34%20AM%20%281%29.jpeg', 1),
(204, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.34%20AM.jpeg', 1),
(205, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.35%20AM%20%281%29.jpeg', 1),
(206, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.35%20AM%20%282%29.jpeg', 1),
(207, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.35%20AM.jpeg', 1),
(208, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.36%20AM%20%281%29.jpeg', 1),
(209, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.36%20AM%20%282%29.jpeg', 1),
(210, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.36%20AM.jpeg', 1),
(211, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.37%20AM.jpeg', 1),
(212, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.38%20AM%20%281%29.jpeg', 1),
(213, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.38%20AM.jpeg', 1),
(214, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.39%20AM%20%281%29.jpeg', 1),
(215, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.39%20AM.jpeg', 1),
(216, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.40%20AM%20%281%29.jpeg', 1),
(217, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.40%20AM%20%282%29.jpeg', 1),
(218, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.40%20AM.jpeg', 1),
(219, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.41%20AM%20%281%29.jpeg', 1),
(220, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.41%20AM.jpeg', 1),
(221, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.42%20AM%20%281%29.jpeg', 1),
(222, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.42%20AM.jpeg', 1),
(223, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.43%20AM%20%281%29.jpeg', 1),
(224, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.43%20AM.jpeg', 1),
(225, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.44%20AM%20%281%29.jpeg', 1),
(226, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.44%20AM%20%282%29.jpeg', 1),
(227, 'clo/WhatsApp%20Image%202026-09-06%20at%206.14.57%20AM.jpeg', 1),
(228, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.43%20AM.jpeg', 1),
(229, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.44%20AM%20%281%29.jpeg', 1),
(230, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.44%20AM%20%282%29.jpeg', 1),
(231, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.44%20AM.jpeg', 1),
(232, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.45%20AM%20%283%29.jpeg', 1),
(233, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%285%29.jpeg', 1),
(234, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%286%29.jpeg', 1),
(235, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.49%20AM%20%287%29.jpeg', 1),
(236, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM%20%281%29.jpeg', 1),
(237, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM%20%282%29.jpeg', 1),
(238, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM%20%283%29.jpeg', 1),
(239, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM%20%284%29.jpeg', 1),
(240, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM%20%285%29.jpeg', 1),
(241, 'images/WhatsApp%20Image%202026-09-06%20at%206.12.50%20AM.jpeg', 1),
(242, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.20%20AM%20%281%29.jpeg', 1),
(243, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.20%20AM%20%282%29.jpeg', 1),
(244, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.20%20AM.jpeg', 1),
(245, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.21%20AM%20%281%29.jpeg', 1),
(246, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.21%20AM%20%282%29.jpeg', 1),
(247, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.21%20AM%20%283%29.jpeg', 1),
(248, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.21%20AM.jpeg', 1),
(249, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.22%20AM%20%281%29.jpeg', 1),
(250, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.22%20AM%20%282%29.jpeg', 1),
(251, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.22%20AM.jpeg', 1),
(252, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.23%20AM%20%281%29.jpeg', 1),
(253, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.23%20AM.jpeg', 1),
(254, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.24%20AM%20%281%29.jpeg', 1),
(255, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.24%20AM.jpeg', 1),
(256, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.25%20AM%20%281%29.jpeg', 1),
(257, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.25%20AM.jpeg', 1),
(258, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.26%20AM%20%281%29.jpeg', 1),
(259, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.26%20AM%20%282%29.jpeg', 1),
(260, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.26%20AM%20%283%29.jpeg', 1),
(261, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.26%20AM.jpeg', 1),
(262, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.27%20AM.jpeg', 1),
(263, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.28%20AM%20%281%29.jpeg', 1),
(264, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.28%20AM%20%282%29.jpeg', 1),
(265, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.28%20AM%20%283%29.jpeg', 1),
(266, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.28%20AM.jpeg', 1),
(267, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.29%20AM%20%281%29.jpeg', 1),
(268, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.29%20AM.jpeg', 1),
(269, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.30%20AM%20%281%29.jpeg', 1),
(270, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.31%20AM%20%281%29.jpeg', 1),
(271, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.31%20AM%20%282%29.jpeg', 1),
(272, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.32%20AM%20%281%29.jpeg', 1),
(273, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.33%20AM%20%281%29.jpeg', 1),
(274, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.33%20AM%20%282%29.jpeg', 1),
(275, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.33%20AM%20%283%29.jpeg', 1),
(276, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.34%20AM%20%281%29.jpeg', 1),
(277, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.34%20AM.jpeg', 1),
(278, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.35%20AM%20%281%29.jpeg', 1),
(279, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.35%20AM%20%282%29.jpeg', 1),
(280, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.35%20AM.jpeg', 1),
(281, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.36%20AM%20%281%29.jpeg', 1),
(282, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.36%20AM.jpeg', 1),
(283, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.37%20AM%20%281%29.jpeg', 1),
(284, 'images/WhatsApp%20Image%202026-09-06%20at%206.13.37%20AM.jpeg', 1),
(285, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.43%20AM%20%282%29.jpeg', 1),
(286, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.43%20AM%20%283%29.jpeg', 1),
(287, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.44%20AM%20%281%29.jpeg', 1),
(288, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.44%20AM%20%282%29.jpeg', 1),
(289, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.44%20AM%20%283%29.jpeg', 1),
(290, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.44%20AM%20%284%29.jpeg', 1),
(291, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.44%20AM.jpeg', 1),
(292, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.45%20AM%20%281%29.jpeg', 1),
(293, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.45%20AM%20%282%29.jpeg', 1),
(294, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.45%20AM%20%283%29.jpeg', 1),
(295, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.45%20AM.jpeg', 1),
(296, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.46%20AM%20%281%29.jpeg', 1),
(297, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.46%20AM%20%282%29.jpeg', 1),
(298, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.46%20AM.jpeg', 1),
(299, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.47%20AM%20%281%29.jpeg', 1),
(300, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.47%20AM%20%282%29.jpeg', 1),
(301, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.47%20AM%20%283%29.jpeg', 1),
(302, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.47%20AM.jpeg', 1),
(303, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.48%20AM%20%281%29.jpeg', 1),
(304, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.48%20AM%20%282%29.jpeg', 1),
(305, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.48%20AM%20%283%29.jpeg', 1),
(306, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.48%20AM.jpeg', 1),
(307, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.49%20AM%20%281%29.jpeg', 1),
(308, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.49%20AM%20%283%29.jpeg', 1),
(309, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.49%20AM%20%284%29.jpeg', 1),
(310, 'images/WhatsApp%20Image%202026-09-07%20at%2012.36.49%20AM.jpeg', 1),
(311, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.41%20AM%20%281%29.jpeg', 1),
(312, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.41%20AM.jpeg', 1),
(313, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.42%20AM.jpeg', 1),
(314, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.43%20AM%20%281%29.jpeg', 1),
(315, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.43%20AM.jpeg', 1),
(316, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.59%20AM%20%281%29.jpeg', 1),
(317, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.59%20AM%20%282%29.jpeg', 1),
(318, 'images/WhatsApp%20Image%202026-09-07%20at%2012.37.59%20AM.jpeg', 1),
(319, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.00%20AM%20%281%29.jpeg', 1),
(320, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.00%20AM%20%282%29.jpeg', 1),
(321, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.00%20AM.jpeg', 1),
(322, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.01%20AM%20%281%29.jpeg', 1),
(323, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.01%20AM.jpeg', 1),
(324, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.02%20AM%20%281%29.jpeg', 1),
(325, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.02%20AM.jpeg', 1),
(326, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.03%20AM%20%281%29.jpeg', 1),
(327, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.03%20AM.jpeg', 1),
(328, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.04%20AM%20%281%29.jpeg', 1),
(329, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.04%20AM%20%282%29.jpeg', 1),
(330, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.04%20AM.jpeg', 1),
(331, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.05%20AM%20%281%29.jpeg', 1),
(332, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.05%20AM.jpeg', 1),
(333, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.06%20AM%20%281%29.jpeg', 1),
(334, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.06%20AM%20%282%29.jpeg', 1),
(335, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.06%20AM.jpeg', 1),
(336, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.07%20AM.jpeg', 1),
(337, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.08%20AM%20%281%29.jpeg', 1),
(338, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.08%20AM%20%282%29.jpeg', 1),
(339, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.08%20AM.jpeg', 1),
(340, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.09%20AM%20%281%29.jpeg', 1),
(341, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.09%20AM.jpeg', 1),
(342, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.10%20AM%20%281%29.jpeg', 1),
(343, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.10%20AM.jpeg', 1),
(344, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.11%20AM%20%281%29.jpeg', 1),
(345, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.12%20AM%20%281%29.jpeg', 1),
(346, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.12%20AM.jpeg', 1),
(347, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.13%20AM%20%281%29.jpeg', 1),
(348, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.13%20AM.jpeg', 1),
(349, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.35%20AM.jpeg', 1),
(350, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.36%20AM.jpeg', 1),
(351, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.37%20AM%20%281%29.jpeg', 1),
(352, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.37%20AM.jpeg', 1),
(353, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.38%20AM%20%281%29.jpeg', 1),
(354, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.38%20AM.jpeg', 1),
(355, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.39%20AM%20%281%29.jpeg', 1),
(356, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.39%20AM.jpeg', 1),
(357, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.40%20AM%20%281%29.jpeg', 1),
(358, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.40%20AM.jpeg', 1),
(359, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.41%20AM%20%281%29.jpeg', 1),
(360, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.41%20AM.jpeg', 1),
(361, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.42%20AM%20%281%29.jpeg', 1),
(362, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.42%20AM%20%282%29.jpeg', 1),
(363, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.42%20AM.jpeg', 1),
(364, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.43%20AM%20%281%29.jpeg', 1),
(365, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.43%20AM.jpeg', 1),
(366, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.44%20AM.jpeg', 1),
(367, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.45%20AM.jpeg', 1),
(368, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.46%20AM%20%281%29.jpeg', 1),
(369, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.46%20AM%20%282%29.jpeg', 1),
(370, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.46%20AM.jpeg', 1),
(371, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.47%20AM%20%281%29.jpeg', 1),
(372, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.47%20AM.jpeg', 1),
(373, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.48%20AM%20%281%29.jpeg', 1),
(374, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.49%20AM.jpeg', 1),
(375, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.50%20AM%20%281%29.jpeg', 1),
(376, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.50%20AM.jpeg', 1),
(377, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.51%20AM%20%281%29.jpeg', 1),
(378, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.51%20AM%20%282%29.jpeg', 1),
(379, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.51%20AM.jpeg', 1),
(380, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.52%20AM%20%281%29.jpeg', 1),
(381, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.52%20AM%20%282%29.jpeg', 1),
(382, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.52%20AM.jpeg', 1),
(383, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.53%20AM%20%281%29.jpeg', 1),
(384, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.55%20AM%20%281%29.jpeg', 1),
(385, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.55%20AM.jpeg', 1),
(386, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.56%20AM%20%281%29.jpeg', 1),
(387, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.56%20AM%20%282%29.jpeg', 1),
(388, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.56%20AM.jpeg', 1),
(389, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.57%20AM%20%281%29.jpeg', 1),
(390, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.57%20AM.jpeg', 1),
(391, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.58%20AM%20%281%29.jpeg', 1),
(392, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.58%20AM%20%282%29.jpeg', 1),
(393, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.58%20AM.jpeg', 1),
(394, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.59%20AM%20%281%29.jpeg', 1),
(395, 'images/WhatsApp%20Image%202026-09-07%20at%2012.38.59%20AM.jpeg', 1),
(396, 'images/WhatsApp%20Image%202026-09-07%20at%2012.39.00%20AM%20%281%29.jpeg', 1),
(397, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.32.52%20AM%20%282%29.jpeg', 1),
(398, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.00%20AM.jpeg', 1),
(399, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.01%20AM%20%281%29.jpeg', 1),
(400, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.01%20AM.jpeg', 1),
(401, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.02%20AM%20%281%29.jpeg', 1),
(402, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.02%20AM.jpeg', 1),
(403, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.03%20AM%20%281%29.jpeg', 1),
(404, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.03%20AM.jpeg', 1),
(405, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.04%20AM%20%281%29.jpeg', 1),
(406, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.04%20AM%20%282%29.jpeg', 1),
(407, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.04%20AM.jpeg', 1),
(408, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.05%20AM%20%281%29.jpeg', 1),
(409, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.05%20AM.jpeg', 1),
(410, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.06%20AM%20%281%29.jpeg', 1),
(411, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.06%20AM%20%282%29.jpeg', 1),
(412, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.06%20AM.jpeg', 1),
(413, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.07%20AM%20%281%29.jpeg', 1),
(414, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.07%20AM.jpeg', 1),
(415, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.33%20AM.jpeg', 1),
(416, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.35%20AM%20%281%29.jpeg', 1),
(417, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.35%20AM.jpeg', 1),
(418, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.36%20AM.jpeg', 1),
(419, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.37%20AM%20%281%29.jpeg', 1),
(420, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.37%20AM%20%282%29.jpeg', 1),
(421, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.37%20AM.jpeg', 1),
(422, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.38%20AM%20%281%29.jpeg', 1),
(423, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.38%20AM%20%282%29.jpeg', 1),
(424, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.38%20AM%20%283%29.jpeg', 1),
(425, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.38%20AM.jpeg', 1),
(426, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.39%20AM%20%281%29.jpeg', 1),
(427, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.39%20AM%20%282%29.jpeg', 1),
(428, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.39%20AM.jpeg', 1),
(429, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.40%20AM%20%281%29.jpeg', 1),
(430, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.40%20AM%20%282%29.jpeg', 1),
(431, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.40%20AM.jpeg', 1),
(432, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.41%20AM%20%281%29.jpeg', 1),
(433, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.41%20AM.jpeg', 1),
(434, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.42%20AM%20%281%29.jpeg', 1),
(435, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.42%20AM%20%282%29.jpeg', 1),
(436, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.42%20AM%20%283%29.jpeg', 1),
(437, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.42%20AM.jpeg', 1),
(438, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.43%20AM%20%281%29.jpeg', 1),
(439, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.43%20AM%20%282%29.jpeg', 1),
(440, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.43%20AM.jpeg', 1),
(441, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.44%20AM%20%281%29.jpeg', 1),
(442, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.44%20AM%20%282%29.jpeg', 1),
(443, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.44%20AM%20%283%29.jpeg', 1),
(444, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.44%20AM.jpeg', 1),
(445, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.45%20AM%20%281%29.jpeg', 1),
(446, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.45%20AM%20%282%29.jpeg', 1),
(447, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.45%20AM%20%283%29.jpeg', 1),
(448, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.45%20AM.jpeg', 1),
(449, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.46%20AM%20%281%29.jpeg', 1),
(450, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.46%20AM%20%282%29.jpeg', 1),
(451, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.46%20AM%20%283%29.jpeg', 1),
(452, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.46%20AM%20%284%29.jpeg', 1),
(453, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.46%20AM.jpeg', 1),
(454, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.47%20AM%20%281%29.jpeg', 1),
(455, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.47%20AM%20%282%29.jpeg', 1),
(456, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.47%20AM%20%283%29.jpeg', 1),
(457, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.47%20AM.jpeg', 1),
(458, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.48%20AM%20%281%29.jpeg', 1),
(459, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.48%20AM%20%282%29.jpeg', 1),
(460, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.48%20AM%20%283%29.jpeg', 1),
(461, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.48%20AM.jpeg', 1),
(462, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.49%20AM%20%281%29.jpeg', 1),
(463, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.49%20AM%20%282%29.jpeg', 1),
(464, 'beau/WhatsApp%20Image%202026-09-07%20at%2012.33.49%20AM.jpeg', 1),
(465, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.30%20AM.jpeg', 1),
(466, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.31%20AM%20%283%29.jpeg', 1),
(467, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.31%20AM.jpeg', 1),
(468, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.32%20AM%20%282%29.jpeg', 1),
(469, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.32%20AM.jpeg', 1),
(470, 'gam/WhatsApp%20Image%202026-09-06%20at%206.13.33%20AM.jpeg', 1),
(471, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.47%20AM%20%281%29.jpeg', 1),
(472, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.47%20AM%20%282%29.jpeg', 1),
(473, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.48%20AM%20%281%29.jpeg', 1),
(474, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.48%20AM.jpeg', 1),
(475, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.49%20AM%20%281%29.jpeg', 1),
(476, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.49%20AM%20%282%29.jpeg', 1),
(477, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.49%20AM.jpeg', 1),
(478, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.50%20AM%20%281%29.jpeg', 1),
(479, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.50%20AM%20%282%29.jpeg', 1),
(480, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.50%20AM.jpeg', 1),
(481, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.51%20AM%20%281%29.jpeg', 1),
(482, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.51%20AM%20%282%29.jpeg', 1),
(483, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.51%20AM.jpeg', 1),
(484, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.52%20AM%20%281%29.jpeg', 1),
(485, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.52%20AM.jpeg', 1),
(486, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.53%20AM%20%281%29.jpeg', 1),
(487, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.53%20AM%20%282%29.jpeg', 1),
(488, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.53%20AM.jpeg', 1),
(489, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.54%20AM%20%281%29.jpeg', 1),
(490, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.54%20AM.jpeg', 1),
(491, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.55%20AM%20%281%29.jpeg', 1),
(492, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.55%20AM.jpeg', 1),
(493, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.56%20AM%20%281%29.jpeg', 1),
(494, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.56%20AM%20%282%29.jpeg', 1),
(495, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.56%20AM.jpeg', 1),
(496, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.57%20AM%20%281%29.jpeg', 1),
(497, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.57%20AM%20%282%29.jpeg', 1),
(498, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.57%20AM.jpeg', 1),
(499, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.58%20AM%20%281%29.jpeg', 1),
(500, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.58%20AM%20%282%29.jpeg', 1),
(501, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.58%20AM.jpeg', 1),
(502, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.59%20AM%20%281%29.jpeg', 1),
(503, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.59%20AM%20%282%29.jpeg', 1),
(504, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.32.59%20AM.jpeg', 1),
(505, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.33.00%20AM%20%281%29.jpeg', 1),
(506, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.33.00%20AM%20%282%29.jpeg', 1),
(507, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.33.00%20AM%20%283%29.jpeg', 1),
(508, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.38.53%20AM%20%282%29.jpeg', 1),
(509, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.38.53%20AM.jpeg', 1),
(510, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.38.54%20AM%20%281%29.jpeg', 1),
(511, 'gam/WhatsApp%20Image%202026-09-07%20at%2012.38.54%20AM.jpeg', 1),
(512, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.51%20AM%20%283%29.jpeg', 1),
(513, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.51%20AM.jpeg', 1),
(514, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.52%20AM%20%281%29.jpeg', 1),
(515, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.52%20AM%20%283%29.jpeg', 1),
(516, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.52%20AM.jpeg', 1),
(517, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.53%20AM%20%281%29.jpeg', 1),
(518, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.53%20AM%20%283%29.jpeg', 1),
(519, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.33.53%20AM.jpeg', 1),
(520, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.13%20AM%20%283%29.jpeg', 1),
(521, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.13%20AM.jpeg', 1),
(522, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.14%20AM%20%281%29.jpeg', 1),
(523, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.14%20AM%20%282%29.jpeg', 1),
(524, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.14%20AM%20%283%29.jpeg', 1),
(525, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.14%20AM.jpeg', 1),
(526, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.15%20AM%20%281%29.jpeg', 1),
(527, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.15%20AM%20%282%29.jpeg', 1),
(528, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.15%20AM.jpeg', 1),
(529, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.16%20AM%20%283%29.jpeg', 1),
(530, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.16%20AM%20%284%29.jpeg', 1),
(531, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.17%20AM%20%281%29.jpeg', 1),
(532, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.17%20AM.jpeg', 1),
(533, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.18%20AM%20%281%29.jpeg', 1),
(534, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.18%20AM%20%282%29.jpeg', 1),
(535, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.18%20AM%20%283%29.jpeg', 1),
(536, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.18%20AM.jpeg', 1),
(537, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.19%20AM%20%282%29.jpeg', 1),
(538, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.20%20AM%20%281%29.jpeg', 1),
(539, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.20%20AM%20%282%29.jpeg', 1),
(540, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.20%20AM%20%283%29.jpeg', 1),
(541, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.20%20AM.jpeg', 1),
(542, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.21%20AM%20%281%29.jpeg', 1),
(543, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.21%20AM%20%282%29.jpeg', 1),
(544, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.21%20AM%20%283%29.jpeg', 1),
(545, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.21%20AM.jpeg', 1),
(546, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.35.22%20AM%20%281%29.jpeg', 1),
(547, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.22%20AM.jpeg', 1),
(548, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.23%20AM.jpeg', 1),
(549, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.24%20AM%20%281%29.jpeg', 1),
(550, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.24%20AM.jpeg', 1),
(551, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.25%20AM%20%281%29.jpeg', 1),
(552, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.25%20AM.jpeg', 1),
(553, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.27%20AM%20%281%29.jpeg', 1),
(554, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.27%20AM.jpeg', 1),
(555, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.30%20AM.jpeg', 1),
(556, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.31%20AM%20%281%29.jpeg', 1),
(557, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.32%20AM.jpeg', 1),
(558, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.33%20AM%20%281%29.jpeg', 1),
(559, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.33%20AM%20%282%29.jpeg', 1),
(560, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.34%20AM%20%281%29.jpeg', 1),
(561, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.35%20AM.jpeg', 1),
(562, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.36%20AM%20%281%29.jpeg', 1),
(563, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.36%20AM%20%282%29.jpeg', 1),
(564, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.37%20AM%20%282%29.jpeg', 1),
(565, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.38%20AM%20%281%29.jpeg', 1),
(566, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.38%20AM%20%283%29.jpeg', 1),
(567, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.39%20AM%20%282%29.jpeg', 1),
(568, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.39%20AM.jpeg', 1),
(569, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.40%20AM%20%281%29.jpeg', 1),
(570, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.40%20AM%20%282%29.jpeg', 1),
(571, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.41%20AM.jpeg', 1),
(572, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.42%20AM%20%283%29.jpeg', 1),
(573, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.42%20AM.jpeg', 1),
(574, 'lug/WhatsApp%20Image%202026-09-07%20at%2012.36.43%20AM%20%281%29.jpeg', 1),
(575, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.33.55%20AM%20%282%29.jpeg', 1),
(576, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.33.56%20AM%20%281%29.jpeg', 1),
(577, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.33.56%20AM%20%283%29.jpeg', 1),
(578, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.33.56%20AM.jpeg', 1),
(579, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.33.57%20AM.jpeg', 1),
(580, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.56%20AM.jpeg', 1),
(581, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.57%20AM.jpeg', 1),
(582, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.58%20AM%20%281%29.jpeg', 1),
(583, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.58%20AM.jpeg', 1),
(584, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.59%20AM%20%281%29.jpeg', 1),
(585, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.59%20AM%20%282%29.jpeg', 1),
(586, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.34.59%20AM.jpeg', 1),
(587, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.00%20AM%20%281%29.jpeg', 1),
(588, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.00%20AM.jpeg', 1),
(589, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.01%20AM%20%281%29.jpeg', 1),
(590, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.01%20AM.jpeg', 1),
(591, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.02%20AM%20%281%29.jpeg', 1),
(592, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.02%20AM.jpeg', 1),
(593, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.03%20AM%20%281%29.jpeg', 1),
(594, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.03%20AM.jpeg', 1),
(595, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.04%20AM%20%283%29.jpeg', 1),
(596, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.04%20AM.jpeg', 1),
(597, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.05%20AM%20%281%29.jpeg', 1),
(598, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.05%20AM%20%283%29.jpeg', 1),
(599, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.05%20AM.jpeg', 1),
(600, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.06%20AM%20%284%29.jpeg', 1),
(601, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.06%20AM.jpeg', 1),
(602, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.07%20AM%20%282%29.jpeg', 1),
(603, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.07%20AM%20%283%29.jpeg', 1),
(604, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.07%20AM.jpeg', 1),
(605, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.08%20AM%20%281%29.jpeg', 1),
(606, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.08%20AM%20%282%29.jpeg', 1),
(607, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.08%20AM%20%283%29.jpeg', 1),
(608, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.08%20AM.jpeg', 1),
(609, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.09%20AM%20%281%29.jpeg', 1),
(610, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.09%20AM%20%282%29.jpeg', 1),
(611, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.09%20AM%20%283%29.jpeg', 1),
(612, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.09%20AM.jpeg', 1),
(613, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.10%20AM%20%281%29.jpeg', 1),
(614, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.10%20AM%20%283%29.jpeg', 1),
(615, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.10%20AM%20%284%29.jpeg', 1),
(616, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.10%20AM.jpeg', 1),
(617, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.11%20AM%20%281%29.jpeg', 1),
(618, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.11%20AM%20%283%29.jpeg', 1),
(619, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.12%20AM%20%281%29.jpeg', 1),
(620, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.12%20AM%20%282%29.jpeg', 1),
(621, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.12%20AM.jpeg', 1),
(622, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.13%20AM%20%281%29.jpeg', 1),
(623, 'sup/WhatsApp%20Image%202026-09-07%20at%2012.35.13%20AM%20%282%29.jpeg', 1);

-- Compatible color/size/variant data from the source
INSERT INTO ProductColors (ProductID, ColorName, ColorCode) VALUES
(2, 'Pink', '#F4A6B8'),
(2, 'White', '#FFFFFF'),
(3, 'Blue', '#2F5D8C'),
(3, 'Black', '#000000'),
(4, 'Black', '#000000'),
(4, 'White', '#FFFFFF');

INSERT INTO ProductSizes (ProductID, SizeName) VALUES
(2, 'S'),
(2, 'M'),
(2, 'L'),
(3, 'S'),
(3, 'M'),
(3, 'L'),
(4, 'S'),
(4, 'M'),
(4, 'L');

INSERT INTO ProductVariants (ProductID, ColorID, SizeID, Stock) VALUES
(2, 1, 1, 10),
(2, 1, 2, 15),
(2, 1, 3, 10),
(2, 2, 1, 5),
(2, 2, 2, 10),
(2, 2, 3, 8),
(3, 3, 4, 8),
(3, 3, 5, 12),
(3, 3, 6, 10),
(3, 4, 4, 6),
(3, 4, 5, 10),
(3, 4, 6, 8),
(4, 5, 7, 15),
(4, 5, 8, 20),
(4, 5, 9, 15),
(4, 6, 7, 10),
(4, 6, 8, 15),
(4, 6, 9, 10);

-- users
INSERT INTO Users
(
    FullName,
    Email,
    PasswordHash,
    Phone,
    Role
)
VALUES
(
    'Samar Tarek',
    'samar@example.com',
    'TEMP_HASH_123',
    '01000000000',
    'User'
),
(
    'Admin User',
    'admin@shestyle.com',
    'TEMP_HASH_ADMIN_123',
    '01111111111',
    'Admin'
);

-- cart
INSERT INTO Cart (UserID)
VALUES (1);

-- cartitems
INSERT INTO CartItems
(
    CartID,
    ProductID,
    Quantity
)
SELECT
    1,
    ProductID,
    2
FROM Products
WHERE ProductName = 'Floral Print Top';

-- wishlist
INSERT INTO Wishlist
(
    UserID,
    ProductID
)
SELECT
    1,
    ProductID
FROM Products
WHERE ProductName = 'Floral Print Top';

-- orders
INSERT INTO Orders
(
    OrderNumber,
    UserID,
    FullName,
    Email,
    Phone,
    Address,
    City,
    PostalCode,
    Subtotal,
    ShippingCost,
    TotalAmount,
    PaymentMethod,
    PaymentStatus
)
VALUES
(
    'SHS-100001',
    1,
    'Samar Tarek',
    'samar@example.com',
    '01000000000',
    '123 Main Street',
    'Cairo',
    '11511',
    37.98,
    5.99,
    43.97,
    'Cash on Delivery',
    'Pending'
);

-- orderitems
INSERT INTO OrderItems
(
    OrderID,
    ProductID,
    ProductName,
    UnitPrice,
    Quantity,
    LineTotal,
    ColorName,
    SizeName
)
SELECT
    o.OrderID,
    p.ProductID,
    p.ProductName,
    p.Price,
    ci.Quantity,
    p.Price * ci.Quantity,
    'Pink',
    'M'
FROM Orders o
JOIN Cart c
    ON c.UserID = o.UserID
JOIN CartItems ci
    ON ci.CartID = c.CartID
JOIN Products p
    ON p.ProductID = ci.ProductID
WHERE o.OrderNumber = 'SHS-100001';

-- payments
INSERT INTO Payments
(
    OrderID,
    PaymentMethod,
    PaymentStatus,
    TransactionID,
    PaymentDate,
    Amount
)
SELECT
    OrderID,
    PaymentMethod,
    PaymentStatus,
    NULL,
    NULL,
    TotalAmount
FROM Orders
WHERE OrderNumber = 'SHS-100001';

-- addresses
INSERT INTO Addresses
(
    UserID,
    FullName,
    Phone,
    AddressLine,
    City,
    PostalCode,
    IsDefault
)
VALUES
(
    1,
    'Samar Tarek',
    '01000000000',
    '123 Main Street',
    'Cairo',
    '11511',
    1
);

-- reviews
INSERT INTO Reviews
(
    UserID,
    ProductID,
    Rating,
    Comment,
    IsApproved
)
VALUES
(
    1,
    1,
    5,
    'Very nice product and good quality.',
    1
);

-- coupons
INSERT INTO Coupons
(
    CouponCode,
    DiscountType,
    DiscountValue,
    StartDate,
    EndDate,
    MinimumAmount,
    UsageLimit,
    UsedCount,
    IsActive
)
VALUES
(
    'WELCOME10',
    'Percentage',
    10.00,
    CURRENT_TIMESTAMP,
    DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 MONTH),
    0,
    100,
    0,
    1
);

-- productsections
INSERT INTO ProductSections
(
    ProductID,
    SectionName
)
VALUES
(1, 'New'),
(1, 'Trending'),

(2, 'Sale'),
(2, 'Trending'),

(3, 'New'),

(4, 'New'),

(5, 'Trending'),

(6, 'New'),
(6, 'Sale');

SET FOREIGN_KEY_CHECKS = 1;

-- ================= Verification =================
SELECT COUNT(*) AS ProductCount FROM Products;
SELECT COUNT(*) AS ProductImageCount FROM ProductImages;
SELECT COUNT(*) AS CategoryCount FROM Categories;
SELECT COUNT(*) AS SubcategoryCount FROM Subcategories;
