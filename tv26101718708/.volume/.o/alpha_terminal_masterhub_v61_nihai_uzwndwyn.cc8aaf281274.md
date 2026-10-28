Calculation: Buyer-volume weight = (close − low) / (high − low); use 0.5 when high = low
Calculation: Latest confirmed pivot high/low = the most recent high/low with the configured number of bars on each side lower/higher, respectively
Calculation: Weekly anchored VWAP = VWAP reset at the start of each week, using the current bar
Long: Close crosses above the latest confirmed pivot high OR buyer-volume weight > 0.65 OR buyer-volume weight > 0.5 OR MACD line > MACD signal line OR Fisher Transform > its previous value OR MFI > 50 OR close > weekly anchored VWAP OR RSI < 30
Short: Close crosses below the latest confirmed pivot low OR buyer-volume weight < 0.35 OR buyer-volume weight <= 0.5 OR MACD line <= MACD signal line OR Fisher Transform <= its previous value OR close <= weekly anchored VWAP OR RSI > 70
Exit: long, MFI <= 50