Calculation: MACD line = short-length moving average of the selected price source minus long-length moving average of the same source, using the same selected moving-average type.
Calculation: Signal line = moving average of the MACD line using the same selected moving-average type and a separate signal length.
Calculation: Risk distance = ATR at entry multiplied by a positive stop multiplier; retain this distance for the trade.
Long: MACD line > signal line OR MACD line > 0, according to the selected reference; when equal to the reference, retain the last non-equal direction.
Short: MACD line < signal line OR MACD line < 0, according to the selected reference; when equal to the reference, retain the last non-equal direction.
Long: On a closed bar, MACD line crosses above signal line AND short moving-average length < long moving-average length AND risk distance > 0 AND close - risk distance > 0 AND position side is not long; enter at close.
Short: On a closed bar, MACD line crosses below signal line AND short moving-average length < long moving-average length AND risk distance > 0 AND close - risk distance × largest target multiplier > 0 AND position side is not short; enter at close.
Exit: long, on a bar after entry, high >= entry price + risk distance × a target multiplier; the two smaller target multipliers each trigger one partial exit and the largest triggers a full exit.
Exit: short, on a bar after entry, low <= entry price - risk distance × a target multiplier; the two smaller target multipliers each trigger one partial exit and the largest triggers a full exit.
Exit: long, on a closed bar after entry, close < entry price - risk distance OR MACD line crosses below signal line AND short moving-average length < long moving-average length AND ATR is available.
Exit: short, on a closed bar after entry, close > entry price + risk distance OR MACD line crosses above signal line AND short moving-average length < long moving-average length AND ATR is available.