Calculation: Smoothed momentum = Jurik moving average, with configurable length and phase, of selected price minus its value a configurable number of bars ago, divided by the price point size. Selected price may be open, high, low, close, median, typical, weighted close, (open + close)/2, (open + high + low + close)/4, high if close > open and low if close < open and close otherwise, (high + close)/2 if close > open and (low + close)/2 if close < open and close otherwise, or DeMark price.
Calculation: DeMark price = (high + low + close + X)/2 - (high + low)/2, where X = low if close < open, high if close > open, otherwise close.
Calculation: Indicator momentum = smoothed momentum on the chart timeframe.
Calculation: Trading momentum = smoothed momentum of close on a configurable indicator timeframe, which may be higher or lower than the chart timeframe; use the last completed indicator bar by default, or the still-forming bar if configured, and the two preceding indicator bars.
Long: Round the current indicator momentum minus its previous value to the nearest integer > 0.
Short: Round the current indicator momentum minus its previous value to the nearest integer < 0.
Long: Latest trading momentum > preceding trading momentum AND trading momentum two bars before latest > preceding trading momentum.
Short: Latest trading momentum < preceding trading momentum AND trading momentum two bars before latest < preceding trading momentum.
Exit: long, latest trading momentum < preceding trading momentum.
Exit: short, latest trading momentum > preceding trading momentum.
Exit: long, low <= entry price - configured stop distance OR high >= entry price + configured profit distance.
Exit: short, high >= entry price + configured stop distance OR low <= entry price - configured profit distance.