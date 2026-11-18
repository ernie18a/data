Calculation: Momentum(n) = (MACD(close, shorter lookback, longer lookback)[n] - MACD(close, shorter lookback, longer lookback)[n+1]) * sensitivity, where MACD is the main line computed on T1 bars, [n] counts T1 bars back, and n=0 is the still-forming T1 bar
Calculation: BandWidth(n) = BollingerUpper(close, band lookback, band deviation)[n] - BollingerLower(close, band lookback, band deviation)[n], where Bollinger bands are computed on T1 bars, [n] counts T1 bars back, and n=0 is the still-forming T1 bar
Calculation: Threshold = dead-zone parameter * point size
Long: Momentum(0) > BandWidth(0) AND BandWidth(0) > Threshold AND BandWidth(0) > BandWidth(1) AND Momentum(0) > Momentum(2)
Short: Momentum(0) < 0 AND Abs(Momentum(0)) > BandWidth(0) AND BandWidth(0) > Threshold AND BandWidth(0) > BandWidth(1) AND Abs(Momentum(0)) > Abs(Momentum(2))
Exit: long, Momentum(0) > Threshold AND Momentum(0) < BandWidth(0) AND Momentum(0) < Momentum(2) AND Momentum(2) > BandWidth(1)
Exit: short, Momentum(0) < 0 AND Momentum(0) > Threshold AND Abs(Momentum(0)) < BandWidth(0) AND Abs(Momentum(0)) < Abs(Momentum(2)) AND Abs(Momentum(2)) > BandWidth(1)