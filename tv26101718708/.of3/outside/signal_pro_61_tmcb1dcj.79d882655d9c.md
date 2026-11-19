Calculation: exit moving average = moving average(closing price, method P3, length P4)
Calculation: trend moving average = moving average(closing price, method P5, length P6)
Calculation: ARSI = ARSI(closing price, length P10, method P11)
Long: P1 enabled AND during session P2 AND flat AND exit moving average > trend moving average AND closing price > upper Bollinger Band(source P7, length P8, multiplier P9) AND ARSI > P12
Short: P13 enabled AND during session P2 AND flat AND exit moving average < trend moving average AND closing price < lower Bollinger Band(source P7, length P8, multiplier P9) AND ARSI < P14
Exit: long, closing price < exit moving average OR current bar outside session P15 AND prior bar inside session P15
Exit: short, closing price > exit moving average OR current bar outside session P15 AND prior bar inside session P15