# SpxSnipper - EMA Zone + FVG Retest Reclaim Signals

- url: https://www.tradingview.com/script/WiJTEDzX-SpxSnipper-EMA-Zone-FVG-Retest-Reclaim-Signals/
- type: indicator
- pine_id: PUB;db355b72829e4b8e87cf051d49096802
- version: 1.0

## Description

This indicator combines an EMA trend zone with Fair Value Gap retest logic.

It is designed to highlight potential continuation setups where price creates a Fair Value Gap, later retests that gap inside the EMA zone, and then confirms the retest by closing beyond the open of the retest candle.

Main components:
• Fast EMA and Slow EMA, default 9 and 21
• Shaded EMA zone between the two moving averages
• Bullish and bearish Fair Value Gap detection
• ATR-based FVG size filter
• Fixed FVG box extension based on a user-selected number of candles
• Retest markers
• Buy and sell signal markers
• Alerts for retests and confirmed signals

Fair Value Gap logic:
For a bullish FVG, the first candle color does not matter, the second candle must be a strong bullish candle, and the third candle color does not matter. The middle candle strength is based on where it closes within its own range.

For a bearish FVG, the opposite logic is used. The middle candle must be a strong bearish candle.

The user can adjust:
• EMA lengths
• FVG validity / box extension in candles
• Minimum and maximum FVG size using ATR multiples
• Middle candle strength threshold
• Visibility of EMAs, EMA zone, FVG boxes, retest markers, and signals

EMA trend alignment:
Bullish setups are only considered when the fast EMA is above the slow EMA.
Bearish setups are only considered when the fast EMA is below the slow EMA.

Retest logic:
A bullish retest occurs when price touches or enters a bullish FVG while the FVG overlaps with the EMA zone, using a bearish candle that does not close below the FVG. A bullish signal is triggered when a later candle closes above the open of the retest candle while the FVG is still active.

A bearish retest uses the opposite logic. Price must touch or enter a bearish FVG while it overlaps with the EMA zone, using a bullish candle that does not close above the FVG. A bearish signal is triggered when a later candle closes below the open of the retest candle while the FVG is still active.

EMA zone colors:
• Blue: EMAs are converging
• Green: EMAs are expanding upward
• Red: EMAs are expanding downward

Suggested use:
This tool is intended for visual analysis of Fair Value Gap retests, EMA-zone reactions, and potential trend-continuation structures. It can be used alongside market structure, volume, support and resistance, session levels, or other forms of confirmation.

Important note:
Signals are based only on the conditions coded in the script. They should not be interpreted as standalone trading recommendations. Users should test and evaluate the logic according to their own methodology and risk management rules.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - EMA Zone + FVG Retest Reclaim Signals", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
src = input.source(close, "Source")

fastEmaLen = input.int(9, "Fast EMA Length", minval=1)
slowEmaLen = input.int(21, "Slow EMA Length", minval=1)

showFastEMA = input.bool(true, "Show Fast EMA")
showSlowEMA = input.bool(true, "Show Slow EMA")
showEmaZone = input.bool(true, "Show EMA Zone")

fvgValidBars = input.int(10, "FVG Validity / Extension in Candles", minval=1, maxval=300)

showFVGBoxes = input.bool(true, "Show FVG Boxes")
showRetestMarkers = input.bool(true, "Show Retest Markers")
showSignals = input.bool(true, "Show Buy/Sell Signals")

maxStoredFVGs = input.int(80, "Maximum Stored FVGs", minval=1, maxval=200)

// Middle candle strength
middleClosePositionInput = input.float(0.75, "FVG Middle Candle Close Position", minval=0.50, maxval=1.00, step=0.05)

// ATR FVG width filter
atrLen = input.int(14, "ATR Length", minval=1)
minFvgAtr = input.float(0.05, "Minimum FVG Size as ATR Multiple", minval=0.00, step=0.01)
maxFvgAtr = input.float(0.00, "Maximum FVG Size as ATR Multiple | 0 = No Max", minval=0.00, step=0.05)

// Colors
fastEmaColor = input.color(color.orange, "Fast EMA Color")
slowEmaColor = input.color(color.white, "Slow EMA Color")

zoneConvergingColor = input.color(color.new(color.blue, 82), "EMA Zone Color: Converging")
zoneBullOpeningColor = input.color(color.new(color.lime, 82), "EMA Zone Color: Opening Up")
zoneBearOpeningColor = input.color(color.new(color.red, 82), "EMA Zone Color: Opening Down")

bullFvgColor = input.color(color.new(color.lime, 85), "Bullish FVG Box Color")
bearFvgColor = input.color(color.new(color.red, 85), "Bearish FVG Box Color")

bullSignalColor = input.color(color.lime, "Buy Signal Color")
bearSignalColor = input.color(color.red, "Sell Signal Color")

confirmedOnly = input.bool(true, "Confirm Signals Only After Bar Close")

// ─────────────────────────────────────────────
// EMA calculations
// ─────────────────────────────────────────────
fastEMA = ta.ema(src, fastEmaLen)
slowEMA = ta.ema(src, slowEmaLen)

emaZoneHigh = math.max(fastEMA, slowEMA)
emaZoneLow  = math.min(fastEMA, slowEMA)

// EMA trend alignment
bullEmaStructure = fastEMA > slowEMA
bearEmaStructure = fastEMA < slowEMA

// EMA zone color logic
emaSpread = math.abs(fastEMA - slowEMA)
emaSpreadExpanding = emaSpread > emaSpread[1]

emaZoneColor =
     not emaSpreadExpanding ? zoneConvergingColor :
     fastEMA > slowEMA ? zoneBullOpeningColor :
     zoneBearOpeningColor

barConfirmedOk = confirmedOnly ? barstate.isconfirmed : true

// ─────────────────────────────────────────────
// Helper functions
// ─────────────────────────────────────────────
f_fvgSizeOk(float fvgSize, float atrValue) =>
    bool minOk = minFvgAtr <= 0.0 or fvgSize >= atrValue * minFvgAtr
    bool maxOk = maxFvgAtr <= 0.0 or fvgSize <= atrValue * maxFvgAtr
    minOk and maxOk

f_boxBg(bool isBull) =>
    showFVGBoxes ? (isBull ? bullFvgColor : bearFvgColor) : color.new(color.black, 100)

f_boxBorder(bool isBull) =>
    showFVGBoxes ? (isBull ? color.new(color.lime, 25) : color.new(color.red, 25)) : color.new(color.black, 100)

// ─────────────────────────────────────────────
// FVG detection
// ─────────────────────────────────────────────
atrValue = ta.atr(atrLen)

middleRange = high[1] - low[1]
middleClosePosition = middleRange > 0 ? (close[1] - low[1]) / middleRange : 0.5

// Bullish FVG:
// 1st candle color does not matter.
// 2nd candle must be strong bullish.
// 3rd candle color does not matter.
bullMiddleStrong = close[1] > open[1] and middleClosePosition >= middleClosePositionInput

// Bearish FVG mirror:
// 1st candle color does not matter.
// 2nd candle must be strong bearish.
// 3rd candle color does not matter.
bearMiddleStrong = close[1] < open[1] and middleClosePosition <= 1.0 - middleClosePositionInput

// Standard 3-candle FVG
bullFvgRaw = not na(high[2]) and low > high[2]
bearFvgRaw = not na(low[2]) and high < low[2]

// Bullish FVG zone = high[2] to low
bullFvgTop = low
bullFvgBottom = high[2]
bullFvgSize = bullFvgTop - bullFvgBottom

// Bearish FVG zone = high to low[2]
bearFvgTop = low[2]
bearFvgBottom = high
bearFvgSize = bearFvgTop - bearFvgBottom

// FVG is valid only when EMA structure agrees with the FVG direction
bullFvgValid = barConfirmedOk and bullEmaStructure and bullFvgRaw and bullMiddleStrong and f_fvgSizeOk(bullFvgSize, atrValue)
bearFvgValid = barConfirmedOk and bearEmaStructure and bearFvgRaw and bearMiddleStrong and f_fvgSizeOk(bearFvgSize, atrValue)

// ─────────────────────────────────────────────
// FVG state arrays
// ─────────────────────────────────────────────
var array<float> fvgTopArr = array.new_float()
var array<float> fvgBottomArr = array.new_float()
var array<bool>  fvgBullArr = array.new_bool()
var array<bool>  fvgActiveArr = array.new_bool()
var array<int>   fvgCreatedBarArr = array.new_int()
var array<int>   fvgExpiryBarArr = array.new_int()

var array<bool>  retestFoundArr = array.new_bool()
var array<float> retestOpenArr = array.new_float()
var array<float> retestHighArr = array.new_float()
var array<float> retestLowArr = array.new_float()
var array<int>   retestBarArr = array.new_int()

var array<box>   fvgBoxArr = array.new_box()

// ─────────────────────────────────────────────
// Add FVG
// ─────────────────────────────────────────────
f_addFvg(float topPrice, float bottomPrice, bool isBull) =>
    while array.size(fvgTopArr) >= maxStoredFVGs
        oldBox = array.shift(fvgBoxArr)
        if not na(oldBox)
            box.delete(oldBox)

        array.shift(fvgTopArr)
        array.shift(fvgBottomArr)
        array.shift(fvgBullArr)
        array.shift(fvgActiveArr)
        array.shift(fvgCreatedBarArr)
        array.shift(fvgExpiryBarArr)

        array.shift(retestFoundArr)
        array.shift(retestOpenArr)
        array.shift(retestHighArr)
        array.shift(retestLowArr)
        array.shift(retestBarArr)

    expiryBar = bar_index + fvgValidBars

    newBox = box.new(
         left=bar_index - 2,
         top=topPrice,
         right=expiryBar,
         bottom=bottomPrice,
         xloc=xloc.bar_index,
         bgcolor=f_boxBg(isBull),
         border_color=f_boxBorder(isBull)
    )

    array.push(fvgTopArr, topPrice)
    array.push(fvgBottomArr, bottomPrice)
    array.push(fvgBullArr, isBull)
    array.push(fvgActiveArr, true)
    array.push(fvgCreatedBarArr, bar_index)
    array.push(fvgExpiryBarArr, expiryBar)

    array.push(retestFoundArr, false)
    array.push(retestOpenArr, na)
    array.push(retestHighArr, na)
    array.push(retestLowArr, na)
    array.push(retestBarArr, na)

    array.push(fvgBoxArr, newBox)

// Add new FVGs
if bullFvgValid
    f_addFvg(bullFvgTop, bullFvgBottom, true)

if bearFvgValid
    f_addFvg(bearFvgTop, bearFvgBottom, false)

// ─────────────────────────────────────────────
// Retest and signal logic
// ─────────────────────────────────────────────
buySignal = false
sellSignal = false

bullRetestEvent = false
bearRetestEvent = false

if array.size(fvgTopArr) > 0
    for i = 0 to array.size(fvgTopArr) - 1
        fvgTop = array.get(fvgTopArr, i)
        fvgBottom = array.get(fvgBottomArr, i)
        isBull = array.get(fvgBullArr, i)
        isActive = array.get(fvgActiveArr, i)
        createdBar = array.get(fvgCreatedBarArr, i)
        expiryBar = array.get(fvgExpiryBarArr, i)
        fvgBox = array.get(fvgBoxArr, i)

        // Fixed box extension:
        // Το FVG εμφανίζεται μέχρι το expiryBar, όχι επ' αόριστον.
        if not na(fvgBox)
            box.set_right(fvgBox, expiryBar)
            box.set_bgcolor(fvgBox, f_boxBg(isBull))
            box.set_border_color(fvgBox, f_boxBorder(isBull))

        if isActive
            stillWithinValidBars = bar_index <= expiryBar

            if not stillWithinValidBars
                array.set(fvgActiveArr, i, false)

            else
                // Το retest πρέπει να γίνεται στο σημείο όπου FVG και EMA zone συμπίπτουν.
                overlapLow = math.max(fvgBottom, emaZoneLow)
                overlapHigh = math.min(fvgTop, emaZoneHigh)
                fvgOverlapsEmaZone = overlapLow <= overlapHigh

                candleTouchesFvgEmaOverlap = fvgOverlapsEmaZone and low <= overlapHigh and high >= overlapLow

                // ─────────────
                // Bullish FVG setup
                // ─────────────
                if isBull
                    // Αν κλείσει κάτω από το bullish FVG, το setup ακυρώνεται για signal.
                    // Το box όμως παραμένει ορατό μέχρι το expiryBar.
                    bullInvalid = bar_index > createdBar and close < fvgBottom

                    if bullInvalid
                        array.set(fvgActiveArr, i, false)

                    else
                        // Bullish retest:
                        // - EMA 9 > EMA 21
                        // - κόκκινο κερί
                        // - ακουμπάει / μπαίνει στο FVG μέσα στην EMA zone
                        // - δεν κλείνει κάτω από το FVG
                        bullRetestCandle = close < open

                        bullValidRetest =
                             barConfirmedOk and
                             bar_index > createdBar and
                             bullEmaStructure and
                             candleTouchesFvgEmaOverlap and
                             bullRetestCandle and
                             close >= fvgBottom

                        retestFound = array.get(retestFoundArr, i)
                        oldRetestLow = array.get(retestLowArr, i)
                        oldRetestOpen = array.get(retestOpenArr, i)
                        oldRetestBar = array.get(retestBarArr, i)

                        deeperBullRetest = not retestFound or (not na(oldRetestLow) and low < oldRetestLow)

                        // First valid retest ή πιο βαθύ valid retest.
                        if bullValidRetest and deeperBullRetest
                            array.set(retestFoundArr, i, true)
                            array.set(retestOpenArr, i, open)
                            array.set(retestHighArr, i, high)
                            array.set(retestLowArr, i, low)
                            array.set(retestBarArr, i, bar_index)
                            bullRetestEvent := true

                        // BUY signal:
                        // Επόμενο ή μεταγενέστερο candle, όσο το FVG είναι ενεργό,
                        // κλείνει πάνω από το open του retest candle.
                        else if retestFound and bar_index > oldRetestBar and barConfirmedOk and bullEmaStructure and close > oldRetestOpen
                            buySignal := true
                            array.set(fvgActiveArr, i, false)

                // ─────────────
                // Bearish FVG setup
                // ─────────────
                else
                    // Αν κλείσει πάνω από το bearish FVG, το setup ακυρώνεται για signal.
                    // Το box όμως παραμένει ορατό μέχρι το expiryBar.
                    bearInvalid = bar_index > createdBar and close > fvgTop

                    if bearInvalid
                        array.set(fvgActiveArr, i, false)

                    else
                        // Bearish retest:
                        // - EMA 9 < EMA 21
                        // - πράσινο κερί
                        // - ακουμπάει / μπαίνει στο FVG μέσα στην EMA zone
                        // - δεν κλείνει πάνω από το FVG
                        bearRetestCandle = close > open

                        bearValidRetest =
                             barConfirmedOk and
                             bar_index > createdBar and
                             bearEmaStructure and
                             candleTouchesFvgEmaOverlap and
                             bearRetestCandle and
                             close <= fvgTop

                        retestFound = array.get(retestFoundArr, i)
                        oldRetestHigh = array.get(retestHighArr, i)
                        oldRetestOpen = array.get(retestOpenArr, i)
                        oldRetestBar = array.get(retestBarArr, i)

                        deeperBearRetest = not retestFound or (not na(oldRetestHigh) and high > oldRetestHigh)

                        // First valid retest ή πιο βαθύ valid retest.
                        if bearValidRetest and deeperBearRetest
                            array.set(retestFoundArr, i, true)
                            array.set(retestOpenArr, i, open)
                            array.set(retestHighArr, i, high)
                            array.set(retestLowArr, i, low)
                            array.set(retestBarArr, i, bar_index)
                            bearRetestEvent := true

                        // SELL signal:
                        // Επόμενο ή μεταγενέστερο candle, όσο το FVG είναι ενεργό,
                        // κλείνει κάτω από το open του retest candle.
                        else if retestFound and bar_index > oldRetestBar and barConfirmedOk and bearEmaStructure and close < oldRetestOpen
                            sellSignal := true
                            array.set(fvgActiveArr, i, false)

// ─────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────
pFast = plot(showFastEMA ? fastEMA : na, "Fast EMA", color=fastEmaColor, linewidth=2)
pSlow = plot(showSlowEMA ? slowEMA : na, "Slow EMA", color=slowEmaColor, linewidth=2)

fill(pFast, pSlow, color=showEmaZone ? emaZoneColor : na, title="EMA Zone")

plotshape(
     showRetestMarkers and bullRetestEvent,
     title="Bullish FVG Retest",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     size=size.tiny,
     text="RT"
)

plotshape(
     showRetestMarkers and bearRetestEvent,
     title="Bearish FVG Retest",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.tiny,
     text="RT"
)

plotshape(
     showSignals and buySignal,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullSignalColor,
     size=size.small,
     text="BUY"
)

plotshape(
     showSignals and sellSignal,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearSignalColor,
     size=size.small,
     text="SELL"
)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(buySignal, title="Buy Signal", message="Bullish EMA Zone + FVG retest open reclaim signal detected")
alertcondition(sellSignal, title="Sell Signal", message="Bearish EMA Zone + FVG retest open rejection signal detected")
alertcondition(bullRetestEvent, title="Bullish Retest Detected", message="Bullish FVG retest candle detected inside EMA zone")
alertcondition(bearRetestEvent, title="Bearish Retest Detected", message="Bearish FVG retest candle detected inside EMA zone")
````
