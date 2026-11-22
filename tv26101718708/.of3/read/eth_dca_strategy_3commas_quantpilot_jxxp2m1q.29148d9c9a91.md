Long: position side is flat AND RSI(close, RSI length, T1, last completed bar) < RSI threshold AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled averaging orders = 0 AND close <= base entry price * (1 - averaging order 1 deviation / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled averaging orders = 1 AND close <= base entry price * (1 - averaging order 2 deviation / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled averaging orders = 2 AND close <= base entry price * (1 - averaging order 3 deviation / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled averaging orders = 3 AND close <= base entry price * (1 - averaging order 4 deviation / 100) AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled averaging orders = 4 AND close <= base entry price * (1 - averaging order 5 deviation / 100) AND datetime >= window start AND datetime <= window end
Exit: long, close >= average entry price * (1 + take-profit / 100)