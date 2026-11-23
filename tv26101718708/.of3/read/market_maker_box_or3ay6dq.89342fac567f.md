Calculation: Clamp(v, lo, hi) = max(lo, min(hi, v))
Calculation: Span = High(T1, last completed bar) - Low(T1, last completed bar)
Calculation: Body = (Close(T1, last completed bar) - Open(T1, last completed bar)) / Span
Calculation: Pos = (Close(T1, last completed bar) - Low(T1, last completed bar)) / Span
Calculation: Atr = ATR(ATR length, T1, last completed bar)
Calculation: Fast = EMA(close, fast EMA length, T1, last completed bar)
Calculation: Slow = EMA(close, slow EMA length, T1, last completed bar)
Calculation: Extension = (Close(T1, last completed bar) - Slow) / Atr
Calculation: Progress = (time of chart bar - start time of forming T1 bar) / duration of T1 bar
Calculation: T2Body = Close(T2, last completed bar) - Open(T2, last completed bar)
Calculation: Sweep = -sweep score if High(T1, last completed bar) > High(T1, last completed bar)[1] AND Close(T1, last completed bar) < High(T1, last completed bar)[1] AND Pos < 0.5; +sweep score if Low(T1, last completed bar) < Low(T1, last completed bar)[1] AND Close(T1, last completed bar) > Low(T1, last completed bar)[1] AND Pos > 0.5; else 0
Calculation: Live = (close - Open(T1, forming bar)) / max(High(T1, forming bar) - Low(T1, forming bar), Atr * live range floor) * live scale
Calculation: TrendTerm = Clamp((Fast - Slow) / Atr * trend scale, -trend cap, trend cap)
Calculation: SlopeTerm = Clamp((Fast - Fast[slope lookback]) / Atr * slope scale, -slope cap, slope cap)
Calculation: Trend = TrendTerm + SlopeTerm + Clamp(T2Body / Atr * six scale, -six cap, six cap) + (if T2Body * T2Body[1] > 0 then Clamp(T2Body / Atr * six sequence scale, -six sequence cap, six sequence cap) else 0) + Clamp((Close(T3, last completed bar) - Open(T3, last completed bar)) / Atr * daily scale, -daily cap, daily cap) + Clamp((Close(T1, last completed bar) - Slow) / Atr * location scale, -location cap, location cap)
Calculation: TrendSign = 1 if Trend >= trend threshold; -1 if Trend <= -trend threshold; else 0
Calculation: Raw = Trend + Body * continuation scale + (Pos - 0.5) * close-location scale + Sweep + Live * (if Live * TrendSign >= 0 then Progress * live agree weight else max(0, Progress - late live cutoff) * late live weight)
Calculation: Lean = if TrendSign != 0 AND NOT (Sweep * TrendSign < 0 AND Progress >= sweep progress threshold AND Live * Sweep > 0) then (if |Trend| >= strong trend threshold then (max(Raw, conviction threshold) if TrendSign > 0 else min(Raw, -conviction threshold)) else if Raw * TrendSign < 0 then 0 else Raw) else Raw
Calculation: Rsi = RSI(close, RSI length, T1, last completed bar)
Calculation: Activity = Volume(T1, last completed bar) / SMA(volume, volume average length, T1, last completed bar)
Calculation: Bias = TrendTerm + SlopeTerm + (if |Extension| > stretch trigger then Clamp(-Extension * stretch scale, -stretch cap, stretch cap) else 0) + (if Rsi >= RSI overbought then -RSI extreme score else if Rsi <= RSI oversold then RSI extreme score else (Rsi - 50) / RSI divisor * RSI weight) + Body * bias body scale + (if Activity > volume high ratio then Body * volume body scale else if Activity < volume low ratio then -Body * low-volume body scale else 0)
Long: Span > 0 AND Lean >= conviction threshold
Short: Span > 0 AND Lean <= -conviction threshold
Long: Span > 0 AND Bias > bias threshold
Short: Span > 0 AND Bias < -bias threshold
Long: Lean[1] < conviction threshold AND Lean >= conviction threshold
Short: Lean[1] > -conviction threshold AND Lean <= -conviction threshold
Long: Span > 0 AND Span / close * 100 >= min box width AND Lean >= conviction threshold AND close <= High(T1, last completed bar) AND close >= Low(T1, last completed bar)
Short: Span > 0 AND Span / close * 100 >= min box width AND Lean <= -conviction threshold AND close <= High(T1, last completed bar) AND close >= Low(T1, last completed bar)
Long: Span > 0 AND Span / close * 100 >= min box width AND Lean >= conviction threshold AND (close > High(T1, last completed bar) OR close < Low(T1, last completed bar))
Short: Span > 0 AND Span / close * 100 >= min box width AND Lean <= -conviction threshold AND (close > High(T1, last completed bar) OR close < Low(T1, last completed bar))
Long: Span > 0 AND low <= Low(T1, last completed bar) AND low[1] > Low(T1, last completed bar)
Short: Span > 0 AND high >= High(T1, last completed bar) AND high[1] < High(T1, last completed bar)
Long: Span > 0 AND new T1 bar starts on this chart bar AND Close(T1, last completed bar) > High(T1, last completed bar)[1]
Short: Span > 0 AND new T1 bar starts on this chart bar AND Close(T1, last completed bar) < Low(T1, last completed bar)[1]