Calculation: Trend filter = reclaim EMA is above the longer trend EMA and rising versus an earlier higher-timeframe value; omit this filter when disabled
Calculation: Standard reclaim = higher-timeframe close is above the reclaim EMA and the prior higher-timeframe close was at or below its prior reclaim EMA
Calculation: Single-candle reclaim = the required prior higher-timeframe lows were all above the reclaim EMA, and the current higher-timeframe bar opened above, dipped below, and closed above the reclaim EMA; it closed above its open, its close was in the required upper fraction of its range, and its range as a percentage of close met the minimum
Calculation: Pullback quality = over the reclaim lookback plus its buffer, the lowest low was below the reclaim EMA by no more than the maximum ATR multiple, average absolute candle body was no more than the maximum ATR multiple, and no down candle's range as a percentage of close met or exceeded the maximum
Calculation: Qualifying reclaim = (standard reclaim OR single-candle reclaim) AND pullback quality
Calculation: Active reclaim setup = a qualifying reclaim occurred within the configured higher-timeframe validity window, its pullback quality passed, the current higher-timeframe close is above the reclaim EMA, and the trend filter passes
Calculation: Volume contraction = the recent volume average is below the prior volume average multiplied by the contraction threshold
Calculation: Range contraction = the recent average high-low range is below the prior average high-low range multiplied by the contraction threshold
Calculation: Entry trigger = current close is above the highest high of the prior breakout lookback bars OR current high-low range exceeds the ATR multiple
Calculation: Volume expansion = current volume exceeds the prior average volume multiplied by the expansion threshold
Long: single-candle reclaim AND trend filter
Long: active reclaim setup AND volume contraction and range contraction were both true on the prior chart-timeframe bar AND entry trigger AND (volume expansion OR volume-expansion requirement is disabled) AND no prior entry signal occurred within the breakout lookback bars