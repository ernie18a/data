Calculation: EMA trend = exponential moving averages of close at fast, medium, base, and macro lookbacks, with fast < medium < base < macro in lookback length
Calculation: RSI = relative strength index of close
Calculation: MACD histogram = MACD line minus its signal line
Calculation: Relative volume = volume / simple moving average of volume
Calculation: Positive/negative divergence = at successive confirmed price pivot lows/highs, price makes a lower low/higher high while the selected indicator makes a higher low/lower high (regular), or price makes a higher low/lower high while the indicator makes a lower low/higher high (hidden); count selected indicators and compare with the minimum count
Calculation: XGS score = weighted points for bullish EMA/trend structure, Donchian support or breakout, momentum, relative leadership, and absence of risk; cap at 100
Calculation: DTS score = weighted points for bullish price location/reclaims, candle strength and triggers, volume/flow participation, and bullish context; cap at 100
Calculation: Confluence = passed enabled layers / active enabled layers × 100; layers test XGS, DTS, EMA structure, RSI/MACD momentum, MACD acceleration, relative volume and participation, CMF/MFI flow, relative leadership, higher-timeframe support, candle authority, trap/distribution safety, phase/safety, SMC, order-block location, Fibonacci location, and divergence
Calculation: SMC bullish/bearish event = close crosses above/below the latest confirmed internal or swing pivot high/low; an event is recent through the configured validity lookback
Calculation: Bottom/top reversal score = sum of the configured weighted component tests for prior trend, exhaustion, sweep, reclaim/loss, candle, momentum turn/fade, divergence, location, participation/distribution, and continuation/risk; cap at 100
Calculation: Active long stop = the tightest applicable ratcheting stop: initial stop is the lower of close minus ATR risk multiple and recent swing low minus ATR buffer; after configured gain or target milestones, raise it to breakeven, EMA trail, or selected ATR/EMA/swing/hybrid trail
Long: confirmed bar AND cooldown elapsed AND (no open trade if trade-state blocking is enabled) AND ((selected authority mode permits the core GS buy, where core GS buy requires XGS and DTS thresholds and at least 10 of 12 core layers, with at least 12 for the strongest grade; filtered authority additionally requires a qualifying independent grade) OR (bottom reversal confirmed and reversal trading enabled))
Long: bottom reversal marking = prior-down condition AND confirmed bar AND enabled mandatory sweep/reclaim/divergence/location/higher-timeframe filters AND reversal score at least the confirmation threshold AND no major risk
Long: bullish trend-break marking = valid rising line through the two latest confirmed pivot lows AND price crosses above that line (close or wick according to confirmation setting)
Long: bullish micro-EMA flip marking = fast micro EMA crosses above slow micro EMA AND (bullish candle if candle confirmation is enabled)
Long: positive-divergence marking = positive divergence count reaches its minimum
Long: bullish SMC marking = bullish internal or swing pivot cross (BOS or CHOCH)
Long: bullish order-block marking = volume pivot confirms while order-block state is bullish
Short: top reversal marking = prior-up condition AND confirmed bar AND enabled mandatory sweep/loss/divergence/location filters AND reversal score at least the confirmation threshold
Short: bearish trend-break marking = valid falling line through the two latest confirmed pivot highs AND price crosses below that line (close or wick according to confirmation setting)
Short: bearish micro-EMA flip marking = fast micro EMA crosses below slow micro EMA AND (bearish candle if candle confirmation is enabled)
Short: negative-divergence marking = negative divergence count reaches its minimum
Short: bearish SMC marking = bearish internal or swing pivot cross (BOS or CHOCH)
Short: bearish order-block marking = volume pivot confirms while order-block state is bearish
Exit: long, open trade AND confirmed bar AND (close < active long stop OR (close < base EMA AND MACD histogram < 0) OR (RSI < bullish floor AND close < medium EMA) OR bearish swing BOS OR (warn exit enabled AND warning event))