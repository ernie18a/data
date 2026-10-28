# Abood's BPA

- url: https://www.tradingview.com/script/qqTXqeGa-Abood-s-BPA/
- type: indicator
- pine_id: PUB;df6141e49f8f431fb2828d3eac27c5da
- version: 1.0

## Description

[b]This Indicator Includes:

- 60-Minute EMA plotted on lower time frames

- Average Bar Range (ABR)

- Bar Count labels with flexible options:
1. Current bar only
2. Key bars only (18 & 40)
3. Any custom frequency

- Special bar pattern detection:
ii (Inside-Inside)
ioi (Inside-Outside-Inside)
OO (Outside-Outside)

## Source Code

````pine
//@version=6
indicator("Abood's BPA", overlay=true, max_labels_count=500)

//=====================================================================
// INPUTS
//=====================================================================

groupEMA = "Hourly EMA"

showEMA      = input.bool(true,  "Enable EMA",      group=groupEMA)
emaColor     = input.color(color.black, "EMA Color", group=groupEMA)
emaWidth     = input.int(1, "EMA Width", minval=1, maxval=5, group=groupEMA)
sessionInput = input.session("0930-1700", "Trading Session", group=groupEMA)
timeZone     = input.string("UTC-5", "Time Zone", group=groupEMA)

//=====================================================================
// ABR INPUTS
//=====================================================================

groupABR   = "ABR"
showABR    = input.bool(true, "Enable ABR", group=groupABR)
abrLength  = input.int(8, "ABR Length", minval=1, group=groupABR)
abrColor   = input.color(color.fuchsia, "ABR Color", group=groupABR)

//=====================================================================
// SESSION DETECTION
//=====================================================================

IsLastBarSession(sessionTime, sessionTimeZone=syminfo.timezone) =>
    var int lastBarHour   = na
    var int lastBarMinute = na
    var int lastBarSecond = na

    inSess = not na(time(timeframe.period, sessionTime, sessionTimeZone))

    if not inSess and inSess[1]
        lastBarHour   := hour[1]
        lastBarMinute := minute[1]
        lastBarSecond := second[1]

    hour == lastBarHour and minute == lastBarMinute and second == lastBarSecond

lastSessionBar = IsLastBarSession(sessionInput, timeZone)

//=====================================================================
// SESSION START
//=====================================================================

tick      = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
TimeFrame = input.timeframe("D", "Session Reset TF")

startr = request.security(
     tick,
     TimeFrame,
     time,
     lookahead = barmerge.lookahead_on)

newSession = ta.change(startr) != 0

var float timeopen = na
timeopen := newSession ? time : nz(timeopen[1])

timesinceopen = (time_close - timeopen) / 60000
hourclose     = (timesinceopen / 60 - math.round(timesinceopen / 60)) == 0

//=====================================================================
// ORIGINAL BROOKS 60M EMA LOGIC
//=====================================================================

my_ema(src, len) =>
    var float sum = na
    var float out = na

    sum := nz(sum[1]) - nz(src[len]) + src
    ma  = na(src[len]) ? na : sum / len

    out := na(out[1]) ?
         ma :
         hourclose or lastSessionBar ?
         out[1] + (2.0 / (len + 1)) * (src - out[1]) :
         out[1]

    out

lengthEMA = 20
myema     = my_ema(close, lengthEMA)

var float true_ema = na
true_ema := hourclose or lastSessionBar ? myema : na

var float intema   = na
var int   countsub = 1

countsub := na(true_ema) ? nz(countsub[1]) + 1 : 0

intema :=
     countsub >= 1 and not na(true_ema[countsub]) ?
     (true_ema[countsub] + (2.0 / (lengthEMA + 1.0)) * (close - true_ema[countsub])) :
     true_ema

plot(
     showEMA ? intema : na,
     color     = emaColor,
     linewidth = emaWidth,
     title     = "Hourly EMA")

//=====================================================================
// ABR
//=====================================================================

abr = ta.sma(high - low, abrLength)

var table abrTable = table.new(position.top_right, 1, 1)

if barstate.islast and showABR
    table.cell(
         abrTable,
         0,
         0,
         "ABR: " + str.tostring(abr, format.mintick),
         text_color = abrColor)

//=====================================================================
// BAR NUMBERS
//=====================================================================

groupBN = "Bar Numbers"

showBarNumbers = input.bool(true, "Enable Bar Numbers", group=groupBN)

bnMode = input.string(
     "Every X Bars",
     "Mode",
     options = ["Every X Bars", "Current Bar Only", "Only 18 & 40"],
     group   = groupBN)

sizeOption = input.string(
     "Normal",
     "Label Size",
     options = ["Auto", "Huge", "Large", "Normal", "Small", "Tiny"],
     group   = groupBN)

labelSize =
     sizeOption == "Huge"  ? size.huge  :
     sizeOption == "Large" ? size.large :
     sizeOption == "Small" ? size.small :
     sizeOption == "Tiny"  ? size.tiny  :
     sizeOption == "Auto"  ? size.auto  :
                             size.normal

bnColor = input.color(color.orange, "Text Color", group=groupBN)
bnEvery = input.int(2, "Display every X bars", minval=1, group=groupBN)

is_new_day() =>
    d = dayofweek
    na(d[1]) or d != d[1]

var int barCount = 1

if is_new_day()
    barCount := 1
else
    barCount += 1

var label bnLabel = na

if showBarNumbers
    if bnMode == "Current Bar Only" and not na(bnLabel)
        label.delete(bnLabel)

    showLabel =
         (bnMode == "Every X Bars" and barCount % bnEvery == 0) or
         (bnMode == "Current Bar Only") or
         (bnMode == "Only 18 & 40" and (barCount == 18 or barCount == 40))

    if showLabel
        bnLabel := label.new(
             x         = bar_index,
             y         = low,
             text      = str.tostring(barCount),
             style     = label.style_none,
             textcolor = bnColor,
             size      = labelSize,
             yloc      = yloc.belowbar)

//=====================================================================
// PATTERNS: ii, ioi, OO
//=====================================================================

groupPat = "Patterns"

// Location
patLocation = input.string(
     "Above Bar",
     "Location",
     options = ["Above Bar", "Below Bar"],
     group   = groupPat)

// Text mode
patTextMode = input.string(
     "Name",
     "Text Mode",
     options = ["Name", "Dot"],
     group   = groupPat)

// Text size
patSizeOpt = input.string(
     "Normal",
     "Text Size",
     options = ["Auto", "Huge", "Large", "Normal", "Small", "Tiny"],
     group   = groupPat)

// Colors
iiColor  = input.color(color.blue,  "ii Color",  group=groupPat)
ioiColor = input.color(color.green, "ioi Color", group=groupPat)
ooColor  = input.color(color.red,   "OO Color",  group=groupPat)

// Convert size
patSize =
     patSizeOpt == "Huge"  ? size.huge  :
     patSizeOpt == "Large" ? size.large :
     patSizeOpt == "Small" ? size.small :
     patSizeOpt == "Tiny"  ? size.tiny  :
     patSizeOpt == "Auto"  ? size.auto  :
                             size.normal

// Helpers
isInside(prevHigh, prevLow, curHigh, curLow) =>
    curHigh <= prevHigh and curLow >= prevLow

isOutside(prevHigh, prevLow, curHigh, curLow) =>
    curHigh > prevHigh and curLow < prevLow

h1 = high[1]
l1 = low[1]
h2 = high[2]
l2 = low[2]

// Patterns
ii  = isInside(h1, l1, high, low) and isInside(h2, l2, h1, l1)
ioi = isInside(h1, l1, high, low) and isOutside(h2, l2, h1, l1)

// OO = two consecutive outside bars
outsidePrev = isOutside(h2, l2, h1, l1)
outsideCur  = isOutside(h1, l1, high, low)
oo  = outsidePrev and outsideCur

// Text mode
iiText  = patTextMode == "Name" ? "ii"  : "•"
ioiText = patTextMode == "Name" ? "ioi" : "•"
ooText  = patTextMode == "Name" ? "oo"  : "•"

// Location
isAbove = patLocation == "Above Bar"
ylocPat = isAbove ? yloc.abovebar : yloc.belowbar
yPrice  = isAbove ? high : low

// Draw labels (clean text only, no background)
if ii
    label.new(
         bar_index,
         yPrice,
         iiText,
         style     = label.style_none,
         textcolor = iiColor,
         size      = patSize,
         yloc      = ylocPat)

if ioi
    label.new(
         bar_index,
         yPrice,
         ioiText,
         style     = label.style_none,
         textcolor = ioiColor,
         size      = patSize,
         yloc      = ylocPat)

if oo
    label.new(
         bar_index,
         yPrice,
         ooText,
         style     = label.style_none,
         textcolor = ooColor,
         size      = patSize,
         yloc      = ylocPat)
````
