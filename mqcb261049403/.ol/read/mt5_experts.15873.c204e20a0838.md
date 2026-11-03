Calculation: Fisher oscillator = On the configured indicator timeframe (higher or lower than the chart timeframe as configured), for each completed bar, let P be the selected applied price and H/L the highest high/lowest low over the lookback. Let x = clamp((P-L)/(H-L) - 0.5 + 0.67 × previous x, -999, 999); Fisher = 0.5 × ln((1+x)/(1-x)) + 0.5 × previous Fisher. If H=L, increase H by one price point.
Calculation: Signal line = Fisher oscillator value on the preceding bar.
Long: Fisher oscillator on the older completed bar <= its signal line AND Fisher oscillator on the latest completed bar > its signal line
Short: Fisher oscillator on the older completed bar >= its signal line AND Fisher oscillator on the latest completed bar < its signal line
Exit: Short, Fisher oscillator on the latest completed bar > its signal line
Exit: Long, Fisher oscillator on the latest completed bar < its signal line