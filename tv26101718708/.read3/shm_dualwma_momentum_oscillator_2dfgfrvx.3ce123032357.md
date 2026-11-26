Calculation: DWO = ((WMA(price source, shorter lookback) - WMA(price source, longer lookback)) / WMA(price source, longer lookback)) * 100, calculated on T1 bars using the current T1 bar in real time and the last completed T1 bar historically, then projected onto chart bars
Calculation: histogram = DWO - EMA(DWO, signal smoothing lookback), calculated on T1 bars using the current T1 bar in real time and the last completed T1 bar historically, then projected onto chart bars
Long: DWO > zero baseline
Short: DWO < zero baseline
Long: histogram >= 0
Short: histogram < 0