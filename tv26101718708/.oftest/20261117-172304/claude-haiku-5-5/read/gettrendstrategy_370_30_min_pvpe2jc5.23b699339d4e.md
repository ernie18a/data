Calculation: HTF_close = close of the last completed bar of the higher timeframe
Calculation: HTF_open = open of the last completed bar of the higher timeframe
Long: HTF_close[1] <= HTF_open[1] AND HTF_close > HTF_open
Short: HTF_close[1] >= HTF_open[1] AND HTF_close < HTF_open
Exit: long, HTF_close[1] >= HTF_open[1] AND HTF_close < HTF_open
Exit: short, HTF_close[1] <= HTF_open[1] AND HTF_close > HTF_open