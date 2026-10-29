Calculation: Fast SMA = simple moving average of close with a shorter lookback than the slow SMA, on the higher timeframe’s last completed bar
Calculation: Slow SMA = simple moving average of close with a longer lookback than the fast SMA, on the higher timeframe’s last completed bar
Calculation: Short ATR = average true range with a shorter lookback than Long ATR, on the chart timeframe’s last completed bar
Calculation: Long ATR = average true range with a longer lookback than Short ATR, on the chart timeframe’s last completed bar
Calculation: Grid step = fixed price distance or ATR multiplied by a parameter, whichever is greater than the minimum grid step
Long: Close > Fast SMA AND Close > Slow SMA AND Close − Fast SMA ≥ minimum signal distance AND current higher-timeframe volume ≥ previous higher-timeframe volume × volume multiplier AND absolute change in Fast SMA ≥ minimum slope AND Short ATR / Long ATR < volatility threshold
Long: Position side is long AND average entry price − current price ≥ Grid step AND last entry price − current price ≥ Grid step
Short: Close < Fast SMA AND Close < Slow SMA AND Fast SMA − Close ≥ minimum signal distance AND current higher-timeframe volume ≥ previous higher-timeframe volume × volume multiplier AND absolute change in Fast SMA ≥ minimum slope AND Short ATR / Long ATR < volatility threshold
Short: Position side is short AND current price − average entry price ≥ Grid step AND current price − last entry price ≥ Grid step
Exit: long, current price ≥ average entry price + take-profit distance
Exit: short, current price ≤ average entry price − take-profit distance
Exit: long, current price ≥ average entry price + grid profit target
Exit: short, current price ≤ average entry price − grid profit target
Exit: long, Close < Fast SMA OR Close < Slow SMA
Exit: short, Close > Fast SMA OR Close > Slow SMA