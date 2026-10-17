# EMA 20/50 with Target Price [SS]

- url: https://www.tradingview.com/script/Gr83NrPt-EMA-20-50-with-Target-Price-SS/
- type: indicator
- pine_id: PUB;240da1874f7e49ada41373effdfc7aa2
- version: 1.0

## Description

Same like ema 9/21 with target price but the values are edited/modified as 20/50. Hope this works for your trading charts also.

## Source Code

````pine
//  /$$$$$$   /$$                                                         /$$                                            
// /$$__  $$ | $$                                                        | $$                                            
//| $$  \__//$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$$
//|  $$$$$$|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$__  $$ /$$_____/|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$_____/
// \____  $$ | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$| $$  \__/|  $$$$$$   | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$|  $$$$$$ 
// /$$  \ $$ | $$ /$$| $$_____/  \  $$$/ | $$_____/| $$       \____  $$  | $$ /$$| $$_____/  \  $$$/ | $$_____/ \____  $$
//|  $$$$$$/ |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$| $$       /$$$$$$$/  |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$ /$$$$$$$/
// \______/   \___/   \_______/    \_/    \_______/|__/      |_______/    \___/   \_______/    \_/    \_______/|_______/ 

//       ___________________
//      /                   \
//     /  _____        _____ \
//    /  /     \      /     \  \
// __/__/       \____/       \__\_____
//|           ___________           ____|
// \_________/           \_________/
//            \  /////// /
//             \/////////
// © Steversteves
//@version=5
indicator("EMA 20/50 with Target Price [SS]", overlay=true)

arraylookback =     input.float(500, "ATR Lookback Length")
showlbls =          input.bool(true, "Show Target Price Labels")



ema20 = ta.ema(close, 20) 
ema50 = ta.ema(close, 50) 

// determine the crossover points
ema20_cross_ema50 = ta.crossover(ema20, ema50)
ema50_cross_ema20 = ta.crossover(ema50, ema20)

// plot arrows on the chart at the crossover points
plotshape(ema20_cross_ema50 ? close : na, title="Up Arrow", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.green)
plotshape(ema50_cross_ema20 ? close : na, title="Down Arrow", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.red)

// sentiment 

bool bullish = close >= ema20 and close >= ema50 
bool bearish = close <= ema20 and close <= ema50 
bool neutral = close < ema20 and close > ema50 

// define colours 

bull =          color.new(color.lime, 50)
bear =          color.new(color.red, 50) 
white =         color.white 
neutralcolor = color.new(color.gray, 50) 

crossovercolor = color.new(color.purple, 75)
crossundercolor = color.new(color.orange, 75) 

color pallette = bullish ? bull : bearish ? bear : neutralcolor
color emacolor = ema20_cross_ema50 ? crossovercolor : ema50_cross_ema20 ? crossundercolor : pallette 

filla = plot(ema20, color=emacolor, linewidth=1) 
fillb = plot(ema50, color=emacolor, linewidth=1)

fill(filla, fillb, color=pallette)

bool above_ema = close >= ema20 and close >= ema50 
bool below_ema = close < ema20 and close <= ema50 
bool crossover = ema20_cross_ema50 
bool crossunder = ema50_cross_ema20 

bull_a = array.new_float() 
open_a = array.new_float() 
crossover_a = array.new_float() 
crossunder_a = array.new_float() 
bear_a = array.new_float() 


for i = 0 to arraylookback 
    if above_ema[i] 
        array.push(bull_a, close[i]) 
    if crossover[i] 
        array.push(crossover_a, close[i])
        array.push(open_a, open[i]) 
    if below_ema[i] 
        array.push(bear_a, close[i]) 
    if crossunder[i] 
        array.push(crossunder_a, close[i]) 

    
max_above = array.max(bull_a) 
crossover_avg = array.avg(crossover_a) 
max_below = array.min(bear_a) 
crossunder_avg = array.avg(crossunder_a) 

bull_dif1 = (max_above - crossover_avg) / 2 
bull_dif2 = (max_above - crossover_avg) 
bear_dif1 = (crossunder_avg - max_below) / 2 
bear_dif2 = (crossunder_avg - max_below) 

float op = 0.0 
float bull_tgt = 0.0 
float bull_tgt_2 = 0.0 
float bear_tgt = 0.0 
float bear_tgt_2 = 0.0 
var label bull_tgt_1_lbl = na 
var label bull_tgt_2_lbl = na 
var label bear_tgt_1_lbl = na 
var label bear_tgt_2_lbl = na 
var line bull_tgt_lin = na
var line bull_tgt_lin_2 = na 
var line bear_tgt_lin = na 
var line bear_tgt_lin_2 = na 

if crossover 
    if array.size(open_a) > 0
        op := array.get(open_a, 0) 
    bull_tgt := op + bull_dif1
    bull_tgt_2 := op + bull_dif2  
if crossunder 
    if array.size(open_a) > 0 
        op := array.get(open_a, 0) 
    bear_tgt := op - bear_dif1 
    bear_tgt_2 := op - bear_dif2 

  
if crossover and barstate.isconfirmed
    line.delete(bull_tgt_lin) 
    line.delete(bull_tgt_lin_2) 
    label.delete(bull_tgt_1_lbl)
    label.delete(bull_tgt_2_lbl) 
    bull_tgt_lin := line.new(bar_index[1], y1 = bull_tgt, x2= bar_index, y2 = bull_tgt, extend = extend.right, color = bull, width=3)
    bull_tgt_lin_2 := line.new(bar_index[1], y1 = bull_tgt_2, x2= bar_index, y2 = bull_tgt_2, extend = extend.right, color = bull, width=3)
    if showlbls 
        bull_tgt_1_lbl := label.new(bar_index[1], y = bull_tgt, text = "Bull Target 1 \n" + str.tostring(math.round(bull_tgt,2)), color = bull, textcolor = white)
        bull_tgt_2_lbl := label.new(bar_index[1], y = bull_tgt_2, text = "Bull Target 2 \n" + str.tostring(math.round(bull_tgt_2,2)), color = bull, textcolor = white)

if crossunder and barstate.isconfirmed
    line.delete(bear_tgt_lin) 
    line.delete(bear_tgt_lin_2)
    label.delete(bear_tgt_1_lbl) 
    label.delete(bear_tgt_2_lbl) 
    bear_tgt_lin := line.new(bar_index[1], y1 = bear_tgt, x2= bar_index, y2 = bear_tgt, extend = extend.right, color = bear, width=3) 
    bear_tgt_lin_2 := line.new(bar_index[1], y1 = bear_tgt_2, x2= bar_index, y2 = bear_tgt_2, extend = extend.right, color = bear, width=3)
    if showlbls  
        bear_tgt_1_lbl := label.new(bar_index[1], y = bear_tgt, text = "Bear Target 1 \n" + str.tostring(math.round(bear_tgt,2)), color = bear, style=label.style_label_up, textcolor = white)
        bear_tgt_2_lbl := label.new(bar_index[1], y = bear_tgt_2, text = "Bear Target 2 \n" + str.tostring(math.round(bear_tgt_2,2)), color = bear, style=label.style_label_up, textcolor = white)




alertcondition(crossover, "EMA 20/50 Crossover", "Bullish Cross") 
alertcondition(crossunder, "EMA 20/50 Crossunder", "Bearish Cross")
````
