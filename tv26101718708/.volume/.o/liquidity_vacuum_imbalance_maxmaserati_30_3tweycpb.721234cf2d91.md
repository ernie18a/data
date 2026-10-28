Calculation: Bar delta = 0.4 × volume when close > open; −0.4 × volume when close < open; otherwise 0.
Calculation: Bar range intensity = (high − low) ÷ ATR over the volume-average lookback; zero when ATR is zero.
Calculation: Low-volume bar = volume < SMA(volume, lookback) × low-volume threshold, when the SMA is positive.
Calculation: Imbalance bar = volume > 0 AND abs(bar delta) ÷ volume > delta threshold.
Calculation: Qualifying vacuum bar = range intensity > movement threshold AND low-volume bar AND NOT imbalance bar.
Calculation: Qualifying flow bar = range intensity > movement threshold AND imbalance bar AND NOT low-volume bar.
Long: A qualifying run of the selected void type reaches the minimum run length and ends or changes type, AND the sum of bar deltas in the run is ≥ 0.
Short: A qualifying run of the selected void type reaches the minimum run length and ends or changes type, AND the sum of bar deltas in the run is < 0.