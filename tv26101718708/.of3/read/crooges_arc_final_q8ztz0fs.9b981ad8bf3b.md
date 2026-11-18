Calculation: Ratchet Line = Let source be the selected close or HLCC4; upper band = highest(EMA(high, smoothing lookback), channel lookback) - RMA(True Range, range lookback) × effective ratchet multiplier; lower band = lowest(EMA(low, smoothing lookback), channel lookback) + RMA(True Range, range lookback) × effective ratchet multiplier; initialize the state bullish and the line to source; each bar, pre-flip line = max(upper band, prior line) if the prior state is bullish, otherwise min(lower band, prior line; if bullish and source < pre-flip line, switch bearish and set line to lower band; if bearish and source > pre-flip line, switch bullish and set line to upper band; otherwise keep the state and set line to pre-flip line; effective ratchet multiplier = manual override when set, otherwise mode multiplier × character multiplier
Long: prior Ratchet state is bearish AND source > pre-flip Ratchet Line
Short: prior Ratchet state is bullish AND source < pre-flip Ratchet Line
Long: Ratchet state is bullish
Short: Ratchet state is bearish
Long: volume > SMA(volume, volume-average lookback) × (manual volume threshold when set, otherwise preset volume multiplier) AND close > open
Short: volume > SMA(volume, volume-average lookback) × (manual volume threshold when set, otherwise preset volume multiplier) AND close <= open
Exit: Long, close < Ratchet Line