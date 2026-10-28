Calculation: ATR = average true range of the chart bars
Calculation: Recent high/low = highest high/lowest low over the lookback, excluding the current bar
Calculation: Bullish/bearish sweep = current high above recent high / current low below recent low by the minimum sweep depth in ATR units
Calculation: Bullish/bearish close acceptance = close above recent high / below recent low by the continuation buffer in ATR units
Calculation: Trend support = bullish: close above the longer-period EMA and shorter-period EMA at or above the longer-period EMA; bearish: close below the longer-period EMA and shorter-period EMA at or below the longer-period EMA
Calculation: Neutral trend = bullish: close above the longer-period EMA or shorter-period EMA at or above it; bearish: close below the longer-period EMA or shorter-period EMA at or below it
Calculation: Volume ratio = current volume divided by its moving average
Calculation: Close location = bullish: (close − low) / (high − low); bearish: (high − close) / (high − low)
Calculation: Body efficiency = absolute(close − open) / (high − low)
Calculation: Normalized score = clamp((value − weak threshold) / (strong threshold − weak threshold) × 100, 0, 100); reverse the direction for lower-is-better measures
Calculation: Sweep score = normalized peak score of sweep depth, rising from the minimum qualifying depth to an ideal depth and falling to zero at the high-depth limit
Calculation: Close score = 55% normalized close distance in ATR units + 30% normalized close location + 15% normalized body efficiency
Calculation: Trend score = 100 with trend support, 62 with neutral trend, otherwise 25
Calculation: Target room = distance from close to the projected target, in ATR units, floored at zero; target distance is the greatest of risk distance × target multiple, fallback ATR distance, or 25% of the recent range; risk distance is the greater of trigger-to-invalidation distance or 0.20 ATR
Calculation: Room score = normalized target room, from weak room to clean-room threshold
Calculation: Reversal risk = clamp(42% rejection fraction + 30% × (100 − close score) + trend penalty (0 with support, 12 with neutral trend, otherwise 28) + 12 if volume ratio < 0.80, 0, 100)
Calculation: Continuation score = clamp(18% sweep score + 28% close score + 15% normalized volume ratio + 18% trend score + 21% room score − 8% reversal risk, 0, 100)
Long: On a confirmed bar, bullish sweep is selected (if both sweeps qualify, its continuation score is at least the bearish score), and either bullish close acceptance meets the selected confirmation mode and bullish continuation score meets the ready threshold, or bullish continuation score meets the watch threshold but the ready condition is false; emit only when this state begins or its selected direction changes
Short: On a confirmed bar, bearish sweep is selected (if both sweeps qualify, bullish is not selected), and either bearish close acceptance meets the selected confirmation mode and bearish continuation score meets the ready threshold, or bearish continuation score meets the watch threshold but the ready condition is false; emit only when this state begins or its selected direction changes