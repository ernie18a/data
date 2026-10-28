Calculation: Net volume = volume × ((close − low) − (high − close)) ÷ (high − low); use 0 when high = low
Calculation: Buy-volume average = multiplier × SMA of max(net volume, 0) over its lookback
Calculation: Sell-volume average = multiplier × SMA of min(net volume, 0) over its lookback
Calculation: Initial stop = signal-bar high − (signal-bar close − lowest low over the 50-bar window ending on the signal bar) × trailing-stop percentage
Long: close > open AND previous close < previous open AND close > previous high AND net volume > buy-volume average AND net volume > −previous net volume AND previous net volume < 0
Short: close < open AND previous close > previous open AND close < previous low AND net volume < sell-volume average AND net volume < −previous net volume AND previous net volume > 0
Exit: long, low ≤ initial stop OR (close < open AND previous close > previous open AND close < previous low AND net volume < sell-volume average AND net volume < −previous net volume AND previous net volume > 0)