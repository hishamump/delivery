CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

CREATE TABLE "Users" (
    "Id" uuid NOT NULL,
    "SupplierId" uuid NOT NULL,
    "FirstName" character varying(200) NOT NULL,
    "LastName" character varying(200) NOT NULL,
    "Email" character varying(255) NOT NULL,
    "PasswordHash" character varying(500) NOT NULL,
    "PhoneNumber" character varying(20),
    "Role" text NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "LastLoginAt" timestamp with time zone,
    CONSTRAINT "PK_Users" PRIMARY KEY ("Id")
);

CREATE TABLE "Suppliers" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "BusinessName" character varying(300) NOT NULL,
    "ContactEmail" character varying(255) NOT NULL,
    "ContactPhone" character varying(20) NOT NULL,
    "BusinessDescription" text,
    "BusinessLicense" character varying(100),
    "TaxNumber" text,
    "IsVerified" boolean NOT NULL DEFAULT FALSE,
    "Rating" numeric NOT NULL,
    "TotalRatings" integer NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Suppliers" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Suppliers_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Addresses" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "SupplierId" uuid,
    "Label" character varying(100) NOT NULL,
    "FullAddress" character varying(500) NOT NULL,
    "City" character varying(100) NOT NULL,
    "State" character varying(100) NOT NULL,
    "PostalCode" character varying(20) NOT NULL,
    "Country" character varying(100) NOT NULL,
    "Latitude" numeric(10,8),
    "Longitude" numeric(11,8),
    "IsDefault" boolean NOT NULL DEFAULT FALSE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Addresses" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Addresses_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Addresses_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Items" (
    "Id" uuid NOT NULL,
    "SupplierId" uuid NOT NULL,
    "Name" character varying(200) NOT NULL,
    "Description" character varying(1000),
    "Price" numeric(10,2) NOT NULL,
    "Currency" character varying(3) NOT NULL DEFAULT 'USD',
    "ImageUrl" character varying(500),
    "Category" character varying(100) NOT NULL,
    "Unit" character varying(50) NOT NULL,
    "StockQuantity" integer NOT NULL DEFAULT 0,
    "MinOrderQuantity" integer NOT NULL DEFAULT 1,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Items" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Items_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Orders" (
    "Id" uuid NOT NULL,
    "OrderNumber" character varying(50) NOT NULL,
    "UserId" uuid NOT NULL,
    "DeliveryScheduleId" uuid NOT NULL,
    "SupplierId" uuid NOT NULL,
    "DeliveryAddressId" uuid NOT NULL,
    "Status" text NOT NULL,
    "DeliveryType" text NOT NULL,
    "SubTotal" numeric(10,2) NOT NULL,
    "DeliveryFee" numeric(8,2) NOT NULL DEFAULT 0.0,
    "TotalAmount" numeric(10,2) NOT NULL,
    "Notes" character varying(1000),
    "OrderDate" timestamp with time zone NOT NULL,
    "RequestedDeliveryDate" timestamp with time zone,
    "ActualDeliveryDate" timestamp with time zone,
    "Currency" character varying(3) NOT NULL DEFAULT 'USD',
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "AddressId" uuid,
    CONSTRAINT "PK_Orders" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Orders_Addresses_AddressId" FOREIGN KEY ("AddressId") REFERENCES "Addresses" ("Id"),
    CONSTRAINT "FK_Orders_Addresses_DeliveryAddressId" FOREIGN KEY ("DeliveryAddressId") REFERENCES "Addresses" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Orders_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_Orders_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE RESTRICT
);

CREATE TABLE "DeliverySchedules" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "ScheduledDate" timestamp with time zone NOT NULL,
    "StartDate" timestamp with time zone NOT NULL,
    "EndDate" timestamp with time zone NOT NULL,
    "DeliveryType" integer NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    "SupplierId" uuid,
    CONSTRAINT "PK_DeliverySchedules" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_DeliverySchedules_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES "Orders" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_DeliverySchedules_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id")
);

CREATE TABLE "OrderItems" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "ItemId" uuid NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(10,2) NOT NULL,
    "TotalPrice" numeric(10,2) NOT NULL,
    "Notes" character varying(500),
    CONSTRAINT "PK_OrderItems" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_OrderItems_Items_ItemId" FOREIGN KEY ("ItemId") REFERENCES "Items" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_OrderItems_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES "Orders" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_Addresses_SupplierId" ON "Addresses" ("SupplierId");

CREATE INDEX "IX_Addresses_UserId_IsDefault" ON "Addresses" ("UserId", "IsDefault");

CREATE UNIQUE INDEX "IX_DeliverySchedules_OrderId" ON "DeliverySchedules" ("OrderId");

CREATE INDEX "IX_DeliverySchedules_ScheduledDate" ON "DeliverySchedules" ("ScheduledDate");

CREATE INDEX "IX_DeliverySchedules_SupplierId" ON "DeliverySchedules" ("SupplierId");

CREATE INDEX "IX_Items_Category" ON "Items" ("Category");

CREATE INDEX "IX_Items_Name" ON "Items" ("Name");

CREATE INDEX "IX_Items_SupplierId_IsActive" ON "Items" ("SupplierId", "IsActive");

CREATE INDEX "IX_OrderItems_ItemId" ON "OrderItems" ("ItemId");

CREATE INDEX "IX_OrderItems_OrderId_ItemId" ON "OrderItems" ("OrderId", "ItemId");

CREATE INDEX "IX_Orders_AddressId" ON "Orders" ("AddressId");

CREATE INDEX "IX_Orders_CreatedAt" ON "Orders" ("CreatedAt");

CREATE INDEX "IX_Orders_DeliveryAddressId" ON "Orders" ("DeliveryAddressId");

CREATE UNIQUE INDEX "IX_Orders_OrderNumber" ON "Orders" ("OrderNumber");

CREATE INDEX "IX_Orders_SupplierId" ON "Orders" ("SupplierId");

CREATE INDEX "IX_Orders_UserId_Status" ON "Orders" ("UserId", "Status");

CREATE UNIQUE INDEX "IX_Suppliers_ContactEmail" ON "Suppliers" ("ContactEmail");

CREATE UNIQUE INDEX "IX_Suppliers_UserId" ON "Suppliers" ("UserId");

CREATE UNIQUE INDEX "IX_Users_Email" ON "Users" ("Email");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250731160234_InitialCreate', '8.0.0');

COMMIT;

START TRANSACTION;

ALTER TABLE "Addresses" DROP CONSTRAINT "FK_Addresses_Suppliers_SupplierId";

ALTER TABLE "DeliverySchedules" DROP CONSTRAINT "FK_DeliverySchedules_Suppliers_SupplierId";

ALTER TABLE "Items" DROP CONSTRAINT "FK_Items_Suppliers_SupplierId";

DROP INDEX "IX_DeliverySchedules_SupplierId";

ALTER TABLE "Users" DROP COLUMN "FirstName";

ALTER TABLE "Users" DROP COLUMN "SupplierId";

ALTER TABLE "Suppliers" DROP COLUMN "IsActive";

ALTER TABLE "DeliverySchedules" DROP COLUMN "SupplierId";

ALTER TABLE "Users" RENAME COLUMN "LastName" TO "FullName";

ALTER INDEX "IX_Users_Email" RENAME TO "IX_User_Email";

ALTER TABLE "Suppliers" RENAME COLUMN "TaxNumber" TO "Logo";

ALTER INDEX "IX_Suppliers_UserId" RENAME TO "IX_Supplier_UserId";

ALTER TABLE "Users" ADD "BirthDate" date;

ALTER TABLE "Users" ADD "EmailNotifications" boolean NOT NULL DEFAULT FALSE;

ALTER TABLE "Users" ADD "Photo" character varying(500);

ALTER TABLE "Users" ADD "PreferredLanguage" character varying(5) DEFAULT 'en';

ALTER TABLE "Users" ADD "SmsNotifications" boolean NOT NULL DEFAULT FALSE;

ALTER TABLE "Suppliers" ADD CONSTRAINT "AK_Suppliers_UserId" UNIQUE ("UserId");

CREATE TABLE "Drivers" (
    "Id" uuid NOT NULL,
    "UserId" uuid NOT NULL,
    "LicenseNumber" character varying(50) NOT NULL,
    "VehicleType" character varying(50) NOT NULL,
    "VehiclePlateNumber" character varying(20) NOT NULL,
    "VehicleModel" character varying(100),
    "VehicleColor" character varying(50),
    "IsAvailable" boolean NOT NULL,
    "IsVerified" boolean NOT NULL,
    "Rating" numeric(3,2) NOT NULL,
    "TotalRatings" integer NOT NULL,
    "LastLocationUpdate" timestamp with time zone,
    "CurrentLatitude" numeric(10,7),
    "CurrentLongitude" numeric(10,7),
    "CreatedAt" timestamp with time zone NOT NULL DEFAULT (NOW()),
    "UpdatedAt" timestamp with time zone NOT NULL DEFAULT (NOW()),
    CONSTRAINT "PK_Drivers" PRIMARY KEY ("Id"),
    CONSTRAINT "AK_Drivers_UserId" UNIQUE ("UserId"),
    CONSTRAINT "FK_Drivers_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Deliveries" (
    "Id" uuid NOT NULL,
    "OrderId" uuid NOT NULL,
    "DriverId" uuid NOT NULL,
    "AssignedAt" timestamp with time zone NOT NULL,
    "PickedUpAt" timestamp with time zone,
    "DeliveredAt" timestamp with time zone,
    "Status" integer NOT NULL,
    "DriverLatitude" numeric,
    "DriverLongitude" numeric,
    "LocationUpdatedAt" timestamp with time zone,
    "DeliveryNotes" text,
    "DeliveryFee" numeric NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_Deliveries" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Deliveries_Drivers_DriverId" FOREIGN KEY ("DriverId") REFERENCES "Drivers" ("UserId") ON DELETE RESTRICT,
    CONSTRAINT "FK_Deliveries_Orders_OrderId" FOREIGN KEY ("OrderId") REFERENCES "Orders" ("Id") ON DELETE CASCADE
);

CREATE INDEX "IX_Deliveries_DriverId" ON "Deliveries" ("DriverId");

CREATE INDEX "IX_Deliveries_OrderId" ON "Deliveries" ("OrderId");

CREATE UNIQUE INDEX "IX_Driver_LicenseNumber" ON "Drivers" ("LicenseNumber");

CREATE UNIQUE INDEX "IX_Driver_UserId" ON "Drivers" ("UserId");

ALTER TABLE "Addresses" ADD CONSTRAINT "FK_Addresses_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id");

ALTER TABLE "Items" ADD CONSTRAINT "FK_Items_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("UserId") ON DELETE CASCADE;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250825165558_CreateUserProfilesSystem', '8.0.0');

COMMIT;

START TRANSACTION;

ALTER TABLE "Items" DROP CONSTRAINT "FK_Items_Suppliers_SupplierId";

ALTER TABLE "Suppliers" DROP CONSTRAINT "AK_Suppliers_UserId";

ALTER TABLE "Items" ADD CONSTRAINT "FK_Items_Suppliers_SupplierId" FOREIGN KEY ("SupplierId") REFERENCES "Suppliers" ("Id") ON DELETE CASCADE;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250912194959_FixItemsSupplier', '8.0.0');

COMMIT;

