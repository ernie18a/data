Calculation: Passband = (a1−a2)×p[i] + (a2×(1−a1)−a1×(1−a2))×p[i−1] + ((1−a1)+(1−a2))×Passband[i−1] − (1−a1)×(1−a2)×Passband[i−2], where a1=5/longer period, a2=5/shorter period, and p is the selected price from the input bars; calculated on the chart timeframe or a higher timeframe, using its bar still forming
Calculation: RMS = square root of the mean of Passband squared over the lookback bars; calculated on the same timeframe as Passband, using its bar still forming
Long: Passband crosses above −RMS
Short: Passband crosses below +RMS