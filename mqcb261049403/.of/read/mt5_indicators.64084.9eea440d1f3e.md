Calculation: WaveVolume = sum of volume over the consecutive bars since the last direction reversal, where a bar is up if close >= previous close, otherwise down; the sum restarts at the current bar's volume when the direction differs from the previous bar's
Long: close >= previous close AND WaveVolume > 0
Short: close < previous close AND WaveVolume > 0