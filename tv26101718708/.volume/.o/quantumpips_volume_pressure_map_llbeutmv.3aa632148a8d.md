Calculation: Relative volume = current volume / SMA(volume, volume lookback)
Calculation: Bar range = max(high − low, minimum tick)
Calculation: Close position = (close − low) / bar range
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Calculation: Smoothed pressure = EMA(volume × (2 × (close position − 0.5) + 0.3 × (lower wick − upper wick) / bar range), pressure smoothing lookback)
Calculation: Compression ratio = (highest high − lowest low over structure lookback) / max(ATR(14) × structure lookback, minimum tick)
Calculation: Accumulation score = 1 if relative volume ≥ high-volume threshold + 1 if compression ratio ≤ compression threshold + 1 if smoothed pressure > 0 + 0.5 if close position ≥ 0.60 + 0.5 if lower wick > upper wick
Calculation: Distribution score = 1 if relative volume ≥ high-volume threshold + 1 if compression ratio ≤ compression threshold + 1 if smoothed pressure < 0 + 0.5 if close position ≤ 0.40 + 0.5 if upper wick > lower wick
Calculation: Body fraction = abs(close − open) / bar range
Calculation: Cumulative pressure = cumulative sum of volume × (2 × (close position − 0.5) + 0.3 × (lower wick − upper wick) / bar range)
Long: Relative volume ≥ high-volume threshold AND accumulation score ≥ 3 OR relative volume ≥ extreme-volume threshold AND close > open AND close position ≥ 0.70 OR relative volume ≥ high-volume threshold AND body fraction ≤ absorption body threshold AND lower wick > 2 × upper wick OR smoothed pressure > 0 OR cumulative pressure > EMA(cumulative pressure, volume lookback)
Short: Relative volume ≥ high-volume threshold AND distribution score ≥ 3 OR relative volume ≥ extreme-volume threshold AND close < open AND close position ≤ 0.30 OR relative volume ≥ high-volume threshold AND body fraction ≤ absorption body threshold AND upper wick > 2 × lower wick OR smoothed pressure < 0 OR cumulative pressure ≤ EMA(cumulative pressure, volume lookback)
Exit: