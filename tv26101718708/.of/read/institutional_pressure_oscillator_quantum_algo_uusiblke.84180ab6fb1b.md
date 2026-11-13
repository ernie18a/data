Calculation: TP = (high + low + close) / 3
Calculation: Gate = sensitivity * close * standard deviation, over a lookback, of (ln(TP) - ln(previous TP))
Calculation: Base = simple moving average of volume over window W, taken as of the previous bar (excluding the current bar)
Calculation: Pressure = if (TP - previous TP) > Gate then min(volume, cap * Base); else if (TP - previous TP) < -Gate then -min(volume, cap * Base); else 0
Calculation: Osc = sum of Pressure over the last W bars / Base
Calculation: Trigger = exponential moving average of Osc with a lookback much shorter than W
Long: Osc crosses above Trigger (Osc <= Trigger on the previous bar and Osc > Trigger on the current bar) OR Osc crosses above 0
Short: Osc crosses below Trigger (Osc >= Trigger on the previous bar and Osc < Trigger on the current bar) OR Osc crosses below 0