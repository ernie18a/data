Calculation: short EMA = EMA(close, short EMA lookback); medium EMA = EMA(close, medium EMA lookback); long EMA = EMA(close, long EMA lookback), with progressively longer lookbacks
Calculation: EMA slope(lookback) = EMA(close, lookback) - EMA(close, lookback)[slope lookback]
Calculation: upward trend = close > short EMA AND short EMA > medium EMA AND medium EMA > long EMA
Calculation: downward trend = close < short EMA AND short EMA < medium EMA AND medium EMA < long EMA
Calculation: higher high = latest confirmed Pivot High(high, swing lookback, swing lookback) > preceding confirmed pivot high
Calculation: lower high = latest confirmed pivot high < preceding confirmed pivot high
Calculation: higher low = latest confirmed Pivot Low(low, swing lookback, swing lookback) > preceding confirmed pivot low
Calculation: lower low = latest confirmed pivot low < preceding confirmed pivot low
Calculation: structure score = higher-high points for a higher high + higher-low points for a higher low - lower-high points for a lower high - lower-low points for a lower low, clamped to ±structure score cap
Calculation: upward break of structure = a confirmed pivot high exists AND close > latest confirmed pivot high
Calculation: downward break of structure = a confirmed pivot low exists AND close < latest confirmed pivot low
Calculation: upward change of character = lower low AND close > short EMA AND EMA slope(short EMA lookback) > 0
Calculation: downward change of character = higher high AND close < short EMA AND EMA slope(short EMA lookback) < 0
Calculation: base trend rating = min(score cap, EMA-order points for each of short EMA > medium EMA and medium EMA > long EMA, + close-location points for each EMA below close, + positive-slope points for each EMA with positive slope, + short-medium separation points when abs(short EMA - medium EMA) > ATR(ATR lookback) × short-medium ATR separation multiplier, + medium-long separation points when abs(medium EMA - long EMA) > ATR(ATR lookback) × medium-long ATR separation multiplier)
Calculation: upward trend rating = min(score cap, upward trend-band weight selected from descending thresholds on the base trend rating, + structure score when positive, + structure-event points for each upward break of structure and upward change of character, + EMA-location points for each EMA below close)
Calculation: downward trend rating = min(score cap, downward trend-band weight selected from ascending thresholds on the base trend rating, + absolute structure score when negative, + structure-event points for each downward break of structure and downward change of character, + EMA-location points for each EMA above close)
Calculation: RSI bullish = RSI(close, RSI lookback) > RSI threshold
Calculation: RSI bearish = RSI(close, RSI lookback) < RSI threshold
Calculation: MACD bullish = MACD line(close, fast lookback, slow lookback) > MACD signal line(close, fast lookback, slow lookback, signal lookback)
Calculation: MACD bearish = MACD line(close, fast lookback, slow lookback) < MACD signal line(close, fast lookback, slow lookback, signal lookback)
Calculation: volatility rating = high-volatility points when ATR(ATR lookback) as a percent of close > high-volatility threshold; otherwise medium-volatility points when it > medium-volatility threshold; otherwise baseline-volatility points
Calculation: volume rating = volume points when volume > SMA(volume, volume lookback), otherwise 0
Calculation: upward momentum rating = momentum-confirmation points for RSI bullish + momentum-confirmation points for MACD bullish + volatility rating + volume rating
Calculation: downward momentum rating = momentum-confirmation points for RSI bearish + momentum-confirmation points for MACD bearish + volatility rating + volume rating
Calculation: long composite score = min(score cap, upward trend rating + upward momentum rating)
Calculation: short composite score = min(score cap, downward trend rating + downward momentum rating)
Long: upward trend
Short: downward trend
Long: long composite score >= action score threshold
Short: long composite score < action score threshold AND short composite score >= action score threshold
Long: upward break of structure
Short: downward break of structure
Long: upward change of character
Short: downward change of character
Long: upward trend AND RSI bullish AND MACD bullish AND ADX(ADX lookback, same ADX smoothing lookback) > strong-trend threshold AND long composite score >= minimum signal score
Short: downward trend AND RSI bearish AND MACD bearish AND ADX(ADX lookback, same ADX smoothing lookback) > strong-trend threshold AND short composite score >= minimum signal score
Calculation: entry price = close on the latest long or short entry signal
Calculation: long stop price = entry price reduced by stop-loss percentage; after break-even is enabled and close reaches entry price increased by the break-even trigger percentage, set it to entry price and keep it there until the next entry
Calculation: short stop price = entry price increased by stop-loss percentage; after break-even is enabled and close reaches entry price reduced by the break-even trigger percentage, set it to entry price and keep it there until the next entry
Calculation: long trailing stop, when trailing is enabled, starts at close - ATR(ATR lookback) × ATR trailing multiplier and thereafter is the maximum of its previous value and close - ATR(ATR lookback) × ATR trailing multiplier
Calculation: short trailing stop, when trailing is enabled, starts at close + ATR(ATR lookback) × ATR trailing multiplier and thereafter is the minimum of its previous value and close + ATR(ATR lookback) × ATR trailing multiplier
Calculation: long active stop = long trailing stop when trailing is enabled and initialized, otherwise long stop price
Calculation: short active stop = short trailing stop when trailing is enabled and initialized, otherwise short stop price
Exit: long, close >= entry price increased by TP1 percentage OR close >= entry price increased by TP2 percentage OR close <= long active stop
Exit: short, close <= entry price reduced by TP1 percentage OR close <= entry price reduced by TP2 percentage OR close >= short active stop