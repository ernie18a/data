Calculation: Moving averages = simple moving averages of close using short-, medium-, and long-term lookbacks, respectively
Calculation: Long-term average uptrend = the long-term moving average is strictly higher on each of the preceding uptrend-lookback bars than on the bar before it
Calculation: 52-bar-range low/high = rolling lowest low / highest high over a long-term lookback
Calculation: Relative-strength estimate = clamp((close / close from the RS lookback ago − 1) × 100 × 1.2 + 50, 0, 100)
Calculation: Criteria score = count of the eight conditions: close above all three moving averages; short-term average above medium-term above long-term average; long-term average uptrend; close at least the configured percentage above the range low; close at least the configured percentage below the range high; relative-strength estimate at least its configured minimum; volume at least its configured multiple of the 50-bar average volume; close above close at both the 1-year and 3-month lookbacks
Long: Criteria score = 8
Exit: Long, Criteria score ≤ 3 OR prior-bar criteria score − current criteria score ≥ 2