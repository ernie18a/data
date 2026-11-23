Long: On chart bars, close(T1, last completed bar) > open(T1, last completed bar) AND hour(datetime) < entry-hour parameter AND account order count < order-limit parameter
Short: On chart bars, close(T1, last completed bar) < open(T1, last completed bar) AND hour(datetime) < entry-hour parameter AND account order count < order-limit parameter
Exit: long, hour(datetime) > close-hour parameter - close-hour offset parameter
Exit: short, hour(datetime) > close-hour parameter - close-hour offset parameter