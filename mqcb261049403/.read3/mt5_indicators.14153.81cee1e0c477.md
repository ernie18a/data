Calculation: Main line = primary smoothing method(if volume selected by volume type is nonzero, (MedianPrice - MedianPrice[1]) * MedianPrice / (2 * volume selected by volume type), otherwise 0), primary lookback, primary phase
Calculation: Signal line = signal smoothing method(Main line, signal lookback, signal phase)
Long: Main line on chart bars > 0
Short: Main line on chart bars < 0
Long: Main line on chart bars > Signal line on chart bars
Short: Main line on chart bars < Signal line on chart bars
Long: Main line calculated on T1 bars, sampled on chart bars from the T1 bar still forming > 0
Short: Main line calculated on T1 bars, sampled on chart bars from the T1 bar still forming < 0
Long: Main line calculated on T1 bars, sampled on chart bars from the T1 bar still forming > Signal line calculated on T1 bars, sampled on chart bars from the T1 bar still forming
Short: Main line calculated on T1 bars, sampled on chart bars from the T1 bar still forming < Signal line calculated on T1 bars, sampled on chart bars from the T1 bar still forming