Calculation: Asia-session high/low = maximum high/minimum low of chart-timeframe bars during the configured Asia session.
Calculation: London opening-range high/low = maximum high/minimum low of chart-timeframe bars during the configured opening-range interval.
Calculation: Higher-timeframe EMA = EMA of closes over the same lookback on each of two higher timeframes, using only each timeframe’s last completed bar.
Calculation: Bullish FVG = gap between the high two chart bars earlier and the current low; bearish FVG = gap between the current high and the low two chart bars earlier.
Long: Asia session complete AND current time within the configured bias window AND no bias has triggered this session AND Asia-session range within its configured bounds AND close > Asia-session high
Short: Asia session complete AND current time within the configured bias window AND no bias has triggered this session AND Asia-session range within its configured bounds AND close < Asia-session low
Long: bullish bias active AND higher-timeframe closes > their EMAs AND opening range complete AND no entry has fired this session AND within the configured entry window AND close > London opening-range high
Short: bearish bias active AND higher-timeframe closes < their EMAs AND opening range complete AND no entry has fired this session AND within the configured entry window AND close < London opening-range low
Long: bullish bias active AND an unmitigated bullish FVG is more than one chart bar old AND current low is within the FVG, at or below its upper boundary with the configured proximity allowance
Short: bearish bias active AND an unmitigated bearish FVG is more than one chart bar old AND current high is within the FVG, at or above its lower boundary with the configured proximity allowance