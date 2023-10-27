### Project: Applications

**Description:**
This project aims to clean, manipulate, and analyze two datasets related to applications data using Python, Pandas, Matplotlib, Seaborn. The primary objectives are to prepare the data for analysis by handling missing values, duplicates, and combining datasets, and then to calculate an application rating based on specific criteria. The datasets used include main application data and a supplementary "industries.csv" file that provides industry ratings.

**Key tasks:**

**Data cleaning and preprocessing:**
- Load the datasets.
- Remove duplicate entries based on 'applicant_id'.
- Handle missing values:
    - Fill 'External Rating' with zeros.
    - Fill 'Education level' with "High School".
- Combine the main dataset with "industries.csv" to integrate industry ratings.
- Calculate the Application Rating based on several conditions, ranging from applicant demographics to external ratings.
- Filter out applications with a rating of zero or less.

**Exploratory data analysis (EDA):**
- Analyze the cleaned dataset to understand the distribution and relationships between variables.
- Investigate the characteristics of accepted applications.
- Explore how different factors like age, location, and external ratings influence the application rating.

**Data visualization using Matplotlib and Seaborn:**
- Visualize the distribution of application ratings.
- Plot the correlation between age and application rating.
- Analyze and visualize the impact of various factors on the acceptance of applications.
- Use bar plots, scatter plots, and other visualization techniques to gain insights from the data.

In this folder you can find datasets files anf Jupiter Notebook with the whole process. 