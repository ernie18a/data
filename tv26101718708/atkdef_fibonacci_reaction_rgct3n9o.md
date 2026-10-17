# ATK/DEF Fibonacci Reaction 

- url: https://www.tradingview.com/script/rGCT3n9o/
- type: indicator
- pine_id: PUB;f5b7fc13e9d44ba290b6fdd10f0107b9
- version: 1.0

## Description

📊 ATK/DEF Fibonacci Reaction

Overview
ATK/DEF Fibonacci Reaction is an auto-directional Fibonacci retracement tool that combines smart trend detection with real-time price action analysis. Unlike static Fibonacci tools that require manual drawing, this indicator automatically adapts to market conditions — plotting retracement levels from low to high in uptrends, and from high to low in downtrends.

Why this mashup matters:
Most Fibonacci tools only plot levels, leaving traders to manually interpret price action. This script solves that by integrating three complementary components into one workflow: Auto-Direction Fib (identifies key levels) + Liquidity Detection (flags potential fakeout zones) + Price Behavior Analysis (translates price action into actionable signals). The synergy is simple: Fib levels tell you where price might reverse, Liquidity tells you where traps might form, and Fib Reaction tells you what is actually happening in real-time. This eliminates the need to switch between multiple indicators or guess price behavior at key levels.

How It Works
The script calculates the highest and lowest price over the user-defined Lookback Period, then plots 7 Fibonacci retracement levels. It automatically detects trend direction using SMA crossover: if the market is in an uptrend, levels are drawn from low to high; in a downtrend, from high to low. Current price position is shown as a percentage, and the script continuously evaluates whether price is bouncing off support, rejecting resistance, or breaking through — generating clear, actionable signals.

What makes this original:
Unlike existing Fibonacci tools that simply draw lines, this script introduces a decision-support layer. The combination of Fib Behavior + Fib Reaction + Liquidity Detection creates a feedback loop rarely seen in open-source Pine Script tools. While other scripts tell you where the levels are, this one tells you what price is doing at those levels — bridging the gap between technical analysis and actionable trading decisions.

Signal Interpretation
Signal	Meaning	Suggested Action
🟢 Bounce at Support	Price rejected support — potential long opportunity	Look for confirmation
🔴 Reject at Resistance	Price rejected resistance — potential short opportunity	Look for confirmation
🚀 Break Resistance	Price broke above resistance — bullish momentum	Monitor for continuation
💥 Break Support	Price broke below support — bearish momentum	Monitor for continuation
🟡 Testing S/R	Price testing key level — no clear direction	Wait for confirmation
How to Use
Scenario	What to Watch
Long setup	Uptrend + price near 50/61.8% + Bounce at Support signal
Short setup	Downtrend + price near 50/61.8% + Reject at Resistance signal
Breakout setup	Break Resistance → bullish momentum; Break Support → bearish momentum
Avoid trading	Testing S/R signal — price lacks clear direction

Parameters
Parameter	Default	Description
Lookback Period	100	Range for highest/lowest price calculation (20-500)
Extension Bars	20	Horizontal line extension to the right (1-100)
Trend Detection Period	50	SMA period for trend direction (20-200)
Show Info Table	On	Toggle the live data table

Best Practices
Best used on 4H, Daily, or Weekly for swing trading; also works on 15m-1H for intraday

Most effective in trending markets; can be combined with RSI or MACD for confluence

Focus on 50% and 61.8% levels — they often act as the strongest reversal zones

When Liquidity Detection shows "Near Liquidity High/Low" alongside a Fib test, expect higher volatility and potential fakeouts

Disclaimer
Past performance does not guarantee future results. This indicator is for educational and analytical purposes only. Always conduct your own research and risk management before trading.

## Source Code

````pine
// @version=6
indicator("📊 ATK/DEF Fibonacci Reaction", "ATK/DEF Fib", overlay=true, 
          max_lines_count=100, max_labels_count=50)

// === INPUT PARAMETERS ===
lookback = input.int(100, "Lookback Period", minval=20, maxval=500)
extendBars = input.int(20, "Extension Bars", minval=1, maxval=100)
showLabels = input.bool(true, "Show Price Labels")
trendPeriod = input.int(50, "Trend Detection Period", minval=20, maxval=200)

// === TABLE SETTINGS ===
showTable = input.bool(true, "Show Info Table", group="Table Settings")
tablePosition = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Table Settings")
tableScale = input.float(1.0, "Table Scale", step=0.1, minval=0.5, maxval=2.0, group="Table Settings")

// === TREND DIRECTION ===
float sma50 = ta.sma(close, trendPeriod)
float sma200 = ta.sma(close, 200)

bool isUptrend = close > sma50 and sma50 > sma200
bool isDowntrend = close < sma50 and sma50 < sma200

// === HIGH/LOW CALCULATION ===
float highPrice = ta.highest(high, lookback)
float lowPrice = ta.lowest(low, lookback)
float fibRange = highPrice - lowPrice

// === AUTO DIRECTION ===
float fib_0_auto = isUptrend ? lowPrice : highPrice
float fib_100_auto = isUptrend ? highPrice : lowPrice
float fibRange_auto = isUptrend ? fibRange : -fibRange

// === FIBONACCI RETRACEMENT LEVELS ===
float fib_0 = fib_0_auto
float fib_236 = fib_0_auto + fibRange_auto * 0.236
float fib_382 = fib_0_auto + fibRange_auto * 0.382
float fib_500 = fib_0_auto + fibRange_auto * 0.500
float fib_618 = fib_0_auto + fibRange_auto * 0.618
float fib_786 = fib_0_auto + fibRange_auto * 0.786
float fib_100 = fib_100_auto

// === SUPPORT & RESISTANCE ===
float support = fib_0
float resistance = fib_100

if close > fib_500
    support := fib_500
    resistance := fib_100
else if close > fib_382
    support := fib_382
    resistance := fib_500
else if close > fib_236
    support := fib_236
    resistance := fib_382
else
    support := fib_0
    resistance := fib_236

// === FIBONACCI POSITION ===
float fibPos = fibRange != 0 ? (close - lowPrice) / fibRange * 100 : 50
if isDowntrend
    fibPos := 100 - fibPos

// === ZONE DETECTION ===
string zoneText = ""
color zoneColor = color.white

if fibPos >= 78.6
    zoneText := isUptrend ? "🔴 High Zone 78.6-100%" : "🔴 Low Zone 0-21.4%"
    zoneColor := color.red
else if fibPos >= 61.8
    zoneText := isUptrend ? "🟠 Mid-High 61.8-78.6%" : "🟠 Mid-Low 21.4-38.2%"
    zoneColor := color.orange
else if fibPos >= 50
    zoneText := isUptrend ? "🟡 Mid Zone 50-61.8%" : "🟡 Mid Zone 38.2-50%"
    zoneColor := color.yellow
else if fibPos >= 38.2
    zoneText := isUptrend ? "🟢 Mid-Low 38.2-50%" : "🟢 Mid-High 50-61.8%"
    zoneColor := color.lime
else if fibPos >= 23.6
    zoneText := isUptrend ? "🔵 Low Zone 23.6-38.2%" : "🔵 High Zone 61.8-78.6%"
    zoneColor := color.teal
else
    zoneText := isUptrend ? "🟣 Very Low 0-23.6%" : "🟣 Very High 78.6-100%"
    zoneColor := color.blue

// === LIQUIDITY DETECTION ===
float liqHigh = ta.highest(high, 20)
float liqLow = ta.lowest(low, 20)
bool nearLiqHigh = close >= liqHigh * 0.995
bool nearLiqLow = close <= liqLow * 1.005

string liquidityText = ""
color liquidityColor = color.white
if nearLiqHigh
    liquidityText := "🔴 Near Liquidity High"
    liquidityColor := color.red
else if nearLiqLow
    liquidityText := "🟢 Near Liquidity Low"
    liquidityColor := color.green
else
    liquidityText := "⚪ Normal Range"
    liquidityColor := color.gray

// === FIB BEHAVIOR ===
string fibBehavior = ""
color fibBehaviorColor = color.white

if close >= fib_618
    fibBehavior := "🔴 Upper Zone (≥61.8%)"
    fibBehaviorColor := color.red
else if close >= fib_500
    fibBehavior := "🟡 Above Mid (50-61.8%)"
    fibBehaviorColor := color.yellow
else if close >= fib_382
    fibBehavior := "🟢 Below Mid (38.2-50%)"
    fibBehaviorColor := color.lime
else if close >= fib_236
    fibBehavior := "🔵 Lower Zone (23.6-38.2%)"
    fibBehaviorColor := color.teal
else
    fibBehavior := "🟣 Very Low (<23.6%)"
    fibBehaviorColor := color.blue

// === FIB REACTION ===
float body = math.abs(close - open)
float atrVal = ta.atr(14)

bool bounceOffSupport = low <= support + atrVal * 0.2 and close > support + atrVal * 0.3
bool rejectFromResistance = high >= resistance - atrVal * 0.2 and close < resistance - atrVal * 0.3
bool breakAboveResistance = close > resistance and close > open and body > atrVal * 0.3
bool breakBelowSupport = close < support and close < open and body > atrVal * 0.3
bool atSupport = close <= support + atrVal * 0.3 and close >= support - atrVal * 0.3
bool atResistance = close <= resistance + atrVal * 0.3 and close >= resistance - atrVal * 0.3

string fibReaction = ""
color fibReactionColor = color.white

if bounceOffSupport
    fibReaction := "🟢 Bounce at Support"
    fibReactionColor := color.green
else if rejectFromResistance
    fibReaction := "🔴 Reject at Resistance"
    fibReactionColor := color.red
else if breakAboveResistance
    fibReaction := "🚀 Break Resistance"
    fibReactionColor := color.green
else if breakBelowSupport
    fibReaction := "💥 Break Support"
    fibReactionColor := color.red
else if atSupport
    fibReaction := "🟡 Testing Support"
    fibReactionColor := color.yellow
else if atResistance
    fibReaction := "🟡 Testing Resistance"
    fibReactionColor := color.yellow
else
    fibReaction := "⚪ No Reaction"
    fibReactionColor := color.gray

// === TIMEFRAME (Readable Format) ===
string timeframeText = ""
string tf = timeframe.period

if tf == "1"
    timeframeText := "1m"
else if tf == "3"
    timeframeText := "3m"
else if tf == "5"
    timeframeText := "5m"
else if tf == "15"
    timeframeText := "15m"
else if tf == "30"
    timeframeText := "30m"
else if tf == "45"
    timeframeText := "45m"
else if tf == "60"
    timeframeText := "1h"
else if tf == "120"
    timeframeText := "2h"
else if tf == "180"
    timeframeText := "3h"
else if tf == "240"
    timeframeText := "4h"
else if tf == "360"
    timeframeText := "6h"
else if tf == "720"
    timeframeText := "12h"
else if tf == "D"
    timeframeText := "Daily"
else if tf == "W"
    timeframeText := "Weekly"
else if tf == "M"
    timeframeText := "Monthly"
else
    timeframeText := tf

// === ARRAYS FOR OBJECTS ===
var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()

// === DRAWING ===
if barstate.islast
    int left = bar_index - lookback
    int right = bar_index + extendBars
    
    // Delete old objects
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
        array.clear(fibLines)
    
    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
        array.clear(fibLabels)
    
    // ----- Draw Fibonacci Lines -----
    array.push(fibLines, line.new(left, fib_0, right, fib_0, color=color.new(color.blue, 80), width=2, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_236, right, fib_236, color=color.new(color.teal, 80), width=2, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_382, right, fib_382, color=color.new(color.green, 80), width=2, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_500, right, fib_500, color=color.new(color.yellow, 90), width=3, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_618, right, fib_618, color=color.new(color.orange, 90), width=3, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_786, right, fib_786, color=color.new(color.red, 80), width=2, style=line.style_solid))
    array.push(fibLines, line.new(left, fib_100, right, fib_100, color=color.new(color.maroon, 80), width=2, style=line.style_solid))
    
    // ----- Draw Labels -----
    if showLabels
        string dirText = isUptrend ? "📈 Uptrend" : isDowntrend ? "📉 Downtrend" : "➖ Sideways"
        color dirColor = isUptrend ? color.green : isDowntrend ? color.red : color.gray
        
        array.push(fibLabels, label.new(right, fib_0, text="0 ★ Retrace Start", color=color.new(color.blue, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_236, text="0.236 ★ Shallow", color=color.new(color.teal, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_382, text="0.382 ★ Common S/R", color=color.new(color.green, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_500, text="0.500 ★ Mid Level", color=color.new(color.yellow, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_618, text="0.618 ★ Golden Zone", color=color.new(color.orange, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_786, text="0.786 ★ Deep Retrace", color=color.new(color.red, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        array.push(fibLabels, label.new(right, fib_100, text="1.0 ★ Retrace End", color=color.new(color.maroon, 15), textcolor=color.white, style=label.style_label_left, size=size.tiny))
        
        // Direction label
        array.push(fibLabels, label.new(right + 2, fib_100 + fibRange_auto * 0.05, 
            text="Trend: " + dirText, 
            color=color.new(color.black, 80), 
            textcolor=dirColor, 
            style=label.style_label_left, 
            size=size.tiny))
        
        // Current position label
        array.push(fibLabels, label.new(bar_index, close, 
            text="📍 " + str.tostring(fibPos, "#.#") + "%\n" + zoneText, 
            color=color.new(color.black, 85), 
            textcolor=zoneColor, 
            style=label.style_label_center, 
            size=size.tiny))
    
    // ----- High/Low Markers -----
    string lowText = isUptrend ? "▼ LOW" : "▲ HIGH (Bounce Start)"
    string highText = isUptrend ? "▲ HIGH" : "▼ LOW (Bounce End)"
    
    array.push(fibLabels, label.new(left, lowPrice, text=lowText, color=color.new(color.blue, 50), textcolor=color.white, style=label.style_label_down, size=size.tiny))
    array.push(fibLabels, label.new(left, highPrice, text=highText, color=color.new(color.red, 50), textcolor=color.white, style=label.style_label_up, size=size.tiny))
    
    // ============================================================
    // === INFO TABLE ===
    // ============================================================
    if showTable
        string pos = tablePosition
        
        var table infoTable = table.new(
            pos == "Top Left" ? position.top_left :
            pos == "Top Right" ? position.top_right :
            pos == "Bottom Left" ? position.bottom_left :
            position.bottom_right, 
            columns=2, rows=8, 
            bgcolor=color.new(color.rgb(10,10,30), 90), 
            border_color=color.rgb(60,60,120), 
            border_width=2)
        
        int fontSize = int(11 * tableScale)
        if fontSize < 8
            fontSize := 8
        if fontSize > 20
            fontSize := 20
        
        string sizeText = ""
        if fontSize <= 8
            sizeText := "tiny"
        else if fontSize <= 10
            sizeText := "small"
        else if fontSize <= 13
            sizeText := "normal"
        else if fontSize <= 16
            sizeText := "large"
        else
            sizeText := "huge"
        
        // Header
        table.cell(infoTable, 0, 0, " 📊 ATK/DEF FIB ", 
            text_color=color.rgb(200,200,255), 
            bgcolor=color.rgb(40,40,100), 
            text_size=sizeText)
        table.cell(infoTable, 1, 0, "", 
            bgcolor=color.rgb(40,40,100))
        
        // Row 1: Timeframe
        table.cell(infoTable, 0, 1, " Timeframe", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 1, " " + timeframeText, 
            text_color=color.rgb(200,200,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 2: Liquidity
        table.cell(infoTable, 0, 2, " Liquidity", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 2, liquidityText, 
            text_color=liquidityColor, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 3: Fib Behavior
        table.cell(infoTable, 0, 3, " Fib Behavior", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 3, fibBehavior, 
            text_color=fibBehaviorColor, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 4: Fib Reaction
        table.cell(infoTable, 0, 4, " Fib Reaction", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 4, fibReaction, 
            text_color=fibReactionColor, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 5: Support
        table.cell(infoTable, 0, 5, " Support", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 5, " " + str.tostring(support, "#.##"), 
            text_color=color.green, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 6: Resistance
        table.cell(infoTable, 0, 6, " Resistance", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 6, " " + str.tostring(resistance, "#.##"), 
            text_color=color.red, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        
        // Row 7: Fib Position
        table.cell(infoTable, 0, 7, " Fib Position", 
            text_color=color.rgb(180,180,200), 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
        table.cell(infoTable, 1, 7, " " + str.tostring(fibPos, "#.#") + "%", 
            text_color=zoneColor, 
            bgcolor=color.rgb(20,20,50), 
            text_size=sizeText)
````
