# Tonka's Signal Bar Indicator

- url: https://www.tradingview.com/script/Z56J5qFS-Tonka-s-Signal-Bar-Indicator/
- type: indicator
- pine_id: PUB;10ff09276ef644a18de0b8a47541d4dd
- version: 1.0

## Description

Tonka’s Signal Bar Indicator is a discretionary price action support indicator designed to highlight potential Savvy-style signal candles around manually entered key levels.

The indicator is built for traders who use institutional-style levels, liquidity context, and displacement candles to identify potential continuation, bounce, and rejection setups.

It allows up to 20 manual Savvy Levels to be entered, then monitors price action around those levels for four core signal types:

CB — Continuation Buy
A bullish continuation candle where the candle body accepts through a key level, with a configurable percentage of the body closing beyond the level.

CS — Continuation Sell
A bearish continuation candle where the candle body accepts through a key level, with a configurable percentage of the body closing beyond the level.

BB — Bounce Buy
A two-candle bullish bounce setup where price tags a level and then reacts away from it with a bullish confirmation candle.

RS — Rejection Sell
A two-candle bearish rejection setup where price tags a level and then reacts away from it with a bearish confirmation candle.

The indicator also includes optional external range liquidity context using:

Previous Day High / Low
Asia Session High / Low
13:20–14:20 UK Initial Balance High / Low

Signal candles can be upgraded to A+ when recent ERL context supports the trade idea, helping identify higher-quality setups after buy-side or sell-side liquidity has been taken.

Key features:

Up to 20 manually entered Savvy Levels
Continuation, bounce, and rejection signal detection
Configurable body size, body percentage, and structure-break filters
Optional A+ liquidity context
Previous day, Asia, and IB levels
Customisable line colours, styles, and widths
Optional signal labels and candle colouring
Built-in alerts for bullish, bearish, and A+ signal candles

This indicator is not designed to provide automatic trade entries or exits. It is intended to highlight potential signal candles and provide structure around discretionary execution, allowing the trader to make the final decision based on context, market structure, liquidity, and trade management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Tonka's Signal Bars", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

//--------------------------------------------------
// Session Inputs
//--------------------------------------------------
string SESSION_TZ   = input.string("Europe/London", "Session Timezone")
string ASIA_SESSION = input.session("2300-0700", "Asia Session For ERL Context")
string IB_SESSION   = input.session("1320-1420", "IB Session")

//--------------------------------------------------
// Signal Candle Inputs
//--------------------------------------------------
float displacementMult = input.float(1.20, "Signal Bar Body Multiplier", minval = 1.0, step = 0.1)
float bodyToRangeMin   = input.float(0.65, "Minimum Body % of Candle", minval = 0.1, maxval = 1.0, step = 0.05)

int bodyLookback         = input.int(20, "Average Body Lookback", minval = 5)
int savvyToleranceTicks  = input.int(15, "Savvy Level Tolerance Ticks", minval = 1)

float minBodyBeyondLevelPct = input.float(0.50, "Minimum BODY Beyond Level %", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "For CB/CS continuation signals. Requires this percentage of the candle body to be beyond the Savvy Level.")

bool requireApproachCandleDirection = input.bool(true, "BB/RS Require Approach Candle Direction")
bool requireReactionBreakBody       = input.bool(true, "BB/RS Require Reaction Break Previous Body")

bool requireStructureBreak = input.bool(true, "Require Signal Candle To Break Short-Term Structure")
int structureBreakLookback = input.int(3, "Structure Break Lookback", minval = 2)

int erlLookbackBars = input.int(300, "ERL Valid Lookback Bars", minval = 1, tooltip = "How long ERL remains valid after being swept. On a 2-minute chart, 300 bars = 10 hours.")

//--------------------------------------------------
// Visual Inputs
//--------------------------------------------------
bool onlyShowAPlus       = input.bool(false, "Only Show A+ Signals")
bool showSavvyLevels     = input.bool(true, "Show Savvy Levels")
bool showSignalLabels    = input.bool(true, "Show Signal Labels")
bool colourSignalBars    = input.bool(true, "Colour Signal Bars")
bool showERLLevels       = input.bool(true, "Show PDH/PDL + Asia H/L")
bool showIBLevels        = input.bool(true, "Show 13:20-14:20 IB H/L")
bool showERLMarkers      = input.bool(false, "Show ERL Sweep Markers")
bool showERLStatusLabel  = input.bool(false, "Show ERL Status Label")

color prevDayLineColor = input.color(color.blue, "Previous Day Level Colour")
string prevDayLineStyleInput = input.string("Solid", "Previous Day Line Type", options = ["Solid", "Dashed", "Dotted"])
int prevDayLineWidth = input.int(1, "Previous Day Line Width", minval = 1, maxval = 5)

color asiaLineColor = input.color(color.fuchsia, "Asia Level Colour")
string asiaLineStyleInput = input.string("Dashed", "Asia Line Type", options = ["Solid", "Dashed", "Dotted"])
int asiaLineWidth = input.int(1, "Asia Line Width", minval = 1, maxval = 5)

color ibLineColor = input.color(color.white, "IB Level Colour")
string ibLineStyleInput = input.string("Dashed", "IB Line Type", options = ["Solid", "Dashed", "Dotted"])
int ibLineWidth = input.int(1, "IB Line Width", minval = 1, maxval = 5)

//--------------------------------------------------
// Manual Savvy Levels - Up To 20
//--------------------------------------------------
bool useSavvy1  = input.bool(false, "Use Savvy Level 1")
float savvy1    = input.float(0.0, "Savvy Level 1 Price")
bool useSavvy2  = input.bool(false, "Use Savvy Level 2")
float savvy2    = input.float(0.0, "Savvy Level 2 Price")
bool useSavvy3  = input.bool(false, "Use Savvy Level 3")
float savvy3    = input.float(0.0, "Savvy Level 3 Price")
bool useSavvy4  = input.bool(false, "Use Savvy Level 4")
float savvy4    = input.float(0.0, "Savvy Level 4 Price")
bool useSavvy5  = input.bool(false, "Use Savvy Level 5")
float savvy5    = input.float(0.0, "Savvy Level 5 Price")
bool useSavvy6  = input.bool(false, "Use Savvy Level 6")
float savvy6    = input.float(0.0, "Savvy Level 6 Price")
bool useSavvy7  = input.bool(false, "Use Savvy Level 7")
float savvy7    = input.float(0.0, "Savvy Level 7 Price")
bool useSavvy8  = input.bool(false, "Use Savvy Level 8")
float savvy8    = input.float(0.0, "Savvy Level 8 Price")
bool useSavvy9  = input.bool(false, "Use Savvy Level 9")
float savvy9    = input.float(0.0, "Savvy Level 9 Price")
bool useSavvy10 = input.bool(false, "Use Savvy Level 10")
float savvy10   = input.float(0.0, "Savvy Level 10 Price")

bool useSavvy11 = input.bool(false, "Use Savvy Level 11")
float savvy11   = input.float(0.0, "Savvy Level 11 Price")
bool useSavvy12 = input.bool(false, "Use Savvy Level 12")
float savvy12   = input.float(0.0, "Savvy Level 12 Price")
bool useSavvy13 = input.bool(false, "Use Savvy Level 13")
float savvy13   = input.float(0.0, "Savvy Level 13 Price")
bool useSavvy14 = input.bool(false, "Use Savvy Level 14")
float savvy14   = input.float(0.0, "Savvy Level 14 Price")
bool useSavvy15 = input.bool(false, "Use Savvy Level 15")
float savvy15   = input.float(0.0, "Savvy Level 15 Price")
bool useSavvy16 = input.bool(false, "Use Savvy Level 16")
float savvy16   = input.float(0.0, "Savvy Level 16 Price")
bool useSavvy17 = input.bool(false, "Use Savvy Level 17")
float savvy17   = input.float(0.0, "Savvy Level 17 Price")
bool useSavvy18 = input.bool(false, "Use Savvy Level 18")
float savvy18   = input.float(0.0, "Savvy Level 18 Price")
bool useSavvy19 = input.bool(false, "Use Savvy Level 19")
float savvy19   = input.float(0.0, "Savvy Level 19 Price")
bool useSavvy20 = input.bool(false, "Use Savvy Level 20")
float savvy20   = input.float(0.0, "Savvy Level 20 Price")

//--------------------------------------------------
// Utility
//--------------------------------------------------
float tick = syminfo.mintick
float savvyTol = savvyToleranceTicks * tick
bool newDay = ta.change(time("D")) != 0

f_validLevel(float lvl) =>
    not na(lvl) and lvl > 0

f_lineStyle(string styleInput) =>
    styleInput == "Solid" ? line.style_solid :
     styleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

float candleRange = math.max(high - low, syminfo.mintick)
float bodySize = math.abs(close - open)
float avgBody = ta.sma(bodySize, bodyLookback)

float bodyHigh = math.max(open, close)
float bodyLow = math.min(open, close)
float bodyRange = math.max(bodyHigh - bodyLow, syminfo.mintick)

float prevBodyHigh = math.max(open[1], close[1])
float prevBodyLow = math.min(open[1], close[1])

bool bodyLargeEnough = bodySize > avgBody * displacementMult
bool bodyCleanEnough = candleRange > 0 and bodySize >= candleRange * bodyToRangeMin

bool bullBreaksStructure = close > ta.highest(high, structureBreakLookback)[1]
bool bearBreaksStructure = close < ta.lowest(low, structureBreakLookback)[1]

//--------------------------------------------------
// Level interaction helpers
//--------------------------------------------------
f_candleTouchesLevel(float lvl) =>
    f_validLevel(lvl) and high >= lvl - savvyTol and low <= lvl + savvyTol

f_prevCandleTouchesLevel(float lvl) =>
    f_validLevel(lvl) and high[1] >= lvl - savvyTol and low[1] <= lvl + savvyTol

f_bodyCrossesLevel(float lvl) =>
    f_validLevel(lvl) and bodyHigh >= lvl and bodyLow <= lvl

f_bodyPctAboveLevel(float lvl) =>
    f_bodyCrossesLevel(lvl) ? math.max(0.0, math.min(1.0, (bodyHigh - lvl) / bodyRange)) : 0.0

f_bodyPctBelowLevel(float lvl) =>
    f_bodyCrossesLevel(lvl) ? math.max(0.0, math.min(1.0, (lvl - bodyLow) / bodyRange)) : 0.0

//--------------------------------------------------
// Continuation logic
//--------------------------------------------------
f_continuationBuy(float lvl) =>
    f_validLevel(lvl) and
     close > open and
     close > lvl and
     f_bodyPctAboveLevel(lvl) >= minBodyBeyondLevelPct

f_continuationSell(float lvl) =>
    f_validLevel(lvl) and
     close < open and
     close < lvl and
     f_bodyPctBelowLevel(lvl) >= minBodyBeyondLevelPct

//--------------------------------------------------
// Two-candle bounce / rejection logic
//--------------------------------------------------
f_bounceBuy(float lvl) =>
    f_validLevel(lvl) and
     f_prevCandleTouchesLevel(lvl) and
     close > open and
     close > lvl and
     (requireApproachCandleDirection ? close[1] < open[1] : true) and
     (requireReactionBreakBody ? close > prevBodyHigh : true)

f_rejectionSell(float lvl) =>
    f_validLevel(lvl) and
     f_prevCandleTouchesLevel(lvl) and
     close < open and
     close < lvl and
     (requireApproachCandleDirection ? close[1] > open[1] : true) and
     (requireReactionBreakBody ? close < prevBodyLow : true)

//--------------------------------------------------
// Level arrays
//--------------------------------------------------
bool[] useArr = array.from(
     useSavvy1, useSavvy2, useSavvy3, useSavvy4, useSavvy5,
     useSavvy6, useSavvy7, useSavvy8, useSavvy9, useSavvy10,
     useSavvy11, useSavvy12, useSavvy13, useSavvy14, useSavvy15,
     useSavvy16, useSavvy17, useSavvy18, useSavvy19, useSavvy20
)

float[] lvlArr = array.from(
     savvy1, savvy2, savvy3, savvy4, savvy5,
     savvy6, savvy7, savvy8, savvy9, savvy10,
     savvy11, savvy12, savvy13, savvy14, savvy15,
     savvy16, savvy17, savvy18, savvy19, savvy20
)

//--------------------------------------------------
// Find level interaction
//--------------------------------------------------
f_findBullLevel() =>
    float found = na
    string typ = ""

    for i = 0 to array.size(lvlArr) - 1
        bool use = array.get(useArr, i)
        float lvl = array.get(lvlArr, i)

        if use and f_validLevel(lvl)
            if f_continuationBuy(lvl)
                found := lvl
                typ := "CB"
            else if f_bounceBuy(lvl)
                found := lvl
                typ := "BB"

    [found, typ]

f_findBearLevel() =>
    float found = na
    string typ = ""

    for i = 0 to array.size(lvlArr) - 1
        bool use = array.get(useArr, i)
        float lvl = array.get(lvlArr, i)

        if use and f_validLevel(lvl)
            if f_continuationSell(lvl)
                found := lvl
                typ := "CS"
            else if f_rejectionSell(lvl)
                found := lvl
                typ := "RS"

    [found, typ]

//--------------------------------------------------
// Draw Savvy levels
//--------------------------------------------------
var line[] savvyLines = array.new_line()

if barstate.isfirst
    for i = 0 to 19
        line l = line.new(bar_index, close, bar_index + 1, close, extend = extend.both, color = color.purple, width = 2)
        array.push(savvyLines, l)

for i = 0 to array.size(savvyLines) - 1
    line l = array.get(savvyLines, i)
    bool use = array.get(useArr, i)
    float lvl = array.get(lvlArr, i)

    if showSavvyLevels and use and f_validLevel(lvl)
        line.set_xy1(l, bar_index - 1, lvl)
        line.set_xy2(l, bar_index, lvl)
        line.set_color(l, color.purple)
        line.set_width(l, 2)
    else
        line.set_color(l, color.new(color.purple, 100))

//--------------------------------------------------
// ERL Context - PDH / PDL / Asia H / Asia L
//--------------------------------------------------
float pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
float pdl = request.security(syminfo.tickerid, "D", low[1], lookahead = barmerge.lookahead_on)

bool isInAsia = not na(time(timeframe.period, ASIA_SESSION, SESSION_TZ))

var float asiaH = na
var float asiaL = na
var float finalAsiaH = na
var float finalAsiaL = na
var int finalAsiaEndBar = na

if isInAsia and not isInAsia[1]
    asiaH := high
    asiaL := low

if isInAsia
    asiaH := math.max(asiaH, high)
    asiaL := math.min(asiaL, low)

if not isInAsia and isInAsia[1]
    finalAsiaH := asiaH
    finalAsiaL := asiaL
    finalAsiaEndBar := bar_index - 1

bool buySideTakenPDH =
     not na(pdh) and high > pdh and close < pdh

bool buySideTakenAsia =
     not na(finalAsiaH) and high > finalAsiaH and close < finalAsiaH

bool sellSideTakenPDL =
     not na(pdl) and low < pdl and close > pdl

bool sellSideTakenAsia =
     not na(finalAsiaL) and low < finalAsiaL and close > finalAsiaL

bool buySideTaken = buySideTakenPDH or buySideTakenAsia
bool sellSideTaken = sellSideTakenPDL or sellSideTakenAsia

var int lastBuySideTakenBar = na
var int lastSellSideTakenBar = na

if newDay
    lastBuySideTakenBar := na
    lastSellSideTakenBar := na

if buySideTaken
    lastBuySideTakenBar := bar_index

if sellSideTaken
    lastSellSideTakenBar := bar_index

bool bearishERLValid = not na(lastBuySideTakenBar) and bar_index - lastBuySideTakenBar <= erlLookbackBars
bool bullishERLValid = not na(lastSellSideTakenBar) and bar_index - lastSellSideTakenBar <= erlLookbackBars

//--------------------------------------------------
// IB Context - 13:20 to 14:20 UK Time
//--------------------------------------------------
bool isInIB = not na(time(timeframe.period, IB_SESSION, SESSION_TZ))

var float ibH = na
var float ibL = na
var float finalIBH = na
var float finalIBL = na
var int finalIBEndBar = na

if isInIB and not isInIB[1]
    ibH := high
    ibL := low

if isInIB
    ibH := math.max(ibH, high)
    ibL := math.min(ibL, low)

if not isInIB and isInIB[1]
    finalIBH := ibH
    finalIBL := ibL
    finalIBEndBar := bar_index - 1

//--------------------------------------------------
// Raw setup detection
//--------------------------------------------------
[rawBullLevel, rawBullType] = f_findBullLevel()
[rawBearLevel, rawBearType] = f_findBearLevel()

bool rawBullValid = not na(rawBullLevel)
bool rawBearValid = not na(rawBearLevel)

//--------------------------------------------------
// Signal / displacement validation
//--------------------------------------------------
bool rawBullContinuation = rawBullType == "CB"
bool rawBearContinuation = rawBearType == "CS"
bool rawBullBounce = rawBullType == "BB"
bool rawBearRejection = rawBearType == "RS"

bool bullContinuationSignal =
     rawBullContinuation and
     bodyLargeEnough and
     bodyCleanEnough and
     (requireStructureBreak ? bullBreaksStructure : true)

bool bearContinuationSignal =
     rawBearContinuation and
     bodyLargeEnough and
     bodyCleanEnough and
     (requireStructureBreak ? bearBreaksStructure : true)

bool bullBounceSignal =
     rawBullBounce and
     bodyLargeEnough and
     bodyCleanEnough and
     (requireStructureBreak ? bullBreaksStructure : true)

bool bearRejectionSignal =
     rawBearRejection and
     bodyLargeEnough and
     bodyCleanEnough and
     (requireStructureBreak ? bearBreaksStructure : true)

bool bullSignalCandle = bullContinuationSignal or bullBounceSignal
bool bearSignalCandle = bearContinuationSignal or bearRejectionSignal

//--------------------------------------------------
// Signal classification
//--------------------------------------------------
bool bullAPlus = bullishERLValid
bool bearAPlus = bearishERLValid

bool bullSetup =
     rawBullValid and
     bullSignalCandle and
     (onlyShowAPlus ? bullAPlus : true)

bool bearSetup =
     rawBearValid and
     bearSignalCandle and
     (onlyShowAPlus ? bearAPlus : true)

//--------------------------------------------------
// Signal labels
//--------------------------------------------------
if showSignalLabels and bullSetup
    string txt = bullAPlus ? "A+ " + rawBullType : rawBullType
    label.new(bar_index, low, txt, style = label.style_label_up, color = bullAPlus ? color.lime : color.new(color.green, 0), textcolor = color.black, size = size.tiny)

if showSignalLabels and bearSetup
    string txt = bearAPlus ? "A+ " + rawBearType : rawBearType
    label.new(bar_index, high, txt, style = label.style_label_down, color = bearAPlus ? color.red : color.new(color.maroon, 0), textcolor = color.white, size = size.tiny)

//--------------------------------------------------
// ERL / IB lines and labels
//--------------------------------------------------
var int dayStartBar = na

if newDay or na(dayStartBar)
    dayStartBar := bar_index

var line pdhLine = na
var line pdlLine = na
var line asiaHLine = na
var line asiaLLine = na
var line ibHLine = na
var line ibLLine = na

if barstate.islast
    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(asiaHLine)
    line.delete(asiaLLine)
    line.delete(ibHLine)
    line.delete(ibLLine)

    if showERLLevels and not na(pdh) and not na(dayStartBar)
        pdhLine := line.new(dayStartBar, pdh, bar_index + 50, pdh, color = prevDayLineColor, width = prevDayLineWidth, style = f_lineStyle(prevDayLineStyleInput))

    if showERLLevels and not na(pdl) and not na(dayStartBar)
        pdlLine := line.new(dayStartBar, pdl, bar_index + 50, pdl, color = prevDayLineColor, width = prevDayLineWidth, style = f_lineStyle(prevDayLineStyleInput))

    if showERLLevels and not na(finalAsiaH) and not na(finalAsiaEndBar)
        asiaHLine := line.new(finalAsiaEndBar, finalAsiaH, bar_index + 50, finalAsiaH, color = asiaLineColor, width = asiaLineWidth, style = f_lineStyle(asiaLineStyleInput))

    if showERLLevels and not na(finalAsiaL) and not na(finalAsiaEndBar)
        asiaLLine := line.new(finalAsiaEndBar, finalAsiaL, bar_index + 50, finalAsiaL, color = asiaLineColor, width = asiaLineWidth, style = f_lineStyle(asiaLineStyleInput))

    if showIBLevels and not na(finalIBH) and not na(finalIBEndBar)
        ibHLine := line.new(finalIBEndBar, finalIBH, bar_index + 50, finalIBH, color = ibLineColor, width = ibLineWidth, style = f_lineStyle(ibLineStyleInput))

    if showIBLevels and not na(finalIBL) and not na(finalIBEndBar)
        ibLLine := line.new(finalIBEndBar, finalIBL, bar_index + 50, finalIBL, color = ibLineColor, width = ibLineWidth, style = f_lineStyle(ibLineStyleInput))

var label pdhLabel = na
var label pdlLabel = na
var label asiaHLabel = na
var label asiaLLabel = na
var label ibHLabel = na
var label ibLLabel = na
var label erlStatusLabel = na

if barstate.islast
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(asiaHLabel)
    label.delete(asiaLLabel)
    label.delete(ibHLabel)
    label.delete(ibLLabel)
    label.delete(erlStatusLabel)

    if showERLLevels and not na(pdh)
        pdhLabel := label.new(bar_index + 3, pdh, "PDH", style = label.style_none, textcolor = prevDayLineColor, size = size.tiny)

    if showERLLevels and not na(pdl)
        pdlLabel := label.new(bar_index + 3, pdl, "PDL", style = label.style_none, textcolor = prevDayLineColor, size = size.tiny)

    if showERLLevels and not na(finalAsiaH)
        asiaHLabel := label.new(bar_index + 3, finalAsiaH, "Asia H", style = label.style_none, textcolor = asiaLineColor, size = size.tiny)

    if showERLLevels and not na(finalAsiaL)
        asiaLLabel := label.new(bar_index + 3, finalAsiaL, "Asia L", style = label.style_none, textcolor = asiaLineColor, size = size.tiny)

    if showIBLevels and not na(finalIBH)
        ibHLabel := label.new(bar_index + 3, finalIBH, "IB H", style = label.style_none, textcolor = ibLineColor, size = size.tiny)

    if showIBLevels and not na(finalIBL)
        ibLLabel := label.new(bar_index + 3, finalIBL, "IB L", style = label.style_none, textcolor = ibLineColor, size = size.tiny)

    if showERLStatusLabel
        string statusText =
             bullishERLValid and bearishERLValid ? "ERL: Both Sides Taken" :
             bullishERLValid ? "ERL: SSL Taken / Bullish Context" :
             bearishERLValid ? "ERL: BSL Taken / Bearish Context" :
             "ERL: No Recent Sweep"

        color statusColour =
             bullishERLValid and bearishERLValid ? color.orange :
             bullishERLValid ? color.lime :
             bearishERLValid ? color.red :
             color.gray

        erlStatusLabel := label.new(bar_index + 3, close, statusText, style = label.style_none, textcolor = statusColour, size = size.tiny)

plotshape(showERLMarkers and buySideTakenPDH, title = "BSL PDH Taken", style = shape.circle, location = location.abovebar, color = color.red, size = size.tiny, text = "BSL PDH")
plotshape(showERLMarkers and buySideTakenAsia, title = "BSL Asia H Taken", style = shape.circle, location = location.abovebar, color = color.red, size = size.tiny, text = "BSL Asia H")
plotshape(showERLMarkers and sellSideTakenPDL, title = "SSL PDL Taken", style = shape.circle, location = location.belowbar, color = color.green, size = size.tiny, text = "SSL PDL")
plotshape(showERLMarkers and sellSideTakenAsia, title = "SSL Asia L Taken", style = shape.circle, location = location.belowbar, color = color.green, size = size.tiny, text = "SSL Asia L")

//--------------------------------------------------
// Bar colours
//--------------------------------------------------
color sigColour =
     bullSetup and colourSignalBars ? color.new(color.green, 65) :
     bearSetup and colourSignalBars ? color.new(color.red, 65) :
     na

barcolor(sigColour)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(bullSetup, title = "Bullish Savvy Signal Bar", message = "Bullish Savvy signal bar formed around a manual level.")
alertcondition(bearSetup, title = "Bearish Savvy Signal Bar", message = "Bearish Savvy signal bar formed around a manual level.")
alertcondition(bullSetup and bullAPlus, title = "A+ Bullish Savvy Signal Bar", message = "A+ Bullish Savvy signal bar formed with ERL context.")
alertcondition(bearSetup and bearAPlus, title = "A+ Bearish Savvy Signal Bar", message = "A+ Bearish Savvy signal bar formed with ERL context.")
````
