# Flexible Moving Averages with MACD and RSI 

- url: https://www.tradingview.com/script/CjWOn2zz-Flexible-Moving-Averages-with-MACD-and-RSI/
- type: indicator
- pine_id: PUB;4b13c9e42a1241bc81415520b48b6fb2
- version: 4.0

## Description

Every stock momentum can be identified either by crossing of higher EMA by lower EMA or MACD line crossing signal line and moving up or RSI value rising above 45 or 50. This indicator combines Moving averages with MACD and RSI

How to use:

Configure any or all of 5 moving averages according to your preference. It can be EMA or SMA. Configure symbols for MACD crossing or RSI rising. 

By default, if RSI crosses above 50, green triangle appears below candle. If RSI crosses 50 and comes down, red inverted triangle appears above candle

By default, if MACD line crosses signal line and moves above, green dot appears below candle. If MACD line crosses signal line and moves down, red dot appears above candle

These indications can give the user how much time RSI and MACD crossing happened along with EMA crossovers. User can take calculated decision and risk

## Source Code

````pine
//@version=6
indicator("Flexible MA + RSI Price Line", overlay = true)

// A DUPLICATE of FlexibleMA.pine, 11 Sep 2026. The original is unchanged and both can sit on one
// chart — the titles differ, so TradingView treats them as separate indicators.
//
// WHAT IS DIFFERENT FROM THE ORIGINAL
//   REMOVED  Section 8, the fundamentals table — and with it all 11 `request.financial` calls.
//            This file uses 5 of the ~40 request ceiling against the original's 16, so there is
//            real headroom for anything added later. Deleting was chosen over defaulting the
//            toggle off BECAUSE those calls sit at global scope and run whether the table is
//            drawn or not: switching it off would have freed nothing.
//   REMOVED  Section 10, the VWAP (line, σ bands and label).
//   ADDED    Section 10, the RSI PRICE LINE — see the block above it.
// Everything else — the five MAs, the signal shapes, the Golden/Death cross, the multi-timeframe
// RSI table and the EMA spread table — is byte-identical to the original.
//
// NOTE: To change MA line style (solid/dashed/dotted), right-click the indicator
// on chart → Settings → Style tab → click the line icon next to each MA.


// ─────────────────────────────────────────────
// SECTION 1: MOVING AVERAGE INPUTS
// ─────────────────────────────────────────────

bool   ma1_on    = input.bool  (true,  "MA 1 — Enable",                               group = "MA 1")
string ma1_type  = input.string("EMA", "MA 1 — Type",  options = ["EMA","SMA","HMA"], group = "MA 1")
int    ma1_len   = input.int   (9,     "MA 1 — Length", minval = 1,                   group = "MA 1")
color  ma1_color = input.color (color.yellow, "MA 1 — Color",                         group = "MA 1")

bool   ma2_on    = input.bool  (true,  "MA 2 — Enable",                               group = "MA 2")
string ma2_type  = input.string("EMA", "MA 2 — Type",  options = ["EMA","SMA","HMA"], group = "MA 2")
int    ma2_len   = input.int   (21,    "MA 2 — Length", minval = 1,                   group = "MA 2")
color  ma2_color = input.color (color.orange, "MA 2 — Color",                         group = "MA 2")

bool   ma3_on    = input.bool  (true,  "MA 3 — Enable",                               group = "MA 3")
string ma3_type  = input.string("SMA", "MA 3 — Type",  options = ["EMA","SMA","HMA"], group = "MA 3")
int    ma3_len   = input.int   (50,    "MA 3 — Length", minval = 1,                   group = "MA 3")
color  ma3_color = input.color (color.blue,   "MA 3 — Color",                         group = "MA 3")

bool   ma4_on    = input.bool  (true,  "MA 4 — Enable",                               group = "MA 4")
string ma4_type  = input.string("SMA", "MA 4 — Type",  options = ["EMA","SMA","HMA"], group = "MA 4")
int    ma4_len   = input.int   (100,   "MA 4 — Length", minval = 1,                   group = "MA 4")
color  ma4_color = input.color (color.red,    "MA 4 — Color",                         group = "MA 4")

bool   ma5_on    = input.bool  (true,  "MA 5 — Enable",                               group = "MA 5")
string ma5_type  = input.string("SMA", "MA 5 — Type",  options = ["EMA","SMA","HMA"], group = "MA 5")
int    ma5_len   = input.int   (200,   "MA 5 — Length", minval = 1,                   group = "MA 5")
color  ma5_color = input.color (color.white,  "MA 5 — Color",                         group = "MA 5")


// ─────────────────────────────────────────────
// SECTION 2: SIGNAL ENABLE + SHAPE INPUTS
// One shape choice for RSI signals (2 signals share same shape).
// One shape choice for MACD signals (4 signals share same shape).
// Color and position (above/below) are fixed per signal logic.
//
// The two Enable switches mirror the Golden/Death Cross pattern in Section 6: they gate the
// SIGNAL BOOLEANS themselves (Section 3), not each individual plotshape. One flag off means all
// of that family's markers vanish — 2 for RSI, 4 for MACD — and there is no way for a stray
// plotshape to be left behind when a new one is added later.
// ─────────────────────────────────────────────

bool   rsi_on   = input.bool  (true, "Enable RSI 50-cross signals",  group = "Signal Shapes",
     tooltip = "Marker whenever RSI(14) crosses 50 — green below the bar on the way up, " +
               "red above the bar on the way down. Turn off to clear both from the chart.")
string shp_rsi  = input.string("Triangle", "RSI Signal Shape",  options = ["Circle","Triangle","Square","Diamond"], group = "Signal Shapes")

bool   macd_on  = input.bool  (true, "Enable MACD cross signals", group = "Signal Shapes",
     tooltip = "Markers for all four MACD × Signal crosses (above and below the zero line). " +
               "Turn off to clear the whole second row of markers from the chart.")
string shp_macd = input.string("Circle",   "MACD Signal Shape", options = ["Circle","Triangle","Square","Diamond"], group = "Signal Shapes")


// ─────────────────────────────────────────────
// SECTION 3: CALCULATIONS
// ─────────────────────────────────────────────

f_ma(string t, int l) =>
    if t == "HMA"
        int half = math.max(l / 2, 1)
        int sqrtl = math.max(math.round(math.sqrt(l)), 1)
        ta.wma(2 * ta.wma(close, half) - ta.wma(close, l), sqrtl)
    else if t == "EMA"
        ta.ema(close, l)
    else
        ta.sma(close, l)

float ma1_val = ma1_on ? f_ma(ma1_type, ma1_len) : na
float ma2_val = ma2_on ? f_ma(ma2_type, ma2_len) : na
float ma3_val = ma3_on ? f_ma(ma3_type, ma3_len) : na
float ma4_val = ma4_on ? f_ma(ma4_type, ma4_len) : na
float ma5_val = ma5_on ? f_ma(ma5_type, ma5_len) : na

[macd_line, signal_line, hist] = ta.macd(close, 12, 26, 9)
float rsi_val = ta.rsi(close, 14)

// Gated at the SOURCE, exactly like `golden_cross`/`death_cross` in Section 6 — every downstream
// plotshape and the ATR-offset position variables all read from these, so one switch is enough.
bool sig_rsi_above = rsi_on  and ta.crossover (rsi_val, 50)
bool sig_rsi_below = rsi_on  and ta.crossunder(rsi_val, 50)
bool sig_macd_ub   = macd_on and ta.crossover (macd_line, signal_line) and macd_line > 0
bool sig_macd_bb   = macd_on and ta.crossover (macd_line, signal_line) and macd_line < 0
bool sig_sig_ua    = macd_on and ta.crossunder(macd_line, signal_line) and macd_line > 0
bool sig_sig_ba    = macd_on and ta.crossunder(macd_line, signal_line) and macd_line < 0


// ─────────────────────────────────────────────
// SECTION 4: PLOTS — Moving Averages
// ─────────────────────────────────────────────

plot(ma1_val, "MA 1", color = ma1_color, linewidth = 1)
plot(ma2_val, "MA 2", color = ma2_color, linewidth = 1)
plot(ma3_val, "MA 3", color = ma3_color, linewidth = 1)
plot(ma4_val, "MA 4", color = ma4_color, linewidth = 1)
plot(ma5_val, "MA 5", color = ma5_color, linewidth = 1)


// ─────────────────────────────────────────────
// SECTION 4b: END-OF-LINE MA LABELS
// ─────────────────────────────────────────────

var label lbl_ma1 = na
var label lbl_ma2 = na
var label lbl_ma3 = na
var label lbl_ma4 = na
var label lbl_ma5 = na

if barstate.islast
    label.delete(lbl_ma1)
    label.delete(lbl_ma2)
    label.delete(lbl_ma3)
    label.delete(lbl_ma4)
    label.delete(lbl_ma5)

    if ma1_on
        lbl_ma1 := label.new(bar_index + 1, ma1_val, ma1_type + str.tostring(ma1_len),
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(ma1_color, 70), style = label.style_label_left,
             textcolor = ma1_color, size = size.small)

    if ma2_on
        lbl_ma2 := label.new(bar_index + 1, ma2_val, ma2_type + str.tostring(ma2_len),
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(ma2_color, 70), style = label.style_label_left,
             textcolor = ma2_color, size = size.small)

    if ma3_on
        lbl_ma3 := label.new(bar_index + 1, ma3_val, ma3_type + str.tostring(ma3_len),
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(ma3_color, 70), style = label.style_label_left,
             textcolor = ma3_color, size = size.small)

    if ma4_on
        lbl_ma4 := label.new(bar_index + 1, ma4_val, ma4_type + str.tostring(ma4_len),
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(ma4_color, 70), style = label.style_label_left,
             textcolor = ma4_color, size = size.small)

    if ma5_on
        lbl_ma5 := label.new(bar_index + 1, ma5_val, ma5_type + str.tostring(ma5_len),
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(ma5_color, 70), style = label.style_label_left,
             textcolor = ma5_color, size = size.small)


// ─────────────────────────────────────────────
// SECTION 5: PLOTS — Signal Shapes
//
// RSI  → location.belowbar / abovebar  — row 1, glued to candle
// MACD → location.absolute at low - ATR / high + ATR — row 2, just below RSI
//
// ATR offset keeps MACD one step further than RSI but still near the candle.
// editable=false keeps the Style tab clean.
// ─────────────────────────────────────────────

float atr_gap = ta.atr(14) * 0.8   // distance of MACD row from candle

// Pre-declare MACD absolute positions (v6 type-safe pattern)
float macd_bull_pos = na
float macd_bear_pos = na

if sig_macd_ub or sig_macd_bb
    macd_bull_pos := low - atr_gap
if sig_sig_ua or sig_sig_ba
    macd_bear_pos := high + atr_gap

// For shape-specific conditions at absolute positions
float macd_ub_pos  = sig_macd_ub ? low  - atr_gap : na
float macd_bb_pos  = sig_macd_bb ? low  - atr_gap : na
float macd_ua_pos  = sig_sig_ua  ? high + atr_gap : na
float macd_ba_pos  = sig_sig_ba  ? high + atr_gap : na

// ── RSI > 50 — green, row 1 below candle ─────
plotshape(sig_rsi_above and shp_rsi == "Circle",   "RSI>50", shape.circle,      location.belowbar, color.green, size=size.tiny, editable=false)
plotshape(sig_rsi_above and shp_rsi == "Triangle", "RSI>50", shape.triangleup,  location.belowbar, color.green, size=size.tiny, editable=false)
plotshape(sig_rsi_above and shp_rsi == "Square",   "RSI>50", shape.square,      location.belowbar, color.green, size=size.tiny, editable=false)
plotshape(sig_rsi_above and shp_rsi == "Diamond",  "RSI>50", shape.diamond,     location.belowbar, color.green, size=size.tiny, editable=false)

// ── RSI < 50 — red, row 1 above candle ───────
plotshape(sig_rsi_below and shp_rsi == "Circle",   "RSI<50", shape.circle,       location.abovebar, color.red, size=size.tiny, editable=false)
plotshape(sig_rsi_below and shp_rsi == "Triangle", "RSI<50", shape.triangledown, location.abovebar, color.red, size=size.tiny, editable=false)
plotshape(sig_rsi_below and shp_rsi == "Square",   "RSI<50", shape.square,       location.abovebar, color.red, size=size.tiny, editable=false)
plotshape(sig_rsi_below and shp_rsi == "Diamond",  "RSI<50", shape.diamond,      location.abovebar, color.red, size=size.tiny, editable=false)

// ── MACD × Signal above zero — green, row 2 below candle ─────
plotshape(shp_macd == "Circle"   ? macd_ub_pos : na, "MACD Bull↑0", shape.circle,     location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Triangle" ? macd_ub_pos : na, "MACD Bull↑0", shape.triangleup, location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Square"   ? macd_ub_pos : na, "MACD Bull↑0", shape.square,     location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Diamond"  ? macd_ub_pos : na, "MACD Bull↑0", shape.diamond,    location.absolute, color.lime, size=size.tiny, editable=false)

// ── MACD × Signal below zero — green, row 2 below candle ─────
plotshape(shp_macd == "Circle"   ? macd_bb_pos : na, "MACD Bull↓0", shape.circle,     location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Triangle" ? macd_bb_pos : na, "MACD Bull↓0", shape.triangleup, location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Square"   ? macd_bb_pos : na, "MACD Bull↓0", shape.square,     location.absolute, color.lime, size=size.tiny, editable=false)
plotshape(shp_macd == "Diamond"  ? macd_bb_pos : na, "MACD Bull↓0", shape.diamond,    location.absolute, color.lime, size=size.tiny, editable=false)

// ── Signal × MACD above zero — red, row 2 above candle ───────
plotshape(shp_macd == "Circle"   ? macd_ua_pos : na, "Sig Bear↑0", shape.circle,       location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Triangle" ? macd_ua_pos : na, "Sig Bear↑0", shape.triangledown, location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Square"   ? macd_ua_pos : na, "Sig Bear↑0", shape.square,       location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Diamond"  ? macd_ua_pos : na, "Sig Bear↑0", shape.diamond,      location.absolute, color.orange, size=size.tiny, editable=false)

// ── Signal × MACD below zero — red, row 2 above candle ───────
plotshape(shp_macd == "Circle"   ? macd_ba_pos : na, "Sig Bear↓0", shape.circle,       location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Triangle" ? macd_ba_pos : na, "Sig Bear↓0", shape.triangledown, location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Square"   ? macd_ba_pos : na, "Sig Bear↓0", shape.square,       location.absolute, color.orange, size=size.tiny, editable=false)
plotshape(shp_macd == "Diamond"  ? macd_ba_pos : na, "Sig Bear↓0", shape.diamond,      location.absolute, color.orange, size=size.tiny, editable=false)


// ─────────────────────────────────────────────
// SECTION 6: GOLDEN / DEATH CROSS (SMA50 × SMA200)
//
// Computed independently from the MA 1-5 panel so the signal
// is never affected by what the user has configured above.
// Toggle the whole feature on/off with the single Enable input.
// ─────────────────────────────────────────────

bool gc_on = input.bool(true, "Enable Golden / Death Cross", group = "Golden / Death Cross",
     tooltip = "Shows a labelled marker and background flash whenever SMA50 crosses SMA200. " +
               "Always uses plain SMA(50) and SMA(200) regardless of MA 1-5 settings.")

// Fixed-period SMAs used only for the crossover signal
float gc_sma50  = ta.sma(close, 50)
float gc_sma200 = ta.sma(close, 200)

bool golden_cross = gc_on and ta.crossover (gc_sma50, gc_sma200)
bool death_cross  = gc_on and ta.crossunder(gc_sma50, gc_sma200)

// ── Callout label on the crossover bar ───────────────────────
if golden_cross
    label.new(bar_index, na,
         "🌟 Golden Cross\nSMA50 ↑ SMA200",
         xloc      = xloc.bar_index,
         yloc      = yloc.belowbar,
         style     = label.style_label_up,
         color     = color.new(color.yellow, 10),
         textcolor = color.black,
         size      = size.normal)

if death_cross
    label.new(bar_index, na,
         "💀 Death Cross\nSMA50 ↓ SMA200",
         xloc      = xloc.bar_index,
         yloc      = yloc.abovebar,
         style     = label.style_label_down,
         color     = color.new(color.red, 10),
         textcolor = color.white,
         size      = size.normal)

// ── Background flash on the crossover bar ────────────────────
bgcolor(golden_cross ? color.new(color.yellow, 75) :
        death_cross  ? color.new(color.red,    75) : na,
        title = "Golden/Death Cross Background")


// ─────────────────────────────────────────────
// SECTION 7: MULTI-TIMEFRAME RSI TABLE  (Daily / Weekly / Monthly)
//
// WHY THIS EXISTS: every signal above (Section 5) is CHART-TIMEFRAME ONLY — on a daily chart the
// RSI markers are daily RSI and there is nothing telling you where weekly and monthly sit. This
// table answers "is the higher timeframe with me or against me" without switching charts.
//
// Reads: value on each timeframe, which side of 50 it is on, and how many of that timeframe's OWN
// bars ago it last crossed 50 (so "▼ 3 ago" on the weekly row means three WEEKS ago).
//
// REPAINTING — the honest note: `request.security` with the default lookahead_off shows the
// DEVELOPING higher-timeframe value on the live bar, which is exactly what you want in a status
// table (it matches what you would see opening a weekly chart right now). It does mean the weekly
// figure keeps moving until Friday's close. Nothing here plots historical shapes, so there is no
// hindsight signal to be misled by.
// ─────────────────────────────────────────────

bool   rt_on   = input.bool  (true, "Show RSI D/W/M table", group = "RSI Table")
string rt_pos  = input.string("Top Right", "Table position",
     options = ["Top Left","Top Center","Top Right",
                "Middle Left","Middle Center","Middle Right",
                "Bottom Left","Bottom Center","Bottom Right"],
     tooltip = "Any of the nine anchor points in the chart window.", group = "RSI Table")
int    rt_len  = input.int   (14, "RSI length", minval = 2, maxval = 100, group = "RSI Table")
string rt_size = input.string("Normal", "Text size", options = ["Tiny","Small","Normal","Large"], group = "RSI Table")
bool   rt_since = input.bool (true, "Show how long since the 50-cross", group = "RSI Table")

f_rt_pos(string p) =>
    p == "Top Left"      ? position.top_left      :
     p == "Top Center"    ? position.top_center    :
     p == "Top Right"     ? position.top_right     :
     p == "Middle Left"   ? position.middle_left   :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right"  ? position.middle_right  :
     p == "Bottom Left"   ? position.bottom_left   :
     p == "Bottom Center" ? position.bottom_center : position.bottom_right

f_rt_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

// request.security must stay at global scope — never inside an if/for block.
// The tuple returns the RSI and the bars-since-cross together so both come from one call.
//
// 4H uses "240" (minutes) — the form TradingView resolves most reliably.
// ⚠️ Requesting a timeframe LOWER than the chart's is unreliable by design: on a daily or weekly
// chart there is no intraday context to pull from and the value comes back na or misleading. So
// the 4H row is only trusted when the chart is on 4H or below, and says why when it is not,
// rather than printing a number that cannot be relied on.
// Each call returns THREE things for that timeframe: the RSI, bars since it last crossed 50, and
// the change against the previous bar of that same timeframe. Computing the delta inside the
// request means it is a genuine higher-timeframe move — comparing two chart-bar samples of a
// weekly value would mostly show zero, since the weekly RSI only changes when its own bar does.
// Bars per NSE session: 09:15–15:30 (6h15m) → 1H 7, 4H 2. NOTE from 3 Aug 2026 an F&O stock's
// CONTINUOUS session is 09:15–15:15 (6h) → 1H 6, 4H still 2. Comment only: the counts below come
// from request.security("60"/"240"), which TradingView resolves against the exchange session.
bool rt_1h_ok = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("60")
bool rt_4h_ok = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("240")
[rt_h1, rt_h1x, rt_h1d] = request.security(syminfo.tickerid, "60",
     [ta.rsi(close, rt_len), ta.barssince(ta.cross(ta.rsi(close, rt_len), 50)),
      ta.rsi(close, rt_len) - ta.rsi(close, rt_len)[1]])
[rt_h4, rt_h4x, rt_h4d] = request.security(syminfo.tickerid, "240",
     [ta.rsi(close, rt_len), ta.barssince(ta.cross(ta.rsi(close, rt_len), 50)),
      ta.rsi(close, rt_len) - ta.rsi(close, rt_len)[1]])
[rt_d, rt_dx, rt_dd] = request.security(syminfo.tickerid, "D",
     [ta.rsi(close, rt_len), ta.barssince(ta.cross(ta.rsi(close, rt_len), 50)),
      ta.rsi(close, rt_len) - ta.rsi(close, rt_len)[1]])
[rt_w, rt_wx, rt_wd] = request.security(syminfo.tickerid, "W",
     [ta.rsi(close, rt_len), ta.barssince(ta.cross(ta.rsi(close, rt_len), 50)),
      ta.rsi(close, rt_len) - ta.rsi(close, rt_len)[1]])
[rt_m, rt_mx, rt_md] = request.security(syminfo.tickerid, "M",
     [ta.rsi(close, rt_len), ta.barssince(ta.cross(ta.rsi(close, rt_len), 50)),
      ta.rsi(close, rt_len) - ta.rsi(close, rt_len)[1]])

// Palette — measured against the table's own background, which is black at 12% transparency and
// therefore near-black (~#141414) on ANY chart theme. WCAG-AA wants 4.5:1 for text this size:
//   #d73027 (the original red) = 3.81  FAILS — it muddied into the dark grey
//   #ef5350 (this red)         = 5.28  passes, and sits closest in weight to the green
//   #1a9850 (green)            = 4.96  passes  ·  #e08b2f (amber) = 6.93 passes
// Green and amber were already fine, so only the red moved.
color RT_RED   = #ef5350
color RT_GREEN = #1a9850
color RT_AMBER = #e08b2f

// Text colour says ONLY which side of 50 it is on, so it can never be ambiguous.
// A background tint carries the second message — 65+ is getting warm, 70+ is stretched.
f_rt_txt(float v) =>
    na(v) ? color.gray : v >= 50 ? RT_GREEN : RT_RED

// fully-transparent rather than `na` — a na colour argument is the kind of thing that trips the
// compiler on some builds, and transparent renders identically
f_rt_bg(float v) =>
    na(v) ? color.new(color.black, 100) :
     v >= 70 ? color.new(RT_RED,   78) :
     v >= 65 ? color.new(RT_AMBER, 78) : color.new(color.black, 100)

f_rt_state(float v) =>
    na(v) ? "—" : v >= 50 ? "▲ above" : "▼ below"

// Direction of travel against the PREVIOUS bar of the same timeframe. Deliberately separate from
// the "vs 50" column: a stock can be below 50 and rising (turning up) or above 50 and falling
// (rolling over), and those two states are the interesting ones — a single colour cannot say both.
f_rt_dir(float d) =>
    na(d) ? "—" :
     d > 0 ? "▲ +" + str.tostring(d, "#.0") :
     d < 0 ? "▼ "  + str.tostring(d, "#.0") : "→ flat"

f_rt_dircol(float d) =>
    na(d) or d == 0 ? color.gray : d > 0 ? RT_GREEN : RT_RED

// "#" forces whole-number formatting — math.round() still returns a float, and the default
// str.tostring() of a float can print a decimal point we do not want in a compact cell.
f_rt_ago(float v, float bars, string unit) =>
    na(v) or na(bars) ? "—" :
     (v >= 50 ? "▲ " : "▼ ") + str.tostring(math.round(bars), "#") + unit

// Always 5 columns × 7 rows — the "Since" column is simply left blank when switched off. Sizing
// the table from an input would make `columns` a non-constant, which is exactly the sort of
// qualifier mismatch that fails to compile.
// Columns: 0 timeframe · 1 value · 2 direction · 3 vs 50 · 4 since
// Rows:    0 header · 1 1H · 2 4H · 3 Daily · 4 Weekly · 5 Monthly · 6 Aligned
var table rt_tbl = table.new(f_rt_pos(rt_pos), 5, 7,
     bgcolor = color.new(color.black, 12), frame_color = color.new(color.gray, 40),
     frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if rt_on and barstate.islast
    string sz = f_rt_size(rt_size)

    // header — bold via text_formatting, and brighter than the body text so it reads as a heading
    table.cell(rt_tbl, 0, 0, "RSI " + str.tostring(rt_len), text_color = color.white, text_size = sz,
         text_formatting = text.format_bold)
    table.cell(rt_tbl, 1, 0, "Value", text_color = color.white, text_size = sz,
         text_formatting = text.format_bold)
    table.cell(rt_tbl, 2, 0, "Dir",   text_color = color.white, text_size = sz,
         text_formatting = text.format_bold,
         tooltip = "Change in RSI against the PREVIOUS bar of that same timeframe — is it rising or falling right now. " +
                   "Read together with 'vs 50': below 50 and rising is a turn up, above 50 and falling is a roll over.")
    table.cell(rt_tbl, 3, 0, "vs 50", text_color = color.white, text_size = sz,
         text_formatting = text.format_bold)
    if rt_since
        table.cell(rt_tbl, 4, 0, "Since", text_color = color.white, text_size = sz,
             text_formatting = text.format_bold,
             tooltip = "How many bars of THAT timeframe since RSI last crossed 50, and which way it went. " +
                       "'×1H' = 1-hour bars (7 per NSE session) · '×4H' = 4-hour bars (2 per session) · " +
                       "'d' = days · 'w' = weeks · 'mo' = months.")

    // ── 1H — fastest first, so the rows read fastest → slowest down the table
    table.cell(rt_tbl, 0, 1, "1H", text_color = color.silver, text_size = sz)
    if rt_1h_ok
        table.cell(rt_tbl, 1, 1, na(rt_h1) ? "—" : str.tostring(rt_h1, "#.0"),
             text_color = f_rt_txt(rt_h1), bgcolor = f_rt_bg(rt_h1), text_size = sz)
        table.cell(rt_tbl, 2, 1, f_rt_dir(rt_h1d),   text_color = f_rt_dircol(rt_h1d), text_size = sz)
        table.cell(rt_tbl, 3, 1, f_rt_state(rt_h1),  text_color = f_rt_txt(rt_h1),     text_size = sz)
        if rt_since
            table.cell(rt_tbl, 4, 1, f_rt_ago(rt_h1, rt_h1x, "×1H"), text_color = color.silver, text_size = sz)
    else
        table.cell(rt_tbl, 1, 1, "—", text_color = color.gray, text_size = sz)
        table.cell(rt_tbl, 2, 1, "",  text_size = sz)
        table.cell(rt_tbl, 3, 1, "chart TF > 1H", text_color = color.gray, text_size = sz,
             tooltip = "TradingView cannot reliably serve a timeframe lower than the chart's own. " +
                       "Open a 1-hour chart (or lower) and this row fills in.")
        if rt_since
            table.cell(rt_tbl, 4, 1, "", text_size = sz)

    // ── 4H
    table.cell(rt_tbl, 0, 2, "4H", text_color = color.silver, text_size = sz)
    if rt_4h_ok
        table.cell(rt_tbl, 1, 2, na(rt_h4) ? "—" : str.tostring(rt_h4, "#.0"),
             text_color = f_rt_txt(rt_h4), bgcolor = f_rt_bg(rt_h4), text_size = sz)
        table.cell(rt_tbl, 2, 2, f_rt_dir(rt_h4d),   text_color = f_rt_dircol(rt_h4d), text_size = sz)
        table.cell(rt_tbl, 3, 2, f_rt_state(rt_h4),  text_color = f_rt_txt(rt_h4),     text_size = sz)
        if rt_since
            // "×4H" not a bare "b": bars-per-day is exchange-specific — an NSE session is
            // 09:15–15:30 (6h15m) so it yields exactly TWO 4H bars a day, a 24h crypto chart six.
            // (An F&O stock is 6h under CAS from 3 Aug 2026 — still two 4H bars.)
            table.cell(rt_tbl, 4, 2, f_rt_ago(rt_h4, rt_h4x, "×4H"), text_color = color.silver, text_size = sz)
    else
        table.cell(rt_tbl, 1, 2, "—", text_color = color.gray, text_size = sz)
        table.cell(rt_tbl, 2, 2, "",  text_size = sz)
        table.cell(rt_tbl, 3, 2, "chart TF > 4H", text_color = color.gray, text_size = sz,
             tooltip = "TradingView cannot reliably serve a timeframe lower than the chart's own. " +
                       "Open a 4-hour chart (or lower) and this row fills in.")
        if rt_since
            table.cell(rt_tbl, 4, 2, "", text_size = sz)

    // ── Daily / Weekly / Monthly
    table.cell(rt_tbl, 0, 3, "Daily", text_color = color.silver, text_size = sz)
    table.cell(rt_tbl, 1, 3, na(rt_d) ? "—" : str.tostring(rt_d, "#.0"),
         text_color = f_rt_txt(rt_d), bgcolor = f_rt_bg(rt_d), text_size = sz)
    table.cell(rt_tbl, 2, 3, f_rt_dir(rt_dd),  text_color = f_rt_dircol(rt_dd), text_size = sz)
    table.cell(rt_tbl, 3, 3, f_rt_state(rt_d), text_color = f_rt_txt(rt_d),     text_size = sz)
    if rt_since
        table.cell(rt_tbl, 4, 3, f_rt_ago(rt_d, rt_dx, "d"), text_color = color.silver, text_size = sz)

    table.cell(rt_tbl, 0, 4, "Weekly", text_color = color.silver, text_size = sz)
    table.cell(rt_tbl, 1, 4, na(rt_w) ? "—" : str.tostring(rt_w, "#.0"),
         text_color = f_rt_txt(rt_w), bgcolor = f_rt_bg(rt_w), text_size = sz)
    table.cell(rt_tbl, 2, 4, f_rt_dir(rt_wd),  text_color = f_rt_dircol(rt_wd), text_size = sz)
    table.cell(rt_tbl, 3, 4, f_rt_state(rt_w), text_color = f_rt_txt(rt_w),     text_size = sz)
    if rt_since
        table.cell(rt_tbl, 4, 4, f_rt_ago(rt_w, rt_wx, "w"), text_color = color.silver, text_size = sz)

    table.cell(rt_tbl, 0, 5, "Monthly", text_color = color.silver, text_size = sz)
    table.cell(rt_tbl, 1, 5, na(rt_m) ? "—" : str.tostring(rt_m, "#.0"),
         text_color = f_rt_txt(rt_m), bgcolor = f_rt_bg(rt_m), text_size = sz)
    table.cell(rt_tbl, 2, 5, f_rt_dir(rt_md),  text_color = f_rt_dircol(rt_md), text_size = sz)
    table.cell(rt_tbl, 3, 5, f_rt_state(rt_m), text_color = f_rt_txt(rt_m),     text_size = sz)
    if rt_since
        table.cell(rt_tbl, 4, 5, f_rt_ago(rt_m, rt_mx, "mo"), text_color = color.silver, text_size = sz)

    // Summary counts DAILY / WEEKLY / MONTHLY only — those three are the regime timeframes the
    // 6-year study was run on. 1H and 4H are entry timing, not regime, and are deliberately NOT
    // counted so the number keeps the same meaning it has on the desk.
    int n_up = (na(rt_d) or rt_d < 50 ? 0 : 1) + (na(rt_w) or rt_w < 50 ? 0 : 1) +
               (na(rt_m) or rt_m < 50 ? 0 : 1)
    color sum_col = n_up == 3 ? RT_GREEN : n_up == 2 ? RT_AMBER : RT_RED
    table.cell(rt_tbl, 0, 6, "Aligned", text_color = color.silver, text_size = sz,
         tooltip = "Counts Daily, Weekly and Monthly — the regime timeframes. 1H and 4H are shown for entry timing but not counted.")
    table.cell(rt_tbl, 1, 6, str.tostring(n_up) + " / 3", text_color = sum_col, text_size = sz)
    table.cell(rt_tbl, 2, 6, "", text_size = sz)
    table.cell(rt_tbl, 3, 6, n_up == 3 ? "all above" : n_up == 0 ? "all below" : "mixed",
         text_color = sum_col, text_size = sz)
    if rt_since
        table.cell(rt_tbl, 4, 6, "", text_size = sz)


// ─────────────────────────────────────────────
// SECTION 9: EMA SPREAD TABLE  (EMA9 − EMA21, added 20 Aug 2026)
//
// The raw distance between the fast and slow EMA, its sign, and how long that sign has held.
// The sign is the same information the 9/21 crossover gives, but the DISTANCE and the RUN LENGTH
// are not on the chart anywhere else: a cross that happened two bars ago and one that has held for
// forty look identical as a line crossing, and a spread that is widening reads very differently
// from one closing back toward zero.
//
// ⚠️ COSTS NO REQUEST SLOTS. Both EMAs come from the chart symbol's own `close`, so there is no
//    request.security / request.financial call here. The file's budget is unchanged at 16 of ~40
//    (5 request.security + 11 request.financial) — see the note above Section 8.
//
// These EMAs are DELIBERATELY INDEPENDENT of the five configurable MAs in Section 1. Those are
// user-set in both type and length, so wiring this table to MA1/MA2 would make the header lie the
// moment somebody switched MA1 to an SMA200. The lengths are inputs defaulting to 9 and 21, which
// is what was asked for; change them and the header follows.
//
// "Floating" here means Pine's nine anchor positions. A table attaches to one of them; Pine has no
// free-pixel dragging for tables. Defaults to Middle Right so it clears the RSI table (Top Right)
// and the fundamentals table (Bottom Right) with no configuration.
//
// REUSES f_rt_pos() / f_rt_size() and the RT_GREEN / RT_RED / RT_AMBER palette from Section 7, for
// the same reason Section 8 does: one palette means the tables cannot drift apart visually.
//
// ⚠️ EVERY construct below is one already used elsewhere in this file. This script has never been
//    compiled, so this is not the place to introduce something unproven: the signed numbers are
//    built by concatenating "+" exactly as the RSI table's direction cell does at Section 7,
//    rather than with a "+#.##;-#.##" sub-pattern, and nothing here calls str.replace_all.
// ─────────────────────────────────────────────

bool   es_on   = input.bool  (true, "Show EMA spread table", group = "EMA Spread",
     tooltip = "Fast EMA minus slow EMA, in price units, with the sign and how long it has held. " +
               "Green when the fast EMA is above the slow one, red when it is below.")
int    es_fast = input.int   (9,  "Fast EMA length", minval = 1, group = "EMA Spread")
int    es_slow = input.int   (21, "Slow EMA length", minval = 2, group = "EMA Spread")
string es_pos  = input.string("Middle Right", "Table position",
     options = ["Top Left","Top Center","Top Right",
                "Middle Left","Middle Center","Middle Right",
                "Bottom Left","Bottom Center","Bottom Right"],
     tooltip = "Defaults to Middle Right so it lands on neither the RSI table (Top Right) nor " +
               "the fundamentals table (Bottom Right).", group = "EMA Spread")
string es_size = input.string("Small", "Text size", options = ["Tiny","Small","Normal","Large"],
     group = "EMA Spread")
bool   es_pct  = input.bool  (true, "Show spread as % of price", group = "EMA Spread",
     tooltip = "The absolute spread is in rupees, so it cannot be compared between a ₹90 stock " +
               "and a ₹9,000 one. The percentage can be.")

float es_fastv = ta.ema(close, es_fast)
float es_slowv = ta.ema(close, es_slow)
float es_val   = es_fastv - es_slowv                  // the formula asked for: EMA9 − EMA21
float es_pc    = close != 0 ? es_val / close * 100 : na

// 3-state sign so an exact zero is neither green nor red, which a bare `> 0` test would get wrong
// by lumping it in with "negative". Never holds na — the display guards on na(es_val) instead,
// because this file has no precedent for an `int` variable carrying na.
int es_sign = na(es_val) ? 0 : es_val > 0 ? 1 : es_val < 0 ? -1 : 0

// How long the CURRENT sign has held, in bars of the chart's timeframe. Counted rather than taken
// from ta.barssince(), which returns na until a flip has actually occurred — on a symbol that has
// never crossed inside the loaded history that would print a blank instead of the correct, and
// more useful, full run length.
var int es_run = 0
es_run := na(es_val) ? 0 : (na(es_val[1]) or es_sign != es_sign[1] ? 1 : es_run + 1)

// Is the gap opening or closing? A shrinking positive spread is the fast EMA rolling back toward
// the slow one — what precedes a cross — and that is invisible from the sign alone.
string es_dir = na(es_val) or na(es_val[1]) ? "" :
     math.abs(es_val) > math.abs(es_val[1]) ? "▲ widening" :
     math.abs(es_val) < math.abs(es_val[1]) ? "▼ narrowing" : "= flat"

color es_col = na(es_val) ? color.gray : es_sign > 0 ? RT_GREEN : es_sign < 0 ? RT_RED : RT_AMBER

// signed text, built the same way Section 7's direction cell does it
string es_vtx = na(es_val) ? "—" : (es_val > 0 ? "+" : "") + str.tostring(es_val, "#.##")
string es_ptx = na(es_pc)  ? "—" : (es_pc  > 0 ? "+" : "") + str.tostring(es_pc,  "#.##") + "%"

var table es_tbl = table.new(f_rt_pos(es_pos), 2, 4,
     bgcolor = color.new(color.black, 12), frame_color = color.new(color.gray, 40),
     frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if es_on and barstate.islast
    string esz = f_rt_size(es_size)

    // header carries the actual lengths, so it stays honest if the inputs are changed
    table.cell(es_tbl, 0, 0, "EMA" + str.tostring(es_fast) + " − EMA" + str.tostring(es_slow),
         text_color = color.white, text_size = esz, text_formatting = text.format_bold)
    table.cell(es_tbl, 1, 0,
         na(es_val) ? "—" : es_sign > 0 ? "ABOVE" : es_sign < 0 ? "BELOW" : "EQUAL",
         text_color = es_col, text_size = esz, text_formatting = text.format_bold)

    table.cell(es_tbl, 0, 1, "Spread", text_color = color.silver, text_size = esz)
    table.cell(es_tbl, 1, 1, es_vtx,
         text_color = es_col, text_size = esz, text_formatting = text.format_bold)

    table.cell(es_tbl, 0, 2, es_pct ? "% of price" : "Gap", text_color = color.silver, text_size = esz)
    table.cell(es_tbl, 1, 2, es_pct ? es_ptx : (es_dir == "" ? "—" : es_dir),
         text_color = es_col, text_size = esz)

    // "for how long it is positive or negative"
    table.cell(es_tbl, 0, 3, "Held for", text_color = color.silver, text_size = esz,
         tooltip = "Consecutive bars of the CHART's timeframe on which the spread has kept the " +
                   "same sign. On a daily chart these are sessions; on a 15-minute chart they " +
                   "are 15-minute bars.")
    table.cell(es_tbl, 1, 3,
         na(es_val) or es_run == 0 ? "—" :
          (es_sign > 0 ? "Positive " : es_sign < 0 ? "Negative " : "Flat ") +
          str.tostring(es_run) + (es_run == 1 ? " bar" : " bars"),
         text_color = es_col, text_size = esz)


// ─────────────────────────────────────────────
// SECTION 10: RSI PRICE LINE  (added 11 Sep 2026 — this file only)
//
// WHAT IT PLOTS, and why it is not "RSI on the chart". RSI runs 0-100 and price runs in rupees, so
// a raw RSI plotted on an overlay chart is a flat line pinned to the axis floor and "price above
// the RSI line" means nothing. What IS meaningful is the INVERSE: the PRICE at which RSI would
// equal a chosen level. That line lives in rupees, sits on the candles, and can honestly be
// compared to price.
//
// THE ALGEBRA. RSI = 100 − 100/(1+RS) with RS = avgGain/avgLoss, both Wilder-smoothed
// (avg_new = (avg_prev·(n−1) + today)/n, which is exactly `ta.rma`). Solving for the next bar:
//   a rise of x  →  RS = (AG·(n−1) + x) / (AL·(n−1))        set = RS_target  →  x = (n−1)(RS_t·AL − AG)
//   a fall of y  →  RS = AG·(n−1) / (AL·(n−1) + y)          set = RS_target  →  y = (n−1)(AG/RS_t − AL)
// Exactly one of x, y is non-negative, so the level is unique: close + x, or close − y.
//
// ⚠️ TWO PROPERTIES WORTH KNOWING, because they are what make the colour rule exact rather than
// approximate:
//   1. When RSI already equals the level, x is exactly 0 and the line TOUCHES the close. So the
//      line crosses price precisely when RSI crosses the level — no drift, no lag.
//   2. Therefore "close above the line" is identical to "RSI above the level". The green/red is a
//      restatement of the RSI's own position, not a second, looser signal that could disagree.
// It is simultaneously a forward-looking TRIGGER: the level is the price NEXT bar that would put
// RSI at your chosen number, so it can be read as tomorrow's RSI-50 line and traded as a level.
//
// ⚠️ SOLID / DASHED / DOTTED IS NOT AVAILABLE TO plot(). Pine's plot() has no dash option at all —
// the styles it offers are line / stepline / circles / cross, which is what the Style input below
// exposes. Dashes are a drawing-object feature (line.new), and drawing one object per bar would
// exhaust the object limit within a screen. For a dashed look, use the Style tab exactly as the
// note at the top of this file says for the MAs.
// ⚠️ A SERIES COLOUR DISABLES THE STYLE-TAB COLOUR PICKER for that plot. That is the price of the
// green/red rule and it is deliberate; thickness and style stay adjustable there as normal.
// ─────────────────────────────────────────────

bool   rl_on    = input.bool  (true, "Enable RSI price line", group = "RSI Price Line",
     tooltip = "Plots the PRICE at which RSI would equal the level below — not the RSI itself, " +
               "which cannot be compared to price. Green while price is above that line " +
               "(= RSI above the level), red while it is below.")
int    rl_len   = input.int   (14, "RSI length", minval = 2, maxval = 100, group = "RSI Price Line")
float  rl_level = input.float (50.0, "RSI level to track", minval = 1.0, maxval = 99.0, step = 0.5,
     group = "RSI Price Line",
     tooltip = "50 is the trend divide the rest of this indicator is built around. 30 and 70 give " +
               "you the price that would mark oversold / overbought on the next bar. " +
               "Bounded 1-99: at 0 or 100 the inverse has no solution.")
int    rl_width = input.int   (2, "Line thickness", minval = 1, maxval = 4, group = "RSI Price Line")
string rl_style = input.string("Line", "Line style",
     options = ["Line","Dashed","Dotted","Stepline","Circles","Cross"], group = "RSI Price Line",
     tooltip = "⚠️ Pine's plot() has NO dash or dot setting — its styles are line, stepline, " +
               "circles, cross and a few fills. Dashed and Dotted here are therefore BUILT, not " +
               "selected:\n\n" +
               "DASHED uses plot.style_linebr (a line that BREAKS at na) and blanks the series on " +
               "alternate runs of bars, so the gaps become the dashes.\n\n" +
               "DOTTED uses plot.style_circles and blanks every bar but one, leaving spaced dots.\n\n" +
               "⚠️ The spacing is measured in BARS, not pixels, so it stretches as you zoom in and " +
               "tightens as you zoom out. Use the dash length below to retune it. The alternative — " +
               "one line.new object per bar for true pixel dashes — exhausts Pine's 500-object " +
               "ceiling within a single screen, so it is not usable for a line that must span the " +
               "whole chart.")
int    rl_dash  = input.int   (3, "Dash / dot spacing (bars)", minval = 1, maxval = 20,
     group = "RSI Price Line",
     tooltip = "Only affects the Dashed and Dotted styles. Dashed draws this many bars then skips " +
               "the same number; Dotted draws one bar in every this many.")
color  rl_up    = input.color (#1a9850, "Colour — price ABOVE the line", group = "RSI Price Line")
color  rl_dn    = input.color (#ef5350, "Colour — price BELOW the line", group = "RSI Price Line")
bool   rl_lbl   = input.bool  (true, "Show end-of-line label", group = "RSI Price Line")
float  rl_maxatr = input.float(6.0, "Hide the line beyond this many ATRs from price",
     minval = 1.0, maxval = 20.0, step = 0.5, group = "RSI Price Line",
     tooltip = "⚠️ THIS IS WHAT KEEPS THE CHART SCALED ON EVERY TIMEFRAME. A plot's values are part " +
               "of what TradingView auto-scales to and Pine has no switch to exempt one, so a " +
               "level far from price squashes every candle into a band.\n\n" +
               "The distance is measured in ATRs, NOT in percent, and that is the whole point. " +
               "Measured on the desk's own data at RSI 50, the gap in PERCENT explodes with " +
               "timeframe — RELIANCE 1.7% median daily against 16.2% monthly, WHEELS reaching " +
               "114.7% on monthly — because a single higher-timeframe bar simply moves further. " +
               "In ATRs it barely moves at all: median 0.9-1.6 and p99 2.7-5.4 across daily, " +
               "weekly AND monthly on every stock tested. So one setting works everywhere, which " +
               "a percentage cannot do.\n\n" +
               "At the default 6 the line shows on ~99% of bars on every timeframe and only the " +
               "genuinely absurd excursions are dropped. When it IS hidden the label still reports " +
               "the level and how far away it is.")

// Wilder's averages of gain and loss — ta.rma IS Wilder's smoothing, which is what ta.rsi uses, so
// this reconstructs the same internals ta.rsi works from rather than approximating them.
float rl_ch = ta.change(close)
float rl_ag = ta.rma(math.max(rl_ch, 0.0), rl_len)
float rl_al = ta.rma(-math.min(rl_ch, 0.0), rl_len)

// RS that corresponds to the chosen RSI. rl_level is bounded 1-99 by the input, so the denominator
// can never be zero and rl_rs is always finite and positive.
float rl_rs = rl_level / (100.0 - rl_level)
float rl_x = (rl_len - 1) * (rl_rs * rl_al - rl_ag)          // price must RISE by this
float rl_y = (rl_len - 1) * (rl_al > 0 or rl_ag > 0 ? rl_ag / rl_rs - rl_al : 0.0)   // or FALL by this
float rl_price = na(rl_ag) or na(rl_al) ? na : (rl_x >= 0 ? close + rl_x : close - rl_y)

// ⚠️ SCALE GUARD. A plot's values are part of what TradingView auto-scales to, and there is no
// Pine switch to exempt one — so a value far from price REDEFINES the visible range and squashes
// the candles. The only script-side remedy is not to plot it. `rl_near` is that test; the level is
// still COMPUTED and still reported by the label, it is simply not drawn when drawing it would
// cost the whole chart.
// Also requires a POSITIVE level: at a low RSI target the fall term can drive the level to or
// below zero, and a non-positive value on a log-scaled chart is worse than useless.
bool rl_near = rl_price > 0 and math.abs(rl_price - close) <= rl_maxatr * ta.atr(rl_len)

// ⚠️ COMPUTED AT GLOBAL SCOPE, AND IT HAS TO BE. `ta.*` functions carry internal state that is only
// correct if they run on EVERY bar. `ta.rsi` was originally called inside `if barstate.islast`,
// where it executed exactly once — on the final bar, with no accumulated history — and returned
// **na**, which is what printed as "NaN" in the label. It was NOT a price condition and it never
// cleared, because nothing about it depended on price.
// This is the same rule the RSI table's note states for `request.security`: stateful calls live at
// global scope, never inside an if. The values are read inside the label block below; only the
// CALL has to be out here.
float rl_now = ta.rsi(close, rl_len)
float rl_gap = (rl_price / close - 1) * 100

// DASH / DOT PATTERN. Pine cannot dash a plot, so the gaps are made in the DATA: the series is set
// to na on the bars that should be blank, and plot.style_linebr draws a line that breaks at na.
// Dotted is the degenerate case — one bar drawn in every `rl_dash`, rendered as circles.
// `bar_index` is a series, which is fine here: it feeds the plotted VALUE, never the `style`
// argument, which must stay input-qualified (see the note on the plot call below).
bool rl_draw = rl_style == "Dashed" ? bar_index % (rl_dash * 2) < rl_dash :
     rl_style == "Dotted" ? bar_index % rl_dash == 0 : true

// Gated on the SERIES, not the plot call — plot() cannot sit inside an if, the same pattern the
// five MAs use in Section 3.
float rl_plot = rl_on and rl_near and rl_draw ? rl_price : na
color rl_col = na(rl_price) ? color.gray : (close >= rl_price ? rl_up : rl_dn)

// ⚠️ THE STYLE TERNARY IS INLINE, NOT A HELPER FUNCTION, and it has to be.
// plot()'s `style` takes an `input plot_style`, and a USER-DEFINED FUNCTION IN PINE ALWAYS RETURNS
// A SERIES-QUALIFIED VALUE — there is no way to return a const or input qualifier from one. So a
// tidy `f_rl_style()` helper fails to compile with
//     Cannot call "plot" with argument "style". An argument of "series plot_style" type was used
//     but an "input plot_style" is expected. (CE10123)
// Written inline, `rl_style` stays `input string`, each comparison stays `input bool`, and the
// whole ternary resolves to `input plot_style`, which is what plot() asks for.
// The same rule is why `linewidth` is the raw `rl_width` input rather than anything computed.
plot(rl_plot, "RSI price line", color = rl_col, linewidth = rl_width,
     style = rl_style == "Stepline" ? plot.style_stepline :
      rl_style == "Circles" or rl_style == "Dotted" ? plot.style_circles :
      rl_style == "Cross" ? plot.style_cross :
      rl_style == "Dashed" ? plot.style_linebr : plot.style_line)

// End-of-line label, mirroring Section 4b. It names the level being tracked and the live RSI, so
// the line is never an anonymous thread across the chart.
var label lbl_rl = na

if barstate.islast
    label.delete(lbl_rl)

    if rl_on and rl_lbl and not na(rl_price)
        // ⚠️ THE LABEL IS ANCHORED AT `close`, NOT AT THE LEVEL, WHENEVER THE LINE IS HIDDEN.
        // A label with yloc.price counts towards the auto-scale exactly as a plot does, so parking
        // it at an off-screen level would undo the guard above and squash the chart anyway — the
        // line would be gone and the scale still ruined, which is the worst of both.
        float rl_at = rl_near ? rl_price : close
        // Text assembled BEFORE the call, not inside its argument list. A comment between
        // arguments of a multi-line call is a construct this file has never used, and the CE10123
        // lesson from the same session was that an unproven construct is not worth the tidiness.
        // The sign is built by CONCATENATION rather than a "+#.0;-#.0" sub-pattern format — that
        // pattern has no precedent here either, and was already removed once for that reason
        // (Section 9, 20 Aug 2026).
        string rl_txt = "RSI " + str.tostring(rl_level, "#.#") + " @ " +
             str.tostring(rl_price, "#.##") + "  (now " + str.tostring(rl_now, "#.0") + ")" +
             (rl_near ? "" : "  ·  " + (rl_gap > 0 ? "+" : "") + str.tostring(rl_gap, "#.0") +
              "% away — line hidden")
        lbl_rl := label.new(bar_index + 1, rl_at,
             rl_txt,
             xloc = xloc.bar_index, yloc = yloc.price,
             color = color.new(rl_col, 70), style = label.style_label_left,
             textcolor = rl_col, size = size.small)
````
