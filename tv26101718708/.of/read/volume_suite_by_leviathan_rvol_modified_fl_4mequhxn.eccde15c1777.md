Calculation: Lower-timeframe buy volume = sum of volume from completed lower-timeframe bars within the chart bar whose close > open.
Calculation: Lower-timeframe sell volume = sum of volume from completed lower-timeframe bars within the chart bar whose close < open.
Calculation: Volume delta = lower-timeframe buy volume - lower-timeframe sell volume.
Calculation: Relative value of a series = its current value / its simple moving average, including the current bar.
Calculation: Relative volume = either the relative value of volume or current volume / average volume of the most recent prior chart bars with the same local hour and minute, searched within a maximum lookback; optionally require the full requested number of matching bars.
Calculation: Positive delta series = volume delta when volume delta > 0, otherwise 0; negative delta series = volume delta when volume delta < 0, otherwise 0.
Long: close > open.
Short: close <= open.
Long: volume delta > 0.
Short: volume delta <= 0.
Long: lower-timeframe buy volume > its simple moving average multiplied by a threshold factor OR its relative value > a threshold OR its z-score >= a threshold.
Short: lower-timeframe sell volume > its simple moving average multiplied by a threshold factor OR its relative value >= a threshold OR its z-score >= a threshold.