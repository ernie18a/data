# Trading Session Analyzer [AlgoChief]

- url: https://www.tradingview.com/script/IOOZe3fP-Trading-Session-Analyzer-AlgoChief/
- type: indicator
- pine_id: PUB;0d4c16d32a8845759c34afe9f5230943
- version: 1.0

## Description

Trading Session Analyzer [AlgoChief]

Professional Multi-Factor Session Strength Analysis

Trading Session Analyzer is a powerful market analysis tool designed to evaluate the historical strength of the three major trading sessions using multiple market factors. Instead of generating direct Buy or Sell signals, this indicator helps traders identify which session has historically offered the strongest trading conditions.

The indicator analyzes recent market activity over a customizable lookback period and calculates a comprehensive strength score for each major trading session based on volatility, relative volume, momentum, trend consistency, and price action quality.

The analyzed sessions include:

• Asian Session

• European Session

• American Session

Each session is evaluated independently, allowing traders to compare market behavior and identify the session that has historically demonstrated the strongest overall performance.

---

# Features

✅ Multi-Factor Session Analysis

✅ Historical Session Strength Scoring

✅ Volatility Analysis

✅ Relative Volume Analysis

✅ Momentum Analysis

✅ Trend Consistency Evaluation

✅ Price Action Quality Analysis

✅ Automatic Best Session Detection

✅ Detailed Dashboard

✅ Session Score Comparison

✅ Customizable Lookback Period

✅ Optional Analysis Components

✅ Alert Conditions

---

# What Does This Indicator Measure?

This indicator combines several important market characteristics into a single session strength score.

### Volatility

Measures the average price movement during each session.

Higher volatility often indicates greater trading opportunities.

---

### Relative Volume

Compares session volume against the average volume across the selected analysis period.

Higher participation generally results in a stronger score.

---

### Momentum

Measures historical directional movement during each trading session.

Sessions showing stronger momentum receive higher ratings.

---

### Trend Consistency

Evaluates how consistently price moved in one direction throughout the session.

Cleaner trends contribute positively to the overall score.

---

### Price Action

Measures candle body size relative to total candle range.

Sessions with stronger directional candles receive higher scores.

---

# Dashboard Information

The dashboard displays:

• Session Strength Score

• Average Volatility

• Average Volume

• Momentum

• Trend Score

• Best Performing Session

• Overall Session Rating

All calculations update automatically using the selected lookback period.

---

# Rating System

The indicator classifies the strongest session into one of four categories:

🟢 Excellent

🔵 Good

🟠 Moderate

🔴 Poor

The rating is based on recent historical performance rather than fixed thresholds, allowing it to adapt naturally to changing market conditions.

---

# How To Use

### Step 1

Add the indicator to your chart.

---

### Step 2

Choose the number of historical days you want to analyze.

A larger value provides smoother long-term analysis.

A smaller value reacts more quickly to recent market changes.

---

### Step 3

Enable or disable individual analysis modules according to your preference.

• Volatility

• Volume

• Momentum

• Trend

• Price Action

---

### Step 4

Watch the dashboard.

The session with the highest score represents the strongest historical market conditions.

---

# How To Trade Using This Indicator

This indicator is designed as a market analysis tool and should be used together with your existing trading strategy.

A simple workflow:

① Identify the highest-scoring trading session.

② Wait for that session to begin.

③ Confirm market direction using your preferred strategy such as:

• Market Structure

• Support & Resistance

• Breakout

• Trend Following

• Price Action

• Moving Averages

• Supply & Demand

• Smart Money Concepts (SMC)

• ICT Concepts

④ Enter a trade only when your own setup aligns with the strongest trading session.

⑤ Always use proper Stop Loss and Risk Management.

The indicator helps traders focus on periods where historical market conditions have been stronger, but it does not guarantee profitable trades.

---

# Best Use Cases

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Indices

• Crypto

• Commodities

• Intraday Trading

• Day Trading

• Scalping

• Swing Trading

---

# Recommended Timeframes

Works on all TradingView supported timeframes including:

• 1 Minute

• 3 Minutes

• 5 Minutes

• 15 Minutes

• 30 Minutes

• 1 Hour

• 4 Hours

• Daily

---

# Alerts

The script includes alert conditions for:

• Excellent Session Detection

• Session Score Crossing Important Levels

These alerts highlight strong session conditions and should be combined with your own trading confirmation before entering any position.

---

# Settings

**Days to Analyze**

Controls how many historical trading days are included in the calculations.

**Volatility Analysis**

Include or exclude volatility from the final score.

**Volume Analysis**

Enable or disable relative volume analysis.

**Momentum Analysis**

Enable or disable momentum calculations.

**Trend Analysis**

Include trend consistency in the overall score.

**Price Action Analysis**

Include candle body quality in the final session rating.

**Dashboard**

Show or hide the information dashboard.

**Score Bars**

Display or hide session score lines.

**Dashboard Position**

Choose where the dashboard appears on the chart.

---

# Important Notes

• This indicator is an analytical tool and does not generate direct Buy or Sell signals.

• It evaluates historical market behavior and should be used alongside your own trading strategy.

• Session times are based on your chart's timezone settings and may vary depending on the selected timezone.

• Historical performance does not guarantee future results.

• Always use proper risk management before entering any trade.

## Source Code

````pine
//@version=6
indicator("Trading Session Analyzer [AlgoChief]", overlay=false)

// INPUTS
analysis_days    = input.int(30,   "Days to Analyze", minval=5, maxval=100, group="Settings")
use_volatility   = input.bool(true, "Volatility Analysis",  group="Settings")
use_volume       = input.bool(true, "Volume Analysis",      group="Settings")
use_momentum     = input.bool(true, "Momentum Analysis",    group="Settings")
use_trend        = input.bool(true, "Trend Analysis",       group="Settings")
use_price_action = input.bool(true, "Price Action",         group="Settings")
show_dashboard   = input.bool(true, "Show Dashboard",       group="Display")
show_bars        = input.bool(true, "Show Score Bars",      group="Display")
dash_pos         = input.string("top_right", "Position", options=["top_left","top_right","bottom_left","bottom_right"], group="Display")

// SESSION DETECTION
get_sess(t) =>
    mins = hour(t) * 60 + minute(t)
    result = 0
    if mins >= 390 and mins < 930
        result := 1
    else if mins >= 810 and mins < 1380
        result := 2
    else if mins >= 1230 or mins < 300
        result := 3
    result

// METRICS
calc(sid, overall_avg_vol) =>
    vl_s = 0.0
    vl_n = 0
    vm_s = 0.0
    vm_n = 0
    mo_arr = array.new_float(0)
    tr_s = 0.0
    tr_n = 0
    pa_s = 0.0
    pa_n = 0

    for i = 1 to analysis_days
        if get_sess(time[i]) == sid
            pc = nz(close[i + 1], close[i])
            if use_volatility
                tv = math.max(high[i] - low[i], math.max(math.abs(high[i] - pc), math.abs(low[i] - pc)))
                if close[i] > 0
                    vl_s += tv / close[i] * 100
                    vl_n += 1
            if use_volume
                vm_s += nz(volume[i])
                vm_n += 1
            if use_momentum
                array.push(mo_arr, close[i])
            if use_trend
                if close[i] > pc
                    tr_s += 1.0
                else if close[i] < pc
                    tr_s -= 1.0
                tr_n += 1
            if use_price_action
                rng = high[i] - low[i]
                bdy = math.abs(close[i] - open[i])
                if rng > 0
                    pa_s += bdy / rng * 100
                    pa_n += 1

    avg_vl = vl_n > 0 ? vl_s / vl_n : 0.0
    avg_vm = vm_n > 0 ? vm_s / vm_n : 0.0
    sz     = array.size(mo_arr)
    ref_mo = sz >= 2 ? array.get(mo_arr, math.min(10, sz - 1)) : 0.0
    avg_mo = sz >= 2 and ref_mo != 0.0 ? (array.get(mo_arr, 0) - ref_mo) / math.abs(ref_mo) * 100 : 0.0
    avg_tr = tr_n > 0 ? tr_s / tr_n : 0.0
    avg_pa = pa_n > 0 ? pa_s / pa_n : 0.0

    // s1: Volatility - typical session true-range% rarely exceeds 2-3%, so scale to 3.0 instead of 5.0 for better spread
    s1 = use_volatility   ? math.min(avg_vl, 3.0) / 3.0 * 25.0 : 0.0

    // s2: Volume - relative to OVERALL average volume across all sessions, not a flat "volume > 0" check.
    //     vol_ratio of 1.0 = average, 1.5+ = strong, 0.5 = weak. Scaled 0-150% of overall avg maps to 0-20 pts.
    vol_ratio = overall_avg_vol > 0.0 ? avg_vm / overall_avg_vol : 1.0
    s2 = use_volume       ? math.min(math.max(vol_ratio / 1.5, 0.0), 1.0) * 20.0 : 0.0

    // s3: Momentum - realistic session momentum is usually within +-5%, not +-50%. Tightened range so normal moves use full 0-25 spread.
    s3 = use_momentum     ? math.min(math.max((avg_mo + 5.0) / 10.0 * 25.0, 0.0), 25.0) : 0.0

    // s4: Trend - amplify consistency using a power curve so strong directional trend (close to +-1) stands out
    //     from weak/mixed trend (close to 0), instead of a flat linear map that hugs the middle.
    tr_dir = avg_tr >= 0.0 ? 1.0 : -1.0
    tr_pow = math.pow(math.abs(avg_tr), 0.6) * tr_dir
    s4 = use_trend        ? (tr_pow + 1.0) / 2.0 * 15.0 : 0.0

    // s5: Price action - body/range% - keep similar but allow full spread to 80% instead of 100% (100% is rare/extreme)
    s5 = use_price_action ? math.min(avg_pa, 80.0) / 80.0 * 15.0 : 0.0

    [s1 + s2 + s3 + s4 + s5, avg_vl, avg_vm, avg_mo, avg_tr, avg_pa]

// Overall average volume across ALL bars in the analysis window (baseline for relative volume scoring)
ov_vm_s = 0.0
ov_vm_n = 0
for i = 1 to analysis_days
    ov_vm_s += nz(volume[i])
    ov_vm_n += 1
overall_avg_vol = ov_vm_n > 0 ? ov_vm_s / ov_vm_n : 0.0

// CALCULATE
[a_sc, a_vl, a_vm, a_mo, a_tr, a_pa] = calc(1, overall_avg_vol)
[e_sc, e_vl, e_vm, e_mo, e_tr, e_pa] = calc(2, overall_avg_vol)
[u_sc, u_vl, u_vm, u_mo, u_tr, u_pa] = calc(3, overall_avg_vol)

best_sc   = math.max(a_sc, math.max(e_sc, u_sc))
best_name = "AMERICAN"
if a_sc >= e_sc and a_sc >= u_sc
    best_name := "ASIAN"
else if e_sc >= u_sc
    best_name := "EUROPEAN"

b_vl = best_name == "ASIAN" ? a_vl : best_name == "EUROPEAN" ? e_vl : u_vl
b_mo = best_name == "ASIAN" ? a_mo : best_name == "EUROPEAN" ? e_mo : u_mo
b_tr = best_name == "ASIAN" ? a_tr : best_name == "EUROPEAN" ? e_tr : u_tr

// ── RELATIVE RATING (percentile-based, adapts to actual data range) ──
// Instead of fixed thresholds (45/60/75) that can leave everything stuck in one band,
// we rank today's best_sc against its own recent history. The strongest sessions in
// the lookback window become EXCELLENT/GOOD, the weakest become POOR — so the rating
// always reflects real relative strength and no genuine high-movement session gets buried.
var float[] sc_hist = array.new_float(0)
array.push(sc_hist, best_sc)
hist_max_len = math.max(analysis_days * 3, 60)
if array.size(sc_hist) > hist_max_len
    array.shift(sc_hist)

pct_rank(arr, val) =>
    n = array.size(arr)
    cnt = 0
    for k = 0 to n - 1
        if array.get(arr, k) <= val
            cnt += 1
    n > 0 ? cnt / n * 100.0 : 50.0

sc_percentile = pct_rank(sc_hist, best_sc)

// ── SCORE LINES (0–100 scale, bold & clearly visible) ──
plot(show_bars ? a_sc    : na, "Asian Score",    color=color.new(#2196F3, 0), linewidth=3, style=plot.style_line)
plot(show_bars ? e_sc    : na, "European Score", color=color.new(#FF9800, 0), linewidth=3, style=plot.style_line)
plot(show_bars ? u_sc    : na, "American Score", color=color.new(#4CAF50, 0), linewidth=3, style=plot.style_line)
plot(show_bars ? best_sc : na, "Best Score",     color=color.new(#FFFFFF, 0), linewidth=4, style=plot.style_line)

// Reference lines (visual guide only — actual rating now uses relative percentile, see dashboard)
hline(75, "High Score Zone",   color=color.new(color.lime,   50), linestyle=hline.style_dashed, linewidth=1)
hline(60, "Above Avg Zone",    color=color.new(color.blue,   50), linestyle=hline.style_dashed, linewidth=1)
hline(45, "Mid Zone",          color=color.new(color.orange, 50), linestyle=hline.style_dashed, linewidth=1)
hline(0,  "Zero",              color=color.new(color.gray,   50), linestyle=hline.style_solid,  linewidth=1)

// DASHBOARD
if show_dashboard and barstate.islast
    pos = dash_pos == "top_left"     ? position.top_left    :
          dash_pos == "bottom_left"  ? position.bottom_left :
          dash_pos == "bottom_right" ? position.bottom_right:
                                       position.top_right

    t  = table.new(pos, 8, 10, frame_color=color.gray, frame_width=2, border_color=color.gray, border_width=1)
    BG = color.new(color.black, 75)

    // Title
    table.cell(t, 0, 0, "SESSION ANALYZER | " + str.tostring(analysis_days) + " DAYS", text_color=color.white, bgcolor=color.navy, text_size=size.small)
    table.merge_cells(t, 0, 0, 7, 0)

    // Headers
    table.cell(t, 0, 1, "SESSION",  text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 1, 1, "SCORE",    text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 2, 1, "VOL%",     text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 3, 1, "VOL K",    text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 4, 1, "MOM%",     text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 5, 1, "TREND",    text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 6, 1, "BEST",     text_color=color.white, bgcolor=color.gray, text_size=size.small)
    table.cell(t, 7, 1, "TIME",     text_color=color.white, bgcolor=color.gray, text_size=size.small)

    // Asian
    a_bg = best_name == "ASIAN" ? color.new(color.yellow, 40) : color.new(color.blue, 50)
    table.cell(t, 0, 2, "ASIAN",                                         text_color=color.white, bgcolor=a_bg, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(math.round(a_sc, 1)),               text_color=color.blue,   bgcolor=BG, text_size=size.small)
    table.cell(t, 2, 2, str.tostring(math.round(a_vl, 3)) + "%",         text_color=color.blue,   bgcolor=BG, text_size=size.small)
    table.cell(t, 3, 2, str.tostring(math.round(a_vm / 1000, 0)) + "K", text_color=color.blue,   bgcolor=BG, text_size=size.small)
    table.cell(t, 4, 2, str.tostring(math.round(a_mo, 2)) + "%",         text_color=a_mo >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 5, 2, str.tostring(math.round(a_tr, 2)),               text_color=a_tr >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 6, 2, best_name == "ASIAN" ? "YES" : "--",             text_color=best_name == "ASIAN" ? color.lime : color.gray, bgcolor=BG, text_size=size.small)
    table.cell(t, 7, 2, "6:30-15:30",                                    text_color=color.white, bgcolor=BG, text_size=size.small)

    // European
    e_bg = best_name == "EUROPEAN" ? color.new(color.yellow, 40) : color.new(color.orange, 50)
    table.cell(t, 0, 3, "EUROPEAN",                                      text_color=color.white, bgcolor=e_bg, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(math.round(e_sc, 1)),               text_color=color.orange, bgcolor=BG, text_size=size.small)
    table.cell(t, 2, 3, str.tostring(math.round(e_vl, 3)) + "%",         text_color=color.orange, bgcolor=BG, text_size=size.small)
    table.cell(t, 3, 3, str.tostring(math.round(e_vm / 1000, 0)) + "K", text_color=color.orange, bgcolor=BG, text_size=size.small)
    table.cell(t, 4, 3, str.tostring(math.round(e_mo, 2)) + "%",         text_color=e_mo >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 5, 3, str.tostring(math.round(e_tr, 2)),               text_color=e_tr >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 6, 3, best_name == "EUROPEAN" ? "YES" : "--",          text_color=best_name == "EUROPEAN" ? color.lime : color.gray, bgcolor=BG, text_size=size.small)
    table.cell(t, 7, 3, "13:30-23:00",                                   text_color=color.white, bgcolor=BG, text_size=size.small)

    // American
    u_bg = best_name == "AMERICAN" ? color.new(color.yellow, 40) : color.new(color.green, 50)
    table.cell(t, 0, 4, "AMERICAN",                                      text_color=color.white, bgcolor=u_bg, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(math.round(u_sc, 1)),               text_color=color.green,  bgcolor=BG, text_size=size.small)
    table.cell(t, 2, 4, str.tostring(math.round(u_vl, 3)) + "%",         text_color=color.green,  bgcolor=BG, text_size=size.small)
    table.cell(t, 3, 4, str.tostring(math.round(u_vm / 1000, 0)) + "K", text_color=color.green,  bgcolor=BG, text_size=size.small)
    table.cell(t, 4, 4, str.tostring(math.round(u_mo, 2)) + "%",         text_color=u_mo >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 5, 4, str.tostring(math.round(u_tr, 2)),               text_color=u_tr >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 6, 4, best_name == "AMERICAN" ? "YES" : "--",          text_color=best_name == "AMERICAN" ? color.lime : color.gray, bgcolor=BG, text_size=size.small)
    table.cell(t, 7, 4, "20:30-5:00",                                    text_color=color.white, bgcolor=BG, text_size=size.small)

    // Separator
    for c = 0 to 7
        table.cell(t, c, 5, "", bgcolor=color.gray)

    // Best session
    table.cell(t, 0, 6, "BEST: " + best_name, text_color=color.white, bgcolor=color.teal, text_size=size.small)
    table.merge_cells(t, 0, 6, 7, 6)

    // Best metrics
    table.cell(t, 0, 7, "VOL",   text_color=color.white, bgcolor=BG, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(math.round(b_vl, 3)) + "%",        text_color=color.lime, bgcolor=BG, text_size=size.small)
    table.cell(t, 2, 7, "MOM",   text_color=color.white, bgcolor=BG, text_size=size.small)
    table.cell(t, 3, 7, str.tostring(math.round(b_mo, 2)) + "%",        text_color=b_mo >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 4, 7, "TREND", text_color=color.white, bgcolor=BG, text_size=size.small)
    table.cell(t, 5, 7, str.tostring(math.round(b_tr, 2)),              text_color=b_tr >= 0 ? color.lime : color.red, bgcolor=BG, text_size=size.small)
    table.cell(t, 6, 7, "SCORE", text_color=color.white, bgcolor=BG, text_size=size.small)
    table.cell(t, 7, 7, str.tostring(math.round(best_sc, 1)),           text_color=color.white, bgcolor=BG, text_size=size.small)

    // Empty
    for c = 0 to 7
        table.cell(t, c, 8, "", bgcolor=BG)

    // Rating - RELATIVE to this session's own recent history (percentile rank), not a fixed absolute cutoff.
    // Top third of historical scores = EXCELLENT, middle third = GOOD, next = MODERATE, bottom = POOR.
    rec = sc_percentile > 85 ? "EXCELLENT" : sc_percentile > 66 ? "GOOD" : sc_percentile > 33 ? "MODERATE" : "POOR"
    rc  = sc_percentile > 85 ? color.new(color.lime,   40) : sc_percentile > 66 ? color.new(color.blue,   40) : sc_percentile > 33 ? color.new(color.orange, 40) :                       color.new(color.red,    40)
    table.cell(t, 0, 9, "RATING: " + rec + "  (" + str.tostring(math.round(sc_percentile, 0)) + " pct rank)", text_color=color.white, bgcolor=rc, text_size=size.small)
    table.merge_cells(t, 0, 9, 7, 9)

// ALERTS
alertcondition(best_sc > 75,          "Excellent Session", "Excellent session detected!")
alertcondition(ta.cross(best_sc, 60), "Score Crossed 60",  "Session score crossed 60")
````
