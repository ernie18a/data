Calculation: Signal series = chosen source, high, low, and close from T1, sampled on chart bars from the last completed T1 bar when repainting is disabled and from the current forming T1 bar when enabled.
Calculation: Trend EMA = EMA(Signal source sampled from the current T2 bar, EMA lookback), calculated on chart bars taking lookahead-on T2 values; T2 is the configured higher-or-equal timeframe for the EMA.
Calculation: PSAR = standard PSAR(start, increment, maximum) on chart bars, using the previous completed chart bar when repainting is disabled and the current forming chart bar when enabled; or adaptive PSAR(starting factor, minimum step, maximum step, maximum factor, adaptation mode, smoothing period, filter) on chart bars using the Signal series.
Calculation: TTM Squeeze momentum = TTM Squeeze momentum(Signal source, high, low, and close, one shared lookback for highest, lowest, SMA, and linear regression), calculated on chart bars.
Calculation: Long stop = at long entry, lowest(Signal low, stop lookback) × stop multiplier if the lowest value is positive; otherwise Signal low × backup multiplier. The lookback is in chart bars.
Calculation: Short stop = at short entry, highest(Signal high, stop lookback) × (1 + (1 − stop multiplier)) if the highest value is positive; otherwise Signal high × (1 + (1 − backup multiplier)). The lookback is in chart bars.
Calculation: Long target = at long entry, Signal close × (1 + (1 − Long stop / Signal close) × risk-reward ratio).
Calculation: Short target = at short entry, Signal close × (1 − (1 − Signal close / Short stop) × risk-reward ratio).
Long: flat AND Signal source > Trend EMA AND Signal source crosses above PSAR AND TTM Squeeze momentum crosses above 0
Short: flat AND Signal source < Trend EMA AND Signal source crosses below PSAR AND TTM Squeeze momentum crosses below 0
Exit: Long, Signal close crosses below Long stop OR Signal close crosses above Long target
Exit: Short, Signal close crosses above Short stop OR Signal close crosses below Short target