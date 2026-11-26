Calculation: 2U = high > high[1] AND low >= low[1]
Calculation: 2D = low < low[1] AND high <= high[1]
Calculation: 1 = high <= high[1] AND low >= low[1]
Calculation: 3 = high > high[1] AND low < low[1]
Calculation: F2D = 2D AND close > open
Calculation: F2U = 2U AND close < open
Calculation: 22U = 2D[1] AND 2U
Calculation: 22D = 2U[1] AND 2D
Calculation: 212U = 2D[2] AND 1[1] AND 2U
Calculation: 212D = 2U[2] AND 1[1] AND 2D
Calculation: 312U = 3[2] AND 1[1] AND 2U
Calculation: 312D = 3[2] AND 1[1] AND 2D
Calculation: Markov adaptive threshold = clamp(StDev(100 * (selected source / selected source[1] - 1), volatility lookback) * sqrt(regime lookback) * multiplier, max(minimum threshold, 0), max(maximum threshold, minimum threshold))
Calculation: Markov bullish threshold = adaptive threshold in adaptive mode; fixed bullish threshold otherwise
Calculation: Markov bearish threshold = -adaptive threshold in adaptive mode; fixed bearish threshold otherwise
Calculation: Markov state = 1 when 100 * (selected source / selected source[regime lookback] - 1) >= Markov bullish threshold; -1 when it is <= Markov bearish threshold; otherwise 0
Calculation: Markov transition probability from state a to state b = 100 * count of sampled transitions from a to b / count of sampled transitions from a, classifying returns with the current Markov thresholds over the transition lookback
Calculation: Markov forecast distribution at the shortest horizon = the transition probability row for the current Markov state; each later horizon distribution is the preceding distribution multiplied by the transition probability matrix
Calculation: Markov signal = mean of bull forecast percentage minus bear forecast percentage at the shortest, middle, and longest forecast horizons, in that order
Calculation: Markov sample count = count of sampled transitions from the current Markov state
Long: 2U OR F2D OR 22U OR 212U OR 312U OR ((Markov sample count = 0 OR Markov sample count >= minimum sample count) AND (Markov signal >= strong threshold OR (Markov signal < strong threshold AND Markov signal > weak band)))
Short: 2D OR F2U OR 22D OR 212D OR 312D OR ((Markov sample count = 0 OR Markov sample count >= minimum sample count) AND (Markov signal <= -strong threshold OR (Markov signal > -strong threshold AND Markov signal < -weak band)))