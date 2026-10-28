Calculation: RSI-based moving average = selected moving average type applied to RSI
Long: RSI > 68 AND RSI-based moving average > its previous-bar value AND datetime >= configured backtest start datetime
Short: RSI < 28 AND RSI-based moving average < its previous-bar value AND datetime >= configured backtest start datetime
Exit: long, RSI < 30 AND datetime >= configured backtest start datetime OR current high >= previous-bar high × 1.004 OR current high >= previous-bar high × 1.008 OR current low <= previous-bar low × 0.98
Exit: short, RSI > 60 AND datetime >= configured backtest start datetime OR current low <= previous-bar low × 0.996 OR current low <= previous-bar low × 0.992 OR current high >= previous-bar high × 1.02