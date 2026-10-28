# EMA Ribbon Trend Filter [StrixEDGE]

- url: https://www.tradingview.com/script/z6prdGnA-EMA-Ribbon-Trend-Filter-StrixEDGE/
- type: indicator
- pine_id: PUB;737f5c58ad764241b7180284c45ab86b
- version: 1.0

## Description

EMA Ribbon Trend Filter is a multi-layered trend analysis system built around a triple EMA ribbon (8/21/55) enhanced with squeeze detection, a composite momentum score, multi-timeframe confluence, and dynamic slope-adaptive coloring.

This is not another moving average overlay. It is a full trend diagnostics dashboard designed to answer five questions at a glance: what is the trend, how strong is it, how long has it been running, is the ribbon compressing toward a breakout, and do higher timeframes agree.


🔹 CORE CONCEPT

Three exponential moving averages — fast (8), mid (21), and slow (55) — form a visual ribbon on the chart. When the EMAs stack in order (fast > mid > slow), the trend is bullish. When they invert, the trend is bearish. Anything else is a transitional state labeled neutral.

The ribbon is more than directional. The distance between the fastest and slowest EMA (the "spread") measures trend strength as a percentage, and the rate at which the ribbon expands or contracts reveals momentum shifts before price confirms them.

https://www.tradingview.com/x/I8GkDtFx/

🔹 WHAT MAKES THIS DIFFERENT

Most EMA ribbons stop at direction and color. This indicator adds four analytical layers that standard ribbons lack:

▸ Ribbon Squeeze Detection
  The indicator continuously measures ribbon width against its own moving average. When the three EMAs converge below a configurable threshold (default: 30% of average width), the ribbon turns yellow and the dashboard flags an active squeeze. Compression precedes expansion — a squeeze ending often marks the start of a directional move. Dedicated markers appear on the chart when a squeeze releases into a bullish or bearish trend.

▸ Composite Momentum Score (0–100)
  A single number synthesizing four components, each weighted equally at 25 points:
  — EMA alignment: full bullish or bearish stack scores 25, mixed scores 0
  — Slope agreement: all three EMAs rising or all falling scores 25, partial agreement scores 12
  — Spread strength: scaled between 0–25 based on where the current spread falls relative to the user-defined weak and strong thresholds
  — Price position: price above the ribbon in a bullish trend (or below in bearish) scores 25, inside the ribbon scores 10, on the wrong side scores 0
  The score is color-coded: cyan (80+), teal (60–79), orange (40–59), red (below 40).

▸ Dynamic Slope-Adaptive Colors
  When enabled, each EMA line independently changes color based on its own slope — rising EMAs render green, falling EMAs render red. This provides an early visual warning when individual EMAs begin to flatten or turn, even while the overall stack remains intact. A bullish stack where the slow EMA has turned red is a qualitatively different signal than one where all three are green.

▸ Multi-Timeframe Dashboard
  A built-in table displays trend state, spread, and grade across five timeframes simultaneously: the current chart timeframe plus 15-minute, 1-hour, 4-hour, and daily. The active chart timeframe is marked with ► in the MTF rows if it matches one of the fixed timeframes. A confluence row at the bottom counts how many timeframes are bullish versus bearish and outputs a directional bias: Strong Bull (4–5 aligned), Bull Lean (3), Neutral (mixed), Bear Lean (3 bearish), or Strong Bear (4–5 bearish).


🔹 CROSSOVER SIGNAL HIERARCHY

Not all EMA crossovers carry equal weight. The indicator differentiates three tiers with distinct marker sizes and shapes:

▸ Fast × Mid (tiny triangles) — Early signal. The 8 EMA crossing the 21 EMA indicates short-term momentum shift. Frequent, noisy, best used as an alert rather than a trigger.

▸ Fast × Slow (standard triangles) — Confirmation signal. The 8 EMA crossing the 55 EMA has more significance and filters out minor pullbacks.

▸ Mid × Slow (diamonds) — Trend shift signal. The 21 EMA crossing the 55 EMA typically marks a genuine change in trend direction. This is the least frequent and most reliable crossover in the set.

All crossover markers can be toggled off independently.


🔹 DASHBOARD COMPONENTS

The top-right dashboard (position and size adjustable) contains:

Row 1 — TREND: Current trend state (▲ Bullish / ▼ Bearish / ◆ Neutral) with bar count showing how long the trend has been active.

https://www.tradingview.com/x/scJpwVgs/

Row 2 — ZONE: Where price sits relative to the ribbon (Above / Inside / Below) alongside the momentum score out of 100.

https://www.tradingview.com/x/o7wfq2jA/

Row 3 — SQUEEZE: Active squeeze status with a visual strength bar (██████░░░░) showing current spread intensity relative to its recent range.

https://www.tradingview.com/x/DJvzHOHO/

Rows 4–9 — MTF OVERVIEW: Trend, spread, and grade for the current chart, 15m, 1H, 4H, and 1D timeframes.

https://www.tradingview.com/x/AjM0PD0y/

Row 10 — BIAS: Multi-timeframe confluence verdict with bull/bear count.

https://www.tradingview.com/x/6ggrxIgZ/

🔹 SETTINGS

EMA Settings
  ▸ Fast / Mid / Slow EMA Period — Default 8/21/55. Periods must be in ascending order.
  ▸ Source — Close, Open, High, Low, HL2, HLC3, or OHLC4.

https://www.tradingview.com/x/1urCeavY/

Overlay Settings
  ▸ Background Transparency — Controls the intensity of the trend-colored chart background (0–99).
  ▸ Crossover Signals — Toggle the three-tier crossover markers.
  ▸ Ribbon Fill — Toggle the colored fill between EMA lines. Fill turns yellow during active squeeze.
  ▸ Dynamic EMA Colors — Toggle slope-based EMA coloring (green = rising, red = falling).
  ▸ Bar Coloring — Optional candle coloring by trend state and price position. Off by default.
  ▸ Squeeze Detection — Toggle squeeze markers and dashboard squeeze status.

Dashboard
  ▸ Table Size — Tiny, Small, Normal, or Large.
  ▸ Table Position — 8 positions (corners, centers, sides).

Thresholds
  ▸ Weak/Strong spread thresholds (%) — Define what constitutes a weak, moderate, or strong trend spread. These should be adjusted per asset class (e.g., lower for forex, higher for crypto).
  ▸ Squeeze Lookback — Number of bars used to calculate the average ribbon width for squeeze detection.
  ▸ Squeeze Ratio — The compression threshold. A ribbon narrower than this ratio × average width triggers a squeeze flag.


🔹 ALERTS

Nine configurable alert conditions:
  ▸ Bullish / Bearish EMA Crossover (any tier)
  ▸ Mid × Slow Bullish / Bearish Shift
  ▸ Bullish / Bearish Stack Formed
  ▸ Squeeze Detected (compression begins)
  ▸ Squeeze Released (expansion starts)
  ▸ High Momentum (score crosses above 80)

https://www.tradingview.com/x/95YXJYbu/

🔹 SUGGESTED USE

This indicator works as a trend filter, not a standalone entry signal. Use it to:
  ▸ Confirm directional bias across timeframes before entering trades
  ▸ Identify compression phases where breakouts are likely
  ▸ Gauge trend quality and exhaustion via the momentum score and bar duration
  ▸ Filter crossover signals — a Fast × Mid cross during an active squeeze with MTF confluence is a higher-probability setup than the same cross in isolation

Pairs well with oscillators (RSI, Stochastic), volume-based indicators, or support/resistance tools for entry timing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("EMA Ribbon Trend Filter [StrixEDGE]", overlay = true, max_bars_back = 500)

// ─── PALETTE ────────────────────────────────────────────────────────────────
color C_CYAN      = #00bcd4
color C_TEAL      = #26a69a
color C_RED       = #ef5350
color C_ORANGE    = #ff9800
color C_PINK      = #e91e63
color C_GRAY      = #787b86
color C_WHITE     = #d1d4dc
color C_YELLOW    = #ffeb3b
color C_DARK0     = #0b0e13
color C_DARK1     = #0d1117
color C_DARK2     = #131722
color C_DARK3     = #161b22
color C_DARK4     = #1c2128
color C_DARK5     = #1e222d
color C_DARK6     = #21262d
color C_BORDER    = #2d333b

// ─── INPUTS ─────────────────────────────────────────────────────────────────
string G1 = "══  EMA  ══"
int    fastLen     = input.int(8,       "Fast EMA",         minval = 2,   maxval = 200,  group = G1)
int    midLen      = input.int(21,      "Mid EMA",          minval = 2,   maxval = 200,  group = G1)
int    slowLen     = input.int(55,      "Slow EMA",         minval = 2,   maxval = 200,  group = G1)
string srcInput    = input.string("Close", "Source",        options = ["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4"], group = G1)

string G2 = "══  Overlay  ══"
int    bgAlpha     = input.int(90,      "Background Transparency",  minval = 0, maxval = 99, group = G2)
bool   showCross   = input.bool(true,   "Crossover Signals",       group = G2)
bool   showFill    = input.bool(true,   "Ribbon Fill",             group = G2)
bool   dynColors   = input.bool(true,   "Dynamic EMA Colors",      group = G2, tooltip = "EMAs change color based on slope direction")
bool   showBarClr  = input.bool(false,  "Bar Coloring",            group = G2, tooltip = "Color candles by trend alignment")
bool   showSqueeze = input.bool(true,   "Squeeze Detection",       group = G2)

string G3 = "══  Dashboard  ══"
bool   showTable   = input.bool(true,   "Show Dashboard",          group = G3)
string tblSizeIn   = input.string("Small", "Table Size",           options = ["Tiny", "Small", "Normal", "Large"], group = G3)
string tblPosIn    = input.string("Top Right", "Position",         options = ["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center", "Middle Right", "Middle Left"], group = G3)

string G4 = "══  Thresholds  ══"
float  threshWeak  = input.float(0.5,   "Weak → Moderate (%)",     minval = 0.01, step = 0.1,  group = G4)
float  threshStr   = input.float(1.5,   "Moderate → Strong (%)",   minval = 0.02, step = 0.1,  group = G4)
int    sqzLookback = input.int(50,      "Squeeze Lookback",        minval = 10,   maxval = 300, group = G4)
float  sqzRatio    = input.float(0.3,   "Squeeze Ratio",           minval = 0.05, maxval = 0.9, step = 0.05, group = G4, tooltip = "Ribbon width below this × average = squeeze")

// ─── VALIDATION ─────────────────────────────────────────────────────────────
if barstate.isfirst and not (fastLen < midLen and midLen < slowLen)
    runtime.error("Periods must be ascending: Fast < Mid < Slow")

// ─── SOURCE ─────────────────────────────────────────────────────────────────
float src = switch srcInput
    "Close" => close
    "Open"  => open
    "High"  => high
    "Low"   => low
    "HL2"   => hl2
    "HLC3"  => hlc3
    "OHLC4" => ohlc4

// ─── RESOLVE TABLE SETTINGS ────────────────────────────────────────────────
string tblSize = switch tblSizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large

string tblPos = switch tblPosIn
    "Top Right"      => position.top_right
    "Top Left"       => position.top_left
    "Top Center"     => position.top_center
    "Bottom Right"   => position.bottom_right
    "Bottom Left"    => position.bottom_left
    "Bottom Center"  => position.bottom_center
    "Middle Right"   => position.middle_right
    "Middle Left"    => position.middle_left

// ═══════════════════════════════════════════════════════════════════════════
//  CORE ENGINE
// ═══════════════════════════════════════════════════════════════════════════

// ─── EMAs ───────────────────────────────────────────────────────────────────
float fastEMA = ta.ema(src, fastLen)
float midEMA  = ta.ema(src, midLen)
float slowEMA = ta.ema(src, slowLen)

// ─── TREND STATE ────────────────────────────────────────────────────────────
bool isBullish = fastEMA > midEMA and midEMA > slowEMA
bool isBearish = fastEMA < midEMA and midEMA < slowEMA

// ─── SPREAD & GRADE ─────────────────────────────────────────────────────────
float spread = slowEMA != 0 ? math.abs(fastEMA - slowEMA) / slowEMA * 100 : 0.0

// ─── SLOPES ─────────────────────────────────────────────────────────────────
bool fastRising = fastEMA > fastEMA[1]
bool midRising  = midEMA  > midEMA[1]
bool slowRising = slowEMA > slowEMA[1]

// ─── PRICE ZONE ─────────────────────────────────────────────────────────────
float ribbonTop = math.max(fastEMA, midEMA, slowEMA)
float ribbonBot = math.min(fastEMA, midEMA, slowEMA)
bool  zoneAbove = close > ribbonTop
bool  zoneBelow = close < ribbonBot
bool  zoneInside = not zoneAbove and not zoneBelow

// ─── TREND DURATION ─────────────────────────────────────────────────────────
var int trendBars = 0
if isBullish
    trendBars := isBullish[1] ? trendBars + 1 : 1
else if isBearish
    trendBars := isBearish[1] ? trendBars + 1 : 1
else
    trendBars := (not isBullish[1] and not isBearish[1]) ? trendBars + 1 : 1

// ─── SQUEEZE DETECTION ──────────────────────────────────────────────────────
float ribbonWidth    = math.abs(fastEMA - slowEMA)
float avgWidth       = ta.sma(ribbonWidth, sqzLookback)
bool  isSqueeze      = ribbonWidth < avgWidth * sqzRatio
bool  squeezeStart   = isSqueeze and not isSqueeze[1]
bool  squeezeEnd     = not isSqueeze and isSqueeze[1]

// ─── MOMENTUM SCORE (0–100) ─────────────────────────────────────────────────
// Component 1: EMA alignment (0–25)
float sc_align = isBullish or isBearish ? 25.0 : 0.0

// Component 2: Slope agreement (0–25)
bool allRising  = fastRising and midRising and slowRising
bool allFalling = not fastRising and not midRising and not slowRising
float sc_slope  = (allRising or allFalling) ? 25.0 : ((fastRising == midRising) or (midRising == slowRising)) ? 12.0 : 0.0

// Component 3: Spread strength (0–25)
float sc_spread = spread >= threshStr ? 25.0 : spread >= threshWeak ? math.round(12.0 + 13.0 * (spread - threshWeak) / (threshStr - threshWeak)) : math.round(12.0 * spread / threshWeak)

// Component 4: Price position (0–25)
float sc_price  = (isBullish and zoneAbove) or (isBearish and zoneBelow) ? 25.0 : zoneInside ? 10.0 : 0.0

float momentum  = math.min(sc_align + sc_slope + sc_spread + sc_price, 100)

// ─── CROSSOVERS ─────────────────────────────────────────────────────────────
bool fxmUp = ta.crossover(fastEMA, midEMA)
bool fxmDn = ta.crossunder(fastEMA, midEMA)
bool fxsUp = ta.crossover(fastEMA, slowEMA)
bool fxsDn = ta.crossunder(fastEMA, slowEMA)
bool mxsUp = ta.crossover(midEMA, slowEMA)
bool mxsDn = ta.crossunder(midEMA, slowEMA)
bool bullCross = fxmUp or fxsUp or mxsUp
bool bearCross = fxmDn or fxsDn or mxsDn

// ═══════════════════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════
[f15, m15, s15] = request.security(syminfo.tickerid, "15",  [fastEMA, midEMA, slowEMA])
[f1h, m1h, s1h] = request.security(syminfo.tickerid, "60",  [fastEMA, midEMA, slowEMA])
[f4h, m4h, s4h] = request.security(syminfo.tickerid, "240", [fastEMA, midEMA, slowEMA])
[f1d, m1d, s1d] = request.security(syminfo.tickerid, "D",   [fastEMA, midEMA, slowEMA])

// TF trend + spread
bool bl15 = f15 > m15 and m15 > s15
bool br15 = f15 < m15 and m15 < s15
bool bl1h = f1h > m1h and m1h > s1h
bool br1h = f1h < m1h and m1h < s1h
bool bl4h = f4h > m4h and m4h > s4h
bool br4h = f4h < m4h and m4h < s4h
bool bl1d = f1d > m1d and m1d > s1d
bool br1d = f1d < m1d and m1d < s1d

float sp15 = s15 != 0 ? math.abs(f15 - s15) / s15 * 100 : 0.0
float sp1h = s1h != 0 ? math.abs(f1h - s1h) / s1h * 100 : 0.0
float sp4h = s4h != 0 ? math.abs(f4h - s4h) / s4h * 100 : 0.0
float sp1d = s1d != 0 ? math.abs(f1d - s1d) / s1d * 100 : 0.0

// Confluence
int bullCount = (isBullish ? 1 : 0) + (bl15 ? 1 : 0) + (bl1h ? 1 : 0) + (bl4h ? 1 : 0) + (bl1d ? 1 : 0)
int bearCount = (isBearish ? 1 : 0) + (br15 ? 1 : 0) + (br1h ? 1 : 0) + (br4h ? 1 : 0) + (br1d ? 1 : 0)

string biasLabel = bullCount >= 4 ? "▲▲  STRONG BULL" : bullCount == 3 ? "▲  BULL LEAN" : bearCount >= 4 ? "▼▼  STRONG BEAR" : bearCount == 3 ? "▼  BEAR LEAN" : "◆  NEUTRAL"
color  biasColor = bullCount >= 3 ? C_TEAL : bearCount >= 3 ? C_RED : C_GRAY

// ═══════════════════════════════════════════════════════════════════════════
//  OVERLAY RENDERING
// ═══════════════════════════════════════════════════════════════════════════

// ─── DYNAMIC EMA COLORS ─────────────────────────────────────────────────────
color clrFast = dynColors ? (fastRising ? C_TEAL : C_RED) : C_CYAN
color clrMid  = dynColors ? (midRising  ? C_TEAL : C_RED) : C_ORANGE
color clrSlow = dynColors ? (slowRising ? C_TEAL : C_RED) : C_PINK

p_f = plot(fastEMA, "Fast EMA", color = clrFast, linewidth = 2)
p_m = plot(midEMA,  "Mid EMA",  color = clrMid,  linewidth = 1)
p_s = plot(slowEMA, "Slow EMA", color = clrSlow, linewidth = 2)

// ─── RIBBON FILL ────────────────────────────────────────────────────────────
color fillClr = isSqueeze ? color.new(C_YELLOW, 85) : isBullish ? color.new(C_TEAL, 78) : isBearish ? color.new(C_RED, 78) : color.new(C_GRAY, 88)
fill(p_f, p_m, color = showFill ? fillClr : na, title = "Ribbon — Fast/Mid")
fill(p_m, p_s, color = showFill ? fillClr : na, title = "Ribbon — Mid/Slow")

// ─── TREND BACKGROUND ──────────────────────────────────────────────────────
color bgClr = isBullish ? color.new(C_TEAL, bgAlpha) : isBearish ? color.new(C_RED, bgAlpha) : color.new(C_GRAY, math.min(bgAlpha + 5, 99))
bgcolor(bgClr, title = "Trend Background")

// ─── BAR COLORING ───────────────────────────────────────────────────────────
barcolor(showBarClr ? (isBullish and zoneAbove ? C_TEAL : isBearish and zoneBelow ? C_RED : isBullish or isBearish ? C_ORANGE : C_GRAY) : na, title = "Bar Color")

// ─── CROSSOVER MARKERS ─────────────────────────────────────────────────────
plotshape(showCross and fxmUp ? low  : na, "F×M ▲", shape.triangleup,   location.belowbar, C_TEAL, size = size.tiny)
plotshape(showCross and fxmDn ? high : na, "F×M ▼", shape.triangledown, location.abovebar, C_RED,  size = size.tiny)
plotshape(showCross and fxsUp ? low  : na, "F×S ▲", shape.triangleup,   location.belowbar, C_TEAL, size = size.small)
plotshape(showCross and fxsDn ? high : na, "F×S ▼", shape.triangledown, location.abovebar, C_RED,  size = size.small)
plotshape(showCross and mxsUp ? low  : na, "M×S ▲", shape.diamond,      location.belowbar, C_CYAN, size = size.small)
plotshape(showCross and mxsDn ? high : na, "M×S ▼", shape.diamond,      location.abovebar, C_PINK, size = size.small)

// ─── SQUEEZE MARKERS ────────────────────────────────────────────────────────
plotshape(showSqueeze and squeezeStart ? midEMA : na, "Squeeze Start", shape.xcross, location.absolute, C_YELLOW, size = size.tiny)
plotshape(showSqueeze and squeezeEnd and isBullish ? low  : na, "Squeeze Release ▲", shape.diamond, location.belowbar, C_CYAN,   size = size.normal)
plotshape(showSqueeze and squeezeEnd and isBearish ? high : na, "Squeeze Release ▼", shape.diamond, location.abovebar, C_PINK,   size = size.normal)
plotshape(showSqueeze and squeezeEnd and not isBullish and not isBearish ? midEMA : na, "Squeeze Release ◆", shape.diamond, location.absolute, C_ORANGE, size = size.normal)

// ═══════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════

// ─── HELPERS ────────────────────────────────────────────────────────────────
f_trendTxt(bool _b, bool _s)  => _b ? "▲ BULLISH"  : _s ? "▼ BEARISH"  : "◆ NEUTRAL"
f_trendClr(bool _b, bool _s)  => _b ? C_TEAL       : _s ? C_RED        : C_GRAY
f_grade(float _sp)             => _sp >= threshStr ? "STRONG" : _sp >= threshWeak ? "MODERATE" : "WEAK"
f_gradeClr(float _sp)          => _sp >= threshStr ? C_TEAL  : _sp >= threshWeak ? C_ORANGE   : C_RED

f_spreadStr(float _sp) => str.tostring(_sp, "#.##") + "%"

f_scoreClr(float _sc) =>
    _sc >= 80 ? C_CYAN : _sc >= 60 ? C_TEAL : _sc >= 40 ? C_ORANGE : C_RED

f_tfLabel() =>
    switch timeframe.period
        "1"   => "1m"
        "2"   => "2m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => timeframe.period

f_mtfMark(string _p) => timeframe.period == _p ? "► " : "   "

f_strengthBar(float _val, float _max) =>
    int n = _max > 0 ? math.min(math.round(_val / _max * 10), 10) : 0
    string r = ""
    for i = 0 to 9
        r += i < n ? "█" : "░"
    r

// ─── BUILD TABLE ────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table d = table.new(tblPos, 4, 12, bgcolor = C_DARK5, border_width = 1, border_color = C_BORDER, frame_width = 2, frame_color = C_BORDER)

    // --- Row 0: Brand -------------------------------------------------------
    table.cell(d, 0, 0, "⬡",             text_color = C_CYAN,  text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 1, 0, "StrixEDGE",     text_color = C_CYAN,  text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_left)
    table.cell(d, 2, 0, str.tostring(fastLen) + "/" + str.tostring(midLen) + "/" + str.tostring(slowLen), text_color = C_GRAY, text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_right)
    table.cell(d, 3, 0, "EMA RIBBON",    text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_right)

    // --- Row 1: Trend + Duration --------------------------------------------
    string trendStr = f_trendTxt(isBullish, isBearish)
    color  trendClr = f_trendClr(isBullish, isBearish)
    table.cell(d, 0, 1, "TREND",          text_color = C_GRAY,   text_size = tblSize, bgcolor = C_DARK2, text_halign = text.align_center)
    table.cell(d, 1, 1, trendStr,         text_color = trendClr, text_size = tblSize, bgcolor = C_DARK2, text_halign = text.align_center)
    table.cell(d, 2, 1, "BARS",           text_color = C_GRAY,   text_size = tblSize, bgcolor = C_DARK2, text_halign = text.align_right)
    table.cell(d, 3, 1, str.tostring(trendBars), text_color = C_WHITE, text_size = tblSize, bgcolor = C_DARK2, text_halign = text.align_right)

    // --- Row 2: Zone + Score ------------------------------------------------
    string zoneStr = zoneAbove ? "▲ ABOVE" : zoneBelow ? "▼ BELOW" : "◆ INSIDE"
    color  zoneClr = zoneAbove ? C_TEAL : zoneBelow ? C_RED : C_ORANGE
    color  momClr  = f_scoreClr(momentum)
    table.cell(d, 0, 2, "ZONE",           text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)
    table.cell(d, 1, 2, zoneStr,          text_color = zoneClr, text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)
    table.cell(d, 2, 2, "SCORE",          text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_right)
    table.cell(d, 3, 2, str.tostring(momentum, "#") + " / 100", text_color = momClr, text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_right)

    // --- Row 3: Squeeze + Strength Bar --------------------------------------
    string sqzStr = isSqueeze ? "⚡ ACTIVE" : "—  NONE"
    color  sqzClr = isSqueeze ? C_YELLOW : C_GRAY
    float  maxSpread = ta.highest(spread, sqzLookback)
    string barStr = f_strengthBar(spread, maxSpread)
    table.cell(d, 0, 3, "SQUEEZE",        text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK4, text_halign = text.align_center)
    table.cell(d, 1, 3, sqzStr,           text_color = sqzClr,  text_size = tblSize, bgcolor = C_DARK4, text_halign = text.align_center)
    table.cell(d, 2, 3, barStr,           text_color = f_gradeClr(spread), text_size = tblSize, bgcolor = C_DARK4, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(d, 3, 3, f_spreadStr(spread), text_color = f_gradeClr(spread), text_size = tblSize, bgcolor = C_DARK4, text_halign = text.align_right)

    // --- Row 4: MTF Column Headers ------------------------------------------
    table.cell(d, 0, 4, "  TF  ",         text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK1, text_halign = text.align_center)
    table.cell(d, 1, 4, "  TREND  ",      text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK1, text_halign = text.align_center)
    table.cell(d, 2, 4, " SPREAD ",       text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK1, text_halign = text.align_center)
    table.cell(d, 3, 4, "  GRADE  ",      text_color = C_GRAY,  text_size = tblSize, bgcolor = C_DARK1, text_halign = text.align_center)

    // --- Row 5: Current Chart TF (highlighted) ------------------------------
    table.cell(d, 0, 5, "► " + f_tfLabel(),                     text_color = C_CYAN,                     text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)
    table.cell(d, 1, 5, f_trendTxt(isBullish, isBearish),       text_color = f_trendClr(isBullish, isBearish), text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)
    table.cell(d, 2, 5, f_spreadStr(spread),                    text_color = f_gradeClr(spread),         text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)
    table.cell(d, 3, 5, f_grade(spread),                        text_color = f_gradeClr(spread),         text_size = tblSize, bgcolor = C_DARK3, text_halign = text.align_center)

    // --- Row 6: 15m ---------------------------------------------------------
    table.cell(d, 0, 6, f_mtfMark("15") + "15m",                text_color = C_WHITE,                    text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 1, 6, f_trendTxt(bl15, br15),                 text_color = f_trendClr(bl15, br15),     text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 2, 6, f_spreadStr(sp15),                      text_color = f_gradeClr(sp15),           text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 3, 6, f_grade(sp15),                          text_color = f_gradeClr(sp15),           text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)

    // --- Row 7: 1H ----------------------------------------------------------
    table.cell(d, 0, 7, f_mtfMark("60") + "1H",                 text_color = C_WHITE,                    text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 1, 7, f_trendTxt(bl1h, br1h),                 text_color = f_trendClr(bl1h, br1h),     text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 2, 7, f_spreadStr(sp1h),                      text_color = f_gradeClr(sp1h),           text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 3, 7, f_grade(sp1h),                          text_color = f_gradeClr(sp1h),           text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)

    // --- Row 8: 4H ----------------------------------------------------------
    table.cell(d, 0, 8, f_mtfMark("240") + "4H",                text_color = C_WHITE,                    text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 1, 8, f_trendTxt(bl4h, br4h),                 text_color = f_trendClr(bl4h, br4h),     text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 2, 8, f_spreadStr(sp4h),                      text_color = f_gradeClr(sp4h),           text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)
    table.cell(d, 3, 8, f_grade(sp4h),                          text_color = f_gradeClr(sp4h),           text_size = tblSize, bgcolor = C_DARK5, text_halign = text.align_center)

    // --- Row 9: 1D ----------------------------------------------------------
    table.cell(d, 0, 9, f_mtfMark("D") + "1D",                  text_color = C_WHITE,                    text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 1, 9, f_trendTxt(bl1d, br1d),                 text_color = f_trendClr(bl1d, br1d),     text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 2, 9, f_spreadStr(sp1d),                      text_color = f_gradeClr(sp1d),           text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)
    table.cell(d, 3, 9, f_grade(sp1d),                          text_color = f_gradeClr(sp1d),           text_size = tblSize, bgcolor = C_DARK6, text_halign = text.align_center)

    // --- Row 10: Confluence -------------------------------------------------
    string scoreStr = str.tostring(bullCount) + "B  " + str.tostring(bearCount) + "S  /  5"
    table.cell(d, 0, 10, "BIAS",           text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 1, 10, biasLabel,        text_color = biasColor, text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 2, 10, scoreStr,         text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 3, 10, "",               text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)

    // --- Row 11: Branding Footer --------------------------------------------
    table.cell(d, 0, 11, "",               text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 1, 11, "",               text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 2, 11, "",               text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_center)
    table.cell(d, 3, 11, syminfo.ticker,   text_color = C_GRAY,    text_size = tblSize, bgcolor = C_DARK0, text_halign = text.align_right)

// ─── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(bullCross,                          "Bullish Crossover",       "StrixEDGE ▲ Bullish EMA crossover")
alertcondition(bearCross,                          "Bearish Crossover",       "StrixEDGE ▼ Bearish EMA crossover")
alertcondition(mxsUp,                              "Mid×Slow Bull Shift",     "StrixEDGE ▲ Mid crossed above Slow — trend shift")
alertcondition(mxsDn,                              "Mid×Slow Bear Shift",     "StrixEDGE ▼ Mid crossed below Slow — trend shift")
alertcondition(isBullish and not isBullish[1],     "Bullish Stack",           "StrixEDGE ▲ Full bullish stack formed")
alertcondition(isBearish and not isBearish[1],     "Bearish Stack",           "StrixEDGE ▼ Full bearish stack formed")
alertcondition(squeezeStart,                       "Squeeze Detected",        "StrixEDGE ⚡ Ribbon squeeze — breakout imminent")
alertcondition(squeezeEnd,                         "Squeeze Released",        "StrixEDGE ⚡ Ribbon squeeze released — expansion starting")
alertcondition(momentum >= 80,                     "High Momentum",           "StrixEDGE 🔥 Momentum score above 80")
// ══════════════════════════════════════════════════════════════════════════════
````
