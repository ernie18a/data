Calculation: Short EMA = EMA(close, shorter lookback)
Calculation: Long EMA = EMA(close, longer lookback)
Calculation: WaveTrend oscillator = WaveTrend(hlc3, shorter channel lookback, longer average lookback)
Calculation: WaveTrend signal line = SMA(WaveTrend oscillator, signal lookback)
Calculation: Signal-bar midpoint = SMA(close, signal-bar lookback)
Long: Short EMA crosses above Long EMA
Short: Short EMA crosses below Long EMA
Long: WaveTrend oscillator crosses above WaveTrend signal line
Short: WaveTrend oscillator crosses below WaveTrend signal line
Long: close > Signal-bar midpoint
Short: close < Signal-bar midpoint