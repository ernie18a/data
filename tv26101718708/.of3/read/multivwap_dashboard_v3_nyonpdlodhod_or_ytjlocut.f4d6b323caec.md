Calculation: NY session VWAP(S) = VWAP(source, anchored at NY session start), undefined outside NY session, where S is the traded instrument or an index-futures series
Calculation: overnight VWAP(S) = VWAP(source, anchored at overnight anchor time), defined only from that anchor through the next NY session end
Calculation: previous-session VWAP(S) = VWAP(source, anchored at previous NY session start, excluding the current NY session start bar), undefined outside NY session
Calculation: session-low VWAP(S) = VWAP(source, anchored at the lowest low since NY session start, earliest bar on ties), undefined outside NY session
Calculation: session-high VWAP(S) = VWAP(source, anchored at the highest high since NY session start, earliest bar on ties), undefined outside NY session
Calculation: AboveCount(S) = number of NY session VWAP(S), overnight VWAP(S), previous-session VWAP(S), session-low VWAP(S), session-high VWAP(S) that are below close(S)
Calculation: OR high(S, D) = highest high of S bars from the latest NY session start with time before that start plus D minutes
Calculation: OR low(S, D) = lowest low of S bars from the latest NY session start with time before that start plus D minutes
Calculation: OR mid(S, D) = (OR high(S, D) + OR low(S, D)) / 2
Long: close(S) > NY session VWAP(S)
Short: not (close(S) > NY session VWAP(S))
Long: close(S) > overnight VWAP(S)
Short: not (close(S) > overnight VWAP(S))
Long: close(S) > previous-session VWAP(S)
Short: not (close(S) > previous-session VWAP(S))
Long: close(S) > session-low VWAP(S)
Short: not (close(S) > session-low VWAP(S))
Long: close(S) > session-high VWAP(S)
Short: not (close(S) > session-high VWAP(S))
Long: AboveCount(S) >= trend threshold
Short: AboveCount(S) <= VWAP count - trend threshold
Long: close(S) > OR mid(S, short OR duration)
Short: close(S) <= OR mid(S, short OR duration)
Long: close(S) > OR mid(S, long OR duration)
Short: close(S) <= OR mid(S, long OR duration)
Long: close(S) crosses above OR high(S, short OR duration) AND within NY session AND elapsed minutes since NY session start >= short OR duration
Short: close(S) crosses below OR low(S, short OR duration) AND within NY session AND elapsed minutes since NY session start >= short OR duration