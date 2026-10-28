Calculation: short, medium, and long moving averages = the same selected MA type (SMA, EMA, WMA, VWMA, HMA, SMMA, or DEMA) of their respective price sources, with lookbacks ordered short < medium < long
Long: short MA crosses above medium MA AND medium MA > long MA
Short: short MA crosses below medium MA AND medium MA < long MA
Exit: long, take-profit percentage > 0 AND close >= entry price × (1 + take-profit percentage / 100) OR stop-loss percentage > 0 AND close <= entry price × (1 − stop-loss percentage / 100)
Exit: short, take-profit percentage > 0 AND close <= entry price × (1 − take-profit percentage / 100) OR stop-loss percentage > 0 AND close >= entry price × (1 + stop-loss percentage / 100)