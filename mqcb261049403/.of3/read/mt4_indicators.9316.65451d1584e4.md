Long: For each T1–T9, the offset indicator’s trend output, using separate lookback and offset parameters on chart bars with the Tn bar still forming, is greater than zero
Short: For each T1–T9, the offset indicator’s trend output, using separate lookback and offset parameters on chart bars with the Tn bar still forming, is less than zero
Long: For each T1–T9, the sum of the offset indicator’s trend output and its second output for the price-versus-average-plus-offset method, using separate lookback and offset parameters on chart bars with the Tn bar still forming, is greater than zero
Short: For each T1–T9, the sum of the offset indicator’s trend output and its second output for the price-versus-average-plus-offset method, using separate lookback and offset parameters on chart bars with the Tn bar still forming, is less than zero
Calculation: MA trend score(Tn) = 1 when SMA(close, shortest lookback, Tn, forming bar) > SMA(close, intermediate lookback, Tn, forming bar) AND SMA(close, shortest lookback, Tn, forming bar) > SMA(close, longest lookback, Tn, forming bar); −1 when both comparisons are <; otherwise 0; shortest lookback < intermediate lookback < longest lookback
Long: For each T1–T9, MA trend score(Tn) > 0
Short: For each T1–T9, MA trend score(Tn) < 0
Calculation: MACD direction score(Tn) = 1 when MACD main line(close, fast lookback, slow lookback, signal lookback, Tn, forming bar) > its value on the previous Tn bar; −1 when <; otherwise 0; fast lookback = signal lookback < slow lookback
Long: For each T1–T9, MACD direction score(Tn) > 0
Short: For each T1–T9, MACD direction score(Tn) < 0
Calculation: All-period score = sum over T1–T9 of the offset indicator’s trend output + the sum of its trend output and its second output for the price-versus-average-plus-offset method + MA trend score(Tn) + MACD direction score(Tn)
Long: All-period score > 0
Short: All-period score < 0