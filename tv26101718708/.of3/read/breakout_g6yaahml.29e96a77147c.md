Calculation: Relative volume = volume / SMA(volume, volume lookback)
Calculation: Volume z-score = (volume - SMA(volume, volume lookback)) / standard deviation(volume, volume lookback), or zero when the standard deviation is zero
Calculation: Volume spike = relative volume >= spike multiple OR volume z-score >= z-score threshold
Calculation: Bull volume spike = volume spike AND close > open AND close - open > high - close
Calculation: Bear volume spike = volume spike AND close < open AND open - close > close - low
Calculation: Bullish RSI divergence = at a confirmed pivot low, price makes a lower low than at the preceding confirmed pivot low while RSI makes a higher low
Calculation: Bearish RSI divergence = at a confirmed pivot high, price makes a higher high than at the preceding confirmed pivot high while RSI makes a lower high
Calculation: Bullish wick rejection = (close - low) / max(high - low, minimum tick) > bullish wick threshold AND close > open
Calculation: Bearish wick rejection = (high - close) / max(high - low, minimum tick) > bearish wick threshold AND close < open
Calculation: Bullish liquidity sweep proxy = bullish wick rejection AND volume spike AND demand reversal context, where demand reversal context is current demand regime context or demand regime context pivot confirmation bars ago
Calculation: Bearish liquidity sweep proxy = bearish wick rejection AND volume spike AND supply reversal context, where supply reversal context is current supply regime context or supply regime context pivot confirmation bars ago
Calculation: Bullish ultimate candle = bearish regime AND at a key demand magnet AND bullish wick rejection AND (volume spike OR bull volume spike OR high relative volume) AND (RSI below oversold threshold OR bullish divergence at demand context OR body-to-range ratio <= small-body threshold)
Calculation: Bearish ultimate candle = (bullish regime OR local rally extension into supply context) AND at a key supply magnet or qualifying higher-timeframe supply zone AND (bearish wick rejection OR upper-wick rejection OR shooting star OR bearish pin bar) AND qualifying volume AND (RSI above exhaustion threshold OR bearish divergence at supply context OR small body OR upper-wick-to-range ratio >= exhaustion threshold)
Calculation: Bullish regime flip = demand regime context AND bullish regime score >= regime flip threshold AND bullish regime score >= bearish regime score
Calculation: Bearish regime flip = supply regime context AND bearish regime score >= regime flip threshold AND bearish regime score > bullish regime score
Calculation: Zone-aware regime = bullish when a bullish regime flip occurs, bearish when a bearish regime flip occurs, otherwise its preceding value
Calculation: Bullish major reversal = first bar at a key demand magnet with hard bullish structure, bullish reversal score >= major reversal threshold, and bullish reversal score >= bearish reversal score
Calculation: Bearish major reversal = first bar at a key supply magnet with hard bearish structure, bearish reversal score >= major reversal threshold, and bearish reversal score > bullish reversal score
Long: bullish major reversal
Short: bearish major reversal
Long: bullish liquidity sweep proxy
Short: bearish liquidity sweep proxy
Long: bullish ultimate candle OR bullish ultimate candle and its preceding bar was false
Short: bearish ultimate candle OR bearish ultimate candle and its preceding bar was false
Long: bullish regime flip OR zone-aware regime is bullish
Short: bearish regime flip OR zone-aware regime is bearish
Long: close >= open AND (volume >= SMA(volume, vector volume lookback) * vector active multiple OR volume >= SMA(volume, vector volume lookback) * vector climax multiple OR volume * (high - low) = highest(volume * (high - low), vector volume lookback))
Short: close < open AND (volume >= SMA(volume, vector volume lookback) * vector active multiple OR volume >= SMA(volume, vector volume lookback) * vector climax multiple OR volume * (high - low) = highest(volume * (high - low), vector volume lookback))
Long: EMA(close, shorter lookback) > EMA(close, medium lookback) AND close > EMA(close, shorter lookback)
Short: EMA(close, shorter lookback) < EMA(close, medium lookback) AND close < EMA(close, shorter lookback)
Long: EMA(close, shorter lookback, T1, bar still forming) > EMA(close, medium lookback, T1, bar still forming) AND EMA(close, medium lookback, T1, bar still forming) > EMA(close, longer lookback, T1, bar still forming) AND close(T1, bar still forming) > EMA(close, shorter lookback, T1, bar still forming)
Short: EMA(close, shorter lookback, T1, bar still forming) < EMA(close, medium lookback, T1, bar still forming) AND EMA(close, medium lookback, T1, bar still forming) < EMA(close, longer lookback, T1, bar still forming) AND close(T1, bar still forming) < EMA(close, shorter lookback, T1, bar still forming)
Long: bullish bias score >= bullish bias threshold, where the score adds bullish chart trend, enabled bullish T1 trend, bullish MACD, and close above the long EMA, and subtracts their bearish counterparts
Short: bearish bias score <= bearish bias threshold, where the score adds bearish chart trend, enabled bearish T1 trend, bearish MACD, and close below the long EMA, and subtracts their bullish counterparts
Exit: long, low <= entry price minus ATR times the stop multiplier OR low <= lowest(low, swing lookback) minus ATR times the swing stop buffer OR high >= entry price plus the risk from the selected stop times the reward-to-risk multiple OR bearish major reversal with bearish reversal score >= bullish reversal score
Exit: short, high >= entry price plus ATR times the stop multiplier OR high >= highest(high, swing lookback) plus ATR times the swing stop buffer OR low <= entry price minus the risk from the selected stop times the reward-to-risk multiple OR bullish major reversal with bullish reversal score >= bearish reversal score