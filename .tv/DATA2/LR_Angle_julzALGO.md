<!-- tradingview-pine-id: PUB;e421aa0692174cfdad5a44df4fda640c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# LR Angle | julzALGO

Source: https://www.tradingview.com/script/4o1g9VHh-LR-Angle-julzALGO/

## Description

LR Angle | julzALGO is a trend-angle visualization tool built around Linear Regression slope measurement.

Instead of judging trend strength only by how steep a line appears on the screen, the indicator calculates the slope mathematically, normalizes it with ATR, and converts it into a degree reading.

This provides a standardized way to evaluate trend direction and relative slope strength across different symbols, price levels, and volatility conditions.

The indicator is designed to answer one simple question:

Is the Linear Regression slope rising, falling, or becoming balanced?

Overview

LR Angle measures the angle of a Linear Regression line using market data rather than chart pixels.

The script compares the current Linear Regression value with its value a selected number of bars ago. It calculates the slope per bar, normalizes that slope using ATR, and converts the result into degrees using `math.atan()`.

This creates a digital-protractor-style angle reading:

Positive angle = rising Linear Regression slope
Negative angle = falling Linear Regression slope
Near zero = flatter or more balanced slope

The visual tools are designed to make this measurement easier to interpret directly on the chart.

Main Features

Linear Regression Angle Line

https://www.tradingview.com/x/vn2N8PxI/

The indicator plots a Linear Regression line directly on the main chart.

The line color changes according to the calculated angle:

Green = rising slope
Red = falling slope
Neutral = flat or calculation not yet available

This provides a direct visual representation of the current trend-angle condition.

Default Linear Regression Length: 50

Visual Protractor

https://www.tradingview.com/x/IsBBwH8n/

LR Angle includes an on-chart digital protractor-style display.

The protractor shows:

* Curved degree guide
* Tick marks
* Degree labels
* Directional needle
* Positive-angle orientation when the slope is rising
* Negative-angle orientation when the slope is falling

When the calculated angle is positive, the protractor represents the rising slope.

When the calculated angle is negative, the protractor flips downward to represent the falling slope.

The protractor is a visual representation only. The actual degree value is calculated mathematically from the ATR-normalized Linear Regression slope.

B / S Flip Labels

https://www.tradingview.com/x/8JJlcIQe/

The script can display small B and S labels when the calculated angle state changes.

B : appears when the angle enters a rising condition
S : appears when the angle enters a falling condition

The optional B / S Angle Threshold allows users to require a minimum angle before a new state is recognized.

Example:

Threshold = 0° → any positive or negative state change can trigger
Threshold = 5°→ B requires an angle above +5°, while S requires an angle below −5°

These labels are directional angle-state markers. They are not automatic trade entries and can be combined with market structure, price action, volume analysis, and risk management.

Multi-Length Angle Matrix

https://www.tradingview.com/x/9YmCbGRF/

The Angle Matrix compares multiple Linear Regression angle readings simultaneously.

Default rows:

LR 50
LR 100
LR 150
LR 200

Each row displays:

* Linear Regression length
* Calculated angle
* Direction state
* Strength blocks

Matrix states:

UP = angle is above the Balance Zone
DOWN = angle is below the negative Balance Zone
BALANCE = angle is inside the selected neutral range

The strength blocks fill according to the absolute angle relative to the selected Full Strength Angle

For example, if Full Strength Angle is set to 30°, readings approaching ±30° progressively fill more blocks. At or beyond the configured Full Strength Angle, the meter reaches full strength.

This makes it easier to compare weaker, balanced, and stronger directional slopes at a glance.

How the Angle Is Calculated

The calculation can be represented as:

Angle = atan(((LR − LR[N]) / N) / ATR) × 180 / π

Where:

LR = current Linear Regression value
LR[N] = Linear Regression value N bars ago
N = Slope Lookback
ATR = Average True Range used for normalization
atan = arctangent function
180 / π = conversion from radians to degrees

 Step-by-Step Calculation

1. Calculate the current Linear Regression value.
2. Compare it with the Linear Regression value from N bars ago.
3. Divide the change by N to calculate slope per bar.
4. Divide the slope per bar by ATR to normalize it.
5. Apply `atan()` to the normalized slope.
6. Convert the result from radians into degrees.

Why ATR Normalization Is Used

Raw slope values are difficult to compare across markets.

For example, a 10-point movement in gold, BTC, forex, or a stock does not represent the same relative market movement.

ATR normalization scales the Linear Regression slope relative to the instrument's recent trading range.

This helps make the angle measurement more comparable across:

* Different symbols
* Different price levels
* Different volatility conditions
* Different chart environments

The result should still be interpreted in the context of the selected timeframe and settings.

Important Note About the Angle

The angle displayed by this indicator is **not the physical screen angle** of the plotted Linear Regression line.

Chart zoom, chart height, price scale, and screen dimensions can make any plotted line appear steeper or flatter.

LR Angle does not measure pixels or chart geometry.

Instead, it calculates a mathematical angle from the ATR-normalized Linear Regression slope, so the displayed degree reading is based on market data rather than the visual geometry of the chart.

Settings

Angle Calculation

Linear Regression Length

Controls the main Linear Regression period used for the angle calculation.

Default: 50

Slope Lookback

Controls how many bars back the current Linear Regression value is compared against.

Default: 10

ATR Length

Controls the ATR period used to normalize the slope.

Default: 14

Angle Settings

B / S Angle Threshold

Controls the minimum absolute angle required before a B or S state can trigger.

Default: 0°

Display

Show Linear Regression Line

Shows or hides the main Linear Regression angle line.

Show B / S Flip Labels

Shows or hides the B and S directional flip labels.

Line Width

Adjusts the thickness of the Linear Regression line.

Angle Matrix

Show Angle Matrix

Shows or hides the multi-length Angle Matrix.

Matrix Position

Controls where the matrix appears on the chart.

Matrix Text Size

Adjusts the size of the matrix text.

Matrix LR 1 / 2 / 3 / 4

Controls the four Linear Regression lengths used by the matrix.

Defaults:

* Matrix LR 1: 50
* Matrix LR 2: 100
* Matrix LR 3: 150
* Matrix LR 4: 200

Balance Zone Angle

Defines the ± neutral range where the matrix state is classified as BALANCE.

Default: 5°

Full Strength Angle

Defines the absolute angle required to completely fill the strength meter.

Default: 30°

Strength Blocks

Controls the number of blocks used in the matrix strength meter.

Default: 18

Visual Protractor

Show Visual Protractor

Shows or hides the digital protractor.

Center Bars Back

Controls how far behind the latest bar the center of the protractor is positioned.

Horizontal Radius

Controls the horizontal width of the protractor.

Vertical Radius ATR

Controls the vertical size of the protractor relative to ATR.

Show Tick Marks

Shows or hides the protractor tick marks.

Show Degree Labels

Shows or hides the degree numbers.

Style

Users can customize:

* Rising color
* Falling color
* Protractor color
* Needle color

How to Use

Rising Condition

https://www.tradingview.com/x/5npm6i0M/

When the Linear Regression line is green and the angle is positive, the calculated Linear Regression slope is rising.

If several Angle Matrix rows also display UP, multiple configured Linear Regression lengths are showing positive slopes.

Falling Condition

https://www.tradingview.com/x/HGqK3wkN/

When the Linear Regression line is red and the angle is negative, the calculated Linear Regression slope is falling.

If several Angle Matrix rows also display DOWN, multiple configured Linear Regression lengths are showing negative slopes.

Balanced Conditions

https://www.tradingview.com/x/fDhsDh9t/

When the angle is near zero, the measured slope is flatter.

The Balance Zone Angle determines how much positive or negative angle is classified as BALANCE in the matrix.

For example, with the Balance Zone set to 5°:

+3° = BALANCE
0° = BALANCE
−3° = BALANCE

Balanced readings indicate that the normalized Linear Regression slope is currently within the configured neutral range.

Reading the Matrix

The matrix helps compare shorter- and longer-length Linear Regression slopes.

Example of directional alignment:

LR 50 = UP
LR 100 = UP
LR 150 = UP
LR 200 = UP

This indicates positive slope readings across all four configured Linear Regression lengths.

Example of mixed conditions:

LR 50 = UP
LR 100 = BALANCE
LR 150 = DOWN
LR 200 = DOWN

This indicates disagreement between the shorter- and longer-length slope measurements.

Practical Uses

LR Angle can be used for:

* Trend-direction confirmation
* Relative slope-strength analysis
* Identifying flat or low-slope conditions
* Comparing shorter- and longer-length trend slopes
* Confirming pullback or continuation setups
* Filtering signals from another strategy
* Supporting discretionary market-structure analysis

It can also be combined with other forms of analysis such as price action, market structure, volume, support and resistance, VWAP, or order blocks.

Repainting / Real-Time Behavior

LR Angle does not intentionally reference future bars.

Values on historical bars are calculated from data available to those bars. On the current open candle, however, price, ATR, Linear Regression, angle readings, matrix values, and directional states can change as new price data arrives.

For traders who require confirmed readings, evaluate the indicator after the candle has closed.

Disclaimer

This indicator is intended for technical analysis and educational purposes only. It does not provide financial advice or guarantee future market direction or trading performance.

The B and S labels identify changes in the calculated angle state and should not be interpreted as guaranteed buy or sell signals.

Always use appropriate risk management and confirm trading decisions with your own analysis.

© julzALGO

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("LR Angle | julzALGO", shorttitle="LRA", overlay=true, max_lines_count=300, max_labels_count=500)

// ───── INPUTS ─────
groupCalc = "Angle Calculation"
linRegLength = input.int(50, "Linear Regression Length", minval=1, group=groupCalc, tooltip="Length used to calculate the linear regression line measured by the digital protractor.")
slopeLookback = input.int(10, "Slope Lookback", minval=1, group=groupCalc, tooltip="Compares the current linear regression value against this many bars ago before converting the slope into degrees.")
atrLength = input.int(14, "ATR Length", minval=1, group=groupCalc, tooltip="ATR is used to normalize the slope so the angle behaves consistently across symbols and price levels.")

groupAngle = "Angle Settings"
signalAngleThreshold = input.float(0.0, "B / S Angle Threshold", minval=0.0, step=0.5, group=groupAngle, tooltip="Minimum absolute angle required before B/S flip labels can print. 0 means any positive or negative angle flip can trigger.")

groupDisplay = "Display"
showLine = input.bool(true, "Show Linear Regression Line", group=groupDisplay)
showFlipLabels = input.bool(true, "Show B / S Flip Labels", group=groupDisplay)
lineWidth = input.int(2, "Line Width", minval=1, maxval=5, group=groupDisplay)

groupMatrix = "Angle Matrix"
showAngleMatrix = input.bool(true, "Show Angle Matrix", group=groupMatrix, tooltip="Shows several Linear Regression angle readings in one compact strength matrix.")
matrixPosition = input.string("Bottom Left", "Matrix Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupMatrix)
matrixTextSizeInput = input.string("Small", "Matrix Text Size", options=["Tiny", "Small", "Normal"], group=groupMatrix)
matrixLen1 = input.int(50, "Matrix LR 1", minval=1, group=groupMatrix)
matrixLen2 = input.int(100, "Matrix LR 2", minval=1, group=groupMatrix)
matrixLen3 = input.int(150, "Matrix LR 3", minval=1, group=groupMatrix)
matrixLen4 = input.int(200, "Matrix LR 4", minval=1, group=groupMatrix)
matrixNeutralAngle = input.float(5.0, "Balance Zone Angle", minval=0.0, step=0.5, group=groupMatrix, tooltip="Angles between this positive and negative value are treated as balanced in the matrix.")
matrixFullAngle = input.float(30.0, "Full Strength Angle", minval=1.0, step=0.5, group=groupMatrix, tooltip="Angle that fills the strength blocks completely.")
matrixBlocks = input.int(18, "Strength Blocks", minval=8, maxval=24, group=groupMatrix)

groupVisual = "Visual Protractor"
showVisualProtractor = input.bool(true, "Show Visual Protractor", group=groupVisual)
visualBarsBack = input.int(35, "Center Bars Back", minval=10, maxval=300, group=groupVisual)
visualRadiusBars = input.int(24, "Horizontal Radius", minval=8, maxval=120, group=groupVisual)
visualRadiusAtr = input.float(5.0, "Vertical Radius ATR", minval=0.5, step=0.25, group=groupVisual)
showVisualTicks = input.bool(true, "Show Tick Marks", group=groupVisual)
showVisualDegreeLabels = input.bool(true, "Show Degree Labels", group=groupVisual)

groupStyle = "Style"
risingColor = input.color(color.rgb(0, 190, 95), "Rising Color", group=groupStyle)
fallingColor = input.color(color.rgb(235, 45, 55), "Falling Color", group=groupStyle)
protractorColor = input.color(color.rgb(0, 1, 3, 41), "Protractor Color", group=groupStyle)
needleColor = input.color(color.rgb(255, 220, 25), "Needle Color", group=groupStyle)

// ───── LINEAR REGRESSION ENGINE ─────
float linRegValue = ta.linreg(close, linRegLength, 0)
float linRegPast = linRegValue[slopeLookback]
float atrValue = ta.atr(atrLength)

float linRegChange = linRegValue - linRegPast
float slopePerBar = linRegChange / slopeLookback
float normalizedSlope = atrValue > 0 and not na(linRegPast) ? slopePerBar / atrValue : na
float angleDeg = not na(normalizedSlope) ? math.atan(normalizedSlope) * 180.0 / math.pi : na

float matrixLr1 = ta.linreg(close, matrixLen1, 0)
float matrixLrPast1 = matrixLr1[slopeLookback]
float matrixSlope1 = (matrixLr1 - matrixLrPast1) / slopeLookback
float matrixNorm1 = atrValue > 0 and not na(matrixLrPast1) ? matrixSlope1 / atrValue : na
float matrixAngle1 = not na(matrixNorm1) ? math.atan(matrixNorm1) * 180.0 / math.pi : na

float matrixLr2 = ta.linreg(close, matrixLen2, 0)
float matrixLrPast2 = matrixLr2[slopeLookback]
float matrixSlope2 = (matrixLr2 - matrixLrPast2) / slopeLookback
float matrixNorm2 = atrValue > 0 and not na(matrixLrPast2) ? matrixSlope2 / atrValue : na
float matrixAngle2 = not na(matrixNorm2) ? math.atan(matrixNorm2) * 180.0 / math.pi : na

float matrixLr3 = ta.linreg(close, matrixLen3, 0)
float matrixLrPast3 = matrixLr3[slopeLookback]
float matrixSlope3 = (matrixLr3 - matrixLrPast3) / slopeLookback
float matrixNorm3 = atrValue > 0 and not na(matrixLrPast3) ? matrixSlope3 / atrValue : na
float matrixAngle3 = not na(matrixNorm3) ? math.atan(matrixNorm3) * 180.0 / math.pi : na

float matrixLr4 = ta.linreg(close, matrixLen4, 0)
float matrixLrPast4 = matrixLr4[slopeLookback]
float matrixSlope4 = (matrixLr4 - matrixLrPast4) / slopeLookback
float matrixNorm4 = atrValue > 0 and not na(matrixLrPast4) ? matrixSlope4 / atrValue : na
float matrixAngle4 = not na(matrixNorm4) ? math.atan(matrixNorm4) * 180.0 / math.pi : na

bool ready = not na(angleDeg)
bool isRising = ready and angleDeg > 0
bool isFalling = ready and angleDeg < 0

color stateColor =
     not ready ? color.rgb(120, 120, 120) :
     isRising ? risingColor :
     isFalling ? fallingColor :
     color.rgb(120, 120, 120)

string displayName = "LINREG " + str.tostring(linRegLength)

int signalAngleState =
     ready and angleDeg > signalAngleThreshold ? 1 :
     ready and angleDeg < -signalAngleThreshold ? -1 :
     0

bool bullFlip = showFlipLabels and signalAngleState == 1 and nz(signalAngleState[1]) != 1
bool bearFlip = showFlipLabels and signalAngleState == -1 and nz(signalAngleState[1]) != -1

// ───── LINE PLOT ─────
plot(showLine ? linRegValue : na, title="Linear Regression Angle Source", color=stateColor, linewidth=lineWidth)

if bullFlip
    label.new(
         bar_index,
         low,
         "B",
         style=label.style_label_up,
         textcolor=color.white,
         color=color.rgb(0, 150, 40),
         size=size.tiny
    )

if bearFlip
    label.new(
         bar_index,
         high,
         "S",
         style=label.style_label_down,
         textcolor=color.white,
         color=color.rgb(220, 0, 0),
         size=size.tiny
    )

// ───── VISUAL PROTRACTOR ─────
var line[] visualLines = array.new_line()
var label[] visualLabels = array.new_label()

clearVisual() =>
    if array.size(visualLines) > 0
        for i = 0 to array.size(visualLines) - 1
            line.delete(array.get(visualLines, i))
    if array.size(visualLabels) > 0
        for i = 0 to array.size(visualLabels) - 1
            label.delete(array.get(visualLabels, i))
    array.clear(visualLines)
    array.clear(visualLabels)
    0

addVisualLine(int x1, float y1, int x2, float y2, color lineColor, int widthInput, styleInput) =>
    line visualLine = line.new(
         x1, y1,
         x2, y2,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=lineColor,
         width=widthInput,
         style=styleInput
    )
    array.push(visualLines, visualLine)
    0

addVisualLabel(int x, float y, string txt, color txtColor, txtSizeInput) =>
    label visualLabel = label.new(
         x, y, txt,
         xloc=xloc.bar_index,
         style=label.style_none,
         textcolor=txtColor,
         color=color.new(color.black, 100),
         size=txtSizeInput
    )
    array.push(visualLabels, visualLabel)
    0

addVisualBoxLabel(int x, float y, string txt, color bgColor, color txtColor, txtSizeInput) =>
    label visualLabel = label.new(
         x, y, txt,
         xloc=xloc.bar_index,
         style=label.style_label_center,
         textcolor=txtColor,
         color=bgColor,
         size=txtSizeInput
    )
    array.push(visualLabels, visualLabel)
    0

if barstate.islast
    clearVisual()

    if showVisualProtractor and ready
        float piValue = math.pi
        int radiusBars = visualRadiusBars
        int centerBack = math.max(visualBarsBack, radiusBars + 2)
        int centerX = bar_index - centerBack
        float centerY = linRegValue
        float radiusY = math.max(atrValue * visualRadiusAtr, syminfo.mintick)
        float curveDirection = angleDeg < 0 ? -1.0 : 1.0
        color gaugeCol = color.new(protractorColor, 15)
        color tickCol = color.new(protractorColor, 0)
        color faintCol = color.new(protractorColor, 55)
        color liveCol = stateColor

        addVisualLine(centerX, centerY, centerX + radiusBars, centerY, faintCol, 2, line.style_solid)

        int arcSteps = 36
        for i = 0 to arcSteps - 1
            float deg1 = (90.0 / arcSteps) * i
            float deg2 = (90.0 / arcSteps) * (i + 1)
            float rad1 = deg1 * piValue / 180.0
            float rad2 = deg2 * piValue / 180.0
            int x1 = centerX + int(math.round(math.cos(rad1) * radiusBars))
            int x2 = centerX + int(math.round(math.cos(rad2) * radiusBars))
            float y1 = centerY + math.sin(rad1) * radiusY * curveDirection
            float y2 = centerY + math.sin(rad2) * radiusY * curveDirection
            int x1Inner = centerX + int(math.round(math.cos(rad1) * radiusBars * 0.72))
            int x2Inner = centerX + int(math.round(math.cos(rad2) * radiusBars * 0.72))
            float y1Inner = centerY + math.sin(rad1) * radiusY * 0.72 * curveDirection
            float y2Inner = centerY + math.sin(rad2) * radiusY * 0.72 * curveDirection
            addVisualLine(x1, y1, x2, y2, gaugeCol, 2, line.style_solid)
            addVisualLine(x1Inner, y1Inner, x2Inner, y2Inner, color.new(protractorColor, 35), 1, line.style_solid)

        if showVisualTicks
            for tick = 0 to 90 by 5
                float rad = tick * piValue / 180.0
                bool majorTick = tick % 10 == 0
                bool largeTick = tick % 30 == 0
                float innerScale = largeTick ? 0.78 : majorTick ? 0.84 : 0.91
                int xOuter = centerX + int(math.round(math.cos(rad) * radiusBars))
                int xInner = centerX + int(math.round(math.cos(rad) * radiusBars * innerScale))
                float yOuter = centerY + math.sin(rad) * radiusY * curveDirection
                float yInner = centerY + math.sin(rad) * radiusY * innerScale * curveDirection
                addVisualLine(xInner, yInner, xOuter, yOuter, tickCol, largeTick ? 2 : 1, line.style_solid)

                if showVisualDegreeLabels and majorTick
                    int xLabel = centerX + int(math.round(math.cos(rad) * radiusBars * 0.61))
                    float yLabel = centerY + math.sin(rad) * radiusY * 0.61 * curveDirection
                    int protractorNumber = angleDeg < 0 ? -tick : tick
                    addVisualLabel(xLabel, yLabel, str.tostring(protractorNumber), tickCol, size.tiny)

        float visualAngle = math.min(math.abs(angleDeg), 90.0)
        float needleRad = visualAngle * piValue / 180.0
        int needleX = centerX + int(math.round(math.cos(needleRad) * radiusBars))
        float needleY = centerY + math.sin(needleRad) * radiusY * curveDirection
        addVisualLine(centerX, centerY, needleX, needleY, needleColor, 1, line.style_arrow_right)
        addVisualBoxLabel(centerX, centerY, "⊙", color.new(color.black, 100), tickCol, size.small)
        addVisualLabel(centerX, centerY + curveDirection * (radiusY + atrValue * 0.35), displayName, needleColor, size.small)

// ───── MULTI-LENGTH ANGLE MATRIX ─────
matrixPos =
     matrixPosition == "Top Left" ? position.top_left :
     matrixPosition == "Top Right" ? position.top_right :
     matrixPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

matrixTxtSize =
     matrixTextSizeInput == "Tiny" ? size.tiny :
     matrixTextSizeInput == "Normal" ? size.normal :
     size.small

var table angleMatrix = table.new(matrixPos, 3 + matrixBlocks, 4, frame_color=color.new(color.white, 85), frame_width=1, border_color=color.new(color.black, 65), border_width=1)

formatMatrixAngle(float matrixAngle) =>
    string matrixSign = not na(matrixAngle) and matrixAngle > 0 ? "+" : ""
    not na(matrixAngle) ? matrixSign + str.tostring(matrixAngle, "#") + "°" : "..."

matrixStateText(float matrixAngle) =>
    not na(matrixAngle) ? math.abs(matrixAngle) <= matrixNeutralAngle ? "BALANCE" : matrixAngle > 0 ? "UP" : "DOWN" : "WAIT"

matrixStateColor(float matrixAngle) =>
    not na(matrixAngle) ? math.abs(matrixAngle) <= matrixNeutralAngle ? color.rgb(238, 186, 68) : matrixAngle > 0 ? risingColor : fallingColor : color.rgb(120, 120, 120)

drawMatrixRow(int row, int lengthValue, float matrixAngle) =>
    bool rowReady = not na(matrixAngle)
    float strength = rowReady ? math.min(math.abs(matrixAngle) / matrixFullAngle, 1.0) : 0.0
    int filledBlocks = int(math.round(strength * matrixBlocks))
    color rowColor = matrixStateColor(matrixAngle)
    color matrixBg = color.new(color.rgb(44, 47, 61), 5)
    color emptyBg = color.new(color.rgb(80, 84, 96), 35)
    color textCol = color.white
    table.cell(angleMatrix, 0, row, "LR " + str.tostring(lengthValue), text_color=textCol, bgcolor=matrixBg, text_size=matrixTxtSize, text_halign=text.align_left)
    table.cell(angleMatrix, 1, row, formatMatrixAngle(matrixAngle), text_color=rowColor, bgcolor=matrixBg, text_size=matrixTxtSize, text_halign=text.align_center)
    table.cell(angleMatrix, 2, row, matrixStateText(matrixAngle), text_color=rowColor, bgcolor=matrixBg, text_size=matrixTxtSize, text_halign=text.align_left)
    for block = 0 to matrixBlocks - 1
        bool blockOn = block < filledBlocks
        table.cell(angleMatrix, block + 3, row, " ", text_color=color.new(color.white, 100), bgcolor=blockOn ? rowColor : emptyBg, text_size=size.tiny)
    0

if barstate.islast
    if showAngleMatrix
        drawMatrixRow(0, matrixLen1, matrixAngle1)
        drawMatrixRow(1, matrixLen2, matrixAngle2)
        drawMatrixRow(2, matrixLen3, matrixAngle3)
        drawMatrixRow(3, matrixLen4, matrixAngle4)
    else
        table.clear(angleMatrix, 0, 0, matrixBlocks + 2, 3)
````
