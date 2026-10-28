# DD-Screener: Breakout Columns

- url: https://www.tradingview.com/script/u8g9NiXj-DD-Screener-Breakout-Columns/
- type: indicator
- pine_id: PUB;e35a86f2b950411b810f8a2e15ce94d9
- version: 1.0

## Description

DD-Screener: Breakout Columns

What Screener DOES:

Scans your entire watchlist or a universe of stocks (S&P 500, NASDAQ, etc.) in real time
Filters stocks based on conditions — price above MA, volume spike, RSI levels etc.
Shows you a live ranked list of stocks meeting your criteria right now
Updates automatically every few seconds
You can add custom Pine Script conditions as screener columns
Sort by any column — so you can see "which stocks have highest volume right now"

What Screener CANNOT do:

Send push notifications
Alert your phone
Run in the background while you're not looking at it
Fire a webhook

## Source Code

````pine
//@version=5
// ─────────────────────────────────────────────────────────────────────────────
//  DD-Screener: Breakout Screener Columns
//
//  Add this to TradingView's Stock Screener as a custom indicator.
//  Each plot() becomes a sortable/filterable column in the screener.
//
//  HOW TO USE:
//  1. Go to TradingView Screener (bottom panel or screener.tradingview.com)
//  2. Click "Filters" → "Add Indicator" → search "DD-Screener"
//  3. Each column below appears as a filterable field
//  4. Sort by "BO Score" descending to see strongest setups at top
//
//  COLUMNS:
//  • BO Score      (0-5)  — overall breakout readiness score
//  • Vol Ratio     (x)    — current volume vs average
//  • Above PDH     (0/1)  — price closed above previous day high
//  • Below PDL     (0/1)  — price closed below previous day low
//  • Cloud Bull    (0/1)  — both Ripster clouds bullish
//  • Cloud Bear    (0/1)  — both Ripster clouds bearish
//  • Near Res      (0/1)  — price within 0.5% of resistance
//  • Near Sup      (0/1)  — price within 0.5% of support
//  • D Res Break   (0/1)  — daily resistance broken this bar
//  • D Sup Break   (0/1)  — daily support broken this bar
//  • 1H Res Break  (0/1)  — 1H resistance broken this bar
//  • 1H Sup Break  (0/1)  — 1H support broken this bar
// ─────────────────────────────────────────────────────────────────────────────
indicator(title="DD-Screener: Breakout Columns",
     shorttitle="DD-Screener", overlay=true)

// ══════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════
vol_lookback   = input.int(20,   "Volume Avg Lookback",     minval=5,   maxval=100)
vol_mult       = input.float(1.3,"Volume Spike Threshold",  minval=1.0, maxval=5.0, step=0.1)
near_pct       = input.float(0.5,"Near Level %",            minval=0.1, maxval=2.0, step=0.1,
     tooltip="Price is considered 'near' a level if within this % of it.")
d_pivot_left   = input.int(5,   "Daily Pivot Left",         minval=2,   maxval=20)
d_pivot_right  = input.int(3,   "Daily Pivot Right",        minval=1,   maxval=10)
d_lookback     = input.int(40,  "Daily Lookback",           minval=10,  maxval=200)
h1_pivot_left  = input.int(5,   "1H Pivot Left",            minval=2,   maxval=20)
h1_pivot_right = input.int(3,   "1H Pivot Right",           minval=1,   maxval=10)
h1_lookback    = input.int(50,  "1H Lookback",              minval=10,  maxval=200)

// ══════════════════════════════════════════════════════════
//  RIPSTER EMAs
// ══════════════════════════════════════════════════════════
ema5  = ta.ema(close, 5)
ema12 = ta.ema(close, 12)
ema34 = ta.ema(close, 34)
ema50 = ta.ema(close, 50)

cloud_3450_top = math.max(ema34, ema50)
cloud_3450_bot = math.min(ema34, ema50)
cloud_512_top  = math.max(ema5,  ema12)
cloud_512_bot  = math.min(ema5,  ema12)

cloud_bull = close > cloud_3450_top and close > cloud_512_top
cloud_bear = close < cloud_3450_bot and close < cloud_512_bot

// ══════════════════════════════════════════════════════════
//  VOLUME
// ══════════════════════════════════════════════════════════
avg_vol   = ta.sma(volume, vol_lookback)
vol_ratio = avg_vol > 0 ? volume / avg_vol : 1.0
vol_spike = vol_ratio >= vol_mult

// ══════════════════════════════════════════════════════════
//  PREVIOUS DAY HIGH / LOW
// ══════════════════════════════════════════════════════════
[_o, pdh, pdl, _c] = request.security(syminfo.tickerid, "D",
     [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

above_pdh = not na(pdh) and close > pdh
below_pdl = not na(pdl) and close < pdl

// ══════════════════════════════════════════════════════════
//  PIVOT DETECTION
// ══════════════════════════════════════════════════════════
f_pivot_high(int pl, int pr, int lb, int slot) =>
    float result = na
    int   count  = 0
    int   max_k  = math.min(lb + pr, bar_index)
    if max_k >= pr
        for k = pr to max_k
            float peak = high[k]
            bool  ok   = not na(peak)
            if ok
                for i = 1 to pl
                    if high[k + i] >= peak
                        ok := false
                for i = 1 to pr
                    if na(high[k - i]) or high[k - i] >= peak
                        ok := false
            if ok
                if count == slot
                    result := peak
                    break
                count += 1
    result

f_pivot_low(int pl, int pr, int lb, int slot) =>
    float result = na
    int   count  = 0
    int   max_k  = math.min(lb + pr, bar_index)
    if max_k >= pr
        for k = pr to max_k
            float trough = low[k]
            bool  ok     = not na(trough)
            if ok
                for i = 1 to pl
                    if low[k + i] <= trough
                        ok := false
                for i = 1 to pr
                    if na(low[k - i]) or low[k - i] <= trough
                        ok := false
            if ok
                if count == slot
                    result := trough
                    break
                count += 1
    result

// ══════════════════════════════════════════════════════════
//  FETCH PIVOT LEVELS
// ══════════════════════════════════════════════════════════
d_ph0  = request.security(syminfo.tickerid, "D",  f_pivot_high(d_pivot_left,  d_pivot_right,  d_lookback,  0), lookahead=barmerge.lookahead_off)
d_pl0  = request.security(syminfo.tickerid, "D",  f_pivot_low( d_pivot_left,  d_pivot_right,  d_lookback,  0), lookahead=barmerge.lookahead_off)
h1_ph0 = request.security(syminfo.tickerid, "60", f_pivot_high(h1_pivot_left, h1_pivot_right, h1_lookback, 0), lookahead=barmerge.lookahead_off)
h1_pl0 = request.security(syminfo.tickerid, "60", f_pivot_low( h1_pivot_left, h1_pivot_right, h1_lookback, 0), lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════
//  BREAKOUT / BREAKDOWN CONDITIONS
// ══════════════════════════════════════════════════════════

// Daily resistance break — close crosses above
d_res_break  = not na(d_ph0) and ta.crossover(close, d_ph0)

// Daily support break — close crosses below
d_sup_break  = not na(d_pl0) and ta.crossunder(close, d_pl0)

// 1H resistance break
h1_res_break = not na(h1_ph0) and ta.crossover(close, h1_ph0)

// 1H support break
h1_sup_break = not na(h1_pl0) and ta.crossunder(close, h1_pl0)

// ── Near Level Detection ──────────────────────────────────
// Price is within near_pct% of a level — about to test it
f_near(float lvl) =>
    not na(lvl) and math.abs(close - lvl) / lvl * 100 <= near_pct

near_d_res  = f_near(d_ph0)
near_d_sup  = f_near(d_pl0)
near_h1_res = f_near(h1_ph0)
near_h1_sup = f_near(h1_pl0)
near_pdh    = f_near(pdh)
near_pdl    = f_near(pdl)

near_res = near_d_res or near_h1_res or near_pdh
near_sup = near_d_sup or near_h1_sup or near_pdl

// ══════════════════════════════════════════════════════════
//  BREAKOUT SCORE (0 - 5)
//
//  Higher = stronger setup
//  5 = everything aligned, ready to break
//  0 = nothing interesting
//
//  Scoring:
//  +1  Volume spike
//  +1  Cloud alignment (bull or bear)
//  +1  Price near a key level (within near_pct%)
//  +1  PDH/PDL broken
//  +1  Any pivot level broken this bar
// ══════════════════════════════════════════════════════════
bo_score = 0
bo_score := bo_score + (vol_spike ? 1 : 0)
bo_score := bo_score + (cloud_bull or cloud_bear ? 1 : 0)
bo_score := bo_score + (near_res or near_sup ? 1 : 0)
bo_score := bo_score + (above_pdh or below_pdl ? 1 : 0)
bo_score := bo_score + (d_res_break or d_sup_break or h1_res_break or h1_sup_break ? 1 : 0)

// ══════════════════════════════════════════════════════════
//  DIRECTION BIAS
//  +1  = bullish setup
//  -1  = bearish setup
//   0  = neutral / mixed
// ══════════════════════════════════════════════════════════
bull_points = (cloud_bull ? 1 : 0) + (above_pdh ? 1 : 0) + (d_res_break or h1_res_break ? 1 : 0)
bear_points = (cloud_bear ? 1 : 0) + (below_pdl ? 1 : 0) + (d_sup_break or h1_sup_break ? 1 : 0)
direction   = bull_points > bear_points ? 1 : bear_points > bull_points ? -1 : 0

// ══════════════════════════════════════════════════════════
//  SCREENER COLUMNS
//  Each plot() = one sortable/filterable column in screener
// ══════════════════════════════════════════════════════════

// ── Primary columns ───────────────────────────────────────
plot(bo_score,            "BO Score",      color=bo_score >= 4 ? color.lime : bo_score >= 2 ? color.yellow : color.gray)
plot(math.round(vol_ratio * 100) / 100, "Vol Ratio",     color=vol_spike ? color.lime : color.gray)
plot(direction,           "Direction",     color=direction > 0 ? color.lime : direction < 0 ? color.red : color.gray)

// ── Level breaks (1 = yes, 0 = no) ───────────────────────
plot(above_pdh  ? 1 : 0,  "Above PDH",    color=above_pdh  ? color.lime : color.gray)
plot(below_pdl  ? 1 : 0,  "Below PDL",    color=below_pdl  ? color.red  : color.gray)
plot(d_res_break  ? 1 : 0,"D Res Break",  color=d_res_break  ? color.lime : color.gray)
plot(d_sup_break  ? 1 : 0,"D Sup Break",  color=d_sup_break  ? color.red  : color.gray)
plot(h1_res_break ? 1 : 0,"1H Res Break", color=h1_res_break ? color.lime : color.gray)
plot(h1_sup_break ? 1 : 0,"1H Sup Break", color=h1_sup_break ? color.red  : color.gray)

// ── Setup quality columns ─────────────────────────────────
plot(cloud_bull ? 1 : 0,  "Cloud Bull",   color=cloud_bull ? color.lime : color.gray)
plot(cloud_bear ? 1 : 0,  "Cloud Bear",   color=cloud_bear ? color.red  : color.gray)
plot(near_res   ? 1 : 0,  "Near Res",     color=near_res   ? color.yellow : color.gray)
plot(near_sup   ? 1 : 0,  "Near Sup",     color=near_sup   ? color.yellow : color.gray)

// ══════════════════════════════════════════════════════════
//  VISUAL ON CHART (when used on a regular chart)
// ══════════════════════════════════════════════════════════
bgcolor(bo_score >= 4 ? color.new(color.lime, 85) : bo_score >= 3 ? color.new(color.yellow, 85) : bo_score >= 2 ? color.new(color.orange, 92) : na, title="Breakout Score Background")

// Signal labels on chart
if d_res_break and vol_spike and cloud_bull
    label.new(bar_index, high, "🚀 D-Res\nBO",
         color=color.lime, textcolor=color.black,
         style=label.style_label_down, size=size.small)

if d_sup_break and vol_spike and cloud_bear
    label.new(bar_index, low, "💥 D-Sup\nBD",
         color=color.red, textcolor=color.white,
         style=label.style_label_up, size=size.small)

if h1_res_break and vol_spike and cloud_bull
    label.new(bar_index, high, "🔼 1H-Res\nBO",
         color=color.new(color.lime, 30), textcolor=color.black,
         style=label.style_label_down, size=size.tiny)

if h1_sup_break and vol_spike and cloud_bear
    label.new(bar_index, low, "🔽 1H-Sup\nBD",
         color=color.new(color.red, 30), textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

// ══════════════════════════════════════════════════════════
//  ALERT CONDITIONS
// ══════════════════════════════════════════════════════════
alertcondition(bo_score >= 4,
     title="🔥 High Score Breakout Setup (4-5)",
     message="{{ticker}} {{interval}} — BO Score 4-5. Strong setup. Close: {{close}} Vol: {{volume}}")

alertcondition(bo_score >= 3,
     title="⚡ Medium Score Breakout Setup (3+)",
     message="{{ticker}} {{interval}} — BO Score 3+. Setup forming. Close: {{close}}")

alertcondition(d_res_break and vol_spike and cloud_bull,
     title="🚀 CONFIRMED Daily Resistance Breakout",
     message="{{ticker}} {{interval}} — Daily Resistance broken with volume + bullish clouds. Close: {{close}}")

alertcondition(d_sup_break and vol_spike and cloud_bear,
     title="💥 CONFIRMED Daily Support Breakdown",
     message="{{ticker}} {{interval}} — Daily Support broken with volume + bearish clouds. Close: {{close}}")

alertcondition(h1_res_break and vol_spike and cloud_bull,
     title="🔼 CONFIRMED 1H Resistance Breakout",
     message="{{ticker}} {{interval}} — 1H Resistance broken with volume + bullish clouds. Close: {{close}}")

alertcondition(h1_sup_break and vol_spike and cloud_bear,
     title="🔽 CONFIRMED 1H Support Breakdown",
     message="{{ticker}} {{interval}} — 1H Support broken with volume + bearish clouds. Close: {{close}}")

alertcondition(near_res and vol_spike and cloud_bull,
     title="👀 Price approaching Resistance (bull setup)",
     message="{{ticker}} {{interval}} — Price near resistance with volume + bullish clouds. Watch for breakout. Close: {{close}}")

alertcondition(near_sup and vol_spike and cloud_bear,
     title="👀 Price approaching Support (bear setup)",
     message="{{ticker}} {{interval}} — Price near support with volume + bearish clouds. Watch for breakdown. Close: {{close}}")
````
