Short: high[1] > high[2] AND low[1] < low[2] AND low < low[1] AND high <= high[1]
Long: high[1] > high[2] AND low[1] < low[2] AND high > high[1] AND low >= low[1]
Short: high[2] < high[3] AND low[2] > low[3] AND high[1] > high[2] AND low[1] >= low[2] AND low < low[1] AND high <= high[1]
Long: high[2] < high[3] AND low[2] > low[3] AND low[1] < low[2] AND high[1] <= high[2] AND high > high[1] AND low >= low[1]
Short: high[1] > high[2] AND low[1] >= low[2] AND low < low[1] AND high <= high[1]
Long: low[1] < low[2] AND high[1] <= high[2] AND high > high[1] AND low >= low[1]
Short: high > high[1] AND low < low[1] AND close < low[1]
Long: high > high[1] AND low < low[1] AND close > high[1]
Long: On chart bars using the current, still-forming bars from distinct timeframes T1 through T8, ordered from shorter to longer: open(T1) <= close(T1) OR open(T2) <= close(T2) OR open(T3) <= close(T3) OR open(T4) <= close(T4) OR open(T5) <= close(T5) OR open(T6) <= close(T6) OR open(T7) <= close(T7) OR open(T8) <= close(T8)
Short: On chart bars using the current, still-forming bars from distinct timeframes T1 through T8, ordered from shorter to longer: open(T1) > close(T1) OR open(T2) > close(T2) OR open(T3) > close(T3) OR open(T4) > close(T4) OR open(T5) > close(T5) OR open(T6) > close(T6) OR open(T7) > close(T7) OR open(T8) > close(T8)
Long: On chart bars using the current, still-forming bars from T2, T3, and T4, ordered from shorter to longer: open(T2) <= close(T2) AND open(T3) <= close(T3) AND open(T4) <= close(T4) AND NOT (open(T2)[1] <= close(T2)[1] AND open(T3)[1] <= close(T3)[1] AND open(T4)[1] <= close(T4)[1])
Short: On chart bars using the current, still-forming bars from T2, T3, and T4, ordered from shorter to longer: open(T2) > close(T2) AND open(T3) > close(T3) AND open(T4) > close(T4) AND NOT (open(T2)[1] > close(T2)[1] AND open(T3)[1] > close(T3)[1] AND open(T4)[1] > close(T4)[1])