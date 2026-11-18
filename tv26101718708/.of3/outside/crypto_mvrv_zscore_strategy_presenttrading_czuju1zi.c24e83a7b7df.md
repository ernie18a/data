Calculation: Valuation spread = (Bitcoin market capitalization on T1 - realized Bitcoin market capitalization on T1) / standard deviation of Bitcoin market capitalization values - Bitcoin market capitalization on T1 / realized Bitcoin market capitalization on T1
Calculation: Spread Z-Score = SMA((Valuation spread - SMA(Valuation spread, Z-score calculation period)) / standard deviation(Valuation spread, Z-score calculation period), smoothing period)
Long: Spread Z-Score crosses above long entry threshold AND configured trade direction permits long
Short: Spread Z-Score crosses below short entry threshold AND configured trade direction permits short
Exit: long, Spread Z-Score crosses below short entry threshold AND configured trade direction permits long and disallows short
Exit: short, Spread Z-Score crosses above long entry threshold AND configured trade direction permits short and disallows long