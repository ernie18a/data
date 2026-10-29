Calculation: Stochastic Fast = the simple moving average of %K, where %K = 100 × (close − lowest low) / (highest high − lowest low) over a lookback; smooth %K with a shorter lookback.
Calculation: Stochastic Slow = the simple moving average of Stochastic Fast over a longer lookback.
Calculation: 123 reversal state = 1 when close two bars ago < previous close AND current close > previous close AND Stochastic Fast < Stochastic Slow AND Stochastic Fast > a level; −1 when close two bars ago > previous close AND current close < previous close AND Stochastic Fast > Stochastic Slow AND Stochastic Fast < that level; otherwise retain the previous state, initially 0.
Calculation: Negative Volume Index = previous value plus close rate of change over a lookback when current volume < previous volume; otherwise retain the previous value, initially 0.
Calculation: NVI trend state = 1 when Negative Volume Index > its exponential moving average, or −1 when it is lower; otherwise retain the previous state, initially 0. Use the same lookback for the rate of change and the exponential moving average.
Long: 123 reversal state = 1 AND NVI trend state = 1
Short: 123 reversal state = −1 AND NVI trend state = −1
Exit: long, NOT (123 reversal state = 1 AND NVI trend state = 1) AND NOT (123 reversal state = −1 AND NVI trend state = −1)
Exit: short, NOT (123 reversal state = 1 AND NVI trend state = 1) AND NOT (123 reversal state = −1 AND NVI trend state = −1)