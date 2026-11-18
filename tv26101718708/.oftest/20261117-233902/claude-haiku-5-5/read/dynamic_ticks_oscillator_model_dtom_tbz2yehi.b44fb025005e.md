Calculation: ROC_S = ROC(secondary close from T1 last completed bar, roc lookback) on chart bars
Calculation: SD_S = STDEV(ROC_S, volatility lookback)
Long: ROC_S < -(SD_S * entry multiplier)
Exit: long, ROC_S > SD_S * exit multiplier