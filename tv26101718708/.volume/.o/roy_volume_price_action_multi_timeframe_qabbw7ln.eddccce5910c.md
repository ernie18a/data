Calculation: Bullish candle = close > open; bearish candle = close < open
Calculation: Candle spread = high - low; candle body = |close - open|; upper wick = high - max(open, close); lower wick = min(open, close) - low
Calculation: High volume = volume > 1.5 × its simple moving average; ultra-high volume = volume > 2.3 × its simple moving average; low volume = volume < 0.7 × its simple moving average
Calculation: Wide spread = candle spread > 1.2 × its simple moving average; narrow spread = candle spread < 0.75 × its simple moving average
Calculation: Bullish trend = close > its exponential moving average; bearish trend = close < its exponential moving average
Calculation: No supply = bearish candle AND low volume AND narrow spread
Calculation: No demand = bullish candle AND low volume AND narrow spread
Calculation: Stopping volume = bearish candle AND ultra-high volume AND lower wick > candle body AND lower wick > upper wick
Calculation: Upthrust = bullish candle AND high volume AND upper wick > 1.5 × candle body AND close < high - 0.35 × candle spread
Calculation: Absorption buy = high volume AND bearish candle AND lower wick > candle body AND close > low + 0.5 × candle spread
Calculation: Absorption sell = high volume AND bullish candle AND upper wick > candle body AND close < high - 0.5 × candle spread
Calculation: Buyer score = 20 if bullish candle + 25 if bullish trend + 20 if high volume + 10 if wide spread + 25 if stopping volume + 15 if no supply + 20 if absorption buy; add 0 for each unmet condition
Calculation: Seller score = 20 if bearish candle + 25 if bearish trend + 20 if high volume + 10 if wide spread + 25 if upthrust + 15 if no demand + 20 if absorption sell; add 0 for each unmet condition
Calculation: Buy percentage = buyer score / (buyer score + seller score) × 100, or 50 if both scores are zero; sell percentage = seller score / (buyer score + seller score) × 100, or 50 if both scores are zero; power = max(buy percentage, sell percentage)
Long: (bullish candle AND high volume AND wide spread AND bullish trend OR stopping volume OR no supply OR absorption buy) AND buy percentage > sell percentage AND power ≥ 55
Short: (bearish candle AND high volume AND wide spread AND bearish trend OR upthrust OR no demand OR absorption sell) AND sell percentage > buy percentage AND power ≥ 55