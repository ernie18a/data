Calculation: ARSI = 50 + 50*RMA(d,N)/RMA(|d|,N), where hi=highest(close,N), lo=lowest(close,N), r=hi-lo, d = r if hi>hi[1], else -r if lo<lo[1], else close-close[1]
Calculation: Signal = EMA(ARSI, M), with M of the same order as N
Calculation: HTF_EMA_A = EMA (updated every chart bar) of the series of the previous completed bar's close of a timeframe higher than the chart
Calculation: HTF_EMA_B = same as HTF_EMA_A but using a timeframe longer than the one used by HTF_EMA_A
Calculation: ATR = Wilder ATR; ATRavg = SMA(ATR) over a longer lookback than the ATR lookback
Calculation: BE = true from the first bar since entry where (long) high - entry >= b*ATR or (short) entry - low >= b*ATR, using current-bar ATR; reset false at each new entry
Calculation: Trail = at entry, entry close -/+ c*ATR (long/short); afterwards each bar long: max(Trail, close - c*ATR), short: min(Trail, close + c*ATR); c > a
Calculation: Stop0 = at entry, entry close -/+ a*ATR (long/short, ATR of the entry bar); once BE is true, Stop0 = entry*(1+f) for long or entry*(1-f) for short, f being a small fraction
Long: ARSI crosses above Signal AND close > HTF_EMA_A AND ARSI <= upper_limit AND ATR > ATRavg AND (high-low) <= k*|close-open| (k>1) AND position side is not long
Short: ARSI crosses below Signal AND close < HTF_EMA_B AND ARSI >= lower_limit (lower_limit < upper_limit) AND ATR > ATRavg AND (high-low) <= k*|close-open| AND position side is not short
Exit: long, low <= max(Stop0, Trail) OR Short condition is true (reverse)
Exit: short, high >= min(Stop0, Trail) OR Long condition is true (reverse)
Exit: long, once per position, close half when high >= entry + g*ATR (g < c)