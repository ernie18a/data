Calculation: Latest pivot high/low = highest high/lowest low with the configured number of chart bars before and after the pivot bar; become available after the bars after it complete.
Calculation: Resistance/support band = latest pivot high/low ± configured percentage tolerance.
Calculation: Near resistance/support = current high/low is within the corresponding band.
Calculation: Bullish/bearish pin bar = lower/upper wick is at least the configured multiple of the body and twice the opposite wick; body and range are positive.
Calculation: Bullish/bearish engulfing = current candle is bullish/bearish, previous candle is bearish/bullish, current close exceeds/falls below previous open, current open is below/above previous close, and current body is at least the configured fraction of previous body.
Calculation: Volume delta = sum of volume on up or unchanged candles minus sum of volume on down candles over the configured lookback.
Calculation: Candle body percentage = absolute close-open divided by high-low, times 100 (zero when range is zero).
Calculation: Long stop = latest pivot low adjusted down by the configured buffer if below entry; otherwise entry minus ATR times the stop multiple.
Calculation: Short stop = latest pivot high adjusted up by the configured buffer if above entry; otherwise entry plus ATR times the stop multiple.
Calculation: Long TP1 = latest pivot high if above entry; otherwise entry plus ATR times the first target multiple.
Calculation: Short TP1 = latest pivot low if below entry; otherwise entry minus ATR times the first target multiple.
Calculation: Long TP2 = latest earlier pivot high if above TP1; otherwise entry plus ATR times the second target multiple; if this result is not above TP1, use the ATR target.
Calculation: Short TP2 = latest earlier pivot low if below TP1; otherwise entry minus ATR times the second target multiple; if this result is not below TP1, use the ATR target.
Long: (bullish pin bar AND near support OR bullish engulfing AND near support OR close crosses above resistance band) AND fast EMA > slow EMA AND absolute fast/slow EMA distance as a percentage of slow EMA meets the configured minimum AND close > fast EMA AND close > VWAP AND volume > configured multiple of volume SMA AND volume delta > 0 AND body >= configured multiple of ATR AND candle body percentage >= configured minimum AND volume > configured spike multiple of volume SMA
Short: (bearish pin bar AND near resistance OR bearish engulfing AND near resistance OR close crosses below support band) AND fast EMA < slow EMA AND absolute fast/slow EMA distance as a percentage of slow EMA meets the configured minimum AND close < fast EMA AND close <= VWAP AND volume > configured multiple of volume SMA AND volume delta < 0 AND body >= configured multiple of ATR AND candle body percentage >= configured minimum AND volume > configured spike multiple of volume SMA
Exit: long, low <= long stop OR high >= long TP1 OR high >= long TP2
Exit: short, high >= short stop OR low <= short TP1 OR low <= short TP2