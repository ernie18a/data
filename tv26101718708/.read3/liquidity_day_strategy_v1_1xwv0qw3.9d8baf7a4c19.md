Long: On chart bars, close crosses above high[1] from T1's last completed bar
Short: On chart bars, close crosses below low[1] from T1's last completed bar
Exit: long, (take-profit enabled AND high >= entry price * (1 + take-profit parameter / 100)) OR (stop-loss enabled AND low <= entry price * (1 - stop-loss parameter / 100))
Exit: short, (take-profit enabled AND low <= entry price * (1 - take-profit parameter / 100)) OR (stop-loss enabled AND high >= entry price * (1 + stop-loss parameter / 100))