Calculation: Opening range high/low = highest high / lowest low during the opening range period
Calculation: Bullish Braid = short-term EMA(close) > intermediate EMA(open) AND spread between the short-, intermediate-, and long-term EMAs > ATR-based threshold
Calculation: Bearish Braid = intermediate EMA(open) > short-term EMA(close) AND spread between the short-, intermediate-, and long-term EMAs > ATR-based threshold
Long: no trade has been taken today AND time is within the configured trading window AND close > opening range high AND close > VWAP AND Bullish Braid
Short: no trade has been taken today AND time is within the configured trading window AND close < opening range low AND close < VWAP AND Bearish Braid
Exit: Long, low <= opening range low OR high >= min(entry price + configured risk multiple × (entry price − opening range low), last completed daily high, current higher-timeframe bar high while forming)
Exit: Short, high >= opening range high OR low <= max(entry price − configured risk multiple × (opening range high − entry price), last completed daily low, current higher-timeframe bar low while forming)