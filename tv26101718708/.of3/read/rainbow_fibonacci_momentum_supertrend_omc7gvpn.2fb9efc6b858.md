Calculation: rising(L) = MA(close, L, type) > MA(close, L, type)[1], where L1 < L2 < L3 < L4 < L5 < L6
Calculation: falling(L) = MA(close, L, type) < MA(close, L, type)[1]
Calculation: all_rising = rising(L1) AND rising(L2) AND rising(L3) AND rising(L4) AND rising(L5) AND rising(L6)
Calculation: all_falling = falling(L1) AND falling(L2) AND falling(L3) AND falling(L4) AND falling(L5) AND falling(L6)
Calculation: up_onset = all_rising AND NOT all_rising[1]
Calculation: down_onset = all_falling AND NOT all_falling[1]
Calculation: bull_area = all_rising AND MA(close, L1, type) > MA(close, L2, type) > MA(close, L3, type) > MA(close, L4, type) > MA(close, L5, type) > MA(close, L6, type)
Calculation: bear_area = all_falling AND MA(close, L1, type) < MA(close, L2, type) < MA(close, L3, type) < MA(close, L4, type) < MA(close, L5, type) < MA(close, L6, type)
Calculation: mega_up = bull_area AND up_onset
Calculation: mega_down = bear_area AND down_onset
Long: bull_area
Long: all_rising
Long: rising(L1) AND falling(L2) AND falling(L3) AND falling(L4) AND falling(L5) AND falling(L6)
Long: rising(L1) AND rising(L2) AND falling(L3) AND falling(L4) AND falling(L5) AND falling(L6)
Long: rising(L1) AND rising(L2) AND rising(L3) AND falling(L4) AND falling(L5) AND falling(L6)
Long: rising(L1) AND rising(L2) AND rising(L3) AND rising(L4) AND falling(L5) AND falling(L6)
Long: rising(L1) AND rising(L2) AND rising(L3) AND rising(L4) AND rising(L5) AND falling(L6)
Long: up_onset AND NOT mega_up
Long: mega_up
Long: up_onset
Short: bear_area
Short: all_falling
Short: falling(L1) AND rising(L2) AND rising(L3) AND rising(L4) AND rising(L5) AND rising(L6)
Short: falling(L1) AND falling(L2) AND rising(L3) AND rising(L4) AND rising(L5) AND rising(L6)
Short: falling(L1) AND falling(L2) AND falling(L3) AND rising(L4) AND rising(L5) AND rising(L6)
Short: falling(L1) AND falling(L2) AND falling(L3) AND falling(L4) AND rising(L5) AND rising(L6)
Short: falling(L1) AND falling(L2) AND falling(L3) AND falling(L4) AND falling(L5) AND rising(L6)
Short: down_onset AND NOT mega_down
Short: mega_down
Short: down_onset