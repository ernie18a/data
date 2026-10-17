# stoch pop and RSI2 strategy

- url: https://www.tradingview.com/script/0EJ6ny4g-stoch-pop-and-RSI2-strategy/
- type: strategy
- pine_id: PUB;4MNMSQtGRYtieE7rjT5I7JHvjVNyLq36
- version: 1.0

## Description

I have combined stochsatic POP and RSI2 strategy.   

Go Long on stochstaic > 80 and  RSI2 pulled back to 30 (note when you are entering Long, check that stochsatic is still above 80 )

Close Long  when stochastic crossing down 55

I have back tested this on SPY weekly.  It has less trades but  high profitable with very less draw down.

Other time frames you have more signals but , not great winning rate.   

Since this is weekly setup, good for investing ... long waiting to close , patience required :-)

## Source Code

````pine
strategy(title="stoch pop setup for IBD stocks", overlay=false, default_qty_value=3,
    initial_capital=10000, currency=currency.USD)

//Stochastic Calculation
k = sma(stoch(close, high, low, 70), 3)

//Upper and Lower Entry Lines
uline = 80
lline = 30

plot(k, title="Stochastic", style=line, linewidth=2, color=blue)

p1 = plot(uline, title="Upper Line", style=line, linewidth=2, color=green)
p3 = plot(lline, title="Lower Line", style=line, linewidth=2, color=red)

rsi2val = rsi(close,2)

// Determine long and short conditions
longCondition  =  k > 80 and crossover(rsi2val , 30) 
//crossover(k, uline) and rsi2val < 30
longCloseCondition = crossunder(k, 55) and rsi2val < 80

// Submit orders
strategy.entry(id="Long Entry", long=true, when=longCondition)
strategy.close(id="Long Entry", when=longCloseCondition)
````
