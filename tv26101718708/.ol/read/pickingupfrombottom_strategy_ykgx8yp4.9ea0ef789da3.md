Calculation: Camarilla center = prior completed higher-timeframe close − (prior completed higher-timeframe high − prior completed higher-timeframe low) × 0.618
Calculation: Camarilla R4 = prior completed higher-timeframe close + (prior completed higher-timeframe high − prior completed higher-timeframe low) × (1.1/2)
Calculation: Camarilla S3 = prior completed higher-timeframe close − (prior completed higher-timeframe high − prior completed higher-timeframe low) × (1.1/4)
Calculation: Smoothed Camarilla center, R4, and S3 = chart-timeframe EMA of each respective level
Calculation: Smoothed long-lookback low = chart-timeframe EMA of the rolling lowest HLC3, with a shorter smoothing length than the low lookback
Long: Smoothed Camarilla center crosses above smoothed long-lookback low AND at least one of the previous three chart-timeframe closes is below the current smoothed long-lookback low
Exit: Long, chart-timeframe close crosses below smoothed Camarilla R4 OR chart-timeframe close crosses below smoothed Camarilla S3