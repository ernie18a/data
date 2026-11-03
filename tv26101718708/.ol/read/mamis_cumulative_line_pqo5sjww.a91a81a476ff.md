Calculation: Daily breadth ratio = (advances − declines) / (advances + declines + unchanged issues), treating missing unchanged issues as zero
Calculation: Cumulative breadth = sum of daily breadth ratios since the selected start year, reset to zero at the start year
Calculation: Breadth EMA = EMA of cumulative breadth
Calculation: Breadth state = impulse if cumulative breadth ≥ its EMA and cumulative breadth is above each of its previous three observations; fading if cumulative breadth ≥ its EMA but the impulse condition is false; weak if cumulative breadth < its EMA; accept a state change after the configured number of consecutive daily breadth observations produce that state
Calculation: Trend Z-score = (cumulative breadth − breadth EMA − the longer-lookback mean of that spread) / the longer-lookback standard deviation of that spread
Calculation: Impulse Z-score = (shorter-lookback SMA of daily breadth ratio − its longer-lookback mean) / its longer-lookback standard deviation
Calculation: Bearish divergence = a confirmed price pivot high is higher than the preceding confirmed price pivot high, while cumulative breadth at the newer pivot is lower than at the preceding pivot; confirm each pivot using bars to its left and right
Long: breadth state is impulse
Long: impulse Z-score > its threshold AND breadth state is impulse AND close > its EMA AND more bars have elapsed since the previous kickoff than the configured cooldown AND daily breadth data is fresh and available
Short: breadth state is weak
Short: bearish divergence occurs AND breadth state is not impulse
Short: breadth state is weak AND Trend Z-score < its threshold AND a bearish divergence occurred within the configured recent-bar window
Exit: 
