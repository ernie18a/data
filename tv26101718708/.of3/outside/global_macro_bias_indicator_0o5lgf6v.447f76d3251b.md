Calculation: Macro risk score = (if SMA(10-year government bond yield - 2-year government bond yield, P1) - SMA(10-year government bond yield - 2-year government bond yield, P1)[P2] > P3 then 1, else if SMA(10-year government bond yield - 2-year government bond yield, P1) - SMA(10-year government bond yield - 2-year government bond yield, P1)[P2] < P4 then -1, else 0) + (if ROC(US dollar index, P5) < P6 then 1, else if ROC(US dollar index, P5) > P7 then -1, else 0) + (if EMA(volatility index, P8) < P9 then 1, else if EMA(volatility index, P8) > P10 then -1, else 0)
Long: macro risk score > 0
Short: macro risk score < 0
Exit: long, macro risk score = 0
Exit: short, macro risk score = 0