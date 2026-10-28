Calculation: Price source = (high + low + close) / 3
Calculation: Prior-window median = median of the previous lookback bars' price sources, excluding the current bar
Calculation: Robust scale = 1.4826 × median absolute deviation of the previous lookback bars' price sources from the prior-window median
Calculation: Relative volume = current volume / median volume of the previous lookback bars
Calculation: Volume coverage = fraction of previous lookback bars with non-missing, positive volume
Calculation: Participation weight = square root of relative volume clipped to a bounded minimum and maximum
Calculation: Raw robust Z = (current price source − prior-window median) / robust scale
Calculation: Weighted Z = raw robust Z × participation weight
Long: Confirmed bar, adequate prior-window volume coverage, valid positive current and median volume, robust scale above a near-zero floor, and either (weighted Z ≥ outer threshold AND relative volume ≥ supported-volume floor AND prior confirmed state ≠ supported upper) OR (raw robust Z ≤ −outer threshold AND relative volume ≤ thin-volume ceiling AND prior confirmed state ≠ thin lower)
Short: Confirmed bar, adequate prior-window volume coverage, valid positive current and median volume, robust scale above a near-zero floor, and either (weighted Z ≤ −outer threshold AND relative volume ≥ supported-volume floor AND prior confirmed state ≠ supported lower) OR (raw robust Z ≥ outer threshold AND relative volume ≤ thin-volume ceiling AND prior confirmed state ≠ thin upper)
Exit: Long, confirmed bar, adequate prior-window volume coverage, valid positive current and median volume, robust scale above a near-zero floor, prior confirmed state ≠ balanced, and absolute weighted Z ≤ center-return threshold
Exit: Short, confirmed bar, adequate prior-window volume coverage, valid positive current and median volume, robust scale above a near-zero floor, prior confirmed state ≠ balanced, and absolute weighted Z ≤ center-return threshold