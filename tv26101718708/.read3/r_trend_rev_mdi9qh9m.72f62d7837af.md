Calculation: Fast %R = selected moving average of Williams %R(source, fast lookback) using the separate fast smoothing lookback; fast lookback is shorter than slow lookback
Calculation: Slow %R = selected moving average of Williams %R(source, slow lookback) using the separate slow smoothing lookback
Calculation: Mean %R = selected moving average of (Fast %R + Slow %R) / 2 using the separate average smoothing lookback
Calculation: HTF slow %R = Williams %R(source, slow lookback) calculated on T1 bars using the last completed T1 bar and sampled on chart bars
Long: (dual mode AND Fast %R and Slow %R enter the overbought zone together) OR (average mode AND Mean %R enters the overbought zone)
Short: (dual mode AND Fast %R and Slow %R enter the oversold zone together) OR (average mode AND Mean %R enters the oversold zone)
Long: (dual mode AND Fast %R and Slow %R enter the oversold zone together) OR (average mode AND Mean %R enters the oversold zone)
Short: (dual mode AND Fast %R and Slow %R enter the overbought zone together) OR (average mode AND Mean %R enters the overbought zone)
Long: (dual mode AND the overbought zone ends) OR (average mode AND the overbought zone ends)
Short: (dual mode AND the oversold zone ends) OR (average mode AND the oversold zone ends)
Long: the oversold zone ends
Short: the overbought zone ends
Short: the overbought zone ends AND (minimum-duration filter disabled OR the prior consecutive overbought-zone bars meet the minimum duration) AND (divergence filter disabled OR, within the zone, price makes a new high and Fast %R in dual mode or Mean %R in average mode is below its value at the preceding zone high by at least the divergence margin) AND (HTF filter disabled OR (extreme-block mode AND HTF slow %R < lower Williams %R bound + HTF zone threshold) OR (bias mode AND HTF slow %R < Williams %R midpoint)) AND (price-confirmation filter disabled OR, through the confirmation window before re-entry into the overbought zone, close < Lowest(low, confirmation lookback)[1]) AND (close-only setting disabled OR the signal bar is confirmed)
Long: the oversold zone ends AND (minimum-duration filter disabled OR the prior consecutive oversold-zone bars meet the minimum duration) AND (divergence filter disabled OR, within the zone, price makes a new low and Fast %R in dual mode or Mean %R in average mode is above its value at the preceding zone low by at least the divergence margin) AND (HTF filter disabled OR (extreme-block mode AND HTF slow %R > lower Williams %R bound + HTF zone threshold) OR (bias mode AND HTF slow %R > Williams %R midpoint)) AND (price-confirmation filter disabled OR, through the confirmation window before re-entry into the oversold zone, close > Highest(high, confirmation lookback)[1]) AND (close-only setting disabled OR the signal bar is confirmed)
Long: Fast %R crosses above Slow %R in dual mode
Short: Fast %R crosses below Slow %R in dual mode
Long: (dual mode AND Fast %R and Slow %R are above the Williams %R midpoint AND either crosses above the midpoint) OR (average mode AND Mean %R crosses above the midpoint)
Short: (dual mode AND Fast %R and Slow %R are below the Williams %R midpoint AND either crosses below the midpoint) OR (average mode AND Mean %R crosses below the midpoint)
Exit: long, (dual mode AND Slow %R crosses below the Williams %R midpoint) OR (average mode AND Mean %R crosses below the midpoint)
Exit: short, (dual mode AND Slow %R crosses above the Williams %R midpoint) OR (average mode AND Mean %R crosses above the midpoint)
Calculation: Long stop = entry - max(abs(entry - (min(lowest low tracked during the oversold zone, Lowest(low, confirmation window plus two bars) - ATR(ATR lookback) * stop buffer)), instrument minimum tick size)
Calculation: Short stop = entry + max(abs(entry - (max(highest high tracked during the overbought zone, Highest(high, confirmation window plus two bars) + ATR(ATR lookback) * stop buffer)), instrument minimum tick size)
Exit: long, on a bar after entry, low <= Long stop OR high >= entry + abs(entry - Long stop) * selected target R (first-target R or second-target R, according to target selection) OR elapsed bars since entry >= maximum holding bars
Exit: short, on a bar after entry, high >= Short stop OR low <= entry - abs(entry - Short stop) * selected target R (first-target R or second-target R, according to target selection) OR elapsed bars since entry >= maximum holding bars