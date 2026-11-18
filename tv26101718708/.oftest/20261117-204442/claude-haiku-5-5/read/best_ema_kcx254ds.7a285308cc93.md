Calculation: vwap = running sum of (close * volume) / running sum of volume, since session start
Calculation: vwap_change = vwap - vwap of previous bar
Long: vwap_change > 0
Short: vwap_change <= 0