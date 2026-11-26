Calculation: CVD balance = cumulative sum, starting at zero, of signed volume from T1 bars within each chart bar; signed volume = T1 volume × direction, where direction = sign(T1 close − previous T1 close), except on tick bars direction is −1 when close = bid and +1 when close = ask
Calculation: CVD delta = CVD balance − CVD balance[1] on chart bars
Calculation: CVD acceleration = CVD delta − CVD delta[1] on chart bars
Calculation: CVD retention close = selected CVD balance, CVD delta, or CVD acceleration
Calculation: CVD retention open = previous CVD retention close, or current CVD retention close on the first bar
Calculation: CVD retention wick = EMA(abs(CVD retention close − CVD retention open), wick smoothing lookback) × wick factor
Calculation: CVD retention high = max(CVD retention open, CVD retention close) + CVD retention wick
Calculation: CVD retention low = min(CVD retention open, CVD retention close) − CVD retention wick
Calculation: CVD EMA slope percentage = 100 × (EMA(CVD retention close, EMA lookback) − EMA(CVD retention close, EMA lookback)[1]) / max(abs(EMA(CVD retention close, EMA lookback)[1]), slope denominator floor)
Calculation: CVD profile value at a price row = within the active profile block, the sum of each T1 bar's signed volume divided equally among profile price rows crossed from its low through its high; update on chart bars using T1 bars, including a T1 bar still forming
Long: In signed-volume profile mode, CVD profile value at a price row is positive
Short: In signed-volume profile mode, CVD profile value at a price row is negative
Long: In buy/sell-ratio profile mode, buy volume divided by sell volume at a price row is greater than or equal to the profile balance threshold
Short: In buy/sell-ratio profile mode, buy volume divided by sell volume at a price row is less than the profile balance threshold
Long: CVD retention close < EMA(CVD retention close, EMA lookback) AND CVD retention high > CVD retention high[structure lookback] AND CVD retention low > CVD retention low[structure lookback]
Short: CVD retention close > EMA(CVD retention close, EMA lookback) AND CVD retention high < CVD retention high[structure lookback] AND CVD retention low < CVD retention low[structure lookback]
Long: CVD retention close >= EMA(CVD retention close, EMA lookback) AND (CVD retention close = EMA(CVD retention close, EMA lookback) OR CVD retention high >= CVD retention high[structure lookback] OR CVD retention low >= CVD retention low[structure lookback])
Short: CVD retention close < EMA(CVD retention close, EMA lookback) AND (CVD retention high <= CVD retention high[structure lookback] OR CVD retention low <= CVD retention low[structure lookback])
Long: CVD EMA slope percentage > slope threshold
Short: CVD EMA slope percentage < −slope threshold
Long: CVD retention close > EMA(CVD retention close, EMA lookback) AND CVD EMA slope percentage > slope threshold AND CVD retention close > CVD retention close[momentum lookback]
Short: CVD retention close < EMA(CVD retention close, EMA lookback) AND CVD EMA slope percentage < −slope threshold AND CVD retention close < CVD retention close[momentum lookback]
Long: CVD retention close > EMA(CVD retention close, EMA lookback) AND CVD EMA slope percentage <= slope threshold
Short: CVD retention close < EMA(CVD retention close, EMA lookback) AND CVD EMA slope percentage >= −slope threshold
Long: A prior confirmed price pivot low exists AND pivotlow(low, left pivot bars, right pivot bars) < prior price pivot low AND CVD retention close[right pivot bars] > CVD retention close saved at the prior confirmed price pivot low
Short: A prior confirmed price pivot high exists AND pivothigh(high, left pivot bars, right pivot bars) > prior price pivot high AND CVD retention close[right pivot bars] < CVD retention close saved at the prior confirmed price pivot high