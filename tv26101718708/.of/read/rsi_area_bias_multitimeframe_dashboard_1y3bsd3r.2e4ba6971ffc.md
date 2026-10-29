Calculation: Timeframe area score = normalize to [-100, 100] the rolling-range position of the rolling sum of (RSI − EMA(RSI)); use each configured dashboard timeframe’s own bars, which may be higher or lower than the chart timeframe, using its current bar (forming in real time).
Calculation: Overall score = weighted average of the four timeframe scores, with weights increasing from 1 for the shortest timeframe to 4 for the longest.
Calculation: Chart score MA = EMA of the chart timeframe’s area score.
Long: any dashboard timeframe score > 0 OR overall score > 0 OR chart score crosses above its score MA
Short: any dashboard timeframe score < 0 OR overall score < 0