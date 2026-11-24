Calculation: liquidity line = basis ± deviation, where basis = SMA(EMA(source, length), length) and deviation = EMA(abs(close − basis), length × deviation-lookback factor) × multiplier; trend starts neutral, changes bullish above the upper band or bearish below the lower band, otherwise persists; the line is the lower band when bullish and the upper band otherwise.
Calculation: heat trail = EMA(TR, stop lookback) × stop multiplier as the stop distance; bullish candidate = high − stop distance and bearish candidate = low + stop distance; each candidate trails by taking the maximum or minimum with its previous value when the previous close is beyond that previous trail, otherwise it resets to the current candidate; trend starts bullish, switches bullish when close exceeds the previous bearish trail or bearish when close is below the previous bullish trail, otherwise persists; use the bullish or bearish trail for the current trend.
Calculation: bullish timeframe alignment(T) = close > liquidity line AND close > heat trail when both confirmations are required, otherwise either comparison; calculated on T bars and chart bars use the current still-forming T bar with lookahead off.
Calculation: bearish timeframe alignment(T) = close < liquidity line AND close < heat trail when both confirmations are required, otherwise either comparison; calculated on T bars and chart bars use the current still-forming T bar with lookahead off.
Calculation: bullish trigger confirmation = T1 close > liquidity line AND T1 close > heat trail when both trigger confirmations are required, otherwise either comparison; calculated on T1 bars and chart bars use the current still-forming T1 bar with lookahead off.
Calculation: bearish trigger confirmation = T1 close < liquidity line AND T1 close < heat trail when both trigger confirmations are required, otherwise either comparison; calculated on T1 bars and chart bars use the current still-forming T1 bar with lookahead off.
Calculation: long timeframe count = bullish trigger confirmation + bullish timeframe alignment(T2) + bullish timeframe alignment(T3) when T3 is enabled, counting each true condition as one.
Calculation: short timeframe count = bearish trigger confirmation + bearish timeframe alignment(T2) + bearish timeframe alignment(T3) when T3 is enabled, counting each true condition as one.
Calculation: required timeframe confirmations = the lesser of the configured minimum and the number of enabled timeframes.
Calculation: unfiltered long setup = bullish trigger confirmation AND long timeframe count >= required timeframe confirmations AND long timeframe count > short timeframe count.
Calculation: unfiltered short setup = bearish trigger confirmation AND short timeframe count >= required timeframe confirmations AND short timeframe count > long timeframe count.
Calculation: BASS bullish count = number of positive values among MACD histogram × MACD scale, RSI minus its midpoint × RSI scale, slow stochastic K−D × stochastic scale, Awesome Oscillator × AO scale, SMMA(hl2, lips lookback)−SMMA(hl2, jaw lookback) × Alligator scale, and optionally VWMA(hlc3, volume lookback)−SMA(hlc3, volume lookback) × volume-bias scale; calculated on T6 bars and chart bars use the current still-forming T6 bar with lookahead off.
Calculation: BASS bearish count = number of negative values among the same selected BASS values; calculated on T6 bars and chart bars use the current still-forming T6 bar with lookahead off.
Calculation: required BASS confirmations = the selected minimum capped at the selected total of five or six, or the total in an all-confirmations mode.
Calculation: bullish BASS state = BASS bullish count >= required BASS confirmations AND BASS bullish count > BASS bearish count.
Calculation: bearish BASS state = BASS bearish count >= required BASS confirmations AND BASS bearish count > BASS bullish count.
Calculation: volume-adjusted close-location index = 100 × sum(volume × ((2 × close − high − low) / (high − low))) / sum(volume) over its lookback, using zero for the close-location value when high = low and zero when summed volume is zero; calculated on T7 bars and chart bars use the current still-forming T7 bar with lookahead off.
Calculation: bullish volume-adjusted index state = volume-adjusted close-location index > 0 AND (slope is not required OR current value >= previous value).
Calculation: bearish volume-adjusted index state = volume-adjusted close-location index < 0 AND (slope is not required OR current value <= previous value).
Calculation: high-volume zone price(T) = current hlc3 when volume > SMA(volume, volume-context lookback) × high-volume factor, otherwise the previous zone price; initialize to current hlc3; calculate on T bars and let chart bars use the current still-forming T bar with lookahead off.
Long: close > liquidity line on T1 trigger bars; chart bars use the current still-forming T1 bar with lookahead off.
Short: close < liquidity line on T1 trigger bars; chart bars use the current still-forming T1 bar with lookahead off.
Long: close > heat trail on T1 trigger bars; chart bars use the current still-forming T1 bar with lookahead off.
Short: close < heat trail on T1 trigger bars; chart bars use the current still-forming T1 bar with lookahead off.
Long: bullish timeframe alignment(T1).
Short: bearish timeframe alignment(T1).
Long: close > liquidity line on T2 confirmation bars; chart bars use the current still-forming T2 bar with lookahead off.
Short: close < liquidity line on T2 confirmation bars; chart bars use the current still-forming T2 bar with lookahead off.
Long: close > heat trail on T2 confirmation bars; chart bars use the current still-forming T2 bar with lookahead off.
Short: close < heat trail on T2 confirmation bars; chart bars use the current still-forming T2 bar with lookahead off.
Long: bullish timeframe alignment(T2).
Short: bearish timeframe alignment(T2).
Long: close > liquidity line on T3 third-confirmation bars; chart bars use the current still-forming T3 bar with lookahead off.
Short: close < liquidity line on T3 third-confirmation bars; chart bars use the current still-forming T3 bar with lookahead off.
Long: close > heat trail on T3 third-confirmation bars; chart bars use the current still-forming T3 bar with lookahead off.
Short: close < heat trail on T3 third-confirmation bars; chart bars use the current still-forming T3 bar with lookahead off.
Long: bullish timeframe alignment(T3).
Short: bearish timeframe alignment(T3).
Long: EMA(close, fast lookback) > EMA(close, slow lookback) on T5 bias bars; chart bars use the current still-forming T5 bar with lookahead off.
Short: EMA(close, fast lookback) < EMA(close, slow lookback) on T5 bias bars; chart bars use the current still-forming T5 bar with lookahead off.
Long: close > VWAP(hlc3, reset at T10 boundary) on T5 bias bars; chart bars use the current still-forming T5 bar with lookahead off.
Short: close < VWAP(hlc3, reset at T10 boundary) on T5 bias bars; chart bars use the current still-forming T5 bar with lookahead off.
Long: bullish BASS state.
Short: bearish BASS state.
Long: bullish volume-adjusted index state.
Short: bearish volume-adjusted index state.
Long: close > VWMA(hlc3, volume-context lookback) AND VWMA(hlc3, volume-context lookback) > SMA(hlc3, volume-context lookback) on T8 volume-context bars; chart bars use the current still-forming T8 bar with lookahead off.
Short: close < VWMA(hlc3, volume-context lookback) AND VWMA(hlc3, volume-context lookback) < SMA(hlc3, volume-context lookback) on T8 volume-context bars; chart bars use the current still-forming T8 bar with lookahead off.
Long: close > VWMA(hlc3, volume-context lookback) AND VWMA(hlc3, volume-context lookback) > SMA(hlc3, volume-context lookback) on T9 volume-context bars; chart bars use the current still-forming T9 bar with lookahead off.
Short: close < VWMA(hlc3, volume-context lookback) AND VWMA(hlc3, volume-context lookback) < SMA(hlc3, volume-context lookback) on T9 volume-context bars; chart bars use the current still-forming T9 bar with lookahead off.
Long: abs(close − high-volume zone price(T8)) <= ATR(ATR lookback) × zone-distance factor AND close > high-volume zone price(T8) on T8 volume-context bars; chart bars use the current still-forming T8 bar with lookahead off.
Short: abs(close − high-volume zone price(T8)) <= ATR(ATR lookback) × zone-distance factor AND close < high-volume zone price(T8) on T8 volume-context bars; chart bars use the current still-forming T8 bar with lookahead off.
Long: abs(close − high-volume zone price(T9)) <= ATR(ATR lookback) × zone-distance factor AND close > high-volume zone price(T9) on T9 volume-context bars; chart bars use the current still-forming T9 bar with lookahead off.
Short: abs(close − high-volume zone price(T9)) <= ATR(ATR lookback) × zone-distance factor AND close < high-volume zone price(T9) on T9 volume-context bars; chart bars use the current still-forming T9 bar with lookahead off.
Long: unfiltered long setup AND (ADX filter disabled OR ADX(T4, ADX lookback) >= minimum ADX AND (non-falling ADX not required OR ADX >= its previous value)); chart bars use the current still-forming T4 bar with lookahead off; AND (bias filter disabled OR every component selected by bias mode is bullish); AND (BASS filter disabled OR bullish BASS state); AND (volume-adjusted index filter disabled OR warning-only mode selected OR bullish volume-adjusted index state).
Short: unfiltered short setup AND (ADX filter disabled OR ADX(T4, ADX lookback) >= minimum ADX AND (non-falling ADX not required OR ADX >= its previous value)); chart bars use the current still-forming T4 bar with lookahead off; AND (bias filter disabled OR every component selected by bias mode is bearish); AND (BASS filter disabled OR bearish BASS state); AND (volume-adjusted index filter disabled OR warning-only mode selected OR bearish volume-adjusted index state).
Long: filtered long signal AND position side is not long.
Short: filtered short signal AND position side is not short.
Exit: long, smart exits enabled AND ((exit mode includes opposite signal AND unfiltered short setup) OR (exit mode includes alignment loss AND long timeframe count < required timeframe confirmations)).
Exit: short, smart exits enabled AND ((exit mode includes opposite signal AND unfiltered long setup) OR (exit mode includes alignment loss AND short timeframe count < required timeframe confirmations)).