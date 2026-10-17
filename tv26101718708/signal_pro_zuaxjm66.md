# Signal Pro

- url: https://www.tradingview.com/script/ZUaXJM66-Signal-Pro/
- type: indicator
- pine_id: PUB;a770422eea354607bab7681da2b4c240
- version: 1.0

## Description

Signal Pro indictor - this idicator add dashboard with signal

## Source Code

````pine
//@version=6
indicator("Signal Pro", shorttitle="Signal Pro", overlay=true, max_bars_back=500)

//------------------------------------------------------------------------------
// Color palette and score constants
//------------------------------------------------------------------------------
STRONG_BULLISH_COLOR = color.rgb(0, 100, 0)
BULLISH_COLOR = color.rgb(102, 187, 106)
NEUTRAL_COLOR = color.rgb(128, 128, 128)
BEARISH_COLOR = color.rgb(255, 152, 0)
STRONG_BEARISH_COLOR = color.rgb(220, 53, 69)
PANEL_BACKGROUND = color.rgb(14, 20, 28)
PANEL_BORDER = color.rgb(42, 54, 68)
HEADER_BACKGROUND = color.rgb(20, 28, 38)
EPSILON = math.max(syminfo.mintick, 0.0000001)
ANNUALIZATION_FACTOR = math.sqrt(365.0)

SIGNAL_STRONG_BEARISH = -2
SIGNAL_BEARISH = -1
SIGNAL_NEUTRAL = 0
SIGNAL_BULLISH = 1
SIGNAL_STRONG_BULLISH = 2

// Original specification weights normalized after removing Smart Money.
TREND_WEIGHT = 0.40
MOMENTUM_WEIGHT = 0.2666666667
VOLUME_WEIGHT = 0.20
VOLATILITY_WEIGHT = 0.1333333333

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
GROUP_GENERAL = "General Settings"
GROUP_TREND = "Trend Settings"
GROUP_MOMENTUM = "Momentum Settings"
GROUP_VOLUME = "Volume Settings"
GROUP_VOLATILITY = "Volatility Settings"

analysisTimeframeInput = input.timeframe("", "Analysis Timeframe", group=GROUP_GENERAL, display=display.none)
compactMobileMode = input.bool(true, "Compact Mobile Layout", group=GROUP_GENERAL, display=display.none)
showCompactSignalGrid = input.bool(false, "Show Compact Signal Grid", group=GROUP_GENERAL, display=display.none)
dashboardPositionInput = input.string("Bottom Left", "Dashboard Position", options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group=GROUP_GENERAL, display=display.none)
signalGridPositionInput = input.string("Bottom Right", "Signal Grid Position", options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group=GROUP_GENERAL, display=display.none)
analysisTimeframe = analysisTimeframeInput == "" ? timeframe.period : analysisTimeframeInput
analysisTimeframeLabel = analysisTimeframeInput == "" ? "Chart" : analysisTimeframeInput

emaTrendEnabled = input.bool(true, "EMA Trend", group=GROUP_TREND, inline="trend_ema", display=display.none)
emaTrendLength = input.int(21, "Len", minval=2, maxval=300, group=GROUP_TREND, inline="trend_ema", display=display.none)
emaTrendSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TREND, inline="trend_ema", display=display.none)
emaTrendLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_TREND, inline="trend_ema", display=display.none)

macdEnabled = input.bool(true, "MACD", group=GROUP_TREND, inline="trend_macd", display=display.none)
macdLength = input.int(26, "Len", minval=4, maxval=300, group=GROUP_TREND, inline="trend_macd", display=display.none)
macdSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TREND, inline="trend_macd", display=display.none)
macdLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_TREND, inline="trend_macd", display=display.none)

supertrendEnabled = input.bool(true, "Supertrend", group=GROUP_TREND, inline="trend_st", display=display.none)
supertrendLength = input.int(10, "Len", minval=2, maxval=300, group=GROUP_TREND, inline="trend_st", display=display.none)
supertrendSensitivity = input.float(1.5, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TREND, inline="trend_st", display=display.none)
supertrendLookback = input.int(4, "Lookback", minval=1, maxval=100, group=GROUP_TREND, inline="trend_st", display=display.none)

ichimokuEnabled = input.bool(true, "Ichimoku Trend", group=GROUP_TREND, inline="trend_ichi", display=display.none)
ichimokuLength = input.int(26, "Len", minval=5, maxval=300, group=GROUP_TREND, inline="trend_ichi", display=display.none)
ichimokuSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TREND, inline="trend_ichi", display=display.none)
ichimokuLookback = input.int(9, "Lookback", minval=1, maxval=100, group=GROUP_TREND, inline="trend_ichi", display=display.none)

psarEnabled = input.bool(true, "Parabolic SAR", group=GROUP_TREND, inline="trend_psar", display=display.none)
psarLength = input.int(14, "Len", minval=2, maxval=300, group=GROUP_TREND, inline="trend_psar", display=display.none)
psarSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_TREND, inline="trend_psar", display=display.none)
psarLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_TREND, inline="trend_psar", display=display.none)

rsiEnabled = input.bool(true, "RSI", group=GROUP_MOMENTUM, inline="mom_rsi", display=display.none)
rsiLength = input.int(14, "Len", minval=2, maxval=300, group=GROUP_MOMENTUM, inline="mom_rsi", display=display.none)
rsiSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_MOMENTUM, inline="mom_rsi", display=display.none)
rsiLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_MOMENTUM, inline="mom_rsi", display=display.none)

stochRsiEnabled = input.bool(true, "Stochastic RSI", group=GROUP_MOMENTUM, inline="mom_stoch", display=display.none)
stochRsiLength = input.int(14, "Len", minval=2, maxval=300, group=GROUP_MOMENTUM, inline="mom_stoch", display=display.none)
stochRsiSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_MOMENTUM, inline="mom_stoch", display=display.none)
stochRsiLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_MOMENTUM, inline="mom_stoch", display=display.none)

cciEnabled = input.bool(true, "CCI", group=GROUP_MOMENTUM, inline="mom_cci", display=display.none)
cciLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_MOMENTUM, inline="mom_cci", display=display.none)
cciSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_MOMENTUM, inline="mom_cci", display=display.none)
cciLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_MOMENTUM, inline="mom_cci", display=display.none)

williamsEnabled = input.bool(true, "Williams %R", group=GROUP_MOMENTUM, inline="mom_wpr", display=display.none)
williamsLength = input.int(14, "Len", minval=2, maxval=300, group=GROUP_MOMENTUM, inline="mom_wpr", display=display.none)
williamsSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_MOMENTUM, inline="mom_wpr", display=display.none)
williamsLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_MOMENTUM, inline="mom_wpr", display=display.none)

rocEnabled = input.bool(true, "ROC", group=GROUP_MOMENTUM, inline="mom_roc", display=display.none)
rocLength = input.int(12, "Len", minval=2, maxval=300, group=GROUP_MOMENTUM, inline="mom_roc", display=display.none)
rocSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_MOMENTUM, inline="mom_roc", display=display.none)
rocLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_MOMENTUM, inline="mom_roc", display=display.none)

vwapEnabled = input.bool(true, "VWAP", group=GROUP_VOLUME, inline="vol_vwap", display=display.none)
vwapLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLUME, inline="vol_vwap", display=display.none)
vwapSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLUME, inline="vol_vwap", display=display.none)
vwapLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLUME, inline="vol_vwap", display=display.none)

obvEnabled = input.bool(true, "OBV", group=GROUP_VOLUME, inline="vol_obv", display=display.none)
obvLength = input.int(21, "Len", minval=2, maxval=300, group=GROUP_VOLUME, inline="vol_obv", display=display.none)
obvSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLUME, inline="vol_obv", display=display.none)
obvLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLUME, inline="vol_obv", display=display.none)

adlEnabled = input.bool(true, "Accumulation Distribution", group=GROUP_VOLUME, inline="vol_adl", display=display.none)
adlLength = input.int(21, "Len", minval=2, maxval=300, group=GROUP_VOLUME, inline="vol_adl", display=display.none)
adlSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLUME, inline="vol_adl", display=display.none)
adlLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLUME, inline="vol_adl", display=display.none)

volumeMaEnabled = input.bool(true, "Volume Moving Average", group=GROUP_VOLUME, inline="vol_ma", display=display.none)
volumeMaLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLUME, inline="vol_ma", display=display.none)
volumeMaSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLUME, inline="vol_ma", display=display.none)
volumeMaLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLUME, inline="vol_ma", display=display.none)

volumeDeltaEnabled = input.bool(true, "Volume Delta Proxy", group=GROUP_VOLUME, inline="vol_delta", display=display.none)
volumeDeltaLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLUME, inline="vol_delta", display=display.none)
volumeDeltaSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLUME, inline="vol_delta", display=display.none)
volumeDeltaLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLUME, inline="vol_delta", display=display.none)

atrEnabled = input.bool(true, "ATR", group=GROUP_VOLATILITY, inline="vlt_atr", display=display.none)
atrLength = input.int(14, "Len", minval=2, maxval=300, group=GROUP_VOLATILITY, inline="vlt_atr", display=display.none)
atrSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLATILITY, inline="vlt_atr", display=display.none)
atrLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLATILITY, inline="vlt_atr", display=display.none)

bbEnabled = input.bool(true, "Bollinger Bands", group=GROUP_VOLATILITY, inline="vlt_bb", display=display.none)
bbLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLATILITY, inline="vlt_bb", display=display.none)
bbSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLATILITY, inline="vlt_bb", display=display.none)
bbLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLATILITY, inline="vlt_bb", display=display.none)

kcEnabled = input.bool(true, "Keltner Channels", group=GROUP_VOLATILITY, inline="vlt_kc", display=display.none)
kcLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLATILITY, inline="vlt_kc", display=display.none)
kcSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLATILITY, inline="vlt_kc", display=display.none)
kcLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLATILITY, inline="vlt_kc", display=display.none)

donchianEnabled = input.bool(true, "Donchian Channels", group=GROUP_VOLATILITY, inline="vlt_don", display=display.none)
donchianLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLATILITY, inline="vlt_don", display=display.none)
donchianSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLATILITY, inline="vlt_don", display=display.none)
donchianLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLATILITY, inline="vlt_don", display=display.none)

hvEnabled = input.bool(true, "Historical Volatility", group=GROUP_VOLATILITY, inline="vlt_hv", display=display.none)
hvLength = input.int(20, "Len", minval=2, maxval=300, group=GROUP_VOLATILITY, inline="vlt_hv", display=display.none)
hvSensitivity = input.float(1.0, "Sens", minval=0.1, maxval=5.0, step=0.1, group=GROUP_VOLATILITY, inline="vlt_hv", display=display.none)
hvLookback = input.int(5, "Lookback", minval=1, maxval=100, group=GROUP_VOLATILITY, inline="vlt_hv", display=display.none)

//------------------------------------------------------------------------------
// Reusable helpers
//------------------------------------------------------------------------------
clamp_float(value, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, value))

table_anchor_from_input(anchorText) =>
    anchorText == "Top Left" ? position.top_left :
     anchorText == "Top Right" ? position.top_right :
     anchorText == "Middle Left" ? position.middle_left :
     anchorText == "Middle Right" ? position.middle_right :
     anchorText == "Bottom Left" ? position.bottom_left : position.bottom_right

classify_strength(strength, threshold) =>
    strength >= threshold * 2.0 ? SIGNAL_STRONG_BULLISH :
     strength >= threshold ? SIGNAL_BULLISH :
     strength <= -threshold * 2.0 ? SIGNAL_STRONG_BEARISH :
     strength <= -threshold ? SIGNAL_BEARISH : SIGNAL_NEUTRAL

normalize_score(rawScore, enabledCount) =>
    enabledCount > 0 ? clamp_float(((rawScore + 2.0 * enabledCount) / (4.0 * enabledCount)) * 100.0, 0.0, 100.0) : 50.0

score_to_signal(score) =>
    score >= 80.0 ? SIGNAL_STRONG_BULLISH :
     score >= 60.0 ? SIGNAL_BULLISH :
     score >= 40.0 ? SIGNAL_NEUTRAL :
     score >= 20.0 ? SIGNAL_BEARISH : SIGNAL_STRONG_BEARISH

signal_to_text(signalCode) =>
    signalCode == SIGNAL_STRONG_BULLISH ? "Strong Bullish" :
     signalCode == SIGNAL_BULLISH ? "Bullish" :
     signalCode == SIGNAL_BEARISH ? "Bearish" :
     signalCode == SIGNAL_STRONG_BEARISH ? "Strong Bearish" : "Neutral"

signal_to_compact_text(signalCode) =>
    signalCode == SIGNAL_STRONG_BULLISH ? "++" :
     signalCode == SIGNAL_BULLISH ? "+" :
     signalCode == SIGNAL_BEARISH ? "-" :
     signalCode == SIGNAL_STRONG_BEARISH ? "--" : "0"

signal_to_color(signalCode) =>
    signalCode == SIGNAL_STRONG_BULLISH ? STRONG_BULLISH_COLOR :
     signalCode == SIGNAL_BULLISH ? BULLISH_COLOR :
     signalCode == SIGNAL_BEARISH ? BEARISH_COLOR :
     signalCode == SIGNAL_STRONG_BEARISH ? STRONG_BEARISH_COLOR : NEUTRAL_COLOR

freeze_float(value) =>
    barstate.isconfirmed ? value : nz(value[1], value)

freeze_int(value) =>
    barstate.isconfirmed ? value : nz(value[1], value)

state_to_text(stateCode) =>
    stateCode == 2 ? "Volatile" : stateCode == 1 ? "Trending" : stateCode == -1 ? "Low Volatility" : "Ranging"

state_to_compact_text(stateCode) =>
    stateCode == 2 ? "VOL" : stateCode == 1 ? "TRND" : stateCode == -1 ? "QUIET" : "RNG"

state_to_color(stateCode) =>
    stateCode == 2 ? BEARISH_COLOR : stateCode == 1 ? BULLISH_COLOR : NEUTRAL_COLOR

format_percent(value) =>
    str.tostring(value, "#.0") + "%"

compact_score_text(score, signalCode) =>
    format_percent(score) + " " + signal_to_compact_text(signalCode)

rolling_sum(source, length) =>
    cumulative = ta.cum(source)
    cumulative - nz(cumulative[length], 0.0)

adx_calc(length) =>
    previousHigh = nz(high[1], high)
    previousLow = nz(low[1], low)
    previousClose = nz(close[1], close)
    upMove = high - previousHigh
    downMove = previousLow - low
    plusDM = upMove > downMove and upMove > 0.0 ? upMove : 0.0
    minusDM = downMove > upMove and downMove > 0.0 ? downMove : 0.0
    trueRange = math.max(high - low, math.max(math.abs(high - previousClose), math.abs(low - previousClose)))
    smoothedTrueRange = ta.rma(trueRange, length)
    smoothedPlusDM = ta.rma(plusDM, length)
    smoothedMinusDM = ta.rma(minusDM, length)
    plusDI = smoothedTrueRange > 0.0 ? 100.0 * smoothedPlusDM / smoothedTrueRange : 0.0
    minusDI = smoothedTrueRange > 0.0 ? 100.0 * smoothedMinusDM / smoothedTrueRange : 0.0
    dx = plusDI + minusDI > 0.0 ? 100.0 * math.abs(plusDI - minusDI) / (plusDI + minusDI) : 0.0
    ta.rma(dx, length)

//------------------------------------------------------------------------------
// Indicator scoring functions
//------------------------------------------------------------------------------
ema_trend_score(length, sensitivity, lookback) =>
    slowLength = math.max(length + lookback, length * 2)
    fastEma = ta.ema(close, length)
    slowEma = ta.ema(close, slowLength)
    atrValue = ta.atr(math.max(5, int(math.round(length * 0.75))))
    atrBase = math.max(atrValue, EPSILON)
    previousFastEma = nz(fastEma[lookback], fastEma)
    separation = (fastEma - slowEma) / atrBase
    slope = (fastEma - previousFastEma) / atrBase
    strength = separation + slope * 0.75 + (close > fastEma ? 0.25 : -0.25)
    classify_strength(strength, sensitivity * 0.45)

macd_score(length, sensitivity, lookback) =>
    fastLength = math.max(2, int(math.round(length * 0.5)))
    slowLength = math.max(fastLength + 1, length)
    signalLength = math.max(2, int(math.round(length * 0.35 + sensitivity * 2.0)))
    [macdLine, signalLine, histogram] = ta.macd(close, fastLength, slowLength, signalLength)
    histogramScale = math.max(ta.stdev(histogram, math.max(5, lookback * 2)), EPSILON)
    previousHistogram = nz(histogram[lookback], histogram)
    strength = ((macdLine - signalLine) / histogramScale) + (histogram / histogramScale) + ((histogram - previousHistogram) / histogramScale) * 0.5
    classify_strength(strength, sensitivity * 0.90)

supertrend_score(length, sensitivity, lookback) =>
    factor = math.max(1.0, 1.5 + sensitivity * 0.5)
    [supertrendLine, direction] = ta.supertrend(factor, length)
    atrBase = math.max(ta.atr(length), EPSILON)
    historicalDirection = nz(direction[lookback], direction)
    stability = direction == historicalDirection ? (direction < 0 ? 0.75 : -0.75) : 0.0
    strength = ((close - supertrendLine) / atrBase) + stability
    classify_strength(strength, sensitivity * 0.65)

ichimoku_score(length, sensitivity, lookback) =>
    conversionLength = math.max(2, int(math.round(length * 0.5)))
    baseLength = math.max(conversionLength + 1, length)
    spanBLength = math.max(baseLength + lookback, length * 3)
    tenkan = (ta.highest(high, conversionLength) + ta.lowest(low, conversionLength)) / 2.0
    kijun = (ta.highest(high, baseLength) + ta.lowest(low, baseLength)) / 2.0
    senkouA = (tenkan + kijun) / 2.0
    senkouB = (ta.highest(high, spanBLength) + ta.lowest(low, spanBLength)) / 2.0
    cloudTop = math.max(senkouA, senkouB)
    cloudBottom = math.min(senkouA, senkouB)
    cloudMid = (cloudTop + cloudBottom) / 2.0
    atrBase = math.max(ta.atr(baseLength), EPSILON)
    previousClose = nz(close[lookback], close)
    cloudBias = close > cloudTop ? (close - cloudTop) / atrBase : close < cloudBottom ? (close - cloudBottom) / atrBase : ((close - cloudMid) / atrBase) * 0.5
    lineBias = (tenkan - kijun) / atrBase
    momentumBias = (close - previousClose) / atrBase
    strength = cloudBias + lineBias + momentumBias * 0.35
    classify_strength(strength, sensitivity * 0.70)

psar_score(length, sensitivity, lookback) =>
    startStep = math.min(0.04, 0.01 + sensitivity * 0.003)
    increment = math.min(0.05, 0.01 + sensitivity * 0.004)
    maximum = math.min(0.30, 0.10 + sensitivity * 0.03)
    sarValue = ta.sar(startStep, increment, maximum)
    atrBase = math.max(ta.atr(length), EPSILON)
    previousSar = nz(sarValue[lookback], sarValue)
    previousClose = nz(close[lookback], close)
    strength = ((close - sarValue) / atrBase) + ((sarValue - previousSar) / atrBase) * 0.25 + ((close - previousClose) / atrBase) * 0.50
    classify_strength(strength, sensitivity * 0.60)

rsi_score(length, sensitivity, lookback) =>
    rsiValue = ta.rsi(close, length)
    previousRsi = nz(rsiValue[lookback], rsiValue)
    strength = ((rsiValue - 50.0) / 10.0) + ((rsiValue - previousRsi) / 8.0)
    classify_strength(strength, sensitivity * 0.60)

stoch_rsi_score(length, sensitivity, lookback) =>
    rsiValue = ta.rsi(close, length)
    lowestRsi = ta.lowest(rsiValue, length)
    highestRsi = ta.highest(rsiValue, length)
    rsiRange = math.max(highestRsi - lowestRsi, EPSILON)
    rawStoch = ((rsiValue - lowestRsi) / rsiRange) * 100.0
    kValue = ta.sma(rawStoch, 3)
    dValue = ta.sma(kValue, 3)
    previousK = nz(kValue[lookback], kValue)
    strength = ((kValue - 50.0) / 12.5) + ((kValue - dValue) / 8.0) + ((kValue - previousK) / 20.0)
    classify_strength(strength, sensitivity * 0.75)

cci_score(length, sensitivity, lookback) =>
    cciValue = ta.cci(hlc3, length)
    previousCci = nz(cciValue[lookback], cciValue)
    strength = (cciValue / 100.0) + ((cciValue - previousCci) / 100.0) * 0.5
    classify_strength(strength, sensitivity * 0.80)

williams_score(length, sensitivity, lookback) =>
    highestHigh = ta.highest(high, length)
    lowestLow = ta.lowest(low, length)
    priceRange = math.max(highestHigh - lowestLow, EPSILON)
    williamsR = -100.0 * (highestHigh - close) / priceRange
    previousWilliams = nz(williamsR[lookback], williamsR)
    centeredValue = williamsR + 50.0
    strength = (centeredValue / 12.5) + ((williamsR - previousWilliams) / 15.0)
    classify_strength(strength, sensitivity * 0.70)

roc_score(length, sensitivity, lookback) =>
    baseClose = nz(close[length], close)
    rocValue = baseClose != 0.0 ? ((close - baseClose) / baseClose) * 100.0 : 0.0
    previousRoc = nz(rocValue[lookback], rocValue)
    atrPct = math.max((ta.atr(length) / math.max(close, EPSILON)) * 100.0, 0.2)
    strength = (rocValue / atrPct) + ((rocValue - previousRoc) / atrPct) * 0.5
    classify_strength(strength, sensitivity * 0.90)

vwap_score(length, sensitivity, lookback) =>
    sessionVwap = nz(ta.vwap(hlc3), close)
    atrBase = math.max(ta.atr(length), EPSILON)
    volumeAverage = nz(ta.sma(volume, length), volume)
    volumeBias = volumeAverage > 0.0 ? (volume / volumeAverage) - 1.0 : 0.0
    previousClose = nz(close[lookback], close)
    strength = ((close - sessionVwap) / atrBase) + ((close - previousClose) / atrBase) * 0.5 + volumeBias * 0.75
    classify_strength(strength, sensitivity * 0.65)

obv_score(length, sensitivity, lookback) =>
    obvValue = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
    obvFast = ta.ema(obvValue, length)
    obvSlow = ta.ema(obvValue, math.max(length * 2, length + lookback))
    obvScale = math.max(ta.stdev(obvValue - obvSlow, length), 1.0)
    previousObv = nz(obvValue[lookback], obvValue)
    strength = ((obvFast - obvSlow) / obvScale) + ((obvValue - previousObv) / obvScale) * 0.5
    classify_strength(strength, sensitivity * 0.70)

adl_score(length, sensitivity, lookback) =>
    moneyFlowMultiplier = high != low ? ((close - low) - (high - close)) / (high - low) : 0.0
    adlValue = ta.cum(moneyFlowMultiplier * volume)
    adlAverage = ta.ema(adlValue, length)
    adlScale = math.max(ta.stdev(adlValue - adlAverage, length), 1.0)
    previousAdl = nz(adlValue[lookback], adlValue)
    strength = ((adlValue - adlAverage) / adlScale) + ((adlValue - previousAdl) / adlScale) * 0.5
    classify_strength(strength, sensitivity * 0.70)

volume_ma_score(length, sensitivity, lookback) =>
    volumeAverage = nz(ta.sma(volume, length), volume)
    volumeRatio = volumeAverage > 0.0 ? volume / volumeAverage : 1.0
    atrBase = math.max(ta.atr(length), EPSILON)
    priceAverage = ta.ema(close, lookback)
    bodyBias = (close - open) / atrBase
    trendBias = (close - priceAverage) / atrBase
    strength = (volumeRatio - 1.0) * (close >= open ? 1.0 : -1.0) + bodyBias + trendBias * 0.5
    classify_strength(strength, sensitivity * 0.60)

volume_delta_proxy_score(length, sensitivity, lookback) =>
    barRange = math.max(high - low, EPSILON)
    deltaProxy = ((close - open) / barRange) * volume
    deltaSum = rolling_sum(deltaProxy, lookback)
    deltaScale = math.max(nz(ta.sma(math.abs(deltaProxy), length), math.abs(deltaProxy)) * lookback, 1.0)
    atrBase = math.max(ta.atr(length), EPSILON)
    previousClose = nz(close[lookback], close)
    strength = (deltaSum / deltaScale) + ((close - previousClose) / atrBase) * 0.5
    classify_strength(strength, sensitivity * 0.75)

atr_volatility_score(length, sensitivity, lookback) =>
    atrValue = ta.atr(length)
    atrBaseline = nz(ta.sma(atrValue, math.max(length, lookback * 2)), atrValue)
    atrRatio = atrBaseline > 0.0 ? (atrValue / atrBaseline) - 1.0 : 0.0
    directionBias = (close - ta.ema(close, length)) / math.max(atrValue, EPSILON)
    strength = directionBias * (1.0 + atrRatio * 1.5)
    classify_strength(strength, sensitivity * 0.55)

bollinger_score(length, sensitivity, lookback) =>
    basis = ta.sma(close, length)
    deviation = ta.stdev(close, length)
    multiplier = 1.5 + sensitivity * 0.3
    upperBand = basis + deviation * multiplier
    lowerBand = basis - deviation * multiplier
    bandWidth = math.max(upperBand - lowerBand, EPSILON)
    widthAverage = nz(ta.sma(bandWidth, math.max(length, lookback)), bandWidth)
    expansion = widthAverage > 0.0 ? (bandWidth / widthAverage) - 1.0 : 0.0
    position = ((close - basis) / bandWidth) * 4.0
    strength = position * (1.0 + expansion)
    classify_strength(strength, sensitivity * 0.70)

keltner_score(length, sensitivity, lookback) =>
    basis = ta.ema(close, length)
    channelAtr = ta.atr(length)
    multiplier = 1.2 + sensitivity * 0.25
    upperBand = basis + channelAtr * multiplier
    lowerBand = basis - channelAtr * multiplier
    channelWidth = math.max(upperBand - lowerBand, EPSILON)
    widthAverage = nz(ta.sma(channelWidth, math.max(length, lookback)), channelWidth)
    expansion = widthAverage > 0.0 ? (channelWidth / widthAverage) - 1.0 : 0.0
    position = ((close - basis) / channelWidth) * 4.0
    strength = position * (1.0 + expansion)
    classify_strength(strength, sensitivity * 0.70)

donchian_score(length, sensitivity, lookback) =>
    upperBand = ta.highest(high, length)
    lowerBand = ta.lowest(low, length)
    midBand = (upperBand + lowerBand) / 2.0
    bandRange = math.max(upperBand - lowerBand, EPSILON)
    previousUpper = nz(upperBand[1], upperBand)
    previousLower = nz(lowerBand[1], lowerBand)
    previousClose = nz(close[lookback], close)
    breakoutBias = close > previousUpper ? 1.25 : close < previousLower ? -1.25 : 0.0
    positionBias = ((close - midBand) / bandRange) * 4.0
    momentumBias = ((close - previousClose) / math.max(ta.atr(length), EPSILON)) * 0.25
    strength = positionBias + breakoutBias + momentumBias
    classify_strength(strength, sensitivity * 0.75)

historical_volatility_score(length, sensitivity, lookback) =>
    previousBarClose = nz(close[1], close)
    logReturn = close > 0.0 and previousBarClose > 0.0 ? math.log(close / previousBarClose) : 0.0
    historicalVolatility = ta.stdev(logReturn, length) * ANNUALIZATION_FACTOR * 100.0
    historicalVolatilityAverage = nz(ta.sma(historicalVolatility, math.max(length, lookback)), historicalVolatility)
    previousClose = nz(close[lookback], close)
    returnBias = previousClose != 0.0 ? ((close - previousClose) / previousClose) * 100.0 : 0.0
    volatilityRatio = historicalVolatilityAverage > 0.0 ? (historicalVolatility / historicalVolatilityAverage) - 1.0 : 0.0
    strength = (returnBias / math.max(historicalVolatility, 0.5)) * 10.0 * (1.0 + volatilityRatio)
    classify_strength(strength, sensitivity * 0.80)

market_state_code() =>
    adxValue = adx_calc(14)
    atrPercent = (ta.atr(14) / math.max(close, EPSILON)) * 100.0
    atrPercentAverage = nz(ta.sma(atrPercent, 50), atrPercent)
    previousBarClose = nz(close[1], close)
    logReturn = close > 0.0 and previousBarClose > 0.0 ? math.log(close / previousBarClose) : 0.0
    shortHv = ta.stdev(logReturn, 14) * ANNUALIZATION_FACTOR * 100.0
    longHv = nz(ta.sma(shortHv, 50), shortHv)
    isVolatile = atrPercent > atrPercentAverage * 1.25 or shortHv > longHv * 1.20
    isLowVolatility = atrPercent < atrPercentAverage * 0.85 and shortHv < longHv * 0.85
    isTrending = adxValue > 23.0 and not isVolatile and not isLowVolatility
    isVolatile ? 2 : isTrending ? 1 : isLowVolatility ? -1 : 0

//------------------------------------------------------------------------------
// Category engine
//------------------------------------------------------------------------------
emaTrendSignal = emaTrendEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, ema_trend_score(emaTrendLength, emaTrendSensitivity, emaTrendLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
macdSignal = macdEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, macd_score(macdLength, macdSensitivity, macdLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
supertrendSignal = supertrendEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, supertrend_score(supertrendLength, supertrendSensitivity, supertrendLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
ichimokuSignal = ichimokuEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, ichimoku_score(ichimokuLength, ichimokuSensitivity, ichimokuLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
psarSignal = psarEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, psar_score(psarLength, psarSensitivity, psarLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL

rsiSignal = rsiEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, rsi_score(rsiLength, rsiSensitivity, rsiLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
stochRsiSignal = stochRsiEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, stoch_rsi_score(stochRsiLength, stochRsiSensitivity, stochRsiLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
cciSignal = cciEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, cci_score(cciLength, cciSensitivity, cciLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
williamsSignal = williamsEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, williams_score(williamsLength, williamsSensitivity, williamsLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
rocSignal = rocEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, roc_score(rocLength, rocSensitivity, rocLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL

vwapSignal = vwapEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, vwap_score(vwapLength, vwapSensitivity, vwapLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
obvSignal = obvEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, obv_score(obvLength, obvSensitivity, obvLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
adlSignal = adlEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, adl_score(adlLength, adlSensitivity, adlLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
volumeMaSignal = volumeMaEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, volume_ma_score(volumeMaLength, volumeMaSensitivity, volumeMaLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
volumeDeltaSignal = volumeDeltaEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, volume_delta_proxy_score(volumeDeltaLength, volumeDeltaSensitivity, volumeDeltaLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL

atrSignal = atrEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, atr_volatility_score(atrLength, atrSensitivity, atrLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
bbSignal = bbEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, bollinger_score(bbLength, bbSensitivity, bbLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
kcSignal = kcEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, keltner_score(kcLength, kcSensitivity, kcLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
donchianSignal = donchianEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, donchian_score(donchianLength, donchianSensitivity, donchianLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL
hvSignal = hvEnabled ? freeze_int(request.security(syminfo.tickerid, analysisTimeframe, historical_volatility_score(hvLength, hvSensitivity, hvLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)) : SIGNAL_NEUTRAL

trendRawScore = (emaTrendEnabled ? emaTrendSignal : 0) + (macdEnabled ? macdSignal : 0) + (supertrendEnabled ? supertrendSignal : 0) + (ichimokuEnabled ? ichimokuSignal : 0) + (psarEnabled ? psarSignal : 0)
momentumRawScore = (rsiEnabled ? rsiSignal : 0) + (stochRsiEnabled ? stochRsiSignal : 0) + (cciEnabled ? cciSignal : 0) + (williamsEnabled ? williamsSignal : 0) + (rocEnabled ? rocSignal : 0)
volumeRawScore = (vwapEnabled ? vwapSignal : 0) + (obvEnabled ? obvSignal : 0) + (adlEnabled ? adlSignal : 0) + (volumeMaEnabled ? volumeMaSignal : 0) + (volumeDeltaEnabled ? volumeDeltaSignal : 0)
volatilityRawScore = (atrEnabled ? atrSignal : 0) + (bbEnabled ? bbSignal : 0) + (kcEnabled ? kcSignal : 0) + (donchianEnabled ? donchianSignal : 0) + (hvEnabled ? hvSignal : 0)

trendEnabledCount = (emaTrendEnabled ? 1 : 0) + (macdEnabled ? 1 : 0) + (supertrendEnabled ? 1 : 0) + (ichimokuEnabled ? 1 : 0) + (psarEnabled ? 1 : 0)
momentumEnabledCount = (rsiEnabled ? 1 : 0) + (stochRsiEnabled ? 1 : 0) + (cciEnabled ? 1 : 0) + (williamsEnabled ? 1 : 0) + (rocEnabled ? 1 : 0)
volumeEnabledCount = (vwapEnabled ? 1 : 0) + (obvEnabled ? 1 : 0) + (adlEnabled ? 1 : 0) + (volumeMaEnabled ? 1 : 0) + (volumeDeltaEnabled ? 1 : 0)
volatilityEnabledCount = (atrEnabled ? 1 : 0) + (bbEnabled ? 1 : 0) + (kcEnabled ? 1 : 0) + (donchianEnabled ? 1 : 0) + (hvEnabled ? 1 : 0)

trendScore = freeze_float(normalize_score(trendRawScore, trendEnabledCount))
momentumScore = freeze_float(normalize_score(momentumRawScore, momentumEnabledCount))
volumeScore = freeze_float(normalize_score(volumeRawScore, volumeEnabledCount))
volatilityScore = freeze_float(normalize_score(volatilityRawScore, volatilityEnabledCount))

trendSignal = freeze_int(score_to_signal(trendScore))
momentumSignal = freeze_int(score_to_signal(momentumScore))
volumeSignal = freeze_int(score_to_signal(volumeScore))
volatilitySignal = freeze_int(score_to_signal(volatilityScore))

overallScore = freeze_float(clamp_float(trendScore * TREND_WEIGHT + momentumScore * MOMENTUM_WEIGHT + volumeScore * VOLUME_WEIGHT + volatilityScore * VOLATILITY_WEIGHT, 0.0, 100.0))
overallSignal = freeze_int(score_to_signal(overallScore))
buyConfidence = overallScore
sellConfidence = 100.0 - overallScore
marketState = freeze_int(request.security(syminfo.tickerid, analysisTimeframe, market_state_code(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off))

trendColor = signal_to_color(trendSignal)
momentumColor = signal_to_color(momentumSignal)
volumeColor = signal_to_color(volumeSignal)
volatilityColor = signal_to_color(volatilitySignal)
overallColor = signal_to_color(overallSignal)
marketStateColor = state_to_color(marketState)

trendSignalText = signal_to_text(trendSignal)
momentumSignalText = signal_to_text(momentumSignal)
volumeSignalText = signal_to_text(volumeSignal)
volatilitySignalText = signal_to_text(volatilitySignal)
overallSignalText = signal_to_text(overallSignal)
marketStateText = state_to_text(marketState)

trendSignalDisplayText = compactMobileMode ? signal_to_compact_text(trendSignal) : trendSignalText
momentumSignalDisplayText = compactMobileMode ? signal_to_compact_text(momentumSignal) : momentumSignalText
volumeSignalDisplayText = compactMobileMode ? signal_to_compact_text(volumeSignal) : volumeSignalText
volatilitySignalDisplayText = compactMobileMode ? signal_to_compact_text(volatilitySignal) : volatilitySignalText
overallSignalDisplayText = compactMobileMode ? signal_to_compact_text(overallSignal) : overallSignalText
marketStateDisplayText = compactMobileMode ? state_to_compact_text(marketState) : marketStateText

trendScoreValueText = compactMobileMode ? compact_score_text(trendScore, trendSignal) : format_percent(trendScore)
momentumScoreValueText = compactMobileMode ? compact_score_text(momentumScore, momentumSignal) : format_percent(momentumScore)
volumeScoreValueText = compactMobileMode ? compact_score_text(volumeScore, volumeSignal) : format_percent(volumeScore)
volatilityScoreValueText = compactMobileMode ? compact_score_text(volatilityScore, volatilitySignal) : format_percent(volatilityScore)
overallScoreValueText = compactMobileMode ? compact_score_text(overallScore, overallSignal) : format_percent(overallScore)

indicatorBreakdownTitle = compactMobileMode ? "SIGNALS" : "INDIVIDUAL INDICATOR SIGNALS"
indicatorBreakdownTfText = compactMobileMode ? "TF: " + analysisTimeframeLabel : "Analysis TF: " + analysisTimeframeLabel
trendHeaderText = "Trend"
momentumHeaderText = compactMobileMode ? "Mom" : "Momentum"
volumeHeaderText = "Volume"
volatilityHeaderText = compactMobileMode ? "Vlt" : "Volatility"
signalHeaderText = compactMobileMode ? "Sig" : "Signal"

emaTrendLabel = compactMobileMode ? "EMA" : "EMA Trend"
supertrendLabel = compactMobileMode ? "ST" : "Supertrend"
ichimokuLabel = compactMobileMode ? "Ichi" : "Ichimoku"
psarLabel = compactMobileMode ? "PSAR" : "Parabolic SAR"
stochRsiLabel = compactMobileMode ? "StRSI" : "Stoch RSI"
williamsLabel = compactMobileMode ? "W%R" : "Williams %R"
adlLabel = compactMobileMode ? "ADL" : "Acc Dist"
volumeMaLabel = compactMobileMode ? "VMA" : "Volume MA"
volumeDeltaLabel = compactMobileMode ? "Delta" : "Delta Proxy"
bbLabel = compactMobileMode ? "BB" : "Bollinger"
kcLabel = compactMobileMode ? "KC" : "Keltner"
donchianLabel = compactMobileMode ? "Don" : "Donchian"
hvLabel = compactMobileMode ? "HV" : "Hist Vol"
showIndicatorBreakdown = not compactMobileMode or showCompactSignalGrid
dashboardPosition = table_anchor_from_input(dashboardPositionInput)
signalGridPosition = table_anchor_from_input(signalGridPositionInput)

//------------------------------------------------------------------------------
// Dashboard table
//------------------------------------------------------------------------------
var table dashboardFull = table.new(position.bottom_left, 2, 15, bgcolor=PANEL_BACKGROUND, frame_color=PANEL_BORDER, frame_width=1, border_color=PANEL_BORDER, border_width=1)
var table dashboardCompact = table.new(position.bottom_left, 2, 10, bgcolor=PANEL_BACKGROUND, frame_color=PANEL_BORDER, frame_width=1, border_color=PANEL_BORDER, border_width=1)
var table indicatorBreakdown = table.new(position.bottom_right, 4, 14, bgcolor=PANEL_BACKGROUND, frame_color=PANEL_BORDER, frame_width=1, border_color=PANEL_BORDER, border_width=1)

if barstate.isfirst
    table.merge_cells(dashboardFull, 0, 0, 1, 0)
    table.merge_cells(dashboardFull, 0, 9, 1, 9)
    table.merge_cells(dashboardCompact, 0, 0, 1, 0)
    table.merge_cells(dashboardCompact, 0, 9, 1, 9)
    if showIndicatorBreakdown
        table.merge_cells(indicatorBreakdown, 0, 0, 3, 0)
        table.merge_cells(indicatorBreakdown, 0, 1, 3, 1)

if barstate.islast
    table.set_position(dashboardFull, dashboardPosition)
    table.set_position(dashboardCompact, dashboardPosition)
    table.set_position(indicatorBreakdown, signalGridPosition)

    if compactMobileMode
        table.cell(dashboardCompact, 0, 0, "SIGNAL PRO", text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_center, text_size=size.normal)
    else
        table.cell(dashboardFull, 0, 0, "SIGNAL PRO", text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_center, text_size=size.large)

    if compactMobileMode
        table.cell(dashboardCompact, 0, 1, "TF", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 1, analysisTimeframeLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 2, "Trend", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 2, trendScoreValueText, text_color=trendColor, bgcolor=color.new(trendColor, 86), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 3, "Mom", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 3, momentumScoreValueText, text_color=momentumColor, bgcolor=color.new(momentumColor, 86), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 4, "Vol", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 4, volumeScoreValueText, text_color=volumeColor, bgcolor=color.new(volumeColor, 86), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 5, "Vlt", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 5, volatilityScoreValueText, text_color=volatilityColor, bgcolor=color.new(volatilityColor, 86), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 6, "Overall", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 6, overallScoreValueText, text_color=overallColor, bgcolor=color.new(overallColor, 82), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 7, "Buy", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 7, format_percent(buyConfidence), text_color=BULLISH_COLOR, bgcolor=color.new(BULLISH_COLOR, 88), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 8, "Sell", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardCompact, 1, 8, format_percent(sellConfidence), text_color=STRONG_BEARISH_COLOR, bgcolor=color.new(STRONG_BEARISH_COLOR, 88), text_halign=text.align_right)
        table.cell(dashboardCompact, 0, 9, "State: " + marketStateDisplayText, text_color=marketStateColor, bgcolor=color.new(marketStateColor, 88), text_halign=text.align_center)
    else
        table.cell(dashboardFull, 0, 1, "Trend Score", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 1, trendScoreValueText, text_color=trendColor, bgcolor=color.new(trendColor, 86), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 2, "Trend Signal", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 2, trendSignalDisplayText, text_color=trendColor, bgcolor=color.new(trendColor, 86), text_halign=text.align_right)

        table.cell(dashboardFull, 0, 3, "Momentum Score", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 3, momentumScoreValueText, text_color=momentumColor, bgcolor=color.new(momentumColor, 86), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 4, "Momentum Signal", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 4, momentumSignalDisplayText, text_color=momentumColor, bgcolor=color.new(momentumColor, 86), text_halign=text.align_right)

        table.cell(dashboardFull, 0, 5, "Volume Score", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 5, volumeScoreValueText, text_color=volumeColor, bgcolor=color.new(volumeColor, 86), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 6, "Volume Signal", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 6, volumeSignalDisplayText, text_color=volumeColor, bgcolor=color.new(volumeColor, 86), text_halign=text.align_right)

        table.cell(dashboardFull, 0, 7, "Volatility Score", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 7, volatilityScoreValueText, text_color=volatilityColor, bgcolor=color.new(volatilityColor, 86), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 8, "Volatility Signal", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 8, volatilitySignalDisplayText, text_color=volatilityColor, bgcolor=color.new(volatilityColor, 86), text_halign=text.align_right)

        table.cell(dashboardFull, 0, 9, "---------------------------------", text_color=color.rgb(123, 138, 148), bgcolor=PANEL_BACKGROUND, text_halign=text.align_center)

        table.cell(dashboardFull, 0, 10, "Overall Score", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 10, overallScoreValueText, text_color=overallColor, bgcolor=color.new(overallColor, 82), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 11, "Overall Signal", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 11, overallSignalDisplayText, text_color=overallColor, bgcolor=color.new(overallColor, 82), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 12, "Buy Confidence", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 12, format_percent(buyConfidence), text_color=BULLISH_COLOR, bgcolor=color.new(BULLISH_COLOR, 88), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 13, "Sell Confidence", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 13, format_percent(sellConfidence), text_color=STRONG_BEARISH_COLOR, bgcolor=color.new(STRONG_BEARISH_COLOR, 88), text_halign=text.align_right)
        table.cell(dashboardFull, 0, 14, "Market State", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(dashboardFull, 1, 14, marketStateDisplayText, text_color=marketStateColor, bgcolor=color.new(marketStateColor, 88), text_halign=text.align_right)

    if showIndicatorBreakdown
        table.cell(indicatorBreakdown, 0, 0, indicatorBreakdownTitle, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_center, text_size=compactMobileMode ? size.small : size.normal)
        table.cell(indicatorBreakdown, 0, 1, indicatorBreakdownTfText, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_center)

        table.cell(indicatorBreakdown, 0, 2, trendHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 2, signalHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 2, momentumHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 2, signalHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 3, emaTrendLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 3, compactMobileMode ? signal_to_compact_text(emaTrendSignal) : signal_to_text(emaTrendSignal), text_color=signal_to_color(emaTrendSignal), bgcolor=color.new(signal_to_color(emaTrendSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 3, "RSI", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 3, compactMobileMode ? signal_to_compact_text(rsiSignal) : signal_to_text(rsiSignal), text_color=signal_to_color(rsiSignal), bgcolor=color.new(signal_to_color(rsiSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 4, "MACD", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 4, compactMobileMode ? signal_to_compact_text(macdSignal) : signal_to_text(macdSignal), text_color=signal_to_color(macdSignal), bgcolor=color.new(signal_to_color(macdSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 4, stochRsiLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 4, compactMobileMode ? signal_to_compact_text(stochRsiSignal) : signal_to_text(stochRsiSignal), text_color=signal_to_color(stochRsiSignal), bgcolor=color.new(signal_to_color(stochRsiSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 5, supertrendLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 5, compactMobileMode ? signal_to_compact_text(supertrendSignal) : signal_to_text(supertrendSignal), text_color=signal_to_color(supertrendSignal), bgcolor=color.new(signal_to_color(supertrendSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 5, "CCI", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 5, compactMobileMode ? signal_to_compact_text(cciSignal) : signal_to_text(cciSignal), text_color=signal_to_color(cciSignal), bgcolor=color.new(signal_to_color(cciSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 6, ichimokuLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 6, compactMobileMode ? signal_to_compact_text(ichimokuSignal) : signal_to_text(ichimokuSignal), text_color=signal_to_color(ichimokuSignal), bgcolor=color.new(signal_to_color(ichimokuSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 6, williamsLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 6, compactMobileMode ? signal_to_compact_text(williamsSignal) : signal_to_text(williamsSignal), text_color=signal_to_color(williamsSignal), bgcolor=color.new(signal_to_color(williamsSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 7, psarLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 7, compactMobileMode ? signal_to_compact_text(psarSignal) : signal_to_text(psarSignal), text_color=signal_to_color(psarSignal), bgcolor=color.new(signal_to_color(psarSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 7, "ROC", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 7, compactMobileMode ? signal_to_compact_text(rocSignal) : signal_to_text(rocSignal), text_color=signal_to_color(rocSignal), bgcolor=color.new(signal_to_color(rocSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 8, volumeHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 8, signalHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 8, volatilityHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 8, signalHeaderText, text_color=color.white, bgcolor=HEADER_BACKGROUND, text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 9, "VWAP", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 9, compactMobileMode ? signal_to_compact_text(vwapSignal) : signal_to_text(vwapSignal), text_color=signal_to_color(vwapSignal), bgcolor=color.new(signal_to_color(vwapSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 9, "ATR", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 9, compactMobileMode ? signal_to_compact_text(atrSignal) : signal_to_text(atrSignal), text_color=signal_to_color(atrSignal), bgcolor=color.new(signal_to_color(atrSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 10, "OBV", text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 10, compactMobileMode ? signal_to_compact_text(obvSignal) : signal_to_text(obvSignal), text_color=signal_to_color(obvSignal), bgcolor=color.new(signal_to_color(obvSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 10, bbLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 10, compactMobileMode ? signal_to_compact_text(bbSignal) : signal_to_text(bbSignal), text_color=signal_to_color(bbSignal), bgcolor=color.new(signal_to_color(bbSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 11, adlLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 11, compactMobileMode ? signal_to_compact_text(adlSignal) : signal_to_text(adlSignal), text_color=signal_to_color(adlSignal), bgcolor=color.new(signal_to_color(adlSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 11, kcLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 11, compactMobileMode ? signal_to_compact_text(kcSignal) : signal_to_text(kcSignal), text_color=signal_to_color(kcSignal), bgcolor=color.new(signal_to_color(kcSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 12, volumeMaLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 12, compactMobileMode ? signal_to_compact_text(volumeMaSignal) : signal_to_text(volumeMaSignal), text_color=signal_to_color(volumeMaSignal), bgcolor=color.new(signal_to_color(volumeMaSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 12, donchianLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 12, compactMobileMode ? signal_to_compact_text(donchianSignal) : signal_to_text(donchianSignal), text_color=signal_to_color(donchianSignal), bgcolor=color.new(signal_to_color(donchianSignal), 86), text_halign=text.align_right)

        table.cell(indicatorBreakdown, 0, 13, volumeDeltaLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 1, 13, compactMobileMode ? signal_to_compact_text(volumeDeltaSignal) : signal_to_text(volumeDeltaSignal), text_color=signal_to_color(volumeDeltaSignal), bgcolor=color.new(signal_to_color(volumeDeltaSignal), 86), text_halign=text.align_right)
        table.cell(indicatorBreakdown, 2, 13, hvLabel, text_color=color.white, bgcolor=PANEL_BACKGROUND, text_halign=text.align_left)
        table.cell(indicatorBreakdown, 3, 13, compactMobileMode ? signal_to_compact_text(hvSignal) : signal_to_text(hvSignal), text_color=signal_to_color(hvSignal), bgcolor=color.new(signal_to_color(hvSignal), 86), text_halign=text.align_right)

//------------------------------------------------------------------------------
// Hidden plots for data window visibility
//------------------------------------------------------------------------------
plot(overallScore, "Overall Score", color=color.new(overallColor, 100), display=display.none)
plot(trendScore, "Trend Score", color=color.new(trendColor, 100), display=display.none)
plot(momentumScore, "Momentum Score", color=color.new(momentumColor, 100), display=display.none)
plot(volumeScore, "Volume Score", color=color.new(volumeColor, 100), display=display.none)
plot(volatilityScore, "Volatility Score", color=color.new(volatilityColor, 100), display=display.none)
plot(buyConfidence, "Buy Confidence", color=color.new(BULLISH_COLOR, 100), display=display.none)
plot(sellConfidence, "Sell Confidence", color=color.new(STRONG_BEARISH_COLOR, 100), display=display.none)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
trendSignalChanged = not na(trendSignal[1]) and trendSignal != trendSignal[1]
momentumSignalChanged = not na(momentumSignal[1]) and momentumSignal != momentumSignal[1]
volumeSignalChanged = not na(volumeSignal[1]) and volumeSignal != volumeSignal[1]
volatilitySignalChanged = not na(volatilitySignal[1]) and volatilitySignal != volatilitySignal[1]
overallSignalChanged = not na(overallSignal[1]) and overallSignal != overallSignal[1]

alertcondition(overallSignal == SIGNAL_STRONG_BULLISH, "Strong Bullish Signal", "Signal Pro: Strong bullish overall signal on {{ticker}} at {{interval}}.")
alertcondition(overallSignal == SIGNAL_BULLISH, "Bullish Signal", "Signal Pro: Bullish overall signal on {{ticker}} at {{interval}}.")
alertcondition(overallSignal == SIGNAL_STRONG_BEARISH, "Strong Bearish Signal", "Signal Pro: Strong bearish overall signal on {{ticker}} at {{interval}}.")
alertcondition(overallSignal == SIGNAL_BEARISH, "Bearish Signal", "Signal Pro: Bearish overall signal on {{ticker}} at {{interval}}.")
alertcondition(trendSignalChanged, "Trend Signal Change", "Signal Pro: Trend category signal changed on {{ticker}} at {{interval}}.")
alertcondition(momentumSignalChanged, "Momentum Signal Change", "Signal Pro: Momentum category signal changed on {{ticker}} at {{interval}}.")
alertcondition(volumeSignalChanged, "Volume Signal Change", "Signal Pro: Volume category signal changed on {{ticker}} at {{interval}}.")
alertcondition(volatilitySignalChanged, "Volatility Signal Change", "Signal Pro: Volatility category signal changed on {{ticker}} at {{interval}}.")
alertcondition(overallSignalChanged, "Overall Signal Change", "Signal Pro: Overall signal changed on {{ticker}} at {{interval}}.")
alertcondition(buyConfidence > 80.0, "Buy Confidence Above 80%", "Signal Pro: Buy confidence is above 80% on {{ticker}} at {{interval}}.")
alertcondition(sellConfidence > 80.0, "Sell Confidence Above 80%", "Signal Pro: Sell confidence is above 80% on {{ticker}} at {{interval}}.")
````
