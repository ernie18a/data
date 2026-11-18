Long: On chart bars, close crosses above valuewhen(time(T1, session), high of the current T1 bar, 0)
Short: On chart bars, close crosses below valuewhen(time(T1, session), low of the current T1 bar, 0)
Exit: long, Heikin-Ashi close < Heikin-Ashi open AND Heikin-Ashi close[1] < Heikin-Ashi open[1]
Exit: short, Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi close[1] > Heikin-Ashi open[1]