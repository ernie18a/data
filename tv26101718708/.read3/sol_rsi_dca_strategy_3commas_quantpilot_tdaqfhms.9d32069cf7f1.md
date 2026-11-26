Calculation: filled count = number of averaging-order entries since the last base entry
Long: RSI(close, RSI length, T1, last completed bar) < RSI threshold AND position side is flat AND datetime >= window start AND datetime <= window end
Long: position side is long AND filled count = 0 AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - first averaging deviation / 100)
Long: position side is long AND filled count = 1 AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - second averaging deviation / 100)
Long: position side is long AND filled count = 2 AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - third averaging deviation / 100)
Long: position side is long AND filled count = 3 AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - fourth averaging deviation / 100)
Long: position side is long AND filled count = 4 AND datetime >= window start AND datetime <= window end AND close <= entry price * (1 - fifth averaging deviation / 100)
Exit: long, close >= average entry price * (1 + take-profit percent / 100)