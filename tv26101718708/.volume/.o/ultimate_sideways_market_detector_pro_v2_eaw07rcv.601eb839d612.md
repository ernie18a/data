Calculation: Range high = highest high over the range lookback, including the current bar
Calculation: Range low = lowest low over the range lookback, including the current bar
Calculation: Last support = low of the latest confirmed pivot low, lower than the lows over the pivot lookback bars on both sides
Calculation: Last resistance = high of the latest confirmed pivot high, higher than the highs over the pivot lookback bars on both sides
Long: (low < Last support AND close > Last support) OR (close > Range high AND close > previous bar high AND close - Range high >= ATR × configured fake-breakout multiplier)
Short: (high > Last resistance AND close < Last resistance) OR (close < Range low AND close < previous bar low AND Range low - close >= ATR × configured fake-breakout multiplier)