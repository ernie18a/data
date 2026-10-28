Calculation: Fractal midpoint = average of the latest confirmed fractal high and fractal low; a fractal high/low is the highest high/lowest low in a centered window.
Calculation: Bullish score = count of bullish EOM flow, close above fractal midpoint, CCI above zero, and bullish ATR thrust.
Calculation: Bearish score = count of bearish EOM flow, close below fractal midpoint, CCI below zero, and bearish ATR thrust.
Calculation: Bullish EOM flow = the smoothed Ease of Movement value is above zero and rising.
Calculation: Bearish EOM flow = the smoothed Ease of Movement value is below zero and falling.
Calculation: Bullish ATR thrust = close > open AND absolute candle body > ATR × thrust multiplier.
Calculation: Bearish ATR thrust = close < open AND absolute candle body > ATR × thrust multiplier.
Long: close > fractal midpoint AND (bullish score >= confirmation threshold AND no bullish confirmed signal within the cooldown period OR bullish score = confirmation threshold − 1)
Short: close < fractal midpoint AND (bearish score >= confirmation threshold AND no bearish confirmed signal within the cooldown period OR bearish score = confirmation threshold − 1)