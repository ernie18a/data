Calculation: swing high = last defined value of Pivot High(high, pivot width, pivot width)
Calculation: swing low = last defined value of Pivot Low(low, pivot width, pivot width)
Calculation: bull break = close crosses above swing high[1]
Calculation: bear break = close crosses below swing low[1] AND NOT bull break
Calculation: bull CHoCH = bull break AND structure trend[1] is not bullish AND trend run[1] >= BOS requirement
Calculation: bear CHoCH = bear break AND structure trend[1] is not bearish AND trend run[1] >= BOS requirement
Calculation: structure trend = bullish if bull CHoCH, bearish if bear CHoCH, otherwise structure trend[1]; neutral initially
Calculation: trend run = 0 if bull CHoCH or bear CHoCH, otherwise trend run[1] + 1 if (structure trend[1] is bullish AND bull break) OR (structure trend[1] is bearish AND bear break), otherwise trend run[1]
Calculation: bars since signal = bars since the most recent earlier bar on which Long or Short was true
Calculation: relative volume = volume / SMA(volume, volume average length)
Calculation: normalized move = abs(close - close[1]) / ATR(ATR length)
Calculation: participation score = conviction level if relative volume >= high effort threshold AND normalized move >= high result threshold, otherwise absorption level if relative volume >= high effort threshold AND normalized move <= low result threshold, otherwise thin-move level if relative volume <= low effort threshold AND normalized move >= high result threshold, otherwise neutral participation level
Calculation: direction score = aligned direction level if (structure trend is bullish AND close > KAMA(close, KAMA lookback, fast period, slow period)) OR (structure trend is bearish AND close <= KAMA(close, KAMA lookback, fast period, slow period)), otherwise mismatch direction level if structure trend is not neutral, otherwise neutral direction level
Calculation: quality score = min(SMA(ER(close, KAMA lookback), smoothing length) / trending threshold, 1)
Calculation: spread rank = PercentRank(AGK spread(open, high, low, close, spread window), cost lookback) as a fraction
Calculation: cost score = cost fallback level if spread rank is undefined, otherwise 1 - spread rank
Calculation: composite score = direction weight * direction score + quality weight * quality score + participation weight * participation score + cost weight * cost score
Long: bull CHoCH AND close > KAMA(close, KAMA lookback, fast period, slow period) AND bars since signal >= cooldown bars AND (composite score >= score threshold OR show C-grade is true) AND (composite score >= grade B threshold OR show C-grade is true)
Short: bear CHoCH AND close <= KAMA(close, KAMA lookback, fast period, slow period) AND bars since signal >= cooldown bars AND (composite score >= score threshold OR show C-grade is true) AND (composite score >= grade B threshold OR show C-grade is true)