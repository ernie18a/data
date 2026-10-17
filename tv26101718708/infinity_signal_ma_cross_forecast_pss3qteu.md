# Infinity Signal MA Cross Forecast

- url: https://www.tradingview.com/script/pSs3QteU-Infinity-Signal-MA-Cross-Forecast/
- type: indicator
- pine_id: PUB;efd22a676793475a8ff53dad517d43ec
- version: 1.0

## Description

Infinity Signal MA Cross Forecast is an advanced moving average forecasting and signal confirmation tool built around the relationship between a moving average and its previous value, MA versus MA[1].

The indicator combines real-time MA cross detection, confirmation signals, forward projection modeling, projected crossover forecasting, and adaptive projection inversion into a single chart overlay.

Core Features

• Adjustable Moving Average Length

• MA and MA[1] Cross Detection

• Raw Buy and Sell Cross Markers

• Buy and Sell Confirmation Signals

• Forward Projection Engine

• Potential Buy and Potential Sell Forecast Balloons

• Projected Cross Vertical Markers

• Auto-Flip Projection Technology

• Manual Projection Flip Option

• Ghost Projection Comparison Mode

• Alignment Status Table

• Projection Direction Reporting

• Customizable Colors and Signal Sizes

• TradingView Alert Support

How the Projection Works

The projection engine clones a historical MA pattern and shifts it forward into the future. The projected MA and projected MA[1] are then analyzed for future crossover opportunities.

Potential Buy and Potential Sell balloons appear at projected crossover locations, allowing traders to visualize possible future signal timing before a cross occurs.

Auto-Flip Projection

One of the unique features of this script is Auto-Flip Projection.

When the projected historical pattern disagrees with the current MA direction, the indicator can automatically invert the projection to better align with current market behavior.

Users may also manually flip the projection and compare the flipped version against the original projection using Ghost Projection mode.

Recommended Projection Settings

The projection engine is designed around a one-hundred-twenty-two-day market cycle.

For best results, use the following Pattern Start Bars Back settings:

Timeframe	Pattern Start Bars Back
1 Hour	2,928
2 Hour	1,464
4 Hour	732
6 Hour	488
8 Hour	366
12 Hour	244
1 Day	122

Pattern End Bars Back is typically set approximately twenty bars less than Pattern Start Bars Back, although users are encouraged to experiment with alternative settings.

Notes

This script is designed as a forecasting and market structure visualization tool. Projected signals are estimates derived from historical MA behavior and should not be interpreted as guarantees of future market direction.

Always perform your own analysis and risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator(
     "Infinity Signal MA Cross Forecast",
     overlay=true,
     scale=scale.right,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=5000
)

//====================================================
// MA INPUTS
//====================================================
maLen = input.int(4, "MA Length", minval=1)
src   = input.source(close, "Source")

showMALines = input.bool(true, "Show MA / MA[1] Lines")
maColor     = input.color(color.rgb(29, 5, 205), "MA Color")
maPrevColor = input.color(color.white, "MA[1] Color")
maWidth     = input.int(2, "MA Line Width", minval=1, maxval=5)

//====================================================
// RAW DOTS + CONFIRM SIGNALS
//====================================================
showRawDots      = input.bool(true, "Show Raw Buy/Sell Dots")
showConfirmSigns = input.bool(true, "Show BUY/SELL Confirm Labels")

buyDotColor  = input.color(color.lime, "Buy Dot Color")
sellDotColor = input.color(color.red, "Sell Dot Color")

buyConfirmColor  = input.color(color.rgb(2, 90, 5), "BUY Confirm Label Color")
sellConfirmColor = input.color(color.red, "SELL Confirm Label Color")
confirmTextColor = input.color(color.white, "Confirm Text Color")

confirmSizeInput = input.string("Small", "Confirm Label Size", options=["Tiny","Small","Normal","Large","Huge"])
confirmSize = confirmSizeInput == "Tiny" ? size.tiny :
     confirmSizeInput == "Normal" ? size.normal :
     confirmSizeInput == "Large" ? size.large :
     confirmSizeInput == "Huge" ? size.huge :
     size.small

//====================================================
// PROJECTION INPUTS
//====================================================
startBarsBack = input.int(220, "Pattern Start Bars Back", minval=1)
endBarsBack   = input.int(180, "Pattern End Bars Back", minval=1)
shiftForward  = input.int(50, "Shift Pattern Forward", minval=0)

useDeltaAnchor = input.bool(true, "Delta-anchor Projection")
showProj       = input.bool(true, "Show Projection")

projNowColor  = input.color(color.aqua, "Projected MA Color")
projPrevColor = input.color(color.orange, "Projected MA[1] Color")

//====================================================
// FLIP CONTROLS
//====================================================
autoFlipProjection   = input.bool(false, "Auto Flip Projection When Direction Disagrees")
manualFlipProjection = input.bool(false, "Manual Flip Projection")
showNormalGhost      = input.bool(true, "Show Normal Projection Ghost When Flipped")
flipSensitivity      = input.int(3, "Auto Flip Direction Lookback", minval=1, maxval=20)

flipNowColor  = input.color(color.white, "Flipped Projected MA Color")
flipPrevColor = input.color(color.gray, "Flipped Projected MA[1] Color")
ghostNowColor = input.color(color.new(color.aqua, 80), "Normal Ghost MA Color")
ghostPrevColor = input.color(color.new(color.orange, 80), "Normal Ghost MA[1] Color")

//====================================================
// PROJECTED CROSS LINES
//====================================================
showProjCrossVLines = input.bool(true, "Show Projected Cross Lines")
vlineBullColor      = input.color(color.lime, "Potential Buy Line Color")
vlineBearColor      = input.color(color.red, "Potential Sell Line Color")
vlineWidth          = input.int(2, "Projected Cross Line Width", minval=1, maxval=4)
vlineStyleInput     = input.string("Dotted", "Projected Cross Line Style", options=["Solid","Dotted","Dashed"])

sd4ForHeight         = input.float(2.618, "Line Height Band Mult", step=0.001, minval=0.0)
vlineHeightMult      = input.float(1.0, "Line Height Mult", minval=0.1, step=0.1)
vlineAtrFallbackMult = input.float(0.8, "Fallback ATR Height Mult", minval=0.1, step=0.1)

//====================================================
// POTENTIAL BUY / SELL BALLOONS
//====================================================
showPotentialLabels = input.bool(true, "Show Potential Buy/Sell Balloons")
potentialBuyText    = input.string("Potential Buy", "Potential Buy Text")
potentialSellText   = input.string("Potential Sell", "Potential Sell Text")

potentialBuyColor   = input.color(color.lime, "Potential Buy Balloon Color")
potentialSellColor  = input.color(color.red, "Potential Sell Balloon Color")
potentialTextColor  = input.color(color.white, "Potential Balloon Text Color")

potentialLabelSizeInput = input.string("Normal", "Potential Balloon Size", options=["Tiny","Small","Normal","Large","Huge"])
potentialLabelOffset    = input.float(0.0, "Potential Balloon Vertical Offset", step=0.01)

potentialSize = potentialLabelSizeInput == "Tiny" ? size.tiny :
     potentialLabelSizeInput == "Small" ? size.small :
     potentialLabelSizeInput == "Large" ? size.large :
     potentialLabelSizeInput == "Huge" ? size.huge :
     size.normal

//====================================================
// ALERTS
//====================================================
enableAlerts = input.bool(true, "Enable Alerts")
useWicks     = input.bool(true, "Use Wicks")
alertBand3   = input.bool(true, "Alert Band 3")
alertBand4   = input.bool(true, "Alert Band 4")

sd3AlertMult = input.float(1.618, "Alert Band 3 Mult", step=0.001, minval=0.0)
sd4AlertMult = input.float(2.618, "Alert Band 4 Mult", step=0.001, minval=0.0)

//====================================================
// TABLE SETTINGS
//====================================================
showTable      = input.bool(true, "Show MA Cross Table")
tableBlue      = input.color(color.rgb(35, 95, 245), "Header Blue")
tableBlueShade = input.int(0, "Header Opacity", minval=0, maxval=100)
tableBlack     = input.color(color.black, "Row Black")
tableBlackSoft = input.color(color.new(color.black, 70), "Soft Black")
tableBuyBg     = input.color(color.rgb(0, 180, 80), "BUY Cell")
tableSellBg    = input.color(color.rgb(255, 50, 50), "SELL Cell")

//====================================================
// CORE MA
//====================================================
maNow  = ta.sma(src, maLen)
maPrev = maNow[1]

plot(showMALines ? maNow : na, "MA", color=maColor, linewidth=maWidth)
plot(showMALines ? maPrev : na, "MA[1]", color=maPrevColor, linewidth=maWidth)

// Scale anchor for merge
plot(close, "Scale Anchor", display=display.none)

//====================================================
// CROSS LOGIC
//====================================================
bullCrossRaw = ta.crossover(maNow, maPrev)
bearCrossRaw = ta.crossunder(maNow, maPrev)

bullConfirm = bullCrossRaw[1]
bearConfirm = bearCrossRaw[1]

// Raw dots on actual cross bar
if showRawDots and bullCrossRaw
    label.new(
         bar_index,
         maNow,
         "x",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_circle,
         size=size.tiny,
         color=buyDotColor,
         textcolor=color.white
    )

if showRawDots and bearCrossRaw
    label.new(
         bar_index,
         maNow,
         "x",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_circle,
         size=size.tiny,
         color=sellDotColor,
         textcolor=color.white
    )

// Confirm labels on candle after cross
if showConfirmSigns and bullConfirm
    label.new(
         bar_index,
         low,
         "▲ BUY (confirm)",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=buyConfirmColor,
         textcolor=confirmTextColor,
         size=confirmSize
    )

if showConfirmSigns and bearConfirm
    label.new(
         bar_index,
         high,
         "▼ SELL (confirm)",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_down,
         color=sellConfirmColor,
         textcolor=confirmTextColor,
         size=confirmSize
    )

//====================================================
// STYLE
//====================================================
vStyle = vlineStyleInput == "Dotted" ? line.style_dotted :
     vlineStyleInput == "Dashed" ? line.style_dashed :
     line.style_solid

//====================================================
// STORAGE
//====================================================
var float[] patNow = array.new_float()
var float[] projNormal = array.new_float()
var float[] projActive = array.new_float()

var line[] projLinesNow = array.new_line()
var line[] projLinesPrev = array.new_line()
var line[] ghostLinesNow = array.new_line()
var line[] ghostLinesPrev = array.new_line()
var line[] projCrossVLines = array.new_line()
var label[] potentialLabels = array.new_label()

maxHorizon = 500
var float[] fcU3 = array.new_float()
var float[] fcL3 = array.new_float()
var float[] fcU4 = array.new_float()
var float[] fcL4 = array.new_float()

if barstate.isfirst
    for _ = 0 to maxHorizon
        array.push(fcU3, na)
        array.push(fcL3, na)
        array.push(fcU4, na)
        array.push(fcL4, na)

//====================================================
// BUILD PATTERN
//====================================================
startIdx = math.max(startBarsBack, endBarsBack)
endIdx   = math.min(startBarsBack, endBarsBack)
count    = math.max(2, startIdx - endIdx + 1)

array.clear(patNow)

for i = 0 to count - 1
    array.push(patNow, maNow[startIdx - i])

//====================================================
// STDEV
//====================================================
float stdev = na

if showProj and count >= 2
    float sumErr = 0.0

    for j = 0 to count - 1
        idx = startIdx - j
        sumErr += close[idx] - maNow[idx]

    float meanErr = sumErr / count
    float variance = 0.0

    for j = 0 to count - 1
        idx = startIdx - j
        float e = close[idx] - maNow[idx] - meanErr
        variance += e * e

    variance := variance / count
    stdev := math.sqrt(math.max(0.0, variance))

//====================================================
// BUILD NORMAL PROJECTION
//====================================================
array.clear(projNormal)
array.clear(projActive)

if showProj and array.size(patNow) >= 2
    base = array.get(patNow, 0)

    for i = 0 to array.size(patNow) - 1
        val = array.get(patNow, i)
        normalVal = useDeltaAnchor ? maNow + (val - base) : val
        array.push(projNormal, normalVal)

//====================================================
// FLIP DECISION
//====================================================
float liveDirSmoothed = ta.sma(maNow - maNow[1], flipSensitivity)
int liveDirection = liveDirSmoothed > 0 ? 1 : liveDirSmoothed < 0 ? -1 : 0

int projectedDirection = 0

if array.size(projNormal) > flipSensitivity
    float projNowTest = array.get(projNormal, 0)
    float projLaterTest = array.get(projNormal, flipSensitivity)
    projectedDirection := projLaterTest > projNowTest ? 1 : projLaterTest < projNowTest ? -1 : 0

bool shouldAutoFlip = autoFlipProjection and liveDirection != 0 and projectedDirection != 0 and liveDirection != projectedDirection
bool shouldFlipProjection = manualFlipProjection or shouldAutoFlip

//====================================================
// BUILD ACTIVE PROJECTION
//====================================================
if showProj and array.size(projNormal) >= 2
    for i = 0 to array.size(projNormal) - 1
        normalVal = array.get(projNormal, i)
        flippedVal = maNow - (normalVal - maNow)
        array.push(projActive, shouldFlipProjection ? flippedVal : normalVal)

//====================================================
// SHIFT ALERT CACHE
//====================================================
array.shift(fcU3), array.push(fcU3, na)
array.shift(fcL3), array.push(fcL3, na)
array.shift(fcU4), array.push(fcU4, na)
array.shift(fcL4), array.push(fcL4, na)

//====================================================
// CLEANUP DYNAMIC PROJECTION OBJECTS
//====================================================
while array.size(projLinesNow) > 0
    line.delete(array.pop(projLinesNow))

while array.size(projLinesPrev) > 0
    line.delete(array.pop(projLinesPrev))

while array.size(ghostLinesNow) > 0
    line.delete(array.pop(ghostLinesNow))

while array.size(ghostLinesPrev) > 0
    line.delete(array.pop(ghostLinesPrev))

while array.size(projCrossVLines) > 0
    line.delete(array.pop(projCrossVLines))

while array.size(potentialLabels) > 0
    label.delete(array.pop(potentialLabels))

//====================================================
// DRAW PROJECTION
//====================================================
atr14 = ta.atr(14)

band4WidthNow = not na(stdev) ? stdev * sd4ForHeight : na
hV = not na(band4WidthNow) ? band4WidthNow * vlineHeightMult : atr14 * vlineAtrFallbackMult

if showProj and array.size(projActive) >= 2
    for i = 0 to array.size(projActive) - 2
        int x1 = bar_index + shiftForward + i
        int x2 = x1 + 1

        float yNow1 = array.get(projActive, i)
        float yNow2 = array.get(projActive, i + 1)

        float yPrev1 = i == 0 ? maPrev : array.get(projActive, i - 1)
        float yPrev2 = array.get(projActive, i)

        if shouldFlipProjection and showNormalGhost
            float gNow1 = array.get(projNormal, i)
            float gNow2 = array.get(projNormal, i + 1)
            float gPrev1 = i == 0 ? maPrev : array.get(projNormal, i - 1)
            float gPrev2 = array.get(projNormal, i)

            array.push(ghostLinesNow, line.new(x1, gNow1, x2, gNow2, xloc=xloc.bar_index, color=ghostNowColor, width=1))
            array.push(ghostLinesPrev, line.new(x1, gPrev1, x2, gPrev2, xloc=xloc.bar_index, color=ghostPrevColor, width=1))

        activeNowColor = shouldFlipProjection ? flipNowColor : projNowColor
        activePrevColor = shouldFlipProjection ? flipPrevColor : projPrevColor

        array.push(projLinesNow, line.new(
             x1, yNow1,
             x2, yNow2,
             xloc=xloc.bar_index,
             color=color.new(activeNowColor, 35),
             width=2
        ))

        array.push(projLinesPrev, line.new(
             x1, yPrev1,
             x2, yPrev2,
             xloc=xloc.bar_index,
             color=color.new(activePrevColor, 35),
             width=2
        ))

        off = shiftForward + i

        if off >= 0 and off < array.size(fcU3) and not na(stdev)
            w3 = stdev * sd3AlertMult
            w4 = stdev * sd4AlertMult
            array.set(fcU3, off, yNow1 + w3)
            array.set(fcL3, off, yNow1 - w3)
            array.set(fcU4, off, yNow1 + w4)
            array.set(fcL4, off, yNow1 - w4)

        if showProjCrossVLines
            bool crossedUp = yNow1 < yPrev1 and yNow2 > yPrev2
            bool crossedDown = yNow1 > yPrev1 and yNow2 < yPrev2

            if crossedUp or crossedDown
                denom = (yNow2 - yNow1) - (yPrev2 - yPrev1)
                t = denom == 0.0 ? 0.5 : -(yNow1 - yPrev1) / denom
                t := math.max(0.0, math.min(1.0, t))

                yCross = yNow1 + (yNow2 - yNow1) * t
                vcol = crossedUp ? vlineBullColor : vlineBearColor

                vln = line.new(
                     x2,
                     yCross - hV,
                     x2,
                     yCross + hV,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     color=vcol,
                     style=vStyle,
                     width=vlineWidth
                )

                array.push(projCrossVLines, vln)

                if showPotentialLabels
                    lblText = crossedUp ? potentialBuyText : potentialSellText
                    lblColor = crossedUp ? potentialBuyColor : potentialSellColor
                    lblStyle = crossedUp ? label.style_label_up : label.style_label_down

                    lbl = label.new(
                         x2,
                         yCross + potentialLabelOffset,
                         lblText,
                         xloc=xloc.bar_index,
                         yloc=yloc.price,
                         style=lblStyle,
                         color=lblColor,
                         textcolor=potentialTextColor,
                         size=potentialSize
                    )

                    array.push(potentialLabels, lbl)

//====================================================
// ALERTS
//====================================================
float pxHi = useWicks ? high : close
float pxLo = useWicks ? low : close

u3 = array.get(fcU3, 0)
l3 = array.get(fcL3, 0)
u4 = array.get(fcU4, 0)
l4 = array.get(fcL4, 0)

band3Breach = enableAlerts and alertBand3 and not na(u3) and not na(l3) and (pxHi > u3 or pxLo < l3)
band4Breach = enableAlerts and alertBand4 and not na(u4) and not na(l4) and (pxHi > u4 or pxLo < l4)

alertcondition(bullCrossRaw, "Raw BUY Cross", "MA crossed above MA[1].")
alertcondition(bearCrossRaw, "Raw SELL Cross", "MA crossed below MA[1].")
alertcondition(bullConfirm, "BUY Confirm", "BUY confirm printed one candle after MA crossed above MA[1].")
alertcondition(bearConfirm, "SELL Confirm", "SELL confirm printed one candle after MA crossed below MA[1].")
alertcondition(band3Breach, "Band 3 Breach", "Price outside projected Band 3 envelope.")
alertcondition(band4Breach, "Band 4 Breach", "Price outside projected Band 4 envelope.")

//====================================================
// TABLE
//====================================================
var string lastSignal = "No cross yet"

if bullCrossRaw
    lastSignal := "BUY (MA crossed ABOVE MA[1])"
else if bearCrossRaw
    lastSignal := "SELL (MA crossed BELOW MA[1])"

alignText = maNow > maPrev ? "Bullish" : maNow < maPrev ? "Bearish" : "Neutral"

var table maTable = table.new(position.top_right, 3, 5, border_width=1)

if barstate.islast and showTable
    blueBg = color.new(tableBlue, tableBlueShade)

    table.cell(maTable, 0, 0, "Item", bgcolor=blueBg, text_color=color.white)
    table.cell(maTable, 1, 0, "Value", bgcolor=blueBg, text_color=color.white)
    table.cell(maTable, 2, 0, "Status", bgcolor=blueBg, text_color=color.white)

    table.cell(maTable, 0, 1, "MA", bgcolor=tableBlack, text_color=color.white)
    table.cell(maTable, 1, 1, str.tostring(maNow, format.mintick), bgcolor=tableBlack, text_color=color.white)
    table.cell(maTable, 2, 1, maNow > maPrev ? "Above" : "Below", bgcolor=tableBlack, text_color=color.white)

    table.cell(maTable, 0, 2, "MA[1]", bgcolor=tableBlack, text_color=color.white)
    table.cell(maTable, 1, 2, str.tostring(maPrev, format.mintick), bgcolor=tableBlack, text_color=color.white)
    table.cell(maTable, 2, 2, maPrev < maNow ? "Below" : "Above", bgcolor=tableBlack, text_color=color.white)

    sigBg = str.startswith(lastSignal, "BUY") ? tableBuyBg :
         str.startswith(lastSignal, "SELL") ? tableSellBg :
         color.new(color.gray, 80)

    flipStatus = shouldFlipProjection ? shouldAutoFlip ? "AUTO FLIPPED" : "MANUAL FLIP" : "Normal"

    table.cell(maTable, 0, 3, "Alignment", bgcolor=blueBg, text_color=color.white)
    table.cell(maTable, 1, 3, alignText, bgcolor=tableBlackSoft, text_color=color.white)
    table.cell(maTable, 2, 3, lastSignal, bgcolor=sigBg, text_color=color.white)

    table.cell(maTable, 0, 4, "Projection", bgcolor=blueBg, text_color=color.white)
    table.cell(maTable, 1, 4, flipStatus, bgcolor=tableBlackSoft, text_color=color.white)
    table.cell(maTable, 2, 4, projectedDirection == 1 ? "Up" : projectedDirection == -1 ? "Down" : "Flat", bgcolor=tableBlackSoft, text_color=color.white)
````
