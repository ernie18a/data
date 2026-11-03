Calculation: Bullish trend = fast HMA is higher than on the prior chart bar AND close is above the longer-lookback WMA
Calculation: Bearish trend = fast HMA is lower than on the prior chart bar AND close is below the longer-lookback WMA
Calculation: Bullish momentum = RSI is above its bullish threshold AND MACD histogram is above zero and higher than on the prior chart bar; MACD uses a shorter fast lookback and a longer slow lookback
Calculation: Bearish momentum = RSI is below its bearish threshold AND MACD histogram is below zero and lower than on the prior chart bar; MACD uses a shorter fast lookback and a longer slow lookback
Calculation: Volume confirmation = volume is greater than its longer-lookback SMA multiplied by a threshold AND the shorter-lookback volume SMA is greater than the longer-lookback volume SMA
Calculation: Volatility confirmation = ATR percentile rank is between its lower and upper thresholds, inclusive
Calculation: Bullish confluence score = count of true conditions among bullish trend, bullish momentum, volume confirmation, and volatility confirmation
Calculation: Bearish confluence score = count of true conditions among bearish trend, bearish momentum, volume confirmation, and volatility confirmation
Long: bullish confluence score >= minimum score AND prior chart bar's bullish confluence score < minimum score AND last signal was not long AND chart bars since the last signal >= cooldown
Short: bearish confluence score >= minimum score AND prior chart bar's bearish confluence score < minimum score AND last signal was not short AND chart bars since the last signal >= cooldown