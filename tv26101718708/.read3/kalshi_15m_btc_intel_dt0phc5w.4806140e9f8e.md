Calculation: Data ready = available T1 close count >= minimum-history parameter
Calculation: Window move (%) = 100 * (latest T1 close - close from (window-length parameter - 1) T1 bars ago) / that earlier close, recalculated on each chart bar using the latest available T1 close, including the forming T1 bar in real time
Calculation: EMA separation (%) = 100 * (EMA(close, shorter EMA lookback, T1) - EMA(close, longer EMA lookback, T1)) / EMA(close, longer EMA lookback, T1), evaluated on chart bars using available T1 closes, including the forming T1 bar in real time
Calculation: Volume ratio = volume summed over the latest window-length parameter T1 bars / average volume summed over each available preceding nonoverlapping block of that length, up to the baseline-block-count parameter; zero if no positive baseline, evaluated on chart bars with the current forming T1 bar included
Calculation: Sampled T2 closes = T1 closes sampled every sampling-stride parameter bars, with the sample offset chosen to include the latest available T1 close; recomputed on each chart bar, including the forming T1 close in real time
Calculation: Return momentum = EMA(100 * (T1 close - prior T1 close) / prior T1 close, momentum EMA lookback), evaluated on chart bars using available T1 closes, including the forming T1 bar in real time
Calculation: Momentum acceleration = current return momentum - return momentum from acceleration-lag parameter T1 bars ago, or zero if unavailable
Calculation: Tick net = sum over the latest tick-count parameter T1 close changes of +1 when close rises, -1 when it falls, and 0 when unchanged
Calculation: EMA vote = +1 when EMA separation > EMA separation deadband parameter, -1 when EMA separation < negative EMA separation deadband parameter, otherwise 0
Calculation: RSI vote = +1 when RSI(sampled T2 closes, RSI lookback parameter), evaluated on chart bars using the current, possibly forming T2 sample, >= bullish RSI threshold parameter; -1 when it <= bearish RSI threshold parameter; otherwise 0, including when unavailable
Calculation: Volume vote = sign of window move when volume ratio >= volume-surge threshold parameter and the preceding volume baseline is positive; otherwise 0
Calculation: Window vote = +1 when window move > window-move deadband parameter, -1 when it < negative window-move deadband parameter, otherwise 0
Calculation: Return-momentum vote = +1 when return momentum > momentum deadband parameter, -1 when it < negative momentum deadband parameter, otherwise 0
Calculation: Acceleration vote = +1 when momentum acceleration > acceleration deadband parameter, -1 when it < negative acceleration deadband parameter, otherwise 0
Calculation: Tick vote = +1 when tick net >= tick-direction threshold parameter, -1 when it <= negative tick-direction threshold parameter, otherwise 0
Calculation: Bull vote count = count of positive votes among EMA, RSI, volume, window, return-momentum, acceleration, and tick votes
Calculation: Bear vote count = count of negative votes among EMA, RSI, volume, window, return-momentum, acceleration, and tick votes
Long: Data ready AND EMA(close, shorter EMA lookback, T1) > EMA(close, longer EMA lookback, T1)
Short: Data ready AND EMA(close, shorter EMA lookback, T1) <= EMA(close, longer EMA lookback, T1)
Long: Data ready AND EMA vote > 0
Short: Data ready AND EMA vote < 0
Long: Data ready AND RSI vote > 0
Short: Data ready AND RSI vote < 0
Long: Data ready AND volume vote > 0
Short: Data ready AND volume vote < 0
Long: Data ready AND window vote > 0
Short: Data ready AND window vote < 0
Long: Data ready AND return-momentum vote > 0
Short: Data ready AND return-momentum vote < 0
Long: Data ready AND acceleration vote > 0
Short: Data ready AND acceleration vote < 0
Long: Data ready AND tick vote > 0
Short: Data ready AND tick vote < 0
Long: Data ready AND bull vote count > bear vote count
Short: Data ready AND bear vote count > bull vote count
Long: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are >= 0 AND at least one of those votes is > 0 AND bull vote count > bear vote count
Short: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are <= 0 AND at least one of those votes is < 0 AND bear vote count > bull vote count
Long: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are >= 0 AND at least one of those votes is > 0 AND bull vote count > bear vote count AND the previous chart bar was ready and classified as neither WARMUP nor UPTREND
Short: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are <= 0 AND at least one of those votes is < 0 AND bear vote count > bull vote count AND the previous chart bar was ready and classified as neither WARMUP nor DOWNTREND
Long: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are >= 0 AND at least one of those votes is > 0 AND bull vote count > bear vote count AND bull vote count >= high-confidence threshold parameter
Short: Data ready AND abs(window move) >= strong-trend threshold parameter AND EMA separation * window move > 0 AND all of RSI, return-momentum, acceleration, and tick votes are <= 0 AND at least one of those votes is < 0 AND bear vote count > bull vote count AND bear vote count >= high-confidence threshold parameter