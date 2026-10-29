Calculation: Higher-timeframe SMA = simple moving average of higher-timeframe closes, using closes from two completed higher-timeframe bars ago
Calculation: Long stop-loss price = entry price × stop-loss fraction
Long: bar time is within the configured end-of-day entry window AND chart close > higher-timeframe SMA
Exit: long, chart low <= long stop-loss price OR (bar time is within the configured next-morning exit window AND chart close > entry price)