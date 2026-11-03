Calculation: Asian range high and low = highest high and lowest low during the configured Asian session
Calculation: Asian range width = Asian range high - Asian range low
Calculation: Daily ATR = ATR calculated on the higher daily timeframe using the last completed daily bar
Long: On an allowed intraday chart, during the configured post-session sweep window, the Asian range is valid, no sweep has occurred this session, and high > Asian range high AND (low >= Asian range low OR high - Asian range high >= Asian range low - low)
Short: On an allowed intraday chart, during the configured post-session sweep window, the Asian range is valid, no sweep has occurred this session, and low < Asian range low AND (high <= Asian range high OR Asian range low - low > high - Asian range high)