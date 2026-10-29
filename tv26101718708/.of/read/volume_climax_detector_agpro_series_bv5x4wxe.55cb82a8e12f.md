Calculation: Volume Z-score = (volume - rolling mean(volume)) / rolling standard deviation(volume)
Calculation: Relative volume = volume / rolling mean(volume)
Calculation: Spread ratio = (high - low) / rolling mean(high - low)
Calculation: Close location = (close - low) / (high - low)
Calculation: Body percentage = abs(close - open) / (high - low)
Calculation: Trend EMA slope = current trend EMA - trend EMA at the slope lookback
Calculation: Normalized EMA slope = trend EMA slope / ATR
Calculation: Bull trend = close > trend EMA AND normalized EMA slope > trend-slope threshold
Calculation: Bear trend = close < trend EMA AND normalized EMA slope < -trend-slope threshold
Calculation: Event side = +1 if close location >= close-location threshold, else -1 if close location <= 1 - close-location threshold, else +1 if close >= open, otherwise -1
Calculation: Event score = round(clamp(relative-volume score + spread score + close score + trend score + body score, 0, 90)); relative-volume score = clamp(relative volume / (relative-volume threshold × 2) × 24, 0, 24); spread score = clamp(spread ratio / (spread threshold × 1.8) × 20, 0, 20); close score = clamp(close quality × 20, 0, 20), where close quality = close location for event side +1 and 1 - close location for event side -1; trend score = 14 when the trend agrees with the event side, 4 when it opposes it, otherwise 8; body score = clamp(body percentage × 12, 0, 12)
Long: event side = -1 AND (volume Z-score >= Z-score threshold OR relative volume >= relative-volume threshold) AND spread ratio >= spread threshold AND (close location >= close-location threshold OR close location <= 1 - close-location threshold OR body percentage >= body threshold) AND event score >= minimum event score AND cooldown elapsed AND no active event within its follow-through window
Short: event side = +1 AND (volume Z-score >= Z-score threshold OR relative volume >= relative-volume threshold) AND spread ratio >= spread threshold AND (close location >= close-location threshold OR close location <= 1 - close-location threshold OR body percentage >= body threshold) AND event score >= minimum event score AND cooldown elapsed AND no active event within its follow-through window