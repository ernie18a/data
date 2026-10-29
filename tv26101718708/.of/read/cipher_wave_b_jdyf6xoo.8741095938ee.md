Calculation: Heikin-Ashi OHLC = standard Heikin-Ashi values derived from the input OHLC bars
Calculation: Fast Wave = EMA of the normalized deviation of HLC3 from its EMA, smoothed by a second EMA and multiplied by an amplitude factor; normalized deviation = (HLC3 − EMA(HLC3)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3))))
Calculation: Signal Wave = SMA of Fast Wave
Long: Fast Wave crosses above Signal Wave AND Signal Wave ≤ oversold dot level
Short: Fast Wave crosses below Signal Wave AND Signal Wave ≥ overbought dot level