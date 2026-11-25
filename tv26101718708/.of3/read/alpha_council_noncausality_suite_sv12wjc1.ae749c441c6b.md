Calculation: CVD = cumulative sum of volume when close > open, negative volume when close < open, and zero otherwise
Calculation: Volume z-score = (volume - SMA(volume, lookback)) / standard deviation(volume, lookback)
Calculation: WESO = clamp((close - band midpoint) / half envelope width, -1, 1) * (weight + (1 - weight) * clamp(inner band width / envelope width, 0, 1)); band midpoint = mean of the outer and inner band values
Calculation: Hilbert phase = atan2(8 * (NW(close, bandwidth) - NW(close, bandwidth)[2]), NW(close, bandwidth) - band midpoint)
Calculation: Regime phase = atan2(8 * (NW(close, bandwidth) - NW(close, bandwidth)[1]), NW(close, bandwidth) - band midpoint)
Calculation: Bullish regime score = bullish RSI, directional movement, CVD change, OBV change, HP slope, and sine-of-regime-phase conditions counted as votes
Calculation: Bearish regime score = bearish RSI, directional movement, CVD change, OBV change, HP slope, and sine-of-regime-phase conditions counted as votes
Calculation: Retail bearish state = CVD change < 0 AND CVD > SMA(CVD, CVD lookback) OR OBV change < 0 AND OBV > SMA(OBV, OBV lookback) OR RSI crosses below upper threshold OR Stoch RSI %K crosses below %D above its upper threshold OR MACD line crosses below signal line OR Aroon up crosses below Aroon down OR premium index crosses below zero OR open interest decreases OR stablecoin dominance increases while below its SMA
Calculation: Retail bullish state = CVD change > 0 AND CVD < SMA(CVD, CVD lookback) OR OBV change > 0 AND OBV < SMA(OBV, OBV lookback) OR RSI crosses above lower threshold OR Stoch RSI %K crosses above %D below its lower threshold OR MACD line crosses above signal line OR Aroon up crosses above Aroon down OR premium index crosses above zero OR open interest decreases OR stablecoin dominance decreases while above its SMA
Calculation: Institutional bearish consensus for CVD, OBV, MACD, or Aroon = at least the consensus fraction of valid anomaly-anchor comparisons have the indicator falling while its current value exceeds its anchor value; for RSI, its anchor-adjusted value crosses below its upper threshold; for stablecoin dominance, it rises while below its anchor value
Calculation: Institutional bullish consensus for CVD, OBV, MACD, or Aroon = at least the consensus fraction of valid anomaly-anchor comparisons have the indicator rising while its current value is below its anchor value; for RSI, its anchor-adjusted value crosses above its lower threshold; for stablecoin dominance, it falls while above its anchor value
Long: On bars of any configured timeframe T1, T2, T3, or T4, retail bullish state when execution mode is retail OR institutional bullish consensus when execution mode is institutional OR close < ALMA(close, lookback) - standard deviation(close, lookback) * multiplier OR MACD line crosses above zero
Short: On bars of any configured timeframe T1, T2, T3, or T4, retail bearish state when execution mode is retail OR institutional bearish consensus when execution mode is institutional OR close > ALMA(close, lookback) + standard deviation(close, lookback) * multiplier OR MACD line crosses below zero; chart bars use the latest available timeframe value, including the forming bar in real time
Long: Low < accumulation-session low AND close > accumulation-session low AND in manipulation session AND (low <= Whittaker lower outer band OR low <= NW(close, bandwidth) - NW-smoothed absolute deviation * envelope multiplier OR low <= polynomial regression of close - regression residual standard deviation * channel multiplier)
Short: High > accumulation-session high AND close < accumulation-session high AND in manipulation session AND (high >= Whittaker upper outer band OR high >= NW(close, bandwidth) + NW-smoothed absolute deviation * envelope multiplier OR high >= polynomial regression of close + regression residual standard deviation * channel multiplier)
Long: Prior WESO <= oversold threshold AND (current WESO > prior WESO OR current lower outer band >= prior lower outer band) AND the active regime is not bullish
Short: Prior WESO >= overbought threshold AND (current WESO < prior WESO OR current upper outer band <= prior upper outer band) AND the active regime is not bearish
Long: Sine of Hilbert phase crosses above lead sine of Hilbert phase
Short: Sine of Hilbert phase crosses below lead sine of Hilbert phase
Long: Lead sine crosses below its lower exhaustion threshold
Short: Lead sine crosses above its upper exhaustion threshold
Long: WESO crosses below its oversold alert threshold
Short: WESO crosses above its overbought alert threshold
Long: Smoothed WESO >= 0 AND its slope > 0 OR smoothed WESO >= 0 AND its slope <= 0
Short: Smoothed WESO < 0 AND its slope > 0 OR smoothed WESO < 0 AND its slope <= 0
Long: Bullish regime score > bearish regime score AND bullish regime score >= minimum vote count
Short: Bearish regime score > bullish regime score AND bearish regime score >= minimum vote count
Long: Long extreme has been touched since its reset AND not a bearish cascade AND not ACV lockdown AND not a bearish pulse lock AND not G-force lock AND long ACV-cleared state AND close > open AND at least one bullish T1 trigger (CVD, OBV, RSI, Stoch RSI, MACD, Aroon, premium, open interest, stablecoin dominance, or armed-anchor VWAP reclaim) has not triggered; show a blocked trigger when hidden-signal display is enabled and ACV-cleared state is false
Short: Short extreme has been touched since its reset AND not a bullish cascade AND not ACV lockdown AND not a bullish pulse lock AND not G-force lock AND short ACV-cleared state AND close < open AND at least one bearish T1 trigger (CVD, OBV, RSI, Stoch RSI, MACD, Aroon, premium, open interest, stablecoin dominance, or armed-anchor VWAP rejection) has not triggered; show a blocked trigger when hidden-signal display is enabled and ACV-cleared state is false
Exit: Long, none
Exit: Short, none