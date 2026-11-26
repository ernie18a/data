# Price Volume Divergence Oscillator (PVDO)

- url: https://www.tradingview.com/script/IcRwpEaL/
- type: indicator
- pine_id: PUB;34da5bab985f4f6bbb2fe42bf73bfbf1
- version: 1.0

## Description

Price Volume Divergence Oscillator (PVDO)

Overview

PVDO is an open-source price-volume indicator designed to show whether price movement is being supported or contradicted by underlying volume pressure.

Instead of treating price and volume as separate signals, PVDO evaluates them together and expresses their relationship as a normalized oscillator. This makes it easier to see when price-volume conditions are aligned, diverging, strengthening, weakening, or moving back toward neutral.

PVDO is the foundation layer of the PVD Ecosystem. Its role is deliberately simple: describe the current price-volume imbalance as clearly and consistently as possible.

What it shows

PVDO is displayed in a separate pane.

• The main oscillator represents the current price-volume divergence state.
• The signal line provides a smoother reference for that state.
• The histogram highlights the difference between the two and helps show changes in pressure.
• Zero is the neutral reference between positive and negative price-volume conditions.

Positive values indicate that the current relationship is tilted toward positive pressure. Negative values indicate the opposite. Changes in distance from zero and changes relative to the signal line can help reveal strengthening, weakening, or shifting conditions.

How to use it

PVDO is best used as market context rather than as a standalone buy/sell system.

Typical uses include:

• checking whether price movement is supported by volume pressure;
• identifying changes in the balance between price and volume;
• comparing current pressure with its recent smoothed state;
• observing transitions through or away from neutral.

A positive or negative value is not, by itself, a trade instruction. The meaning of a reading depends on the instrument, timeframe, and surrounding market structure.

Role in the PVD Ecosystem

PVDO answers the basic PVD question:

What is the current relationship between price movement and volume pressure?

Within the PVD Ecosystem, this present-state information is the common analytical foundation. PVDO itself remains focused on the underlying imbalance rather than trying to perform state classification, momentum analysis, or forecasting at the same time.

Originality

PVDO uses an original implementation that combines normalized price movement and normalized volume pressure into a dedicated price-volume divergence state, followed by adaptive smoothing and stored-pressure processing.

The script is published open source so users can inspect its construction and understand how the displayed state is produced.

Limitations

PVDO does not predict certain future prices and does not guarantee that a positive or negative pressure state will continue.

The indicator depends on both price and volume data. On symbols where meaningful volume information is unavailable or differs materially between data feeds, results may be limited or differ from other markets.

Like all indicators, PVDO simplifies market information. It should be used together with market context, independent judgment, and appropriate risk management.

## Source Code

````pine
//@version=6
indicator("Price Volume Divergence Oscillator", shorttitle="PVDO", overlay=false)

// 1. Inputs
priceDeltaType = input.string("Signed High - Low", "Price Movement", options=["Close - Open", "Signed High - Low"])
normLength = input.int(11, "Normalization Length", minval=1)
maType = input.string("EMA", "PVDO MA Type", options=["SMA", "EMA", "HMA", "LMA", "RMA", "WMA", "VWMA", "TEMA"])
pvdoMaLength = input.int(121, "PVDO MA Length", minval=1)
signalMaType = input.string("EMA", "Signal MA Type", options=["SMA", "EMA", "HMA", "LMA", "RMA", "WMA", "VWMA", "TEMA"])
signalMaLength = input.int(44, "Signal MA Length", minval=1)
logisticBandwidth = input.float(121, "Logistic Bandwidth", minval=1)
storedLength = input.int(11, "Stored Imbalance Length", minval=1)
histLength = input.int(44, "Correction Histogram Smoothing", minval=1)
histScale = input.float(0.25, "Correction Histogram Scale", minval=0.01)

// 2. Pressure
candleRange = math.max(high - low, syminfo.mintick)
pressure = volume * (close - open) / candleRange
pressureScale = ta.sma(math.abs(pressure), normLength)
pressureNorm = na(pressureScale) ? na : pressureScale == 0.0 ? 0.0 : pressure / pressureScale

// 3. Price Movement
priceMove = priceDeltaType == "Close - Open" ? close - open : close > open ? high - low : close < open ? -(high - low) : 0.0
priceScale = ta.sma(math.abs(priceMove), normLength)
priceNorm = na(priceScale) ? na : priceScale == 0.0 ? 0.0 : priceMove / priceScale

// 4. Raw PVDO
pvdoRaw = -(priceNorm - pressureNorm) * math.abs(priceNorm)

// 5. Moving Average Functions
tema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    3 * ema1 - 3 * ema2 + ema3

ma(src, len, type) =>
    switch type
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "HMA" => ta.hma(src, len)
        "LMA" => ta.linreg(src, len, 0)
        "RMA" => ta.rma(src, len)
        "WMA" => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "TEMA" => tema(src, len)

// 6. PVDO Moving Averages
pvdoMain = ma(pvdoRaw, pvdoMaLength, maType)
pvdoSignal = ma(pvdoMain, signalMaLength, signalMaType)

// 7. Logistic Adaptive Smoothing
mkr_logistic_weight(src, bandwidth) => 1.0 / (1.0 + math.exp(-math.abs(src) / bandwidth))
var float pvdoLogistic = na
var float signalLogistic = na
pvdoChange = pvdoMain - nz(pvdoLogistic, pvdoMain)
signalChange = pvdoSignal - nz(signalLogistic, pvdoSignal)
pvdoWeight = mkr_logistic_weight(pvdoChange, logisticBandwidth)
signalWeight = mkr_logistic_weight(signalChange, logisticBandwidth)
pvdoLogistic := na(pvdoLogistic[1]) ? pvdoMain : pvdoLogistic[1] + pvdoWeight * pvdoChange
signalLogistic := na(signalLogistic[1]) ? pvdoSignal : signalLogistic[1] + signalWeight * signalChange

// 8. Stored Imbalance
decay = (storedLength - 1.0) / storedLength
var float storedImbalance = na
storedImbalance := na(storedImbalance[1]) ? pvdoMain : storedImbalance[1] * decay + pvdoMain

// 9. Logistic Stored Imbalance
var float storedLogistic = na
storedChange = storedImbalance - nz(storedLogistic, storedImbalance)
storedWeight = mkr_logistic_weight(storedChange, logisticBandwidth)
storedLogistic := na(storedLogistic[1]) ? storedImbalance : storedLogistic[1] + storedWeight * storedChange

// 10. Correction Pressure Histogram
storedScale = ta.sma(math.abs(storedLogistic), storedLength)
storedValue = na(storedScale) ? na : storedScale == 0.0 ? 0.0 : storedLogistic / storedScale
storedNormalized = (math.exp(2 * storedValue) - 1) / (math.exp(2 * storedValue) + 1)
var float correctionPressureSmooth = na
correctionPressureEMA = ta.ema(storedNormalized, histLength)
correctionPressureSmooth := na(correctionPressureSmooth[1]) ? storedNormalized : correctionPressureEMA
correctionDisplay = correctionPressureSmooth * histScale

// 11. Histogram State
histRising = correctionDisplay > correctionDisplay[1]
histPositive = correctionDisplay >= 0
correctionColor = histPositive ? (histRising ? color.new(#4caf4f, 63) : color.new(#a4e8a6, 51)) : (histRising ? color.new(#ff9292, 49) : color.new(#f32323, 59))
zeroCross = ta.cross(correctionDisplay, 0)

// 12. Outputs
hline(0, "Zero Line", color=color.gray)
plotshape(zeroCross ? 0 : na, title="Correction Pressure Zero Cross", style=shape.circle, location=location.absolute, color=color.rgb(255, 245, 151), size=size.tiny)
plot(pvdoLogistic, title="PVDO Logistic Overlay", color=pvdoLogistic > pvdoLogistic[1] ? color.green : color.red, linewidth=2)
plot(signalLogistic, title="Signal Logistic Overlay", color=signalLogistic > signalLogistic[1] ? color.aqua : color.rgb(248, 174, 1), linewidth=2)
plot(correctionDisplay, title="Correction Pressure", style=plot.style_columns, color=correctionColor, linewidth=2)
````
