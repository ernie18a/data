Calculation: Volume spike = current volume > prior-bar volume AND current volume > its short-term moving average
Calculation: Strong volume spike = current volume > its longer-term moving average multiplied by a configurable factor greater than one
Calculation: Full-body candle = absolute open-close distance >= a configured fraction of high-low range
Calculation: Bullish candle confirmation = upward full-body candle OR lower wick > half the range OR (lower wick > a configured fraction of range AND upper wick < a smaller configured fraction)
Calculation: Bearish candle confirmation = downward full-body candle OR upper wick > half the range OR (upper wick > a configured fraction of range AND lower wick < a smaller configured fraction)
Calculation: Bullish SFP = price sweeps below the latest confirmed swing low and closes back above it; the pattern remains valid until invalidated, then confirms within its validity window when close exceeds the pattern high and closes sufficiently above the prior bar's high
Calculation: Bearish SFP = price sweeps above the latest confirmed swing high and closes back below it; the pattern remains valid until invalidated, then confirms within its validity window when close falls below the pattern low and closes sufficiently below the prior bar's low
Calculation: Long nullification = no active bearish SFP and upper wick does not exceed its configured fraction of the range
Calculation: Short nullification = no active bullish SFP and lower wick does not exceed its configured fraction of the range
Calculation: Long trailing stop = selected mode: LinReg projection minus long ATR distance; LinReg projection minus long volume-weighted ATR distance scaled by the short-side efficiency ratio, ratcheted upward; highest high minus long volume-weighted ATR distance, ratcheted upward with a tighter initial distance; or LinReg projection minus long volume-weighted ATR distance without ratcheting. Plain ATR is the moving average of true range; volume-weighted ATR is the moving average of true range weighted by volume relative to its moving average.
Calculation: Short trailing stop = selected mode: LinReg projection plus short ATR distance; LinReg projection plus short volume-weighted ATR distance scaled by the short-side efficiency ratio, ratcheted downward; lowest low plus short volume-weighted ATR distance, ratcheted downward with a tighter initial distance; or LinReg projection plus short volume-weighted ATR distance without ratcheting. Plain ATR is the moving average of true range; volume-weighted ATR is the moving average of true range weighted by volume relative to its moving average.
Long: (selected EMA pair crosses upward OR longer-term EMA pair crosses upward) AND volume spike AND close > latest confirmed swing high AND long nullification
Short: selected EMA pair crosses downward AND volume spike AND bearish SFP nullification AND a short volatility breakout occurred within its recent validity window
Long: close > recent high extreme AND close > prior close AND fast EMA >= slower EMA AND bullish candle confirmation AND strong volume spike AND long nullification
Short: recent low extreme breakout with close < prior close AND prior turtle regime was long AND bearish candle confirmation AND bearish SFP nullification AND (short volatility breakout with strong volume spike occurred within its recent validity window)
Long: (confirmed bullish SFP with longer right-side pivot lookback AND full-body candle OR confirmed bullish SFP with shorter right-side pivot lookback AND bullish candle confirmation AND strong volume spike) AND long nullification
Short: (confirmed bearish SFP with longer right-side pivot lookback AND full-body candle OR confirmed bearish SFP with shorter right-side pivot lookback AND bearish candle confirmation) AND short nullification
Long: high > prior multi-bar high extreme AND full-body candle AND within the configured post-entry window AND long nullification
Short: close < prior multi-bar low extreme AND full-body candle AND within the configured post-entry window AND short nullification
Long: bullish Turtle lost-trade marker condition
Short: bearish Turtle lost-trade marker condition
Short: confirmed bearish SFP marker condition for either configured pivot lookback
Exit: long, (close crosses below long trailing stop OR prior bar crossed below long trailing stop and current close remains below it) AND minimum bars since entry
Exit: long, open profit percentage <= configured smart-stop loss threshold AND (close crosses below long trailing stop after minimum bars since entry OR close < low of entry bar), with exactly one open position
Exit: short, (close crosses above short trailing stop OR prior bar crossed above short trailing stop and current close remains above it) AND minimum bars since entry
Exit: short, open profit percentage <= configured smart-stop loss threshold AND (close crosses above short trailing stop after minimum bars since entry OR close > high of entry bar)
Exit: long or short, open profit percentage < configured failsafe loss threshold