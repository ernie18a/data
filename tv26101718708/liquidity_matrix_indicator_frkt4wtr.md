# Liquidity Matrix Indicator

- url: https://www.tradingview.com/script/FrkT4WTr-Liquidity-Matrix-Indicator/
- type: indicator
- pine_id: PUB;3b86076ef1084812bea3846087d1fc4b
- version: 1.0

## Description

Liquidity Matrix Indicator
Smart Money • AI Confluence • Precision Entries

🧠 Overview
Liquidity Matrix Indicator is an advanced multi-confluence trading system built to detect high-probability entries using a fusion of:

[list]
[*]Smart Money Concepts (SMC)
[*]Liquidity Sweeps & Stop Hunts
[*]Break of Structure (BOS)
[*]Fair Value Gaps (FVG)
[*]Trend & Higher Timeframe Alignment
[*]AI-Based Signal Scoring
[/list]

This indicator is designed for traders who want to move beyond basic indicators and trade with institutional logic and precision.

⚡ Core Features
🔹 Trend Intelligence Engine
[list]
[*]Uses EMA 50 for directional bias
[*]Uses EMA 200 for higher timeframe confirmation
[*]Filters trades to align with dominant market direction
[/list]
💧 Liquidity Sweep Detection
Identifies buy-side & sell-side liquidity zones
Detects stop hunts where smart money traps retail traders
Highlights potential reversal zones
🔥 Market Structure (BOS)
Detects Break of Structure for confirmation of momentum
Ensures trades are taken only when structure supports the move
⚡ Fair Value Gap (FVG) Detection
Identifies price imbalances
Confirms institutional activity and strong directional intent
🎯 Dual Entry System
🔄 Reversal Mode (SMC Logic)

Triggered when:

Liquidity sweep ✔
BOS ✔
FVG ✔

👉 Ideal for catching market turning points

📈 Trend Continuation Mode
[list]
[*]Pullback to EMA zone
[*]Strong confirmation candle
[/list]

👉 Designed to ride established trends

🤖 AI Signal Scoring System
Each setup is evaluated using a weighted scoring model:
[list]
[*]Trend Alignment
[*]HTF Confirmation
[*]Liquidity Sweep
[*]BOS
[*]FVG
[*]Candle Strength
[/list]

✅ Only signals with score ≥ 60 are triggered
👉 Filters out low-quality trades

💪 Strength Filter (Volatility-Based)
[list]
[*]Uses ATR-based candle strength detection
[*]Avoids weak or indecisive market conditions
[/list]

📊 Built-in Risk Management
[list]
[*]Automatic Stop Loss (ATR-based)
[*]Dynamic Take Profit (Risk:Reward based)
[*]Default optimized for 1:2 RR
[/list]

📺 Smart Dashboard
Displays real-time:
[list]
[*]Trend direction
[*]Higher timeframe bias
[*]Market volatility (ATR)
[/list]

🔔 Alerts Ready
Instant BUY / SELL alerts
Perfect for automation & scalping workflows

🎯 Best Use Cases
[list]
[*]Intraday trading
[*]Scalping
[*]Swing trading
[*]Forex / Crypto / Indices
[/list]

✅ Advantages
✔ Multi-layer confluence system
✔ Smart money + trend hybrid approach
✔ High-quality filtered signals
✔ Built-in SL/TP logic
✔ Clean and non-cluttered visuals
✔ Works across multiple timeframes

⚠️ Limitations
May produce fewer signals in low volatility markets
Not ideal for highly ranging/choppy conditions
Requires basic understanding of market structure for best results

💡 Pro Tips
Use during high liquidity sessions (London / New York)
[list]
[*]Avoid sideways markets
[*]Combine with key support/resistance zones
[*]Focus on quality setups over quantity
[/list]

🏁 Final Note
Liquidity Matrix Indicator is not just an indicator — it’s a decision-making framework built to help traders align with smart money behavior and execute with confidence.

⚠️ Disclaimer

This indicator is intended for educational and informational purposes only and does not constitute financial, investment, or trading advice.

Trading in financial markets, including forex, cryptocurrencies, and derivatives, involves substantial risk and may not be suitable for all investors. You may lose part or all of your invested capital.

Past performance, Back-testing results, or example trades shown using Liquidity Matrix Indicator do not guarantee future results. Market conditions can change rapidly, and no indicator can predict outcomes with certainty.

Users are solely responsible for their own trading decisions. It is strongly recommended to:
[list]
[*]Use proper risk management
[*]Test strategies on a demo account before live trading
[*]Consult with a qualified financial advisor if needed
[/list]

By using this indicator, you agree that the creator is not liable for any financial losses or damages incurred.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © srini_mallareddy

//@version=6
indicator("Liquidity Matrix Indicator", overlay=true, max_labels_count=500)

// ================= INPUTS =================
len     = input.int(10, "Liquidity Lookback")
bosLen  = input.int(10, "BOS Lookback")
atrLen  = input.int(14, "ATR Length")
emaLen  = input.int(50, "EMA 50")
htfLen  = input.int(200, "EMA 200")
rr      = input.float(2.0, "Risk Reward")
slMult  = input.float(1.0, "SL ATR Multiplier")

// ================= CORE =================
atr     = ta.atr(atrLen)
ema     = ta.ema(close, emaLen)
htfEma  = ta.ema(close, htfLen)

plot(ema, color=color.yellow, linewidth=2)
plot(htfEma, color=color.blue, linewidth=2)

// ================= TREND =================
trendBull = close > ema
trendBear = close < ema
htfBull   = close > htfEma
htfBear   = close < htfEma

// ================= LIQUIDITY =================
liqHigh = ta.highest(high[1], len)
liqLow  = ta.lowest(low[1], len)

// ================= STOP HUNT =================
stopHuntSell = high > liqHigh and close < liqHigh
stopHuntBuy  = low < liqLow and close > liqLow

plotshape(stopHuntBuy,  location=location.belowbar, color=color.orange, style=shape.circle, size=size.tiny, title="Stop Hunt Buy")
plotshape(stopHuntSell, location=location.abovebar, color=color.orange, style=shape.circle, size=size.tiny, title="Stop Hunt Sell")

// ================= BOS =================
bullBOS = close > ta.highest(high[1], bosLen)
bearBOS = close < ta.lowest(low[1], bosLen)

// ================= FVG =================
bullFVG = low > high[2]
bearFVG = high < low[2]

// ================= TREND SETUP =================
emaZone = atr * 0.3

pullbackSell = trendBear and high >= ema - emaZone
pullbackBuy  = trendBull and low <= ema + emaZone

bearConfirm = close < open and close < close[1]
bullConfirm = close > open and close > close[1]

// ================= SIGNAL LOGIC =================
revBuy  = stopHuntBuy and bullBOS and bullFVG
revSell = stopHuntSell and bearBOS and bearFVG

trendBuy  = pullbackBuy and bullConfirm
trendSell = pullbackSell and bearConfirm

bodySize     = math.abs(close - open)
strongCandle = bodySize > atr * 0.5

validBuy  = (revBuy or trendBuy) and trendBull and htfBull and strongCandle
validSell = (revSell or trendSell) and trendBear and htfBear and strongCandle

// ================= AI SCORE =================
scoreBuy = 0.0
scoreSell = 0.0

scoreBuy += trendBull  ? 20 : 0
scoreBuy += htfBull    ? 20 : 0
scoreBuy += stopHuntBuy ? 20 : 0
scoreBuy += bullBOS    ? 15 : 0
scoreBuy += bullFVG    ? 15 : 0
scoreBuy += strongCandle ? 10 : 0

scoreSell += trendBear ? 20 : 0
scoreSell += htfBear   ? 20 : 0
scoreSell += stopHuntSell ? 20 : 0
scoreSell += bearBOS   ? 15 : 0
scoreSell += bearFVG   ? 15 : 0
scoreSell += strongCandle ? 10 : 0

// ================= SIGNAL FILTER =================
var int lastSignal = 0

buySignal  = validBuy  and scoreBuy >= 60 and lastSignal != 1
sellSignal = validSell and scoreSell >= 60 and lastSignal != -1

if buySignal
    lastSignal := 1
if sellSignal
    lastSignal := -1

// ================= SL / TP =================
longSL = close - atr * slMult
longTP = close + (close - longSL) * rr

shortSL = close + atr * slMult
shortTP = close - (shortSL - close) * rr

// ================= VISUALS =================
plotshape(buySignal,  location=location.belowbar, color=color.green, style=shape.labelup,   text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red,   style=shape.labeldown, text="SELL")

// SL/TP Lines
if buySignal
    line.new(bar_index, longSL, bar_index+10, longSL, color=color.red)
    line.new(bar_index, longTP, bar_index+10, longTP, color=color.green)

if sellSignal
    line.new(bar_index, shortSL, bar_index+10, shortSL, color=color.red)
    line.new(bar_index, shortTP, bar_index+10, shortTP, color=color.green)

// ================= AI LABEL =================
if buySignal
    label.new(bar_index, low, "AI BUY: " + str.tostring(scoreBuy), style=label.style_label_up, color=color.green)

if sellSignal
    label.new(bar_index, high, "AI SELL: " + str.tostring(scoreSell), style=label.style_label_down, color=color.red)

// ================= DASHBOARD =================
var table dash = table.new(position.top_right, 2, 3)

if bar_index % 10 == 0
    table.cell(dash, 0, 0, "Trend", text_color=color.white)
    table.cell(dash, 1, 0, trendBull ? "BULLISH" : "BEARISH", text_color=trendBull ? color.green : color.red)

    table.cell(dash, 0, 1, "HTF", text_color=color.white)
    table.cell(dash, 1, 1, htfBull ? "BULL" : "BEAR", text_color=htfBull ? color.green : color.red)

    table.cell(dash, 0, 2, "ATR", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(atr))

// ================= ALERTS =================
alertcondition(buySignal,  "BUY ALERT",  "ELITE BUY Signal")
alertcondition(sellSignal, "SELL ALERT", "ELITE SELL Signal")
````
