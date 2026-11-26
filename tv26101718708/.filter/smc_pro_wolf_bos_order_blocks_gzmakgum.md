# SMC PRO WOLF - BOS & Order Blocks

- url: https://www.tradingview.com/script/GzmAKGUM-SMC-PRO-WOLF-BOS-Order-Blocks/
- type: indicator
- pine_id: PUB;7f5a5dc0dccc40e2a3f886f3bbedee49
- version: 3.0

## Description

SMC PRO WOLF - High-Precision Market Structure & Order Blocks

The SMC PRO WOLF is an algorithm designed to filter out chart noise and focus purely on institutional price action. It is ideal for traders who utilize Smart Money Concepts (SMC) and need to maintain an objective, strict market reading—especially useful for managing funded accounts where precision and risk management are everything.

This indicator automatically maps market structure in real-time with no lag (non-repainting), helping you identify the institutional order flow with ease.

🔥 KEY FEATURES:

Structure Identification (BOS & CHoCH): Automatically detects Break of Structure (BOS) in the direction of the trend, and Change of Character (CHoCH) when the trend reverses.

Precise Order Block (OB) Detection: Every time a validated structural break occurs, the algorithm traces the origin of the move and draws a supply (red) or demand (green) zone. These zones are key for catching pullbacks and executing sniper entries.

Clean & Minimalist Chart: Unlike other SMC indicators that clutter your screen, the SMC PRO WOLF maintains a clean design. Order Blocks are projected forward without obstructing the visibility of the current price action.

⚙️ CUSTOMIZABLE SETTINGS:

Swing Sensitivity: Set to 5 by default. If you are a Scalper (1m, 5m), reduce it to 3 to detect micro-fractals. If you are a Swing Trader (4H, Daily), increase it to 8-10 to focus only on the macro structure.

Order Block Extension: Adjust how many candles into the future you want the liquidity zones to be projected to perfectly align with your limit orders.

Use this tool in combination with your own liquidity analysis and Premium/Discount zones to maximize your Risk:Reward ratio.

I hope this indicator takes your trading to the next level! Please drop a comment or a "Boost" if you find it valuable.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo - Modificado con Filtro Direccional Estricto

//@version=6
indicator("SMC PRO + Order Block Detector [LuxAlgo]"
  , overlay = true
  , max_boxes_count = 500
  , max_labels_count = 500
  , max_lines_count = 500)
//------------------------------------------------------------------------------
// Settings
//-----------------------------------------------------------------------------{
length = input.int(5, 'Volume Pivot Length'
  , minval = 1, group="Order Blocks [LuxAlgo]")

bull_ext_last = input.int(3, 'Bullish OB '
  , minval = 1
  , inline = 'bull', group="Order Blocks [LuxAlgo]")

bg_bull_css = input.color(color.new(#169400, 80), ''
  , inline = 'bull', group="Order Blocks [LuxAlgo]")

bull_css = input.color(#169400, ''
  , inline = 'bull', group="Order Blocks [LuxAlgo]")

bull_avg_css = input.color(color.new(#9598a1, 37), ''
  , inline = 'bull', group="Order Blocks [LuxAlgo]")

bear_ext_last = input.int(3, 'Bearish OB'
  , minval = 1
  , inline = 'bear', group="Order Blocks [LuxAlgo]")

bg_bear_css = input.color(color.new(#ff1100, 80), ''
  , inline = 'bear', group="Order Blocks [LuxAlgo]")

bear_css = input.color(#ff1100, ''
  , inline = 'bear', group="Order Blocks [LuxAlgo]")

bear_avg_css = input.color(color.new(#9598a1, 37), ''
  , inline = 'bear', group="Order Blocks [LuxAlgo]")

line_style = input.string('⎯⎯⎯', 'Average Line Style'
  , options = ['⎯⎯⎯', '----', '····'], group="Order Blocks [LuxAlgo]")

line_width = input.int(1, 'Average Line Width'
  , minval = 1, group="Order Blocks [LuxAlgo]")

mitigation = input.string('Wick', 'Mitigation Methods'
  , options = ['Wick', 'Close'], group="Order Blocks [LuxAlgo]")

smc_length = input.int(5, 'Sensibilidad Swings SMC', minval=2, tooltip="Controla qué tan rápido detecta los BOS y CHoCH.", group="Estructura SMC & Señales")

vol_length = input.int(20, 'Promedio de Volumen (SMA)', minval=5, group="Heatmap de Volumen")
vol_climax_mult = input.float(1.5, 'Multiplicador de Clímax', step=0.1, tooltip="1.5 significa que el volumen debe ser 50% mayor al promedio para pintar amarillo.", group="Heatmap de Volumen")

//-----------------------------------------------------------------------------}
// Functions 
//-----------------------------------------------------------------------------{
get_line_style(style) =>
    out = switch style
        '⎯⎯⎯'  => line.style_solid
        '----' => line.style_dashed
        '····' => line.style_dotted

get_coordinates(condition, top, btm, ob_val)=>
    var ob_top  = array.new_float(0)
    var ob_btm  = array.new_float(0)
    var ob_avg  = array.new_float(0)
    var ob_left = array.new_int(0)

    float ob = na

    if condition
        avg = math.avg(top, btm)
        array.unshift(ob_top, top)
        array.unshift(ob_btm, btm)
        array.unshift(ob_avg, avg)
        array.unshift(ob_left, time[length])
        ob := ob_val
    
    [ob_top, ob_btm, ob_avg, ob_left, ob]

remove_mitigated(ob_top, ob_btm, ob_left, ob_avg, target, bull)=>
    mitigated = false
    target_array = bull ? ob_btm : ob_top

    for element in target_array
        idx = array.indexof(target_array, element)
        if (bull ? target < element : target > element)
            mitigated := true
            array.remove(ob_top, idx)
            array.remove(ob_btm, idx)
            array.remove(ob_avg, idx)
            array.remove(ob_left, idx)
    
    mitigated

set_order_blocks(ob_top, ob_btm, ob_left, ob_avg, ext_last, bg_css, border_css, lvl_css)=>
    var ob_box = array.new_box(0)
    var ob_lvl = array.new_line(0)

    if barstate.isfirst
        for i = 0 to ext_last-1
            array.unshift(ob_box, box.new(na,na,na,na, xloc = xloc.bar_time, extend= extend.right, bgcolor = bg_css, border_color = color.new(border_css, 70)))
            array.unshift(ob_lvl, line.new(na,na,na,na, xloc = xloc.bar_time, extend = extend.right, color = lvl_css, style = get_line_style(line_style), width = line_width))

    if barstate.islast
        if array.size(ob_top) > 0
            for i = 0 to math.min(ext_last-1, array.size(ob_top)-1)
                get_box = array.get(ob_box, i)
                get_lvl = array.get(ob_lvl, i)
                box.set_lefttop(get_box, array.get(ob_left, i), array.get(ob_top, i))
                box.set_rightbottom(get_box, array.get(ob_left, i), array.get(ob_btm, i))
                line.set_xy1(get_lvl, array.get(ob_left, i), array.get(ob_avg, i))
                line.set_xy2(get_lvl, array.get(ob_left, i)+1, array.get(ob_avg, i))

//-----------------------------------------------------------------------------}
// Global elements 
//-----------------------------------------------------------------------------{
var os = 0
var target_bull = 0.
var target_bear = 0.

n = bar_index
upper = ta.highest(length)
lower = ta.lowest(length)

if mitigation == 'Close'
    target_bull := ta.lowest(close, length)
    target_bear := ta.highest(close, length)
else
    target_bull := lower
    target_bear := upper

os := high[length] > upper ? 0 : low[length] < lower ? 1 : os[1]
phv = ta.pivothigh(volume, length, length)

[bull_top, bull_btm, bull_avg, bull_left, bull_ob] = get_coordinates(not na(phv) and os == 1, hl2[length], low[length], low[length])
[bear_top, bear_btm, bear_avg, bear_left, bear_ob] = get_coordinates(not na(phv) and os == 0, high[length], hl2[length], high[length])

mitigated_bull = remove_mitigated(bull_top, bull_btm, bull_left, bull_avg, target_bull, true)
mitigated_bear = remove_mitigated(bear_top, bear_btm, bear_left, bear_avg, target_bear, false)

set_order_blocks(bull_top, bull_btm, bull_left, bull_avg, bull_ext_last, bg_bull_css, bull_css, bull_avg_css)
set_order_blocks(bear_top, bear_btm, bear_left, bear_avg, bear_ext_last, bg_bear_css, bear_css, bear_avg_css)
        
plot(bull_ob, 'Bull OB', bull_css, 2, plot.style_linebr, offset = -length, display = display.none)
plot(bear_ob, 'Bear OB', bear_css, 2, plot.style_linebr, offset = -length, display = display.none)

//-----------------------------------------------------------------------------}
// SMC Structure Logic (BOS & CHoCH)
//-----------------------------------------------------------------------------{
var int trend_smc = 0
var float lastHighSMC = na
var int lastHighBarSMC = na
var float lastLowSMC = na
var int lastLowBarSMC = na

swingHighSMC = ta.pivothigh(high, smc_length, smc_length)
swingLowSMC = ta.pivotlow(low, smc_length, smc_length)

if not na(swingHighSMC)
    lastHighSMC := swingHighSMC
    lastHighBarSMC := bar_index[smc_length]
    
if not na(swingLowSMC)
    lastLowSMC := swingLowSMC
    lastLowBarSMC := bar_index[smc_length]
    
bullishBreakSMC = ta.crossover(close, lastHighSMC)
bearishBreakSMC = ta.crossunder(close, lastLowSMC)

if bullishBreakSMC
    isBOS = (trend_smc == 1)
    line.new(lastHighBarSMC, lastHighSMC, bar_index, lastHighSMC, color=color.new(bull_css, 0), style=line.style_dashed, width=1)
    label.new(int((lastHighBarSMC + bar_index)/2), lastHighSMC, isBOS ? "BOS" : "CHoCH", color=color.new(color.white, 100), textcolor=bull_css, style=label.style_label_down, size=size.small)
    trend_smc := 1
    lastHighSMC := na
    
if bearishBreakSMC
    isBOS = (trend_smc == -1)
    line.new(lastLowBarSMC, lastLowSMC, bar_index, lastLowSMC, color=color.new(bear_css, 0), style=line.style_dashed, width=1)
    label.new(int((lastLowBarSMC + bar_index)/2), lastLowSMC, isBOS ? "BOS" : "CHoCH", color=color.new(color.white, 100), textcolor=bear_css, style=label.style_label_up, size=size.small)
    trend_smc := -1
    lastLowSMC := na

//-----------------------------------------------------------------------------}
// Buy & Sell Signals + Volume Heatmap + Filtro Direccional Estricto
//-----------------------------------------------------------------------------{
// Lógica Direccional: El cierre debe estar a favor de la operación (rechazando la zona)
candle_range = high - low
bullish_rejection = close > (low + (candle_range * 0.5)) // Cierre en la mitad superior
bearish_rejection = close < (high - (candle_range * 0.5)) // Cierre en la mitad inferior

buy_signal = mitigated_bull and close > open and bullish_rejection
sell_signal = mitigated_bear and close < open and bearish_rejection

// Cálculo de Promedios de Volumen
vol_sma = ta.sma(volume, vol_length)
vol_climax = vol_sma * vol_climax_mult

color_buy_heat = volume > vol_climax ? color.new(color.yellow, 0) : volume >= vol_sma ? color.new(bull_css, 0) : color.new(color.gray, 60)
color_sell_heat = volume > vol_climax ? color.new(color.yellow, 0) : volume >= vol_sma ? color.new(bear_css, 0) : color.new(color.gray, 60)

plotshape(buy_signal, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=bull_css, text="BUY", textcolor=color.white, size=size.normal)
plotshape(buy_signal, title="Buy Volume Heat", style=shape.circle, location=location.belowbar, color=color_buy_heat, size=size.small)

plotshape(sell_signal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=bear_css, text="SELL", textcolor=color.white, size=size.normal)
plotshape(sell_signal, title="Sell Volume Heat", style=shape.circle, location=location.abovebar, color=color_sell_heat, size=size.small)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(not na(bull_ob), 'Bullish OB Formed', 'Bullish order block detected')
alertcondition(not na(bear_ob), 'Bearish OB Formed', 'Bearish order block detected')
alertcondition(mitigated_bull, 'Bullish OB Mitigated', 'Bullish order block mitigated')
alertcondition(mitigated_bear, 'Bearish OB Mitigated', 'Bearish order block mitigated')
alertcondition(buy_signal, 'SMC Buy Signal', 'Precio rebotó fuertemente en un Bullish OB')
alertcondition(sell_signal, 'SMC Sell Signal', 'Precio fue rechazado fuertemente en un Bearish OB')
````
