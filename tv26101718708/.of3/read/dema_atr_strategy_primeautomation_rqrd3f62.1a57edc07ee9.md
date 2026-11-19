Calculation: Adjusted DEMA = DEMA(close, DEMA lookback) on the first bar; thereafter clamp its previous value between DEMA(close, DEMA lookback) − ATR(envelope ATR lookback) × envelope ATR factor and DEMA(close, DEMA lookback) + ATR(envelope ATR lookback) × envelope ATR factor
Calculation: Profit-target ATR distance = ATR(profit-target ATR lookback) × profit-target ATR factor, calculated on the entry-signal bar and held fixed for the trade
Long: Adjusted DEMA crosses above its value comparison-lag bars ago on a confirmed bar AND position is flat or short
Short: Adjusted DEMA crosses below its value comparison-lag bars ago on a confirmed bar AND position is long
Exit: Long, profit targets enabled AND nearest target has not previously been hit during this trade AND high > entry-signal close + profit-target ATR distance × nearest target multiplier
Exit: Long, profit targets enabled AND middle target has not previously been hit during this trade AND high > entry-signal close + profit-target ATR distance × middle target multiplier
Exit: Long, profit targets enabled AND farthest target has not previously been hit during this trade AND high > entry-signal close + profit-target ATR distance × farthest target multiplier
Exit: Short, profit targets enabled AND nearest target has not previously been hit during this trade AND low < entry-signal close − profit-target ATR distance × nearest target multiplier
Exit: Short, profit targets enabled AND middle target has not previously been hit during this trade AND low < entry-signal close − profit-target ATR distance × middle target multiplier
Exit: Short, profit targets enabled AND farthest target has not previously been hit during this trade AND low < entry-signal close − profit-target ATR distance × farthest target multiplier
Exit: Long, exit-before-market-close setting is enabled
Exit: Short, exit-before-market-close setting is enabled