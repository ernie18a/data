Calculation: Adjusted %B average = negative simple moving average of Bollinger %B
Calculation: FG score = (average of normalized KDJ K, Bollinger %B, and close’s normalized position within the lookback high-low range, minus 8) divided by 10; normalize each input by clipping it at zero and the percentile-rank lookback, then multiplying by one third of that lookback
Long: FG score <= -0.6
Long: adjusted %B average > FG score AND (adjusted %B average > Bollinger %B OR KDJ K < nearest-rank percentile of (Bollinger %B + adjusted %B average) at the 10th percentile OR FG score < -0.6)
Long: Bollinger %B crosses above adjusted %B average
Short: FG score >= 1.24
Short: close’s position within the lookback high-low range > -0.05 OR Bollinger %B - 1 > FG score