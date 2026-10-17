# KDJ L2: Advanced Momentum & Reversal Strategy

- url: https://www.tradingview.com/script/0mCoTcC1-kdj-l2-advanced-momentum-reversal-strategy/
- type: strategy
- pine_id: PUB;a03f276fdc184201bebc4590d582c5f8
- version: 1.0

## Description

This strategy utilizes an optimized KDJ oscillator to identify high-probability momentum shifts. By refining the traditional stochastic approach, it captures the "sweet spot" of trend reversals and breakout continuations, filtering out market noise. Its edge lies in the sensitivity of the J-line, allowing for timely entries before the crowd catches on

Long Entry: Triggered when the J-line crosses above the BuyAlertLimit.

Exit Logic: Positions are closed either when the J-line crosses below the SellAlertLimit or when the J-line crosses below the K-line (suggesting momentum exhaustion) while above the 50-level.

I built this tool to make trading more systematic. Your feedback is the engine of its evolution! Please share your backtest results in the comments—let me know which pairs and timeframes work best for you. If you have ideas for adding trailing stops or new filters, drop a comment below. Together, we can make this the most robust KDJ tool on the platform

Disclaimer
Trading involves significant risk of loss. This script is for educational purposes only and does not constitute financial advice. Past performance does not guarantee future results. Always perform your own due diligence before trading with real capital

## Source Code

````pine
//@version=5
strategy('KDJ L2: Advanced Momentum & Reversal Strategy', 
     overlay=false, 
     initial_capital=100000, 
     currency=currency.USD,
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=10,
     pyramiding=1,
     commission_type=strategy.commission.percent, 
     commission_value=0.05, 
     slippage=1,
     process_orders_on_close=true)

// Inputs
BuyAlertLimit = input.int(0, step=1, title='BuyAlertLimit')
SellAlertLimit = input.int(100, step=1, title='SellAlertLimit')

// Helper Functions
xrf(values, length) =>
    r_val = float(na)
    if length >= 1
        for i = 0 to length by 1
            if na(r_val) or not na(values[i])
                r_val := values[i]
    r_val

xsa(src, len, wei) =>
    sumf = 0.0
    ma = 0.0
    out = 0.0
    sumf := nz(sumf[1]) - nz(src[len]) + src
    ma := na(src[len]) ? na : sumf / len
    out := na(out[1]) ? ma : (src * wei + out[1] * (len - wei)) / len
    out

// KDJ Parameters
n1 = input.int(18, title='n1', minval=1)
m1 = input.int(4, title='m1', minval=1)
m2 = input.int(4, title='m2', minval=1)

// KDJ Calculation
rsv = (close - ta.lowest(low, n1)) / (ta.highest(high, n1) - ta.lowest(low, n1)) * 100
k = xsa(rsv, m1, 1)
d = xsa(k, m2, 1)
j = 3 * k - 2 * d

// --- Strategy Logic ---

// Entry and Exit conditions based on signals
longCondition = ta.crossover(j, BuyAlertLimit)
exitCondition = ta.crossunder(j, SellAlertLimit) or (ta.crossunder(j, k) and j > 50)

if (longCondition)
    strategy.entry("Long", strategy.long)

if (exitCondition)
    strategy.close("Long")

// --- Visualization ---
plot(k, color=color.new(color.white, 0), title="K")
plot(d, color=color.new(color.yellow, 0), title="D")
plot(j, color=j > j[1] ? color.fuchsia : color.red, linewidth=2, title="J")

bgcolor(longCondition ? color.new(color.lime, 80) : na)
bgcolor(exitCondition ? color.new(color.red, 80) : na)

hline(0, color=color.yellow, linestyle=hline.style_dotted)
hline(100, color=color.red, linestyle=hline.style_dotted)
````
