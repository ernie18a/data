Calculation: Reference range = highest high and lowest low during the reference session
Calculation: Risk distance = max(reference-range width, configured minimum stop distance)
Long: close > reference-range high AND during the post-reference entry window AND no trade has been taken that day
Short: close < reference-range low AND during the post-reference entry window AND no trade has been taken that day
Exit: Long, low <= reference-range high − risk distance OR high >= reference-range high + configured reward multiple × risk distance
Exit: Short, high >= reference-range low + risk distance OR low <= reference-range low − configured reward multiple × risk distance