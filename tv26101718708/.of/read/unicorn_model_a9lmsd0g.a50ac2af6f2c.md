Calculation: Confirmed swing high/low = pivot high/low confirmed after the configured left and right strength bars
Calculation: Displacement = candle body at least the configured ATR(14) multiple, closing above the latest confirmed swing high for an up displacement or below the latest confirmed swing low for a down displacement
Calculation: Order block = the consecutive run of opposite-color candles immediately before a displacement; its zone spans the run's highest high to lowest low
Calculation: Bullish Breaker = bearish Order Block followed by a candle close above its zone; bearish Breaker = bullish Order Block followed by a candle close below its zone
Calculation: Fair Value Gap = bullish when current low is above the high two bars earlier; bearish when current high is below the low two bars earlier; the gap must meet the configured minimum ATR(14) height
Calculation: Inversion Fair Value Gap = a Fair Value Gap whose polarity flips when a candle closes through its far boundary; it retains the original gap zone
Calculation: Auto bias = compare bullish votes (close below Midnight Open and below the midpoint of the latest confirmed swing high and low) with bearish votes (close above Midnight Open and above that midpoint); greater bullish votes means bullish, greater bearish votes means bearish, equal votes means mixed
Long: A bullish Breaker overlaps a live bullish Inversion Fair Value Gap AND bias gating is off or bias is bullish or mixed
Short: A bearish Breaker overlaps a live bearish Inversion Fair Value Gap AND bias gating is off or bias is bearish or mixed