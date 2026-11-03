Calculation: all-time high = highest chart-timeframe close from the start of the data
Calculation: drawdown = 100 × (all-time high − current chart-timeframe close) ÷ all-time high
Calculation: trailing peak = highest weekly high since entry (or highest weekly close, if configured), using completed higher-timeframe bars
Calculation: exit threshold = trailing peak × (1 − exit drawdown fraction)
Long: at a monthly, quarterly, or annual rebalance boundary, while not in the first year after a confirmed SPY recovery from a deep drawdown
Long: at a monthly or quarterly deployment boundary AND cash reserve > 0
Long: last completed higher-timeframe weekly close > its simple moving average, calculated over a longer lookback than the chart timeframe
Exit: long, last completed higher-timeframe weekly low ≤ exit threshold (or weekly close ≤ exit threshold, if configured)