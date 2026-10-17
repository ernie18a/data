# Trend Pullback EMA Combo: Algorithmic Trend Following

- url: https://www.tradingview.com/script/GJgM8vsH-trend-pullback-ema-combo-algorithmic-trend-following/
- type: strategy
- pine_id: PUB;11bcc642079540849f1b83cd852c82a4
- version: 1.0

## Description

This strategy is designed to capture high-probability trend continuations by identifying "pullbacks" within a strong structural trend. By combining the long-term smoothing of EMA 200 with the medium-term EMA 50 and the momentum oscillators of WaveTrend (VuManChu style), it filters out noise and enters trades only when price momentum aligns with the primary market direction.

he system evaluates the market based on three layers of confirmation:

Trend Filter: Defines the primary direction via EMA 200.

Pullback Zone: Looks for price positioning between EMA 50 and EMA 200 to ensure we aren't chasing overextended moves.

Trigger: Uses a crossover of WaveTrend (WT1 & WT2) to identify the momentum shift.

Entry Logic:

Long: Price > EMA 200 AND Price < EMA 50 AND WT1 crosses over WT2.

Short: Price < EMA 200 AND Price > EMA 50 AND WT1 crosses under WT2.

I am committed to making this tool as effective as possible. Your feedback is invaluable! Please share your backtest results in the comments below. If you have ideas for technical improvements or code optimizations, feel free to suggest them. Together, we can refine this system for the whole community

Disclaimer: Trading involves significant risk of loss and is not suitable for all investors. Past performance does not guarantee future results. This script is for educational purposes only. Never trade with money you cannot afford to lose.

## Source Code

````pine
//@version=5
strategy("Trend Pullback EMA50 EMA200", 
     overlay=true, 
     initial_capital=100000, 
     currency=currency.USD, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=10, 
     pyramiding=1, 
     commission_type=strategy.commission.percent, 
     commission_value=0.05, 
     slippage=1, 
     process_orders_on_close=true)

// EMA Calculations
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(ema50, title="EMA 50", color=color.blue)
plot(ema200, title="EMA 200", color=color.red)

// WaveTrend (Based on VuManChu)
length = 9
avg = 12

esa = ta.ema(close, length)
d = ta.ema(math.abs(close - esa), length)
ci = (close - esa) / (0.015 * d)
wt1 = ta.ema(ci, avg)
wt2 = ta.sma(wt1, 3)

// Strategy Conditions
longCondition = close > ema200 and close < ema50 and ta.crossover(wt1, wt2)
shortCondition = close < ema200 and close > ema50 and ta.crossunder(wt1, wt2)

// Execution
if longCondition
    strategy.entry("Long", strategy.long)

if shortCondition
    strategy.entry("Short", strategy.short)
````
