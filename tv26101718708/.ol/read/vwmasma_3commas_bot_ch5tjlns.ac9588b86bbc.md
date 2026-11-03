Calculation: Entry pair = fast VWMA and fast SMA for the fast signal; fast VWMA and slow SMA for the medium signal; slow VWMA and slow SMA for the slow signal. Fast lookbacks are shorter than slow lookbacks.
Calculation: Long take-profit level = close + ATR × take-profit multiple when the slow VWMA crosses above the slow SMA; otherwise retain the previous level.
Calculation: Long stop level = close − ATR × stop-loss multiple when the slow VWMA crosses above the slow SMA; otherwise retain the previous level.
Calculation: Short take-profit level = close − ATR × take-profit multiple when the slow VWMA crosses below the slow SMA; otherwise retain the previous level.
Calculation: Short stop level = close + ATR × stop-loss multiple when the slow VWMA crosses below the slow SMA; otherwise retain the previous level.
Calculation: Stochastic K = smoothed stochastic oscillator; Stochastic D = a shorter moving average of Stochastic K.
Long: datetime is within the configured entry window AND the configured entry pair's VWMA crosses above its SMA.
Short: datetime is within the configured entry window AND the configured entry pair's VWMA crosses below its SMA.
Exit: long, high reaches or exceeds the long take-profit level OR low reaches or falls below the long stop level OR the slow VWMA crosses below the slow SMA OR Stochastic K crosses below Stochastic D while their average is at or above the overbought threshold.
Exit: short, low reaches or falls below the short take-profit level OR high reaches or exceeds the short stop level OR the slow VWMA crosses above the slow SMA OR Stochastic K crosses above Stochastic D while their average is at or below the oversold threshold.