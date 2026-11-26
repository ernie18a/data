# TA Moving Averages

- url: https://www.tradingview.com/script/McRWHz6U-TA-Moving-Averages/
- type: indicator
- pine_id: PUB;eeeea7e97a9f4031b814d918e54c88e8
- version: 4.0

## Description

TA Moving Averages

An all-in-one moving average overlay: eight timeframe-anchored MAs (the 20 / 50 / 100 / 200 day and 20 / 50 / 100 / 200 week) plus five fully customizable slots, all on one indicator.

The point of difference is that every predefined MA is calculated with request.security, so it shows the correct daily or weekly value no matter what timeframe your chart is on. The 200-day reads the true daily 200-period SMA whether you are viewing a 5-minute, hourly, daily, or weekly chart. No switching timeframes to check where the big averages sit.

Daily structure
20-Day (bright pink), short-term reference
50-Day (royal blue), common swing reference
100-Day (deep orange), stronger short-term floor
200-Day (yellow), the most-watched long-term trend line across equities and crypto

Weekly structure
20-Week (green), accumulation zone often defended during pullbacks
50-Week (cyan), primary long-term trend filter; above is structural bull, below is structural bear
100-Week (amber), intermediate structural zone for multi-year cycles
200-Week (purple), long-term structural anchor and the classic bull-market floor for crypto

Custom slots
Five extra slots, each with any length, SMA or EMA type, a Chart / Daily / Weekly anchor, and a color picker. Off by default. Enable a 34 EMA, an 89-day Fibonacci reference, a 300-week anchor, or whatever your method calls for.

Built for every style
Day traders lean on the 20D / 50D for intraday support and resistance. Swing traders use the 50D / 100D with the 20W / 50W for cycle structure. Position traders watch the 100W / 200W as long-term anchors. Multi-timeframe analysts see all eight at once.

Notes
All MAs use lookahead off, so there is no repaint risk. Each line has its own toggle and color picker, and values are kept out of the chart legend to keep the title clean (still visible on the price scale and in the Data Window). Works on any timeframe; the weekly MAs reveal structure best on daily and weekly charts.

## Source Code

````pine
// @version=6
//
// TA Moving Averages
// ──────────────────
// An all-in-one moving average tool: the eight most-watched timeframe-anchored
// MAs (20 / 50 / 100 / 200 day AND week) plus up to five fully-customizable
// additional MAs (SMA or EMA, any length, day or week or chart timeframe).
//
// COLOR CODING (logical support hierarchy)
// ────────────────────────────────────────
// Each MA gets a visually distinct hue. The iconic 200-day in yellow drives
// immediate attention and regime awareness; weekly MAs each have their own
// hue tied to what they represent at the structural level.
//
//   20D  bright pink    │  20W  green       (institutional buyer zone)
//   50D  royal blue     │  50W  cyan        (primary trend filter)
//   100D deep orange    │  100W amber       (intermediate structural zone)
//   200D yellow         │  200W purple      (long-term structural anchor)
//
// TIMEFRAME HANDLING
// ──────────────────
// All MAs use request.security so the values are anchored to their NAMED
// timeframe regardless of what your chart is set to. The 200-day MA always
// shows the actual daily 200-period SMA — never an intraday-bar approximation.
//
// v2 (2026-08): PERFORMANCE REBUILD, identical values. v1 registered all 13
// data requests and computed every series on every load regardless of the
// toggles — the five DISABLED custom slots still fetched data and computed
// two MAs each. v2 batches the eight fixed MAs into TWO tuple requests (one
// per timeframe), gates every request on its toggles so a hidden timeframe
// or disabled slot costs nothing, and declares dynamic_requests explicitly.
// Worst case drops from 13 request slots to 2 + enabled custom slots.
//
// (c) 2026 TA LLC - All Rights Reserved
// Provided exclusively to authorized Trading Apologist Quant members.

indicator("TA Moving Averages",
     overlay=true,
     dynamic_requests=true)

// ════════════════════════════════════════════════════════════════════════
// INPUTS — Daily MAs
// ════════════════════════════════════════════════════════════════════════

g_d = "Daily Moving Averages"

show_20d  = input.bool(true,  "Show 20-day SMA",  group=g_d, inline="20d")
c_20d     = input.color(#FF1493, "",              group=g_d, inline="20d")
show_50d  = input.bool(true,  "Show 50-day SMA",  group=g_d, inline="50d")
c_50d     = input.color(#1976D2, "",              group=g_d, inline="50d")
show_100d = input.bool(true,  "Show 100-day SMA", group=g_d, inline="100d")
c_100d    = input.color(#E65100, "",              group=g_d, inline="100d")
show_200d = input.bool(true,  "Show 200-day SMA", group=g_d, inline="200d",
     tooltip="The 200-day SMA is the most-watched long-term trend reference across equities and crypto. Yellow by design for immediate attention and regime awareness.")
c_200d    = input.color(#FFD700, "",              group=g_d, inline="200d")

// ════════════════════════════════════════════════════════════════════════
// INPUTS — Weekly MAs
// ════════════════════════════════════════════════════════════════════════

g_w = "Weekly Moving Averages"

show_20w  = input.bool(true,  "Show 20-week SMA",  group=g_w, inline="20w",
     tooltip="The 20-week SMA is widely watched as an institutional-buyer zone — accumulation tends to defend this level during pullbacks. Green by design.")
c_20w     = input.color(#4CAF50, "",               group=g_w, inline="20w")
show_50w  = input.bool(true,  "Show 50-week SMA",  group=g_w, inline="50w",
     tooltip="The 50-week SMA is the primary long-term trend filter — price above is structural bull, below is structural bear.")
c_50w     = input.color(#00BCD4, "",               group=g_w, inline="50w")
show_100w = input.bool(true,  "Show 100-week SMA", group=g_w, inline="100w",
     tooltip="The 100-week SMA marks the intermediate structural zone — a key secondary support for multi-year cycles.")
c_100w    = input.color(#FF9800, "",               group=g_w, inline="100w")
show_200w = input.bool(true,  "Show 200-week SMA", group=g_w, inline="200w",
     tooltip="The 200-week SMA is the long-term structural anchor — the bull-market floor for crypto and a major secular support for indices.")
c_200w    = input.color(#9C27B0, "",               group=g_w, inline="200w")

// ════════════════════════════════════════════════════════════════════════
// INPUTS — Custom MAs (1-5)
// ════════════════════════════════════════════════════════════════════════
// Each custom slot lets you pick: length, type (SMA/EMA), timeframe anchor
// (Chart / D / W), and color. Off by default.

// Shared tooltip for every slot's SMA/EMA selector (info icon next to "Type")
MA_TYPE_TIP = "SMA (Simple Moving Average) averages the last N closes equally, so it is smoother and slower to react. EMA (Exponential Moving Average) weights recent closes more heavily, so it reacts faster and turns sooner. SMA suits the classic widely watched levels; EMA suits quicker trend signals."

g_c1 = "Custom MA 1"
show_c1  = input.bool(false, "Enable",                                      group=g_c1, inline="c1a")
len_c1   = input.int(12, "Length", minval=1,                                group=g_c1, inline="c1a")
type_c1  = input.string("SMA", "Type", options=["SMA", "EMA"],              group=g_c1, inline="c1b", tooltip=MA_TYPE_TIP)
tf_c1    = input.string("Chart", "TF", options=["Chart", "D", "W"],         group=g_c1, inline="c1b")
c_c1     = input.color(#80DEEA, "",                                         group=g_c1, inline="c1b")

g_c2 = "Custom MA 2"
show_c2  = input.bool(false, "Enable",                                      group=g_c2, inline="c2a")
len_c2   = input.int(22, "Length", minval=1,                                group=g_c2, inline="c2a")
type_c2  = input.string("EMA", "Type", options=["SMA", "EMA"],              group=g_c2, inline="c2b", tooltip=MA_TYPE_TIP)
tf_c2    = input.string("Chart", "TF", options=["Chart", "D", "W"],         group=g_c2, inline="c2b")
c_c2     = input.color(#FFEB3B, "",                                         group=g_c2, inline="c2b")

g_c3 = "Custom MA 3"
show_c3  = input.bool(false, "Enable",                                      group=g_c3, inline="c3a")
len_c3   = input.int(55, "Length", minval=1,                                group=g_c3, inline="c3a")
type_c3  = input.string("SMA", "Type", options=["SMA", "EMA"],              group=g_c3, inline="c3b", tooltip=MA_TYPE_TIP)
tf_c3    = input.string("D",   "TF",   options=["Chart", "D", "W"],         group=g_c3, inline="c3b")
c_c3     = input.color(#4CAF50, "",                                         group=g_c3, inline="c3b")

g_c4 = "Custom MA 4"
show_c4  = input.bool(false, "Enable",                                      group=g_c4, inline="c4a")
len_c4   = input.int(9, "Length", minval=1,                                 group=g_c4, inline="c4a")
type_c4  = input.string("EMA", "Type", options=["SMA", "EMA"],              group=g_c4, inline="c4b", tooltip=MA_TYPE_TIP)
tf_c4    = input.string("Chart", "TF", options=["Chart", "D", "W"],         group=g_c4, inline="c4b")
c_c4     = input.color(#E91E63, "",                                         group=g_c4, inline="c4b")

g_c5 = "Custom MA 5"
show_c5  = input.bool(false, "Enable",                                      group=g_c5, inline="c5a")
len_c5   = input.int(200, "Length", minval=1,                               group=g_c5, inline="c5a")
type_c5  = input.string("EMA", "Type", options=["SMA", "EMA"],              group=g_c5, inline="c5b", tooltip=MA_TYPE_TIP)
tf_c5    = input.string("D",   "TF",   options=["Chart", "D", "W"],         group=g_c5, inline="c5b")
c_c5     = input.color(#FFFFFF, "",                                         group=g_c5, inline="c5b")

// ════════════════════════════════════════════════════════════════════════
// MA CALCULATIONS
// ════════════════════════════════════════════════════════════════════════
// v2 PERFORMANCE ARCHITECTURE
// The eight fixed MAs come back in at most TWO batched tuple requests — one
// per timeframe — and each request only runs when at least one of its MAs is
// visible: hide all four dailies and the daily fetch never happens. Custom
// slots are gated the same way, so a disabled slot costs nothing (v1 fetched
// and computed all five even when disabled). Gating on toggles is safe for
// ta.* / request.* history because an input is constant for the entire run —
// a series can't be "sometimes computed"; it either always runs or never
// does. That is also why an ENABLED custom slot still computes BOTH the SMA
// and the EMA before picking: the type dropdown is likewise constant, but
// keeping both live means the pick can never desync either series' history.

anyDaily  = show_20d or show_50d or show_100d or show_200d
anyWeekly = show_20w or show_50w or show_100w or show_200w

// ---- Predefined daily SMAs (always SMA, always daily timeframe) ----
float ma20d  = na
float ma50d  = na
float ma100d = na
float ma200d = na
if anyDaily
    [d20, d50, d100, d200] = request.security(syminfo.tickerid, "D",
         [ta.sma(close, 20), ta.sma(close, 50), ta.sma(close, 100), ta.sma(close, 200)],
         lookahead=barmerge.lookahead_off)
    ma20d  := d20
    ma50d  := d50
    ma100d := d100
    ma200d := d200

// ---- Predefined weekly SMAs (always SMA, always weekly timeframe) ----
float ma20w  = na
float ma50w  = na
float ma100w = na
float ma200w = na
if anyWeekly
    [w20, w50, w100, w200] = request.security(syminfo.tickerid, "W",
         [ta.sma(close, 20), ta.sma(close, 50), ta.sma(close, 100), ta.sma(close, 200)],
         lookahead=barmerge.lookahead_off)
    ma20w  := w20
    ma50w  := w50
    ma100w := w100
    ma200w := w200

// ---- Custom MAs (user-configurable length / SMA-or-EMA / TF) ----
// Helper: pick SMA or EMA result based on type string (both computed while
// the slot is enabled — see the architecture note above)
f_pick(_sma, _ema, _type) =>
    _type == "EMA" ? _ema : _sma

// Compute each enabled slot's value, fetched from its chosen timeframe.
// A disabled slot short-circuits to na before any data work happens.
ma_c1 = not show_c1 ? na :
     tf_c1 == "Chart" ? f_pick(ta.sma(close, len_c1), ta.ema(close, len_c1), type_c1) :
     request.security(syminfo.tickerid, tf_c1, f_pick(ta.sma(close, len_c1), ta.ema(close, len_c1), type_c1), lookahead=barmerge.lookahead_off)

ma_c2 = not show_c2 ? na :
     tf_c2 == "Chart" ? f_pick(ta.sma(close, len_c2), ta.ema(close, len_c2), type_c2) :
     request.security(syminfo.tickerid, tf_c2, f_pick(ta.sma(close, len_c2), ta.ema(close, len_c2), type_c2), lookahead=barmerge.lookahead_off)

ma_c3 = not show_c3 ? na :
     tf_c3 == "Chart" ? f_pick(ta.sma(close, len_c3), ta.ema(close, len_c3), type_c3) :
     request.security(syminfo.tickerid, tf_c3, f_pick(ta.sma(close, len_c3), ta.ema(close, len_c3), type_c3), lookahead=barmerge.lookahead_off)

ma_c4 = not show_c4 ? na :
     tf_c4 == "Chart" ? f_pick(ta.sma(close, len_c4), ta.ema(close, len_c4), type_c4) :
     request.security(syminfo.tickerid, tf_c4, f_pick(ta.sma(close, len_c4), ta.ema(close, len_c4), type_c4), lookahead=barmerge.lookahead_off)

ma_c5 = not show_c5 ? na :
     tf_c5 == "Chart" ? f_pick(ta.sma(close, len_c5), ta.ema(close, len_c5), type_c5) :
     request.security(syminfo.tickerid, tf_c5, f_pick(ta.sma(close, len_c5), ta.ema(close, len_c5), type_c5), lookahead=barmerge.lookahead_off)

// ════════════════════════════════════════════════════════════════════════
// PLOTS
// ════════════════════════════════════════════════════════════════════════
// All lines default to linewidth=1 (narrowest) to keep the price chart
// uncluttered. Users can thicken any individual MA via the Style tab if they
// want to emphasize a specific level. Values are hidden from the chart legend
// so the title section stays clean.

plot(show_20d  ? ma20d  : na, "20D SMA",  color=c_20d,  linewidth=1, display=display.all - display.status_line)
plot(show_50d  ? ma50d  : na, "50D SMA",  color=c_50d,  linewidth=1, display=display.all - display.status_line)
plot(show_100d ? ma100d : na, "100D SMA", color=c_100d, linewidth=1, display=display.all - display.status_line)
plot(show_200d ? ma200d : na, "200D SMA", color=c_200d, linewidth=1, display=display.all - display.status_line)

plot(show_20w  ? ma20w  : na, "20W SMA",  color=c_20w,  linewidth=1, display=display.all - display.status_line)
plot(show_50w  ? ma50w  : na, "50W SMA",  color=c_50w,  linewidth=1, display=display.all - display.status_line)
plot(show_100w ? ma100w : na, "100W SMA", color=c_100w, linewidth=1, display=display.all - display.status_line)
plot(show_200w ? ma200w : na, "200W SMA", color=c_200w, linewidth=1, display=display.all - display.status_line)

// Custom MA plots. Pine v6 requires plot() titles to be CONST strings, so we
// can't bake the length/type/TF into the title — those details live in the
// Settings dialog instead. Users see "Custom 1" in the Style tab; their
// configured length/type/TF is right above in the Inputs tab.
plot(show_c1 ? ma_c1 : na, "Custom 1", color=c_c1, linewidth=1, display=display.all - display.status_line)
plot(show_c2 ? ma_c2 : na, "Custom 2", color=c_c2, linewidth=1, display=display.all - display.status_line)
plot(show_c3 ? ma_c3 : na, "Custom 3", color=c_c3, linewidth=1, display=display.all - display.status_line)
plot(show_c4 ? ma_c4 : na, "Custom 4", color=c_c4, linewidth=1, display=display.all - display.status_line)
plot(show_c5 ? ma_c5 : na, "Custom 5", color=c_c5, linewidth=1, display=display.all - display.status_line)
````
