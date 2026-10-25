# VWAP Suite | Trend & Mean Reversion with Adaptive Filters

- url: https://www.tradingview.com/script/L7P3quUz-VWAP-Suite-Trend-Mean-Reversion-with-Adaptive-Filters/
- type: strategy
- pine_id: PUB;fb5e03cfda9244b3b2c437f5453ee5db
- version: 1.0

## Description

[b]Overview[/b]
This strategy is built around a custom volume-weighted average price (VWAP) engine with standard-deviation bands, and gives you two complete, independently-tuned trading modes in a single script:

Trend Following — trades breakouts/crossovers in the direction of VWAP's own momentum
Mean Reversion — trades stretched price extremes back toward VWAP, filtered for low-trend conditions

Rather than assuming one style of market behavior, this script lets you choose the mode that matches what you're trading — a trending momentum stock, or a calmer range-bound one — and includes a layered filter system designed to keep you out of low-quality setups in either mode.

[b]How VWAP Is Calculated[/b]
VWAP weights price by the volume traded at that price, rather than treating all price ticks equally — so it reflects where the real trading activity concentrated, not just a simple average. 

This script computes it manually (not via a black-box built-in), which allows for flexible anchoring:
Session — resets daily (best for lower timeframes, intraday charts)
Week — resets weekly (better for 1H–4H charts)
Month — resets monthly (for swing/position-style testing)

Standard deviation bands are plotted at three levels (1, 2, and 3 std dev by default), giving visual reference points for "normal," "stretched," and "extreme" price deviation from the volume-weighted average.

[b]Strategy Modes[/b]

Trend Following
[list]
[*]Looks for price to break through VWAP (or an outer band) in a direction confirmed by VWAP's own slope — the idea being that VWAP acting as support/resistance and trending in your trade's direction adds conviction to the move.
[*]Three selectable entry triggers: VWAP Cross, Band 1 Break, Band 2 Break
[*]VWAP slope filter (with adjustable lookback and minimum slope %) to avoid trading flat/directionless VWAP
[*]Take-profit targets at the opposite band or at VWAP itself
[*]Best suited for: momentum-driven, higher-volatility names where trends persist once established.
[/list]

Mean Reversion
[list]
[*]Looks for price to overextend beyond a chosen band, then trades the snap-back toward VWAP. Includes an ADX filter to specifically avoid taking reversion trades during strongly trending conditions (where "buying the dip" or "fading the rip" is historically much riskier).
[*]Three selectable entry triggers: Outside Band, Band Cross, Band Reclaim (wick-and-recover confirmation — the most conservative/false-signal-resistant option)
[*]ADX filter caps entries below a configurable trend-strength threshold
[*]Maximum VWAP deviation cap (in ATR units) to avoid catching a falling knife on extreme extensions
[*]Best suited for: range-bound, lower-volatility names where price oscillates predictably around a stable average.
[/list]

[b]Filter System (False-Signal Reduction)[/b]
Every entry — in either mode — passes through a shared base filter layer before mode-specific logic is applied:
[list]
[*]Volume Filter: Requires volume above a multiple of its recent average, filtering out low-conviction moves
[*]Volatility (ATR) Filter: Requires a minimum ATR (as % of price) to avoid dead, directionless conditions
[*]Band Width Filter: Avoids trading when bands are unusually tight (a sign of indecision and high whipsaw risk)
[*]VWAP Slope Filter	(Trend mode): Confirms VWAP itself is moving meaningfully in the trade direction, not just flat
[*]ADX Filter (Mean Reversion mode): Blocks entries when the broader trend is too strong to safely fade
[/list]
Each filter can be toggled independently, so you can isolate which conditions matter most for the instrument and timeframe you're trading.

[b]Optional Confluence Layer[/b]
A secondary indicator can be layered on top of either mode:
[list]
[*]RSI — for trend mode, confirms momentum direction; for mean reversion, confirms oversold/overbought exhaustion via a crossover trigger
[*]EMA Regime (200-period default) — acts as a higher-level trend filter, only allowing longs above the EMA and shorts below it
[/list]
[b]Risk Management[/b]
[list]
[*]Risk-based position sizing — position size is calculated from your risk % input divided by stop distance, not a fixed share count
[*]Maximum position size cap (% of equity) — acts as a hard ceiling so tight-stop trades can't produce oversized positions
[*]Two stop-loss methods — ATR-multiple based, or band-based (using the outer bands as structural stop references)
[*]Two take-profit methods — opposite band target, or VWAP itself
[*]Optional fixed take-profit lock — freezes the target price at entry rather than letting it drift with VWAP
[*]Optional break-even stop — moves the stop to entry once a configurable ATR-multiple of profit is reached
[/list]

[b]Visuals[/b]
[list]
[*]VWAP line color-shifts between two colors depending on whether price is above or below it
[*]Three-tier shaded band system for at-a-glance visual reference of price deviation
[*]Entry markers (triangle up/down) plotted directly on signal bars
[*]Background shading during filtered/no-trade conditions, so you can visually see why the strategy stayed flat
[/list]

[b]Important Notes Before Use[/b]
Match your anchor period to your timeframe. Session anchoring is built for intraday charts; on higher timeframes (2H+), Week or Month anchoring will produce more reliable slope readings, since Session resets can occur every few bars and distort trend measurement.

Backtest results include commission assumptions but not slippage — adjust the commission/slippage settings in the strategy properties to reflect your actual broker before drawing conclusions from performance metrics.

[i]This script is provided for research and educational purposes. Past performance in backtesting does not guarantee future results. Always forward-test on a paper account before committing real capital.[/i]

## Source Code

````pine
//@version=6
strategy("VWAP Strategy (Trend + Mean Reversion)", overlay=true,
     default_qty_type=strategy.fixed, default_qty_value=1,
     initial_capital=100000, commission_type=strategy.commission.percent, commission_value=0.05, pyramiding=0)

//User Inputs
anchorPeriod = input.string("Session", "VWAP Anchor Period", ["Session", "Week", "Month"])
strategyMode = input.string("Trend Following", "Strategy Mode", ["Trend Following", "Mean Reversion"])

band1Mult = input.float(1.0, "Band 1 (St Dev Mult)", step=0.1)
band2Mult = input.float(2.0, "Band 2 (St Dev Mult)", step=0.1)
band3Mult = input.float(3.0, "Band 3 (St Dev Mult)", step=0.1)

useVolumeFilter = input.bool(true, "Use Volume Filter")
volumeThresh = input.float(1.2, "Volume Threshold", step=0.1)
volumeLength = input.int(20, "Volume Average Length", minval=1)

useSlopeFilter = input.bool(true, "Use VWAP Slope Filter")
slopeLookback = input.int(5, "Slope Lookback (bars)", minval=1)
minSlopePct = input.float(0.05, "Minimum VWAP Slope (%)", step=0.01)

useVolatilityFilter = input.bool(true, "Use Volatility (ATR) Filter")
atrLength = input.int(14, "ATR Length", minval=1)
atrThresh = input.float(0.2, "Minimum ATR (% of Price)", step=0.05)

useBandwidthFilter = input.bool(true, "Use Band Width Filter")
minBandwidthPercent = input.float(0.2, "Minimum Bandwidth (% Price)", step=0.05)

secondaryIndicator = input.string("None", "Secondary Indicator", ["None", "RSI", "EMA Regime"])
rsiLength = input.int(14, "RSI Length", minval=1)
rsiTrendLongMin = input.int(50, "Trend RSI Minimum for Longs", minval=0, maxval=100)
rsiTrendShortMax = input.int(50, "Trend RSI Maximum for Shorts", minval=0, maxval=100)
rsiMeanRevOversold = input.int(30, "Mean Reversion RSI Oversold", minval=1, maxval=50)
rsiMeanRevOverbought = input.int(70, "Mean Reversion RSI Overbought", minval=50, maxval=99)
emaLength = input.int(200, "EMA Regime Length", minval=1)

useADXFilter = input.bool(true, "Use ADX Filter")
adxLength = input.int(14, "ADX Length", minval=1)
maxADXForMeanReversion = input.float(25.0, "Maximum ADX", step=1.0)

trendEntryType = input.string("VWAP Cross", "Trend Entry Trigger", ["VWAP Cross", "Band 1 Break", "Band 2 Break"])

meanRevEntryType = input.string("Band Reclaim", "Mean Reversion Entry Trigger", ["Outside Band", "Band Cross", "Band Reclaim"])
meanRevBand = input.string("Band 2", "Mean Reversion Entry Band", ["Band 1", "Band 2", "Band 3"])
maxMeanRevDeviation = input.float(3.0, "Maximum VWAP Deviation (ATR)", step=0.1)

riskPercent = input.float(1.0, "Risk per Trade (%)", step=0.1, minval=0.1)
maxPositionPercent = input.float(20.0, "Maximum Position Size (% Equity)", step=5.0, minval=1.0)
stopLossMethod = input.string("ATR", "Stop Loss Method", ["Band Based", "ATR"])
stopATRMult = input.float(1.5, "Stop ATR Multiple", step=0.1)

profitMethod = input.string("Opposite Band", "Take Profit Method", ["Opposite Band", "VWAP Target"])
useFixedTakeProfit = input.bool(false, "Lock Take Profit at Entry")

useBreakEven = input.bool(false, "Use Break-Even Stop")
breakEvenATR = input.float(1.0, "Profit Required Before Break-Even (ATR)", step=0.1)

//VWAP Calculations
typicalPrice = (high+low+close)/3
var float cumPV  = 0.0
var float cumVol = 0.0
var float cumPV2 = 0.0   // for variance: sum(vol * price^2)

isNewPeriod = switch anchorPeriod
    "Session" => ta.change(time("D")) != 0
    "Week"    => ta.change(time("W")) != 0
    "Month"   => ta.change(time("M")) != 0

if isNewPeriod
    cumPV  := 0.0
    cumVol := 0.0
    cumPV2 := 0.0

cumPV  += typicalPrice * volume
cumVol += volume
cumPV2 += volume * math.pow(typicalPrice, 2)

vwapValue = cumVol != 0 ? cumPV / cumVol : typicalPrice

// Volume-weighted variance -> standard deviation
variance = cumVol != 0 ? (cumPV2 / cumVol) - math.pow(vwapValue, 2) : 0.0
vwapStdDev = math.sqrt(math.max(variance, 0.0))

upperBand1 = vwapValue + vwapStdDev * band1Mult
lowerBand1 = vwapValue - vwapStdDev * band1Mult
upperBand2 = vwapValue + vwapStdDev * band2Mult
lowerBand2 = vwapValue - vwapStdDev * band2Mult
upperBand3 = vwapValue + vwapStdDev * band3Mult
lowerBand3 = vwapValue - vwapStdDev * band3Mult

//Indicators
atrValue = ta.atr(atrLength)
rsiValue = ta.rsi(close, rsiLength)
regimeEma = ta.ema(close, emaLength)
avgVolume = ta.sma(volume, volumeLength)
[diPlus, diMinus, adxValue] = ta.dmi(adxLength, adxLength)

//Filter conditions
volumeOK = not useVolumeFilter or volume > avgVolume*volumeThresh

atrPct = (atrValue / close) * 100
volatilityOK = not useVolatilityFilter or atrPct > atrThresh

bandWidthPct = ((upperBand1 - lowerBand1) / close) * 100
bandWidthOK = not useBandwidthFilter or bandWidthPct > minBandwidthPercent

vwapSlopePct = not na(vwapValue[slopeLookback]) ? ((vwapValue - vwapValue[slopeLookback]) / vwapValue[slopeLookback]) * 100 : 0.0
slopeLongOK = not useSlopeFilter or vwapSlopePct > minSlopePct
slopeShortOK = not useSlopeFilter or vwapSlopePct < -minSlopePct

baseFiltersOK = volumeOK and volatilityOK and bandWidthOK

adxOK = not useADXFilter or adxValue < maxADXForMeanReversion

vwapDistanceATR = atrValue > 0 ? (close - vwapValue) / atrValue : 0.0
meanRevDeviationOK = math.abs(vwapDistanceATR) <= maxMeanRevDeviation

//Secondary indicators
trendRSILongOK = rsiValue > rsiTrendLongMin
trendRSIShortOK = rsiValue < rsiTrendShortMax
meanRevRSILongOK = ta.crossover(rsiValue, rsiMeanRevOversold)
meanRevRSIShortOK = ta.crossunder(rsiValue, rsiMeanRevOverbought)
emaLongOK = close > regimeEma
emaShortOK = close < regimeEma

trendConfluenceLong = switch secondaryIndicator
    "RSI"        => trendRSILongOK
    "EMA Regime" => emaLongOK
    => true

trendConfluenceShort = switch secondaryIndicator
    "RSI"        => trendRSIShortOK
    "EMA Regime" => emaShortOK
    => true

meanRevConfluenceLong = switch secondaryIndicator
    "RSI"        => meanRevRSILongOK
    "EMA Regime" => emaLongOK
    => true

meanRevConfluenceShort = switch secondaryIndicator
    "RSI"        => meanRevRSIShortOK
    "EMA Regime" => emaShortOK
    => true

//Mean reversion band selection
meanRevUpperBand = switch meanRevBand
    "Band 1" => upperBand1
    "Band 2" => upperBand2
    "Band 3" => upperBand3

meanRevLowerBand = switch meanRevBand
    "Band 1" => lowerBand1
    "Band 2" => lowerBand2
    "Band 3" => lowerBand3

//Entry triggers
trendLongTrigger = switch trendEntryType
    "VWAP Cross"   => ta.crossover(close, vwapValue)
    "Band 1 Break" => ta.crossover(close, upperBand1)
    "Band 2 Break" => ta.crossover(close, upperBand2)

trendShortTrigger = switch trendEntryType
    "VWAP Cross"   => ta.crossunder(close, vwapValue)
    "Band 1 Break" => ta.crossunder(close, lowerBand1)
    "Band 2 Break" => ta.crossunder(close, lowerBand2)

meanRevLongTrigger = switch meanRevEntryType
    "Outside Band" => close < meanRevLowerBand
    "Band Cross"   => ta.crossunder(close, meanRevLowerBand)
    "Band Reclaim" => low < meanRevLowerBand and close > meanRevLowerBand

meanRevShortTrigger = switch meanRevEntryType
    "Outside Band" => close > meanRevUpperBand
    "Band Cross"   => ta.crossover(close, meanRevUpperBand)
    "Band Reclaim" => high > meanRevUpperBand and close < meanRevUpperBand

//Entry
longCondition  = false
shortCondition = false

if strategyMode == "Trend Following"
    longCondition  := trendLongTrigger and baseFiltersOK and slopeLongOK and trendConfluenceLong
    shortCondition := trendShortTrigger and baseFiltersOK and slopeShortOK and trendConfluenceShort
else
    longCondition  := meanRevLongTrigger and baseFiltersOK and adxOK and meanRevDeviationOK and meanRevConfluenceLong
    shortCondition := meanRevShortTrigger and baseFiltersOK and adxOK and meanRevDeviationOK and meanRevConfluenceShort

//Risk and Position Sizing
trendLongStopDistance = stopLossMethod == "ATR" ? atrValue*stopATRMult : math.abs(close - lowerBand1)
trendShortStopDistance = stopLossMethod == "ATR" ? atrValue*stopATRMult : math.abs(upperBand1 - close)
meanRevLongStopDistance = stopLossMethod == "ATR" ? atrValue*stopATRMult : math.abs(close - lowerBand3)
meanRevShortStopDistance = stopLossMethod == "ATR" ? atrValue*stopATRMult : math.abs(upperBand3 - close)

longStopDistance = strategyMode == "Trend Following" ? trendLongStopDistance : meanRevLongStopDistance
shortStopDistance = strategyMode == "Trend Following" ? trendShortStopDistance : meanRevShortStopDistance

riskAmount = strategy.equity * (riskPercent / 100)
maxPositionValue = strategy.equity * (maxPositionPercent / 100)
rawQtyLong = longStopDistance > 0 ? riskAmount / longStopDistance : 0
rawQtyShort = shortStopDistance > 0 ? riskAmount / shortStopDistance : 0
maxQty = close > 0 ? maxPositionValue / close : 0
qtyLong = math.min(rawQtyLong, maxQty)
qtyShort = math.min(rawQtyShort, maxQty)

//Trade variables
var float longStopPrice = na
var float shortStopPrice = na
var float longTakeProfit = na
var float shortTakeProfit = na
var float entryATR = na

longTarget = profitMethod == "VWAP Target" ? vwapValue : strategyMode == "Trend Following" ? upperBand2 : vwapValue
shortTarget = profitMethod == "VWAP Target" ? vwapValue : strategyMode == "Trend Following" ? lowerBand2 : vwapValue

//Entries
if longCondition and strategy.position_size == 0
    longStopPrice := close - longStopDistance
    longTakeProfit := longTarget
    entryATR := atrValue
    strategy.entry("Long", strategy.long, qty=qtyLong)

if shortCondition and strategy.position_size == 0
    shortStopPrice := close + shortStopDistance
    shortTakeProfit := shortTarget
    entryATR := atrValue
    strategy.entry("Short", strategy.short, qty=qtyShort)

//Break-even management
if strategy.position_size > 0 and useBreakEven
    breakEvenTrigger = strategy.position_avg_price + entryATR * breakEvenATR
    if high >= breakEvenTrigger
        longStopPrice := math.max(longStopPrice, strategy.position_avg_price)

if strategy.position_size < 0 and useBreakEven
    breakEvenTrigger = strategy.position_avg_price - entryATR * breakEvenATR
    if low <= breakEvenTrigger
        shortStopPrice := math.min(shortStopPrice, strategy.position_avg_price)

//Exits
if strategy.position_size > 0
    currentLongTarget = useFixedTakeProfit ? longTakeProfit : longTarget
    strategy.exit("Long Exit", "Long", stop=longStopPrice, limit=currentLongTarget)

if strategy.position_size < 0
    currentShortTarget = useFixedTakeProfit ? shortTakeProfit : shortTarget
    strategy.exit("Short Exit", "Short", stop=shortStopPrice, limit=currentShortTarget)

//Reset trade variables after close
if strategy.position_size == 0 and strategy.position_size[1] != 0
    longStopPrice := na
    shortStopPrice := na
    longTakeProfit := na
    shortTakeProfit := na
    entryATR := na

//Visuals
vwapColor = close > vwapValue ? color.lime : color.red
plot(vwapValue, "VWAP", color=vwapColor, linewidth=2)
plotUpper1 = plot(upperBand1, "Upper Band 1", color=color.new(color.gray, 50))
plotLower1 = plot(lowerBand1, "Lower Band 1", color=color.new(color.gray, 50))
plotUpper2 = plot(upperBand2, "Upper Band 2", color=color.new(color.orange, 60))
plotLower2 = plot(lowerBand2, "Lower Band 2", color=color.new(color.orange, 60))
plotUpper3 = plot(upperBand3, "Upper Band 3", color=color.new(color.red, 70))
plotLower3 = plot(lowerBand3, "Lower Band 3", color=color.new(color.red, 70))

fill(plotUpper1, plotLower1, color=color.new(color.gray, 92))
fill(plotUpper2, plotUpper1, color=color.new(color.orange, 94))
fill(plotLower1, plotLower2, color=color.new(color.orange, 94))
fill(plotUpper3, plotUpper2, color=color.new(color.red, 95))
fill(plotLower2, plotLower3, color=color.new(color.red, 95))

plotshape(longCondition and strategy.position_size == 0, "Long Signal", shape.triangleup, location.belowbar, color=color.lime, size=size.tiny, text="L")
plotshape(shortCondition and strategy.position_size == 0, "Short Signal", shape.triangledown, location.abovebar, color=color.red, size=size.tiny, text="S")
````
