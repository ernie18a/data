# 8:30 Texas Clean Signal + HTF + Volume + Asian London Time

- url: https://www.tradingview.com/script/GC2DHjGX-8-30-Texas-Clean-Signal-HTF-Volume-Asian-London-Time/
- type: indicator
- pine_id: PUB;fecc6f40f7664e22bd203dd57847553e
- version: 1.0

## Description

ORB strategy. Opening range breakout + VWAP + EMA + RSI + MACD + HTF + Volume confluence indicator for QQQ traders. Uses the first 15-minute U.S. candle to define bias and flip conditions, with Asian and London session markers for additional context.

## Source Code

````pine
//@version=6
indicator("8:30 Texas Clean Signal + HTF + Volume + Asian London Time", overlay=true, max_labels_count=500)

// ===== INPUT =====
emaLen = input.int(20, "EMA 20 Length")
rsiLen = input.int(14, "RSI Length")

useHTFTrend = input.bool(true, "Use Higher Timeframe Confluence")
htf1 = input.timeframe("15", "HTF 1")
htf2 = input.timeframe("60", "HTF 2")
htfFastLen = input.int(50, "HTF Fast EMA")
htfSlowLen = input.int(200, "HTF Slow EMA")

useVolume = input.bool(true, "Use Volume Confirmation")
volLen = input.int(20, "Volume MA Length")
volMultiplier = input.float(1.2, "Volume Multiplier")

showDebug = input.bool(true, "Show Debug")

// ===== ASIAN / LONDON TIME MARKERS ONLY =====
showSessionTime = input.bool(true, "Show Asian/London Time")

asianHour = input.int(18, "Asian Hour Texas", minval=0, maxval=23)
asianMinute = input.int(0, "Asian Minute Texas", minval=0, maxval=59)

londonHour = input.int(2, "London Hour Texas", minval=0, maxval=23)
londonMinute = input.int(0, "London Minute Texas", minval=0, maxval=59)

// ===== EMA + VWAP =====
ema20High = ta.ema(high, emaLen)
ema20Low = ta.ema(low, emaLen)
ema20Close = ta.ema(close, emaLen)
vwapValue = ta.vwap(close)

// ===== RSI / MACD SOFT CONFLUENCE =====
rsi = ta.rsi(close, rsiLen)
rsiBull = rsi > 50
rsiBear = rsi < 50

[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
macdBull = hist > hist[1]
macdBear = hist < hist[1]

buyConfluence = rsiBull or macdBull
sellConfluence = rsiBear or macdBear

// ===== VOLUME CONFIRMATION =====
volMA = ta.sma(volume, volLen)
volumeBull = volume > volMA * volMultiplier
volumeBear = volume > volMA * volMultiplier

volumeBuyOk = useVolume ? volumeBull : true
volumeSellOk = useVolume ? volumeBear : true

// ===== HIGHER TIMEFRAME CONFLUENCE =====
htfFast1 = request.security(syminfo.tickerid, htf1, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow1 = request.security(syminfo.tickerid, htf1, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)

htfFast2 = request.security(syminfo.tickerid, htf2, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow2 = request.security(syminfo.tickerid, htf2, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfFast1 > htfSlow1 and htfFast2 > htfSlow2
htfBear = htfFast1 < htfSlow1 and htfFast2 < htfSlow2

htfBuyOk = useHTFTrend ? htfBull : true
htfSellOk = useHTFTrend ? htfBear : true

// ===== TEXAS TIME LOCK =====
txHour = hour(time, "America/Chicago")
txMinute = minute(time, "America/Chicago")

// ===== ASIAN / LONDON MARKERS ONLY =====
isAsianTime = txHour == asianHour and txMinute == asianMinute
isLondonTime = txHour == londonHour and txMinute == londonMinute

is830 = txHour == 8 and txMinute == 30
is835 = txHour == 8 and txMinute == 35
is840 = txHour == 8 and txMinute == 40
is845 = txHour == 8 and txMinute == 45

// ===== FIRST 15M CANDLE =====
var float firstHigh = na
var float firstLow = na
var float firstClose = na
var float firstVWAP = na
var int originalBias = 0
var bool firstDone = false

if is830
    firstHigh := high
    firstLow := low
    firstClose := close
    firstVWAP := vwapValue
    originalBias := 0
    firstDone := false

if is835 or is840
    firstHigh := math.max(firstHigh, high)
    firstLow := math.min(firstLow, low)
    firstClose := close
    firstVWAP := vwapValue

if is845
    originalBias := firstClose > firstVWAP ? 1 : firstClose < firstVWAP ? -1 : 0
    firstDone := true

buyBias = firstDone and originalBias == 1
sellBias = firstDone and originalBias == -1

// ===== BREAKOUT =====
breakFirstHigh = firstDone and close > firstHigh and close[1] <= firstHigh
breakFirstLow = firstDone and close < firstLow and close[1] >= firstLow

// ===== BIAS FLIP =====
sellBiasInvalid = sellBias and close > firstHigh and close > vwapValue
buyBiasInvalid = buyBias and close < firstLow and close < vwapValue

buyFlip = sellBiasInvalid
sellFlip = buyBiasInvalid

// ===== EMA FILTER =====
emaBuyOk = close > ema20High and close > ema20Close
emaSellOk = close < ema20Low and close < ema20Close

// ===== FINAL SIGNAL =====
buySignal =
     firstDone and
     close > vwapValue and
     breakFirstHigh and
     emaBuyOk and
     buyConfluence and
     htfBuyOk and
     volumeBuyOk and
     (buyBias or buyFlip)

sellSignal =
     firstDone and
     close < vwapValue and
     breakFirstLow and
     emaSellOk and
     sellConfluence and
     htfSellOk and
     volumeSellOk and
     (sellBias or sellFlip)

// ===== PLOTS =====
plot(ema20High, "EMA20 High", color=color.green, linewidth=2)
plot(ema20Low, "EMA20 Low", color=color.red, linewidth=2)
plot(ema20Close, "EMA20 Close", color=color.blue, linewidth=2)
plot(vwapValue, "VWAP", color=color.purple, linewidth=2)

plot(firstHigh, "First 15m High", color=color.gray, linewidth=2)
plot(firstLow, "First 15m Low", color=color.gray, linewidth=2)

// ===== SIGNALS =====
plotshape(buySignal, title="BUY", style=shape.labelup, text="BUY",
     location=location.belowbar, color=color.green, textcolor=color.white)

plotshape(sellSignal, title="SELL", style=shape.labeldown, text="SELL",
     location=location.abovebar, color=color.red, textcolor=color.white)

// ===== DEBUG =====
plotshape(showDebug and is830, title="8:30 Start", style=shape.circle,
     location=location.belowbar, color=color.yellow, text="START", textcolor=color.black)

plotshape(showDebug and is845 and originalBias == 1, title="BUY BIAS",
     style=shape.circle, location=location.belowbar,
     color=color.green, text="BUY BIAS", textcolor=color.white)

plotshape(showDebug and is845 and originalBias == -1, title="SELL BIAS",
     style=shape.circle, location=location.abovebar,
     color=color.red, text="SELL BIAS", textcolor=color.white)

plotshape(showDebug and sellBiasInvalid, title="FLIP BUY",
     style=shape.triangleup, location=location.belowbar,
     color=color.lime, text="FLIP BUY", textcolor=color.black)

plotshape(showDebug and buyBiasInvalid, title="FLIP SELL",
     style=shape.triangledown, location=location.abovebar,
     color=color.orange, text="FLIP SELL", textcolor=color.black)

// ===== ASIAN / LONDON TIME MARKERS ONLY =====
plotshape(showDebug and showSessionTime and isAsianTime, title="Asian Time",
     style=shape.circle, location=location.belowbar,
     color=color.blue, text="ASIAN", textcolor=color.white)

plotshape(showDebug and showSessionTime and isLondonTime, title="London Time",
     style=shape.circle, location=location.belowbar,
     color=color.orange, text="LONDON", textcolor=color.black)

// ===== ALERTS =====
alertcondition(buySignal, title="BUY Alert",
     message="BUY: 8:30 Texas bias/flip + EMA/VWAP + RSI/MACD + HTF + Volume.")

alertcondition(sellSignal, title="SELL Alert",
     message="SELL: 8:30 Texas bias/flip + EMA/VWAP + RSI/MACD + HTF + Volume.")
````
