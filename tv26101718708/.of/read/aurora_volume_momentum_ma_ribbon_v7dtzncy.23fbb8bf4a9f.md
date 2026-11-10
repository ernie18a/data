Calculation: Volume momentum = EMA((close - previous close) × volume, momentum smoothing period) / population standard deviation of close over an independently configurable volatility period.
Long: volume >= 0 AND population standard deviation of close > 0 AND volume momentum >= 0
Short: volume >= 0 AND population standard deviation of close > 0 AND volume momentum < 0
Long: volume >= 0 AND population standard deviation of close > 0 AND volume momentum > nonnegative momentum threshold AND close > SMA of close
Short: volume >= 0 AND population standard deviation of close > 0 AND volume momentum < negative of the momentum threshold AND close < SMA of close
Long: an earlier-numbered ribbon moving average > the next numbered ribbon moving average, for any adjacent pair
Short: an earlier-numbered ribbon moving average < the next numbered ribbon moving average, for any adjacent pair
Calculation: Ribbon moving averages = four independently configured EMA, SMA, WMA, RMA, VWMA, or HMA calculations, each with its own length and data source; their numbered order does not require any length ordering.