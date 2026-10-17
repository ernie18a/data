# Gold Trade Setup Strategy

- url: https://www.tradingview.com/script/25wTlm4E-Gold-Trade-Setup-Strategy/
- type: strategy
- pine_id: PUB;580da01b572c41fbb7f99653746d8244
- version: 1.0

## Description

Title: Profitable Gold Setup Strategy with Adaptive Moving Average & Supertrend

Introduction:
This trading strategy for Gold (XAU/USD) combines the Adaptive Moving Average (AMA) and Supertrend, tailored for high-probability setups during specific trading hours. The AMA identifies the trend, while the Supertrend confirms entry and exit points. The strategy is optimized for swing and intraday traders looking to capitalize on Gold’s price movements with precise trade timing.

Strategy Components:
	1.	Adaptive Moving Average (AMA):
	•	Reacts dynamically to market conditions, filtering noise in choppy markets.
	•	Serves as the primary trend indicator.
	2.	Supertrend:
	•	Confirms entry signals with clear buy and sell levels.
	•	Acts as a trailing stop-loss to protect profits.

Trading Rules:

Trading Hours:
	•	Only take trades between 8:30 AM and 10:30 PM IST.
	•	Avoid trading outside these hours to reduce noise and low-volume setups.

Buy Setup:
	1.	Trend Confirmation: The Adaptive Moving Average (AMA) must be green.
	2.	Signal Confirmation: The Supertrend should turn green after the AMA is green.
	3.	Trigger: Take the trade when the high of the trigger candle (the candle that turned Supertrend green) is broken.

Sell Setup (Optional if included):
	•	Reverse the rules for a short trade: AMA and Supertrend should both indicate bearish conditions (red), and take the trade when the low of the trigger candle is broken.

Stop-Loss and Targets:
	•	Place the stop-loss at the low of the trigger candle for long trades.
	•	Set a 1:2 risk-reward ratio or use the Supertrend line as a trailing stop-loss.

Timeframes:
	•	Recommended timeframes: 1H, 4H, or Daily for swing trading.
	•	For intraday trading, use 15-minute or 30-minute charts.

Why This Strategy Works:
	•	Combines trend-following (AMA) with momentum-based entries (Supertrend).
	•	Focused trading hours filter out low-probability setups.
	•	Provides precise entry, stop-loss, and target levels for disciplined trading.

Conclusion:
This Gold Setup Strategy is designed for traders seeking a structured approach to trading Gold. Follow the rules strictly, backtest the strategy extensively, and share your results. Let’s master the Gold market together!

Tags: #Gold #XAUUSD #SwingTrading #Intraday #Supertrend #AMA #TechnicalAnalysis #GoldStrategy

## Source Code

````pine
//@version=5
strategy("Gold Trade Setup Strategy", shorttitle="Gold Trade Setup", overlay=true)

// Inputs for AMA
length = input.int(title="AMA Length", defval=14, minval=1)
fastLength = input.int(title="Fast EMA Length", defval=2, minval=1)
slowLength = input.int(title="Slow EMA Length", defval=30, minval=1)
highlightMovements = input.bool(title="Highlight AMA Movements?", defval=true)
src = input.source(title="Source for AMA", defval=close)

// Inputs for Target and Stop Loss Levels
targetBox = input.float(title="Target Level Multiplier", defval=3.0, minval=1.0, step=0.1)
riskBox = input.float(title="Risk Level Multiplier", defval=1.0, minval=0.1, step=0.1)

// AMA Calculation
fastAlpha = 2 / (fastLength + 1)
slowAlpha = 2 / (slowLength + 1)

hh = ta.highest(src, length + 1)
ll = ta.lowest(src, length + 1)

mltp = hh - ll != 0 ? math.abs(2 * src - ll - hh) / (hh - ll) : 0.0

ssc = mltp * (fastAlpha - slowAlpha) + slowAlpha

var float ama = na
ama := na(ama[1]) ? src : ama[1] + math.pow(ssc, 2) * (src - ama[1])

amaColor = highlightMovements ? (ama > ama[1] ? color.green : color.red) : color.gray
plot(ama, title="AMA", linewidth=2, color=amaColor)

// Inputs for SuperTrend
atrPeriod = input.int(10, "ATR Length", minval=1)
factor = input.float(3.0, "Factor", minval=0.01, step=0.01)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

supertrend := barstate.isfirst ? na : supertrend
upTrend = plot(direction > 0 ? supertrend : na, "Up Trend", color=color.green, style=plot.style_linebr)
downTrend = plot(direction <= 0 ? supertrend : na, "Down Trend", color=color.red, style=plot.style_linebr)
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2, "Body Middle", display=display.none)

fill(bodyMiddle, upTrend, color.new(color.green, 90), fillgaps=false)
fill(bodyMiddle, downTrend, color.new(color.red, 90), fillgaps=false)

// Buy Condition
var bool amaGreen = false
amaGreen := ama > ama[1] and close > ama ? true : amaGreen  // AMA green and price above AMA

buyCondition = amaGreen and direction > 0 and direction[1] <= 0  // SuperTrend turns green after AMA is green

if (buyCondition)
    entryPrice = close
    targetPrice = entryPrice + (entryPrice - low) * targetBox
    stopPrice = entryPrice - (entryPrice - low) * riskBox
    strategy.entry("SELL", strategy.short)


// Sell Condition
var bool amaRed = false
amaRed := ama < ama[1] and close < ama ? true : amaRed  // AMA red and price below AMA

sellCondition = amaRed and direction <= 0 and direction[1] > 0  // SuperTrend turns red after AMA is red

if (sellCondition)
    entryPrice = close
    targetPrice = entryPrice - (high - entryPrice) * targetBox
    stopPrice = entryPrice + (high - entryPrice) * riskBox
    strategy.entry("BUY", strategy.long)
    

// Alerts for SuperTrend
alertcondition(direction[1] > direction, title="Downtrend to Uptrend", message="The Supertrend value switched from Downtrend to Uptrend")
alertcondition(direction[1] < direction, title="Uptrend to Downtrend", message="The Supertrend value switched from Uptrend to Downtrend")
alertcondition(direction[1] != direction, title="Trend Change", message="The Supertrend value switched from Uptrend to Downtrend or vice versa")
// Moon Phase Calculation
var float moonCycle = 29.53  // Average days in a lunar cycle
var float newMoonBase = timestamp(2023, 1, 21, 0, 0)  // Known New Moon date (January 21, 2023)

daysSinceNewMoon = (timenow - newMoonBase) / (24 * 60 * 60 * 1000)
phase = daysSinceNewMoon % moonCycle  // Moon phase in days

isAmavasya = phase < 1 or phase > moonCycle - 1  // Near day 0 or end of the cycle
isPurnima = phase > moonCycle / 2 - 1 and phase < moonCycle / 2 + 1  // Near day 15

// Plot Amavasya and Purnima
bgcolor(isAmavasya ? color.new(color.black, 90) : na, title="Amavasya Highlight")
bgcolor(isPurnima ? color.new(color.white, 90) : na, title="Purnima Highlight")
````
