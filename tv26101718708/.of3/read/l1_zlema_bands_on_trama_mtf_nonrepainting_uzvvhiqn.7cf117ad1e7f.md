Calculation: Lower band = EMA(TRAMA(close, trama length), zlema length) - band multiplier * STDEV(TRAMA(close, trama length), zlema length), calculated on T1 and sampled from its last completed bar
Calculation: Upper band = EMA(TRAMA(close, trama length), zlema length) + band multiplier * STDEV(TRAMA(close, trama length), zlema length), calculated on T1 and sampled from its last completed bar
Long: On chart bars, price source crosses below the lower band
Short: On chart bars, price source crosses above the upper band