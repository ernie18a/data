Calculation: EWO = Elliott Wave Oscillator(first applied-price input, shorter lookback, second applied-price input, longer lookback), calculated on T1 bars
Long: EWO(T1, current forming bar) > EWO(T1, last completed bar) AND EWO(T1, last completed bar) < EWO(T1, 2 bars ago)
Short: EWO(T1, current forming bar) < EWO(T1, last completed bar) AND EWO(T1, last completed bar) > EWO(T1, 2 bars ago)
Exit: long, EWO(T1, last completed bar) > EWO(T1, 2 bars ago) AND EWO(T1, current forming bar) >= EWO(T1, last completed bar)
Exit: short, EWO(T1, last completed bar) < EWO(T1, 2 bars ago) AND EWO(T1, current forming bar) <= EWO(T1, last completed bar)