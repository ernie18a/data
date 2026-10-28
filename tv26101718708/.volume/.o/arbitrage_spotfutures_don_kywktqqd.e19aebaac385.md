Calculation: spread = (futures close − spot close) / spot close
Calculation: long entry threshold = max(minimum spread threshold, mean spread + 1.5 × spread standard deviation) when adaptive thresholds are enabled; otherwise minimum spread threshold
Calculation: short entry threshold = min(−minimum spread threshold, mean spread − 1.5 × spread standard deviation) when adaptive thresholds are enabled; otherwise −minimum spread threshold
Long: spread ≥ long entry threshold AND spot close > 0 AND futures close > 0 AND (no open position OR elapsed time since entry > maximum holding duration)
Short: spread ≤ short entry threshold AND spot close > 0 AND futures close > 0 AND (no open position OR elapsed time since entry > maximum holding duration)
Exit: Long, spread < 0.6 × long entry threshold OR elapsed time since entry ≥ maximum holding duration
Exit: Short, spread > 0.6 × short entry threshold OR elapsed time since entry ≥ maximum holding duration