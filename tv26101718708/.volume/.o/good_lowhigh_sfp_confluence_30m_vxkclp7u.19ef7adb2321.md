Calculation: Good Low = a pivot low confirmed by the configured left and right swing lookback, followed by the configured number of bars holding with low <= pivot low + ATR-based tolerance before price leaves that tolerance
Calculation: Good High = a pivot high confirmed by the configured left and right swing lookback, followed by the configured number of bars holding with high >= pivot high - ATR-based tolerance before price leaves that tolerance
Calculation: Bad Low = a confirmed pivot low followed by price leaving above pivot low + ATR-based tolerance before the configured confirmation count is reached
Calculation: Bad High = a confirmed pivot high followed by price leaving below pivot high - ATR-based tolerance before the configured confirmation count is reached
Calculation: Bullish SFP = current low < the lowest low of the configured prior-bar lookback AND current close > that prior lowest low AND the sweep below it is at least the configured fraction of ATR
Calculation: Bearish SFP = current high > the highest high of the configured prior-bar lookback AND current close < that prior highest high AND the sweep above it is at least the configured fraction of ATR
Long: Good Low OR Bad High OR Bullish SFP
Short: Good High OR Bad Low OR Bearish SFP