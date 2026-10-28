Calculation: Donchian upper band = highest high over the breakout lookback, using prior completed bars and excluding the current bar
Calculation: Donchian lower band = lowest low over the breakout lookback, using prior completed bars and excluding the current bar
Long: close > EMA(close, trend lookback) AND close > Donchian upper band AND volume > SMA(volume, volume lookback) × volume multiplier
Short: close < EMA(close, trend lookback) AND close < Donchian lower band AND volume > SMA(volume, volume lookback) × volume multiplier