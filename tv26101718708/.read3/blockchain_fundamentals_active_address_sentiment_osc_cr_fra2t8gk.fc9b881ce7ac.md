Calculation: Price change = optionally WMA((price close of current T1 bar − price close N T1 bars ago) / price close N T1 bars ago, smoothing lookback) when smoothing is enabled; otherwise use the unsmoothed percentage change. Calculate on chart bars using the still-forming T1 close in real time.
Calculation: Address change = (address close of current T1 bar − address close N T1 bars ago) / address close N T1 bars ago, calculated on chart bars using the still-forming T1 close in real time. Use the same N as for price change.
Calculation: Upper/lower bands = selected MA(address change ± band multiplier × standard deviation(address change, volatility lookback), band lookback), calculated on chart bars.
Long: Price change < lower band OR Price change < lower price-change threshold
Short: Price change > upper band OR Price change > upper price-change threshold
Calculation: Active-address change = (active-address count on T1 − active-address count P1 T1 bars ago) / active-address count P1 T1 bars ago
Calculation: Upper active-address band = MA(Active-address change + P4 × STDEV(Active-address change, P5), P6, P7)
Calculation: Lower active-address band = MA(Active-address change − P4 × STDEV(Active-address change, P5), P6, P7)
Calculation: BTC price change = P2 ? WMA((BTC closing price on T1 − BTC closing price P1 T1 bars ago) / BTC closing price P1 T1 bars ago, P3) : (BTC closing price on T1 − BTC closing price P1 T1 bars ago) / BTC closing price P1 T1 bars ago
Long: BTC price change < Lower active-address band
Short: BTC price change > Upper active-address band