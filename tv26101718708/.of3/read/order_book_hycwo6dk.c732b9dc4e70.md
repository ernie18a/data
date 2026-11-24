Calculation: buy volume = if T1 is shorter than the chart timeframe, the sum of volume of the T1 bars inside the current chart bar whose close >= open; otherwise the volume of the current chart bar if its close >= open, else 0
Calculation: sell volume = if T1 is shorter than the chart timeframe, the sum of volume of the T1 bars inside the current chart bar whose close < open; otherwise the volume of the current chart bar if its close < open, else 0
Calculation: DOM pressure = (volume weight * ((buy volume - sell volume) / max(buy volume + sell volume, minimum volume)) + close position weight * (((close - low) / max(high - low, minimum range)) - 0.5) + body weight * ((close - open) / max(high - low, minimum range))) * power
Long: buy volume >= sell volume
Short: buy volume < sell volume
Long: buy volume > sell volume * strong ratio
Short: sell volume > buy volume * strong ratio
Long: DOM pressure > threshold
Short: DOM pressure < -threshold
Long: CVD(buy volume, sell volume) >= 0
Short: CVD(buy volume, sell volume) < 0