Calculation: Bullish trend = close > EMA(close, EMA length) AND close > VWAP
Calculation: Bearish trend = close < EMA(close, EMA length) AND close < VWAP
Calculation: Opening-range high = highest high of each session at the opening-range hour while minute is less than the opening-range cutoff minute
Calculation: Opening-range low = lowest low of each session at the opening-range hour while minute is less than the opening-range cutoff minute
Calculation: Hero Score = (close > VWAP ? VWAP score points : 0) + (volume > SMA(volume, volume-average length) × volume-expansion multiplier ? volume-expansion score points : 0) + (close > previous T1 high OR close < previous T1 low ? previous-day-breakout score points : 0) + (close > opening-range high OR close < opening-range low ? opening-range-breakout score points : 0) + (ATR(ATR length) > SMA(ATR(ATR length), ATR-average length) ? ATR-expansion score points : 0)
Long: Bullish trend
Short: Bearish trend
Long: close > previous T1 high
Short: close < previous T1 low
Long: close > opening-range high
Short: close < opening-range low
Long: Hero Score ≥ high-score threshold AND Bullish trend
Short: Hero Score ≥ high-score threshold AND Bearish trend
Option: buy call, Hero Score ≥ high-score threshold AND Bullish trend
Option: buy put, Hero Score ≥ high-score threshold AND Bearish trend