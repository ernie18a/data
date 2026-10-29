Calculation: Reference high/low = either the highest high / lowest low over the structure lookback, excluding the current bar, or the high / low of the last completed higher-timeframe bar, according to the selected level mode
Calculation: Relative volume = current volume / average volume over the preceding volume lookback bars
Calculation: Body ratio = abs(close - open) / ATR
Calculation: Normalized pressure = sum over the pressure lookback of volume × (2 × (close - low) / (high - low) - 1), divided by the preceding average volume × the pressure lookback
Calculation: Close extension = distance from close to the broken reference level in the breakout direction / ATR
Calculation: Breakout score = count of these four conditions: relative volume meets its threshold; body ratio meets its threshold and, when direction is required, close is above open for an upward breakout or below open for a downward breakout; normalized pressure meets its positive threshold for an upward breakout or its negative threshold for a downward breakout; close extension meets its threshold
Long: high > reference high AND close > reference high AND breakout score >= 3
Short: low < reference low AND close < reference low AND breakout score >= 3