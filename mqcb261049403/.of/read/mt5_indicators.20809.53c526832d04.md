Calculation: JMA(x, n) = Jurik moving average of series x with length n (fixed phase)
Calculation: UpCount = over a ladder of many lengths n spaced at equal steps from short to long, the number of lengths for which JMA(close, n) on the current bar > JMA(close, n) on the previous bar
Calculation: DnCount = the number of ladder lengths n for which JMA(close, n) on the current bar <= JMA(close, n) on the previous bar (UpCount + DnCount = number of ladder lengths)
Calculation: Up = JMA(UpCount, smoothing length); Dn = JMA(DnCount, smoothing length)
Long: Up > Dn
Short: Up <= Dn