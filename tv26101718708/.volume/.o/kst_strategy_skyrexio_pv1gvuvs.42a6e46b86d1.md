Calculation: KST = weighted sum of four simple moving averages of close rate of change, with weights increasing from 1 to 4 and ROC lookbacks ordered shortest to longest
Calculation: Alligator jaw = smoothed moving average of (high + low) / 2, using a lagged value
Calculation: Choppiness Index = 100 × log10(sum of true range over the lookback / (highest high − lowest low over the lookback)) / log10(lookback)
Calculation: Stop loss = low of entry bar − stop multiplier × ATR(14) on entry bar
Calculation: Take profit = close of entry bar + profit multiplier × ATR(14) on entry bar
Long: KST > signal line AND previous KST ≤ previous signal line AND close > filtering moving average AND close > Alligator jaw AND (choppiness filter disabled OR Choppiness Index < threshold) AND datetime is within the configured trading period
Exit: long, high ≥ take profit OR low ≤ stop loss