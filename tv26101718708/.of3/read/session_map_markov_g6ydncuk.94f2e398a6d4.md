Calculation: Opening-range high = highest high of chart bars starting from regular-hours session start up to, but excluding, session start plus the opening-range duration
Calculation: Opening-range low = lowest low of chart bars starting from regular-hours session start up to, but excluding, session start plus the opening-range duration
Calculation: Initial-balance high = highest high of chart bars starting from regular-hours session start up to, but excluding, session start plus the initial-balance duration
Calculation: Initial-balance low = lowest low of chart bars starting from regular-hours session start up to, but excluding, session start plus the initial-balance duration
Calculation: Session VWAP = cumulative sum(weight × HLC3) / cumulative sum(weight) since the most recent regular-hours session start, where weight = volume when positive and 1 otherwise
Calculation: Session VWAP standard deviation = sqrt(max(0, cumulative sum(weight × HLC3^2) / cumulative sum(weight) − session VWAP^2)) over the same bars
Long: During regular-hours, after the opening-range duration ends, if no opening-range long signal has occurred this session, close > opening-range high
Short: During regular-hours, after the opening-range duration ends, if no opening-range short signal has occurred this session, close < opening-range low
Long: During regular-hours, after the initial-balance duration ends, if no initial-balance long signal has occurred this session, close > initial-balance high
Short: During regular-hours, after the initial-balance duration ends, if no initial-balance short signal has occurred this session, close < initial-balance low
Long: At chart-bar close, session VWAP standard deviation > 0 AND low <= session VWAP − deviation multiplier × session VWAP standard deviation
Short: At chart-bar close, session VWAP standard deviation > 0 AND high >= session VWAP + deviation multiplier × session VWAP standard deviation