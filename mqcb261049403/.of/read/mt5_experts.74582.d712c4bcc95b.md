Indexing: bar[1] = last completed bar, bar[2] = the one before it, bar[3] = the one before that; bar[i+k] is k bars older than bar[i]. Decisions are evaluated once per new bar, using completed bars only, and orders are filled at the new bar's open. N = base lookback; M = z-score lookback, longer than N.
Calculation: ED[i] = population standard deviation of close over the N bars ending at bar[i]
Calculation: VQ[i] = (close[i] - close[i+N]) / (sum over j=0..N-1 of |close[i+j] - close[i+j+1]| + tiny epsilon)
Calculation: KD[i] = close[i] - mean of close over the N bars ending at bar[i]
Calculation: PV[i] = close[i] - close[i+N]
Calculation: Z(x)[i] = (x[i] - mean of x over the M bars ending at bar[i]) / population std of x over the same M bars; 0 if std is 0
Calculation: KCI[i] = sum of |a - b| over all 6 pairs (a,b) drawn from {Z(VQ)[i], Z(KD)[i], Z(ED)[i], Z(PV)[i]}
Calculation: Energy[i] = volume[i] * (close[i] - close[i+1])^2
Calculation: WPR[i] = Williams %R on the chart timeframe at bar[i]
Calculation: TrendMA = EMA of close on a higher timeframe than the chart, taken from its last completed bar (used only if the optional trend filter is enabled)
Long: position is flat AND KCI[2] < KCI[1] AND KCI[2] < KCI[3] AND KCI[2] <= compression threshold AND Energy[2] < Energy[1] AND close[2] < close[3] AND WPR[1] <= oversold level AND ED[1] != 0 AND (optional trend filter) open of the new bar >= TrendMA
Short: position is flat AND KCI[2] < KCI[1] AND KCI[2] < KCI[3] AND KCI[2] <= compression threshold AND Energy[2] < Energy[1] AND close[2] >= close[3] AND WPR[1] >= overbought level (overbought level is higher than oversold level) AND ED[1] != 0 AND (optional trend filter) open of the new bar <= TrendMA
Exit: long, low <= entry price - k_sl * ED_entry OR high >= entry price + k_tp * ED_entry (ED_entry = ED[1] at the entry decision; k_tp > k_sl)
Exit: short, high >= entry price + k_sl * ED_entry OR low <= entry price - k_tp * ED_entry (ED_entry = ED[1] at the entry decision; k_tp > k_sl)
Exit: long, price <= trailing stop; the trailing stop is inactive until price - entry price > trail distance; once active, whenever current stop < price - (trail distance + trail step), set stop = price - trail distance; the stop only ratchets up
Exit: short, price >= trailing stop; the trailing stop is inactive until entry price - price > trail distance; once active, whenever current stop > price + (trail distance + trail step), set stop = price + trail distance; the stop only ratchets down