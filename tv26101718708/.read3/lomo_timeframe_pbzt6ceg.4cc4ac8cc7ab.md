Calculation: BandWidth(lookback, ATR-window multiplier, band multiplier) = Highest(ATR(lookback), lookback × ATR-window multiplier) × band multiplier
Calculation: Regime(lookback, ATR-window multiplier, band multiplier, T) runs on T bars, starts at 0, becomes 1 when close crosses above ZLEMA(close, lookback) + BandWidth(...), becomes -1 when close crosses below ZLEMA(close, lookback) - BandWidth(...), and otherwise holds its prior value; chart bars take the current T-bar value (still forming in real time, last completed historically)
Long: Regime(lookback, ATR-window multiplier, band multiplier, T1) = 1
Short: Regime(lookback, ATR-window multiplier, band multiplier, T1) ≠ 1
Long: Regime(lookback, ATR-window multiplier, band multiplier, T2) = 1
Short: Regime(lookback, ATR-window multiplier, band multiplier, T2) ≠ 1
Long: Regime(lookback, ATR-window multiplier, band multiplier, T3) = 1
Short: Regime(lookback, ATR-window multiplier, band multiplier, T3) ≠ 1
Long: Regime(lookback, ATR-window multiplier, band multiplier, T4) = 1
Short: Regime(lookback, ATR-window multiplier, band multiplier, T4) ≠ 1
Long: Regime(lookback, ATR-window multiplier, band multiplier, T5) = 1
Short: Regime(lookback, ATR-window multiplier, band multiplier, T5) ≠ 1