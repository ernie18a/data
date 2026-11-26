# Zen Alerts

- url: https://www.tradingview.com/script/EtkzRryV-Zen-Alerts/
- type: indicator
- pine_id: PUB;30e4259c85384e6691ce5214ab2cb00f
- version: 4.0

## Description

This indicator detects Fair Value Gaps (FVGs) on both the chart timeframe and a higher timeframe, but only registers them when they form at confluence with the 200 EMA. It's designed for traders who use the 200 EMA as a trend bias and FVGs as entry zones, and want to be alerted only when both conditions align — without having to monitor multiple charts.

## Source Code

````pine
//@version=6
// =====================================================================
// ZEN alerts
// ---------------------------------------------------------------------
// Detects Fair Value Gaps on the chart timeframe AND a higher timeframe,
// fires an alert ONLY when the EMA passes through the FVG at formation,
// and keeps each FVG box active until price fully closes the gap.
//
// Alert fires once per setup (at FVG formation). Repaint-safe HTF data.
//
// NOTE: The display EMAs (200/1, 20/5) and VWAP are visual only and are
//       NOT used in the alert calculation. The EMA 200/5 line is the
//       chart-TF 200 EMA used for both display and confluence detection.
// =====================================================================
indicator("Zen Alerts", overlay=true, max_boxes_count=500, max_lines_count=500)

// ============================ INPUTS =================================
// --- EMA 200/5 (used for confluence check AND displayed on chart) ---
emaLength    = input.int(200,  "EMA Length",     minval=1, group="EMA 200/5")
showEMA      = input.bool(true, "Show EMA 200/5",          group="EMA 200/5")

// --- Confluence Tolerance (per-symbol; auto-selected) ---
tolNQ      = input.float(17.0, "NQ Tolerance (points)",      minval=0, group="Confluence Tolerance")
tolES      = input.float(4.5,  "ES Tolerance (points)",      minval=0, group="Confluence Tolerance")
tolGold    = input.float(3.0,  "Gold Tolerance ($)",         minval=0, group="Confluence Tolerance")
tolDefault = input.float(0.0,  "Default (other symbols)",    minval=0, group="Confluence Tolerance")

// --- FVG detection ---
useLTF       = input.bool(true, "Detect FVGs on Chart Timeframe",     group="FVG Detection")
useHTF       = input.bool(true, "Detect FVGs on Higher Timeframe",    group="FVG Detection")
htfRes       = input.timeframe("15", "Higher Timeframe",              group="FVG Detection")

// --- FVG visuals ---
bullColor    = input.color(color.new(#90bff9, 90),      "Bullish FVG",       group="FVG Visuals")
bearColor    = input.color(color.new(#b39ddb, 85),      "Bearish FVG",       group="FVG Visuals")
bullTextColor = input.color(color.new(#90bff9, 30),     "Bullish Label Text", group="FVG Visuals")
bearTextColor = input.color(color.new(#b39ddb, 30),     "Bearish Label Text", group="FVG Visuals")
extendBars   = input.int(20, "Extend FVG Box Right (bars)", minval=1,     group="FVG Visuals")

// --- NY time lines ---
showNY930    = input.bool(true, "Show NY 9:30 Open Line",              group="NY Time Lines")
showNY1000   = input.bool(true, "Show NY 10:00 Line",                   group="NY Time Lines")
show10Price  = input.bool(true, "Show NY 10:00 Price (horizontal)",     group="NY Time Lines")
colorNY930   = input.color(#C0C0C0, "9:30 Line Color",                  group="NY Time Lines")
colorNY1000  = input.color(#C0C0C0, "10:00 Line Color",                 group="NY Time Lines")
color10Price = input.color(#C0C0C0, "10:00 Price Line Color",           group="NY Time Lines")

// --- Display EMAs (visual only, NOT used for alerts) ---
showEma200_1 = input.bool(true, "Show EMA 200/1 (200 EMA, 1m)", group="Display EMAs")
showEma20_5  = input.bool(true, "Show EMA 20/5 (20 EMA, 5m)",   group="Display EMAs")

// --- VWAP (visual only, NOT used for alerts) ---
showVwap     = input.bool(true, "Show VWAP (session, HLC3)",  group="VWAP")

// =========================== EMA 200/5 ===============================
// Single line used for both display AND alert confluence detection.
emaVal = ta.ema(close, emaLength)
plot(showEMA ? emaVal : na, "EMA 200/5", color=#b39ddb, linewidth=2)

// ===================== AUTO-DETECT TOLERANCE =========================
// Pick the right tolerance based on the chart's symbol. Handles both
// full-size and micro futures contracts, plus spot gold (XAU/GOLD).
isNQ_sym   = syminfo.root == "NQ" or syminfo.root == "MNQ"
isES_sym   = syminfo.root == "ES" or syminfo.root == "MES"
isGold_sym = syminfo.root == "GC" or syminfo.root == "MGC" or str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
tolerance  = isNQ_sym ? tolNQ : isES_sym ? tolES : isGold_sym ? tolGold : tolDefault

// ====================== FVG STATE TRACKING ===========================
var array<float> fvgTops   = array.new<float>()
var array<float> fvgBots   = array.new<float>()
var array<int>   fvgTypes  = array.new<int>()      // 1 = bull, -1 = bear
var array<bool>  fvgFilled = array.new<bool>()
var array<box>   fvgBoxes  = array.new<box>()

// =========== HELPER: format timeframe like "5m", "15m", "1D" =========
formatTF(tf) =>
    n = str.tonumber(tf)
    not na(n) ? tf + "m" : tf

// =================== REGISTER FVG (with EMA check) ===================
registerFVG(top, bot, ftype, tfLabel) =>
    if emaVal >= bot - tolerance and emaVal <= top + tolerance
        bg = ftype == 1 ? bullColor     : bearColor
        tc = ftype == 1 ? bullTextColor : bearTextColor
        b  = box.new(bar_index, top, bar_index + extendBars, bot,
             border_width = 0,
             bgcolor      = bg,
             text         = "FVG " + tfLabel,
             text_color   = tc,
             text_size    = size.small,
             text_halign  = text.align_right,
             text_valign  = text.align_center)
        array.push(fvgTops,   top)
        array.push(fvgBots,   bot)
        array.push(fvgTypes,  ftype)
        array.push(fvgFilled, false)
        array.push(fvgBoxes,  b)
        dir = ftype == 1 ? "Bullish" : "Bearish"
        alert(dir + " " + tfLabel + " FVG + EMA confluence on " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar_close)

// ==================== CHART-TF FVG DETECTION =========================
// 3-bar pattern (bars n-2, n-1, n). Confirmed at the close of bar n.
if barstate.isconfirmed and useLTF
    bullLTF = low  > high[2]
    bearLTF = high < low[2]
    if bullLTF
        registerFVG(low,    high[2], 1,  formatTF(timeframe.period))
    if bearLTF
        registerFVG(low[2], high,   -1,  formatTF(timeframe.period))

// ====================== HTF FVG DETECTION ============================
// Repaint-safe: shifted by 1 with lookahead_on.
htf_h1 = request.security(syminfo.tickerid, htfRes, high[1], lookahead=barmerge.lookahead_on)
htf_l1 = request.security(syminfo.tickerid, htfRes, low[1],  lookahead=barmerge.lookahead_on)
htf_h3 = request.security(syminfo.tickerid, htfRes, high[3], lookahead=barmerge.lookahead_on)
htf_l3 = request.security(syminfo.tickerid, htfRes, low[3],  lookahead=barmerge.lookahead_on)

// Fire once per HTF bar: close of the first chart-TF bar inside a new HTF bar.
newHtfBar = ta.change(time(htfRes)) != 0

if barstate.isconfirmed and newHtfBar and useHTF and not na(htf_h3)
    bullHTF = htf_l1 > htf_h3
    bearHTF = htf_h1 < htf_l3
    if bullHTF
        registerFVG(htf_l1, htf_h3, 1,  formatTF(htfRes))
    if bearHTF
        registerFVG(htf_l3, htf_h1, -1, formatTF(htfRes))

// ===================== FILL TRACKING =================================
// FVG boxes keep their original width (extendBars from formation bar)
// regardless of fill status. The fvgFilled flag is still maintained for
// potential future use (e.g. alerting on retests).
if array.size(fvgTops) > 0
    for i = array.size(fvgTops) - 1 to 0
        if not array.get(fvgFilled, i)
            bot   = array.get(fvgBots,  i)
            top   = array.get(fvgTops,  i)
            ftype = array.get(fvgTypes, i)
            isFilled = (ftype == 1 and low <= bot) or (ftype == -1 and high >= top)
            if isFilled
                array.set(fvgFilled, i, true)

// =========================== NY TIME LINES ===========================
// Vertical dotted lines at NY 9:30 (equity open) and 10:00. Timezone-aware.
// Plus a horizontal dotted line at the 10:00 price (open of the 10:00 bar).
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")
is930    = nyHour == 9  and nyMinute == 30
is1000   = nyHour == 10 and nyMinute == 0

if is930 and showNY930
    line.new(time, 0, time, 1, xloc=xloc.bar_time, extend=extend.both, color=colorNY930,  style=line.style_dotted, width=1)

if is1000 and showNY1000
    line.new(time, 0, time, 1, xloc=xloc.bar_time, extend=extend.both, color=colorNY1000, style=line.style_dotted, width=1)

// Horizontal line at the 10:00 open price, extending to the right.
if is1000 and show10Price
    line.new(time, open, time + 1, open, xloc=xloc.bar_time, extend=extend.right, color=color10Price, style=line.style_dotted, width=1)

// =========================== DISPLAY EMAs ============================
// Plain EMAs (no smoothing) on their specified timeframes — same approach
// as the EMA 200/5 above. When the chart TF matches the EMA's TF, compute
// natively for perfect smoothness; otherwise request from the appropriate
// timeframe.
is1mChart = timeframe.in_seconds(timeframe.period) == timeframe.in_seconds("1")
is5mChart = timeframe.in_seconds(timeframe.period) == timeframe.in_seconds("5")

ema200_1_native = ta.ema(close, 200)
ema200_1_sec    = request.security(syminfo.tickerid, "1", ta.ema(close, 200))
ema200_1        = is1mChart ? ema200_1_native : ema200_1_sec

ema20_5_native = ta.ema(close, 20)
ema20_5_sec    = request.security(syminfo.tickerid, "5", ta.ema(close, 20))
ema20_5        = is5mChart ? ema20_5_native : ema20_5_sec

plot(showEma200_1 ? ema200_1 : na, "EMA 200/1", color=#b39ddb, linewidth=1)
plot(showEma20_5  ? ema20_5  : na, "EMA 20/5",  color=#d1c4e9, linewidth=1)

// ================================ VWAP ===============================
// Session-anchored VWAP using HLC3 source on the chart timeframe.
// ta.vwap automatically resets at the start of each session.
vwapVal = ta.vwap(hlc3)
plot(showVwap ? vwapVal : na, "VWAP", color=#90bff9, linewidth=1)
````
