Calculation: AO trigger price(deviation) = base entry price * (1 - deviation / 100)
Long: position side is flat AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND RSI(close, RSI length, T1, last completed bar) < RSI threshold
Long: position side is long AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND close <= AO trigger price(AO 1 deviation)
Long: position side is long AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND close <= AO trigger price(AO 2 deviation, deeper than AO 1 deviation)
Long: position side is long AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND close <= AO trigger price(AO 3 deviation, deeper than AO 2 deviation)
Long: position side is long AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND close <= AO trigger price(AO 4 deviation, deeper than AO 3 deviation)
Long: position side is long AND (date filter disabled OR (datetime >= start datetime AND datetime <= end datetime)) AND close <= AO trigger price(AO 5 deviation, deeper than AO 4 deviation)
Exit: long, close >= average entry price * (1 + take-profit / 100)