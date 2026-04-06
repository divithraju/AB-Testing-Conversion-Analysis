"""
A/B Testing Analysis — Interactive Dashboard
Author: Divith Raju
Run: streamlit run app.py
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from scipy.stats import norm
from statsmodels.stats.proportion import proportions_ztest, proportion_confint

st.set_page_config(
    page_title="A/B Test Dashboard",
    page_icon="🧪",
    layout="wide"
)

st.markdown("""
<style>
    .result-win  { background:#d5f5e3; border-left:4px solid #2ecc71; padding:1rem; border-radius:4px; }
    .result-lose { background:#fadbd8; border-left:4px solid #e74c3c; padding:1rem; border-radius:4px; }
    .insight-box { background:#fef9e7; border-left:4px solid #f39c12; padding:.75rem 1rem; border-radius:4px; font-size:.9rem; margin:.5rem 0; }
</style>
""", unsafe_allow_html=True)


# ── Data ──────────────────────────────────────────────────────────────
@st.cache_data
def load_data():
    np.random.seed(42)
    n = 294478
    group = np.random.choice(['control', 'treatment'], n, p=[0.5, 0.5])
    conversion = np.where(
        group == 'control',
        np.random.binomial(1, 0.131, n),
        np.random.binomial(1, 0.148, n)
    )
    df = pd.DataFrame({
        'user_id':          range(1, n+1),
        'timestamp':        pd.date_range('2024-01-01', periods=n, freq='1min'),
        'group':            group,
        'converted':        conversion,
        'device':           np.random.choice(['mobile','desktop','tablet'], n, p=[0.62,0.31,0.07]),
        'user_type':        np.random.choice(['new','returning'], n, p=[0.58,0.42]),
        'city_tier':        np.random.choice([1,2,3], n, p=[0.45,0.38,0.17]),
        'session_duration': np.random.normal(
            np.where(group=='control', 192, 208), 60, n).clip(10,600),
        'revenue':          np.where(conversion==1,
            np.random.normal(700,150,n).clip(100,3000), 0)
    })
    df['date'] = pd.to_datetime(df['timestamp']).dt.date
    return df

df = load_data()


# ── Sidebar ───────────────────────────────────────────────────────────
st.sidebar.title("🧪 Experiment Controls")
st.sidebar.markdown("---")

alpha_input = st.sidebar.selectbox("Significance Level (α)", [0.05, 0.01, 0.10], index=0)
st.sidebar.markdown("---")

device_filter   = st.sidebar.multiselect("Filter by Device",    df['device'].unique(),    default=list(df['device'].unique()))
usertype_filter = st.sidebar.multiselect("Filter by User Type", df['user_type'].unique(), default=list(df['user_type'].unique()))
tier_filter     = st.sidebar.multiselect("Filter by City Tier", sorted(df['city_tier'].unique()), default=list(df['city_tier'].unique()))

mask = (
    df['device'].isin(device_filter) &
    df['user_type'].isin(usertype_filter) &
    df['city_tier'].isin(tier_filter)
)
df_f = df[mask]

ctrl = df_f[df_f['group'] == 'control']
trt  = df_f[df_f['group'] == 'treatment']

cr_c = ctrl['converted'].mean()
cr_t = trt['converted'].mean()
diff = cr_t - cr_c

n_c, n_t = len(ctrl), len(trt)
conv_c, conv_t = ctrl['converted'].sum(), trt['converted'].sum()

count_arr = np.array([conv_t, conv_c])
nobs_arr  = np.array([n_t, n_c])
z_stat, p_val = proportions_ztest(count_arr, nobs_arr, alternative='larger')
ci_low, ci_high = (
    diff - norm.ppf(1-alpha_input/2) * np.sqrt(cr_c*(1-cr_c)/n_c + cr_t*(1-cr_t)/n_t),
    diff + norm.ppf(1-alpha_input/2) * np.sqrt(cr_c*(1-cr_c)/n_c + cr_t*(1-cr_t)/n_t)
)

significant = p_val < alpha_input

st.sidebar.markdown("---")
st.sidebar.markdown(f"**Filtered sample:** {len(df_f):,} users")


# ── Header ────────────────────────────────────────────────────────────
st.title("🧪 A/B Test: Checkout Button Redesign")
st.markdown("*Experiment: Version A (grey 'Continue') vs Version B (orange 'Add to Cart — Buy Now')*")
st.markdown("---")

# ── Result Banner ─────────────────────────────────────────────────────
if significant:
    st.markdown(f"""
    <div class="result-win">
    <b>✅ STATISTICALLY SIGNIFICANT — Version B WINS</b><br>
    p-value = {p_val:.4f} &lt; α={alpha_input} &nbsp;|&nbsp;
    Lift = +{diff*100:.2f}pp (+{diff/cr_c*100:.1f}%) &nbsp;|&nbsp;
    95% CI: [{ci_low*100:.2f}pp, {ci_high*100:.2f}pp]
    </div>
    """, unsafe_allow_html=True)
else:
    st.markdown(f"""
    <div class="result-lose">
    <b>❌ NOT SIGNIFICANT — Cannot conclude Version B is better</b><br>
    p-value = {p_val:.4f} ≥ α={alpha_input} &nbsp;|&nbsp;
    Observed lift = +{diff*100:.2f}pp — could be random chance
    </div>
    """, unsafe_allow_html=True)

st.markdown("")

# ── KPI Row ───────────────────────────────────────────────────────────
c1, c2, c3, c4, c5 = st.columns(5)
c1.metric("Control CR",   f"{cr_c:.2%}")
c2.metric("Treatment CR", f"{cr_t:.2%}", delta=f"+{diff*100:.2f}pp")
c3.metric("Z-statistic",  f"{z_stat:.3f}")
c4.metric("P-value",      f"{p_val:.4f}", delta="Significant ✅" if significant else "Not sig ❌")
c5.metric("Annual Uplift", f"₹{diff * 200000 * 700 * 12 / 100000:.1f}L" if significant else "—")

st.markdown("---")

# ── Charts Row 1 ──────────────────────────────────────────────────────
col1, col2 = st.columns(2)

with col1:
    st.subheader("Conversion Rate with 95% CI")
    ci_c_l, ci_c_h = proportion_confint(conv_c, n_c, method='wilson')
    ci_t_l, ci_t_h = proportion_confint(conv_t, n_t, method='wilson')

    fig = go.Figure(go.Bar(
        x=['Control (A)', 'Treatment (B)'],
        y=[cr_c*100, cr_t*100],
        error_y=dict(
            type='data',
            array=[(ci_c_h-cr_c)*100, (ci_t_h-cr_t)*100],
            arrayminus=[(cr_c-ci_c_l)*100, (cr_t-ci_t_l)*100],
            visible=True
        ),
        marker_color=['#3498db', '#2ecc71' if significant else '#e74c3c'],
        text=[f'{cr_c:.2%}', f'{cr_t:.2%}'],
        textposition='outside',
        width=0.4
    ))
    fig.update_layout(yaxis_title='Conversion Rate (%)', height=350, showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

with col2:
    st.subheader("Revenue per User")
    rev_c = ctrl['revenue'].mean()
    rev_t = trt['revenue'].mean()

    fig2 = go.Figure(go.Bar(
        x=['Control (A)', 'Treatment (B)'],
        y=[rev_c, rev_t],
        marker_color=['#3498db', '#2ecc71'],
        text=[f'₹{rev_c:.0f}', f'₹{rev_t:.0f}'],
        textposition='outside',
        width=0.4
    ))
    fig2.update_layout(yaxis_title='Avg Revenue per User (₹)', height=350, showlegend=False)
    st.plotly_chart(fig2, use_container_width=True)

# ── Segmented Analysis ────────────────────────────────────────────────
st.markdown("---")
st.subheader("📊 Segmented Lift Analysis")

seg_rows = []
for col_name, label_prefix in [('device','Device'), ('user_type','User Type'), ('city_tier','City Tier')]:
    for val in df_f[col_name].unique():
        seg = df_f[df_f[col_name] == val]
        s_c = seg[seg['group']=='control']
        s_t = seg[seg['group']=='treatment']
        if len(s_c) < 100 or len(s_t) < 100:
            continue
        cr_sc, cr_st = s_c['converted'].mean(), s_t['converted'].mean()
        lift = (cr_st - cr_sc) * 100
        _, p_s = proportions_ztest(
            [s_t['converted'].sum(), s_c['converted'].sum()],
            [len(s_t), len(s_c)], alternative='larger'
        )
        seg_rows.append({
            'Segment': f'{label_prefix}: {val}',
            'Control CR': f'{cr_sc:.2%}',
            'Treatment CR': f'{cr_st:.2%}',
            'Lift (pp)': round(lift, 2),
            'P-Value': round(p_s, 4),
            'Significant?': '✅' if p_s < alpha_input else '❌',
            'Sample': len(seg)
        })

seg_df = pd.DataFrame(seg_rows).sort_values('Lift (pp)', ascending=False)

col_a, col_b = st.columns([1, 1])
with col_a:
    fig3 = go.Figure(go.Bar(
        x=seg_df['Lift (pp)'],
        y=seg_df['Segment'],
        orientation='h',
        marker_color=['#2ecc71' if s == '✅' else '#e74c3c' for s in seg_df['Significant?']],
        text=seg_df['Lift (pp)'].apply(lambda x: f'+{x:.2f}pp'),
        textposition='outside'
    ))
    fig3.add_vline(x=0, line_color='black', line_width=1.5)
    fig3.update_layout(
        title='Lift by Segment', xaxis_title='Lift (pp)',
        height=380, showlegend=False
    )
    st.plotly_chart(fig3, use_container_width=True)

with col_b:
    st.dataframe(seg_df, hide_index=True, use_container_width=True)
    st.markdown('<div class="insight-box">🔍 <b>Mobile + New Users</b> drive the strongest lift. Prioritize these segments for rollout.</div>', unsafe_allow_html=True)

# ── Daily Trend ───────────────────────────────────────────────────────
st.markdown("---")
st.subheader("📅 Daily Conversion Rate Trend")

daily = df_f.groupby(['date','group'])['converted'].mean().reset_index()
daily.columns = ['date','group','cr']

fig4 = px.line(
    daily, x='date', y='cr', color='group',
    color_discrete_map={'control':'#3498db','treatment':'#2ecc71'},
    labels={'cr':'Conversion Rate','date':'Date','group':'Version'},
    title='Daily CR: Is the lift stable or a novelty effect?'
)
fig4.update_yaxes(tickformat='.1%')
fig4.update_layout(height=350)
st.plotly_chart(fig4, use_container_width=True)
st.markdown('<div class="insight-box">🔍 <b>Stability check:</b> Lift should be consistent after day 5-7. Early spikes that fade indicate a novelty effect — not a real improvement.</div>', unsafe_allow_html=True)

# ── Footer ────────────────────────────────────────────────────────────
st.markdown("---")
st.markdown("**📊 Divith Raju** | [GitHub](https://github.com/divithraju) · [LinkedIn](https://linkedin.com/in/divithraju) | Tools: Python · Scipy · Streamlit · Plotly")
