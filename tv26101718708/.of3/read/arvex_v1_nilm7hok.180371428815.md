Calculation: Doji = abs(close - open) <= (high - low) * Doji body-to-range parameter
Calculation: Hammer or Hanging Man = abs(close - open) <= (high - low) * Hammer body-to-range parameter AND ((close - low) >= abs(close - open) * wick-to-body parameter OR (high - close) >= abs(close - open) * wick-to-body parameter)
Long: close[1] > open[1] AND close < open AND volume > volume[1] AND low >= low[1] AND NOT Doji AND NOT Hammer or Hanging Man
Short: close[1] < open[1] AND close > open AND volume > volume[1] AND high <= high[1] AND NOT Doji AND NOT Hammer or Hanging Man