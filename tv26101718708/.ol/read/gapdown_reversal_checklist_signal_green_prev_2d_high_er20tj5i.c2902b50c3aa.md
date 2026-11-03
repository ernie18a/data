Calculation: Previous-day high = high of the last completed bar on a higher timeframe than the chart timeframe (daily)
Calculation: Previous close = close of the last completed bar on a higher timeframe than the chart timeframe (daily)
Calculation: Daily 50-bar SMA = simple moving average of closes over 50 bars on a higher timeframe than the chart timeframe (daily), using the bar still forming
Calculation: Daily 200-bar SMA = simple moving average of closes over 200 bars on a higher timeframe than the chart timeframe (daily), using the bar still forming
Calculation: Opening-range high = highest chart-timeframe bar high during the configured opening-range window
Calculation: RSI = relative strength index of chart-timeframe closes
Calculation: RSI moving average = configured moving average of RSI; its lookback is independent of the RSI lookback
Calculation: Setup score = count of these seven conditions: close > VWAP; close > previous close; opening range is complete and close > opening-range high; close >= previous-day high × (1 − configured proximity threshold) OR close > previous-day high; close is within the configured proximity threshold of either daily 50-bar SMA or daily 200-bar SMA, OR close crossed above either SMA from at or below it, OR close is above either SMA; RSI < configured limit; RSI moving average is not enabled, has no prior value, or is >= its prior value
Long: during the regular session, setup score >= 4