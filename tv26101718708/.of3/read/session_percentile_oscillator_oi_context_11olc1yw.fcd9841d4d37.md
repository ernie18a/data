Calculation: SmoothedRoc(x) = ROC(EMA(x, emaLen), rocLen)
Calculation: OIChange = open interest at close - open interest at open
Calculation: BullScore = IF(close > close[1], priceWeight, 0) + IF(SmoothedRoc(OBV) > thr, flowWeight, 0) + IF(SmoothedRoc(volume delta) > thr, flowWeight, 0)
Calculation: BearScore = IF(close < close[1], priceWeight, 0) + IF(SmoothedRoc(OBV) < -thr, flowWeight, 0) + IF(SmoothedRoc(volume delta) < -thr, flowWeight, 0)
Calculation: SessionPct = IF(the session window containing the current bar has a completed past session on an enabled trading-day weekday, 100 * count(those past sessions whose range / ATR at their trading-day rollover <= current range / ATR) / count(those past sessions), missing), where range = highest high - lowest low over that window's bars from its start through the current bar, ATR = ATR(atrLen, T1, last completed bar), and trading day = New York time shifted forward by dayShift hours
Calculation: SmoothedPct = K(SessionPct, L), where K is SMA, EMA, RMA, or RQ, and RQ(x, L) = sum over i=0..L of w_i * x[i] / sum over i=0..L of w_i with missing x[i] taken as 0, w_i = (1 + i^2 / (2 * L^2 * r))^(-r), r = relative weight
Long: close < Lowest(close[1], N) AND SmoothedPct > Lowest(SmoothedPct[1], N)
Short: close > Highest(close[1], N) AND SmoothedPct < Highest(SmoothedPct[1], N)
Long: (OIChange > 0 AND (BullScore > BearScore OR (BullScore = BearScore AND NOT (override-on AND close < close[1])))) OR (OIChange = 0 AND Long[1])
Short: (OIChange > 0 AND (BearScore > BullScore OR (BearScore = BullScore AND override-on AND close < close[1]))) OR (OIChange = 0 AND Short[1])
Exit: short, (OIChange < 0 AND (BullScore > BearScore OR (BullScore = BearScore AND override-on AND close > close[1]))) OR (OIChange = 0 AND Exit short[1])
Exit: long, (OIChange < 0 AND (BearScore > BullScore OR (BearScore = BullScore AND NOT (override-on AND close > close[1])))) OR (OIChange = 0 AND Exit long[1])