Calculation: HTF = a timeframe higher than the chart timeframe; every HTF value is taken from the HTF bar that contains the current chart bar (the bar still forming, using data up to the current chart bar)
Calculation: Stack EMAs = four EMAs of HTF close with increasing lengths E1<E2<E3<E4
Calculation: Trend = EMA of HTF close whose length equals E2 (the second-shortest Stack EMA)
Calculation: Band = k * EMA(HTF true range, short length), k a fixed multiplier
Calculation: Dir (state per chart bar) = +1 if HTF close > Trend + Band; -1 if HTF close < Trend - Band; otherwise the previous bar's Dir (initially 0)
Calculation: Cloud = Trend - Band if Dir == +1; Trend + Band if Dir == -1
Long: Dir == +1 AND previous chart bar's Dir == -1 AND Stack EMAs strictly ordered E1>E2>E3>E4 (all HTF) AND HTF close >= Trend
Short: Dir == -1 AND previous chart bar's Dir == +1 AND Stack EMAs strictly ordered E1<E2<E3<E4 (all HTF) AND HTF close <= Trend
Exit: long, chart close < Cloud AND Dir == +1 OR low <= entry price * (1 - stop%) OR high >= entry price * (1 + target%)
Exit: short, chart close > Cloud AND Dir == -1 OR high >= entry price * (1 + stop%) OR low <= entry price * (1 - target%)