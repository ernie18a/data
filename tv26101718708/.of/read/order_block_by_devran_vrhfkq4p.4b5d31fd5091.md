Calculation: ATR = Average True Range on the chart timeframe
Calculation: RangeNorm(bar) = (R - lowest R over a long lookback) / (highest R - lowest R over the same lookback) * 100, where R = high - low of that bar
Calculation: SwingLow/SwingHigh = most recent confirmed pivot low/pivot high (extreme over equal short numbers of bars on both sides, known only after the right-side bars complete)
Calculation: SweepLow(bar) = low < latest pivot low AND close > that pivot low; SweepHigh(bar) = high > latest pivot high AND close < that pivot high (for scoring, a pivot of any of several sizes counts)
Calculation: BullMSS(bar) = within a few bars after a bar with low < SwingLow AND close > SwingLow (that bar included), close > the SwingHigh that was latest on that sweep bar AND (close - open) > ATR * k
Calculation: BearMSS(bar) = within a few bars after a bar with high > SwingHigh AND close < SwingHigh (that bar included), close < the SwingLow that was latest on that sweep bar AND (open - close) > ATR * k
Calculation: HTFBias = sign of (fast EMA(close) - slow EMA(close)) on a higher timeframe, using the still-forming higher-timeframe bar
Calculation: BullScore = base + weighted sum of flags: SweepLow within recent bars (heavy); (close - open) > 1.5 * ATR * k (heavy); BullMSS within recent bars, longer window than the sweep window (heavy); high[2] < low (medium); HTFBias > 0 (medium); RangeNorm(previous bar) >= a higher percentile than the OB volume filter (light). BearScore is the mirror: SweepHigh; (open - close) > 1.5 * ATR * k; BearMSS; low[2] > high; HTFBias < 0; same light flag.
Calculation: BullOB(bar) = previous bar bearish (close < open) AND (open[1] - close[1]) > ATR * m (m < k) AND current bar bullish with (close - open) > ATR * k AND RangeNorm(previous bar) >= minimum percentile AND BullScore >= minimum score
Calculation: BearOB(bar) = previous bar bullish AND (close[1] - open[1]) > ATR * m (m < k) AND current bar bearish with (open - close) > ATR * k AND RangeNorm(previous bar) >= minimum percentile AND BearScore >= minimum score
Long: BullMSS OR BullOB, evaluated on a completed bar
Short: BearMSS OR BearOB, evaluated on a completed bar