Calculation: Rolling low and low RSI = lowest low and lowest RSI of close, respectively, over the same lookback; initialize the stored low and stored low RSI from these values, then update both only when the rolling low is strictly below the stored low, after evaluating the decision.
Calculation: Rolling high and high RSI = highest high and highest RSI of close, respectively, over the same lookback; initialize the stored high and stored high RSI from these values, then update both only when the rolling high is strictly above the stored high, after evaluating the decision.
Calculation: Running high and running low = highest high and lowest low, respectively, since the first chart bar, including the current bar.
Long: Rolling low < stored low AND rolling low RSI > stored low RSI
Long: Close > running high AND previous close <= previous running high
Short: Rolling high > stored high AND rolling high RSI < stored high RSI
Short: Close < running low AND previous close >= previous running low