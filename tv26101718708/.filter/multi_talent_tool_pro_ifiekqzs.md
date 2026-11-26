# Multi Talent Tool Pro

- url: https://www.tradingview.com/script/IFiEkQzS-Multi-Talent-Tool-Pro/
- type: indicator
- pine_id: PUB;ab8820714e9242b181409e729cfbab4a
- version: 1.0

## Description

This Multi Talent Tool Pro 

Is a comprehensive, all-in-one TradingView indicator designed to streamline your technical analysis by centralizing three critical trading components into one clean, professional interface.

Key Features
Multi-EMA Suite: Includes eight customizable Exponential Moving Averages (9, 15, 20, 25, 50, 100, 200, 400). You can toggle each one on/off, change colors, and adjust line thickness directly from the settings.

Higher Timeframe (HTF) Dashboard: Provides a "Heads-Up" view of market structure by drawing the last three candles of a higher timeframe directly onto your current chart. It features a smart-tinted background that changes color based on the HTF trend (Bullish vs. Bearish) and includes a live countdown timer until the next HTF candle closes.

Automated Pattern Recognition: Identifies high-probability reversal and indecision signals, specifically Bullish/Inverted Hammers, Dojis, and Engulfing Patterns. These are plotted as clean, professional labels directly on the chart for quick visual reference.

Server-Side Alerts: Every feature is alert-enabled. You can set custom triggers for EMA crossovers, pattern detection, and HTF candle closures, ensuring you never miss a trade setup even when you aren't looking at the screen.

[b]Why It's a "Pro" Tool[/b]
Instead of cluttering your chart with multiple indicators, this tool uses garbage collection logic to ensure your screen remains clean. The HTF drawings and pattern labels are calculated to be unobtrusive, allowing you to maintain focus on your primary trading strategy while having all necessary context at your fingertips.

[b]Quick Setup Guide
[/b]
Right Margin: For the HTF candles to display clearly, right-click your price scale > Settings > Canvas > set your Right Margin to 25 or more.

Alerts: Access these by clicking the clock icon on the right sidebar. Select Multi Talent Tool Pro as the condition, and choose your preferred signal from the dropdown list.

This tool is optimized for traders who demand high-level situational awareness without the distraction of a "busy" chart.

## Source Code

````pine
//@version=6
indicator("Multi Talent Tool Pro", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =========================================================================
// 1. EMA SETTINGS & PLOTTING
// =========================================================================
grpEMA = "EMA Settings"
showEma9   = input.bool(false, "EMA 9",   group=grpEMA, inline="1")
colEma9    = input.color(color.blue, "",  group=grpEMA, inline="1")
showEma15  = input.bool(true,  "EMA 15",  group=grpEMA, inline="1")
colEma15   = input.color(color.aqua, "",  group=grpEMA, inline="1")

showEma20  = input.bool(false, "EMA 20",  group=grpEMA, inline="2")
colEma20   = input.color(color.green, "", group=grpEMA, inline="2")
showEma25  = input.bool(false, "EMA 25",  group=grpEMA, inline="2")
colEma25   = input.color(color.lime, "",  group=grpEMA, inline="2")

showEma50  = input.bool(false, "EMA 50",  group=grpEMA, inline="3")
colEma50   = input.color(color.orange,"", group=grpEMA, inline="3")
showEma100 = input.bool(false, "EMA 100", group=grpEMA, inline="3")
colEma100  = input.color(color.red, "",   group=grpEMA, inline="3")

showEma200 = input.bool(true,  "EMA 200", group=grpEMA, inline="4")
colEma200  = input.color(color.maroon,"", group=grpEMA, inline="4")
showEma400 = input.bool(false, "EMA 400", group=grpEMA, inline="4")
colEma400  = input.color(color.purple,"", group=grpEMA, inline="4")

plot(showEma9   ? ta.ema(close, 9)   : na, title="EMA 9",   color=colEma9)
plot(showEma15  ? ta.ema(close, 15)  : na, title="EMA 15",  color=colEma15)
plot(showEma20  ? ta.ema(close, 20)  : na, title="EMA 20",  color=colEma20)
plot(showEma25  ? ta.ema(close, 25)  : na, title="EMA 25",  color=colEma25)
plot(showEma50  ? ta.ema(close, 50)  : na, title="EMA 50",  color=colEma50)
plot(showEma100 ? ta.ema(close, 100) : na, title="EMA 100", color=colEma100)
plot(showEma200 ? ta.ema(close, 200) : na, title="EMA 200", color=colEma200)
plot(showEma400 ? ta.ema(close, 400) : na, title="EMA 400", color=colEma400)

// =========================================================================
// 2. CANDLESTICK PATTERNS
// =========================================================================
grpPat = "Candlestick Patterns"
showHammer    = input.bool(true, "Show Hammer Candles", group=grpPat)
showDoji      = input.bool(true, "Show Doji Candles", group=grpPat)
showEngulfing = input.bool(true, "Show Engulfing Candles", group=grpPat)

// Pattern Math (Hammers & Dojis)
bodySize  = math.abs(close - open)
rangeSize = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

// Hammer & Doji Conditions
isBullishHammer  = (lowerWick >= bodySize * 2) and (upperWick <= bodySize * 0.5) and (bodySize > 0)
isInvertedHammer = (upperWick >= bodySize * 2) and (lowerWick <= bodySize * 0.5) and (bodySize > 0)
isDoji           = (bodySize <= rangeSize * 0.05) and (rangeSize > 0)

// Engulfing Conditions
isBullEngulfing = (close[1] < open[1]) and (close > open) and (close >= open[1]) and (open <= close[1]) and ((close - open) > (open[1] - close[1]))
isBearEngulfing = (close[1] > open[1]) and (close < open) and (open >= close[1]) and (close <= open[1]) and ((open - close) > (close[1] - open[1]))

// Plotting the labels
plotshape(showHammer and isBullishHammer ? 1 : na, title="Bullish Hammer", text="H", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
plotshape(showHammer and isInvertedHammer ? 1 : na, title="Inverted Hammer", text="H", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)
plotshape(showDoji and isDoji ? 1 : na, title="Doji", text="Doji", style=shape.labelup, location=location.belowbar, color=color.new(color.gray, 20), textcolor=color.white, size=size.tiny)

plotshape(showEngulfing and isBullEngulfing ? 1 : na, title="Bullish Engulfing", text="Bull Eng", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
plotshape(showEngulfing and isBearEngulfing ? 1 : na, title="Bearish Engulfing", text="Bear Eng", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)


// =========================================================================
// 3. ALERT CONDITIONS
// =========================================================================
grpAlerts = "Alert Settings"
fastAlertEma = input.int(9, "Fast EMA for Alerts", group=grpAlerts, inline="A")
slowAlertEma = input.int(20, "Slow EMA for Alerts", group=grpAlerts, inline="A")

emaFastVal = ta.ema(close, fastAlertEma)
emaSlowVal = ta.ema(close, slowAlertEma)

// EMA Cross Alerts
alertcondition(ta.crossover(emaFastVal, emaSlowVal), title="Bullish EMA Cross", message="Bullish Cross: Fast EMA crossed ABOVE Slow EMA")
alertcondition(ta.crossunder(emaFastVal, emaSlowVal), title="Bearish EMA Cross", message="Bearish Cross: Fast EMA crossed BELOW Slow EMA")

// Pattern Alerts
alertcondition(isBullishHammer, title="Bullish Hammer Detected", message="Bullish Hammer pattern formed!")
alertcondition(isInvertedHammer, title="Inverted Hammer Detected", message="Bearish Inverted Hammer (Shooting Star) pattern formed!")
alertcondition(isDoji, title="Doji Candle Detected", message="Doji candlestick pattern formed!")
alertcondition(isBullEngulfing, title="Bullish Engulfing Detected", message="Bullish Engulfing pattern formed!")
alertcondition(isBearEngulfing, title="Bearish Engulfing Detected", message="Bearish Engulfing pattern formed!")


// =========================================================================
// 4. HTF LOGIC & INPUTS
// =========================================================================
grpHTF = "HTF Custom Candles"
showHTF     = input.bool(true, "Show HTF Candles", group=grpHTF)
offsetDist  = input.int(15, "Distance from Current Price", group=grpHTF, minval=5, maxval=50)
upColor     = input.color(color.new(color.teal, 0), "Up Candle", group=grpHTF, inline="C")
dnColor     = input.color(color.new(color.red, 0), "Down Candle", group=grpHTF, inline="C")

// Smart Tint & Label Colors
bullTint    = input.color(color.new(color.teal, 90), "Bullish Background Tint", group=grpHTF, inline="T")
bearTint    = input.color(color.new(color.red, 90), "Bearish Background Tint", group=grpHTF, inline="T")
labelBg     = input.color(color.new(color.gray, 50), "Label Background", group=grpHTF)

// Timeframe Routing strictly formatted as "simple strings"
tf1 = switch timeframe.period
    "1"  => "5"
    "3"  => "5"
    "5"  => "30"
    "15" => "60"
    => "60" 

tf2 = switch timeframe.period
    "1"  => "15"
    "3"  => "15"
    "5"  => "60"
    "15" => "D"
    => "D" 

// HTF Alerts Logic
time_tf1 = time(tf1)
time_tf2 = time(tf2)
bool htf1_closed = ta.change(time_tf1) != 0
bool htf2_closed = ta.change(time_tf2) != 0

alertcondition(htf1_closed, title="HTF 1 Candle Closed", message="HTF 1 Candle just closed!")
alertcondition(htf2_closed, title="HTF 2 Candle Closed", message="HTF 2 Candle just closed!")

// Fetch HTF Candle Data 
[t1_o0, t1_h0, t1_l0, t1_c0] = request.security(syminfo.tickerid, tf1, [open[0], high[0], low[0], close[0]], lookahead=barmerge.lookahead_on)
[t1_o1, t1_h1, t1_l1, t1_c1] = request.security(syminfo.tickerid, tf1, [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[t1_o2, t1_h2, t1_l2, t1_c2] = request.security(syminfo.tickerid, tf1, [open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)

[t2_o0, t2_h0, t2_l0, t2_c0] = request.security(syminfo.tickerid, tf2, [open[0], high[0], low[0], close[0]], lookahead=barmerge.lookahead_on)
[t2_o1, t2_h1, t2_l1, t2_c1] = request.security(syminfo.tickerid, tf2, [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[t2_o2, t2_h2, t2_l2, t2_c2] = request.security(syminfo.tickerid, tf2, [open[2], high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)

// =========================================================================
// 5. COUNTDOWN TIMER & GLOBAL DRAWING ARRAYS
// =========================================================================
f_countdown(tf_str) =>
    float c_time = na
    if tf_str == "5" or tf_str == "15" or tf_str == "30" or tf_str == "60" or tf_str == "D"
        c_time := time_close(tf_str)
    
    string res = ""
    if not na(c_time)
        float t_left = c_time - timenow
        if t_left < 0
            res := "Closed"
        else
            int h = math.floor(t_left / 3600000)
            int m = math.floor((t_left % 3600000) / 60000)
            int s = math.floor((t_left % 60000) / 1000)
            res := h > 0 ? str.tostring(h, "00") + ":" + str.tostring(m, "00") + ":" + str.tostring(s, "00") : str.tostring(m, "00") + ":" + str.tostring(s, "00")
    res

var line[]  d_lines  = array.new_line()
var box[]   d_boxes  = array.new_box()
var label[] d_labels = array.new_label()

draw_candle(int offset, float o, float h, float l, float c, string tf_name, float lowest_l) =>
    color candleCol = c >= o ? upColor : dnColor
    float top = math.max(o, c)
    float bot = math.min(o, c)
    
    // Draw Candle
    array.push(d_lines, line.new(bar_index + offset, h, bar_index + offset, l, color=candleCol, width=2))
    array.push(d_boxes, box.new(bar_index + offset - 1, top, bar_index + offset + 1, bot, border_color=candleCol, bgcolor=candleCol))
    
    // Draw Label with Countdown
    if tf_name != ""
        string time_str = f_countdown(tf_name)
        string display_name = tf_name == "D" ? "1 Day" : tf_name + " mins"
        string lbl_txt = "Time Frame\n" + display_name + (time_str != "" ? "\n" + time_str : "")
        
        array.push(d_labels, label.new(bar_index + offset, lowest_l, lbl_txt, style=label.style_label_up, color=labelBg, textcolor=color.black, size=size.small))

// =========================================================================
// 6. EXECUTE DRAWINGS ON CHART
// =========================================================================
if barstate.islast and showHTF
    // Clear old drawings
    if array.size(d_lines) > 0
        for i = 0 to array.size(d_lines) - 1
            line.delete(array.get(d_lines, i))
        array.clear(d_lines)
    if array.size(d_boxes) > 0
        for i = 0 to array.size(d_boxes) - 1
            box.delete(array.get(d_boxes, i))
        array.clear(d_boxes)
    if array.size(d_labels) > 0
        for i = 0 to array.size(d_labels) - 1
            label.delete(array.get(d_labels, i))
        array.clear(d_labels)

    // ==========================================
    // RENDER TF1
    // ==========================================
    float h1 = math.max(t1_h2, t1_h1, t1_h0)
    float l1 = math.min(t1_l2, t1_l1, t1_l0)
    float pad1 = (h1 - l1) * 0.05
    
    // Smart Tint Logic
    color bgCol1 = t1_c0 >= t1_o2 ? bullTint : bearTint
    
    array.push(d_boxes, box.new(bar_index + offsetDist - 2, h1 + pad1, bar_index + offsetDist + 10, l1 - pad1, bgcolor=bgCol1, border_color=color.new(color.gray, 50), border_style=line.style_dotted))
    
    draw_candle(offsetDist,     t1_o2, t1_h2, t1_l2, t1_c2, "", na)
    draw_candle(offsetDist + 4, t1_o1, t1_h1, t1_l1, t1_c1, "", na)
    draw_candle(offsetDist + 8, t1_o0, t1_h0, t1_l0, t1_c0, tf1, l1 - pad1)

    // ==========================================
    // RENDER TF2
    // ==========================================
    int offset2 = offsetDist + 16
    float h2 = math.max(t2_h2, t2_h1, t2_h0)
    float l2 = math.min(t2_l2, t2_l1, t2_l0)
    float pad2 = (h2 - l2) * 0.05
    
    // Smart Tint Logic
    color bgCol2 = t2_c0 >= t2_o2 ? bullTint : bearTint
    
    array.push(d_boxes, box.new(bar_index + offset2 - 2, h2 + pad2, bar_index + offset2 + 10, l2 - pad2, bgcolor=bgCol2, border_color=color.new(color.gray, 50), border_style=line.style_dotted))
    
    draw_candle(offset2,     t2_o2, t2_h2, t2_l2, t2_c2, "", na)
    draw_candle(offset2 + 4, t2_o1, t2_h1, t2_l1, t2_c1, "", na)
    draw_candle(offset2 + 8, t2_o0, t2_h0, t2_l0, t2_c0, tf2, l2 - pad2)
````
