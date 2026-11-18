Calculation: EurStrength = (Close(EURUSD) + Close(EURGBP) + Close(EURJPY)/100 + Close(EURAUD) + Close(EURCHF) + Close(EURCAD) + Close(EURNZD)) / 7
Long: Mode = trend AND EurStrength > EMA(EurStrength, P1) AND UsdStrength < EMA(UsdStrength, P1)
Long: Mode = counter-trend AND EurStrength < EMA(EurStrength, P1) AND UsdStrength > EMA(UsdStrength, P1)
Short: Mode = trend AND EurStrength < EMA(EurStrength, P1) AND UsdStrength > EMA(UsdStrength, P1)
Short: Mode = counter-trend AND EurStrength > EMA(EurStrength, P1) AND UsdStrength < EMA(UsdStrength, P1)