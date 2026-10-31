Calculation: Upper channel = Jurik moving average of the SATL digital filter of high, rounded to the nearest configured price increment and shifted forward by a configured number of bars.
Calculation: Lower channel = Jurik moving average of the SATL digital filter of low using the same smoothing parameters, rounded to the same price increment and shifted forward by the same number of bars.
Long: Chart-bar close > upper channel AND chart-bar close >= lower channel.
Short: Chart-bar close < lower channel.
Long: Last completed higher-timeframe bar close > its upper channel AND close >= its lower channel AND (previous higher-timeframe bar close <= its upper channel OR previous higher-timeframe bar close < its lower channel).
Short: Last completed higher-timeframe bar close < its lower channel AND previous higher-timeframe bar close >= its lower channel.
Exit: long, last completed higher-timeframe bar close < its lower channel OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, (last completed higher-timeframe bar close > its upper channel AND close >= its lower channel) OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.