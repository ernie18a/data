Calculation: Long environment = chart close > SMA(close, environment SMA length, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off) OR that SMA > its value slope lookback T2 bars ago.
Calculation: Short environment = SMA(close, environment SMA length, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off) > SMA(close, zone SMA length, T1 requested bar sampled on chart bars; current T1 bar in real time, latest completed T1 bar historically, lookahead off) AND the T1 SMA > chart close AND the T2 SMA is below its value T2 slope lookback bars ago AND the T1 SMA is below its value T1 slope lookback bars ago.
Long: Long environment
Short: Short environment
Long: SMA(close, environment SMA length, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off) > its value T2 slope lookback bars ago
Short: SMA(close, environment SMA length, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off) < its value T2 slope lookback bars ago
Calculation: Bullish pinbar = lower wick > candle body × pinbar wick-to-body ratio AND lower wick > upper wick AND close > open AND lower wick >= ATR(pinbar ATR lookback) × minimum pinbar wick ATR multiple.
Calculation: Bearish pinbar = upper wick > candle body × pinbar wick-to-body ratio AND upper wick > lower wick AND close < open AND upper wick >= ATR(pinbar ATR lookback) × minimum pinbar wick ATR multiple.
Calculation: Bullish engulfing = close > open AND previous close < previous open AND close >= previous open AND open <= previous close AND absolute current candle body >= ATR(pinbar ATR lookback) × bullish engulfing body ATR multiple.
Calculation: Bearish engulfing = close < open AND previous close > previous open AND close <= previous open AND open >= previous close AND absolute current candle body >= ATR(pinbar ATR lookback) × bearish engulfing body ATR multiple.
Calculation: Statistical upper-wick anomaly = upper wick average is the average of the longer Scados MA-period SMA of upper wick and the longer Scados MA-period SMA of lower wick; when standard deviation of that average over the longer Scados MA period is nonzero, (current upper wick - average) / standard deviation × wick sensitivity / wick normalization parameter > wick anomaly threshold; otherwise false.
Calculation: Statistical lower-wick anomaly = upper wick average is the average of the longer Scados MA-period SMA of upper wick and the longer Scados MA-period SMA of lower wick; when standard deviation of that average over the longer Scados MA period is nonzero, (current lower wick - average) / standard deviation × wick sensitivity / wick normalization parameter > wick anomaly threshold; otherwise false.
Long: Long environment AND Bullish pinbar
Short: Short environment AND Bearish pinbar
Long: Long environment AND Bullish engulfing
Short: Short environment AND Bearish engulfing
Calculation: Active zone bounds = on chart bars, T1 high and low are highest(high, zone lookback, T1 bars) and lowest(low, zone lookback, T1 bars), using the current T1 bar in real time and latest completed T1 bar historically with lookahead off; when environment direction changes, initialize running high and low to those T1 extrema; otherwise, in a long environment update running high to the maximum of its prior value and chart high, and in a short environment update running low to the minimum of its prior value and chart low. In a long environment use running high as zone high and T1 low as zone low; in a short environment use T1 high as zone high and running low as zone low; otherwise use T1 extrema.
Calculation: Bullish deep FVG = on T1 bars, scan from current bar back through the FVG search lookback and select the most recent gap where high at the gap offset bars ago < low of the scanned bar and the scanned-bar low <= highest(high, zone lookback) - (highest(high, zone lookback) - lowest(low, zone lookback)) × FVG midpoint fraction; its bounds are that scanned-bar low and the high at the gap offset bars ago. The result is sampled on chart bars from the current T1 bar in real time and latest completed T1 bar historically, lookahead off.
Calculation: Bearish deep FVG = on T1 bars, scan from current bar back through the FVG search lookback and select the most recent gap where low at the gap offset bars ago > high of the scanned bar and the scanned-bar high >= lowest(low, zone lookback) + (highest(high, zone lookback) - lowest(low, zone lookback)) × FVG midpoint fraction; its bounds are the low at the gap offset bars ago and that scanned-bar high. The result is sampled on chart bars from the current T1 bar in real time and latest completed T1 bar historically, lookahead off.
Calculation: Long retracement zone = long environment AND (chart bar overlaps the interval from zone high - (zone high - zone low) × upper retracement fraction to zone high - (zone high - zone low) × deeper retracement fraction OR chart bar overlaps the bullish deep FVG).
Calculation: Short retracement zone = short environment AND (chart bar overlaps the interval from zone low + (zone high - zone low) × upper retracement fraction to zone low + (zone high - zone low) × deeper retracement fraction OR chart bar overlaps the bearish deep FVG).
Calculation: Long range breakout = highest(high, range lookback)[1] - lowest(low, range lookback)[1] <= ATR(range ATR lookback) × range-width ATR multiple AND close > highest(high, range lookback)[1] AND close - highest(high, range lookback)[1] >= ATR(pinbar ATR lookback) × range-break ATR margin.
Calculation: Short range breakout = highest(high, range lookback)[1] - lowest(low, range lookback)[1] <= ATR(range ATR lookback) × range-width ATR multiple AND close < lowest(low, range lookback)[1] AND lowest(low, range lookback)[1] - close >= ATR(pinbar ATR lookback) × range-break ATR margin.
Long: Long environment AND Long range breakout
Short: Short environment AND Short range breakout
Calculation: Main bullish BOS = close > latest confirmed pivot high, where pivots use separate BOS left and right confirmation lookbacks; after a bullish BOS, set the tracked pivot-high reference to current high. Suppress this BOS when Long range breakout is true.
Calculation: Main bearish BOS = close < latest confirmed pivot low, where pivots use the BOS left and right confirmation lookbacks; after a bearish BOS, set the tracked pivot-low reference to current low. Suppress this BOS when Short range breakout is true.
Long: Long environment AND Main bullish BOS
Short: Short environment AND Main bearish BOS
Calculation: Double bottom = the latest two confirmed pivot lows, using double-pattern left and right confirmation lookbacks, are separated by at least the minimum pivot distance and differ by no more than the double-pattern tolerance percent of current close; use a confirmed pivot high between the two lows as neckline when available, otherwise the highest high after the second low is confirmed; close > neckline; trigger once per pair of lows.
Calculation: Double top = the latest two confirmed pivot highs, using the double-pattern left and right confirmation lookbacks, are separated by at least the minimum pivot distance and differ by no more than the double-pattern tolerance percent of current close; use a confirmed pivot low between the two highs as neckline when available, otherwise the lowest low after the second high is confirmed; close < neckline; trigger once per pair of highs.
Long: Long environment AND Double bottom
Short: Short environment AND Double top
Long: Long environment AND EMA(close, shorter crossover lookback) crosses above EMA(close, longer crossover lookback)
Short: Short environment AND EMA(close, shorter crossover lookback) crosses below EMA(close, longer crossover lookback)
Calculation: Bullish Stochastic RSI reversal = Stochastic RSI %K(close, Stochastic RSI length, stochastic lookback, K smoothing) reached or fell below the oversold threshold within the Stochastic RSI level lookback AND %K crosses above the oversold threshold AND current %K > prior %K.
Calculation: Bearish Stochastic RSI reversal = Stochastic RSI %K(close, Stochastic RSI length, stochastic lookback, K smoothing) reached or exceeded the overbought threshold within the Stochastic RSI level lookback AND %K crosses below the overbought threshold AND current %K < prior %K.
Long: Long environment AND Stochastic RSI reversal enabled AND Bullish Stochastic RSI reversal
Short: Short environment AND Stochastic RSI reversal enabled AND Bearish Stochastic RSI reversal
Calculation: Scados moving-average histogram = the shorter-period selected EMA or SMA of close minus the longer-period selected EMA or SMA of close, with signal equal to the selected EMA or SMA of that difference using the shorter MA period; histogram equals difference minus signal. Scados RSI values are RSI of each MA using max(minimum derived RSI length, round(that MA period × derived RSI-length fraction)).
Calculation: Scados long overheat = RSI of shorter-period selected MA > Scados overbought RSI threshold AND RSI of longer-period selected MA > Scados overbought RSI threshold.
Calculation: Scados short overheat = RSI of shorter-period selected MA < Scados oversold RSI threshold AND RSI of longer-period selected MA < Scados oversold RSI threshold.
Calculation: Scados long partial-exit condition = Scados exits enabled AND Scados long overheat AND (Statistical upper-wick anomaly OR Scados moving-average histogram crosses below its prior value).
Calculation: Scados short partial-exit condition = Scados exits enabled AND Scados short overheat AND (Statistical lower-wick anomaly OR Scados moving-average histogram crosses above its prior value).
Calculation: Scados long full-exit condition = Scados exits enabled AND Scados long overheat AND Statistical upper-wick anomaly AND Scados moving-average histogram crosses below its prior value.
Calculation: Scados short full-exit condition = Scados exits enabled AND Scados short overheat AND Statistical lower-wick anomaly AND Scados moving-average histogram crosses above its prior value.
Long: Long environment AND (Bullish pinbar OR Bullish engulfing OR Double bottom OR Long range breakout OR Main bullish BOS OR shorter-period EMA crosses above longer-period EMA OR (Stochastic RSI reversal enabled AND Bullish Stochastic RSI reversal))
Short: Short environment AND (Bearish pinbar OR Bearish engulfing OR Double top OR Short range breakout OR Main bearish BOS OR shorter-period EMA crosses below longer-period EMA OR (Stochastic RSI reversal enabled AND Bearish Stochastic RSI reversal))
Calculation: Long structure score = (Bullish pinbar ? (strong pinbar scoring enabled AND Statistical lower-wick anomaly ? strong-pinbar points : ordinary-pinbar points) : 0) + (Bullish engulfing ? engulfing points : 0) + (Double bottom ? double-pattern points : 0) + (Long range breakout ? range-break points : 0) + (Main bullish BOS ? BOS points : 0) + (shorter-period EMA crosses above longer-period EMA ? EMA-crossover points : 0) + (Stochastic RSI reversal enabled AND Bullish Stochastic RSI reversal ? Stochastic RSI points : 0).
Calculation: Short structure score = (Bearish pinbar ? (strong pinbar scoring enabled AND Statistical upper-wick anomaly ? strong-pinbar points : ordinary-pinbar points) : 0) + (Bearish engulfing ? engulfing points : 0) + (Double top ? double-pattern points : 0) + (Short range breakout ? range-break points : 0) + (Main bearish BOS ? BOS points : 0) + (shorter-period EMA crosses below longer-period EMA ? EMA-crossover points : 0) + (Stochastic RSI reversal enabled AND Bearish Stochastic RSI reversal ? Stochastic RSI points : 0).
Calculation: Long total score = Long structure score + (Long retracement zone AND Long structure score > 0 ? long zone bonus points : 0).
Calculation: Short total score = Short structure score + (Short retracement zone AND Short structure score > 0 ? short zone bonus points : 0).
Long: Long environment AND Long total score >= entry score threshold AND (no prior long entry signal OR current chart bar index - prior long entry-signal bar index > same-direction cooldown lookback)
Short: Short environment AND Short total score >= entry score threshold AND (no prior short entry signal OR current chart bar index - prior short entry-signal bar index > same-direction cooldown lookback)
Long: Long environment AND (Bullish pinbar OR Bullish engulfing OR Double bottom OR Long range breakout OR Main bullish BOS OR shorter-period EMA crosses above longer-period EMA OR (Stochastic RSI reversal enabled AND Bullish Stochastic RSI reversal)) AND Long retracement zone
Short: Short environment AND (Bearish pinbar OR Bearish engulfing OR Double top OR Short range breakout OR Main bearish BOS OR shorter-period EMA crosses below longer-period EMA OR (Stochastic RSI reversal enabled AND Bearish Stochastic RSI reversal)) AND Short retracement zone
Calculation: Tracked trade state = activate long on a long entry signal and short on a short entry signal; an opposite entry replaces the active side; deactivate both sides on either full-exit condition; partial exits leave the active side unchanged. A new entry resets that side's add-on trigger and completion state.
Calculation: Bullish chase break = close > highest(high, chase BOS lookback)[1]. Bearish chase break = close < lowest(low, chase BOS lookback)[1].
Calculation: Long add-on = while a tracked long trade is active, the first Bullish chase break records that bar's high; then, once per entry and only on a later chart bar, close > the recorded high.
Calculation: Short add-on = while a tracked short trade is active, the first Bearish chase break records that bar's low; then, once per entry and only on a later chart bar, close < the recorded low.
Long: Long add-on
Short: Short add-on
Long: Long environment AND Bullish pinbar
Short: Short environment AND Bearish pinbar
Long: Long environment AND Bullish engulfing
Short: Short environment AND Bearish engulfing
Long: Long environment AND Double bottom
Short: Short environment AND Double top
Long: Long environment AND Long range breakout
Short: Short environment AND Short range breakout
Long: Long environment AND Main bullish BOS
Short: Short environment AND Main bearish BOS
Long: Long environment AND shorter-period EMA crosses above longer-period EMA
Short: Short environment AND shorter-period EMA crosses below longer-period EMA
Long: Long environment AND Stochastic RSI reversal enabled AND Bullish Stochastic RSI reversal
Short: Short environment AND Stochastic RSI reversal enabled AND Bearish Stochastic RSI reversal
Long: Long environment AND Long structure score > 0 AND Long retracement zone
Short: Short environment AND Short structure score > 0 AND Short retracement zone
Long: close > SMA(close, dashboard SMA lookback, T1 requested bar sampled on chart bars; current T1 bar in real time, latest completed T1 bar historically, lookahead off)
Short: close <= SMA(close, dashboard SMA lookback, T1 requested bar sampled on chart bars; current T1 bar in real time, latest completed T1 bar historically, lookahead off)
Long: close > SMA(close, dashboard SMA lookback, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off)
Short: close <= SMA(close, dashboard SMA lookback, T2 requested bar sampled on chart bars; current T2 bar in real time, latest completed T2 bar historically, lookahead off)
Long: close > SMA(close, dashboard SMA lookback, T3 requested bar sampled on chart bars; current T3 bar in real time, latest completed T3 bar historically, lookahead off)
Short: close <= SMA(close, dashboard SMA lookback, T3 requested bar sampled on chart bars; current T3 bar in real time, latest completed T3 bar historically, lookahead off)
Long: close > SMA(close, dashboard SMA lookback, T4 requested bar sampled on chart bars; current T4 bar in real time, latest completed T4 bar historically, lookahead off)
Short: close <= SMA(close, dashboard SMA lookback, T4 requested bar sampled on chart bars; current T4 bar in real time, latest completed T4 bar historically, lookahead off)
Calculation: Bullish reversal exit pattern = Bearish pinbar OR Bearish engulfing. Bearish reversal exit pattern = Bullish pinbar OR Bullish engulfing.
Calculation: Long partial exit = tracked long trade active AND (high >= active zone high OR shorter-period EMA crosses below longer-period EMA OR Scados long partial-exit condition).
Calculation: Short partial exit = tracked short trade active AND (low <= active zone low OR shorter-period EMA crosses above longer-period EMA OR Scados short partial-exit condition).
Calculation: Long full exit = tracked long trade active AND (Bearish chase break OR Bullish reversal exit pattern OR (RSI(close, regular RSI lookback) > long overheat threshold AND close < open) OR Scados long full-exit condition).
Calculation: Short full exit = tracked short trade active AND (Bullish chase break OR Bearish reversal exit pattern OR (RSI(close, regular RSI lookback) < short oversold threshold AND close > open) OR Scados short full-exit condition).
Exit: Long, Long partial exit
Exit: Long, Long full exit
Exit: Short, Short partial exit
Exit: Short, Short full exit