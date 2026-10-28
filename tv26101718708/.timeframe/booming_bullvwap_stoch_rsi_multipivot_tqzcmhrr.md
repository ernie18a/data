# Booming Bull:VWAP + Stoch RSI + Multi-Pivot

- url: https://www.tradingview.com/script/TQzcMHrR-Booming-Bull-VWAP-Stoch-RSI-Multi-Pivot/
- type: strategy
- pine_id: PUB;cc0085b9d5d044f8895abc841a4308c1
- version: 1.0

## Description

Booming Bull: VWAP + Stoch RSI + Multi-Pivot Strategy
Overview
This strategy is an automated implementation of the "Ultimate Intraday Strategy" popularized by Anish Singh Thakur (Booming Bulls). It combines Trend (VWAP), Momentum (Stochastic RSI), and Value Levels (Daily Fibonacci Pivots) to capture high-probability intraday reversals and breakouts.

Core Logic
The strategy operates on a 5-minute timeframe and relies on a triple-confirmation system:

The Filter (VWAP): Ensures we only trade in the direction of the daily average price. Buy above VWAP, Sell below VWAP.

The Trigger (Pivot Points): Uses Fibonacci Daily Pivots (P, R1-R3, S1-S3). A trade is only considered when the price physically crosses one of these key levels.

The Momentum (Stochastic RSI): Confirms that the momentum is shifting in our favor to avoid "fake-outs."

Key Features
Efficiency Filter (Toggle):

ON: Allows for smoother entries. It triggers if the Pivot is crossed while VWAP and Stoch RSI are already in a bullish/bearish state.

OFF: Requires all three indicators to "snap" and cross on the exact same candle (more conservative).

Multi-Pivot Entry: Unlike standard versions that only look at the central Pivot (P), this script can be toggled to trigger entries on S1, S2, S3 or R1, R2, R3 levels.

Automated Risk Management: * Choose between a fixed 1% Price Target or a dynamic Risk/Reward (1:1.5) target.

Stop Loss is automatically placed at the high/low of the entry candle for precise risk control.

Intraday Auto-Exit: All positions are forcibly closed at 15:00 (3:00 PM IST) to avoid overnight gaps and volatility.

How to Use
Timeframe: Optimized for the 5-minute chart.

Session: Defaulted to Indian Standard Time (GMT+530).

Execution: Use the "Strategy Tester" tab to view backtest results for your favorite stocks (e.g., Bajaj Finance, Reliance, Nifty).

## Source Code

````pine

//@version=6
strategy("Booming Bull:VWAP + Stoch RSI + Multi-Pivot", 
     overlay=true, 
     margin_long=100, 
     margin_short=100, 
     initial_capital=5000000, 
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=50,
     calc_on_every_tick=true)
// ==========================
// ⚙️ SETTINGS & TOGGLES
// ==========================
efficiencyFilter  = input.bool(true, "Enable Efficiency Filter", tooltip="ON: Pivot cross triggers if VWAP/Stoch are ALREADY aligned. OFF: All must cross on same candle.")
onlyCentralPivot  = input.bool(false, "Only Central Pivot", tooltip="ON: Only the 'P' line triggers trades. OFF: P, R1, R2, R3, S1, S2, S3 all act as triggers.")
tzOffset          = input.string("GMT+530", "Timezone Offset", tooltip="Use GMT+530 for Indian Standard Time (IST)")
// Session & Profit Settings
sessionInput      = input.session("0915-1500", "Trading Session Entry Window")
profitMode        = input.string("Risk/Reward", "Profit Mode", options=["1% Price", "Risk/Reward"])
rrRatio           = input.float(1.5, "Risk/Reward Ratio", minval=0.1)
// ==========================
// 📊 INDICATORS & PIVOT LEVELS
// ==========================
// 1. VWAP
vwapVal = ta.vwap(hlc3)
plot(vwapVal, color=color.yellow, linewidth=2, title="VWAP")
// 2. DAILY PIVOT CALCULATIONS (Standard)
ph = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
p  = (ph + pl + pc) / 3
r1 = (p * 2) - pl
s1 = (p * 2) - ph
r2 = p + (ph - pl)
s2 = p - (ph - pl)
r3 = ph + 2 * (p - pl)
s3 = pl - 2 * (ph - p)
// ✅ ALL LEVELS NOW VISIBLE BY DEFAULT
plot(p,  "P",  color=color.blue,   style=plot.style_linebr)
plot(r1, "R1", color=color.red,    style=plot.style_linebr)
plot(s1, "S1", color=color.green,  style=plot.style_linebr)
plot(r2, "R2", color=color.maroon, style=plot.style_linebr)
plot(s2, "S2", color=color.lime,   style=plot.style_linebr)
plot(r3, "R3", color=color.red,    style=plot.style_linebr)
plot(s3, "S3", color=color.green,  style=plot.style_linebr)
// ==========================
// 📊 STOCHASTIC RSI
// ==========================
rsiVal = ta.rsi(close, 14)
stochK = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, 14), 3)
stochD = ta.sma(stochK, 3)
// ==========================
// 📌 TRIGGER LOGIC
// ==========================
inSession = not na(time(timeframe.period, sessionInput, tzOffset))
pivotCrossDown = onlyCentralPivot ? ta.crossunder(close, p) : (ta.crossunder(close, p) or ta.crossunder(close, r1) or ta.crossunder(close, r2) or ta.crossunder(close, r3) or ta.crossunder(close, s1) or ta.crossunder(close, s2) or ta.crossunder(close, s3))
pivotCrossUp   = onlyCentralPivot ? ta.crossover(close, p)  : (ta.crossover(close, p)  or ta.crossover(close, r1)  or ta.crossover(close, r2)  or ta.crossover(close, r3)  or ta.crossover(close, s1)  or ta.crossover(close, s2)  or ta.crossover(close, s3))
stochCrossDown = ta.crossunder(stochK, stochD)
stochCrossUp   = ta.crossover(stochK, stochD)
stochIsBearish = stochK < stochD
stochIsBullish = stochK > stochD
bool sellCondition = false
bool buyCondition  = false
if efficiencyFilter
    sellCondition := inSession and close < vwapVal and stochIsBearish and pivotCrossDown
    buyCondition  := inSession and close > vwapVal and stochIsBullish and pivotCrossUp
else
    sellCondition := inSession and close < vwapVal and stochCrossDown and pivotCrossDown
    buyCondition  := inSession and close > vwapVal and stochCrossUp   and pivotCrossUp
// ==========================
// 🎯 EXECUTION & PROFIT BOOKING
// ==========================
var float sl = 0.0
var float tp = 0.0
if (sellCondition and strategy.position_size == 0)
    sl := high
    float risk = sl - close
    tp := (profitMode == "1% Price") ? close * 0.99 : close - (risk * rrRatio)
    strategy.entry("SELL", strategy.short)
    strategy.exit("Exit Short", "SELL", stop=sl, limit=tp)
if (buyCondition and strategy.position_size == 0)
    sl := low
    float risk = close - sl
    tp := (profitMode == "1% Price") ? close * 1.01 : close + (risk * rrRatio)
    strategy.entry("BUY", strategy.long)
    strategy.exit("Exit Long", "BUY", stop=sl, limit=tp)
// ==========================
// ⛔ TIME-BASED EXIT (15:00)
// ==========================
currTimeMinutes = hour(time, tzOffset) * 60 + minute(time, tzOffset)
if (currTimeMinutes >= 900)
    strategy.close_all(comment="EOD Exit at 15:00")
// ==========================
// 📈 VISUALS
// ==========================
barcolor(stochIsBullish ? color.new(color.teal, 50) : color.new(color.maroon, 50))
````
