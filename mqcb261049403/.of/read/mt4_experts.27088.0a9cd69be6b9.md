Calculation: CCI = 20-period Commodity Channel Index of typical price
Calculation: Fast/slow LWMA = linearly weighted moving average of typical price; fast lookback is shorter than slow lookback
Calculation: MACD main and signal = MACD with shorter and longer exponential averages and a signal average
Calculation: OsMA = MACD main minus signal
Calculation: Bollinger lower band = 20-period Bollinger lower band, 2 standard deviations
Calculation: Guppy equalities = either all six short EMAs (3, 5, 8, 10, 12, 15) are equal, or all six longer EMAs (30, 35, 40, 45, 50, 60) are equal; both sets use typical price
Calculation: Bullish votes = count of: CCI current > previous AND current < 75; fast/slow LWMA current > slow; ATR on last completed chart bar > ATR on forming chart bar; OsMA > 0; MACD main > signal AND main != 0; stochastic <= 12 is false and stochastic >= 88. Bearish votes = count of: CCI current < previous AND current >= -75; fast/slow LWMA current < slow; ATR on last completed chart bar < ATR on forming chart bar; OsMA < 0; MACD main < signal AND main != 0; stochastic <= 12.
Long: CCI current > previous AND CCI current < 75
Short: CCI current < previous AND CCI current >= -75
Long: fast/slow LWMA on the last completed chart bar, fast > slow
Short: fast/slow LWMA on the last completed chart bar, fast < slow
Long: ATR on the last completed chart bar > ATR on the forming chart bar
Short: ATR on the last completed chart bar < ATR on the forming chart bar
Long: OsMA > 0
Short: OsMA < 0
Long: MACD main > signal AND MACD main != 0
Short: MACD main < signal AND MACD main != 0
Long: stochastic %K >= 88
Short: stochastic %K <= 12
Long: Bullish votes > Bearish votes AND 5-period EMA of close > 13-period EMA of close on the last completed chart bar AND 7-period RSI of close > 50 on the last completed chart bar AND fast/slow LWMA on the forming chart bar, fast > slow AND low two bars ago < high one bar ago
Short: Bearish votes > Bullish votes AND 5-period EMA of close < 13-period EMA of close on the last completed chart bar AND 7-period RSI of close < 50 on the last completed chart bar AND fast/slow LWMA on the forming chart bar, fast < slow AND low one bar ago < high two bars ago
Exit: long, close <= entry price - stop-loss distance OR close >= entry price + take-profit distance OR Guppy equalities OR close one bar ago <= lower Bollinger band
Exit: short, close <= entry price - stop-loss distance OR close >= entry price + take-profit distance OR Guppy equalities OR close one bar ago <= lower Bollinger band