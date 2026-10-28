Calculation: Body = absolute difference between open and close
Calculation: Range = high minus low
Calculation: Lower wick = min(open, close) minus low
Calculation: Upper wick = high minus max(open, close)
Long: Range > 0 AND Body > 0 AND Body ≤ body-size threshold × Range AND Lower wick ≥ dominant-wick multiplier × Body AND Upper wick ≤ opposite-wick limit × Body AND Current low ≤ Previous bar low
Short: Range > 0 AND Body > 0 AND Body ≤ body-size threshold × Range AND Upper wick ≥ dominant-wick multiplier × Body AND Lower wick ≤ opposite-wick limit × Body AND Current high ≥ Previous bar high