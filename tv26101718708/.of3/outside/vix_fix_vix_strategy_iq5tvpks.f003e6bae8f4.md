Calculation: Combined Williams VIX Fix = 100 × (highest closing price over P1 − low price) / highest closing price over P1 + 100 × (lowest closing price over P1 − high price) / lowest closing price over P1
Calculation: Lower VIX Fix band = moving average(100 × (lowest closing price over P1 − high price) / lowest closing price over P1, length P7, type P6) × P8
Short: (combined Williams VIX Fix crosses below the lower VIX Fix band AND MACD line(selected series P9, fast length P10, slow length P11, signal length P12) on T1 > 0) OR (combined Williams VIX Fix < lower VIX Fix band AND (combined Williams VIX Fix < lower Bollinger Band(combined Williams VIX Fix, length P2, deviation P3) OR combined Williams VIX Fix <= lowest(combined Williams VIX Fix over P4) × P5) AND combined Williams VIX Fix < 0)
Exit: long, P13 AND contract expiration date <= current time
Exit: short, P13 AND contract expiration date <= current time
Exit: long, P14 AND bars since position entry >= P15
Exit: short, P14 AND bars since position entry >= P15