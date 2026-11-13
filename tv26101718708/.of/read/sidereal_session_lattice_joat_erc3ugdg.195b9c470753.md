Calculation: Session VWAP = cumulative sum(hlc3*volume)/cumulative sum(volume), reset at the start of each session, computed on chart-timeframe bars
Calculation: Session phase = (bars since session start, mod a cycle length) / cycle length, giving a value in [0,1); session bar count starts at 0 on the first bar of the session
Calculation: Harmonic blend = positive weight A*sin(2*pi*phase) + positive weight B*sin(4*pi*phase + pi/4), with A > B
Calculation: Drift ATR = EMA(close - Session VWAP, drift smoothing length) / ATR (chart timeframe)
Calculation: Range position = (close - session low so far) / (session high so far - session low so far); 0.5 if the range is zero
Calculation: Orbit width = ATR * (base + positive weight*|Harmonic blend| + smaller positive weight*|Drift ATR|)
Calculation: Orbit mean = Session VWAP + Harmonic blend * Orbit width * fraction below 1
Calculation: Upper orbit = Orbit mean + Orbit width; Lower orbit = Orbit mean - Orbit width
Calculation: Anomaly rank = percent rank, over an anomaly lookback, of |log return| / SMA(|log return|, same anomaly lookback); 50 if unavailable. The anomaly lookback is longer than the entropy lookback
Calculation: Entropy pct = binary Shannon entropy of upShare, normalized to 0-100, where upShare = sum(max(close-open,0)*volume) over an entropy lookback / sum(|close-open|*volume) over the same lookback (0.5 if the denominator is zero)
Calculation: Phase pressure = clamp to [-100,100] of ((Range position - 0.5)*100 + positive weight*Drift ATR + positive weight*Harmonic blend)
Calculation: Lattice score = clamp to [0,100] of (positive weight*Anomaly rank + positive weight*|Phase pressure| + positive weight*(100 - Entropy pct)), weights sum to 1
Long: bar is closed AND bar is inside the session AND close > Upper orbit AND Phase pressure > 0 AND Lattice score >= a score gate
Short: bar is closed AND bar is inside the session AND close < Lower orbit AND Phase pressure < 0 AND Lattice score >= the same score gate