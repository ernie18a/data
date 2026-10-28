Calculation: Session VWAP = volume-weighted average of HLC3 since the start of the current configured session, including the current bar
Calculation: Session standard deviation = square root of max(0, session volume-weighted average of HLC3 squared − Session VWAP squared); smooth with an EMA
Calculation: Synthetic delta = volume × clamp(0.68 × (close−open)/range + 0.32 × (2×close−high−low)/range, −1, 1) × (0.30 + 0.70 × clamp(abs(close−open)/range, 0, 1)), where range is max(high−low, minimum price increment)
Calculation: Session CVD = sum of Synthetic delta since the start of the current configured session, including the current bar
Calculation: Delta bias = clamp((Synthetic delta − EMA(Synthetic delta)) / (2 × standard deviation of Synthetic delta), −1, 1); use the same lookback for the EMA and standard deviation
Calculation: CVD pulse = clamp((Session CVD − EMA(Session CVD)) / EMA(abs(Session CVD − EMA(Session CVD))), −1, 1); the signal EMA uses twice the delta smoothing lookback and the denominator EMA uses the volume baseline lookback
Calculation: VWAP bias = clamp((close − Session VWAP) / (1.25 × ATR), −1, 1)
Calculation: Structure bias = 1 for a bullish sweep, −1 for a bearish sweep, otherwise 0
Calculation: Absorption bias = 0.65 for bullish absorption, −0.65 for bearish absorption, otherwise 0
Calculation: Confidence = clamp(50 + 16×VWAP bias + 15×Delta bias + 13×CVD pulse + 18×Structure bias + 10×Absorption bias + 8×clamp((volume/SMA(volume)−1)/1.6, −1, 1) + 5×session bias, 0, 100), where session bias is 0.20 in session and −0.05 otherwise
Calculation: Sigma position = clamp((close − Session VWAP) / (2 × smoothed session standard deviation), −1, 1)
Calculation: Sigma state = 2 if close is at or above Session VWAP + 2×smoothed session standard deviation; 1 if at or above +1×; −2 if at or below −2×; −1 if at or below −1×; otherwise 0
Calculation: Bullish sweep = confirmed bar with low below the latest confirmed pivot low and close above that pivot low and open
Calculation: Bearish sweep = confirmed bar with high above the latest confirmed pivot high and close below that pivot high and open
Calculation: Bullish absorption = confirmed bar with volume/SMA(volume) at least the volume-spike threshold, compactness above 0.35, close location within the bar at least the bullish close-bias threshold, and Synthetic delta > 0; compactness = clamp(1 − bar range/(ATR × absorption-range threshold), 0, 1)
Calculation: Bearish absorption = confirmed bar with volume/SMA(volume) at least the volume-spike threshold, compactness above 0.35, close location within the bar at most the bearish close-bias threshold, and Synthetic delta < 0
Calculation: Bullish reclaim = bullish sweep and (low wick − high wick)/bar range > 0.10 and close > Session VWAP
Calculation: Bearish reclaim = bearish sweep and (low wick − high wick)/bar range < −0.10 and close < Session VWAP
Calculation: Long stop = min(signal-bar low, Session VWAP − 2×smoothed session standard deviation) − 0.15×ATR
Calculation: Short stop = max(signal-bar high, Session VWAP + 2×smoothed session standard deviation) + 0.15×ATR
Calculation: Risk unit = max(abs(entry price − stop), 0.50×ATR)
Calculation: Long third target = entry price + risk unit × third target R multiple; Short third target = entry price − risk unit × third target R multiple
Long: bullish sweep OR bullish absorption
Long: confirmed bar AND bars since previous ledger signal > signal cooldown AND Confidence ≥ long-confidence threshold AND close > Session VWAP AND Synthetic delta > its EMA AND Session CVD ≥ its signal EMA AND Sigma position > −0.35 AND NOT bearish sweep AND (bullish reclaim OR bullish absorption OR Sigma state ≤ 0)
Short: bearish sweep OR bearish absorption
Short: confirmed bar AND bars since previous ledger signal > signal cooldown AND Confidence ≥ short-confidence threshold AND close < Session VWAP AND Synthetic delta < its EMA AND Session CVD ≤ its signal EMA AND Sigma position < 0.35 AND NOT bullish sweep AND (bearish reclaim OR bearish absorption OR Sigma state ≥ 0)
Exit: Long, confirmed bar AND (low ≤ Long stop OR high ≥ Long third target)
Exit: Short, confirmed bar AND (high ≥ Short stop OR low ≤ Short third target)