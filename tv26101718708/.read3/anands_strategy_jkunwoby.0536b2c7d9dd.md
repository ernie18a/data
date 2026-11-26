Calculation: T1 reference high/low = high/low of the reference T1 bar, initialized from the bar before the last completed T1 bar and replaced by each searched earlier T1 bar whose high is below or low is above the last completed T1 close; calculate on chart bars using completed T1 bars
Calculation: T2 reference high/low = high/low of the reference T2 bar, initialized from the bar before the last completed T2 bar and replaced by each searched earlier T2 bar whose high is below or low is above the last completed T2 close; calculate on chart bars using completed T2 bars
Long: close of the last completed T1 bar > T1 reference high
Short: close of the last completed T1 bar < T1 reference low
Long: close of the last completed T1 bar > T1 reference high AND close of the last completed T2 bar > T2 reference high
Short: close of the last completed T1 bar < T1 reference low AND close of the last completed T2 bar < T2 reference low
Exit: long, chart-bar low <= T2 reference low at the entry signal
Exit: short, chart-bar high >= T2 reference high at the entry signal