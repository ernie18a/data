Calculation: Momentum Z-score = (current close change − 50-bar mean of close changes) / standard deviation of close changes over 50 bars; use 0 if the standard deviation is 0
Calculation: Candle body ratio = abs(close − open) / (high − low); use 0 if high = low
Calculation: Volume ratio = volume / 20-bar simple moving average of volume; use 1 if the average is 0
Calculation: Bullish/bearish swing level = latest confirmed pivot high/low, with the configured number of bars on both sides; confirmation uses chart-timeframe bars
Calculation: Bullish/bearish confluence score = clamp to 0–100 the sum of: 30 for bullish/bearish MSB, otherwise 20 for bullish/bearish BMS, otherwise 0; 20 for matching liquidity sweep; 18 for at least 2 nearby matching unmitigated HPZ order blocks or 10 for 1; 10 for at least 2 unfilled opposite-direction FVGs beyond price or 5 for 1; momentum points (bull: 12 if Z>2, 7 if Z>1, 3 if Z>0.5; bear: 12 if Z<−2, 7 if Z<−1, 3 if Z<−0.5); volume points (8 if ratio>2, 5 if >1.3, 2 if >1); 6 for a matching-direction candle with body ratio>0.6 or 3 for any matching-direction candle; minus 10 for opposing momentum beyond 1 standard deviation and minus 8 for at least 2 nearby opposing HPZ order blocks. Nearby means within 2 ATR(14) of close. An unfilled bullish FVG is beyond price when its top is below close; an unfilled bearish FVG is beyond price when its bottom is above close.
Calculation: Bullish/bearish liquidity sweep level = lowest low/highest high of the preceding configured lookback bars
Calculation: Bullish/bearish fair value gap = current low − high two bars earlier / low two bars earlier − current high, respectively; the gap must be at least ATR(14) times the configured minimum-size factor
Long: close crosses above the latest confirmed swing high (previous close ≤ level), momentum Z-score > configured threshold
Long: close crosses above the latest confirmed swing high (previous close ≤ level), candle body ratio > 0.5
Long: current low < preceding lookback lowest low AND close > that lowest low AND close > open
Long: current low > high two bars earlier AND current low − high two bars earlier ≥ ATR(14) × configured minimum-size factor
Long: confluence score ≥ configured minimum AND (bullish MSB OR bullish liquidity sweep) AND volume filter disabled OR volume ratio ≥ configured minimum when enabled AND same-direction cooldown elapsed
Short: close crosses below the latest confirmed swing low (previous close ≥ level), momentum Z-score < negative configured threshold
Short: close crosses below the latest confirmed swing low (previous close ≥ level), candle body ratio > 0.5
Short: current high > preceding lookback highest high AND close < that highest high AND close < open
Short: current high < low two bars earlier AND low two bars earlier − current high ≥ ATR(14) × configured minimum-size factor
Short: confluence score ≥ configured minimum AND (bearish MSB OR bearish liquidity sweep) AND volume filter disabled OR volume ratio ≥ configured minimum when enabled AND same-direction cooldown elapsed
Exit: long, bearish MSB
Exit: short, bullish MSB
Exit: long, bullish confluence score < configured minimum
Exit: short, bearish confluence score < configured minimum