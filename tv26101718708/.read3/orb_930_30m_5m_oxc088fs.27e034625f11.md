Calculation: PipUnit = tick size * pip multiplier parameter if the decimal places of tick size are in the pip digit set parameter, else tick size
Calculation: BandTop(TF, S) = high of the last completed TF bar that starts at time S on the current day, taken on chart bars; undefined until that bar completes
Calculation: BandBottom(TF, S) = low of the last completed TF bar that starts at time S on the current day, taken on chart bars; undefined until that bar completes
Calculation: FirstBreakout(TF, S) = direction of the first chart bar, from the bar where BandTop(TF, S) is first defined today through the current bar, that closes above BandTop(TF, S) or below BandBottom(TF, S): 1 if above, -1 if below; 0 if none
Calculation: ChartBandTop = BandTop(T2, session open time) if chart timeframe is shorter than T2; BandTop(T3, session open time) if chart timeframe is at least T2 and at most T3; undefined otherwise
Calculation: ChartBandBottom = BandBottom(T2, session open time) if chart timeframe is shorter than T2; BandBottom(T3, session open time) if chart timeframe is at least T2 and at most T3; undefined otherwise
Calculation: ChartBreakout = FirstBreakout(T2, session open time) if chart timeframe = T1; FirstBreakout(T3, session open time) if chart timeframe = T2; 0 otherwise
Calculation: RunLength = number of consecutive bars ending at the current bar with the same direction as the current bar, where a bar is up if close >= open and down otherwise
Calculation: RunTop = highest of max(open, close) over the bars counted by RunLength
Calculation: RunBottom = lowest of min(open, close) over the bars counted by RunLength
Calculation: RunBase = the bar immediately before the bars counted by RunLength
Calculation: UpEngulfs = current bar is up AND RunTop >= high of RunBase AND high of RunBase >= ChartBandBottom AND low of RunBase <= ChartBandTop
Calculation: DownEngulfs = current bar is down AND RunBottom <= low of RunBase AND high of RunBase >= ChartBandBottom AND low of RunBase <= ChartBandTop
Calculation: EntryTakenBefore = on any earlier bar today, (FirstBreakout(T2, session open time) = 1 AND UpEngulfs) OR (FirstBreakout(T2, session open time) = -1 AND DownEngulfs)
Long: chart timeframe = T1 AND FirstBreakout(T2, session open time) = 1 AND FirstBreakout(T2, session open time)[1] = 0
Short: chart timeframe = T1 AND FirstBreakout(T2, session open time) = -1 AND FirstBreakout(T2, session open time)[1] = 0
Long: chart timeframe = T2 AND FirstBreakout(T3, session open time) = 1 AND FirstBreakout(T3, session open time)[1] = 0
Short: chart timeframe = T2 AND FirstBreakout(T3, session open time) = -1 AND FirstBreakout(T3, session open time)[1] = 0
Long: chart timeframe = T2 AND FirstBreakout(T3, pre-session window start time) = 1 AND FirstBreakout(T3, pre-session window start time)[1] = 0
Short: chart timeframe = T2 AND FirstBreakout(T3, pre-session window start time) = -1 AND FirstBreakout(T3, pre-session window start time)[1] = 0
Long: UpEngulfs AND ChartBreakout[1] = 0 AND NOT (UpEngulfs[1] AND ChartBreakout[2] = 0) AND RunLength <= max run length parameter
Short: DownEngulfs AND ChartBreakout[1] = 0 AND NOT (DownEngulfs[1] AND ChartBreakout[2] = 0) AND RunLength <= max run length parameter
Long: chart timeframe = T1 AND FirstBreakout(T2, session open time) = 1 AND UpEngulfs AND NOT EntryTakenBefore
Short: chart timeframe = T1 AND FirstBreakout(T2, session open time) = -1 AND DownEngulfs AND NOT EntryTakenBefore
Exit: long, low <= entry price - stop-loss pips parameter * PipUnit OR high >= entry price + take-profit pips parameter * PipUnit
Exit: short, high >= entry price + stop-loss pips parameter * PipUnit OR low <= entry price - take-profit pips parameter * PipUnit