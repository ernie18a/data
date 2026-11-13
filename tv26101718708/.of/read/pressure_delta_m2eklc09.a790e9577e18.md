Calculation: Range = high - low (use a tiny positive value if zero); LowerWick = min(open, close) - low; UpperWick = high - max(open, close)
Calculation: BuyShare = clamp(0.6 * (close - low) / Range + 0.4 * ((LowerWick - UpperWick) / Range + 1) / 2, 0, 1)
Calculation: Pressure = 100 * BuyShare
Calculation: RVoL = volume / SMA(volume, long lookback)
Calculation: RVoLDelta = (BuyShare - (1 - BuyShare)) * RVoL
Calculation: RVoLPct = 100 * RVoLDelta / RVoL
Calculation: Spike = RVoLDelta / SMA(abs(RVoLDelta), lookback shorter than the volume average lookback); 0 if the denominator is 0
Long: Pressure >= bullish pressure threshold OR RVoLDelta >= positive RVoLDelta threshold OR RVoLPct >= positive RVoLPct threshold OR Spike > positive spike threshold
Short: Pressure < the bullish pressure threshold OR RVoLDelta < the positive RVoLDelta threshold OR RVoLPct < the positive RVoLPct threshold OR Spike < 0