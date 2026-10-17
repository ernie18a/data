# Dynamic FibTrend Signals [MarkitTick]

- url: https://www.tradingview.com/script/28Fhhwv1-Dynamic-FibTrend-Signals-MarkitTick/
- type: indicator
- pine_id: PUB;6d053c0667b34084824cf3e7bf73adf5
- version: 1.0

## Description

💡 This indicator represents an advanced multi-layered analytical framework designed to synchronize trend identification with structural market geometry. By integrating adaptive trend-following logic with automated price action mapping, the tool serves as a comprehensive dashboard for traders seeking to identify high-probability entry zones. It solves the common problem of "indicator clutter" by condensing volatility-adjusted trend direction, swing structure recognition, and Fibonacci retracement depth into a single, cohesive visual interface that provides real-time trade execution levels based on current market volatility.

[b]● ✨ Originality and Utility[/b]
The primary utility of this script lies in its ability to bridge the gap between momentum-based trend following and static price levels. While many scripts focus on a single aspect of technical analysis, this indicator utilizes a synergistic approach:
[list]
[*]It combines the volatility-sensitive nature of SuperTrend with the objective structural points of Pivot Highs and Lows.
[*]It automates the projection of Fibonacci retracement levels based on a dynamic lookback period, ensuring that support and defense zones are always relevant to recent price action.
[*]Unlike standard tools that leave the user to determine their own risk, this system automatically calculates a suggested entry, stop loss, and multiple target levels using Average True Range (ATR) to adjust for current market volatility.
[/list]

[b]● 🔬 Methodology and Concepts[/b]
The core engine operates on a tripartite logic system:
[list=1]
[*]Trend Quantification: The system employs an Average True Range (ATR) calculation multiplied by a specific factor to create a dynamic band around the price. This determines the prevailing bias (Bullish or Bearish) and filters out market noise.
[*]Structural Mapping: Through a pivot-point algorithm, the script identifies "Swing" levels. These are points where the market has shown significant rejection, helping to define the current trading range.
[*]Risk Geometry: Upon a trend shift (signal), the script calculates trade levels. The Entry is based on the previous bar's close, while the Stop Loss and Profit Targets are mathematically derived from the ATR. This ensures that the risk-to-reward ratio remains consistent regardless of whether the market is in a high or low-volatility state.
[/list]

[b]● 🎨 Visual Guide[/b]
The chart interface is designed for high legibility, using distinct color coding and shapes to signify different market states:
[list]
[*]SuperTrend Line: A continuous line that turns Green during bullish momentum and Red during bearish momentum. The area between this line and the price is filled with a subtle transparency to highlight the "trend cloud."
[*]Signal Arrows: Bright green "BUY" arrows appear below the bars for bullish transitions, and red "SELL" arrows appear above the bars for bearish transitions.
[*]Swing Markers: Small orange downward triangles mark Swing Highs, while blue upward triangles mark Swing Lows. These are accompanied by dashed horizontal lines projecting the price level forward.
[*]Fibonacci Grid: A series of purple dotted horizontal lines representing key retracement levels (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%). These levels provide context for potential pullbacks within the main trend.
[*]Trade Execution Box: When a signal is generated, a yellow entry box appears along with three distinct lines:
[list]
[*]Yellow Line: The specific Entry price.
[*]Green Dashed Line: The Target (Take Profit) level.
[*]Red Dashed Line: The Stop Loss level.
[/list]
[*]Info Table: A professional-grade data table in the top-right corner summarizes the current trend status, the most recent swing levels, and the active trade coordinates for quick reference.
[/list]

[b]● 📖 How to Use[/b]
[list]
[*]Trend Identification: Observe the color of the SuperTrend line. If the line is green and the price is above it, focus on long opportunities. If red, focus on shorts.
[*]Confirmation: Look for signals where the SuperTrend flip aligns with a bounce off a Fibonacci level (specifically the 50% or 61.8% "Golden Pocket").
[*]Execution: When a "BUY" or "SELL" arrow appears, refer to the yellow entry zone. The script projects these levels 40 bars into the future to allow for trade planning.
[*]Exit Strategy: Use the target line for profit-taking and the red stop-loss line for capital protection. The 2:1 risk-to-reward ratio is the default, but this can be adjusted in the settings.
[/list]

[b]● ⚙️ Inputs and Settings[/b]
[list]
[*]⚡ SuperTrend: Adjust the ATR Length and Factor. A higher factor makes the trend slower and more resilient to whipsaws, while a lower factor makes it more sensitive.
[*]🔄 Swing High / Low: Define the lookback period for pivot detection. Increasing this value will only identify major market turns.
[*]📐 Fibonacci Retracement: Change the lookback bars for the Fibonacci grid. This determines the "height" of the range being measured.
[*]🎯 Trade Levels: Set your desired Risk-to-Reward ratio (default is 2.0). You can also toggle the visibility of the entry, target, and stop lines.
[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The indicator is built upon the "Volatility Clustering" theory, which suggests that market volatility is not constant but occurs in bursts. By using ATR-based thresholds, the indicator applies a statistical filter that expands and contracts based on realized variance. The swing detection logic utilizes a "Windowed Extrema" approach, which is a fundamental concept in time-series analysis for identifying local maxima and minima within a defined temporal window. Furthermore, the integration of Fibonacci ratios (specifically the 0.618 Golden Mean) incorporates elements of fractal geometry and Elliott Wave theory, positing that market corrections often move in proportions derived from the Fibonacci sequence. The final trade execution component utilizes a fixed-fractional risk management model, ensuring that trade parameters are mathematically optimized for the current market environment rather than being based on arbitrary price distances.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
/// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator(title="Dynamic FibTrend Signals [MarkitTick]",
          overlay=true,
          max_lines_count=500,
          max_labels_count=500,
          max_boxes_count=200)


f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

// ─────────────────────────────────────────────
//  GROUP 1 ▸ SuperTrend Settings
// ─────────────────────────────────────────────
grpST       = "⚡ SuperTrend"
st_atr_len  = input.int   (10,   "ATR Length",          group=grpST)
st_factor   = input.float (3.0,  "Factor",    step=0.1, group=grpST)
st_bull_col = input.color (color.new(#00c853, 0), "Bullish Color", group=grpST)
st_bear_col = input.color (color.new(#ff1744, 0), "Bearish Color", group=grpST)
st_show     = input.bool  (true, "Show SuperTrend",     group=grpST)

// ─────────────────────────────────────────────
//  GROUP 2 ▸ Swing High / Low Settings
// ─────────────────────────────────────────────
grpSW     = "🔄 Swing High / Low"
sw_len    = input.int  (10,   "Swing Lookback",    group=grpSW, minval=2)
sw_show   = input.bool (true, "Show Swing Levels", group=grpSW)
sw_hi_col = input.color(color.new(#f57f17, 0), "Swing High Color", group=grpSW)
sw_lo_col = input.color(color.new(#1565c0, 0), "Swing Low Color",  group=grpSW)

// ─────────────────────────────────────────────
//  GROUP 3 ▸ Fibonacci Settings
// ─────────────────────────────────────────────
grpFB        = "📐 Fibonacci Retracement"
fib_show     = input.bool  (true, "Show Fibonacci Levels", group=grpFB)
fib_lookback = input.int   (50,   "Fib Lookback Bars",     group=grpFB, minval=10)
fib_col      = input.color (color.new(#9c27b0, 60), "Fib Line Color", group=grpFB)
fib_lbl_show = input.bool  (true, "Show Fib Labels",       group=grpFB)

// ─────────────────────────────────────────────
//  GROUP 4 ▸ Trade Levels (Entry / Target / SL)
// ─────────────────────────────────────────────
grpTR      = "🎯 Trade Levels"
tl_show    = input.bool  (true, "Show Trade Levels",   group=grpTR)
tl_rr      = input.float (2.0,  "Risk : Reward Ratio", group=grpTR, step=0.5, minval=0.5)
entry_col  = input.color (color.new(#ffeb3b, 0), "Entry Zone Color", group=grpTR)
target_col = input.color (color.new(#00e676, 0), "Target Color",     group=grpTR)
sl_col     = input.color (color.new(#ff5252, 0), "Stop Loss Color",  group=grpTR)

// ─────────────────────────────────────────────
//  CALCULATIONS ▸ SuperTrend
// ─────────────────────────────────────────────
[st_val, st_dir] = ta.supertrend(st_factor, st_atr_len)

// ─────────────────────────────────────────────
//  SIGNAL LOGIC 
// ─────────────────────────────────────────────
bullSignal = st_dir[1] < 0 and st_dir[2] >= 0
bearSignal = st_dir[1] > 0 and st_dir[2] <= 0

atrVal = ta.atr(14)

// ─────────────────────────────────────────────
//  PLOTS ▸ SuperTrend
// ─────────────────────────────────────────────
st_color = st_dir < 0 ? st_bull_col : st_bear_col
plot(st_show ? st_val : na, "SuperTrend",
     color=st_color, linewidth=2, style=plot.style_line)

bullFill = st_dir < 0 ? st_val : na
bearFill = st_dir > 0 ? st_val : na
p_bull = plot(st_show ? bullFill : na, display=display.none)
p_bear = plot(st_show ? bearFill : na, display=display.none)
p_cls  = plot(close,                   display=display.none)
fill(p_bull, p_cls, color=color.new(st_bull_col, 90))
fill(p_bear, p_cls, color=color.new(st_bear_col, 90))

// ─────────────────────────────────────────────
//  SIGNAL ARROWS
// ─────────────────────────────────────────────
plotshape(tl_show and bullSignal, "Buy Signal",
          shape.arrowup, location.belowbar,
          color=color.new(#00e676, 0), size=size.normal,
          text="BUY", textcolor=color.new(#00e676, 0))

plotshape(tl_show and bearSignal, "Sell Signal",
          shape.arrowdown, location.abovebar,
          color=color.new(#ff5252, 0), size=size.normal,
          text="SELL", textcolor=color.new(#ff5252, 0))

// ─────────────────────────────────────────────
//  CALCULATIONS ▸ Swing High / Low
// ─────────────────────────────────────────────
swingHigh = f_pivotHigh(high, sw_len)
swingLow  = f_pivotLow (low,  sw_len)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int   swingHighBar  = na
var int   swingLowBar   = na

if not na(swingHigh)
    lastSwingHigh := swingHigh
    swingHighBar  := bar_index - sw_len

if not na(swingLow)
    lastSwingLow := swingLow
    swingLowBar  := bar_index - sw_len

// ─────────────────────────────────────────────
//  PLOTS ▸ Swing Markers
// ─────────────────────────────────────────────
plotshape(sw_show and not na(swingHigh), "Swing High",
          shape.triangledown, location.abovebar,
          color=sw_hi_col, size=size.small, offset=-sw_len)

plotshape(sw_show and not na(swingLow), "Swing Low",
          shape.triangleup, location.belowbar,
          color=sw_lo_col, size=size.small, offset=-sw_len)

// ─────────────────────────────────────────────
//  DRAW ▸ Swing Lines + Labels 
// ─────────────────────────────────────────────
var line  lineSwHi = na
var line  lineSwLo = na
var label lblSwHi  = na
var label lblSwLo  = na

if sw_show
    line.delete(lineSwHi)
    label.delete(lblSwHi)
    if not na(lastSwingHigh)
        lineSwHi := line.new(swingHighBar, lastSwingHigh,
                             bar_index + 5, lastSwingHigh,
                             color=sw_hi_col, width=1,
                             style=line.style_dashed)
        lblSwHi  := label.new(bar_index + 5, lastSwingHigh,
                              " SH: " + str.tostring(lastSwingHigh, format.mintick),
                              color=color.new(sw_hi_col, 80),
                              textcolor=sw_hi_col,
                              style=label.style_label_left, size=size.small)

    line.delete(lineSwLo)
    label.delete(lblSwLo)
    if not na(lastSwingLow)
        lineSwLo := line.new(swingLowBar, lastSwingLow,
                             bar_index + 5, lastSwingLow,
                             color=sw_lo_col, width=1,
                             style=line.style_dashed)
        lblSwLo  := label.new(bar_index + 5, lastSwingLow,
                              " SL: " + str.tostring(lastSwingLow, format.mintick),
                              color=color.new(sw_lo_col, 80),
                              textcolor=sw_lo_col,
                              style=label.style_label_left, size=size.small)

// ─────────────────────────────────────────────
//  CALCULATIONS ▸ Fibonacci Retracement
// ─────────────────────────────────────────────
fibHigh  = ta.highest(high, fib_lookback)
fibLow   = ta.lowest (low,  fib_lookback)
fibRange = fibHigh - fibLow

var array<float>  fibLevels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
var array<string> fibNames  = array.from("0%", "23.6%", "38.2%", "50%", "61.8%", "78.6%", "100%")

var array<line>  fibLines  = array.new<line>()
var array<label> fibLabels = array.new<label>()

// ─────────────────────────────────────────────
//  DRAW ▸ Fibonacci Lines + Labels 
// ─────────────────────────────────────────────
if fib_show
    int _lsz = array.size(fibLines)
    if _lsz > 0
        for i = 0 to _lsz - 1
            line.delete(array.get(fibLines, i))
    array.clear(fibLines)

    int _lblsz = array.size(fibLabels)
    if _lblsz > 0
        for i = 0 to _lblsz - 1
            label.delete(array.get(fibLabels, i))
    array.clear(fibLabels)

    int _sz = array.size(fibLevels)
    if _sz > 0
        for i = 0 to _sz - 1
            float  lvl      = array.get(fibLevels, i)
            float  price    = fibHigh - fibRange * lvl
            string lname    = array.get(fibNames, i)
            int    lineAlpha = i == 2 or i == 4 ? 20 : 60
            color  fibLineCol = color.new(fib_col, lineAlpha)

            array.push(fibLines,
                       line.new(bar_index - fib_lookback, price,
                                bar_index + 3, price,
                                color=fibLineCol, width=1,
                                style=line.style_dotted))

            if fib_lbl_show
                array.push(fibLabels,
                           label.new(bar_index + 3, price,
                                     " " + lname + "  " + str.tostring(price, format.mintick),
                                     color=color.new(fib_col, 85),
                                     textcolor=color.new(fib_col, 0),
                                     style=label.style_label_left, size=size.tiny))

// ─────────────────────────────────────────────
//  DRAW ▸ Trade Levels — Entry / Target / SL 
// ─────────────────────────────────────────────
var line  lineEntry  = na
var line  lineTarget = na
var line  lineSL     = na
var box   entryBox   = na
var label lblTarget  = na
var label lblEntry   = na
var label lblSL      = na

var float entryPrice  = na
var float targetPrice = na
var float slPrice     = na
var bool  isBullTrade = true

if tl_show and (bullSignal or bearSignal)
    line.delete(lineEntry)
    line.delete(lineTarget)
    line.delete(lineSL)
    box.delete(entryBox)
    label.delete(lblTarget)
    label.delete(lblEntry)
    label.delete(lblSL)

    isBullTrade   := bullSignal
    entryPrice    := close[1]      
    float slDist   = atrVal * 1.5

    if isBullTrade
        slPrice     := entryPrice - slDist
        targetPrice := entryPrice + slDist * tl_rr
    else
        slPrice     := entryPrice + slDist
        targetPrice := entryPrice - slDist * tl_rr

    int endBar = bar_index + 40

    entryBox   := box.new(bar_index, entryPrice + atrVal * 0.3,
                          endBar,    entryPrice - atrVal * 0.3,
                          border_color=entry_col,
                          bgcolor=color.new(entry_col, 85))

    lineEntry  := line.new(bar_index, entryPrice,  endBar, entryPrice,
                           color=entry_col,  width=2)
    lineTarget := line.new(bar_index, targetPrice, endBar, targetPrice,
                           color=target_col, width=2, style=line.style_dashed)
    lineSL     := line.new(bar_index, slPrice,     endBar, slPrice,
                           color=sl_col,     width=2, style=line.style_dashed)

    lblTarget  := label.new(endBar, targetPrice,
                            " 🎯 TARGET  " + str.tostring(targetPrice, format.mintick),
                            color=color.new(target_col, 80), textcolor=target_col,
                            style=label.style_label_left, size=size.small)

    lblEntry   := label.new(endBar, entryPrice,
                            " ⚡ ENTRY  " + str.tostring(entryPrice, format.mintick),
                            color=color.new(entry_col, 80), textcolor=entry_col,
                            style=label.style_label_left, size=size.small)

    lblSL      := label.new(endBar, slPrice,
                            " 🛑 STOP  " + str.tostring(slPrice, format.mintick),
                            color=color.new(sl_col, 80), textcolor=sl_col,
                            style=label.style_label_left, size=size.small)

// ─────────────────────────────────────────────
//  INFO TABLE ▸ Top Right 
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 7,
                                border_width=1,
                                border_color=color.new(color.gray, 60),
                                frame_width=1,
                                frame_color=color.new(color.gray, 40))

table.cell(infoTable, 0, 0, "📊 PRO TRADING INDICATOR",
           bgcolor=color.new(#1a1a2e, 0),
           text_color=color.white,
           text_size=size.small, text_halign=text.align_center)
table.merge_cells(infoTable, 0, 0, 1, 0)

string stStatus = st_dir < 0 ? "▲ BULLISH" : "▼ BEARISH"
color  stColor  = st_dir < 0 ? st_bull_col : st_bear_col

table.cell(infoTable, 0, 1, "SuperTrend",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 1, stStatus,
           bgcolor=color.new(#16213e, 0), text_color=stColor, text_size=size.small)

table.cell(infoTable, 0, 2, "Swing High",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 2, not na(lastSwingHigh) ? str.tostring(lastSwingHigh, format.mintick) : "—",
           bgcolor=color.new(#16213e, 0), text_color=sw_hi_col, text_size=size.small)

table.cell(infoTable, 0, 3, "Swing Low",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 3, not na(lastSwingLow) ? str.tostring(lastSwingLow, format.mintick) : "—",
           bgcolor=color.new(#16213e, 0), text_color=sw_lo_col, text_size=size.small)

table.cell(infoTable, 0, 4, "Entry",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 4, not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "—",
           bgcolor=color.new(#16213e, 0), text_color=entry_col, text_size=size.small)

table.cell(infoTable, 0, 5, "Target",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 5, not na(targetPrice) ? str.tostring(targetPrice, format.mintick) : "—",
           bgcolor=color.new(#16213e, 0), text_color=target_col, text_size=size.small)

table.cell(infoTable, 0, 6, "Stop Loss",
           bgcolor=color.new(#16213e, 0), text_color=color.new(color.gray, 20), text_size=size.small)
table.cell(infoTable, 1, 6, not na(slPrice) ? str.tostring(slPrice, format.mintick) : "—",
           bgcolor=color.new(#16213e, 0), text_color=sl_col, text_size=size.small)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
if bullSignal and barstate.isconfirmed
    alert(str.format("🟢 [{0}] MTI Pro BUY — SuperTrend flipped BULLISH | Entry: {1} | TP: {2} | SL: {3} | TF: {4}",
          syminfo.tickerid,
          str.tostring(entryPrice,  format.mintick),
          str.tostring(targetPrice, format.mintick),
          str.tostring(slPrice,     format.mintick),
          timeframe.period),
          alert.freq_once_per_bar_close)

if bearSignal and barstate.isconfirmed
    alert(str.format("🔴 [{0}] MTI Pro SELL — SuperTrend flipped BEARISH | Entry: {1} | TP: {2} | SL: {3} | TF: {4}",
          syminfo.tickerid,
          str.tostring(entryPrice,  format.mintick),
          str.tostring(targetPrice, format.mintick),
          str.tostring(slPrice,     format.mintick),
          timeframe.period),
          alert.freq_once_per_bar_close)
````
