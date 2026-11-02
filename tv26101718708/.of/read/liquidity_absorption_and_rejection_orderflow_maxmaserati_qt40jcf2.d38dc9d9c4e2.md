Calculation: Analysis bar = the completed chart bar, or the last completed bar of a higher timeframe when a higher timeframe is selected; update higher-timeframe decisions on the first chart bar of each new higher-timeframe bar.
Calculation: Active levels = highs and lows of prior analysis bars that have not been reached by a later analysis bar; keep at most a configurable number of active highs and active lows, discarding the oldest when necessary. A high is reached when the analysis-bar high is at least the level; a low is reached when the analysis-bar low is at most the level. Remove reached levels before adding the current analysis bar's high and low. For each side, classify the newest and oldest levels reached in an update, and retain those classifications until the next update that reaches a level on that side.
Calculation: Volume ratio = current chart-bar volume divided by its simple moving average, including the current bar; use one when the average is not positive.
Calculation: Strong body = absolute analysis-bar close minus open, divided by analysis-bar high minus low, is greater than a body-fraction threshold; treat a zero-range bar as not having a strong body.
Calculation: Low-volume trap = volume ratio is at most the capitulation threshold AND NOT (volume ratio is at least the absorption threshold AND strong body).
Long: Analysis-bar close > analysis-bar open.
Short: Analysis-bar close < analysis-bar open.
Long: Volume ratio >= absorption threshold AND volume ratio < exhaustion threshold AND analysis-bar close >= analysis-bar open.
Short: Volume ratio >= absorption threshold AND volume ratio < exhaustion threshold AND analysis-bar close < analysis-bar open.
Long: A reached high level has analysis-bar close >= level AND low-volume trap is false.
Short: A reached high level has analysis-bar close < level OR (analysis-bar close >= level AND low-volume trap is true).
Long: A reached low level has analysis-bar close > level OR (analysis-bar close <= level AND low-volume trap is true).
Short: A reached low level has analysis-bar close <= level AND low-volume trap is false.
Long: Chart-bar close > a retained reached level.
Short: Chart-bar close <= a retained reached level.