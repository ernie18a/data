# Institutional Accumulation Engine 

- url: https://www.tradingview.com/script/IvCSwuXf-Institutional-Accumulation-Engine/
- type: indicator
- pine_id: PUB;304a3008895844bd983997468ad4490d
- version: 1.0

## Description

Relative Strength (RS) vs Nifty
Measures whether the stock is outperforming the benchmark—early sign of institutional interest.
Price–Volume Behavior
Detects accumulation through rising prices with strong volume and flags distribution via heavy selling.
Smart Money Flow (A/D Line)
Uses the Accumulation/Distribution concept to track underlying demand and supply dynamics [5
].
Volatility Compression & Breakout Setup
Identifies consolidation phases that often precede major breakouts.
Breakout Probability Score
Combines compression, volume spikes, and price breakout to estimate likelihood of a move.
PE Expansion Proxy Model
Detects early re-rating conditions using price strength, moderate RSI, and improving relative strength.

## Source Code

````pine
//@version=6
indicator("Institutional Accumulation Engine PRO (v6 Clean)", overlay=false)

// ===== INPUT =====
niftySymbol = input.symbol("NSE:NIFTY", "Benchmark")

// ===== DATA =====
nifty = request.security(niftySymbol, timeframe.period, close)

// ===== CORE =====
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
rsi = ta.rsi(close, 14)
atr = ta.atr(14)
atrAvg = ta.sma(atr, 50)
volAvg = ta.sma(volume, 30)

// ===== RELATIVE STRENGTH =====
rs = close / nifty
rsMA = ta.sma(rs, 50)

float rsScore = 0.0
rsScore := rsScore + (rs > rsMA ? 3 : 0)
rsScore := rsScore + (ta.roc(close, 20) > 0 ? 2 : 0)

// ===== BREAKOUT =====
compression = atr < atrAvg
volSpike = volume > volAvg
rangeHigh = ta.highest(high, 20)

float breakoutScore = 0.0
breakoutScore := breakoutScore + (compression ? 2 : 0)
breakoutScore := breakoutScore + (volSpike ? 2 : 0)
breakoutScore := breakoutScore + (close > rangeHigh[1] ? 1 : 0)

// ===== PE EXPANSION =====
float peScore = 0.0
peScore := peScore + (close > ema50 ? 2 : 0)
peScore := peScore + (rsi < 65 ? 2 : 0)
peScore := peScore + (rs > rsMA ? 1 : 0)

// ===== SMART MONEY (A/D) =====
priceRange = high - low
safeRange = priceRange == 0 ? 0.01 : priceRange

mfm = ((close - low) - (high - close)) / safeRange
ad = ta.cum(mfm * volume)

float smartScore = 0.0
smartScore := smartScore + (ad > ta.sma(ad, 20) ? 3 : 0)
smartScore := smartScore + (volSpike ? 2 : 0)

// ===== PRICE-VOLUME =====
float pvScore = 0.0
pvScore := pvScore + (close > ema50 ? 2 : 0)
pvScore := pvScore + (volume > volAvg ? 2 : 0)
pvScore := pvScore + (close > close[1] ? 1 : 0)

// ===== VOLATILITY =====
volScore = compression ? 4 : 1

// ===== FINAL SCORE =====
totalScore =
     pvScore * 20 +
     smartScore * 20 +
     rsScore * 15 +
     peScore * 15 +
     breakoutScore * 15 +
     volScore * 15

finalScore = totalScore / 5

// ===== PHASE =====
phase =
     finalScore > 70 ? "Strong Accumulation" :
     finalScore > 60 ? "Accumulation" :
     finalScore < 40 ? "Distribution" :
     "Neutral"

// ===== CONFIDENCE =====
confidence =
     finalScore > 80 or finalScore < 30 ? "High" :
     finalScore > 65 or finalScore < 40 ? "Medium" :
     "Low"

// ===== OUTPUT =====
plot(finalScore, title="Institutional Score", color=color.blue, linewidth=2)

hline(70, "Accumulation Zone", color=color.green)
hline(40, "Distribution Zone", color=color.red)

// Show label only on last bar
if barstate.islast
    label.new(bar_index, finalScore,
         "Score: " + str.tostring(math.round(finalScore)) +
         "\nPhase: " + phase +
         "\nConfidence: " + confidence,
         style=label.style_label_up,
         size=size.small)
````
