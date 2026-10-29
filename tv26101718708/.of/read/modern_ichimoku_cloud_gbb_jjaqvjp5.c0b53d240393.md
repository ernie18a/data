Calculation: Tenkan-sen = midpoint of the highest high and lowest low over the short Ichimoku lookback
Calculation: Kijun-sen = midpoint of the highest high and lowest low over a longer Ichimoku lookback than Tenkan-sen
Calculation: Senkou A = midpoint of Tenkan-sen and Kijun-sen
Calculation: Senkou B = midpoint of the highest high and lowest low over a longer Ichimoku lookback than Kijun-sen
Calculation: Current cloud = Senkou A and Senkou B from the chart bars `displacement - 1` bars earlier
Calculation: Price-to-cloud distance = signed distance from close to the nearest cloud edge, divided by ATR; positive above the cloud, negative below it, and zero inside it
Calculation: Chikou momentum = (close - close from `displacement - 1` chart bars earlier) / ATR
Long: Tenkan-sen crosses above Kijun-sen OR close crosses above the current cloud's upper edge OR Senkou A crosses above Senkou B
Long: (Tenkan-sen crosses above Kijun-sen OR close crosses above the current cloud's upper edge) AND close > open AND (abs(price-to-cloud distance) >= minimum distance for a cloud breakout OR price-to-cloud distance != 0 for a Tenkan/Kijun cross) AND Chikou momentum > 0 AND abs(Chikou momentum) >= minimum Chikou momentum AND (higher-timeframe cloud filter disabled OR close on the last completed higher-timeframe bar is above that bar's cloud)
Short: Tenkan-sen crosses below Kijun-sen OR close crosses below the current cloud's lower edge OR Senkou A crosses below Senkou B
Short: (Tenkan-sen crosses below Kijun-sen OR close crosses below the current cloud's lower edge) AND close < open AND (abs(price-to-cloud distance) >= minimum distance for a cloud breakout OR price-to-cloud distance != 0 for a Tenkan/Kijun cross) AND Chikou momentum < 0 AND abs(Chikou momentum) >= minimum Chikou momentum AND (higher-timeframe cloud filter disabled OR close on the last completed higher-timeframe bar is below that bar's cloud)