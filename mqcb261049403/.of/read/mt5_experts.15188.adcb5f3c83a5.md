Calculation: Smoothed open and close = apply the same configured smoothing method and lookback to the open and close prices on the configured indicator timeframe, which may be higher or lower than the chart timeframe; evaluate completed bars only.
Long: Previous completed indicator bar smoothed close <= smoothed open AND latest completed indicator bar smoothed close > smoothed open
Short: Previous completed indicator bar smoothed close > smoothed open AND latest completed indicator bar smoothed close <= smoothed open
Exit: long, latest completed indicator bar smoothed close <= smoothed open
Exit: short, latest completed indicator bar smoothed close > smoothed open