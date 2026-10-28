Calculation: Asia opening-range high/low = highest high/lowest low during the opening-range session, fixed when that session completes
Calculation: Candle body percentage = abs(close − open) / (high − low) × 100
Calculation: HTF trend = on the last completed 15-minute bar, shorter-period EMA > longer-period EMA and close > VWAP for bullish; shorter-period EMA < longer-period EMA and close < VWAP for bearish
Long: HTF trend is bullish
Short: HTF trend is bearish
Long: opening range is complete AND time is within the entry session AND close > opening-range high + breakout buffer AND prior close ≤ opening-range high + breakout buffer AND close > open AND candle body percentage ≥ minimum AND HTF trend is bullish
Short: opening range is complete AND time is within the entry session AND close < opening-range low − breakout buffer AND prior close ≥ opening-range low − breakout buffer AND close < open AND candle body percentage ≥ minimum AND HTF trend is bearish