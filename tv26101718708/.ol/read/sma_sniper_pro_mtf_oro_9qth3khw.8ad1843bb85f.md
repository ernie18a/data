Calculation: SMA = simple moving average of selected-timeframe closes over the selected lookback; uses the selected-timeframe bar exposed by the platform (last completed bar for historical higher-timeframe data, potentially still forming in real time; lower-timeframe requests use the selected intrabar exposed for the chart bar)
Calculation: Body = absolute difference between selected-timeframe close and open
Calculation: Lower wick = minimum of selected-timeframe open and close minus selected-timeframe low
Calculation: Upper wick = selected-timeframe high minus maximum of selected-timeframe open and close
Long: selected-timeframe low <= SMA AND selected-timeframe high >= SMA AND selected-timeframe close > SMA AND lower wick > body × rejection threshold
Short: selected-timeframe low <= SMA AND selected-timeframe high >= SMA AND selected-timeframe close < SMA AND upper wick > body × rejection threshold