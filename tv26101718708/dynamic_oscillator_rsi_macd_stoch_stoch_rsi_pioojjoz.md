# Dynamic Oscillator (RSI, MACD, Stoch, Stoch RSI)

- url: https://www.tradingview.com/script/pioOjJOZ-Dynamic-Oscillator-RSI-MACD-Stoch-Stoch-RSI/
- type: indicator
- pine_id: PUB;37b8b6b985c14f358dfe1f0036692116
- version: 2.0

## Description

Description:

This indicator combines four of the most widely used momentum and trend oscillators—RSI, MACD, Stochastic RSI, and Stochastic—into a single, unified pane.

Originality and Usefulness:
The primary issue with combining multiple bounded (0-100) and unbounded (MACD) oscillators into a single pane is overlapping, which creates an unreadable chart. This script solves that problem by introducing a Dynamic Auto-Scaling and Stacking Algorithm.
Instead of rendering all indicators on the same axis, the script dynamically assigns a visual 100-point tier (base level) to each activated indicator. If an indicator is toggled off in the settings, the script automatically recalculates the bases and shifts the remaining active indicators down to fill the void (auto-scale). This ensures a clean, non-overlapping visualization that saves valuable chart space, especially for users who rely on multiple momentum confirmations.

To achieve this, the script utilizes invisible base plots and custom helper functions drawing extended dashed lines (line.new with extend.both) to act as smart visual separators that adapt dynamically based on how many indicators are currently active.

Underlying Concepts & How It Does It:

1. MACD Normalization (Unbounded to Bounded):
Since the MACD does not have a fixed upper or lower bound, directly overlaying it with bounded oscillators is impossible without distortion. This script uses a mathematical workaround: it calculates the highest absolute value among the MACD line, Signal line, and Histogram over a 100-bar lookback window using ta.highest(). It then generates a proportional scaling factor to compress the MACD data precisely into a 100-point visual zone. The visual crosses, trend direction, and histogram shapes remain mathematically accurate to a traditional MACD, but scaled to fit the stacking environment.

2. Relative Strength Index (RSI) & Divergence:
The script includes a standard RSI (default 14-period). It is equipped with an automated Regular Divergence detection system. The logic uses ta.pivotlow and ta.pivothigh with customizable lookback windows (left and right) to identify price extremes compared to RSI extremes. Furthermore, users can enable a moving average smoothing line directly applied to the RSI calculation (SMA, EMA, WMA, VWMA, or Bollinger Bands).

3. Stochastic & Stochastic RSI:
The script calculates the traditional Stochastic Oscillator (%K and %D) using the standard ta.stoch() function based on Close, High, and Low. Additionally, it provides the Stochastic RSI, applying the Stochastic formula directly to the RSI values rather than price data, increasing sensitivity for identifying short-term overbought/oversold conditions.

How to Use It:

● Toggle System: Open the indicator settings and use the checkboxes to turn specific oscillators ON or OFF. The layout will adapt automatically.

● Confluence Trading: Use this stacked view to spot confluences. For example, spotting a Regular Bullish Divergence on the RSI occurring simultaneously with a MACD zero-line cross and a Stochastic %K/%D crossover in the oversold zone.

● Clean Visualization: The indicator uses custom transparent boundaries and dashed separator lines to keep your workspace structured.

(Note: This script is published for educational purposes to demonstrate dynamic vertical scaling of mixed-bound arrays).

Disclaimer:
This script is strictly an analytical tool for educational and informational purposes only. It does not constitute financial advice, nor is it an invitation, solicitation, or recommendation to buy or sell any financial instrument. The developer of this indicator assumes no responsibility or liability for any trading decisions, financial losses, or actions you take based on this tool. Trading in financial markets involves a high degree of risk, and all trading decisions are entirely in your own hands. Past performance of any trading system is not indicative of future results. Always Do Your Own Research (DYOR) and test strategies on a paper trading account before risking real capital.

## Source Code

````pine
//@version=6
indicator(title="6-in-1 Dynamic Auto-Scaling Oscillator", shorttitle="6-in-1 Osc", format=format.price, precision=2)

// ==============================================================================
// 1. TOGGLE INDICATORS (TOMBOL ON/OFF)
// ==============================================================================
grp_toggles = "Indicators (On/Off)"
show_rsi      = input.bool(true, "Show RSI", group=grp_toggles)
show_macd     = input.bool(true, "Show MACD", group=grp_toggles)
show_stochrsi = input.bool(false, "Show Stochastic RSI", group=grp_toggles)
show_stoch    = input.bool(false, "Show Stochastic", group=grp_toggles)
show_smi      = input.bool(false, "Show SMI", group=grp_toggles)
show_smiio    = input.bool(false, "Show SMI Ergodic (SMIIO)", group=grp_toggles)

// ==============================================================================
// 2. HELPER FUNCTION: GARIS PUTUS-PUTUS & EXTEND KE KANAN
// ==============================================================================
f_hline(y_val, show_cond, c, s) =>
    var line l = line.new(na, na, na, na, extend=extend.both)
    if barstate.islast
        if show_cond
            line.set_xy1(l, bar_index, y_val)
            line.set_xy2(l, bar_index + 1, y_val)
            line.set_color(l, c)
            line.set_style(l, s)
        else
            line.set_color(l, na)

// ==============================================================================
// 3. DYNAMIC AUTO-SCALE LOGIC (SISTEM PENYUSUNAN OTOMATIS)
// ==============================================================================
int active_count = 0

float smi_base = 0.0
if show_smi
    smi_base := active_count * 100
    active_count += 1

float smiio_base = 0.0
if show_smiio
    smiio_base := active_count * 100
    active_count += 1

float stoch_base = 0.0
if show_stoch
    stoch_base := active_count * 100
    active_count += 1

float stochrsi_base = 0.0
if show_stochrsi
    stochrsi_base := active_count * 100
    active_count += 1

float rsi_base = 0.0
if show_rsi
    rsi_base := active_count * 100
    active_count += 1

float macd_base = 0.0
if show_macd
    macd_base := active_count * 100
    active_count += 1

// ==============================================================================
// 4. SMART SEPARATOR LINES (PEMBATAS ABU-ABU EXTEND)
// ==============================================================================
f_hline(100, active_count > 1, color.new(#787B86, 60), line.style_solid)
f_hline(200, active_count > 2, color.new(#787B86, 60), line.style_solid)
f_hline(300, active_count > 3, color.new(#787B86, 60), line.style_solid)
f_hline(400, active_count > 4, color.new(#787B86, 60), line.style_solid)
f_hline(500, active_count > 5, color.new(#787B86, 60), line.style_solid)

// ==============================================================================
// 5. STOCHASTIC MOMENTUM INDEX (SMI) - INJECTED
// ==============================================================================
grp_smi = "SMI Settings"
lengthK_smi   = input.int(10, "%K Length",  minval = 1, maxval = 15000, group=grp_smi)
lengthD_smi   = input.int(3,  "%D Length",  minval = 1, maxval = 4999, group=grp_smi)
lengthEMA_smi = input.int(3,  "EMA Length", minval = 1, maxval = 4999, group=grp_smi)

emaEma(source, length) => ta.ema(ta.ema(source, length), length)

highestHigh_smi = ta.highest(lengthK_smi)
lowestLow_smi   = ta.lowest(lengthK_smi)
highestLowestRange_smi = highestHigh_smi - lowestLow_smi
relativeRange_smi = close - (highestHigh_smi + lowestLow_smi) / 2

smi_raw = 200 * (emaEma(relativeRange_smi, lengthD_smi) / emaEma(highestLowestRange_smi, lengthD_smi))
smi_ema_raw = ta.ema(smi_raw, lengthEMA_smi)

scaled_smi = show_smi ? (smi_raw / 2) + 50 + smi_base : na
scaled_smi_ema = show_smi ? (smi_ema_raw / 2) + 50 + smi_base : na

smiPlot = plot(scaled_smi, "SMI", color = color.blue)
plot(scaled_smi_ema, "SMI-based EMA", color = color.orange)

smiOverboughtPlot = plot(show_smi ? 70 + smi_base : na, "SMI Overbought Invisible", color=na, editable=false)
smiOversoldPlot   = plot(show_smi ? 30 + smi_base : na, "SMI Oversold Invisible", color=na, editable=false)
smiMidLinePlot    = plot(show_smi ? 50 + smi_base : na, "SMI Mid Invisible", color=na, editable=false)

fill(smiOverboughtPlot, smiOversoldPlot, title = "SMI Background", color = show_smi ? color.new(color.blue, 90) : na)
fill(smiPlot, smiMidLinePlot, 110 + smi_base,  70 + smi_base, top_color = show_smi ? color.new(#4caf4f, 50) : na, bottom_color = show_smi ? color.new(color.green, 100) : na, title = "SMI Overbought Fill")
fill(smiPlot, smiMidLinePlot, 30 + smi_base, -10 + smi_base, top_color = show_smi ? color.new(color.red, 100) : na, bottom_color = show_smi ? color.new(color.red, 50) : na, title = "SMI Oversold Fill")

f_hline(70 + smi_base, show_smi, color.new(#787B86, 50), line.style_dashed)
f_hline(50 + smi_base, show_smi, color.new(#787B86, 70), line.style_dashed)
f_hline(30 + smi_base, show_smi, color.new(#787B86, 50), line.style_dashed)

// ==============================================================================
// 6. SMI ERGODIC INDICATOR & OSCILLATOR (SMIIO)
// ==============================================================================
grp_smiio = "SMIIO Settings"
shortlen_smiio = input.int(5, minval=1, title="Short Length", group=grp_smiio)
longlen_smiio  = input.int(20, minval=1, title="Long Length", group=grp_smiio)
siglen_smiio   = input.int(5, minval=1, title="Signal Line Length", group=grp_smiio)

col_smiio_grow_above = input(#26A69A, 'Above Grow', group = grp_smiio, inline = 'SMIIO Above')
col_smiio_fall_above = input(#B2DFDB, 'Fall', group = grp_smiio, inline = 'SMIIO Above')
col_smiio_grow_below = input(#FFCDD2, 'Below Grow', group = grp_smiio, inline = 'SMIIO Below')
col_smiio_fall_below = input(#FF5252, 'Fall', group = grp_smiio, inline = 'SMIIO Below')

erg_smiio = ta.tsi(close, shortlen_smiio, longlen_smiio)
sig_smiio = ta.ema(erg_smiio, siglen_smiio)
osc_smiio = erg_smiio - sig_smiio

// Logika 4 Warna MACD untuk Histogram SMIIO
hist_color_smiio = osc_smiio >= 0 ? (osc_smiio[1] < osc_smiio ? col_smiio_grow_above : col_smiio_fall_above) : (osc_smiio[1] < osc_smiio ? col_smiio_grow_below : col_smiio_fall_below)

max_smiio_val = nz(math.max(math.abs(erg_smiio), math.max(math.abs(sig_smiio), math.abs(osc_smiio))))
smiio_highest = nz(ta.highest(max_smiio_val, 100))
smiio_scale   = smiio_highest > 0 ? 40 / smiio_highest : 1

scaled_erg_smiio = show_smiio ? (erg_smiio * smiio_scale) + smiio_base + 50 : na
scaled_sig_smiio = show_smiio ? (sig_smiio * smiio_scale) + smiio_base + 50 : na
scaled_osc_smiio = show_smiio ? (osc_smiio * smiio_scale) + smiio_base + 50 : na

f_hline(smiio_base + 50, show_smiio, color.new(#787B86, 70), line.style_dashed)

plot(scaled_osc_smiio, title="SMIIO Oscillator", style=plot.style_columns, histbase=smiio_base + 50, color=show_smiio ? hist_color_smiio : na)
plot(scaled_erg_smiio, title="SMIIO Indicator", color=show_smiio ? color.new(#FF0000, 0) : na)
plot(scaled_sig_smiio, title="SMIIO Signal", color=show_smiio ? color.new(#2962FF, 0) : na)

// Menambahkan penanda persilangan (cross) berbentuk lingkaran putih
plot(ta.cross(erg_smiio, sig_smiio) and show_smiio ? scaled_sig_smiio : na, title="SMIIO Cross", color=color.white, style=plot.style_circles, linewidth=2)

// ==============================================================================
// 7. STOCHASTIC INDICATOR
// ==============================================================================
grp_stoch = "Stochastic Settings"
periodK_stoch = input.int(14, title="%K Length", minval=1, group=grp_stoch)
smoothK_stoch = input.int(3, title="%K Smoothing", minval=1, group=grp_stoch)
periodD_stoch = input.int(3, title="%D Smoothing", minval=1, group=grp_stoch)

k_stoch = ta.sma(ta.stoch(close, high, low, periodK_stoch), smoothK_stoch)
d_stoch = ta.sma(k_stoch, periodD_stoch)

plot(show_stoch ? k_stoch + stoch_base : na, title="Stoch %K", color=#ff0000)
plot(show_stoch ? d_stoch + stoch_base : na, title="Stoch %D", color=#2196f3)

stoch_h0 = plot(show_stoch ? 80 + stoch_base : na, "Stoch Upper Invisible", color=na, editable=false)
stoch_h1 = plot(show_stoch ? 20 + stoch_base : na, "Stoch Lower Invisible", color=na, editable=false)
fill(stoch_h0, stoch_h1, color=show_stoch ? color.rgb(33, 150, 243, 100) : na, title="Stoch Background")

f_hline(80 + stoch_base, show_stoch, color.new(#787B86, 50), line.style_dashed)
f_hline(50 + stoch_base, show_stoch, color.new(#787B86, 70), line.style_dashed)
f_hline(20 + stoch_base, show_stoch, color.new(#787B86, 50), line.style_dashed)

// ==============================================================================
// 8. STOCHASTIC RSI INDICATOR
// ==============================================================================
grp_stochrsi = "Stochastic RSI Settings"
smoothK_stochrsi = input.int(3, "K", minval=1, group=grp_stochrsi)
smoothD_stochrsi = input.int(3, "D", minval=1, group=grp_stochrsi)
lengthRSI_stochrsi = input.int(14, "RSI Length", minval=1, group=grp_stochrsi)
lengthStoch_stochrsi = input.int(14, "Stochastic Length", minval=1, group=grp_stochrsi)
src_stochrsi = input(close, title="RSI Source", group=grp_stochrsi)

rsi1_stochrsi = ta.rsi(src_stochrsi, lengthRSI_stochrsi)
k_stochrsi = ta.sma(ta.stoch(rsi1_stochrsi, rsi1_stochrsi, rsi1_stochrsi, lengthStoch_stochrsi), smoothK_stochrsi)
d_stochrsi = ta.sma(k_stochrsi, smoothD_stochrsi)

plot(show_stochrsi ? k_stochrsi + stochrsi_base : na, "Stoch RSI K", color=#ff0000)
plot(show_stochrsi ? d_stochrsi + stochrsi_base : na, "Stoch RSI D", color=#2196f3)

srsi_h0 = plot(show_stochrsi ? 80 + stochrsi_base : na, "Stoch RSI Upper Invisible", color=na, editable=false)
srsi_h1 = plot(show_stochrsi ? 20 + stochrsi_base : na, "Stoch RSI Lower Invisible", color=na, editable=false)
fill(srsi_h0, srsi_h1, color=show_stochrsi ? color.rgb(33, 150, 243, 100) : na, title="Stoch RSI Background")

f_hline(80 + stochrsi_base, show_stochrsi, color.new(#787B86, 50), line.style_dashed)
f_hline(50 + stochrsi_base, show_stochrsi, color.new(#787B86, 70), line.style_dashed)
f_hline(20 + stochrsi_base, show_stochrsi, color.new(#787B86, 50), line.style_dashed)

// ==============================================================================
// 9. RSI INDICATOR & DIVERGENCE
// ==============================================================================
grp_rsi = "RSI Settings"
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group=grp_rsi)
rsiSourceInput = input.source(close, "Source", group=grp_rsi)
calculateDivergence = input.bool(true, title="Calculate Divergence", group=grp_rsi, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(show_rsi ? rsi + rsi_base : na, "RSI", color=#ff0000)

rsiUpperBand = plot(show_rsi ? 70 + rsi_base : na, "RSI Upper Invisible", color=na, editable=false)
midlinePlot = plot(show_rsi ? 50 + rsi_base : na, "RSI Middle Invisible", color=na, editable=false)
rsiLowerBand = plot(show_rsi ? 30 + rsi_base : na, "RSI Lower Invisible", color=na, editable=false)

fill(rsiUpperBand, rsiLowerBand, color=show_rsi ? color.rgb(126, 87, 194, 100) : na, title="RSI Background Fill")
fill(rsiPlot, midlinePlot, 100 + rsi_base, 70 + rsi_base, top_color = show_rsi ? color.new(color.green, 100) : na, bottom_color = show_rsi ? color.new(color.green, 100) : na, title = "Overbought Gradient Fill")
fill(rsiPlot, midlinePlot, 30 + rsi_base, rsi_base, top_color = show_rsi ? color.new(color.red, 100) : na, bottom_color = show_rsi ? color.new(color.red, 100) : na, title = "Oversold Gradient Fill")

f_hline(70 + rsi_base, show_rsi, color.new(#787B86, 50), line.style_dashed)
f_hline(50 + rsi_base, show_rsi, color.new(#787B86, 70), line.style_dashed)
f_hline(30 + rsi_base, show_rsi, color.new(#787B86, 50), line.style_dashed)

grp_smooth = "RSI Smoothing"
maTypeInput = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = grp_smooth)
var isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = grp_smooth)
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, group = grp_smooth)
var enableMA = maTypeInput != "None"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(show_rsi and enableMA ? smoothingMA + rsi_base : na, "RSI-based MA", color=#2196f3)
bbUpperBand = plot(show_rsi and isBB ? smoothingMA + smoothingStDev + rsi_base : na, title = "Upper Bollinger Band", color=color.green)
bbLowerBand = plot(show_rsi and isBB ? smoothingMA - smoothingStDev + rsi_base : na, title = "Lower Bollinger Band", color=color.green)
fill(bbUpperBand, bbLowerBand, color= (show_rsi and isBB) ? color.new(color.green, 100) : na, title="Bollinger Bands Background Fill")

lookbackRight = 5
lookbackLeft = 5
rangeUpper = 60
rangeLower = 5
bearColor = color.red
bullColor = color.green
textColor = color.white
noneColor = color.new(color.white, 100)

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound = false
phFound = false
bullCond = false
bearCond = false
rsiLBR = rsi[lookbackRight]

if calculateDivergence
    plFound := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))    
    rsiHL = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and _inRange(plFound[1])
    lowLBR = low[lookbackRight]
    priceLL = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    phFound := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    rsiLH = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and _inRange(phFound[1])
    highLBR = high[lookbackRight]
    priceHH = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond := priceHH and rsiLH and phFound

plot(show_rsi and plFound ? rsiLBR + rsi_base : na, offset = -lookbackRight, title = "Regular Bullish", linewidth = 2, color = (bullCond ? bullColor : noneColor))
plotshape(show_rsi and bullCond ? rsiLBR + rsi_base : na, offset = -lookbackRight, title = "Regular Bullish Label", text = " Bull ", style = shape.labelup, location = location.absolute, color = bullColor, textcolor = textColor)
plot(show_rsi and phFound ? rsiLBR + rsi_base : na, offset = -lookbackRight, title = "Regular Bearish", linewidth = 2, color = (bearCond ? bearColor : noneColor))
plotshape(show_rsi and bearCond ? rsiLBR + rsi_base : na, offset = -lookbackRight, title = "Regular Bearish Label", text = " Bear ", style = shape.labeldown, location = location.absolute, color = bearColor, textcolor = textColor)

alertcondition(bullCond and show_rsi, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence.")
alertcondition(bearCond and show_rsi, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence.')

// ==============================================================================
// 10. MACD INDICATOR (WITH AUTO-SCALE)
// ==============================================================================
grp_macd = "MACD Settings"
fast_length_macd = input(title='Fast Length', defval=12, group=grp_macd)
slow_length_macd = input(title='Slow Length', defval=26, group=grp_macd)
src_macd = input(title='Source', defval=close, group=grp_macd)
signal_length_macd = input.int(title='Signal Smoothing', minval=1, maxval=50, defval=9, group=grp_macd)
sma_source_macd = input.string(title='Oscillator MA Type', defval='EMA', options=['SMA', 'EMA'], group=grp_macd)
sma_signal_macd = input.string(title='Signal Line MA Type', defval='EMA', options=['SMA', 'EMA'], group=grp_macd)

col_macd = input(#ff0000, 'MACD Line  ', group = 'MACD Colors', inline = 'MACD')
col_signal = input(#2196f3, 'Signal Line  ', group = 'MACD Colors', inline = 'Signal')
col_grow_above = input(#26A69A, 'Above   Grow', group = 'MACD Histogram', inline = 'Above')
col_fall_above = input(#B2DFDB, 'Fall', group = 'MACD Histogram', inline = 'Above')
col_grow_below = input(#FFCDD2, 'Below Grow', group = 'MACD Histogram', inline = 'Below')
col_fall_below = input(#FF5252, 'Fall', group = 'MACD Histogram', inline = 'Below')

fast_ma = sma_source_macd == 'SMA' ? ta.sma(src_macd, fast_length_macd) : ta.ema(src_macd, fast_length_macd)
slow_ma = sma_source_macd == 'SMA' ? ta.sma(src_macd, slow_length_macd) : ta.ema(src_macd, slow_length_macd)
macd = fast_ma - slow_ma
signal = sma_signal_macd == 'SMA' ? ta.sma(macd, signal_length_macd) : ta.ema(macd, signal_length_macd)
hist = macd - signal

max_macd_val = nz(math.max(math.abs(macd), math.max(math.abs(hist), math.abs(signal))))
macd_highest = nz(ta.highest(max_macd_val, 100))
macd_scale = macd_highest > 0 ? 40 / macd_highest : 1

scaled_macd = show_macd ? (macd * macd_scale) + macd_base + 50 : na
scaled_signal = show_macd ? (signal * macd_scale) + macd_base + 50 : na
scaled_hist = show_macd ? (hist * macd_scale) + macd_base + 50 : na

hist_color = hist >= 0 ? (hist[1] < hist ? col_grow_above : col_fall_above) : (hist[1] < hist ? col_grow_below : col_fall_below)

f_hline(macd_base + 50, show_macd, color.new(#787B86, 70), line.style_dashed)

plot(scaled_hist, title='Histogram', style=plot.style_columns, histbase=macd_base + 50, color=show_macd ? hist_color : na)
plot(scaled_macd, title='MACD', color=col_macd)
plot(scaled_signal, title='Signal', color=col_signal)
plot(ta.cross(macd, signal) and show_macd ? scaled_signal : na, color=color.white, style=plot.style_circles, linewidth=2)
````
