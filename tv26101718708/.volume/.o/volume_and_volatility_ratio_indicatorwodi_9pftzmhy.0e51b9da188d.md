Calculation: Volume average = simple moving average of volume over a lookback
Calculation: Volatility index = volume × (high − low) / close × 100
Calculation: Volatility threshold = long-lookback simple moving average of volatility index × threshold multiplier / 100
Calculation: Pattern A = volatility index[1] > volatility index[2] AND (volatility index[1] > volatility index[0] OR volume[1] > volume[0]) AND volume > volume average AND volatility index > volatility threshold AND ((open[1] − close[1] < close[1] − low[1]) OR (open[0] − close[0] < close[0] − low[0])) AND close[1] < close[0] AND close[lookback+1] > close[lookback] > … > close[2] > close[1]
Calculation: Pattern B = volatility index[1] > volatility index[2] AND (volatility index[1] > volatility index[0] OR volume[1] > volume[0]) AND volume > volume average AND volatility index > volatility threshold AND ((close[1] − open[1] < high[1] − close[1]) OR (close[0] − open[0] < high[0] − close[0])) AND close[1] > close[0] AND close[lookback+1] < close[lookback] < … < close[2] < close[1]
Calculation: Pattern A range = max(high[lookback], high[0]) − min(low[1], low[0])
Calculation: Pattern B range = max(high[1], high[0]) − min(low[lookback], low[0])
Long: Pattern A AND reversal mode off AND position size ≤ 0 OR Pattern B AND reversal mode on AND position size ≤ 0
Short: Pattern A AND reversal mode on AND position size ≥ 0 OR Pattern B AND reversal mode off AND position size ≥ 0
Exit: Long, low < long stop (Pattern A low − Pattern A range × stop ratio, or Pattern B low − Pattern B range × stop ratio) OR high > long target (Pattern A low + Pattern A range × target ratio, or Pattern B low + Pattern B range × target ratio)
Exit: Short, high > short stop (Pattern A high + Pattern A range × stop ratio, or Pattern B high + Pattern B range × stop ratio) OR low < short target (Pattern A high − Pattern A range × target ratio, or Pattern B high − Pattern B range × target ratio)