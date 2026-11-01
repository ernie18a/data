Calculation: Session VWAP = cumulative sum of typical price × volume divided by cumulative volume, resetting at each new day; typical price = (high + low + close) / 3.
Calculation: Opening-range high and low = highest high and lowest low of regular-session bars whose opening times fall within the configured opening interval; lock them after that interval and reset them each new day.
Calculation: Active swing high or low = the most recent pivot high or low confirmed during the configured trading-hours window, using equal numbers of bars on both sides. Each newly confirmed pivot replaces the corresponding level and makes it unswept; the first qualifying sweep consumes it. Levels persist across days until replaced.
Calculation: Bullish sweep = regular-session bar AND active swing low is unswept AND low < active swing low AND close > active swing low AND close − low >= ATR × minimum sweep multiplier AND bars since the preceding bullish sweep >= cooldown, or no preceding bullish sweep exists.
Calculation: Bearish sweep = regular-session bar AND active swing high is unswept AND high > active swing high AND close < active swing high AND high − close >= ATR × minimum sweep multiplier AND bars since the preceding bearish sweep >= cooldown, or no preceding bearish sweep exists.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Bars since the most recent bullish sweep = confirmation delay AND close > that sweep bar's low AND close > open.
Short: Bars since the most recent bearish sweep = confirmation delay AND close < that sweep bar's high AND close < open.
Long: low <= session VWAP AND close > session VWAP.
Short: high >= session VWAP AND close < session VWAP.
Long: Opening range is locked AND close > opening-range high AND previous close <= opening-range high.
Short: Opening range is locked AND close < opening-range low AND previous close >= opening-range low.
Long: Opening range is locked AND low <= opening-range high AND close > opening-range high.
Short: Opening range is locked AND high >= opening-range low AND close < opening-range low.
Long: Regular-session bar AND short-period EMA of close > long-period EMA of close AND close > session VWAP AND close > open AND (absolute distance from close to long-period EMA < ATR × proximity multiplier OR absolute distance from close to session VWAP < ATR × proximity multiplier OR (opening range is locked AND (absolute distance from close to opening-range high < ATR × proximity multiplier OR absolute distance from close to opening-range low < ATR × proximity multiplier))).
Short: Regular-session bar AND short-period EMA of close < long-period EMA of close AND close < session VWAP AND close < open AND (absolute distance from close to long-period EMA < ATR × proximity multiplier OR absolute distance from close to session VWAP < ATR × proximity multiplier OR (opening range is locked AND (absolute distance from close to opening-range high < ATR × proximity multiplier OR absolute distance from close to opening-range low < ATR × proximity multiplier))).