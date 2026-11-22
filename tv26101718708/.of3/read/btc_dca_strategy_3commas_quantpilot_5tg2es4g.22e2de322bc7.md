Calculation: WithinBacktestWindow = NOT backtest window enabled OR (datetime >= backtest window start AND datetime <= backtest window end)
Long: RSI(close, RSI length, T1, last completed bar) < RSI threshold AND position side is flat AND WithinBacktestWindow is true
Long: position side is long AND close <= entry price * (1 - averaging deviation 1 / 100) AND WithinBacktestWindow is true
Long: position side is long AND close <= entry price * (1 - averaging deviation 2 / 100) AND WithinBacktestWindow is true
Long: position side is long AND close <= entry price * (1 - averaging deviation 3 / 100) AND WithinBacktestWindow is true
Long: position side is long AND close <= entry price * (1 - averaging deviation 4 / 100) AND WithinBacktestWindow is true
Long: position side is long AND close <= entry price * (1 - averaging deviation 5 / 100) AND WithinBacktestWindow is true
Exit: long, close >= average entry price * (1 + take profit percent / 100)