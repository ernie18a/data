Calculation: Short-term and long-term moving averages = independently configured SMA, EMA, or VWMA of independently configured OHLC price sources, with the short-term lookback shorter than the long-term lookback.
Calculation: Anchored VWAP = volume-weighted average of typical price, reset at the start of each trading day.
Calculation: Relative volume = volume divided by its SMA.
Calculation: Nearest-neighbor confidence = form a feature vector from (1) short-term MA minus long-term MA divided by ATR times a scale, (2) close minus anchored VWAP divided by ATR times a different scale, (3) HMA minus its value a fixed number of bars earlier divided by ATR times a third scale, and (4) relative volume divided by a fourth scale. Clamp the first three features to a symmetric range and cap the fourth at its upper bound; substitute a fixed positive value for unavailable or zero ATR. Scan the preceding memory lookback, select the configured number of vectors with smallest Euclidean distance from the current vector, retaining earlier-scanned, more recent vectors on equal distances. Each neighbor votes long if its close at a fixed lag is above its close at twice that lag, short if below, and neutral if equal. Each directional confidence is its vote count divided by the total neighbor count. Confidence remains zero until the bar index exceeds the memory lookback.
Calculation: Long baseline = short-term MA > long-term MA AND close > anchored VWAP AND short-term MA > anchored VWAP AND HMA > HMA a fixed number of bars earlier AND close > HMA AND Supertrend direction is bullish AND ADX > threshold AND relative volume > threshold.
Calculation: Short baseline = short-term MA < long-term MA AND close < anchored VWAP AND short-term MA < anchored VWAP AND HMA < HMA the same number of bars earlier AND close < HMA AND Supertrend direction is bearish AND ADX > threshold AND relative volume > threshold.
Calculation: Long forecast = long confidence >= threshold AND close > anchored VWAP AND ADX > threshold. When nearest-neighbor mode is disabled, confidence is a fixed score if the long baseline is true and zero otherwise.
Calculation: Short forecast = short confidence >= threshold AND close < anchored VWAP AND ADX > threshold. When nearest-neighbor mode is disabled, confidence is the same fixed score if the short baseline is true and zero otherwise.
Calculation: Signal state = initially flat; set to long on a long signal and short on a short signal, and otherwise retain the previous state. Only the alternating signals below update this state.
Long: Nearest-neighbor mode enabled AND long forecast is true AND previous bar's long forecast is false AND signal state is not long.
Short: Nearest-neighbor mode enabled AND short forecast is true AND previous bar's short forecast is false AND signal state is not short.
Long: Nearest-neighbor mode disabled AND long baseline is true AND previous bar's long baseline is false AND signal state is not long.
Short: Nearest-neighbor mode disabled AND short baseline is true AND previous bar's short baseline is false AND signal state is not short.
Long: Long forecast is true.
Short: Short forecast is true AND long forecast is false.
Long: Short-term MA crosses above long-term MA AND anchored VWAP is available.
Short: Short-term MA crosses below long-term MA AND anchored VWAP is available.
Long: Short-term MA crosses above anchored VWAP AND long-term MA is available.
Short: Short-term MA crosses below anchored VWAP AND long-term MA is available.
Long: Short-term MA > long-term MA.
Short: Short-term MA <= long-term MA.
Long: Close > anchored VWAP AND short-term MA > anchored VWAP.
Short: Close <= anchored VWAP OR short-term MA <= anchored VWAP.
Long: HMA > HMA a fixed number of bars earlier AND close > HMA.
Short: HMA < HMA the same number of bars earlier AND close < HMA.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: Close > previous close.
Short: Close < previous close.