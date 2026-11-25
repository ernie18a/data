Calculation: Strong signal state starts flat; on each bar, set it to long if LongScore reaches its strong threshold and the prior state is flat or short, then set it to short if ShortScore reaches its strong threshold and the updated state is flat or long; otherwise retain the state
Calculation: LongScore = sum of the separate long-importance parameters for the true weighted long component conditions below
Calculation: ShortScore = sum of the separate short-importance parameters for the true weighted short component conditions below
Calculation: Quick resistance = close at the latest quick pivot high of close, using support pivot-left and quick pivot-right parameters
Calculation: Quick support = close at the latest quick pivot low of close, using support pivot-left and quick pivot-right parameters
Calculation: Resistance 1, 2, and 3 = close at the latest, previous, and second-previous pivot highs of close, using support pivot-left and standard pivot-right parameters
Calculation: Support 1, 2, and 3 = close at the latest, previous, and second-previous pivot lows of close, using support pivot-left and standard pivot-right parameters
Calculation: Support/resistance cross up = HMA(close, support-cross HMA lookback) > any of the eight support/resistance levels AND its prior value < that level's prior value AND close > close[2]
Calculation: Support/resistance cross down = HMA(close, support-cross HMA lookback) < any of the eight support/resistance levels AND its prior value > that level's prior value AND close < close[2]
Calculation: Regular bullish divergence(oscillator, price low, pivot-left, pivot-right, minimum gap, maximum gap) = current pivot low found AND oscillator[pivot-right] > oscillator value at the prior pivot low AND price low[pivot-right] < price low at the prior pivot low AND the prior pivot gap is within the gap parameters
Calculation: Regular bearish divergence(oscillator, price high, pivot-left, pivot-right, minimum gap, maximum gap) = current pivot high found AND oscillator[pivot-right] < oscillator value at the prior pivot high AND price high[pivot-right] > price high at the prior pivot high AND the prior pivot gap is within the gap parameters
Calculation: CCI candle adjustment = positive offset when open > close and open - close exceeds the body threshold; negative offset when close > open and close - open exceeds the body threshold; otherwise zero
Calculation: CCI candle filter = CCI candle adjustment is zero OR CCI(close, CCI lookback) + CCI candle adjustment is zero
Calculation: Selected downtrend filter = true for the no-filter selection, close < SMA(close, first trend lookback) for the single-average selection, or close < SMA(close, first trend lookback) AND SMA(close, first trend lookback) < SMA(close, second trend lookback) for the dual-average selection
Calculation: Selected uptrend filter = true for the no-filter selection, close > SMA(close, first trend lookback) for the single-average selection, or close > SMA(close, first trend lookback) AND SMA(close, first trend lookback) > SMA(close, second trend lookback) for the dual-average selection
Calculation: Engulfing body average = EMA(abs(close - open), body-average lookback)
Calculation: Bullish engulfing pattern = Selected downtrend filter AND open < close AND abs(close - open) > Engulfing body average AND open[1] > close[1] AND abs(close[1] - open[1]) < Engulfing body average[1] AND close >= open[1] AND open <= close[1] AND (close > open[1] OR open < close[1])
Calculation: Bearish engulfing pattern = Selected uptrend filter AND open > close AND abs(close - open) > Engulfing body average AND open[1] < close[1] AND abs(close[1] - open[1]) < Engulfing body average[1] AND close <= open[1] AND open >= close[1] AND (close < open[1] OR open > close[1])
Calculation: Long setup = (CCI(close, CCI trigger lookback) crosses above EMA(CCI(close, CCI trigger lookback), CCI signal lookback) AND CCI(close[1], CCI trigger lookback) < negative CCI cutoff AND CCI candle filter AND bars since HalfTrend up reversal > 0 AND bars since HalfTrend up reversal < bars since HalfTrend down reversal) OR (RSI(close, setup RSI lookback) + RSI-average margin > EMA(RSI(close, setup RSI lookback), setup RSI-average lookback)) OR (RSI(close[1], short RSI lookback) < lower prior-RSI threshold AND CCI(close, CCI trigger lookback) crosses above EMA(CCI(close, CCI trigger lookback), CCI signal lookback) AND CCI(close[1], CCI trigger lookback) < negative CCI cutoff AND CCI candle filter)
Calculation: Short setup = (CCI(close, CCI trigger lookback) crosses below EMA(CCI(close, CCI trigger lookback), CCI signal lookback) AND CCI(close[1], CCI trigger lookback) > positive CCI cutoff AND CCI candle filter AND bars since HalfTrend down reversal > 0 AND bars since HalfTrend down reversal < bars since HalfTrend up reversal AND RSI(close, setup RSI lookback) - RSI-average margin < EMA(RSI(close, setup RSI lookback), setup RSI-average lookback)) OR (RSI(close[1], short RSI lookback) > upper prior-RSI threshold AND CCI(close, CCI trigger lookback) crosses below EMA(CCI(close, CCI trigger lookback), CCI signal lookback) AND CCI(close[1], CCI trigger lookback) > short prior-CCI cutoff AND CCI candle filter)
Long: long EMA-direction importance > 0 AND close > EMA(close, long EMA-direction lookback)
Short: short EMA-direction importance > 0 AND close < EMA(close, long EMA-direction lookback)
Long: long EMA-pressure importance > 0 AND EMA(close, shorter pressure lookback) > its prior value AND EMA(close, longer pressure lookback) < its prior value
Short: short EMA-pressure importance > 0 AND EMA(close, shorter pressure lookback) < its prior value AND EMA(close, longer pressure lookback) > its prior value
Long: long Supertrend-direction importance > 0 AND Supertrend direction < 0
Short: short Supertrend-direction importance > 0 AND Supertrend direction > 0
Long: long Supertrend-reversal importance > 0 AND Supertrend direction < 0 AND its prior value > 0
Short: short Supertrend-reversal importance > 0 AND Supertrend direction > 0 AND its prior value < 0
Long: long Parabolic SAR-direction importance > 0 AND Parabolic SAR < close
Short: short Parabolic SAR-direction importance > 0 AND Parabolic SAR > close
Long: long Parabolic SAR-reversal importance > 0 AND Parabolic SAR < close AND Parabolic SAR[1] > close[1]
Short: short Parabolic SAR-reversal importance > 0 AND Parabolic SAR > close AND Parabolic SAR[1] < close
Long: long HMA-position importance > 0 AND HMA(close, HMA trend lookback) < close AND its prior value is nonzero
Short: short HMA-position importance > 0 AND HMA(close, HMA trend lookback) > close
Long: long HMA-pivot importance > 0 AND HMA(close, HMA trend lookback) > its prior value AND its prior value < its value two bars ago
Short: short HMA-pivot importance > 0 AND HMA(close, HMA trend lookback) < its prior value AND its prior value > its value two bars ago
Long: long RSI-divergence importance > 0 AND (regular bullish divergence(RSI(close, RSI divergence lookback), low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap) or that condition within the divergence recency lookback)
Short: short RSI-divergence importance > 0 AND (regular bearish divergence(RSI(close, RSI divergence lookback), high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap) or that condition within the divergence recency lookback)
Long: long RSI-level importance > 0 AND RSI(close, RSI level lookback) < RSI lower-level parameter
Short: short RSI-level importance > 0 AND RSI(close, RSI level lookback) > RSI upper-level parameter
Long: long RSI-cross importance > 0 AND RSI(close, RSI direction lookback) > RSI midline parameter AND (RSI[1] < RSI midline parameter OR RSI[2] < RSI midline parameter)
Short: short RSI-cross importance > 0 AND RSI(close, RSI direction lookback) < RSI midline parameter AND (RSI[1] > RSI midline parameter OR RSI[2] > RSI midline parameter)
Long: long MACD-divergence importance > 0 AND regular bullish divergence(MACD(close, fast lookback, slow lookback, signal lookback), low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap) AND MACD at the pivot < 0 AND highest MACD over the MACD zero-range lookback < 0, or that condition within the divergence recency lookback
Short: short MACD-divergence importance > 0 AND regular bearish divergence(MACD(close, fast lookback, slow lookback, signal lookback), high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap) AND MACD at the pivot > 0 AND lowest MACD over the MACD zero-range lookback > 0, or that condition within the divergence recency lookback
Long: long MACD-histogram-pivot importance > 0 AND MACD histogram > its prior value AND its prior value < its value two bars ago AND MACD histogram < 0
Short: short MACD-histogram-pivot importance > 0 AND MACD histogram < its prior value AND its prior value > its value two bars ago AND MACD histogram > 0
Long: long MACD-signal-cross importance > 0 AND MACD > MACD signal AND MACD[1] < MACD signal[1] AND MACD signal < 0
Short: short MACD-signal-cross importance > 0 AND MACD < MACD signal AND MACD[1] > MACD signal[1] AND MACD signal > 0
Long: long WaveTrend-divergence importance > 0 AND regular bullish divergence(WaveTrend main line, low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Short: short WaveTrend-divergence importance > 0 AND regular bearish divergence(WaveTrend main line, high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Long: long WaveTrend-cross importance > 0 AND WaveTrend main line > WaveTrend signal line AND main line[1] < signal line[1] AND WaveTrend signal line < lower WaveTrend threshold
Short: short WaveTrend-cross importance > 0 AND WaveTrend main line < WaveTrend signal line AND main line[1] > signal line[1] AND WaveTrend signal line > upper WaveTrend threshold
Long: long stochastic-divergence importance > 0 AND regular bullish divergence(Stochastic %K, low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Short: short stochastic-divergence importance > 0 AND regular bearish divergence(Stochastic %K, high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Long: long stochastic-cross importance > 0 AND Stochastic %K > Stochastic %D AND Stochastic %K[1] < Stochastic %D[1]
Short: short stochastic-cross importance > 0 AND Stochastic %K < Stochastic %D AND Stochastic %K[1] > Stochastic %D[1]
Long: long Bollinger-contact importance > 0 AND close < lower Bollinger band(close, band lookback, band multiplier)
Short: short Bollinger-contact importance > 0 AND open > upper Bollinger band(close, band lookback, band multiplier)
Long: long ATR-reversal importance > 0 AND ATR trend-stop direction reverses from short to long using its ATR lookback and multiplier
Short: short ATR-reversal importance > 0 AND ATR trend-stop direction reverses from long to short using its ATR lookback and multiplier
Long: long RVI-position importance > 0 AND RVI(close, RVI lookback, RVI smoothing) > lower RVI threshold AND its prior value < lower prior-RVI threshold
Short: short RVI-position importance > 0 AND RVI(close, RVI lookback, RVI smoothing) < upper RVI threshold AND its prior value > upper prior-RVI threshold
Long: long RVI-divergence importance > 0 AND regular bullish divergence(RVI(close, RVI lookback, RVI smoothing), low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Short: short RVI-divergence importance > 0 AND regular bearish divergence(RVI(close, RVI lookback, RVI smoothing), high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Long: long support/resistance-cross importance > 0 AND Support/resistance cross up
Short: short support/resistance-cross importance > 0 AND Support/resistance cross down
Long: long OBV-divergence importance > 0 AND regular bullish divergence(OBV(close, volume) - EMA(OBV(close, volume), OBV oscillator lookback), low, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Short: short OBV-divergence importance > 0 AND regular bearish divergence(OBV(close, volume) - EMA(OBV(close, volume), OBV oscillator lookback), high, divergence pivot-left, divergence pivot-right, divergence minimum gap, divergence maximum gap), or that condition within the divergence recency lookback
Long: long CMF-cross importance > 0 AND CMF(high, low, close, volume, CMF lookback) > 0 AND its prior value < 0
Short: short CMF-cross importance > 0 AND CMF(high, low, close, volume, CMF lookback) < 0 AND its prior value > 0
Long: long CMF-level importance > 0 AND CMF(high, low, close, volume, CMF lookback) > 0
Short: short CMF-level importance > 0 AND CMF(high, low, close, volume, CMF lookback) < 0
Long: long VWAP/HMA-cross importance > 0 AND HMA(close, HMA trend lookback) < session VWAP(hlc3) AND HMA[1] > session VWAP[1]
Short: short VWAP/HMA-cross importance > 0 AND HMA(close, HMA trend lookback) > session VWAP(hlc3) AND HMA[1] < session VWAP[1]
Long: long VWAP-trend importance > 0 AND EMA(close, shorter pressure lookback) > session VWAP(hlc3)
Short: short VWAP-trend importance > 0 AND EMA(close, shorter pressure lookback) < session VWAP(hlc3)
Long: long engulfing importance > 0 AND Bullish engulfing pattern
Short: short engulfing importance > 0 AND Bearish engulfing pattern
Long: HMA line-color condition, close > HMA(close, HMA trend lookback)
Short: HMA line-color condition, close <= HMA(close, HMA trend lookback)
Long: EMA line-color condition, EMA(close, EMA line lookback) > its prior value, for each plotted EMA
Short: EMA line-color condition, EMA(close, EMA line lookback) <= its prior value, for each plotted EMA
Long: LongScore >= weak-long threshold
Short: ShortScore >= weak-short threshold
Long: (alternating-signals parameter enabled AND strong signal state changes to long OR alternating-signals parameter disabled AND LongScore >= strong-long threshold) AND (trend-only parameter disabled OR EMA(close, trend-filter lookback) > its prior value)
Short: (alternating-signals parameter enabled AND strong signal state changes to short OR alternating-signals parameter disabled AND ShortScore >= strong-short threshold) AND (trend-only parameter disabled OR EMA(close, trend-filter lookback) < its prior value)
Long: selected K or D of SMA-smoothed Stochastic(CCI(close, CCI lookback), Stochastic lookback, K smoothing, D smoothing) < CCI oversold parameter
Short: selected K or D of SMA-smoothed Stochastic(CCI(close, CCI lookback), Stochastic lookback, K smoothing, D smoothing) > CCI overbought parameter
Long: Long setup AND NOT (ShortScore >= weak-short threshold AND EMA-smoothed StochasticRSI(close, exit RSI lookback, exit stochastic lookback, K smoothing, D smoothing) K < D)
Short: Short setup AND NOT (LongScore >= weak-long threshold AND EMA-smoothed StochasticRSI(close, exit RSI lookback, exit stochastic lookback, K smoothing, D smoothing) K > D)
Exit: long, ShortScore >= weak-short threshold AND EMA-smoothed StochasticRSI(close, exit RSI lookback, exit stochastic lookback, K smoothing, D smoothing) K < D AND NOT Long setup
Exit: short, LongScore >= weak-long threshold AND EMA-smoothed StochasticRSI(close, exit RSI lookback, exit stochastic lookback, K smoothing, D smoothing) K > D AND NOT Short setup
Exit: long, long position AND close < entry price * (1 + stop-loss fraction) AND prior close > prior long stop price
Exit: short, short position AND close > entry price * (1 - stop-loss fraction) AND prior close < prior short stop price