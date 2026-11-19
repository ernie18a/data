Calculation: Volume spike = SMA(volume, spike-volume lookback) > 0 AND volume >= spike multiplier × SMA(volume, spike-volume lookback)
Calculation: Close position = (close - low) / (high - low) when high > low; the midpoint fraction when high = low
Calculation: Accumulation spike = volume spike AND close position >= close-position threshold
Calculation: Distribution spike = volume spike AND close position <= 1 - close-position threshold
Calculation: Spike bias = initially neutral; accumulation spike sets it long and distribution spike sets it short, remaining until the opposite classified spike; distribution takes precedence if both occur together
Long: Accumulation spike
Short: Distribution spike
Long: Spike bias is long
Short: Spike bias is short
Long: Close crosses above EMA(close, entry-reclaim lookback)
Short: Close crosses below EMA(close, entry-reclaim lookback)
Long: Accumulation spike AND NOT distribution spike AND previous spike bias was not long
Short: Distribution spike AND previous spike bias was not short
Long: (Spike-Only mode AND accumulation spike OR NOT Spike-Only mode AND spike bias is long AND close crosses above EMA(close, entry-reclaim lookback)) AND (session restriction is disabled OR current chart bar is in session) AND position is not long AND at least cooldown chart bars have elapsed since the previous entry signal AND the bar is confirmed
Short: (Spike-Only mode AND distribution spike OR NOT Spike-Only mode AND spike bias is short AND close crosses below EMA(close, entry-reclaim lookback)) AND (session restriction is disabled OR current chart bar is in session) AND position is not short AND at least cooldown chart bars have elapsed since the previous entry signal AND the bar is confirmed