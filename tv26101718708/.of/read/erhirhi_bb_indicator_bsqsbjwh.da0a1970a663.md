Calculation: BB %B = (close - (SMA(close,L) - 2 × StDev(close,L))) / (4 × StDev(close,L))
Calculation: BB %B adjusted SMA = -SMA(BB %B,S)
Calculation: KDJ K = RMA((close - lowest(low,R)) / (highest(high,R) - lowest(low,R)),K)
Calculation: %Range = (close - highest(high,L)) / (highest(high,L) - lowest(low,L))
Calculation: FG score = (average(clamp(KDJ K,0,P) × P/3, clamp(BB %B,0,P) × P/3, clamp(%Range,0,P) × P/3) - 8) / 10
Long: FG score < -0.6 OR (BB %B > BB %B adjusted SMA AND previous-bar BB %B <= previous-bar BB %B adjusted SMA)
Short: FG score >= 1.24 OR %Range > -0.05 OR BB %B - 1 > FG score