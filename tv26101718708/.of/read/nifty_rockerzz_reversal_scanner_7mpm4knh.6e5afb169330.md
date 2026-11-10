Calculation: Scan values = calculate independently on each scan timeframe; a scan timeframe may be higher or lower than the chart timeframe. For a higher timeframe, use the last completed bar on historical chart bars and the forming bar on the live chart bar; for a lower timeframe, use the last available intrabar within each chart bar.
Calculation: Stochastic K = SMA of 100 × (close − lowest low) / (highest high − lowest low) over the stochastic lookback; stochastic D = SMA of K over a separate smoothing lookback.
Calculation: Stochastic state = initially zero; on each chart bar set it to 1 when the scan-timeframe K crosses above D, or −1 when K crosses below D, and otherwise retain its previous value. Crosses compare the current and previous chart-bar values.
Calculation: Confirmed pivot = a close or RSI swing high or low confirmed after a configurable number of bars to its right, using a configurable number of bars to its left. Track the latest two confirmed close highs, close lows, RSI highs, and RSI lows independently on each scan timeframe.
Long: Scan-timeframe Chaikin Money Flow <= buy threshold
Short: Scan-timeframe Chaikin Money Flow > buy threshold AND Chaikin Money Flow >= sell threshold
Long: Scan-timeframe RSI > RSI threshold
Short: Scan-timeframe RSI <= RSI threshold
Long: Stochastic state = 1 OR (stochastic state = 0 AND scan-timeframe stochastic K < oversold threshold)
Short: Stochastic state = −1 OR (stochastic state = 0 AND scan-timeframe stochastic K > overbought threshold)
Short: Latest confirmed close high > previous confirmed close high AND latest confirmed RSI high < previous confirmed RSI high
Long: Latest confirmed close low < previous confirmed close low AND latest confirmed RSI low > previous confirmed RSI low AND (latest confirmed close high <= previous confirmed close high OR latest confirmed RSI high >= previous confirmed RSI high OR the two confirmed close highs or RSI highs are unavailable)