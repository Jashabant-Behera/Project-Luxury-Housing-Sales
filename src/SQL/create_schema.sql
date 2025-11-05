
-- ============= CREATE DATABASE =============
CREATE DATABASE luxury_housing_database;
USE luxury_housing_database;

-- ============= CREATE SCHEMA =============
CREATE TABLE data_table (
    property_ID VARCHAR(50) PRIMARY KEY,
    Micro_Market VARCHAR(150) NOT NULL,
    Project_Name VARCHAR(150) NOT NULL,
    Developer_Name VARCHAR(150) NOT NULL,
    Unit_Size_Sqft DECIMAL(10,2),
    Configuration VARCHAR(50) NOT NULL,
    Ticket_Price_Cr DECIMAL(12,6),
    Transaction_Type VARCHAR(50),
    Buyer_Type VARCHAR(100),
    Purchase_Quarter DATE,
    Connectivity_Score DECIMAL(5,2),
    Amenity_Score DECIMAL(5,2),
    Locality_Infra_Score DECIMAL(5,2),
    Possession_Status VARCHAR(100),
    Sales_Channel VARCHAR(100),
    NRI_Buyer VARCHAR(10),
    Avg_Traffic_Time_Min INT,
    Buyer_Comments TEXT
);

-- ============= CREATE DATABASE =============
CREATE INDEX idx_micro_market ON data_table(Micro_Market);
CREATE INDEX idx_developer ON data_table(Developer_Name);
CREATE INDEX idx_configuration ON data_table(Configuration);
CREATE INDEX idx_buyer_type ON data_table(Buyer_Type);
CREATE INDEX idx_possession_status ON data_table(Possession_Status);
CREATE INDEX idx_sales_channel ON data_table(Sales_Channel);
CREATE INDEX idx_purchase_quarter ON data_table(Purchase_Quarter);
CREATE INDEX idx_ticket_price ON data_table(Ticket_Price_Cr);
CREATE INDEX idx_market_config ON data_table(Micro_Market, Configuration);
CREATE INDEX idx_developer_config ON data_table(Developer_Name, Configuration);
CREATE INDEX idx_market_price ON data_table(Micro_Market, Ticket_Price_Cr);