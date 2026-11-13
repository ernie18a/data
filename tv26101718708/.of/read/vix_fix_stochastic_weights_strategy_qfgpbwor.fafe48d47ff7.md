Calculation: WVF = (highest close over lookback A - low) / (highest close over lookback A) * 100
Calculation: UpperBand = SMA(WVF, B) + k * stdev(WVF, B), with k a positive multiplier
Calculation: RangeHigh = f * highest WVF over lookback C, with f a fraction below 1 and C longer than A
Calculation: SpikeNow = WVF >= UpperBand OR WVF >= RangeHigh
Calculation: SpikePrev = SpikeNow evaluated on the previous bar (WVF[1] vs UpperBand[1] and RangeHigh[1])
Calculation: Pullback = close < close N_long bars ago OR close < close N_med bars ago, with N_long > N_med
Calculation: K = average of two components. Component 1 = SMA of the Stochastic %K of (close, high, low) over lookback L1. Component 2 = SMA of the Stochastic of RSI(close) over lookback L2 (stochastic of RSI uses RSI as close, high and low), where the RSI length is similar to L2. Both SMA smoothing lengths are short.
Calculation: D = SMA(K, short length)
Calculation: CCIh = CCI(hlc3, n); CCIc = CCI(close, n); m = a lookback for the stochastic window
Calculation: S = 100 * WMA(V3, w), where V3 = (CCIh - lowest(CCIh, m)) / (highest(CCIc, m) - lowest(CCIc, m)), and V3 = 0 when the denominator is 0 or undefined. Trigger = S on the previous bar.
Long: SpikePrev AND NOT SpikeNow AND low > previous low AND close > previous high AND close > close M bars ago (M short, below N_med) AND Pullback
Long: SpikePrev AND SpikeNow AND close > previous close AND close > previous open AND close > close M bars ago AND Pullback
Long: S crosses above Trigger (S > Trigger AND previous S <= previous Trigger) AND S < 50
Short: S crosses below Trigger (S < Trigger AND previous S >= previous Trigger) AND S > 50
Exit: long, K crosses below D (K < D AND previous K >= previous D) AND D > 80