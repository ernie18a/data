Calculation: UpRun = cumulative positive trunc((close - close[1]) / minimum price increment), reset to absent on a negative value and unchanged on zero
Calculation: DownRun = cumulative negative trunc((close - close[1]) / minimum price increment), reset to absent on a positive value and unchanged on zero
Long: UpRun > UpRun[1] OR DownRun > DownRun[1]
Short: UpRun < UpRun[1] OR DownRun < DownRun[1]