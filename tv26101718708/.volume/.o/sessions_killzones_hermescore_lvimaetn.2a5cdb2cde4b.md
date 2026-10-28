Calculation: Session high/low = highest high and lowest low of each configured session, finalized when that session closes; keep each level active until the next session of the same type closes.
Calculation: ATR break buffer = ATR multiplied by a configurable buffer parameter.
Short: An active session high has not been swept, high > level, and close <= level + ATR break buffer, evaluated on a completed bar.
Long: An active session low has not been swept, low < level, and close >= level - ATR break buffer, evaluated on a completed bar.