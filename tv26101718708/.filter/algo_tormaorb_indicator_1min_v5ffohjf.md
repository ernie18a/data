# Algo TormaORB Indicator [1min]

- url: https://www.tradingview.com/script/v5FfoHjF-Algo-TormaORB-Indicator-1min/
- type: indicator
- pine_id: PUB;510b1b621fde4e22a525ec28d038ecf3
- version: 1.0

## Description

ORB Indicator [1min]

This indicator is built exclusively for the 1-minute chart and will not function on any other timeframe. It is designed for intraday traders who use the Opening Range Breakout strategy on any instrument supported by TradingView.


How It Works

The indicator captures the high and low of the first five candles of the session (9:30 AM to 9:34 AM New York time) to define the opening range. At 9:35 AM, these levels are locked and drawn on the chart as horizontal lines with a shaded box between them. Both the lines and the box remain visible until 10:30 AM, at which point the opening range period closes and no new signals are generated for the rest of the day.

A dashed line is also drawn at the 9:30 AM open price and extends to 10:30 AM as an additional intraday reference level.


Breakout Detection

A breakout is confirmed when a candle closes above the opening range high (bullish) or below the opening range low (bearish). A "BO" label is plotted on the chart at the moment of confirmation. Only one breakout is tracked per day — once the first signal fires, no further breakout labels are generated regardless of price action.


Retest Signals

After a confirmed breakout, the indicator watches for price to return and touch the broken level. If price wicks back into the opening range after a bullish breakout, an "ORB Retest Long" label is plotted below the candle. If price wicks back after a bearish breakout, an "ORB Retest Short" label is plotted above the candle. The retest signal fires once and then resets.


Take Profit Levels

Two take profit levels are drawn as dashed lines immediately after a breakout is confirmed. Both targets are based on fixed point values set in the indicator inputs and are labeled directly on the chart for quick reference.

Target 1 — default 10 points from the breakout close
Target 2 — default 20 points from the breakout close


Alerts

The indicator includes four built-in alerts that trigger on bar close.

Bullish breakout — fires when a candle closes above the opening range high.
Bearish breakout — fires when a candle closes below the opening range low.
ORB Retest Long — fires when price returns to touch the high after a bullish breakout.
ORB Retest Short — fires when price returns to touch the low after a bearish breakout.

To activate alerts, open the TradingView alert dialog, select this indicator, and choose the condition you want to be notified on.


Inputs & Customization

All visual elements are fully customizable through the indicator settings panel, organized into four groups.

ORB Settings — adjust the opening range start time and end time.
Take Profit Settings — set the fixed point value for Target 1 and Target 2.
Color Settings — customize the color of every line, box, and label individually.
Line Style — control the width of the ORB high/low lines and the open line.


Important Notes

This indicator is designed for the 1-minute chart only. It will produce a runtime error if applied to any other timeframe.

All times are based on the America/New York timezone. Ensure your TradingView chart timezone is set correctly for accurate signal timing.

This indicator is for informational and educational purposes only. It does not constitute financial advice. Always manage your risk appropriately.

## Source Code

````pine
//@version=6
indicator("Algo TormaORB Indicator [1min]", overlay = true, max_lines_count = 20, max_labels_count = 100, max_boxes_count = 5)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════

var g_orb = "ORB Settings"
orbStartHour = input.int(9,  "ORB Start Hour",   group = g_orb)
orbStartMin  = input.int(30, "ORB Start Minute",  group = g_orb)
orbEndHour   = input.int(10, "ORB End Hour",      group = g_orb)
orbEndMin    = input.int(30, "ORB End Minute",    group = g_orb)

var g_tp = "Take Profit Settings"
tp1Points = input.float(10.0, "Target 1 (3-candle) - Fixed Points", group = g_tp)
tp2Points = input.float(20.0, "Target 2 (5-candle) - Fixed Points", group = g_tp)

var g_col = "Color Settings"
orbHighColor    = input.color(color.blue,                "ORB High Line",        group = g_col)
orbLowColor     = input.color(color.red,                 "ORB Low Line",         group = g_col)
orbBoxColor     = input.color(color.new(color.blue, 85), "ORB Box Fill",         group = g_col)
openLineColor   = input.color(color.new(color.teal, 20), "9:30 Open Line",       group = g_col)
boLongColor     = input.color(color.lime,                "Breakout Long Label",  group = g_col)
boShortColor    = input.color(color.red,                 "Breakout Short Label", group = g_col)
retestLongColor = input.color(color.blue,                "Retest Long Label",    group = g_col)
retestShrtColor = input.color(color.orange,              "Retest Short Label",   group = g_col)
tp1Color        = input.color(color.new(color.green, 40),"TP1 Line",             group = g_col)
tp2Color        = input.color(color.new(color.green, 20),"TP2 Line",             group = g_col)

var g_style = "Line Style"
orbLineWidth  = input.int(2, "ORB Line Width",  minval = 1, maxval = 4, group = g_style)
openLineWidth = input.int(1, "Open Line Width", minval = 1, maxval = 4, group = g_style)

// ═══════════════════════════════════════════
// STATE VARIABLES
// ═══════════════════════════════════════════
var float  orbHigh      = na
var float  orbLow       = na
var float  dayOpen      = na
var bool   orbFormed    = false
var bool   tradeTaken   = false
var bool   retestArmed  = false
var string boDirection  = ""

var line lineHigh = na
var line lineLow  = na
var line lineOpen = na
var line lineTP1  = na
var line lineTP2  = na
var box  orbBox   = na

// ═══════════════════════════════════════════
// ONLY RUN ON 1-MIN CHART
// ═══════════════════════════════════════════
if timeframe.period != "1"
    runtime.error("This indicator is designed for the 1-minute chart only.")

// ═══════════════════════════════════════════
// RESET DAILY
// ═══════════════════════════════════════════
isNewDay = ta.change(time("D")) != 0

if isNewDay
    orbHigh     := na
    orbLow      := na
    dayOpen     := na
    orbFormed   := false
    tradeTaken  := false
    retestArmed := false
    boDirection := ""
    lineHigh    := na
    lineLow     := na
    lineOpen    := na
    lineTP1     := na
    lineTP2     := na
    orbBox      := na

// ═══════════════════════════════════════════
// TIME HELPERS
// ═══════════════════════════════════════════
barHour   = hour(time,   "America/New_York")
barMinute = minute(time, "America/New_York")

isORBCandle  = barHour == orbStartHour and barMinute >= orbStartMin and barMinute <= orbStartMin + 4
isORBStart   = barHour == orbStartHour and barMinute == orbStartMin
isAfterORB   = barHour > orbEndHour or (barHour == orbEndHour and barMinute > orbEndMin)
orbActive    = orbFormed and not isAfterORB

// ═══════════════════════════════════════════
// 9:30 OPEN LINE
// ═══════════════════════════════════════════
if isORBStart
    dayOpen  := open
    lineOpen := line.new(bar_index, open, bar_index, open,
                 color = openLineColor, width = openLineWidth, style = line.style_dashed)
    label.new(bar_index, open, "9hr30 open",
              color    = color.new(color.teal, 80),
              textcolor= openLineColor,
              size     = size.tiny,
              style    = label.style_label_right)

if not na(lineOpen) and not isAfterORB
    line.set_x2(lineOpen, bar_index)

// ═══════════════════════════════════════════
// BUILD ORB HIGH/LOW FROM 9:30-9:34 CANDLES
// ═══════════════════════════════════════════
if isORBCandle
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

if barHour == orbStartHour and barMinute == orbStartMin + 5 and not orbFormed and not na(orbHigh)
    orbFormed := true
    lineHigh  := line.new(bar_index, orbHigh, bar_index, orbHigh,
                  color = orbHighColor, width = orbLineWidth, style = line.style_solid)
    lineLow   := line.new(bar_index, orbLow, bar_index, orbLow,
                  color = orbLowColor, width = orbLineWidth, style = line.style_solid)
    orbBox    := box.new(bar_index, orbHigh, bar_index, orbLow,
                  border_color = color.new(orbHighColor, 60),
                  bgcolor      = orbBoxColor)

if orbActive and not na(lineHigh)
    line.set_x2(lineHigh, bar_index)
    line.set_x2(lineLow,  bar_index)
    box.set_right(orbBox, bar_index)

// ═══════════════════════════════════════════
// BREAKOUT DETECTION
// ═══════════════════════════════════════════
inTradingWindow = orbFormed and orbActive

bullBO = inTradingWindow and not tradeTaken and close > orbHigh and close[1] <= orbHigh
bearBO = inTradingWindow and not tradeTaken and close < orbLow  and close[1] >= orbLow

if bullBO
    tradeTaken  := true
    retestArmed := true
    boDirection := "long"
    label.new(bar_index, low, "BO",
              color     = boLongColor,
              textcolor = color.white,
              style     = label.style_label_up,
              size      = size.small)
    lineTP1 := line.new(bar_index, close + tp1Points, bar_index + 10, close + tp1Points,
                color = tp1Color, width = 1, style = line.style_dashed)
    lineTP2 := line.new(bar_index, close + tp2Points, bar_index + 10, close + tp2Points,
                color = tp2Color, width = 1, style = line.style_dashed)
    label.new(bar_index + 1, close + tp1Points, "TP1 +" + str.tostring(tp1Points),
              color = color.new(color.green, 60), textcolor = color.green,
              size  = size.tiny, style = label.style_label_left)
    label.new(bar_index + 1, close + tp2Points, "TP2 +" + str.tostring(tp2Points),
              color = color.new(color.green, 60), textcolor = color.green,
              size  = size.tiny, style = label.style_label_left)
    alert("ORB Bullish Breakout! Close: " + str.tostring(close), alert.freq_once_per_bar_close)

if bearBO
    tradeTaken  := true
    retestArmed := true
    boDirection := "short"
    label.new(bar_index, high, "BO",
              color     = boShortColor,
              textcolor = color.white,
              style     = label.style_label_down,
              size      = size.small)
    lineTP1 := line.new(bar_index, close - tp1Points, bar_index + 10, close - tp1Points,
                color = tp1Color, width = 1, style = line.style_dashed)
    lineTP2 := line.new(bar_index, close - tp2Points, bar_index + 10, close - tp2Points,
                color = tp2Color, width = 1, style = line.style_dashed)
    label.new(bar_index + 1, close - tp1Points, "TP1 -" + str.tostring(tp1Points),
              color = color.new(color.green, 60), textcolor = color.green,
              size  = size.tiny, style = label.style_label_left)
    label.new(bar_index + 1, close - tp2Points, "TP2 -" + str.tostring(tp2Points),
              color = color.new(color.green, 60), textcolor = color.green,
              size  = size.tiny, style = label.style_label_left)
    alert("ORB Bearish Breakout! Close: " + str.tostring(close), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════
// RETEST DETECTION
// ═══════════════════════════════════════════
retestLong  = retestArmed and boDirection == "long"  and low  <= orbHigh and low  >= orbLow
retestShort = retestArmed and boDirection == "short" and high >= orbLow  and high <= orbHigh

if retestLong
    retestArmed := false
    label.new(bar_index, low, "ORB Retest Long\n+2",
              color     = retestLongColor,
              textcolor = color.white,
              style     = label.style_label_up,
              size      = size.small)
    alert("ORB Retest Long! Price: " + str.tostring(close), alert.freq_once_per_bar_close)

if retestShort
    retestArmed := false
    label.new(bar_index, high, "ORB Retest Short\n+2",
              color     = retestShrtColor,
              textcolor = color.white,
              style     = label.style_label_down,
              size      = size.small)
    alert("ORB Retest Short! Price: " + str.tostring(close), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════
plot(orbFormed ? orbHigh : na, title = "ORB High", color = color.new(orbHighColor, 100))
plot(orbFormed ? orbLow  : na, title = "ORB Low",  color = color.new(orbLowColor,  100))
````
