# Range Detector

- url: https://www.tradingview.com/script/eY7Xp9fg-Range-Detector/
- type: indicator
- pine_id: PUB;4fc2ea0516664cd38fa0b4866e5653c6
- version: 1.0

## Description

range detector is built to identify real consolidation zones directly on the chart.

instead of marking every small pause as a range, the tool waits for price to remain contained between two boundaries for a minimum number of bars. the range must stay compact compared to volatility, avoid strong directional expansion, and remain valid until a confirmed breakout or structural widening occurs.

the goal is simple: help traders separate true sideways compression from normal market noise.

what the indicator detects

range detector searches for market areas where price is moving inside a controlled box instead of trending aggressively. a valid range is built from three main conditions:

price must stay contained between a top and bottom boundary
the height of the box must remain reasonable compared to atr
the structure must last long enough to confirm consolidation

once a range is active, the indicator displays:

top of the range
bottom of the range
midline equilibrium
range size classification
breakout markers
dashboard status

range size classification

each range is classified by height using atr units.

small range
medium range
large range

this helps understand whether the market is compressing tightly or building a wider consolidation structure. a tight range can be useful for breakout preparation, while a wider range can be useful for mean reversion, liquidity sweeps, and boundary reactions.

multi-timeframe detection

one of the most important features is the detection timeframe input.

by default, the detection timeframe is empty. this means the indicator uses the current chart timeframe.

for stronger structure, you can select a higher timeframe.

examples:

on a 5 minute chart, set detection timeframe to 1h to see larger intraday ranges
on a 15 minute chart, set detection timeframe to 4h to track stronger session structures
on a 1h chart, set detection timeframe to 1d to follow major daily compression zones

this is useful because a range detected on a higher timeframe is generally more important than a small range detected only on the chart timeframe.

when using mtf, the range engine runs directly on the selected detection timeframe. this means the boxes are not simply visual approximations from the lower timeframe. the range logic is calculated from the chosen timeframe structure.

how to use mtf correctly

for scalping, use a chart timeframe such as 1m, 3m, or 5m, then set the detection timeframe to 15m, 30m, or 1h.

for intraday trading, use a chart timeframe such as 5m, 15m, or 30m, then set the detection timeframe to 1h or 4h.

for swing trading, use a chart timeframe such as 1h or 4h, then set the detection timeframe to daily or weekly.

the higher the detection timeframe, the fewer ranges will appear, but the zones usually become more meaningful.

basic trading workflow

1. choose the chart timeframe

start with the timeframe you trade most often.

scalpers may use 1m to 5m.
intraday traders may use 15m to 1h.
swing traders may use 4h to daily.

2. set the detection timeframe

leave it empty for chart timeframe detection.

select a higher timeframe when you want cleaner and more structural ranges.

3. wait for an active range

when a range appears, price is currently moving inside a consolidation box. the top acts as upper range resistance, the bottom acts as lower range support, and the midline represents equilibrium.

4. study price behavior inside the box

near the top of the range, traders often watch for rejection, failed breakouts, or liquidity sweeps.

near the bottom of the range, traders often watch for absorption, failed breakdowns, or reversal behavior.

near the midline, price is usually less attractive because it is balanced between both sides.

5. wait for breakout confirmation

breakout markers appear only when price closes beyond the range boundary with the selected atr buffer.

a break above the range suggests upside expansion.
a break below the range suggests downside expansion.

the breakout buffer helps reduce false breaks by requiring extra distance beyond the range boundary.

main inputs explained

detection timeframe

selects the timeframe used to detect ranges. leave empty to use the current chart timeframe. use higher timeframes for cleaner structural ranges.

min consolidation bars

sets the minimum number of bars required before a range can be confirmed. higher values create fewer but stronger ranges. lower values make the tool more reactive.

reference atr length

controls the volatility reference used to evaluate range height and breakout buffer. a longer atr length gives a smoother volatility base.

max range height

defines the maximum allowed range height in atr units. if the box becomes too wide, the structure is no longer treated as a clean range.

breakout buffer

adds confirmation beyond the range boundary before a breakout is validated. increasing this value makes breakouts stricter.

small range threshold

defines the maximum atr height for a small range.

medium range threshold

defines the maximum atr height for a medium range. anything above this level is classified as large.

show small, medium, large

allows each range category to be shown or hidden independently.

show midline

displays the equilibrium level of the range.

show range labels

displays the range class and range height directly on the chart.

show breakout markers

displays breakout markers when price confirms an upside or downside break.

show dashboard

shows the live range dashboard.

dashboard position

moves the dashboard to any side or corner of the chart.

dashboard size

changes the text size of the dashboard.

range colors and opacity

each range category can be customized with its own color. fill opacity, border opacity, midline opacity, and label opacity can also be adjusted to match any chart style.

dashboard

the dashboard gives a fast reading of the current market state.

it shows:

active timeframe
current state
range height
top level
midline
bottom level

when no valid range is active, the dashboard shows that the market is trending or that no range is currently detected.

alerts

the indicator includes alerts for:

range started
range break up
range break down

these alerts can be used to monitor new compression zones and confirmed exits from consolidation.

example setups

scalping setup

chart timeframe: 5m
detection timeframe: 1h
min consolidation: 10 to 20 bars
breakout buffer: 0.20 to 0.35 atr

this setup keeps the chart reactive while using stronger higher timeframe structure.

intraday setup

chart timeframe: 15m
detection timeframe: 4h
min consolidation: 10 to 30 bars
breakout buffer: 0.25 to 0.50 atr

this setup is useful for session ranges and larger intraday breakouts.

swing setup

chart timeframe: 1h or 4h
detection timeframe: daily
min consolidation: 10 to 50 bars
breakout buffer: 0.35 to 0.75 atr

this setup focuses on major compression zones before larger directional moves.

practical interpretation

inside the range, the market is balanced.

above the range, buyers are attempting expansion.

below the range, sellers are attempting expansion.

the midline is the equilibrium zone. reactions near the top and bottom are usually more meaningful than signals in the middle.

range detector is not designed to predict direction by itself. it is designed to map consolidation, structure, compression, and breakout conditions so traders can build cleaner decisions around price behavior.

best used with:

market structure
volume analysis
session timing
liquidity sweeps
support and resistance
trend filters
risk management

risk note

no indicator guarantees a winning trade. always use risk management, wait for confirmation, and avoid trading during unclear market conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("Range Detector", shorttitle="Range D", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

gD = "Detection"
detTF = input.timeframe("", "Detection Timeframe (MTF)", group=gD, tooltip="Empty uses the chart timeframe. Select a higher timeframe to detect larger structural ranges.")
minBars = input.int(10, "Min Consolidation (bars)", minval=3, maxval=200, group=gD, tooltip="Minimum number of detection-timeframe bars required before a range can be validated.")
atrRef = input.int(100, "Reference ATR Length", minval=10, group=gD, tooltip="ATR length used as the volatility reference for range height and breakout buffer calculations.")
maxK = input.float(3.0, "Max Range Height (× ATR)", minval=0.5, step=0.25, group=gD, tooltip="Maximum allowed range height in ATR units. Above this value, the structure is treated as expansion instead of range.")
brkBuf = input.float(0.25, "Breakout Buffer (× ATR)", minval=0.0, step=0.05, group=gD, tooltip="Extra ATR buffer required beyond the range boundary before a breakout is confirmed.")

gT = "Size Thresholds"
smallK = input.float(1.0, "Small ≤", minval=0.1, step=0.1, group=gT, tooltip="Maximum range height in ATR units for the Small category.")
medK = input.float(2.0, "Medium ≤", minval=0.2, step=0.1, group=gT, tooltip="Maximum range height in ATR units for the Medium category. Values above this threshold are classified as Large.")
showSmall = input.bool(true, "Show Small", inline="sz", group=gT, tooltip="Show or hide Small range boxes. The dashboard remains active even when this is disabled.")
showMed = input.bool(true, "Show Medium", inline="sz", group=gT, tooltip="Show or hide Medium range boxes. The dashboard remains active even when this is disabled.")
showLarge = input.bool(true, "Show Large", inline="sz", group=gT, tooltip="Show or hide Large range boxes. The dashboard remains active even when this is disabled.")

gX = "Visual"
showMid = input.bool(true, "Show Midline", group=gX, tooltip="Show the equilibrium line in the middle of the active range.")
showLbl = input.bool(true, "Show Range Labels", group=gX, tooltip="Show a small label on each active range with its size class and height.")
showBrk = input.bool(true, "Show Breakout Markers", group=gX, tooltip="Show triangle markers when a confirmed breakout occurs.")
dashPos = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=gX, tooltip="Choose where the dashboard is displayed on the chart.")
dashSize = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=gX, tooltip="Controls the dashboard text size.")

gC = "Range Colors"
colSmall = input.color(#00FFD1, "Small Range Color", group=gC, tooltip="Color used for Small ranges.")
colMed = input.color(#FFD23F, "Medium Range Color", group=gC, tooltip="Color used for Medium ranges.")
colLarge = input.color(#FF3B5C, "Large Range Color", group=gC, tooltip="Color used for Large ranges.")
rangeFillOpacity = input.int(14, "Range Fill Opacity %", minval=0, maxval=100, group=gC, tooltip="Opacity of the range fill. 0 is invisible, 100 is fully opaque.")
rangeBorderOpacity = input.int(85, "Range Border Opacity %", minval=0, maxval=100, group=gC, tooltip="Opacity of the range border. 0 is invisible, 100 is fully opaque.")
midlineOpacity = input.int(55, "Midline Opacity %", minval=0, maxval=100, group=gC, tooltip="Opacity of the range midline. 0 is invisible, 100 is fully opaque.")
labelOpacity = input.int(85, "Label Opacity %", minval=0, maxval=100, group=gC, tooltip="Opacity of the range label background. 0 is invisible, 100 is fully opaque.")
colBrk = input.color(#9AB0C7, "Breakout Marker Color", group=gC, tooltip="Color used for confirmed breakout markers.")

detectRange() =>
    rATR = ta.atr(atrRef)
    hh = ta.highest(high, minBars)
    ll = ta.lowest(low, minBars)
    tight = (hh - ll) <= maxK * rATR
    var bool active = false
    var float top = na
    var float bot = na
    var int startT = na
    var int endR = 0
    endR := 0
    if not active
        if tight and rATR > 0
            active := true
            top := hh
            bot := ll
            startT := int(time[minBars - 1])
    else
        buf = brkBuf * rATR
        brokeUpLocal = close > top + buf
        brokeDnLocal = close < bot - buf
        if brokeUpLocal
            active := false
            endR := 1
        else if brokeDnLocal
            active := false
            endR := 2
        else
            top := math.max(top, high)
            bot := math.min(bot, low)
            if (top - bot) > maxK * rATR * 1.5
                active := false
                endR := 3
    h = nz(top) - nz(bot)
    sizeClass = h <= smallK * rATR ? 1 : h <= medK * rATR ? 2 : 3
    [active, top, bot, startT, sizeClass, endR, rATR]

detTFres = detTF == "" ? timeframe.period : detTF
[rActive, rTop, rBot, rStartT, rSz, rEnd, rATR] = request.security(syminfo.tickerid, detTFres, detectRange(), lookahead=barmerge.lookahead_off)
scanTop = request.security(syminfo.tickerid, detTFres, ta.highest(high, minBars), lookahead=barmerge.lookahead_off)
scanBot = request.security(syminfo.tickerid, detTFres, ta.lowest(low, minBars), lookahead=barmerge.lookahead_off)
scanAtr = request.security(syminfo.tickerid, detTFres, ta.atr(atrRef), lookahead=barmerge.lookahead_off)

clsCol(int s) => s == 1 ? colSmall : s == 2 ? colMed : colLarge
clsTxt(int s) => s == 1 ? "S" : s == 2 ? "M" : "L"
clsShow(int s) => s == 1 ? showSmall : s == 2 ? showMed : showLarge
trFromOpacity(int opacity) => 100 - opacity
dashPosition(string p) => p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Top Right" ? position.top_right : p == "Middle Left" ? position.middle_left : p == "Middle Center" ? position.middle_center : p == "Middle Right" ? position.middle_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Center" ? position.bottom_center : position.bottom_right
dashTextSize(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge
sizeName(int s) => s == 1 ? "SMALL" : s == 2 ? "MEDIUM" : "LARGE"

var box cBox = na
var line cMid = na
var label cLbl = na
var int cStart = na

newRange = rActive and (na(cStart) or rStartT != cStart)
endRange = not rActive and not na(cStart)

if newRange and not na(rStartT)
    cStart := rStartT
    col = clsCol(rSz)
    vis = clsShow(rSz)
    cBox := box.new(rStartT, rTop, int(time), rBot, xloc=xloc.bar_time, border_color=color.new(col, vis ? trFromOpacity(rangeBorderOpacity) : 100), bgcolor=color.new(col, vis ? trFromOpacity(rangeFillOpacity) : 100), border_width=1)
    cMid := showMid ? line.new(rStartT, (rTop + rBot) / 2, int(time), (rTop + rBot) / 2, xloc=xloc.bar_time, color=color.new(col, vis ? trFromOpacity(midlineOpacity) : 100), style=line.style_dotted) : na
    cLbl := showLbl ? label.new(rStartT, rTop, clsTxt(rSz) + " RANGE", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col, vis ? trFromOpacity(labelOpacity) : 100), textcolor=#0A0E14, size=size.tiny) : na
else if rActive and not na(cBox)
    col = clsCol(rSz)
    vis = clsShow(rSz)
    box.set_right(cBox, int(time))
    box.set_top(cBox, rTop)
    box.set_bottom(cBox, rBot)
    box.set_border_color(cBox, color.new(col, vis ? trFromOpacity(rangeBorderOpacity) : 100))
    box.set_bgcolor(cBox, color.new(col, vis ? trFromOpacity(rangeFillOpacity) : 100))
    if not na(cMid)
        mid = (rTop + rBot) / 2
        line.set_xy1(cMid, rStartT, mid)
        line.set_xy2(cMid, int(time), mid)
        line.set_color(cMid, color.new(col, vis ? trFromOpacity(midlineOpacity) : 100))
    if not na(cLbl)
        label.set_xy(cLbl, rStartT, rTop)
        label.set_text(cLbl, clsTxt(rSz) + " RANGE  " + str.tostring(rTop - rBot, format.mintick))
        label.set_color(cLbl, color.new(col, vis ? trFromOpacity(labelOpacity) : 100))

if endRange
    if not na(cBox)
        box.set_right(cBox, int(time))
    cStart := na
    cBox := na
    cMid := na
    cLbl := na

startedEvt = rActive and not rActive[1]
brokeUp = not rActive and rActive[1] and rEnd == 1
brokeDn = not rActive and rActive[1] and rEnd == 2

plotshape(showBrk and brokeUp, "Break Up", shape.triangleup, location.belowbar, color.new(colBrk, 0), size=size.tiny, text="BO▲", textcolor=colBrk)
plotshape(showBrk and brokeDn, "Break Down", shape.triangledown, location.abovebar, color.new(colBrk, 0), size=size.tiny, text="BO▼", textcolor=colBrk)

plot(rActive ? 1 : 0, "InRange", display=display.none)
plot(rActive ? rSz : 0, "RangeSize", display=display.none)
plot(rActive ? rTop : na, "RangeTop", display=display.none)
plot(rActive ? rBot : na, "RangeBot", display=display.none)
plot(rActive ? (rTop + rBot) / 2 : na, "RangeMid", display=display.none)

alertcondition(startedEvt, "Range Started", "Range Detector — a range has formed")
alertcondition(brokeUp, "Range Break Up", "Range Detector — range broken upward")
alertcondition(brokeDn, "Range Break Down", "Range Detector — range broken downward")

panelBg = color.new(#2B2F36, 4)
panelHead = color.new(#3A4048, 0)
panelRowA = color.new(#343A42, 8)
panelRowB = color.new(#2F353D, 8)
panelFrame = color.new(#6E7781, 35)
panelBorder = color.new(#535C66, 55)
panelText = #E7EAEE
panelMuted = #C2C7CE

var table dash = na
var string dashKey = ""

if na(dash) or dashKey != dashPos
    if not na(dash)
        table.delete(dash)
    dash := table.new(dashPosition(dashPos), 2, 7, bgcolor=panelBg, frame_color=panelFrame, frame_width=1, border_color=panelBorder, border_width=1)
    dashKey := dashPos

cell(int c, int r, string t, color tc, color bg) => table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=dashTextSize(dashSize), text_halign=text.align_left)

if barstate.islast and not na(dash)
    panelTop = rActive ? rTop : scanTop
    panelBot = rActive ? rBot : scanBot
    panelMid = (panelTop + panelBot) / 2
    panelH = panelTop - panelBot
    panelAtr = rActive ? rATR : scanAtr
    panelHAtr = not na(panelAtr) and panelAtr > 0 ? panelH / panelAtr : na
    panelState = rActive ? sizeName(rSz) + " RANGE" : "SCANNING"
    panelStateColor = rActive ? clsCol(rSz) : panelMuted
    cell(0, 0, "📦 RANGE DETECTOR", panelText, panelHead)
    cell(1, 0, "⚙️ LIVE", panelMuted, panelHead)
    cell(0, 1, "⏱️ TF", panelMuted, panelRowA)
    cell(1, 1, detTF == "" ? timeframe.period : detTF, panelText, panelRowA)
    cell(0, 2, "📊 STATE", panelMuted, panelRowB)
    cell(1, 2, panelState, panelStateColor, panelRowB)
    cell(0, 3, "📏 HEIGHT", panelMuted, panelRowA)
    cell(1, 3, na(panelH) ? "WAITING" : str.tostring(panelH, format.mintick) + (na(panelHAtr) ? "" : "  (" + str.tostring(panelHAtr, "0.0") + "×ATR)"), panelText, panelRowA)
    cell(0, 4, "🔼 TOP", panelMuted, panelRowB)
    cell(1, 4, na(panelTop) ? "WAITING" : str.tostring(panelTop, format.mintick), panelText, panelRowB)
    cell(0, 5, "⚖️ MID", panelMuted, panelRowA)
    cell(1, 5, na(panelMid) ? "WAITING" : str.tostring(panelMid, format.mintick), panelText, panelRowA)
    cell(0, 6, "🔽 BOTTOM", panelMuted, panelRowB)
    cell(1, 6, na(panelBot) ? "WAITING" : str.tostring(panelBot, format.mintick), panelText, panelRowB)
````
