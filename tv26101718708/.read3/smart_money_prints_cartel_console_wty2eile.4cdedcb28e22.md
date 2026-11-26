Calculation: Buy interest = SUM(RSI(NVI - EMA(NVI, EMA lookback), flow lookback) / RSI(PVI - EMA(PVI, EMA lookback), flow lookback), summation lookback)
Calculation: Sell interest = SUM((100 - RSI(NVI - EMA(NVI, EMA lookback), flow lookback)) / (100 - RSI(PVI - EMA(PVI, EMA lookback), flow lookback)), summation lookback)
Calculation: MSS trend = starts upward; switches from upward to downward when low[swing lookback] <= Lowest(low, swing lookback), and from downward to upward when high[swing lookback] >= Highest(high, swing lookback)
Calculation: Latest MSS high = high[swing lookback] at each switch from downward to upward; otherwise retains its prior value
Calculation: Latest MSS low = low[swing lookback] at each switch from upward to downward; otherwise retains its prior value
Calculation: Up break = the first bar with close > latest MSS high after each switch from downward to upward; the up-break flag resets at that switch and is set at that bar
Calculation: Down break = the first bar with close < latest MSS low after each switch from upward to downward; the down-break flag resets at that switch and is set at that bar
Calculation: Prior MSS break direction = direction of the most recent up or down break before the current bar, including breaks that did not produce a signal; initially unset
Long: Up break AND (prior MSS break direction is downward or unset) AND Buy interest > Sell interest
Short: Down break AND (prior MSS break direction is upward or unset) AND Sell interest > Buy interest