Calculation: RVWAP = volume-weighted average of typical price (high+low+close)/3 over a rolling time window, computed on the chart timeframe, smoothed with a short weighted moving average; window holds at least a minimum number of bars
Calculation: SD = volume-weighted standard deviation of typical price around the current-window RVWAP over the same window, smoothed the same way
Calculation: Upper = RVWAP + k*SD; Lower = RVWAP - k*SD (k is a positive multiplier)
Calculation: SATR = short weighted moving average (4 samples) of ATR
Calculation: AvgVol = mean volume over a rolling window longer than the chart bar (long-term baseline)
Calculation: UpVol = mean volume of up bars (close > open) within the last N bars; DownVol = mean volume of down bars (close < open) within the last N bars
Calculation: Width = (Upper - Lower) / RVWAP; AvgWidth = mean of Width over a rolling window longer than the chart bar (same long-term window as AvgVol)
Long: close > Upper AND previous close <= previous Upper AND RVWAP > previous bar's RVWAP AND SATR > previous bar's SATR AND volume > m1*AvgVol (m1 > 1) AND previous bar's UpVol > previous bar's DownVol AND previous bar's Width <= m2 * previous bar's AvgWidth (m2 < 1)
Long: RVWAP > previous bar's RVWAP AND close > Upper
Short: close < Lower AND previous close >= previous Lower AND RVWAP < previous bar's RVWAP AND SATR > previous bar's SATR AND volume > m1*AvgVol (m1 > 1) AND previous bar's DownVol > previous bar's UpVol AND previous bar's Width <= m2 * previous bar's AvgWidth (m2 < 1)
Short: RVWAP < previous bar's RVWAP AND close < Lower