Calculation: Confirmed pivot high or low = a high or low at a bar with a parameterized number of bars on each side, confirmed only after the right-hand bars have completed; retain the latest confirmed pivot of each kind.
Calculation: Bullish break = close crosses above the latest confirmed pivot high, comparing each bar's close with that bar's latest confirmed pivot high.
Calculation: Bearish break = close crosses below the latest confirmed pivot low, comparing each bar's close with that bar's latest confirmed pivot low.
Calculation: Structure trend = initially neutral; set bullish on a bullish break, then set bearish on a bearish break, and otherwise retain its previous state.
Calculation: Entry stop distance = ATR on the entry signal bar multiplied by a stop multiplier and a volatility scaling factor; hold this distance and the entry signal bar's close fixed for the trade.
Long: bullish break = true AND structure trend = bullish
Long: structure trend = bullish AND low < lowest low of the preceding sweep-lookback bars AND close > lowest low of the preceding sweep-lookback bars
Short: bearish break = true AND structure trend = bearish
Short: structure trend = bearish AND high > highest high of the preceding sweep-lookback bars AND close < highest high of the preceding sweep-lookback bars
Exit: long, low <= entry signal bar close - entry stop distance OR high >= entry signal bar close + entry stop distance * reward-to-risk ratio
Exit: short, high >= entry signal bar close + entry stop distance OR low <= entry signal bar close - entry stop distance * reward-to-risk ratio