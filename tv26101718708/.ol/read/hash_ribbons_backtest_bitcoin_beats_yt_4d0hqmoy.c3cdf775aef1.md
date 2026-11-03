Calculation: Hash-rate short SMA = short-lookback simple moving average of daily hash-rate close, using the last completed daily bar (higher timeframe than the chart timeframe)
Calculation: Hash-rate long SMA = longer-lookback simple moving average of daily hash-rate close, using the last completed daily bar (higher timeframe than the chart timeframe)
Calculation: Short price SMA = shorter-lookback simple moving average of daily close, using the last completed daily bar (higher timeframe than the chart timeframe)
Calculation: Long price SMA = longer-lookback simple moving average of daily close, using the last completed daily bar (higher timeframe than the chart timeframe)
Long: (Short price SMA crosses above Long price SMA AND bars since Hash-rate short SMA crossed above Hash-rate long SMA < bars since Short price SMA crossed below Long price SMA AND bars since Hash-rate short SMA crossed above Hash-rate long SMA < bars since Hash-rate short SMA crossed below Hash-rate long SMA) OR (Short price SMA > Long price SMA AND Hash-rate short SMA crosses above Hash-rate long SMA)
Short: Hash-rate short SMA crosses below Hash-rate long SMA
Exit: long, Hash-rate short SMA crosses below Hash-rate long SMA OR low <= entry price - (entry price / leverage * stop-loss percentage)
Exit: short, Hash-rate short SMA crosses below Hash-rate long SMA