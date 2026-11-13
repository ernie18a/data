Calculation: VWMA = volume-weighted moving average of close over lookback L (chart timeframe, completed bars)
Calculation: ATR = average true range over the same lookback L as the VWMA (chart timeframe)
Calculation: Basis = EMA of VWMA, with EMA period S much shorter than L
Calculation: Upper = EMA with period S of (VWMA + M * ATR), where M is a positive multiplier
Calculation: Lower = EMA with period S of (VWMA - M * ATR), same S and M as Upper
Long: close > Upper AND previous close <= previous Upper
Long: close > Basis
Short: close < Lower AND previous close >= previous Lower
Short: close <= Basis