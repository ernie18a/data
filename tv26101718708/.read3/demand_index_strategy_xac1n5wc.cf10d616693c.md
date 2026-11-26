Calculation: Setup DI = Demand Index(high, low, close, volume, power lookback, power smoothing lookback), computed on T1 bars using the current bar and sampled on chart bars
Calculation: Trigger DI = Demand Index(high, low, close, volume, power lookback, power smoothing lookback), computed on T2 bars using the current bar and sampled on chart bars
Calculation: Setup state starts inactive; on each chart bar, set it active if Setup DI <= deep level, then inactive if Setup DI > 0; otherwise retain its prior state
Calculation: Long stop starts at entry price × (1 − stop-loss percentage); in fixed mode, keep it there, and in trailing mode, update it each chart bar while long to max(previous long stop, close × (1 − stop-loss percentage))
Long: Setup state is active AND Setup DI > recovery level AND Trigger DI crosses above EMA(Trigger DI, signal lookback) calculated on chart bars
Exit: long, low <= long stop OR high >= entry price × (1 + take-profit percentage)