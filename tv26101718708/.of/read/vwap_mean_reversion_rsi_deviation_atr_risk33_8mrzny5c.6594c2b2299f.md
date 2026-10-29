Calculation: Standardized VWAP deviation = (close − VWAP − mean of (close − VWAP) over the lookback) ÷ standard deviation of (close − VWAP) over the same lookback; use 0 when the standard deviation is 0
Calculation: ATR risk distance = ATR × stop multiple
Calculation: Long stop = entry price − ATR risk distance
Calculation: Short stop = entry price + ATR risk distance
Calculation: Long target = max(VWAP, entry price + ATR risk distance × reward multiple) when VWAP target is enabled; otherwise entry price + ATR risk distance × reward multiple
Calculation: Short target = min(VWAP, entry price − ATR risk distance × reward multiple) when VWAP target is enabled; otherwise entry price − ATR risk distance × reward multiple
Long: Standardized VWAP deviation ≤ −deviation threshold AND RSI ≤ oversold threshold AND (HTF trend filter disabled OR chart close ≥ EMA of closes on a higher timeframe using the last completed higher-timeframe bar) AND (session filter disabled OR datetime is within the configured session)
Short: Standardized VWAP deviation ≥ deviation threshold AND RSI ≥ overbought threshold AND (HTF trend filter disabled OR chart close ≤ EMA of closes on a higher timeframe using the last completed higher-timeframe bar) AND (session filter disabled OR datetime is within the configured session)
Exit: long, low ≤ Long stop OR high ≥ Long target OR elapsed chart bars since entry ≥ time limit when time stop is enabled
Exit: short, high ≥ Short stop OR low ≤ Short target OR elapsed chart bars since entry ≥ time limit when time stop is enabled