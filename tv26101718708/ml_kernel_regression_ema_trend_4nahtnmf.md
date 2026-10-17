# ML Kernel Regression + EMA Trend

- url: https://www.tradingview.com/script/4NaHTNmF-ML-Kernel-Regression-EMA-Trend/
- type: indicator
- pine_id: PUB;2f24dfe32d39496db9d30b72e380da7d
- version: 1.0

## Description

// This work is based on concepts by Uptrick
// Modified and updated by marjyhen1921                                                           

[ML] Nadaraya-Watson Kernel Regression (Multi-EMA Filter Edition)

Overview
This indicator features a Non-Parametric Machine Learning estimator based on the Nadaraya-Watson (NW) Kernel Regression. Unlike traditional moving averages that rely on fixed time-windows, this model uses a Gaussian Kernel to assign weights to historical data points, effectively estimating the underlying price trend with minimal lag.

Credits & Inspiration
Special thanks to Uptrick for the original logic and the machine learning concepts that inspired this implementation. This version has been refined for Pine Script V6 with added multi-filter flexibility.

What’s New:

Triple EMA Filter System: To help traders avoid "whipsaws" in sideways markets, I have integrated independent toggles for EMA 9, EMA 20, and EMA 50.

Default "No Filter" Mode: The script starts with all filters disabled, allowing for pure ML signal analysis out of the box.

Dynamic Volatility Bands: The bands are calculated based on the standard deviation of residuals (price error relative to the kernel), providing a "confidence interval" for price movement.

How to Use:

Mean Reversion: Trade the "B" (Buy) and "S" (Sell) labels when price breaks out of the upper/lower bands and the kernel flips color.

Trend Alignment: In the settings, enable the EMA filter of your choice. A Buy signal will only trigger if the price is above your selected EMA; a Sell signal will only trigger if it is below.

Customization: Use the "Visuals" section to show or hide the EMA lines and change the lookback windows to fit your timeframe.

## Source Code

````pine
// This work is based on original concepts by Uptrick
// Modified and updated by marjyhen1921
// Licensed under Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

//@version=6
indicator("ML Kernel Regression + EMA Trend", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
//  SECTION 1 — INPUTS
// ============================================================
grpKernel = "╔═════ ML Kernel Regression ═════╗"
i_length     = input.int(25, "Lookback Window", minval=10, group=grpKernel)
i_bandwidth  = input.float(8.0, "Bandwidth (h)", minval=0.5, group=grpKernel)
i_smooth     = input.int(3, "MA Output Smoothing", minval=1, group=grpKernel)

grpBands = "╔═══════ Volatility Bands ═══════╗"
i_bandMult   = input.float(1.2, "Band Multiplier (σ)", minval=0.5, step=0.1, group=grpBands)
i_bandLen    = input.int(25, "Band Lookback (σ)", minval=10, group=grpBands)

// --- TREND FILTER INPUTS (Defaults set to FALSE) ---
grpFilter = "╔════════ Trend Filter ═══════╗"
i_useEMA9    = input.bool(false, "Filter with EMA 9", group=grpFilter)
i_useEMA20   = input.bool(false, "Filter with EMA 20", group=grpFilter)
i_useEMA50   = input.bool(false, "Filter with EMA 50", group=grpFilter)

grpVis = "╔═════════ Visuals ═════════╗"
i_showBars   = input.bool(true, "Color Bars", group=grpVis)
i_showFill   = input.bool(true, "Fill Bands", group=grpVis)
i_showEMAs   = input.bool(false, "Show Filter EMA Lines", group=grpVis)

// ============================================================
//  SECTION 2 — PALETTE
// ============================================================
C_BULL = #00ff00 
C_BEAR = #ff0000 

// ============================================================
//  SECTION 3 — ML KERNEL REGRESSION CORE
// ============================================================
nwSum    = 0.0
nwWeight = 0.0

for i = 0 to i_length - 1
    kw = math.exp(-math.pow(i, 2) / (2.0 * math.pow(i_bandwidth, 2)))
    nwSum   += kw * close[i]
    nwWeight += kw

nwRaw    = nwSum / nwWeight
kernelMA = ta.ema(nwRaw, i_smooth)

residual = close - kernelMA
sigma    = ta.stdev(residual, i_bandLen)
upperBand = kernelMA + i_bandMult * sigma
lowerBand = kernelMA - i_bandMult * sigma

// ============================================================
//  SECTION 4 — SIGNAL LOGIC (TRIPLE FILTER TOGGLES)
// ============================================================
ema9  = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

var int lastState = 0
if barstate.isconfirmed
    if close > upperBand
        lastState := 1
    else if close < lowerBand
        lastState := -1

isBull = lastState == 1
isBear = lastState == -1

buyCond_Raw  = lastState == 1 and lastState != lastState[1]
sellCond_Raw = lastState == -1 and lastState != lastState[1]

// Multi-Filter Logic: Price must be above/below ALL active filters
filterBull = true
filterBear = true

if i_useEMA9
    filterBull := filterBull and close > ema9
    filterBear := filterBear and close < ema9

if i_useEMA20
    filterBull := filterBull and close > ema20
    filterBear := filterBear and close < ema20

if i_useEMA50
    filterBull := filterBull and close > ema50
    filterBear := filterBear and close < ema50

buySignal  = buyCond_Raw  and filterBull
sellSignal = sellCond_Raw and filterBear

// ============================================================
//  SECTION 5 — VISUALS & PLOTS
// ============================================================
// Plot EMAs only if visuals are enabled AND filter is active
plot(i_showEMAs and i_useEMA9  ? ema9  : na, "EMA 9",  color.new(color.blue, 60))
plot(i_showEMAs and i_useEMA20 ? ema20 : na, "EMA 20", color.new(color.orange, 60))
plot(i_showEMAs and i_useEMA50 ? ema50 : na, "EMA 50", color.new(color.gray, 60), 2)

pMid = plot(kernelMA, "NW Kernel MA", color.new(isBull ? C_BULL : C_BEAR, 20), 2)
pUp  = plot(upperBand, "Upper Band", color.new(C_BULL, 70))
pDn  = plot(lowerBand, "Lower Band", color.new(C_BEAR, 70))

fill(pUp, pDn, i_showFill ? color.new(isBull ? C_BULL : C_BEAR, 92) : na, "State Fill")

barcolor(i_showBars ? (isBull ? C_BULL : C_BEAR) : na)

if buySignal
    label.new(bar_index, low, "B", style=label.style_label_up, color=C_BULL, textcolor=color.black, size=size.small, yloc=yloc.belowbar)

if sellSignal
    label.new(bar_index, high, "S", style=label.style_label_down, color=C_BEAR, textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// ============================================================
//  SECTION 6 — ALERTS
// ============================================================
alertcondition(buySignal, "Bullish Entry", "ML Kernel Trend Alignment: B")
alertcondition(sellSignal, "Bearish Entry", "ML Kernel Trend Alignment: S")
````
