Calculation: Ember ratio = if the sum of volume over the last ember lookback bars where high - low <= ATR(ATR lookback) * small-bar ATR multiple is positive, the sum over those bars of (volume when close > open, -volume when close < open, otherwise 0) divided by that volume sum; otherwise 0
Calculation: Bullish ignition = high - low >= ATR(ATR lookback) * ignition ATR multiple AND close > open AND close > previous bar close
Calculation: Bearish ignition = high - low >= ATR(ATR lookback) * ignition ATR multiple AND close < open AND close < previous bar close
Calculation: Signal score = round(min(min(abs(Ember ratio) * ratio-score weight, ratio-score cap) + (Bullish ignition OR Bearish ignition ? ignition points : 0) + min(abs(Change(EMA(close, bias EMA lookback), bias slope lookback)) / (ATR(ATR lookback) + ATR stabilizer) * bias-score weight, bias-score cap), total-score cap))
Long: Ember ratio > ember alert threshold
Short: Ember ratio < -ember alert threshold
Long: Bullish ignition
Short: Bearish ignition
Long: Ember ratio > 0 AND Bullish ignition AND close > EMA(close, bias EMA lookback) AND Change(EMA(close, bias EMA lookback), bias slope lookback) > 0 AND Signal score >= score threshold AND signal cooldown bars have elapsed since the previous long or short signal AND the current chart bar is confirmed
Short: Ember ratio < 0 AND Bearish ignition AND close < EMA(close, bias EMA lookback) AND Change(EMA(close, bias EMA lookback), bias slope lookback) < 0 AND Signal score >= score threshold AND signal cooldown bars have elapsed since the previous long or short signal AND the current chart bar is confirmed