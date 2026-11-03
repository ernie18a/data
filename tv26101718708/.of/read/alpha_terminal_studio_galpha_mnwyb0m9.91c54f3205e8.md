Calculation: Fibonacci pivot levels = Using the preceding bar of a configurable timeframe, calculate pivot = (high + low + close) / 3 and range = high - low. The levels are the pivot and pivot plus or minus each of three ordered range multipliers. The configurable timeframe may be the chart timeframe, higher, or lower; for a higher timeframe, lookahead-off historical merging exposes the preceding bar's values on the final chart bar of the current higher-timeframe bar and carries the prior result until then; for a lower timeframe, use the last intrabar.
Calculation: Kijun-sen = (highest high + lowest low) / 2 over a lookback.
Long: close > open AND high - close > absolute(close - open) * wick multiplier AND absolute(close - any Fibonacci pivot level) <= close * proximity threshold
Short: close < open AND open - low > absolute(close - open) * wick multiplier AND absolute(close - any Fibonacci pivot level) <= close * proximity threshold
Long: chart close > Kijun-sen calculated on a higher timeframe's last completed bar
Short: chart close <= Kijun-sen calculated on a higher timeframe's last completed bar
Long: ATR > simple moving average of ATR AND close > open
Short: ATR > simple moving average of ATR AND close <= open
Long: close > Kijun-sen on any selected timeframe, which may be higher or lower than the chart timeframe; use the last completed bar for a higher timeframe and the last intrabar for a lower timeframe
Short: close <= Kijun-sen on any selected timeframe, which may be higher or lower than the chart timeframe; use the last completed bar for a higher timeframe and the last intrabar for a lower timeframe