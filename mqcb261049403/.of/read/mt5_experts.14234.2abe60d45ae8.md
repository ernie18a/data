Calculation: Channel upper and lower = the same configurable moving average applied separately to high and low, respectively; use the same smoothing parameters for both. For the trading system, calculate on a configurable indicator timeframe, which may be higher or lower than the chart timeframe, using either the last completed bar or the forming bar according to the signal-bar setting.
Calculation: Bullish state = close > channel upper AND close >= channel lower.
Calculation: Bearish state = close < channel lower.
Long: Bullish state = true.
Long: Bullish state = true AND previous indicator bar's bullish state = false.
Short: Bearish state = true.
Short: Bearish state = true AND previous indicator bar's bearish state = false.
Exit: long, bearish state = true OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, bullish state = true OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.