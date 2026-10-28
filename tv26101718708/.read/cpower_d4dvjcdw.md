# C-Power

- url: https://www.tradingview.com/script/d4dVjcDw/
- type: indicator
- pine_id: PUB;c6fc5aa675f04b008097bef41abdca73
- version: 5.0

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

## Source Code

````pine
//@version=6
indicator("C-Power PRO", overlay=true)

// USER SETTINGS
int candlePeriod = input.int(7, title="Analysis Period (bars)", minval=3)
int labelOffset = input.int(5, title="Label Offset", minval=-50)
float logWeight = input.float(50.0, title="Log Structure Weight (%)", minval=0.0, maxval=100.0, step=5.0)

color customBullColor = input.color(color.rgb(34, 139, 34), title="Buyers Color")
color customBearColor = input.color(color.rgb(220, 20, 60), title="Sellers Color")
color customNeutColor = input.color(color.rgb(128, 128, 128), title="Balance Color")

bool showAnom = input.bool(true, title="Wyckoff Anomalies?")
bool showCentroid = input.bool(true, title="Show POC Points?")
bool showFull = input.bool(true, title="Full Dashboard Info (ON/OFF)")

// CORE AUXILIARY MATHEMATICAL FUNCTIONS
f_tanh(float x) =>
    float ax = math.abs(x)
    float t = math.exp(-2.0 * ax)
    float y = (1.0 - t) / (1.0 + t)
    math.sign(x) * y

erf(float x) =>  
    float clampedX = math.max(-4.0, math.min(4.0, x))
    float t = 1.0 / (1.0 + 0.5 * math.abs(clampedX))
    float ans = 1.0 - t * math.exp(-clampedX * clampedX - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.01862880 + t * (0.02788680 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277)))))))))
    clampedX >= 0.0 ? ans : -ans

normCDF(float z) =>
    0.5 * (1.0 + erf(z / math.sqrt(2.0)))

// VOLUME FILTER - ADAPTIVE SMOOTHING
float rawVolume = nz(volume)
float processedVolume = rawVolume

float periodAvgVol = ta.alma(rawVolume, candlePeriod, 0.85, 1)
float rawVolStDev = ta.stdev(rawVolume, candlePeriod)
float volStDev = na(rawVolStDev) or rawVolStDev == 0.0 ? 0.00000001 : rawVolStDev

float maxAllowedVol = periodAvgVol > 0.0 ? periodAvgVol + (4.0 * volStDev) : 0.0

if rawVolume > maxAllowedVol and periodAvgVol > 0.0
    processedVolume := maxAllowedVol

// GKYZ HYBRID CORE
float prev_close = nz(close[1], open)
float effHigh = math.max(high, prev_close)
float effLow = math.max(math.min(low, prev_close), 0.00000001)

float GK_COEF = 2.0 * math.log(2.0) - 1.0
float overnightReturn = open > 0.0 and prev_close > 0.0 ? 100.0 * math.log(open / prev_close) : 0.0
float overnightVariance = math.pow(overnightReturn, 2.0)

float pct_h_l = effHigh > 0.0 and effLow > 0.0 ? 100.0 * math.log(effHigh / effLow) : 0.0
float pct_c_o = open > 0.0 and close > 0.0 ? 100.0 * math.log(close / open) : 0.0
float gk_core = 0.5 * math.pow(pct_h_l, 2.0) - GK_COEF * math.pow(pct_c_o, 2.0)

float pct_h_c = effHigh > 0.0 and close > 0.0 ? 100.0 * math.log(effHigh / close) : 0.0
float pct_h_o = effHigh > 0.0 and open > 0.0 ? 100.0 * math.log(effHigh / open) : 0.0
float pct_l_c = effLow > 0.0 and close > 0.0 ? 100.0 * math.log(effLow / close) : 0.0
float pct_l_o = effLow > 0.0 and open > 0.0 ? 100.0 * math.log(effLow / open) : 0.0
float rs_core = pct_h_c * pct_h_o + pct_l_c * pct_l_o

float intradayVariance = (math.max(gk_core, 0.0) + math.max(rs_core, 0.0)) / 2.0
float hybrid_element = (0.5 * overnightVariance) + (0.5 * intradayVariance)
float gkyzMeanVariance = ta.alma(hybrid_element, candlePeriod, 0.85, 1.0)
float finalVolatilityPct = na(gkyzMeanVariance) or gkyzMeanVariance < 0.0 ? 0.01 : math.max(math.sqrt(gkyzMeanVariance), 0.01)

// KAUFMAN & FISHER INFO
float candleSpread = math.abs(close - open)

float prevCloseVal = nz(close[1], open)
float priceChangeAbs = math.abs(close - prevCloseVal)
float volWeightedChange = priceChangeAbs * processedVolume
float totalVolWeightedChange = math.sum(volWeightedChange, candlePeriod)

float directionalChange = (close - prevCloseVal) * processedVolume
float netVolWeightedChange = math.sum(directionalChange, candlePeriod)

float rawVWER = totalVolWeightedChange > 0.0 ? math.min(math.abs(netVolWeightedChange) / totalVolWeightedChange, 1.0) : 0.5
float efficiencyRatio = ta.alma(rawVWER, candlePeriod, 0.85, 1.0)

// Fisher Information Scaling
float fisherInf = f_tanh(efficiencyRatio * math.log(1.0 + finalVolatilityPct))
float dynamicLogWeight = logWeight * fisherInf

float midPoint = (open + prev_close) / 2.0
float interBarImbalancePct = close > 0.0 and midPoint > 0.0 ? 100.0 * math.log(close / midPoint) : 0.0
float intraLogImbalancePct = pct_c_o

float w_log = dynamicLogWeight / 100.0
float w_inter = 1.0 - w_log
float priceImbalancePct = (interBarImbalancePct * w_inter) + (intraLogImbalancePct * w_log)

// 2D MAHALANOBIS DISTANCE WYCKOFF ENGINE
float spreadStDev = math.max(ta.stdev(candleSpread, candlePeriod), 0.00000001)

float volZScore = (processedVolume - periodAvgVol) / volStDev
float spreadZScore = (candleSpread - ta.alma(candleSpread, candlePeriod, 0.85, 1)) / spreadStDev

float expected_XY = ta.alma(processedVolume * candleSpread, candlePeriod, 0.85, 1)
float cov_vol_spread = expected_XY - (periodAvgVol * ta.alma(candleSpread, candlePeriod, 0.85, 1))
float r_corr = cov_vol_spread / math.max(volStDev * spreadStDev, 0.00000001)
float r_clamped = math.max(-0.99, math.min(0.99, r_corr))
float mahalanobis_sq = (1.0 / (1.0 - math.pow(r_clamped, 2.0))) * (math.pow(volZScore, 2.0) + math.pow(spreadZScore, 2.0) - 2.0 * r_clamped * volZScore * spreadZScore)
float mahalanobis_dist = math.sqrt(math.max(mahalanobis_sq, 0.0))
float rawEffortScore = (volZScore > 0.0 and spreadZScore < volZScore) ? mahalanobis_dist : 0.0
float continuousAnomalyWeight = f_tanh(rawEffortScore * 0.5)

float candleRange = high - low
float closePosition = candleRange > 0.0 ? (close - low) / candleRange : 0.5
float volumeFlowDirection = (closePosition - 0.5) * 2.0 

if showAnom
    float anomalyAdjustmentPct = volumeFlowDirection * continuousAnomalyWeight * finalVolatilityPct * 0.4
    priceImbalancePct := priceImbalancePct + anomalyAdjustmentPct

// RE-BALANCED Z-SCORE & MACRO AGGREGATION
float z_score = priceImbalancePct / finalVolatilityPct
float directionWeight = normCDF(z_score)

float sumVolume = math.sum(processedVolume, candlePeriod)
bool hasVolume = nz(sumVolume) > 0.0

float buyPowerSeries = hasVolume ? (processedVolume * directionWeight) : directionWeight
float sellPowerSeries = hasVolume ? (processedVolume * (1.0 - directionWeight)) : (1.0 - directionWeight)

float totalBuyPower = math.sum(nz(buyPowerSeries), candlePeriod)
float totalSellPower = math.sum(nz(sellPowerSeries), candlePeriod)
float aggregatePower = totalBuyPower + totalSellPower

float periodHigh = ta.highest(effHigh, candlePeriod)
float periodLow = ta.lowest(effLow, candlePeriod)

// STRENGTH trend S-TR
float rawSign = math.sign(netVolWeightedChange)
float netDirectionSign = na(rawSign) ? 0.0 : rawSign
float rawDirectionalSTR = efficiencyRatio * netDirectionSign * 100.0

float avgAnomalyWeight = ta.alma(continuousAnomalyWeight, candlePeriod, 0.85, 1)
float stdAnomalyWeight = math.max(ta.stdev(continuousAnomalyWeight, candlePeriod), 0.00000001)

float rawThreshold = avgAnomalyWeight + (1.28 * stdAnomalyWeight)
float dynamicAnomThreshold = math.max(0.50, math.min(0.90, rawThreshold))
bool isAnomalousVol = continuousAnomalyWeight > dynamicAnomThreshold

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float totalWicks = upperWick + lowerWick
float wickPressurePct = candleRange > 0.0 ? (upperWick - lowerWick) / candleRange * 100.0 : 0.0

float midCandle = (high + low) / 2.0

float p_momentum = (close - open) / math.max(candleSpread, 0.00000001)
float knotAsymmetry = totalWicks > 0.0 ? (lowerWick - upperWick) / totalWicks : 0.0
float gravityShift = (volumeFlowDirection * 0.3) + (knotAsymmetry * 0.15) + (p_momentum * 0.05)
float parabolicPOCFactor = 0.5 + math.max(-0.45, math.min(0.45, gravityShift))
float parabolicCentroid = low + (candleRange * parabolicPOCFactor)

float candleCentroid = candleRange > 0.0 ? parabolicCentroid : midCandle

float rawBuyPercent = aggregatePower > 0.0 ? (totalBuyPower / aggregatePower) * 100.0 : 50.0
float finalBuyPercent = rawBuyPercent
if finalBuyPercent >= 100.0 and close < periodHigh
    finalBuyPercent := 97.5
if finalBuyPercent <= 0.0 and close > periodLow
    finalBuyPercent := 2.5

float buyPercentRaw = finalBuyPercent
float sellPercentRaw = 100.0 - finalBuyPercent

float velocityRatioRaw = candleRange > 0.0 ? math.abs(close - open) / candleRange * 100.0 : 0.0
float avgVelocity = ta.alma(velocityRatioRaw, candlePeriod, 0.85, 1)
float stdVelocity = math.max(ta.stdev(velocityRatioRaw, candlePeriod), 0.00000001)
float velocityPercentile = normCDF((velocityRatioRaw - avgVelocity) / stdVelocity)

float wickRatio = candleRange > 0.0 ? totalWicks / candleRange * 100.0 : 0.0
float avgWickRatio = ta.alma(wickRatio, candlePeriod, 0.85, 1)
float stdWickRatio = math.max(ta.stdev(wickRatio, candlePeriod), 0.00000001)
float wickPercentile = normCDF((wickRatio - avgWickRatio) / stdWickRatio)

float microImbalance = totalWicks > 0.0 ? math.abs(close - open) / math.max(totalWicks, 0.00000001) : 1.0
float avgMicroImbalance = math.max(ta.alma(microImbalance, candlePeriod, 0.85, 1), 0.00000001)
float normalizedImbalancePctRaw = math.min((microImbalance / avgMicroImbalance) * 50.0, 100.0)

// STATISTICAL PATTERN ENGINE
string dynamicSignal = "Neutral Balanced"

if candleRange > 0.0
    if velocityPercentile > 0.90 and normalizedImbalancePctRaw > 75.0
        dynamicSignal := close > open ? "🚀 Algo Expans (Bull)" : "📉 Algo Expans (Bear)"
    else if velocityPercentile < 0.30 and wickPercentile > 0.85
        if lowerWick > upperWick * 1.5 and close > candleCentroid
            dynamicSignal := "🟢 Bull Liquid Sweep"
        else if upperWick > lowerWick * 1.5 and close < candleCentroid
            dynamicSignal := "🔴 Bear Liquid Sweep"
    else if velocityPercentile > 0.75
        if close > open and upperWick / candleRange > 0.25 and close < candleCentroid
            dynamicSignal := "⚠️ Bear Absorp (Buy Trapp)"
        else if close < open and lowerWick / candleRange > 0.25 and close > candleCentroid
            dynamicSignal := "⚠️ Bull Absorp (Sell Trapp)"

// GLOBAL SMOOTHING
float smoothBuyPercentRaw = ta.alma(buyPercentRaw, 5, 0.85, 1.5)
float smoothSellPercentRaw = ta.alma(sellPercentRaw, 5, 0.85, 1.5)
float smoothDirectionalSTRRaw = ta.alma(rawDirectionalSTR, 5, 0.85, 1.5)
float smoothWickPressurePctRaw = ta.alma(wickPressurePct, 5, 0.85, 1.5)
float smoothVelocityRatioRaw = ta.alma(velocityRatioRaw, 5, 0.85, 1.5)
float smoothNormalizedImbPctRaw = ta.alma(normalizedImbalancePctRaw, 3, 0.85, 1.5)

// QUANT
float smoothBuyPercent = math.round(smoothBuyPercentRaw / 2.5) * 2.5
float smoothSellPercent = math.round(smoothSellPercentRaw / 2.5) * 2.5
float smoothDirectionalSTR = math.round(smoothDirectionalSTRRaw / 2.5) * 2.5
float smoothWickPressurePct = math.round(smoothWickPressurePctRaw / 2.5) * 2.5
float smoothVelocityRatio = math.round(smoothVelocityRatioRaw / 2.5) * 2.5
float smoothNormalizedImbPct = math.round(smoothNormalizedImbPctRaw / 2.5) * 2.5

plotchar(showCentroid ? candleCentroid : na, title="Center (POC)", char="•", location=location.absolute, color=close > candleCentroid ? customBullColor : customBearColor, size=size.tiny)

if barstate.islast
    var label powerLabel = label.new(
         x=bar_index + labelOffset, 
         y=close, 
         text="", 
         color=customNeutColor, 
         textcolor=color.white, 
         style=label.style_label_left, 
         yloc=yloc.price
         )

    color labelColor = customNeutColor
    if smoothBuyPercent > 50.0
        labelColor := color.from_gradient(smoothBuyPercent, 50.0, 100.0, customNeutColor, customBullColor)
    else if smoothSellPercent > 50.0
        labelColor := color.from_gradient(smoothSellPercent, 50.0, 100.0, customNeutColor, customBearColor)
        
    string modeText = hasVolume ? "POWER" : "Pure PA"
    string anomStatus = isAnomalousVol and showAnom ? "\n🔥 WYCKOFF ANOMALY" : ""
    
    string strSign = smoothDirectionalSTR > 0.0 ? "+" : ""
    string strFormatted = strSign + str.tostring(smoothDirectionalSTR, "0.0") + "%"
    
    string wickDir = smoothWickPressurePct > 0.0 ? "Bear" : "Bull"
    string wickPressureStr = str.tostring(math.abs(smoothWickPressurePct), "0.0") + "% (" + wickDir + ")"
    
    string powerSection = "= " + modeText + " (" + str.tostring(candlePeriod) + " bars) =\n" + "BUY :  " + str.tostring(smoothBuyPercent, "0.0") + "%\n" + "SELL :  " + str.tostring(smoothSellPercent, "0.0") + "%\n" + "S-TR : " + strFormatted
    string intraSection = "= INTRA-CANDLE =\nW-Press : " + wickPressureStr + "\nVelocity : " + str.tostring(smoothVelocityRatio, "0.0") + "%\nImbalance : " + str.tostring(smoothNormalizedImbPct, "0.0") + "%"
    string signalSection = "= CANDLE SIGNAL =\n" + dynamicSignal

    string labelText = ""
    if showFull
        labelText := powerSection + "\n\n" + intraSection + "\n\n" + signalSection + anomStatus
    else
        labelText := powerSection + anomStatus
         
    powerLabel.set_x(bar_index + labelOffset)
    powerLabel.set_y(close)
    powerLabel.set_text(labelText)
    powerLabel.set_color(labelColor)
````
