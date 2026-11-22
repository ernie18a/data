Calculation: SRC = OSC(close, oscillator type, oscillator length, short length, long length) OR BandPercent(close, band type, band MA type, band length, band multiplier)
Calculation: HPR = PercentRank(SRC, historical lookback)
Calculation: HMED = Median(SRC, historical lookback)
Calculation: PMA = MA(HPR, MA type, MA length)
Long: HPR < HMED - buy offset AND HPR crosses above PMA
Exit: long, HPR > HMED + sell offset AND HPR crosses below PMA