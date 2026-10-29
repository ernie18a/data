Calculation: Previous-quarter high/low = highest high and lowest low across the previous completed calendar quarter, using completed higher-timeframe bars
Calculation: QRB range = previous-quarter high - previous-quarter low
Calculation: QRB midline = (previous-quarter high + previous-quarter low) / 2
Calculation: QRB position = (close - previous-quarter low) / QRB range × 100
Calculation: Eligible = valid QRB range AND close ≥ minimum price AND average volume over its configured lookback ≥ minimum average volume
Calculation: Approach rising = close > close at the configured approach lookback
Calculation: Breakout seen = a close above the previous-quarter high has occurred during the current calendar quarter
Long: Eligible AND close crosses above QRB midline
Long: Eligible AND no earlier close above the previous-quarter high this quarter AND close > previous-quarter high
Long: Eligible AND no close above the previous-quarter high earlier this quarter AND QRB position is within the configured ready zone below 100% AND approach rising
Long: Eligible AND breakout seen on an earlier bar this quarter AND bars since the first such breakout are within the configured retest lookback AND current bar's low-to-high range intersects the configured tolerance band around the previous-quarter high AND close ≥ previous-quarter high
Long: Eligible AND breakout seen this quarter AND close > previous-quarter high AND NOT the first breakout bar this quarter AND NOT a retest