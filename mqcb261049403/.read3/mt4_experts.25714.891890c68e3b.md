Calculation: Average = SMA(close, SMA lookback)
Calculation: Force = Force Index(close, Force lookback, SMA)
Calculation: Bands = Bollinger Bands(close, band lookback, band deviation)
Calculation: Mean open-trade net profit = mean(open-trade profit + swap + commission)
Long: Average < close[1] AND Force > 0 AND close[1] <= lower Bands
Short: Average > close[1] AND Force < 0 AND close[1] >= upper Bands
Exit: long, Mean open-trade net profit > profit threshold AND position profit is the highest among open trades
Exit: long, Mean open-trade net profit > profit threshold AND position profit is the lowest among open trades
Exit: short, Mean open-trade net profit > profit threshold AND position profit is the highest among open trades
Exit: short, Mean open-trade net profit > profit threshold AND position profit is the lowest among open trades