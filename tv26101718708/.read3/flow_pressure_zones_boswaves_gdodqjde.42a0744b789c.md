Calculation: Close position = (close - low) / max(high - low, minimum tick size)
Calculation: Normalized volume = if SMA(volume, volume lookback) > 0 then min(volume / SMA(volume, volume lookback), volume cap) else normalized-volume fallback
Calculation: Raw flow = ABS(close - open) / max(high - low, minimum tick size) × normalized volume
Calculation: Normalized flow = if highest(raw flow, flow lookback) > lowest(raw flow, flow lookback) then (raw flow - lowest(raw flow, flow lookback)) / (highest(raw flow, flow lookback) - lowest(raw flow, flow lookback)) else flow fallback
Long: close > WMA(close, baseline lookback)
Short: close <= WMA(close, baseline lookback)
Long: close <= WMA(close, baseline lookback) AND close position > upper close-position threshold AND close > open AND normalized volume > minimum normalized-volume threshold AND normalized flow > minimum normalized-flow threshold
Short: close > WMA(close, baseline lookback) AND close position < lower close-position threshold AND close < open AND normalized volume > minimum normalized-volume threshold AND normalized flow > minimum normalized-flow threshold