Calculation: Confirmed bull tier = 3 if A and B and C; else 2 if A and B; else 1 if A; else 0, where A = the last two completed T1 HA candles are both bullish (close >= open), B = the last completed T2 HA candle is bullish (close >= open), C = that T2 candle has body > 0 and lower wick <= tick size
Calculation: Confirmed bear tier = 3 if A and B and C; else 2 if A and B; else 1 if A; else 0, where A = the last two completed T1 HA candles are both bearish (close < open), B = the last completed T2 HA candle is bearish (close < open), C = that T2 candle has body > 0 and upper wick <= tick size
Calculation: Live bull tier = Confirmed bull tier if the forming T1 HA candle is bullish (close >= open), else 0
Calculation: Live bear tier = Confirmed bear tier if the forming T1 HA candle is bearish (close < open), else 0
Calculation: Gated bull tier = Confirmed bull tier if the kill switch is disabled or the forming T1 HA candle is bullish (close >= open), else 0
Calculation: Gated bear tier = Confirmed bear tier if the kill switch is disabled or the forming T1 HA candle is bearish (close < open), else 0
Calculation: Bull gate = Confirmed bull tier >= minimum tier AND (QuadCore filter disabled OR QuadCore all-oversold on the previous bar)
Calculation: Bear gate = Confirmed bear tier >= minimum tier AND (QuadCore filter disabled OR QuadCore all-overbought on the previous bar)
Calculation: RSI_HA = RSI(HA close, RSI length)
Calculation: RSI_C = RSI(close, RSI length C)
Calculation: RSI_T = RSI(close, TDI RSI length)
Calculation: Stoch_A = Stochastic %K(Stoch lookback A)
Calculation: Stoch_B = Stochastic %K(Stoch lookback B), where lookback B is longer than lookback A
Calculation: Quad_i = SMA(Stochastic %K(K lookback i), D length i) for i = 1 to 4, where K lookback increases with i so Quad_4 is the slowest
Calculation: QuadCore all-oversold = Quad_1 through Quad_4 are all below QuadCore oversold level; QuadCore all-overbought = Quad_1 through Quad_4 are all above QuadCore overbought level
Calculation: WT_line = EMA(CI, WT average length), where CI = (hlc3 - EMA(hlc3, WT channel length)) / (0.015 x EMA(abs(hlc3 - EMA(hlc3, WT channel length)), WT channel length))
Calculation: WT_signal = SMA(WT_line, WT signal length)
Calculation: TDI signal = SMA(RSI_T, TDI signal length)
Calculation: TDI upper band = SMA(RSI_T, TDI band length) + TDI band multiplier x stdev(RSI_T, TDI band length)
Calculation: TDI lower band = SMA(RSI_T, TDI band length) - TDI band multiplier x stdev(RSI_T, TDI band length)
Calculation: Pure candle state(T) = 1 if the last two completed regular (non-HA) T candles are both bullish (close > open) with body > 0 and lower wick <= tick size, and the newer body is strictly larger than the older; -1 if both are bearish (close < open) with body > 0 and upper wick <= tick size, and the newer body is strictly larger than the older; else 0
Calculation: VMC long zone = (zone filter disabled OR Stoch_A and Stoch_B both <= zone low level) AND (RSI filter disabled OR RSI_C[1] < VMC RSI low level) AND (K-D filter disabled OR Stoch_B[1] < RSI_C[1] AND Stoch_A[1] < RSI_C[1])
Calculation: VMC short zone = (zone filter disabled OR Stoch_A and Stoch_B both >= zone high level) AND (RSI filter disabled OR RSI_C[1] > VMC RSI high level) AND (K-D filter disabled OR Stoch_B[1] > RSI_C[1] AND Stoch_A[1] > RSI_C[1])
Calculation: Bullish WaveTrend divergence = WT_signal three bars ago is strictly below WT_signal one, two, four and five bars ago, is <= bullish divergence level, its low is below the low at the previous bar meeting the same two conditions, and its WT_signal is above WT_signal at that previous bar
Calculation: Bearish WaveTrend divergence = WT_signal three bars ago is strictly above WT_signal one, two, four and five bars ago, is >= bearish divergence level, its high is above the high at the previous bar meeting the same two conditions, and its WT_signal is below WT_signal at that previous bar
Calculation: Bullish RSI divergence = a pivot low was confirmed on the previous bar (lowest low within pivot lookback bars on each side), the latest pivot low was confirmed within max pivot gap bars, its low is below the previous pivot low's low, and RSI_HA at its bar is above RSI_HA at the previous pivot's bar
Calculation: Bearish RSI divergence = a pivot high was confirmed on the previous bar (highest high within pivot lookback bars on each side), the latest pivot high was confirmed within max pivot gap bars, its high is above the previous pivot high's high, and RSI_HA at its bar is below RSI_HA at the previous pivot's bar
Calculation: Quad bull divergence on Quad_i = a pivot low of Quad_i is confirmed on the current bar (lowest Quad_i value within QuadCore pivot lookbacks left and right, ties allowed) with Quad_i below QuadCore oversold level, and an earlier pivot low of Quad_i between min and max bars before it has Quad_i below QuadCore oversold level, a lower Quad_i value, and a higher price low than the current pivot
Calculation: Quad bear divergence on Quad_i = a pivot high of Quad_i is confirmed on the current bar (highest Quad_i value within QuadCore pivot lookbacks left and right, ties allowed) with Quad_i above QuadCore overbought level, and an earlier pivot high of Quad_i between min and max bars before it has Quad_i above QuadCore overbought level, a higher Quad_i value, and a lower price high than the current pivot
Calculation: QuadCore bull signal = the number of enabled Quad_i with a bull divergence on the previous bar is >= minimum agreeing stochastics, AND more than cooldown bars have passed since the last bar on which this was true
Calculation: QuadCore bear signal = the number of enabled Quad_i with a bear divergence on the previous bar is >= minimum agreeing stochastics, AND more than cooldown bars have passed since the last bar on which this was true
Calculation: Bullish WAR formation = over the last N completed chart candles, each is bullish (close > open) with open - low <= wick tolerance; each newer body is strictly larger than the older body; each newer high - close is strictly larger than the older one; the newest high of each three consecutive candles is >= 2 x middle high - oldest high; and this holds now but did not hold one bar earlier
Calculation: Bearish WAR formation = over the last N completed chart candles, each is bearish (close < open) with high - open <= wick tolerance; each newer body is strictly larger than the older body; each newer close - low is strictly larger than the older one; the newest low of each three consecutive candles is <= 2 x middle low - oldest low; and this holds now but did not hold one bar earlier
Calculation: Repeat block = repeat blocking enabled AND a tracked trade of the same signal type and side is open, has not reached win target 1 since its entry (long: high >= entry x (1 + win target 1 %) not yet reached; short: low <= entry x (1 - win target 1 %) not yet reached), and has not hit its stop; a tracked trade's entry is the open of the bar its decision fired on
Long: crosses above(SMA(RSI_HA, shorter smoothing length), SMA(RSI_HA, longer smoothing length))[1] AND RSI_HA < RSI midline AND Bull gate AND NOT Repeat block
Short: crosses below(SMA(RSI_HA, shorter smoothing length), SMA(RSI_HA, longer smoothing length))[1] AND RSI_HA > RSI midline AND Bear gate AND NOT Repeat block
Long: Bullish RSI divergence AND Bull gate AND NOT Repeat block
Short: Bearish RSI divergence AND Bear gate AND NOT Repeat block
Long: crosses above(WT_line, WT_signal)[1] AND WT_signal[1] <= VMC oversold level AND VMC long zone AND Bull gate AND NOT Repeat block
Short: crosses below(WT_line, WT_signal)[1] AND WT_signal[1] >= VMC overbought level AND VMC short zone AND Bear gate AND NOT Repeat block
Long: Bullish WaveTrend divergence AND VMC long zone AND Bull gate AND NOT Repeat block
Short: Bearish WaveTrend divergence AND VMC short zone AND Bear gate AND NOT Repeat block
Long: Supertrend bullish[1] AND NOT Supertrend bullish[2] AND Bull gate AND NOT Repeat block
Short: Supertrend bearish[1] AND NOT Supertrend bearish[2] AND Bear gate AND NOT Repeat block
Long: crosses above(Stoch_A, RSI_C)[1] AND (RSI filter disabled OR RSI_C[1] < Stoch_A-cross RSI low level) AND Bull gate AND NOT Repeat block
Short: crosses below(Stoch_A, RSI_C)[1] AND (RSI filter disabled OR RSI_C[1] > Stoch_A-cross RSI high level) AND Bear gate AND NOT Repeat block
Long: crosses above(Stoch_B, RSI_C)[1] AND (extreme filter disabled OR RSI_C[1] < Stoch_B extreme overbought level) AND Bull gate AND NOT Repeat block
Short: crosses below(Stoch_B, RSI_C)[1] AND (extreme filter disabled OR RSI_C[1] > Stoch_B extreme oversold level) AND Bear gate AND NOT Repeat block
Long: Pure candle state(T1)[1] = 1 AND Pure candle state(T2)[1] = 1 AND NOT (Pure candle state(T1)[2] = 1 AND Pure candle state(T2)[2] = 1) AND NOT Repeat block
Short: Pure candle state(T1)[1] = -1 AND Pure candle state(T2)[1] = -1 AND NOT (Pure candle state(T1)[2] = -1 AND Pure candle state(T2)[2] = -1) AND NOT Repeat block
Long: QuadCore all-oversold[2] AND NOT QuadCore all-oversold[1] AND chart HA candle[1] bullish (HA close > HA open) AND (background requirement disabled OR Confirmed bull tier >= minimum tier) AND NOT Repeat block
Short: QuadCore all-overbought[2] AND NOT QuadCore all-overbought[1] AND chart HA candle[1] bearish (HA close < HA open) AND (background requirement disabled OR Confirmed bear tier >= minimum tier) AND NOT Repeat block
Long: TDI signal[2] <= TDI upper band[2] AND TDI signal[1] > TDI upper band[1] AND (extreme filter disabled OR TDI signal[1] < TDI extreme overbought level) AND (background requirement disabled OR Confirmed bull tier >= minimum tier) AND NOT Repeat block
Short: TDI signal[2] >= TDI lower band[2] AND TDI signal[1] < TDI lower band[1] AND (extreme filter disabled OR TDI signal[1] > TDI extreme oversold level) AND (background requirement disabled OR Confirmed bear tier >= minimum tier) AND NOT Repeat block
Long: Quad_4[2] <= QuadCore oversold level AND Quad_4[1] > QuadCore oversold level AND (rising filter disabled OR Quad_1 through Quad_4 each rose from [2] to [1]) AND (background requirement disabled OR Confirmed bull tier >= minimum tier) AND NOT Repeat block
Short: Quad_4[2] >= QuadCore overbought level AND Quad_4[1] < QuadCore overbought level AND (falling filter disabled OR Quad_1 through Quad_4 each fell from [2] to [1]) AND (background requirement disabled OR Confirmed bear tier >= minimum tier) AND NOT Repeat block
Long: Bullish WAR formation AND (background requirement disabled OR Confirmed bull tier >= minimum tier) AND NOT Repeat block
Short: Bearish WAR formation AND (background requirement disabled OR Confirmed bear tier >= minimum tier) AND NOT Repeat block
Long: QuadCore bull signal AND Bull gate AND NOT Repeat block
Short: QuadCore bear signal AND Bear gate AND NOT Repeat block
Long: Gated bull tier >= 1
Short: Gated bear tier >= 1
Long: QuadCore all-oversold AND (candle-color background match disabled OR Gated bull tier >= minimum tier)
Short: QuadCore all-overbought AND (candle-color background match disabled OR Gated bear tier >= minimum tier)
Long: Live bull tier >= 1 AND Live bull tier[1] = 0
Long: Live bull tier >= 3 AND Live bull tier[1] < 3
Exit: long, Live bull tier = 0 AND Live bull tier[1] > 0
Short: Live bear tier >= 1 AND Live bear tier[1] = 0
Short: Live bear tier >= 3 AND Live bear tier[1] < 3
Exit: short, Live bear tier = 0 AND Live bear tier[1] > 0
Long: Bull gate AND Confirmed bull tier[1] >= minimum tier AND (any long signal entry above other than background and candle-color markings, without its Repeat block)
Short: Bear gate AND Confirmed bear tier[1] >= minimum tier AND (any short signal entry above other than background and candle-color markings, without its Repeat block)
Long: crosses above(SMA(RSI_HA, shorter smoothing length), SMA(RSI_HA, longer smoothing length)) on the forming bar AND RSI_HA < RSI midline AND Bull gate
Short: crosses below(SMA(RSI_HA, shorter smoothing length), SMA(RSI_HA, longer smoothing length)) on the forming bar AND RSI_HA > RSI midline AND Bear gate
Long: crosses above(WT_line, WT_signal) on the forming bar AND WT_signal <= VMC oversold level AND Stoch_A <= zone low level AND Stoch_B <= zone low level AND (RSI filter disabled OR RSI_C < VMC RSI low level) AND (K-D filter disabled OR Stoch_B < RSI_C AND Stoch_A < RSI_C) AND Bull gate
Short: crosses below(WT_line, WT_signal) on the forming bar AND WT_signal >= VMC overbought level AND Stoch_A >= zone high level AND Stoch_B >= zone high level AND (RSI filter disabled OR RSI_C > VMC RSI high level) AND (K-D filter disabled OR Stoch_B > RSI_C AND Stoch_A > RSI_C) AND Bear gate
Long: Supertrend bullish AND NOT Supertrend bullish[1] AND Bull gate
Short: Supertrend bearish AND NOT Supertrend bearish[1] AND Bear gate
Long: crosses above(Stoch_A, RSI_C) on the forming bar AND (RSI filter disabled OR RSI_C[1] < Stoch_A-cross RSI low level) AND Bull gate
Short: crosses below(Stoch_A, RSI_C) on the forming bar AND (RSI filter disabled OR RSI_C[1] > Stoch_A-cross RSI high level) AND Bear gate
Long: crosses above(Stoch_B, RSI_C) on the forming bar AND (extreme filter disabled OR RSI_C[1] < Stoch_B extreme overbought level) AND Bull gate
Short: crosses below(Stoch_B, RSI_C) on the forming bar AND (extreme filter disabled OR RSI_C[1] > Stoch_B extreme oversold level) AND Bear gate
Exit: long, low <= entry x (1 - stop %)
Exit: short, high >= entry x (1 + stop %)
Exit: long, high >= entry x (1 + largest of win target 1 %, win target 2 %, win target 3 %)
Exit: short, low <= entry x (1 - largest of win target 1 %, win target 2 %, win target 3 %)