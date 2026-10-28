Long: (Fast VWMA crosses above fast SMA OR fast VWMA crosses above slow SMA OR slow VWMA crosses above slow SMA, according to the selected entry speed) AND bar time is within the configured entry window
Short: (Fast VWMA crosses below fast SMA OR fast VWMA crosses below slow SMA OR slow VWMA crosses below slow SMA, according to the selected entry speed) AND bar time is within the configured entry window
Calculation: Long take-profit level = close at the latest slow VWMA cross above slow SMA + ATR at that cross × take-profit multiple
Calculation: Long stop level = close at the latest slow VWMA cross above slow SMA − ATR at that cross × stop-loss multiple
Calculation: Short take-profit level = close at the latest slow VWMA cross below slow SMA − ATR at that cross × take-profit multiple
Calculation: Short stop level = close at the latest slow VWMA cross below slow SMA + ATR at that cross × stop-loss multiple
Calculation: Stochastic %K = smoothed stochastic value of close within the rolling high-low range
Calculation: Stochastic %D = shorter-period smoothing of Stochastic %K
Exit: Long, high > long take-profit level OR low < long stop level OR slow VWMA crosses below slow SMA OR Stochastic %K crosses below %D while their average is at or above the overbought threshold
Exit: Short, low < short take-profit level OR high > short stop level OR slow VWMA crosses above slow SMA OR Stochastic %K crosses above %D while their average is at or below the oversold threshold