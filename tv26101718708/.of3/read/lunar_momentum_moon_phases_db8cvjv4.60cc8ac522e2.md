Calculation: Lunar momentum = sin(2π × (((bar datetime − reference new-moon datetime) modulo lunar-cycle duration) / lunar-cycle duration))
Calculation: Lunar phase = the equal one-eighth interval of the lunar cycle centered on New Moon, Waxing Crescent, First Quarter, Waxing Gibbous, Full Moon, Waning Gibbous, Last Quarter, or Waning Crescent that contains the current lunar age
Calculation: Phase changed = current lunar phase differs from the previous chart bar's lunar phase
Calculation: T1 series = close and EMAs calculated on T1 higher-timeframe bars aggregated from chart bars and carried onto chart bars with lookahead off; historical chart bars use the last completed T1 bar and real-time chart bars use the still-forming T1 bar
Calculation: T1 bullish = T1 close > EMA(close, trend lookback, T1) AND EMA(close, fast lookback, T1) > EMA(close, slow lookback, T1)
Calculation: T1 bearish = T1 close < EMA(close, trend lookback, T1) AND EMA(close, fast lookback, T1) < EMA(close, slow lookback, T1)
Calculation: Bull trend = close > EMA(source, trend lookback) AND EMA(source, fast lookback) > EMA(source, slow lookback) AND EMA(source, fast lookback) > its previous chart-bar value; fast lookback < slow lookback < trend lookback
Calculation: Bear trend = close < EMA(source, trend lookback) AND EMA(source, fast lookback) < EMA(source, slow lookback) AND EMA(source, fast lookback) < its previous chart-bar value
Calculation: Bull participation = volume / max(SMA(volume, volume lookback), volume denominator floor) >= relative-volume threshold AND close > open AND (close − low) / max(high − low, minimum price increment) >= close-location threshold AND abs(close − open) >= ATR(ATR lookback) × body-to-ATR threshold
Calculation: Bear participation = volume / max(SMA(volume, volume lookback), volume denominator floor) >= relative-volume threshold AND close < open AND (high − close) / max(high − low, minimum price increment) >= close-location threshold AND abs(close − open) >= ATR(ATR lookback) × body-to-ATR threshold
Calculation: Weighted condition(weight, condition) = weight if condition is true, otherwise zero
Calculation: Bull momentum score = clamp(Weighted condition(trend weight, bull trend) + Weighted condition(slow EMA weight, close > EMA(source, slow lookback)) + Weighted condition(RSI weight, RSI(source, RSI lookback) >= bull RSI threshold) + Weighted condition(RSI extension weight, RSI(source, RSI lookback) > bull RSI threshold + RSI extension offset) + Weighted condition(MACD weight, MACD histogram(source, shorter MACD fast lookback, longer MACD slow lookback, MACD signal lookback) > 0 AND current histogram >= previous chart-bar histogram) + Weighted condition(VWAP weight, close > session VWAP(hlc3)) + Weighted condition(participation weight, bull participation) + Weighted condition(HTF weight, HTF filter disabled OR T1 bullish), 0, score scale)
Calculation: Bear momentum score = clamp(Weighted condition(trend weight, bear trend) + Weighted condition(slow EMA weight, close < EMA(source, slow lookback)) + Weighted condition(RSI weight, RSI(source, RSI lookback) <= bear RSI threshold) + Weighted condition(RSI extension weight, RSI(source, RSI lookback) < bear RSI threshold − RSI extension offset) + Weighted condition(MACD weight, MACD histogram(source, shorter MACD fast lookback, longer MACD slow lookback, MACD signal lookback) < 0 AND current histogram <= previous chart-bar histogram) + Weighted condition(VWAP weight, close < session VWAP(hlc3)) + Weighted condition(participation weight, bear participation) + Weighted condition(HTF weight, HTF filter disabled OR T1 bearish), 0, score scale)
Calculation: Long phase bonus = phase bonus weight if phase changed AND current lunar phase is New Moon or First Quarter AND lunar momentum > 0, otherwise zero
Calculation: Short phase bonus = phase bonus weight if phase changed AND current lunar phase is Full Moon or Last Quarter AND lunar momentum < 0, otherwise zero
Calculation: Long confluence = clamp(momentum confluence weight × bull momentum score + lunar confluence weight × max(lunar momentum, 0) × score scale + long phase bonus, 0, score scale)
Calculation: Short confluence = clamp(momentum confluence weight × bear momentum score + lunar confluence weight × max(−lunar momentum, 0) × score scale + short phase bonus, 0, score scale)
Calculation: Long stop = lowest low over swing lookback on the long-signal bar − ATR(ATR lookback) on that bar × ATR stop buffer
Calculation: Long risk = max(entry price − long stop, minimum price increment × risk-floor ticks)
Calculation: Long target 2 = entry price + long risk × target-2 multiple
Calculation: Short stop = highest high over swing lookback on the short-signal bar + ATR(ATR lookback) on that bar × ATR stop buffer
Calculation: Short risk = max(short stop − entry price, minimum price increment × risk-floor ticks)
Calculation: Short target 2 = entry price − short risk × target-2 multiple
Long: lunar momentum > lunar bias threshold
Short: lunar momentum < −lunar bias threshold
Long: EMA(source, fast lookback) >= EMA(source, slow lookback)
Short: EMA(source, fast lookback) < EMA(source, slow lookback)
Long: bull momentum score >= minimum momentum score
Short: bear momentum score >= minimum momentum score
Long: T1 bullish
Short: T1 bearish
Long: confirmed chart bar AND long direction enabled AND no previous long signal OR current chart-bar index − most recent long-signal bar index > cooldown bars AND lunar momentum > lunar bias threshold AND bull momentum score >= minimum momentum score AND long confluence >= minimum confluence score AND (close > highest high of the preceding breakout lookback chart bars AND close > open OR lowest low over pullback lookback chart bars, including the current bar, <= EMA(source, fast lookback) AND close > EMA(source, fast lookback) AND close > open AND close > previous chart-bar close) AND (HTF filter disabled OR T1 bullish)
Short: confirmed chart bar AND short direction enabled AND no previous short signal OR current chart-bar index − most recent short-signal bar index > cooldown bars AND lunar momentum < −lunar bias threshold AND bear momentum score >= minimum momentum score AND short confluence >= minimum confluence score AND (close < lowest low of the preceding breakout lookback chart bars AND close < open OR highest high over pullback lookback chart bars, including the current bar, >= EMA(source, fast lookback) AND close < EMA(source, fast lookback) AND close < open AND close < previous chart-bar close) AND (HTF filter disabled OR T1 bearish)
Exit: Long, current low <= long stop set at entry OR current high >= long target 2 set at entry
Exit: Short, current high >= short stop set at entry OR current low <= short target 2 set at entry