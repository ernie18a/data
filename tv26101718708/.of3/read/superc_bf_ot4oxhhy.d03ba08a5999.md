Calculation: Movement filter = EMA(ROC(close, ROC lookback), ROC lookback / 2) > movement threshold / 2 OR EMA(ROC(close, ROC lookback), ROC lookback / 2) < -movement threshold / 2
Long: MFI(hlc3, volume, lookback) > MFI(hlc3, volume, lookback)[1] AND Movement filter AND SMA(opposite Supertrend band, longer lookback) > SMA(active Supertrend band, shorter lookback)
Short: MFI(hlc3, volume, lookback) < MFI(hlc3, volume, lookback)[1] AND Movement filter AND SMA(opposite Supertrend band, longer lookback) < SMA(active Supertrend band, shorter lookback)
Long: MFI(hlc3, volume, lookback) > MFI(hlc3, volume, lookback)[1] AND Movement filter AND close > Supertrend
Short: MFI(hlc3, volume, lookback) < MFI(hlc3, volume, lookback)[1] AND Movement filter AND close < Supertrend
Long: crossover(time of most recent bar satisfying the long condition, time of most recent bar satisfying the short condition)
Short: crossover(time of most recent bar satisfying the short condition, time of most recent bar satisfying the long condition)
Exit: long, low <= entry price × (1 − stop-loss percentage)
Exit: short, high >= entry price × (1 + stop-loss percentage)