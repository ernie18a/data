Calculation: Active-address change = (active-address count on T1 − active-address count P1 T1 bars ago) / active-address count P1 T1 bars ago
Calculation: Upper active-address band = MA(Active-address change + P4 × STDEV(Active-address change, P5), P6, P7)
Calculation: Lower active-address band = MA(Active-address change − P4 × STDEV(Active-address change, P5), P6, P7)
Calculation: BTC price change = P2 ? WMA((BTC closing price on T1 − BTC closing price P1 T1 bars ago) / BTC closing price P1 T1 bars ago, P3) : (BTC closing price on T1 − BTC closing price P1 T1 bars ago) / BTC closing price P1 T1 bars ago
Long: BTC price change < Lower active-address band
Short: BTC price change > Upper active-address band