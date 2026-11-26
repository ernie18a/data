Calculation: FormationBars = completed T1 bars with time from session open to range end (session open + range duration) on sessions whose day is in the active-day set
Calculation: RangeHigh = highest high of FormationBars
Calculation: RangeLow = lowest low of FormationBars
Calculation: Efficiency = Kaufman efficiency ratio of FormationBars closes, with the first FormationBar open as the starting price
Calculation: CloseLocation = Stochastic %K of the last FormationBar close over FormationBars
Calculation: Skew = ((RangeHigh - FirstOpen) - (FirstOpen - RangeLow)) / (RangeHigh - RangeLow), where FirstOpen is the open of the first FormationBar
Calculation: LateShare = 1 - HalfWidth / (RangeHigh - RangeLow), where HalfWidth is the highest high minus the lowest low of FormationBars timed before session open + half of range duration
Calculation: Buffer = buffer fraction * (RangeHigh - RangeLow)
Calculation: PostBars = completed T1 bars with time from range end to projection end (session open + projection duration)
Calculation: UpperRun = number of consecutive PostBars ending at the current bar where (close, or high if evidence basis is wick) > RangeHigh + Buffer AND NOT (close, or low if evidence basis is wick) < RangeLow - Buffer
Calculation: LowerRun = number of consecutive PostBars ending at the current bar where (close, or low if evidence basis is wick) < RangeLow - Buffer AND NOT (close, or high if evidence basis is wick) > RangeHigh + Buffer
Long: at range end, Efficiency >= efficiency minimum AND CloseLocation >= close-location edge AND Skew >= skew threshold
Long: at range end, LateShare >= late share minimum AND Skew >= skew threshold
Short: at range end, Efficiency >= efficiency minimum AND CloseLocation <= 1 - close-location edge AND Skew <= -skew threshold
Short: at range end, LateShare >= late share minimum AND Skew <= -skew threshold
Long: UpperRun >= confirmation count AND neither UpperRun nor LowerRun reached confirmation count on any earlier PostBar
Short: LowerRun >= confirmation count AND neither UpperRun nor LowerRun reached confirmation count on any earlier PostBar
Exit: long, close <= RangeHigh on the first PostBar after the accepted departure above
Exit: short, close >= RangeLow on the first PostBar after the accepted departure below
Short: low <= RangeLow on the first PostBar after a re-entry, where the re-entry is the first PostBar after the accepted departure above with close <= RangeHigh
Long: high >= RangeHigh on the first PostBar after a re-entry, where the re-entry is the first PostBar after the accepted departure below with close >= RangeLow