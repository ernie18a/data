Calculation: Tracked swing high = the most recent confirmed Pivot High(high, pivot lookback, pivot lookback), confirmed after the right-side pivot lookback has elapsed
Calculation: Tracked swing low = the most recent confirmed Pivot Low(low, pivot lookback, pivot lookback), confirmed after the right-side pivot lookback has elapsed
Calculation: Bullish structure break = a confirmed chart bar closes above the tracked swing high
Calculation: Bearish structure break = a confirmed chart bar closes below the tracked swing low
Calculation: Structural trend = bullish after a bullish structure break, bearish after a bearish structure break, and otherwise unchanged; initially neutral
Calculation: Bullish CHoCH = bullish structure break when the structural trend before that break was bearish
Calculation: Bearish CHoCH = bearish structure break when the structural trend before that break was bullish
Calculation: Bullish BOS = bullish structure break when the structural trend before that break was bullish
Calculation: Bearish BOS = bearish structure break when the structural trend before that break was bearish
Calculation: Bullish sweep = confirmed chart bar low < tracked swing low − ATR(ATR lookback) × sweep wick threshold AND close > tracked swing low AND close > open
Calculation: Bearish sweep = confirmed chart bar high > tracked swing high + ATR(ATR lookback) × sweep wick threshold AND close < tracked swing high AND close < open
Calculation: Recent bullish sweep = bullish sweep on the current or immediately preceding chart bar
Calculation: Recent bearish sweep = bearish sweep on the current or immediately preceding chart bar
Calculation: Dealing range midpoint = (Highest(high, dealing range lookback) + Lowest(low, dealing range lookback)) / 2 on chart bars
Calculation: Higher timeframe fast EMA = EMA(close, fast HTF lookback) on T1 bars, sampled onto chart bars with lookahead off (last completed T1 bar historically; forming T1 bar in realtime)
Calculation: Higher timeframe slow EMA = EMA(close, slow HTF lookback) on T1 bars, sampled onto chart bars with lookahead off (last completed T1 bar historically; forming T1 bar in realtime)
Calculation: TTM Squeeze momentum = Linear regression over the momentum lookback of close − average(average(Highest(high, momentum lookback), Lowest(low, momentum lookback)), SMA(close, momentum lookback))
Calculation: Bull volume estimate = volume × (close − low) / (high − low) when high differs from low; otherwise half of volume
Calculation: Bear volume estimate = volume − bull volume estimate
Calculation: Volume delta = EMA(bull volume estimate, volume smoothing lookback) − EMA(bear volume estimate, volume smoothing lookback)
Calculation: Smoothed volume delta = EMA(volume delta, delta smoothing lookback)
Calculation: OBV slope = OBV(close, volume) − OBV(close, volume)[OBV slope lookback]
Calculation: Bullish volume pressure = volume delta > 0 AND smoothed volume delta > 0 AND OBV slope > 0
Calculation: Bearish volume pressure = volume delta < 0 AND smoothed volume delta < 0 AND OBV slope < 0
Calculation: Long confluence count = count of true conditions among recent bullish sweep, bullish structural trend, (PD filter disabled OR close <= dealing range midpoint), (HTF filter disabled OR higher timeframe fast EMA > higher timeframe slow EMA), TTM Squeeze momentum > 0 and greater than its prior chart-bar value, and bullish volume pressure
Calculation: Short confluence count = count of true conditions among recent bearish sweep, bearish structural trend, (PD filter disabled OR close >= dealing range midpoint), (HTF filter disabled OR higher timeframe fast EMA < higher timeframe slow EMA), TTM Squeeze momentum < 0 and less than its prior chart-bar value, and bearish volume pressure
Calculation: Long setup = recent bullish sweep AND (reversal setups enabled AND bullish CHoCH OR continuation setups enabled AND (bullish BOS OR structural trend is bullish)) AND long confluence count >= minimum layer count AND (ADX filter disabled OR ADX(ADX lookback) >= ADX threshold) AND (session filter disabled OR chart bar is within the configured session) AND (no prior long signal within the configured cooldown) AND (VWAP filter disabled OR close > session VWAP(HLC3))
Calculation: Short setup = recent bearish sweep AND (reversal setups enabled AND bearish CHoCH OR continuation setups enabled AND (bearish BOS OR structural trend is bearish)) AND short confluence count >= minimum layer count AND (ADX filter disabled OR ADX(ADX lookback) >= ADX threshold) AND (session filter disabled OR chart bar is within the configured session) AND (no prior short signal within the configured cooldown) AND (VWAP filter disabled OR close < session VWAP(HLC3))
Long: Bullish sweep
Short: Bearish sweep
Long: Bullish CHoCH
Short: Bearish CHoCH
Long: Bullish BOS
Short: Bearish BOS
Long: Structural trend is bullish
Short: Structural trend is bearish
Long: close <= dealing range midpoint
Short: close > dealing range midpoint
Long: Higher timeframe fast EMA > higher timeframe slow EMA
Short: Higher timeframe fast EMA < higher timeframe slow EMA
Long: TTM Squeeze momentum > 0 AND TTM Squeeze momentum > its prior chart-bar value
Short: TTM Squeeze momentum < 0 AND TTM Squeeze momentum < its prior chart-bar value
Long: Bullish volume pressure
Short: Bearish volume pressure
Long: EMA(close, fast ribbon lookback) > EMA(close, middle ribbon lookback) AND EMA(close, middle ribbon lookback) > EMA(close, signal ribbon lookback) AND close > EMA(close, fast ribbon lookback)
Short: EMA(close, fast ribbon lookback) < EMA(close, middle ribbon lookback) AND EMA(close, middle ribbon lookback) < EMA(close, signal ribbon lookback) AND close < EMA(close, fast ribbon lookback)
Long: Long confluence count >= minimum layer count
Short: Short confluence count >= minimum layer count
Long: Long setup AND NOT long setup on the preceding chart bar
Short: Short setup AND NOT short setup on the preceding chart bar
Calculation: Long stop base = tracked swing low when sweep-anchored stop is enabled and the tracked swing low exists; otherwise the low of the signal bar
Calculation: Short stop base = tracked swing high when sweep-anchored stop is enabled and the tracked swing high exists; otherwise the high of the signal bar
Calculation: Long stop = long stop base at signal time − ATR(ATR lookback) at signal time × stop buffer parameter
Calculation: Short stop = short stop base at signal time + ATR(ATR lookback) at signal time × stop buffer parameter
Calculation: Long first target = signal-bar close + ATR(ATR lookback) at signal time × first-target distance parameter
Calculation: Short first target = signal-bar close − ATR(ATR lookback) at signal time × first-target distance parameter
Calculation: Long final target = signal-bar close + ATR(ATR lookback) at signal time × final-target distance parameter
Calculation: Short final target = signal-bar close − ATR(ATR lookback) at signal time × final-target distance parameter
Calculation: Long trailing stop = initialized at the long stop base at signal time − signal-time ATR(ATR lookback) × trailing distance parameter; on each later chart bar when trailing is enabled, maximum(previous trailing stop, current low − current ATR(ATR lookback) × trailing distance parameter)
Calculation: Short trailing stop = initialized at the short stop base at signal time + signal-time ATR(ATR lookback) × trailing distance parameter; on each later chart bar when trailing is enabled, minimum(previous trailing stop, current high + current ATR(ATR lookback) × trailing distance parameter)
Exit: long, after the entry bar AND high >= long first target AND high < long final target
Exit: short, after the entry bar AND low <= short first target AND low > short final target
Exit: long, after the entry bar AND (low <= long stop OR high >= long final target OR (trailing enabled AND more than one chart bar has elapsed since entry AND low <= long trailing stop))
Exit: short, after the entry bar AND (high >= short stop OR low <= short final target OR (trailing enabled AND more than one chart bar has elapsed since entry AND high >= short trailing stop))