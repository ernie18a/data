Calculation: Short-term KST = sum of four rate-of-change series, each smoothed by its own moving average and weighted 1, 2, 3, and 4; intermediate-term and long-term KST use progressively longer lookbacks.
Calculation: Short-term oscillator and signal = short-term KST and its moving average, optionally standardized using the same rolling statistics; the signal is the moving average of short-term KST.
Calculation: Long-term direction = current long-term KST compared with its previous bar.
Calculation: ADX = directional movement index average.
Calculation: Higher-timeframe direction = sign of short-term KST minus its signal on the last completed higher-timeframe bar.
Calculation: Efficiency Ratio = absolute close change over a lookback divided by the sum of absolute one-bar close changes over that lookback; conviction scale linearly interpolates between its chop and trend scale parameters using this ratio.
Calculation: Confidence = absolute weighted average of four votes, scaled by the Efficiency Ratio conviction scale and capped at 100; votes are +1 or -1 for short-term oscillator above or below signal, long-term KST rising or falling, close above or below its trend moving average, and bullish or bearish divergence; the divergence vote is 0 when absent, and the long-term vote is 0 when flat.
Calculation: Confirmed bullish divergence = at a confirmed price low pivot, oscillator pivot is higher and price low is lower than at the preceding price low pivot; hidden bullish divergence = oscillator pivot is lower and price low is higher.
Calculation: Confirmed bearish divergence = at a confirmed price high pivot, oscillator pivot is lower and price high is higher than at the preceding price high pivot; hidden bearish divergence = oscillator pivot is higher and price high is lower.
Long: Short-term oscillator crosses above its signal AND long-term KST is rising AND (ADX is at or above its threshold if the regime filter is enabled) AND (short-term KST is at least its signal on the last completed higher-timeframe bar if the higher-timeframe filter is enabled) AND Confidence is at or above its threshold AND warm-up period has elapsed AND bar is confirmed if close confirmation is enabled
Short: Short-term oscillator crosses below its signal AND long-term KST is falling AND (ADX is at or above its threshold if the regime filter is enabled) AND (short-term KST is at most its signal on the last completed higher-timeframe bar if the higher-timeframe filter is enabled) AND Confidence is at or above its threshold AND warm-up period has elapsed AND bar is confirmed if close confirmation is enabled
Long: At a confirmed low pivot, bullish regular or hidden divergence occurs between this pivot and the preceding low pivot within the maximum pivot spacing
Short: At a confirmed high pivot, bearish regular or hidden divergence occurs between this pivot and the preceding high pivot within the maximum pivot spacing
Long: Weighted vote score is at least zero
Short: Weighted vote score is below zero
Long: Short-term, intermediate-term, and long-term KST are all above zero
Short: Short-term, intermediate-term, and long-term KST are all below zero