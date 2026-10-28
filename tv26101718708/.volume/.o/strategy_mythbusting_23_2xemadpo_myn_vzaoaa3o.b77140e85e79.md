Calculation: DPO = close minus the simple moving average of close over a lookback, shifted back by half that lookback plus one bar; use the current chart timeframe.
Calculation: Long stop = lowest low over a lookback ending on the entry bar; use the current chart timeframe.
Calculation: Short stop = highest high over a lookback ending on the entry bar; use the current chart timeframe.
Calculation: Long target = entry price + (entry price − long stop) × a reward multiple.
Calculation: Short target = entry price − (short stop − entry price) × a reward multiple.
Long: fast EMA crosses above slow EMA AND DPO > 0 on the current bar and the previous two bars.
Short: fast EMA crosses below slow EMA AND DPO < 0 on the current bar and the previous two bars.
Exit: Long, close ≤ long stop OR close ≥ long target.
Exit: Short, close ≥ short stop OR close ≤ short target.