Calculation: latest confirmed pivot high = latest confirmed PivotHigh(high, pivot lookback, pivot lookback)
Calculation: latest confirmed pivot low = latest confirmed PivotLow(low, pivot lookback, pivot lookback)
Calculation: bullish BOS = close > latest confirmed pivot high
Calculation: bearish BOS = close < latest confirmed pivot low
Calculation: recent bullish BOS = bullish BOS occurred within the BOS recency lookback
Calculation: recent bearish BOS = bearish BOS occurred within the BOS recency lookback
Calculation: structure bias = bullish after bullish BOS, then bearish after bearish BOS, otherwise unchanged; initially neutral
Calculation: low sweep = low < latest confirmed pivot low AND close > latest confirmed pivot low
Calculation: high sweep = high > latest confirmed pivot high AND close < latest confirmed pivot high
Calculation: anchored volume profile = Volume Profile over the configured anchor window, using row-count, value-area-fraction, and high-resolution-distribution settings; calculated only on the last chart bar using its current values
Calculation: profile POC = POC(anchored volume profile)
Calculation: profile VAH = VAH(anchored volume profile)
Calculation: profile VAL = VAL(anchored volume profile)
Calculation: value-area height = profile VAH - profile VAL
Calculation: anchored VWAP = sum(selected source × volume) / sum(volume) over the configured anchor window for positive-volume bars with a valid source; unavailable if the denominator is zero; calculated only on the last chart bar using its current values
Calculation: bull volume share = 100 × SMA(buy proxy, flow lookback) / [SMA(buy proxy, flow lookback) + SMA(sell proxy, flow lookback)], or 50 if the denominator is zero; buy proxy = volume × clamp((close - low) / max(high - low, minimum price increment), 0, 1); sell proxy = volume × [1 - clamp((close - low) / max(high - low, minimum price increment), 0, 1)]
Calculation: bear volume share = 100 - bull volume share
Calculation: long signal fires = signals enabled AND chart bar confirmed AND (if a liquidity sweep is required: low sweep AND close > open; otherwise: latest confirmed pivot low exists AND close > latest confirmed pivot low AND close > open AND close > close[1]) AND (structure confirmation not required OR recent bullish BOS) AND (VA-edge test not required OR profile VAL unavailable OR abs(low - profile VAL) <= VA tolerance × value-area height OR abs(low - profile POC) <= VA tolerance × value-area height) AND (trend filter disabled OR close > EMA(close, trend lookback)) AND (no previous signal OR bars since the most recent signal >= signal cooldown)
Calculation: short signal fires = signals enabled AND chart bar confirmed AND (if a liquidity sweep is required: high sweep AND close < open; otherwise: latest confirmed pivot high exists AND close < latest confirmed pivot high AND close < open AND close < close[1]) AND (structure confirmation not required OR recent bearish BOS) AND (VA-edge test not required OR profile VAH unavailable OR abs(high - profile VAH) <= VA tolerance × value-area height OR abs(high - profile POC) <= VA tolerance × value-area height) AND (trend filter disabled OR close < EMA(close, trend lookback)) AND (no previous signal OR bars since the most recent signal >= signal cooldown)
Long: long signal fires
Short: short signal fires
Long: structure bias is bullish
Short: structure bias is bearish
Long: profile VAH is available AND close > profile VAH
Short: profile VAH is available AND close < profile VAL
Long: bull volume share >= bear volume share
Short: bear volume share > bull volume share
Long: bull volume share > pressure threshold
Short: bear volume share > pressure threshold
Long: low sweep
Short: high sweep
Long: VWAP display enabled AND anchored VWAP available AND close > anchored VWAP
Short: VWAP display enabled AND anchored VWAP available AND close < anchored VWAP
Long: long signal fires OR (neither signal fires AND structure bias is bullish AND bull volume share >= pressure threshold AND (profile POC unavailable OR close >= profile POC))
Short: short signal fires OR (neither signal fires AND structure bias is bearish AND bear volume share >= pressure threshold AND (profile POC unavailable OR close <= profile POC))