Calculation: Moving averages = independently configured SMA, EMA, or VWMA of a selected price source; one has a shorter lookback and the other a longer lookback.
Calculation: VWAP = volume-weighted average of (high + low + close) / 3, reset at the start of each trading day.
Calculation: Relative volume = volume / SMA of volume.
Calculation: k-NN confidence = form a feature vector from (shorter MA - longer MA) / (ATR × scale), (close - VWAP) / (ATR × scale), (HMA - HMA at an earlier bar) / (ATR × scale), each clipped to [-1, 1], and relative volume / scale capped at 1. Use 1 in place of ATR when ATR is unavailable or zero. After the historical lookback is available, scan the preceding bars in that lookback from newest to oldest and retain the k smallest Euclidean distances to the current vector; replace the first most-distant retained neighbor only when the new distance is strictly smaller. Label each neighbor bullish if its close at an earlier offset is greater than its close at a still earlier offset, bearish if less, and neutral if equal. Bullish and bearish confidence are their respective vote counts divided by all retained neighbors, including neutral neighbors. Before the lookback is available, confidence is zero.
Calculation: Baseline long state = shorter MA > longer MA AND close > VWAP AND shorter MA > VWAP AND HMA > HMA at an earlier bar AND close > HMA AND Supertrend direction is bullish AND ADX > threshold AND relative volume > threshold.
Calculation: Baseline short state = shorter MA < longer MA AND close < VWAP AND shorter MA < VWAP AND HMA < HMA at an earlier bar AND close < HMA AND Supertrend direction is bearish AND ADX > threshold AND relative volume > threshold.
Calculation: AI long state = bullish k-NN confidence >= confidence threshold AND close > VWAP AND ADX > threshold.
Calculation: AI short state = bearish k-NN confidence >= confidence threshold AND close < VWAP AND ADX > threshold.
Calculation: Signal state = initially flat; set to long on a final long signal and to short on a final short signal. A final signal requires the selected AI or baseline state to be true on the current bar and false on the previous bar, and signal state to differ from its direction.
Long: AI long state = true AND AI long state on previous bar = false AND signal state != long.
Short: AI short state = true AND AI short state on previous bar = false AND signal state != short.
Long: Baseline long state = true AND baseline long state on previous bar = false AND signal state != long.
Short: Baseline short state = true AND baseline short state on previous bar = false AND signal state != short.
Long: AI long state = true.
Short: AI long state = false AND AI short state = true.
Long: Shorter MA crosses above longer MA AND VWAP is available.
Short: Shorter MA crosses below longer MA AND VWAP is available.
Long: Shorter MA crosses above VWAP AND longer MA is available.
Short: Shorter MA crosses below VWAP AND longer MA is available.
Long: Close > previous close.
Short: Close < previous close.
Long: Close > VWAP AND shorter MA > VWAP.
Short: Close <= VWAP OR shorter MA <= VWAP.
Long: Shorter MA > longer MA.
Short: Shorter MA <= longer MA.
Long: HMA > HMA at an earlier bar AND close > HMA.
Short: HMA < HMA at an earlier bar AND close < HMA.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.