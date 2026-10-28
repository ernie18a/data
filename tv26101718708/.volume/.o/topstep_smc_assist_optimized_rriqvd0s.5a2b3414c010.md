Calculation: Bullish HTF score = weighted sum of bullish HTF trend, slope, displacement, volume flow, fair value gap, close above prior high, and prime-session conditions, minus penalties for midday, overextension, and bad market conditions; floor at zero
Calculation: Bearish HTF score = corresponding weighted sum of bearish HTF conditions, minus the same penalties; floor at zero
Calculation: HTF overextension = absolute distance between the current HTF close and HTF EMA exceeds a configurable multiple of HTF ATR
Calculation: Bad market conditions = flat EMA slope OR low ATR relative to its moving average OR compressed recent range OR weak candle body OR excessive wick ratio on two consecutive bars
Calculation: HTF bullish setup = HTF close above HTF EMA AND bullish HTF score meets its threshold AND (score is within the allowed score band and exceeds bearish score OR score exceeds the band and is not overextended) AND (countertrend blocking is disabled OR bullish score exceeds bearish score by the dominance buffer)
Calculation: HTF bearish setup = symmetric bearish conditions, using HTF close below HTF EMA and bearish score
Calculation: Micro bullish confirmation = on the micro timeframe, at least one bullish fair value gap, close above prior high, or bullish order block during the kill zone; otherwise at least two
Calculation: Micro bearish confirmation = symmetric bearish conditions, using bearish fair value gap, close below prior low, or bearish order block
Calculation: Strong body = absolute candle body divided by high-low meets its minimum ratio
Calculation: Good follow-through = ATR exceeds its moving average threshold OR recent range exceeds its ATR threshold OR the bar is in the kill zone
Calculation: Bullish trigger = (close above EMA AND EMA slope exceeds its ATR threshold AND (bullish flow OR strong buy pressure)) OR (bullish sweep OR bullish fair value gap OR close above prior high OR bullish order block) AND bullish flow OR micro bullish confirmation
Calculation: Bearish trigger = symmetric bearish conditions, using close below EMA, negative EMA slope, bearish flow or strong sell pressure, bearish sweep, bearish fair value gap, close below prior low, bearish order block, or micro bearish confirmation
Calculation: Bullish sweep = a bar's low falls below the latest confirmed swing low and its close finishes above that swing low; bearish sweep is the inverse using the latest confirmed swing high
Calculation: Bullish order block = previous bar closes below its open and current close exceeds previous high; bearish order block is the inverse
Calculation: Bullish fair value gap = current low exceeds high two bars earlier; bearish fair value gap = current high is below low two bars earlier
Calculation: Bullish flow = up-close bar with volume above its moving average threshold and close above EMA; bearish flow is the inverse. Strong buy/sell pressure uses a higher volume threshold
Calculation: Long stop = entry-signal bar low minus an ATR multiple; long target = entry price plus the stop risk multiplied by a reward-to-risk parameter
Calculation: Short stop = entry-signal bar high plus an ATR multiple; short target = entry price minus the stop risk multiplied by a reward-to-risk parameter
Long: no trade is active AND bar is confirmed when confirmation is enabled AND bar is in the configured session AND HTF bullish setup AND bullish trigger AND strong body AND good follow-through AND NOT bad market conditions AND NOT HTF overextension
Short: no trade is active AND bar is confirmed when confirmation is enabled AND bar is in the configured session AND HTF bearish setup AND bearish trigger AND strong body AND good follow-through AND NOT bad market conditions AND NOT HTF overextension
Exit: long, bar high >= long target OR bar low <= long stop OR bars since entry >= timeout
Exit: short, bar low <= short target OR bar high >= short stop OR bars since entry >= timeout