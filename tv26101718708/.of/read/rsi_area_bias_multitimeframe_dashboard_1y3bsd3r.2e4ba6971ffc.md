Calculation: Score (per timeframe) = computed on that timeframe's own bars (aggregated from chart bars, value of the bar still forming). RSI; rsiMA = EMA of RSI; gap = RSI - rsiMA; bullArea = rolling sum over an area window of max(gap,0); bearArea = rolling sum over the same window of max(-gap,0); raw = bullArea - bearArea; score = (raw - lowest(raw, norm window)) / (highest(raw, norm window) - lowest(raw, norm window)) * 200 - 100, or 0 if the range is 0. The norm window is longer than the area window.
Calculation: TF scores = Score on four timeframes ordered shortest to longest (independent of chart timeframe).
Calculation: Overall = weighted average of the four TF scores, weights increasing with timeframe length (longest timeframe weighted most).
Calculation: Chart score = Score computed on chart timeframe bars (current bar); Score MA = EMA of Chart score, with a shorter lookback than the norm window.
Long: Overall > 0
Long: all four TF scores > 0 AND Overall >= strong-bull threshold
Long: Chart score >= Score MA
Short: Overall < 0
Short: all four TF scores < 0 AND Overall <= -(strong threshold)
Short: Chart score < Score MA