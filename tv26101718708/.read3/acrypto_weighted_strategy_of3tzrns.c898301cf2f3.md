Calculation: MA spread = MA(source A, type A, lookback A) − MA(source B, type B, lookback B)
Calculation: MACD signal average = SMA(MA spread, signal lookback)
Calculation: Stochastic RSI K = SMA(Stochastic(RSI(close, RSI lookback), stochastic lookback), smoothing lookback)
Calculation: MACD long signal = MA spread > MACD signal average AND MA spread[dMACD − 1] > MACD signal average[dMACD − 1] AND MA spread[dMACD] <= MACD signal average[dMACD]
Calculation: MACD short signal = MA spread < MACD signal average AND MA spread[dMACD − 1] < MACD signal average[dMACD − 1] AND MA spread[dMACD] >= MACD signal average[dMACD]
Calculation: Stochastic RSI long signal = Stochastic RSI K[dStochRSI] <= stochastic oversold threshold AND Stochastic RSI K < stochastic overbought threshold AND bars since entry >= entry cooldown AND bars since last closed trade >= entry cooldown
Calculation: Stochastic RSI short signal = Stochastic RSI K[dStochRSI] >= stochastic overbought threshold AND Stochastic RSI K > stochastic oversold threshold AND bars since entry >= entry cooldown AND bars since last closed trade >= entry cooldown
Calculation: RSI long signal = RSI(close, RSI lookback)[dRSI] <= RSI oversold threshold AND RSI(close, RSI lookback) < RSI overbought threshold AND bars since entry >= entry cooldown AND bars since last closed trade >= entry cooldown
Calculation: RSI short signal = RSI(close, RSI lookback)[dRSI] >= RSI overbought threshold AND RSI(close, RSI lookback) > RSI oversold threshold AND bars since entry >= entry cooldown AND bars since last closed trade >= entry cooldown
Calculation: Supertrend long signal = Supertrend direction is bullish AND Supertrend direction[dSupertrend − 1] is bullish AND Supertrend direction[dSupertrend] is bearish
Calculation: Supertrend short signal = Supertrend direction is bearish AND Supertrend direction[dSupertrend − 1] is bearish AND Supertrend direction[dSupertrend] is bullish
Calculation: MA-cross long signal = MA(source C, type C, lookback C) > MA(source D, type D, lookback D) AND the same relation at [dMA − 1] AND NOT the same relation at [dMA]
Calculation: MA-cross short signal = MA(source C, type C, lookback C) < MA(source D, type D, lookback D) AND the same relation at [dMA − 1] AND NOT the same relation at [dMA]
Calculation: Long weighted score = sum of each strategy's separate weight when its long signal is true, or zero otherwise; disabled strategy weights are zero in weighted mode
Calculation: Short weighted score = sum of each strategy's separate weight when its short signal is true, or zero otherwise; disabled strategy weights are zero in weighted mode
Long: MACD long signal
Long: Stochastic RSI long signal
Long: RSI long signal
Long: Supertrend long signal
Long: MA-cross long signal
Long: Long weighted score >= weighted entry threshold
Short: MACD short signal
Short: Stochastic RSI short signal
Short: RSI short signal
Short: Supertrend short signal
Short: MA-cross short signal
Short: Short weighted score >= weighted entry threshold
Long: within configured date window AND long entries enabled AND ((weighted strategy enabled AND Long weighted score >= weighted entry threshold) OR (weighted strategy disabled AND at least one enabled strategy's long signal is true))
Short: within configured date window AND short entries enabled AND ((weighted strategy enabled AND Short weighted score >= weighted entry threshold) OR (weighted strategy disabled AND at least one enabled strategy's short signal is true))
Calculation: One-way close condition = any enabled strategy's condition: MA spread < MACD signal average AND NOT (MA spread[dMACD] > MACD signal average[dMACD]); Stochastic RSI short signal; RSI short signal; Supertrend short signal; or MA(source C, type C, lookback C) < MA(source D, type D, lookback D) AND NOT (MA(source C, type C, lookback C)[dMA] > MA(source D, type D, lookback D)[dMA])
Exit: long, within configured date window AND long entries enabled AND short entries disabled AND ((weighted strategy enabled AND Short weighted score >= weighted entry threshold) OR (weighted strategy disabled AND One-way close condition))
Exit: short, within configured date window AND short entries enabled AND long entries disabled AND ((weighted strategy enabled AND Long weighted score >= weighted entry threshold) OR (weighted strategy disabled AND One-way close condition))
Calculation: Long target(n) = entry price × (1 + n × long target interval), for target levels n up to the configured maximum
Calculation: Short target(n) = entry price × (1 − n × short target interval), for target levels n up to the configured maximum
Exit: long, within configured date window AND take-profits enabled AND high >= Long target(n) for any target level n up to the configured maximum
Exit: short, within configured date window AND take-profits enabled AND low <= Short target(n) for any target level n up to the configured maximum
Calculation: Long stop price = entry price × (1 − initial stop fraction) at entry; on a bar since the last closed trade, find the greatest eligible n with high > Long target(n); in percentage mode set to entry price × (1 + n × long target interval − initial stop fraction × stop move factor); in target-offset mode set to Long target(n − selected offset) when n exceeds the offset, set to entry price when n does not exceed it and move-to-entry is enabled, and otherwise retain the prior stop price; in no-move mode retain the prior stop price
Calculation: Short stop price = entry price × (1 + initial stop fraction) at entry; on a bar since the last closed trade, find the greatest eligible n with low < Short target(n); in percentage mode set to entry price × (1 − n × short target interval + initial stop fraction × stop move factor); in target-offset mode set to Short target(n − selected offset) when n exceeds the offset, set to entry price when n does not exceed it and move-to-entry is enabled, and otherwise retain the prior stop price; in no-move mode retain the prior stop price
Exit: long, within configured date window AND long entries enabled AND stop-loss enabled AND bars since entry > 0 AND stop source <= Long stop price
Exit: short, within configured date window AND short entries enabled AND stop-loss enabled AND bars since entry > 0 AND stop source >= Short stop price
Calculation: Volume pattern = volume at the configured pivot offset > volume at each of three configured older offsets
Calculation: Potential top = (RSI(close, RSI lookback) >= RSI overbought threshold AND (Stochastic RSI K >= stochastic overbought threshold OR volume < SMA(volume, volume lookback) / volume divisor) OR volume at pivot offset / previous-bar volume > 1 + long volume-trail fraction AND Stochastic RSI K >= stochastic overbought threshold) AND Volume pattern
Calculation: Potential bottom = (RSI(close, RSI lookback) <= RSI oversold threshold AND (Stochastic RSI K <= stochastic oversold threshold OR volume < SMA(volume, volume lookback) / volume divisor) OR volume at pivot offset / previous-bar volume > 1 + short volume-trail fraction AND Stochastic RSI K <= stochastic oversold threshold) AND Volume pattern
Calculation: Repeated potential top = Potential top[1] AND Potential top at any configured older repeat offset
Calculation: Repeated potential bottom = Potential bottom[1] AND Potential bottom at any configured older repeat offset
Exit: long, within configured date window AND long entries enabled AND stop-loss enabled AND bars since entry > 0 AND potential-top strategy enabled AND Repeated potential top AND (top exit quantity is the full position OR high >= top price source[1])
Exit: short, within configured date window AND short entries enabled AND stop-loss enabled AND bars since entry > 0 AND potential-top strategy enabled AND Repeated potential bottom AND (top exit quantity is the full position OR low <= bottom price source[1])