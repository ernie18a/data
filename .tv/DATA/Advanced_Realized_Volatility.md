<!-- tradingview-pine-id: PUB;155accc0abda4099acf4439d576ffc40 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Realized Volatility

Source: https://www.tradingview.com/script/ggJnWML8-Advanced-Realized-Volatility-Crypto-Stocks-Indices-Forex/

## Description

**Advanced Realized Volatility — Detailed Guide**

### What This Indicator Does

Advanced Realized Volatility (Crypto) measures the actual historical price fluctuation of an asset over a user-defined calendar-day window and expresses it as an annualized percentage. Unlike simple standard-deviation tools, it offers six statistically grounded estimators (Close-to-Close, Parkinson, Garman-Klass, Yang-Zhang, Rogers-Satchell, and EWMA), automatically converts a calendar-day lookback into the correct number of bars for any timeframe, and applies the proper annualization factor (√365 for crypto by default, √252 for traditional assets).

The indicator places the current volatility reading in historical context through percentile rank, classifies the market into four regimes (Low / Normal / High / Extreme), calculates Expected Moves for 1-, 7-, and 30-day horizons, and allows direct visual comparison with up to three other symbols. All key metrics appear in a compact on-chart table.

### Core Concepts Explained Simply

- **Realized Volatility (RV)** shows how much the asset has actually moved in the recent past, scaled to a one-year basis. Higher RV means larger typical price swings.
- **Percentile Rank** answers the question: “Is the current volatility high or low relative to its own history?” A reading of 15 means the present volatility is lower than 85 % of the readings in the chosen historical window.
- **Volatility regimes** translate the percentile into actionable categories:
  - Low (compression) — percentile below 20
  - Normal — 20 to 80
  - High — above 80
  - Extreme — above 95
- **Expected Move** converts the current annualized RV into an approximate price range the market is statistically likely to traverse over the next 1, 7, or 30 days.
- **Relative Volatility** and multi-asset lines show whether the current instrument is quieter or more turbulent than its peers or its own longer-term average.

### How to Set Up and Read the Indicator

1. Apply the script to any chart (crypto, stocks, indices, and forex work correctly).
2. Choose the volatility method. Yang-Zhang is the recommended default because it efficiently incorporates overnight gaps, open-to-close drift, and the high-low range.
3. Select a lookback in calendar days (30 days is a balanced starting point; shorter windows react faster, longer windows are smoother).
4. Leave annualization on Auto unless you have a specific reason to force 365 or 252.
5. Optionally enable one to three comparison symbols (e.g., BTC vs ETH, SOL, or QQQ) using the same method and period.
6. Turn on background regime coloring and the information table for at-a-glance context.
7. Observe three primary visual elements:
   - The main RV line and any comparison lines
   - Horizontal reference levels (mean, 20th and 80th percentiles)
   - Background color that changes with the regime

The table always displays the current annualized RV, percentile rank with regime label, relative volatility, Expected Moves, and the values of any enabled comparison assets.

### Practical Trading Applications and Patterns

**1. Volatility Compression → Expansion (Breakout Preparation)**  
When the percentile rank falls below 20 and the background turns to the Low-volatility color, the market is in a compressed state. Historically, prolonged low-volatility periods are frequently followed by a sharp expansion in range. Traders watch for price to break a well-defined consolidation, range, or chart pattern while RV is still low or just beginning to rise. The Expected Move values help set realistic profit targets once the expansion starts.

**2. High / Extreme Volatility Regime (Risk Management & Mean-Reversion Bias)**  
A percentile above 80 (especially above 95) signals elevated or extreme turbulence. In these conditions:
- Position sizes are typically reduced.
- Stops are widened or switched to volatility-based (ATR or Expected Move multiples).
- Mean-reversion or fade strategies become more attractive after a climax move, because extreme readings often revert toward the mean.
- Trend-following systems may stay in the market but with tighter risk controls.

**3. Regime Shifts as Timing Filters**  
A cross of the RV line above its longer-term mean or a move of the percentile from Low into Normal/High can confirm that a new directional move has volatility support. Conversely, a drop back into the Low regime after an expansion often marks the end of a volatile phase and the start of a quieter consolidation.

**4. Cross-Asset Relative Volatility**  
When the main asset’s RV line sits significantly above or below the comparison lines, relative volatility strength or weakness appears. Example patterns:
- BTC RV rising while ETH RV stays flat or declines → possible BTC leadership or capital rotation into Bitcoin.
- An altcoin showing persistently higher RV than BTC → higher-risk, higher-reward environment that may require stricter position sizing.
- Equity index (QQQ or SPX) RV rising together with crypto → broader risk-off or risk-on regime alignment.

**5. Expected Move for Targets and Option Structures**  
The 1-day, 7-day, and 30-day Expected Move figures provide statistically derived price ranges. Common uses:
- Setting take-profit levels at approximately 1× or 1.5× the Expected Move.
- Judging whether an options premium is rich or cheap relative to recent realized movement.
- Sizing positions so that a 1–2 Expected Move adverse excursion remains within acceptable risk.

**6. Volatility of Volatility (VoV)**  
When enabled, VoV highlights periods when volatility itself is unstable. Rising VoV often accompanies regime transitions and can serve as an early warning that the current quiet or elevated state is about to change.

### Typical Workflow for Discretionary Traders

1. Note the current regime and percentile rank.
2. Check whether RV is rising or falling and how it compares with the chosen benchmark assets.
3. Read the Expected Move numbers to gauge the probable size of the next swing.
4. Align the volatility picture with classical price action (breakouts from compression, exhaustion after extreme readings, relative strength between assets).
5. Adjust position size, stop distance, and profit targets accordingly.
6. Use the built-in alerts for regime changes, RV crosses of its mean, or sharp expansions so that monitoring can be partly automated.

### Recommended Starting Settings

- Method: Yang-Zhang  
- Lookback: 30 calendar days  
- Annualization: Auto  
- Percentile lookback: 365 days  
- Background coloring and table: enabled  
- One or two comparison symbols relevant to the traded asset  

These settings provide a balanced, responsive view on most crypto pairs while remaining stable enough for higher-timeframe analysis.

The indicator does not generate buy or sell signals by itself. It supplies a quantitative volatility context that improves timing, risk management, and cross-market comparison. When combined with price structure, volume, and a clear trading plan, the regimes, percentile extremes, and Expected Moves become reliable filters for identifying high-probability compression-to-expansion setups, managing risk during turbulent periods, and comparing the relative “temperature” of different assets.

⚠️ Disclaimer

This indicator is for *educational and informational purposes only*. It does not constitute financial advice. Always do your own research before making investment decisions.

*Indicator by:* iCD_creator
*Version:* 1.0
*Pine Script™ Version:* 6
---
Updates & Support
For questions, suggestions, or bug reports, please comment below or message the author.
*Like this indicator? Leave a 👍 and share your feedback!*

---

## Source Code

````pine
//@version=6
indicator("Advanced Realized Volatility", shorttitle="Adv RV", overlay=false, max_bars_back=5000, max_lines_count=50, max_labels_count=50)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────

// Group: Calculation
string method          = input.string("Yang-Zhang", "Volatility Method", options=["Close-to-Close", "Parkinson", "Garman-Klass", "Yang-Zhang", "Rogers-Satchell", "EWMA"], group="Calculation")
int    lookback_days   = input.int(30, "Lookback Period (Calendar Days)", minval=3, maxval=500, group="Calculation")
string ann_mode        = input.string("Auto", "Annualization Basis", options=["Auto", "365", "252", "Custom"], group="Calculation")
float  custom_ann      = input.float(365.0, "Custom Annualization Factor", minval=1.0, maxval=400.0, step=1.0, group="Calculation")
float  ewma_lambda     = input.float(0.94, "EWMA Lambda", minval=0.80, maxval=0.999, step=0.001, group="Calculation")

// Group: Comparison
bool   enable_comp1    = input.bool(false, "Enable Comparison 1", group="Comparison")
string symbol1         = input.symbol("BINANCE:ETHUSDT", "Symbol 1", group="Comparison")
bool   enable_comp2    = input.bool(false, "Enable Comparison 2", group="Comparison")
string symbol2         = input.symbol("BINANCE:SOLUSDT", "Symbol 2", group="Comparison")
bool   enable_comp3    = input.bool(false, "Enable Comparison 3", group="Comparison")
string symbol3         = input.symbol("NASDAQ:QQQ", "Symbol 3", group="Comparison")

// Group: Display
bool   show_percentile = input.bool(true, "Show Percentile Rank Line", group="Display")
bool   show_mean       = input.bool(true, "Show Mean RV Line", group="Display")
bool   show_p20_p80    = input.bool(true, "Show 20th / 80th Percentile Lines", group="Display")
bool   show_bg         = input.bool(true, "Show Background Regime Coloring", group="Display")
bool   show_table      = input.bool(true, "Show Information Table", group="Display")
string table_pos       = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display")
string table_size      = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal"], group="Display")

// Colors
color  col_main        = input.color(color.new(#2962FF, 0), "Main RV Color", group="Display")
color  col_comp1       = input.color(color.new(#FF6D00, 0), "Comparison 1 Color", group="Display")
color  col_comp2       = input.color(color.new(#00C853, 0), "Comparison 2 Color", group="Display")
color  col_comp3       = input.color(color.new(#AA00FF, 0), "Comparison 3 Color", group="Display")
color  col_low         = input.color(color.new(#00E676, 85), "Low Vol (<20) Background", group="Display")
color  col_normal      = input.color(color.new(#2962FF, 92), "Normal Vol Background", group="Display")
color  col_high        = input.color(color.new(#FF6D00, 85), "High Vol (>80) Background", group="Display")
color  col_extreme     = input.color(color.new(#D50000, 75), "Extreme Vol (>95) Background", group="Display")

// Group: Advanced
int    perc_days       = input.int(365, "Percentile Lookback (Calendar Days)", minval=30, maxval=1000, group="Advanced")
int    smooth_len      = input.int(1, "Smooth RV (MA Length, 1 = off)", minval=1, maxval=50, group="Advanced")
bool   show_vov        = input.bool(false, "Show Volatility of Volatility", group="Advanced")
int    vov_len         = input.int(60, "VoV Lookback (bars)", minval=10, maxval=200, group="Advanced")
float  low_th          = input.float(20.0, "Low Vol Threshold", minval=5, maxval=40, group="Advanced")
float  high_th         = input.float(80.0, "High Vol Threshold", minval=60, maxval=95, group="Advanced")
float  extreme_th      = input.float(95.0, "Extreme Vol Threshold", minval=85, maxval=99, group="Advanced")

// ─────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────

float tf_sec           = timeframe.in_seconds(timeframe.period)
float bars_per_day     = 86400.0 / tf_sec
int   length           = math.max(2, int(math.round(lookback_days * bars_per_day)))
int   perc_length      = math.max(10, int(math.round(perc_days * bars_per_day)))

float annual_basis     = switch ann_mode
    "Auto"   => syminfo.type == "crypto" ? 365.0 : 252.0
    "365"    => 365.0
    "252"    => 252.0
    => custom_ann

float periods_per_year = annual_basis * bars_per_day

// ─── Volatility calculation function ───
f_calc_rv(_o, _h, _l, _c, _len, _method, _lambda, _ppy) =>
    float result = na
    float log_ret = math.log(_c / _c[1])
    
    if _method == "Close-to-Close"
        float sd = ta.stdev(log_ret, _len)
        result := sd * math.sqrt(_ppy) * 100.0
        
    else if _method == "Parkinson"
        float log_hl = math.log(_h / _l)
        float var_p  = ta.sma(log_hl * log_hl, _len) / (4.0 * math.log(2.0))
        result := math.sqrt(math.max(var_p, 0.0)) * math.sqrt(_ppy) * 100.0
        
    else if _method == "Garman-Klass"
        float log_hl = math.log(_h / _l)
        float log_co = math.log(_c / _o)
        float var_gk = ta.sma(0.5 * log_hl * log_hl - (2.0 * math.log(2.0) - 1.0) * log_co * log_co, _len)
        result := math.sqrt(math.max(var_gk, 0.0)) * math.sqrt(_ppy) * 100.0
        
    else if _method == "Rogers-Satchell"
        float rs = math.log(_h / _c) * math.log(_h / _o) + math.log(_l / _c) * math.log(_l / _o)
        float var_rs = ta.sma(rs, _len)
        result := math.sqrt(math.max(var_rs, 0.0)) * math.sqrt(_ppy) * 100.0
        
    else if _method == "Yang-Zhang"
        float log_oc = math.log(_o / _c[1])          // overnight
        float log_co = math.log(_c / _o)             // open-to-close
        float rs     = math.log(_h / _c) * math.log(_h / _o) + math.log(_l / _c) * math.log(_l / _o)
        
        float var_o  = ta.variance(log_oc, _len)
        float var_c  = ta.variance(log_co, _len)
        float var_rs = ta.sma(rs, _len)
        
        float k = 0.34 / (1.34 + (_len + 1.0) / (_len - 1.0))
        float var_yz = var_o + k * var_c + (1.0 - k) * var_rs
        result := math.sqrt(math.max(var_yz, 0.0)) * math.sqrt(_ppy) * 100.0
        
    else if _method == "EWMA"
        var float ewma_var = na
        float r2 = log_ret * log_ret
        ewma_var := na(ewma_var[1]) ? r2 : _lambda * ewma_var[1] + (1.0 - _lambda) * r2
        result := math.sqrt(ewma_var) * math.sqrt(_ppy) * 100.0
    
    result

// Main RV
float raw_rv = f_calc_rv(open, high, low, close, length, method, ewma_lambda, periods_per_year)
float rv     = smooth_len > 1 ? ta.sma(raw_rv, smooth_len) : raw_rv

// Comparison RVs
float rv1 = na
float rv2 = na
float rv3 = na

if enable_comp1
    [o1, h1, l1, c1] = request.security(symbol1, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
    rv1 := f_calc_rv(o1, h1, l1, c1, length, method, ewma_lambda, periods_per_year)

if enable_comp2
    [o2, h2, l2, c2] = request.security(symbol2, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
    rv2 := f_calc_rv(o2, h2, l2, c2, length, method, ewma_lambda, periods_per_year)

if enable_comp3
    [o3, h3, l3, c3] = request.security(symbol3, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
    rv3 := f_calc_rv(o3, h3, l3, c3, length, method, ewma_lambda, periods_per_year)

// Percentile Rank & Relative Volatility
float perc_rank = ta.percentrank(rv, perc_length)
float mean_rv   = ta.sma(rv, perc_length)
float rel_vol   = mean_rv != 0 ? rv / mean_rv : na

float p20 = ta.percentile_nearest_rank(rv, perc_length, 20)
float p80 = ta.percentile_nearest_rank(rv, perc_length, 80)

// Expected Move
float em_1d  = close * (rv / 100.0) * math.sqrt(1.0 / annual_basis)
float em_7d  = close * (rv / 100.0) * math.sqrt(7.0 / annual_basis)
float em_30d = close * (rv / 100.0) * math.sqrt(30.0 / annual_basis)

float em_1d_pct  = (rv / 100.0) * math.sqrt(1.0 / annual_basis) * 100.0
float em_7d_pct  = (rv / 100.0) * math.sqrt(7.0 / annual_basis) * 100.0
float em_30d_pct = (rv / 100.0) * math.sqrt(30.0 / annual_basis) * 100.0

// VoV
float vov = show_vov ? ta.stdev(rv, vov_len) : na

// Regime
string regime = perc_rank < low_th ? "Low" : perc_rank > extreme_th ? "Extreme" : perc_rank > high_th ? "High" : "Normal"
color  bg_col = perc_rank < low_th ? col_low : perc_rank > extreme_th ? col_extreme : perc_rank > high_th ? col_high : col_normal

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────

plot(rv, "Realized Volatility", color=col_main, linewidth=2)
plot(enable_comp1 ? rv1 : na, "Comparison 1", color=col_comp1, linewidth=1)
plot(enable_comp2 ? rv2 : na, "Comparison 2", color=col_comp2, linewidth=1)
plot(enable_comp3 ? rv3 : na, "Comparison 3", color=col_comp3, linewidth=1)

plot(show_mean ? mean_rv : na, "Mean RV", color=color.new(color.gray, 30), style=plot.style_stepline)
plot(show_p20_p80 ? p20 : na, "20th Percentile", color=color.new(color.green, 50), style=plot.style_stepline)
plot(show_p20_p80 ? p80 : na, "80th Percentile", color=color.new(color.red, 50), style=plot.style_stepline)
plot(show_vov ? vov : na, "VoV", color=color.new(color.purple, 0), linewidth=1)

bgcolor(show_bg ? bg_col : na, title="Regime Background")

// ─────────────────────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────────────────────

var table info = table.new(
     table_pos == "Top Left" ? position.top_left :
     table_pos == "Top Right" ? position.top_right :
     table_pos == "Bottom Left" ? position.bottom_left : position.bottom_right,
     2, 14, border_width=1)

text_size = table_size == "Tiny" ? size.tiny : table_size == "Small" ? size.small : size.normal

if show_table and barstate.islast
    table.cell(info, 0, 0, "Advanced RV", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 0, method + " | " + str.tostring(lookback_days) + "d", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 1, "RV (ann.)", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 1, str.tostring(rv, "#.##") + "%", text_color=col_main, text_size=text_size)
    
    table.cell(info, 0, 2, "Percentile", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 2, str.tostring(perc_rank, "#.#") + "%  (" + regime + ")", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 3, "Relative Vol", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 3, str.tostring(rel_vol, "#.##") + "x", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 4, "EM 1d", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 4, str.tostring(em_1d_pct, "#.##") + "%  (" + str.tostring(em_1d, "#.####") + ")", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 5, "EM 7d", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 5, str.tostring(em_7d_pct, "#.##") + "%  (" + str.tostring(em_7d, "#.####") + ")", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 6, "EM 30d", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 6, str.tostring(em_30d_pct, "#.##") + "%  (" + str.tostring(em_30d, "#.####") + ")", text_color=color.gray, text_size=text_size)
    
    table.cell(info, 0, 7, "Ann. Basis", text_color=color.gray, text_size=text_size)
    table.cell(info, 1, 7, str.tostring(annual_basis, "#") + "  |  bars=" + str.tostring(length), text_color=color.gray, text_size=text_size)
    
    int row = 8
    if enable_comp1 and not na(rv1)
        table.cell(info, 0, row, "Comp 1", text_color=color.gray, text_size=text_size)
        table.cell(info, 1, row, str.tostring(rv1, "#.##") + "%", text_color=col_comp1, text_size=text_size)
        row += 1
    if enable_comp2 and not na(rv2)
        table.cell(info, 0, row, "Comp 2", text_color=color.gray, text_size=text_size)
        table.cell(info, 1, row, str.tostring(rv2, "#.##") + "%", text_color=col_comp2, text_size=text_size)
        row += 1
    if enable_comp3 and not na(rv3)
        table.cell(info, 0, row, "Comp 3", text_color=color.gray, text_size=text_size)
        table.cell(info, 1, row, str.tostring(rv3, "#.##") + "%", text_color=col_comp3, text_size=text_size)
        row += 1
    if show_vov and not na(vov)
        table.cell(info, 0, row, "VoV", text_color=color.gray, text_size=text_size)
        table.cell(info, 1, row, str.tostring(vov, "#.##"), text_color=color.purple, text_size=text_size)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(ta.crossover(rv, mean_rv),  "RV crossed above Mean", "Realized Volatility crossed above its mean")
alertcondition(ta.crossunder(rv, mean_rv), "RV crossed below Mean", "Realized Volatility crossed below its mean")

alertcondition(perc_rank < low_th and perc_rank[1] >= low_th, "Entered Low Vol Regime", "Percentile Rank entered Low Volatility zone")
alertcondition(perc_rank > high_th and perc_rank[1] <= high_th, "Entered High Vol Regime", "Percentile Rank entered High Volatility zone")
alertcondition(perc_rank > extreme_th and perc_rank[1] <= extreme_th, "Entered Extreme Vol Regime", "Percentile Rank entered Extreme Volatility zone")

alertcondition(enable_comp1 and ta.crossover(rv, rv1), "RV > Comp1", "Main RV crossed above Comparison 1")
alertcondition(enable_comp1 and ta.crossunder(rv, rv1), "RV < Comp1", "Main RV crossed below Comparison 1")

alertcondition(rv > rv[1] * 1.15, "Sharp RV Expansion", "Realized Volatility expanded more than 15% from previous bar")

// ─────────────────────────────────────────────────────────────
// END
````
