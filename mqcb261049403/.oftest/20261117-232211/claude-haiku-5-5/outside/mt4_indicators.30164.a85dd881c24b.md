Calculation: EUR power = (close of EURUSD + close of EURGBP + close of EURJPY / 100 + close of EURAUD + close of EURCHF + close of EURCAD + close of EURNZD) / 7
Calculation: EUR power average = EMA of EUR power over P1 bars
Calculation: USD power average = EMA of USD power over P1 bars
Long: mode = M1 AND EUR power > EUR power average AND USD power < USD power average
Short: mode = M1 AND EUR power < EUR power average AND USD power > USD power average
Long: mode = M2 AND EUR power < EUR power average AND USD power > USD power average
Short: mode = M2 AND EUR power > EUR power average AND USD power < USD power average