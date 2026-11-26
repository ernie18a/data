Calculation: Coppock = MA((selected price - selected price[longer ROC lookback]) / selected price[longer ROC lookback] + (selected price - selected price[shorter ROC lookback]) / selected price[shorter ROC lookback], smoothing lookback, moving-average method); for T1, calculate on T1 bars and sample the T1 bar still forming at each chart-bar time
Long: Coppock > 0 AND Coppock != Coppock[1]
Short: Coppock < 0 AND Coppock != Coppock[1]
Long: Coppock(T1, bar still forming) > 0 AND Coppock(T1, bar still forming) != Coppock(T1)[1]
Short: Coppock(T1, bar still forming) < 0 AND Coppock(T1, bar still forming) != Coppock(T1)[1]