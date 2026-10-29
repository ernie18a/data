Calculation: Bull/bear moving-average stack = fast moving average > mid > slow / fast < mid < slow, with shorter lookback for fast and longer for slow.
Calculation: VWAP neutral band = ATR × configurable fraction; VWAP direction is bullish when close > VWAP + band and bearish when close < VWAP − band.
Calculation: Momentum direction = whichever side has more bullish or bearish votes; RSI votes bullish at/above its bullish threshold and bearish at/below its bearish threshold; Stochastic RSI votes bullish when %K > %D and %K > midpoint, bearish when %K < %D and %K < midpoint.
Calculation: Timeframe bias = bullish if at least two of the moving-average stack, RSI vote, and Stochastic RSI vote are bullish and bullish votes exceed bearish votes; bearish by the symmetric condition; otherwise neutral. Apply to each of eight configured timeframes, which may be lower or higher than the chart timeframe; use the available security value (completed higher-timeframe bars historically and the forming bar in realtime).
Calculation: Multi-timeframe direction = bullish when bullish timeframe biases meet the configured minimum and outnumber bearish timeframe biases; bearish by the symmetric condition; otherwise neutral.
Calculation: Structure direction = bullish after close exceeds the latest confirmed pivot high, bearish after close falls below the latest confirmed pivot low; retain the last break direction until the opposite break.
Calculation: Session sweep direction = bullish after price sweeps below the selected session low, bearish after price sweeps above its high; retain the last sweep direction until reset or the opposite sweep. Selected session is Asia or the active session.
Calculation: Hybrid direction = sum of enabled component directions (trend, VWAP, momentum, structure, multi-timeframe, session; bullish = +1, bearish = −1, neutral = 0); bullish at/above the minimum directional score, bearish at/below its negative, otherwise neutral. Selected direction is the chosen mode's direction: hybrid, trend, VWAP, momentum, structure, multi-timeframe, or session sweep.
Long: fast moving average > mid moving average AND mid moving average > slow moving average
Long: close > VWAP + ATR × configurable neutral-band fraction
Long: RSI ≥ bullish threshold AND RSI > bearish threshold
Long: Stochastic RSI %K > %D AND %K > midpoint
Long: at least two bullish votes among moving-average stack, RSI, and Stochastic RSI AND bullish votes > bearish votes
Long: bullish timeframe biases ≥ configured minimum AND bullish timeframe biases > bearish timeframe biases
Long: close > latest confirmed pivot high
Long: price sweeps below selected session low
Long: hybrid direction ≥ minimum directional score
Long: selected direction is bullish AND absolute enabled-component directional score / enabled-component count × 100 ≥ configured neutral-strength percentage
Short: fast moving average < mid moving average AND mid moving average < slow moving average
Short: close < VWAP − ATR × configurable neutral-band fraction
Short: RSI ≤ bearish threshold AND RSI < bullish threshold
Short: Stochastic RSI %K < %D AND %K < midpoint
Short: at least two bearish votes among moving-average stack, RSI, and Stochastic RSI AND bearish votes > bullish votes
Short: bearish timeframe biases ≥ configured minimum AND bearish timeframe biases > bullish timeframe biases
Short: close < latest confirmed pivot low
Short: price sweeps above selected session high
Short: hybrid direction ≤ negative minimum directional score
Short: selected direction is bearish AND absolute enabled-component directional score / enabled-component count × 100 ≥ configured neutral-strength percentage