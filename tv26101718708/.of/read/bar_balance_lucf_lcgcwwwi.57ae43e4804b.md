Calculation: Up and down intrabar counts = counts of lower-timeframe bars within the current chart bar whose close is respectively above or below their open; apply a configurable weight to qualifying bars in the later half. Use only after the chart bar is complete.
Calculation: Instant balance = up intrabar count − down intrabar count.
Calculation: Average balance = EMA(up intrabar count, longer lookback) − EMA(down intrabar count, same lookback).
Calculation: Momentum balance = RSI(EMA(up count, average-balance lookback) − SMA(up count, twice that lookback) − EMA(down count, average-balance lookback) + SMA(down count, twice that lookback), shorter lookback) − 50.
Calculation: Combined balance = bullish count − bearish count across instant, average, and momentum balances; a balance is bullish if positive and bearish if negative.
Calculation: Up-intrabar proportion = up intrabar count ÷ total intrabar count; down-intrabar proportion = down intrabar count ÷ total intrabar count.
Long: Instant, average, and momentum balances are all bullish.
Short: Instant, average, and momentum balances are all bearish.
Long: Up-intrabar proportion exceeds a configurable threshold AND chart close > open.
Short: Down-intrabar proportion exceeds a configurable threshold AND chart close < open.
Long: On the preceding chart bar, the selected balance (instant, average, momentum, or combined) was bullish while chart close < open; on the current bar chart close > open AND the selected balance does not diverge from price in either direction.
Short: On the preceding chart bar, the selected balance (instant, average, momentum, or combined) was bearish while chart close > open; on the current bar chart close < open AND the selected balance does not diverge from price in either direction.
Long: The selected average, momentum, or combined balance crosses above zero.
Short: The selected average, momentum, or combined balance crosses below zero.
Calculation: Marker bias = sum over a configurable lookback of bullish minus bearish occurrences of the combined-balance agreement, up/down-proportion agreement, price-confirmed divergence, and balance-transition conditions.
Long: Marker bias crossed above zero on the preceding chart bar.
Short: Marker bias crossed below zero on the preceding chart bar.
Calculation: Divergence event = the selected instant, average, momentum, or combined balance is bullish while chart close < open, or bearish while chart close > open; optionally, a neutral-intrabar proportion above one half also counts as a divergence.
Calculation: Divergence levels = running upper and lower levels of the selected balance, initialized and expanded at divergence events; after a level breach, reset both levels to the balance at the next divergence event.
Long: Selected balance rises above its previous upper divergence level for the first time.
Short: Selected balance falls below its previous lower divergence level for the first time.