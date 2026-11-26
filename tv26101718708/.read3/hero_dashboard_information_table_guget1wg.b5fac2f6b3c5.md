Calculation: Opening-range high = highest(high) during the opening-range interval of each session
Calculation: Opening-range low = lowest(low) during the opening-range interval of each session
Calculation: Hero score = VWAP score weight if close > VWAP(close), plus volume score weight if volume > SMA(volume, volume lookback) × relative-volume threshold, plus prior-day breakout score weight if close > high of the last completed T1 bar or close < low of the last completed T1 bar (T1 values taken on each chart bar), plus opening-range breakout score weight if close > opening-range high or close < opening-range low, plus ATR score weight if ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback)
Long: close > EMA(close, EMA lookback) AND close > VWAP(close)
Short: close < EMA(close, EMA lookback) AND close < VWAP(close)
Long: close > high of the last completed T1 bar, with the T1 value taken on each chart bar
Short: close < low of the last completed T1 bar, with the T1 value taken on each chart bar
Long: close > opening-range high
Short: close < opening-range low
Long: Hero score >= Hero-score threshold AND close > EMA(close, EMA lookback) AND close > VWAP(close)
Short: Hero score >= Hero-score threshold AND close < EMA(close, EMA lookback) AND close < VWAP(close)
Calculation: Bullish trend = close > EMA(close, EMA length) AND close > VWAP
Calculation: Bearish trend = close < EMA(close, EMA length) AND close < VWAP
Calculation: Opening-range high = highest high of each session at the opening-range hour while minute is less than the opening-range cutoff minute
Calculation: Opening-range low = lowest low of each session at the opening-range hour while minute is less than the opening-range cutoff minute
Calculation: Hero Score = (close > VWAP ? VWAP score points : 0) + (volume > SMA(volume, volume-average length) × volume-expansion multiplier ? volume-expansion score points : 0) + (close > previous T1 high OR close < previous T1 low ? previous-day-breakout score points : 0) + (close > opening-range high OR close < opening-range low ? opening-range-breakout score points : 0) + (ATR(ATR length) > SMA(ATR(ATR length), ATR-average length) ? ATR-expansion score points : 0)
Long: Bullish trend
Short: Bearish trend
Long: close > previous T1 high
Short: close < previous T1 low
Long: Hero Score ≥ high-score threshold AND Bullish trend
Short: Hero Score ≥ high-score threshold AND Bearish trend
Option: buy call, Hero Score ≥ high-score threshold AND Bullish trend
Option: buy put, Hero Score ≥ high-score threshold AND Bearish trend