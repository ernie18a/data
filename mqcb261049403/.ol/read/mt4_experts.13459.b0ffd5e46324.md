Long: EMA(open) on the previous completed bar > EMA(close) on the previous completed bar AND EMA(open) on the latest completed bar < EMA(close) on the latest completed bar
Short: EMA(open) on the previous completed bar < EMA(close) on the previous completed bar AND EMA(open) on the latest completed bar > EMA(close) on the latest completed bar
Calculation: Take-profit distance = greater of EMA(high) − EMA(low) and the minimum take-profit distance
Calculation: Long stop distance = lesser of twice (EMA(close) − EMA(low)) and the maximum stop distance
Calculation: Short stop distance = lesser of twice (EMA(high) − EMA(open)) and the maximum stop distance
Exit: long, bar low ≤ entry price − long stop distance OR bar high ≥ entry price + take-profit distance
Exit: short, bar high ≥ entry price + short stop distance OR bar low ≤ entry price − take-profit distance