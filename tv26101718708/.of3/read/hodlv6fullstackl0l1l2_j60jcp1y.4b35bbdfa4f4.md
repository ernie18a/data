Calculation: bounded(x) = min(100, max(0, x))
Calculation: macro close(instrument) = close of the external instrument from the still-forming T1 bar, taken on each chart bar
Calculation: macro move(instrument) = ROC(macro close(instrument), macro lookback)
Calculation: macro liquidity = USD weight * bounded(50 - USD sensitivity * macro move(USD index)) + gold weight * bounded(50 + gold sensitivity * macro move(gold)) + Nasdaq weight * bounded(50 + Nasdaq sensitivity * macro move(Nasdaq-100)) + VIX weight * bounded(50 - VIX sensitivity * macro move(VIX))
Calculation: macro agreement = agreement points * count of true among [macro move(USD index) < 0, macro move(gold) > 0, macro move(Nasdaq-100) > 0, macro move(VIX) < 0, macro move(copper) > 0]
Calculation: macro fear = bounded(100 * (1 - macro close(VIX) / VIX fear level))
Calculation: macro score = liquidity weight * macro liquidity + agreement weight * macro agreement + fear weight * macro fear
Calculation: trend state = first true of: strong bull if EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback) AND ADX(high, low, close, ADX lookback) > ADX threshold; weak bull if EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback); strong bear if EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback) AND ADX(high, low, close, ADX lookback) > ADX threshold; weak bear if EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback); else range
Calculation: trend state score = trend state score table[trend state]
Calculation: momentum score = bounded(50 + momentum sensitivity * ROC(close, trend ROC lookback))
Calculation: ATR percent = ATR(high, low, close, ATR lookback) / close * 100
Calculation: volatility score = 100 - PercentRank(ATR percent, percent-rank lookback)
Calculation: trend score = state weight * trend state score + momentum weight * momentum score + volatility weight * volatility score
Calculation: peak close = running maximum of close from the first bar through the current bar
Calculation: drawdown = (close - peak close) / peak close
Calculation: stepped points(x, breakpoints, values) = values[k], where k = number of breakpoints less than x, breakpoints ascending, values has one more entry than breakpoints
Calculation: DCA points = stepped points(drawdown, band thresholds deepest first, DCA point table)
Calculation: distance from long EMA = (close - EMA(close, longer EMA lookback)) / EMA(close, longer EMA lookback)
Calculation: RSI points = stepped points(RSI(close, RSI lookback), RSI breakpoints, RSI point table)
Calculation: distance points = stepped points(distance from long EMA, distance breakpoints, distance point table)
Calculation: ATR points = stepped points(ATR percent, ATR breakpoints, ATR point table)
Calculation: asset trend points = asset trend points table[trend state]
Calculation: overheat penalty = overheat deduction if RSI(close, RSI lookback) > RSI overheat threshold AND distance from long EMA > distance overheat threshold, else 0
Calculation: asset score = bounded(DCA points + RSI points + asset trend points + distance points + ATR points - overheat penalty)
Calculation: composite score = macro weight * macro score + trend weight * trend score + asset weight * asset score
Long: composite score >= buy threshold
Long: drawdown <= band 4 threshold
Long: RSI(close, RSI lookback) < RSI oversold threshold
Exit: long, composite score < reduce threshold