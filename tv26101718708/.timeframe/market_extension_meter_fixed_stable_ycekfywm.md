# Market Extension Meter (Fixed Stable)

- url: https://www.tradingview.com/script/yCekFYwM/
- type: indicator
- pine_id: PUB;3db27de990ad4989a6c5e187cee1b70f
- version: 1.0

## Description

Indicates whether the market is overheated and how likely a pullback or sideways phase is.

## Source Code

````pine
//@version=5
indicator("Market Extension Meter (Fixed Stable)", overlay=true)

// === INPUTS ===
useHTF = input.bool(true, "Use Higher Timeframe (Daily)")
htf = input.timeframe("D", "Higher Timeframe")

rsiLength = input.int(14)
stochLength = input.int(14)
emaLength = input.int(50)
atrLength = input.int(14)

// === FUNCTIONS ===
rsiFunc() => ta.rsi(close, rsiLength)
stochFunc() => ta.stoch(close, high, low, stochLength)
emaFunc() => ta.ema(close, emaLength)
atrFunc() => ta.atr(atrLength)

// === DATA ===
rsi = useHTF ? request.security(syminfo.tickerid, htf, rsiFunc()) : rsiFunc()
stoch = useHTF ? request.security(syminfo.tickerid, htf, stochFunc()) : stochFunc()
ema = useHTF ? request.security(syminfo.tickerid, htf, emaFunc()) : emaFunc()
atr = useHTF ? request.security(syminfo.tickerid, htf, atrFunc()) : atrFunc()

// === SCORE ===
rsiScore = math.min(math.max((rsi - 30) / 40 * 25, 0), 25)
stochScore = math.min(math.max((stoch - 20) / 60 * 25, 0), 25)

dist = (close - ema) / ema * 100
emaScore = math.min(math.max(dist / 10 * 25, 0), 25)

volScore = math.min(math.max((atr / close) * 100 * 10, 0), 25)

totalScore = rsiScore + stochScore + emaScore + volScore

// === STATE ===
state = totalScore > 70 ? "OVERHEATED 🔴" : totalScore < 30 ? "COMPRESSED 🟢" : "NEUTRAL 🟡"
colorState = totalScore > 70 ? color.red : totalScore < 30 ? color.green : color.yellow

// === TOP CENTER DISPLAY (LOGO STYLE) ===
var table t = table.new(position.top_center, 1, 1)

if bar_index % 5 == 0
    table.cell( t, 0, 0, "Extension: " + state + "\nScore: " + str.tostring(math.round(totalScore)), text_color=color.black, bgcolor=colorState )

// === PLOT ===
plot(totalScore, "Extension Score", color=colorState, linewidth=2)
hline(70)
hline(30)
````
