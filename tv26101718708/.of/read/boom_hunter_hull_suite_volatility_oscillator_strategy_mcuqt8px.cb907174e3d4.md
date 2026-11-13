Calculation: Roof(P) = Ehlers roofing filter of close: 2-pole high-pass with a fixed cutoff period longer than any P, then 2-pole Super Smoother low-pass with period P; X = filtered value / Peak, where Peak = max(|filtered value|, 0.991 * previous Peak)
Calculation: Trigger = short SMA of Roof(P_short) X (no warp), and Q2 = (X + K) / (K * X + 1) with X from Roof(P_long) and K > 0; P_long is longer than P_short; both are scaled by the same linear transform
Calculation: Hull = Hull moving average of close with a long length
Calculation: Spike = close - open; SpikeSD = standard deviation of Spike over a lookback
Calculation: Ref = close of the signal bar; ATR = average true range. LongStop = min(Ref - ATR, lowest low over N bars including the signal bar); LongTarget = Ref + R * (Ref - LongStop); ShortStop = max(Ref + ATR, highest high over N bars including the signal bar); ShortTarget = Ref - R * (ShortStop - Ref); all fixed at entry
Long: Trigger crosses above Q2 AND Hull > Hull value 2 bars ago AND close > Hull AND Spike > SpikeSD AND no long position is open
Short: Trigger crosses below Q2 AND Hull < Hull value 2 bars ago AND close < Hull value 2 bars ago AND Spike < -SpikeSD AND no short position is open
Exit: long, low <= LongStop OR high >= LongTarget OR Short condition is true
Exit: short, high >= ShortStop OR low <= ShortTarget OR Long condition is true