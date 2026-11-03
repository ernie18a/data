Calculation: Opening range high = highest high during the opening-range period
Calculation: Opening range low = lowest low during the opening-range period
Calculation: Long fixed-risk target = entry price + (entry price − opening range low) × reward multiple
Calculation: Short fixed-risk target = entry price − (opening range high − entry price) × reward multiple
Long: Opening range is complete AND previous completed chart-timeframe bar close > opening range high AND no long breakout has occurred that day AND before entry cutoff AND long trading is enabled
Short: Opening range is complete AND previous completed chart-timeframe bar close < opening range low AND no short breakout has occurred that day AND before entry cutoff AND short trading is enabled
Long: Previous condition is true AND current chart-timeframe close > moving average when moving-average take-profit filtering is enabled AND position is flat
Short: Previous condition is true AND current chart-timeframe close < moving average when moving-average take-profit filtering is enabled AND position is flat
Exit: Long, low ≤ opening range low OR high ≥ long fixed-risk target OR close < moving average
Exit: Short, high ≥ opening range high OR low ≤ short fixed-risk target OR close > moving average