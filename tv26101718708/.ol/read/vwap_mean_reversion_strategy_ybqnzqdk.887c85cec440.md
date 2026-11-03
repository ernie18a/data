Calculation: Doji = candle body ≤ candle range × doji body fraction, with candle range > 0
Calculation: Hammer = body ≤ candle range × small-body fraction AND lower wick ≥ body × lower-wick multiple AND upper wick ≤ body, with candle range > 0
Calculation: Shooting star = body ≤ candle range × small-body fraction AND upper wick ≥ body × upper-wick multiple AND lower wick ≤ body, with candle range > 0
Calculation: Bullish engulfing = current candle is bullish AND previous candle is bearish AND current open ≤ previous close AND current close ≥ previous open
Calculation: Bearish engulfing = current candle is bearish AND previous candle is bullish AND current open ≥ previous close AND current close ≤ previous open
Calculation: VWAP = volume-weighted average of (high + low + close) / 3 since the start of the current day; standard deviation = volume-weighted standard deviation of that price over the same period; upper band = VWAP + standard deviation; lower band = VWAP − standard deviation
Long: (hammer OR doji) AND low ≤ lookback-period lowest low
Long: previous bar is a bullish setup bar AND candle range > 0 AND candle size ≤ ATR × maximum candle-size multiple AND (close − low) / (high − low) ≥ 1 − close-position fraction AND (bullish engulfing OR current low > previous low AND current close > previous high) AND previous close < current lower band AND current confirmation was false on the previous bar
Short: (shooting star OR doji) AND high ≥ lookback-period highest high
Short: previous bar is a bearish setup bar AND candle range > 0 AND candle size ≤ ATR × maximum candle-size multiple AND (close − low) / (high − low) ≤ close-position fraction AND (bearish engulfing OR current high < previous high AND current close < previous low) AND previous close > current upper band AND current confirmation was false on the previous bar
Exit: Long, low ≤ stored long stop OR high ≥ stored long target OR short-entry signal
Exit: Short, high ≥ stored short stop OR low ≤ stored short target OR long-entry signal