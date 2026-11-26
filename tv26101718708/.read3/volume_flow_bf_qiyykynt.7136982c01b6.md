Calculation: Bull volume average = selected MA(volume if close > open else 0, MA lookback)
Calculation: Bear volume average = selected MA(volume if open > close else 0, same MA lookback and type as bull volume average)
Calculation: Movement filter = EMA(ROC(close, ROC lookback), half the ROC lookback) > half the movement threshold OR EMA(ROC(close, ROC lookback), half the ROC lookback) < negative half the movement threshold
Calculation: Latest long-condition time = current bar datetime when bull volume average > bear volume average AND movement filter; otherwise its prior value, initialized at zero
Calculation: Latest short-condition time = current bar datetime when bull volume average < bear volume average AND movement filter; otherwise its prior value, initialized at zero
Calculation: Latest long-signal open = current open when latest long-condition time crosses above latest short-condition time; otherwise its prior value, initialized at zero
Calculation: Latest short-signal open = current open when latest short-condition time crosses above latest long-condition time; otherwise its prior value, initialized at zero
Calculation: Long exit delay = bars since latest long-signal open differs from its prior-bar value
Calculation: Short exit delay = bars since latest short-signal open differs from its prior-bar value
Long: bull volume average > bear volume average AND movement filter
Short: bull volume average < bear volume average AND movement filter
Long: latest long-condition time crosses above latest short-condition time
Short: latest short-condition time crosses above latest long-condition time
Exit: Long, long exit delay > 0 AND (low <= entry price × (1 − stop-loss parameter) OR high >= entry price × (1 + take-profit parameter))
Exit: Short, short exit delay > 0 AND (high >= entry price × (1 + stop-loss parameter) OR low <= entry price × (1 − take-profit parameter))