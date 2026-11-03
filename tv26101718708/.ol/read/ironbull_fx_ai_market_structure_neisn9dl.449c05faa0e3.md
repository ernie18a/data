Calculation: Confirmed pivot high/low = a high/low with the same lookback number of bars on its left and right; ST, MT, and LT use progressively longer lookbacks.
Calculation: Selected high/low = latest pivot high/low of the active term (configured term, or the longest enabled term in automatic mode).
Calculation: Valid structure level = a confirmed pivot whose mean score among its k nearest prior pivots of the same term and side meets the confidence threshold; each pivot’s score is 1, and the score is 0.5 when there are not enough prior pivots.
Long: close > selected high OR close > an active valid structure high
Short: close < selected low OR close < an active valid structure low