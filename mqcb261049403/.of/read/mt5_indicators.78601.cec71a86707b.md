Calculation: Completed session high and low = maximum high and minimum low of chart bars whose opening times fall within the most recently completed occurrence of a configured session; the start hour is inclusive and the end hour exclusive, including sessions spanning midnight.
Calculation: Active session high and low = maximum high and minimum low of chart bars in the current occurrence of a configured session, using completed bars and the current bar's opening price; the session uses the same time boundaries as the completed session.
Long: Current bar close > completed session high.
Short: Current bar close < completed session low.
Long: Current bar opening time is within a configured session AND previous bar close > active session high.
Short: Current bar opening time is within a configured session AND previous bar close < active session low.