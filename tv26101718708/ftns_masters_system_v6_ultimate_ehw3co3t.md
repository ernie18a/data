# FTNS Masters System v6 Ultimate

- url: https://www.tradingview.com/script/eHw3CO3T/
- type: indicator
- pine_id: PUB;9e88ad92b0b74cef96b1c676c31d7794
- version: 1.0

## Description

FTNS Masters System v6 Ultimate

[b][Description][/b]
This indicator is the ultimate hybrid trading system designed for active day traders. It seamlessly integrates the core mechanics of the FTNS Strategy (Phase, Direction, Volume, and Momentum) with the highly acclaimed visual elements and indicators from the THV System.

Equipped with a built-in multi-vector matrix and an elegant HUD dashboard, this script eliminates screen clutter by consolidating multiple separate indicators into a single, cohesive overlay script. It also features a dual-mode engine, allowing you to switch between conservative Trend Following and aggressive Counter-Trend trading setups with a single click.

[b]Key Features & Components:[/b]
[b]Multi-EMA Phase Recognition[/b]
Tracks market structure using 4 specific Moving Averages (62 EMA, 144 EMA, 200 SMA, 800 SMA) to instantly classify the environment into an Up-Trend (Bull), Down-Trend (Bear), or Sideways Range.

[b]Heiken Ashi Smoothed (Direction)[/b]
Filters out market noise using a double-smoothed calculation (SMMA followed by LWMA). It replaces standard candles to give you a clear, unpolluted view of the immediate market direction.

[b]Better Volume Spike Detection[/b]
Monitors volume activity to catch institutional spikes. The system requires an influx of volume (configurable multiplier) to validate high-probability setups.

[b]ADX Momentum Filter[/b]
Ensures that you never jump into a stagnant market. Signals are filtered by Average Directional Index (ADX) criteria to guarantee strong momentum is present at the time of the cross.

[b]Integrated THV Trix Oscillator Status[/b]
Incorporates the essence of the THV System's famous Trix indicators (triple-smoothed EMAs). Instead of taking up extra sub-window space, the fast/slow Trix crossover status is calculated in the background and displayed in the HUD.

[b]Auto Pivot Lines (Targets & Key Levels)[/b]
Automatically calculates and draws daily Pivot Points (P, R1, R2, S1, S2) using a clean step-line style. These serve as institutional price magnets, primary profit targets, and key rejection levels.

[b]Two Dedicated Trading Modes:[/b]
You can toggle the system behavior instantly via the settings menu:

[b]Trend Follow Mode (Default): [/b]Generates high-probability breakout and continuation signals (Solid Triangles) when the major MA phase, Heiken Ashi color change, ADX direction, and a recent volume spike completely align.

[b]Counter Trend Mode (Advanced): [/b]Designed for range-bound markets or fading overextended trend exhausts. It flags sharp reversal entry points (Hollow Arrows) when the price tests daily Pivot support/resistance lines (R1/R2/S1/S2) simultaneously with a Heiken Ashi color flip and a THV Trix momentum turn.

[b]Real-Time HUD Dashboard:[/b]
The compact, semi-transparent table on the top-right corner tracks all 5 dimensions of the market condition concurrently:

Selected Mode: Displays whether you are looking for TREND or COUNTER setups.

MA Phase: Displays BULL, BEAR, or RANGE.

Heiken Ashi: Displays immediate trend color status (UP / DOWN).

Better Vol: Warns you with a "SPIKE!" notification when unusual volume enters.

ADX Force: Shows if directional momentum is sufficiently strong.

THV Trix: Displays the background Trix oscillator crossover direction.

[b]Dynamic Alert Conditions Included:[/b]
Fully optimized for automated notifications. You can easily set up alerts for:

Trend Follow Buy / Sell Signals

Counter Trend Support / Resistance Reversals

[b]Disclaimer: [/b]This script is published for educational and analysis purposes only. Past performance is not indicative of future results. Trading foreign exchange and financial instruments involves significant risk. Always practice strict risk management.

## Source Code

````pine
//@version=6
indicator("FTNS Masters System v6 Ultimate (THV Full Custom)", overlay=true, max_labels_count=500, max_boxes_count=500)

// ==========================================
// Input Settings
// ==========================================
gp_mode = "★ System Mode Settings"
trade_mode = input.string("Trend Follow", title="Current Trade Mode", options=["Trend Follow", "Counter Trend"], group=gp_mode)

gp_ma  = "1. Phase Recognition (MA)"
ma62_len  = input.int(62,  title="EMA 62 Length", group=gp_ma)
ma144_len = input.int(144, title="EMA 144 Length", group=gp_ma)
ma200_len = input.int(200, title="SMA 200 Length", group=gp_ma)
ma800_len = input.int(800, title="SMA 800 Length", group=gp_ma)

gp_ha  = "2. Direction (Heiken Ashi Smoothed)"
ha_p1  = input.int(6, title="1st Smoothing Length (SMMA)", group=gp_ha)
ha_p2  = input.int(2, title="2nd Smoothing Length (LWMA)", group=gp_ha)

gp_vol = "3. Volume (Better Volume)"
vol_len = input.int(20, title="Volume Avg Length", group=gp_vol)
vol_mult = input.float(1.5, title="Volume Spike Threshold (Mult)", group=gp_vol)

gp_adx = "4. Momentum (ADX Crossing)"
adx_len = input.int(14, title="ADX Length", group=gp_adx)
adx_th  = input.int(20, title="ADX Threshold", group=gp_adx)

gp_pvt = "5. Exit / Resistance (Auto Pivot)"
show_pivot = input.bool(true, title="Show Pivot Lines", group=gp_pvt)

// ==========================================
// 1. Phase Recognition (4 MAs)
// ==========================================
ema62  = ta.ema(close, ma62_len)
ema144 = ta.ema(close, ma144_len)
sma200 = ta.sma(close, ma200_len)
sma800 = ta.sma(close, ma800_len)

plot(ema62,  color=color.rgb(0, 191, 255),    linewidth=1, title="62 EMA")
plot(ema144, color=color.rgb(255, 0, 128),    linewidth=1, title="144 EMA")
plot(sma200, color=color.rgb(255, 215, 0),    linewidth=2, title="200 SMA")
plot(sma800, color=color.rgb(128, 128, 128),  linewidth=3, title="800 SMA")

isUpTrend   = (ema62 > ema144) and (ema144 > sma200) and (sma200 > sma800)
isDownTrend = (ema62 < ema144) and (ema144 < sma200) and (sma200 < sma800)

// ==========================================
// 2. Direction (Heiken Ashi Smoothed)
// ==========================================
srcOpen  = ta.rma(open, ha_p1)
srcHigh  = ta.rma(high, ha_p1)
srcLow   = ta.rma(low, ha_p1)
srcClose = ta.rma(close, ha_p1)

var float haOpen = na
haClose = (srcOpen + srcHigh + srcLow + srcClose) / 4
haOpen := na(haOpen[1]) ? (srcOpen + srcClose) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh  = math.max(srcHigh, math.max(haOpen, haClose))
haLow   = math.min(srcLow, math.min(haOpen, haClose))

haOpen_s  = ta.wma(haOpen, ha_p2)
haHigh_s  = ta.wma(haHigh, ha_p2)
haLow_s   = ta.wma(haLow, ha_p2)
haClose_s = ta.wma(haClose, ha_p2)

color_bull = color.rgb(0, 230, 118)
color_bear = color.rgb(255, 23, 68)
haColor = haClose_s >= haOpen_s ? color_bull : color_bear

plotcandle(haOpen_s, haHigh_s, haLow_s, haClose_s, title="Heiken Ashi Smoothed", color=haColor, wickcolor=haColor, bordercolor=haColor)

haChangedToBlue = (haClose_s >= haOpen_s) and (haClose_s[1] < haOpen_s[1])
haChangedToRed  = (haClose_s < haOpen_s) and (haClose_s[1] >= haOpen_s[1])

// ==========================================
// 3. Volume & 4. ADX
// ==========================================
volAvg = ta.sma(volume, vol_len)
isVolumeSpike = (volume > volAvg * vol_mult)

[plusDI, minusDI, adx] = ta.dmi(adx_len, adx_len)
adxUp = adx > adx[1] and adx > adx_th
adxBuyDot  = adxUp and (plusDI > minusDI)
adxSellDot = adxUp and (minusDI > plusDI)

// ==========================================
// 5. THV Trix Oscillator
// ==========================================
calc_trix(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    trix = (e3 - e3[1]) / e3[1] * 10000
    trix

trix_fast = calc_trix(close, 4)
trix_slow = calc_trix(close, 8)
trix_bull = trix_fast > trix_slow

// ==========================================
// 6. Auto Pivot Lines (Exit/Resistance Targets)
// ==========================================
d_high  = request.security(syminfo.tickerid, "D", high[1])
d_low   = request.security(syminfo.tickerid, "D", low[1])
d_close = request.security(syminfo.tickerid, "D", close[1])

p_P  = (d_high + d_low + d_close) / 3
p_R1 = (2 * p_P) - d_low
p_R2 = p_P + (d_high - d_low)
p_S1 = (2 * p_P) - d_high
p_S2 = p_P - (d_high - d_low)

plot(show_pivot ? p_R2 : na, title="Pivot R2", color=color.new(color.maroon, 30), style=plot.style_stepline, linewidth=1)
plot(show_pivot ? p_R1 : na, title="Pivot R1", color=color.new(color.red, 40),    style=plot.style_stepline, linewidth=1)
plot(show_pivot ? p_P  : na, title="Pivot P",  color=color.new(color.white, 50),  style=plot.style_stepline, linewidth=1)
plot(show_pivot ? p_S1 : na, title="Pivot S1", color=color.new(color.green, 40),  style=plot.style_stepline, linewidth=1)
plot(show_pivot ? p_S2 : na, title="Pivot S2", color=color.new(color.olive, 30),  style=plot.style_stepline, linewidth=1)

atr = ta.atr(14)
near_R = (math.abs(high - p_R1) <= atr * 0.5) or (math.abs(high - p_R2) <= atr * 0.5) or (math.abs(close - p_R1) <= atr * 0.5)
near_S = (math.abs(low - p_S1) <= atr * 0.5) or (math.abs(low - p_S2) <= atr * 0.5) or (math.abs(close - p_S1) <= atr * 0.5)

// ==========================================
// 7. Entry Signal Generation (Mode Split)
// ==========================================
barsSinceVolSpike = ta.barssince(isVolumeSpike)

buy_trend  = (trade_mode == "Trend Follow") and isUpTrend and haChangedToBlue and adxBuyDot and (barsSinceVolSpike <= 3)
sell_trend = (trade_mode == "Trend Follow") and isDownTrend and haChangedToRed and adxSellDot and (barsSinceVolSpike <= 3)

buy_counter  = (trade_mode == "Counter Trend") and near_S and haChangedToBlue and trix_bull
sell_counter = (trade_mode == "Counter Trend") and near_R and haChangedToRed and not trix_bull

plotshape(buy_trend,    title="FTNS Trend BUY",  style=shape.triangleup,   location=location.belowbar, color=color_bull, size=size.normal)
plotshape(sell_trend,   title="FTNS Trend SELL", style=shape.triangledown, location=location.abovebar, color=color_bear, size=size.normal)
plotshape(buy_counter,  title="FTNS Counter BUY", style=shape.arrowup,       location=location.belowbar, color=color.rgb(0, 255, 210), size=size.normal)
plotshape(sell_counter, title="FTNS Counter SELL",style=shape.arrowdown,     location=location.abovebar, color=color.rgb(255, 152, 0), size=size.normal)

// ==========================================
// 8. Advanced THV Multi-Dashboard (Table)
// ==========================================
var table panel = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 20), border_color=color.rgb(60, 60, 60), border_width=1)
if barstate.islast
    table.cell(panel, 0, 0, "FTNS ULTIMATE", text_color=color.white, text_size=size.small, bgcolor=color.rgb(20, 20, 20))
    table.cell(panel, 1, 0, "STATUS",        text_color=color.white, text_size=size.small, bgcolor=color.rgb(20, 20, 20))
    
    table.cell(panel, 0, 1, "Selected Mode", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, trade_mode == "Trend Follow" ? "TREND" : "COUNTER", bgcolor=trade_mode == "Trend Follow" ? color.blue : color.purple, text_color=color.white, text_size=size.small)
    
    table.cell(panel, 0, 2, "1. MA Phase", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 2, isUpTrend ? "BULL" : isDownTrend ? "BEAR" : "RANGE", bgcolor=isUpTrend ? color.new(color_bull, 20) : isDownTrend ? color.new(color_bear, 20) : color.new(color.orange, 20), text_color=color.white, text_size=size.small)
    
    table.cell(panel, 0, 3, "2. Heiken Ashi", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 3, haClose_s >= haOpen_s ? "UP (GREEN)" : "DOWN (RED)", bgcolor=haClose_s >= haOpen_s ? color_bull : color_bear, text_color=color.black, text_size=size.small)
    
    table.cell(panel, 0, 4, "3. Better Vol", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 4, isVolumeSpike ? "SPIKE!" : "NORMAL", bgcolor=isVolumeSpike ? color.rgb(186, 104, 200) : color.gray, text_color=color.white, text_size=size.small)
    
    table.cell(panel, 0, 5, "4. ADX Force", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 5, adxBuyDot ? "BUY FORCE" : adxSellDot ? "SELL FORCE" : "WEAK", bgcolor=adxBuyDot ? color.new(color_bull, 20) : adxSellDot ? color.new(color_bear, 20) : color.gray, text_color=color.white, text_size=size.small)

    table.cell(panel, 0, 6, "5. THV Trix", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 6, trix_bull ? "▲ BULL" : "▼ BEAR", bgcolor=trix_bull ? color_bull : color_bear, text_color=color.black, text_size=size.small)

// ==========================================
// 9. Dynamic Alerts Settings
// ==========================================
if buy_trend
    alert("[FTNS Trend Follow] Buy Signal Detected!", alert.freq_once_per_bar_close)
if sell_trend
    alert("[FTNS Trend Follow] Sell Signal Detected!", alert.freq_once_per_bar_close)
if buy_counter
    alert("[FTNS Counter Trend] Buy Reversal from Support!", alert.freq_once_per_bar_close)
if sell_counter
    alert("[FTNS Counter Trend] Sell Reversal from Resistance!", alert.freq_once_per_bar_close)
````
