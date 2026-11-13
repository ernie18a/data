Calculation: EMA_fast = EMA of close with a shorter length than EMA_slow
Calculation: EMA_slow = EMA of close with a longer length than EMA_fast
Calculation: ATR = Wilder average true range on the chart timeframe, current bar
Long: close > EMA_fast AND previous close <= previous EMA_fast AND EMA_fast > EMA_slow
Long: close > EMA_fast AND EMA_fast > previous EMA_fast
Long: low > high of 2 bars ago
Short: close < EMA_fast AND previous close >= previous EMA_fast AND EMA_fast < EMA_slow
Short: close < EMA_fast AND EMA_fast < previous EMA_fast
Short: high < low of 2 bars ago
Exit: long, close < EMA_slow OR low <= entry price - multiplier * ATR OR the Short entry condition (first Short line) is true
Exit: short, close > EMA_slow OR high >= entry price + multiplier * ATR OR the Long entry condition (first Long line) is true