Calculation: Coppock Curve = smooth((applied price / applied price[longer ROC lookback] - 1) + (applied price / applied price[shorter ROC lookback] - 1), smoothing method, smoothing phase, smoothing lookback) on T1 bars
Long: Coppock Curve > 0 AND Coppock Curve != Coppock Curve[1] on each completed T1 bar
Short: Coppock Curve < 0 AND Coppock Curve != Coppock Curve[1] on each completed T1 bar
Long: On each T1 bar close, with [0] the just-completed bar, long-entry permission is enabled AND Coppock Curve[1] < Coppock Curve[2] AND Coppock Curve[0] > Coppock Curve[1]
Short: On each T1 bar close, with [0] the just-completed bar, short-entry permission is enabled AND Coppock Curve[1] > Coppock Curve[2] AND Coppock Curve[0] < Coppock Curve[1]
Exit: short, On each T1 bar close, short-close permission is enabled AND Coppock Curve[1] < Coppock Curve[2]
Exit: long, On each T1 bar close, long-close permission is enabled AND Coppock Curve[1] > Coppock Curve[2]