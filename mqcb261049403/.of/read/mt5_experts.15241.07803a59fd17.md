Calculation: UpVotes = number of the 7 prices (open, high, low, median (high+low)/2, typical (high+low+close)/3, weighted (high+low+2*close)/4, close) whose value on the currently forming bar of a separately specified signal timeframe (may differ from, or equal, the chart timeframe) is strictly greater than the same price on the last completed bar of that timeframe
Calculation: DownVotes = 7 - UpVotes (prices that are equal or lower count as down)
Long: UpVotes > DownVotes (if currently short, close the short and reverse to long)
Short: DownVotes > UpVotes (if currently long, close the long and reverse to short)
Exit: short, UpVotes > DownVotes
Exit: long, DownVotes > UpVotes