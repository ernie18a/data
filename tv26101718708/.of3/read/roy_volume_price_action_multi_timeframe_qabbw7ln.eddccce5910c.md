Calculation: candle range = high - low
Calculation: candle body = abs(close - open)
Calculation: upper shadow = high - max(open, close)
Calculation: lower shadow = min(open, close) - low
Calculation: high-volume condition = volume > SMA(volume, volume lookback) × high-volume multiplier
Calculation: ultra-volume condition = volume > SMA(volume, volume lookback) × ultra-volume multiplier
Calculation: low-volume condition = volume < SMA(volume, volume lookback) × low-volume multiplier
Calculation: wide-range condition = candle range > SMA(candle range, range lookback) × wide-range multiplier
Calculation: narrow-range condition = candle range < SMA(candle range, range lookback) × narrow-range multiplier
Calculation: bullish trend condition = close > EMA(close, EMA lookback)
Calculation: bearish trend condition = close < EMA(close, EMA lookback)
Calculation: buying-pressure event = close > open AND high-volume condition AND wide-range condition AND bullish trend condition
Calculation: selling-pressure event = close < open AND high-volume condition AND wide-range condition AND bearish trend condition
Calculation: stopping-volume event = close < open AND ultra-volume condition AND lower shadow > candle body AND lower shadow > upper shadow
Calculation: upthrust event = close > open AND high-volume condition AND upper shadow > candle body × upthrust wick multiplier AND close < high - candle range × upthrust close offset
Calculation: no-demand event = close > open AND low-volume condition AND narrow-range condition
Calculation: no-supply event = close < open AND low-volume condition AND narrow-range condition
Calculation: absorption-buy event = high-volume condition AND close < open AND lower shadow > candle body AND close > low + candle range × absorption close fraction
Calculation: absorption-sell event = high-volume condition AND close > open AND upper shadow > candle body AND close < high - candle range × absorption close fraction
Calculation: bullish score = (candle score weight if close > open else 0) + (trend score weight if bullish trend condition else 0) + (volume score weight if high-volume condition else 0) + (range score weight if wide-range condition else 0) + (stopping-volume/upthrust score weight if stopping-volume event else 0) + (supply/demand score weight if no-supply event else 0) + (absorption score weight if absorption-buy event else 0)
Calculation: bearish score = (candle score weight if close < open else 0) + (trend score weight if bearish trend condition else 0) + (volume score weight if high-volume condition else 0) + (range score weight if wide-range condition else 0) + (stopping-volume/upthrust score weight if upthrust event else 0) + (supply/demand score weight if no-demand event else 0) + (absorption score weight if absorption-sell event else 0)
Long: (buying-pressure event OR stopping-volume event OR no-supply event OR absorption-buy event) AND bullish score > bearish score AND 100 × bullish score / (bullish score + bearish score) >= power threshold; evaluate on chart bars and independently on T1, T2, T3, T4, T5, and T6 bars. For each T timeframe, calculations run on its bars; request.security maps results to chart bars with lookahead_off, using the still-forming T bar in realtime and the available mapped T-bar value historically.
Short: (selling-pressure event OR upthrust event OR no-demand event OR absorption-sell event) AND bearish score > bullish score AND 100 × bearish score / (bullish score + bearish score) >= power threshold; evaluate on chart bars and independently on T1, T2, T3, T4, T5, and T6 bars. For each T timeframe, calculations run on its bars; request.security maps results to chart bars with lookahead_off, using the still-forming T bar in realtime and the available mapped T-bar value historically.
Long: bullish score > bearish score on T1, T2, T3, T4, T5, and T6 bars for the dashboard bias; calculations run on each T timeframe's bars, and request.security maps results to chart bars with lookahead_off, using the still-forming T bar in realtime and the available mapped T-bar value historically.
Short: bearish score > bullish score on T1, T2, T3, T4, T5, and T6 bars for the dashboard bias; calculations run on each T timeframe's bars, and request.security maps results to chart bars with lookahead_off, using the still-forming T bar in realtime and the available mapped T-bar value historically.