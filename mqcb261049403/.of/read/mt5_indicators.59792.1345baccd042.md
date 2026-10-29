Calculation: Donchian lower boundary = lowest low over the channel lookback.
Calculation: Donchian upper boundary = highest high over the channel lookback.
Calculation: Tick volume average = average tick volume over the volume lookback, including the current bar.
Long: Donchian lower boundary falls from the prior bar and equals its value depth + 1 bars later AND RSI < 50 AND tick volume >= tick volume average × volume multiplier AND close < EMA(close).
Short: Donchian upper boundary rises from the prior bar and equals its value depth + 1 bars later AND RSI > 50 AND tick volume >= tick volume average × volume multiplier AND close > EMA(close).