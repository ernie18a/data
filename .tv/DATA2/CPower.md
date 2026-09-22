<!-- tradingview-pine-id: PUB;c6fc5aa675f04b008097bef41abdca73 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# C-Power

Source: https://www.tradingview.com/script/d4dVjcDw/

## Description

Indicator "C-Power" (candle buy/sell power) and is designed to dynamically measure and display the buying power (Buyers) and selling power (Sellers) over a specific period.
Simply put: the script analyzes recent candles and displays a small label on your chart showing who currently holds the upper hand in the market, along with their respective percentages.

How the Script Works (Step-by-Step)
1. Volume Filtering:
- The script retrieves market volume and smooths it using an ALMA (Arnaud Legoux Moving Average) over a selected period (5 candles by default).
- It protects the chart from anomalies – if an abrupt, massive volume spike occurs (over 3.5 times the average), the script "caps" it so that a single outlier does not distort the overall result.
2. Gap Protection:
- Instead of using just the raw highs and lows of the current candle, the script compares them with the closing price of the previous candle (prev_close). This ensures that price gaps are factored into the market's true momentum.
3. Garman-Klass Volatility Calculation (GK Volatility):
- This is the mathematical core of the script. It utilizes the advanced Garman-Klass formula, which measures market volatility based on the relationship between the open, high, low, and close prices.
- The result is further smoothed by the ALMA filter, delivering a highly stable representation of market volatility that is resilient against market noise.
4. Z-Score and Probability Estimation (Statistics):
- The script measures where the current price sits relative to the candle's midpoint and divides this by the calculated volatility. This creates a statistical value known as a Z-score.
- Using a built-in Cumulative Distribution Function for a normal distribution (normCDF via the error function erf), the script converts this score into a directional weight between 0 and 1. This weight represents the statistical probability of whether the move is inherently bullish or bearish.
5. Determining Final Power (Buy/Sell Power):
- If trading volume data is available for the asset, the script multiplies the volume by this calculated statistical weight.
- If volume data is unavailable (e.g., on certain indices or Forex pairs), the script relies entirely on the mathematical structure of the price action itself (hence the dynamic text update to GK Price).
- These accumulated values over the specified period (e.g., 5 candles) are then converted into percentages (e.g., BUY: 65.0% / SELL: 35.0%).
6. Chart Visualization:
- A text label is generated on the right side of the chart, shifted forward by a user-defined offset (3 candles by default).
- This label smoothly changes color (gradient) depending on who is dominating the market. If buyers have the upper hand, the label turns green (or your custom bullish color). If sellers take control, it turns red. It remains gray when the market is in balance.

Key Advantages of This Script:
- Versatility: It functions seamlessly both on markets with volume data (crypto, stocks) and markets without it (forex).
- Statistical Framework: Rather than guessing a trend based on simple logic like "the price is going up, so buy," it evaluates mathematical probability and volatility.

Conclusion – Overall, this is a dynamic indicator that utilizes mathematical estimations (Garman-Klass volatility, statistical Z-score, and probability distribution) to estimate the power of buyers and sellers over a selected candle lookback period.Typically, similar indicators fetch data from lower timeframes and rely on a simple logic: a red candle means a drop where sellers won, while a green candle means a rise where buyers won. They then simply aggregate the data and determine the buy/sell power based on the ratio of bullish to bearish candles.This indicator, however, attempts to reconstruct those same relationships mathematically on a single timeframe.Soon, I will release an oscillator that will serve as a historical complement to this indicator.

---

## Source Code

````pine
//@version=6
indicator("C-Power", overlay=true)

// INPUT DATA
int candlePeriod = input.int(5, title="Analysis Period (bars)", minval=2)
int labelOffset  = input.int(3, title="Label Offset", minval=0)

color customBullColor = input.color(color.rgb(34, 139, 34), title="Buyers Color (Bull Color)")
color customBearColor = input.color(color.rgb(220, 20, 60), title="Sellers Color (Bear Color)")
color customNeutColor = input.color(color.rgb(128, 128, 128), title="Balance Color (Neutral Color)")

// VOLUME FILTER
float rawVolume = nz(volume)
float processedVolume = rawVolume

float periodAvgVol = ta.alma(rawVolume, candlePeriod, 0.85, 1)
float maxAllowedVol = periodAvgVol * 3.5

if rawVolume > maxAllowedVol and periodAvgVol > 0
    processedVolume := maxAllowedVol

// COMPUTATIONAL CORE (HYBRID GK + RS + YZ)
float c_open     = open
float c_high     = high
float c_low      = low
float c_close    = close
float prev_close = nz(close[1], c_open)

float effHigh = math.max(c_high, prev_close)
float effLow  = math.max(math.min(c_low, prev_close), 0.00000001)

// YANG-ZHANG (Opening gap volatility / Overnight Gap)
float log_gap = math.log(c_open / math.max(prev_close, 0.00000001))
float yz_gap_element = math.pow(log_gap, 2.0)

// GARMAN-KLASS (Efficiency of H-L to C-O ratio)
float log_h_l = math.log(effHigh / effLow)
float log_c_o = c_open > 0 ? math.log(c_close / math.max(c_open, 0.00000001)) : 0.0
float gk_core = 0.5 * math.pow(log_h_l, 2.0) - (2.0 * math.log(2.0) - 1.0) * math.pow(log_c_o, 2.0)

// ROGERS-SATCHELL (Resilience to strong trends / Drift-Independent)
float log_h_c = math.log(effHigh / c_close)
float log_h_o = math.log(effHigh / c_open)
float log_l_c = math.log(effLow / c_close)
float log_l_o = math.log(effLow / math.max(c_open, 0.00000001))
float rs_core = log_h_c * log_h_o + log_l_c * log_l_o

// HYBRID SYNTHESIS (50/50 component weighting)
float intraday_core = (math.max(gk_core, 0.0) + math.max(rs_core, 0.0)) / 2.0
float hybrid_element = (0.5 * yz_gap_element) + (0.5 * intraday_core)

// Final volatility calculation for Z-Score
float hybrid_volatility = math.sqrt(math.max(hybrid_element, 0.0)) * c_close
float minVolatility = 0.00000001 * c_close
float finalVolatility = math.max(hybrid_volatility, minVolatility)

float midPoint = (c_open + prev_close) / 2.0
float priceImbalance = c_close - midPoint

float z_score = priceImbalance / finalVolatility

erf(x) =>
    float t = 1.0 / (1.0 + 0.5 * math.abs(x))
    float ans = 1.0 - t * math.exp(-x * x - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.01862880 + t * (0.02788680 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277)))))))))
    x >= 0 ? ans : -ans

normCDF(z) =>
    0.5 * (1.0 + erf(z / math.sqrt(2.0)))

float directionWeight = normCDF(z_score)

// MACRO AGGREGATION
float sumVolume = math.sum(processedVolume, candlePeriod)
bool hasVolume = nz(sumVolume) > 0

float buyPowerSeries  = hasVolume ? (processedVolume * directionWeight) : directionWeight
float sellPowerSeries = hasVolume ? (processedVolume * (1.0 - directionWeight)) : (1.0 - directionWeight)

float totalBuyPower  = math.sum(nz(buyPowerSeries), candlePeriod)
float totalSellPower = math.sum(nz(sellPowerSeries), candlePeriod)
float aggregatePower = totalBuyPower + totalSellPower

float periodHigh = ta.highest(effHigh, candlePeriod)
float periodLow  = ta.lowest(effLow, candlePeriod)

// LABEL VISUALIZATION
var label powerLabel = na

if barstate.islast
    float rawBuyPercent = aggregatePower > 0.0 ? (totalBuyPower / aggregatePower) * 100.0 : 50.0
  
    float finalBuyPercent = rawBuyPercent
    if finalBuyPercent >= 100.0 and c_close < periodHigh
        finalBuyPercent := 97.5
    if finalBuyPercent <= 0.0 and c_close > periodLow
        finalBuyPercent := 2.5

    float buyPercent  = math.round(finalBuyPercent / 2.5) * 2.5
    float sellPercent = 100.0 - buyPercent

    color labelColor = customNeutColor
    if buyPercent > 50.0
        labelColor := color.from_gradient(buyPercent, 50.0, 100.0, customNeutColor, customBullColor)
    else if sellPercent > 50.0
        labelColor := color.from_gradient(sellPercent, 50.0, 100.0, customNeutColor, customBearColor)

    if not na(powerLabel)
        label.delete(powerLabel)
        
    string modeText = hasVolume ? "Power" : "Pure PA"
    string labelText = modeText + " (" + str.tostring(candlePeriod) + " bars)\n" + 
                       "BUY : " + str.tostring(buyPercent, "0.0") + "%\n" + 
                       "SELL: " + str.tostring(sellPercent, "0.0") + "%"
                
    powerLabel := label.new(
         x=bar_index + labelOffset, 
         y=c_close, 
         text=labelText, 
         color=labelColor, 
         textcolor=color.white, 
         style=label.style_label_left, 
         yloc=yloc.price
         )
````
