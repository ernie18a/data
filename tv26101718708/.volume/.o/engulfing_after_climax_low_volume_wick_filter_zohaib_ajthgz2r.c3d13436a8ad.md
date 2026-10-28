Calculation: Candle body = absolute value of close − open
Calculation: Previous candle body = absolute value of previous bar’s close − open
Calculation: Candle range = high − low
Calculation: Body percentage = candle body / candle range (0 if candle range is 0)
Calculation: Average volume = simple moving average of volume over a configured lookback
Calculation: Average candle range = simple moving average of high − low over the same lookback as average volume
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Calculation: Selling climax = close < open AND volume > average volume × configured climax-volume multiplier AND candle range > average candle range × configured wide-spread multiplier
Calculation: Buying climax = close > open AND volume > average volume × configured climax-volume multiplier AND candle range > average candle range × configured wide-spread multiplier
Long: At least one bar within the configured climax lookback, including the current bar, is a selling climax AND close > open AND previous close < previous open AND close > previous open AND open ≤ previous close AND candle body ≥ previous candle body × configured body multiplier AND volume < average volume × configured low-volume multiplier AND body percentage ≥ configured minimum AND upper wick ≤ lower wick
Short: At least one bar within the configured climax lookback, including the current bar, is a buying climax AND close < open AND previous close > previous open AND open ≥ previous close AND close < previous open AND candle body ≥ previous candle body × configured body multiplier AND volume < average volume × configured low-volume multiplier AND body percentage ≥ configured minimum AND lower wick ≤ upper wick