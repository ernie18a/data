Calculation: Range high = most recent confirmed pivot high, requiring the same lookback on the left and right
Calculation: Range low = most recent confirmed pivot low, requiring the same lookback on the left and right
Calculation: Body size = absolute difference between close and open
Calculation: Upper wick = high minus the greater of open and close
Calculation: Lower wick = the lesser of open and close minus low
Calculation: Bullish EMA trend = shorter-term EMA crosses above longer-term EMA and remains active until it crosses below
Calculation: Bearish EMA trend = shorter-term EMA crosses below longer-term EMA and remains active until it crosses above
Calculation: EMAs use the selected timeframe, which may be higher or lower than the chart timeframe; use the latest available bar (last completed historically, forming in real time)
Calculation: Long stop = signal bar low minus ATR times the stop multiplier; long target = signal bar close plus ATR times the target multiplier times the reward-to-risk ratio
Calculation: Short stop = signal bar high plus ATR times the stop multiplier; short target = signal bar close minus ATR times the target multiplier times the reward-to-risk ratio
Long: low < range low AND close > open AND lower wick ≥ body size × wick-to-body ratio AND bullish EMA trend AND close > longer-term EMA
Short: high > range high AND close < open AND upper wick ≥ body size × wick-to-body ratio AND bearish EMA trend AND close < longer-term EMA
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target