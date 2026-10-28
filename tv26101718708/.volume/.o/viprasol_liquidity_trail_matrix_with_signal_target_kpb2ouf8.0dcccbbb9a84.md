Calculation: ATR trail bands = source price ± ATR × four increasing band multipliers; maintain four ratcheting trailing bands in the current trend direction, reset them on a trend flip
Calculation: Trend flip = source price crosses the previous completed bar’s selected trailing band; bullish when above in a downtrend, bearish when below in an uptrend
Calculation: RSI regime = RSI within the bull or bear range AND price above or below its trend moving average, respectively, for the required consecutive bars
Calculation: Retest score = weighted score for deepest band touched, reclaim candle close location, trend age, current volume versus the previous bar’s volume average, higher-timeframe bias, and optionally RSI regime; normalize when RSI regime scoring is enabled
Calculation: Higher-timeframe bias = previous completed higher-timeframe close compared with its 50-period EMA
Calculation: Retest depth = deepest of four trailing bands touched during the pending retest window
Calculation: Reclaim = after a band touch, close back beyond band 1 in the trend direction with a candle closing in that direction
Calculation: Stop = signal-bar wick plus an ATR buffer, enforcing a minimum ATR distance; alternatively, entry price plus or minus an ATR-based risk distance
Calculation: Risk = absolute distance between entry price and stop; targets 1, 2, and 3 = entry price plus (long) or minus (short) risk multiplied by each target’s risk multiple
Long: confirmed bullish trend flip OR confirmed bullish retest reclaim with minimum score met; apply confirmed bull RSI regime and ADX minimum when the RSI hard filter is enabled
Short: confirmed bearish trend flip OR confirmed bearish retest reclaim with minimum score met; apply confirmed bear RSI regime and ADX minimum when the RSI hard filter is enabled
Exit: long, after entry bar, low <= active stop OR high >= target 3 OR enabled trade-duration limit reached; after target 1, move stop to entry when break-even is enabled; close and reverse on an opposite signal when reversal is enabled
Exit: short, after entry bar, high >= active stop OR low <= target 3 OR enabled trade-duration limit reached; after target 1, move stop to entry when break-even is enabled; close and reverse on an opposite signal when reversal is enabled