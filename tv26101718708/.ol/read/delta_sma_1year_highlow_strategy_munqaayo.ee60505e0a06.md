Calculation: Delta SMA = simple moving average of signed volume (volume when close > open, negative volume when close < open, zero when close = open)
Calculation: Rolling Delta SMA low = lowest Delta SMA over the lookback
Calculation: Rolling Delta SMA high = highest Delta SMA over the same lookback
Calculation: Low threshold = rolling Delta SMA low multiplied by a low-threshold factor
Calculation: High trigger = rolling Delta SMA high multiplied by a high-trigger factor
Calculation: Exit threshold = rolling Delta SMA high multiplied by an exit-threshold factor
Calculation: Low-state flag = initially false; set true when Delta SMA < low threshold; reset false when Delta SMA crosses above a reset level
Calculation: High-state flag = initially false; set true when Delta SMA crosses above high trigger; reset false when Delta SMA < exit threshold multiplied by a reset factor
Long: Low-state flag AND Delta SMA crosses above zero
Exit: long, High-state flag AND Delta SMA < exit threshold