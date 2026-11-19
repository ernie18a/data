Calculation: NYSE issue count = NYSE advances + NYSE declines
Calculation: NYSE new-high percentage = 100 × NYSE issues hitting new 52-week highs ÷ NYSE issue count, or 0 when NYSE issue count is 0
Calculation: NYSE new-low percentage = 100 × NYSE issues hitting new 52-week lows ÷ NYSE issue count, or 0 when NYSE issue count is 0
Calculation: S&P 500 new-high percentage = 100 × S&P 500 issues hitting new 52-week highs ÷ S&P 500 constituent-count parameter, or 0 when the count is 0
Calculation: S&P 500 new-low percentage = 100 × S&P 500 issues hitting new 52-week lows ÷ S&P 500 constituent-count parameter, or 0 when the count is 0
Calculation: NASDAQ new-high percentage = 100 × NASDAQ issues hitting new 52-week highs ÷ NASDAQ constituent-count parameter, or 0 when the count is 0
Calculation: NASDAQ new-low percentage = 100 × NASDAQ issues hitting new 52-week lows ÷ NASDAQ constituent-count parameter, or 0 when the count is 0
Calculation: NYSE breadth trigger = NYSE new-high percentage ≥ NYSE threshold parameter AND NYSE new-low percentage ≥ NYSE threshold parameter AND NYSE Composite index ≥ its value trend-lookback parameter T1 bars ago
Calculation: S&P 500 breadth trigger = S&P 500 new-high percentage ≥ S&P 500 threshold parameter AND S&P 500 new-low percentage ≥ S&P 500 threshold parameter AND S&P 500 index ≥ its value trend-lookback parameter T1 bars ago
Calculation: NASDAQ breadth trigger = NASDAQ new-high percentage ≥ NASDAQ threshold parameter AND NASDAQ new-low percentage ≥ NASDAQ threshold parameter AND NASDAQ Composite index ≥ its value trend-lookback parameter T1 bars ago
Short: at least the minimum-consensus parameter number of enabled universes trigger on the same T1 bar
Short: at least the minimum-consensus parameter number of enabled universes triggered no more than the signal-window parameter T1 bars ago AND McClellan Oscillator < 0