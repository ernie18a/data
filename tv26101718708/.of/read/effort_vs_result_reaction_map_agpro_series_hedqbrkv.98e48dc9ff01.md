Calculation: Safe ATR = max(ATR, minimum positive price increment); before ATR is available, use true range in place of ATR.
Calculation: Candle range = max(high - low, minimum positive price increment).
Calculation: Relative volume = volume / SMA(volume) when SMA(volume) > 0; otherwise 1. Treat missing volume as 0.
Calculation: Raw effort = relative volume × volume weight + (true range / safe ATR) × (1 - volume weight).
Calculation: Effort score = clamp(100 × raw effort / high-effort threshold, 0, 150).
Calculation: Progress direction = 1 if close is above the close at the progress lookback, -1 if below; if equal or unavailable, 1 if close >= open, otherwise -1.
Calculation: Directional close score = 100 × clamp((close - low) / candle range, 0, 1) for progress direction 1; otherwise 100 × (1 - clamp((close - low) / candle range, 0, 1)).
Calculation: Progress score = clamp(100 × abs(close - close at the progress lookback) / safe ATR / strong-progress ATR multiple, 0, 130); use 0 when the lookback close is unavailable.
Calculation: Result score = clamp(0.62 × progress score + 0.38 × directional close score, 0, 100).
Calculation: Wick balance = (high - max(open, close) - min(open, close) + low) / candle range.
Calculation: Attempt direction = sign of wick balance when abs(wick balance) >= 0.18; otherwise 1 if close > open, -1 if close < open, and progress direction if close = open.
Calculation: Failed-progress confidence = clamp(0.50 × effort score + 0.35 × (100 - result score) + 15 × abs(wick balance), 0, 100).
Calculation: Ease confidence = clamp(0.35 × (100 - effort score) + 0.50 × result score + 0.15 × directional close score, 0, 100).
Calculation: Event cooldown = number of bars since the most recent accepted long or short event; if none has occurred, the cooldown condition is satisfied. An event is accepted when either decision line is true, and resets the shared cooldown.
Long: bar index > max(volume SMA length, ATR length) + progress lookback AND event cooldown >= cooldown threshold AND ((raw effort >= high-effort threshold AND result score <= poor-result threshold AND failed-progress confidence >= confidence threshold AND attempt direction = -1) OR (NOT (raw effort >= high-effort threshold AND result score <= poor-result threshold) AND raw effort <= low-effort threshold AND result score >= strong-result threshold AND ease confidence >= confidence threshold AND progress direction = 1)).
Short: bar index > max(volume SMA length, ATR length) + progress lookback AND event cooldown >= cooldown threshold AND ((raw effort >= high-effort threshold AND result score <= poor-result threshold AND failed-progress confidence >= confidence threshold AND attempt direction = 1) OR (NOT (raw effort >= high-effort threshold AND result score <= poor-result threshold) AND raw effort <= low-effort threshold AND result score >= strong-result threshold AND ease confidence >= confidence threshold AND progress direction = -1)).