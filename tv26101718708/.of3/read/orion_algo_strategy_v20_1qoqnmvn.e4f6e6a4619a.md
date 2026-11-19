Calculation: RSI deviation component = RSI(close − SMA(close, deviation SMA lookback), RSI lookback) × RSI multiplier − RSI offset
Calculation: Directional RSI component = RSI(fixnan(100 × RMA(change(high) > change(low) AND change(high) > 0 ? change(high) : 0, one-bar RMA length) / RMA(true range, one-bar RMA length)) − fixnan(100 × RMA(change(low) > change(high) AND change(low) > 0 ? change(low) : 0, one-bar RMA length) / RMA(true range, one-bar RMA length)), RSI lookback) × RSI multiplier − RSI offset
Calculation: Volume RSI component = RSI(100 × (close − ((SUM(volume, volume lookback) − volume) / SUM(volume, volume lookback)) + (volume × close / SUM(volume, volume lookback))) / ((close + ((SUM(volume, volume lookback) − volume) / SUM(volume, volume lookback)) + (volume × close / SUM(volume, volume lookback))) / 2), RSI lookback) − RSI offset
Calculation: Range RSI component = RSI(SMA((close − lowest(low, range lookback)) / highest(high, range lookback) − lowest(low, range lookback) − range offset, range smoothing lookback), RSI lookback) × RSI multiplier − RSI offset
Calculation: Composite oscillator = HMA(arithmetic mean of seven terms, composite smoothing lookback), where each term is its component when its separate enable input is on and zero otherwise; the terms are MACD histogram(close, fast EMA lookback, slow EMA lookback, MACD signal lookback) / MACD divisor, Williams %R(high, low, close, Williams %R lookback), Bollinger %B(close, Bollinger lookback, band deviation), RSI deviation component, Directional RSI component, Volume RSI component, and Range RSI component; multiply the mean by oscillator scale before applying HMA
Calculation: Signal velocity = velocity scale × change(Composite oscillator)
Calculation: Prediction curve = Signal velocity + prediction bias × (Composite oscillator − Signal velocity)
Long: Composite oscillator > Composite oscillator[1] AND Composite oscillator[1] < Composite oscillator[2]
Short: Composite oscillator < Composite oscillator[1] AND Composite oscillator[1] > Composite oscillator[2]
Long: Prediction curve > Prediction curve[1] AND Prediction curve[1] < Prediction curve[2]
Short: Prediction curve < Prediction curve[1] AND Prediction curve[1] > Prediction curve[2]
Long: Signal velocity crosses above its zero line
Short: Signal velocity crosses below its zero line
Long: Simple mode AND Composite oscillator crosses above Composite oscillator[1]
Short: Simple mode AND Composite oscillator crosses below Composite oscillator[1]
Long: DCA long mode AND Composite oscillator crosses above Composite oscillator[1] AND (flat OR (long position AND close ≤ most recent long entry price × (1 − entry drop parameter) AND current long entry count ≤ pyramid limit parameter))
Exit: long, DCA long mode AND close ≥ mean close of current trade's long entries × (1 + profit target parameter) AND Composite oscillator ≤ Composite oscillator[1] AND Composite oscillator[1] ≥ Composite oscillator[2]