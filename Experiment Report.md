# Experiment Report: Checkout Button Redesign
### A/B Test — Final Results & Recommendation
**Author:** Divith Raju | Data Analyst  
**Experiment Period:** 14 days | **Decision Date:** End of Week 2

---

## Executive Summary

We tested whether changing the checkout button from a grey *"Continue"* button to an orange *"Add to Cart — Buy Now"* button increases purchase conversion rate. After a 14-day experiment with 294,000 users, **Version B significantly outperforms Version A**.

**Recommendation: Ship Version B. Estimated annual revenue uplift: ₹2.86 crore.**

---

## What We Tested

| | Version A (Control) | Version B (Treatment) |
|---|---|---|
| Button Color | Grey | Orange |
| Button Text | "Continue" | "Add to Cart — Buy Now" |
| Button Position | Below description | Above fold |
| Who Saw It | 50% of users | 50% of users |

---

## Was the Experiment Run Correctly?

Before trusting results, we ran three validation checks:

**1. Sample Ratio Mismatch:** Traffic split was 50.02% / 49.98% — well within acceptable range. ✅  
**2. User Contamination:** Zero users saw both versions. ✅  
**3. Page Assignment:** All control users saw old page; all treatment users saw new page. ✅  

The experiment infrastructure worked correctly. Results can be trusted.

---

## Results

### Primary Metric: Conversion Rate

| | Control (A) | Treatment (B) |
|---|---|---|
| Users | 147,276 | 147,202 |
| Conversions | 19,293 | 21,787 |
| Conversion Rate | 13.1% | 14.8% |
| **Absolute Lift** | — | **+1.7 percentage points** |
| **Relative Lift** | — | **+13%** |

**Statistical test:** Two-proportion Z-test  
**Z-statistic:** 2.03  
**P-value:** 0.043  
**Significant at α=0.05:** YES ✅  
**95% Confidence Interval for the lift:** [+0.02pp, +3.37pp]

The CI tells us: we are 95% confident the true lift is between 0.02 and 3.37 percentage points. Even at the lower bound, the improvement is positive.

### Secondary Metrics

| Metric | Control | Treatment | Change | Significant? |
|---|---|---|---|---|
| Revenue per user | ₹87.3 | ₹99.2 | +₹11.9 (+13.6%) | ✅ Yes |
| Bounce rate | 42.3% | 40.1% | -2.2pp | ✅ Yes |
| Session duration | 3m 12s | 3m 28s | +16s | ✅ Yes |

All secondary metrics moved in the right direction, strengthening confidence in the result.

---

## Where the Lift Comes From

### Best performing segment: Mobile new users
Mobile new users showed a +3.2pp lift — nearly double the overall result. These are the customers who benefit most from a clearer, more visible call-to-action.

### Weakest segment: Desktop returning users
Desktop returning users showed only +0.4pp lift, and it was not statistically significant. These users already know the product and are not influenced by button changes.

This pattern makes intuitive sense: new visitors need more guidance; loyal customers already know where to click.

---

## Is This a Real Effect?

One concern with A/B tests is the "novelty effect" — users click something new simply because it's different, and the effect fades after a few days. We checked:

- Days 1-6: Lift was slightly higher (expected, some novelty)
- Days 7-14: Lift stabilized at approximately +1.7pp
- The effect is **not** a novelty effect. It is a sustained genuine improvement.

---

## Revenue Impact

```
Monthly sessions:       200,000
Additional conversions: +3,400/month
Average order value:    ₹700

Monthly uplift:  ₹23,80,000
Annual uplift:   ₹2,85,60,000
```

Even at the lower confidence interval bound (+0.02pp), the annual revenue impact is positive.

---

## Recommendation & Rollout Plan

**Decision: SHIP Version B**

**Phased rollout to manage risk:**

| Week | Action |
|---|---|
| Week 1 | 100% rollout to mobile new users (highest impact, lowest risk) |
| Week 2 | 100% rollout to mobile returning users |
| Week 3 | 100% rollout to desktop users |
| Week 4 | Full rollout complete — monitor for 2 additional weeks |

**Post-launch monitoring metrics:**
- Overall conversion rate (target: ≥14.5%)
- Revenue per user
- Bounce rate
- Segment-level dashboards

---

## Risks & Limitations

1. **External validity:** The experiment was run in January. Conversion behavior may differ during sale seasons (Diwali, etc.)
2. **One metric optimized:** We optimized for conversion rate. Long-term retention impact of the button change was not measured.
3. **Interaction effects:** This test ran in isolation. Future experiments should avoid simultaneous changes to the same page.

---

*Full statistical analysis: `notebooks/ab_testing_analysis.ipynb`*  
*SQL queries: `sql/ab_testing_queries.sql`*  
*Live dashboard: `streamlit run dashboard/app.py`*
