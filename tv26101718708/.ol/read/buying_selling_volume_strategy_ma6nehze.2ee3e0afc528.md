Calculation: Buying volume = volume × (close − low) / (high − low), or 0 when high = low, on the selected volume timeframe’s current bar (which may be higher or lower than the chart timeframe)
Calculation: Selling volume = volume × (high − close) / (high − low), or 0 when high = low, on the selected volume timeframe’s current bar
Calculation: Signed buying volume = buying volume when buying volume > selling volume; otherwise −|buying volume|
Calculation: Signed selling volume = selling volume when selling volume > buying volume; otherwise −|selling volume|
Calculation: Buying-selling difference = signed buying volume + signed selling volume
Calculation: Upper Bollinger Band = simple moving average of the buying-selling difference + standard deviation multiplier × its standard deviation, using the same lookback and selected volume timeframe
Calculation: Weekly VWAP = VWAP of hlc3 on the weekly higher-timeframe bar still forming
Calculation: Daily ATR percentage = 14-day simple moving average of daily true range ÷ daily close × 100, using the daily higher-timeframe bar still forming; daily true range is the maximum of daily high − daily low, |daily high − previous daily close|, and |daily low − previous daily close|
Long: buying-selling difference > upper Bollinger Band AND signed buying volume > signed selling volume AND close > weekly VWAP
Short: buying-selling difference > upper Bollinger Band AND signed buying volume < signed selling volume AND close < weekly VWAP
Exit: long, buying-selling difference > upper Bollinger Band AND signed buying volume < signed selling volume AND close < weekly VWAP OR high > entry price + entry price × daily ATR percentage × long target multiplier / 100 OR close > entry price + entry price × daily ATR percentage × long target multiplier / 100 OR low < entry price − entry price × daily ATR percentage × long stop multiplier / 100 OR close < entry price − entry price × daily ATR percentage × long stop multiplier / 100
Exit: short, buying-selling difference > upper Bollinger Band AND signed buying volume > signed selling volume AND close > weekly VWAP