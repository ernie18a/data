# CVD Bollinger Bands

- url: https://www.tradingview.com/script/NkuqmeDj-CVD-Bollinger-Bands/
- type: indicator
- pine_id: PUB;90830b822b7149ae87f5148d34981c24
- version: 1.0

## Description

CVD SMA Bollinger Bands (Local Reset)

This indicator applies Bollinger Bands directly to the Cumulative Volume Delta (CVD)​ of each individual bar, providing a statistical framework to detect extreme order‑flow imbalances.

How it works

CVD Calculation

Uses TradingView's built-in ta.requestVolumeDelta(lowerTimeframe, anchorInput) function. It computes the Volume Delta (buy volume minus sell volume) on a user-defined lower timeframe (e.g., 1‑minute) and accumulates the delta within each anchor period (default: 1 day). At the start of each new anchor period, the accumulation resets to zero. This means the CVD values are not globally cumulative—they reflect net buying/selling pressure only within the current anchor period.

SMA and Bollinger Bands​

A simple moving average (SMA) of the CVD is calculated over a user‑defined lookback period (default 20 bars). The sample standard deviation is derived from the squared differences. Two bands are plotted at ±bbWeight standard deviations around the SMA.

Important Notes

Stationarity Assumption​ – The local‑reset CVD sequence is approximately stationary (if the per‑bar volume‑delta distribution is stable). This satisfies the key assumption behind Bollinger Bands – that the mean and variance are locally constant. In trending markets, the mean may shift slightly, but the rolling window automatically adjusts the center line and bandwidth.

No Accumulation Drift​ – Unlike global cumulative CVD (e.g., OBV), local reset CVD does not suffer from random‑walk drift. Its mean and variance remain bounded, making Bollinger Bands statistically meaningful even over long periods.

Scale Sensitivity​ – CVD values depend on the instrument’s volume and bar duration. A Bollinger weight of 2.0 may need adjustment for different symbols or timeframes. Consider scaling by dividing CVD by a moving average of volume if cross‑instrument consistency is required.

False Signals from Volume Spikes​ – A single bar with abnormally high volume (e.g., news event) can cause a temporary CVD spike, triggering a band touch that may not persist. To reduce noise, combine with volume confirmation or require multiple consecutive touches.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YanisZh

//@version=6
indicator(title="CVD Bollinger Bands", shorttitle="CVD BB", overlay=false, timeframe="", timeframe_gaps=true)
import TradingView/ta/12
// --- Input ---
anchorInput         = input.timeframe("1D", "Anchor period(Timeframe)")
dataAggregationTooltip = "Defines how lower timeframe data is aggregated for the delta calculation. \"1 tick\" computes the delta on tick data and is available only on expert plans."
dataAggregationInput = input.string("Time", "Data aggregation", options = ["Time", "1 tick"], tooltip = dataAggregationTooltip)
useTicks = dataAggregationInput == "1 tick"
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe.\n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip, active = not useTicks)
lowerTimeframeInput = input.timeframe("1", "LowerTimeframe", active = useCustomTimeframeInput and not useTicks)


smaWindow = input.int(20, "SMA Window", minval=1)
bbWeight  = input.float(2.0, "Bollinger Weight", minval=0.001, step=0.1)

// --- select lowerTimeframe ---
var lowerTimeframe = switch
    useTicks                => "1T"
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

// ---  CVD（reset as Anchor） ---
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

// lastVolume as CVD
cvd = lastVolume

// --- SMA and sdev ---
avgCVD   = ta.sma(cvd, smaWindow)
avgSqCVD = ta.sma(cvd * cvd, smaWindow)
varCVD   = avgSqCVD - avgCVD * avgCVD
stdevCVD = math.sqrt(math.max(varCVD, 0))

// --- Bollinger Bands ---
upperBB = avgCVD + bbWeight * stdevCVD
lowerBB = avgCVD - bbWeight * stdevCVD

// --- Plot ---
plot(cvd,     "CVD",           color=#7E57C2, linewidth=1)
plot(avgCVD,  "CVD SMA",       color=color.yellow, linewidth=1)
plot(upperBB, "Upper Band",    color=color.green, linewidth=1)
plot(lowerBB, "Lower Band",    color=color.red,   linewidth=1)
hline(50, "Midline", color=color.gray, linestyle=hline.style_dashed)
````
