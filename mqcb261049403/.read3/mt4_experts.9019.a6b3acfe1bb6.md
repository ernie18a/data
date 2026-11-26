Calculation: Short MA[n] = LWMA(close, shorter lookback, T1, n bars ago), sampled on each attached-chart tick; n=0 is forming and n>0 are completed
Calculation: Long MA[n] = SMA(close, longer lookback, T1, n bars ago), sampled on each attached-chart tick; n=0 is forming and n>0 are completed
Long: Short MA[2] < Long MA[2] AND Short MA[1] > Long MA[1] OR Long MA[trend offset] < Long MA[0]
Short: Short MA[2] > Long MA[2] AND Short MA[1] < Long MA[1] OR Long MA[trend offset] > Long MA[0]