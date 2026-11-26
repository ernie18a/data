Calculation: direction(T) = up when JFATL(close, lookback, T, current bar) > JFATL(close, lookback, T, preceding bar), down when lower, otherwise retain the preceding direction; calculate on T bars using the still-forming current bar
Long: direction(T1) = up AND direction(T1)[1] is not up
Short: direction(T2) = down AND direction(T2)[1] is not down
Exit: long, direction(T1) = down AND direction(T1)[1] = down
Exit: short, direction(T2) = up AND direction(T2)[1] = up