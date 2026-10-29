Calculation: New high = highest(high, shorter lookback) equals highest(high, longer lookback)
Calculation: New low = lowest(low, shorter lookback) equals lowest(low, longer lookback)
Calculation: Bullish MA alignment = close > shorter-term MA > successively longer-term MAs, through the longest MA; use the same MA type for all
Calculation: Yearly high filter = true if the latest completed higher-timeframe 12-month high exceeds each available comparison high from 365 and 730 chart bars earlier, OR close exceeds the greater of the latest high and the lesser of those comparison highs; comparisons requiring unavailable highs pass
Calculation: Yearly low filter = true if the latest completed higher-timeframe 12-month low is below each available comparison low from 365 and 730 chart bars earlier, OR close is below the lesser of the latest low and the greater of those comparison lows; comparisons requiring unavailable lows pass
Calculation: ATR trailing stop = the greater of the previous stop and close minus an ATR multiple
Long: close crosses above the previous bar's Donchian upper line AND yearly high filter passes AND new high is true AND bullish MA alignment occurred within the lookback AND datetime is within the configured backtest date range
Short: close crosses below the previous bar's Donchian lower line AND yearly low filter passes AND new low is true
Exit: long, low reaches the Donchian lower line OR the ATR trailing stop, according to the selected exit method