Calculation: Opening range high = highest high of bars within the configured New York opening range for the current trading day, available after that window ends
Calculation: Opening range low = lowest low of bars within the configured New York opening range for the current trading day, available after that window ends
Calculation: Opening range range = opening range high − opening range low
Calculation: Higher-timeframe bullish trend = EMA(close, fast EMA lookback, T1) > EMA(close, slow EMA lookback, T1) AND chart close > EMA(close, fast EMA lookback, T1); calculate on T1 bars and take values on chart bars, using the forming T1 bar in real time and the last completed T1 bar historically
Calculation: Higher-timeframe bearish trend = EMA(close, fast EMA lookback, T1) < EMA(close, slow EMA lookback, T1) AND chart close < EMA(close, fast EMA lookback, T1); calculate on T1 bars and take values on chart bars, using the forming T1 bar in real time and the last completed T1 bar historically
Calculation: Bullish BOS = close crosses above the latest confirmed Pivot High(high, pivot lookback, pivot lookback)
Calculation: Bearish BOS = close crosses below the latest confirmed Pivot Low(low, pivot lookback, pivot lookback)
Calculation: Structural trend = bullish after a bullish BOS, bearish after a bearish BOS, and otherwise unchanged; initially neither
Calculation: Bullish CHoCH = structural trend is bearish AND bullish BOS
Calculation: Bearish CHoCH = structural trend is bullish AND bearish BOS
Calculation: Bullish order-block zone = the most recent bearish candle within the order-block search lookback before a bullish BOS; its high and low define the zone, which remains active until close < zone low + (zone high − zone low) × mitigation fraction
Calculation: Bearish order-block zone = the most recent bullish candle within the order-block search lookback before a bearish BOS; its high and low define the zone, which remains active until close > zone high − (zone high − zone low) × mitigation fraction
Calculation: Bullish order-block interaction = active bullish order-block zone AND low <= zone high AND close >= zone low
Calculation: Bearish order-block interaction = active bearish order-block zone AND high >= zone low AND close <= zone high
Calculation: Bullish FVG interaction = close is between the bounds high[2] and low of the latest bullish FVG, where low > high[2], and its age in bars <= FVG maximum age
Calculation: Bearish FVG interaction = close is between the bounds high and low[2] of the latest bearish FVG, where high < low[2], and its age in bars <= FVG maximum age
Calculation: Smart Trail = initialize trail to close; each chart bar use ATR(ATR lookback) × trail multiplier as the step; when close > prior trail set trail to max(prior trail, close − step) and direction bullish; when close < prior trail set trail to min(prior trail, close + step) and direction bearish; otherwise retain trail and direction
Calculation: Long confluence score = unit score weight for each enabled condition that is true: higher-timeframe bullish trend, bullish BOS, bullish liquidity sweep, bullish order-block interaction, bullish FVG interaction, bullish volume flow, bullish Smart Trail direction, bullish RSI condition, and eligible session and weekday; use the separate BOS weight for bullish BOS
Calculation: Short confluence score = unit score weight for each enabled condition that is true: higher-timeframe bearish trend, bearish BOS, bearish liquidity sweep, bearish order-block interaction, bearish FVG interaction, bearish volume flow, bearish Smart Trail direction, bearish RSI condition, and eligible session and weekday; use the separate BOS weight for bearish BOS
Calculation: Long risk distance = max(selected stop distance, minimum tick), using ATR(ATR lookback) × ATR stop multiple, entry price − opening range midpoint, entry price − opening range low, or fixed stop distance as selected; use the ATR stop distance if the selected distance is unavailable
Calculation: Short risk distance = max(selected stop distance, minimum tick), using ATR(ATR lookback) × ATR stop multiple, opening range midpoint − entry price, opening range high − entry price, or fixed stop distance as selected; use the ATR stop distance if the selected distance is unavailable
Calculation: Active long stop = before first target touch, entry price − long risk distance; after first target touch, entry price + breakeven offset in ticks, or max of that value and Smart Trail when trail-after-target is enabled
Calculation: Active short stop = before first target touch, entry price + short risk distance; after first target touch, entry price − breakeven offset in ticks, or min of that value and Smart Trail when trail-after-target is enabled
Calculation: Effective P&L since current date began = account realized P&L since date start + open P&L
Calculation: Effective P&L since current week began = account realized P&L since week start + open P&L
Calculation: Risk lockout = effective P&L since current date began <= −absolute daily loss limit OR effective P&L since current week began <= −absolute weekly loss limit OR trades today >= daily trade limit OR consecutive losses >= consecutive loss limit OR (daily profit target > 0 AND effective P&L since current date began >= daily profit target) OR (weekly profit target > 0 AND effective P&L since current week began >= weekly profit target)
Long: bullish BOS
Short: bearish BOS
Long: bullish CHoCH
Short: bearish CHoCH
Long: low < Lowest(low, liquidity lookback)[1] AND close > Lowest(low, liquidity lookback)[1]
Short: high > Highest(high, liquidity lookback)[1] AND close < Highest(high, liquidity lookback)[1]
Long: bullish BOS AND bullish order-block zone is active
Short: bearish BOS AND bearish order-block zone is active
Long: low > high[2]
Short: high < low[2]
Long: higher-timeframe bullish trend
Short: higher-timeframe bearish trend
Long: Smart Trail direction is bullish
Short: Smart Trail direction is bearish
Long: trading side enabled AND position is flat AND opening range is set AND (retest requirement disabled AND close > opening range high OR retest requirement enabled AND a breakout has armed an unfired long retest AND low <= opening range high + opening range range × retest tolerance fraction AND close > opening range high) AND before the configured New York cutoff AND an enabled weekday AND (within an enabled New York session window OR within an enabled London session window) AND (higher-timeframe filter disabled OR higher-timeframe bullish trend) AND long confluence score >= minimum score AND NOT risk lockout AND no bearish RSI divergence when the divergence filter is enabled AND (close >= RSI bullish threshold when momentum is enabled) AND (volume > SMA(volume, volume lookback) AND close > open AND (OBV(close, volume) > OBV(close, volume)[OBV slope lookback] OR OBV confirmation disabled) when volume flow is enabled)
Short: trading side enabled AND position is flat AND opening range is set AND (retest requirement disabled AND close < opening range low OR retest requirement enabled AND a breakout has armed an unfired short retest AND high >= opening range low − opening range range × retest tolerance fraction AND close < opening range low) AND before the configured New York cutoff AND an enabled weekday AND (within an enabled New York session window OR within an enabled London session window) AND (higher-timeframe filter disabled OR higher-timeframe bearish trend) AND short confluence score >= minimum score AND NOT risk lockout AND no bullish RSI divergence when the divergence filter is enabled AND (close <= RSI bearish threshold when momentum is enabled) AND (volume > SMA(volume, volume lookback) AND close < open AND (OBV(close, volume) < OBV(close, volume)[OBV slope lookback] OR OBV confirmation disabled) when volume flow is enabled)
Exit: Long, low <= active long stop OR high >= entry price + long risk distance × TP1 multiple OR high >= entry price + long risk distance × TP2 multiple
Exit: Short, high >= active short stop OR low <= entry price − short risk distance × TP1 multiple OR low <= entry price − short risk distance × TP2 multiple
Exit: Long, configured New York cutoff reached
Exit: Short, configured New York cutoff reached