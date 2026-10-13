<!-- tradingview-pine-id: PUB;d18605bef989433e8a21da688748acd7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TMA Volatility Bands

Source: https://www.tradingview.com/script/QgEGRBtz-TMA-Volatility-Bands/

## Description

TMA Volatility Bands

TMA Volatility Bands is a trend and volatility indicator built around a smoothed Triangular Moving Average (TMA) and dynamically calculated deviation bands.

The indicator is designed to show the current market trend, volatility range, and potential reversal areas through a structured set of expanding TMA bands.

The TMA acts as the central trend reference, while the surrounding bands expand according to the current deviation of price from the TMA. This creates three volatility levels on both sides of the TMA, helping visualize how far price has moved from its smoothed average.

Main Settings

[*]TMA Trend Line

The central TMA provides a smooth representation of the underlying price trend and reduces short-term market noise.

[*]Dynamic Volatility Bands

Three band levels are calculated above and below the TMA. The bands automatically adapt to changing price volatility, creating a dynamic market range.

[*]Multi-Level Band Structure

The first band represents the primary volatility boundary, while the middle and outer bands extend progressively farther from the TMA. This makes it easier to identify stronger extensions in price movement.

[*]Trend Strength Gradient

The TMA changes color according to the direction and strength of its movement relative to ATR-based volatility. Stronger TMA movement produces a stronger color transition, while weaker movement moves toward a neutral color.

[*]Buy and Sell Signals

The indicator includes automatic reversal-style signals based on price extending beyond the primary volatility band and then forming an opposite-direction candle.

A Buy signal appears when the previous candle moves below the lower primary band and the current candle closes bullish.

A Sell signal appears when the previous candle moves above the upper primary band and the current candle closes bearish.

Adjustable Settings

[*]TMA Period controls the smoothing and responsiveness of the central TMA.
[*]Band Deviation controls the distance of the primary volatility bands from the TMA.
[*]Price Source allows the calculation to use the selected price source.
[*]Trend Threshold controls the sensitivity of the TMA trend-strength gradient.

TMA Volatility Bands is designed to provide a clean visual framework for analyzing trend direction, volatility expansion, price extensions, and potential reversal areas.

The signals should be used as part of a broader trading strategy and confirmed with price action, market structure, or other analysis tools.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © achirameegasthanne

//@version=6
indicator('TMA Volatility Bands', overlay = true, max_bars_back = 300)

//inputs
groupMain = "Main Settings"

Period_TMA = input.int(title="TMA Period", defval=22, group=groupMain)
BandsDeviations = input.float(title="Band Deviation", defval=1, group=groupMain)
src = input.source(title="Price Source", defval=hlc3, group=groupMain)
TrendThreshold = input.float(0.25, 'Trend Threshold', minval = 0.001, maxval = 50, display = display.none)

groupArt = "Art"
upCol = input(#0df1c6, "Bullish Color", group = groupArt)
dnCol = input(#871ee9, "Bearish Color", group = groupArt)

//internals
period = Period_TMA
FullLength = 2.0 * Period_TMA + 1.0

ma = src

//REAL TMA
sma1 = ta.sma(ma, Period_TMA)
TMA = ta.sma(sma1, Period_TMA)

//WU / WD
diff = ma - TMA

var float Variance = na

if na(Variance)
    Variance := diff * diff
else
    Variance := (Variance * (FullLength - 1) + diff * diff) / FullLength

Deviation = math.sqrt(Variance)

//BANDS
UpBand = TMA + BandsDeviations * Deviation
UpMiddleBand = TMA + (BandsDeviations * Deviation) * 1.15
UpTopBand = TMA + (BandsDeviations * Deviation) * 1.30

DnBand = TMA - BandsDeviations * Deviation
DnMiddleBand = TMA - (BandsDeviations * Deviation) * 1.15
DnTopBand = TMA - (BandsDeviations * Deviation) * 1.30

//================ TREND STRENGTH =================
atrBase = ta.atr(Period_TMA)
tilt = atrBase != 0 ? (TMA - TMA[1]) / (0.1 * atrBase) : 0

gradientRange = math.max(TrendThreshold * 4, 1.0)

TMAColor = tilt < 0 ? color.from_gradient(tilt, -gradientRange, 0, upCol, color.gray) : color.from_gradient(tilt, 0, gradientRange, color.gray, dnCol)

// PLOTS
plot(TMA, color = TMAColor, editable = false)

T = plot(UpBand, color = dnCol, editable = false)
plot(UpMiddleBand, color = color.new(dnCol, 30), editable = false)
T1 = plot(UpTopBand, color = color.new(dnCol, 60), editable = false)

D = plot(DnBand, color = upCol, editable = false)
plot(DnMiddleBand, color = color.new(upCol, 30), editable = false)
D1 = plot(DnTopBand, color = color.new(upCol, 60), editable = false)

fill(T, T1, UpBand, UpMiddleBand, color.new(dnCol, 60), na, editable = false)
fill(D1, D, DnMiddleBand, DnBand, na, color.new(upCol, 60), editable = false)

// SIGNALS
SELL = high[1] > UpBand[1] and close[1] > open[1] and close < open
BUY = low[1] < DnBand[1] and close[1] < open[1] and close > open

plotshape(SELL, style = shape.triangledown, location = location.abovebar, color = dnCol, size = size.tiny, editable = false)
plotshape(BUY, style = shape.triangleup, location = location.belowbar, color = upCol, size = size.tiny, editable = false)
````
