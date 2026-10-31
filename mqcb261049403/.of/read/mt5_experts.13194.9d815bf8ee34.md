Calculation: zero-lag average = 2 × a first moving average of a selected bar price − a second moving average of the first moving average; the two smoothing methods and lengths are independently selectable
Long: chart-timeframe zero-lag average > its previous-bar value
Short: chart-timeframe zero-lag average < its previous-bar value
Long: higher-timeframe zero-lag average on the last completed bar > its value on the preceding bar AND its value two bars before the last completed bar > its value on the preceding bar
Short: higher-timeframe zero-lag average on the last completed bar < its value on the preceding bar AND its value two bars before the last completed bar < its value on the preceding bar
Exit: long, higher-timeframe zero-lag average on the last completed bar < its value on the preceding bar
Exit: short, higher-timeframe zero-lag average on the last completed bar > its value on the preceding bar
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance