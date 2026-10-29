Calculation: Entry price = lower-timeframe bar close
Calculation: Long stop-loss price = entry price − stop-loss buffer
Calculation: Long take-profit price = entry price + (entry price − long stop-loss price) × risk-reward ratio
Calculation: Short stop-loss price = entry price + stop-loss buffer
Calculation: Short take-profit price = entry price − (short stop-loss price − entry price) × risk-reward ratio
Long: lower-timeframe bar close > high of the last completed higher-timeframe bar AND long stop-loss price > 0 AND long take-profit price > 0
Short: lower-timeframe bar close < low of the last completed higher-timeframe bar AND short stop-loss price > 0 AND short take-profit price > 0
Exit: long, low <= long stop-loss price OR high >= long take-profit price
Exit: short, high >= short stop-loss price OR low <= short take-profit price