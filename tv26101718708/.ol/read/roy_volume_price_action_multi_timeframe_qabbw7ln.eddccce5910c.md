Calculation: High volume = volume > its longer-lookback average × a threshold
Calculation: Ultra-high volume = volume > its longer-lookback average × a higher threshold than the high-volume threshold
Calculation: Low volume = volume < its longer-lookback average × a threshold
Calculation: Wide spread = high − low > its longer-lookback average × a threshold
Calculation: Narrow spread = high − low < its longer-lookback average × a threshold
Calculation: Buyer score = weighted sum of bullish candle, close above EMA, high volume, wide spread, stopping volume, no supply, and buy absorption; use the same weights as the paired seller-score components
Calculation: Seller score = weighted sum of bearish candle, close below EMA, high volume, wide spread, upthrust, no demand, and sell absorption; use the same weights as the paired buyer-score components
Calculation: Stopping volume = bearish candle AND ultra-high volume AND lower wick > candle body AND lower wick > upper wick
Calculation: Upthrust = bullish candle AND high volume AND upper wick > candle body × a threshold AND close < high − (high − low) × a threshold
Calculation: No supply = bearish candle AND low volume AND narrow spread
Calculation: No demand = bullish candle AND low volume AND narrow spread
Calculation: Buy absorption = high volume AND bearish candle AND lower wick > candle body AND close > low + (high − low) × a threshold
Calculation: Sell absorption = high volume AND bullish candle AND upper wick > candle body AND close < high − (high − low) × a threshold
Calculation: Buy pressure = bullish candle AND high volume AND wide spread AND close > EMA
Calculation: Sell pressure = bearish candle AND high volume AND wide spread AND close < EMA
Calculation: Buy share = buyer score / (buyer score + seller score)
Calculation: Sell share = seller score / (buyer score + seller score)
Long: (buy pressure OR stopping volume OR no supply OR buy absorption) AND buyer score > seller score AND buy share ≥ a threshold
Short: (sell pressure OR upthrust OR no demand OR sell absorption) AND seller score > buyer score AND sell share ≥ a threshold