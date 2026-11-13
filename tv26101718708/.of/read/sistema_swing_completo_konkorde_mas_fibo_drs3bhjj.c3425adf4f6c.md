Calculation: PVI = running index starting at a constant nonzero value; each bar, if volume > previous volume then PVI = previous PVI * close / previous close, else PVI = previous PVI
Calculation: NVI = same as PVI but updated only when volume < previous volume
Calculation: RetailOsc = (PVI - EMA(PVI, n)) * 100 / max(highest(EMA(PVI, n), m) - lowest(EMA(PVI, n), m), 1), with m (range lookback) longer than n (EMA length)
Calculation: WhaleOsc = same formula as RetailOsc applied to NVI, with the same n and m
Calculation: Hist = MACD histogram (MACD line - signal line) of close
Calculation: EMAfast, EMAmid, EMAslow = EMAs of close with length fast < mid < slow
Calculation: HH = highest high over a lookback; LL = lowest low over the same lookback; F236 = HH - 0.236*(HH-LL); F382 = HH - 0.382*(HH-LL); F618 = HH - 0.618*(HH-LL)
Long: on the current bar, the number of true items among [EMAfast > EMAmid AND EMAmid > EMAslow; WhaleOsc > RetailOsc OR (WhaleOsc > previous WhaleOsc AND WhaleOsc > 0); close <= F382 AND close >= F618; Hist > previous Hist] >= threshold A (a majority of the 4), AND the same count on the previous bar < threshold A
Exit: long, the number of true items among [EMAfast < EMAmid; WhaleOsc < RetailOsc OR (WhaleOsc < previous WhaleOsc AND RetailOsc > previous RetailOsc); close >= F236; Hist < previous Hist] >= threshold B (a majority of the 4), AND the same count on the previous bar < threshold B
Exit: long, close < EMAmid AND previous close >= previous EMAmid