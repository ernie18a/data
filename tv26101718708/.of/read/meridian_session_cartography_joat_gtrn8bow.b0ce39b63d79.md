Calculation: Developing day high and low = highest high and lowest low of chart bars since the current exchange day began, including the current bar.
Calculation: Developing session high and low = highest high and lowest low of chart bars since the current session began, including the current bar.
Long: A configured session is active AND close >= (developing day high + developing day low) / 2.
Short: A configured session is active AND close < (developing day high + developing day low) / 2.
Long: A configured session is active AND the chart bar is complete AND low < developing session low AND close > developing session low AND close > open.
Short: A configured session is active AND the chart bar is complete AND high > developing session high AND close < developing session high AND close < open.