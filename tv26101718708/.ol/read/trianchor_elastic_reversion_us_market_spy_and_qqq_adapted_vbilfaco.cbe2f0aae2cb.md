Calculation: Tri-anchor energy percentile = percentile rank of the sum of squared distances from close to daily, weekly, and monthly HLC3 anchored VWAPs, each divided by ATR (use true range if ATR is zero), over a lookback
Calculation: Robust Z = (close − rolling median of close) / (1.4826 × rolling median of the absolute difference between close and its rolling median)
Calculation: Breadth Z = average Robust Z of the closes of three breadth instruments, calculated on the chart timeframe
Calculation: Close position in range = (close − low) / max(high − low, minimum tick)
Calculation: Gap shock = absolute percentage change from the previous close to the current open on the first regular-session bar of an intraday chart, or on each bar of a non-intraday chart
Long: Tri-anchor energy percentile ≥ threshold AND Robust Z ≤ −threshold AND close position in range ≤ threshold AND (breadth gate disabled OR Breadth Z ≤ −threshold) AND NOT gap shock, with the setup evaluated after a fixed bar delay
Short: Tri-anchor energy percentile ≥ threshold AND Robust Z ≥ threshold AND close position in range ≥ 1 − threshold AND (breadth gate disabled OR Breadth Z ≥ threshold) AND NOT gap shock
Exit: Long, current long setup OR current short setup
Exit: Short, current long setup OR short stop reached (entry price + ATR × stop multiple) OR short take profit reached (entry price − ATR × take-profit multiple)