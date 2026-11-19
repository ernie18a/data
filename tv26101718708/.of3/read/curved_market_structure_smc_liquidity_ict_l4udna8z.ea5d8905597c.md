Calculation: Upper curve = EMA(EMA(close, curve lookback), round(curve lookback / 2)) + EMA(StDev(close, curve lookback), curve lookback) * curve multiplier
Calculation: Lower curve = EMA(EMA(close, curve lookback), round(curve lookback / 2)) - EMA(StDev(close, curve lookback), curve lookback) * curve multiplier
Calculation: Equilibrium = (Highest(high, equilibrium lookback) + Lowest(low, equilibrium lookback)) / 2
Calculation: Body fraction = if high > low then abs(close - open) / (high - low) else 0
Long: RSI(close, sweep RSI lookback) > buy RSI threshold AND close > open AND (low <= Lower curve OR low[1] <= Lower curve[1]) AND bars since previous long signal >= signal cooldown
Short: RSI(close, sweep RSI lookback) < sell RSI threshold AND close < open AND (high >= Upper curve OR high[1] >= Upper curve[1]) AND bars since previous short signal >= signal cooldown
Long: close crosses above the latest confirmed pivot high, using swing sensitivity for both left and right lookbacks
Short: close crosses below the latest confirmed pivot low, using swing sensitivity for both left and right lookbacks
Long: Body fraction >= consolidation threshold AND close > open
Short: Body fraction >= consolidation threshold AND close < open
Exit: Long, high >= Equilibrium OR high >= Upper curve OR high >= latest confirmed pivot high
Exit: Short, low <= Equilibrium OR low <= Lower curve OR low <= latest confirmed pivot low