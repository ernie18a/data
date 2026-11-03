Calculation: Relative volume = current bar volume / average volume over a lookback
Calculation: Trigger price = setup bar close + trigger buffer
Calculation: Close location = (close − low) / (high − low)
Calculation: Giveback percentage = 100 × (high − close) / (high − low)
Calculation: Very wide bar = high − low ≥ range threshold
Calculation: Current R = (close − entry price) / (ATR × ATR multiplier)
Long: A setup was armed within the maximum setup age when close > EMA, close > VWAP, and relative volume ≥ setup minimum; on a later bar before setup expiry, high ≥ trigger price, close > EMA, close > VWAP, relative volume ≥ entry minimum, and (increasing-volume filter is disabled OR current volume > prior bar volume)
Exit: long, close < EMA AND close < VWAP OR (bars since entry ≥ 1 AND ((close < open AND close location ≤ weak-close threshold AND ((close > EMA AND close < VWAP) OR (close < EMA AND close > VWAP))) OR (close < open AND giveback percentage ≥ reversal threshold AND very wide bar) OR (base-hit threshold reached AND close < open AND (close ≤ EMA OR close ≤ VWAP)) OR (current R < 1 AND close < open AND (close ≤ EMA OR close ≤ VWAP)))) OR (close < open AND close location ≤ weak-close threshold AND (close ≤ VWAP OR close ≤ EMA)) OR (bars since entry > 0 AND relative volume < 1 AND (close ≤ EMA OR close ≤ VWAP))