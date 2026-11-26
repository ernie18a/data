Long: no open long position AND close of last completed chart bar > open of last completed chart bar AND bullish body size in pips >= bull-and-bear EA long minimum body size
Short: no open short position AND open of last completed chart bar > close of last completed chart bar AND bearish body size in pips >= bull-and-bear EA short minimum body size
Exit: long, low <= entry price - bull-and-bear EA long stop-loss distance OR high >= entry price + bull-and-bear EA long take-profit distance
Exit: short, high >= entry price + bull-and-bear EA short stop-loss distance OR low <= entry price - bull-and-bear EA short take-profit distance
Long: no open position AND close of last completed chart bar > open of last completed chart bar AND bullish body size in pips > QCandle EA minimum body size
Exit: long, low <= entry price - QCandle EA stop-loss distance OR high >= entry price + QCandle EA take-profit distance
Long: current chart bar body size in pips > simple-candle size threshold
Exit: long, low <= entry price - simple-candle stop-loss distance OR high >= entry price + simple-candle take-profit distance