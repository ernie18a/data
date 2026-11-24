Calculation: HTF RSI = RSI(close, RSI length, T1 bars), calculated on T1 bars and sampled on chart bars from the last completed T1 bar or the T1 bar still forming, according to the HTF mode
Calculation: Smoothed RSI phase(R) = EMA(atan2(R - R[1], R - 50), phase smoothing length), calculated on chart bars with [1] as the previous chart bar
Calculation: Wrapped phase difference = the smoothed RSI phase of chart-timeframe RSI(price source, RSI length) minus the smoothed RSI phase of HTF RSI, wrapped into (-π, π]
Calculation: Coherence = EMA(cos(wrapped phase difference), coherence smoothing length), calculated on chart bars
Long: (Coherence >= in-phase threshold AND Coherence[1] < in-phase threshold) OR (Coherence > in-phase threshold AND Coherence[1] = in-phase threshold)
Short: (Coherence <= anti-phase threshold AND Coherence[1] > anti-phase threshold) OR (Coherence < anti-phase threshold AND Coherence[1] = anti-phase threshold)