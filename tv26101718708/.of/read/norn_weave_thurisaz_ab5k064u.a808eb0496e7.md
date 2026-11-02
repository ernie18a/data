Calculation: Chart swing high/low = the high/low at the center of a symmetric lookback window when it equals the highest high/lowest low in that window; retain the latest confirmed value of each.
Calculation: Chart trend = initially neutral; set to long when close exceeds the latest chart swing high, and set to short when close falls below the latest chart swing low; otherwise retain its previous value. Apply the short update last if both occur.
Calculation: Higher-timeframe swings and trend = use confirmed pivot highs and lows with an independent symmetric lookback, and the close of the last completed higher-timeframe bar; retain the latest pivots and update the trend using the same breakout and precedence rules as the chart trend.
Calculation: Higher-timeframe long retracement levels = latest higher-timeframe swing low plus the swing range multiplied by a smaller and a larger retracement ratio; short retracement levels = latest higher-timeframe swing high minus the range multiplied by those ratios. Swing range = latest higher-timeframe swing high minus latest higher-timeframe swing low.
Calculation: Volatility percentage = ATR divided by close, multiplied by the percentage scale.
Calculation: Automatic ADX threshold = the rolling nearest-rank median of ADX, or a fallback threshold before it is available.
Calculation: Automatic ATR factor = a base factor plus an adjustment coefficient times the clipped difference between one and volatility percentage divided by its longer SMA; use a ratio of one until that SMA is positive and available.
Calculation: Automatic stop-loss percentage = the negative of a coefficient times a shorter SMA of volatility percentage, bounded between configured negative limits; use a fallback until the SMA is available.
Calculation: Profit percentage = percentage change from entry price to close for a long, or from close to entry price for a short.
Calculation: Profit targets = at the entry signal bar, store its close plus or minus ATR times the selected ATR factor times each of three increasing target multipliers. For the first long target, substitute the smaller higher-timeframe long retracement level if the higher-timeframe trend is short and the signal close is below that level; for the first short target, substitute the smaller higher-timeframe short retracement level if the higher-timeframe trend is long and the signal close is above that level. Each target is available only until its first hit in the position.
Long: EMA of close > its previous value.
Short: EMA of close <= its previous value.
Long: Chart trend = long.
Short: Chart trend = short.
Long: Higher-timeframe trend = long.
Short: Higher-timeframe trend = short.
Long: Position is flat AND EMA of close > its previous value AND chart trend = long AND ADX > selected manual or automatic ADX threshold AND (higher-timeframe trend is long or neutral OR higher-timeframe retracement levels are unavailable OR close is outside the inclusive interval between the higher-timeframe long retracement levels).
Short: Position is flat AND EMA of close < its previous value AND chart trend = short AND ADX > selected manual or automatic ADX threshold AND (higher-timeframe trend is short or neutral OR higher-timeframe retracement levels are unavailable OR close is outside the inclusive interval between the higher-timeframe short retracement levels).
Exit: long, profit percentage < selected manual or automatic stop-loss percentage OR chart trend = short.
Exit: short, profit percentage < selected manual or automatic stop-loss percentage OR chart trend = long.
Exit: long, break-even stop enabled AND profit percentage has reached its activation threshold during the current position AND low <= entry price.
Exit: short, break-even stop enabled AND profit percentage has reached its activation threshold during the current position AND high >= entry price.
Exit: long, high > an available long profit target; close the configured fraction of the remaining position for each target hit.
Exit: short, low < an available short profit target; close the configured fraction of the remaining position for each target hit.