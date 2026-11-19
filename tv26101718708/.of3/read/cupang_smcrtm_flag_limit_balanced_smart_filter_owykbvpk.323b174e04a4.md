Calculation: Candle range = max(high - low, minimum tick size)
Calculation: Body ratio = abs(close - open) / Candle range
Calculation: Bullish quality score = base score + strong-body bonus when Body ratio >= strong-body threshold + range-expansion bonus when Candle range >= Candle range[1] * range-expansion multiplier + trend bonus when trend filter is disabled or close > EMA(close, trend lookback)
Calculation: Bearish quality score = base score + strong-body bonus when Body ratio >= strong-body threshold + range-expansion bonus when Candle range >= Candle range[1] * range-expansion multiplier + trend bonus when trend filter is disabled or close < EMA(close, trend lookback)
Calculation: Long entry price = high of the base candle
Calculation: Short entry price = low of the base candle
Calculation: Long stop = low of the base candle - ATR(ATR lookback, setup bar) * stop-buffer multiplier
Calculation: Long target = Long entry price + max(Long entry price - Long stop, ATR(ATR lookback, setup bar) * minimum-risk ATR multiplier) * risk/reward ratio
Calculation: Short stop = high of the base candle + ATR(ATR lookback, setup bar) * stop-buffer multiplier
Calculation: Short target = Short entry price - max(Short stop - Short entry price, ATR(ATR lookback, setup bar) * minimum-risk ATR multiplier) * risk/reward ratio
Long: Candle range[1] <= ATR(ATR lookback) * base-range ATR multiplier AND close > open AND close > high[1] AND Body ratio >= minimum body ratio AND Bullish quality score >= minimum quality score
Short: Candle range[1] <= ATR(ATR lookback) * base-range ATR multiplier AND close < open AND close < low[1] AND Body ratio >= minimum body ratio AND Bearish quality score >= minimum quality score
Long: A qualifying bullish setup is active AND low <= its Long entry price
Short: A qualifying bearish setup is active AND high >= its Short entry price
Exit: Long, after the post-setup exit delay, close < Long stop OR high >= Long target
Exit: Short, after the post-setup exit delay, close > Short stop OR low <= Short target