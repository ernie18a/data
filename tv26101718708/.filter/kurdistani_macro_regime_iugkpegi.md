# Kurdistani Macro Regime

- url: https://www.tradingview.com/script/IUgkPeGI-Kurdistani-Macro-Regime/
- type: indicator
- pine_id: PUB;59b1a8e38d9f4514a0ba6b921e671671
- version: 1.0

## Description

# Kurdistani Macro Regime

## Overview

Kurdistani Macro Regime is a comprehensive macroeconomic dashboard designed to help traders evaluate the current global macro environment using publicly available economic data.

Rather than predicting future prices, the script converts multiple macroeconomic indicators into a rule-based market regime model that helps identify whether current conditions favor:

• Expansion
• Recovery
• Slowdown
• Stagflation
• Recession

The indicator combines inflation, monetary policy, liquidity, labor market conditions, yield curve dynamics, credit spreads and volatility into a single analytical framework.

This script is intended for macro analysis and portfolio positioning rather than short-term price forecasting.

---

# Data Sources

The indicator retrieves macroeconomic information directly from the FRED (Federal Reserve Economic Data) database whenever available.

Main datasets include:

• CPI Inflation
• Federal Funds Rate
• ECB Policy Rate
• GDP
• Unemployment Rate
• M2 Money Supply
• Treasury Yields
• Credit Spreads
• VIX
• Inflation Breakevens
• Oil Prices

Because macroeconomic releases occur weekly, monthly or quarterly, values update only when new official data become available.

---

# Macro Regime Engine

The script evaluates three major components of the economy.

## 1. Growth

Growth is estimated using:

• GDP Growth
• PMI Trend
• Labor Market
• Growth Momentum

Higher scores indicate stronger economic expansion.

---

## 2. Inflation

Inflation analysis includes:

• CPI Level
• CPI Trend

Higher inflation increases the probability of restrictive monetary policy.

---

## 3. Liquidity

Liquidity considers:

• M2 Growth
• Federal Funds Rate
• Yield Curve
• Market Volatility

Higher liquidity generally supports risk assets.

---

These components are combined into five macro regimes.

Expansion

Strong growth with controlled inflation.

Recovery

Improving growth following economic weakness.

Slowdown

Moderating economic activity.

Stagflation

High inflation combined with weak growth.

Recession

Broad deterioration across multiple macro indicators.

---

# Advanced Macro Indicators

The dashboard includes several composite indicators.

## Macro Health Score

A composite score between 0 and 100 summarizing overall macro conditions.

Higher values indicate healthier macro environments.

---

## Recession Risk Score

A rule-based composite using:

• Yield Curve
• GDP
• PMI
• Labor Market
• Credit Spreads
• Real Interest Rates

This score is **not** a statistical recession probability.

---

## Fed Pivot Score

Measures whether macro conditions are becoming more favorable for future monetary easing.

Inputs include:

• Inflation
• GDP
• Unemployment
• Yield Curve
• Interest Rates

This is an analytical score rather than a forecast.

---

## Dollar Milkshake Score

Estimates relative USD strength using:

• Interest Rate Differential
• Credit Stress
• Emerging Market Stress
• Volatility
• Real Rates

Higher values suggest stronger demand for USD liquidity.

---

# Asset Outlook

The indicator estimates macro conditions for several asset classes.

## Gold

Gold generally benefits from:

• Negative Real Rates
• Higher Inflation
• Recession Risk
• Easier Liquidity

---

## Bitcoin

Bitcoin is evaluated primarily through:

• Global Liquidity
• Risk Appetite
• Real Rates
• Monetary Conditions

---

## US Dollar

The Dollar score reflects:

• Rate Differentials
• Risk-Off Conditions
• Real Rates
• Credit Stress

---

## US Equities

The equity model incorporates:

• Growth
• Liquidity
• Yield Curve
• Credit Conditions

---

## Long-Term Treasury Bonds

Bond scoring focuses on:

• Recession Risk
• Fed Pivot
• Yield Curve
• Real Rates

---

# Dashboard

The dashboard summarizes:

Current Macro Regime

Risk-On / Risk-Off Environment

Macro Health

Recession Risk

Fed Pivot Score

Dollar Milkshake Score

Yield Curve

Interest Rates

Inflation

GDP

PMI

Employment

Oil Trend

Asset Scores

Signal History

Upcoming Economic Calendar

---

# Trading Signals

The script generates several informational signals.

Gold Macro Bullish

Appears when macro conditions become favorable for gold.

Bitcoin Risk-On

Appears when liquidity and risk conditions support Bitcoin.

Yield Curve Inversion

Highlights significant inversion events.

Fed Pivot

Indicates improving conditions for potential future monetary easing.

Oil Shock

Flags unusually large oil price movements.

These signals are informational and should be confirmed with market structure and price action.

---

# Risk Management

This indicator is designed to complement—not replace—technical analysis.

Possible workflow:

1. Determine the current macro regime.

2. Evaluate risk appetite.

3. Compare asset scores.

4. Wait for technical confirmation.

5. Execute trades according to your own trading plan.

---

# Inputs

Users can customize:

• Macro thresholds

• Dashboard visibility

• Signal visibility

• Calendar dates

• Watermark

• Risk profile

• Alert system

• Bullish thresholds

---

# Limitations

This script uses macroeconomic data that update less frequently than market prices.

Economic releases may be revised after publication.

Some FRED series may be unavailable depending on TradingView data availability.

The model is deterministic and rule-based.

It does not employ machine learning or statistical forecasting.

---

# Disclaimer

This indicator is intended solely as an educational and analytical tool.

All scores, regimes, probabilities and signals are generated using predefined rule-based logic and should not be interpreted as predictions or guarantees of future market performance.

Always combine macro analysis with technical analysis, sound risk management and your own independent research before making trading decisions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coin_Kurd
//@version=6

indicator("Kurdistani Macro Regime", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — INPUTS & SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Macro Calendar ────────────────────────────────────────────────────────────
// NOTE: Dates below reflect the next known scheduled release as of the last
// script update. They are user-editable inputs — traders should verify against
// the official Fed / ECB / BLS / BEA calendars, as these dates can shift.
string GRP_CAL  = "📅 Macro Calendar (Next Releases)"
string cal_fed  = input.string("July 29",  "Next Fed Meeting",   group=GRP_CAL, tooltip="تاریخ جلسه تعیین نرخ بهره فدرال رزرو (FOMC)؛ محرک اصلی نقدینگی و جهت‌دهی به کل بازارهای مالی.")
string cal_ecb  = input.string("July 23",  "Next ECB Meeting",   group=GRP_CAL, tooltip="تاریخ جلسه بانک مرکزی اروپا؛ تعیین‌کننده نرخ بهره یورو و جهت حرکت شاخص DXY (دلار).")
string cal_cpi  = input.string("July 14",  "Next CPI Release",   group=GRP_CAL, tooltip="تاریخ انتشار شاخص قیمت مصرف‌کننده (تورم آمریکا)؛ مبنای تصمیم‌گیری فدرال رزرو برای نرخ بهره.")
string cal_gdp  = input.string("July 30",  "Next GDP Release",   group=GRP_CAL, tooltip="تاریخ انتشار نرخ رشد تولید ناخالص داخلی؛ نشان‌دهنده رکود یا رونق اقتصادی (قدرت بنیادی اقتصاد).")
string cal_unmp = input.string("Aug 07",   "Next Unemp Release", group=GRP_CAL, tooltip="گزارش اشتغال و نرخ بیکاری آمریکا (NFP)؛ کلیدی‌ترین محرک فاندامنتال، معمولاً اولین جمعه هر ماه میلادی.")
string cal_pmi  = input.string("Aug 03",   "Next PMI Release",   group=GRP_CAL, tooltip="شاخص مدیران خرید؛ پیش‌ران و دماسنج وضعیت تولید، صنعت و خدمات پیش از انتشار داده‌های رسمی GDP.")

// ── Trading Signals & Core Engine ─────────────────────────────────────────────
string GRP_TRD  = "📊 Analytics Signals & Strategy"
bool   i_show_signals       = input.bool(true,       "Show Analytics Signals (Shapes)",     group=GRP_TRD)
bool   i_show_bg_regime     = input.bool(true,       "Show Regime Background on Chart",    group=GRP_TRD)
bool   i_show_yc_band       = input.bool(true,       "Show Yield Curve Inversion Band",    group=GRP_TRD)
bool   i_show_oil_shock     = input.bool(true,       "Show Oil Shock Labels",              group=GRP_TRD)
bool   i_show_regime_label  = input.bool(true,       "Show Regime Label on Chart",         group=GRP_TRD)
bool   i_alerts_enabled     = input.bool(true,       "Enable Macro Alerts",                group=GRP_TRD)
string i_risk_profile       = input.string("Moderate","Risk Profile",                      group=GRP_TRD, options=["Conservative","Moderate","Aggressive"])
float  i_xau_bull_th        = input.float(65.0,      "XAU Macro Bull Threshold",           group=GRP_TRD)
float  i_btc_bull_th        = input.float(60.0,      "BTC Macro Bull Threshold",           group=GRP_TRD)

// ── Dashboard UI Customization ────────────────────────────────────────────────
string GRP_UI   = "🖥 Dashboard UI Customization"
string i_pos        = input.string("top_right", "Position",                        group=GRP_UI, options=["top_right","top_left","bottom_right","bottom_left"])
string i_tsz        = input.string("small",     "Text size",                       group=GRP_UI, options=["tiny","small","normal"])
bool   i_show_heat  = input.bool(true,          "Show Asset Outlook Section",      group=GRP_UI)
bool   i_show_alloc = input.bool(true,          "Show Macro Exposure Bias",        group=GRP_UI)
bool   i_show_alert = input.bool(true,          "Show Macro Alerts Log",           group=GRP_UI)
bool   i_show_conf  = input.bool(true,          "Show Analytical Confidence Metrics", group=GRP_UI)
bool   i_show_new   = input.bool(true,          "Show Advanced Macro Indicators",  group=GRP_UI)
bool   i_show_hist  = input.bool(true,          "Show Signal History Log",         group=GRP_UI)
int    i_update_freq= input.int(5,              "Dashboard Update Every N Bars",    minval=1, group=GRP_UI)
bool   i_compact_mode=input.bool(false,         "Enable Compact Mode (Saves Space)",group=GRP_UI)

// ── Macro Thresholds (Advanced) ──────────────────────────────────────────────
string GRP4     = "⚙️ Macro Thresholds (Advanced)"
float  i_cpi_hot        = input.float(3.5,  "CPI Hot threshold",        group=GRP4, step=0.1)
float  i_cpi_cold       = input.float(2.0,  "CPI Cold threshold",       group=GRP4, step=0.1)
float  i_rr_neg         = input.float(-0.5, "Real Rate Neg threshold",  group=GRP4, step=0.1)
float  i_rr_pos         = input.float(2.0,  "Real Rate Pos threshold",  group=GRP4, step=0.1)
float  i_oil_shock_pct  = input.float(5.0,  "Oil Shock % Threshold",    group=GRP4, step=0.5)

// ── Watermark Branding ────────────────────────────────────────────────────────
string GRP_WM   = "🏷 Watermark Branding"
string wm_vpos     = input.string("top",    "Text V-Position", group=GRP_WM, options=["top","middle","bottom"])
bool   wm_show     = input.bool(true,       "Show Brand Text",  group=GRP_WM)
string wm_title    = input.string("I ❤ ₿itcoin", "Title Text", group=GRP_WM)
color  wm_title_c  = input.color(#FF9800,               "Title Color",   group=GRP_WM)
string wm_tsz      = input.string("normal", "Title Size",    group=GRP_WM, options=["small","normal","large","huge","auto"])
string wm_subtitle = input.string("In Crypto We Trust", "Subtitle Text", group=GRP_WM)
color  wm_sub_c    = input.color(color.new(#FF9800, 0),  "Subtitle Color",group=GRP_WM)
string wm_ssz      = input.string("normal", "Subtitle Size", group=GRP_WM, options=["small","normal","large","huge","auto"])

string GRP_SYM  = "🏷 Watermark Custom Ticker"
bool   sym_show  = input.bool(true,    "Show Symbol Text",  group=GRP_SYM)
string sym_vpos  = input.string("bottom","V-Position",      group=GRP_SYM, options=["top","middle","bottom"])
color  sym_clr   = input.color(color.new(#FF9800, 0), "Symbol Color", group=GRP_SYM)
string sym_sz    = input.string("normal","Symbol Size",      group=GRP_SYM, options=["small","normal","large","huge","auto"])


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — DATA FETCHING (FRED) & HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Centralized safe value and request engine to optimize security calls
safe_val(float val, float def) => na(val) ? def : val

f_get(string sym, string tf, float def_val) =>
    float res = request.security(sym, tf, close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off)
    safe_val(res, def_val)

// Core Macro Data Fetching using standardized helper
float cpi_raw      = f_get("FRED:CPIAUCSL", "M", 100.0)
float i_cpi        = ta.change(cpi_raw) != 0 ? (cpi_raw - cpi_raw[12]) / cpi_raw[12] * 100 : 3.2
float i_cpi_prev   = ta.change(cpi_raw) != 0 ? (cpi_raw[1] - cpi_raw[13]) / cpi_raw[13] * 100 : 3.5
float i_rate       = f_get("FRED:FEDFUNDS", "D", 1.0)
float i_rate_ecb   = f_get("FRED:ECBMAINRES", "D", 1.0)
float i_unemp      = f_get("FRED:UNRATE", "M", 3.7)
float i_unemp_prev = safe_val(i_unemp[1], 3.7)
float i_pmi        = ta.rsi(f_get("FRED:MANEMP", "M", 100.0), 14) * 0.5 + 25
float i_pmi_prev   = safe_val(i_pmi[1], 51.5)

float gdp_raw      = request.security("FRED:GDPC1", "3M", close, ignore_invalid_symbol=true)
float gdp_clean    = safe_val(gdp_raw, 26000.0)
float i_gdp        = (gdp_clean - gdp_clean[4]) / gdp_clean[4] * 100
float i_gdp_prev   = (gdp_clean[1] - gdp_clean[5]) / gdp_clean[5] * 100

float m2_raw       = f_get("FRED:M2SL", "M", 100.0)
float i_m2         = (m2_raw - m2_raw[12]) / m2_raw[12] * 100
float i_yield10    = f_get("FRED:DGS10", "D", 1.0)
float i_yield2     = f_get("FRED:DGS2", "D", 1.0)
float i_yield30    = f_get("FRED:DGS30", "D", 1.0)   
float i_yield3m    = f_get("FRED:DGS3MO", "D", 1.0)  

// Risk / Volatility / Commodities
float vix          = f_get("FRED:VIXCLS", "D", 1.0)
float vix_score    = vix > 30 ? -20 : vix < 15 ? 15 : 0
float oil          = f_get("FRED:DCOILWTICO", "D", 1.0)
float tips_break   = f_get("FRED:T10YIE", "D", 1.0)

// Credit Spread Proxy (HY OAS — IG OAS gap)
float hy_spread    = f_get("FRED:BAMLH0A0HYM2", "D", 4.0)   
float ig_spread    = f_get("FRED:BAMLC0A0CM", "D", 1.2)      
float credit_spread = hy_spread - ig_spread

// EM Stress Proxy (EM Sovereign spread)
float em_spread    = f_get("FRED:BAMLEMCBPIOAS", "D", 1.0)

// Data Freshness Engine
bool is_stale = (time("W") == time("W")[1]) and bar_index % 50 == 0


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — REGIME ENGINE & COMPUTED MACRO SCORING
// ═══════════════════════════════════════════════════════════════════════════════

// Real Rate = Nominal Rate - Inflation
// نرخ بهره حقیقی = نرخ اسمی - تورم (یکی از قوی‌ترین درایورهای طلا و اوراق)
float real_rate    = i_rate - i_cpi
float yc_slope     = i_yield10 - i_yield2
float yc_slope_30  = i_yield30 - i_yield2   
float rate_spread  = i_rate - i_rate_ecb

// NOTE: M2 Velocity Proxy — هرچه بالاتر باشد، پول سریع‌تر گردش می‌کند (ریسک‌پذیری بیشتر)
float m2_velocity  = gdp_clean / m2_raw * 100

// Oil Shock detection
float oil_chg_pct  = (oil - oil[5]) / oil[5] * 100
bool oil_shock_up  = oil_chg_pct > i_oil_shock_pct
bool oil_shock_dn  = oil_chg_pct < -i_oil_shock_pct

// Fed Pivot Score — a rule-based composite, not a statistical probability
float fed_pivot_score = 0.0
fed_pivot_score += yc_slope > yc_slope[20] ? 20 : 0       
fed_pivot_score += i_rate > 4.0 ? 20 : 0                  
fed_pivot_score += i_unemp > 4.5 ? 20 : 0                 
fed_pivot_score += i_cpi < 3.0 ? 20 : 0                   
fed_pivot_score += i_gdp < 1.0 ? 20 : 0                   
float fed_pivot_prob = math.min(fed_pivot_score, 99)

// Dollar Milkshake Score
float milkshake = 0.0
milkshake += rate_spread > 2.0 ? 25 : rate_spread > 1.0 ? 15 : 0
milkshake += em_spread > 400 ? 20 : em_spread > 300 ? 10 : 0
milkshake += credit_spread > 5.0 ? 15 : credit_spread > 3.5 ? 8 : 0
milkshake += vix > 25 ? 20 : vix > 20 ? 10 : 0
milkshake += real_rate > 1.5 ? 20 : 0
float milkshake_score = math.min(milkshake, 99)

getTrend(float cur, float prev) => cur > prev * 1.02 ? "UP" : cur < prev * 0.98 ? "DN" : "FL"
string cpi_trend   = getTrend(i_cpi, i_cpi_prev)
string unemp_trend = getTrend(i_unemp, i_unemp_prev)
string pmi_trend   = getTrend(i_pmi, i_pmi_prev)
string gdp_trend   = getTrend(i_gdp, i_gdp_prev)
trendArrow(string t) => t == "UP" ? "▲" : t == "DN" ? "▼" : "▶"

// ── Regime Engine Scoring ─────────────────────────────────────────────────────
// امتیازدهی رشد اقتصادی، تورم، نقدینگی و ریسک رکود برای تشخیص ۵ رژیم اصلی
int growth_score = 0
growth_score += i_gdp > 2.5 ? 2 : i_gdp > 1.0 ? 1 : i_gdp < 0 ? -2 : 0
growth_score += i_pmi > 52 ? 2 : i_pmi > 50 ? 1 : i_pmi < 48 ? -2 : 0
growth_score += i_unemp < 4.0 ? 1 : i_unemp > 5.5 ? -2 : 0
growth_score += gdp_trend == "UP" ? 1 : gdp_trend == "DN" ? -1 : 0

int infl_score = 0
infl_score += i_cpi > i_cpi_hot ? 3 : i_cpi > 2.5 ? 1 : i_cpi < i_cpi_cold ? -2 : 0
infl_score += cpi_trend == "UP" ? 1 : cpi_trend == "DN" ? -1 : 0

float liq_score = 0.0
liq_score += i_m2 > 4 ? 2 : i_m2 > 1 ? 1 : i_m2 < -1 ? -2 : 0
liq_score += i_rate < 2 ? 2 : i_rate > 5 ? -1 : 0
liq_score += yc_slope < -0.5 ? -2 : yc_slope > 0.5 ? 1 : 0
liq_score += vix_score / 10

bool is_expansion   = growth_score >= 4 and infl_score < 3
bool is_stagflation = infl_score >= 3 and growth_score <= 1
bool is_recession   = growth_score <= -3
bool is_recovery    = growth_score >= 2 and infl_score < 1

string regime_name = is_recession ? "RECESSION" : is_stagflation ? "STAGFLATION" : is_expansion ? "EXPANSION" : is_recovery ? "RECOVERY" : "SLOWDOWN"
color  regime_clr  = is_recession ? color.rgb(255,23,68) : is_stagflation ? color.rgb(255,109,0) : is_expansion ? color.rgb(0,200,83) : is_recovery ? color.rgb(105,240,174) : color.rgb(244,180,0)

// Regime Duration Counter
var int regime_bar_count = 0
var string tracked_regime = ""
if regime_name != tracked_regime
    regime_bar_count := 0
    tracked_regime   := regime_name
else
    regime_bar_count := regime_bar_count + 1

// نمایش مدت زمان ماندگاری رژیم به صورت کاملاً خوانا
string regime_duration = regime_bar_count < 20 ? str.tostring(regime_bar_count) + " bars" : regime_bar_count < 100 ? "≈ " + str.tostring(math.round(regime_bar_count/20.0), "#") + " weeks" : "Long-term"

// Recession Risk Score Calculation — rule-based composite, not a statistical forecast
float rec_prob = 0.0
rec_prob += yc_slope < -0.5 ? 25 : yc_slope < 0 ? 12 : 0
rec_prob += i_unemp > i_unemp_prev * 1.05 ? 20 : 0
rec_prob += i_pmi < 48 ? 20 : i_pmi < 50 ? 10 : 0
rec_prob += i_gdp < 0 ? 25 : i_gdp < 1 ? 10 : 0
rec_prob += real_rate > 2.5 ? 10 : 0
rec_prob += credit_spread > 5.0 ? 10 : 0  
rec_prob  := math.min(rec_prob, 99)
string rec_lvl = rec_prob > 60 ? "HIGH" : rec_prob > 35 ? "ELEV" : "LOW"
color  rec_clr = rec_prob > 60 ? color.rgb(255,90,95) : rec_prob > 35 ? color.rgb(244,180,0) : color.rgb(0,200,83)

// Risk On/Off Matrix
int risk_score = 0
risk_score += growth_score > 3 ? 2 : growth_score < 0 ? -2 : 0
risk_score += liq_score > 2 ? 2 : liq_score < -1 ? -2 : 0
risk_score += rec_prob < 25 ? 1 : rec_prob > 50 ? -2 : 0
risk_score += yc_slope > 0.3 ? 1 : yc_slope < -0.3 ? -1 : 0
risk_score += credit_spread > 5.0 ? -1 : 0  
bool   is_risk_on  = risk_score >= 2
bool   is_risk_off = risk_score <= -2
string risk_lbl    = is_risk_on ? "RISK ON" : is_risk_off ? "RISK OFF" : "NEUTRAL"
color  risk_clr    = is_risk_on ? color.rgb(0,200,83) : is_risk_off ? color.rgb(255,90,95) : color.rgb(244,180,0)

// Macro Health Composite (0-100)
float macro_health = 50.0
macro_health += growth_score * 5
macro_health += infl_score   < 2 ? 5 : infl_score > 3 ? -10 : 0
macro_health += liq_score    > 1 ? 8 : liq_score < -1 ? -8 : 0
macro_health += rec_prob < 20 ? 10 : rec_prob > 60 ? -15 : 0
macro_health += yc_slope > 0 ? 5 : -5

macro_health := math.max(5, math.min(95, macro_health))
int macro_health_i = int(math.round(macro_health))


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — ADAPTIVE ASSET SCORING
// ═══════════════════════════════════════════════════════════════════════════════
float wt_rate   = is_recession ? 2.0 : is_expansion ? 1.5 : 1.0
float wt_infl   = is_stagflation ? 2.0 : is_expansion ? 1.5 : 1.0
float wt_liq    = is_recession ? 2.5 : is_recovery ? 2.0 : 1.0
float wt_growth = is_expansion ? 1.5 : is_recession ? 2.0 : 1.0

// ۱. امتیاز طلا (XAU) - طلا با کاهش نرخ بهره حقیقی و افزایش تورم/رکود صعودی می‌شود.
float xau_raw = 50.0
xau_raw += (real_rate < i_rr_neg ? 20 : real_rate > i_rr_pos ? -20 : -real_rate * 5) * wt_rate
xau_raw += (i_cpi > i_cpi_hot ? 10 : i_cpi < i_cpi_cold ? -8 : 0) * wt_infl
xau_raw += is_recession ? 15 : is_stagflation ? 12 : is_expansion ? -8 : 0
xau_raw += (liq_score > 2 ? 8 : liq_score < -1 ? -5 : 0) * wt_liq
xau_raw += cpi_trend == "UP" ? 4 : cpi_trend == "DN" ? -4 : 0
xau_raw += tips_break > 2.5 ? 8 : 0
xau_raw += milkshake_score > 60 ? -5 : 0  
int xau_score = int(math.max(5, math.min(95, math.round(xau_raw))))

// ۲. امتیاز بیت‌کوین (BTC) - دارایی حساس به نقدینگی جهانی (M2) و شرایط ریسک‌پذیری (Risk-On).
float btc_raw = 50.0
btc_raw += (liq_score > 2 ? 18 : liq_score < -1 ? -18 : liq_score * 5) * wt_liq
btc_raw += (real_rate < 0 ? 10 : real_rate > 2 ? -12 : 0) * wt_rate
btc_raw += is_risk_on ? 12 : is_risk_off ? -12 : 0
btc_raw += (growth_score > 3 ? 8 : growth_score < 0 ? -8 : 0) * wt_growth
btc_raw += rate_spread > 1 ? -5 : rate_spread < 0 ? 5 : 0
btc_raw += vix_score
btc_raw += fed_pivot_prob > 60 ? 10 : 0  
int btc_score = int(math.max(5, math.min(95, math.round(btc_raw))))

// ۳. امتیاز شاخص دلار (DXY) - تقویت با اختلاف نرخ بهره مثبت آمریکا و بحران نقدینگی (Risk-Off).
float dxy_raw = 50.0
dxy_raw += rate_spread > 1.5 ? 20 : rate_spread < 0 ? -15 : rate_spread * 8
dxy_raw += real_rate > i_rr_pos ? 12 : real_rate < i_rr_neg ? -12 : real_rate * 4
dxy_raw += growth_score > 3 ? 8 : growth_score < -2 ? -8 : 0
dxy_raw += is_risk_off ? 10 : is_risk_on ? -5 : 0
dxy_raw += liq_score < -1 ? 5 : liq_score > 2 ? -5 : 0
dxy_raw += milkshake_score > 60 ? 12 : 0  
int dxy_score = int(math.max(5, math.min(95, math.round(dxy_raw))))

// ۴. امتیاز شاخص سهام (SPX)
float spx_raw = 50.0
spx_raw += (growth_score > 3 ? 18 : growth_score < 0 ? -18 : growth_score * 4) * wt_growth
spx_raw += (liq_score > 2 ? 12 : liq_score < -1 ? -12 : 0) * wt_liq
spx_raw += real_rate < 0 ? 8 : real_rate > 3 ? -10 : 0
spx_raw += is_recession ? -20 : is_stagflation ? -10 : is_expansion ? 10 : 0
spx_raw += yc_slope > 0.5 ? 5 : yc_slope < -0.5 ? -8 : 0
spx_raw += credit_spread > 5.0 ? -8 : credit_spread < 2.5 ? 5 : 0  
int spx_score = int(math.max(5, math.min(95, math.round(spx_raw))))

// ۵. امتیاز اوراق قرضه (TLT)
float tlt_raw = 50.0
tlt_raw += is_recession ? 25 : is_expansion ? -10 : 0
tlt_raw += fed_pivot_prob > 60 ? 20 : fed_pivot_prob > 40 ? 10 : 0
tlt_raw += real_rate > 2.0 ? 15 : real_rate < 0 ? -10 : 0
tlt_raw += yc_slope_30 > 1.0 ? -5 : yc_slope_30 < 0 ? 10 : 0
int tlt_score = int(math.max(5, math.min(95, math.round(tlt_raw))))

// ── Macro Exposure Bias (informational — not investment advice) ───────────────
string gold_alloc   = xau_score >= i_xau_bull_th ? "Strong Bias"     : xau_score > 45 ? "Moderate Bias" : "Light Bias"
string btc_alloc    = btc_score >= i_btc_bull_th ? "Strong Bias"     : btc_score < 35 ? "Weak Bias"     : "Neutral Bias"
string equity_alloc = spx_score > 60             ? "Above Benchmark" : spx_score < 40 ? "Below Benchmark" : "At Benchmark"
string bond_alloc   = tlt_score > 60             ? "Above Benchmark" : tlt_score < 35 ? "Below Benchmark" : "Neutral"  
string stop_distance = is_recession or is_stagflation ? "Tight Stop-Loss Needed" : is_expansion ? "Wider Trailing Stops OK" : "Standard Risk Rules"

// ── Confidence Score ──────────────────────────────────────────────────────────
int conf_pts = 0
conf_pts += math.abs(real_rate) > 1 ? 1 : 0
conf_pts += math.abs(yc_slope) > 0.3 ? 1 : 0
conf_pts += i_pmi != 50 ? 1 : 0
conf_pts += gdp_trend != "FL" ? 1 : 0
conf_pts += cpi_trend != "FL" ? 1 : 0
conf_pts += math.abs(growth_score) > 2 ? 1 : 0
conf_pts += not is_stale ? 1 : 0
int   confidence = math.round(conf_pts / 7.0 * 100)
color conf_clr   = confidence > 70 ? color.rgb(0,200,83) : confidence > 40 ? color.rgb(244,180,0) : color.rgb(255,90,95)


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — VISUAL ENGINE & SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════
bool gold_bullish_signal  = (xau_score >= i_xau_bull_th) and (real_rate < 0)
bool btc_bullish_signal   = (btc_score >= i_btc_bull_th) and is_risk_on
bool dxy_flight_to_safety = (dxy_score > 65) and (is_risk_off or is_recession)
bool yc_inversion_signal  = yc_slope < -0.5 and yc_slope[1] >= -0.5   
bool fed_pivot_signal     = fed_pivot_prob > 70 and fed_pivot_prob[1] <= 70  

// ── Chart Visual Layers ───────────────────────────────────────────────────────
bgcolor(i_show_bg_regime ? color.new(regime_clr, 94) : na, title="Macro Regime Background")
bgcolor(i_show_yc_band and yc_slope < 0 ? color.new(color.rgb(255,23,68), 90) : na, title="YC Inversion Band")

// Regime Change Labels
var string last_regime = na
if regime_name != last_regime and barstate.isconfirmed
    if i_show_regime_label
        label.new(bar_index, high, "↺ Regime Shift\n" + regime_name, color=regime_clr, textcolor=color.white, style=label.style_label_down, size=size.normal)
    last_regime := regime_name

// Oil Shock Labels
if i_show_oil_shock and oil_shock_up and not oil_shock_up[1]
    label.new(bar_index, high, "🛢 OIL SHOCK\n+" + str.tostring(oil_chg_pct, "#.#") + "%", color=color.rgb(255,109,0), textcolor=color.white, style=label.style_label_down, size=size.small)
if i_show_oil_shock and oil_shock_dn and not oil_shock_dn[1]
    label.new(bar_index, low, "🛢 OIL CRASH\n" + str.tostring(oil_chg_pct, "#.#") + "%", color=color.rgb(66,165,245), textcolor=color.white, style=label.style_label_up, size=size.small)

// Signal Shapes
plotshape(i_show_signals and gold_bullish_signal and not gold_bullish_signal[1], title="Gold Macro Bullish", style=shape.triangleup, location=location.belowbar, color=color.rgb(255,215,0), size=size.tiny, text="MACRO XAU+")
plotshape(i_show_signals and btc_bullish_signal and not btc_bullish_signal[1], title="BTC Risk-On", style=shape.triangleup, location=location.belowbar, color=color.rgb(247,147,26), size=size.tiny, text="MACRO BTC+")
plotshape(i_show_signals and dxy_flight_to_safety and not dxy_flight_to_safety[1], title="DXY Flight to Safety", style=shape.triangledown, location=location.abovebar, color=color.rgb(255,90,95), size=size.tiny, text="FLIGHT TO CASH")
plotshape(i_show_signals and yc_inversion_signal, title="YC Inversion Alert", style=shape.xcross, location=location.abovebar, color=color.rgb(255,23,68), size=size.tiny, text="YC INV")
plotshape(i_show_signals and fed_pivot_signal, title="Fed Pivot Signal", style=shape.circle, location=location.belowbar, color=color.rgb(105,240,174), size=size.tiny, text="PIVOT?")

// ── Macro Alerts System ────────────────────────────────────────────────────────
if i_alerts_enabled and barstate.islast
    if regime_name == "RECESSION" and regime_name != regime_name[1]
        alert("⚠️ Recession Regime Detected. This is a rule-based estimate, not a forecast guarantee.", alert.freq_once_per_bar_close)
    if btc_bullish_signal and not btc_bullish_signal[1]
        alert("🚀 Macro Bitcoin Bull Signal Triggered. Liquidity conditions are currently favorable per the model.", alert.freq_once_per_bar_close)
    if gold_bullish_signal and not gold_bullish_signal[1]
        alert("👑 Macro Gold Bull Signal Triggered. Safe-haven conditions favored per the model.", alert.freq_once_per_bar_close)


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — SIGNAL HISTORY LOG
// ═══════════════════════════════════════════════════════════════════════════════
var string sig1 = "—"
var string sig2 = "—"
var string sig3 = "—"

if gold_bullish_signal and not gold_bullish_signal[1]
    sig3 := sig2
    sig2 := sig1
    sig1 := "XAU BULL @ bar " + str.tostring(bar_index)
if btc_bullish_signal and not btc_bullish_signal[1]
    sig3 := sig2
    sig2 := sig1
    sig1 := "BTC BULL @ bar " + str.tostring(bar_index)


// ══════════════════════════════════════════════════════════════════════════
// SECTION 7 — COLOR PALETTE & HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════
color C_BG0  = color.new(#05080f, 5)
color C_BG1  = color.new(#0b1120, 5)
color C_BG2  = color.new(#0d1830, 5)
color C_HDR  = color.new(#071428, 3)
color C_ACC  = color.new(#00c2a8, 0)
color C_WHT  = color.new(#e0e6f0, 0)
color C_GRY  = color.new(#4a6278, 0)
color C_GRN  = color.new(#00c853, 0)
color C_RED  = color.new(#ff5a5f, 0)
color C_YLW  = color.new(#f4b400, 0)
color C_GOLD = color.rgb(255,215,0)
color C_BTC  = color.rgb(247,147,26)
color C_BLU  = color.rgb(66,165,245)
color C_SPX  = color.rgb(171,71,188)
color C_TLT  = color.rgb(38,198,218)  
color C_BG   = color.new(color.blue, 100)

scoreClr(int s)           => s >= 65 ? C_GRN : s >= 40 ? C_YLW : C_RED
allocClr(string a)        => a == "Strong Bias" or a == "Above Benchmark" ? C_GRN : a == "Weak Bias" or a == "Below Benchmark" ? C_RED : C_YLW
valClr3(float v, float lo, float hi) => v >= hi ? C_GRN : v <= lo ? C_RED : C_YLW
rrClr(float r)            => r < i_rr_neg ? C_GRN : r > i_rr_pos ? C_RED : C_YLW
trendClr(string t)        => t == "UP" or t == "Bullish" ? C_GRN : t == "DN" or t == "Bearish" ? C_RED : C_GRY

getPos() => i_pos == "top_right" ? position.top_right : i_pos == "top_left" ? position.top_left : i_pos == "bottom_right" ? position.bottom_right : position.bottom_left
getTsz() => i_tsz == "tiny" ? size.tiny : i_tsz == "normal" ? size.normal : size.small

getWmPos()  => wm_vpos == "top" ? position.top_center : wm_vpos == "middle" ? position.middle_center : position.bottom_center
getSymPos() => sym_vpos == "top" ? position.top_center : sym_vpos == "middle" ? position.middle_center : position.bottom_center

cell(table tbl, int col, int row, string ts, color tc, color bg, string sz) => table.cell(tbl, col, row, ts, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center, text_valign=text.align_center)
wide(table tbl, int row, string txt, color tc, color bg, string sz) => table.cell(tbl, 0, row, txt, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center, text_valign=text.align_center), table.merge_cells(tbl, 0, row, 3, row)
halfL(table tbl, int row, string txt, color tc, color bg, string sz) => table.cell(tbl, 0, row, txt, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center, text_valign=text.align_center), table.merge_cells(tbl, 0, row, 1, row)
halfR(table tbl, int row, string txt, color tc, color bg, string sz) => table.cell(tbl, 2, row, txt, text_color=tc, bgcolor=bg, text_size=sz, text_halign=text.align_center, text_valign=text.align_center), table.merge_cells(tbl, 2, row, 3, row)

progressBar(int score) =>
    int    n      = math.min(math.max(int(score / 12.5), 0), 8)
    string filled = ""
    string empty  = ""
    if n > 0
        for i = 1 to n
            filled := filled + "█"
    if n < 8
        for i = n + 1 to 8
            empty := empty + "░"
    filled + empty

string oil_trend = ta.rising(oil, 5) ? "Bullish" : ta.falling(oil, 5) ? "Bearish" : "Neutral"

// ══════════════════════════════════════════════════════════════════════════
// SECTION 8 — MAIN DASHBOARD TABLE (WITH OPTIMIZED ASSET OUTLOOK)
// ══════════════════════════════════════════════════════════════════════════
var table tbl = na

if barstate.islast
    if not na(tbl)
        table.delete(tbl)

    tbl := table.new(getPos(), 4, 50, border_width=1, border_color=color.new(#1e3a5f, 60), frame_width=2, frame_color=color.new(#00c2a8, 20))
    string tsz = getTsz()

    // ── Header ───────────────────────────────────────────────────────────
    wide(tbl, 0, "⚡ KURDISTANI MACRO REGIME", C_ACC, C_HDR, tsz)
    wide(tbl, 1, "CURRENT MACRO CONDITIONS", C_WHT, C_BG2, tsz)

    // ── Row: CPI ─────────────────────────────────────────────────────────
    cell(tbl, 0, 2, "CPI (Inflation)",    C_GRY, C_BG1, tsz)
    cell(tbl, 1, 2, str.tostring(i_cpi, "#.##") + "%", valClr3(i_cpi, i_cpi_cold, i_cpi_hot), C_BG1, tsz)
    cell(tbl, 2, 2, trendArrow(cpi_trend), trendClr(cpi_trend), C_BG1, tsz)
    cell(tbl, 3, 2, cal_cpi, C_WHT, C_BG1, tsz)

    // ── Row: Real Rate / Fed Rate ─────────────────────────────────────────
    cell(tbl, 0, 3, "Real Rate",  C_GRY, C_BG2, tsz)
    cell(tbl, 1, 3, str.tostring(real_rate, "#.##") + "%", rrClr(real_rate), C_BG2, tsz)
    cell(tbl, 2, 3, "Fed Rate",   C_GRY, C_BG2, tsz)
    cell(tbl, 3, 3, str.tostring(i_rate, "#.##") + "%", C_WHT, C_BG2, tsz)

    // ── Row: VIX / FOMC ───────────────────────────────────────────────────
    cell(tbl, 0, 4, "VIX (Fear)", C_GRY, C_BG1, tsz)
    cell(tbl, 1, 4, str.tostring(vix, "#.#"), vix > 25 ? C_RED : C_GRN, C_BG1, tsz)
    cell(tbl, 2, 4, "Next FOMC",  C_GRY, C_BG1, tsz)
    cell(tbl, 3, 4, cal_fed, C_WHT, C_BG1, tsz)

    // ── Row: Unemployment ────────────────────────────────────────────────
    cell(tbl, 0, 5, "Unemployment", C_GRY, C_BG2, tsz)
    cell(tbl, 1, 5, str.tostring(i_unemp, "#.##") + "%", i_unemp > 5 ? C_RED : C_GRN, C_BG2, tsz)
    cell(tbl, 2, 5, trendArrow(unemp_trend), trendClr(unemp_trend), C_BG2, tsz)
    cell(tbl, 3, 5, cal_unmp, C_WHT, C_BG2, tsz)

    // ── Row: Oil Trend / TIPS ────────────────────────────────────────────
    cell(tbl, 0, 6, "Crude Oil",   C_GRY, C_BG1, tsz)
    cell(tbl, 1, 6, oil_trend,    trendClr(oil_trend), C_BG1, tsz)
    cell(tbl, 2, 6, "TIPS Break", C_GRY, C_BG1, tsz)
    cell(tbl, 3, 6, str.tostring(tips_break, "#.##") + "%", C_WHT, C_BG1, tsz)

    // ── Row: PMI / GDP ───────────────────────────────────────────────────
    cell(tbl, 0, 7, "ISM PMI",    C_GRY, C_BG2, tsz)
    cell(tbl, 1, 7, str.tostring(i_pmi, "#.#"), i_pmi < 50 ? C_RED : C_GRN, C_BG2, tsz)
    cell(tbl, 2, 7, "US GDP YoY", C_GRY, C_BG2, tsz)
    cell(tbl, 3, 7, str.tostring(i_gdp, "#.##") + "%", i_gdp < 0 ? C_RED : C_GRN, C_BG2, tsz)

    // ── Row: Yield Curve ────────────────────────────────────────────
    cell(tbl, 0, 8, "2Y-10Y Curve", C_GRY, C_BG1, tsz)
    cell(tbl, 1, 8, str.tostring(yc_slope, "#.##") + "%", yc_slope < 0 ? C_RED : C_GRN, C_BG1, tsz)
    cell(tbl, 2, 8, "2Y-30Y",       C_GRY, C_BG1, tsz)
    cell(tbl, 3, 8, str.tostring(yc_slope_30, "#.##") + "%", yc_slope_30 < 0 ? C_RED : C_GRN, C_BG1, tsz)

    // ── Row: ECB vs Fed Spread ──────────────────────────────────────
    cell(tbl, 0, 9, "ECB Rate", C_GRY, C_BG2, tsz)
    cell(tbl, 1, 9, str.tostring(i_rate_ecb, "#.##") + "%", C_WHT, C_BG2, tsz)
    cell(tbl, 2, 9, "USD-EUR Spread", C_GRY, C_BG2, tsz)
    cell(tbl, 3, 9, str.tostring(rate_spread, "#.##") + "%", rate_spread > 1.5 ? C_GRN : rate_spread < 0 ? C_RED : C_YLW, C_BG2, tsz)

    // ── Regime Block ───────────────────────────────────────────────────────
    wide(tbl, 10, "CURRENT MACRO REGIME", C_WHT, C_BG2, tsz)
    wide(tbl, 11, regime_name + "  ·  " + risk_lbl, regime_clr, C_BG0, tsz)
    halfL(tbl, 12, "Recession Risk:", C_GRY, C_BG1, tsz)
    halfR(tbl, 12, str.tostring(math.round(rec_prob)) + "% [" + rec_lvl + "]", rec_clr, C_BG1, tsz)
    halfL(tbl, 13, "Regime Duration:", C_GRY, C_BG2, tsz)
    halfR(tbl, 13, str.tostring(regime_bar_count) + " bars", C_WHT, C_BG2, tsz)
    halfL(tbl, 14, "Risk Management:", C_GRY, C_BG1, tsz)
    halfR(tbl, 14, stop_distance, is_risk_off ? C_RED : C_GRN, C_BG1, tsz)

    int currentRow = 15

    // ── Advanced Macro Indicators Block ─────────────────────────────────────
    if i_show_new
        wide(tbl, currentRow, "ADVANCED MACRO INDICATORS", C_WHT, C_BG2, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "Macro Health Score:", C_GRY, C_BG1, tsz)
        halfR(tbl, currentRow, str.tostring(macro_health_i) + "/100 " + progressBar(macro_health_i), scoreClr(macro_health_i), C_BG1, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "Fed Pivot Score:", C_GRY, C_BG2, tsz)
        halfR(tbl, currentRow, str.tostring(int(fed_pivot_prob)) + "%", fed_pivot_prob > 60 ? C_GRN : fed_pivot_prob > 40 ? C_YLW : C_RED, C_BG2, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "$ Milkshake Score:", C_GRY, C_BG1, tsz)
        halfR(tbl, currentRow, str.tostring(int(milkshake_score)) + "/99", milkshake_score > 60 ? C_RED : milkshake_score > 40 ? C_YLW : C_GRN, C_BG1, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "Credit Spread (HY-IG):", C_GRY, C_BG2, tsz)
        halfR(tbl, currentRow, str.tostring(credit_spread, "#.##") + "%", credit_spread > 5.0 ? C_RED : credit_spread > 3.5 ? C_YLW : C_GRN, C_BG2, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "M2 Velocity:", C_GRY, C_BG1, tsz)
        halfR(tbl, currentRow, str.tostring(m2_velocity, "#.##"), m2_velocity < 1.2 ? C_RED : C_GRN, C_BG1, tsz)
        currentRow := currentRow + 1

        halfL(tbl, currentRow, "Oil Shock:", C_GRY, C_BG2, tsz)
        halfR(tbl, currentRow, oil_shock_up ? "▲ SPIKE +" + str.tostring(oil_chg_pct,"#.#") + "%" : oil_shock_dn ? "▼ CRASH " + str.tostring(oil_chg_pct,"#.#") + "%" : "None", oil_shock_up ? C_RED : oil_shock_dn ? C_BLU : C_GRY, C_BG2, tsz)
        currentRow := currentRow + 1

    // ── Asset Outlook ─────────────────────────────────────────
    if i_show_heat
        wide(tbl, currentRow, "ASSET QUANT OUTLOOK  (0=Bear | 100=Bull)", C_WHT, C_BG2, tsz)
        currentRow := currentRow + 1

        cell(tbl, 0, currentRow, "XAU", C_GOLD, C_BG1, tsz)
        cell(tbl, 1, currentRow, progressBar(xau_score), scoreClr(xau_score), C_BG1, tsz)
        table.merge_cells(tbl, 1, currentRow, 2, currentRow)
        cell(tbl, 3, currentRow, str.tostring(xau_score), scoreClr(xau_score), C_BG1, tsz)
        currentRow := currentRow + 1

        cell(tbl, 0, currentRow, "BTC", C_BTC, C_BG2, tsz)
        cell(tbl, 1, currentRow, progressBar(btc_score), scoreClr(btc_score), C_BG2, tsz)
        table.merge_cells(tbl, 1, currentRow, 2, currentRow)
        cell(tbl, 3, currentRow, str.tostring(btc_score), scoreClr(btc_score), C_BG2, tsz)
        currentRow := currentRow + 1

        cell(tbl, 0, currentRow, "DXY", C_BLU, C_BG1, tsz)
        cell(tbl, 1, currentRow, progressBar(dxy_score), scoreClr(dxy_score), C_BG1, tsz)
        table.merge_cells(tbl, 1, currentRow, 2, currentRow)
        cell(tbl, 3, currentRow, str.tostring(dxy_score), scoreClr(dxy_score), C_BG1, tsz)
        currentRow := currentRow + 1

// ═══════════════════════════════════════════════════════════════════════════════
// NOTE FOR THE AUTHOR:
// The original script you pasted was cut off at this exact point (mid dashboard
// table, before the SPX/TLT rows, the Macro Exposure Bias block, Macro Alerts
// Log block, Confidence block, Signal History block, watermark plotchar/table
// calls, and any closing logic). Everything above this line has been updated
// with the corrected calendar defaults and the safer terminology. If you paste
// the remainder of the script, I will apply the same terminology/date fixes to
// it and return the complete file.
// ═══════════════════════════════════════════════════════════════════════════════
````
