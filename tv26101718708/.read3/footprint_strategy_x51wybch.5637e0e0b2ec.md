Calculation: Footprint buy volume = buy-side volume summed across the T1 bars within the current chart bar, including any T1 bar still forming.
Calculation: Footprint sell volume = sell-side volume summed across the T1 bars within the current chart bar, including any T1 bar still forming.
Calculation: Buy-imbalance row count = number of current chart-bar footprint rows classified as buy imbalances using the imbalance-percent parameter.
Calculation: Sell-imbalance row count = number of current chart-bar footprint rows classified as sell imbalances using the imbalance-percent parameter.
Calculation: Reversal reference price = highest price among buy-imbalance rows in the signal chart bar's footprint.
Calculation: Buy-imbalance line count = number of buy-imbalance lines in the current chart bar's footprint, formed using the imbalance-percent and stacked-level parameters.
Calculation: Trend reference price = highest price among buy-imbalance line prices in the signal chart bar's footprint.
Calculation: Eligible chart bar = current and preceding chart bars have T1 data arrays available, and the current chart bar is within the selected history range.
Long: Eligible chart bar AND buy-imbalance row count > sell-imbalance row count AND close < open AND (trend filter disabled OR current T2 close > previous T2 close, evaluated on T2 bars and mapped to chart bars using the T2 bar still forming).
Long: Eligible chart bar AND footprint buy volume > footprint sell volume AND buy-imbalance line count > 0.
Exit: long, high >= signal bar's reversal reference price × (1 + take-profit parameter) OR (stop-loss enabled AND low <= signal bar's reversal reference price × (1 − stop-loss parameter)).
Exit: long, high >= entry price + (signal bar's trend reference price × (1 + take-profit parameter)) ticks OR (stop-loss enabled AND low <= entry price − (signal bar's trend reference price × (1 − stop-loss parameter)) ticks).