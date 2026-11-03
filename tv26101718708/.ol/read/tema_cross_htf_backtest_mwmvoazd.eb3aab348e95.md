Calculation: Chart-timeframe TEMA = 3 × EMA(close, lookback) − 3 × EMA(EMA(close, lookback), lookback) + EMA(EMA(EMA(close, lookback), lookback), lookback); the fast TEMA uses a shorter lookback than the slow TEMA
Calculation: Higher-timeframe TEMA = the same TEMA calculation on higher-timeframe close, using the last completed higher-timeframe bar; the fast TEMA uses a shorter lookback than the slow TEMA
Long: chart-timeframe fast TEMA > chart-timeframe slow TEMA AND higher-timeframe fast TEMA > higher-timeframe slow TEMA AND time >= configured start time AND time <= configured end time
Short: chart-timeframe fast TEMA < chart-timeframe slow TEMA AND higher-timeframe fast TEMA < higher-timeframe slow TEMA AND time >= configured start time AND time <= configured end time
Exit: long, chart-timeframe fast TEMA < chart-timeframe slow TEMA AND time >= configured start time AND time <= configured end time
Exit: short, chart-timeframe fast TEMA > chart-timeframe slow TEMA