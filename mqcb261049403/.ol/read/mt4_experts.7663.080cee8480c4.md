Calculation: Prior completed higher-timeframe close = close of the last completed bar on a higher timeframe.
Calculation: Current higher-timeframe open = open of the still-forming bar on a higher timeframe.
Calculation: Lookback high = highest high across the configured lookback bars on a higher timeframe, excluding the last completed and still-forming bars.
Calculation: Lookback low = lowest low across the same configured lookback bars on a higher timeframe, excluding the last completed and still-forming bars.
Calculation: Higher-timeframe SMA = simple moving average of close over its configured lookback, evaluated on the last completed bar of a higher timeframe.
Long: flat AND datetime is Monday AND (Prior completed higher-timeframe close > Lookback high OR (Higher-timeframe SMA > Current higher-timeframe open AND Prior completed higher-timeframe close <= Lookback high AND Prior completed higher-timeframe close >= Lookback low))
Short: flat AND datetime is Monday AND (Prior completed higher-timeframe close < Lookback low OR (Higher-timeframe SMA < Current higher-timeframe open AND Prior completed higher-timeframe close <= Lookback high AND Prior completed higher-timeframe close >= Lookback low))
Exit: long, low <= entry price - configured stop-loss distance OR elapsed time since entry > configured holding-time limit
Exit: short, high >= entry price + configured stop-loss distance OR elapsed time since entry > configured holding-time limit