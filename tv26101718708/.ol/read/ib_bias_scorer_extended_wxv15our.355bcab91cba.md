Calculation: Bullish structure = the latest two confirmed swing highs and latest two confirmed swing lows are both rising; bearish structure = both are falling; otherwise structure score is zero.
Calculation: EMA alignment score = positive when fast EMA > medium EMA > slow EMA, negative when fast EMA < medium EMA < slow EMA, otherwise zero; the fast EMA uses the shortest lookback and the slow EMA the longest.
Calculation: Daily-anchored VWAP slope = percent change in VWAP over a configurable lookback; rising/falling means the slope exceeds the positive/negative configurable flat threshold.
Calculation: VWAP score = +2 when close is above rising VWAP, +1 when above VWAP but not falling, −2 when below falling VWAP, −1 when below VWAP but not rising, otherwise zero.
Calculation: Higher-timeframe bias = close compared with its EMA on each of two higher timeframes, using the latest available completed bar; each timeframe uses the same EMA lookback. Agreement gives ±2, one directional and one neutral gives ±1, otherwise zero.
Calculation: RSI momentum score = +2 at or above the configurable bullish threshold, −2 at or below the configurable bearish threshold, +1 above 50, −1 below 50, otherwise zero.
Calculation: Relative-volume score has the sign of the sum of the structure, EMA, VWAP, higher-timeframe, and RSI scores; it is zero if that sum is zero.
Calculation: Liquidity score counts uncleared highs above close and lows below close among the latest completed Asia, London, and New York session highs/lows and the previous completed daily bar's high/low. Score +1 if no highs remain above and at least one low remains below; −1 if no lows remain below and at least one high remains above; otherwise score +2/+1 for a high-minus-low count of at least 3/at least 1, −2/−1 for at most −3/at most −1, and zero otherwise. Clear a high when a bar's high reaches it and a low when a bar's low reaches it.
Calculation: Composite score = the weighted sum of the seven component scores, normalized by the maximum possible weighted sum to a range of −10 to +10.
Long: latest two confirmed swing highs and latest two confirmed swing lows are both rising
Short: latest two confirmed swing highs and latest two confirmed swing lows are both falling
Long: fast EMA > medium EMA > slow EMA
Short: fast EMA < medium EMA < slow EMA
Long: close > daily-anchored VWAP
Short: close < daily-anchored VWAP
Long: both higher-timeframe closes are above their respective EMAs, or one is above and the other equals its EMA
Short: both higher-timeframe closes are below their respective EMAs, or one is below and the other equals its EMA
Long: RSI > 50
Short: RSI < 50
Long: the sum of the structure, EMA, VWAP, higher-timeframe, and RSI scores > 0
Short: the sum of the structure, EMA, VWAP, higher-timeframe, and RSI scores < 0
Long: no uncleared highs remain above close and at least one uncleared low remains below close, or the difference between uncleared highs above and lows below is positive
Short: no uncleared lows remain below close and at least one uncleared high remains above close, or the difference between uncleared highs above and lows below is negative
Long: composite score > configurable chop threshold
Short: composite score < negative configurable chop threshold