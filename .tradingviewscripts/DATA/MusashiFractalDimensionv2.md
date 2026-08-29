<!-- tradingview-pine-id: PUB;0c7b097ff0f9474dad76ac46c5df4bf0 -->
<!-- tradingviewscripts-format: 1 -->
# Musashi_Fractal_Dimension_v2

Source: https://www.tradingview.com/script/ertRXbpf-Musashi-Fractal-Dimension/

## Description

=== Musashi-Fractal-Dimension === 
This tool is part of my research on the fractal nature of the markets and understanding the relation between fractal dimension and chaos theory.

 To take full advantage of this indicator, you need to incorporate some principles and concepts: 
- Traditional Technical Analysis is linear and Euclidean, which makes very difficult its modeling.
    - Linear techniques cannot quantify non-linear behavior
    - Is it possible to measure accurately a wave or the surface of a mountain with a simple ruler?
- Fractals quantify what Euclidean Geometry can’t, they measure chaos, as they identify order in apparent randomness.
    - Remember: Chaos is order disguised as randomness.
- Chaos is the study of unstable aperiodic behavior in deterministic non-linear dynamic systems
    - Order and randomness can coexist, allowing predictability.
- There is a reason why Fractal Dimension was invented, we had no way of measuring fractal-based structures. 
    - Benoit Mandelbrot used to explain it by asking: How do we measure the coast of Great Britain?
    - An easy way of getting the need of a dimension in between is looking at the Koch snowflake.
- Market prices tend to seek natural levels of ranges of balance. These levels can be described as attractors and are determinant.

Fractal Dimension Index ('FDI') 
Determines the persistence or anti-persistence of a market.
    - A persistent market follows a market trend. An anti-persistent market results in substantial volatility around the trend (with a low r2), and is more vulnerable to price reversals
    - An easy way to see this is to think that fractal dimension measures what is in between mainstream dimensions. These are: 
        - One dimension: a line
        - Two dimensions: a square
        - Three dimensions: a cube. 
        --> This will hint you that at certain moment, if the market has a Fractal Dimension of 1.25 (which is low), the market is behaving more “line-like”, while if the market has a high Fractal Dimension, it could be interpreted as “square-like”. 
    - 'FDI' is trend agnostic, which means that doesn't consider trend. This makes it super useful as gives you clean information about the market without trying to include trend stuff.

Question:  If we have a game where you must choose between two options. 
1. a horizontal line 
2. a vertical line. 
Each iteration a Horizontal Line or a Square will appear as continuation of a figure. If it that iteration shows a square and you bet vertical you win, same as if it is horizontal and it is a line. 
    - Wouldn’t be useful to know that Fractal dimension is 1.8? This will hint square. In the markets you can use 'FD' to filter mean-reversal signals like Bollinger bands, stochastics, Regular RSI divergences, etc.
    - Wouldn’t be useful to know that Fractal dimension is 1.2? This will hint Line. In the markets you can use 'FD' to confirm trend following strategies like Moving averages, MACD, Hidden RSI divergences.

Calculation method: 
Fractal dimension is obtained from the ‘hurst exponent’.
'FDI' = 2 - 'Hurst Exponent'

 Musashi version of the Classic 'OG' Fractal Dimension Index ('FDI') 
- By default, you get 3 fast 'FDI's (11,12,13) + 1 Slow 'FDI' (21), their interaction gives useful information. 
- Fast 'FDI' cross will give you gray or red dots while Slow 'FDI' cross with the slowest of the fast 'FDI's will give white and orange dots. This are great to early spot trend beginnings or trend ends.
- A baseline (purple) is also provided, this is calculated using a 21 period Bollinger bands with 1.618 'SD', once calculated, you just take midpoint, this is the 'TDI's (Traders Dynamic Index) way. The indicator will print purple dots when Slow 'FDI' and baseline crosses, I see them as Short-Term cycle changes.
- Negative slope 'FDI' means trending asset. 
- Positive most of the times hints correction, but if it got overextended it might hint a rocket-shot.

TDI Ranges: 
- 'FDI' between 1.0≤ 'FDI' ≤1.4 will confirm trend following continuation signals.
- 'FDI' between 1.6≥ 'FDI' ≥2.0 will confirm reversal signals.
- 'FDI' == 1.5 hints a random unpredictable market.

 Fractal Attractors 
- As you must know, fractals tend orbit certain spots, this are named Attractors, this happens with any fractal behavior. The market of course also shows them, in form of Support & Resistance, Supply Demand, etc. It’s obvious they are there, but now we understand that they’re not linear, as the market is fractal, so simple trendline might not be the best tool to model this.
- I’ve noticed that when the Musashi version of the 'FDI' indicator start making a cluster of multicolor dots, this end up being an attractor, I tend to draw a rectangle as that area as price tend to come back (I still researching here).

 Extra useful stuff 
- Momentum / speed: Included by checking RSI Study in the indicator properties. This will add two RSI’s (9 and a 7 periods) plus a baseline calculated same way as explained for 'FDI'. This gives accurate short-term trends. It also includes RSI divergences (regular and hidden), deactivate with a simple check in the RSI section of the properties.
- BBWP (Bollinger Bands with Percentile): Efficient way of visualizing volatility as the percentile of Bollinger bands expansion. This line varies color from Iced blue when low volatility and magma red when high. By default, comes with the High vols deactivated for better view of 'FDI' and RSI while all studies are included. DDWP is trend agnostic, just like 'FDI', which make it very clean at providing information.
- Ultra Slow 'FDI': I noticed that while using BBWP and RSI, the indicator gets overcrowded, so there is the possibility of adding only one 'FDI' + its baseline.

Final Note:  I’ve shown you few ways of using this indicator, please backtest before using in real trading. As you know trading is more about risk and trade management than the strategy used. This still a work in progress, I really hope you find value out of it. I use it combination with a tool named “Musashi_Katana” (also found in TradingView).

Best! 
Musashi

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Musashi-Alchemist

//@version=5
indicator(title = "Musashi_Fractal_Dimension_v2", overlay = false, max_bars_back = 5000)

//===================================
// GENERAL INPUTS
//===================================
// ----------------------------------
show_fdi = input.bool(true, title = "FDI      ", group='STUDIES', inline='studies')
show_rsi = input.bool(false, title = "RSI      ", group='STUDIES', inline='studies')
show_bbwp = input.bool(false, title = "BBWP", group='STUDIES', inline='studies')
// ----------------------------------

//===================================
// FDI INPUTS
//===================================
// ----------------------------------
fdi_src    = input.source(close, title = "FDI Source        ", group='FDI - FRACTAL DIMENSION INDEX', inline='fdi_a')
fdi_length = input.int(21, title = "Slow FDI Length   ", minval = 2, group='FDI - FRACTAL DIMENSION INDEX', inline='fdi_0')
fdi_length_2 = input.int(13, title = "Fast FDIs Length 1:", minval = 2, group='FDI - FRACTAL DIMENSION INDEX', inline='fdi_1')
fdi_length_3 = input.int(12, title = "2:", minval = 2, group='FDI - FRACTAL DIMENSION INDEX', inline='fdi_1')
fdi_length_4 = input.int(11, title = "3:", minval = 2, group='FDI - FRACTAL DIMENSION INDEX', inline='fdi_1')
// ----------------------------------
bandLength = input.int(21, minval = 1, title = "Baseline Length   ", group='FDI - FRACTAL DIMENSION INDEX', inline='base_1')
// ----------------------------------
ultra_show_fdi = input.bool(false, title = "Show Ultra-Slow FDI", group='ULTRA-SLOW FDI', inline='base_0')
ultra_fdi_length = input.int(34, title = "     Length", minval = 2, group='ULTRA-SLOW FDI', inline='base_0')
// ----------------------------------
ultra_show_fdi_baseline = input.bool(false, title = "Show Baseline", group='ULTRA-SLOW FDI', inline='base_2')
ultra_bandLength = input.int(15, minval = 1, title = "          Length", group='ULTRA-SLOW FDI', inline='base_2')
// ----------------------------------

//===================================
// PLOT HORIZONTAL LINES
//===================================
// ----------------------------------
adjust_number = show_fdi or ultra_show_fdi or ultra_show_fdi_baseline ? 1 : 0
// ----------------------------------
p_scaleHi   = hline (show_bbwp or show_rsi ?  1 + adjust_number : na, 'High', color.new(#f57c00,50), hline.style_dotted )
p_scaleHi_1 = hline (show_fdi or show_bbwp or show_rsi ? 0.8 + adjust_number : na, 'Level 6', color.new(#b71c1c,50), hline.style_dotted )
p_scaleHi_2 = hline (show_fdi or show_rsi ? 0.75 + adjust_number : na,'Level 5', color.new(#b71c1c,50), hline.style_dotted )
p_scaleHi_3 = hline (show_fdi? 0.6 + adjust_number : na, 'Level 4', color.new(#b71c1c,50), hline.style_dotted )
p_midLine   = hline (show_fdi or show_bbwp or show_rsi or ultra_show_fdi or ultra_show_fdi_baseline? 0.5 + adjust_number : na, 'Mid-Line', color.new(#f57c00,42), hline.style_dashed )
p_scaleLo   = hline (show_fdi ? 0.4 + adjust_number : na, 'Level 3', color.new(#b71c1c,50), hline.style_dotted )
p_scaleLo_1 = hline (show_fdi or show_rsi ? 0.25 + adjust_number : na,'Level 2', color.new(#b71c1c,50), hline.style_dotted )
p_scaleLo_2 = hline (show_fdi or show_bbwp or show_rsi ? 0.2 + adjust_number : na, 'Level 1', color.new(#b71c1c,50), hline.style_dotted )
p_scaleLo_3 = hline (show_bbwp or show_rsi ? 0 + adjust_number : na, 'Low', color.new(#f57c00,50), hline.style_dotted )
// ----------------------------------

//===================================
// FDI CALCULATIONS
//===================================
// ----------------------------------
calculate_FDI(fdi_src, fdi_length) =>
    highest_high = ta.highest(fdi_src, fdi_length)
    lowest_low   = ta.lowest(fdi_src,  fdi_length)
    // ----------------------------------
    diff = float(0.0)
    length = float(0.0)
    for i = 1 to fdi_length - 1
        diff := (fdi_src[i] - lowest_low) / (highest_high - lowest_low)
        length := length + math.sqrt(math.pow(diff[i] - diff[i+1], 2) + (1 / math.pow(fdi_length, 2)))

    fdi = 1 + (math.log(length) + math.log(2)) / math.log(2*fdi_length)
    fdi
// ----------------------------------
fdi  = float(0.0)
fdi := calculate_FDI(fdi_src, fdi_length)
// ----------------------------------
fdi_2  = float(0.0)
fdi_2 := calculate_FDI(fdi_src, fdi_length_2)
// ----------------------------------
fdi_3  = float(0.0)
fdi_3 := calculate_FDI(fdi_src, fdi_length_3)
// ----------------------------------
fdi_4  = float(0.0)
fdi_4 := calculate_FDI(fdi_src, fdi_length_4)
// ----------------------------------
offs = (1.6185 * ta.stdev(fdi, bandLength))  
ma = ta.sma(fdi, bandLength)
// ------------------------------------
fdi_color = fdi_2 > fdi ? show_fdi ? color.new(color.silver,25) : na :  show_fdi ? color.new(#e92727, 0) : na
fdi_plot   = plot(show_fdi ? fdi : na, title = "Slow FDI", color = fdi_color, linewidth=2)
// ----------------------------------
fdi_color_2 = fdi_2 > fdi ? show_fdi ? color.new(color.silver,66) : na :  show_fdi ? color.new(#e92727, 56) : na
fdi_plot_2   = plot(show_fdi ? fdi_2 : na, title = "Fast FDI 1", color = fdi_color_2, linewidth=2)
// ----------------------------------
fdi_color_3 = fdi_3 > fdi_2 ? show_fdi ? color.new(#434651,46) : na :  show_fdi ? color.new(#e92727, 45) : na
fdi_plot_3   = plot(show_fdi ? fdi_3 : na, title = "Fast FDI 2", color = fdi_color_3, linewidth=1)
// ----------------------------------
fdi_color_4 = fdi_4 > fdi_3 ? show_fdi ? color.new(#434651,46) : na :  show_fdi ? color.new(#e92727, 62) : na
fdi_plot_4   = plot(show_fdi ? fdi_4 : na, title = "Fast FDI 3", color = fdi_color_4, linewidth=1)
// ----------------------------------
plot(show_fdi and ta.cross(fdi, fdi_2) and fdi>=fdi_2? fdi : na, title = "FDI_0 x FDI_1 ABOVE 1.5", color = color.white, linewidth = 2, style = plot.style_circles) //, title = "Slow FDI"
plot(show_fdi and ta.cross(fdi_3, fdi_2) and fdi_3<=fdi_2 and fdi_3>=1.5? fdi_2 : na, title = "FDI_1 x FDI_2 ABOVE 1.5", color = color.new(color.silver, 28), linewidth = 2, style = plot.style_circles)
plot(show_fdi and ta.cross(fdi_4, fdi_3) and fdi_4<=fdi_3 and fdi_4>=1.5? fdi_3 : na, title = "FDI_2 x FDI_3 ABOVE 1.5", color = color.new(color.silver, 36), linewidth = 2, style = plot.style_circles)
// ----------------------------------
plot(show_fdi and ta.cross(fdi, fdi_2) and fdi<=fdi_2? fdi : na, title = "FDI_0 x FDI_1 BELOW 1.4", color = #ff8919, linewidth = 2, style = plot.style_circles)
plot(show_fdi and ta.cross(fdi_3, fdi_2) and fdi_3>=fdi_2 and fdi_3<=1.4? fdi_2 : na, title = "FDI_1 x FDI_2 BELOW 1.4", color = color.new(#e92727, 28), linewidth = 2, style = plot.style_circles)
plot(show_fdi and ta.cross(fdi_4, fdi_3) and fdi_4>=fdi_3 and fdi_4<=1.4? fdi_3 : na, title = "FDI_2 x FDI_3 BELOW 1.4", color = color.new(#e92727, 36), linewidth = 2, style = plot.style_circles)
// ----------------------------------
upb = fdi + offs // Upper Bands
dnb = fdi - offs // Lower Bands
mid = ((ma + offs) + (ma - offs)) / 2

midl = plot(show_fdi ? mid : na, "FDI Baseline", color = color.new(#7e57c2, 38), linewidth = 2, style=plot.style_line)
// ----------------------------------
plot(show_fdi and ta.cross(fdi, mid) ? mid : na, color = color.new(#7e57c2, 0), title = "Primary FDI x Baseline", linewidth = 3, style = plot.style_circles) //plot.style_cross
// ----------------------------------

// ----------------------------------
// FDI - ULTRA SLOW
// ----------------------------------
ultra_fdi  = float(0.0)
ultra_fdi := calculate_FDI(fdi_src, ultra_fdi_length)
// ----------------------------------
ultra_offs = (1.6185 * ta.stdev(ultra_fdi, ultra_bandLength))  
ultra_ma = ta.sma(ultra_fdi, ultra_bandLength)
// ----------------------------------
ultra_upb = ultra_fdi + ultra_offs // Upper Bands
ultra_dnb = ultra_fdi - ultra_offs // Lower Bands
ultra_mid = ((ultra_ma + ultra_offs) + (ultra_ma - ultra_offs)) / 2
// ----------------------------------
ultra_midl = plot(ultra_show_fdi_baseline ? ultra_mid : na, "Ultra-Slow FDI Baseline", color = color.new(#5d606b, 28), linewidth = 2, style=plot.style_line)
// ----------------------------------
plot(ultra_show_fdi_baseline and ta.cross(ultra_fdi, ultra_mid) ? ultra_mid : na, color = color.new(#5d606b, 12), title = "Ultra Slow Baseline x Short Term baseline", linewidth = 3, style = plot.style_circles) //plot.style_cross
// ----------------------------------
ultra_fdi_color = ultra_show_fdi and (ultra_mid < ultra_fdi) ? color.new(color.silver,0) :  color.new(#e92727, 0)
ultra_fdi_plot   = plot(ultra_show_fdi ? ultra_fdi : na, title = "Ultra-Slow FDI", color = ultra_fdi_color, linewidth=2)
// ------------------------------------

//===================================
//=== RSI INPUTS
//===================================
// ----------------------------------
rsiPeriod = input.int(9, minval=1, title='Primary RSI Period', group='RSI - RELATIVE STERNGTH INDEX', inline='base_1')
second_rsiPeriod = input.int(7, minval=1, title='Secondary RSI Period', group='RSI - RELATIVE STERNGTH INDEX', inline='base_1')
// ----------------------------------
rsibandLength = input.int(21, minval = 1, title = "Baseline Length   ", group='RSI - RELATIVE STERNGTH INDEX', inline='base_1')
// ----------------------------------

//===================================
//=== RSI CALCULATIONS & PLOT
//===================================
// ----------------------------------
prim_rsi = ta.rsi(close, rsiPeriod)
second_rsi = ta.rsi(close, second_rsiPeriod)
// ----------------------------------
p_rsi_f = show_rsi ?  adjust_number + prim_rsi/100 : na
s_rsi_f = show_rsi ?  adjust_number + second_rsi/100 : na
// ----------------------------------
offs_rsi = (1.6185 * ta.stdev(p_rsi_f, rsibandLength))  
ma_rsi = ta.sma(p_rsi_f, rsibandLength)
// ----------------------------------
upb_rsi = p_rsi_f + offs_rsi // Upper Bands
dnb_rsi = p_rsi_f - offs_rsi // Lower Bands
mid_rsi = ((ma_rsi + offs_rsi) + (ma_rsi - offs_rsi)) / 2
// ----------------------------------
midl_rsi = plot(show_rsi ? mid_rsi : na, "RSI Baseline", color = color.new(#1848cc, 25), linewidth = 2, style=plot.style_line)
plot(show_rsi and ta.cross(p_rsi_f, mid_rsi) ? mid_rsi : na, color = color.new(#1848cc, 0) , title = "RSI x Baseline", linewidth = 3, style = plot.style_circles) //plot.style_cross
// ----------------------------------
prim_rsi_plot = plot(show_rsi ? p_rsi_f : na, 'Primary RSI', color=color.new(#3179f5, 60), linewidth=2) //#f57c00 color.white
sec_rsi_plot = plot(show_rsi ? s_rsi_f : na, 'Secondary RSI', color=color.new(#3179f5, 80), linewidth=2) //#d1d4dc
// ----------------------------------

//===================================
//=== RSI DIVERGENCES & PLOT
//===================================
// ----------------------------------
// Inputs 
lbR = input(title='Pivot Lookback Right', defval=2, group='RSI - DIVERGENCES', inline='div_1')
lbL = input(title='Pivot Lookback Left', defval=9, group='RSI - DIVERGENCES', inline='div_1')
// ----------------------------------
rangeUpper = input(title='Max of Lookback   ', defval=120, group='RSI - DIVERGENCES', inline='div_2')
rangeLower = input(title='    Min of Lookback', defval=1, group='RSI - DIVERGENCES', inline='div_2')
// ----------------------------------
plotBull = input(title='Bullish', defval=true, group='RSI - DIVERGENCES', inline='div_3')
plotBear = input(title='Bearish       ', defval=true, group='RSI - DIVERGENCES', inline='div_3')
plotHiddenBull = input(title='Hidden Bullish', defval=true, group='RSI - DIVERGENCES', inline='div_3')
plotHiddenBear = input(title='Hidden Bearish', defval=true, group='RSI - DIVERGENCES', inline='div_3')
// ----------------------------------
showLabels = input(title='Show Labels', defval=false, group='RSI - DIVERGENCES', inline='div_4')
// ----------------------------------
// Color setup
bullColor = color.new(#5b9cf6, 28)
hiddenBullColor = color.new(#5b9cf6, 25)  //orange: #ff9800
bearColor = color.new(#d32f2f, 28)  //red: #b71c1c
hiddenBearColor = color.new(#d32f2f, 25)  //gray:#9598a1 red:#d32f2f
textColor = #d1d4dc  //color.white
noneColor = color.new(color.white, 100)
// ----------------------------------
bull_line_width = 2
bear_line_width = 2
// ----------------------------------
plFound = na(ta.pivotlow(p_rsi_f, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(p_rsi_f, lbL, lbR)) ? false : true
// ----------------------------------
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper
// ----------------------------------

// ==================
// RSI DIVERGENCES
// ==================
// ----------------------------------
// Regular Bullish
// ----------------------------------
oscHL = p_rsi_f[lbR] > ta.valuewhen(plFound, p_rsi_f[lbR], 1) and _inRange(plFound[1]) // Osc: Higher Low
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1) // Price: Lower Low
bullCond = plotBull and priceLL and oscHL and plFound // Regular Bull condition
plot(plFound ? p_rsi_f[lbR] : na, offset=-lbR, title='Regular Bullish line', linewidth=2, color=show_rsi and bullCond ? bullColor : na)
plotshape(show_rsi and showLabels and bullCond ? p_rsi_f[lbR] : na, offset=-lbR, title='Regular Bullish Label', text='R', style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)
// ----------------------------------
// Hidden Bullish
// ----------------------------------
oscLL = p_rsi_f[lbR] < ta.valuewhen(plFound, p_rsi_f[lbR], 1) and _inRange(plFound[1]) // Osc: Lower Low
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1) // Price: Higher Low
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound // Hidden Bull condition
plot(plFound ? p_rsi_f[lbR] : na, offset=-lbR, title='Hidden Bullish line', linewidth=2, color=show_rsi and hiddenBullCond ? hiddenBullColor : na)
plotshape(show_rsi and showLabels and hiddenBullCond ? p_rsi_f[lbR] : na, offset=-lbR, title='Hidden Bullish Label', text=' H', style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)
// ----------------------------------
// Regular Bearish
// ----------------------------------
oscLH = p_rsi_f[lbR] < ta.valuewhen(phFound, p_rsi_f[lbR], 1) and _inRange(phFound[1]) // Osc: Lower High
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1) // Price: Higher High
bearCond = plotBear and priceHH and oscLH and phFound // Regular Bear condition
plot(phFound ? p_rsi_f[lbR] : na, offset=-lbR, title='Regular Bearish line', linewidth=2, color=show_rsi and bearCond ? bearColor : na)
plotshape(show_rsi and showLabels and bearCond ? p_rsi_f[lbR] : na, offset=-lbR, title='Regular Bearish Label', text='R', style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)
// ----------------------------------
// Hidden Bearish
// ----------------------------------
oscHH = p_rsi_f[lbR] > ta.valuewhen(phFound, p_rsi_f[lbR], 1) and _inRange(phFound[1]) // Osc: Higher High
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1) // Price: Lower High
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound // Hidden Bear condition
plot(phFound ? p_rsi_f[lbR] : na, offset=-lbR, title='Hidden Bearish line', linewidth=2, color=show_rsi and hiddenBearCond ? hiddenBearColor : na)
plotshape(show_rsi and showLabels and hiddenBearCond ? p_rsi_f[lbR] : na, offset=-lbR, title='Hidden Bearish Label', text='H', style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)
// ----------------------------------


//===================================
// BBWP
//===================================
// ----------------------------------

hide_lava = input.bool    (true, 'Hide high values', inline='4', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
// ----------------------------------


//===================================
// BBWP FUNCTIONS
//===================================
// ----------------------------------
f_maType ( _price, _len, _type ) =>
    _type == 'SMA' ? ta.sma ( _price, _len ) : _type == 'EMA' ? ta.ema ( _price, _len ) : ta.vwma ( _price, _len )
// ----------------------------------
f_bbwp ( _price, _bbwLen, _bbwpLen, _type ) =>
    float _basis = f_maType ( _price, _bbwLen, _type )
    float _dev = ta.stdev ( _price, _bbwLen )
    _bbw = ( _basis + _dev - ( _basis - _dev )) / _basis
    _bbwSum = 0.0
    _len = bar_index < _bbwpLen ? bar_index : _bbwpLen
    for _i = 1 to _len by 1
        _bbwSum += ( _bbw[_i] > _bbw ? 0 : 1 )
        _bbwSum
    _return = bar_index >= _bbwLen ? ( _bbwSum / _len) * 100 : na
    _return
// ----------------------------------
f_clrSlct ( _percent, _select, _type, _solid, _array1 ) =>
    _select == 'Solid' ? _solid : array.get (_array1, math.round ( _percent ) )
// ----------------------------------
var c_prcntSpctrm2 = array.new_color(na)
if barstate.isfirst
    array.push ( c_prcntSpctrm2, #0000FF )
    array.push ( c_prcntSpctrm2, #0200FC ), array.push ( c_prcntSpctrm2, #0500F9 ), array.push ( c_prcntSpctrm2, #0700F7 ), array.push ( c_prcntSpctrm2, #0A00F4 ), array.push ( c_prcntSpctrm2, #0C00F2 ),
    array.push ( c_prcntSpctrm2, #0F00EF ), array.push ( c_prcntSpctrm2, #1100ED ), array.push ( c_prcntSpctrm2, #1400EA ), array.push ( c_prcntSpctrm2, #1600E8 ), array.push ( c_prcntSpctrm2, #1900E5 ),
    array.push ( c_prcntSpctrm2, #1C00E2 ), array.push ( c_prcntSpctrm2, #1E00E0 ), array.push ( c_prcntSpctrm2, #2100DD ), array.push ( c_prcntSpctrm2, #2300DB ), array.push ( c_prcntSpctrm2, #2600D8 ),
    array.push ( c_prcntSpctrm2, #2800D6 ), array.push ( c_prcntSpctrm2, #2B00D3 ), array.push ( c_prcntSpctrm2, #2D00D1 ), array.push ( c_prcntSpctrm2, #3000CE ), array.push ( c_prcntSpctrm2, #3300CC ),
    array.push ( c_prcntSpctrm2, #3500C9 ), array.push ( c_prcntSpctrm2, #3800C6 ), array.push ( c_prcntSpctrm2, #3A00C4 ), array.push ( c_prcntSpctrm2, #3D00C1 ), array.push ( c_prcntSpctrm2, #3F00BF ),
    array.push ( c_prcntSpctrm2, #4200BC ), array.push ( c_prcntSpctrm2, #4400BA ), array.push ( c_prcntSpctrm2, #4700B7 ), array.push ( c_prcntSpctrm2, #4900B5 ), array.push ( c_prcntSpctrm2, #4C00B2 ),
    array.push ( c_prcntSpctrm2, #4F00AF ), array.push ( c_prcntSpctrm2, #5100AD ), array.push ( c_prcntSpctrm2, #5400AA ), array.push ( c_prcntSpctrm2, #5600A8 ), array.push ( c_prcntSpctrm2, #5900A5 ),
    array.push ( c_prcntSpctrm2, #5B00A3 ), array.push ( c_prcntSpctrm2, #5E00A0 ), array.push ( c_prcntSpctrm2, #60009E ), array.push ( c_prcntSpctrm2, #63009B ), array.push ( c_prcntSpctrm2, #660099 ),
    array.push ( c_prcntSpctrm2, #680096 ), array.push ( c_prcntSpctrm2, #6B0093 ), array.push ( c_prcntSpctrm2, #6D0091 ), array.push ( c_prcntSpctrm2, #70008E ), array.push ( c_prcntSpctrm2, #72008C ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#750089 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #770087 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #7A0084 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #7C0082 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #7F007F ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#82007C ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #84007A ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#870077 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #890075 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #8C0072 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#8E0070 ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#91006D ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #93006B ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #960068 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #990066 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#9B0063 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #9E0060 ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#A0005E ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #A3005B ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #A50059 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#A80056 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #AA0054 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #AD0051 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #AF004F ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #B2004C ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#B50049 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #B70047 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #BA0044 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #BC0042 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #BF003F ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#C1003D ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #C4003A ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#C60038 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #C90035 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #CC0033 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#CE0030 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #D1002D ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#D3002B ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #D60028 ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#D80026 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#DB0023 ), array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#DD0021 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #E0001E ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #E2001C ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #E50019 ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#E80016 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #EA0014 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #ED0011 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #EF000F ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #F2000C ),
    array.push ( c_prcntSpctrm2, hide_lava?color.new(color.white,100):#F4000A ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #F70007 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #F90005 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #FC0002 ), array.push ( c_prcntSpctrm2,hide_lava?color.new(color.white,100): #FF0000 )
// ----------------------------------
var string STM = 'Spectrum'
var string SLD = 'Solid'
// var string BGR = 'Blue Green Red'
var string BR  = 'Blue Red'
// ----------------------------------

//===================================
// BBWP INPUTS
//===================================
// ----------------------------------
i_priceSrc      = input.source  ( close, 'Price Source', group='BBWP - BOLLINGER BANDS WITH PERCENTILE', inline='bbwp_0')
i_basisType     = input.string  ( 'SMA', '     Basis Type', options=['SMA', 'EMA', 'VWMA'], group='BBWP - BOLLINGER BANDS WITH PERCENTILE', inline='bbwp_0')
i_bbwpLen       = input.int     ( 13, 'Length     ', minval=1, group='BBWP - BOLLINGER BANDS WITH PERCENTILE', inline='bbwp_1')
i_bbwpLkbk      = input.int     ( 252, '     Lookback ', minval=1, group='BBWP - BOLLINGER BANDS WITH PERCENTILE', inline='bbwp_1')
// ----------------------------------
i_c_bbwpTyped   = input.string  ( STM, 'Color Type  ', options=[STM, SLD], inline='1', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_c_spctrmType  = input.string  ( BR, '    Spectrum  ', options=[BR], inline='1', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_c_bbwpsolid   = color.new(color.silver,50)
// ----------------------------------
i_ma1On         = input.bool    ( true, '', inline='1', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_ma1Type       = input.string  ( 'SMA', 'MA 1 Type   ', options=['SMA', 'EMA', 'VWMA'], inline='1', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_ma1Len        = input.int     ( 5, '   MA 1 Length', minval=1, inline='1', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
// ----------------------------------
i_ma2Type       = input.string  ( 'SMA', 'MA 2 Type  ', options=['SMA', 'EMA', 'VWMA'], inline='2', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_ma2Len        = input.int     ( 55, '  MA 2 Length  ', minval=1, inline='2', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_ma2On         = input.bool    ( true, '', inline='2', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
// ----------------------------------
i_bbwpWidth     = input.int     ( 2, 'Line Width  ', minval=1, maxval=4, inline='3', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_alrtsOn       = input.bool    ( true, 'Highlight extreme values', inline='3', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_upperLevel    = input.int     ( 98, 'Extreme High', minval=1, inline='3', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
i_lowerLevel    = input.int     ( 2, 'Extreme Low', minval=1, inline='3', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
// ----------------------------------
// hide_lava = input.bool    (true, 'Hide high values', inline='4', group='BBWP - BOLLINGER BANDS WITH PERCENTILE')
// ----------------------------------

//===================================
// BBWP CALCULATIONS & PLOT
//===================================
// ----------------------------------
bbwp        = show_bbwp ? f_bbwp ( i_priceSrc, i_bbwpLen, i_bbwpLkbk, i_basisType ) : na
c_bbwp      = show_bbwp ? f_clrSlct ( bbwp, i_c_bbwpTyped, i_c_spctrmType, i_c_bbwpsolid, c_prcntSpctrm2 ) : na
bbwpMA1     = show_bbwp and i_ma1On ? f_maType ( bbwp, i_ma1Len, i_ma1Type ) : na
bbwpMA2     = show_bbwp and i_ma2On ? f_maType ( bbwp, i_ma2Len, i_ma2Type ) : na
// ----------------------------------
bdf = bbwp/100
bdf_calc = adjust_number + bdf
// ----------------------------------
hiAlrtBar   = i_alrtsOn and bbwp >= i_upperLevel ? bdf_calc : na
loAlrtBar   = i_alrtsOn and bbwp <= i_lowerLevel ? bdf_calc : na
// ----------------------------------
p_bbwp      = plot (show_bbwp ? bdf_calc : na, 'BBWP', c_bbwp, i_bbwpWidth, plot.style_line, editable=true )
// ----------------------------------
p_hiAlrt    = plot ( show_bbwp ? hiAlrtBar : na, 'Extreme Hi', color.new(#cb0101,85), 1, plot.style_columns, histbase=adjust_number, editable=true )
p_loAlrt    = plot ( show_bbwp ? loAlrtBar : na, 'Extreme Lo', color.new(#3000d9,60), 1, plot.style_columns, histbase=adjust_number+1, editable=true )
// ----------------------------------
````
