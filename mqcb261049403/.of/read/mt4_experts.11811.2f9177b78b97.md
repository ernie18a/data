Calculation: Long trailing stop = highest eligible chart-bar open since entry minus the long trailing distance; an open is eligible only when it exceeds entry price by more than that distance. The stop is inactive until an eligible open occurs.
Calculation: Short trailing stop = lowest eligible chart-bar open since entry plus the short trailing distance; an open is eligible only when it is below entry price by more than that distance. The stop is inactive until an eligible open occurs.
Long: Positive directional indicator > negative directional indicator, calculated on the forming chart-timeframe bar AND (trading-time filter disabled OR start hour ≤ bar hour ≤ end hour)
Short: Negative directional indicator > positive directional indicator, calculated on the forming chart-timeframe bar AND (trading-time filter disabled OR start hour ≤ bar hour ≤ end hour)
Exit: long, negative directional indicator > positive directional indicator, calculated on the forming chart-timeframe bar AND hedging disabled AND (trading-time filter disabled OR start hour ≤ bar hour ≤ end hour)
Exit: short, positive directional indicator > negative directional indicator, calculated on the forming chart-timeframe bar AND hedging disabled AND (trading-time filter disabled OR start hour ≤ bar hour ≤ end hour)
Exit: long, trading-time filter enabled AND close outside trading hours enabled AND (bar hour < start hour OR bar hour > end hour)
Exit: short, trading-time filter enabled AND close outside trading hours enabled AND (bar hour < start hour OR bar hour > end hour)
Exit: long, long stop-loss distance > 0 AND low ≤ entry price minus long stop-loss distance
Exit: long, long take-profit distance > 0 AND high ≥ entry price plus long take-profit distance
Exit: short, short stop-loss distance > 0 AND high ≥ entry price plus short stop-loss distance
Exit: short, short take-profit distance > 0 AND low ≤ entry price minus short take-profit distance
Exit: long, long trailing distance > 0 AND long trailing stop active AND low ≤ long trailing stop
Exit: short, short trailing distance > 0 AND short trailing stop active AND high ≥ short trailing stop