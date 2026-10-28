Calculation: Hull moving average (HMA) = Hull moving average of close
Calculation: ATR-normalized HMA slope = 100 × (current HMA − prior HMA) / ATR
Calculation: Volatility ratio = ATR / 50-bar simple moving average of ATR
Calculation: Volume-weighted momentum oscillator (VWMO) = smooth the 0–100 normalization of the rolling sum of (close change × volume / momentum-length average volume), using the rolling highest and lowest sums over the normalization window
Calculation: Trend state = flat during a squeeze or when slope is between the bullish and bearish thresholds; otherwise bullish for a bullish slope or bearish for a bearish slope, except a bullish state persists through a bearish slope and vice versa until a squeeze breakout in the new direction
Long: squeeze on prior bar AND no squeeze now AND ATR-normalized HMA slope is bullish
Short: squeeze on prior bar AND no squeeze now AND ATR-normalized HMA slope is bearish
Long: VWMO enters oversold (crosses below an active oversold level)
Short: VWMO enters overbought (crosses above an active overbought level)
Long: VWMO crosses above an active oversold level
Short: VWMO crosses below an active overbought level
Long: bullish trend state OR bullish squeeze breakout AND (VWMO crosses above an active oversold level OR (VWMO > 50 AND rising AND not overbought)) AND close > HMA AND more than the cooldown interval has elapsed since the last confluence signal
Short: bearish trend state OR bearish squeeze breakout AND (VWMO crosses below an active overbought level OR (VWMO < 50 AND falling AND not oversold)) AND close < HMA AND more than the cooldown interval has elapsed since the last confluence signal