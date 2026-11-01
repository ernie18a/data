Calculation: Upper channel at a bar = highest high over a configurable number of bars starting at a configurable offset before that bar.
Calculation: Lower channel at a bar = lowest low over a separately configurable number of bars starting at a separately configurable offset before that bar.
Long: Chart bar close > upper channel AND chart bar close >= lower channel.
Short: Chart bar close < lower channel.
Long: Last completed higher-timeframe bar close > its upper channel AND its close >= its lower channel AND (the preceding higher-timeframe bar close <= its upper channel OR its close < its lower channel).
Short: Last completed higher-timeframe bar close < its lower channel AND preceding higher-timeframe bar close >= its lower channel.
Exit: long, last completed higher-timeframe bar close < its lower channel.
Exit: short, last completed higher-timeframe bar close > its upper channel AND its close >= its lower channel.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.