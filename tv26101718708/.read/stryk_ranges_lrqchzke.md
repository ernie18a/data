# Stryk Ranges

- url: https://www.tradingview.com/script/lrqCHzke-Stryk-Ranges/
- type: indicator
- pine_id: PUB;224e2eba2e22484db9b21e095e4d86cf
- version: 1.0

## Description

MY BEST INDICATOR FOR FINDING LIQUIDITY LEVELS

Stryk Ranges is a context layer for intraday futures and index traders. It combines the previous completed Day/Week/Month highs and lows, the overnight Asian session range, a volume-participation shader, and a market-structure engine that distinguishes a genuine break from a liquidity grab. It prints no buy/sell signals - it maps the levels and structural events around which a trader builds their own decisions.

WHY THESE COMPONENTS ARE COMBINED

The three modules feed one workflow. The level engine defines where resting liquidity sits (prior D/W/M and Asian extremes). The structure engine classifies what price does when it reaches those levels - break, or sweep-and-fail. The volume-participation shader shows whether the move happened on real participation or in a dead tape. Each module can be toggled independently, but the sweep engine reads the level engine's outputs directly: the same Day/Week/Asian levels drawn on the chart are the levels it monitors for sweeps. That shared plumbing is the reason they live in one script rather than three.

HOW THE MARKET STRUCTURE ENGINE WORKS

Most structure tools mark every higher-high or lower-low break. This script applies three validation rules drawn from liquidity-based price action:

1. Body-close rule. A swing level is only "broken" (BOS/CHoCH) when a candle body closes through it. A wick through the level is never a break - it is classified as a SWEEP: price raided the liquidity resting beyond the level and was rejected back inside.

2. Displacement validation. After a sweep, the engine watches a configurable window of bars for an opposite-direction candle whose body is at least k x ATR (default 1.5). If it prints, the swept wick extreme is promoted to a STRONG PIVOT - drawn as a solid line that acts as an anchor and invalidation reference. A sweep with no displacement expires quietly. The sweep candle itself may qualify as the displacement candle (the classic swing-failure pattern).

3. MSS upgrade. A Change of Character (dotted line) that prints within a configurable number of bars of an opposite-side Strong Pivot is upgraded to MSS - a sweep-validated structural reversal - drawn solid with increased width. BOS (dashed) continues to mark trend-direction continuation breaks.

SWEEPABLE LIQUIDITY SOURCES

The sweep engine monitors four level types simultaneously, each toggleable: confirmed swing pivots, the Asian session high/low, the previous day's high/low, and the previous week's high/low. Session and higher-timeframe levels typically hold more resting liquidity than a short-lookback fractal, so sweeps of those levels are tagged by source (e.g. "SP PDH", "SP Asia H").

ALSO INCLUDED

- Previous completed Day / Week / Month high-low lines, built from the intraday session open (merge-proof on continuous futures), with optional forward projection, gradient fading, and price-scale tags
- Asian session range with configurable hours and extension behavior
- Range-position status box: where price sits (as a %) inside each prior period's range, with above/below coloring and optional quartile highlighting
- Volume-participation oscillator (0-100 normalized volume EMA) with background tinting at extremes
- Optional zone engine that flags range + volume expansion at any tracked level
- Alerts: liquidity sweep, Strong Pivot confirmed, MSS, and zone expansion

REPAINTING BEHAVIOR

All breaks, sweeps, and validations are evaluated on the bar's close - set alerts to "Once per bar close". Swing pivots confirm the configured number of bars after they form, by definition of a pivot; confirmed events do not repaint. Higher-timeframe reads use prior completed periods only.

USAGE NOTES

Designed on index futures at intraday timeframes (session open hour defaults to 17:00 exchange time for CME index products) but works on any symbol with volume data. On fast timeframes, consider disabling BOS labels and keeping only CHoCH/MSS and Strong Pivots for a cleaner read.

This is a technical analysis tool for chart context. It does not predict price and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Es-Sniper
//
// Stryk Ranges. The DWM (previous completed Day/Week/Month) high/low
// engine, the overnight Asian range, market structure (BOS/CHoCH/MSS with
// sweep + displacement validated strong pivots), and a volume-participation
// oscillator with background shading — extracted from the Stryk ACE engine as a
// standalone context layer. No composite, signals, or trailing stop.
// Native built-ins only; non-repainting on closed bars; HTF reads use confirmed
// prior-period values. Day & Week build from the intraday session open (merge-proof).

//@version=6
indicator("Stryk Ranges", "Stryk: Ranges", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ════════════════════════════════════════════════════════════════════════════
// 0 · MASTER SWITCHBOARD (levels only)
// ════════════════════════════════════════════════════════════════════════════
g0 = "0 · Master switchboard"
mLvlAll   = input.bool(true, "Levels — all", group = g0, tooltip = "Master hide for every on-chart level (DWM, Asian, market structure). The status box is unaffected.")
mLvlDwm   = input.bool(true, "      DWM high/low (+ price-scale tags)", group = g0)
mLvlAsian = input.bool(true, "      Asian range", group = g0)
mLvlMs    = input.bool(true, "      Market structure (BOS / CHoCH)", group = g0)

// ════════════════════════════════════════════════════════════════════════════
// 9 · VOLUME PARTICIPATION
// ════════════════════════════════════════════════════════════════════════════
g_volosc = "9 · Volume participation"
showVolOsc = input.bool(true, "Enable volume participation", group = g_volosc, tooltip = "Volume EMA normalized 0-100 over its own recent range. Box row + background tint at the extremes. 50 = average participation.")
volOscEmaLen = input.int(20, "Volume EMA length", minval = 1, group = g_volosc)
volOscLook = input.int(100, "Vol-osc lookback", minval = 10, maxval = 500, group = g_volosc)
volOscHigh = input.int(60, "Vol-osc high", minval = 50, maxval = 100, group = g_volosc)
volOscLow = input.int(40, "Vol-osc low", minval = 0, maxval = 50, group = g_volosc)
volBgHigh = input.int(80, "BG tint high", minval = 50, maxval = 100, group = g_volosc)
volBgLow = input.int(20, "BG tint low", minval = 0, maxval = 50, group = g_volosc)
volBgTransp = input.int(85, "BG tint transparency", minval = 50, maxval = 98, group = g_volosc)
volOscGreen = input.color(#00bcd4, "High color", group = g_volosc)
volOscYellow = input.color(#ffd700, "Mid color", group = g_volosc)
volOscRed = input.color(#9c27b0, "Low color", group = g_volosc)

// ════════════════════════════════════════════════════════════════════════════
// 10 · ASIAN RANGE + DWM BIAS / LEVELS
// ════════════════════════════════════════════════════════════════════════════
g_dwm = "10 · Asian range + multi-TF bias"
asianOn = input.bool(true, "Show Asian session range", group = g_dwm, tooltip = "High and low of the overnight Asian session as levels that extend into the trading day.")
showAsian = mLvlAll and mLvlAsian and asianOn
asianStart = input.string("2000", "Asian start (HHMM)", inline = "atime", group = g_dwm)
asianEnd = input.string("0400", "end", inline = "atime", group = g_dwm)
asianColor = input.color(#e040fb, "Asian range color", group = g_dwm)
asianWidth = input.int(2, "Line width", minval = 1, maxval = 3, group = g_dwm)
showAsianLabels = input.bool(false, "Show Asia H/L labels", group = g_dwm)
asianEndOfDay = input.bool(true, "Asian: extend to end of trading day", group = g_dwm, tooltip = "Extends the confirmed Asian range across the current trading day, then stops at the daily roll.")
asianEndOfChart = input.bool(false, "Asian: extend to end of chart", group = g_dwm, tooltip = "Keeps every shown Asian range extending to the newest bar, across days. Overrides end-of-day.")
asianShow = input.int(4, "Asian sessions to show", minval = 1, maxval = 20, group = g_dwm)
showDwmBias = input.bool(true, "Show DWM bias lights in box", group = g_dwm, tooltip = "Day / Week / Month range-position % rows in the status box: where price sits inside each period's previous completed range. Lookahead-safe.")
dwmFlashOn   = input.bool(false, "Highlight rows near quartiles", inline = "dwmf", group = g_dwm, tooltip = "When a Day / Week / Month / Asian range-position row sits within the chosen distance of a 0 / 25 / 50 / 75 / 100% mark, the row switches to the highlight colour, then returns to its normal colour once price moves away. A steady highlight, not a blink.")
dwmFlashColor = input.color(#ffffff, "", inline = "dwmf", group = g_dwm)
dwmFlashDist = input.float(1.0, "Highlight distance (% from a quartile)", minval = 1.0, maxval = 10.0, step = 0.5, group = g_dwm, tooltip = "How close to a 0 / 25 / 50 / 75 / 100% mark a row must be to highlight.")
f_nearQ(float _p, float _d) => not na(_p) and math.abs(_p - math.max(0, math.min(100, math.round(_p / 25) * 25))) < _d
dwmHLOn = input.bool(true, "Show DWM HL lines", group = g_dwm, tooltip = "Previous completed Day / Week / Month high & low. Each level is drawn from its period's open and stops at the next period boundary. Non-repainting.")
showDwmHL = mLvlAll and mLvlDwm and dwmHLOn
dwmHLDaily        = input.bool(true,  "Daily HL",   inline = "dwmD", group = g_dwm)
dwmHLDailyColor   = input.color(#ffffff, "",         inline = "dwmD", group = g_dwm)
dwmHLDailyW       = input.int(2, "Width",  minval = 1, maxval = 4, inline = "dwmD", group = g_dwm)
dwmHLDailyShow    = input.int(1, "Show",   minval = 1, inline = "dwmD", group = g_dwm, tooltip = "How many past daily levels to keep drawn. Only affects lines — the box % always reads the single most recent completed period.")
dwmHLWeekly       = input.bool(true,  "Weekly HL",  inline = "dwmW", group = g_dwm)
dwmHLWeeklyColor  = input.color(#ffd700, "",         inline = "dwmW", group = g_dwm)
dwmHLWeeklyW      = input.int(2, "Width",  minval = 1, maxval = 4, inline = "dwmW", group = g_dwm)
dwmHLWeeklyShow   = input.int(1, "Show",   minval = 1, inline = "dwmW", group = g_dwm)
dwmHLMonthly      = input.bool(true,  "Monthly HL", inline = "dwmM", group = g_dwm)
dwmHLMonthlyColor = input.color(#2962ff, "",         inline = "dwmM", group = g_dwm)
dwmHLMonthlyW     = input.int(2, "Width",  minval = 1, maxval = 4, inline = "dwmM", group = g_dwm)
dwmHLMonthlyShow  = input.int(1, "Show",   minval = 1, inline = "dwmM", group = g_dwm)
weekStartDay      = input.string("Sunday", "Week starts on", options = ["Sunday", "Monday"], group = g_dwm, tooltip = "Sunday = the futures/forex week (Sun 17:00 open through Fri close). Monday = the cash-equity week.")
sessOpenHr        = input.int(17, "Session opens at (hour, exchange time)", minval = 0, maxval = 23, group = g_dwm, tooltip = "The hour the daily session opens in the exchange's own time zone. CME index futures (ES/NQ/YM/RTY) open at 17:00.")
dwmExtend         = input.bool(true, "Extend levels to end of chart bar", group = g_dwm, tooltip = "OFF: each level stays inside its own period. ON: every shown level extends as a ray to the newest chart bar.")
dwmProject        = input.bool(true, "Project levels forward", inline = "dwmP", group = g_dwm, tooltip = "Pushes the live level this many bars into the future. Affects D/W/M only — not the Asian range.")
dwmProjBars       = input.int(20, "bars", minval = 0, maxval = 500, inline = "dwmP", group = g_dwm)
dwmHLGradient     = input.bool(true, "Fade older HL lines", group = g_dwm)
dwmHLLabels       = input.bool(false, "Show D/W/M name labels", inline = "dwmL", group = g_dwm, tooltip = "Prints a name label on each level — high reads 'Day/Week/Month High', low reads 'Day/Week/Month Low'.")
dwmHLLabelPos     = input.string("Outside right", "", options = ["Outside left", "Inside middle", "Outside right"], inline = "dwmL", group = g_dwm)
dwmLblDCol = input.color(#000000, "Daily label text",   inline = "ldD", group = g_dwm)
dwmLblDSz  = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large"], inline = "ldD", group = g_dwm)
dwmLblWCol = input.color(#000000, "Weekly label text",  inline = "ldW", group = g_dwm)
dwmLblWSz  = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large"], inline = "ldW", group = g_dwm)
dwmLblMCol = input.color(#ffffff, "Monthly label text", inline = "ldM", group = g_dwm)
dwmLblMSz  = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large"], inline = "ldM", group = g_dwm)
priceScale        = mLvlAll and mLvlDwm and input.bool(false, "Show Day/Week prices on the price scale", group = g_dwm, tooltip = "Standard TradingView price-scale tags for each active Day & Week high & low on the right axis. Monthly still draws its line + name label.")
// DWM/Asian zone engine
zoneOn        = input.bool(false, "Zone engine (yellow on in-zone expansion)", group = g_dwm, tooltip = "Builds a band of +/- (half-width)% of each shown level's OWN period range around every D/W/M and Asian high/low. The engine averages range + volume over the first few in-zone closes, then the first candle that expands past that baseline on BOTH range and volume paints yellow until price leaves the band.")
zonePaint     = input.bool(true, "Paint expansion candles yellow", group = g_dwm, tooltip = "Overlays a yellow candle only on the expansion bar(s). Off = engine still drives the alert and bands but leaves candles untouched.")
zonePct       = input.float(12.5, "Zone half-width (% of period range)", minval = 1.0, maxval = 50.0, step = 0.5, group = g_dwm)
zoneMinBars   = input.int(3, "Baseline bars (in-zone closes)", minval = 2, maxval = 50, group = g_dwm)
zoneRangeMult = input.float(1.3, "Expansion: range vs baseline", minval = 1.0, maxval = 5.0, step = 0.1, group = g_dwm)
zoneVolMult   = input.float(1.5, "Expansion: volume vs baseline", minval = 1.0, maxval = 5.0, step = 0.1, group = g_dwm)
zoneYellow_c  = input.color(#ffd166, "Zone yellow", group = g_dwm)
zoneShowBands = input.bool(false, "Show band fill", inline = "zb", group = g_dwm)
zoneShowEdges = input.bool(false, "edge lines", inline = "zb", group = g_dwm)
zoneBandColor = input.color(#ffd166, "Band colour", group = g_dwm)
rangeInside = input.color(#2962ff, "Range pos: in-range", inline = "rng", group = g_dwm, tooltip = "Color for the bias-box % when price sits INSIDE the period's prior range (0-100%).")
rangeAbove  = input.color(#00ff88, "above", inline = "rng", group = g_dwm)
rangeBelow  = input.color(#ff3355, "below", inline = "rng", group = g_dwm)

// ════════════════════════════════════════════════════════════════════════════
// 13 · MARKET STRUCTURE (BOS / CHoCH / SWEEP / STRONG PIVOT)
// ════════════════════════════════════════════════════════════════════════════
g_ict = "13 · Market structure"
ictOn      = mLvlAll and mLvlMs and input.bool(true, "Enable market structure", group = g_ict, tooltip = "Marks a break of structure (BOS) and a change of character (CHoCH) with a line at the broken swing — green bullish, red bearish. BOS = dashed, CHoCH = dotted, MSS (sweep-validated CHoCH) = solid. Breaks are body-close only; a wick through a level is a sweep, never a break.")
ictLen     = input.int(13, "Swing length", minval = 1, maxval = 50, group = g_ict)
ictBOS     = input.bool(true, "Show BOS (continuation)", group = g_ict)
ictCHOCH   = input.bool(true, "Show CHoCH (reversal)", group = g_ict)
ictShowLbl = input.bool(true, "Label breaks (BOS / CHoCH / MSS)", group = g_ict)
ictExtend  = input.int(10, "Line extend (bars)", minval = 0, maxval = 500, group = g_ict)
ictEos     = input.bool(true, "Extend lines to end of session", group = g_ict)
ictWidth   = input.int(1, "Line width", minval = 1, maxval = 4, group = g_ict)
ictBullCol = input.color(#00e676, "Bull break", inline = "ictc", group = g_ict)
ictBearCol = input.color(#ff1744, "Bear break", inline = "ictc", group = g_ict)
// — sweep + displacement validation —
swpOn       = input.bool(true, "Enable sweep + displacement engine", group = g_ict, tooltip = "SWEEP = wick through a tracked level with the body closing back inside (liquidity grab). If an opposite displacement candle (body ≥ k × ATR) prints within the window, the swept wick extreme is promoted to a STRONG PIVOT — drawn as a solid anchor/invalidation line. A CHoCH inside the MSS window of an opposite strong pivot upgrades to MSS.")
swpSwing    = input.bool(true,  "Sweep source: swing pivots", inline = "swps1", group = g_ict)
swpAsian    = input.bool(true,  "Asian H/L", inline = "swps1", group = g_ict)
swpDay      = input.bool(true,  "Sweep source: prev Day H/L", inline = "swps2", group = g_ict)
swpWeek     = input.bool(false, "prev Week H/L", inline = "swps2", group = g_ict)
swpAtrLen   = input.int(14, "ATR length", minval = 1, group = g_ict)
swpDispMult = input.float(1.5, "Displacement body ≥ k × ATR", minval = 0.5, maxval = 5.0, step = 0.1, group = g_ict, tooltip = "Body size the confirming candle must print, as a multiple of ATR. Separates a real fail from CHoCH noise.")
swpWindow   = input.int(5, "Displacement window (bars after sweep)", minval = 1, maxval = 50, group = g_ict, tooltip = "How many bars after the sweep the displacement candle may print. The sweep candle itself counts (classic SFP).")
mssWindow   = input.int(40, "MSS window (bars: strong pivot → CHoCH)", minval = 5, maxval = 300, group = g_ict, tooltip = "A CHoCH within this many bars of an opposite-side strong pivot upgrades to MSS — the sweep-validated reversal.")
swpShow     = input.int(6, "Strong pivots to keep", minval = 1, maxval = 50, group = g_ict)
swpBoxOn    = input.bool(true, "Show raid box on sweep", group = g_ict)
swpCol      = input.color(#ff6a00, "Strong pivot", inline = "swpc", group = g_ict)
swpBoxCol   = input.color(color.new(#e63030, 82), "Raid box", inline = "swpc", group = g_ict)

// ════════════════════════════════════════════════════════════════════════════
// 14 · STATUS BOX
// ════════════════════════════════════════════════════════════════════════════
g_box = "14 · Status box"
showBox = input.bool(true, "Show status box", group = g_box)
boxPos  = input.string("Bottom Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = g_box)
boxSize = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_box)
boxLayout = input.string("Stacked", "Layout", options = ["Stacked", "Horizontal", "Mobile grid"], group = g_box)
gridCols = input.int(4, "Mobile grid columns", minval = 2, maxval = 6, group = g_box)
showLabels = input.bool(true, "Show text labels", group = g_box)
bxFlow  = input.bool(true, "Rows: volume participation", group = g_box)
boxBg = input.color(color.new(#0a1a3a, 20), "Box background", group = g_box)
txtColor = input.color(#ffffff, "Box text", group = g_box)
offColor = input.color(#2a2e39, "Box off / dim", group = g_box)
boxBorder = input.color(#000000, "Box border", group = g_box)

posLookup = boxPos == "Top Right" ? position.top_right : boxPos == "Top Left" ? position.top_left : boxPos == "Bottom Right" ? position.bottom_right : boxPos == "Bottom Left" ? position.bottom_left : boxPos == "Middle Right" ? position.middle_right : position.middle_left
lightSize = boxSize == "Tiny" ? size.small : boxSize == "Small" ? size.normal : boxSize == "Large" ? size.huge : size.large
txtSize = boxSize == "Tiny" ? size.tiny : boxSize == "Small" ? size.small : boxSize == "Large" ? size.large : size.normal
pctSize = boxSize == "Tiny" ? size.tiny : boxSize == "Small" ? size.tiny : boxSize == "Large" ? size.normal : size.small

// ════════════════════════════════════════════════════════════════════════════
// VOLUME PARTICIPATION OSCILLATOR + BACKGROUND SHADER
// ════════════════════════════════════════════════════════════════════════════
volEma = ta.ema(volume, volOscEmaLen)
volEmaAvg = ta.sma(volEma, volOscLook)
volEmaMax = ta.highest(volEma, volOscLook)
volEmaMin = ta.lowest(volEma, volOscLook)
volAbove = volEma >= volEmaAvg
volOscA = volAbove and volEmaMax != volEmaAvg ? 50.0 + (volEma - volEmaAvg) / (volEmaMax - volEmaAvg) * 50.0 : 50.0
volOscB = not volAbove and volEmaAvg != volEmaMin ? 50.0 - (volEmaAvg - volEma) / (volEmaAvg - volEmaMin) * 50.0 : 50.0
volOscVal = math.max(0, math.min(100, volAbove ? volOscA : volOscB))
volOscLightColor = volOscVal >= volOscHigh ? volOscGreen : volOscVal <= volOscLow ? volOscRed : volOscYellow
bgShade = showVolOsc and volOscVal >= volBgHigh ? color.new(volOscGreen, volBgTransp) : showVolOsc and volOscVal <= volBgLow ? color.new(volOscRed, volBgTransp) : na
bgcolor(bgShade, title = "Volume Extreme Shader")

// ════════════════════════════════════════════════════════════════════════════
// ASIAN RANGE
// ════════════════════════════════════════════════════════════════════════════
f_hhmm(s) => str.tonumber(str.substring(s, 0, 2)) * 60 + str.tonumber(str.substring(s, 2, 4))
aStart = f_hhmm(asianStart)
aEnd = f_hhmm(asianEnd)
curMin = hour * 60 + minute
inAsian = aStart > aEnd ? (curMin >= aStart or curMin < aEnd) : (curMin >= aStart and curMin < aEnd)
newAsian = inAsian and not inAsian[1]
endAsian = not inAsian and inAsian[1]
var float asianHi = na
var float asianLo = na
var int asianStartBar = na
var int asianStartTime = na
var array<line> asianHiLines = array.new<line>()
var array<line> asianLoLines = array.new<line>()
var array<label> asianHiLbls = array.new<label>()
var array<label> asianLoLbls = array.new<label>()
if newAsian
    asianHi := high
    asianLo := low
    asianStartBar := bar_index
    asianStartTime := time
else if inAsian
    asianHi := math.max(asianHi, high)
    asianLo := math.min(asianLo, low)
var line liveHiLine = na
var line liveLoLine = na
if showAsian and inAsian
    if newAsian
        liveHiLine := line.new(asianStartBar, asianHi, bar_index, asianHi, color = color.new(asianColor, 35), width = asianWidth, style = line.style_dotted)
        liveLoLine := line.new(asianStartBar, asianLo, bar_index, asianLo, color = color.new(asianColor, 35), width = asianWidth, style = line.style_dotted)
    if not na(liveHiLine)
        line.set_xy1(liveHiLine, asianStartBar, asianHi)
        line.set_xy2(liveHiLine, bar_index, asianHi)
        line.set_xy1(liveLoLine, asianStartBar, asianLo)
        line.set_xy2(liveLoLine, bar_index, asianLo)
var line activeHiLine = na
var line activeLoLine = na
if newAsian
    activeHiLine := na
    activeLoLine := na
bool newTradingDay = timeframe.change("D")
if newTradingDay
    activeHiLine := line(na)
    activeLoLine := line(na)
    if not na(liveHiLine)
        line.delete(liveHiLine)
        line.delete(liveLoLine)
        liveHiLine := na
        liveLoLine := na
if showAsian and endAsian and not na(asianHi)
    if not na(liveHiLine)
        line.delete(liveHiLine)
        line.delete(liveLoLine)
        liveHiLine := na
        liveLoLine := na
    line hiLn = line.new(asianStartTime, asianHi, time, asianHi, xloc = xloc.bar_time, color = asianColor, width = asianWidth)
    line loLn = line.new(asianStartTime, asianLo, time, asianLo, xloc = xloc.bar_time, color = asianColor, width = asianWidth)
    if asianEndOfDay
        activeHiLine := hiLn
        activeLoLine := loLn
    array.push(asianHiLines, hiLn)
    array.push(asianLoLines, loLn)
    array.push(asianHiLbls, label.new(time, asianHi, "Asia High", xloc = xloc.bar_time, textcolor = color.white, size = size.small))
    array.push(asianLoLbls, label.new(time, asianLo, "Asia Low", xloc = xloc.bar_time, textcolor = color.white, size = size.small))
    while array.size(asianHiLines) > asianShow
        line.delete(array.shift(asianHiLines))
        line.delete(array.shift(asianLoLines))
    while array.size(asianHiLbls) > asianShow
        label.delete(array.shift(asianHiLbls))
        label.delete(array.shift(asianLoLbls))
asProjMs = (dwmProject ? dwmProjBars : 0) * timeframe.in_seconds() * 1000
if asianEndOfChart and array.size(asianHiLines) > 0
    for i = 0 to array.size(asianHiLines) - 1
        line.set_x2(array.get(asianHiLines, i), time + asProjMs)
        line.set_x2(array.get(asianLoLines, i), time + asProjMs)
else if asianEndOfDay and not na(activeHiLine)
    line.set_x2(activeHiLine, time + asProjMs)
    line.set_x2(activeLoLine, time + asProjMs)
if array.size(asianHiLbls) > 0
    aLblStyle = dwmHLLabelPos == "Outside left" ? label.style_label_right : dwmHLLabelPos == "Outside right" ? label.style_label_left : label.style_label_center
    aBg = showAsianLabels ? asianColor : color.new(asianColor, 100)
    aTx = showAsianLabels ? color.white : color.new(color.white, 100)
    for i = 0 to array.size(asianHiLbls) - 1
        hLn = array.get(asianHiLines, i)
        lLn = array.get(asianLoLines, i)
        ax1 = line.get_x1(hLn)
        ax2 = line.get_x2(hLn)
        aLblX = dwmHLLabelPos == "Outside left" ? ax1 : dwmHLLabelPos == "Outside right" ? ax2 : int(ax1 / 2 + ax2 / 2)
        hLb = array.get(asianHiLbls, i)
        lLb = array.get(asianLoLbls, i)
        label.set_xy(hLb, aLblX, line.get_y1(hLn))
        label.set_xy(lLb, aLblX, line.get_y1(lLn))
        label.set_style(hLb, aLblStyle)
        label.set_style(lLb, aLblStyle)
        label.set_color(hLb, aBg)
        label.set_color(lLb, aBg)
        label.set_textcolor(hLb, aTx)
        label.set_textcolor(lLb, aTx)

// ════════════════════════════════════════════════════════════════════════════
// RANGE POSITION (Asian / D / W / M, prior completed period, merge-proof)
// ════════════════════════════════════════════════════════════════════════════
exTz      = syminfo.timezone
_modNow   = hour(time, exTz) * 60 + minute(time, exTz)
_modPrev  = na(time[1]) ? na : hour(time[1], exTz) * 60 + minute(time[1], exTz)
sessOpenM = sessOpenHr * 60
sessNew   = na(_modPrev) or (_modNow >= sessOpenM and _modPrev < sessOpenM)

var float dHiCur = na
var float dLoCur = na
var float dHiPrev = na
var float dLoPrev = na
var int   dOpenCurT   = na
var int   dOpenPrevT  = na
var int   dClosePrevT = na
if sessNew
    dHiPrev     := dHiCur
    dLoPrev     := dLoCur
    dOpenPrevT  := dOpenCurT
    dClosePrevT := time[1]
    dOpenCurT   := time
    dHiCur := high
    dLoCur := low
else
    dHiCur := na(dHiCur) ? high : math.max(dHiCur, high)
    dLoCur := na(dLoCur) ? low  : math.min(dLoCur, low)
dayNew = sessNew and not na(dHiPrev)

wkDow  = weekStartDay == "Monday" ? dayofweek.monday : dayofweek.sunday
wkRoll = sessNew and dayofweek(time, exTz) == wkDow
var float wkHi = na
var float wkLo = na
var float priorWkHi = na
var float priorWkLo = na
var int   wkCurStartT  = na
var int   wkPrevStartT = na
var int   wkPrevEndT   = na
if wkRoll
    priorWkHi    := wkHi
    priorWkLo    := wkLo
    wkPrevStartT := wkCurStartT
    wkPrevEndT   := time[1]
    wkCurStartT  := time
    wkHi := high
    wkLo := low
else
    wkHi := na(wkHi) ? high : math.max(wkHi, high)
    wkLo := na(wkLo) ? low : math.min(wkLo, low)

[pmH, pmL, pmOpenT, pmCloseT] = request.security(syminfo.tickerid, "M", [high[1], low[1], time[1], time_close[1]], lookahead = barmerge.lookahead_on)
monNew = not na(pmOpenT) and pmOpenT != pmOpenT[1]

f_rngPct(_hi, _lo) => _hi > _lo ? (close - _lo) / (_hi - _lo) * 100.0 : na
f_rngCol(_pct) => na(_pct) ? offColor : _pct > 100 ? rangeAbove : _pct < 0 ? rangeBelow : rangeInside
asPct = f_rngPct(asianHi, asianLo)
dPct  = f_rngPct(dHiPrev, dLoPrev)
wPct  = f_rngPct(priorWkHi, priorWkLo)
mPct  = f_rngPct(pmH, pmL)

// ════════════════════════════════════════════════════════════════════════════
// DWM HL LINES (previous completed D/W/M high & low, non-repainting)
// ════════════════════════════════════════════════════════════════════════════
canShowDaily   = dwmHLDaily   and timeframe.isintraday
canShowWeekly  = dwmHLWeekly  and timeframe.isintraday
canShowMonthly = dwmHLMonthly and not timeframe.ismonthly
barMs = timeframe.in_seconds() * 1000
f_lblSz(s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small
f_drawDWM(bool _isNew, int _anchorT, int _endT, float _h, float _l, int _show, color _color, int _width, string _lblName, color _lblTxtCol, string _lblSzStr) =>
    var _highs   = array.new<line>()
    var _lows    = array.new<line>()
    var _ends    = array.new<int>()
    var _hLbls   = array.new<label>()
    var _lLbls   = array.new<label>()
    if _isNew and not na(_h) and not na(_l) and not na(_anchorT)
        nh = line.new(_anchorT, _h, _anchorT, _h, xloc = xloc.bar_time, color = _color, style = line.style_solid, width = _width)
        nl = line.new(_anchorT, _l, _anchorT, _l, xloc = xloc.bar_time, color = _color, style = line.style_solid, width = _width)
        array.push(_highs, nh)
        array.push(_lows, nl)
        array.push(_ends, _endT)
        array.push(_hLbls, label.new(_anchorT, _h, "", xloc = xloc.bar_time, textcolor = color.white, size = size.small))
        array.push(_lLbls, label.new(_anchorT, _l, "", xloc = xloc.bar_time, textcolor = color.white, size = size.small))
        if array.size(_highs) > _show
            line.delete(array.shift(_highs))
            line.delete(array.shift(_lows))
            array.shift(_ends)
            label.delete(array.shift(_hLbls))
            label.delete(array.shift(_lLbls))
        if dwmHLGradient
            _size = array.size(_highs)
            for i = 0 to _size - 1
                _steps = _size - 1 - i
                _t = math.min(95, _steps * 20)
                _c = color.new(_color, _t)
                line.set_color(array.get(_highs, i), _c)
                line.set_color(array.get(_lows, i), _c)
    _n = array.size(_highs)
    if _n > 0
        liveT = time
        projT = liveT + (dwmProject ? dwmProjBars * barMs : 0)
        _lblStyle = dwmHLLabelPos == "Outside left" ? label.style_label_right : dwmHLLabelPos == "Outside right" ? label.style_label_left : label.style_label_center
        _szC = f_lblSz(_lblSzStr)
        for i = 0 to _n - 1
            ownEnd = array.get(_ends, i)
            _x2 = dwmExtend ? projT : (na(ownEnd) ? liveT : ownEnd)
            hLn = array.get(_highs, i)
            lLn = array.get(_lows,  i)
            line.set_x2(hLn, _x2)
            line.set_x2(lLn, _x2)
            hLb = array.get(_hLbls, i)
            lLb = array.get(_lLbls, i)
            anchorT = line.get_x1(hLn)
            lblT = dwmHLLabelPos == "Outside left" ? anchorT : dwmHLLabelPos == "Outside right" ? _x2 : int(anchorT / 2 + _x2 / 2)
            _hVal = line.get_y1(hLn)
            _lVal = line.get_y1(lLn)
            _hBg = dwmHLLabels ? _color : color.new(_color, 100)
            _hTx = dwmHLLabels ? _lblTxtCol : color.new(_lblTxtCol, 100)
            label.set_xy(hLb, lblT, _hVal)
            label.set_xy(lLb, lblT, _lVal)
            label.set_text(hLb, _lblName + " High")
            label.set_text(lLb, _lblName + " Low")
            label.set_style(hLb, _lblStyle)
            label.set_style(lLb, _lblStyle)
            label.set_color(hLb, _hBg)
            label.set_color(lLb, _hBg)
            label.set_textcolor(hLb, _hTx)
            label.set_textcolor(lLb, _hTx)
            label.set_size(hLb, _szC)
            label.set_size(lLb, _szC)
if showDwmHL and canShowMonthly
    f_drawDWM(monNew, pmOpenT, pmCloseT, pmH, pmL, dwmHLMonthlyShow, dwmHLMonthlyColor, dwmHLMonthlyW, "Month", dwmLblMCol, dwmLblMSz)
if showDwmHL and canShowWeekly
    f_drawDWM(wkRoll, wkPrevStartT, wkPrevEndT, priorWkHi, priorWkLo, dwmHLWeeklyShow, dwmHLWeeklyColor, dwmHLWeeklyW, "Week", dwmLblWCol, dwmLblWSz)
if showDwmHL and canShowDaily
    f_drawDWM(dayNew, dOpenPrevT, dClosePrevT, dHiPrev, dLoPrev, dwmHLDailyShow, dwmHLDailyColor, dwmHLDailyW, "Day", dwmLblDCol, dwmLblDSz)

plot(priceScale and canShowDaily  ? dHiPrev   : na, "Day High",  color = dwmHLDailyColor,  display = display.price_scale, editable = false)
plot(priceScale and canShowDaily  ? dLoPrev   : na, "Day Low",   color = dwmHLDailyColor,  display = display.price_scale, editable = false)
plot(priceScale and canShowWeekly ? priorWkHi : na, "Week High", color = dwmHLWeeklyColor, display = display.price_scale, editable = false)
plot(priceScale and canShowWeekly ? priorWkLo : na, "Week Low",  color = dwmHLWeeklyColor, display = display.price_scale, editable = false)

// ════════════════════════════════════════════════════════════════════════════
// DWM/ASIAN ZONE ENGINE (yellow on in-zone expansion + band fills)
// ════════════════════════════════════════════════════════════════════════════
f_inBand(float _c, float _w, bool _gate, bool _isHigh) => _gate and not na(_c) and (_isHigh ? (close <= _c and close >= _c - _w) : (close >= _c and close <= _c + _w))
zFrac    = zonePct / 100.0
wDaily   = zFrac * (dHiPrev   - dLoPrev)
wWeekly  = zFrac * (priorWkHi - priorWkLo)
wMonthly = zFrac * (pmH       - pmL)
wAsian   = zFrac * (asianHi   - asianLo)
gDaily   = dwmHLOn and dwmHLDaily
gWeekly  = dwmHLOn and dwmHLWeekly
gMonthly = dwmHLOn and dwmHLMonthly
gAsian   = asianOn and not inAsian
inZone = f_inBand(dHiPrev, wDaily, gDaily, true) or f_inBand(dLoPrev, wDaily, gDaily, false) or f_inBand(priorWkHi, wWeekly, gWeekly, true) or f_inBand(priorWkLo, wWeekly, gWeekly, false) or f_inBand(pmH, wMonthly, gMonthly, true) or f_inBand(pmL, wMonthly, gMonthly, false) or f_inBand(asianHi, wAsian, gAsian, true) or f_inBand(asianLo, wAsian, gAsian, false)
var bool  zoneActive = false
var int   zoneBars = 0
var float zSumRange = 0.0
var float zSumVol = 0.0
var float zBaseRange = na
var float zBaseVol = na
var bool  zoneYellow = false
if zoneOn
    if inZone and not zoneActive
        zoneActive := true
        zoneBars := 0
        zSumRange := 0.0
        zSumVol := 0.0
        zBaseRange := na
        zBaseVol := na
        zoneYellow := false
    if zoneActive and inZone
        if zoneBars < zoneMinBars
            zSumRange := zSumRange + (high - low)
            zSumVol := zSumVol + volume
            zoneBars := zoneBars + 1
            if zoneBars == zoneMinBars
                zBaseRange := zSumRange / zoneMinBars
                zBaseVol := zSumVol / zoneMinBars
        else
            if not zoneYellow and (high - low) > zBaseRange * zoneRangeMult and volume > zBaseVol * zoneVolMult
                zoneYellow := true
    if zoneActive and not inZone
        zoneActive := false
        zoneYellow := false
zoneFired = zoneOn and zoneYellow and not zoneYellow[1]
candleCol = zoneOn and zoneYellow and zonePaint ? zoneYellow_c : na
// band fills
var box zbDHi = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbDLo = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbWHi = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbWLo = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbMHi = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbMLo = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbAHi = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
var box zbALo = box.new(time, close, time, close, xloc = xloc.bar_time, border_color = na, bgcolor = na, border_width = 1)
f_zbox(box _bx, bool _gate, float _c, float _w, int _lt, int _rt) =>
    if _gate and not na(_c) and not na(_w) and not na(_lt)
        box.set_left(_bx, _lt)
        box.set_right(_bx, _rt)
        box.set_top(_bx, _c + _w)
        box.set_bottom(_bx, _c - _w)
        box.set_bgcolor(_bx, zoneShowBands ? color.new(zoneBandColor, 90) : na)
        box.set_border_color(_bx, zoneShowEdges ? color.new(zoneBandColor, 30) : na)
    else
        box.set_bgcolor(_bx, na)
        box.set_border_color(_bx, na)
if zoneOn and (zoneShowBands or zoneShowEdges) and barstate.islast
    projRt = time + (dwmProject ? dwmProjBars * barMs : 0)
    f_zbox(zbDHi, gDaily and mLvlAll and mLvlDwm,   dHiPrev,   wDaily,   dOpenCurT,     projRt)
    f_zbox(zbDLo, gDaily and mLvlAll and mLvlDwm,   dLoPrev,   wDaily,   dOpenCurT,     projRt)
    f_zbox(zbWHi, gWeekly and mLvlAll and mLvlDwm,  priorWkHi, wWeekly,  wkCurStartT,   projRt)
    f_zbox(zbWLo, gWeekly and mLvlAll and mLvlDwm,  priorWkLo, wWeekly,  wkCurStartT,   projRt)
    f_zbox(zbMHi, gMonthly and mLvlAll and mLvlDwm, pmH,       wMonthly, pmOpenT,       projRt)
    f_zbox(zbMLo, gMonthly and mLvlAll and mLvlDwm, pmL,       wMonthly, pmOpenT,       projRt)
    f_zbox(zbAHi, gAsian and mLvlAll and mLvlAsian,   asianHi,   wAsian,   asianStartTime, projRt)
    f_zbox(zbALo, gAsian and mLvlAll and mLvlAsian,   asianLo,   wAsian,   asianStartTime, projRt)
plotcandle(open, high, low, close, "Zone expansion candles", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)

// ════════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE (BOS / CHoCH / SWEEP / STRONG PIVOT)
// ════════════════════════════════════════════════════════════════════════════
swpAtr = ta.atr(swpAtrLen)                       // unconditional — never gate the call
ictPh  = ta.pivothigh(high, ictLen, ictLen)
ictPl  = ta.pivotlow(low, ictLen, ictLen)
var float ictLsh = na
var int   ictLshBar = na
var bool  ictLshBroken = false
var float ictLsl = na
var int   ictLslBar = na
var bool  ictLslBroken = false
var int   ictDir = 0
if not na(ictPh)
    ictLsh := ictPh
    ictLshBar := bar_index - ictLen
    ictLshBroken := false
if not na(ictPl)
    ictLsl := ictPl
    ictLslBar := bar_index - ictLen
    ictLslBroken := false

// ── generic sweep tracker ────────────────────────────────────────────────────
// One call site per level side; each call site keeps its own state (same
// pattern as f_drawDWM). Sweep = raid + rejection close. Pending sweeps expire
// after the window, die if the level truly breaks (body close through), or die
// if the tracked level rolls to a new value. The sweep candle itself may be the
// displacement candle (classic SFP). Close-based → final at bar close.
f_sweep(bool _gate, float _lvl, bool _isHigh) =>
    var bool  _pend = false
    var float _ext  = na
    var int   _sBar = na
    var float _sLvl = na
    bool _sweepNew = false
    bool _fired    = false
    if _pend and (na(_lvl) or _lvl != _sLvl)
        _pend := false
    bool _raid = _gate and not na(_lvl) and (_isHigh ? high > _lvl and close < _lvl : low < _lvl and close > _lvl)
    if _raid
        if _pend
            _ext := _isHigh ? math.max(_ext, high) : math.min(_ext, low)
        else
            _pend := true
            _sweepNew := true
            _sLvl := _lvl
            _ext  := _isHigh ? high : low
            _sBar := bar_index
    if _pend and bar_index - _sBar > swpWindow
        _pend := false
    if _pend and (_isHigh ? close > _sLvl : close < _sLvl)   // body closed through → real break, not a grab
        _pend := false
    if _pend
        float _body   = math.abs(close - open)
        bool  _oppDir = _isHigh ? close < open : close > open
        if _oppDir and _body >= swpDispMult * swpAtr
            _fired := true
            _pend  := false
    [_sweepNew, _fired, _ext, _sBar, _sLvl]

// ── strong pivot drawing (shared arrays, capped) ────────────────────────────
var array<line>  spLines  = array.new<line>()
var array<label> spLabels = array.new<label>()
var array<box>   spBoxes  = array.new<box>()
var array<line>  spActive = array.new<line>()
var int lastSpHiBar = na
var int lastSpLoBar = na
var array<line> ictActive = array.new<line>()
if ictEos and timeframe.change("D")
    while array.size(ictActive) > 0
        line.delete(array.shift(ictActive))
    array.clear(spActive)                         // strong-pivot lines stay drawn; they just stop session-extending
ictX2 = ictEos ? bar_index : bar_index + ictExtend

f_spFire(bool _fired, float _ext, int _sBar, float _lvl, bool _isHigh, string _tag) =>
    if _fired
        line ln = line.new(_sBar, _ext, ictX2, _ext, color = swpCol, width = ictWidth + 1, style = line.style_solid)
        array.push(spLines, ln)
        array.push(spLabels, label.new(_sBar, _ext, "SP ✓ " + _tag, style = _isHigh ? label.style_label_down : label.style_label_up, color = color.new(swpCol, 15), textcolor = color.white, size = size.small))
        if ictEos
            array.push(spActive, ln)
        if swpBoxOn
            array.push(spBoxes, box.new(_sBar, _isHigh ? _ext : _lvl, bar_index, _isHigh ? _lvl : _ext, border_color = color.new(swpBoxCol, 40), bgcolor = swpBoxCol))
        while array.size(spLines) > swpShow
            line.delete(array.shift(spLines))
            label.delete(array.shift(spLabels))
        while array.size(spBoxes) > swpShow
            box.delete(array.shift(spBoxes))

// ── run the trackers (8 call sites: swing / Asian / prev-Day / prev-Week) ───
msGate = ictOn and swpOn
[swNewShH, swFireShH, swExtShH, swBarShH, swLvlShH] = f_sweep(msGate and swpSwing and not ictLshBroken, ictLsh, true)
[swNewShL, swFireShL, swExtShL, swBarShL, swLvlShL] = f_sweep(msGate and swpSwing and not ictLslBroken, ictLsl, false)
[swNewAsH, swFireAsH, swExtAsH, swBarAsH, swLvlAsH] = f_sweep(msGate and swpAsian and gAsian, asianHi, true)
[swNewAsL, swFireAsL, swExtAsL, swBarAsL, swLvlAsL] = f_sweep(msGate and swpAsian and gAsian, asianLo, false)
[swNewDH,  swFireDH,  swExtDH,  swBarDH,  swLvlDH ] = f_sweep(msGate and swpDay, dHiPrev, true)
[swNewDL,  swFireDL,  swExtDL,  swBarDL,  swLvlDL ] = f_sweep(msGate and swpDay, dLoPrev, false)
[swNewWH,  swFireWH,  swExtWH,  swBarWH,  swLvlWH ] = f_sweep(msGate and swpWeek, priorWkHi, true)
[swNewWL,  swFireWL,  swExtWL,  swBarWL,  swLvlWL ] = f_sweep(msGate and swpWeek, priorWkLo, false)

f_spFire(swFireShH, swExtShH, swBarShH, swLvlShH, true,  "Swing")
f_spFire(swFireShL, swExtShL, swBarShL, swLvlShL, false, "Swing")
f_spFire(swFireAsH, swExtAsH, swBarAsH, swLvlAsH, true,  "Asia H")
f_spFire(swFireAsL, swExtAsL, swBarAsL, swLvlAsL, false, "Asia L")
f_spFire(swFireDH,  swExtDH,  swBarDH,  swLvlDH,  true,  "PDH")
f_spFire(swFireDL,  swExtDL,  swBarDL,  swLvlDL,  false, "PDL")
f_spFire(swFireWH,  swExtWH,  swBarWH,  swLvlWH,  true,  "PWH")
f_spFire(swFireWL,  swExtWL,  swBarWL,  swLvlWL,  false, "PWL")

bool spHiEvt = swFireShH or swFireAsH or swFireDH or swFireWH
bool spLoEvt = swFireShL or swFireAsL or swFireDL or swFireWL
if spHiEvt
    lastSpHiBar := bar_index
if spLoEvt
    lastSpLoBar := bar_index
sweepEvt = swNewShH or swNewShL or swNewAsH or swNewAsL or swNewDH or swNewDL or swNewWH or swNewWL
spEvt    = spHiEvt or spLoEvt

// ── breaks: BOS / CHoCH / MSS (body close only) ──────────────────────────────
bool mssEvt = false
if ictOn and not na(ictLsh) and not ictLshBroken and close > ictLsh
    ictIsChoch = ictDir != 1
    bool isMssUp = ictIsChoch and swpOn and not na(lastSpLoBar) and bar_index - lastSpLoBar <= mssWindow
    if (ictIsChoch and ictCHOCH) or (not ictIsChoch and ictBOS)
        lnUp = line.new(ictLshBar, ictLsh, ictX2, ictLsh, color = ictBullCol, width = isMssUp ? ictWidth + 1 : ictWidth, style = isMssUp ? line.style_solid : ictIsChoch ? line.style_dotted : line.style_dashed)
        if ictShowLbl
            label.new(bar_index, ictLsh, isMssUp ? "MSS" : ictIsChoch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(ictBullCol, 25), textcolor = color.white, size = size.tiny)
        if ictEos
            array.push(ictActive, lnUp)
    mssEvt := mssEvt or isMssUp
    ictLshBroken := true
    ictDir := 1
if ictOn and not na(ictLsl) and not ictLslBroken and close < ictLsl
    ictIsChochD = ictDir != -1
    bool isMssDn = ictIsChochD and swpOn and not na(lastSpHiBar) and bar_index - lastSpHiBar <= mssWindow
    if (ictIsChochD and ictCHOCH) or (not ictIsChochD and ictBOS)
        lnDn = line.new(ictLslBar, ictLsl, ictX2, ictLsl, color = ictBearCol, width = isMssDn ? ictWidth + 1 : ictWidth, style = isMssDn ? line.style_solid : ictIsChochD ? line.style_dotted : line.style_dashed)
        if ictShowLbl
            label.new(bar_index, ictLsl, isMssDn ? "MSS" : ictIsChochD ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(ictBearCol, 25), textcolor = color.white, size = size.tiny)
        if ictEos
            array.push(ictActive, lnDn)
    mssEvt := mssEvt or isMssDn
    ictLslBroken := true
    ictDir := -1
if array.size(ictActive) > 0
    for i = 0 to array.size(ictActive) - 1
        line.set_x2(array.get(ictActive, i), bar_index)
if array.size(spActive) > 0
    for i = 0 to array.size(spActive) - 1
        line.set_x2(array.get(spActive, i), bar_index)

// ════════════════════════════════════════════════════════════════════════════
// STATUS BOX (volume participation + DWM bias rows)
// ════════════════════════════════════════════════════════════════════════════
f_boxPut(table _t, int _i, string _short, string _mk, color _mkC, string _lb, color _lbC, string _vl, color _vlC) =>
    if boxLayout == "Mobile grid"
        _r = int(_i / gridCols)
        _c = _i % gridCols
        _txt = _short + (_vl != "" ? " " + _vl : "")
        table.cell(_t, _c, _r, _txt, text_color = _mkC, text_size = txtSize, bgcolor = boxBg)
    else if boxLayout == "Horizontal"
        _txt = _mk + (showLabels and _lb != "" ? " " + _lb : "") + (_vl != "" ? " " + _vl : "")
        table.cell(_t, _i, 0, _txt, text_color = _mkC, text_size = txtSize, bgcolor = boxBg)
    else
        table.cell(_t, 0, _i, _mk, text_color = _mkC, text_size = lightSize, bgcolor = boxBg)
        table.cell(_t, 1, _i, showLabels ? _lb : "", text_color = _lbC, text_size = txtSize, bgcolor = boxBg)
        table.cell(_t, 2, _i, _vl, text_color = _vlC, text_size = pctSize, bgcolor = boxBg)

var table tl = na
var int    prevBoxRows = -1
var string prevLayout = ""
var int    prevCols = -1
nVol   = showVolOsc and bxFlow ? 1 : 0
nRange = showDwmBias ? 4 : 0
boxRows = nVol + nRange
gridRows = boxRows > 0 ? int(math.ceil(boxRows / gridCols)) : 0
nCols = boxLayout == "Mobile grid" ? gridCols : boxLayout == "Horizontal" ? boxRows : 3
nRows = boxLayout == "Mobile grid" ? gridRows : boxLayout == "Horizontal" ? 1 : boxRows
if showBox and boxRows > 0
    if na(tl) or prevBoxRows != boxRows or prevLayout != boxLayout or prevCols != gridCols
        if not na(tl)
            table.delete(tl)
        tl := table.new(posLookup, nCols, nRows, bgcolor = boxBg, border_width = 2, border_color = color.new(boxBorder, 50))
        prevBoxRows := boxRows
        prevLayout := boxLayout
        prevCols := gridCols
    if barstate.islast
        ci = 0
        if showVolOsc and bxFlow
            f_boxPut(tl, ci, "VOL", "●", volOscLightColor, "VOL OSC", color.new(txtColor, 30), str.tostring(volOscVal, "#") + "%", volOscLightColor)
            ci += 1
        if showDwmBias
            asTxt = na(asPct) ? "—" : str.tostring(asPct, "#") + "%"
            dTxt  = na(dPct)  ? "—" : str.tostring(dPct, "#") + "%"
            wTxt  = na(wPct)  ? "—" : str.tostring(wPct, "#") + "%"
            mTxt  = na(mPct)  ? "—" : str.tostring(mPct, "#") + "%"
            asCol = dwmFlashOn and f_nearQ(asPct, dwmFlashDist) ? dwmFlashColor : f_rngCol(asPct)
            dCol  = dwmFlashOn and f_nearQ(dPct,  dwmFlashDist) ? dwmFlashColor : f_rngCol(dPct)
            wCol  = dwmFlashOn and f_nearQ(wPct,  dwmFlashDist) ? dwmFlashColor : f_rngCol(wPct)
            mCol  = dwmFlashOn and f_nearQ(mPct,  dwmFlashDist) ? dwmFlashColor : f_rngCol(mPct)
            f_boxPut(tl, ci, "AS", "●", asCol, showLabels ? "Asian" : "AS", color.new(txtColor, 30), asTxt, asCol)
            ci += 1
            f_boxPut(tl, ci, "D", "●", dCol, showLabels ? "Day" : "D", color.new(txtColor, 30), dTxt, dCol)
            ci += 1
            f_boxPut(tl, ci, "W", "●", wCol, showLabels ? "Week" : "W", color.new(txtColor, 30), wTxt, wCol)
            ci += 1
            f_boxPut(tl, ci, "M", "●", mCol, showLabels ? "Month" : "M", color.new(txtColor, 30), mTxt, mCol)
            ci += 1

// ════════════════════════════════════════════════════════════════════════════
// ALERTS (set to "Once per bar close" — all events are close-based)
// ════════════════════════════════════════════════════════════════════════════
alertcondition(zoneFired, "Zone expansion (yellow)", "Stryk Ranges: in-zone range + volume expansion at a D/W/M/Asian level on {{ticker}} ({{interval}})")
alertcondition(sweepEvt, "Liquidity sweep", "Stryk Ranges: wick raid through a tracked level, body closed back inside on {{ticker}} ({{interval}})")
alertcondition(spEvt, "Strong pivot confirmed", "Stryk Ranges: sweep + displacement — strong pivot anchored on {{ticker}} ({{interval}})")
alertcondition(mssEvt, "MSS — validated reversal", "Stryk Ranges: CHoCH inside the MSS window of a strong pivot on {{ticker}} ({{interval}})")
````
