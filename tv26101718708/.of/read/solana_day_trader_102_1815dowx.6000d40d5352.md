Calculation: Williams VIX Fix = 100 × (highest close over its lookback − current low) / highest close over its lookback; filtered event = previous value was at or above its upper Bollinger band or a fraction of its rolling high, current value is below both, current low > previous low, current close > previous high, current close > close at each of two shorter lookbacks, and current close > close at a longer lookback
Calculation: Bullish fair value gap = current low − high two bars earlier > 0 and gap / current close ≥ minimum gap fraction
Calculation: VIDYA = recursively adaptive moving average of close, with adaptation rate proportional to the absolute Chande Momentum Oscillator over its lookback; bullish when close > VIDYA
Calculation: OBV slope = cumulative signed volume, where volume is positive when close ≥ open and negative otherwise; bullish when current OBV > OBV at a shorter lookback
Calculation: Signed-volume DELTA = EMA of signed volume, where volume is positive when close ≥ open and negative otherwise; bullish when EMA > 0
Calculation: TQI = average of efficiency ratio, normalized ATR-fast/ATR-slow ratio, normalized close distance above a long SMA in ATR units, and normalized rate of change; each component is clipped to [0,1]
Calculation: VOL HI = percentile rank of ATR over a rolling lookback ≥ an upper percentile cut
Calculation: VOL LO = percentile rank of ATR over a rolling lookback < a lower percentile cut
Calculation: Long confluence score = weighted sum of armed bullish EMA alignment, armed bullish VIDYA, bullish OBV slope, armed bullish signed-volume DELTA, armed bullish fair value gap when enabled for scoring, TQI above its threshold when enabled for scoring, and VOL HI, minus the weighted VOL LO term
Calculation: Lower Bollinger band = SMA(close, lookback) − multiplier × standard deviation(close, lookback)
Calculation: WVF Top = previous value of 100 × (lowest close over its lookback − current high) / lowest close over its lookback was at or below its lower Bollinger band or a fraction of its rolling low, and current value is above both
Calculation: CVI = (close − lowest low over its lookback) / (highest high over its lookback − lowest low over its lookback); CVI Top = previous CVI ≥ threshold and current CVI < threshold; CVI Bottom = previous CVI ≤ 1 − threshold and current CVI > 1 − threshold
Calculation: TQI Char-Flip = previous TQI > upper threshold and current TQI < lower threshold after the minimum trend age
Calculation: Sweep-lite long = price wicks below the nearest valid session low or lower Bollinger band by at least an ATR fraction, open or close is above that level, then within a short reclaim window close is above the level and open, with current or previous-bar volume at least a multiple of its moving average
Calculation: Sweep-lite short = price wicks above the nearest valid session high or upper Bollinger band by at least an ATR fraction, open or close is below that level, then within a short reclaim window close is below the level and open, with current or previous-bar volume at least a multiple of its moving average
Calculation: MBI bull/bear fire = momentum (close minus close at a lookback) divided by EMA of high-low range; split into positive and negative parts, sum over a short window, smooth with HMA, then fire when the dominant bias component is above its EMA-plus-standard-deviation bound and crosses below its prior value
Calculation: BBAWE rising/falling = Awesome Oscillator (fast SMA of hl2 − slow SMA of hl2) is ≥ 0 and rising / < 0 and falling
Long: Any enabled evaluation timeframe has WVF armed within its arm window, passes the WVF gate if enabled, and its long confluence score meets the BASE floor; tier is BASE below the SCALE floor, SCALE at or above that floor, and FULL at or above it when ADX is below its cap; a recent Bollinger-break anti-signal can demote tiers above BASE by one; optional TQI dead-zone exclusion, BTC-bull requirement for FULL, and SCALE suppression apply; emit on a new nonzero tier after its configured bar offset (15-minute evaluation timeframe is primary when primary-only mode is enabled)
Long: close > faster EMA and faster EMA > its value several bars earlier
Long: faster EMA crosses above Bollinger basis, close > Bollinger basis, and BBAWE rising
Long: MBI bull fire
Long: Sweep-lite long
Long: CVI Bottom
Long: close > Swing VWAP
Long: HTF fast EMA > HTF slow EMA on a higher timeframe, using its last completed bar
Long: BTC close > BTC EMA on the chart timeframe
Long: close > HTF EMA and HTF VWAP on the same timeframe, and (close − close three bars earlier) + volatility contribution makes total trend score > 0.5; volatility contributes 0.5 when ATR > its longer SMA, otherwise 0
Short: Faster EMA ≤ slower EMA and faster EMA < its value several bars earlier
Short: Faster EMA crosses below Bollinger basis, close < Bollinger basis, and BBAWE is falling
Short: MBI bear fire
Short: Sweep-lite short
Short: CVI Top
Short: close < Swing VWAP
Short: HTF fast EMA < HTF slow EMA on a higher timeframe, using its last completed bar
Short: BTC close ≤ BTC EMA on the chart timeframe
Short: close < HTF EMA and HTF VWAP on the same timeframe, and (close − close three bars earlier) + volatility contribution makes total trend score < −0.5; volatility contributes 0.5 when ATR > its longer SMA, otherwise 0
Exit: long, any enabled Bollinger-break, WVF Top, or CVI Top condition produces a new rising-edge pulse on any evaluation timeframe while an entry is active and outside the post-entry cooldown; exit fully when at least two distinct exit types pulse within the escalation window, or a pulse occurs while sell-side liquidity is near; otherwise the first distinct pulse exits half
Exit: long, TQI Char-Flip on any evaluation timeframe or chart timeframe while an entry is active
Exit: long, close ≤ lower Bollinger band