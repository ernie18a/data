Calculation: Anchor reset = first chart bar of each new T1 bar
Calculation: VWAP = VWAP(source, Anchor reset)
Calculation: VWAP deviation = VWAP standard deviation(source, Anchor reset)
Calculation: Inner upper = VWAP + inner multiplier * VWAP deviation, where inner multiplier < outer multiplier
Calculation: Inner lower = VWAP - inner multiplier * VWAP deviation
Calculation: Ready = volume > 0 AND VWAP deviation >= tick size AND bars since Anchor reset, current bar counted as 1, >= minimum bars after reset
Calculation: ADX value = ADX(DI length, ADX smoothing)
Calculation: ADX gate = NOT ADX filter OR (ADX value and ADX value[1] defined AND NOT (ADX value > ADX threshold AND ADX value > ADX value[1]))
Calculation: Grid spacing = custom spacing in custom round mode, otherwise round group factor * base spacing(instrument class, 10^floor(log10(close[1]))) rounded to a tick multiple
Calculation: Grid tolerance = custom tolerance in custom round mode, otherwise round tolerance percent / 100 * Grid spacing
Calculation: Short VWAP touch = (wick mode AND Low <= VWAP) OR (NOT wick mode AND Close <= VWAP)
Calculation: Long VWAP touch = (wick mode AND High >= VWAP) OR (NOT wick mode AND Close >= VWAP)
Calculation: Short trigger = (wick mode AND High > Inner upper AND High > max(Open, Close) AND Low > VWAP AND (NOT round filter OR (Grid spacing = Grid spacing[1] AND |High - round(High / Grid spacing) * Grid spacing| <= Grid tolerance)) AND (NOT wick quality filter OR High - max(Open, Close) >= max(|Close - Open| * minimum wick/body ratio, (High - Low) * minimum wick/range percent / 100))) OR (NOT wick mode AND Close > VWAP + outer multiplier * VWAP deviation)
Calculation: Long trigger = (wick mode AND Low < Inner lower AND Low < min(Open, Close) AND High < VWAP AND (NOT round filter OR (Grid spacing = Grid spacing[1] AND |Low - round(Low / Grid spacing) * Grid spacing| <= Grid tolerance)) AND (NOT wick quality filter OR min(Open, Close) - Low >= max(|Close - Open| * minimum wick/body ratio, (High - Low) * minimum wick/range percent / 100))) OR (NOT wick mode AND Close < VWAP - outer multiplier * VWAP deviation)
Calculation: Short free = false if Short start; true if Anchor reset OR (Ready AND Short VWAP touch); otherwise Short free[1]
Calculation: Long free = false if Long start; true if Anchor reset OR (Ready AND Long VWAP touch); otherwise Long free[1]
Calculation: Last short start = bar index if Short start; undefined if Anchor reset; otherwise Last short start[1]
Calculation: Last long start = bar index if Long start; undefined if Anchor reset; otherwise Last long start[1]
Calculation: Short start = Ready AND (Setup[1] = 0 OR Cancel) AND Short trigger AND ((wick mode AND repeat setups AND (Last short start[1] undefined OR bar index - Last short start[1] >= minimum setup spacing)) OR ((NOT wick mode OR NOT repeat setups) AND Short free[1]))
Calculation: Long start = Ready AND (Setup[1] = 0 OR Cancel) AND NOT Short start AND Long trigger AND ((wick mode AND repeat setups AND (Last long start[1] undefined OR bar index - Last long start[1] >= minimum setup spacing)) OR ((NOT wick mode OR NOT repeat setups) AND Long free[1]))
Calculation: Cancel = Setup[1] != 0 AND ((Setup[1] < 0 AND Short VWAP touch) OR (Setup[1] > 0 AND Long VWAP touch) OR (|Setup[1]| >= 2 AND bar index - C1 bar[1] > maximum wait) OR (Setup[1] = -3 AND Close > Peak close[1]) OR (Setup[1] = +3 AND Close < Peak close[1]))
Calculation: Setup = 0 if not Ready; -1 if Short start; +1 if Long start; 0 if Cancel; otherwise by Setup[1]: -1 -> -2 if Close < Open, else -1; +1 -> +2 if Close > Open, else +1; -2 -> -1 if Close > Peak close[1], else -3 if Close < Open AND Close < C1 close[1], else -2; +2 -> +1 if Close < Peak close[1], else +3 if Close > Open AND Close > C1 close[1], else +2; -3 -> 0 if Close < C2 close[1], else -3; +3 -> 0 if Close > C2 close[1], else +3; 0 -> 0
Calculation: Peak close = Close if Short start or Long start; max(Peak close[1], Close) if Setup[1] is -1 or -2; min(Peak close[1], Close) if Setup[1] is +1 or +2; otherwise Peak close[1]
Calculation: C1 close = Close on the bar Setup changes to -2 or +2; otherwise C1 close[1]
Calculation: C1 bar = bar index on the bar Setup changes to -2 or +2; otherwise C1 bar[1]
Calculation: C2 close = Close on the bar Setup changes to -3 or +3; otherwise C2 close[1]
Short: Setup[1] = -3 AND Ready AND NOT Short VWAP touch AND bar index - C1 bar[1] <= maximum wait AND Close < C2 close[1] AND Close >= Inner upper AND ADX gate
Long: Setup[1] = +3 AND Ready AND NOT Long VWAP touch AND bar index - C1 bar[1] <= maximum wait AND Close > C2 close[1] AND Close <= Inner lower AND ADX gate