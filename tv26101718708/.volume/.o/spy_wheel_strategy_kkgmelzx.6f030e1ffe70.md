Calculation: 200-day SMA = simple average of the current and preceding 199 daily closes, including the current bar
Calculation: 20-day EMA = exponential moving average of daily closes, including the current bar
Calculation: Covered-call strike = round close × (1 + selected out-of-the-money percentage) up to the next $1; use a wider percentage when VIX is at or above its threshold, otherwise use the narrower percentage
Long: flat AND (first bar on or after the strategy start date OR the bar after covered-call assignment OR previously exited after consecutive closes below the 200-day SMA AND close > 200-day SMA)
Long: flat after covered-call assignment AND all of the following: close > 200-day SMA AND close > 20-day EMA AND RSI outside its blocked band AND VIX below its threshold AND (VWAP gate disabled OR close >= VWAP) AND macro-event block off AND low <= round open × (1 − put out-of-the-money percentage) down to the next $1
Exit: long, consecutive daily closes below the 200-day SMA reach the configured breach count
Exit: long, close > the applicable covered-call strike AND that strike >= entry price