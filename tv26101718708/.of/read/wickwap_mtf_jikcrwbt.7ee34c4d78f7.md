Calculation: Upper wick = high − max(open, close) on the selected timeframe, which may be higher or lower than the chart timeframe; use its currently forming bar in realtime and its last available bar in historical data
Calculation: Lower wick = min(open, close) − low on the selected timeframe, which may be higher or lower than the chart timeframe; use its currently forming bar in realtime and its last available bar in historical data
Calculation: Average upper wick = simple moving average of upper wick over a lookback period
Calculation: Average lower wick = simple moving average of lower wick over a lookback period
Long: Lower wick >= average lower wick × minimum strength threshold AND a confirmed swing low exists
Short: Upper wick >= average upper wick × minimum strength threshold AND a confirmed swing high exists