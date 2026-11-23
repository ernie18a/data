Calculation: MA = VIDYA(close, length, CMO lookback)
Calculation: OTT line = OTT(MA, percent)
Calculation: screened trend = OTT trend(VIDYA(screened close, length, CMO lookback), percent)
Long: MA crosses above OTT line[2] AND datetime >= start date AND datetime <= end date
Short: MA crosses below OTT line[2] AND datetime >= start date AND datetime <= end date
Long: MA crosses above OTT line[2]
Short: MA crosses below OTT line[2]
Long: close crosses above OTT line[2]
Short: close crosses below OTT line[2]
Long: OTT line[2] crosses above OTT line[3]
Short: OTT line[2] crosses below OTT line[3]
Long: MA > OTT line
Short: MA < OTT line
Long: OTT line[2] > OTT line[3]
Short: OTT line[2] <= OTT line[3]
Long: screened trend[1] = up
Short: screened trend[1] = down