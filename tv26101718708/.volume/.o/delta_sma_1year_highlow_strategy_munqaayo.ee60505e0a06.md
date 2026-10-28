Calculation: Delta = volume when close > open minus volume when close < open; otherwise zero
Calculation: Delta SMA = simple moving average of Delta
Calculation: Trailing Delta SMA low = lowest Delta SMA over the lookback
Calculation: Trailing Delta SMA high = highest Delta SMA over the lookback
Long: Delta SMA crosses above zero AND Delta SMA previously fell below a configured fraction of its trailing low, with that state cleared when Delta SMA crosses above its reset level
Exit: Long, Delta SMA previously crossed above a configured fraction of its trailing high AND Delta SMA is below a configured fraction of its trailing high