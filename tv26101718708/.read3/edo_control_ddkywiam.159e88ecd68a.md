Calculation: candle_state = 10 if WPR(WPR_LEN) crosses below MID; else 11 if WPR(WPR_LEN) crosses above MID; else 0 if WPR(WPR_LEN) < MID AND WPR(WPR_LEN) > WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 1 if WPR(WPR_LEN) > MID AND WPR(WPR_LEN) < HI AND WPR(WPR_LEN) > WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 2 if WPR(WPR_LEN) > HI AND WPR(WPR_LEN) > WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 3 if WPR(WPR_LEN) > MID AND WPR(WPR_LEN) < WPR(WPR_LEN)[1] AND ADX(ADX_LEN) <= ADX(ADX_LEN)[1]; else 4 if WPR(WPR_LEN) < MID AND WPR(WPR_LEN) < WPR(WPR_LEN)[1] AND ADX(ADX_LEN) <= ADX(ADX_LEN)[1]; else 5 if WPR(WPR_LEN) > MID AND WPR(WPR_LEN) < WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 6 if WPR(WPR_LEN) > LO AND WPR(WPR_LEN) < MID AND WPR(WPR_LEN) < WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 7 if WPR(WPR_LEN) < LO AND WPR(WPR_LEN) < WPR(WPR_LEN)[1] AND ADX(ADX_LEN) >= ADX(ADX_LEN)[1]; else 8 if WPR(WPR_LEN) < MID AND WPR(WPR_LEN) > WPR(WPR_LEN)[1] AND ADX(ADX_LEN) <= ADX(ADX_LEN)[1]; else 9 if WPR(WPR_LEN) > MID AND WPR(WPR_LEN) > WPR(WPR_LEN)[1] AND ADX(ADX_LEN) <= ADX(ADX_LEN)[1]; otherwise 0
Calculation: intensity = max(0, SCORE_SCALE - abs(WPR(WPR_LEN) - MID)) * min(ADX_CAP, ADX(ADX_LEN)) / SCORE_DIV
Calculation: mtf_all_above = WPR(WPR_LEN, T1, last completed bar) > MID AND WPR(WPR_LEN, T2, last completed bar) > MID AND WPR(WPR_LEN, T3, last completed bar) > MID, where T1 shorter than T2 shorter than T3
Calculation: mtf_all_below = WPR(WPR_LEN, T1, last completed bar) < MID AND WPR(WPR_LEN, T2, last completed bar) < MID AND WPR(WPR_LEN, T3, last completed bar) < MID, where T1 shorter than T2 shorter than T3
Long: WPR(WPR_LEN) crosses above MID
Short: WPR(WPR_LEN) crosses below MID
Long: candle_state = 0 OR candle_state = 1 OR candle_state = 2 OR candle_state = 3 OR candle_state = 9
Short: candle_state = 4 OR candle_state = 5 OR candle_state = 6 OR candle_state = 7 OR candle_state = 8
Long: +DI(ADX_LEN) >= -DI(ADX_LEN)
Short: +DI(ADX_LEN) < -DI(ADX_LEN)
Long: mtf_all_above AND NOT mtf_all_above[1]
Short: mtf_all_below AND NOT mtf_all_below[1]
Exit: long, intensity crosses under LOW_INTENSITY
Exit: short, intensity crosses under LOW_INTENSITY