Calculation: Equilibrium = (last confirmed PivotHigh(high, swing lookback, swing lookback) + last confirmed PivotLow(low, swing lookback, swing lookback)) / 2
Long: close < Equilibrium
Short: close > Equilibrium
Long: low[1] > high[3] AND low[1] - high[3] >= ATR(ATR lookback) * FVG size multiplier
Short: low[3] > high[1] AND low[3] - high[1] >= ATR(ATR lookback) * FVG size multiplier
Long: close > open AND abs(close - open) >= ATR(ATR lookback) * displacement body multiplier AND (high - close) / (high - low) <= maximum wick-to-range ratio AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier)
Short: close < open AND abs(close - open) >= ATR(ATR lookback) * displacement body multiplier AND (close - low) / (high - low) <= maximum wick-to-range ratio AND (volume filter disabled OR volume > SMA(volume, volume lookback) * volume multiplier)
Long: low < Lowest(low, inducement lookback)[1] AND close > Lowest(low, inducement lookback)[1] AND Lowest(low, inducement lookback)[1] - low >= ATR(ATR lookback) * inducement wick multiplier
Short: high > Highest(high, inducement lookback)[1] AND close < Highest(high, inducement lookback)[1] AND high - Highest(high, inducement lookback)[1] >= ATR(ATR lookback) * inducement wick multiplier
Long: a bullish inducement occurs, then low < Lowest(low, structural sweep lookback)[1], then either displacement condition above occurs, all within the sequence timeout; close < Equilibrium
Short: a bearish inducement occurs, then high > Highest(high, structural sweep lookback)[1], then either displacement condition above occurs, all within the sequence timeout; close > Equilibrium
Long: after a bullish ISD sequence completes, the bar range intersects the bullish FVG formed by its displacement
Short: after a bearish ISD sequence completes, the bar range intersects the bearish FVG formed by its displacement