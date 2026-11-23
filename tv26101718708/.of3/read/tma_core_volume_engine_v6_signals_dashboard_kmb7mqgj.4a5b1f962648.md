Calculation: POC = price bin with the largest volume accumulated so far in the session, where each bar's volume is added to the bin nearest the bar's low and bin size = tick size * bin-multiplier parameter
Calculation: VAH = highest price of the session's value area so far, where the value area grows from POC toward the adjacent bin with more volume until it holds value-area-percent parameter of session volume
Calculation: VAL = lowest price of the session's value area so far, where the value area is defined as in VAH
Calculation: Prior POC = POC of the previous session, held through the current session
Calculation: Touch(L) = high >= L - tick size * touch-tick parameter AND low <= L + tick size * touch-tick parameter
Calculation: Touch start(L) = Touch(L) AND NOT Touch(L)[1]
Calculation: Naked = no bar of the current session up to and including this bar has low <= Prior POC <= high
Calculation: Signal(E) = E AND bars since the last bar where Signal(E) was true >= min-spacing parameter
Long: Signal(Touch start(VAL) AND bar in RTH window)
Short: Signal(Touch start(VAH) AND bar in RTH window)
Long: Signal(Touch start(POC) AND bar in RTH window) AND close >= POC
Short: Signal(Touch start(POC) AND bar in RTH window) AND close < POC
Long: Signal(Touch start(Prior POC) AND Naked AND bar in RTH window) AND close >= Prior POC
Short: Signal(Touch start(Prior POC) AND Naked AND bar in RTH window) AND close < Prior POC
Long: close crosses above VAH AND Signal((close crosses above VAH OR close crosses below VAL) AND bar in RTH window)
Short: close crosses below VAL AND Signal((close crosses above VAH OR close crosses below VAL) AND bar in RTH window)