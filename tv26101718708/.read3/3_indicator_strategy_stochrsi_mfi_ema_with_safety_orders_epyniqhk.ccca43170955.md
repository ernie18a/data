Calculation: Unrealized P&L percentage = 100 × open P&L / abs(average entry price × position quantity)
Long: long entries enabled AND flat position AND Stochastic RSI D(source, RSI lookback, stochastic lookback, K smoothing, D smoothing) < long Stochastic RSI threshold AND MFI(source, lookback) < long MFI threshold AND close < EMA(source, lookback)
Short: short entries enabled AND flat position AND Stochastic RSI D(source, RSI lookback, stochastic lookback, K smoothing, D smoothing) > short Stochastic RSI threshold AND MFI(source, lookback) > short MFI threshold AND close > EMA(source, lookback)
Long: long position AND Unrealized P&L percentage ≤ -safety-order deviation AND safety-order count < maximum safety orders
Short: short position AND Unrealized P&L percentage ≤ -safety-order deviation AND safety-order count < maximum safety orders
Exit: Long, long position AND Unrealized P&L percentage ≤ -safety-order deviation AND safety-order count ≥ maximum safety orders - 1
Exit: Short, short position AND Unrealized P&L percentage ≤ -safety-order deviation AND safety-order count ≥ maximum safety orders
Exit: Long, currency-threshold exit selected AND (open P&L > base target × risk/reward ratio OR open P&L ≤ -base target)
Exit: Short, currency-threshold exit selected AND (open P&L > base target × risk/reward ratio OR open P&L ≤ -base target)
Exit: Long, tick-distance exit selected AND (high ≥ average entry price + long take-profit distance in ticks OR low ≤ average entry price - long stop-loss distance in ticks)
Exit: Short, tick-distance exit selected AND (low ≤ average entry price - short take-profit distance in ticks OR high ≥ average entry price + short stop-loss distance in ticks)
Exit: Long, opposite-signal exit selected AND Stochastic RSI D(source, RSI lookback, stochastic lookback, K smoothing, D smoothing) > short Stochastic RSI threshold AND MFI(source, lookback) > short MFI threshold AND close > EMA(source, lookback)
Exit: Short, opposite-signal exit selected AND Stochastic RSI D(source, RSI lookback, stochastic lookback, K smoothing, D smoothing) < long Stochastic RSI threshold AND MFI(source, lookback) < long MFI threshold AND close < EMA(source, lookback)