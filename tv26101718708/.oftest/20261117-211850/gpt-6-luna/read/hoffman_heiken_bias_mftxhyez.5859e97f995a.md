Calculation: Trigger SMA = simple moving average of close over its independent lookback parameter
Calculation: Trend EMA = exponential moving average of close over its independent lookback parameter
Calculation: Trend SMA 1 = simple moving average of close over its independent lookback parameter
Calculation: Trend SMA 2 = simple moving average of close over its independent lookback parameter
Calculation: Trend EMA 1 = exponential moving average of close over its independent lookback parameter
Calculation: Trend EMA 2 = exponential moving average of close over its independent lookback parameter
Calculation: True range RMA = Wilder moving average of true range over its independent lookback parameter
Calculation: Upper trend band = Trend EMA 2 + 0.5 × True range RMA
Calculation: Lower trend band = Trend EMA 2 − 0.5 × True range RMA
Calculation: Uptrend = Trend EMA 1 < Trend EMA and Trend SMA 1 < Trend EMA and Trend SMA 2 < Trend EMA and Trend EMA 2 < Trend EMA and Upper trend band < Trend EMA and Lower trend band < Trend EMA
Calculation: Downtrend = Trend EMA 1 > Trend EMA and Trend SMA 1 > Trend EMA and Trend SMA 2 > Trend EMA and Trend EMA 2 > Trend EMA and Upper trend band > Trend EMA and Lower trend band > Trend EMA
Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (open + close) / 2 on the first bar; thereafter (previous Heikin-Ashi open + previous Heikin-Ashi close) / 2
Calculation: Heikin-Ashi high = maximum of high, Heikin-Ashi open, and Heikin-Ashi close
Calculation: Heikin-Ashi low = minimum of low, Heikin-Ashi open, and Heikin-Ashi close
Calculation: Upper wick = Heikin-Ashi high minus the greater of Heikin-Ashi open and Heikin-Ashi close
Calculation: Lower wick = the lesser of Heikin-Ashi open and Heikin-Ashi close minus Heikin-Ashi low
Calculation: Body = absolute difference between Heikin-Ashi close and Heikin-Ashi open
Calculation: Heikin-Ashi OHLC4 = (Heikin-Ashi high + Heikin-Ashi low + Heikin-Ashi open + Heikin-Ashi close) / 4
Calculation: Up fraction = (upper wick + lower wick + 2 × body) / (2 × (upper wick + lower wick + body)) when Heikin-Ashi close > Heikin-Ashi open; otherwise (upper wick + lower wick) / (2 × (upper wick + lower wick + body))
Calculation: Down fraction = (upper wick + lower wick) / (2 × (upper wick + lower wick + body)) when Heikin-Ashi close > Heikin-Ashi open; otherwise (upper wick + lower wick + 2 × body) / (2 × (upper wick + lower wick + body))
Calculation: Net volume = volume × up fraction × Heikin-Ashi OHLC4 − volume × down fraction × Heikin-Ashi OHLC4
Calculation: Net-volume regression = linear regression of net volume over its independent lookback parameter, with offset equal to the negative of that lookback parameter
Long: Trigger SMA > Trend EMA AND Uptrend AND Net-volume regression > 0
Short: Trigger SMA < Trend EMA AND Downtrend AND Net-volume regression < 0