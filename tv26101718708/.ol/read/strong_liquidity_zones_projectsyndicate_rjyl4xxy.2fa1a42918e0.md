Calculation: Bullish wick rejection = low < open or close? AND (min(open, close) - low) / (high - low) > wick-dominance threshold AND close > open
Calculation: Bearish wick rejection = (high - max(open, close)) / (high - low) > wick-dominance threshold AND close < open
Calculation: Bullish volume spike = volume > its 20-bar average × volume-spike multiplier AND close > open AND low is the 10-bar lowest low
Calculation: Bearish volume spike = volume > its 20-bar average × volume-spike multiplier AND close < open AND high is the 10-bar highest high
Calculation: Bullish liquidity zone = active price band centered on a cluster of bullish pivot-low, bullish wick-rejection, or bullish volume-spike prices; bearish liquidity zone = corresponding band centered on bearish detections. Cluster detections whose prices are within a tolerance measured in ATR; zone half-width is ATR × zone-width multiplier.
Calculation: Zone power rank = rounded sum, capped at 10, of confluence points (0.5 for 1 detection; 1.5 for 2; 2.5 for 3; 3.2 for 4; 3.6 for 5; 3.8 for 6; 4 for 7 or more), detection-diversity points (3 for all 3 detection types; 1.5 for 2; otherwise 0), average-strength points (1.8 if >2.2; 1.3 if >1.9; 0.8 if >1.6; 0.3 if >1.3; otherwise 0), and recency points (0.8 if newest detection is <15 bars old; 0.5 if <50; 0.2 if <150; otherwise 0).
Long: bullish pivot low OR bullish wick rejection OR bullish volume spike
Long: active STRONG/ELITE bullish liquidity zone AND low <= zone upper edge AND close > zone upper edge
Long: (active WEAK/MEDIUM bearish liquidity zone OR bearish liquidity zone breached on this bar) AND close > zone upper edge AND volume > its 20-bar average
Short: bearish pivot high OR bearish wick rejection OR bearish volume spike
Short: active STRONG/ELITE bearish liquidity zone AND high >= zone lower edge AND close < zone lower edge
Short: (active WEAK/MEDIUM bullish liquidity zone OR bullish liquidity zone breached on this bar) AND close < zone lower edge AND volume > its 20-bar average
Exit: long, close < the lower edge of the zone used for entry
Exit: short, close > the upper edge of the zone used for entry