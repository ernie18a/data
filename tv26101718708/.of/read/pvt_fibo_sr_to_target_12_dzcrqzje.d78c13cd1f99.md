Calculation: Previous-period pivot (PP) = (high + low + close) / 3 of the last completed bar on a higher timeframe
Calculation: Pivot range = previous-period high − previous-period low
Calculation: R2 = PP + 0.618 × pivot range
Calculation: S2 = PP − 0.618 × pivot range
Long: (close crosses above PP OR close > PP for X consecutive bars) AND the trigger occurred the configured delay ago AND the bar is confirmed AND (same-direction blocking is disabled OR the last signal was short) AND bars since the previous long signal ≥ the configured minimum wait
Short: (close crosses below PP OR close < PP for X consecutive bars) AND the trigger occurred the configured delay ago AND the bar is confirmed AND (same-direction blocking is disabled OR the last signal was long) AND bars since the previous short signal ≥ the configured minimum wait
Exit: long, high crosses above R2 OR a short signal occurs
Exit: short, low crosses below S2 OR a long signal occurs