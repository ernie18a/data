Calculation: Delta = volume if close > open, −volume if close < open, doji volume fraction parameter × volume if close = open and close ≥ HL2, otherwise −(doji volume fraction parameter × volume); optionally divided by SMA(volume, normalization lookback), using a fallback parameter when that SMA is unavailable
Long: Delta crosses above zero
Short: Delta crosses below zero
Long: Delta crosses above SMA(Delta, signal lookback)
Short: Delta crosses below SMA(Delta, signal lookback)