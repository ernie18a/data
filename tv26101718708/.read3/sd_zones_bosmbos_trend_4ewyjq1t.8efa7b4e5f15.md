Long: close > EMA(close, longest lookback) AND EMA(close, shorter lookback) > EMA(close, intermediate lookback), with shorter < intermediate < longest lookbacks
Short: close < EMA(close, longest lookback) AND EMA(close, shorter lookback) < EMA(close, intermediate lookback), with shorter < intermediate < longest lookbacks
Long: chart-bar close crosses above the most recent confirmed chart-bar pivot high of high, using equal left and right swing lookbacks
Short: chart-bar close crosses below the most recent confirmed chart-bar pivot low of low, using equal left and right swing lookbacks
Long: chart-bar high > the most recent confirmed chart-bar pivot high of high AND chart-bar close <= that pivot high, using equal left and right swing lookbacks
Short: chart-bar low < the most recent confirmed chart-bar pivot low of low AND chart-bar close >= that pivot low, using equal left and right swing lookbacks
Long: on chart bars, chart-bar close crosses above the latest pivot high calculated from T1 high using equal left and right swing lookbacks, with T1 values from the last completed T1 bar
Short: on chart bars, chart-bar close crosses below the latest pivot low calculated from T1 low using equal left and right swing lookbacks, with T1 values from the last completed T1 bar