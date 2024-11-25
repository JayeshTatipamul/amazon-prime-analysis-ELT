# Amazon Prime Movies and TV Shows Analysis Project

## Overview
This project analyzes the Amazon Prime Movies and TV Shows dataset sourced from Kaggle. The dataset was downloaded, extracted using Python and the loaded into MySQL for transformation. The focus was on cleaning, normalizing, and analyzing the data to derive valuable business insights while applying advanced SQL techniques and data modeling principles. 

## Steps Involved
1. **Data Acquisition and Loading**:
   - Downloaded the dataset from Kaggle.
   - Extracted the data and loaded it into a MySQL database using Python.

2. **Data Transformation**:
   - Removed duplicate records.
   - Handled missing values, deriving new columns like `date_added` from `release_year` when feasible.
   - Split multi-valued columns (e.g., genres, directors) into normalized structures using advanced SQL techniques such as Recursive CTEs.
   - Normalized denormalized data for relational integrity.

3. **Data Modeling**:
   - Structured the database by normalizing data into separate tables.
   - Established relationships between tables to enable efficient querying.

4. **Challenges Faced**:
   - Splitting comma-separated values in MySQL required implementing Recursive CTEs and advanced string functions.
   - Addressing null values in critical columns like `date_added` involved leveraging related fields like `release_year`.

## Business Questions Answered
This project addressed the following business questions:

1. **Top 10 Directors (Excluding Unknown)**:
   - Identified the top 10 directors contributing the most to movies on Amazon Prime.

2. **Country with the Highest Number of Comedy Movies**:
   - Analyzed which country produced the most comedy movies based on cleaned and normalized data.

3. **Most Prolific Directors by Year**:
   - For each year (derived from the `date_added` column), identified the director who released the maximum number of movies.

4. **Average Movie Duration by Genre**:
   - Calculated the average duration of movies for each genre.

5. **Directors Creating Both Comedy and Horror Movies**:
   - Found directors who have contributed to both comedy and horror movies, along with the number of movies in each genre they directed.

## Skills and Techniques Applied
- **SQL Concepts**:
  - Recursive CTEs for splitting multi-valued columns.
  - Advanced `GROUP BY` queries and aggregate functions.
  - Joins, Subqueries, and Case Statements for complex transformations.
  - Data normalization and relational modeling.
- **Data Engineering**:
  - Developed an ELT (Extract, Load, Transform) pipeline.
  - Addressed nulls, duplicates, and data inconsistencies.
  - Derived meaningful columns to enhance data analysis.
- **Problem Solving**:
  - Solved real-world data manipulation challenges and provided business insights.

## Key Learnings
- Strengthened SQL fundamentals, including advanced techniques such as Recursive CTEs, Window Functions, and Data Modeling.
- Gained practical experience in developing end-to-end ELT pipelines with a focus on data transformation and business problem-solving.
- Enhanced problem-solving abilities by tackling complex data scenarios.

## Acknowledgments
This project was inspired and guided by **Ankit Bansal** on his YouTube channel. The structured approach helped address real-world data challenges and develop actionable business insights.

---

## How to Use
1. Clone this repository.
2. Load the dataset into your MySQL database.
3. Run the SQL scripts included in the repository to replicate the transformations and analyses.

Feel free to reach out with any questions or suggestions!
