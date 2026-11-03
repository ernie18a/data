Calculation: Body size = absolute value of open minus close
Calculation: Candle range = high minus low
Calculation: Lower wick = min(open, close) minus low
Calculation: Upper wick = high minus max(open, close)
Long: candle range > 0 AND body size > 0 AND body size <= body-threshold × candle range AND lower wick >= dominant-wick-multiplier × body size AND upper wick <= opposite-wick-limit × body size AND (volume filter disabled OR volume >= simple moving average of volume over the configured lookback × volume multiplier) AND previous bar low >= current low
Short: candle range > 0 AND body size > 0 AND body size <= body-threshold × candle range AND upper wick >= dominant-wick-multiplier × body size AND lower wick <= opposite-wick-limit × body size AND (volume filter disabled OR volume >= simple moving average of volume over the configured lookback × volume multiplier) AND previous bar high <= current high