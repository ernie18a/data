Calculation: Pivot(n) = the n-th newest entry (n = 1 is newest) of a list of alternating pivots with fields price, type and bar; each new PivotHigh(high, pivot left, pivot right) or PivotLow(low, pivot left, pivot right) is added as the newest entry if its type differs from the newest entry's type, otherwise it replaces the newest entry only if more extreme
Calculation: Leg = Pivot(2).price - Pivot(3).price
Calculation: Retracement = (Pivot(2).price - Pivot(1).price) / Leg
Calculation: Confluence = Pivot(5) exists AND sign(Pivot(2).price - Pivot(5).price) = sign(Leg) AND min over r, s in {fib low ratio, fib high ratio} of abs(s * (Pivot(2).price - Pivot(5).price) - r * Leg) <= ATR(ATR length) * confluence tolerance, where fib low ratio < fib high ratio
Calculation: StopLevel = Pivot(1).price - ATR(ATR length) * stop buffer for long, or Pivot(1).price + ATR(ATR length) * stop buffer for short, evaluated at the entry bar
Calculation: Objective(k) = Pivot(1).price + k * Leg, for k = COP ratio, OP ratio or XOP ratio, where COP ratio < OP ratio < XOP ratio, evaluated at the entry bar
Long: Pivot(1).type is low AND Leg > 0 AND abs(Leg) >= ATR(ATR length) * min swing AND Pivot(1).bar differs from the Pivot(1).bar of the last fired signal AND Retracement >= min retrace AND Retracement <= max retrace AND (trend filter off OR close > SMA(close, trend SMA length)[trend SMA displacement]) AND (smoothing filter off OR close > MA(close, smoothing method, smoothing length)) AND (ADX filter off OR ADX(ADX length, ADX smoothing) >= ADX min) AND (HTF filter off OR close > close(T1, last completed bar)) AND (confluence filter off OR Confluence) AND (lock signal off OR bar is not the last bar)
Short: Pivot(1).type is high AND Leg < 0 AND abs(Leg) >= ATR(ATR length) * min swing AND Pivot(1).bar differs from the Pivot(1).bar of the last fired signal AND Retracement >= min retrace AND Retracement <= max retrace AND (trend filter off OR close < SMA(close, trend SMA length)[trend SMA displacement]) AND (smoothing filter off OR close < MA(close, smoothing method, smoothing length)) AND (ADX filter off OR ADX(ADX length, ADX smoothing) >= ADX min) AND (HTF filter off OR close < close(T1, last completed bar)) AND (confluence filter off OR Confluence) AND (lock signal off OR bar is not the last bar)
Exit: long, low <= StopLevel
Exit: long, high >= Objective(COP ratio) AND low > StopLevel
Exit: long, high >= Objective(OP ratio) AND low > StopLevel
Exit: long, high >= Objective(XOP ratio) AND low > StopLevel
Exit: short, high >= StopLevel
Exit: short, low <= Objective(COP ratio) AND high < StopLevel
Exit: short, low <= Objective(OP ratio) AND high < StopLevel
Exit: short, low <= Objective(XOP ratio) AND high < StopLevel