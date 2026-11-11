Calculation: Buy-volume weight = (close − low) / (high − low), or a neutral weight when high equals low.
Calculation: Fisher transform = normalize close within the rolling highest high and lowest low, recursively smooth the normalized value, clamp it near −1 and 1, apply the log transform, and add a smoothed contribution from the previous Fisher value; use zero when the rolling range is zero.
Calculation: Pivot-high target = the most recently confirmed pivot high, replaced when a new pivot high is confirmed and cleared after an upward close crossover; a pivot is confirmed after its specified right-side bars and is compared with its specified left-side bars.
Calculation: Pivot-low target = the most recently confirmed pivot low, replaced when a new pivot low is confirmed and cleared after a downward close crossover; a pivot is confirmed after its specified right-side bars and is compared with its specified left-side bars.
Calculation: Anchored VWAP = cumulative close × volume divided by cumulative volume, reset at the start of each specified calendar period.
Calculation: Score = sum of configurable positive weights for RSI above its lower score threshold AND below its upper score threshold; MACD line above its signal line; Fisher transform above its previous value; buy-volume weight above its score threshold; money flow index above its threshold; close above anchored VWAP; relative volume above its threshold; and Bollinger upper band below Keltner upper band AND Bollinger lower band above Keltner lower band. Relative volume is volume divided by its moving average, or a neutral value when the average is unavailable or zero. Keltner bands are an EMA of close plus or minus a multiple of ATR.
Long: Close crosses above the pivot-high target.
Short: Close crosses below the pivot-low target.
Long: Current low > high two bars ago AND previous close > high two bars ago.
Short: Current high < low two bars ago AND previous close < low two bars ago.
Long: Volume-based candle coloring is enabled AND buy-volume weight > its upper candle threshold.
Short: Volume-based candle coloring is enabled AND buy-volume weight < its lower candle threshold.
Long: Close >= open AND (volume-based candle coloring is disabled OR buy-volume weight >= its lower candle threshold AND buy-volume weight <= its upper candle threshold).
Short: Close < open AND (volume-based candle coloring is disabled OR buy-volume weight >= its lower candle threshold AND buy-volume weight <= its upper candle threshold).
Long: RSI < its lower display threshold.
Short: RSI > its upper display threshold.
Long: MACD line > signal line.
Short: MACD line <= signal line.
Long: Fisher transform > its previous value.
Short: Fisher transform <= its previous value.
Long: Buy-volume weight > its display threshold.
Short: Buy-volume weight <= its display threshold.
Long: Money flow index > its threshold.
Short: Money flow index <= its threshold.
Long: Close > anchored VWAP.
Short: Close <= anchored VWAP.
Long: Score >= its upper display threshold.
Short: Score < its lower display threshold.