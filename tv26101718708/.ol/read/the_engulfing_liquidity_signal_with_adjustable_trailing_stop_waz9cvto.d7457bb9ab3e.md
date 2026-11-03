Calculation: Net volume = 0 when high = low; otherwise volume × ((close − low) − (high − close)) / (high − low)
Calculation: Positive net volume average = 2 × simple moving average of max(net volume, 0) over a lookback
Calculation: Negative net volume average = 2 × simple moving average of min(net volume, 0) over a lookback
Calculation: Lowest low = lowest low over a lookback ending on the current bar
Calculation: Long stop level = signal-bar high − stop percentage × (signal-bar close − signal-bar lowest low)
Long: close > open AND previous close < previous open AND close > previous high AND net volume > positive net volume average AND net volume > −previous net volume AND previous net volume < 0
Exit: long, low ≤ long stop level OR (close < open AND previous close > previous open AND close < previous low AND net volume < negative net volume average AND net volume < −previous net volume AND previous net volume > 0)