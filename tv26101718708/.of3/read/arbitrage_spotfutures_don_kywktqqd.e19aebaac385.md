Calculation: spread = (futures close - spot close) / spot close
Calculation: long entry threshold = adaptive thresholds enabled ? max(minimum spread threshold, SMA(spread, spread lookback) + standard deviation(spread, spread lookback) * deviation multiplier) : minimum spread threshold
Calculation: short entry threshold = adaptive thresholds enabled ? min(-minimum spread threshold, SMA(spread, spread lookback) - standard deviation(spread, spread lookback) * deviation multiplier) : -minimum spread threshold
Long: spot close > 0 AND futures close > 0 AND spread >= long entry threshold AND (no open position OR time since most recent entry > maximum holding duration)
Short: spot close > 0 AND futures close > 0 AND spread <= short entry threshold AND (no open position OR time since most recent entry > maximum holding duration)
Exit: Long, spread < long entry threshold * exit fraction OR time since entry >= maximum holding duration
Exit: Short, spread > short entry threshold * exit fraction OR time since entry >= maximum holding duration
Calculation: Spot-futures spread = (futures close − spot close) ÷ spot close
Calculation: Long entry threshold = if adaptive thresholds are enabled, max(minimum spread percentage ÷ 100, SMA(spot-futures spread, lookback length) + standard-deviation multiplier × standard deviation(spot-futures spread, lookback length)); otherwise, minimum spread percentage ÷ 100
Calculation: Short entry threshold = if adaptive thresholds are enabled, min(−minimum spread percentage ÷ 100, SMA(spot-futures spread, lookback length) − standard-deviation multiplier × standard deviation(spot-futures spread, lookback length)); otherwise, −minimum spread percentage ÷ 100
Long: spot close > 0 AND futures close > 0 AND spot-futures spread ≥ long entry threshold AND (no position is open OR elapsed holding time > maximum holding duration)
Short: spot close > 0 AND futures close > 0 AND spot-futures spread ≤ short entry threshold AND (no position is open OR elapsed holding time > maximum holding duration)
Exit: long, spot-futures spread < long entry threshold × exit fraction OR elapsed holding time ≥ maximum holding duration
Exit: short, spot-futures spread > short entry threshold × exit fraction OR elapsed holding time ≥ maximum holding duration