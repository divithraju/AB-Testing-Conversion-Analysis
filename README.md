# 🧪 A/B Testing & Conversion Rate Optimization — Statistical Analysis

<div align="center">

![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Statistics](https://img.shields.io/badge/Statistics-Hypothesis_Testing-9B59B6?style=for-the-badge)
![Scipy](https://img.shields.io/badge/Scipy-Stats-8CAAE6?style=for-the-badge&logo=scipy&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Streamlit](https://img.shields.io/badge/Streamlit-Live_Demo-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)

**Experiment Design → Statistical Testing → Business Decision → Revenue Impact**


</div>


## 📌 Business Problem

An e-commerce company redesigned their **product page checkout button** — changing the color, copy, and placement. Before rolling it out to all **2 million users**, the product team ran an A/B test.

**The challenge:** Anyone can say "Version B looks better." But *statistically*, is it actually better? Or did it just get lucky with the sample?

- Shipping a losing variation → **loss of revenue**
- Shipping a winning variation → **significant growth**

**My objective:**
- Apply statistical testing  
- Determine if Version B improves conversion  
- Calculate revenue impact  
- Document analysis like a real analytics team  

## 🎯 Experiment Design

| Parameter | Detail |
|----------|--------|
| Hypothesis | New checkout button (Version B) increases conversion vs Version A |
| Null Hypothesis (H₀) | Conversion Rate A = Conversion Rate B |
| Alt Hypothesis (H₁) | Conversion Rate B > Conversion Rate A |
| Metric | Conversion Rate (purchases / sessions) |
| Secondary Metrics | Revenue per user, Bounce rate, Time on page |
| Significance Level | α = 0.05 (95% confidence) |
| Statistical Power | β = 0.80 (80% power) |
| Minimum Detectable Effect | 2% lift (13% → 15%) |
| Required Sample Size | 4,720 per group |
| Test Duration | 14 days |
| Test Type | Two-proportion Z-test |

## 📊 Results Summary

| Metric | Control (A) | Treatment (B) | Lift | Significant? |
|--------|-------------|---------------|------|--------------|
| Conversion Rate | 13.1% | 14.8% | **+1.7pp (+13%)** | ✅ Yes (p=0.043) |
| Revenue per User | ₹87.3 | ₹99.2 | **+₹11.9 (+13.6%)** | ✅ Yes |
| Bounce Rate | 42.3% | 40.1% | **-2.2pp (-5.2%)** | ✅ Yes |
| Avg Session Duration | 3m 12s | 3m 28s | **+16s (+8.3%)** | ✅ Yes |
| Pages per Session | 4.2 | 4.5 | **+0.3 (+7.1%)** | ✅ Yes |

> **Decision: SHIP Version B — estimated annual revenue uplift ₹28.6 lakhs**

## 📁 Project Structure

- **notebooks/**
  - `ab_testing_analysis.ipynb` – Full analysis + visualizations  

- **sql/**
  - `ab_testing_queries.sql` – 14 experiment queries  

- **dashboard/**
  - `app.py` – Streamlit interactive dashboard  

- **data/**
  - `README_data.md` – Dataset info + download link  

- **reports/**
  - `experiment_report.md` – Stakeholder-ready findings  

- **README.md**
  - Project overview
 
## 🔬 Statistical Methods Used

### 1. Sample Size Calculation (Pre-Experiment)

Calculated the **minimum sample size required before running the experiment** —  
a step most analysts skip but every **senior analyst prioritizes**.

- **Baseline conversion rate:** 13%  
- **Minimum detectable effect (MDE):** 2% absolute lift  
- **Significance level (α):** 0.05  
- **Statistical power:** 0.80  

📊 **Required sample size:** 4,720 users per group  
### 2. Sanity Checks (A/A Test Validation)

Before trusting experiment results, verified that the **experiment setup is valid and unbiased**:

- **Sample Ratio Mismatch (SRM) test**  
  - Ensures traffic is evenly split between control and variant groups  

- **Pre-experiment baseline comparison**  
  - Confirms both groups behave similarly before the test  

- **Cookie/session contamination check**  
  - Ensures users are not exposed to multiple variants  

### 3. Two-Proportion Z-Test

- Primary statistical test for comparing **conversion rates** between control and treatment groups  
- Determines whether observed differences are **statistically significant**  

### 4. Welch’s T-Test

- Used for **continuous metrics**:
  - Revenue per user  
  - Session duration  
- Handles **unequal variances** between groups  

### 5. Chi-Square Test

- Used for **categorical metrics**:
  - Bounce rate (bounced vs not)  
  - Device type distribution  
- Tests whether differences in proportions are **significant across categories**

### 6. Confidence Interval Construction

- Constructed **95% confidence intervals** for:
  - Conversion rate difference  
  - Revenue uplift  
- Provides a **range of plausible values** instead of relying only on point estimates  
- Helps assess both **statistical significance and practical impact** 

### 7. Segmented Analysis

- Broke down results across key segments:
  - Device type  
  - User type (new vs returning)  
  - City tier  

- Ensures that **overall results do not mask segment-level differences**  

💡 **Key Insight:**
- A statistically significant overall lift can still hide a **negative impact in specific segments**  
- Segment-level validation is critical before making rollout decisions

## 💡 Key Insights Beyond the Headline

### 🔹 Insight 1: New Users vs Returning Users React Differently

- Version B performed strongly for **new users**:
  - **+3.2pp conversion lift**  
- Minimal impact for **returning users**:
  - **+0.4pp (not statistically significant)**  

💡 **Interpretation:**
- Version B improves **first-impression clarity**  
- Reduces hesitation for users unfamiliar with the product  

**🎯 Recommendation:**
- Show **Version B only to new/first-time visitors**  
- Keep existing experience for **returning users** to maintain familiarity  
- This approach maximizes **ROI while minimizing risk**  
### 🔹 Insight 3: The Effect Plateaued After Day 7

- Day-by-day analysis shows conversion lift **stabilized after day 7**  
- Experiment ran for **14 days**, confirming result consistency  

💡 **Interpretation:**
- The improvement is **not a novelty effect**  
- Users are not just reacting to something “new” — the change delivers **real value**  

**🎯 Recommendation:**
- Results are **stable and reliable** → safe to move forward  
- No need to extend experiment duration further  

### 🔹 Insight 4: High-Value Customers Converted More

- Users with **previous purchase > ₹500**:
  - **+4.1pp conversion lift**  

- Lower-value customers:
  - **+1.1pp conversion lift**  

💡 **Interpretation:**
- Version B resonates more with **high-intent / high-value users**  
- Indicates stronger impact on **revenue-driving segments**  

**🎯 Recommendation:**
- Prioritize rollout for **high-value customer segments**  
- Consider **personalized experiences** based on user value  
- Focus on maximizing **revenue impact, not just conversion rate**

## 📈 Revenue Impact Calculation

- **Monthly traffic:** 200,000 sessions  

### 📊 Conversion Comparison

| Metric | Version A (Current) | Version B (New) |
|--------|--------------------|-----------------|
| Conversion Rate | 13.1% | 14.8% |
| Orders / Month  | 26,200 | 29,600 |

---

### 📦 Incremental Impact

- **Additional orders/month:** 3,400  
- **Average order value (AOV):** ₹700  

💰 **Monthly Revenue Uplift:** ₹23,80,000  
💰 **Annual Revenue Uplift:** ₹2,85,60,000  

---

### ⚠️ Conservative Estimate

- Assuming only **10% attribution**:

👉 **₹28,56,000 annual incremental revenue**

---

### 💡 Business Takeaway

- Even under conservative assumptions, the experiment delivers **multi-lakh annual impact**  
- Strong case for **immediate rollout (especially mobile + high-value segments)**

## 🛠️ Tech Stack

| Tool                     | Purpose                                   |
|--------------------------|-------------------------------------------|
| Python + Pandas          | Data manipulation, feature engineering    |
| Scipy (stats)            | Z-test, T-test, Chi-square                |
| Statsmodels              | Power analysis, confidence intervals      |
| Plotly + Seaborn         | 10+ statistical visualizations            |
| MySQL                    | Experiment data queries                   |
| Streamlit                | Interactive results dashboard             |

## 🚀 How to Run

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/divithraju/ab-testing-conversion-analysis
cd ab-testing-conversion-analysis
```
### 2️⃣ Install Dependencies

```bash
pip install -r requirements.txt
```

### 3️⃣ Run the Analysis Notebook

```bash
jupyter notebook notebooks/ab_testing_analysis.ipynb
```

### 4️⃣ Launch the Dashboard

```bash
streamlit run dashboard/app.py
```

## 📊 Dataset

- Available on **Kaggle – A/B Testing Dataset**  
- See: `data/README_data.md` for download link and setup instructions  

---

## 📋 Requirements

```txt
pandas==2.0.3
numpy==1.24.3
scipy==1.11.1
statsmodels==0.14.0
plotly==5.15.0
seaborn==0.12.2
matplotlib==3.7.1
streamlit==1.25.0
mysql-connector-python==8.1.0
jupyter==1.0.0
```

---

## 🔗 Connect

- LinkedIn: https://www.linkedin.com/in/divithraju/
- GitHub: https://github.com/divithraju  






