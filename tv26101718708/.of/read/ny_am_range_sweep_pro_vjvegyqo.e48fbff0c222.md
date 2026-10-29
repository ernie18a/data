Calculation: Daily range high = highest high during the configured daily range session, finalized when the session ends
Calculation: Daily range low = lowest low during the configured daily range session, finalized when the session ends
Calculation: Most recent bearish-bar high = high of the most recent prior chart bar with close < open
Calculation: Most recent bullish-bar low = low of the most recent prior chart bar with close > open
Long: Daily range is complete AND no sweep or trade has occurred today AND close < daily range low, followed by close > most recent bearish-bar high before any close > daily range high, AND the last completed higher-timeframe candle closes > its open
Short: Daily range is complete AND no sweep or trade has occurred today AND close > daily range high, followed by close < most recent bullish-bar low before any close < daily range low, AND the last completed higher-timeframe candle closes < its open
Exit: long, low <= low of the below-range sweep bar OR high >= daily range high
Exit: short, high >= high of the above-range sweep bar OR low <= daily range low