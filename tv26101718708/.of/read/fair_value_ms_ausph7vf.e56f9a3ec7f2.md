Calculation: Up FVG = current low > high two bars ago AND previous close > high two bars ago
Calculation: Down FVG = current high < low two bars ago AND previous close < low two bars ago
Calculation: Swing high = highest high tracked since the latest Up FVG; confirmed when a Down FVG occurs
Calculation: Swing low = lowest low tracked since the latest Down FVG; confirmed when an Up FVG occurs
Calculation: Bullish AOI pending = an Up FVG confirms a swing low below the previous confirmed swing low, and either no bullish AOI is pending or that swing low is at or below the pending bullish AOI's lower boundary; its lower boundary is the confirmed swing low
Calculation: Bearish AOI pending = a Down FVG confirms a swing high above the previous confirmed swing high, and either no bearish AOI is pending or that swing high is at or above the pending bearish AOI's upper boundary; its upper boundary is the confirmed swing high
Long: close > latest confirmed swing high AND bullish AOI pending AND current downswing low <= bullish AOI lower boundary
Short: close < latest confirmed swing low AND bearish AOI pending AND current upswing high >= bearish AOI upper boundary