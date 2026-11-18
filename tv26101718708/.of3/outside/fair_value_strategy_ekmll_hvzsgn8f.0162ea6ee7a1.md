Calculation: Net liquidity = Federal Reserve balance sheet on T1 - Treasury General Account on T1 - reverse repo balance on T1
Calculation: Index fair value = net liquidity / 1 billion / scalar - subtractor
Calculation: Index deviation = selected index closing price on T1 - index fair value
Calculation: Overbought crossing = net liquidity > 0 AND previous chart bar's index deviation < overbought threshold AND current index deviation > overbought threshold
Calculation: Oversold crossing = net liquidity > 0 AND previous chart bar's index deviation > oversold threshold AND current index deviation < oversold threshold
Long: oversold crossing OR (overbought crossing AND on or after configured start date AND inverse enabled AND strategy permits short-side trades)
Short: overbought crossing OR (oversold crossing AND on or after configured start date AND inverse enabled AND strategy permits long-side trades)
Exit: long, close-date closing enabled AND current bar date = configured close date OR (inverse enabled AND strategy permits only short-side trades AND on or after configured start date AND oversold crossing) OR (inverse disabled AND strategy permits only long-side trades AND on or after configured start date AND overbought crossing)
Exit: short, close-date closing enabled AND current bar date = configured close date OR (inverse disabled AND strategy permits only short-side trades AND on or after configured start date AND oversold crossing) OR (inverse enabled AND strategy permits only long-side trades AND on or after configured start date AND overbought crossing)