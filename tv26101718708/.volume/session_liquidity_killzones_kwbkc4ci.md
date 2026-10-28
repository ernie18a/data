# Session Liquidity Killzones

- url: https://www.tradingview.com/script/KWBKc4CI-Session-Liquidity-Killzones/
- type: indicator
- pine_id: PUB;5738e1ff65c043b6b6f16a60c6d67c88
- version: 1.0

## Description

[b]Session Liquidity Killzones[/b]
Session Liquidity Killzones is a session-based liquidity and sweep indicator by ImtiyazAli73, designed for intraday traders who track Asia, London, and New York killzones.

The script marks each session range, extends completed session highs/lows, detects when later sessions sweep prior session liquidity, and highlights post-sweep expansion candles. It is built as a decision-support tool, not as a guaranteed buy/sell signal system.

[b]What It Shows[/b]
[list]
[*]Asia, London, and New York killzone boxes.
[*]Completed session high, low, and optional midpoint levels.
[*]London sweeps of Asia high/low.
[*]New York sweeps of London high/low.
[*]Optional New York sweeps of Asia high/low.
[*]Compact sweep markers, with optional text labels.
[*]One-shot bullish and bearish post-sweep expansion markers.
[*]Optional compressed session range markers.
[*]Dashboard showing current session, latest range readings, sweep state, compression state, and latest expansion bias.
[/list]

[b]How It Works[/b]

The indicator tracks each configured session using the selected timezone. When a session starts, the script begins building that session's high/low range. When the session ends, the completed high, low, and midpoint can be extended forward as reference liquidity levels.

Sweep detection compares the current killzone against completed prior session levels:

[list]
[*]London can sweep the Asia high or low.
[*]New York can sweep the London high or low.
[*]New York can also sweep Asia levels if that option is enabled.
[/list]

Sweep confirmation can use either wick touch logic or stricter close-back-inside logic. After a sweep, the script watches for displacement candles within the selected expansion window.

[b]Main Settings[/b]

Session Timezone controls how the Asia, London, and New York session windows are interpreted.

Asia Killzone, London Killzone, and New York Killzone define the exact session windows.

Sweep Confirmation controls whether a sweep requires price to close back inside the swept level or only touch it with a wick.

Expansion Window After Sweep controls how many bars after a sweep are eligible for post-sweep expansion detection.

Displacement Candle ATR controls how large the expansion candle must be relative to ATR.

Require Volume Expansion optionally filters expansion signals using volume relative to a moving average baseline.

Compressed Session Max ATR marks session ranges that end below the selected ATR multiple.

Completed Sessions To Keep controls how much history remains on the chart. The default is intentionally low to keep price action readable.

Show Sweep Marker Text can be enabled when you want detailed labels, but the default compact marker mode keeps the chart cleaner.

Show Session Midlines and Show Compression Markers are optional visual layers and are disabled by default for readability.

[b]Alerts[/b]

The indicator includes alerts for:

[list]
[*]Asia killzone start.
[*]London killzone start.
[*]New York killzone start.
[*]Buy-side session liquidity sweep.
[*]Sell-side session liquidity sweep.
[*]Bullish post-sweep expansion.
[*]Bearish post-sweep expansion.
[*]Compressed killzone range.
[/list]

[b]How To Use[/b]

Use the session boxes to understand where each killzone created its high and low. Watch later sessions for sweeps of prior highs/lows, then check whether the market expands away from the swept level.

A sell-side sweep followed by bullish expansion can suggest upside displacement after liquidity was taken. A buy-side sweep followed by bearish expansion can suggest downside displacement after liquidity was taken.

The dashboard is intended to summarize session state quickly, but all signals should be interpreted with market context, risk management, and independent analysis.

[b]Originality[/b]

This script combines configurable killzone tracking, prior-session liquidity levels, sweep confirmation modes, ATR-based expansion detection, optional volume expansion filtering, compression readings, and a compact dashboard into a single original session-liquidity workflow.

[b]Disclaimer[/b]

This script is for educational and informational purposes only. Trading involves risk. Always do your own analysis before taking any trade.

## Source Code

````pine
//@version=6
indicator("Session Liquidity Killzones", "Session KZ", overlay=true, max_boxes_count=200, max_lines_count=300, max_labels_count=300)

// Disclaimer: This script is for educational and informational purposes only.
// Trading involves risk. Always do your own analysis before taking any trade.

grpSessions = "Killzone Sessions"
sessionTz = input.string("America/New_York", "Session Timezone", group=grpSessions)
asiaSession = input.session("2000-0000", "Asia Killzone", group=grpSessions)
londonSession = input.session("0200-0500", "London Killzone", group=grpSessions)
nySession = input.session("0830-1100", "New York Killzone", group=grpSessions)
trackAsiaDuringNy = input.bool(true, "NY Can Sweep Asia Liquidity", group=grpSessions)

grpDetection = "Sweep and Expansion"
sweepMode = input.string("Close Back Inside", "Sweep Confirmation", options=["Close Back Inside", "Wick Touch"], group=grpDetection)
atrLen = input.int(14, "ATR Length", minval=2, group=grpDetection)
expansionLookback = input.int(3, "Expansion Window After Sweep", minval=1, maxval=10, group=grpDetection)
displacementAtr = input.float(0.8, "Displacement Candle ATR", minval=0.1, maxval=5.0, step=0.1, group=grpDetection)
useVolumeFilter = input.bool(false, "Require Volume Expansion", group=grpDetection)
volumeLen = input.int(30, "Volume Baseline Length", minval=2, group=grpDetection)
volumeMult = input.float(1.2, "Volume Expansion Multiplier", minval=0.1, maxval=5.0, step=0.1, group=grpDetection)
compressionAtr = input.float(1.1, "Compressed Session Max ATR", minval=0.1, maxval=10.0, step=0.1, group=grpDetection)

grpVisual = "Visuals"
showBoxes = input.bool(true, "Show Session Boxes", group=grpVisual)
showLevels = input.bool(true, "Show Completed Session High/Low", group=grpVisual)
showMidlines = input.bool(false, "Show Session Midlines", group=grpVisual)
showSweeps = input.bool(true, "Show Sweep Markers", group=grpVisual)
showSweepText = input.bool(false, "Show Sweep Marker Text", group=grpVisual)
showExpansion = input.bool(true, "Show Expansion Markers", group=grpVisual)
showCompression = input.bool(false, "Show Compression Markers", group=grpVisual)
showDashboard = input.bool(true, "Show Dashboard", group=grpVisual)
extendBars = input.int(60, "Level Extension Bars", minval=10, maxval=500, group=grpVisual)
keepCompletedSessions = input.int(5, "Completed Sessions To Keep", minval=1, maxval=30, group=grpVisual)
asiaColor = input.color(color.rgb(40, 150, 255), "Asia Color", group=grpVisual)
londonColor = input.color(color.rgb(245, 170, 55), "London Color", group=grpVisual)
nyColor = input.color(color.rgb(0, 185, 120), "New York Color", group=grpVisual)
bullColor = input.color(color.rgb(0, 180, 100), "Bullish Expansion Color", group=grpVisual)
bearColor = input.color(color.rgb(235, 70, 70), "Bearish Expansion Color", group=grpVisual)
neutralColor = input.color(color.rgb(145, 150, 160), "Neutral Color", group=grpVisual)

inAsia = not na(time(timeframe.period, asiaSession, sessionTz))
inLondon = not na(time(timeframe.period, londonSession, sessionTz))
inNy = not na(time(timeframe.period, nySession, sessionTz))

asiaStart = inAsia and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart = inNy and not inNy[1]
asiaEnd = not inAsia and inAsia[1]
londonEnd = not inLondon and inLondon[1]
nyEnd = not inNy and inNy[1]

atr = ta.atr(atrLen)
volBase = ta.sma(volume, volumeLen)
volumeOk = not useVolumeFilter or volume >= volBase * volumeMult
displacementOk = high - low >= atr * displacementAtr and volumeOk

var float asiaHigh = na
var float asiaLow = na
var int asiaStartBar = na
var float lastAsiaHigh = na
var float lastAsiaLow = na
var float lastAsiaRangeAtr = na
var box asiaBox = na
var line asiaHighLine = na
var line asiaLowLine = na
var line asiaMidLine = na
var array<box> sessionBoxes = array.new_box()
var array<line> sessionLines = array.new_line()

var float londonHigh = na
var float londonLow = na
var int londonStartBar = na
var float lastLondonHigh = na
var float lastLondonLow = na
var float lastLondonRangeAtr = na
var box londonBox = na
var line londonHighLine = na
var line londonLowLine = na
var line londonMidLine = na

var float nyHigh = na
var float nyLow = na
var int nyStartBar = na
var float lastNyHigh = na
var float lastNyLow = na
var float lastNyRangeAtr = na
var box nyBox = na
var line nyHighLine = na
var line nyLowLine = na
var line nyMidLine = na

f_boxBg(color c) =>
    color.new(c, showBoxes ? 92 : 100)

f_boxBorder(color c) =>
    color.new(c, showBoxes ? 55 : 100)

f_levelColor(color c) =>
    color.new(c, showLevels ? 35 : 100)

f_midColor(color c) =>
    color.new(c, showLevels and showMidlines ? 75 : 100)

f_keepBox(box b) =>
    array.push(sessionBoxes, b)
    if array.size(sessionBoxes) > keepCompletedSessions
        box.delete(array.shift(sessionBoxes))

f_keepLine(line l) =>
    array.push(sessionLines, l)
    if array.size(sessionLines) > keepCompletedSessions * 3
        line.delete(array.shift(sessionLines))

f_sweptHigh(float level) =>
    not na(level) and (sweepMode == "Close Back Inside" ? high > level and close < level : high >= level)

f_sweptLow(float level) =>
    not na(level) and (sweepMode == "Close Back Inside" ? low < level and close > level : low <= level)

if asiaStart
    asiaHigh := high
    asiaLow := low
    asiaStartBar := bar_index
    asiaBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=f_boxBg(asiaColor), border_color=f_boxBorder(asiaColor))
    f_keepBox(asiaBox)

if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)
    if not na(asiaBox)
        box.set_lefttop(asiaBox, nz(asiaStartBar, bar_index), asiaHigh)
        box.set_rightbottom(asiaBox, bar_index, asiaLow)
        box.set_bgcolor(asiaBox, f_boxBg(asiaColor))
        box.set_border_color(asiaBox, f_boxBorder(asiaColor))

if asiaEnd
    lastAsiaHigh := asiaHigh
    lastAsiaLow := asiaLow
    lastAsiaRangeAtr := (asiaHigh - asiaLow) / math.max(atr, syminfo.mintick)
    float mid = math.avg(asiaHigh, asiaLow)
    asiaHighLine := line.new(asiaStartBar, asiaHigh, bar_index + extendBars, asiaHigh, xloc=xloc.bar_index, color=f_levelColor(asiaColor), style=line.style_solid)
    asiaLowLine := line.new(asiaStartBar, asiaLow, bar_index + extendBars, asiaLow, xloc=xloc.bar_index, color=f_levelColor(asiaColor), style=line.style_solid)
    asiaMidLine := line.new(asiaStartBar, mid, bar_index + extendBars, mid, xloc=xloc.bar_index, color=f_midColor(asiaColor), style=line.style_dotted)
    f_keepLine(asiaHighLine)
    f_keepLine(asiaLowLine)
    f_keepLine(asiaMidLine)

if londonStart
    londonHigh := high
    londonLow := low
    londonStartBar := bar_index
    londonBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=f_boxBg(londonColor), border_color=f_boxBorder(londonColor))
    f_keepBox(londonBox)

if inLondon
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow := math.min(nz(londonLow, low), low)
    if not na(londonBox)
        box.set_lefttop(londonBox, nz(londonStartBar, bar_index), londonHigh)
        box.set_rightbottom(londonBox, bar_index, londonLow)
        box.set_bgcolor(londonBox, f_boxBg(londonColor))
        box.set_border_color(londonBox, f_boxBorder(londonColor))

if londonEnd
    lastLondonHigh := londonHigh
    lastLondonLow := londonLow
    lastLondonRangeAtr := (londonHigh - londonLow) / math.max(atr, syminfo.mintick)
    float mid = math.avg(londonHigh, londonLow)
    londonHighLine := line.new(londonStartBar, londonHigh, bar_index + extendBars, londonHigh, xloc=xloc.bar_index, color=f_levelColor(londonColor), style=line.style_solid)
    londonLowLine := line.new(londonStartBar, londonLow, bar_index + extendBars, londonLow, xloc=xloc.bar_index, color=f_levelColor(londonColor), style=line.style_solid)
    londonMidLine := line.new(londonStartBar, mid, bar_index + extendBars, mid, xloc=xloc.bar_index, color=f_midColor(londonColor), style=line.style_dotted)
    f_keepLine(londonHighLine)
    f_keepLine(londonLowLine)
    f_keepLine(londonMidLine)

if nyStart
    nyHigh := high
    nyLow := low
    nyStartBar := bar_index
    nyBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=f_boxBg(nyColor), border_color=f_boxBorder(nyColor))
    f_keepBox(nyBox)

if inNy
    nyHigh := math.max(nz(nyHigh, high), high)
    nyLow := math.min(nz(nyLow, low), low)
    if not na(nyBox)
        box.set_lefttop(nyBox, nz(nyStartBar, bar_index), nyHigh)
        box.set_rightbottom(nyBox, bar_index, nyLow)
        box.set_bgcolor(nyBox, f_boxBg(nyColor))
        box.set_border_color(nyBox, f_boxBorder(nyColor))

if nyEnd
    lastNyHigh := nyHigh
    lastNyLow := nyLow
    lastNyRangeAtr := (nyHigh - nyLow) / math.max(atr, syminfo.mintick)
    float mid = math.avg(nyHigh, nyLow)
    nyHighLine := line.new(nyStartBar, nyHigh, bar_index + extendBars, nyHigh, xloc=xloc.bar_index, color=f_levelColor(nyColor), style=line.style_solid)
    nyLowLine := line.new(nyStartBar, nyLow, bar_index + extendBars, nyLow, xloc=xloc.bar_index, color=f_levelColor(nyColor), style=line.style_solid)
    nyMidLine := line.new(nyStartBar, mid, bar_index + extendBars, mid, xloc=xloc.bar_index, color=f_midColor(nyColor), style=line.style_dotted)
    f_keepLine(nyHighLine)
    f_keepLine(nyLowLine)
    f_keepLine(nyMidLine)

if barstate.islast
    if not na(asiaHighLine)
        line.set_x2(asiaHighLine, bar_index + extendBars)
        line.set_x2(asiaLowLine, bar_index + extendBars)
        line.set_x2(asiaMidLine, bar_index + extendBars)
        line.set_color(asiaHighLine, f_levelColor(asiaColor))
        line.set_color(asiaLowLine, f_levelColor(asiaColor))
        line.set_color(asiaMidLine, f_midColor(asiaColor))
    if not na(londonHighLine)
        line.set_x2(londonHighLine, bar_index + extendBars)
        line.set_x2(londonLowLine, bar_index + extendBars)
        line.set_x2(londonMidLine, bar_index + extendBars)
        line.set_color(londonHighLine, f_levelColor(londonColor))
        line.set_color(londonLowLine, f_levelColor(londonColor))
        line.set_color(londonMidLine, f_midColor(londonColor))
    if not na(nyHighLine)
        line.set_x2(nyHighLine, bar_index + extendBars)
        line.set_x2(nyLowLine, bar_index + extendBars)
        line.set_x2(nyMidLine, bar_index + extendBars)
        line.set_color(nyHighLine, f_levelColor(nyColor))
        line.set_color(nyLowLine, f_levelColor(nyColor))
        line.set_color(nyMidLine, f_midColor(nyColor))

var bool londonAsiaHighDone = false
var bool londonAsiaLowDone = false
var bool nyLondonHighDone = false
var bool nyLondonLowDone = false
var bool nyAsiaHighDone = false
var bool nyAsiaLowDone = false

if londonStart
    londonAsiaHighDone := false
    londonAsiaLowDone := false

if nyStart
    nyLondonHighDone := false
    nyLondonLowDone := false
    nyAsiaHighDone := false
    nyAsiaLowDone := false

rawLondonSweepsAsiaHigh = inLondon and f_sweptHigh(lastAsiaHigh)
rawLondonSweepsAsiaLow = inLondon and f_sweptLow(lastAsiaLow)
rawNySweepsLondonHigh = inNy and f_sweptHigh(lastLondonHigh)
rawNySweepsLondonLow = inNy and f_sweptLow(lastLondonLow)
rawNySweepsAsiaHigh = inNy and trackAsiaDuringNy and f_sweptHigh(lastAsiaHigh)
rawNySweepsAsiaLow = inNy and trackAsiaDuringNy and f_sweptLow(lastAsiaLow)

londonSweepsAsiaHigh = rawLondonSweepsAsiaHigh and not londonAsiaHighDone
londonSweepsAsiaLow = rawLondonSweepsAsiaLow and not londonAsiaLowDone
nySweepsLondonHigh = rawNySweepsLondonHigh and not nyLondonHighDone
nySweepsLondonLow = rawNySweepsLondonLow and not nyLondonLowDone
nySweepsAsiaHigh = rawNySweepsAsiaHigh and not nyAsiaHighDone
nySweepsAsiaLow = rawNySweepsAsiaLow and not nyAsiaLowDone

if londonSweepsAsiaHigh
    londonAsiaHighDone := true
if londonSweepsAsiaLow
    londonAsiaLowDone := true
if nySweepsLondonHigh
    nyLondonHighDone := true
if nySweepsLondonLow
    nyLondonLowDone := true
if nySweepsAsiaHigh
    nyAsiaHighDone := true
if nySweepsAsiaLow
    nyAsiaLowDone := true

buySideSweep = londonSweepsAsiaHigh or nySweepsLondonHigh or nySweepsAsiaHigh
sellSideSweep = londonSweepsAsiaLow or nySweepsLondonLow or nySweepsAsiaLow

var bool bullExpansionDone = false
var bool bearExpansionDone = false

if sellSideSweep
    bullExpansionDone := false
if buySideSweep
    bearExpansionDone := false

barsSinceSellSweep = ta.barssince(sellSideSweep)
barsSinceBuySweep = ta.barssince(buySideSweep)
rawBullExpansion = showExpansion and not na(barsSinceSellSweep) and barsSinceSellSweep <= expansionLookback and displacementOk and close > open and close > ta.highest(high, 3)[1]
rawBearExpansion = showExpansion and not na(barsSinceBuySweep) and barsSinceBuySweep <= expansionLookback and displacementOk and close < open and close < ta.lowest(low, 3)[1]
bullExpansion = rawBullExpansion and not bullExpansionDone
bearExpansion = rawBearExpansion and not bearExpansionDone

if bullExpansion
    bullExpansionDone := true
if bearExpansion
    bearExpansionDone := true

asiaCompressed = asiaEnd and not na(lastAsiaRangeAtr) and lastAsiaRangeAtr <= compressionAtr
londonCompressed = londonEnd and not na(lastLondonRangeAtr) and lastLondonRangeAtr <= compressionAtr
nyCompressed = nyEnd and not na(lastNyRangeAtr) and lastNyRangeAtr <= compressionAtr

var int lastBias = 0
if bullExpansion
    lastBias := 1
if bearExpansion
    lastBias := -1

currentSession = inAsia ? "Asia" : inLondon ? "London" : inNy ? "New York" : "Outside"
biasText = lastBias == 1 ? "Bullish expansion" : lastBias == -1 ? "Bearish expansion" : "Waiting"
biasColor = lastBias == 1 ? bullColor : lastBias == -1 ? bearColor : neutralColor
rangeAsiaText = na(lastAsiaRangeAtr) ? "-" : str.tostring(lastAsiaRangeAtr, "#.##") + " ATR"
rangeLondonText = na(lastLondonRangeAtr) ? "-" : str.tostring(lastLondonRangeAtr, "#.##") + " ATR"
rangeNyText = na(lastNyRangeAtr) ? "-" : str.tostring(lastNyRangeAtr, "#.##") + " ATR"

plotshape(showSweeps and not showSweepText and londonSweepsAsiaHigh, "London Swept Asia High", shape.xcross, location.abovebar, color.new(londonColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and londonSweepsAsiaHigh, "London Swept Asia High Text", shape.xcross, location.abovebar, color.new(londonColor, 0), text="LON > Asia H", textcolor=londonColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and not showSweepText and londonSweepsAsiaLow, "London Swept Asia Low", shape.xcross, location.belowbar, color.new(londonColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and londonSweepsAsiaLow, "London Swept Asia Low Text", shape.xcross, location.belowbar, color.new(londonColor, 0), text="LON < Asia L", textcolor=londonColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and not showSweepText and nySweepsLondonHigh, "NY Swept London High", shape.xcross, location.abovebar, color.new(nyColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and nySweepsLondonHigh, "NY Swept London High Text", shape.xcross, location.abovebar, color.new(nyColor, 0), text="NY > Lon H", textcolor=nyColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and not showSweepText and nySweepsLondonLow, "NY Swept London Low", shape.xcross, location.belowbar, color.new(nyColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and nySweepsLondonLow, "NY Swept London Low Text", shape.xcross, location.belowbar, color.new(nyColor, 0), text="NY < Lon L", textcolor=nyColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and not showSweepText and nySweepsAsiaHigh, "NY Swept Asia High", shape.circle, location.abovebar, color.new(asiaColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and nySweepsAsiaHigh, "NY Swept Asia High Text", shape.circle, location.abovebar, color.new(asiaColor, 0), text="NY > Asia H", textcolor=asiaColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and not showSweepText and nySweepsAsiaLow, "NY Swept Asia Low", shape.circle, location.belowbar, color.new(asiaColor, 0), text="", size=size.tiny, display=display.all - display.status_line)
plotshape(showSweeps and showSweepText and nySweepsAsiaLow, "NY Swept Asia Low Text", shape.circle, location.belowbar, color.new(asiaColor, 0), text="NY < Asia L", textcolor=asiaColor, size=size.tiny, display=display.all - display.status_line)
plotshape(bullExpansion, "Bullish Post-Sweep Expansion", shape.labelup, location.belowbar, color.new(bullColor, 0), text="EXP UP", textcolor=color.white, size=size.tiny, display=display.all - display.status_line)
plotshape(bearExpansion, "Bearish Post-Sweep Expansion", shape.labeldown, location.abovebar, color.new(bearColor, 0), text="EXP DN", textcolor=color.white, size=size.tiny, display=display.all - display.status_line)
plotshape(showCompression and asiaCompressed, "Asia Compression", shape.diamond, location.bottom, color.new(asiaColor, 0), text="Asia C", textcolor=asiaColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showCompression and londonCompressed, "London Compression", shape.diamond, location.bottom, color.new(londonColor, 0), text="Lon C", textcolor=londonColor, size=size.tiny, display=display.all - display.status_line)
plotshape(showCompression and nyCompressed, "New York Compression", shape.diamond, location.bottom, color.new(nyColor, 0), text="NY C", textcolor=nyColor, size=size.tiny, display=display.all - display.status_line)

var table dash = table.new(position.top_right, 2, 7, border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Session KZ", text_color=color.white, bgcolor=biasColor)
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=biasColor)
    table.cell(dash, 0, 1, "Session", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 1, currentSession, text_color=inAsia ? asiaColor : inLondon ? londonColor : inNy ? nyColor : neutralColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 2, "Asia range", text_color=asiaColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 2, rangeAsiaText, text_color=asiaColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 3, "London range", text_color=londonColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 3, rangeLondonText, text_color=londonColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 4, "NY range", text_color=nyColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 4, rangeNyText, text_color=nyColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 5, "Sweep", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 5, buySideSweep ? "Buy-side" : sellSideSweep ? "Sell-side" : "None", text_color=buySideSweep ? bearColor : sellSideSweep ? bullColor : neutralColor, bgcolor=color.new(color.black, 0))
    table.cell(dash, 0, 6, "Compression", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 6, asiaCompressed ? "Asia" : londonCompressed ? "London" : nyCompressed ? "NY" : "-", text_color=asiaCompressed ? asiaColor : londonCompressed ? londonColor : nyCompressed ? nyColor : neutralColor, bgcolor=color.new(color.black, 0))
else if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 6)

alertcondition(asiaStart, "Asia Killzone Started", "Asia killzone started on {{ticker}} {{interval}}.")
alertcondition(londonStart, "London Killzone Started", "London killzone started on {{ticker}} {{interval}}.")
alertcondition(nyStart, "New York Killzone Started", "New York killzone started on {{ticker}} {{interval}}.")
alertcondition(buySideSweep, "Buy-Side Session Liquidity Sweep", "Buy-side session liquidity swept on {{ticker}} {{interval}} near {{close}}.")
alertcondition(sellSideSweep, "Sell-Side Session Liquidity Sweep", "Sell-side session liquidity swept on {{ticker}} {{interval}} near {{close}}.")
alertcondition(bullExpansion, "Bullish Post-Sweep Expansion", "Bullish post-sweep expansion on {{ticker}} {{interval}} near {{close}}.")
alertcondition(bearExpansion, "Bearish Post-Sweep Expansion", "Bearish post-sweep expansion on {{ticker}} {{interval}} near {{close}}.")
alertcondition(asiaCompressed or londonCompressed or nyCompressed, "Compressed Killzone Range", "A killzone ended with compressed range on {{ticker}} {{interval}}.")
````
