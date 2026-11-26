Calculation: Safe ATR = ATR(ATR length), or 1 if ATR is 0 or undefined
Calculation: LinReg Slope(series, lookback) = linreg(series, lookback, 0) - linreg(series, lookback, 1)
Calculation: Trend Score = round(clamp(sum over k from 1 to 6 of clamp(x_k * trend gain k, -trend limit k, trend limit k), -100, 100)), where x_1 = (close - EMA(close, shorter lookback)) / Safe ATR; x_2 = (EMA(close, shorter lookback) - EMA(close, longer lookback)) / Safe ATR; x_3 = (EMA(close, shorter lookback) - EMA(close, shorter lookback)[EMA slope lookback]) / Safe ATR; x_4 = (EMA(close, longer lookback) - EMA(close, longer lookback)[EMA slope lookback]) / Safe ATR; x_5 = (close - close[momentum lookback]) / Safe ATR; x_6 = ((LinReg Slope(high, structure lookback) + LinReg Slope(low, structure lookback)) / 2) / Safe ATR
Calculation: Sideways = Efficiency Ratio(close, range lookback) < sideways efficiency threshold, where Efficiency Ratio is 0 when its denominator is 0
Calculation: Range High = Highest(high[1], range lookback)
Calculation: Range Low = Lowest(low[1], range lookback)
Calculation: Range Mid = (Range High + Range Low) / 2
Calculation: Sweep Low = low < Range Low AND close > Range Low
Calculation: Sweep High = high > Range High AND close < Range High
Calculation: Recent Sweep Low = Sweep Low[k] is true for some k from 0 to sweep memory
Calculation: Recent Sweep High = Sweep High[k] is true for some k from 0 to sweep memory
Calculation: Bullish Structure Recovery = close > Range Mid AND close > EMA(close, shorter lookback) AND LinReg Slope(low, structure lookback) > 0
Calculation: Bearish Structure Damage = close < Range Mid AND close < EMA(close, shorter lookback) AND LinReg Slope(high, structure lookback) < 0
Calculation: Confirmed Spring = Recent Sweep Low AND Sideways AND Bullish Structure Recovery AND CMF(money flow lookback) > 0 AND LinReg Slope(OBV, flow slope lookback) > 0
Calculation: Confirmed UTAD = Recent Sweep High AND Sideways AND Bearish Structure Damage AND CMF(money flow lookback) < 0 AND LinReg Slope(OBV, flow slope lookback) < 0
Calculation: SOS = close > Range High AND RVOL(volume lookback) >= breakout RVOL threshold AND CMF(money flow lookback) > 0
Calculation: SOW = close < Range Low AND RVOL(volume lookback) >= breakout RVOL threshold AND CMF(money flow lookback) < 0
Calculation: Accumulation Pressure = clamp(sum of: accumulation sideways weight if Sideways; accumulation strong CMF weight if CMF(money flow lookback) >= bullish CMF threshold, else accumulation weak CMF weight if CMF(money flow lookback) > 0; accumulation OBV weight if LinReg Slope(OBV, flow slope lookback) > 0; accumulation A/D weight if LinReg Slope(A/D line, flow slope lookback) > 0; accumulation buy volume weight if SMA(volume if close > close[1] else 0, volume lookback) > SMA(volume if close < close[1] else 0, volume lookback); accumulation sweep weight if Recent Sweep Low; accumulation spring weight if Confirmed Spring; accumulation recovery weight if Bullish Structure Recovery, 0, 100)
Calculation: Distribution Pressure = clamp(sum of: distribution sideways weight if Sideways; distribution strong CMF weight if CMF(money flow lookback) <= bearish CMF threshold, else distribution weak CMF weight if CMF(money flow lookback) < 0; distribution OBV weight if LinReg Slope(OBV, flow slope lookback) < 0; distribution A/D weight if LinReg Slope(A/D line, flow slope lookback) < 0; distribution sell volume weight if SMA(volume if close < close[1] else 0, volume lookback) > SMA(volume if close > close[1] else 0, volume lookback); distribution sweep weight if Recent Sweep High; distribution UTAD weight if Confirmed UTAD; distribution damage weight if Bearish Structure Damage, 0, 100)
Calculation: Raw Phase = if Sideways: (if Accumulation Pressure >= phase pressure threshold AND Accumulation Pressure >= Distribution Pressure + pressure advantage margin: 3 if Trend Score >= re-accumulation trend minimum, else 6 if Trend Score <= re-distribution trend maximum AND NOT Bullish Structure Recovery, else 1; else if Distribution Pressure >= phase pressure threshold AND Distribution Pressure >= Accumulation Pressure + pressure advantage margin: 3 if Trend Score >= trend gate threshold AND NOT Bearish Structure Damage AND NOT SOW, else 6 if Trend Score <= re-distribution trend maximum, else 4; else: 3 if Trend Score >= trend gate threshold, else 6 if Trend Score <= -trend gate threshold, else 0); else: 2 if Trend Score >= strong trend threshold, else 5 if Trend Score <= -strong trend threshold, else 0
Calculation: Phase = Raw Phase if Raw Phase equals Raw Phase[k] for every k from 1 to (phase confirmation bars - 1), else 0
Calculation: Cooldown Event(X) = X AND NOT X[1] AND NOT Cooldown Event(X)[k] for every k from 1 to event cooldown
Calculation: Bull Context = Trend Score >= bias trend threshold OR Phase in {2, 3}
Calculation: Bear Context = Trend Score <= -bias trend threshold OR Phase in {5, 6}
Calculation: Local Bear Context = Trend Score <= -bias trend threshold OR Phase in {4, 5, 6}
Calculation: Strong Bull Raw = (Phase(T1, last completed bar) in {2, 3} OR Trend Score(T1, last completed bar) >= strong bull context threshold) AND (Phase(T2, last completed bar) = 2 OR (Phase(T2, last completed bar) = 3 AND Accumulation Pressure(T2, last completed bar) >= high pressure level) OR SOS(T2, last completed bar)) AND Distribution Pressure(T2, last completed bar) < high pressure level
Calculation: Risk Raw = Bull Context(T1, last completed bar) AND Phase(T2, last completed bar) = 4 AND Distribution Pressure(T2, last completed bar) >= high pressure level
Calculation: Bearish Reversal Raw = (Trend Score(T1, last completed bar) < bias trend threshold OR Distribution Pressure(T1, last completed bar) >= high pressure level OR Phase(T1, last completed bar) in {4, 5, 6}) AND Phase(T2, last completed bar) = 4 AND Distribution Pressure(T2, last completed bar) >= strong distribution alert level AND SOW(T2, last completed bar)
Calculation: Bullish Recovery Raw = Bull Context(T1, last completed bar) AND SOS(T2, last completed bar) AND Distribution Pressure(T2, last completed bar) < high pressure level AND (Distribution Pressure(T2, last completed bar)[1] >= high pressure level OR Phase(T2, last completed bar)[1] in {4, 6} OR Trend Score(T2, last completed bar)[1] <= 0)
Long: Cooldown Event(Confirmed Spring)
Short: Cooldown Event(Confirmed UTAD)
Long: Cooldown Event(SOS)
Short: Cooldown Event(SOW)
Long: Cooldown Event(Sweep Low)
Short: Cooldown Event(Sweep High)
Long: Phase != Phase[1] AND Phase in {1, 2, 3}
Short: Phase != Phase[1] AND Phase in {4, 5, 6}
Long: Phase in {1, 2, 3}
Short: Phase in {4, 5, 6}
Long: Trend Score >= regime trend threshold
Short: Trend Score <= -regime trend threshold
Long: Trend Score >= trend name threshold
Short: Trend Score <= -trend name threshold
Long: Confirmed Spring
Short: Confirmed UTAD
Long: SOS
Short: SOW
Long: CMF(money flow lookback) > 0
Short: CMF(money flow lookback) < 0
Long: Phase(T1, last completed bar) in {1, 2, 3}
Short: Phase(T1, last completed bar) in {4, 5, 6}
Long: Phase(T2, last completed bar) in {1, 2, 3}
Short: Phase(T2, last completed bar) in {4, 5, 6}
Long: Bull Context(T1, last completed bar) OR (Bull Context(T2, last completed bar) AND NOT Bear Context(T1, last completed bar))
Short: Bear Context(T1, last completed bar) OR (Local Bear Context(T2, last completed bar) AND NOT Bull Context(T1, last completed bar))
Long: Strong Bull Raw AND NOT Strong Bull Raw[1]
Exit: long, Risk Raw AND NOT Risk Raw[1]
Short: Bearish Reversal Raw AND NOT Bearish Reversal Raw[1]
Long: Bullish Recovery Raw AND NOT Bullish Recovery Raw[1]