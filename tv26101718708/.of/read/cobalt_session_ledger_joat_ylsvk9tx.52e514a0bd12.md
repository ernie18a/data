Calculation: Synthetic delta = volume × clamp(0.68 × (close − open) / range + 0.32 × (2 × close − high − low) / range, −1, 1) × (0.30 + 0.70 × clamp(abs(close − open) / range, 0, 1)), where range = max(high − low, minimum price increment)
Calculation: Session VWAP = cumulative (typical price × volume) / cumulative volume within the configured session, where typical price = (high + low + close) / 3
Calculation: Session sigma = EMA of the square root of max(cumulative (typical price² × volume) / cumulative volume − session VWAP², 0)
Calculation: Sigma position = clamp((close − session VWAP) / (2 × session sigma), −1, 1)
Calculation: Sigma state = 2 if close ≥ session VWAP + 2 × session sigma; 1 if close ≥ session VWAP + session sigma; −2 if close ≤ session VWAP − 2 × session sigma; −1 if close ≤ session VWAP − session sigma; otherwise 0
Calculation: Synthetic delta baseline = EMA of synthetic delta; delta spread = standard deviation of synthetic delta over the same lookback; normalized delta = (synthetic delta − delta baseline) / max(delta spread, 1)
Calculation: Session CVD = cumulative synthetic delta within the configured session
Calculation: CVD signal = EMA of session CVD with a longer lookback than the synthetic delta baseline; CVD pulse = clamp((session CVD − CVD signal) / max(EMA(abs(session CVD − CVD signal), volume baseline lookback), 1), −1, 1)
Calculation: Volume ratio = volume / max(SMA(volume, volume baseline lookback), 1)
Calculation: Confidence = clamp(50 + 16 × VWAP bias + 15 × delta bias + 13 × CVD pulse + 18 × sweep bias + 10 × absorption bias + 8 × clamp((volume ratio − 1) / 1.6, −1, 1) + 5 × session bias, 0, 100), where VWAP bias = clamp((close − session VWAP) / (ATR × 1.25), −1, 1), delta bias = clamp(normalized delta / 2, −1, 1), sweep bias = 1 for a bullish sweep, −1 for a bearish sweep, otherwise 0, absorption bias = 0.65 for bullish absorption, −0.65 for bearish absorption, otherwise 0, and session bias = 0.20 in session, −0.05 otherwise
Calculation: Confirmed swing high/low = most recent pivot high/low confirmed after the same number of bars on its right as on its left
Calculation: Bullish sweep = confirmed bar AND low < confirmed swing low AND close > confirmed swing low AND close > open; bearish sweep = confirmed bar AND high > confirmed swing high AND close < confirmed swing high AND close < open
Calculation: Close bias = (close − low) / max(high − low, minimum price increment); compactness = clamp(1 − max(high − low, minimum price increment) / max(ATR × absorption range ceiling, minimum price increment), 0, 1)
Calculation: Bullish absorption = confirmed bar AND volume ratio ≥ volume spike threshold AND compactness > 0.35 AND close bias ≥ bullish close bias threshold AND synthetic delta > 0; bearish absorption = confirmed bar AND volume ratio ≥ volume spike threshold AND compactness > 0.35 AND close bias ≤ bearish close bias threshold AND synthetic delta < 0
Calculation: Bullish reclaim = bullish sweep AND (lower wick − upper wick) / max(high − low, minimum price increment) > 0.10 AND close > session VWAP; bearish reclaim = bearish sweep AND (lower wick − upper wick) / max(high − low, minimum price increment) < −0.10 AND close < session VWAP
Long: Bullish sweep
Long: Bullish absorption
Long: Confirmed bar AND cooldown elapsed since the previous ledger signal AND confidence ≥ entry threshold AND close > session VWAP AND synthetic delta > synthetic delta baseline AND session CVD ≥ CVD signal AND sigma position > −0.35 AND NOT bearish sweep AND (bullish reclaim OR bullish absorption OR sigma state ≤ 0)
Short: Bearish sweep
Short: Bearish absorption
Short: Confirmed bar AND cooldown elapsed since the previous ledger signal AND confidence ≥ entry threshold AND close < session VWAP AND synthetic delta < synthetic delta baseline AND session CVD ≤ CVD signal AND sigma position < 0.35 AND NOT bullish sweep AND (bearish reclaim OR bearish absorption OR sigma state ≥ 0)
Calculation: Long stop = min(signal bar low, session VWAP − 2 × session sigma) − 0.15 × ATR; short stop = max(signal bar high, session VWAP + 2 × session sigma) + 0.15 × ATR; risk distance = max(abs(entry price − stop), 0.50 × ATR); third target = entry price + position direction × risk distance × third target R multiple
Exit: Long, confirmed bar AND (low ≤ long stop OR high ≥ third target)
Exit: Short, confirmed bar AND (high ≥ short stop OR low ≤ third target)