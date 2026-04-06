# Dataset Information

## Dataset: E-Commerce A/B Testing

**Source:** Kaggle — Free, publicly available  
**Download Link:** https://www.kaggle.com/datasets/putdejudomthai/ecommerce-ab-testing-2022-dataset1  
**File:** `ab_data.csv`

## Alternative Dataset (also works perfectly)
https://www.kaggle.com/datasets/zhangluyuan/ab-testing  
File: `ab_data.csv`

## How to Set Up

1. Download dataset from either Kaggle link above
2. Place file in this `/data/` folder as `ab_data.csv`
3. Run: `jupyter notebook notebooks/ab_testing_analysis.ipynb`

> **Note:** If dataset file is missing, the notebook automatically generates realistic synthetic data matching the same structure. You can run the full analysis without downloading anything.

## Dataset Structure

| Column | Type | Description |
|---|---|---|
| user_id | int | Unique user identifier |
| timestamp | datetime | When the session occurred |
| group | string | 'control' or 'treatment' |
| landing_page | string | 'old_page' or 'new_page' |
| converted | binary | 1 = purchased, 0 = did not purchase |

## Columns Added by Our Analysis

| Column | Description |
|---|---|
| device | mobile / desktop / tablet |
| user_type | new / returning |
| city_tier | 1 / 2 / 3 |
| session_duration | seconds spent on page |
| revenue | order value if converted, else 0 |

## Dataset Size
- ~294,000 rows
- 50/50 control/treatment split
- 14-day experiment window
