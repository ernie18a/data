Long: open[1] < SMA(close, MA period, MA shift) AND close[1] > SMA(close, MA period, MA shift) AND number of bars > minimum bar count
Short: open[1] > SMA(close, MA period, MA shift) AND close[1] < SMA(close, MA period, MA shift) AND number of bars > minimum bar count
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance