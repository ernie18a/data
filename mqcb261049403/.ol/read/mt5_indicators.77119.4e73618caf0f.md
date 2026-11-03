Calculation: Candle range = high − low; if zero, use a positive minimum range
Calculation: Body, upper wick, lower wick = absolute close−open, high−max(open,close), min(open,close)−low, respectively
Calculation: Body, upper-wick, and lower-wick percentages = each measure divided by candle range × 100
Calculation: Bullish candle = close ≥ open; bearish candle = close < open
Calculation: Volume average = moving average of volume over a lookback
Calculation: High volume = volume > volume average × high-volume multiplier; ultra volume = volume > volume average × ultra-volume multiplier; low volume = volume < volume average × low-volume multiplier
Calculation: Spread average = moving average of high−low over a shorter lookback than the volume-average lookback
Calculation: Bull pin = body percentage ≤ pin-body limit AND lower-wick percentage ≥ pin-wick limit; bear pin = body percentage ≤ pin-body limit AND upper-wick percentage ≥ pin-wick limit
Long: Bull pin AND (high volume OR ultra volume) OR bearish candle AND lower-wick percentage ≥ 25 AND (high volume OR ultra volume) OR bearish candle AND (high volume OR ultra volume) AND body percentage < 30 OR bearish candle AND ultra volume AND close > low + 0.4 × candle range OR bull pin AND volume < each of the prior two bars' volumes OR bearish candle AND low volume AND volume < each of the prior two bars' volumes OR bearish candle AND candle range > spread average AND low volume OR bull pin
Short: Bear pin AND (high volume OR ultra volume) OR bullish candle AND upper-wick percentage ≥ 25 AND (high volume OR ultra volume) OR bullish candle AND (high volume OR ultra volume) AND body percentage < 30 OR bull pin AND (high volume OR ultra volume) AND high ≥ prior bar high OR bullish candle AND ultra volume AND close < high − 0.4 × candle range OR bear pin AND volume < each of the prior two bars' volumes OR bullish candle AND low volume AND volume < each of the prior two bars' volumes OR bullish candle AND candle range > spread average AND low volume OR bear pin
Exit: long, weakness signal OR close < trailing SAR level
Exit: short, strength signal OR close > trailing SAR level