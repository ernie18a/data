Calculation: spread = (futures close - spot close) / spot close
Calculation: long entry threshold = adaptive thresholds enabled ? max(minimum spread threshold, SMA(spread, spread lookback) + standard deviation(spread, spread lookback) * deviation multiplier) : minimum spread threshold
Calculation: short entry threshold = adaptive thresholds enabled ? min(-minimum spread threshold, SMA(spread, spread lookback) - standard deviation(spread, spread lookback) * deviation multiplier) : -minimum spread threshold
Long: spot close > 0 AND futures close > 0 AND spread >= long entry threshold AND (no open position OR time since most recent entry > maximum holding duration)
Short: spot close > 0 AND futures close > 0 AND spread <= short entry threshold AND (no open position OR time since most recent entry > maximum holding duration)
Exit: Long, spread < long entry threshold * exit fraction OR time since entry >= maximum holding duration
Exit: Short, spread > short entry threshold * exit fraction OR time since entry >= maximum holding duration