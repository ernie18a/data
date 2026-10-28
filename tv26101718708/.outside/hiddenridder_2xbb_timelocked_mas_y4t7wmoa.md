# HiddenRidder - 2xBB Timelocked  + MAs

- url: https://www.tradingview.com/script/y4T7wMOA-HiddenRidder-2xBB-Timelocked-MAs/
- type: indicator
- pine_id: PUB;a30f938828da4a9391a3d562e5f62a20
- version: 1.0

## Description

## HiddenRidder - 2xBB Timelocked + MAs## 

⚠️ Disclaimer
This indicator is shared for educational purposes only. It is a technical analysis tool and does not guarantee specific win rates or financial success. Always practice strict risk management.

------------------------------
## 🔍 Overview

HiddenRidder - 2xBB Timelocked + MAs is a multi-timeframe trend architecture overlay. It projects macro volatility zones and institutional trend states directly onto lower execution timeframes. 
This setup is highly optimized for [b]0DTE options, futures trading, and swing trades[/b].

Unlike standard Bollinger Bands that track a single period, this script tracks two separate Higher Timeframe (HTF) bands simultaneously: a [b]Fast Bollinger[/b] (Length 3) and a [b]Slow Bollinger[/b] (Length 9). This allows you to monitor short-term momentum shifts and long-term structural trends from a single chart without switching timeframes.

------------------------------
## 🛠️ Core Features & Logic

* Timelocked Dual Bollinger Bands: Calculates two separate Bollinger Bands locked to a higher timeframe (e.g., Daily) using a 2x Standard Deviation multiplier.
* Fast Bollinger (Length 3): Captures immediate HTF price expansions.
* Slow Bollinger (Length 9): Establishes the macro structural boundaries.
* Dynamic Trend Basis Line: The central slow basis line changes color dynamically. It turns Green when the price trades above it and Red when the price trades below it.
* Hyper-Extension Breakout Clouds: When enabled (Fill Outside BB), the chart floods with color when the price breaks outside the slow 2SD bands.
* Bright Green Cloud: Triggers when the close price breaks above the upper outer band.
* Bright Red Cloud: Triggers when the close price breaks below the lower outer band.

------------------------------
## ⏱️ Timeframe Setup Guide

* Indicator Input Setting: Keep the Bollinger Band lock Timeframe set to Daily (D).
* Execution Chart: Open your main trading chart on the 5-Minute (5M) timeframe.
* The Interface: The wide macro bands will stretch across your fast 5M candles, acting as major institutional support and resistance maps.

------------------------------
## 🚦 The Baseline Filter ([b]The Golden Rule[/b])
To stay on the right side of the institutional trend on a fast 5M chart, use the center line color as your directional filter:

* If the center line is [b]Green[/b], focus only on Long setups.
* If the center line is [b]Red[/b], focus only on Short setups.

------------------------------
## 🎯 Trade Setups & Strategy Execution##

[b]Strategy 1[/b]: The Mean Reversion (The Snap-Back)
Best for choppy, sideways, or range-bound macro markets.

* Long Setup:
1. The 5M price drops and touches or pierces the Slow Bollinger Lower Band (Length 9).
   2. Wait for a 5M bullish reversal candle (e.g., a hammer, bullish engulfing, or long lower wick).
   3. Entry: Open of the next candle.
   4. Take Profit (TP): The dynamic central basis line.
   5. Stop Loss (SL): Just below the recent 5M swing low.
* Short Setup:
1. The 5M price rallies and touches or pierces the Slow Bollinger Upper Band (Length 9).
   2. Wait for a 5M bearish reversal candle (e.g., a shooting star, bearish engulfing, or long upper wick).
   3. Entry: Open of the next candle.
   4. Take Profit (TP): The dynamic central basis line.
   5. Stop Loss (SL): Just above the recent 5M swing high.

## [b]Strategy 2[/b]: The Hyper-Extension Breakout (Riding the Cloud)
Best for aggressive, heavy-volume momentum days.

* Long Setup:
1. A 5M candle closes completely above the Slow Bollinger Upper Band.
   2. The Bright Green Breakout Cloud floods your screen.
   3. Entry: Enter long immediately on the close of that breakout candle.
   4. Take Profit (TP): Trail using 5M swing highs, or exit when a 5M candle closes back inside the Fast Bollinger Upper Band (Length 3).
   5. Stop Loss (SL): Below the Fast Bollinger Upper Band line.
* Short Setup:
1. A 5M candle closes completely below the Slow Bollinger Lower Band.
   2. The Bright Red Breakout Cloud floods your screen.
   3. Entry: Enter short immediately on the close of that breakout candle.
   4. Take Profit (TP): Trail using 5M swing lows, or exit when a 5M candle closes back inside the Fast Bollinger Lower Band (Length 3).
   5. Stop Loss (SL): Above the Fast Bollinger Lower Band line.

------------------------------
## ⚙️ Input Settings Summary

* Bollinger Band lock Timeframe: Select your target higher timeframe (Default: D).
* Length Short: Sets the period for the Fast Bollinger band (Default: 3).
* Length Long: Sets the period for the Slow Bollinger band (Default: 9).
* Fill Outside BB: Turn this on to display the green/red hyper-extension breakout clouds.


=====================
🎁 [b]Bonus Feature[/b]: High-tier institutional EMA Ribbon (20/50/200) with custom trend-cloud formatting. It is currently set to[b] invisible by default[/b], keeping the chart clean while hiding a pro-level momentum engine just for my loyal fans.

## Source Code

````pine
//@version=6
indicator('HiddenRidder - 2xBB Timelocked  + MAs', shorttitle = 'HiddenRidder - 2xBB Timelock  + MAs ', overlay = true,max_boxes_count = 20)

// ==========================================
// 1. User Input Settings
// ==========================================

showEMA2050200Group = input(false, title = "EMA 20/50/200 Group")
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2, "Body Middle",display = display.none)

FilledOverBB = input(true, title = "Fill Outside BB")
///////////////////

group_sett = 'Basic Settings'
tf_input = input.timeframe('D', title = 'Bollinger Band lock Timeframe', group = group_sett)
len_input = input.int(3, minval = 1, title = 'Length Short', group = group_sett)
len_input2 = input.int(9, minval = 1, title = 'Length Long', group = group_sett)
src_input = input.source(close, title = 'Source', group = group_sett)

group_mult = 'Standard Deviation Multipliers'
mult2 = input.float(2.0)

group_style = 'Style Settings'
basis_col = input.color(color.red, title = 'Basis Line Color', group = group_style)
band_col = input.color(color.new(color.blue, 0), title = 'Band Base Color', group = group_style) // Base color transparency fixed at 0, adjusted below

// Lowered default transparency from 92 → 80 for better visibility
fill_transp = input.int(90, minval = 0, maxval = 100, title = 'Background Transparency (0-100)', group = group_style)

// ==========================================
// 2. Data Calculation
// ==========================================
[htf_basis, htf_dev] = request.security(syminfo.tickerid, tf_input, [ta.ema(src_input, len_input), ta.stdev(src_input, len_input)], gaps = barmerge.gaps_off)
[htf_basis2, htf_dev2] = request.security(syminfo.tickerid, tf_input, [ta.ema(src_input, len_input2), ta.stdev(src_input, len_input2)], gaps = barmerge.gaps_off)

upper2 = htf_basis + htf_dev * mult2
lower2 = htf_basis - htf_dev * mult2
upper3 = htf_basis2 + htf_dev2 * mult2
lower3 = htf_basis2 - htf_dev2 * mult2

// ==========================================
// 3. Plotting
// ==========================================
// MSavg = ta.ema(src_input, len_input)

MAdirectHTF = close > htf_basis2 ? color.green : color.red 
plot(htf_basis2,color = MAdirectHTF, title = "MA with dynamic color",linewidth = 2)

// Basis line
// plot(htf_basis, 'Basis Line', color = basis_col, linewidth = 2)

// Outer lines (fixed transparency 50 for visibility)
p_u3 = plot(upper3, 'Upper 3SD', color = color.new(band_col, 80))
p_l3 = plot(lower3, 'Lower 3SD', color = color.new(band_col, 80))
p_u2 = plot(upper2, 'Upper 2SD', color = color.new(MAdirectHTF, 50))
p_l2 = plot(lower2, 'Lower 2SD', color = color.new(MAdirectHTF, 50))

// ==========================================
// 4. Fills
// ==========================================

// 3SD (full range) – uses selected transparency
fill(p_u3, p_l3, title = '3SD Background', color = color.new(band_col, fill_transp))

// 2SD (inner range) – uses selected transparency (overlap makes it darker)
fill(p_u2, p_l2, title = '2SD Background', color = color.new(MAdirectHTF, fill_transp))
/////////////////////////////////////////////////////


Uptrendcol1 = FilledOverBB and close > (htf_basis2 + htf_dev2 * mult2) ? color.rgb(68, 187, 55, 60) : na 
Dwntrendcol1 = FilledOverBB and close < (htf_basis2 - htf_dev2 * mult2) ? color.rgb(219, 5, 5, 60) : na

fill(bodyMiddle, p_u3,   title = "Uptrend background",   color = Uptrendcol1)
fill(bodyMiddle, p_l3, title = "Downtrend background", color = Dwntrendcol1)


////////////////////////////////////////////////////

group_bonus = 'Bonus Settings'
EMASource = close
MAleng20 = input(20,title = "EMA 20",group = group_bonus)
MAleng50 = input(50,title = "EMA 50",group = group_bonus)
MAleng200 = input(200,title = "EMA 200",group = group_bonus)

EMALines2 = showEMA2050200Group
ema20 = EMALines2 ? ta.ema(src_input, MAleng20) : na
ema45 = EMALines2 ? ta.ema(src_input, MAleng50) : na
ema200 = EMALines2 ? ta.ema(src_input, MAleng200) : na
PlotM4 = plot(ema20, color = color.rgb(1, 170, 4, 0), title = "EMA 20",display = display.none)
PlotM18 = plot(ema200, color = color.rgb(4, 0, 0, 0), title = "EMA 200",display = display.none)
EM9color = ema20 > ema200 ? color.rgb(1, 170, 4, 0) : ema20 < ema200 ? color.rgb(255, 0, 0, 0):na

PlotM9 = plot(ema45, color = EM9color, title = "EMA 50")

M4918 =  ema20 > ema45 and ema45 > ema200 ? color.rgb(1, 250, 9, 90) : ema20 < ema45 and ema45 < ema200 ? color.rgb(255, 0, 0, 90) : na
fill(PlotM4,PlotM18,M4918, title = "Plot EMA 4/9/18 bgcolor")
````
