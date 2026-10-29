Calculation: Bullish structure = the two latest confirmed swing highs and the two latest confirmed swing lows are each rising.
Calculation: Bearish structure = the two latest confirmed swing highs and the two latest confirmed swing lows are each falling.
Calculation: Bullish break of structure = close crosses above the second-latest confirmed swing high.
Calculation: Bearish break of structure = close crosses below the second-latest confirmed swing low.
Calculation: Bullish retest = after a bullish break of structure, price reaches the broken level within a configurable proportional buffer and closes above it.
Calculation: Bearish retest = after a bearish break of structure, price reaches the broken level within a configurable proportional buffer and closes below it.
Calculation: Confirmed demand zone = a zone around a confirmed swing low that has been touched by at least the configured number of confirmed swing lows.
Calculation: Confirmed supply zone = a zone around a confirmed swing high that has been touched by at least the configured number of confirmed swing highs.
Calculation: In demand zone = close is within any confirmed demand zone.
Calculation: In supply zone = close is within any confirmed supply zone.
Calculation: Institution candle = candle body is larger than a configurable multiple of the average body over a lookback; bullish when close > open, bearish when close < open.
Calculation: High liquidity sweep = high exceeds the prior rolling high and close is below that high.
Calculation: Low liquidity sweep = low falls below the prior rolling low and close is above that low.
Calculation: Long score = count of bullish structure, in demand zone, bullish break of structure, bullish retest, close above session VWAP, short-period EMA above long-period EMA, and RSI above its midpoint.
Calculation: Short score = count of bearish structure, in supply zone, bearish break of structure, bearish retest, close below session VWAP, short-period EMA below long-period EMA, and RSI below its midpoint.
Long: bullish structure OR bullish break of structure OR bullish retest OR bullish institution candle OR low liquidity sweep OR entry into a confirmed demand zone OR (long score >= configured minimum score AND flat AND not trade-locked AND long-signal cooldown elapsed)
Short: bearish structure OR bearish break of structure OR bearish retest OR bearish institution candle OR high liquidity sweep OR entry into a confirmed supply zone OR (short score >= configured minimum score AND flat AND not trade-locked AND short-signal cooldown elapsed)
Exit: Long, long score < configured minimum score minus one OR price reaches target 1 OR price reaches target 3 OR price reaches the initial stop
Exit: Short, short score < configured minimum score minus one OR price reaches target 1 OR price reaches target 3 OR price reaches the initial stop