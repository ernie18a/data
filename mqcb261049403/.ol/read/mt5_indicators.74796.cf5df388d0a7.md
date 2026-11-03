Calculation: EMA trend score = (1 if the shorter-lookback EMA is above the medium-lookback EMA, otherwise −1, plus 1 if the medium-lookback EMA is above the longer-lookback EMA, otherwise −1) / 2; use the last completed chart-timeframe bar
Calculation: ADX direction score = ADX strength × direction, where ADX strength is ADX / 50 clamped to [0, 1], and direction is 1 when +DI > −DI, otherwise −1; use the last completed chart-timeframe bar
Calculation: RSI momentum score = (RSI − 50) / 50, clamped to [−1, 1]; use the last completed chart-timeframe bar
Calculation: MACD momentum score = (MACD line − signal line) / ATR, clamped to [−1, 1]; use the last completed chart-timeframe bar
Calculation: Swing structure score = 1 when the latest confirmed five-bar swing high and low are both above their respective preceding confirmed swing high and low; −1 when both are below; otherwise 0. A swing high/low is higher/lower than the two bars on each side; use only completed chart-timeframe bars
Calculation: Signed score = weighted average, scaled by 100, of EMA trend score, ADX direction score, RSI momentum score, MACD momentum score, and swing structure score; each factor’s weight is an input parameter
Calculation: Volume multiplier = clamp(0.85 + 0.15 × (last completed bar’s volume / mean volume of the preceding bars), 0.85, 1.15); use the same chart timeframe, with a longer lookback for the mean than one bar
Calculation: Confidence score = clamp(abs(Signed score) × Volume multiplier, 0, 100)
Long: Signed score > 0 AND Confidence score ≥ minimum score threshold
Short: Signed score < 0 AND Confidence score ≥ minimum score threshold