Calculation: Momentum = linear regression endpoint(selected source - average(midpoint(highest(high, momentum lookback), lowest(low, momentum lookback)), selected moving average(selected source, momentum lookback)), momentum lookback)
Calculation: Momentum strength = Momentum - SMA(Momentum, signal lookback)
Calculation: XTL value = (selected XTL source - selected moving average(selected XTL source, XTL lookback)) / (CCI scale coefficient × (traditional formula ? mean absolute deviation(abs(selected XTL source - selected moving average(selected XTL source, XTL lookback)), XTL lookback) : mean absolute deviation(selected XTL source, XTL lookback))
Calculation: Hull average = selected HMA, EHMA, THMA, or AHMA of selected source and lookback; THMA uses half the selected lookback
Calculation: Divergence confirmation = delay-until-close disabled OR bar is historical OR bar is confirmed
Calculation: Oscillator low at pivot occurrence = Momentum[right pivot lookback] at the specified confirmed pivotlow(Momentum, left pivot lookback, right pivot lookback) occurrence
Calculation: Oscillator high at pivot occurrence = Momentum[right pivot lookback] at the specified confirmed pivothigh(Momentum, left pivot lookback, right pivot lookback) occurrence
Calculation: Close low at pivot occurrence = lowest(close, right pivot lookback + price-window adjustment) at the specified confirmed pivotlow(Momentum, left pivot lookback, right pivot lookback) occurrence
Calculation: Close high at pivot occurrence = highest(close, right pivot lookback + price-window adjustment) at the specified confirmed pivothigh(Momentum, left pivot lookback, right pivot lookback) occurrence
Calculation: Low-pivot span at occurrence = current bar index - valuewhen(pivotlow(Momentum, left pivot lookback, right pivot lookback), bar index, occurrence)
Calculation: High-pivot span at occurrence = current bar index - valuewhen(pivothigh(Momentum, left pivot lookback, right pivot lookback), bar index, occurrence)
Calculation: Low-pivot bar at occurrence = valuewhen(pivotlow(Momentum, left pivot lookback, right pivot lookback), bar index - right pivot lookback, occurrence)
Calculation: High-pivot bar at occurrence = valuewhen(pivothigh(Momentum, left pivot lookback, right pivot lookback), bar index - right pivot lookback, occurrence)
Calculation: Low two-back trendline value at previous pivot = Oscillator low at two-back pivot + (Oscillator low at current pivot - Oscillator low at two-back pivot) × (Low-pivot bar at previous pivot - Low-pivot bar at two-back pivot) / (Low-pivot bar at current pivot - Low-pivot bar at two-back pivot)
Calculation: High two-back trendline value at previous pivot = Oscillator high at two-back pivot + (Oscillator high at current pivot - Oscillator high at two-back pivot) × (High-pivot bar at previous pivot - High-pivot bar at two-back pivot) / (High-pivot bar at current pivot - High-pivot bar at two-back pivot)
Long: Momentum >= 0
Short: Momentum < 0
Long: Momentum >= SMA(Momentum, signal lookback)
Short: Momentum < SMA(Momentum, signal lookback)
Long: Momentum strength > 0
Short: Momentum strength <= 0
Long: DI+(DI lookback, ADX smoothing) >= DI-(DI lookback, ADX smoothing)
Short: DI+(DI lookback, ADX smoothing) < DI-(DI lookback, ADX smoothing)
Long: DI+ at label-history offset >= DI- at label-history offset AND ADX at label-history offset > weak-trend threshold
Short: DI+ at label-history offset < DI- at label-history offset AND ADX at label-history offset > weak-trend threshold
Long: DI+ >= DI- AND ADX >= ADX trend threshold AND (DI+ one bar ago < DI- one bar ago OR ADX one bar ago < ADX trend threshold)
Short: DI+ < DI- AND ADX >= ADX trend threshold AND (DI+ one bar ago >= DI- one bar ago OR ADX one bar ago < ADX trend threshold)
Long: Hull average crosses above its value at the Hull comparison lag
Short: Hull average crosses below its value at the Hull comparison lag
Long: Hull average > its value at the Hull comparison lag
Short: Hull average < its value at the Hull comparison lag
Long: XTL value > XTL threshold
Short: XTL value < -XTL threshold
Long: confirmed pivotlow(Momentum, left pivot lookback, right pivot lookback) AND Divergence confirmation AND Momentum < 0 AND ((lowest(close, right pivot lookback + price-window adjustment) < Close low at previous pivot AND Oscillator low at current pivot > Oscillator low at previous pivot AND divergence minimum <= Low-pivot span at previous pivot <= divergence maximum) OR (two-back comparison enabled AND lowest(close, right pivot lookback + price-window adjustment) < Close low at two-back pivot AND Oscillator low at current pivot > Oscillator low at two-back pivot AND divergence minimum <= Low-pivot span at two-back pivot <= divergence maximum AND Oscillator low at previous pivot > Low two-back trendline value at previous pivot))
Long: confirmed pivotlow(Momentum, left pivot lookback, right pivot lookback) AND Divergence confirmation AND Momentum < 0 AND ((lowest(close, right pivot lookback + price-window adjustment) > Close low at previous pivot AND Oscillator low at current pivot < Oscillator low at previous pivot AND divergence minimum <= Low-pivot span at previous pivot <= divergence maximum) OR (two-back comparison enabled AND lowest(close, right pivot lookback + price-window adjustment) > Close low at two-back pivot AND Oscillator low at current pivot < Oscillator low at two-back pivot AND divergence minimum <= Low-pivot span at two-back pivot <= divergence maximum AND Oscillator low at previous pivot > Low two-back trendline value at previous pivot))
Short: confirmed pivothigh(Momentum, left pivot lookback, right pivot lookback) AND Divergence confirmation AND Momentum > 0 AND ((highest(close, right pivot lookback + price-window adjustment) > Close high at previous pivot AND Oscillator high at current pivot < Oscillator high at previous pivot AND divergence minimum <= High-pivot span at previous pivot <= divergence maximum) OR (two-back comparison enabled AND highest(close, right pivot lookback + price-window adjustment) > Close high at two-back pivot AND Oscillator high at current pivot < Oscillator high at two-back pivot AND divergence minimum <= High-pivot span at two-back pivot <= divergence maximum AND Oscillator high at previous pivot < High two-back trendline value at previous pivot))
Short: confirmed pivothigh(Momentum, left pivot lookback, right pivot lookback) AND Divergence confirmation AND Momentum > 0 AND ((highest(close, right pivot lookback + price-window adjustment) < Close high at previous pivot AND Oscillator high at current pivot > Oscillator high at previous pivot AND divergence minimum <= High-pivot span at previous pivot <= divergence maximum) OR (two-back comparison enabled AND highest(close, right pivot lookback + price-window adjustment) < Close high at two-back pivot AND Oscillator high at current pivot > Oscillator high at two-back pivot AND divergence minimum <= High-pivot span at two-back pivot <= divergence maximum AND Oscillator high at previous pivot < High two-back trendline value at previous pivot))