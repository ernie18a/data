# Elaris Auto Trend Fibonacci Pro

- url: https://www.tradingview.com/script/zf2xakcQ-Elaris-Auto-Trend-Fibonacci-Pro/
- type: indicator
- pine_id: PUB;3d94cb07627a4a5889af26d34a350a64
- version: 1.0

## Description

[b]Elaris Auto Trend Fibonacci Pro[/b]

[b]Overview[/b]

Elaris Auto Trend Fibonacci Pro is an advanced market structure and Fibonacci analysis tool designed to automatically identify directional trends, detect significant swing points, and project professional-grade Fibonacci retracement and extension levels directly on the chart.

Unlike manual Fibonacci drawing tools that require traders to constantly adjust anchor points, this indicator continuously analyzes confirmed swing structure and automatically maps the most relevant Fibonacci framework based on the current market trend.

The goal is to help traders quickly identify potential pullback zones, trend continuation areas, profit targets, and key reaction levels without manually redrawing Fibonacci levels throughout the trading session.

---

[b]How The Indicator Works[/b]

[b]1. Swing Structure Detection[/b]

The indicator first identifies confirmed swing highs and swing lows using a configurable pivot confirmation algorithm.

A swing is only considered valid after confirmation, which helps eliminate many false or premature swing points that often appear during volatile market conditions.

The minimum swing size can also be filtered using ATR-based validation, ensuring that insignificant market fluctuations are ignored.

---

[b]2. Trend Identification[/b]

After detecting valid market structure, the indicator determines the dominant directional trend.

Bullish trends are identified when recent confirmed swing lows lead into higher confirmed swing highs.

Bearish trends are identified when recent confirmed swing highs lead into lower confirmed swing lows.

An optional EMA trend filter can be enabled to require alignment between price structure and moving average direction.

This additional layer helps reduce counter-trend Fibonacci projections.

---

[b]3. Automatic Fibonacci Mapping[/b]

Once a valid trend is detected, Fibonacci levels are automatically projected between the most relevant confirmed swing points.

The indicator plots:

• 0.236 Retracement
• 0.382 Retracement
• 0.500 Midpoint
• 0.618 Golden Ratio
• 0.786 Deep Retracement
• 1.000 Retracement

These levels represent areas where pullbacks, reactions, trend continuations, or reversals may occur.

---

[b]4. Golden Zone Highlighting[/b]

The area between the 50% and 61.8% retracement levels is automatically highlighted as the Golden Zone.

Many traders monitor this region because it often represents an area where institutional participants may re-enter an existing trend after a pullback.

The highlighted zone provides a quick visual reference for potential trend continuation opportunities.

---

[b]5. Extension Targets[/b]

The indicator can optionally project Fibonacci extension levels beyond the current trend.

Available extension targets include:

• 1.272 Extension
• 1.618 Extension
• 2.000 Extension

These levels can be used as potential profit-taking areas, trend continuation objectives, or future reaction zones.

---

[b]6. Trend Dashboard[/b]

A built-in dashboard provides real-time information including:

• Current trend direction
• Swing strength relative to ATR
• Fibonacci anchor direction
• Golden zone status
• Indicator operating mode

The dashboard helps traders evaluate current market conditions without needing additional analysis tools.

---

[b]How To Use[/b]

[b]Trend Continuation[/b]

1. Wait for a confirmed bullish or bearish trend.
2. Allow price to retrace toward the highlighted Fibonacci levels.
3. Monitor the Golden Zone for potential continuation setups.
4. Use extension levels as potential target areas.

[b]Pullback Analysis[/b]

The 38.2%, 50%, and 61.8% retracement levels can help identify areas where temporary corrections may end and the primary trend may resume.

[b]Target Projection[/b]

The Fibonacci extensions can be used to estimate possible future trend objectives after a successful continuation move.

---

[b]Important Notes[/b]

• The indicator uses confirmed swing points and does not rely on future-looking calculations after confirmation.

• Fibonacci levels automatically update when a new confirmed market structure is established.

• The indicator is designed for trending markets and may generate fewer meaningful projections during prolonged ranging conditions.

• This tool is intended for technical analysis and should not be used as a standalone trading system.

---

[b]Best Markets[/b]

The indicator can be applied to:

• Cryptocurrency Markets
• Forex Markets
• Stock Markets
• Index Markets
• Commodity Markets

It is particularly effective on higher liquidity instruments where market structure tends to be more consistent.

---

[b]Best Timeframes[/b]

Recommended timeframes:

• 15 Minutes
• 1 Hour
• 4 Hours
• Daily

Higher timeframes generally produce more reliable market structure and Fibonacci projections.

---

[b]Alerts[/b]

The indicator includes alerts for:

• Trend direction changes
• Golden Zone interactions
• Key Fibonacci level breaks

These alerts can be integrated into trading workflows for additional monitoring and confirmation.

---

Thank you for using Elaris Auto Trend Fibonacci Pro.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// © ElarisGroup

//@version=6
indicator("Elaris Auto Trend Fibonacci Pro", shorttitle="Elaris Auto Fib Pro", overlay=true, max_lines_count=120, max_labels_count=120, max_boxes_count=20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSwing = "Swing & Trend Detection"
swingLen = input.int(8, "Swing Confirmation Length", minval=2, maxval=50, group=groupSwing)
useTrendEma = input.bool(true, "Use EMA Trend Filter", group=groupSwing)
emaLen = input.int(100, "Trend EMA Length", minval=10, maxval=300, group=groupSwing)
minSwingAtr = input.float(1.0, "Minimum Swing Size ATR", minval=0.1, step=0.1, group=groupSwing)

groupFib = "Fibonacci Levels"
showFib = input.bool(true, "Show Fibonacci Map", group=groupFib)
showExtensions = input.bool(true, "Show Extension Targets", group=groupFib)
showGoldenZone = input.bool(true, "Highlight Golden Zone", group=groupFib)
fibWidth = input.int(1, "Fib Line Width", minval=1, maxval=4, group=groupFib)

groupVisual = "Visual Design"
theme = input.string("Dark", "Theme", options=["Dark", "Light"], group=groupVisual)
showLabels = input.bool(true, "Show Level Labels", group=groupVisual)
showTrendBg = input.bool(true, "Show Trend Background", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
dashboardPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupVisual)

groupAlerts = "Alerts"
alertOnGoldenTouch = input.bool(true, "Alert: Golden Zone Touch", group=groupAlerts)
alertOnTrendFlip = input.bool(true, "Alert: Trend Flip", group=groupAlerts)
alertOnLevelBreak = input.bool(true, "Alert: Important Level Break", group=groupAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isDark = theme == "Dark"

bullColor = color.rgb(0, 200, 120)
bearColor = color.rgb(255, 80, 90)
neutralColor = color.rgb(160, 160, 160)
textColor = isDark ? color.white : color.black
panelBg = isDark ? color.rgb(20, 24, 32) : color.rgb(245, 245, 245)
fibColor = isDark ? color.rgb(170, 190, 255) : color.rgb(45, 70, 150)
goldColor = color.rgb(255, 190, 70)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(14)
ema = ta.ema(close, emaLen)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow = na
var int lastHighBar = na
var int lastLowBar = na

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - swingLen

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - swingLen

hasStructure = not na(lastHigh) and not na(lastLow)
swingSize = hasStructure ? math.abs(lastHigh - lastLow) : na
validSwing = hasStructure and swingSize >= atr * minSwingAtr

rawBull = validSwing and lastLowBar > lastHighBar
rawBear = validSwing and lastHighBar > lastLowBar

emaBull = close > ema and ema > ema[5]
emaBear = close < ema and ema < ema[5]

bullTrend = rawBull and (not useTrendEma or emaBull)
bearTrend = rawBear and (not useTrendEma or emaBear)

trend = bullTrend ? 1 : bearTrend ? -1 : 0
trendChanged = trend != trend[1] and trend != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fib Anchors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fibStart = trend == 1 ? lastLow : trend == -1 ? lastHigh : na
fibEnd = trend == 1 ? lastHigh : trend == -1 ? lastLow : na
startBar = trend == 1 ? lastLowBar : trend == -1 ? lastHighBar : na
endBar = trend == 1 ? lastHighBar : trend == -1 ? lastLowBar : na

fibRange = math.abs(fibEnd - fibStart)

fibPrice(float level) =>
    trend == 1 ? fibEnd - fibRange * level : fibEnd + fibRange * level

extPrice(float level) =>
    trend == 1 ? fibStart + fibRange * level : fibStart - fibRange * level

// Main retracements
l0 = fibPrice(0.0)
l236 = fibPrice(0.236)
l382 = fibPrice(0.382)
l50 = fibPrice(0.5)
l618 = fibPrice(0.618)
l786 = fibPrice(0.786)
l100 = fibPrice(1.0)

// Extensions
e127 = extPrice(1.272)
e161 = extPrice(1.618)
e200 = extPrice(2.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Object Management
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()
var box goldenBox = na

clearObjects() =>
    while array.size(fibLines) > 0
        line.delete(array.pop(fibLines))
    while array.size(fibLabels) > 0
        label.delete(array.pop(fibLabels))
    if not na(goldenBox)
        box.delete(goldenBox)

drawLevel(float price, string txt, color clr, int width) =>
    ln = line.new(startBar, price, bar_index + 40, price, extend=extend.right, color=clr, width=width)
    array.push(fibLines, ln)
    if showLabels
        lb = label.new(bar_index + 40, price, txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, textcolor=textColor, color=color.new(clr, 75), size=size.small)
        array.push(fibLabels, lb)

if barstate.islast
    clearObjects()

    if showFib and validSwing and trend != 0
        drawLevel(l0, "0.0 Trend Extreme", fibColor, fibWidth)
        drawLevel(l236, "0.236 Shallow Pullback", fibColor, fibWidth)
        drawLevel(l382, "0.382 Reaction Level", fibColor, fibWidth)
        drawLevel(l50, "0.500 Midpoint", color.new(fibColor, 10), fibWidth + 1)
        drawLevel(l618, "0.618 Golden Level", goldColor, fibWidth + 1)
        drawLevel(l786, "0.786 Deep Retracement", color.new(goldColor, 10), fibWidth)
        drawLevel(l100, "1.0 Origin", fibColor, fibWidth)

        if showGoldenZone
            topZone = math.max(l50, l618)
            botZone = math.min(l50, l618)
            goldenBox := box.new(startBar, topZone, bar_index + 40, botZone, bgcolor=color.new(goldColor, 88), border_color=color.new(goldColor, 60))

        if showExtensions
            drawLevel(e127, "1.272 Target", bullTrend ? bullColor : bearColor, fibWidth)
            drawLevel(e161, "1.618 Major Target", bullTrend ? bullColor : bearColor, fibWidth + 1)
            drawLevel(e200, "2.000 Extended Target", bullTrend ? bullColor : bearColor, fibWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Important Level Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inGoldenZone = validSwing and trend != 0 and close <= math.max(l50, l618) and close >= math.min(l50, l618)

break618Bull = trend == 1 and ta.crossover(close, l618)
break618Bear = trend == -1 and ta.crossunder(close, l618)

plot(ema, "Trend EMA", color=trend == 1 ? bullColor : trend == -1 ? bearColor : neutralColor, linewidth=2)

plotshape(trendChanged and trend == 1, title="Bull Trend Confirmed", style=shape.labelup, text="BULL\nFIB", color=bullColor, textcolor=color.white, location=location.belowbar, size=size.small)
plotshape(trendChanged and trend == -1, title="Bear Trend Confirmed", style=shape.labeldown, text="BEAR\nFIB", color=bearColor, textcolor=color.white, location=location.abovebar, size=size.small)

plotshape(inGoldenZone and trend == 1, title="Bull Golden Zone Touch", style=shape.circle, color=goldColor, location=location.belowbar, size=size.tiny)
plotshape(inGoldenZone and trend == -1, title="Bear Golden Zone Touch", style=shape.circle, color=goldColor, location=location.abovebar, size=size.tiny)

bgcolor(showTrendBg ? trend == 1 ? color.new(bullColor, 92) : trend == -1 ? color.new(bearColor, 92) : na : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos = dashboardPos == "Top Right" ? position.top_right : dashboardPos == "Top Left" ? position.top_left : dashboardPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(pos, 2, 5, border_width=1)

if barstate.islast and showDashboard
    trendTxt = trend == 1 ? "Bullish" : trend == -1 ? "Bearish" : "Neutral"
    trendClr = trend == 1 ? bullColor : trend == -1 ? bearColor : neutralColor

    table.cell(dash, 0, 0, "Elaris Auto Fib Pro", text_color=textColor, bgcolor=panelBg)
    table.cell(dash, 1, 0, trendTxt, text_color=color.white, bgcolor=trendClr)

    table.cell(dash, 0, 1, "Swing Size", text_color=textColor, bgcolor=panelBg)
    table.cell(dash, 1, 1, validSwing ? str.tostring(swingSize / atr, "#.##") + " ATR" : "Invalid", text_color=textColor, bgcolor=panelBg)

    table.cell(dash, 0, 2, "Golden Zone", text_color=textColor, bgcolor=panelBg)
    table.cell(dash, 1, 2, inGoldenZone ? "Price Inside" : "Waiting", text_color=inGoldenZone ? goldColor : textColor, bgcolor=panelBg)

    table.cell(dash, 0, 3, "Fib Anchor", text_color=textColor, bgcolor=panelBg)
    table.cell(dash, 1, 3, trend == 1 ? "Low → High" : trend == -1 ? "High → Low" : "None", text_color=textColor, bgcolor=panelBg)

    table.cell(dash, 0, 4, "Mode", text_color=textColor, bgcolor=panelBg)
    table.cell(dash, 1, 4, "Confirmed / Non-Repaint", text_color=textColor, bgcolor=panelBg)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(alertOnTrendFlip and trendChanged and trend == 1, "Bullish Trend Fib Confirmed", "Bullish trend confirmed and Fibonacci map updated.")
alertcondition(alertOnTrendFlip and trendChanged and trend == -1, "Bearish Trend Fib Confirmed", "Bearish trend confirmed and Fibonacci map updated.")
alertcondition(alertOnGoldenTouch and inGoldenZone, "Golden Zone Touch", "Price is reacting inside the Fibonacci golden zone.")
alertcondition(alertOnLevelBreak and (break618Bull or break618Bear), "0.618 Level Break", "Price has broken the important 0.618 Fibonacci level.")
````
