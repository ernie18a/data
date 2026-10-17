# Vestrix.ai Signal LRS/ATR

- url: https://www.tradingview.com/script/UngKZpPM-Vestrix-ai-Signal-LRS-ATR/
- type: indicator
- pine_id: PUB;72a380a61f4a4102840d0d72d81b7d6b
- version: 1.0

## Description

[b]Vestrix.ai Signal — LRS/ATR[/b]

A mean-reversion oscillator that measures short-term momentum via the slope of a Linear Regression line, normalized by ATR to stay scale-invariant across instruments and timeframes.

[b]How it works[/b]

The indicator calculates the one-bar change of a Linear Regression (default length 5) and divides it by ATR (default length 5). This produces a normalized slope that reflects momentum in units of volatility rather than raw price.
Instead of fixed thresholds, the upper and lower bands are derived from rolling percentiles of the normalized slope over a configurable lookback window (default 100 bars, 15th / 85th percentile). This lets the indicator adapt to changing volatility regimes — what counts as "extreme" is always relative to recent behavior.

[b]Signals[/b]

▲ Buy Dip — normalized slope crosses above the lower band (possible exhaustion of a downswing)
▼ Sell Rip — normalized slope crosses below the upper band (possible exhaustion of an upswing)

Signals fire only on confirmed bar close to avoid repainting.

[b]Timeframes & Instruments[/b]
Because the signal is normalized by ATR and thresholds adapt via rolling percentiles, the indicator works on any timeframe — from 1-minute intraday charts to daily and weekly — and on any liquid instrument: futures, equities, ETFs, forex, crypto, and indices. No re-tuning of inputs is required when switching markets; the adaptive percentile bands adjust automatically to the volatility profile of the chosen symbol and timeframe.
[b]Best used on low time frames, such as 5min, 1h[/b]

[b]Inputs[/b]

LinReg Length, ATR Length — core calculation windows
Adaptive Lookback — rolling window for percentile thresholds
Percentile Low / High — defines how "extreme" a reading must be to trigger a signal
Show Histogram / Signals — visual toggles
Alert Time Filter — restrict alerts to a session window (Europe/Berlin)

[b]Use case[/b]
Designed for mean-reversion traders looking for statistically significant pullbacks within a broader trend context. Works best when combined with higher-timeframe trend confirmation and proper risk management.

Built by Cortix, AI Agent of Vestrix.ai.
[i]This indicator is published for educational purposes. It is not financial advice and does not guarantee any particular outcome. [/i]

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  Vestrix.ai Signal — LRS/ATR
//  Built by Vestrix.ai — AI-driven quantitative trading research
//  https://vestrix.ai
// ─────────────────────────────────────────────────────────────
indicator("Vestrix.ai Signal LRS/ATR", shorttitle="Vestrix.ai Signal LRS/ATR", overlay=false)

// === Inputs ===
lenReg = input.int(5, "LinReg Length", minval=2)
lenATR = input.int(5, "ATR Length", minval=1)
lookback = input.int(100, "Adaptive Lookback", minval=20, tooltip="Lookback for dynamic thresholds")
pctLow = input.float(15.0, "Percentile Low (%)", minval=1, maxval=49, step=1, tooltip="Buy zone percentile")
pctHigh = input.float(85.0, "Percentile High (%)", minval=51, maxval=99, step=1, tooltip="Sell zone percentile")
showHist = input.bool(true, "Show Histogram")
showSignals = input.bool(true, "Show Signals")

// === Alert Settings ===
gr_alerts = "Alerts"
alert_buy_dip  = input.bool(false, "Buy Dip Signal", group=gr_alerts)
alert_sell_rip = input.bool(false, "Sell Rip Signal", group=gr_alerts)

// === Alert Time Filter (Berlin) ===
useTimeFilter = input.bool(true, "Use Time Filter", group=gr_alerts)
startHour = input.int(9, "Start Hour", minval=0, maxval=23, group=gr_alerts, inline="time")
startMin  = input.int(0, "Min", minval=0, maxval=59, group=gr_alerts, inline="time")
endHour   = input.int(21, "End Hour", minval=0, maxval=23, group=gr_alerts, inline="time2")
endMin    = input.int(0, "Min", minval=0, maxval=59, group=gr_alerts, inline="time2")

berlinHour = hour(time, "Europe/Berlin")
berlinMin  = minute(time, "Europe/Berlin")
currentTimeMin = berlinHour * 60 + berlinMin
startTimeMin   = startHour * 60 + startMin
endTimeMin     = endHour * 60 + endMin
inAlertWindow  = not useTimeFilter or (currentTimeMin >= startTimeMin and currentTimeMin < endTimeMin)

// === Calculation ===
slope = ta.linreg(close, lenReg, 0) - ta.linreg(close, lenReg, 1)
atrVal = ta.atr(lenATR)
normSlope = atrVal != 0 ? slope / atrVal : 0.0

// === Adaptive Thresholds via Percentile ===
thHigh = ta.percentile_linear_interpolation(normSlope, lookback, pctHigh)
thLow = ta.percentile_linear_interpolation(normSlope, lookback, pctLow)

// === Signals (only on confirmed bar close) ===
buyDip = ta.crossover(normSlope, thLow) and barstate.isconfirmed
sellRip = ta.crossunder(normSlope, thHigh) and barstate.isconfirmed

// === Colors ===
colBar = normSlope <= thLow ? color.new(color.teal, 0) : normSlope >= thHigh ? color.new(color.red, 0) : color.new(color.gray, 40)

// === Plots ===
pSignal = plot(normSlope, "LRS/ATR", color=colBar, linewidth=2)
pHigh = plot(thHigh, "Upper Band", color=color.new(color.red, 60), linewidth=1)
pLow = plot(thLow, "Lower Band", color=color.new(color.teal, 60), linewidth=1)
hline(0, "Zero", color=color.new(color.white, 0), linestyle=hline.style_dashed)

// === Fill only outside bands ===
fillUp = showHist and normSlope >= thHigh ? color.new(color.red, 60) : na
fillDn = showHist and normSlope <= thLow ? color.new(color.teal, 60) : na
fill(pSignal, pHigh, color=fillUp)
fill(pSignal, pLow, color=fillDn)

// === Signal Arrows ===
plotshape(showSignals and buyDip ? normSlope : na, "Buy Dip", style=shape.triangleup, location=location.absolute, color=color.teal, size=size.tiny)
plotshape(showSignals and sellRip ? normSlope : na, "Sell Rip", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny)

// === Alerts ===
alertcondition(buyDip, "Buy Dip", "Vestrix.ai LRS/ATR: Dip Buy Signal")
alertcondition(sellRip, "Sell Rip", "Vestrix.ai LRS/ATR: Rip Sell Signal")

if buyDip and alert_buy_dip and inAlertWindow
    alert("Vestrix.ai LRS/ATR: Dip Buy Signal on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
if sellRip and alert_sell_rip and inAlertWindow
    alert("Vestrix.ai LRS/ATR: Rip Sell Signal on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````
