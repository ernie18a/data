Calculation: Upper band = VWAP + ATR times a configured deviation multiple
Calculation: Lower band = VWAP - ATR times the same deviation multiple
Calculation: Upper stop = VWAP + ATR times a configured stop multiple
Calculation: Lower stop = VWAP - ATR times the same stop multiple
Calculation: Flat EMA filter = absolute difference between a shorter-lookback EMA and that EMA at a longer lag is below ATR times a configured threshold
Long: (previous bar low < previous bar lower band OR current bar low < current bar lower band) AND current close > current lower band AND VWAP minus current close >= the configured minimum reward-to-risk ratio times (current close minus current lower stop) AND time is in the configured overnight session AND the flat EMA filter is true
Short: (previous bar high > previous bar upper band OR current bar high > current bar upper band) AND current close < current upper band AND current close minus VWAP >= the configured minimum reward-to-risk ratio times (current upper stop minus current close) AND time is in the configured overnight session AND the flat EMA filter is true
Exit: long, current low <= current lower stop OR current high >= current VWAP
Exit: short, current high >= current upper stop OR current low <= current VWAP