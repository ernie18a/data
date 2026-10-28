Calculation: Positive Vortex = sum(abs(high − previous bar’s low), lookback) / sum(ATR(1), lookback)
Calculation: Negative Vortex = sum(abs(low − previous bar’s high), lookback) / sum(ATR(1), lookback)
Calculation: Smoothing line = selected moving average of the simple moving average of close
Long: Positive Vortex crosses above Negative Vortex AND close > Smoothing line
Short: Positive Vortex crosses below Negative Vortex AND close < Smoothing line