Calculation: Chart MA bias = Sort the enabled chart-timeframe EMA or SMA lines by increasing length. If fewer than two are enabled, or any pair differs by less than a configurable multiple of ATR, the bias is 0. Otherwise let A be the fastest, D the slowest, C the second slowest if at least three are enabled or D otherwise, and B the third slowest if at least four are enabled or C otherwise. Assign +2 if C > D AND B > C AND A > B AND close > A; otherwise +1 if C > D AND B > C AND close > B; otherwise -2 if C < D AND B < C AND A < B AND close < A; otherwise -1 if C < D AND B < C AND close < B; otherwise 0.
Calculation: Ladder bias = For five increasingly long lookbacks, including the current bar, calculate the lowest lows and highest highs. Count adjacent pairs where the longer-lookback lowest low is strictly below the shorter-lookback lowest low, and subtract the count where the longer-lookback highest high is strictly above the shorter-lookback highest high. Map a net count of at least 2 to +2, 1 to +1, -1 to -1, at most -2 to -2, and 0 to 0.
Calculation: Composite bias = If any pair of enabled chart moving averages differs by less than the spacing threshold, use 0; otherwise add chart MA bias and ladder bias. Map sums of at least 3 to +2, positive sums below 3 to +1, sums of at most -3 to -2, negative sums above -3 to -1, and 0 to 0.
Calculation: Higher-timeframe bias = On each of two higher timeframes, one longer than the other, calculate a short EMA, a longer EMA, and a still longer SMA of close. Use the last completed higher-timeframe bar in historical evaluation and the still-forming higher-timeframe bar in realtime. For each timeframe assign +1 if chart close > short EMA > longer EMA > longest SMA, -1 if chart close < short EMA < longer EMA < longest SMA, and 0 otherwise. Sum the two scores.
Calculation: Candle body low = min(open, close); candle body high = max(open, close); candle range = high - low; body fraction = abs(close - open) / candle range.
Long: Chart MA bias > 0
Short: Chart MA bias < 0
Long: Ladder bias > 0
Short: Ladder bias < 0
Long: Composite bias > 0
Short: Composite bias < 0
Long: Either individual higher-timeframe score > 0
Short: Either individual higher-timeframe score < 0
Long: Higher-timeframe bias > 0
Short: Higher-timeframe bias < 0
Long: Higher-timeframe bias + composite bias = 4
Short: Higher-timeframe bias + composite bias = -4
Long: close > session VWAP of close
Short: close < session VWAP of close
Long: Previous bar range > 0 AND previous bar ATR > 0 AND previous bar range >= previous bar ATR multiplied by the engulfing size threshold AND previous bar close > previous bar open AND previous bar body low < body low two bars ago AND previous bar body high > body high two bars ago AND previous bar body fraction >= engulfing body threshold
Short: Previous bar range > 0 AND previous bar ATR > 0 AND previous bar range >= previous bar ATR multiplied by the engulfing size threshold AND previous bar close < previous bar open AND previous bar body low < body low two bars ago AND previous bar body high > body high two bars ago AND previous bar body fraction >= engulfing body threshold
Long: Previous bar range > 0 AND previous bar ATR > 0 AND previous bar range >= previous bar ATR multiplied by the long-tail size threshold AND previous bar lower wick / range >= tail threshold AND previous bar body low >= previous bar low + tail threshold multiplied by previous bar range AND previous bar close > previous bar open AND (long-tail body filter disabled OR previous bar body fraction >= long-tail body threshold)
Short: Previous bar range > 0 AND previous bar ATR > 0 AND previous bar range >= previous bar ATR multiplied by the long-tail size threshold AND previous bar upper wick / range >= tail threshold AND previous bar body high <= previous bar high - tail threshold multiplied by previous bar range AND previous bar close < previous bar open AND (long-tail body filter disabled OR previous bar body fraction >= long-tail body threshold)
Long: Previous RSI < upper breakout threshold AND current RSI >= upper breakout threshold
Short: Previous RSI > lower breakout threshold AND current RSI <= lower breakout threshold
Long: Previous RSI < lower breakout threshold AND current RSI >= lower breakout threshold AND RSI simple moving average >= lower RSI-average threshold AND previous RSI <= previous RSI simple moving average AND current RSI > current RSI simple moving average
Short: Previous RSI > upper breakout threshold AND current RSI <= upper breakout threshold AND RSI simple moving average >= upper RSI-average threshold AND previous RSI >= previous RSI simple moving average AND current RSI < current RSI simple moving average