Calculation: FastEMA = EMA of close; MidSMA = SMA of close; SlowSMA = SMA of close; lookbacks satisfy FastEMA < MidSMA < SlowSMA. All use the chart timeframe.
Calculation: CrossUp(X,Y) = X > Y on the last completed bar AND X < Y on the bar before it AND X > Y on the bar still forming (evaluated at its open). CrossDown(X,Y) is the mirror image.
Calculation: A = close of the last completed bar (the bar that confirms the cross).
Calculation: B_long = lowest low from the start of the current run of bars with FastEMA < SlowSMA through the last completed bar. B_short = highest high from the start of the current run of bars with FastEMA > SlowSMA through the last completed bar. B is fixed at entry.
Calculation: Fib(k) = B + k*(A - B).
Calculation: Target = Fib(1.618) by default. Let H be the high (long) or low (short) of the last completed bar of a higher timeframe than the chart (daily). If H is beyond Fib(1.618) in the profit direction, Target = Fib(1.618). Else if H is beyond Fib(1.25) in the profit direction, Target = Fib(1.25). Else if H is beyond A in the profit direction, Target = H. Else Target = Fib(1.618). Target must be at least a minimum distance from entry in the profit direction; otherwise use entry +/- the minimum distance.
Calculation: Stop = for long, the higher of (entry - max stop distance) and Fib(0.382); for short, the lower of (entry + max stop distance) and Fib(0.382).
Long: CrossUp(FastEMA, SlowSMA) AND bar time is within the allowed hours and weekdays
Short: CrossDown(FastEMA, SlowSMA) AND bar time is within the allowed hours and weekdays
Exit: long, CrossDown(FastEMA, MidSMA) AND position unrealized P/L < 0
Exit: short, CrossUp(FastEMA, MidSMA) AND position unrealized P/L < 0
Exit: long, price <= Stop OR price >= Target
Exit: short, price >= Stop OR price <= Target