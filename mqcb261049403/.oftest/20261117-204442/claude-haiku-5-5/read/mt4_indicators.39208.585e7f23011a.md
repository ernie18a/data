Calculation: VolumeChange = volume of the current bar minus volume of the previous bar
Calculation: VolumeStdDev = standard deviation of volume over the Lookback bars ending at the current bar, inclusive
Long: Close > Open AND VolumeChange > VolumeStdDev * Multiplier
Short: Close < Open AND VolumeChange > VolumeStdDev * Multiplier