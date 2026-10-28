Calculation: Resistance = most recent confirmed swing high, whose high exceeds the highs of the configured number of bars before and after it
Calculation: Support = most recent confirmed swing low, whose low is below the lows of the configured number of bars before and after it
Long: close crosses above Resistance AND volume > its moving average × surge multiplier AND (trend filter disabled OR close > EMA) AND datetime is within the configured backtest date range
Short: close crosses below Support AND volume > its moving average × surge multiplier AND (trend filter disabled OR close < EMA) AND datetime is within the configured backtest date range
Calculation: Long stop = Support at entry − ATR at entry × structural buffer when structural stops are enabled and Support exists; otherwise entry close − ATR at entry × stop multiple
Calculation: Long target = entry close + ATR at entry × target multiple
Calculation: Short stop = Resistance at entry + ATR at entry × structural buffer when structural stops are enabled and Resistance exists; otherwise entry close + ATR at entry × stop multiple
Calculation: Short target = entry close − ATR at entry × target multiple
Exit: long, low ≤ Long stop OR high ≥ Long target
Exit: short, high ≥ Short stop OR low ≤ Short target