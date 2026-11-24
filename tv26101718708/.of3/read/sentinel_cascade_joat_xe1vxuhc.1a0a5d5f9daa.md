Calculation: Range basis = (highest(high, range lookback) + lowest(low, range lookback)) / 2
Calculation: Adaptive ATR = ATR(ATR lookback) initially; thereafter previous Adaptive ATR + smoothing constant × (ATR(ATR lookback) − previous Adaptive ATR), where smoothing constant = (ER × (2 / (fast smoothing lookback + 1) − 2 / (slow smoothing lookback + 1)) + 2 / (slow smoothing lookback + 1))², and ER = 0 if sum(abs(close − close[1]), ER lookback) is zero, otherwise abs(close − close[ER lookback]) / sum(abs(close − close[1]), ER lookback)
Calculation: Volume Z-score = (volume − SMA(volume, volume lookback)) / max(STDEV(volume, volume lookback), volume standard-deviation floor)
Calculation: R/S(n) = (maximum − minimum of cumulative sums of log(close / close[1]) − SMA(log(close / close[1]), n) over n bars) / STDEV(log(close / close[1]), n)
Calculation: Hurst = Hurst midpoint if either R/S value is unavailable or nonpositive; otherwise clamp(ln(R/S(long Hurst lookback) / R/S(short Hurst lookback)) / ln(long Hurst lookback / short Hurst lookback), Hurst lower bound, Hurst upper bound)
Calculation: Stage 1 = Supertrend(Stage 1 factor, Adaptive ATR, Range basis)
Calculation: Stage 2 = Supertrend(Stage 2 factor × clamp(volume modifier baseline + volume modifier sensitivity × Volume Z-score, volume modifier floor, volume modifier ceiling), Adaptive ATR, Stage 1 line)
Calculation: Stage 3 = Supertrend(Stage 3 factor × clamp(Hurst modifier baseline + Hurst modifier sensitivity × (Hurst − Hurst center), Hurst modifier floor, Hurst modifier ceiling), Adaptive ATR, Stage 2 line)
Long: Stage 1 direction is bullish
Short: Stage 1 direction is bearish
Long: Stage 2 direction is bullish
Short: Stage 2 direction is bearish
Long: Stage 3 direction is bullish
Short: Stage 3 direction is bearish
Long: Stage 3 changes to bullish on a confirmed chart bar
Short: Stage 3 changes to bearish on a confirmed chart bar
Long: Stage 3 changes to bullish on a confirmed chart bar AND Stage 2 direction is bullish on the current or one of the preceding Sentinel confirmation-window chart bars
Short: Stage 3 changes to bearish on a confirmed chart bar AND Stage 2 direction is bearish on the current or one of the preceding Sentinel confirmation-window chart bars
Long: Stage 3 is bullish AND open < Stage 2 line AND close > Stage 2 line AND this condition was false on the preceding chart bar, on a confirmed chart bar
Short: Stage 3 is bearish AND open > Stage 2 line AND close < Stage 2 line AND this condition was false on the preceding chart bar, on a confirmed chart bar
Long: Stage 1, Stage 2, and Stage 3 directions are all bullish
Short: Stage 1, Stage 2, and Stage 3 directions are all bearish
Long: Stage 1, Stage 2, and Stage 3 directions change to all bullish on a confirmed chart bar
Short: Stage 1, Stage 2, and Stage 3 directions change to all bearish on a confirmed chart bar