Calculation: Basis = a selectable SMA, EMA, or WMA of close. The Bollinger upper and lower bands are the basis plus and minus a configurable multiplier times the standard deviation of close over the basis lookback.
Calculation: Squeeze = Bollinger band width is less than or equal to Keltner channel width. Keltner width is twice a configurable multiplier times the true range smoothed with the same moving-average type as the basis and a separately configurable lookback. If Bollinger width is zero, treat squeeze as active.
Calculation: Pressure = clamp 50 times the WMA of weighted pressure to [-100, 100]. Weighted pressure is ((close - low) - (high - close)) / (high - low) times volume divided by its moving average. Use zero directional pressure when high equals low, and a volume ratio of 1 when the volume moving average is not positive. The volume moving average uses the same type as the basis, with its own lookback; pressure smoothing has a separate lookback.
Calculation: Release age = bars since the latest transition from squeeze active to squeeze inactive, including the release bar as age zero. Each new release resets the first-signal state. The first signal is the first qualifying long or short entry within the configurable expansion window, inclusive of its endpoints; after that signal, retain its direction until the next release.
Long: Release age is within the expansion window AND no first signal has occurred since that release AND long side is enabled AND close > open AND abs(close - open) / (high - low) >= minimum body ratio AND (close - low) / (high - low) >= 0.60 AND high > previous high AND pressure > minimum pressure AND (trend filter disabled OR close > trend EMA) AND ((band-break filter disabled AND close > basis) OR (band-break filter enabled AND (close > Bollinger upper band OR high > Bollinger upper band))).
Short: Release age is within the expansion window AND no first signal has occurred since that release AND short side is enabled AND close < open AND abs(close - open) / (high - low) >= minimum body ratio AND (close - low) / (high - low) <= 0.40 AND low < previous low AND pressure < negative minimum pressure AND (trend filter disabled OR close < trend EMA) AND ((band-break filter disabled AND close < basis) OR (band-break filter enabled AND (close < Bollinger lower band OR low < Bollinger lower band))).
Long: First signal since the latest release was long AND current bar is after that signal AND release age > 0 AND release age <= expansion window + 2 bars AND close > basis AND pressure > strong-pressure threshold AND high > previous high.
Short: First signal since the latest release was short AND current bar is after that signal AND release age > 0 AND release age <= expansion window + 2 bars AND close < basis AND pressure < negative strong-pressure threshold AND low < previous low.
Long: Pressure >= 0.
Short: Pressure < 0.
Long: Close > basis.
Short: Close < basis.
Long: Pressure > minimum pressure.
Short: Pressure < negative minimum pressure.
Long: Pressure > strong-pressure threshold.
Short: Pressure < negative strong-pressure threshold.
Long: Close > open.
Short: Close < open.
Long: High > previous high.
Short: Low < previous low.
Long: Close > trend EMA.
Short: Close < trend EMA.