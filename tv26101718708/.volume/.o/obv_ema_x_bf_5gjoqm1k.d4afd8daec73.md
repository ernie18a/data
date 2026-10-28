Calculation: ATR-adjusted OBV = cumulative sum of volume² / ATR when close rises, −volume² / ATR when close falls, and 0 when close is unchanged
Long: short-lookback EMA of ATR-adjusted OBV crosses above long-lookback EMA of ATR-adjusted OBV
Short: short-lookback EMA of ATR-adjusted OBV crosses below long-lookback EMA of ATR-adjusted OBV
Exit: long, low <= entry price × (1 − stop-loss fraction)
Exit: short, high >= entry price × (1 + stop-loss fraction)