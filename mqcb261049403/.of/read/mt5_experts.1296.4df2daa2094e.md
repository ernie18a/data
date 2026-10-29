Calculation: NonLagDot = a cosine-weighted average of a moving average, using a longer lookback than its underlying moving average; weights are cosine(pi × t), multiplied by 1 when t ≤ 0.5 and otherwise by 1/(3πt + 1), then normalized by their sum. t advances in two parameterized increments across the lookback.
Calculation: MACD = fast NonLagDot − slow NonLagDot, where the fast NonLagDot uses a shorter lookback than the slow NonLagDot.
Calculation: Signal line = moving average of MACD.
Long: On the indicator timeframe's latest completed bar, NonLagDot is rising by more than its filter threshold.
Short: On the indicator timeframe's latest completed bar, NonLagDot is falling by more than its filter threshold.
Long: On the indicator timeframe's latest two completed bars, MACD crosses from at or below zero to above zero (breakdown mode's buy condition).
Short: On the indicator timeframe's latest two completed bars, MACD crosses from at or above zero to below zero (breakdown mode's sell condition).
Long: On the indicator timeframe's latest three completed bars, MACD first falls and then rises (MACD twist mode).
Short: On the indicator timeframe's latest three completed bars, MACD first rises and then falls (MACD twist mode).
Long: On the indicator timeframe's latest three completed bars, the signal line first falls and then rises (signal twist mode).
Short: On the indicator timeframe's latest three completed bars, the signal line first rises and then falls (signal twist mode).
Long: On the indicator timeframe's latest two completed bars, MACD crosses from at or below the signal line to above it (MACD disposition mode).
Short: On the indicator timeframe's latest two completed bars, MACD crosses from at or above the signal line to below it (MACD disposition mode).
Exit: short, MACD > 0 (breakdown mode)
Exit: long, MACD < 0 (breakdown mode)
Exit: short, MACD is rising over the latest two completed bars (MACD twist mode)
Exit: long, MACD is falling over the latest two completed bars (MACD twist mode)
Exit: short, the signal line is rising over the latest two completed bars (signal twist mode)
Exit: long, the signal line is falling over the latest two completed bars (signal twist mode)
Exit: short, MACD > signal line on the latest completed bar (MACD disposition mode)
Exit: long, MACD < signal line on the latest completed bar (MACD disposition mode)