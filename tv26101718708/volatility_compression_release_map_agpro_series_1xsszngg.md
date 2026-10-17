# Volatility Compression Release Map [AGPro Series]

- url: https://www.tradingview.com/script/1XssZNgG-Volatility-Compression-Release-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;1c967e83e5c04a65b1301614c9d5d4c0
- version: 4.0

## Description

Volatility Compression Release Map [AGPro Series]

🧠 Core Idea

Is the market quietly building expansion energy, or has the release already failed back into the shelf?


📌 Overview / What it does

Volatility Compression Release Map [AGPro Series] is a volatility regime and compression shelf visualization tool built to identify quiet range contraction, release attempts, fake releases, and expansion quality.

The script maps a projected compression shelf when volatility rank and range size contract together. It then tracks whether price releases away from that shelf, returns back inside it, or continues to hold expansion pressure.

This script does not predict future price direction, automate trades, or produce guaranteed buy/sell signals. It is designed as a structured chart-reading layer for volatility compression, release quality, and contextual risk.


🎯 Purpose & Design Philosophy

The script was built for traders who care about the transition between quiet markets and expansion phases.

Many charts look calm before movement starts. The challenge is not simply seeing a tight range, but understanding whether that range is still building energy, whether the release is active, or whether the move has already failed back into the shelf.

The design philosophy is simple: reduce volatility noise into a readable map, preserve the important shelf story, and make the current regime understandable at first glance.


⚡ Why This Script Is Different

Most tools focus on breakout arrows, squeeze dots, or raw volatility bands.

This script does NOT treat every contraction as an immediate trade signal and does NOT frame every expansion candle as confirmation.

Instead, it builds a full compression-to-release map: the shelf, volatility rank, range size, release direction, fake-release risk, quality score, right-side state labels, and a compact AG Pro panel all work together.


⚙️ Methodology

1. Context Detection
The script evaluates ATR rank, recent range size, and whether price is still inside a quiet shelf.

2. Shelf Mapping
When compression conditions align, the active range is stored and projected forward as a compression shelf.

3. Release Evaluation
The script checks whether price leaves the shelf with enough candle body expansion to qualify as a release attempt.

4. Failure Tracking
If price quickly returns into the shelf during the fake-release window, the state changes to fake release.

5. Visual Output
The chart displays a projected shelf, dotted rails, a centered shelf-quality label, event labels, right-side state tags, and a compact AG Pro panel.


🗺️ How to Read the Chart

Zones represent the active compression shelf.

The shelf label shows the current shelf quality score using a compact `SHELF | Q` format.

Green/teal visual states generally indicate constructive expansion or defended release behavior.

Pink visual states highlight failed release or adverse volatility behavior.

Indigo/accent visuals represent compression and neutral shelf structure.

The panel summarizes compression state, release direction, volatility rank, range size, quality score, shelf range, and next context.


🚦 Signals & States

• COMPRESSION BUILD → a quiet shelf is forming and volatility is compressed

• RELEASE ACTIVE → price has moved away from the shelf with sufficient body expansion

• FAKE RELEASE → price returned back into the shelf after a release attempt

• SHELF WATCH → a shelf exists but the market has not produced a clean active release

• WAIT COMPRESSION → no valid compression shelf is currently active


🔔 Alerts Logic

Compression Build alert triggers when a new volatility compression shelf is detected.

Compression Release alert triggers when price releases from the active shelf with enough candle body expansion.

Fake Release alert triggers when price returns back into the shelf within the defined fake-release window.

Alerts are attention markers. They are not trade instructions.


🧩 Confluence Logic

The context becomes stronger when low volatility rank, compact range size, a visible shelf, and a strong release candle align.

The context becomes weaker when price fails back into the shelf shortly after release.


📊 When to Use

• Before potential expansion phases

• During quiet range compression

• Around breakout preparation zones

• When evaluating whether a move is expanding or failing

• On liquid markets where volatility structure is meaningful


⚠️ When NOT to Use

• Extremely illiquid symbols

• Very noisy low-timeframe charts

• News shock environments where volatility structure changes suddenly

• Markets with unreliable volume or large gaps

• Situations where a single indicator is being used without broader context


🎛️ Key Inputs

• Compression Lookback → controls the range window used to detect the shelf

• Volatility Rank Lookback → controls how ATR rank is measured

• Compression Rank Max → changes how selective compression detection is

• Range ATR Max → limits how wide a valid shelf can be

• Release Body ATR Min → defines how strong a release candle must be

• Fake Release Window → controls how quickly a release failure is detected

• Visual settings → control shelf projection, labels, panel, theme, and font sizes


🖥️ Interface & Visual Design

The interface is designed to look clean, premium, and publication-ready.

The shelf is the main visual anchor. Event labels are intentionally limited so the chart does not become crowded.

The AG Pro panel uses a merged blue header row and summarizes the state without covering the main chart story.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Locate the active compression shelf.

3. Check whether price is inside, releasing, or failing back into the shelf.

4. Compare the quality score with the visual structure.

5. Use broader market context before making any decision.


🔍 Interpretation Guidelines

Compression is not direction.

A shelf shows where volatility has contracted.

A release shows that price moved away from the shelf with expansion pressure.

A fake release shows that the market rejected the expansion and returned to the compression area.

The strongest interpretations come from combining the shelf, state, quality score, and surrounding market structure.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not guarantee profitable trades.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

Timeframe differences can change how compression and release behavior appears.

High volatility news events may reduce the usefulness of shelf-based interpretation.

Low-liquidity markets can produce misleading shelves and sudden false releases.

The script is rule-based and should always be interpreted within broader market context.


🧠 Market Context Notes

Volatility often contracts before expansion, but compression alone does not define direction.

The shelf helps identify where the market has stored recent range energy.

Release quality helps separate stronger expansion attempts from weak movement outside the range.


🧾 Use Case Examples

When price remains inside a shelf while volatility rank is low, the market may still be building energy.

When price leaves the shelf with strong body expansion, the script marks release behavior.

When price returns into the shelf quickly, the script flags a fake-release context.


🧱 System Philosophy

AGPro Series tools are built to turn complex market behavior into structured visual maps.

The goal is not to simplify markets into certainty, but to make important context easier to read.


🔐 Non-Promise Statement

No script can know the future.

No signal is certain.

No visual state should be treated as a guaranteed outcome.


📉 Risk Disclosure

Trading involves risk.

Markets can move unexpectedly.

Users are responsible for their own decisions, risk management, and trade execution.

This script does not provide financial advice.


📚 Educational Note

This tool is intended for educational and analytical use. It can help traders study volatility compression, release behavior, fake-release risk, and shelf-based market context.

## Source Code

````pine
// --------------------------------------------------
// Volatility Compression Release Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Volatility Compression Release Map highlights quiet range contraction,
// compression shelves, release attempts, failed releases, and expansion quality.
// It is designed for traders who want to read volatility regimes, breakout
// energy, fake expansion risk, and market structure context without turning the
// chart into a prediction or automation board. Version 1.6 adds distance-aware
// shelf visibility and a consolidated active-context badge so completed release
// origins no longer distort the live chart scale after price expansion.
// --------------------------------------------------

//@version=6
indicator("Volatility Compression Release Map [AGPro Series]",
     shorttitle = "AG Pro VCR",
     overlay = true,
     max_labels_count = 120,
     max_boxes_count = 40,
     max_lines_count = 50)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_CORE = "Core Logic"
compressionLookback = input.int(34, "Compression Lookback", minval = 12, maxval = 120, group = G_CORE,
     tooltip = "Defines the range window used to detect volatility compression shelves.")
rankLookback = input.int(120, "Volatility Rank Lookback", minval = 40, maxval = 300, group = G_CORE,
     tooltip = "Controls how far back ATR rank is compared. Higher values make the regime test slower and more selective.")
compressionRankMax = input.float(32.0, "Compression Rank Max", minval = 5.0, maxval = 70.0, step = 1.0, group = G_CORE,
     tooltip = "Maximum ATR rank allowed for a compression state. Lower values detect tighter volatility contractions.")
rangeAtrMax = input.float(3.6, "Range ATR Max", minval = 1.0, maxval = 14.0, step = 0.25, group = G_CORE,
     tooltip = "Maximum range size measured in ATR units for a valid compression shelf.")
releaseAtrMin = input.float(0.85, "Release Body ATR Min", minval = 0.25, maxval = 3.0, step = 0.05, group = G_CORE,
     tooltip = "Minimum candle body size in ATR units required for a release attempt.")
fakeBars = input.int(5, "Fake Release Window", minval = 2, maxval = 12, group = G_CORE,
     tooltip = "Number of bars used to decide whether a release quickly failed back into the compression shelf.")

G_VISUAL = "Visual Design"
showCompressionBox = input.bool(true, "Show Compression Shelf", group = G_VISUAL,
     tooltip = "Displays the active compression shelf as a projected zone.")
autoHideRemoteShelf = input.bool(true, "Auto-Hide Remote Shelf", group = G_VISUAL,
     tooltip = "Hides shelf drawings after price moves materially away, while preserving shelf values and state logic in the panel.")
remoteShelfAtr = input.float(5.0, "Remote Shelf Distance", minval = 1.0, maxval = 20.0, step = 0.5, group = G_VISUAL,
     tooltip = "Maximum distance from the shelf midpoint, measured in ATR, before remote shelf drawings are hidden.")
showShelfHalo = input.bool(true, "Show Shelf Halo", group = G_VISUAL,
     tooltip = "Adds a soft outer frame around the active compression shelf.")
showCenterLabel = input.bool(true, "Show Shelf Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the compression shelf.")
showMidline = input.bool(true, "Show Shelf Midline", group = G_VISUAL,
     tooltip = "Shows the midpoint of the active compression shelf.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows balanced release, compression, and failed release labels on the chart.")
showRightTags = input.bool(true, "Show Active Context Badge", group = G_VISUAL,
     tooltip = "Shows one consolidated current-state and quality badge on the right side of the chart.")
showPanel = input.bool(true, "Show Panel", group = G_VISUAL,
     tooltip = "Shows or hides the AG Pro information panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_VISUAL,
     tooltip = "Controls where the AG Pro panel is placed.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_VISUAL,
     tooltip = "Controls the panel color theme.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size of chart labels, shelf badge, and right-side tags.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls the font size of the panel.")
shelfHistoryBars = input.int(96, "Visible Shelf Bars", minval = 20, maxval = 260, group = G_VISUAL,
     tooltip = "Controls how far the active shelf reaches back from the latest bar.")
projectionBars = input.int(26, "Zone Projection Bars", minval = 8, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far the compression shelf is projected to the right.")
rightTagOffset = input.int(5, "Right Tag Offset", minval = 1, maxval = 40, group = G_VISUAL,
     tooltip = "Controls how far right-side tags sit from the latest bar.")
labelCooldownBars = input.int(52, "Event Label Cooldown", minval = 8, maxval = 160, group = G_VISUAL,
     tooltip = "Minimum number of bars between event labels. Higher values reduce label density.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 3, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
labelOffsetAtr = input.float(0.90, "Label Offset ATR", minval = 0.20, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Distance between event labels and candles, measured in ATR.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(86, 103, 130)
panelLabelCol = color.rgb(190, 202, 220)
panelValueCol = color.rgb(245, 247, 250)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posName) =>
    switch posName
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_fmt(float value) =>
    str.tostring(value, format.mintick)

f_dir_text(int direction) =>
    direction > 0 ? "Bullish" : direction < 0 ? "Bearish" : "Neutral"

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float luminance = (0.299 * r + 0.587 * g + 0.114 * b)
    luminance > 155.0 ? color.rgb(15, 23, 42) : color.white

f_set_box(box boxRef, int leftValue, int rightValue, float topValue, float bottomValue, color bg, color border, int borderWidth) =>
    box.set_left(boxRef, leftValue)
    box.set_right(boxRef, rightValue)
    box.set_top(boxRef, topValue)
    box.set_bottom(boxRef, bottomValue)
    box.set_bgcolor(boxRef, bg)
    box.set_border_color(boxRef, border)
    box.set_border_width(boxRef, borderWidth)

f_set_line(line lineRef, int x1, float y1, int x2, float y2, color col, styleValue, int widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, col)
    line.set_style(lineRef, styleValue)
    line.set_width(lineRef, widthValue)

f_set_tag(label tag, int x, float y, string labelText, color bg, styleValue, string textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, f_size(textSize))
    label.set_textalign(tag, text.align_center)

f_keep_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_panel_cell(table panelRef, int col, int row, string txt, color bg, color txtColor, string txtSize, string alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = f_size(txtSize), text_halign = alignValue)

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
atr = ta.atr(14)
atrSafe = math.max(atr, syminfo.mintick)
rangeHigh = ta.highest(high, compressionLookback)
rangeLow = ta.lowest(low, compressionLookback)
rangeSize = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangeAtr = rangeSize / atrSafe
atrRankRaw = ta.percentrank(atr, rankLookback)
atrRank = nz(atrRankRaw, 50.0)
bodyAtr = math.abs(close - open) / atrSafe
closeLocation = (close - rangeLow) / rangeSize
htfRangeRelax = timeframe.ismonthly ? 8.0 : timeframe.isweekly ? 6.2 : timeframe.isdaily ? 0.5 : 0.0
rangeAtrLimit = rangeAtrMax + htfRangeRelax
aboveShelf = close > rangeHigh[1]
belowShelf = close < rangeLow[1]
insideShelf = close <= rangeHigh and close >= rangeLow
compressionNow = atrRank <= compressionRankMax and rangeAtr <= rangeAtrLimit and insideShelf

var bool shelfMemory = false
var int shelfStart = na
var float shelfHigh = na
var float shelfLow = na
var int lastReleaseBar = na
var int releaseMemoryDir = 0
var float releaseQualityMemory = na
var bool fakeReleaseMemory = false

if compressionNow
    if not shelfMemory
        shelfStart := bar_index - compressionLookback + 1
    shelfMemory := true
    shelfHigh := rangeHigh
    shelfLow := rangeLow
    fakeReleaseMemory := false

shelfTop = na(shelfHigh) ? rangeHigh : shelfHigh
shelfBottom = na(shelfLow) ? rangeLow : shelfLow
shelfMid = (shelfTop + shelfBottom) * 0.50
upperBreak = close > shelfTop
lowerBreak = close < shelfBottom
currentRelease = shelfMemory and (upperBreak or lowerBreak) and bodyAtr >= releaseAtrMin
currentReleaseDir = upperBreak ? 1 : lowerBreak ? -1 : 0

if currentRelease
    lastReleaseBar := bar_index
    releaseMemoryDir := currentReleaseDir
    releaseQualityMemory := f_clamp(bodyAtr * 24.0 + math.abs(closeLocation - 0.50) * 55.0 + atrRank * 0.20 + rangeAtr * 3.0, 0.0, 100.0)

returnedInside = shelfMemory and not na(lastReleaseBar) and bar_index - lastReleaseBar <= fakeBars and close <= shelfTop and close >= shelfBottom
if returnedInside
    fakeReleaseMemory := true

releaseActive = shelfMemory and not fakeReleaseMemory and not na(lastReleaseBar) and bar_index - lastReleaseBar <= fakeBars * 3
expansionQuality = na(releaseQualityMemory) ? f_clamp((100.0 - atrRank) * 0.55 + (rangeAtrLimit - rangeAtr) * 6.0, 0.0, 100.0) : releaseQualityMemory
stateText = not shelfMemory ? "Wait Compression" : fakeReleaseMemory ? "Fake Release" : releaseActive ? "Release Active" : compressionNow ? "Compression Build" : "Shelf Watch"
stateColor = fakeReleaseMemory ? bearColor : releaseActive ? (releaseMemoryDir > 0 ? bullColor : bearColor) : compressionNow ? accentColor : neutralColor
nextContext = not shelfMemory ? "Wait quiet range" : fakeReleaseMemory ? "Recheck shelf" : releaseActive ? "Track expansion" : compressionNow ? "Energy building" : "Watch release"
shelfText = shelfMemory ? f_fmt(shelfBottom) + " / " + f_fmt(shelfTop) : "n/a"
shelfDistanceAtr = shelfMemory ? math.abs(close - shelfMid) / atrSafe : 0.0
shelfDrawActive = shelfMemory and showCompressionBox and (not autoHideRemoteShelf or shelfDistanceAtr <= remoteShelfAtr)

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box shelfHalo = na
var box shelfBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 88), border_color = accentColor, border_width = 3)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line midRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var label shelfCenter = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = color.white, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)

rightX = bar_index + projectionBars
tagX = bar_index + rightTagOffset
leftX = shelfMemory and not na(shelfStart) ? shelfStart : bar_index
drawLeftX = math.max(leftX, bar_index - shelfHistoryBars)
shelfLabelX = shelfMemory ? int(math.round(drawLeftX + (rightX - drawLeftX) * 0.66)) : bar_index
haloPad = atrSafe * 0.35

if barstate.islast and shelfDrawActive
    if showShelfHalo
        if na(shelfHalo)
            shelfHalo := box.new(drawLeftX, shelfTop + haloPad, rightX, shelfBottom - haloPad, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 94), border_color = color.new(stateColor, 58), border_width = 1)
        else
            f_set_box(shelfHalo, drawLeftX, rightX, shelfTop + haloPad, shelfBottom - haloPad, color.new(stateColor, 94), color.new(stateColor, 58), 1)
    else
        if not na(shelfHalo)
            box.delete(shelfHalo)
            shelfHalo := na
    f_set_box(shelfBox, drawLeftX, rightX, shelfTop, shelfBottom, color.new(stateColor, 91), color.new(stateColor, 0), 3)
    f_set_line(upperRail, drawLeftX, shelfTop, rightX, shelfTop, color.new(stateColor, 0), line.style_solid, 3)
    f_set_line(lowerRail, drawLeftX, shelfBottom, rightX, shelfBottom, color.new(stateColor, 0), line.style_solid, 3)
    if showMidline
        f_set_line(midRail, drawLeftX, shelfMid, rightX, shelfMid, color.new(stateColor, 20), line.style_dotted, 2)
    else
        f_set_line(midRail, bar_index, close, bar_index + 1, close, color.new(stateColor, 100), line.style_dotted, 1)
    if showCenterLabel
        f_set_tag(shelfCenter, shelfLabelX, shelfMid, "SHELF | Q" + f_score(expansionQuality), stateColor, label.style_label_center, labelSizeInput)
    else
        label.set_text(shelfCenter, "")
else if barstate.islast
    if not na(shelfHalo)
        box.delete(shelfHalo)
        shelfHalo := na
    f_set_box(shelfBox, bar_index, bar_index + 1, close, close, color.new(accentColor, 100), color.new(accentColor, 100), 1)
    f_set_line(upperRail, bar_index, close, bar_index + 1, close, color.new(accentColor, 100), line.style_dotted, 1)
    f_set_line(lowerRail, bar_index, close, bar_index + 1, close, color.new(accentColor, 100), line.style_dotted, 1)
    f_set_line(midRail, bar_index, close, bar_index + 1, close, color.new(accentColor, 100), line.style_dotted, 1)
    label.set_text(shelfCenter, "")

if barstate.islast and shelfMemory and showRightTags
    f_set_tag(stateTag, tagX, close, str.upper(stateText) + " | Q" + f_score(expansionQuality), stateColor, label.style_label_left, labelSizeInput)
else if barstate.islast
    label.set_text(stateTag, "")

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
newCompressionEvent = compressionNow and not compressionNow[1]
releaseEvent = currentRelease and not currentRelease[1]
fakeEvent = returnedInside and not returnedInside[1]
eventCandidate = newCompressionEvent or releaseEvent or fakeEvent
eventText = fakeEvent ? "FAKE RELEASE | Q" + f_score(expansionQuality) : releaseEvent ? "RELEASE | Q" + f_score(expansionQuality) : "COMPRESSION | Q" + f_score(expansionQuality)
eventColor = fakeEvent ? bearColor : releaseEvent ? stateColor : accentColor
eventY = releaseMemoryDir < 0 ? low - atrSafe * labelOffsetAtr : high + atrSafe * labelOffsetAtr
eventStyle = releaseMemoryDir < 0 ? label.style_label_up : label.style_label_down

if showEventLabels and eventCandidate and canPrintEvent
    label newEventLabel = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, style = eventStyle, textcolor = f_text_on(eventColor), color = eventColor, size = labelSize, textalign = text.align_center)
    f_keep_label(eventLabels, newEventLabel, maxEventLabels)
    lastEventBar := bar_index

barCol = fakeReleaseMemory ? color.new(bearColor, 55) : releaseActive ? color.new(stateColor, 65) : compressionNow ? color.new(accentColor, 78) : na
barcolor(barCol)

// --------------------------------------------------
// Release follow-through proof (stop-aware)
// --------------------------------------------------
// After each release, did price expand one ATR beyond the shelf edge before
// returning back inside the shelf? Win = expanded first, Loss = returned first,
// neither inside the window = uncounted.
var int   pfTotal    = 0
var int   pfWins     = 0
var bool  pfOpen     = false
var int   pfDir      = 0
var float pfWinLvl   = na
var float pfShelfTop = na
var float pfShelfBot = na
var int   pfBar      = na
int pfWindow = fakeBars * 4

if barstate.isconfirmed
    if pfOpen
        bool pfReenter = close <= pfShelfTop and close >= pfShelfBot
        bool pfWin = pfDir == 1 ? high >= pfWinLvl : low <= pfWinLvl
        if pfReenter
            pfTotal += 1
            pfOpen  := false
        else if pfWin
            pfTotal += 1
            pfWins  += 1
            pfOpen  := false
        else if not na(pfBar) and bar_index - pfBar > pfWindow
            pfOpen := false
    if releaseEvent and not pfOpen and currentReleaseDir != 0
        pfOpen     := true
        pfDir      := currentReleaseDir
        pfShelfTop := shelfTop
        pfShelfBot := shelfBottom
        pfWinLvl   := currentReleaseDir == 1 ? shelfTop + atrSafe : shelfBottom - atrSafe
        pfBar      := bar_index

float pfRate = pfTotal > 0 ? pfWins / pfTotal * 100.0 : na
releaseRateText = pfTotal >= 6 ? str.tostring(math.round(pfRate)) + "%  (" + str.tostring(pfTotal) + ")" : "Building (" + str.tostring(pfTotal) + ")"

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = panelThemeInput == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelBorderActive = panelThemeInput == "Dark" ? panelBorder : color.rgb(203, 213, 225)
panelLabelActive = panelThemeInput == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
panelValueActive = panelThemeInput == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
releaseRateCol = pfTotal >= 6 ? (pfRate >= 55.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor) : panelValueActive

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 9, bgcolor = panelBgActive, border_color = panelBorderActive, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    table.clear(panel, 0, 0, 1, 8)
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 0, "AG Pro Volatility Compression Release Map", headerBg, headerText, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 1, "Compression State", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 1, stateText, panelBgActive, stateColor, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 2, "Release Direction", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 2, f_dir_text(releaseMemoryDir), panelBgActive, stateColor, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 3, "Volatility Rank", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 3, f_score(atrRank), panelBgActive, panelValueActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 4, "Range Size", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 4, str.tostring(rangeAtr, "#.##") + " ATR", panelBgActive, panelValueActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 5, "Quality Score", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 5, f_score(expansionQuality), panelBgActive, panelValueActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 6, "Release Rate", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 6, releaseRateText, panelBgActive, releaseRateCol, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 7, "Shelf Range", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 7, shelfText, panelBgActive, panelValueActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 0, 8, "Next Context", panelBgActive, panelLabelActive, panelSizeInput, text.align_center)
    f_panel_cell(panel, 1, 8, nextContext, panelBgActive, panelValueActive, panelSizeInput, text.align_center)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(newCompressionEvent, "Compression Build", "Volatility compression shelf detected.")
alertcondition(releaseEvent, "Compression Release", "Price released from the active compression shelf.")
alertcondition(fakeEvent, "Fake Release", "Release returned into the compression shelf within the fake-release window.")
````
