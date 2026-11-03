Calculation: Hammer = lower wick >= body × wick-to-body ratio AND upper wick <= body AND high > low
Calculation: Bullish engulfing = close > open AND open <= previous close AND close >= previous open AND previous close < previous open
Calculation: Shooting star = upper wick >= body × wick-to-body ratio AND lower wick <= body AND high > low
Calculation: Bearish engulfing = close < open AND open >= previous close AND close <= previous open AND previous close > previous open
Calculation: Doji = body <= candle range × maximum doji body fraction
Long: volume > volume moving average × volume multiplier AND (Hammer OR bullish engulfing)
Long: close > 50-period simple moving average of close AND volume > volume moving average × volume multiplier AND close > open AND NOT (volume > volume moving average × volume multiplier AND (Shooting star OR bearish engulfing)) AND previous chart-timeframe bar is a Doji
Short: volume > volume moving average × volume multiplier AND (Shooting star OR bearish engulfing)
Short: close < 50-period simple moving average of close AND volume > volume moving average × volume multiplier AND close < open AND NOT (volume > volume moving average × volume multiplier AND (Hammer OR bullish engulfing)) AND previous chart-timeframe bar is a Doji