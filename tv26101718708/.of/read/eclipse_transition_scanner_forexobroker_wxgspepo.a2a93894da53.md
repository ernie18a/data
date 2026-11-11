Calculation: Compression = maximum of abs(shorter-period EMA(close) - longer-period EMA(close)) over the proximity lookback including the current bar, divided by current ATR.
Calculation: Directional setup = shorter-period EMA(close) crosses above or below longer-period EMA(close) AND ATR > 0 AND Compression <= maximum compression threshold AND volume >= SMA(volume) * volume multiplier AND RSI(close) > bullish RSI threshold for an upward cross or RSI(close) < bearish RSI threshold for a downward cross.
Calculation: Directional score = round(min(100, min((maximum compression threshold - Compression) * 150 + 20, 35) + volume score + momentum score + 20)), where volume score = min(max((volume / SMA(volume) - 1) * 45, 0), 25) if SMA(volume) > 0, otherwise 0; momentum score = min((RSI(close) - 50) * 2, 25) for an upward directional setup and min((50 - RSI(close)) * 2, 25) for a downward directional setup.
Calculation: Bars since signal = current bar index minus the index of the most recent long or short signal satisfying the directional setup, score threshold, and cooldown conditions; initialize the most recent signal index to 0 and update it after each such signal.
Long: shorter-period EMA(close) > longer-period EMA(close).
Short: shorter-period EMA(close) <= longer-period EMA(close).
Long: RSI(close) > bullish RSI threshold.
Short: RSI(close) <= bullish RSI threshold AND RSI(close) < bearish RSI threshold.
Long: upward directional setup AND directional score >= 70.
Short: downward directional setup AND directional score >= 70.
Long: upward directional setup AND directional score >= signal score threshold AND bars since signal >= cooldown threshold.
Short: downward directional setup AND directional score >= signal score threshold AND bars since signal >= cooldown threshold.