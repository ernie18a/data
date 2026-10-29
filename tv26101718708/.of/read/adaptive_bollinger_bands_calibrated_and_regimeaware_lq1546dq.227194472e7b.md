Calculation: Main bands = selected price-source basis plus/minus the selected deviation estimate times the main-band multiplier; inner and outer bands use shorter and longer multipliers, respectively
Calculation: %B = (price source − lower main band) / (upper main band − lower main band)
Calculation: Band z-score = (price source − basis) / upper deviation when price source is at or above basis, otherwise (price source − basis) / lower deviation
Calculation: Trend regime = ADX exceeds its threshold AND efficiency ratio exceeds its threshold; bull trend = close above the trend EMA, bear trend = close at or below it; range regime = neither trending nor volatile
Calculation: Volatility thrust = volume exceeds its longer-lookback volume average times a confirmation factor; if volume is unavailable, confirmation passes
Calculation: Band walk = consecutive closes above the upper main band or below the lower main band for at least the walk threshold
Calculation: Higher-timeframe %B direction = sign of %B minus 0.5, using 20-bar SMA bands at two standard deviations; use the configured higher-timeframe data with lookahead off
Long: Range regime AND low <= lower main band AND close > lower main band AND (previous bar %B <= 0 OR previous bar band z-score <= negative main-band multiplier) AND volume confirmation if enabled AND bar-close confirmation if enabled
Short: Range regime AND high >= upper main band AND close < upper main band AND (previous bar %B >= 1 OR previous bar band z-score >= main-band multiplier) AND volume confirmation if enabled AND bar-close confirmation if enabled
Long: Trend regime AND close > trend EMA AND (upward band walk OR (close > inner upper band AND close > previous close)) AND volume confirmation if enabled AND bar-close confirmation if enabled AND (higher-timeframe gate disabled OR higher-timeframe %B direction >= 0)
Short: Trend regime AND close <= trend EMA AND (downward band walk OR (close < inner lower band AND close < previous close)) AND volume confirmation if enabled AND bar-close confirmation if enabled AND (higher-timeframe gate disabled OR higher-timeframe %B direction <= 0)
Long: Squeeze has ended within the recent expansion window AND bandwidth is rising AND close > basis
Short: Squeeze has ended within the recent expansion window AND bandwidth is rising AND close <= basis
Long: Price makes a lower pivot low while %B makes a higher pivot low
Short: Price makes a higher pivot high while %B makes a lower pivot high
Long: A fade or ride long signal is present AND conviction meets its minimum AND no veto applies
Short: A fade or ride short signal is present AND conviction meets its minimum AND no veto applies
Exit: Long, low <= stop price OR high >= second target
Exit: Short, high >= stop price OR low <= second target