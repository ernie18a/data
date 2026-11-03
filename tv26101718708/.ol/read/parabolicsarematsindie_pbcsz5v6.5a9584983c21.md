Calculation: Fast moving average = configured moving-average type of close with a shorter lookback than the slow moving average
Calculation: Slow moving average = configured moving-average type of close with a longer lookback than the fast moving average
Calculation: Stop buffer = EMA of true range × configured ATR multiplier
Calculation: Long stop = Parabolic SAR − stop buffer
Calculation: Short stop = Parabolic SAR + stop buffer
Calculation: Long target = entry price + (entry price − long stop) × configured risk/reward ratio
Calculation: Short target = entry price − (short stop − entry price) × configured risk/reward ratio
Long: While flat, close ≤ fast moving average AND fast moving average > slow moving average (setup marking)
Long: After the setup marking, close ≥ fast moving average AND fast moving average > slow moving average AND current Parabolic SAR < current low AND previous Parabolic SAR > previous high; once this confirmation has occurred, enter on each confirmed flat bar within the configured date range and any selected trading session(s)
Short: While flat, close ≥ fast moving average AND fast moving average < slow moving average (setup marking)
Short: After the setup marking, close ≤ fast moving average AND fast moving average < slow moving average AND current Parabolic SAR > current high AND previous Parabolic SAR < previous low; once this confirmation has occurred, enter on each confirmed flat bar within the configured date range and any selected trading session(s)
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target