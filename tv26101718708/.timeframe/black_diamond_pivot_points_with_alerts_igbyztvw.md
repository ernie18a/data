# Black Diamond - Pivot Points with alerts

- url: https://www.tradingview.com/script/igbyztvW-Black-Diamond-Pivot-Points-with-alerts/
- type: indicator
- pine_id: PUB;23fcb78453cf4687aa3f7ecf1b7b401b
- version: 1.0

## Description

# Carl's Pivot Points - Left & Right Extension With Alerts V6

## OVERVIEW

Carl's Pivot Points V6 is a clean and professional pivot point indicator designed to help traders quickly identify key support and resistance levels based on previous market data.

The indicator automatically calculates and displays:

• Pivot Point (PP)
• Resistance 1 (R1)
• Resistance 2 (R2)
• Resistance 3 (R3)
• Support 1 (S1)
• Support 2 (S2)
• Support 3 (S3)

In addition to displaying the levels, the indicator provides customizable alerts and a visual market bias background based on price location relative to the Pivot Point.

The goal of this indicator is simplicity. Rather than filling your chart with unnecessary signals and complex calculations, Carl's Pivot Points focuses on providing traders with important institutional levels that can be used across all markets and timeframes.

---

## FEATURES

✓ Daily, Weekly or Monthly Pivot Source Selection

✓ Clean Support and Resistance Levels

✓ Adjustable Left and Right Line Extensions

✓ Individual Alert Options for Each Pivot Level

✓ Cross, Cross Up and Cross Down Alert Modes

✓ Visual Bullish and Bearish Background Bias

✓ Fully Customisable Colours

✓ Lightweight and Fast

✓ Suitable for Beginners and Experienced Traders

---

## HOW PIVOT POINTS WORK

Pivot Points are calculated using the previous period's:

• High
• Low
• Close

These values are used to create potential support and resistance levels for the current trading session.

Institutional traders, day traders and swing traders have used Pivot Points for decades as areas where price may:

• Reverse
• Stall
• Consolidate
• Break Out

Because many traders monitor these levels, they often become self-fulfilling areas of market interest.

---

## HOW TO USE THE INDICATOR

### Pivot Point (PP)

The Pivot Point is the most important level on the chart.

Price Above Pivot:
• Bullish Bias
• Buyers currently have control
• Look for buying opportunities

Price Below Pivot:
• Bearish Bias
• Sellers currently have control
• Look for selling opportunities

---

### Support Levels

S1:
First potential support level.

S2:
Stronger support level if S1 fails.

S3:
Extreme support level often associated with oversold conditions.

Possible Uses:
• Trade reversals
• Profit targets
• Stop loss placement
• Areas to watch for bullish reactions

---

### Resistance Levels

R1:
First potential resistance level.

R2:
Stronger resistance level if R1 breaks.

R3:
Extreme resistance level often associated with overbought conditions.

Possible Uses:
• Trade reversals
• Profit targets
• Stop loss placement
• Areas to watch for bearish reactions

---

## BACKGROUND BIAS

The optional background colouring provides an instant visual bias.

Green Background:
Price is trading above the Pivot Point.

Red Background:
Price is trading below the Pivot Point.

This feature helps traders quickly identify market direction without additional indicators.

---

## ALERT SYSTEM

The indicator includes fully customisable alerts.

You can choose alerts for:

• Pivot
• R1
• S1
• R2
• S2
• R3
• S3

Alert Modes:

Cross
Triggers when price crosses a level in either direction.

Cross Up
Triggers only when price moves upward through a level.

Cross Down
Triggers only when price moves downward through a level.

These alerts are ideal for traders who do not wish to constantly monitor charts.

---

## BEST WAYS TO USE THIS INDICATOR

### Trend Trading

Use the Pivot Point as your directional filter.

Above Pivot:
Focus on long opportunities.

Below Pivot:
Focus on short opportunities.

---

### Scalping

Watch for reactions around:

• Pivot
• S1
• R1

These levels often provide excellent short-term trading opportunities.

---

### Swing Trading

Use:

• S2
• S3
• R2
• R3

to identify larger reversal and profit-taking zones.

---

### Confluence Trading

For best results combine Pivot Levels with:

• Market Structure
• Support & Resistance
• Order Blocks
• Fair Value Gaps
• Liquidity Zones
• Trend Analysis

The strongest setups typically occur when multiple forms of analysis align at the same price level.

---

## SETTINGS GUIDE

Pivot Source Timeframe
Select Daily, Weekly or Monthly Pivot calculations.

Show Pivot
Show or hide the main Pivot Point.

Show R1/S1
Show or hide first support and resistance levels.

Show R2/S2
Show or hide second support and resistance levels.

Show R3/S3
Show or hide third support and resistance levels.

Line Width
Adjust line thickness.

Left Extension Bars
Controls how far levels extend to the left.

Right Extension Bars
Controls how far levels extend to the right.

Show Background Bias
Enable or disable bullish/bearish background colouring.

Alert Settings
Choose which levels trigger alerts.

Alert Trigger Type
Choose Cross, Cross Up or Cross Down.

---

## TRADING TIP

Do not treat Pivot Levels as automatic buy or sell signals.

Instead, think of them as areas of interest where price may react.

Always wait for confirmation from price action before entering a trade.

Patience and discipline will often outperform simply reacting to every level.

---

## DISCLAIMER

This indicator is provided for educational and informational purposes only.

Nothing contained within this indicator, its description, settings or alerts should be considered financial advice, investment advice or a recommendation to buy or sell any financial instrument.

Trading Forex, Commodities, Indices, Stocks and Cryptocurrencies carries a high level of risk and may not be suitable for all investors.

Past performance does not guarantee future results.

Users are solely responsible for their own trading decisions, risk management and financial outcomes.

Always conduct your own analysis and consult a qualified financial professional if required before making investment decisions.

Use this indicator entirely at your own risk.

## Source Code

````pine
//@version=6
indicator("Black Diamond - Pivot Points with alerts", overlay=true, max_lines_count=100, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
pivotTF = input.timeframe("D", "Pivot Source Timeframe")

showPivot = input.bool(true, "Show Pivot")
showR1S1  = input.bool(true, "Show R1 / S1")
showR2S2  = input.bool(true, "Show R2 / S2")
showR3S3  = input.bool(true, "Show R3 / S3")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

pivotColour = input.color(color.yellow, "Pivot Colour")
resColour   = input.color(color.red, "Resistance Colour")
supColour   = input.color(color.lime, "Support Colour")
textColour  = input.color(color.white, "Text Colour")

showBackgroundBias = input.bool(true, "Show Background Bias")

leftExtendBars  = input.int(40, "Left Extension Bars", minval=1, maxval=500)
rightExtendBars = input.int(8, "Right Extension Bars", minval=1, maxval=100)

//━━━━━━━━━━━━━━━━━━━
// ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━
alertPivot = input.bool(true, "Alert On Pivot")
alertR1    = input.bool(true, "Alert On R1")
alertS1    = input.bool(true, "Alert On S1")
alertR2    = input.bool(false, "Alert On R2")
alertS2    = input.bool(false, "Alert On S2")
alertR3    = input.bool(false, "Alert On R3")
alertS3    = input.bool(false, "Alert On S3")

alertMode = input.string("Cross", "Alert Trigger Type", options=["Cross", "Cross Up", "Cross Down"])

//━━━━━━━━━━━━━━━━━━━
// PIVOT CALCULATIONS
//━━━━━━━━━━━━━━━━━━━
prevHigh  = request.security(syminfo.tickerid, pivotTF, high[1], lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, pivotTF, low[1], lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, pivotTF, close[1], lookahead=barmerge.lookahead_on)

pivot = (prevHigh + prevLow + prevClose) / 3

r1 = (2 * pivot) - prevLow
s1 = (2 * pivot) - prevHigh

r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)

r3 = prevHigh + 2 * (pivot - prevLow)
s3 = prevLow - 2 * (prevHigh - pivot)

//━━━━━━━━━━━━━━━━━━━
// LINE AND LABEL VARIABLES
//━━━━━━━━━━━━━━━━━━━
var line pivotLine = na
var line r1Line = na
var line s1Line = na
var line r2Line = na
var line s2Line = na
var line r3Line = na
var line s3Line = na

var label pivotLabel = na
var label r1Label = na
var label s1Label = na
var label r2Label = na
var label s2Label = na
var label r3Label = na
var label s3Label = na

//━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━
makeLine(_price, _colour) =>
    line.new(bar_index - leftExtendBars, _price, bar_index + rightExtendBars, _price, xloc=xloc.bar_index, extend=extend.none, color=_colour, width=lineWidth)

makeLabel(_price, _text) =>
    label.new(bar_index + rightExtendBars, _price, _text, xloc=xloc.bar_index, style=label.style_none, textcolor=textColour, size=size.small)

updateLevel(_line, _label, _price, _text) =>
    if not na(_line) and not na(_price)
        line.set_xy1(_line, bar_index - leftExtendBars, _price)
        line.set_xy2(_line, bar_index + rightExtendBars, _price)
        line.set_width(_line, lineWidth)

    if not na(_label) and not na(_price)
        label.set_x(_label, bar_index + rightExtendBars)
        label.set_y(_label, _price)
        label.set_text(_label, _text)
        label.set_textcolor(_label, textColour)

alertHit(_level) =>
    alertMode == "Cross" ? ta.cross(close, _level) : alertMode == "Cross Up" ? ta.crossover(close, _level) : ta.crossunder(close, _level)

//━━━━━━━━━━━━━━━━━━━
// CREATE LINES AND LABELS
//━━━━━━━━━━━━━━━━━━━
if na(pivotLine) and not na(pivot)
    if showPivot
        pivotLine := makeLine(pivot, pivotColour)
        pivotLabel := makeLabel(pivot, "PIVOT")

    if showR1S1
        r1Line := makeLine(r1, resColour)
        r1Label := makeLabel(r1, "R1")
        s1Line := makeLine(s1, supColour)
        s1Label := makeLabel(s1, "S1")

    if showR2S2
        r2Line := makeLine(r2, resColour)
        r2Label := makeLabel(r2, "R2")
        s2Line := makeLine(s2, supColour)
        s2Label := makeLabel(s2, "S2")

    if showR3S3
        r3Line := makeLine(r3, resColour)
        r3Label := makeLabel(r3, "R3")
        s3Line := makeLine(s3, supColour)
        s3Label := makeLabel(s3, "S3")

//━━━━━━━━━━━━━━━━━━━
// UPDATE LINES AND LABELS
//━━━━━━━━━━━━━━━━━━━
updateLevel(pivotLine, pivotLabel, pivot, "PIVOT")
updateLevel(r1Line, r1Label, r1, "R1")
updateLevel(s1Line, s1Label, s1, "S1")
updateLevel(r2Line, r2Label, r2, "R2")
updateLevel(s2Line, s2Label, s2, "S2")
updateLevel(r3Line, r3Label, r3, "R3")
updateLevel(s3Line, s3Label, s3, "S3")

//━━━━━━━━━━━━━━━━━━━
// BACKGROUND BIAS
//━━━━━━━━━━━━━━━━━━━
bullish = close > pivot
bearish = close < pivot

bgColour = showBackgroundBias ? bullish ? color.new(color.green, 92) : bearish ? color.new(color.red, 92) : na : na
bgcolor(bgColour)

//━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━
pivotAlert = alertPivot and not na(pivot) and alertHit(pivot)
r1Alert    = alertR1 and not na(r1) and alertHit(r1)
s1Alert    = alertS1 and not na(s1) and alertHit(s1)
r2Alert    = alertR2 and not na(r2) and alertHit(r2)
s2Alert    = alertS2 and not na(s2) and alertHit(s2)
r3Alert    = alertR3 and not na(r3) and alertHit(r3)
s3Alert    = alertS3 and not na(s3) and alertHit(s3)

anyPivotAlert = pivotAlert or r1Alert or s1Alert or r2Alert or s2Alert or r3Alert or s3Alert

alertcondition(pivotAlert, title="Pivot Alert", message="Price has triggered the Pivot level")
alertcondition(r1Alert, title="R1 Alert", message="Price has triggered the R1 resistance level")
alertcondition(s1Alert, title="S1 Alert", message="Price has triggered the S1 support level")
alertcondition(r2Alert, title="R2 Alert", message="Price has triggered the R2 resistance level")
alertcondition(s2Alert, title="S2 Alert", message="Price has triggered the S2 support level")
alertcondition(r3Alert, title="R3 Alert", message="Price has triggered the R3 resistance level")
alertcondition(s3Alert, title="S3 Alert", message="Price has triggered the S3 support level")
alertcondition(anyPivotAlert, title="Any Selected Pivot Level Alert", message="Price has triggered one of your selected pivot levels")
````
