Calculation: volume ratio = SMA(volume, short volume lookback) / max(SMA(volume, long volume lookback), positive floor)
Calculation: armed box high and low = highest high and lowest low of consecutive confirmed chart bars with volume ratio >= expansion threshold; arm on the first subsequent confirmed bar with volume ratio below the threshold and reset after a breakout
Calculation: readiness = chart bar count >= max(long volume lookback, projection range lookback, strength lookback, body averaging lookback)
Calculation: projected basis = EMA(lowest(low, projection range lookback) + SMA(RSI(close, RSI lookback), RSI smoothing lookback) * max(highest(high, projection range lookback) - lowest(low, projection range lookback), positive floor) / 100, projection smoothing lookback)
Calculation: projection tolerance = SMA(abs(close - open), body averaging lookback) * tolerance multiplier
Calculation: upper and lower projection bands = projected basis + projection tolerance and projected basis - projection tolerance
Calculation: projected trend state = initially bearish; on confirmed chart bars, bullish after close > upper projection band, bearish after close < lower projection band, otherwise unchanged
Calculation: entry risk distance = ATR(ATR lookback) on the entry bar * stop multiplier when ATR mode is selected; otherwise entry price * percentage risk parameter * stop multiplier
Long: readiness AND confirmed chart bar AND armed box exists AND close > armed box high AND close[1] <= armed box high
Short: readiness AND confirmed chart bar AND armed box exists AND close < armed box low AND close[1] >= armed box low
Long: projected trend state is bullish
Short: projected trend state is bearish
Long: readiness AND confirmed chart bar AND projected trend state changes from bearish to bullish
Short: readiness AND confirmed chart bar AND projected trend state changes from bullish to bearish
Exit: long, low <= entry price - entry risk distance OR high >= entry price + entry risk distance * third target reward/risk parameter OR bars since entry > trade-line lifetime parameter
Exit: short, high >= entry price + entry risk distance OR low <= entry price - entry risk distance * third target reward/risk parameter OR bars since entry > trade-line lifetime parameter