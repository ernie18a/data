Calculation: Chart-timeframe scale = min(configured chart-timeframe minutes / timeframe-scaling interval, maximum chart scale)
Calculation: Trend lookback = round(base trend lookback * chart-timeframe scale)
Calculation: Whale sustain lookback = round(base whale-sustain lookback * min(chart-timeframe scale, whale-sustain scaling cap))
Calculation: Smoothed breakout direction = SMA(raw breakout direction, min(chart-timeframe scale, direction-smoothing cap)), where raw breakout direction is 1 when close > highest(high, trend lookback) on the previous bar, -1 when close < lowest(low, trend lookback) on the previous bar, and 0 otherwise
Calculation: Trend confirmation = 1 when smoothed breakout direction > 0 AND change(close, price-momentum lookback) > 0 AND change(EMA(close, EMA lookback), EMA-slope lookback) > 0; -1 when all three are < 0; otherwise 0
Calculation: Sampled price-volume sum = HLC3 * volume + (bars since first bar >= VWAP interval ? sampled price-volume sum[VWAP interval] : 0)
Calculation: Sampled volume sum = volume + (bars since first bar >= VWAP interval ? sampled volume sum[VWAP interval] : 0)
Calculation: Sampled cumulative VWAP = sampled price-volume sum / sampled volume sum when sampled volume sum != 0, otherwise HLC3
Calculation: Whale volume = volume > SMA(volume, volume-MA lookback) * whale-volume multiplier * (ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR-average lookback)) * (chart-timeframe scale > upper whale-scale cutoff ? upper whale-scale factor : chart-timeframe scale > lower whale-scale cutoff ? lower whale-scale factor : base whale-scale factor)
Calculation: Sustained whale volume = bars since whale volume was false <= whale-sustain lookback
Calculation: Upward VWA = whale volume AND sustained whale volume AND close > sampled cumulative VWAP AND change(close, one-bar lookback) > 0 AND volume > SMA(volume, VWA volume-confirmation lookback) * VWA volume-confirmation multiplier
Calculation: Downward VWA = whale volume AND sustained whale volume AND close < sampled cumulative VWAP AND change(close, one-bar lookback) < 0 AND volume > SMA(volume, VWA volume-confirmation lookback) * VWA volume-confirmation multiplier
Calculation: Volatility filter = ATR(ATR lookback) < SMA(ATR(ATR lookback), ATR-average lookback) * upper volatility ratio AND ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback) * lower volatility ratio AND change(ATR(ATR lookback), one-bar lookback) < SMA(ATR(ATR lookback), ATR-average lookback) * ATR-change limit
Calculation: Pullback depth = (highest(high, pullback lookback) - lowest(low, pullback lookback)) / ATR(ATR lookback)
Calculation: Score = (ADX(ADX lookback) > ADX threshold OR ADX(ADX lookback) > secondary ADX threshold ? trend-strength score weight : 0) + (volume > SMA(volume, volume-MA lookback) * volume-spike multiplier ? volume-spike score weight : 0) + (whale volume ? whale-volume score weight : 0) + ((RSI(close, RSI lookback) > RSI midpoint AND RSI(close, RSI lookback) < RSI overbought) OR (RSI(close, RSI lookback) <= RSI midpoint AND RSI(close, RSI lookback) > RSI oversold) ? RSI score weight : 0) + ((smoothed breakout direction > 0 AND close > EMA(close, EMA lookback)) OR (smoothed breakout direction < 0 AND close < EMA(close, EMA lookback)) ? trend-alignment score weight : 0) + (upward VWA ? positive VWA score weight : downward VWA ? -negative VWA score weight : 0) + (sustained whale volume ? sustained-whale score weight : 0)
Calculation: Score threshold = chart-timeframe scale <= score-scale cutoff ? low-scale score threshold : other-scale score threshold
Calculation: Breakout up = close crosses above EMA(close, EMA lookback) OR (upward VWA AND close > EMA(close, EMA lookback) on the previous bar)
Calculation: Breakout down = close crosses below EMA(close, EMA lookback) OR (downward VWA AND close < EMA(close, EMA lookback) on the previous bar)
Calculation: Bullish pullback = lowest(low, pullback lookback) < EMA(close, EMA lookback) AND close > EMA(close, EMA lookback) AND RSI(close, RSI lookback) > bullish pullback RSI lower bound AND RSI(close, RSI lookback) < bullish pullback RSI upper bound AND pullback depth > pullback ATR threshold AND close > sampled cumulative VWAP AND volume > SMA(volume, volume-MA lookback) AND trend confirmation > 0
Calculation: Bearish pullback = highest(high, pullback lookback) > EMA(close, EMA lookback) AND close < EMA(close, EMA lookback) AND RSI(close, RSI lookback) < bearish pullback RSI upper bound AND RSI(close, RSI lookback) > bearish pullback RSI lower bound AND pullback depth > pullback ATR threshold AND close < sampled cumulative VWAP AND volume > SMA(volume, volume-MA lookback) AND trend confirmation < 0
Calculation: Long signal = (breakout up OR bullish pullback) AND score >= score threshold AND volatility filter
Calculation: Short signal = (breakout down OR bearish pullback) AND score >= score threshold AND volatility filter
Calculation: Long take-profit target = highest(high, stop-target lookback) + ATR(ATR lookback) * take-profit ATR multiplier, set at each long signal
Calculation: Short take-profit target = lowest(low, stop-target lookback) - ATR(ATR lookback) * take-profit ATR multiplier, set at each short signal
Calculation: Long trailing stop = at each long signal, lowest(low, stop-target lookback) - ATR(ATR lookback) * stop-loss ATR multiplier; while long, max(previous long trailing stop, close - ATR(ATR lookback) * stop-loss ATR multiplier * max(1, ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR-average lookback)))
Calculation: Short trailing stop = at each short signal, highest(high, stop-target lookback) + ATR(ATR lookback) * stop-loss ATR multiplier; while short, min(previous short trailing stop, close + ATR(ATR lookback) * stop-loss ATR multiplier * max(1, ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR-average lookback)))
Long: breakout up OR bullish pullback
Long: long signal
Long: long signal AND position side is not long
Short: breakout down OR bearish pullback
Short: short signal
Short: short signal AND position side is not short
Exit: long, close < long entry price * (1 - maximum loss fraction) OR close >= long take-profit target OR close <= long trailing stop OR trend confirmation < 0
Exit: short, close > short entry price * (1 + maximum loss fraction) OR close <= short take-profit target OR close >= short trailing stop OR trend confirmation > 0