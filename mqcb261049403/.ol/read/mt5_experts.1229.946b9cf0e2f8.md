Calculation: Buy SVM classification = positive class from a support vector machine trained on chart-timeframe Bears Power, Bulls Power, ATR, Momentum, MACD, Stochastic, and Force Index values to label hypothetical buy trades using configured stop-loss, take-profit, and duration parameters; evaluate current values on the newly forming chart bar
Calculation: Sell SVM classification = positive class from a separate support vector machine trained on the same chart-timeframe indicator values to label hypothetical sell trades using the configured stop-loss, take-profit, and duration parameters; evaluate current values on the newly forming chart bar
Calculation: Pip size = 10^(-round(abs(round(log10(bid / 10000)))))
Long: Buy SVM classification is positive
Short: Sell SVM classification is positive
Exit: long, low <= entry price - configured stop-loss pips × pip size OR high >= entry price + configured take-profit pips × pip size
Exit: short, high >= entry price + configured stop-loss pips × pip size OR low <= entry price - configured take-profit pips × pip size