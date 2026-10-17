# RSI Pivot Break System + TP/SL

- url: https://www.tradingview.com/script/3xXlsmrI-RSI-Pivot-Break-System-TP-SL/
- type: indicator
- pine_id: PUB;9a5c1f4b310f4409ab292f0f0af0fb18
- version: 1.0

## Description

█ OVERVIEW
RSI Pivot Break System + TP/SL is a technical tool that detects RSI-filtered price pivots, draws support and resistance levels, and generates breakout signals together with a complete trade setup – Stop Loss and three Take Profit levels based on Risk-Reward ratios.

The indicator combines classic pivot analysis with RSI momentum filtering. As a result, signals appear only when local highs or lows are confirmed by overbought or oversold market conditions.

Filtering pivots through RSI can also reduce the time needed to detect important pivots. Pivots forming inside Overbought/Oversold zones often represent the ending phase of local impulsive moves, which is why the default pivot length is set to a low value of 2.

After a breakout occurs, the indicator automatically creates a complete position visualization:
• entry level,
• Stop Loss,
• TP1 / TP2 / TP3,
• risk and reward zones.

█ CONCEPTS
The indicator was designed as a combination of price action, pivot analysis, and RSI momentum within a single breakout system.

Classic pivots often generate too many low-significance levels. Here, every pivot must additionally be confirmed by RSI:
• a pivot HIGH is created only when RSI is inside the overbought zone,
• a pivot LOW is created only when RSI is inside the oversold zone.
This allows the indicator to focus only on more significant local market extremes.

Pivot High and Pivot Low
Local price highs and lows detected using a specified number of candles on both sides.
• Pivot HIGH creates a potential resistance level
• Pivot LOW creates a potential support level
Once detected, the indicator automatically draws a horizontal level extended to the right.

RSI Filter
A pivot is accepted only when RSI meets a specific condition:
• for HIGH pivots → RSI ≥ overbought level
• for LOW pivots → RSI ≤ oversold level
This helps filter out many weak or random pivots.
The number of detected pivots can additionally be adjusted by modifying the Overbought/Oversold levels:
• adjusting Overbought/Oversold levels allows you to increase or decrease the number of detected pivots.

Breakout
A signal appears when a level is broken:
• breakout above resistance → BUY
• breakout below support → SELL
After the breakout, the level can either:
• remain on the chart,
or
• be automatically removed.

RSI Signal Filter
An optional additional filter can block signals during extreme RSI conditions:
• BUY signals can be blocked when RSI is too high
• SELL signals can be blocked when RSI is too low
This helps avoid entries after heavily extended moves.

TP/SL with Risk-Reward
After every signal, the indicator automatically calculates:
• entry level (close price of the breakout candle),
• Stop Loss,
• three Take Profit levels based on selected RR ratios.
SL can be calculated:
• using ATR × multiplier,
or
• as a percentage from the entry price.

█ FEATURES
1. Pivot Settings
• Pivot Length – number of candles required to confirm a pivot.
Lower values = more signals and faster pivot detection.
Higher values = stronger pivots but greater delay.

2. RSI Levels – Pivots
• RSI Overbought Level – minimum RSI level required for HIGH pivots
• RSI Oversold Level – maximum RSI level required for LOW pivots
This is the main pivot quality filter.

3. RSI Filters
Optional filter for blocking breakout signals:
• Enable signal blocking filter – enables the filter
• RSI Overbought (block BUY) – blocks BUY signals at very high RSI
• RSI Oversold (block SELL) – blocks SELL signals at very low RSI

4. Signal Settings
• Ability to select signal triangle size:
• Tiny
• Small
• Normal

5. Line Settings
• Delete broken lines after break – removes broken levels after breakout.

6. Colors
Full color customization for:
• HIGH levels,
• LOW levels,
• pivot price labels,
• BUY/SELL signals,
• line transparency.
Signal colors are also automatically synchronized with TP/SL levels and fill zones.

7. TP/SL Settings
• SL = ATR × or percentage from entry
• ATR Period
• ATR Multiplier
• SL %
• RR for TP1 / TP2 / TP3
Each TP can use its own RR multiplier.

8. TP/SL Display
Ability to individually enable:
• SL,
• TP1,
• TP2,
• TP3.

9. Position Visualization
The indicator automatically creates:
• entry line,
• SL line,
• TP lines,
• price labels,
• red risk zone,
• green reward zone.
When TP or SL is reached, all lines automatically stop extending.

█ APPLICATIONS
1. Local Structure Breakouts
The primary use of the indicator is trading breakouts of important local levels created by RSI-filtered pivots. A breakout may indicate a short-term market structure shift and the beginning of a new impulsive move in the breakout direction.
The best results usually occur when the breakout aligns with the dominant trend and is supported by increasing momentum. Before entering a position, it is worth additionally analyzing:
• the strength of the current move,
• higher timeframe trend direction,
• nearby support/resistance zones,
• available space for further price expansion.

2. Pivots as Important Market Levels
The pivots themselves can act as important reaction zones even without waiting for a breakout. Since the levels are additionally filtered by RSI, they often represent areas of local overbought or oversold market conditions.
Because of this, pivots can be used as:
• potential reaction zones,
• local support and resistance,
• profit-taking areas,
• price action and momentum observation zones.
In practice, the market often reacts to these levels multiple times before a final breakout occurs.

3. Position Management
Immediately after a signal appears, you can clearly see:
• defined risk level,
• potential RR,
• realistic targets,
• visual risk/reward relationship.

█ NOTES
• Small Pivot Length values generate more levels and more market noise.
• Large Pivot Length values create stronger levels but signals appear later.
• RSI is not used here as a classic entry oscillator, but as a pivot quality filter.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator(title = 'RSI Pivot Break System + TP/SL', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// Parameters 
pivotLength   = input.int(2, title = 'Pivot Length', minval = 1)
rsiLength     = input.int(14, title = 'RSI Length', minval = 1)

rsiOverbought = input.int(70, title = 'RSI Overbought Level (for pivots)',  group = "RSI Levels - Pivots")
rsiOversold   = input.int(30, title = 'RSI Oversold Level (for pivots)',    group = "RSI Levels - Pivots")

deleteBrokenLines = input.bool(false, "Delete broken lines after break", group = "Line Settings")

useRSIFilterOnSignals = input.bool(false, title = "Enable signal blocking filter", group = "RSI Filters")
rsiFilterOverbought = input.int(75, title = 'RSI Overbought (block BUY)', group = "RSI Filters")
rsiFilterOversold   = input.int(25, title = 'RSI Oversold (block SELL)', group = "RSI Filters")

// Signal Settings 
signalSizeStr = input.string("Tiny", title = "Signal triangle size", 
     options = ["Tiny", "Small", "Normal"], 
     group = "Signal Settings")

// Colors 
pivotTransparency  = input.int(0, title = 'Pivot line transparency (%)', minval = 0, maxval = 100, group = "Colors")
highLineColor      = input.color(color.new(color.red, 0),   title = 'High Pivot Line Color', group = "Colors")
lowLineColor       = input.color(color.new(color.green, 0), title = 'Low Pivot Line Color',  group = "Colors")
pivotPriceColor    = input.color(color.new(color.gray, 0), title = 'Pivot price level color', group = "Colors")

bullBreakColor = input.color(color.new(color.green, 0), "Bullish Break signal color", group = "Colors")
bearBreakColor = input.color(color.new(color.red, 0),   "Bearish Break signal color", group = "Colors")

// TP/SL Settings 
show_targets = input.bool(true, "Show TP/SL levels", group = "TP/SL")
use_atr_sl = input.bool(true, "SL = ATR × instead of %", group = "TP/SL")
tp_atr_period = input.int(14, "ATR period for TP/SL", minval=1, group = "TP/SL")
sl_atr_mult = input.float(1.5, "ATR multiplier for SL", step=0.1, group = "TP/SL")
sl_percent = input.float(1.0, "SL % from entry", step=0.1, group = "TP/SL")
rr_tp1 = input.float(1.0, "RR for TP1", step=0.1, group = "TP/SL")
rr_tp2 = input.float(2.0, "RR for TP2", step=0.1, group = "TP/SL")
rr_tp3 = input.float(3.0, "RR for TP3", step=0.1, group = "TP/SL")

show_sl_level = input.bool(true, "Show SL level", group = "TP/SL Display")
show_tp1_level = input.bool(true, "Show TP1 level", group = "TP/SL Display")
show_tp2_level = input.bool(true, "Show TP2 level", group = "TP/SL Display")
show_tp3_level = input.bool(true, "Show TP3 level", group = "TP/SL Display")

// ATR 
atr_for_targets = ta.atr(tp_atr_period)

// TP/SL Colors (set by the same inputs as signal colors) 
buyLabelColor  = bullBreakColor
sellLabelColor = bearBreakColor
buyColorLight  = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill        = color.new(buyLabelColor, 70)
sellFill       = color.new(sellLabelColor, 70)

// RSI 
rsi = ta.rsi(close, rsiLength)

// Pre-compute 
float maxRSI_pivot = ta.highest(rsi, pivotLength + 1)[pivotLength]
float minRSI_pivot = ta.lowest(rsi,  pivotLength + 1)[pivotLength]

// Pivot detection 
pivot_high = ta.pivothigh(high, pivotLength, pivotLength)
pivot_low  = ta.pivotlow(low,  pivotLength, pivotLength)

// Arrays 
var array<line>   pivotLines   = array.new<line>()
var array<label>  pivotLabels  = array.new<label>()
var array<float>  pivotLevels  = array.new<float>()
var array<bool>   isResistance = array.new<bool>()
var array<bool>   lineActive   = array.new<bool>()

// TP/SL Variables
var int    trade_dir     = 0
var float  sl_level      = na
var float  extreme_level = na
var line   entry_line    = na
var label  entry_label   = na
var line   sl_line       = na
var label  sl_label      = na
var line   tp1_line      = na
var label  tp1_label     = na
var line   tp2_line      = na
var label  tp2_label     = na
var line   tp3_line      = na
var label  tp3_label     = na
var line   extreme_line  = na
var linefill risk_fill   = na
var linefill reward_fill = na
var int    entry_bar     = na

// Creating pivot lines + price labels 
if not na(pivot_high)
    bool allowLine = maxRSI_pivot >= rsiOverbought
    if allowLine
        int startBar = bar_index - pivotLength
        line newLine = line.new(startBar, pivot_high, startBar + 1, pivot_high, 
             extend = extend.right, 
             color = color.new(highLineColor, pivotTransparency), 
             width = 1)
        
        label newLabel = label.new(
             x = startBar, 
             y = pivot_high, 
             text = str.tostring(pivot_high, "0.00"),
             style = label.style_label_down,
             color = na,
             textcolor = pivotPriceColor,
             size = size.normal
        )
        
        array.push(pivotLines, newLine)
        array.push(pivotLabels, newLabel)
        array.push(pivotLevels, pivot_high)
        array.push(isResistance, true)
        array.push(lineActive, true)

if not na(pivot_low)
    bool allowLine = minRSI_pivot <= rsiOversold
    if allowLine
        int startBar = bar_index - pivotLength
        line newLine = line.new(startBar, pivot_low, startBar + 1, pivot_low, 
             extend = extend.right, 
             color = color.new(lowLineColor, pivotTransparency), 
             width = 1)
        
        label newLabel = label.new(
             x = startBar, 
             y = pivot_low, 
             text = str.tostring(pivot_low, "0.00"),
             style = label.style_label_up,
             color = na,
             textcolor = pivotPriceColor,
             size = size.normal
        )
        
        array.push(pivotLines, newLine)
        array.push(pivotLabels, newLabel)
        array.push(pivotLevels, pivot_low)
        array.push(isResistance, false)
        array.push(lineActive, true)

// Break detection + signal filter 
bool bullBreakSignal = false
bool bearBreakSignal = false
var array<int> toRemove = array.new<int>()

if array.size(pivotLines) > 0
    for i = 0 to array.size(pivotLines) - 1
        if array.get(lineActive, i)
            line l = array.get(pivotLines, i)
            float lvl = array.get(pivotLevels, i)
            bool isRes = array.get(isResistance, i)
            
            bool broken = isRes ? close > lvl : close < lvl
            
            if broken
                line.set_extend(l, extend.none)
                line.set_x2(l, bar_index)
                array.set(lineActive, i, false)
                
                bool allowSignal = true
                if useRSIFilterOnSignals
                    if isRes
                        allowSignal := rsi < rsiFilterOverbought
                    else
                        allowSignal := rsi > rsiFilterOversold
                
                if allowSignal
                    if isRes
                        bullBreakSignal := true
                    else
                        bearBreakSignal := true
                
                if deleteBrokenLines
                    array.push(toRemove, i)

// Cleanup (lines + labels) 
if array.size(toRemove) > 0
    array.sort(toRemove, order.descending)
    for j = 0 to array.size(toRemove) - 1
        int idx = array.get(toRemove, j)
        line.delete(array.get(pivotLines, idx))
        label.delete(array.get(pivotLabels, idx))
        array.remove(pivotLines, idx)
        array.remove(pivotLabels, idx)
        array.remove(pivotLevels, idx)
        array.remove(isResistance, idx)
        array.remove(lineActive, idx)
    array.clear(toRemove)

// TP/SL LOGIC 
if (bullBreakSignal or bearBreakSignal) and show_targets
    // Delete previous objects
    line.delete(entry_line)
    label.delete(entry_label)
    line.delete(sl_line)
    label.delete(sl_label)
    line.delete(tp1_line)
    label.delete(tp1_label)
    line.delete(tp2_line)
    label.delete(tp2_label)
    line.delete(tp3_line)
    label.delete(tp3_label)
    line.delete(extreme_line)
    linefill.delete(risk_fill)
    linefill.delete(reward_fill)
    
    trade_dir := bullBreakSignal ? 1 : -1
    entry_bar := bar_index
    float entry_price = close
    float risk_dist = use_atr_sl ? atr_for_targets * sl_atr_mult : entry_price * (sl_percent / 100)
    
    float tp1_p = na
    float tp2_p = na
    float tp3_p = na
    
    if trade_dir == 1  // BUY
        sl_level := entry_price - risk_dist
        tp1_p := entry_price + risk_dist * rr_tp1
        tp2_p := entry_price + risk_dist * rr_tp2
        tp3_p := entry_price + risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
        
        // Lines end one bar after the current bar
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = buyLabelColor, width = 1, extend = extend.none)
        entry_label := label.new(bar_index, entry_price, "BUY " + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = buyLabelColor, textcolor = color.white, size = size.small)
        
        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none)
            sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
        
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.none)
            tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.none)
            tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none)
            tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        
        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)
        
        float max_tp_for_fill = entry_price
        if show_tp1_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp1_p)
        if show_tp2_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp2_p)
        if show_tp3_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp3_p)
        if max_tp_for_fill > entry_price
            extreme_line := line.new(bar_index, max_tp_for_fill, bar_index + 1, max_tp_for_fill, color = na, extend = extend.none)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)
    
    else  // SELL
        sl_level := entry_price + risk_dist
        tp1_p := entry_price - risk_dist * rr_tp1
        tp2_p := entry_price - risk_dist * rr_tp2
        tp3_p := entry_price - risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na
        
        // Lines end one bar after the current bar
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = sellLabelColor, width = 1, extend = extend.none)
        entry_label := label.new(bar_index, entry_price, "SELL " + str.tostring(entry_price, format.mintick), style = label.style_label_left, color = sellLabelColor, textcolor = color.white, size = size.small)
        
        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none)
            sl_label := label.new(bar_index, sl_level, "SL " + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
        
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.none)
            tp1_label := label.new(bar_index, tp1_p, "TP1 " + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.none)
            tp2_label := label.new(bar_index, tp2_p, "TP2 " + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none)
            tp3_label := label.new(bar_index, tp3_p, "TP3 " + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        
        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)
        
        float min_tp_for_fill = entry_price
        if show_tp1_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp1_p)
        if show_tp2_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp2_p)
        if show_tp3_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp3_p)
        if min_tp_for_fill < entry_price
            extreme_line := line.new(bar_index, min_tp_for_fill, bar_index + 1, min_tp_for_fill, color = na, extend = extend.none)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)

// Position update + closing on SL/TP 
if trade_dir != 0
    // Move labels to the current bar
    if not na(entry_label)
        label.set_x(entry_label, bar_index)
    if not na(sl_label)
        label.set_x(sl_label, bar_index)
    if not na(tp1_label)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_label)
        label.set_x(tp3_label, bar_index)
    
    // Lines end exactly one bar after the current bar
    if not na(entry_line)
        line.set_x2(entry_line, bar_index + 1)
    if not na(sl_line)
        line.set_x2(sl_line, bar_index + 1)
    if not na(tp1_line)
        line.set_x2(tp1_line, bar_index + 1)
    if not na(tp2_line)
        line.set_x2(tp2_line, bar_index + 1)
    if not na(tp3_line)
        line.set_x2(tp3_line, bar_index + 1)
    if not na(extreme_line)
        line.set_x2(extreme_line, bar_index + 1)
    
    bool sl_hit = false
    bool tp_hit = false
    if trade_dir == 1
        sl_hit := low <= sl_level
        tp_hit := not na(extreme_level) and high >= extreme_level
    else if trade_dir == -1
        sl_hit := high >= sl_level
        tp_hit := not na(extreme_level) and low <= extreme_level
    
    if bar_index > entry_bar and (sl_hit or tp_hit)
        line.set_extend(entry_line, extend.none)
        line.set_x2(entry_line, bar_index)
        if not na(sl_line)
            line.set_extend(sl_line, extend.none)
            line.set_x2(sl_line, bar_index)
        if not na(tp1_line)
            line.set_extend(tp1_line, extend.none)
            line.set_x2(tp1_line, bar_index)
        if not na(tp2_line)
            line.set_extend(tp2_line, extend.none)
            line.set_x2(tp2_line, bar_index)
        if not na(tp3_line)
            line.set_extend(tp3_line, extend.none)
            line.set_x2(tp3_line, bar_index)
        if not na(extreme_line)
            line.set_extend(extreme_line, extend.none)
            line.set_x2(extreme_line, bar_index)
        trade_dir := 0

// Signals – SEPARATE plotshape for each size 
plotshape(bullBreakSignal and signalSizeStr == "Tiny",   title="Bullish Pivot Break", style=shape.triangleup,   location=location.belowbar, color=bullBreakColor, size=size.tiny)
plotshape(bullBreakSignal and signalSizeStr == "Small",  title="Bullish Pivot Break", style=shape.triangleup,   location=location.belowbar, color=bullBreakColor, size=size.small)
plotshape(bullBreakSignal and signalSizeStr == "Normal", title="Bullish Pivot Break", style=shape.triangleup,   location=location.belowbar, color=bullBreakColor, size=size.normal)

plotshape(bearBreakSignal and signalSizeStr == "Tiny",   title="Bearish Pivot Break", style=shape.triangledown, location=location.abovebar,  color=bearBreakColor, size=size.tiny)
plotshape(bearBreakSignal and signalSizeStr == "Small",  title="Bearish Pivot Break", style=shape.triangledown, location=location.abovebar,  color=bearBreakColor, size=size.small)
plotshape(bearBreakSignal and signalSizeStr == "Normal", title="Bearish Pivot Break", style=shape.triangledown, location=location.abovebar,  color=bearBreakColor, size=size.normal)

alertcondition(bullBreakSignal, title = "Bullish Pivot Break", message = "Bullish Break of RSI-Filtered Resistance\nTicker: {{ticker}} | Timeframe: {{interval}} | Price: {{close}}")
alertcondition(bearBreakSignal, title = "Bearish Pivot Break", message = "Bearish Break of RSI-Filtered Support\nTicker: {{ticker}} | Timeframe: {{interval}} | Price: {{close}}")
````
