Calculation: T3-anchored VWAP = VWAP(hlc3, anchored at each T3 boundary, current/forming T3 period), evaluated on chart bars
Calculation: T3 VWAP bands = upper and lower VWAP bands using the T3-anchored VWAP and band-width parameter, evaluated on chart bars
Calculation: Confirmed swing pivots = pivot high(high, swing lookback, swing lookback) and pivot low(low, swing lookback, swing lookback); retain the latest and preceding confirmed pivots and RSI at each pivot bar
Calculation: Bullish structure = latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low
Calculation: Bearish structure = latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low
Calculation: Structure direction = bullish when bullish structure is true, bearish when bearish structure is true, otherwise retain the previous direction; initially neutral
Calculation: Bullish break = close > latest confirmed pivot high AND close[1] <= latest confirmed pivot high
Calculation: Bearish break = close < latest confirmed pivot low AND close[1] >= latest confirmed pivot low
Calculation: Bullish BOS = bullish break AND structure direction is bullish
Calculation: Bearish BOS = bearish break AND structure direction is bearish
Calculation: Bullish CHoCH = bullish break AND structure direction is bearish
Calculation: Bearish CHoCH = bearish break AND structure direction is bullish
Calculation: Bullish sweep = low < latest confirmed pivot low AND close > latest confirmed pivot low AND selected-source RVOL(volume lookback, chart timeframe current/forming bar) >= volume-spike threshold
Calculation: Bearish sweep = high > latest confirmed pivot high AND close < latest confirmed pivot high AND selected-source RVOL(volume lookback, chart timeframe current/forming bar) >= volume-spike threshold
Calculation: Recent bullish sweep or BOS = the corresponding event occurred within the recent-event lookback
Calculation: Recent bearish sweep or BOS = the corresponding event occurred within the recent-event lookback
Calculation: Bearish divergence = latest confirmed pivot high > preceding confirmed pivot high AND RSI at latest pivot high < RSI at preceding pivot high
Calculation: Bullish divergence = latest confirmed pivot low < preceding confirmed pivot low AND RSI at latest pivot low > RSI at preceding pivot low
Calculation: Bullish structure score = count of true conditions: close > T3-anchored VWAP; fast EMA > mid EMA; recent bullish sweep; recent bullish BOS; selected-source RVOL(volume lookback, chart timeframe current/forming bar) >= volume-spike threshold; close > upper T3 VWAP band
Calculation: Bearish structure score = count of true conditions: close < T3-anchored VWAP; fast EMA < mid EMA; recent bearish sweep; recent bearish BOS; selected-source RVOL(volume lookback, chart timeframe current/forming bar) >= volume-spike threshold; close < lower T3 VWAP band
Calculation: Bullish and bearish score shares = 50% each when their sum is zero; otherwise each score divided by their sum
Calculation: Flow = zero when the bullish and bearish structure scores sum to zero; otherwise 100% × (bullish structure score - bearish structure score) / their sum
Calculation: Trend strength = min(ADX / ADX normalization parameter, ADX cap parameter) × ADX weight parameter + (fast, mid, and slow EMAs stacked in either direction ? full-stack weight parameter : fast EMA != mid EMA ? partial-stack weight parameter : 0) + min(abs(close - T3-anchored VWAP) / (ATR == 0 ? 1 : ATR), VWAP-gap cap parameter) × VWAP weight parameter + (native RVOL(volume lookback) >= volume-spike threshold ? native-spike weight parameter : native RVOL(volume lookback) > native-volume baseline parameter ? above-average-volume weight parameter : 0), with indicators calculated in the requested timeframe context
Calculation: Bullish chart trend = fast EMA > mid EMA AND (slow-EMA alignment filter disabled OR mid EMA > slow EMA) AND close > T3-anchored VWAP
Calculation: Bearish chart trend = fast EMA < mid EMA AND (slow-EMA alignment filter disabled OR mid EMA < slow EMA) AND close < T3-anchored VWAP
Long: bullish chart trend
Short: bearish chart trend
Long: bullish sweep
Short: bearish sweep
Long: bullish BOS OR bullish CHoCH, structure labels enabled AND chart bar confirmed
Short: bearish BOS OR bearish CHoCH, structure labels enabled AND chart bar confirmed
Long: recent bullish sweep
Short: recent bearish sweep
Long: bullish share >= bias-display threshold parameter
Short: bearish share >= bias-display threshold parameter
Long: Flow >= flow-display threshold parameter
Short: Flow <= -flow-display threshold parameter
Long: RSI(close, RSI lookback) > call RSI threshold parameter
Short: RSI(close, RSI lookback) < put RSI threshold parameter
Long: EMA(close, fast lookback, T2, last completed bar) > EMA(close, mid lookback, T2, last completed bar), values taken on chart bars
Short: EMA(close, fast lookback, T2, last completed bar) <= EMA(close, mid lookback, T2, last completed bar), values taken on chart bars
Long: reference-index alignment enabled AND an index is configured AND EMA(reference-index close, fast lookback, T2, last completed bar) > EMA(reference-index close, mid lookback, T2, last completed bar), values taken on chart bars
Short: reference-index alignment enabled AND an index is configured AND EMA(reference-index close, fast lookback, T2, last completed bar) <= EMA(reference-index close, mid lookback, T2, last completed bar), values taken on chart bars
Long: long-term-high proximity marking enabled AND highest(high, long-term lookback, T3, last completed bar) is available AND close >= that high × high-proximity multiplier parameter
Short: long-term-low proximity marking enabled AND lowest(low, long-term lookback, T3, last completed bar) is available AND close <= that low × low-proximity multiplier parameter
Option: buy call, RSI(close, RSI lookback) crosses above call RSI threshold parameter OR bullish BOS OR bullish sweep; EMA(close, fast lookback, T2, last completed bar) > EMA(close, mid lookback, T2, last completed bar) AND trend strength(T2, last completed bar) >= minimum-strength parameter; EMA(close, fast lookback, T1, last completed bar) > EMA(close, mid lookback, T1, last completed bar) AND SMA(volume from selected volume source, volume lookback, T1, last completed bar) > 0 AND RVOL(volume from selected volume source, volume lookback, T1, last completed bar) >= minimum-volume-ratio parameter; reference-index alignment disabled or no index configured or reference-index EMA fast > EMA mid on T2 last completed bar; bullish chart trend; RSI(close, RSI lookback) > call RSI threshold parameter AND RSI(close, RSI lookback) < overbought parameter; bullish structure score >= bullish entry-score parameter; Flow > entry-flow threshold parameter; ADX(adx lookback) > minimum-ADX parameter; session restriction disabled or chart-bar time is within the configured session in Asia/Kolkata; bar-close validation disabled or chart bar confirmed; entries since the current T3 period began < signal-cap parameter; no prior entry signal or chart bars since the prior entry signal >= cooldown parameter; position is flat
Option: buy put, RSI(close, RSI lookback) crosses below put RSI threshold parameter OR bearish BOS OR bearish sweep; EMA(close, fast lookback, T2, last completed bar) < EMA(close, mid lookback, T2, last completed bar) AND trend strength(T2, last completed bar) >= minimum-strength parameter; EMA(close, fast lookback, T1, last completed bar) < EMA(close, mid lookback, T1, last completed bar) AND SMA(volume from selected volume source, volume lookback, T1, last completed bar) > 0 AND RVOL(volume from selected volume source, volume lookback, T1, last completed bar) >= minimum-volume-ratio parameter; reference-index alignment disabled or no index configured or reference-index EMA fast < EMA mid on T2 last completed bar; bearish chart trend; RSI(close, RSI lookback) < put RSI threshold parameter AND RSI(close, RSI lookback) > oversold parameter; bearish structure score >= bearish entry-score parameter; Flow < -entry-flow threshold parameter; ADX(adx lookback) > minimum-ADX parameter; session restriction disabled or chart-bar time is within the configured session in Asia/Kolkata; bar-close validation disabled or chart bar confirmed; entries since the current T3 period began < signal-cap parameter; no prior entry signal or chart bars since the prior entry signal >= cooldown parameter; position is flat
Exit: long, long position AND (ADX(adx lookback) < minimum-ADX parameter OR (close < T3-anchored VWAP AND close[1] >= current T3-anchored VWAP) OR bearish divergence OR bearish sweep OR selected-source RVOL(volume lookback, chart timeframe current/forming bar) < volume-dry-up parameter OR bullish structure score < long-exit score parameter) AND (bar-close validation disabled OR chart bar confirmed)
Exit: short, short position AND (ADX(adx lookback) < minimum-ADX parameter OR (close > T3-anchored VWAP AND close[1] <= current T3-anchored VWAP) OR bullish divergence OR bullish sweep OR selected-source RVOL(volume lookback, chart timeframe current/forming bar) < volume-dry-up parameter OR bearish structure score < short-exit score parameter) AND (bar-close validation disabled OR chart bar confirmed)
Exit: long, bullish chart trend AND ((bearish divergence AND NOT bearish divergence[1]) OR bearish sweep) AND (bar-close validation disabled OR chart bar confirmed)
Exit: short, bearish chart trend AND ((bullish divergence AND NOT bullish divergence[1]) OR bullish sweep) AND (bar-close validation disabled OR chart bar confirmed)