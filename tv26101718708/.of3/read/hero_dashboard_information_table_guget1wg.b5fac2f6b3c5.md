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