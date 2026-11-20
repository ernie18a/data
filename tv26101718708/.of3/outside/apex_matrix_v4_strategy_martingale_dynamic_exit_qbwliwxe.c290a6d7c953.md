Calculation: Aggregated open interest = sum(open interest across three exchanges)
Calculation: Bullish swing failure pattern = low < lowest low of prior P1 bars AND close > that lowest low
Calculation: Bearish swing failure pattern = high > highest high of prior P1 bars AND close < that highest high
Calculation: Volume anomaly = volume > SMA(volume, P2) + P3 × standard deviation(volume, P2)
Calculation: Absorption = abs(close - open) < P4 × abs(high - low)
Long: bullish swing failure pattern occurred within P5 bars AND (volume anomaly OR absorption) AND Tether dominance < SMA(Tether dominance, P6) AND aggregated open interest ≤ SMA(aggregated open interest, P6) AND more than P5 bars since the previous long signal
Short: bearish swing failure pattern occurred within P5 bars AND (volume anomaly OR absorption) AND Tether dominance > SMA(Tether dominance, P6) AND aggregated open interest > SMA(aggregated open interest, P6) AND more than P5 bars since the previous short signal