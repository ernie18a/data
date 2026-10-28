Calculation: Previous-period high = highest high over the lookback bars completed before the current bar
Calculation: Previous-period low = lowest low over the lookback bars completed before the current bar
Calculation: Average volume = simple moving average of volume
Long: low < previous-period low AND close > previous-period low AND min(open, close) - low > abs(close - open) * wick-strength multiplier AND volume > average volume AND close > EMA of close
Short: high > previous-period high AND close < previous-period high AND high - max(open, close) > abs(close - open) * wick-strength multiplier AND volume > average volume AND close < EMA of close