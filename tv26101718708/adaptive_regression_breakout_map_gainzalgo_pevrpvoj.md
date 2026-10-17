# Adaptive Regression Breakout Map | GainzAlgo

- url: https://www.tradingview.com/script/PEVRpvOj-Adaptive-Regression-Breakout-Map-GainzAlgo/
- type: indicator
- pine_id: PUB;3f8e071eab864e6ebeee4d0e8b2e84d0
- version: 2.0

## Description

The Adaptive Regression Breakout Map (ARBM) is an advanced volatility and trend-tracking system designed to identify periods of extreme market compression and automatically map out high-probability breakout trades.

Rather than relying on traditional lagging indicators, ARBM utilizes a continuous statistical baseline to measure market "squeezes." Once a breakout is confirmed, the indicator shifts from analysis into execution mode, drawing a dynamic visual map on your chart that outlines precise Entry, Stop Loss, and Take Profit (TP1, TP2, TP3) levels, complete with automated trailing stop logic and a live performance dashboard.

[b]How It Works[/b]

At its core, the ARBM operates on a dual-engine architecture:

[list=1]
[*] Statistical Compression (The Squeeze): The script calculates a rolling linear regression baseline and wraps it in standard deviation bands. It continuously measures the width of this channel and compares it to a historical lookback period. When the bandwidth drops into a historically low percentile, the bands change color, signaling that the market is in a "squeeze" and building energy for a move.
[*] Auto-Trendlines: Alongside the statistical bands, the script plots dynamic, auto-trendlines across recent pivot highs (cyan) and lows (magenta). These holographic lines track geometric compression and leave a visual history on the chart.
[*]The Breakout Trigger: A signal is generated when the price violently escapes either the statistical standard deviation bands or the geometric auto-trendlines while the market is in a confirmed contraction state.
[*]  Dynamic Trade Mapping: Upon a breakout, the script calculates targets based on the volatility (bandwidth) at the time of the breakout. It plots the trade directly on your chart and actively trails the stop loss as targets are hit.
[/list]

[b]The Settings and Selections[/b]

The indicator is highly customizable, divided into four primary control groups:

[i]Regression Model:[/i]

[list]
[*] Regression Length: The lookback period for the linear regression baseline.
[*] Deviation Multiplier: The width of the statistical bands (similar to Bollinger Bands).
[/list]
       
[i]Contraction Metrics:[/i]

[list]
[*]Lookback Period: How far back the script looks to determine if the current channel is historically narrow.
[*]Contraction Threshold %: The percentile the bandwidth must drop below to trigger a "squeeze" state.
[/list]

[i]Target Architecture:[/i]

https://www.tradingview.com/x/IgAtNjOw/

[list]
[*] TP1, TP2, TP3 Multipliers: Determines how far away your take profit targets are, dynamically scaled by multiplying the width of the channel at the time of the breakout.
[/list]

[b]Trendlines Overlay:[/b]

https://www.tradingview.com/x/IgAtNjOw/

[list]
[*] Show Holographic Trendlines: Toggle the geometric trendlines on or off.
[*] Pivot Length: Determines how sensitive the script is when identifying the swing highs and lows used to draw the trendlines.
[/list]

[b]How to Use It[/b]

[i]Trading with the ARBM is highly visual and systematic:[/i]

[list]
[*] Wait for the Squeeze: Watch the regression channel. When the bands turn gray, volatility has compressed, and the market is consolidating.
[*] Wait for the Signal: Look for a "Breakout, Long" or "Breakout, Short" label to appear. This confirms price has broken structure with momentum.
[*] Follow the Map: The script will immediately draw your Entry (Blue), Stop Loss (Red), and three Take Profit targets (Green dashed lines).
[*] Manage the Trade: The indicator handles trade management visually.
[/list]

[list=1]
[*] When TP1 is hit, the Stop Loss line automatically moves to your Entry price (Breakeven), and a label confirms the trail.
[*] When TP2 is hit, the Stop Loss trails to TP1.
[*] When TP2 is hit, the Stop Loss trails to TP1.
[/list]

https://www.tradingview.com/x/BMWCKcdx/
        
[list]
[*] The trade closes entirely if TP3 or the trailing stop is hit. (Note: Hitting TP1 secures a win for the system's tracking, even if the remainder is stopped out at breakeven).
[*] Monitor Performance: A stylized dashboard in the top right corner tracks the total number of signals, the historical Win Rate, and the Trade-by-Trade Sharpe Ratio, allowing you to quickly validate the settings for any given asset or timeframe.
[/list]
        
[b]Final Thoughts [/b]

The Adaptive Regression Breakout Map removes the guesswork from breakout trading. By combining continuous statistical volatility tracking with futuristic geometric trendlines, it mathematically identifies when a market is ready to move. Furthermore, by drawing the exact risk-to-reward parameters on the chart and tracking its own historical performance, it forces strict risk management and objective trade execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GainzAlgo
//    │    │     │        ██████╗  █████╗ ██╗███╗   ██╗███████╗ █████╗ ██╗      ██████╗  ██████╗
//   ┌┴┐   │    ┌┴┐      ██╔════╝ ██╔══██╗██║████╗  ██║╚══███╔╝██╔══██╗██║     ██╔════╝ ██╔═══██╗
//   │ │   │    │ │      ██║  ███╗███████║██║██╔██╗ ██║  ███╔╝ ███████║██║     ██║  ███╗██║   ██║
//   └┬┘  ┌┴┐   └┬┘      ██║   ██║██╔══██║██║██║╚██╗██║ ███╔╝  ██╔══██║██║     ██║   ██║██║   ██║
//    │   │ │    │       ██████╔╝██║  ██║██║██║ ╚████║███████╗██║  ██║███████╗╚██████╔╝╚██████╔╝
//    │   └┬┘             ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
//         │
//@version=6
indicator("Adaptive Regression Breakout Map | GainzAlgo", shorttitle="ARBM | GainzAlgo", overlay=true, max_lines_count=500, max_labels_count=500)

// UI inputs 
grp_model = "Regression Model"
length    = input.int(50, "Regression Length", group=grp_model)
devMult   = input.float(2.0, "Deviation Multiplier", group=grp_model)

grp_sqz   = "Contraction Metrics"
sqzLen    = input.int(100, "Lookback Period", group=grp_sqz)
sqzPct    = input.float(20.0, "Contraction Threshold %", group=grp_sqz)

grp_risk  = "Target Architecture"
tp1Mult   = input.float(1.0, "TP1 Multiplier (x Bandwidth)", group=grp_risk)
tp2Mult   = input.float(2.0, "TP2 Multiplier (x Bandwidth)", group=grp_risk)
tp3Mult   = input.float(3.0, "TP3 Multiplier (x Bandwidth)", group=grp_risk)

grp_trend = "Holographic Trendlines Overlay"
showTrend = input.bool(true, "Show Holographic Trendlines", group=grp_trend)
pivLen    = input.int(10, "Pivot Length", group=grp_trend)


regBasis  = ta.linreg(close, length, 0)
stdDev    = ta.stdev(close, length)
upperBand = regBasis + (stdDev * devMult)
lowerBand = regBasis - (stdDev * devMult)
bandWidth = upperBand - lowerBand
minWidth  = ta.lowest(bandWidth, sqzLen)
maxWidth  = ta.highest(bandWidth, sqzLen)
widthPct  = (bandWidth - minWidth) / math.max(maxWidth - minWidth, 0.000001) * 100
isSqueeze = widthPct <= sqzPct


var float ph1_y = na, var int ph1_x = na
var float ph2_y = na, var int ph2_x = na
var float pl1_y = na, var int pl1_x = na
var float pl2_y = na, var int pl2_x = na


var line line_ph_core  = line.new(na, na, na, na, color=color.new(#00FFFF, 0), style=line.style_solid, width=1)
var line line_ph_glow1 = line.new(na, na, na, na, color=color.new(#00FFFF, 60), style=line.style_solid, width=3)
var line line_ph_glow2 = line.new(na, na, na, na, color=color.new(#00FFFF, 85), style=line.style_solid, width=6)

var line line_pl_core  = line.new(na, na, na, na, color=color.new(#FF00FF, 0), style=line.style_solid, width=1)
var line line_pl_glow1 = line.new(na, na, na, na, color=color.new(#FF00FF, 60), style=line.style_solid, width=3)
var line line_pl_glow2 = line.new(na, na, na, na, color=color.new(#FF00FF, 85), style=line.style_solid, width=6)

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

if not na(ph)
    ph2_y := ph1_y, ph2_x := ph1_x
    ph1_y := ph, ph1_x := bar_index - pivLen
    if showTrend and not na(ph2_x)
        line.set_xy1(line_ph_core, ph2_x, ph2_y)
        line.set_xy2(line_ph_core, ph1_x, ph1_y)
        line.set_extend(line_ph_core, extend.right)
        

        line.set_xy1(line_ph_glow1, ph2_x, ph2_y)
        line.set_xy2(line_ph_glow1, ph1_x, ph1_y)
        line.set_extend(line_ph_glow1, extend.right)
        
        line.set_xy1(line_ph_glow2, ph2_x, ph2_y)
        line.set_xy2(line_ph_glow2, ph1_x, ph1_y)
        line.set_extend(line_ph_glow2, extend.right)

if not na(pl)
    pl2_y := pl1_y, pl2_x := pl1_x
    pl1_y := pl, pl1_x := bar_index - pivLen
    if showTrend and not na(pl2_x)

        line.set_xy1(line_pl_core, pl2_x, pl2_y)
        line.set_xy2(line_pl_core, pl1_x, pl1_y)
        line.set_extend(line_pl_core, extend.right)

        line.set_xy1(line_pl_glow1, pl2_x, pl2_y)
        line.set_xy2(line_pl_glow1, pl1_x, pl1_y)
        line.set_extend(line_pl_glow1, extend.right)
        
  
        line.set_xy1(line_pl_glow2, pl2_x, pl2_y)
        line.set_xy2(line_pl_glow2, pl1_x, pl1_y)
        line.set_extend(line_pl_glow2, extend.right)


bullTrigger = close > upperBand and close[1] <= upperBand[1] and isSqueeze[1]
bearTrigger = close < lowerBand and close[1] >= lowerBand[1] and isSqueeze[1]


var int   tradeDir = 0
var float entryPx  = na
var float slPx     = na
var float tp1Px    = na
var float tp2Px    = na
var float tp3Px    = na

var bool  tp1Hit   = false
var bool  tp2Hit   = false
var bool  tp3Hit   = false

var float[] tradeReturns = array.new<float>()
var int     totalTrades  = 0
var int     winTrades    = 0

var line  lineEp   = na
var line  lineSl   = na
var line  lineTp1  = na
var line  lineTp2  = na
var line  lineTp3  = na

var label lblTp1   = na
var label lblTp2   = na
var label lblTp3   = na

if tradeDir == 0
    if bullTrigger
        tradeDir := 1
        entryPx  := close
        slPx     := lowerBand[1] 
        tp1Px    := entryPx + (bandWidth[1] * tp1Mult)
        tp2Px    := entryPx + (bandWidth[1] * tp2Mult)
        tp3Px    := entryPx + (bandWidth[1] * tp3Mult)
        tp1Hit   := false
        tp2Hit   := false
        tp3Hit   := false
        
        label.new(bar_index, low, "Breakout, Long", style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=size.small)
        
    else if bearTrigger
        tradeDir := -1
        entryPx  := close
        slPx     := upperBand[1]
        tp1Px    := entryPx - (bandWidth[1] * tp1Mult)
        tp2Px    := entryPx - (bandWidth[1] * tp2Mult)
        tp3Px    := entryPx - (bandWidth[1] * tp3Mult)
        tp1Hit   := false
        tp2Hit   := false
        tp3Hit   := false

        label.new(bar_index, high, "Breakout, Short", style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.small)

    if tradeDir != 0
        lineEp  := line.new(bar_index, entryPx, bar_index + 10, entryPx, color=color.new(color.blue, 50), width=2)
        lineSl  := line.new(bar_index, slPx, bar_index + 10, slPx, color=color.new(color.red, 50), width=2)
        lineTp1 := line.new(bar_index, tp1Px, bar_index + 10, tp1Px, color=color.new(color.green, 50), style=line.style_dashed)
        lineTp2 := line.new(bar_index, tp2Px, bar_index + 10, tp2Px, color=color.new(color.green, 50), style=line.style_dashed)
        lineTp3 := line.new(bar_index, tp3Px, bar_index + 10, tp3Px, color=color.new(color.green, 50), style=line.style_dashed)
        
        lblTp1  := label.new(bar_index + 10, tp1Px, "TP1", style=label.style_none, textcolor=color.green, size=size.small)
        lblTp2  := label.new(bar_index + 10, tp2Px, "TP2", style=label.style_none, textcolor=color.green, size=size.small)
        lblTp3  := label.new(bar_index + 10, tp3Px, "TP3", style=label.style_none, textcolor=color.green, size=size.small)

if tradeDir != 0

    line.set_x2(lineEp, bar_index + 5)
    line.set_x2(lineSl, bar_index + 5)
    line.set_x2(lineTp1, bar_index + 5)
    line.set_x2(lineTp2, bar_index + 5)
    line.set_x2(lineTp3, bar_index + 5)
    
    label.set_x(lblTp1, bar_index + 5)
    label.set_x(lblTp2, bar_index + 5)
    label.set_x(lblTp3, bar_index + 5)


    bool hitSl  = (tradeDir == 1 and low <= slPx) or (tradeDir == -1 and high >= slPx)
    bool hitTp1 = (tradeDir == 1 and high >= tp1Px) or (tradeDir == -1 and low <= tp1Px)
    bool hitTp2 = (tradeDir == 1 and high >= tp2Px) or (tradeDir == -1 and low <= tp2Px)
    bool hitTp3 = (tradeDir == 1 and high >= tp3Px) or (tradeDir == -1 and low <= tp3Px)

    if hitTp1 and not tp1Hit
        tp1Hit := true
        slPx   := entryPx 
        line.set_y1(lineSl, slPx)
        line.set_y2(lineSl, slPx)
        label.new(bar_index, tradeDir == 1 ? high : low, "TP1 Hit, Set Trail stop", style=tradeDir == 1 ? label.style_label_down : label.style_label_up, color=color.blue, textcolor=color.white, size=size.small)

    if hitTp2 and not tp2Hit
        tp2Hit := true
        slPx   := tp1Px 
        line.set_y1(lineSl, slPx)
        line.set_y2(lineSl, slPx)
        label.new(bar_index, tradeDir == 1 ? high : low, "TP2 Hit", style=tradeDir == 1 ? label.style_label_down : label.style_label_up, color=color.blue, textcolor=color.white, size=size.small)

  
    if hitTp3
        tradeReturn = ((tp3Px - entryPx) / entryPx) * tradeDir * 100
        array.push(tradeReturns, tradeReturn)
        
        totalTrades += 1
        winTrades   += 1
        tradeDir    := 0 
        
        label.new(bar_index, tradeDir == 1 ? high : low, "TP3 Hit (Closed)", style=tradeDir == 1 ? label.style_label_down : label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
        
    else if hitSl
        tradeReturn = ((slPx - entryPx) / entryPx) * tradeDir * 100
        array.push(tradeReturns, tradeReturn)
        
        totalTrades += 1
        
        if tp1Hit
            winTrades += 1
            tradeDir  := 0
        else
            label.new(bar_index, tradeDir == 1 ? low : high, "Stop Loss Hit", style=tradeDir == 1 ? label.style_label_up : label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
            tradeDir  := 0

// Visuals and mapping 
bandColor = isSqueeze ? color.new(color.gray, 60) : color.new(color.navy, 80)
pUpper    = plot(upperBand, color=bandColor, title="Upper Deviation")
pLower    = plot(lowerBand, color=bandColor, title="Lower Deviation")
fill(pUpper, pLower, color=color.new(bandColor, 90), title="Regression Channel")

// Stats table 
if barstate.islast
    var tbl = table.new(position.top_right, 2, 4, bgcolor=color.new(color.navy, 10), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)
    
    float avgRet   = array.size(tradeReturns) > 0 ? array.avg(tradeReturns) : 0.0
    float stdevRet = array.size(tradeReturns) > 1 ? array.stdev(tradeReturns) : 0.0
    float sharpe   = stdevRet > 0 ? (avgRet / stdevRet) : 0.0
    float winRate  = totalTrades > 0 ? (winTrades / totalTrades) * 100 : 0.0
    
    table.cell(tbl, 0, 0, "Map Performance", text_halign=text.align_center, text_color=color.white, bgcolor=color.new(color.navy, 20))
    table.merge_cells(tbl, 0, 0, 1, 0)
    
    table.cell(tbl, 0, 1, "Total Signals", text_color=color.gray, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(totalTrades), text_color=color.white, text_halign=text.align_right)
    
    table.cell(tbl, 0, 2, "Win Rate", text_color=color.gray, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(winRate, "#.##") + "%", text_color=winRate >= 50 ? color.green : color.red, text_halign=text.align_right)
    
    table.cell(tbl, 0, 3, "Trade Sharpe", text_color=color.gray, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(sharpe, "#.##"), text_color=sharpe >= 1 ? color.green : color.white, text_halign=text.align_right)
````
