Calculation: Short-lookback EMA = EMA(close, shorter lookback)
Calculation: Long-lookback EMA = EMA(close, longer lookback)
Calculation: VWAP = VWAP(hlc3)
Calculation: Opening-range high = highest high during the opening-range session for each trading date
Calculation: Opening-range low = lowest low during the opening-range session for each trading date
Long: Short-lookback EMA crosses above long-lookback EMA
Short: Short-lookback EMA crosses below long-lookback EMA
Long: Regular session AND opening range complete AND close > opening-range high AND no earlier long breakout occurred this trading date
Short: Regular session AND opening range complete AND close < opening-range low AND no earlier short breakout occurred this trading date
Long: Regular session AND opening range complete AND a long breakout occurred earlier this trading date AND no earlier qualifying long retest occurred this trading date AND low <= opening-range high AND close > opening-range high AND no long breakout occurs on this bar AND close > VWAP AND short-lookback EMA > long-lookback EMA
Short: Regular session AND opening range complete AND a short breakout occurred earlier this trading date AND no earlier qualifying short retest occurred this trading date AND high >= opening-range low AND close < opening-range low AND no short breakout occurs on this bar AND close < VWAP AND short-lookback EMA < long-lookback EMA
Long: Regular session AND on or after a long retest while awaiting its first confirmation AND close > open AND close > high[1]
Short: Regular session AND on or after a short retest while awaiting its first confirmation AND close < open AND close < low[1]