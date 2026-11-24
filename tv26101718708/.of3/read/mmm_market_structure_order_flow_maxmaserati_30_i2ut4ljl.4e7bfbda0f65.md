Calculation: Bullish BC = close > high[1] OR open > high[1]
Calculation: Bearish BC = close < low[1] OR open < low[1]
Calculation: Bullish BC plus = Bullish BC AND close > (high + low) / 2
Calculation: Bearish BC plus = Bearish BC AND close < (high + low) / 2
Calculation: Synthetic delta = 0 when volume <= 0; when high > low and close > open, volume * (2 * min(0.85, 0.50 + abs(close - open) / (high - low) * 0.25 + 0.10 * (lower wick > upper wick) + 0.05 * ((close - low) / (high - low) > 0.7)) - 1); when high > low and close < open, -volume * (2 * min(0.85, 0.50 + abs(close - open) / (high - low) * 0.25 + 0.10 * (upper wick > lower wick) + 0.05 * ((close - low) / (high - low) < 0.3)) - 1); when high > low and close = open, -0.40 * volume if upper wick > 1.5 * lower wick, 0.40 * volume if lower wick > 1.5 * upper wick, otherwise volume * (0.04 if (close - low) / (high - low) > 0.5, else -0.04); when high <= low, 0.20 * volume if close > open, -0.20 * volume if close < open, otherwise 0
Calculation: Current delta = footprint delta when footprint use is enabled and footprint data is available, otherwise Synthetic delta
Calculation: Mean BC range = mean of high - low for the two most recent bars where Bullish BC or Bearish BC was true
Calculation: Mean absolute BC delta = mean of abs(Current delta) for the two most recent bars where Bullish BC or Bearish BC was true
Long: Bullish BC AND (NOT Bearish BC OR close >= open)
Short: Bearish BC AND (NOT Bullish BC OR close < open)
Long: Bullish BC AND Mean BC range > 0 AND (plus-only mode is disabled OR Bullish BC plus) AND high - low >= Mean BC range * range expansion factor AND ((delta confirmation is enabled AND Current delta > 0 AND (Mean absolute BC delta = 0 OR abs(Current delta) >= Mean absolute BC delta * delta expansion factor)) OR (delta confirmation is disabled AND Current delta >= 0)) AND (wickless mode is disabled OR (close >= open AND min(open, close) - low <= minimum tick AND high - low > minimum tick))
Short: Bearish BC AND Mean BC range > 0 AND (plus-only mode is disabled OR Bearish BC plus) AND high - low >= Mean BC range * range expansion factor AND ((delta confirmation is enabled AND Current delta < 0 AND (Mean absolute BC delta = 0 OR abs(Current delta) >= Mean absolute BC delta * delta expansion factor)) OR (delta confirmation is disabled AND Current delta <= 0)) AND (wickless mode is disabled OR (close <= open AND high - max(open, close) <= minimum tick AND high - low > minimum tick))
Long: open > close[1] AND high[1] > low AND close > close[1] AND open > open[1] AND high[1] < min(close, open)
Short: open < close[1] AND low[1] < high AND close < close[1] AND open < open[1] AND low[1] > max(close, open)
Long: low > high[1]
Short: high < low[1]
Long: low > high[2] AND close[1] > high[2] AND NOT (low > high[1] OR low[1] > high[2])
Short: high < low[2] AND close[1] < low[2] AND NOT (high < low[1] OR high[1] < low[2])
Long: close > an active validated swing high AND a validated swing low exists AND the most recent structural break is not bullish
Short: close < an active validated swing low AND a validated swing high exists AND the most recent structural break is not bearish