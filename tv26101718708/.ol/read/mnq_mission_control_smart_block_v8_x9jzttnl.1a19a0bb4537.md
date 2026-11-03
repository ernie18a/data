Calculation: Fast EMA = exponential moving average of close using the shorter of the two EMA lookbacks
Calculation: Slow EMA = exponential moving average of close using the longer of the two EMA lookbacks
Calculation: Trend EMA = exponential moving average of close using a longer lookback than the fast and slow EMAs
Calculation: Bullish reversal event count = number of these four upward crosses within the reversal lookback: close above fast EMA, fast EMA above slow EMA, fast EMA above trend EMA, close above trend EMA
Calculation: Bearish reversal event count = number of these four downward crosses within the reversal lookback: close below fast EMA, fast EMA below slow EMA, fast EMA below trend EMA, close below trend EMA
Calculation: Most recent reversal event = the smallest number of bars ago among the four corresponding crosses
Calculation: Bullish held-bar count = consecutive bars since a bullish reversal formed that close above the slow EMA
Calculation: Bearish held-bar count = consecutive bars since a bearish reversal formed that close below the slow EMA
Calculation: Bullish held pullback = after a bullish reversal forms, within the pullback lookback, a bar's low reaches the slow EMA plus a small ATR-based buffer and closes above the slow EMA
Calculation: Bearish held pullback = after a bearish reversal forms, within the pullback lookback, a bar's high reaches the slow EMA minus a small ATR-based buffer and closes below the slow EMA
Long: On 5-minute signal bars (higher than the chart timeframe if it is below 5 minutes, lower if above; use the current bar, including while forming), bullish reversal event count meets its minimum and either bearish reversal event count is below its minimum or the most recent bullish reversal event is at least as recent as the most recent bearish reversal event
Long: Bullish reversal is active AND (bullish held-bar count meets its minimum OR bullish held pullback)
Short: On 5-minute signal bars (higher than the chart timeframe if it is below 5 minutes, lower if above; use the current bar, including while forming), bearish reversal event count meets its minimum and either bullish reversal event count is below its minimum or the most recent bearish reversal event is more recent than the most recent bullish reversal event
Short: Bearish reversal is active AND (bearish held-bar count meets its minimum OR bearish held pullback)