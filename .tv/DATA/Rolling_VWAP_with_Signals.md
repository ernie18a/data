<!-- tradingview-pine-id: PUB;c61e50d96ec849dd9e67c01bbc045b6c -->
<!-- tradingviewscripts-format: 1 -->
# Rolling VWAP with Signals

Source: https://www.tradingview.com/script/AhfcWUjm-Rolling-VWAP-with-Signals/

## Description

Rolling VWAP with Signals

Overview

Rolling VWAP with Signals plots a time-window ("rolling") VWAP with standard deviation bands, and generates filtered buy/sell signals on band breakouts. Unlike a session VWAP, which resets at a fixed anchor such as the start of day or week, this VWAP recalculates continuously over a trailing window that you define, for example the last 10 hours or the last 2 minutes of 3-minute bars. This keeps it adapting on any chart, in any session, in any market, including markets that trade around the clock.

This script is an original extension built on the rolling VWAP concept from [Rolling VWAP](https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/). It adds standard deviation bands, trend-state coloring, crossover based buy/sell signals, an ATR rising filter, and a VWAP trend-alignment filter, none of which are present in the original.

How It Works

The rolling VWAP is computed by summing price times volume and volume over a trailing time window, then dividing, the standard VWAP formula applied to a moving window instead of a fixed session. The calculation runs on an independent timeframe set by the RVWAP Timeframe input, evaluated with request.security().

Standard deviation bands sit above and below the VWAP at a configurable multiple of the rolling standard deviation, computed with the direct weighted squared deviation method rather than the E[x^2] minus E[x]^2 shortcut, which avoids precision loss on high-priced instruments.

[pine]
smoothedATR = ta.swma(ta.atr(atrLength))
atrRising   = not useATRFilter or smoothedATR > smoothedATR[1]
[/pine]

Trend state is bullish when the VWAP is higher than it was one higher-timeframe bar ago and price is above the upper band, and bearish under the mirrored condition. The VWAP line is colored accordingly.

Buy and sell signals fire once, on the bar where price crosses a band, not on every bar price remains outside it:

[*]Buy — close crosses over the upper band
[*]Sell — close crosses under the lower band

Two optional filters narrow signals to higher-conviction setups:

[*]Rising ATR — requires an SWMA-smoothed ATR to be higher than the prior bar, filtering out breakouts occurring while volatility is contracting
[*]RVWAP trend alignment — requires the bullish or bearish trend state described above, so buy only fires in an established uptrend and sell only in an established downtrend

Four alert conditions are available: price above the upper band, price below the lower band, a buy signal, and a sell signal.

Inputs

[*]RVWAP Timeframe — Timeframe the rolling VWAP and standard deviation calculation runs on, independent of the chart timeframe. Default: 1 minute.
[*]RVWAP Time Period (Hours / Minutes) — Length of the trailing window used for the rolling calculation. Shorter windows track faster; longer windows behave more like a session VWAP. Default: 0 hours, 1 minute.
[*]Standard Deviation Multiplier — Distance of the bands from the VWAP, in standard deviations. Lower values give tighter bands and more signals; higher values give wider bands and fewer, stronger signals. Default: 1.618.
[*]Show Standard Deviation Bands — Toggles the band plots and disables buy/sell signals when off, since signals require a band cross. Default: on.
[*]Show Fill Between Bands — Toggles the shaded fill between the upper and lower bands. Default: on.
[*]Smooth VWAP/StdDev — Applies additional smoothing to the VWAP and standard deviation lines for a less-lagged appearance when off, or a smoother, laggier line when on. Default: off.
[*]Require Rising ATR for Signals — Gates buy and sell signals on a rising smoothed ATR. Default: on.
[*]Length — ATR length used by the rising-ATR filter. Default: 14.
[*]Require RVWAP Trend Alignment for Signals — Gates buy signals on a bullish RVWAP trend and sell signals on a bearish RVWAP trend. Default: on.
[*]Upper Band, Lower Band, Fill — Colors for the band lines and the fill between them.

Usage Notes

[*]Requires a data feed that provides volume; the script raises a runtime error if none is available.
[*]The rolling calculation needs a minimum of 10 bars within the window to produce a value; very short windows on sparse data may show gaps.
[*]Rising ATR means the current SWMA-smoothed ATR value is strictly greater than the previous bar's value, a one-bar comparison rather than a multi-bar slope.
[*]Values inside the current, still-forming RVWAP Timeframe bar can update intrabar, as with any request.security() call without a fixed historical offset. Confirmed bars do not repaint.
[*]Disable both signal filters to see every raw band-crossing signal, or enable them independently to trade off signal frequency against signal quality.

Credits

[*]Rolling VWAP methodology adapted from the original [Rolling VWAP](https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/).
[*]Uses the open-source PineCoders ConditionalAverages library for the windowed total calculations.

Disclaimer

This script is provided for educational and informational purposes only and does not constitute financial advice. Past performance is not indicative of future results. Always do your own research and apply proper risk management before trading.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jabez4jc
//
// Based on "Rolling VWAP": https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/

//@version=6
indicator('Rolling VWAP with Signals', 'RVWAP Signals', overlay = true)

// Import PineCoders library
import PineCoders/ConditionalAverages/2 as pc

// ───────────────────────────── Inputs ─────────────────────────────
tfrvwap = input.timeframe("1", 'RVWAP Timeframe')
int hoursInput = input.int(0, 'RVWAP Time Period — Hours', minval = 0, maxval = 23, inline = 'period')
int minsInput = input.int(1, 'Minutes', minval = 0, maxval = 59, inline = 'period')
float stdDevMult = input.float(1.618, 'Standard Deviation Multiplier', minval = 0.146, maxval = 5.0, step = 0.5)
bool showBands = input.bool(true, 'Show Standard Deviation Bands')
bool showFill = input.bool(true, 'Show Fill Between Bands')
bool useSmoothing = input.bool(false, 'Smooth VWAP/StdDev (uncheck for tighter, less-lagged line)')
bool useATRFilter = input.bool(true, 'Require Rising ATR for Signals', inline = 'atr', group = 'Signal Filters')
int atrLength = input.int(14, 'Length', minval = 1, inline = 'atr', group = 'Signal Filters')
bool useTrendFilter = input.bool(true, 'Require RVWAP Trend Alignment for Signals', group = 'Signal Filters')
color upperBandColor = input.color(color.new(color.blue, 50), 'Upper Band', inline = 'colors')
color lowerBandColor = input.color(color.new(color.red, 50), 'Lower Band', inline = 'colors')
color fillColor = input.color(color.new(color.gray, 80), 'Fill', inline = 'colors')

// ───────────────────────────── Constants ─────────────────────────────
int MS_IN_MIN = 60 * 1000
int MS_IN_HOUR = MS_IN_MIN * 60
int periodMs = hoursInput * MS_IN_HOUR + minsInput * MS_IN_MIN
int MIN_BARS = 10

// ───────────────────────────── Safety check ─────────────────────────────
// FIX: guard against data feeds that don't supply volume — without this the
// VWAP silently evaluates to na/0 with no indication of why.
if ta.cum(nz(volume)) == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")

// ───────────────────────────── Calculation ─────────────────────────────
// FIX: VWAP and its StdDev are now computed together in ONE function and
// returned as a tuple from a SINGLE request.security() call. Previously,
// calculateRVWAP() was invoked inside a second, separate request.security()
// call just to feed the StdDev calc — silently doubling the RVWAP
// computation and the data-feed cost for identical results.
//
// The direct weighted squared-deviation method (rather than the
// E[x²] - E[x]² shortcut) is kept intentionally: it avoids precision loss
// from subtracting two large nearly-equal numbers, which matters on
// high-priced instruments like BTC/crypto pairs.
//
// Smoothing (rma(swma())) is now toggled by the useSmoothing input —
// uncheck it for a tighter, less-lagged line suited to faster execution
// timing; leave it checked for the original smoother behavior.
calcRVWAP(src, windowMs) =>
    float sumSrcVol = pc.totalForTimeWhen(src * volume, windowMs, true, MIN_BARS)
    float sumVol = pc.totalForTimeWhen(volume, windowMs, true, MIN_BARS)
    float vwap = sumSrcVol / sumVol

    float squaredDev = math.pow(src - vwap, 2) * volume
    float sumSquaredDevVol = pc.totalForTimeWhen(squaredDev, windowMs, true, MIN_BARS)
    float variance = sumSquaredDevVol / sumVol
    float stdDev = math.sqrt(variance)

    float outVWAP = useSmoothing ? ta.rma(ta.swma(vwap), 6) : vwap
    float outStdDev = useSmoothing ? ta.rma(ta.swma(stdDev), 6) : stdDev
    [outVWAP, outStdDev]

[rollingVWAP, stdDev] = request.security(syminfo.tickerid, tfrvwap, calcRVWAP(hlc3, periodMs), barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Calculate standard deviation bands
float upperBand = rollingVWAP + (stdDevMult * stdDev)
float lowerBand = rollingVWAP - (stdDevMult * stdDev)

// ───────────────────────────── Trend detection ─────────────────────────────
// FIX: replaced the hand-rolled tf_in_seconds() timeframe string parser with
// the built-in timeframe.in_seconds(), which is tested against every
// timeframe-string edge case (seconds/minutes/days/weeks/months) and needs
// no maintenance.
htf_secs = timeframe.in_seconds(tfrvwap)
ltf_secs = timeframe.in_seconds()
ratio = math.round(htf_secs / ltf_secs)

// Trend conditions
rvwapUp = rollingVWAP > rollingVWAP[ratio] and close > upperBand
rvwapDn = rollingVWAP < rollingVWAP[ratio] and close < lowerBand

// ───────────────────────────── ATR rising filter ─────────────────────────────
// Smoothed ATR via SWMA must be rising (not falling) for a signal to fire —
// filters out breakouts happening while volatility is contracting.
smoothedATR = ta.swma(ta.atr(atrLength))
atrRising = not useATRFilter or smoothedATR > smoothedATR[1]

// ───────────────────────────── Buy/Sell band-break signals ─────────────────────────────
// Fires once on the bar where price crosses the band, not on every bar it
// remains outside it. Buy = breakout above the upper band; Sell = breakdown
// below the lower band — same directional logic as rvwapUp/rvwapDn above.
trendOkBuy = not useTrendFilter or rvwapUp
trendOkSell = not useTrendFilter or rvwapDn

buySignal = showBands and ta.crossover(close, upperBand) and atrRising and trendOkBuy
sellSignal = showBands and ta.crossunder(close, lowerBand) and atrRising and trendOkSell

// ───────────────────────────── Plotting ─────────────────────────────
plot(rollingVWAP, 'Rolling VWAP', color = rvwapUp ? color.new(color.green, 0) : rvwapDn ? color.new(color.red, 0) : color.new(color.white, 0), linewidth = 3)

upperBandPlot = plot(showBands ? upperBand : na, 'Upper Band', color = upperBandColor, linewidth = 1, style = plot.style_line)
lowerBandPlot = plot(showBands ? lowerBand : na, 'Lower Band', color = lowerBandColor, linewidth = 1, style = plot.style_line)

fill(upperBandPlot, lowerBandPlot, color = showFill and showBands ? fillColor : na, title = 'Band Fill')

plotshape(buySignal, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = color.new(color.green, 0), size = size.small, text = 'BUY')
plotshape(sellSignal, title = 'Sell Signal', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.small, text = 'SELL')

// Alerts
alertcondition(close > upperBand, title = "Price Above Upper Band", message = "Price has moved above the upper standard deviation band")
alertcondition(close < lowerBand, title = "Price Below Lower Band", message = "Price has moved below the lower standard deviation band")
alertcondition(buySignal, title = "RVWAP Buy Signal", message = "Price broke above the upper RVWAP band — buy signal")
alertcondition(sellSignal, title = "RVWAP Sell Signal", message = "Price broke below the lower RVWAP band — sell signal")
````
