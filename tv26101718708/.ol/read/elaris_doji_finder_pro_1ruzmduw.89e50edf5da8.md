Calculation: Candle range = high - low
Calculation: Body percentage = 100 * abs(close - open) / candle range; use 100 when range is zero
Calculation: Upper wick percentage = 100 * (high - max(open, close)) / candle range; use 0 when range is zero
Calculation: Lower wick percentage = 100 * (min(open, close) - low) / candle range; use 0 when range is zero
Calculation: Dragonfly Doji = body percentage <= maximum body percentage AND lower wick percentage >= long wick minimum AND upper wick percentage <= small wick maximum
Calculation: Gravestone Doji = body percentage <= maximum body percentage AND upper wick percentage >= long wick minimum AND lower wick percentage <= small wick maximum
Calculation: Long-legged Doji = body percentage <= maximum body percentage AND upper wick percentage >= long wick minimum AND lower wick percentage >= long wick minimum
Calculation: Neutral Doji = body percentage <= maximum body percentage AND NOT Dragonfly Doji AND NOT Gravestone Doji AND NOT Long-legged Doji
Calculation: Valid Doji = any enabled Doji type is present
Calculation: Near support = a confirmed swing low exists AND abs(low - latest confirmed swing low) <= ATR * maximum support/resistance distance
Calculation: Near resistance = a confirmed swing high exists AND abs(high - latest confirmed swing high) <= ATR * maximum support/resistance distance
Calculation: Bullish context = Dragonfly Doji OR near support OR close > open
Calculation: Bearish context = Gravestone Doji OR near resistance OR close < open
Long: Valid Doji AND candle range >= ATR * minimum range multiplier AND (volume filter disabled OR volume >= volume moving average * volume multiplier) AND (support/resistance filter disabled OR near support OR near resistance) AND (trend filter disabled OR (bullish context AND close < EMA) OR (bearish context AND close > EMA) OR Long-legged Doji) AND Bullish context AND NOT Bearish context
Short: Valid Doji AND candle range >= ATR * minimum range multiplier AND (volume filter disabled OR volume >= volume moving average * volume multiplier) AND (support/resistance filter disabled OR near support OR near resistance) AND (trend filter disabled OR (bullish context AND close < EMA) OR (bearish context AND close > EMA) OR Long-legged Doji) AND Bearish context AND NOT Bullish context