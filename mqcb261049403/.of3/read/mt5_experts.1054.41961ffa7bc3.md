Calculation: Daily pivot levels = Classic Pivot Points(high, low, close, T1, last completed bar)
Long: close[1] >= configured entry support AND open[2] > configured entry support AND (low[2] < configured entry support OR close[2] <= configured entry support) AND NOT ((high[2] > configured entry resistance OR close[2] >= configured entry resistance) AND open[2] < configured entry resistance AND close[1] <= configured entry resistance)
Short: close[1] <= configured entry resistance AND open[2] < configured entry resistance AND (high[2] > configured entry resistance OR close[2] >= configured entry resistance) AND NOT ((low[2] < configured entry support OR close[2] <= configured entry support) AND open[2] > configured entry support AND close[1] >= configured entry support)
Exit: long, low <= configured stop-loss support OR high >= configured take-profit resistance
Exit: short, high >= configured stop-loss resistance OR low <= configured take-profit support
Exit: long, intraday-only mode is enabled AND hour(datetime) equals the intraday closing hour
Exit: short, intraday-only mode is enabled AND hour(datetime) equals the intraday closing hour
Exit: long, stop-modification mode is enabled AND highest high since entry reaches the nearest pivot level above entry AND low <= entry price + spread
Exit: short, stop-modification mode is enabled AND lowest low since entry reaches the nearest pivot level below entry AND high >= entry price - spread