CREATE DATABASE IF NOT EXISTS luxury_housing_database;
USE luxury_housing_database;

DROP TABLE IF EXISTS data_table;
CREATE TABLE data_table (
    Property_ID VARCHAR(50) PRIMARY KEY,
    Micro_Market VARCHAR(150) NOT NULL,
    Project_Name VARCHAR(150) NOT NULL,
    Developer_Name VARCHAR(150) NOT NULL,
    Unit_Size_Sqft DECIMAL(10,2),
    Configuration VARCHAR(50) NOT NULL,
    Ticket_Price_Cr DECIMAL(12,6),
    Price_per_Sqft DECIMAL(12,2),
    Transaction_Type VARCHAR(50),
    Buyer_Type VARCHAR(100),
    Purchase_Quarter DATE,
    Quarter_Number INT,
    Connectivity_Score DECIMAL(5,2),
    Amenity_Score DECIMAL(5,2),
    Locality_Infra_Score DECIMAL(5,2),
    Overall_Property_Score DECIMAL(5,2),
    Possession_Status VARCHAR(100),
    Sales_Channel VARCHAR(100),
    NRI_Buyer VARCHAR(10),
    Avg_Traffic_Time_Min INT,
    Booking_Flag TINYINT,
    Buyer_Comments TEXT
);

-- ============= CREATE INDEXES FOR PERFORMANCE =============
CREATE INDEX idx_micro_market ON data_table(Micro_Market);
CREATE INDEX idx_developer ON data_table(Developer_Name);
CREATE INDEX idx_project ON data_table(Project_Name);
CREATE INDEX idx_configuration ON data_table(Configuration);
CREATE INDEX idx_unit_size ON data_table(Unit_Size_Sqft);
CREATE INDEX idx_ticket_price ON data_table(Ticket_Price_Cr);
CREATE INDEX idx_price_per_sqft ON data_table(Price_per_Sqft);
CREATE INDEX idx_buyer_type ON data_table(Buyer_Type);
CREATE INDEX idx_possession_status ON data_table(Possession_Status);
CREATE INDEX idx_sales_channel ON data_table(Sales_Channel);
CREATE INDEX idx_purchase_quarter ON data_table(Purchase_Quarter);
CREATE INDEX idx_quarter_number ON data_table(Quarter_Number);
CREATE INDEX idx_booking_flag ON data_table(Booking_Flag);
CREATE INDEX idx_nri_buyer ON data_table(NRI_Buyer);
CREATE INDEX idx_market_config ON data_table(Micro_Market, Configuration);
CREATE INDEX idx_developer_config ON data_table(Developer_Name, Configuration);
CREATE INDEX idx_market_price ON data_table(Micro_Market, Ticket_Price_Cr);
CREATE INDEX idx_quarter_booking ON data_table(Quarter_Number, Booking_Flag);
CREATE INDEX idx_developer_quarter ON data_table(Developer_Name, Purchase_Quarter);
CREATE INDEX idx_market_developer ON data_table(Micro_Market, Developer_Name);
