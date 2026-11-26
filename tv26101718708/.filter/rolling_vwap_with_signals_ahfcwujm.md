# Rolling VWAP with Signals

- url: https://www.tradingview.com/script/AhfcWUjm-Rolling-VWAP-with-Signals/
- type: indicator
- pine_id: PUB;c61e50d96ec849dd9e67c01bbc045b6c
- version: 4.0

## Description

[b]Rolling VWAP with Signals[/b]

[b]Overview[/b]

Rolling VWAP with Signals plots a time-window ("rolling") VWAP with standard deviation bands, and generates filtered buy/sell signals on band breakouts. Unlike a session VWAP, which resets at a fixed anchor such as the start of day or week, this VWAP recalculates continuously over a trailing window that you define, for example the last 10 hours or the last 2 minutes of 3-minute bars. This keeps it adapting on any chart, in any session, in any market, including markets that trade around the clock.

This script is an original extension built on the rolling VWAP concept from [url=https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/]Rolling VWAP[/url]. It adds standard deviation bands, trend-state coloring, crossover based buy/sell signals, an ATR rising filter, and a VWAP trend-alignment filter, none of which are present in the original.

[b]How It Works[/b]

The rolling VWAP is computed by summing price times volume and volume over a trailing time window, then dividing, the standard VWAP formula applied to a moving window instead of a fixed session. The calculation runs on an independent timeframe set by the RVWAP Timeframe input, evaluated with request.security().

Standard deviation bands sit above and below the VWAP at a configurable multiple of the rolling standard deviation, computed with the direct weighted squared deviation method rather than the E[x^2] minus E[x]^2 shortcut, which avoids precision loss on high-priced instruments.

[pine]
smoothedATR = ta.swma(ta.atr(atrLength))
atrRising   = not useATRFilter or smoothedATR > smoothedATR[1]
[/pine]

Trend state is bullish when the VWAP is higher than it was one higher-timeframe bar ago and price is above the upper band, and bearish under the mirrored condition. The VWAP line is colored accordingly.

Buy and sell signals fire once, on the bar where price crosses a band, not on every bar price remains outside it:

[list]
[*]Buy — close crosses over the upper band
[*]Sell — close crosses under the lower band
[/list]

Two optional filters narrow signals to higher-conviction setups:

[list]
[*]Rising ATR — requires an SWMA-smoothed ATR to be higher than the prior bar, filtering out breakouts occurring while volatility is contracting
[*]RVWAP trend alignment — requires the bullish or bearish trend state described above, so buy only fires in an established uptrend and sell only in an established downtrend
[/list]

Four alert conditions are available: price above the upper band, price below the lower band, a buy signal, and a sell signal.

[b]Inputs[/b]

[list=1]
[*][b]RVWAP Timeframe[/b] — Timeframe the rolling VWAP and standard deviation calculation runs on, independent of the chart timeframe. Default: 1 minute.
[*][b]RVWAP Time Period (Hours / Minutes)[/b] — Length of the trailing window used for the rolling calculation. Shorter windows track faster; longer windows behave more like a session VWAP. Default: 0 hours, 1 minute.
[*][b]Standard Deviation Multiplier[/b] — Distance of the bands from the VWAP, in standard deviations. Lower values give tighter bands and more signals; higher values give wider bands and fewer, stronger signals. Default: 1.618.
[*][b]Show Standard Deviation Bands[/b] — Toggles the band plots and disables buy/sell signals when off, since signals require a band cross. Default: on.
[*][b]Show Fill Between Bands[/b] — Toggles the shaded fill between the upper and lower bands. Default: on.
[*][b]Smooth VWAP/StdDev[/b] — Applies additional smoothing to the VWAP and standard deviation lines for a less-lagged appearance when off, or a smoother, laggier line when on. Default: off.
[*][b]Require Rising ATR for Signals[/b] — Gates buy and sell signals on a rising smoothed ATR. Default: on.
[*][b]Length[/b] — ATR length used by the rising-ATR filter. Default: 14.
[*][b]Require RVWAP Trend Alignment for Signals[/b] — Gates buy signals on a bullish RVWAP trend and sell signals on a bearish RVWAP trend. Default: on.
[*][b]Upper Band, Lower Band, Fill[/b] — Colors for the band lines and the fill between them.
[/list]

[b]Usage Notes[/b]

[list]
[*]Requires a data feed that provides volume; the script raises a runtime error if none is available.
[*]The rolling calculation needs a minimum of 10 bars within the window to produce a value; very short windows on sparse data may show gaps.
[*]Rising ATR means the current SWMA-smoothed ATR value is strictly greater than the previous bar's value, a one-bar comparison rather than a multi-bar slope.
[*]Values inside the current, still-forming RVWAP Timeframe bar can update intrabar, as with any request.security() call without a fixed historical offset. Confirmed bars do not repaint.
[*]Disable both signal filters to see every raw band-crossing signal, or enable them independently to trade off signal frequency against signal quality.
[/list]

[b]Credits[/b]

[list]
[*]Rolling VWAP methodology adapted from the original [url=https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/]Rolling VWAP[/url].
[*]Uses the open-source PineCoders ConditionalAverages library for the windowed total calculations.
[/list]

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only and does not constitute financial advice. Past performance is not indicative of future results. Always do your own research and apply proper risk management before trading.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jabez4jc
//
// Based on "Rolling VWAP": https://www.tradingview.com/script/ZU2UUu9T-Rolling-VWAP/

//@version=6
indicator('Rolling VWAP with Signals', 'RVWAP Signals', overlay = true)

// Requires the GatedStats library (GatedStats.pine in this repo), published as jabez4jc/GatedStats/3.
// If you publish a new version, bump the number here.
import jabez4jc/GatedStats/3 as gs

// ───────────────────────────── Band multiplier (Fibonacci ratios) ─────────────────────────────
// Each title is the reasoning shown in the dropdown when choosing the band width.
// Tighter ratios trigger earlier and more often; wider ratios trigger later with fewer, stronger breakouts.
enum BandRatio
    r0236 = '0.236 — Shallowest: extreme strength, earliest entries, most noise'
    r0382 = '0.382 — Shallow: strong, fast-moving trend; buyers/sellers step in early'
    r0500 = '0.500 — Halfway: psychological midpoint, balanced sensitivity'
    r0618 = '0.618 — Golden ratio: key trend-continuation level, optimal risk/reward'
    r0707 = '0.707 — Deep (√0.5): complex correction, likely stop-run zone'
    r0786 = '0.786 — Deep (√0.618): last stop-run before a trend resumes'
    r0886 = '0.886 — Ultra-deep: institutional discount, last chance for a reversal'
    r1000 = '1.000 — Full 1σ: classic standard-deviation band'
    r1130 = '1.130 — Bull/Bear trap: price often pokes past this to hunt liquidity, then reverses'
    r1272 = '1.272 — √1.618: first major extension target after a breakout'
    r1414 = '1.414 — √2: exhaustion point for impulsive moves'
    r1618 = '1.618 — Golden extension: healthy, powerful trending wave target'
    r2000 = '2.000 — Early parabolic exhaustion: partial-profit zone on strong continuation breakouts'
    r2272 = '2.272 — Early parabolic exhaustion (√5): partial-profit zone on strong continuation breakouts'
    r2414 = '2.414 — 1+√2 (silver ratio): extended impulsive move, momentum-only breakouts'
    r2618 = '2.618 — Major macro wave completion: core profit target for structural cyclical runs'
    r3141 = '3.141 — π: hyper-extended move, very rare breakouts'
    r3618 = '3.618 — Extreme blow-off top territory: hyper-extended terminal peaks'
    r4236 = '4.236 — Extreme blow-off top territory: macro short setups; rarest signals'

bandRatioValue(BandRatio r) =>
    switch r
        BandRatio.r0236 => 0.236
        BandRatio.r0382 => 0.382
        BandRatio.r0500 => 0.5
        BandRatio.r0618 => 0.618
        BandRatio.r0707 => 0.707
        BandRatio.r0786 => 0.786
        BandRatio.r0886 => 0.886
        BandRatio.r1000 => 1.0
        BandRatio.r1130 => 1.13
        BandRatio.r1272 => 1.272
        BandRatio.r1414 => 1.414
        BandRatio.r1618 => 1.618
        BandRatio.r2000 => 2.0
        BandRatio.r2272 => 2.272
        BandRatio.r2414 => 2.414
        BandRatio.r2618 => 2.618
        BandRatio.r3141 => 3.141
        BandRatio.r3618 => 3.618
        BandRatio.r4236 => 4.236

// ───────────────────────────── Inputs ─────────────────────────────
tfrvwap = input.timeframe("", 'RVWAP Timeframe')
int hoursInput = input.int(1, 'RVWAP Time Period — Hours', minval = 0, maxval = 23, inline = 'period')
int minsInput = input.int(0, 'Minutes', minval = 0, maxval = 59, inline = 'period')
BandRatio bandRatio = input.enum(BandRatio.r1130, 'Standard Deviation Multiplier (Fibonacci ratio)')
float stdDevMult = bandRatioValue(bandRatio)
bool showBands = input.bool(true, 'Show Standard Deviation Bands')
bool showFill = input.bool(true, 'Show Fill Between Bands')

// Smoothing
bool useSmoothing = input.bool(true, 'Smooth VWAP/StdDev (uncheck for tighter, less-lagged line)', group = 'Smoothing')
gs.MaType smoothType = input.enum(gs.MaType.swma, 'Smoothing Type', group = 'Smoothing')
// SWMA always uses 4 samples, so the length input is disabled when it is selected.
int smoothLen = input.int(6, 'Smoothing Length', minval = 2, group = 'Smoothing', active = smoothType != gs.MaType.swma)

// Signal filters
bool useATRFilter = input.bool(true, 'Require Rising ATR for Signals', inline = 'atr', group = 'Signal Filters')
int atrLength = input.int(14, 'Length', minval = 1, inline = 'atr', group = 'Signal Filters')
bool useTrendFilter = input.bool(true, 'Require RVWAP Trend Alignment for Signals', group = 'Signal Filters')
bool useVolFilter = input.bool(true, 'Require Relative Volume', inline = 'rvol', group = 'Signal Filters')
float rvolMult = input.float(1.2, 'Min ×', minval = 0.5, step = 0.1, inline = 'rvol', group = 'Signal Filters', active = useVolFilter)
bool useFlowFilter = input.bool(true, 'Require Directional Volume Dominance', inline = 'flow', group = 'Signal Filters')
int flowLen = input.int(34, 'Bars', minval = 5, inline = 'flow', group = 'Signal Filters', active = useFlowFilter)
bool useNarrowFilter = input.bool(true, 'Require Narrow Band', inline = 'narrow', group = 'Signal Filters')
float narrowMult = input.float(0.8, 'Max × avg width', minval = 0.1, step = 0.05, inline = 'narrow', group = 'Signal Filters', active = useNarrowFilter)

// Colors
color upperBandColor = input.color(color.new(color.blue, 50), 'Upper Band', inline = 'colors')
color lowerBandColor = input.color(color.new(color.red, 50), 'Lower Band', inline = 'colors')
color fillColor = input.color(color.new(color.gray, 80), 'Fill', inline = 'colors')

// ───────────────────────────── Constants ─────────────────────────────
int MS_IN_MIN = 60 * 1000
int MS_IN_HOUR = MS_IN_MIN * 60
int periodMs = hoursInput * MS_IN_HOUR + minsInput * MS_IN_MIN
int MIN_BARS = 10

// ───────────────────────────── Safety check ─────────────────────────────
if ta.cum(nz(volume)) == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")

// ───────────────────────────── Calculation ─────────────────────────────
// gs.gatedVwapTime() returns the rolling VWAP and its weighted standard deviation
// in one call (one window, one request.security). The deviation is measured against
// the CURRENT window VWAP for every sample, i.e. the true weighted std dev.
//
// Smoothing uses gs.gatedMa() with a selectable type and length, toggled by
// useSmoothing — uncheck it for a tighter, less-lagged line suited to faster
// execution timing. The smoothing calls run on every bar regardless of the toggle
// so their history stays consistent.
calcRVWAP(src, simple int windowMs) =>
    [vwap, stdDev] = gs.gatedVwapTime(src, volume, windowMs, true, MIN_BARS)
    float smoothVWAP = gs.gatedMa(vwap, true, smoothLen, smoothType)
    float smoothStdDev = gs.gatedMa(stdDev, true, smoothLen, smoothType)
    [useSmoothing ? smoothVWAP : vwap, useSmoothing ? smoothStdDev : stdDev]

[rollingVWAP, stdDev] = request.security(syminfo.tickerid, tfrvwap, calcRVWAP(hlc3, periodMs), barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Calculate standard deviation bands
float upperBand = rollingVWAP + (stdDevMult * stdDev)
float lowerBand = rollingVWAP - (stdDevMult * stdDev)

// ───────────────────────────── Trend detection ─────────────────────────────
// ratio is clamped to >= 1. When the RVWAP timeframe is lower than the chart
// timeframe, round(htf/ltf) is 0, so rollingVWAP[0] would compare the value to
// itself and the trend condition could never be true.
htf_secs = timeframe.in_seconds(tfrvwap)
ltf_secs = timeframe.in_seconds()
int ratio = math.max(1, math.round(htf_secs / ltf_secs))

// Trend conditions
rvwapUp = rollingVWAP > rollingVWAP[ratio] and close > upperBand
rvwapDn = rollingVWAP < rollingVWAP[ratio] and close < lowerBand

// ───────────────────────────── ATR rising filter ─────────────────────────────
// Smoothed ATR via SWMA must be rising (not falling) for a signal to fire —
// filters out breakouts happening while volatility is contracting.
smoothedATR = ta.swma(ta.atr(atrLength))
atrRising = not useATRFilter or smoothedATR > smoothedATR[1]

// ───────────────────────────── Volume filters ─────────────────────────────
// Relative volume: the breakout bar must trade above its rolling 24h average.
float avgVol = gs.gatedMeanTime(volume, 24 * MS_IN_HOUR, true, MIN_BARS)
bool volOk = not useVolFilter or volume > avgVol * rvolMult

// Directional dominance: up-bar volume must have exceeded down-bar volume (buys), or the
// reverse (sells), over the last flowLen bars. Up/down bar (close vs open) is only a rough
// proxy for buying/selling pressure because `volume` is unsigned.
// [1]: judge the pressure BEFORE the breakout bar so its own volume can't confirm itself.
bool upBar = close > open
bool downBar = close < open
float upVol = gs.gatedMeanInBars(volume, upBar, flowLen, 3)
float downVol = gs.gatedMeanInBars(volume, downBar, flowLen, 3)
bool flowOkBuy = not useFlowFilter or upVol[1] > downVol[1]
bool flowOkSell = not useFlowFilter or downVol[1] > upVol[1]

// ───────────────────────────── Narrow-band filter ─────────────────────────────
// Band width as a fraction of price must be at most narrowMult × its rolling 24h average
// (same GatedStats time window as the relative-volume baseline).
// [1]: judge the squeeze BEFORE the breakout bar, because the breakout itself widens the band.
float bandWidth = (upperBand - lowerBand) / rollingVWAP
float avgWidth = gs.gatedMeanTime(bandWidth, 24 * MS_IN_HOUR, true, MIN_BARS)
bool narrowOk = not useNarrowFilter or bandWidth[1] <= avgWidth[1] * narrowMult

// ───────────────────────────── Buy/Sell band-break signals ─────────────────────────────
// Signals fire on the bar that crosses a band and on later bars that stay beyond it while closing in the same
// direction. The crossovers are computed on every bar (CW10002) before being combined.
// Signals do not depend on showBands — hiding the bands is a display choice and
// must not silently disable signals and alerts.
bool crossUp = ta.crossover(close, upperBand)// or (close > upperBand and close > close[1])
bool crossDn = ta.crossunder(close, lowerBand)// or (close < lowerBand and close < close[1])

trendOkBuy = not useTrendFilter or rvwapUp
trendOkSell = not useTrendFilter or rvwapDn

buySignal = crossUp and narrowOk and atrRising and trendOkBuy and volOk and flowOkBuy
sellSignal = crossDn and narrowOk and atrRising and trendOkSell and volOk and flowOkSell

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
