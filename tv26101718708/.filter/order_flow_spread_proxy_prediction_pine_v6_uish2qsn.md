# Order Flow + Spread Proxy Prediction [Pine v6]

- url: https://www.tradingview.com/script/uIsh2qsN/
- type: indicator
- pine_id: PUB;4b9b59e59b2c4e71a350908485fe3e8c
- version: 1.0

## Description

Order Flow + Spread Proxy Prediction [Pine v6] is a market microstructure-inspired indicator designed to estimate short-term directional pressure using TradingView-accessible OHLCV data. Since Pine Script does not normally provide full Level 2 order book depth, true bid-ask spread, tick-by-tick trade classification, or real aggressive buy and sell order flow, this script does not claim to measure institutional order flow directly. Instead, it builds a volume-price order-flow proxy model based on candle structure, volume behavior, close-location value, cumulative volume delta proxy, VWAP deviation, range-based spread risk, Amihud illiquidity, VPIN-like toxic flow risk, and liquidity confirmation. The model first estimates directional buying or selling pressure from candle body direction, close position within the bar, and volume distribution. It then measures whether that pressure is accumulating through a CVD slope proxy and adjusts the signal using VWAP positioning, liquidity conditions, spread risk, and toxicity risk. The final composite score is smoothed and converted into an estimated probability of upward price movement. A long signal is generated when the estimated upside probability exceeds the bullish threshold, the composite score is sufficiently positive, and the EMA trend filter confirms a bullish regime. A short signal is generated when the estimated upside probability falls below the bearish threshold, the composite score is sufficiently negative, and the EMA trend filter confirms a bearish regime. The indicator also includes background coloring, signal labels, VWAP and EMA plots, and a dashboard showing probability, composite score, OFI proxy, CVD score, VWAP score, spread risk, VPIN risk, and trend direction. This tool is best suited for liquid intraday markets such as BTC, ETH, major futures, and high-volume equities on short timeframes such as 1-minute, 3-minute, 5-minute, and 15-minute charts. It should be understood as a proxy-based microstructure indicator rather than a true order book or institutional flow system, and its signals should be used together with risk management, execution-cost awareness, and independent market judgment.

## Source Code

````pine
//@version=6
indicator("Order Flow + Spread Proxy Prediction [Pine v6]", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// Inputs
//====================================================
groupCore = "Core Model"
lenZ       = input.int(80, "Z-Score Length", minval=20, group=groupCore)
cvdLen     = input.int(34, "CVD Slope Length", minval=5, group=groupCore)
vpinLen    = input.int(50, "VPIN Proxy Length", minval=10, group=groupCore)
atrLen     = input.int(14, "ATR Length", minval=5, group=groupCore)
smoothLen  = input.int(5, "Score Smoothing", minval=1, group=groupCore)

groupWeight = "Model Weights"
wOFI     = input.float(2.00, "Weight: OFI Proxy", step=0.1, group=groupWeight)
wCVD     = input.float(1.40, "Weight: CVD Slope", step=0.1, group=groupWeight)
wCLV     = input.float(1.00, "Weight: Close Location", step=0.1, group=groupWeight)
wVWAP    = input.float(0.80, "Weight: VWAP Deviation", step=0.1, group=groupWeight)
wLiq     = input.float(0.60, "Weight: Liquidity Confirmation", step=0.1, group=groupWeight)
wSpread  = input.float(0.75, "Penalty: Spread / Range Risk", step=0.1, group=groupWeight)
wVPIN    = input.float(0.60, "Penalty: Toxic Flow / VPIN", step=0.1, group=groupWeight)

groupSignal = "Signal Settings"
sensitivity = input.float(2.2, "Probability Sensitivity", step=0.1, group=groupSignal)
longThr     = input.float(62.0, "Long Threshold: Prob Up >", step=0.5, group=groupSignal)
shortThr    = input.float(38.0, "Short Threshold: Prob Up <", step=0.5, group=groupSignal)
minAbsScore = input.float(0.15, "Minimum Absolute Score", step=0.05, group=groupSignal)
signalMode  = input.string("First in phase", "Signal Mode", options=["Every bar", "First in phase"], group=groupSignal)

groupTrend = "Trend Filter"
useTrend   = input.bool(true, "Use EMA Trend Filter", group=groupTrend)
emaFastLen = input.int(21, "Fast EMA", minval=2, group=groupTrend)
emaSlowLen = input.int(55, "Slow EMA", minval=5, group=groupTrend)

groupVisual = "Visual"
showBg      = input.bool(true, "Show Background", group=groupVisual)
showTable   = input.bool(true, "Show Dashboard Table", group=groupVisual)
showVWAP    = input.bool(true, "Show VWAP", group=groupVisual)
showEMA     = input.bool(true, "Show EMA Trend Lines", group=groupVisual)
showLabels  = input.bool(true, "Show Signal Labels", group=groupVisual)

//====================================================
// Helper Functions
//====================================================
f_clip(x, lo, hi) =>
    math.min(math.max(x, lo), hi)

f_zscore(src, len) =>
    mean = ta.sma(src, len)
    dev  = ta.stdev(src, len)
    dev == 0.0 or na(dev) ? 0.0 : (src - mean) / dev

f_sigmoid(x) =>
    1.0 / (1.0 + math.exp(-x))

//====================================================
// Basic Microstructure Proxies
//====================================================
barRange = math.max(high - low, syminfo.mintick)
atr      = ta.atr(atrLen)

// Close Location Value, range [-1, 1]
// 收盘位置代理：越接近高点，买方控制越强；越接近低点，卖方控制越强。
closeLocation = ((close - low) / barRange - 0.5) * 2.0
closeLocation := f_clip(closeLocation, -1.0, 1.0)

// Candle body pressure
// K线实体方向压力：阳线偏买方，阴线偏卖方。
bodySign  = close > open ? 1.0 : close < open ? -1.0 : 0.0
bodyRatio = math.abs(close - open) / barRange

// Directional pressure combines body and close location.
// 方向压力 = 实体方向 + 收盘位置。
dirPressure = 0.65 * bodySign * bodyRatio + 0.35 * closeLocation
dirPressure := f_clip(dirPressure, -1.0, 1.0)

// Approximate aggressive buy/sell volume.
// 主动买卖成交量代理，不是真实逐笔成交方向。
buyVolProxy  = volume * (dirPressure + 1.0) / 2.0
sellVolProxy = volume - buyVolProxy
deltaVol     = buyVolProxy - sellVolProxy

// Order Flow Imbalance Proxy
// 订单流不平衡代理。
ofiProxy = volume > 0 ? deltaVol / volume : 0.0
ofiProxy := f_clip(ofiProxy, -1.0, 1.0)

// CVD Proxy
// 累计成交量差代理。
cvd = ta.cum(deltaVol)
cvdSlopeRaw = ta.linreg(cvd, cvdLen, 0) - ta.linreg(cvd, cvdLen, 1)
cvdSlopeZ   = f_zscore(cvdSlopeRaw, lenZ)
cvdScore    = f_clip(cvdSlopeZ / 3.0, -1.0, 1.0)

// VWAP deviation
// VWAP 偏离：价格在 VWAP 上方偏多，下方偏空。
vwapValue = ta.vwap(hlc3)
vwapDev   = atr > 0 ? (close - vwapValue) / atr : 0.0
vwapScore = f_clip(vwapDev / 3.0, -1.0, 1.0)

// Range spread proxy
// Pine 没有真实 bid-ask spread，所以用 high-low range / price 代理短期价差风险。
rangeSpread = close != 0 ? barRange / close : 0.0
spreadZ     = f_zscore(rangeSpread, lenZ)
spreadRisk  = math.max(spreadZ, 0.0)

// Amihud illiquidity proxy
// Amihud 非流动性：单位成交额造成的价格变化。
retAbs       = math.abs(math.log(close / close[1]))
dollarVolume = math.max(volume * close, 1.0)
amihud       = retAbs / dollarVolume
amihudZ      = f_zscore(amihud, lenZ)
amihudRisk   = math.max(amihudZ, 0.0)

// Liquidity proxy
// 流动性代理：同样 range 下成交量越大，说明市场承接越厚。
liqRaw   = volume / barRange
liqZ     = f_zscore(liqRaw, lenZ)
liqScore = f_clip(liqZ / 3.0, -1.0, 1.0)

// VPIN-like proxy
// VPIN 代理：绝对订单流不平衡 / 总成交量。越高说明订单流越“有毒”，容易跳动。
vpinProxy = ta.sma(math.abs(deltaVol), vpinLen) / math.max(ta.sma(volume, vpinLen), 1.0)
vpinZ     = f_zscore(vpinProxy, lenZ)
vpinRisk  = math.max(vpinZ, 0.0)

//====================================================
// Composite Prediction Score
//====================================================
// Directional component
// 方向分数：正数偏多，负数偏空。
directionScore =
     wOFI  * ofiProxy +
     wCVD  * cvdScore +
     wCLV  * closeLocation +
     wVWAP * vwapScore

// Liquidity confirmation
// 如果订单流方向和流动性方向一致，则增强信号。
liqConfirm = math.sign(directionScore) * math.max(liqScore, 0.0)
directionScore += wLiq * liqConfirm

// Risk penalty
// spread / VPIN / Amihud 越高，信号可信度越低。
riskPenalty = 1.0 + wSpread * spreadRisk + wVPIN * vpinRisk + 0.50 * amihudRisk
rawScore    = riskPenalty > 0 ? directionScore / riskPenalty : directionScore
score       = ta.ema(rawScore, smoothLen)

// Convert to probability
// 转换为上涨概率。
probUp = 100.0 * f_sigmoid(score * sensitivity)
probDn = 100.0 - probUp

//====================================================
// Trend Filter
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

trendLong  = not useTrend or emaFast > emaSlow
trendShort = not useTrend or emaFast < emaSlow

rawLong  = probUp > longThr and score > minAbsScore and trendLong
rawShort = probUp < shortThr and score < -minAbsScore and trendShort

longSignal  = signalMode == "Every bar" ? rawLong : rawLong and not rawLong[1]
shortSignal = signalMode == "Every bar" ? rawShort : rawShort and not rawShort[1]

//====================================================
// Plots
//====================================================
plot(showVWAP ? vwapValue : na, "VWAP", color=color.new(color.yellow, 0), linewidth=2)
plot(showEMA ? emaFast : na, "Fast EMA", color=color.new(color.teal, 0), linewidth=1)
plot(showEMA ? emaSlow : na, "Slow EMA", color=color.new(color.orange, 0), linewidth=1)

plotshape(showLabels and longSignal, title="Long Signal", style=shape.labelup, text="OF Long\nProb↑", location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.small)
plotshape(showLabels and shortSignal, title="Short Signal", style=shape.labeldown, text="OF Short\nProb↓", location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

// Background
bgColor =
     probUp >= longThr  ? color.new(color.lime, 86) :
     probUp <= shortThr ? color.new(color.red, 86) :
     color.new(color.gray, 100)

bgcolor(showBg ? bgColor : na)

// Hidden plots for Data Window
plot(probUp, "Probability Up", display=display.data_window)
plot(probDn, "Probability Down", display=display.data_window)
plot(score, "Composite Score", display=display.data_window)
plot(ofiProxy, "OFI Proxy", display=display.data_window)
plot(vpinProxy, "VPIN Proxy", display=display.data_window)
plot(rangeSpread, "Range Spread Proxy", display=display.data_window)
plot(amihud, "Amihud Illiquidity", display=display.data_window)

//====================================================
// Dashboard Table
//====================================================
var table dash = table.new(position.top_right, 2, 9, border_width=1)

if showTable and barstate.islast
    table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "Prob Up")
    table.cell(dash, 1, 1, str.tostring(probUp, "#.##") + "%", text_color=probUp >= 50 ? color.lime : color.red)

    table.cell(dash, 0, 2, "Score")
    table.cell(dash, 1, 2, str.tostring(score, "#.###"), text_color=score >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 3, "OFI Proxy")
    table.cell(dash, 1, 3, str.tostring(ofiProxy, "#.###"), text_color=ofiProxy >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 4, "CVD Score")
    table.cell(dash, 1, 4, str.tostring(cvdScore, "#.###"), text_color=cvdScore >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 5, "VWAP Score")
    table.cell(dash, 1, 5, str.tostring(vwapScore, "#.###"), text_color=vwapScore >= 0 ? color.lime : color.red)

    table.cell(dash, 0, 6, "Spread Risk")
    table.cell(dash, 1, 6, str.tostring(spreadRisk, "#.###"), text_color=spreadRisk > 1 ? color.orange : color.white)

    table.cell(dash, 0, 7, "VPIN Risk")
    table.cell(dash, 1, 7, str.tostring(vpinRisk, "#.###"), text_color=vpinRisk > 1 ? color.orange : color.white)

    table.cell(dash, 0, 8, "Trend")
    table.cell(dash, 1, 8, emaFast > emaSlow ? "Bullish" : "Bearish", text_color=emaFast > emaSlow ? color.lime : color.red)

//====================================================
// Alerts
//====================================================
alertcondition(longSignal, title="Order Flow Proxy Long", message="Order Flow Proxy Long Signal")
alertcondition(shortSignal, title="Order Flow Proxy Short", message="Order Flow Proxy Short Signal")
````
