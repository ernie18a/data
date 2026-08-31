<!-- tradingview-pine-id: PUB;5e2b995aec2643759bf38c689e8b6965 -->
<!-- tradingviewscripts-format: 1 -->
# Northern Algo - Stacked B/S Volume

Source: https://www.tradingview.com/script/RZBFH9wz-Northern-Algo-Stacked-B-S-Volume/

## Description

Overview

Northern Algo - Stacked Buy/Sell Volume Estimate is a volume-panel indicator that divides each chart bar’s reported volume into estimated buy and sell portions. Both portions are displayed together as one stacked column, allowing total volume, estimated directional composition, and relative buy-volume intensity to be viewed in the same panel.

How the volume split is calculated

The indicator estimates the division of volume from the closing price’s position within each candle’s high-low range:

Close position = (close - low) / (high - low)

Estimated buy volume = total volume x close position

Estimated sell volume = total volume - estimated buy volume

The close-position value is constrained between zero and one. Within this model, a candle closing near its high receives a larger estimated buy-volume portion, while a candle closing near its low receives a larger estimated sell-volume portion. A close near the middle of the range produces a more balanced division.

This is a candle-based estimate. It is not a measurement of exchange-level bid/ask volume, trade aggressor volume, order flow, or the actual number of transactions initiated by buyers and sellers.

Stacked-volume display

Each column contains two segments:

* The lower teal segment represents estimated buy volume.
* The upper red segment represents estimated sell volume.
* The combined height of both segments equals the bar’s total reported volume.

An optional moving average is plotted across the stacked columns. Its default length is 20 bars and it is calculated from total volume rather than either estimated segment. This provides a reference for comparing the current bar’s overall activity with its recent average.

Seller-adjusted buy-volume scale

The optional volume-intensity color scale evaluates estimated buy volume relative to its recent history.

First, the current estimated buy volume is divided by the average estimated buy volume from previous bars. The script performs a separate relative-volume calculation for estimated sell volume. A configurable portion of that sell-volume measurement is then subtracted from the buy-volume measurement:

Adjusted buy relative volume = buy relative volume - (sell relative volume x counter-pressure weight)

The result cannot fall below zero. It is mapped through 18 intensity levels, with progressively darker teal shades representing greater estimated buy-volume expansion after accounting for elevated estimated sell volume.

This seller-adjusted scale is the indicator’s distinguishing feature. It helps separate bars where the buy-volume estimate is expanding with limited opposing pressure from bars where both estimated portions are elevated because total volume has increased.

Using the indicator

The indicator can be used to examine three related characteristics:

* Total activity: Compare the complete column height with surrounding bars and the total-volume average.
* Estimated composition: Compare the relative size of the teal and red portions within each column.
* Relative intensity: When the color scale is enabled, compare the teal shading across bars to identify changes in seller-adjusted estimated buy-volume intensity.

The calculations are performed independently on the active chart timeframe. Shorter lookbacks respond more quickly to recent volume changes, while longer lookbacks provide a smoother comparison. Increasing the counter-pressure weight causes elevated estimated sell volume to have a greater effect on the buy-volume color scale. Setting the weight to zero disables this adjustment.

Settings

* Use V Color Scale: Enables or disables the seller-adjusted buy-volume intensity scale.
* Buy RVOL Lookback Bars: Sets the number of previous bars used to calculate average estimated buy volume.
* Sell Counter-Pressure Lookback Bars: Sets the number of previous bars used to calculate average estimated sell volume.
* Sell Counter-Pressure Weight: Controls how strongly estimated sell relative volume reduces the buy-volume intensity measurement.
* Show Total Volume Average: Shows or hides the moving average of total volume.
* Total Volume Average Length: Controls the moving-average period.
* Buy, Sell, and Volume Average Colors: Customize the panel’s standard display colors.

Important limitations

The displayed buy and sell portions are estimates derived entirely from OHLCV candle data. A larger estimated buy portion does not prove that buyers initiated that proportion of the bar’s transactions, and a larger estimated sell portion does not prove that sellers initiated that proportion.

The model is less informative on candles with very small ranges. On a zero-range candle, the current calculation assigns the displayed volume to the estimated sell segment.

Results depend on the volume data supplied for the selected symbol, exchange, data feed, and chart timeframe. The script does not request lower-timeframe trade data or use future data. Values on an open realtime candle will continue changing as its high, low, close, and volume develop.

This indicator does not generate trade signals, predict future price movement, or provide a complete trading system. It is intended as a contextual volume-visualization and educational tool.

---

## Source Code

````pine
//@version=6
indicator(title = "Northern Algo - Stacked B/S Volume", shorttitle = "NA Stacked B/S Vol", overlay = false, format = format.volume)

// Estimates buy/sell volume from the candle close location inside the high-low range.
// This is a visual volume split, not exchange-level bid/ask volume.

string grpColor = "Northern Algo Color Scale"
string grpEmaGate = "EMA Gate"
string grpVisual = "Visual"

bool useNaVColorScale = input.bool(true, "Use Northern Algo V Color Scale", group = grpColor, tooltip = "Colors the buy-volume stack with Northern Algo's teal volume-intensity scale.")
int buyRvolLookback = input.int(2, "Buy RVOL Lookback Bars", minval = 1, group = grpColor, tooltip = "Lookback used to compare current estimated buy volume against prior estimated buy volume.")
int sellImpactLookback = input.int(2, "Sell Counter-Pressure Lookback Bars", minval = 1, group = grpColor, tooltip = "Lookback used to compare current estimated sell volume against prior estimated sell volume.")
float sellerRvolImpactWeight = input.float(0.25, "Sell Counter-Pressure Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = grpColor, tooltip = "Reduces buy-color intensity when estimated sell pressure is also elevated.")

bool useEmaGateSuppression = input.bool(true, "Use EMA Gate Buy Suppression", group = grpEmaGate, tooltip = "When enabled, buy-volume RVOL intensity is suppressed while the 20 EMA is above the 9 EMA.")
int emaGateFastLen = input.int(9, "Fast EMA Length", minval = 1, maxval = 200, group = grpEmaGate)
int emaGateSlowLen = input.int(20, "Slow EMA Length", minval = 1, maxval = 500, group = grpEmaGate)
float closedGateBuyRvolMult = input.float(0.35, "Closed Gate Buy RVOL Mult", minval = 0.0, maxval = 1.0, step = 0.05, group = grpEmaGate, tooltip = "Multiplier applied to estimated buy volume before the buy RVOL/color calculation when the slow EMA is above the fast EMA.")

bool showVolumeMa = input.bool(true, "Show Total Volume Average", group = grpVisual, tooltip = "Shows a moving average of total volume on top of the stacked bars.")
int volumeMaLen = input.int(20, "Total Volume Average Length", minval = 1, group = grpVisual, tooltip = "Length for the total-volume moving average.")
color buyColor = input.color(color.rgb(83, 242, 208), "Buy Color", group = grpVisual)
color sellColor = input.color(color.rgb(167, 59, 95), "Sell Color", group = grpVisual)
color volumeMaColor = input.color(color.white, "Volume Average Color", group = grpVisual)

float baseBuyRvolMult = 0.90
float b1BuyRvolMult = 1.25
float b2BuyRvolMult = 1.50
float b3BuyRvolMult = 2.25
float b4BuyRvolMult = 3.25
float b5BuyRvolMult = 5.00
float b6BuyRvolMult = 7.00
float b7BuyRvolMult = 9.00
float b8BuyRvolMult = 12.00
float b9BuyRvolMult = 15.00

calcBuyStrength(float value, float thresholdScale) =>
    float t1 = baseBuyRvolMult * thresholdScale
    float t2 = (baseBuyRvolMult + b1BuyRvolMult) * 0.5 * thresholdScale
    float t3 = b1BuyRvolMult * thresholdScale
    float t4 = (b1BuyRvolMult + b2BuyRvolMult) * 0.5 * thresholdScale
    float t5 = b2BuyRvolMult * thresholdScale
    float t6 = (b2BuyRvolMult + b3BuyRvolMult) * 0.5 * thresholdScale
    float t7 = b3BuyRvolMult * thresholdScale
    float t8 = (b3BuyRvolMult + b4BuyRvolMult) * 0.5 * thresholdScale
    float t9 = b4BuyRvolMult * thresholdScale
    float t10 = (b4BuyRvolMult + b5BuyRvolMult) * 0.5 * thresholdScale
    float t11 = b5BuyRvolMult * thresholdScale
    float t12 = (b5BuyRvolMult + b6BuyRvolMult) * 0.5 * thresholdScale
    float t13 = b6BuyRvolMult * thresholdScale
    float t14 = (b6BuyRvolMult + b7BuyRvolMult) * 0.5 * thresholdScale
    float t15 = b7BuyRvolMult * thresholdScale
    float t16 = (b7BuyRvolMult + b8BuyRvolMult) * 0.5 * thresholdScale
    float t17 = b8BuyRvolMult * thresholdScale
    float t18 = b9BuyRvolMult * thresholdScale
    value >= t18 ? 18 : value >= t17 ? 17 : value >= t16 ? 16 : value >= t15 ? 15 : value >= t14 ? 14 : value >= t13 ? 13 : value >= t12 ? 12 : value >= t11 ? 11 : value >= t10 ? 10 : value >= t9 ? 9 : value >= t8 ? 8 : value >= t7 ? 7 : value >= t6 ? 6 : value >= t5 ? 5 : value >= t4 ? 4 : value >= t3 ? 3 : value >= t2 ? 2 : value >= t1 ? 1 : 0

float barRange = high - low
float closePosition = barRange > 0.0 ? math.min(math.max((close - low) / barRange, 0.0), 1.0) : 0.5
float buyVolEst = volume * closePosition
float sellVolEst = volume - buyVolEst
float volumeMa = ta.sma(volume, volumeMaLen)

float emaGateFast = ta.ema(close, emaGateFastLen)
float emaGateSlow = ta.ema(close, emaGateSlowLen)
bool emaGateClosedForBuy = useEmaGateSuppression and emaGateSlow > emaGateFast
float buyVolForRvol = buyVolEst * (emaGateClosedForBuy ? closedGateBuyRvolMult : 1.0)

float avgBuyVol = ta.sma(buyVolEst[1], buyRvolLookback)
float avgSellVol = ta.sma(sellVolEst[1], sellImpactLookback)
float buyRvol = not na(avgBuyVol) and avgBuyVol > 0.0 ? buyVolForRvol / avgBuyVol : na
float sellRvol = not na(avgSellVol) and avgSellVol > 0.0 ? sellVolEst / avgSellVol : na
float adjustedBuyRvol = not na(buyRvol) ? math.max(buyRvol - nz(sellRvol, 0.0) * sellerRvolImpactWeight, 0.0) : na
int buyColorStrength = not na(adjustedBuyRvol) ? calcBuyStrength(adjustedBuyRvol, 1.0) : 0

color naBuyBaseColor = color.rgb(83, 242, 208)
color naBuyMaxColor = color.rgb(0, 22, 23)
color activeBuyColor = useNaVColorScale and buyColorStrength > 0 ? color.from_gradient(buyColorStrength, 1, 18, naBuyBaseColor, naBuyMaxColor) : buyColor

hline(0, "Zero", color = color.new(color.gray, 85))

plotcandle(
     open = 0,
     high = buyVolEst,
     low = 0,
     close = buyVolEst,
     title = "Estimated Buy Volume",
     color = activeBuyColor,
     wickcolor = activeBuyColor,
     bordercolor = activeBuyColor)

plotcandle(
     open = buyVolEst,
     high = volume,
     low = buyVolEst,
     close = volume,
     title = "Estimated Sell Volume",
     color = sellColor,
     wickcolor = sellColor,
     bordercolor = sellColor)

plot(showVolumeMa ? volumeMa : na, title = "Total Volume Average", color = volumeMaColor, linewidth = 2)
````
