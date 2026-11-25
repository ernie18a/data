Calculation: RVI line separation = ABS(RVI main(high, low, open, close, lookback parameter) - RVI signal(high, low, open, close, lookback parameter))
Calculation: RVI midpoint difference = RVI line separation / RVI divisor parameter
Long: close > Supertrend upper band(high, low, close, lookback parameter, multiplier parameter)[1]
Short: close < Supertrend lower band(high, low, close, lookback parameter, multiplier parameter)[1]
Long: RVI signal line < RVI main line - RVI midpoint difference AND RVI line separation > RVI difference threshold parameter AND total ask > total ask[4] AND ask value > ask value[2] AND total close > total close[4] AND close value > close value[2] AND close > Supertrend upper band(high, low, close, lookback parameter, multiplier parameter)[1]
Short: RVI signal line > RVI main line + RVI midpoint difference AND RVI line separation > RVI difference threshold parameter AND total bid < total bid[4] AND bid value < bid value[2] AND total close < total close[4] AND close value < close value[2] AND close < Supertrend lower band(high, low, close, lookback parameter, multiplier parameter)[1]
Exit: long, position profit >= minimum profit parameter OR position profit <= -minimum loss parameter
Exit: short, position profit >= minimum profit parameter OR position profit <= -minimum loss parameter