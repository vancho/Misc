### Project: A/B Test

**Description**
This project involved an A/B test analysis to evaluate the effectiveness of two different pricing strategies on user conversion rates. The objective was to determine whether offering a subscription service at $4.99 (Group A) or the same subscription with a 50% discount note (Group B) had a significant impact on user conversions. The dataset used for this analysis, _**ab_test_data.csv**_, contained information about users' group allocations (Group A or B), timestamps of user actions, and their conversion status (whether they purchased the subscription or not).

**Key Tasks**

**Data Loading and Preparation:** Utilized Python's _**pandas**_ library to load and prepare the dataset for analysis. This involved reading the CSV file, parsing timestamps, and organizing the data for analysis.

**Descriptive Statistics Calculation:** Computed key metrics such as the number of users in each group, the number of conversions, and the conversion rates. This provided a clear understanding of the basic characteristics of the dataset.

**Statistical Testing for Hypothesis:** Conducted a Chi-Squared test using the _**scipy.stats**_ library to evaluate if there was a statistically significant difference in conversion rates between the two groups. This involved constructing a contingency table and calculating the test statistic and p-value.

**Data Visualization:**
- Used **_matplotlib_** and **_seaborn_** libraries to create visualizations.
- Generated a bar chart showing the conversion rates with 95% confidence intervals for each group.
- Created a time-series plot to illustrate the daily conversion rates over the test period, allowing for the observation of trends and patterns in the data.

**Insights and Recommendations:** Based on the statistical analysis and visualizations, provided insights into the effectiveness of the discount strategy and offered business strategy recommendations.

This project combined data manipulation, statistical analysis, and visualization techniques to draw meaningful conclusions from the A/B testing data, aiding in informed decision-making.