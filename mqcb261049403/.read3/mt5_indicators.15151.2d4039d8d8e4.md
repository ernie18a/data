Calculation: JMA change = JMA(applied price, JMA lookback, phase) - JMA(applied price, JMA lookback, phase)[1]; calculate signal quantities on chart bars for chart-timeframe signals or on T1 bars for higher-timeframe signals, using the still-forming T1 bar and sampling its signal on the first chart bar of each T1 interval, holding it until the next interval
Calculation: Population deviation = population standard deviation(JMA change, deviation lookback, including the current bar)
Calculation: Rounded JMA change = round(JMA change, instrument precision + additional precision)
Calculation: Smaller threshold = round(smaller deviation multiplier × Population deviation, instrument precision + additional precision)
Calculation: Larger threshold = round(larger deviation multiplier × Population deviation, instrument precision + additional precision)
Long: Rounded JMA change > Smaller threshold AND Rounded JMA change <= Larger threshold
Long: Rounded JMA change > Larger threshold
Short: Rounded JMA change < -Smaller threshold AND Rounded JMA change >= -Larger threshold
Short: Rounded JMA change < -Larger threshold