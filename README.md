# Luxury Housing Sales Analysis - Bengaluru

## Project Overview

A comprehensive real estate analytics solution for luxury housing market in Bengaluru, India. This project demonstrates end-to-end data analytics workflow including data cleaning with Python, database management with MySQL, and interactive dashboard creation using Power BI.

**Dataset Size:** 100,000+ property transactions  
**Time Period:** 2023-2025  
**Location:** Bengaluru, India (16 Micro Markets)

---

## Table of Contents

- [Project Architecture](#project-architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Data Pipeline](#data-pipeline)
- [Dashboard Features](#dashboard-features)
- [Key Insights](#key-insights)
- [Usage Guide](#usage-guide)
- [Business Metrics](#business-metrics)
- [Contributing](#contributing)
- [License](#license)

---

## Project Architecture

```
Raw Data (CSV) 
    → Python Data Cleaning (Pandas, NumPy) 
    → MySQL Database 
    → Power BI Dashboard 
    → Business Insights
```

### Workflow Summary:

1. **Extract:** Load raw CSV data (101,000 rows)
2. **Transform:** Clean and engineer features using Python
3. **Load:** Insert processed data into MySQL database
4. **Visualize:** Create interactive Power BI dashboard
5. **Analyze:** Generate business insights and KPIs

---

## Technologies Used

### Data Processing:
- **Python 3.13**
  - pandas 2.0+
  - numpy 1.24+
  - geopy 2.4+ (for geocoding)
  
### Database:
- **MySQL 8.0+**
- **SQLAlchemy** (Python-MySQL connector)

### Visualization:
- **Power BI Desktop**
- DAX (Data Analysis Expressions)

### Environment Management:
- python-dotenv
- Jupyter Notebook

---

## Project Structure

```
PROJRCT-LUXURY-HOUSING/
│
├── src/
│   ├── Data/
│   │   ├── raw/
│   │   │   └── Luxury_Housing_Bangalore.csv
│   │   └── cleaned/
│   │       └── luxury_housing_cleaned.csv
│   │
│   ├── Notebook/
│   │   ├── data_cleaning.ipynb
│   │   └── load_to_mysql.ipynb
│   │
│   ├── PowerBI/
│   │   └── luxury_housing_dashboard.pbix
│   │
│   └── SQL/
│       └── create_schema.sql
│
├── .env
├── .gitignore
├── README.md
└── requirements.txt
```

---

## Installation & Setup

### Prerequisites:

- Python 3.13 or higher
- MySQL 8.0 or higher
- Power BI Desktop
- Git (optional)

### Step 1: Clone Repository

```bash
git clone https://github.com/Jashabant-Behera/Project-Luxury-Housing-Sales.git
cd PROJRCT-LUXURY-HOUSING
```

### Step 2: Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Configure Database

Create a `.env` file in the root directory:

```env
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_HOST=localhost
DB_NAME=luxury_housing_database
```

### Step 4: Create Database Schema

```bash
mysql -u your_username -p < src/SQL/create_schema.sql
```

### Step 5: Run Data Pipeline

```bash
# Open and run notebooks in order:
jupyter notebook src/Notebook/data_cleaning.ipynb
jupyter notebook src/Notebook/load_to_mysql.ipynb
```

### Step 6: Open Power BI Dashboard

```
Open: src/PowerBI/luxury_housing_dashboard.pbix
Configure: Data source connection to your MySQL database
```

---

## Data Pipeline

### Phase 1: Data Cleaning (Python)

**Notebook:** `data_cleaning.ipynb`

#### Data Quality Issues Handled:

1. **Duplicates:** Removed 1,000 duplicate rows
2. **Missing Values:**
   - Amenity_Score: Filled with median (10,000 nulls)
   - Unit_Size_Sqft: Filled by Configuration group (9,957 nulls)
   - Ticket_Price_Cr: Filled by Market + Configuration (9,913 nulls)
   - Buyer_Comments: Replaced nulls with "No Comments from Buyer"

3. **Data Type Issues:**
   - Converted Ticket_Price_Cr from object to numeric
   - Removed currency symbols and special characters
   - Converted Purchase_Quarter to datetime

4. **Negative Values:**
   - Unit_Size_Sqft: Replaced 1 negative value
   - Ticket_Price_Cr: Replaced 5 negative values

5. **Text Standardization:**
   - Micro_Market: Uppercase, stripped whitespace
   - Developer_Name: Uppercase, stripped whitespace
   - Configuration: Uppercase (3BHK, 4BHK, 5BHK+)
   - All categorical fields: Title case

#### Feature Engineering:

**New Columns Created:**

1. **Price_per_Sqft**
   ```python
   (Ticket_Price_Cr × 10,000,000) / Unit_Size_Sqft
   ```

2. **Quarter_Number**
   ```python
   Extracted from Purchase_Quarter (1-4)
   ```

3. **Booking_Flag** (Business Rule-Based)
   ```python
   Rules:
   - Positive sentiment in comments → 1 (Booked)
   - Primary transaction + No negative sentiment → 1
   - High property score (>8) + Ready to move → 1
   - Otherwise → 0 (Inquiry)
   ```

4. **Overall_Property_Score**
   ```python
   Connectivity_Score × 0.3 +
   Amenity_Score × 0.3 +
   Locality_Infra_Score × 0.4
   ```

5. **Geocoding (Latitude/Longitude)**
   ```python
   Used geopy to get coordinates for 16 micro-markets
   For map visualizations in Power BI
   ```

**Final Dataset:** 100,000 rows × 24 columns

---

### Phase 2: Database Loading (MySQL)

**Notebook:** `load_to_mysql.ipynb`

#### Database Schema:

```sql
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
```

#### Indexes Created (20):

- Single column indexes on key fields (Market, Developer, Configuration, etc.)
- Composite indexes for common queries (Market+Config, Developer+Quarter, etc.)
- Optimizes query performance for dashboard

**Load Method:** SQLAlchemy with chunked insertion

---

### Phase 3: Dashboard Creation (Power BI)

**File:** `luxury_housing_dashboard.pbix`

#### Connection Setup:

```
Data Source: MySQL Database
Connection Type: DirectQuery / Import
Server: localhost
Database: luxury_housing_database
Table: data_table
```

#### DAX Measures Created:

```dax
Total Properties = COUNTROWS(data_table)

Total Revenue (Cr) = SUM(data_table[Ticket_Price_Cr])

Avg Ticket Price (Cr) = AVERAGE(data_table[Ticket_Price_Cr])

Total Bookings = 
CALCULATE(
    COUNTROWS(data_table),
    data_table[Booking_Flag] = 1
)

Total Inquiries = 
CALCULATE(
    COUNTROWS(data_table),
    data_table[Booking_Flag] = 0
)

Booking Rate % = 
DIVIDE(
    [Total Bookings],
    [Total Properties],
    0
) * 100

Avg Property Score = AVERAGE(data_table[Overall_Property_Score])

Avg Price per Sqft = AVERAGE(data_table[Price_per_Sqft])
```

---

## Dashboard Features

### Page 1: Executive Overview

**Global Filters:**
- Quarter Number
- Micro Market
- Developer Name
- Configuration
- Buyer Type
- Possession Status

**KPI Cards (6):**
- Total Properties: 9K
- Total Revenue: 116.76K Cr
- Avg Ticket Price: 12.66 Cr
- Booked Properties: 6K
- Booking Rate: 70.11%
- Avg Property Score: 7.34/10

**Visualizations (10):**

1. **Market Trends (Line Chart)**
   - X-axis: Quarter
   - Y-axis: Total Properties
   - Legend: Micro Market
   - Shows quarterly booking trends across markets

2. **Builder Performance (Bar Chart)**
   - Y-axis: Developer Name (Top 10)
   - X-axis: Total Revenue
   - Sorted by revenue descending

3. **Amenity Impact (Scatter Plot)**
   - X-axis: Amenity Score
   - Y-axis: Booking Rate %
   - Bubble Size: Total Properties
   - Shows correlation between amenity and success

4. **Booking Conversion (Stacked Column)**
   - X-axis: Micro Market
   - Y-axis: Total Properties
   - Legend: Booking Status (Booked/Inquiry)
   - Color: Green (Booked), Orange (Inquiry)

5. **Configuration Demand (Donut Chart)**
   - Shows distribution of 3BHK, 4BHK, 5BHK+
   - 4BHK: 33.09%
   - 5BHK+: 33.54%
   - 3BHK: 33.38%

6. **Sales Channel Effectiveness (100% Stacked Bar)**
   - Y-axis: Sales Channel
   - Shows booking conversion by channel
   - All channels: ~70% booking rate

7. **Quarterly Builder Contribution (Matrix)**
   - Rows: Top builders
   - Columns: Quarters (Q1-Q4)
   - Values: Revenue per quarter
   - Conditional formatting by amount

8. **Possession Status Analysis (Clustered Column with Small Multiples)**
   - Located on Page 2: Market Intelligence
   - Grid: 2 rows × 3 columns by Buyer Type
   - Shows booking patterns by possession status

9. **Geographic Insights (Map)**
   - Bubble map of Bengaluru
   - Size: Total Properties per market
   - Uses Latitude/Longitude data
   - 16 micro-markets visualized

10. **Top Performers (Cards + Table)**
    - Top Builder: PRESTIGE
    - Revenue: 116.76K Cr
    - Booking Rate: 70.11%
    - Top 5 Table with drill-through capability

---

### Page 2: Market Intelligence

**Purpose:** Market-level deep dive analysis

**Features:**
- Market-focused filters (5)
- Market KPI cards (4)
- VIZ 8: Possession Status Analysis (main feature)
- Market ranking table
- Market performance trend line

---

### Page 3: Builder Performance

**Purpose:** Individual builder analysis and drill-through destination

**Features:**
- Builder selector (large dropdown)
- Builder profile cards (5 KPIs)
- Detailed projects table
- Configuration mix pie chart
- Quarterly performance line
- Buyer type distribution
- Builder vs industry comparison

**Drill-Through:** Right-click any builder in Top 5 table → Navigate to this page

---

## Key Insights

### Market Intelligence:

1. **Top Performing Markets:**
   - Based on property concentration and revenue
   - Whitefield, Sarjapur Road lead in volume
   - Indiranagar commands premium pricing

2. **Booking Conversion Rate:** 70.11% overall
   - Industry benchmark: 50-60%
   - Indicates strong market performance

3. **Configuration Demand:** Nearly equal split
   - 4BHK: 33.09%
   - 5BHK+: 33.54%
   - 3BHK: 33.38%
   - Balanced portfolio strategy needed

4. **Amenity Impact:** Moderate positive correlation
   - Properties with score >8: 71.5% booking rate
   - Properties with score <7: 69.5% booking rate
   - ~2% difference suggests amenities help but aren't decisive

### Builder Performance:

1. **Top 5 Builders** control ~50% market share:
   - PRESTIGE: 116.76K Cr
   - TOTAL ENVIRONMENT: 116.22K Cr
   - L&T REALTY: 116.06K Cr
   - SNN RAJ: 115.81K Cr
   - GODREJ: 115.79K Cr

2. **Average Ticket Price:** 12.66 Cr
   - Range: 9.4 Cr to 16.3 Cr
   - Premium segment dominance

3. **Quarterly Stability:**
   - Consistent revenue across quarters
   - Q1-Q4 revenue: ~315K Cr each
   - Low seasonality in luxury segment

### Sales Channel Analysis:

4. **All Channels Perform Similarly:** ~70% conversion
   - Online: 70.63%
   - Broker: 70.24%
   - NRI Desk: 70.71%
   - Direct: 70.64%
   - Suggests strong market fundamentals

### Buyer Behavior:

5. **Buyer Type Distribution:**
   - HNI and CXO dominant segments
   - NRI buyers concentrated in specific markets
   - Startup Founders emerging segment

6. **Possession Status Impact:**
   - Ready to Move: Highest demand
   - Under Construction: Requires incentives
   - Launch: Price-sensitive buyers

---

## Usage Guide

### For Data Analysts:

1. **Modify Data Pipeline:**
   ```bash
   # Edit cleaning logic
   vim src/Notebook/data_cleaning.ipynb
   
   # Re-run pipeline
   jupyter notebook src/Notebook/data_cleaning.ipynb
   jupyter notebook src/Notebook/load_to_mysql.ipynb
   ```

2. **Query Database:**
   ```sql
   -- Top markets by revenue
   SELECT 
       Micro_Market,
       SUM(Ticket_Price_Cr) as Revenue,
       COUNT(*) as Properties
   FROM data_table
   GROUP BY Micro_Market
   ORDER BY Revenue DESC
   LIMIT 10;
   ```

3. **Validate Data:**
   ```python
   # In Python
   import pandas as pd
   from sqlalchemy import create_engine
   
   engine = create_engine('mysql+mysqlconnector://user:pass@localhost/luxury_housing_database')
   df = pd.read_sql('SELECT * FROM data_table LIMIT 1000', engine)
   print(df.describe())
   ```

### For Business Users:

1. **Open Dashboard:**
   - Launch Power BI Desktop
   - Open `luxury_housing_dashboard.pbix`
   - Wait for data refresh

2. **Use Filters:**
   - Select Quarter, Market, Configuration
   - All visuals update automatically
   - Clear filters to reset

3. **Drill-Through:**
   - Right-click any builder in Top 5 table
   - Select "Drill through" → "Builder Performance"
   - View detailed builder analytics

4. **Export Data:**
   - Click "..." on any visual
   - Select "Export data"
   - Choose CSV or Excel format

### For Developers:

1. **Add New Visualization:**
   ```
   - Open Power BI file
   - Add new page or modify existing
   - Create visual from Fields pane
   - Apply glass morphism theme
   - Save and test
   ```

2. **Add New DAX Measure:**
   ```dax
   New Measure = 
   CALCULATE(
       SUM(data_table[Ticket_Price_Cr]),
       FILTER(data_table, condition)
   )
   ```

3. **Modify Database Schema:**
   ```sql
   -- Add new column
   ALTER TABLE data_table 
   ADD COLUMN New_Column VARCHAR(100);
   
   -- Update existing data
   UPDATE data_table 
   SET New_Column = 'value' 
   WHERE condition;
   ```

---

## Business Metrics

### Key Performance Indicators (KPIs):

| Metric | Value | Industry Benchmark | Status |
|--------|-------|-------------------|--------|
| Booking Rate | 70.11% | 50-60% | Above Average |
| Avg Ticket Price | 12.66 Cr | 10-15 Cr | On Target |
| Properties Listed | 100,000 | - | Large Dataset |
| Markets Covered | 16 | - | Comprehensive |
| Developers Tracked | 50+ | - | Diverse Portfolio |
| Avg Property Score | 7.34/10 | 7.0/10 | Good Quality |

### Revenue Metrics:

- **Total Market Size:** 1,265.21K Cr (1.26 Trillion INR)
- **Top 10 Builders:** ~1,150K Cr (91% of total)
- **Average Deal Size:** 12.66 Cr per property
- **Quarterly Revenue:** ~315K Cr per quarter (stable)

### Operational Metrics:

- **Data Freshness:** Real-time with DirectQuery
- **Dashboard Load Time:** <5 seconds
- **Query Performance:** <2 seconds with indexes
- **Data Quality Score:** 99.1% (after cleaning)

---

## Data Dictionary

### Core Fields:

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| Property_ID | VARCHAR(50) | Unique property identifier | PROP000001 |
| Micro_Market | VARCHAR(150) | Location within Bengaluru | SARJAPUR ROAD |
| Project_Name | VARCHAR(150) | Name of housing project | Project_0 |
| Developer_Name | VARCHAR(150) | Builder/developer name | PRESTIGE |
| Unit_Size_Sqft | DECIMAL(10,2) | Property size in sq ft | 4025.00 |
| Configuration | VARCHAR(50) | BHK type | 4BHK |
| Ticket_Price_Cr | DECIMAL(12,6) | Price in Crores | 12.750846 |
| Price_per_Sqft | DECIMAL(12,2) | Calculated price/sqft | 31679.12 |

### Transaction Fields:

| Column | Type | Description | Values |
|--------|------|-------------|--------|
| Transaction_Type | VARCHAR(50) | Sale type | Primary, Secondary |
| Buyer_Type | VARCHAR(100) | Customer segment | HNI, CXO, NRI, Startup Founder, Other |
| Purchase_Quarter | DATE | Transaction date | 2025-03-31 |
| Quarter_Number | INT | Quarter (1-4) | 1, 2, 3, 4 |
| Possession_Status | VARCHAR(100) | Construction status | Launch, Under Construction, Ready To Move |
| Sales_Channel | VARCHAR(100) | Sales medium | Direct, Broker, Online, NRI Desk |
| NRI_Buyer | VARCHAR(10) | Is NRI buyer? | Yes, No |

### Score Fields:

| Column | Type | Description | Range |
|--------|------|-------------|-------|
| Connectivity_Score | DECIMAL(5,2) | Transport connectivity | 4.0 - 10.0 |
| Amenity_Score | DECIMAL(5,2) | Facilities rating | 5.0 - 10.0 |
| Locality_Infra_Score | DECIMAL(5,2) | Neighborhood quality | 5.0 - 10.0 |
| Overall_Property_Score | DECIMAL(5,2) | Weighted composite score | 5.0 - 10.0 |
| Avg_Traffic_Time_Min | INT | Commute time | 15 - 119 minutes |

### Derived Fields:

| Column | Type | Description | Calculation |
|--------|------|-------------|-------------|
| Booking_Flag | TINYINT | Booking status | 0 (Inquiry), 1 (Booked) |
| Latitude | DECIMAL | Latitude coordinate | 12.8 - 13.1 |
| Longitude | DECIMAL | Longitude coordinate | 77.5 - 77.8 |
| Buyer_Comments | TEXT | Customer feedback | Free text |

---

## Maintenance & Updates

### Regular Tasks:

**Daily:**
- Database backup
- Dashboard refresh (if not using DirectQuery)

**Weekly:**
- Data quality checks
- Performance monitoring
- User access audit

**Monthly:**
- Full database optimization
- Index maintenance
- Archival of old data (if needed)

**Quarterly:**
- Review KPIs and benchmarks
- Update business logic if needed
- Stakeholder feedback incorporation

### Backup Strategy:

```bash
# Database backup
mysqldump -u user -p luxury_housing_database > backup_$(date +%Y%m%d).sql

# Data file backup
cp src/Data/cleaned/luxury_housing_cleaned.csv backups/

# Power BI file backup
cp src/PowerBI/luxury_housing_dashboard.pbix backups/
```

---

## Troubleshooting

### Common Issues:

**Issue 1: Database Connection Failed**
```
Error: Can't connect to MySQL server
Solution: 
1. Check MySQL service is running
2. Verify .env file credentials
3. Test connection: mysql -u user -p
4. Check firewall settings
```

**Issue 2: Power BI Slow Performance**
```
Error: Dashboard takes >10 seconds to load
Solution:
1. Switch to Import mode instead of DirectQuery
2. Optimize DAX measures (avoid iterators)
3. Create aggregated tables
4. Reduce data volume with filters
```

**Issue 3: Data Mismatch**
```
Error: Numbers don't match between SQL and Power BI
Solution:
1. Check filter contexts in Power BI
2. Verify DAX measure logic
3. Run validation SQL queries
4. Clear Power BI cache and refresh
```

**Issue 4: Python Notebook Errors**
```
Error: Module not found or import errors
Solution:
1. pip install -r requirements.txt
2. Check Python version (3.13+)
3. Verify virtual environment activated
4. Restart Jupyter kernel
```

---

## Future Enhancements

### Planned Features:

1. **Predictive Analytics:**
   - Price prediction model using scikit-learn
   - Demand forecasting by configuration
   - Churn prediction for inquiries

2. **Advanced Visualizations:**
   - Heat maps for price trends
   - 3D scatter plots for multi-factor analysis
   - Animated time-series visualizations

3. **NLP Integration:**
   - Sentiment analysis on Buyer_Comments
   - Topic modeling for feedback themes
   - Auto-categorization of complaints

4. **Real-Time Updates:**
   - Streaming data pipeline
   - Live dashboard refresh
   - Real-time alerts for anomalies

5. **Mobile App:**
   - React Native or Flutter app
   - Mobile-optimized dashboards
   - Push notifications for alerts

6. **API Development:**
   - REST API for data access
   - Authentication and rate limiting
   - Third-party integrations

---

## Contributing

We welcome contributions! Here's how:

### Development Workflow:

1. **Fork the repository**
2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes**
   - Follow PEP 8 for Python code
   - Comment complex logic
   - Update documentation

4. **Test changes**
   - Run data pipeline end-to-end
   - Verify dashboard functionality
   - Check for broken links in README

5. **Submit pull request**
   - Clear description of changes
   - Link related issues
   - Add screenshots if UI changes

### Code Standards:

- Python: PEP 8
- SQL: Uppercase keywords, lowercase identifiers
- DAX: Pascal case for measures
- Comments: Explain "why", not "what"

---

## Project Team

**Role Assignments:**

- Data Engineer: Data pipeline and ETL
- Database Administrator: MySQL setup and optimization
- BI Developer: Power BI dashboard creation
- Data Analyst: Business insights and KPIs
- Project Manager: Coordination and documentation

---

## Acknowledgments

- **Dataset Source:** Synthetic data for educational purposes
- **Technologies:** Python, MySQL, Power BI
- **Inspiration:** Real estate market analysis best practices
- **Community:** Stack Overflow, Power BI Community

---

## License

This project is for educational and portfolio purposes.

**Data:** Synthetic dataset (not real transactions)  
**Code:** MIT License (modify as needed)  
**Dashboard:** Free to use and modify

---

## Contact & Support

**Project Repository:** https://github.com/Jashabant-Behera/Project-Luxury-Housing-Sales.git 
**Documentation:** This README  
**Issues:** Use GitHub Issues tab  
**Discussions:** Use GitHub Discussions tab

---

## Version History

**v1.0.0** (Current)
- Initial release
- Complete data pipeline
- 3-page Power BI dashboard
- 100,000 records processed

---

## Quick Links

- [Installation Guide](#installation--setup)
- [Data Pipeline](#data-pipeline)
- [Dashboard Features](#dashboard-features)
- [Usage Guide](#usage-guide)
- [Troubleshooting](#troubleshooting)

---

**Last Updated:** November 2024  
**Status:** Production Ready  
**Maintenance:** Active

---

## Appendix

### A. SQL Validation Queries

```sql
-- Total records
SELECT COUNT(*) FROM data_table;

-- Revenue by market
SELECT 
    Micro_Market,
    SUM(Ticket_Price_Cr) as Total_Revenue,
    AVG(Ticket_Price_Cr) as Avg_Price,
    COUNT(*) as Properties
FROM data_table
GROUP BY Micro_Market
ORDER BY Total_Revenue DESC;

-- Booking conversion by channel
SELECT 
    Sales_Channel,
    SUM(Booking_Flag) as Bookings,
    COUNT(*) as Total,
    ROUND(SUM(Booking_Flag) * 100.0 / COUNT(*), 2) as Conversion_Rate
FROM data_table
GROUP BY Sales_Channel;

-- Top developers
SELECT 
    Developer_Name,
    SUM(Ticket_Price_Cr) as Revenue,
    COUNT(*) as Projects,
    AVG(Ticket_Price_Cr) as Avg_Price
FROM data_table
GROUP BY Developer_Name
ORDER BY Revenue DESC
LIMIT 10;
```

### B. Python Environment Setup

```bash
# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Mac/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

### C. Power BI Tips

1. **Optimize Performance:**
   - Use Import mode for <1GB data
   - Use DirectQuery for real-time data
   - Create aggregated tables for large datasets
   - Minimize number of visuals per page (max 15-20)

2. **Design Best Practices:**
   - Consistent color scheme across pages
   - Clear hierarchy (title > subtitle > visuals)
   - White space for breathing room
   - Mobile layout for phone/tablet users

3. **DAX Optimization:**
   - Avoid calculated columns when possible
   - Use variables in complex measures
   - Filter early in calculations
   - Test performance with DAX Studio

---

**End of Documentation**
