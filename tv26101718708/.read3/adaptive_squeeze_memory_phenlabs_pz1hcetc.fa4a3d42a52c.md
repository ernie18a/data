Calculation: Squeeze = BollingerBandWidth(close, BB lookback, BB multiplier) < KeltnerChannelWidth(hlc3, KC lookback, ATR lookback, KC multiplier)
Calculation: SqueezeFire = Squeeze AND NOT Squeeze[1]
Calculation: Ready = bars elapsed > MAX(BB lookback, KC lookback, ATR lookback, RSI lookback, volume MA lookback) + warmup bars
Calculation: Feature(bar) = (ATR(ATR lookback) / |close|, RSI(close, RSI lookback) / 100, volume / SMA(volume, volume MA lookback)) at the bar
Calculation: ForwardReturn(bar) = 100 * (close of the bar forward horizon bars later / close of the bar - 1)
Calculation: Matches = the match count nearest bars by Euclidean distance between Feature(bar) and Feature(current bar), among bars at least forward horizon bars before the current bar where SqueezeFire AND Ready
Calculation: MedianEdge = nearest-rank median of ForwardReturn over Matches
Calculation: BullShare = 100 * count of Matches with ForwardReturn > 0 / count of Matches
Calculation: StrongBull = MedianEdge > median edge threshold AND BullShare >= probability threshold
Calculation: StrongBear = MedianEdge < -median edge threshold AND BullShare <= 100 - probability threshold
Calculation: LeanLong = NOT StrongBull AND (MedianEdge > 0 OR BullShare >= probability threshold) AND NOT StrongBear
Long: SqueezeFire AND Ready AND count of Matches >= minimum matches AND StrongBull
Long: SqueezeFire AND Ready AND count of Matches >= minimum matches AND LeanLong
Long: SqueezeFire AND Ready AND count of Matches >= minimum matches AND MedianEdge >= 0
Short: SqueezeFire AND Ready AND count of Matches >= minimum matches AND StrongBear
Short: SqueezeFire AND Ready AND count of Matches >= minimum matches AND NOT StrongBear AND (MedianEdge < 0 OR BullShare <= 100 - probability threshold) AND NOT StrongBull AND NOT LeanLong
Short: SqueezeFire AND Ready AND count of Matches >= minimum matches AND MedianEdge < 0