# Nifty Institutional Trend Rider om

- url: https://www.tradingview.com/script/DgucR632-Nifty-Institutional-Trend-Rider-om/
- type: strategy
- pine_id: PUB;0ed0dc767a8e417980fc0f161825d7f9
- version: 1.0

## Description

How this manages your "Big Lots" and "Cutting":

    High Conviction Entry: It only enters CE when the RSI is above 60. This means you aren't just guessing; you are entering when momentum is already strong.

    The "VWAP" Guard: Big players (FIIs/DIIs) use VWAP. By staying on the same side as VWAP, you avoid being "trapped" by big institutional sell-offs.

    Automatic "Cutting" (Trailing SL): The red line that appears on your chart when you are in a trade is your Trailing Stop Loss.

        As Nifty moves in your favor, this line moves up.

        If Nifty reverses by 0.5% (you can change this in settings), the script will signal to "Cut" the trade immediately. This protects your capital on big lot sizes.

    Long Term Trend: By using the 15-minute timeframe instead of 5-min, you will catch the moves that last for 2–3 hours (or even until the 3:30 PM close), which is where the real money is made in Nifty options.

## Source Code

````pine
//@version=5
strategy("Nifty Institutional Trend Rider", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- Inputs ---
rsiLen = input.int(14, "RSI Length")
rsiUpper = input.int(60, "RSI Bullish (CE) Level")
rsiLower = input.int(40, "RSI Bearish (PE) Level")
emaLen = input.int(20, "Trend Filter EMA")
trailPerc = input.float(0.5, "Trailing Stop Loss (%)", step=0.1) / 100

// --- Indicators ---
rsiValue = ta.rsi(close, rsiLen)
vwapValue = ta.vwap(close)
emaValue = ta.ema(close, emaLen)

// --- Logic ---
longCondition = close > vwapValue and close > emaValue and rsiValue > rsiUpper
shortCondition = close < vwapValue and close < emaValue and rsiValue < rsiLower

// --- Execution ---
if (longCondition)
    strategy.entry("CE Entry", strategy.long)

if (shortCondition)
    strategy.entry("PE Entry", strategy.short)

// --- Professional "Cutting" (Trailing Stop Loss) ---
// This automatically "cuts" your big lots if the market moves against you
longStopPrice = 0.0
longStopPrice := if (strategy.position_size > 0)
    stopValue = close * (1 - trailPerc)
    math.max(stopValue, nz(longStopPrice[1]))
else
    0.0

shortStopPrice = 0.0
shortStopPrice := if (strategy.position_size < 0)
    stopValue = close * (1 + trailPerc)
    math.min(stopValue, nz(shortStopPrice[1] == 0 ? 999999 : shortStopPrice[1]))
else
    999999

if (strategy.position_size > 0)
    strategy.exit("Exit CE", "CE Entry", stop=longStopPrice)

if (strategy.position_size < 0)
    strategy.exit("Exit PE", "PE Entry", stop=shortStopPrice)

// --- Visuals ---
plot(vwapValue, color=color.orange, title="VWAP (Institutional Avg)")
plot(emaValue, color=color.blue, title="Trend EMA")
plot(strategy.position_size > 0 ? longStopPrice : na, color=color.red, style=plot.style_linebr, title="Trailing SL")
plot(strategy.position_size < 0 ? shortStopPrice : na, color=color.red, style=plot.style_linebr, title="Trailing SL")
````
