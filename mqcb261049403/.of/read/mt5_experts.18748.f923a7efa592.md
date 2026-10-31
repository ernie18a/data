Calculation: Eight-stage EMA = apply an EMA with the same length successively eight times to a selected bar price; initialize each stage with its first available input, starting successive stages one bar apart.
Calculation: Rounded center = round (8 × stage 1 − 28 × stage 2 + 56 × stage 3 − 70 × stage 4 + 56 × stage 5 − 28 × stage 6 + 8 × stage 7 − stage 8) to the nearest configurable price increment.
Calculation: Upper and lower envelope = rounded center × (1 + deviation percentage / 100) and rounded center × (1 − deviation percentage / 100), respectively, plus a configurable vertical price offset. Compare each bar with the envelope calculated a configurable number of bars earlier.
Long: Chart-timeframe close > upper envelope.
Short: Chart-timeframe close < lower envelope.
Long: Chart-timeframe upper envelope > its previous value.
Short: Chart-timeframe upper envelope < its previous value.
Long: On a configurable higher or lower indicator timeframe, the last completed bar's close > its upper envelope AND the preceding bar's close <= its upper envelope.
Short: On a configurable higher or lower indicator timeframe, the last completed bar's close < its lower envelope AND the preceding bar's close >= its lower envelope.
Exit: short, on the indicator timeframe, the last completed bar's close > its upper envelope.
Exit: long, on the indicator timeframe, the last completed bar's close < its lower envelope.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.