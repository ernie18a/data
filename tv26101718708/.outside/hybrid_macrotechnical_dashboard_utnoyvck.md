# Hybrid Macro/Technical Dashboard

- url: https://www.tradingview.com/script/UTNOYVcK-Hybrid-Macro-Technical-Dashboard/
- type: indicator
- pine_id: PUB;19445ceba17448848bc2085d34a7af3e
- version: 1.0

## Description

[b]Credits:[/b]
A massive thank you and credit goes to @giorgos_ts. The core "Global Liquidity (GLI Z)" measurement engine acting as the heavy anchor for this script was adapted directly from their original GLI Z indicator work. You can find their original script here: https://www.tradingview.com/script/f3XslEsI-Global-Liquidity-Index-Z-Score/

[b]Description:[/b]
Navigating the stock market requires understanding two completely different forces: **Macroeconomic Gravity** (the slow, structural foundation) and **Price Action** (the real-time reality of hype and momentum). 

[b]The 7 Pillars of Macro Gravity:[/b]
The indicator evaluates the following components under the hood:
1. **Global Liquidity (GLI Z):** Tracks the real-time expansion/contraction of Central Bank balance sheets.
2. **Yield Curve (10Y-2Y):** Tracks structural banking recessions and warns of inversions.
3. **Credit Spreads (HY):** Measures corporate stress and default risk.
4. **Real Yields (10Y TIPS):** The true cost of capital for the global economy.
5. **Growth vs. Fear (Copper/Gold):** A live proxy for global industrial expansion.
6. **Currency Strength (DXY):** Measures global trade friction and offshore dollar liquidity.
7. **Volatility (VIX):** A real-time panic override switch.

[b]The 4 Actionable States (The Trend Filter):[/b]
Macro data is not a timing tool. To solve this, the dashboard filters the Macro Score through a 40-Week Moving Average (the 200-Day equivalent) to generate 4 actionable regimes:
*   🟢 **SECURE BULL MARKET:** Macro is healthy, and Price is above trend.
*   🔵 **BUY THE DIP OPPORTUNITY:** Macro is healthy, but Price broke below trend. A temporary technical breakdown; historically a strong buy signal.
*   🟠 **DANGER ZONE / DEFYING GRAVITY:** Macro is completely broken, but the Price is still above trend (fueled by hype or fiscal deficits).
*   🔴 **CRASH REGIME / MAX GRAVITY:** Macro is broken, and the Price finally broke below trend. The hype is dead, gravity has taken over.

[b]The Customizable Weighting Engine:[/b]
The entire engine is exposed in the indicator settings. You can assign custom integer weights to any of the 7 pillars to backtest your own unique algorithmic scoring system. The dashboard UI will automatically scale and display your custom weights in real-time.

[b]HOW TO USE:[/b]
1. **You MUST apply this to a Weekly ("1W") chart.** The momentum and lookback math is specifically tuned to weeks.
2. Customize the point system as you wish, using the relevant inputs in settings.

## Source Code

````pine
// © voidvaxa
//@version=6
indicator(title = 'Macro Regime Score', shorttitle = 'Macro Score', overlay = false)

// ==============================================================================
// 1. INPUTS & SETTINGS
// ==============================================================================
group_gli = "GLI Z (Liquidity) Settings"
calc_mode   = input.string('Net Central Banks', title = 'Liquidity Metric', options = ['Net Central Banks', 'Global M2'], group=group_gli)
offset_bars = input.int(15, title = 'Projection Offset (Bars Forward)', group=group_gli)
use_norm    = input.bool(true, title = 'Normalize Signal (Z-Score)', tooltip="Εξισορροπεί τις διαφορές μεγέθους μεταξύ των Κεντρικών Τραπεζών.", group=group_gli)
norm_len    = input.int(100, title = 'Normalization Length', minval=10, group=group_gli)
base_smooth = input.int(3, title = 'Base Data Smoothing', minval=1, group=group_gli)
roc_len     = input.int(12, title = 'Momentum Length', group=group_gli)
fast_len    = input.int(4,  title = 'Fast EMA', group=group_gli)
med_len     = input.int(12, title = 'Medium EMA', group=group_gli)
slow_len    = input.int(26, title = 'Slow EMA', group=group_gli)

group_macro = "Macro Momentum Settings"
macro_roc_len = input.int(12, title="Macro ROC Length", tooltip="Lookback period to determine if metrics are rising or falling.", group=group_macro)

group_trend = "Price Action Trend Filter"
trend_len = input.int(40, title="Trend Moving Average Length (Weeks)", group=group_trend)

group_weights = "Scoring Weights (Customizable Engine)"
w_gli_p2 = input.int(2, "GLI Phase 2 (Full Thrust)", group=group_weights)
w_gli_p1 = input.int(1, "GLI Phase 1 (Recovery)", group=group_weights)
w_gli_p3 = input.int(-2, "GLI Phase 3 (Downturn)", group=group_weights)
w_gli_p4 = input.int(-4, "GLI Phase 4 (Drought)", group=group_weights)

w_yc_bull = input.int(1, "Yield Curve Normal", group=group_weights)
w_yc_bear = input.int(-3, "Yield Curve Inverted", group=group_weights)

w_vix_bull = input.int(1, "VIX Calm (<20)", group=group_weights)
w_vix_bear = input.int(-2, "VIX Panic (>25)", group=group_weights)

w_hy_bull = input.int(1, "HY Spread Falling", group=group_weights)
w_hy_bear = input.int(-1, "HY Spread Rising", group=group_weights)

w_ry_bull = input.int(1, "Real Yield Falling", group=group_weights)
w_ry_bear = input.int(-1, "Real Yield Rising", group=group_weights)

w_dxy_bull = input.int(1, "DXY Weakening", group=group_weights)
w_dxy_bear = input.int(-1, "DXY Strengthening", group=group_weights)

w_cg_bull = input.int(1, "Copper/Gold Rising", group=group_weights)
w_cg_bear = input.int(-1, "Copper/Gold Falling", group=group_weights)

group_thresh = "Regime Thresholds"
thresh_best = input.int(4, "Best (Strong Bull) Minimum Score", group=group_thresh)
thresh_worst = input.int(-5, "Worst (Strong Bear) Maximum Score", group=group_thresh)

// ==============================================================================
// 2. DATA FETCHING
// ==============================================================================
tf = timeframe.period

// GLI Z Data
fed_bs  = request.security('ECONOMICS:USCBBS', tf, close, currency = currency.USD)
fed_rrp = request.security('FRED:RRPONTSYD',   tf, close, currency = currency.USD)
fed_tga = request.security('FRED:WTREGEN',     tf, close, currency = currency.USD)
us_m2   = request.security('ECONOMICS:USM2',   tf, close, currency = currency.USD)
ecb_cb  = request.security('ECONOMICS:EUCBBS', tf, close, currency = currency.USD)
eu_m2   = request.security('ECONOMICS:EUM2',   tf, close, currency = currency.USD)
pboc_cb = request.security('ECONOMICS:CNCBBS', tf, close, currency = currency.USD)
cn_m2   = request.security('ECONOMICS:CNM2',   tf, close, currency = currency.USD)
boj_cb  = request.security('ECONOMICS:JPCBBS', tf, close, currency = currency.USD)
jp_m2   = request.security('ECONOMICS:JPM2',   tf, close, currency = currency.USD)
boe_cb  = request.security('ECONOMICS:GBCBBS', tf, close, currency = currency.USD)
uk_m2   = request.security('ECONOMICS:GBM2',   tf, close, currency = currency.USD)
snb_cb  = request.security('ECONOMICS:CHCBBS', tf, close, currency = currency.USD)
ch_m2   = request.security('ECONOMICS:CHM2',   tf, close, currency = currency.USD)

// Other Macro Data
hy_spread   = request.security('FRED:BAMLH0A0HYM2', tf, close)
real_yield  = request.security('FRED:DFII10', tf, close)
dxy         = request.security('TVC:DXY', tf, close)
copper      = request.security('COMEX:HG1!', tf, close)
gold        = request.security('COMEX:GC1!', tf, close)
yield_curve = request.security('FRED:T10Y2Y', tf, close)
vix         = request.security('CBOE:VIX', tf, close)

// Copper/Gold Ratio
cg_ratio = gold != 0 ? copper / gold : 0

// ==============================================================================
// 3. GLI Z CORE LOGIC
// ==============================================================================
var float raw_liquidity = 0.0

if calc_mode == 'Net Central Banks'
    raw_liquidity := (fed_bs - nz(fed_rrp) - nz(fed_tga)) + ecb_cb + pboc_cb + boj_cb + boe_cb + snb_cb
else
    raw_liquidity := us_m2 + eu_m2 + cn_m2 + jp_m2 + uk_m2 + ch_m2

total_liquidity = ta.ema(raw_liquidity, base_smooth)
liq_roc = ta.roc(total_liquidity, roc_len)

norm_roc = liq_roc
if use_norm
    roc_sma = ta.sma(liq_roc, norm_len)
    roc_std = ta.stdev(liq_roc, norm_len)
    norm_roc := roc_std != 0 ? (liq_roc - roc_sma) / roc_std : 0

fast_liq = ta.ema(norm_roc, fast_len)
med_liq  = ta.ema(norm_roc, med_len)
slow_liq = ta.ema(norm_roc, slow_len)

is_phase_1 = fast_liq > med_liq and med_liq <= slow_liq
is_phase_2 = fast_liq > med_liq and med_liq > slow_liq
is_phase_3 = fast_liq < med_liq and med_liq >= slow_liq
is_phase_4 = fast_liq < med_liq and med_liq < slow_liq

// ==============================================================================
// 4. SCORING LOGIC
// ==============================================================================

// GLI Score (-4 to +2) - Heavily weighted for early warning
score_gli = is_phase_2 ? w_gli_p2 : is_phase_1 ? w_gli_p1 : is_phase_3 ? w_gli_p3 : is_phase_4 ? w_gli_p4 : 0

// HY Spread Score (-1 to +1) - Falling = Bullish
hy_roc = ta.roc(hy_spread, macro_roc_len)
score_hy = hy_roc < 0 ? w_hy_bull : hy_roc > 0 ? w_hy_bear : 0

// Real Yield Score (-1 to +1) - Falling = Bullish
ry_diff = real_yield - real_yield[macro_roc_len]
score_ry = ry_diff < 0 ? w_ry_bull : ry_diff > 0 ? w_ry_bear : 0

// DXY Score (-1 to +1) - Weakening = Bullish
dxy_roc = ta.roc(dxy, macro_roc_len)
score_dxy = dxy_roc < 0 ? w_dxy_bull : dxy_roc > 0 ? w_dxy_bear : 0

// Copper/Gold Score (-1 to +1) - Rising = Bullish
cg_roc = ta.roc(cg_ratio, macro_roc_len)
score_cg = cg_roc > 0 ? w_cg_bull : cg_roc < 0 ? w_cg_bear : 0

// Yield Curve Score (-3 to +1) - Normal (>0) = Bullish, Inverted (<0) = Heavy Bearish Warning
score_yc = yield_curve > 0 ? w_yc_bull : yield_curve < 0 ? w_yc_bear : 0

// VIX Score (-2 to +1) - <20 = Bullish, >25 = Panic/Bearish
score_vix = vix < 20 ? w_vix_bull : vix > 25 ? w_vix_bear : 0

// TOTAL MACRO SCORE (-13 to +8)
total_score = score_gli + score_hy + score_ry + score_dxy + score_cg + score_yc + score_vix

// ==============================================================================
// 5. REGIME DETERMINATION
// ==============================================================================
regime_str = total_score >= thresh_best ? "BEST (Strong Bull)" :
             total_score >= 1 ? "GOOD (Bullish)" :
             total_score == 0 ? "NEUTRAL" :
             total_score <= thresh_worst ? "WORST (Strong Bear)" : "BAD (Bearish)"

regime_color = total_score >= thresh_best ? color.new(color.lime, 10) :
               total_score >= 1 ? color.new(color.green, 40) :
               total_score == 0 ? color.new(color.gray, 60) :
               total_score <= thresh_worst ? color.new(color.maroon, 10) : color.new(color.red, 40)

// ==============================================================================
// 6. ACTIONABLE STATE (Price Action Filter)
// ==============================================================================
price_trend = ta.sma(close, trend_len)
is_above_trend = close > price_trend

string action_str = na
color action_color = na

if total_score >= 1 and is_above_trend
    action_str := "SECURE BULL MARKET"
    action_color := color.new(color.lime, 20)
else if total_score >= 1 and not is_above_trend
    action_str := "BUY THE DIP OPPORTUNITY"
    action_color := color.new(color.teal, 20)
else if total_score < 1 and is_above_trend
    action_str := "DANGER ZONE / DEFYING GRAVITY"
    action_color := color.new(color.orange, 20)
else
    action_str := "CRASH REGIME / MAX GRAVITY"
    action_color := color.new(color.maroon, 20)

// ==============================================================================
// 7. VISUALS & DASHBOARD
// ==============================================================================
plot(total_score, title="Total Macro Score", color=regime_color, style=plot.style_columns, linewidth=4)
hline(0, "Neutral Line", color=color.gray, linestyle=hline.style_dashed)
hline(thresh_best, "Best Threshold", color=color.new(color.green, 50), linestyle=hline.style_dotted)
hline(thresh_worst, "Worst Threshold", color=color.new(color.red, 50), linestyle=hline.style_dotted)

var table tb = table.new(position.bottom_right, 2, 10, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    // Header
    table.cell(tb, 0, 0, "MACRO REGIME DASHBOARD", text_color=color.white, bgcolor=color.black, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(tb, 0, 0, 1, 0)
    
    // GLI
    gli_phase_str = is_phase_2 ? "PHASE 2 " : is_phase_1 ? "PHASE 1 " : is_phase_3 ? "PHASE 3 " : "PHASE 4 "
    gli_str = gli_phase_str + (score_gli > 0 ? "(+" : "(") + str.tostring(score_gli) + ")"
    table.cell(tb, 0, 1, "GLI Z (Leading Liquidity)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 1, gli_str, text_color=color.white, bgcolor=score_gli > 0 ? color.new(color.green,50) : score_gli < 0 ? color.new(color.red,50) : color.gray)
    
    // HY Spread
    hy_val = str.tostring(hy_spread, "#.##")
    hy_past = hy_spread[macro_roc_len]
    hy_past_str = str.tostring(hy_past, "#.##")
    hy_text = " [" + hy_val + "% from " + hy_past_str + "%]"
    hy_str = (score_hy > 0 ? "Falling " : score_hy < 0 ? "Rising " : "Neutral ") + (score_hy > 0 ? "(+" : "(") + str.tostring(score_hy) + ")" + hy_text
    table.cell(tb, 0, 2, "HY Spread (Credit)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 2, hy_str, text_color=color.white, bgcolor=score_hy > 0 ? color.new(color.green,50) : score_hy < 0 ? color.new(color.red,50) : color.gray)

    // Real Yield
    ry_past = real_yield[macro_roc_len]
    ry_val = str.tostring(real_yield, "#.##")
    ry_past_str = str.tostring(ry_past, "#.##")
    ry_text = " [" + ry_val + "% from " + ry_past_str + "%]"
    ry_str = (score_ry > 0 ? "Falling " : score_ry < 0 ? "Rising " : "Neutral ") + (score_ry > 0 ? "(+" : "(") + str.tostring(score_ry) + ")" + ry_text
    table.cell(tb, 0, 3, "10Y Real Yield", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 3, ry_str, text_color=color.white, bgcolor=score_ry > 0 ? color.new(color.green,50) : score_ry < 0 ? color.new(color.red,50) : color.gray)

    // DXY
    dxy_past = dxy[macro_roc_len]
    dxy_val = str.tostring(dxy, "#.##")
    dxy_past_str = str.tostring(dxy_past, "#.##")
    dxy_text = " [" + dxy_val + " from " + dxy_past_str + "]"
    dxy_str = (score_dxy > 0 ? "Weakening " : score_dxy < 0 ? "Strengthening " : "Neutral ") + (score_dxy > 0 ? "(+" : "(") + str.tostring(score_dxy) + ")" + dxy_text
    table.cell(tb, 0, 4, "US Dollar (DXY)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 4, dxy_str, text_color=color.white, bgcolor=score_dxy > 0 ? color.new(color.green,50) : score_dxy < 0 ? color.new(color.red,50) : color.gray)

    // Copper/Gold
    cg_past = cg_ratio[macro_roc_len]
    cg_val = str.tostring(cg_ratio, "#.####")
    cg_past_str = str.tostring(cg_past, "#.####")
    cg_text = " [" + cg_val + " from " + cg_past_str + "]"
    cg_str = (score_cg > 0 ? "Rising " : score_cg < 0 ? "Falling " : "Neutral ") + (score_cg > 0 ? "(+" : "(") + str.tostring(score_cg) + ")" + cg_text
    table.cell(tb, 0, 5, "Copper/Gold (Growth)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 5, cg_str, text_color=color.white, bgcolor=score_cg > 0 ? color.new(color.green,50) : score_cg < 0 ? color.new(color.red,50) : color.gray)

    // Yield Curve
    yc_past = yield_curve[macro_roc_len]
    yc_val = str.tostring(yield_curve, "#.##")
    yc_past_str = str.tostring(yc_past, "#.##")
    yc_text = " [" + yc_val + "% from " + yc_past_str + "%]"
    yc_str = (score_yc > 0 ? "Normal " : score_yc < 0 ? "Inverted " : "Neutral ") + (score_yc > 0 ? "(+" : "(") + str.tostring(score_yc) + ")" + yc_text
    table.cell(tb, 0, 6, "10Y-2Y Spread (Curve)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 6, yc_str, text_color=color.white, bgcolor=score_yc > 0 ? color.new(color.green,50) : score_yc < 0 ? color.new(color.red,50) : color.gray)

    // VIX
    vix_val = str.tostring(vix, "#.##")
    vix_str = (score_vix > 0 ? "Calm " : score_vix < 0 ? "Panic " : "Neutral ") + (score_vix > 0 ? "(+" : "(") + str.tostring(score_vix) + ") [" + vix_val + "]"
    table.cell(tb, 0, 7, "Volatility (VIX)", text_color=color.white, bgcolor=color.black, text_halign=text.align_left)
    table.cell(tb, 1, 7, vix_str, text_color=color.white, bgcolor=score_vix > 0 ? color.new(color.green,50) : score_vix < 0 ? color.new(color.red,50) : color.gray)

    // Total
    table.cell(tb, 0, 8, "REGIME: " + regime_str, text_color=color.white, bgcolor=regime_color, text_halign=text.align_center, text_size=size.large)
    table.merge_cells(tb, 0, 8, 1, 8)
    
    // Action State
    table.cell(tb, 0, 9, "ACTION STATE: " + action_str, text_color=color.white, bgcolor=action_color, text_halign=text.align_center, text_size=size.large)
    table.merge_cells(tb, 0, 9, 1, 9)
````
