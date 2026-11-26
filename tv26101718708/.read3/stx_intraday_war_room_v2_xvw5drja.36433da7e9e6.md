Calculation: Trend(T) = sign(EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback)) on bars of T, last completed bar
Calculation: Swing high = last confirmed pivot high of high, pivot length bars on each side
Calculation: Swing low = last confirmed pivot low of low, pivot length bars on each side
Calculation: Structure = +1 if Swing high > previous Swing high AND Swing low > previous Swing low; -1 if Swing high < previous Swing high AND Swing low < previous Swing low; otherwise Structure[1]; initially 0 (previous Swing high = the confirmed pivot high before Swing high; same for lows)
Calculation: OTE level(r) = Swing high - (Swing high - Swing low) * r
Calculation: ADX = ADX(high, low, close, ADX DI length, ADX smoothing length)
Calculation: Displacement(d) = on bars of T3, last completed bar: for d=+1, close > open AND |close - open| / (high - low) >= OB displacement ratio AND close > high[1] AND close[1] < open[1]; for d=-1, close < open AND |close - open| / (high - low) >= OB displacement ratio AND close < low[1] AND close[1] > open[1]
Calculation: OB high(d) = high[1] and OB low(d) = low[1] at the latest bar where Displacement(d) holds, on bars of T3, last completed bar
Calculation: Armed(d) = (d=+1 AND close > OB high(+1)) OR (d=-1 AND close < OB low(-1)) OR (Armed(d)[1] AND NOT Displacement(d))
Calculation: Retest(d) = Armed(d) AND low <= OB high(d) AND high >= OB low(d)
Calculation: Sniper score(d) = max(number of these occurring among the T5 bars inside the current chart bar (still forming): displacement in d (close > open for d=+1, close < open for d=-1) with body/range > M1 displacement ratio; a low above the high two T5 bars earlier (d=+1) or a high below the low two T5 bars earlier (d=-1); a close above the highest earlier T5 high (d=+1) or below the lowest earlier T5 low (d=-1); Retest(d) - 1 if any T5 bar inside the current chart bar has displacement in -d, 0); 0 if the current chart bar has fewer than min T5 bar count T5 bars
Calculation: Sweep(d) = at least min equal-level count of the prior ICT lookback bars have a low (d=+1) or high (d=-1) within sweep tolerance of L(d), where L(+1) = lowest low and L(-1) = highest high over the prior ICT lookback bars; AND for d=+1, low < L(+1) AND close > L(+1); for d=-1, high > L(-1) AND close < L(-1)
Calculation: Recent sweep(d) = the latest bar where Sweep(+1) or Sweep(-1) holds is a Sweep(d) bar, and it lies within ICT lookback bars of the current bar
Calculation: Leg = min(max(Swing high - Swing low, min leg), max leg), fixed on the entry bar
Calculation: Target(d,k) = (OTE level(OTE low ratio) + OTE level(OTE high ratio)) / 2 + d * (Leg * leg extension k - TP buffer), fixed on the entry bar
Calculation: Initial stop(d) = OTE level(OTE high ratio) - SL buffer for d=+1, or OTE level(OTE low ratio) + SL buffer for d=-1, fixed on the entry bar
Calculation: BE level(d) = entry price + d * BE fraction * |Target(d,1) - entry price|, fixed on the entry bar
Calculation: Stop(d) = entry price if the highest high since entry including the current bar >= BE level(+1) (d=+1), or the lowest low since entry including the current bar <= BE level(-1) (d=-1); otherwise Initial stop(d)
Calculation: Market trend = 0 until Structure first becomes nonzero, then Market trend takes Structure's value; afterwards CHoCH(+1) sets it to +1 and CHoCH(-1) sets it to -1
Calculation: CHoCH(d) = Market trend = -d AND close crosses above Protected high (d=+1) or crosses below Protected low (d=-1)
Calculation: BOS(d) = Market trend = d AND close crosses above Swing high (d=+1) or crosses below Swing low (d=-1)
Calculation: Protected high = Swing high at CHoCH(+1), CHoCH(-1), BOS(-1), and when Market trend first becomes nonzero; = newly confirmed pivot high while Market trend <= 0; otherwise unchanged
Calculation: Protected low = Swing low at CHoCH(+1), CHoCH(-1), BOS(+1), and when Market trend first becomes nonzero; = newly confirmed pivot low while Market trend >= 0; otherwise unchanged
Long: Trend(T1) > 0 AND Trend(T2) > 0 AND Trend(T3) > 0 AND Structure >= 0 AND ADX >= ADX threshold AND Swing high > Swing low AND low <= OTE level(OTE low ratio) AND high >= OTE level(OTE high ratio) AND Retest(+1) AND close > open AND min(open, close) - low >= (high - low) * reject ratio AND Trend(T4) > 0 AND Sniper score(+1) >= min sniper confirmations
Long: Trend(T1) > 0 AND Trend(T2) > 0 AND Trend(T3) > 0 AND Trend(T4) > 0 AND Sniper score(+1) >= min sniper confirmations
Long: CHoCH(+1) AND Recent sweep(+1)
Long: CHoCH(+1) OR BOS(+1)
Long: Sweep(+1)
Short: Trend(T1) < 0 AND Trend(T2) < 0 AND Trend(T3) < 0 AND Structure <= 0 AND ADX >= ADX threshold AND Swing high > Swing low AND low <= OTE level(OTE low ratio) AND high >= OTE level(OTE high ratio) AND Retest(-1) AND close < open AND high - max(open, close) >= (high - low) * reject ratio AND Trend(T4) < 0 AND Sniper score(-1) >= min sniper confirmations
Short: Trend(T1) < 0 AND Trend(T2) < 0 AND Trend(T3) < 0 AND Trend(T4) < 0 AND Sniper score(-1) >= min sniper confirmations
Short: CHoCH(-1) AND Recent sweep(-1)
Short: CHoCH(-1) OR BOS(-1)
Short: Sweep(-1)
Exit: long, high >= Target(+1, 3) OR low <= Stop(+1)
Exit: short, low <= Target(-1, 3) OR high >= Stop(-1)