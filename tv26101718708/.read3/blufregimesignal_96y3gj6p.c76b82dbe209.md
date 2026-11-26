Calculation: regime state = initially CAUTION; enter TREND when ER(close, lookback) > trend threshold, enter RANGE when ER(close, lookback) < range threshold, otherwise retain the prior state
Calculation: bullish confluence count = count of ER(close, lookback) >= trend threshold, HMA(close, shorter lookback) > HMA(close, longer lookback), RSI(close, lookback) >= bullish RSI threshold, MACD histogram(close, fast lookback, slower lookback, signal lookback) > 0 and rising consecutively over the acceleration lookback, and close > VWAP(source)
Calculation: bearish confluence count = count of ER(close, lookback) >= trend threshold, HMA(close, shorter lookback) < HMA(close, longer lookback), RSI(close, lookback) <= bearish RSI threshold, MACD histogram(close, fast lookback, slower lookback, signal lookback) < 0 and falling consecutively over the acceleration lookback, and close < VWAP(source)
Calculation: bullish confluence score = bullish confluence count as a percentage of all confluence components, rounded
Calculation: bearish confluence score = bearish confluence count as a percentage of all confluence components, rounded
Calculation: bullish tier = PRIME when bullish confluence count meets the prime-count threshold and bullish MACD acceleration is true; otherwise STRONG when count meets the strong-count threshold, WEAK when count meets the weak-count threshold, or NONE
Calculation: bearish tier = PRIME when bearish confluence count meets the prime-count threshold and bearish MACD acceleration is true; otherwise STRONG when count meets the strong-count threshold, WEAK when count meets the weak-count threshold, or NONE
Calculation: higher-timeframe HMA = HMA(close, separate lookback, on T1 bars, mapped to chart bars with lookahead off and using the T1 bar still forming in realtime)
Calculation: VWAP standard deviation(source) = zero when cumulative volume is zero; otherwise sqrt(max(volume-weighted mean(source squared) − VWAP(source) squared, zero)) over the VWAP anchor period
Calculation: anchor level = VWAP(source), unless automatic levels are off and a nonzero manual anchor is set
Calculation: flip level = Volume Profile POC(lookback, bin count), falling back to the previous completed T2 close mapped to chart bars if unavailable, unless automatic levels are off and a nonzero manual flip is set
Calculation: call wall level = VWAP(source) + band multiplier × VWAP standard deviation(source), unless automatic levels are off and a nonzero manual call wall is set
Calculation: put wall level = VWAP(source) − band multiplier × VWAP standard deviation(source), unless automatic levels are off and a nonzero manual put wall is set
Calculation: bullish outer stop = max(previous bullish outer stop, close − ATR(lookback) × outer-stop multiplier); initialize to the current candidate on entering the bullish flip state
Calculation: bearish outer stop = min(previous bearish outer stop, close + ATR(lookback) × outer-stop multiplier); initialize to the current candidate on entering the bearish flip state
Calculation: flip state = initially bullish; changes to bearish when close < the previous bullish outer stop and to bullish when close > the previous bearish outer stop
Long: HMA(close, shorter lookback) > HMA(close, longer lookback)
Short: HMA(close, shorter lookback) < HMA(close, longer lookback)
Long: higher-timeframe HMA is available AND close > higher-timeframe HMA
Short: higher-timeframe HMA is available AND close < higher-timeframe HMA
Long: close > flip level
Short: close <= flip level
Long: bullish confluence count > bearish confluence count
Short: bearish confluence count > bullish confluence count
Long: regime changes to TREND from a non-TREND state AND close > VWAP(source) AND bullish tier rank meets the configured minimum tier AND (prime-only is disabled OR bullish tier is PRIME) AND same-direction lockout has elapsed since the prior bullish trend signal AND cooldown has elapsed since the last emitted trend or range shift AND (HTF filter is off OR HTF mode is aligned and close > higher-timeframe HMA OR HTF mode is reversal and close < higher-timeframe HMA)
Short: regime changes to TREND from a non-TREND state AND close <= VWAP(source) AND bearish tier rank meets the configured minimum tier AND (prime-only is disabled OR bearish tier is PRIME) AND same-direction lockout has elapsed since the prior bearish trend signal AND cooldown has elapsed since the last emitted trend or range shift AND (HTF filter is off OR HTF mode is aligned and close < higher-timeframe HMA OR HTF mode is reversal and close > higher-timeframe HMA)
Long: optimizer capture is enabled AND regime changes to TREND from a non-TREND state AND cooldown has elapsed since the last emitted trend or range shift AND bullish confluence count >= bearish confluence count
Short: optimizer capture is enabled AND regime changes to TREND from a non-TREND state AND cooldown has elapsed since the last emitted trend or range shift AND bullish confluence count < bearish confluence count
Long: flip state is bearish AND close > previous bearish outer stop
Short: flip state is bullish AND close < previous bullish outer stop
Long: flip state is bullish
Short: flip state is bearish
Long: close crosses above flip level
Short: close crosses below flip level
Long: close crosses above anchor level
Short: close crosses below anchor level
Long: close crosses above call wall level
Short: close crosses below put wall level
Long: most recent shift is a bullish TREND shift AND bars since that shift <= trade-plan stale-bar parameter AND bearish confluence score <= bullish confluence score + confluence-flip threshold
Short: most recent shift is a bearish TREND shift AND bars since that shift <= trade-plan stale-bar parameter AND bullish confluence score <= bearish confluence score + confluence-flip threshold