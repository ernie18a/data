Calculation: ImpulseLine = MA(source, shorter lookback, Impulse type, chart, current bar)
Calculation: LeadLine = MA(source, longer lookback, Lead type, chart, current bar)
Calculation: MomentumLine = MA(source, Momentum lookback, Momentum type, Momentum timeframe, current bar if chart else last completed bar)
Calculation: MainTrendLine = MA(source, MainTrend lookback, MainTrend type, MainTrend timeframe, current bar if chart else last completed bar)
Calculation: HTFRatio = max(1, round(selected HTF duration / chart duration))
Calculation: HTFLine(type, lookback) = if HTF mode is Scaled then MA(source, lookback scaled by HTFRatio, type, chart, current bar) else if HTF mode is Stepped then MA(source, lookback, type, selected HTF, last completed bar) else EMA(MA(source, lookback, type, selected HTF, last completed bar), max(2, HTFRatio), chart, current bar)
Calculation: Bull(line, paint) = (paint is Slope and line > line[1] on its own bars) or (paint is Price and close > line)
Calculation: Bear(line, paint) = (paint is Slope and line < line[1] on its own bars) or (paint is Price and close < line)
Calculation: CloudBull(fast, slow, paint) = (paint is Stack and fast > slow) or (paint is Slope and fast > fast[1] and slow > slow[1]) or (paint is Price and close > fast and close > slow)
Calculation: CloudBear(fast, slow, paint) = (paint is Stack and fast < slow) or (paint is Slope and fast < fast[1] and slow < slow[1]) or (paint is Price and close < fast and close < slow)
Calculation: TrenderBull(sources) = (some source in sources has paint other than Uni) and (every source in sources with paint other than Uni has Bull(its line, its paint)); source to (line, paint): Impulse to (ImpulseLine, Impulse paint); Lead to (LeadLine, Lead paint); Momentum to (MomentumLine, Momentum paint); MainTrend to (MainTrendLine, MainTrend paint); Impulse HTF to (HTFLine(Impulse type, shorter lookback), HTF paint); Lead HTF to (HTFLine(Lead type, longer lookback), HTF paint); Momentum HTF to (HTFLine(Momentum type, Momentum lookback), Momentum paint); VWAP to (VWAP(source), VWAP paint)
Calculation: TrenderBear(sources) = (some source in sources has paint other than Uni) and (every source in sources with paint other than Uni has Bear(its line, its paint)), with the source mapping of TrenderBull
Long: TrenderBull(Trender 1 ticked sources)
Short: TrenderBear(Trender 1 ticked sources)
Long: TrenderBull(Trender 1 ticked sources) and not TrenderBull(Trender 1 ticked sources)[1]
Short: TrenderBear(Trender 1 ticked sources) and not TrenderBear(Trender 1 ticked sources)[1]
Long: TrenderBull(Trender 2 ticked sources)
Short: TrenderBear(Trender 2 ticked sources)
Long: TrenderBull(Trender 2 ticked sources) and not TrenderBull(Trender 2 ticked sources)[1]
Short: TrenderBear(Trender 2 ticked sources) and not TrenderBear(Trender 2 ticked sources)[1]
Long: TrenderBull(Trender 3 ticked sources)
Short: TrenderBear(Trender 3 ticked sources)
Long: TrenderBull(Trender 3 ticked sources) and not TrenderBull(Trender 3 ticked sources)[1]
Short: TrenderBear(Trender 3 ticked sources) and not TrenderBear(Trender 3 ticked sources)[1]
Long: CloudBull(ImpulseLine, LeadLine, cloud paint)
Short: CloudBear(ImpulseLine, LeadLine, cloud paint)
Long: CloudBull(ImpulseLine, LeadLine, cloud paint) and not CloudBull(ImpulseLine, LeadLine, cloud paint)[1]
Short: CloudBear(ImpulseLine, LeadLine, cloud paint) and not CloudBear(ImpulseLine, LeadLine, cloud paint)[1]
Long: CloudBull(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint)
Short: CloudBear(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint)
Long: CloudBull(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint) and not CloudBull(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint)[1]
Short: CloudBear(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint) and not CloudBear(HTFLine(Impulse type, shorter lookback), HTFLine(Lead type, longer lookback), cloud paint)[1]
Long: Bull(ImpulseLine, Impulse paint)
Short: Bear(ImpulseLine, Impulse paint)
Long: Bull(LeadLine, Lead paint)
Short: Bear(LeadLine, Lead paint)
Long: Bull(MomentumLine, Momentum paint)
Short: Bear(MomentumLine, Momentum paint)
Long: Bull(MainTrendLine, MainTrend paint)
Short: Bear(MainTrendLine, MainTrend paint)
Long: Bull(HTFLine(Impulse type, shorter lookback), HTF paint)
Short: Bear(HTFLine(Impulse type, shorter lookback), HTF paint)
Long: Bull(HTFLine(Lead type, longer lookback), HTF paint)
Short: Bear(HTFLine(Lead type, longer lookback), HTF paint)
Long: Bull(HTFLine(Momentum type, Momentum lookback), Momentum paint)
Short: Bear(HTFLine(Momentum type, Momentum lookback), Momentum paint)
Long: Bull(VWAP(source), VWAP paint)
Short: Bear(VWAP(source), VWAP paint)
Long: Bull(MomentumLine, Momentum paint) and not Bull(MomentumLine, Momentum paint)[1]
Short: Bear(MomentumLine, Momentum paint) and not Bear(MomentumLine, Momentum paint)[1]
Long: Bull(MainTrendLine, MainTrend paint) and not Bull(MainTrendLine, MainTrend paint)[1]
Short: Bear(MainTrendLine, MainTrend paint) and not Bear(MainTrendLine, MainTrend paint)[1]
Long: Bull(VWAP(source), VWAP paint) and not Bull(VWAP(source), VWAP paint)[1]
Short: Bear(VWAP(source), VWAP paint) and not Bear(VWAP(source), VWAP paint)[1]