Calculation: Delta = sum over the T0 bars inside the last completed T1 bar of signed volume, where signed volume is +volume if close > open, -volume if close < open, else +volume if close > prior T0 close, -volume if close < prior T0 close, else 0
Calculation: Body = close minus open of the last completed T1 bar
Calculation: AvgAbsDelta = SMA(abs(Delta), lookback) over the last completed T1 bars
Calculation: Vwap = VWAP(T0 close, T0 volume) over T0 bars of the last lookback completed T1 bars plus the forming T1 bar, up to the current chart bar
Calculation: BandCenter = EMA(Vwap, smoothing length) on chart bars
Calculation: BandSigma = EMA(sqrt(max(0, VWAP(T0 close squared, T0 volume) over the same T0 bars - Vwap squared)), smoothing length) on chart bars
Calculation: CandleBreadthHigh = max of the high of upticks-minus-downticks breadth over chart bars of the last completed T1 bar
Calculation: CandleBreadthLow = min of the low of upticks-minus-downticks breadth over chart bars of the last completed T1 bar
Long: a T1 bar completes on this chart bar AND Delta[1] < 0 AND Delta > 0 AND Body <= flat tolerance
Short: a T1 bar completes on this chart bar AND Delta[1] > 0 AND Delta < 0 AND Body >= -flat tolerance
Long: a T1 bar completes on this chart bar AND Body < -flat tolerance AND Delta > 0 AND Delta[1] >= 0
Short: a T1 bar completes on this chart bar AND Body > flat tolerance AND Delta < 0 AND Delta[1] <= 0
Long: a T1 bar completes on this chart bar AND Delta < 0 AND abs(Delta) >= absorption multiple * AvgAbsDelta AND abs(Body) <= flat tolerance
Short: a T1 bar completes on this chart bar AND Delta > 0 AND Delta >= absorption multiple * AvgAbsDelta AND abs(Body) <= flat tolerance
Long: a T1 bar completes on this chart bar AND CandleBreadthLow <= -breadth extreme AND Delta[1] < 0 AND Delta > 0 AND Body <= flat tolerance
Long: a T1 bar completes on this chart bar AND CandleBreadthLow <= -breadth extreme AND Body < -flat tolerance AND Delta > 0 AND Delta[1] >= 0
Long: a T1 bar completes on this chart bar AND CandleBreadthLow <= -breadth extreme AND Delta < 0 AND abs(Delta) >= absorption multiple * AvgAbsDelta AND abs(Body) <= flat tolerance
Short: a T1 bar completes on this chart bar AND CandleBreadthHigh >= breadth extreme AND Delta[1] > 0 AND Delta < 0 AND Body >= -flat tolerance
Short: a T1 bar completes on this chart bar AND CandleBreadthHigh >= breadth extreme AND Body > flat tolerance AND Delta < 0 AND Delta[1] <= 0
Short: a T1 bar completes on this chart bar AND CandleBreadthHigh >= breadth extreme AND Delta > 0 AND Delta >= absorption multiple * AvgAbsDelta AND abs(Body) <= flat tolerance
Short: close crosses below BandCenter + band multiple 1 * BandSigma
Short: close crosses below BandCenter + band multiple 2 * BandSigma
Short: close crosses below BandCenter + band multiple 3 * BandSigma
Long: close crosses above BandCenter - band multiple 1 * BandSigma
Long: close crosses above BandCenter - band multiple 2 * BandSigma
Long: close crosses above BandCenter - band multiple 3 * BandSigma