# Change in State of Delivery [CISD] (Zeiierman)

- url: https://www.tradingview.com/script/1SytPYEb-Change-in-State-of-Delivery-CISD-Zeiierman/
- type: indicator
- pine_id: PUB;7fbb57313ca845dcb6fc5a42f8a307d2
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Change in State of Delivery [CISD] (Zeiierman)[/b] identifies genuine changes in buying and selling pressure by monitoring consecutive delivery candles and tracking when price closes beyond the opening price of the previous delivery phase.

Rather than relying solely on traditional market structure concepts such as Break of Structure (BoS) or Market Structure Shift (MSS), the indicator focuses on delivery itself, the sequence of aggressive buying or selling that drives price.

When price successfully closes beyond the opening price of the previous delivery leg, a Change in State of Delivery (CISD) is confirmed, highlighting a potential shift in market control.
[image]https://www.tradingview.com/x/f0ZiMnkX/[/image]
⚪ [b]True Delivery Engine[/b]

The indicator continuously tracks bullish and bearish delivery sequences. A delivery begins whenever consecutive candles close in the same direction.

[b]Once a minimum number of delivery candles has formed, the indicator records:[/b]
• The opening price of the first delivery candle.
• The starting bar of the delivery sequence.
• The active delivery level.

Unlike many CISD implementations, this indicator is built around the actual delivery sequence instead of simply using arbitrary candle opens.
[image]https://www.tradingview.com/x/4NMqvVk8/[/image]
⚪ [b]CISD Confirmation[/b]

A Change in State of Delivery is confirmed when price closes beyond the opening price of the previous delivery sequence.

[b]Bullish CISD[/b]
• Bearish delivery completes.
• Price closes above the opening price of that bearish delivery.

[b]Bearish CISD[/b]
• Bullish delivery completes.
• Price closes below the opening price of that bullish delivery.
[image]https://www.tradingview.com/x/dKfEM6Sn/[/image]

⚪ [b]Liquidity Sweep Detection[/b]

The indicator can optionally display liquidity sweeps around confirmed swing highs and swing lows.

[b]A bearish liquidity sweep occurs when:[/b]
• Price trades above a previous swing high.
• Price closes back below the swing high.

[b]A bullish liquidity sweep occurs when:[/b]
• Price trades below a previous swing low.
• Price closes back above the swing low.
[image]https://www.tradingview.com/x/1xw89qTj/[/image]
⚪ [b]Market Structure Shift (MSS)[/b]

For additional confirmation, the indicator can display simple Market Structure Shift events. 

[b]Bullish MSS[/b]
• Price closes above the most recent confirmed swing high.

[b]Bearish MSS[/b]
• Price closes below the most recent confirmed swing low.
[image]https://www.tradingview.com/x/Zdrq1avY/[/image]
█ [b]How It Works[/b]

⚪ [b]Delivery Detection[/b]

The script continuously counts consecutive bullish and bearish candles.

Once the minimum delivery requirement is reached, the opening price of the delivery sequence becomes the active CISD level.

This level represents the point where the current buying or selling pressure originally began.
[pine]if bull
    bullSeq := bull[1] ? bullSeq + 1 : 1
    if bullSeq == 1
        bullDeliveryOpen := open

if bear
    bearSeq := bear[1] ? bearSeq + 1 : 1
    if bearSeq == 1
        bearDeliveryOpen := open[/pine]
⚪ [b]CISD Validation[/b]

[b]The delivery level remains active until one of two events occurs:[/b]
• Price confirms the CISD by closing beyond the delivery open.
• The setup expires after the maximum user-defined validity period.

Confirmed CISDs remain visible, while expired setups are automatically removed.

⚪ [b]Dynamic Trend State[/b]

Each confirmed CISD updates the internal trend state.

[b]This trend can optionally be used to:[/b]
• Color candles.
• Visually distinguish bullish and bearish market conditions.
• Generate trend shift alerts.

Repeated confirmations in the same direction are displayed using dashed CISD levels, making ongoing directional control easier to recognize.

█ [b]How to Use[/b]

⚪ [b]Identify Delivery Shifts[/b]

The primary purpose of the indicator is to detect when one side of the market successfully overcomes the previous delivery phase.

[b]A bullish CISD[/b] shows that buyers have reclaimed control after a bearish delivery sequence. [b]A bearish CISD[/b] shows that sellers have reclaimed control after a bullish delivery sequence.

Instead of reacting to every structural break, traders can use confirmed CISD levels to focus on cleaner shifts in market pressure.
[image]https://www.tradingview.com/x/XvdT5VZt/[/image]

⚪ [b]Solid vs Dashed CISD Levels[/b]

Not all confirmed CISD levels are displayed the same way.

[b]Solid CISD lines[/b] represent a new change in delivery, where market control shifts from buyers to sellers or from sellers to buyers. These are often the most significant signals, as they indicate a potential trend reversal or the beginning of a new directional move.

[b]Dashed CISD lines[/b] occur when another CISD confirms in the same direction as the current trend. Instead of signaling a reversal, they indicate that the existing trend continues to regain control after a pullback.

[b]In practice:[/b]

[b]• Solid CISD →[/b] Potential change in directional control.
[image]https://www.tradingview.com/x/84akBCLi/[/image]
[b]• Dashed CISD →[/b] Trend continuation after a correction or retracement.
[image]https://www.tradingview.com/x/WBaCkmAy/[/image]
This visual distinction helps traders quickly identify whether a CISD represents a fresh shift in market control or simply reinforces the current trend.

█ [b]Settings[/b]
[list]
[*][b]Show CISD:[/b] Displays active and confirmed CISD levels.
[*][b]Minimum Delivery Candles:[/b] Minimum number of consecutive candles required before a delivery sequence becomes valid.
[*][b]Maximum CISD Validity:[/b] Maximum number of bars a setup can remain active before expiring.
[*][b]Minimum CISD Duration:[/b] Minimum number of bars before a CISD is allowed to confirm.
[*][b]Show Liquidity Sweeps:[/b] Displays bullish and bearish liquidity sweep levels.
[*][b]Sweep Swing Length:[/b] Controls the swing detection used for identifying liquidity sweeps.
[*][b]Show MSS Dots:[/b] Displays Market Structure Shift confirmations.
[*][b]MSS Length: [/b]Controls the pivot length used for structure detection.
[*][b]Color Candles by CISD Trend:[/b] Colors candles using the latest confirmed CISD direction.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Change in State of Delivery [CISD] (Zeiierman)", overlay=true, max_lines_count=500, max_labels_count=500, behind_chart = false)
//}

// ~~ Tooltips {
var string t1  = "Minimum number of consecutive delivery candles required before a CISD setup can form."
var string t2  = "Maximum number of bars a CISD setup can stay active before it expires."
var string t3  = "Minimum number of bars required between the delivery start and CISD confirmation."
var string t4  = "Pivot length used to detect MSS break levels."
var string t5  = "Show confirmed and active CISD lines."
var string t6  = "Show MSS dots on the chart."
var string t7  = "Size used for the CISD label text."
var string t8  = "Size used for the confirmation arrow text."
var string t9  = "Bullish CISD color."
var string t10 = "Bearish CISD color."
var string t11 = "MSS dot color."
var string t12 = "Line width used for CISD levels."
var string t13 = "Color candles based on the latest confirmed CISD trend."
var string t14 = "Candle color used after bullish CISD confirmation."
var string t15 = "Candle color used after bearish CISD confirmation."
var string t16 = "Show liquidity sweep lines when price sweeps a confirmed swing high or swing low and closes back inside."
var string t17 = "Swing length used to detect liquidity sweep highs and lows."
var string t18 = "Color used for bearish sweep lines above swing highs."
var string t19 = "Color used for bullish sweep lines below swing lows."
var string t20 = "Line width used for the horizontal sweep level."
var string t21 = "Line width used for the sweep wick marker."
var string t22 = "Show a live label on the current active pending CISD level."
var string t23 = "Number of bars to offset the pending CISD label into the future."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
showCISD    = input.bool(true, "Show CISD", tooltip=t5, group="True CISD")
minDelivery = input.int(3, "Minimum Delivery Candles", minval=1, tooltip=t1, active=showCISD, group="True CISD")
maxSeq      = input.int(100, "Maximum CISD Validity", minval=10, maxval=1000, tooltip=t2, active=showCISD, group="True CISD")
minSeq      = input.int(1, "Minimum CISD Duration", minval=0, tooltip=t3, active=showCISD, group="True CISD")

labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="True CISD", tooltip=t7, active=showCISD, inline="s")
arrowSizeInput = input.string("Normal", "Arrow Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="True CISD", tooltip=t8, active=showCISD, inline="s")

cBull     = input.color(#089981, "", group="True CISD", tooltip=t9, active=showCISD, inline="c")
cBear     = input.color(#f23645, "", group="True CISD", tooltip=t10, active=showCISD, inline="c")
cisdWidth = input.int(2, "", minval=1, maxval=5, group="True CISD", tooltip=t12, active=showCISD, inline="c")

showPendingLabel = input.bool(true, "Show Pending CISD Label", group="True CISD", tooltip=t22, active=showCISD)
pendingOffset    = input.int(2, "Pending Label Offset", minval=0, maxval=50, group="True CISD", tooltip=t23, active=showPendingLabel)

showMSS     = input.bool(false, "Show MSS Dots", tooltip=t6, inline="showMSS", group="MSS")
mssLen      = input.int(3, "", minval=1, tooltip=t4, inline="showMSS", active=showMSS, group="MSS")
cMSS        = input.color(#787b86, "", tooltip=t11, active=showMSS, group="MSS", inline="showMSS")

showSweeps     = input.bool(true, "Show Liquidity Sweeps", group="Liquidity Sweeps", tooltip=t16)
swingLen       = input.int(10, "Sweep Swing Length", minval=1, group="Liquidity Sweeps", tooltip=t17, active=showSweeps)
cSweepH        = input.color(#787b8684, "Sweep High", group="Liquidity Sweeps", tooltip=t18, active=showSweeps)
cSweepL        = input.color(#787b8684, "Sweep Low", group="Liquidity Sweeps", tooltip=t19, active=showSweeps)
sweepWidth     = input.int(1, "Sweep Level Width", minval=1, maxval=5, group="Liquidity Sweeps", tooltip=t20, active=showSweeps)
sweepWickWidth = input.int(10, "Sweep Wick Width", minval=1, maxval=20, group="Liquidity Sweeps", tooltip=t21, active=showSweeps)

colorCandles = input.bool(false, "Color Candles by CISD Trend", group="Candle Coloring", tooltip=t13, active=showCISD)
bullCandle   = input.color(color.new(#089981, 0), "", group="Candle Coloring", tooltip=t14, active=showCISD, inline="c")
bearCandle   = input.color(color.new(#f23645, 0), "", group="Candle Coloring", tooltip=t15, active=showCISD, inline="c")

INV = color(na)
n   = bar_index

labelSize = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge
arrowSize = arrowSizeInput == "Tiny" ? size.tiny : arrowSizeInput == "Small" ? size.small : arrowSizeInput == "Normal" ? size.normal : arrowSizeInput == "Large" ? size.large : size.huge
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Types {
type cisdSetup
    line ln
    label pendingLbl
    float level
    int x1
    bool active
    int direction
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Variables {
var cisdSetup bullSetup = cisdSetup.new(na, na, na, na, false, 1)
var cisdSetup bearSetup = cisdSetup.new(na, na, na, na, false, -1)

var int trend = 0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Functions {
newCisdLine(int x1, float y, color col, int width) =>
    line.new(x1, y, bar_index, y, color=color.new(col, 40), width=width)

updateLine(line ln, int width) =>
    line.set_x2(ln, bar_index)
    line.set_width(ln, width)

confirmLine(line ln, color col, int width, bool dashed) =>
    line.set_color(ln, col)
    line.set_width(ln, width)
    if dashed
        line.set_style(ln, line.style_dashed)

drawCisdLabels(int x1, int x2, float level, bool isBull, color col, string lblSize, string arrSize) =>
    int mid = math.ceil(math.avg(x1, x2))
    label.new(mid, level, "CISD", style=isBull ? label.style_label_down : label.style_label_up, textcolor=col, color=INV, size=lblSize)
    label.new(x2, isBull ? low : high, isBull ? "▲" : "▼", style=isBull ? label.style_label_up : label.style_label_down, textcolor=col, color=INV, size=arrSize)

drawSweep(int x1, float level, int x2, float wickLevel, color col, int levelWidth, int wickWidth) =>
    line.new(x1, level, x2, level, color=col, width=levelWidth)
    line.new(x2, level, x2, wickLevel, color=col, width=wickWidth)

deleteSetupLine(cisdSetup setup) =>
    if setup.active and not na(setup.ln)
        line.delete(setup.ln)

deletePendingLabel(label lbl) =>
    if not na(lbl)
        label.delete(lbl)

newPendingLabel(float level, color col) =>
    label.new(bar_index + pendingOffset, level, "Pending CISD", style=label.style_label_left, textcolor=color.new(col, 40), color=INV, size=labelSize)

updatePendingLabel(label lbl, float level, color col) =>
    label.set_x(lbl, bar_index + pendingOffset)
    label.set_y(lbl, level)
    label.set_textcolor(lbl, color.new(col, 40))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Candle Delivery Engine {
bull = close > open
bear = close < open

var int bullSeq = 0
var int bearSeq = 0

var float bullDeliveryOpen = na
var float bearDeliveryOpen = na

var int bullDeliveryStart = na
var int bearDeliveryStart = na

if bull
    if not bull[1]
        bullDeliveryOpen := open
        bullDeliveryStart := n
        bullSeq := 1
    else
        bullSeq += 1
    bearSeq := 0

if bear
    if not bear[1]
        bearDeliveryOpen := open
        bearDeliveryStart := n
        bearSeq := 1
    else
        bearSeq += 1
    bullSeq := 0

if not bull and not bear
    bullSeq := 0
    bearSeq := 0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Liquidity Sweeps {
ph = ta.pivothigh(high, swingLen, 1)
pl = ta.pivotlow(low, swingLen, 1)

var float swingHigh = na
var float swingLow = na
var int swingHighBar = na
var int swingLowBar = na

if not na(ph)
    swingHigh := ph
    swingHighBar := n - 1

if not na(pl)
    swingLow := pl
    swingLowBar := n - 1

bearSweep = not na(swingHigh) and high > swingHigh and close < swingHigh
bullSweep = not na(swingLow) and low < swingLow and close > swingLow

if showSweeps and bearSweep
    drawSweep(swingHighBar, swingHigh, n, high, cSweepH, sweepWidth, sweepWickWidth)

if showSweeps and bullSweep
    drawSweep(swingLowBar, swingLow, n, low, cSweepL, sweepWidth, sweepWickWidth)

if not na(swingHigh) and close > swingHigh
    swingHigh := na
    swingHighBar := na

if not na(swingLow) and close < swingLow
    swingLow := na
    swingLowBar := na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ MSS {
mssHigh = ta.pivothigh(high, mssLen, mssLen)
mssLow  = ta.pivotlow(low, mssLen, mssLen)

var float lastMssHigh = na
var float lastMssLow = na

if not na(mssHigh)
    lastMssHigh := mssHigh

if not na(mssLow)
    lastMssLow := mssLow

bullMSS = not na(lastMssHigh) and close > lastMssHigh and close[1] <= lastMssHigh
bearMSS = not na(lastMssLow) and close < lastMssLow and close[1] >= lastMssLow

plotshape(showMSS and bullMSS, title="Bullish MSS", style=shape.circle, location=location.belowbar, color=cMSS, size=size.tiny)
plotshape(showMSS and bearMSS, title="Bearish MSS", style=shape.circle, location=location.abovebar, color=cMSS, size=size.tiny)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ CISD Setup Conditions {
newBullSetup = bearSeq >= minDelivery
newBearSetup = bullSeq >= minDelivery

if showCISD and newBullSetup
    deleteSetupLine(bullSetup)
    deletePendingLabel(bullSetup.pendingLbl)

    bullSetup.level := bearDeliveryOpen
    bullSetup.x1 := bearDeliveryStart
    bullSetup.ln := newCisdLine(bullSetup.x1, bullSetup.level, cBull, cisdWidth)
    bullSetup.pendingLbl := showPendingLabel ? newPendingLabel(bullSetup.level, cBull) : na
    bullSetup.active := true
    bullSetup.direction := 1

if showCISD and newBearSetup
    deleteSetupLine(bearSetup)
    deletePendingLabel(bearSetup.pendingLbl)

    bearSetup.level := bullDeliveryOpen
    bearSetup.x1 := bullDeliveryStart
    bearSetup.ln := newCisdLine(bearSetup.x1, bearSetup.level, cBear, cisdWidth)
    bearSetup.pendingLbl := showPendingLabel ? newPendingLabel(bearSetup.level, cBear) : na
    bearSetup.active := true
    bearSetup.direction := -1
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Confirm CISD {
bullConfirm = bullSetup.active and close > bullSetup.level and n - bullSetup.x1 >= minSeq
bearConfirm = bearSetup.active and close < bearSetup.level and n - bearSetup.x1 >= minSeq

bullExpired = bullSetup.active and n - bullSetup.x1 > maxSeq
bearExpired = bearSetup.active and n - bearSetup.x1 > maxSeq

if bullSetup.active
    if n - bullSetup.x1 <= maxSeq
        updateLine(bullSetup.ln, cisdWidth)

        if showPendingLabel and not na(bullSetup.pendingLbl)
            updatePendingLabel(bullSetup.pendingLbl, bullSetup.level, cBull)

        if bullConfirm
            confirmLine(bullSetup.ln, cBull, cisdWidth, trend == 1)
            drawCisdLabels(bullSetup.x1, n, bullSetup.level, true, cBull, labelSize, arrowSize)
            deletePendingLabel(bullSetup.pendingLbl)
            bullSetup.pendingLbl := na

            trend := 1
            bullSetup.active := false
    else
        line.delete(bullSetup.ln)
        deletePendingLabel(bullSetup.pendingLbl)
        bullSetup.pendingLbl := na
        bullSetup.active := false

if bearSetup.active
    if n - bearSetup.x1 <= maxSeq
        updateLine(bearSetup.ln, cisdWidth)

        if showPendingLabel and not na(bearSetup.pendingLbl)
            updatePendingLabel(bearSetup.pendingLbl, bearSetup.level, cBear)

        if bearConfirm
            confirmLine(bearSetup.ln, cBear, cisdWidth, trend == -1)
            drawCisdLabels(bearSetup.x1, n, bearSetup.level, false, cBear, labelSize, arrowSize)
            deletePendingLabel(bearSetup.pendingLbl)
            bearSetup.pendingLbl := na

            trend := -1
            bearSetup.active := false
    else
        line.delete(bearSetup.ln)
        deletePendingLabel(bearSetup.pendingLbl)
        bearSetup.pendingLbl := na
        bearSetup.active := false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Candle Coloring {
barColor = colorCandles ? trend == 1 ? bullCandle : trend == -1 ? bearCandle : na : na
barcolor(barColor)
plotcandle(open, high, low, close, color=barColor, wickcolor=barColor, bordercolor=barColor, title="Candle color")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(newBullSetup, "New Bullish CISD Setup", "New bullish CISD setup formed")
alertcondition(newBearSetup, "New Bearish CISD Setup", "New bearish CISD setup formed")

alertcondition(bullConfirm, "Bullish CISD Confirmed", "Bullish CISD confirmed")
alertcondition(bearConfirm, "Bearish CISD Confirmed", "Bearish CISD confirmed")

alertcondition(bullSweep, "Bullish Liquidity Sweep", "Bullish liquidity sweep detected")
alertcondition(bearSweep, "Bearish Liquidity Sweep", "Bearish liquidity sweep detected")

alertcondition(bullMSS, "Bullish MSS", "Bullish MSS detected")
alertcondition(bearMSS, "Bearish MSS", "Bearish MSS detected")

alertcondition(bullConfirm and trend[1] != 1, "Bullish CISD Trend Shift", "CISD trend shifted bullish")
alertcondition(bearConfirm and trend[1] != -1, "Bearish CISD Trend Shift", "CISD trend shifted bearish")

alertcondition(bullExpired, "Bullish CISD Expired", "Bullish CISD setup expired")
alertcondition(bearExpired, "Bearish CISD Expired", "Bearish CISD setup expired")

alertcondition(colorCandles and trend == 1 and trend[1] != 1, "Candle Color Shift Bullish", "Candle coloring shifted bullish")
alertcondition(colorCandles and trend == -1 and trend[1] != -1, "Candle Color Shift Bearish", "Candle coloring shifted bearish")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
