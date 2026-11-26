Calculation: Gap = Open of the forming T1 bar / Close of the last completed T1 bar - 1, on chart bars taking T1 values
Calculation: IntradayReturn = Close / Open - 1 of the T1 bar that completes at the current bar, on chart bars taking T1 values
Calculation: Rank(X, order) = 1-based position of the traded instrument's X among the X values of all enabled universe members, sorted in the given order (descending or ascending) with missing values last
Calculation: SeasonQuarter(bar) = (month of bar, index of the day-of-month period containing bar's day), where day-of-month periods are split at three boundary days
Long: bar is first bar of its T1 period AND Rank(Gap, descending) <= top N AND Gap >= min move threshold AND SeasonQuarter(bar) not in blocked season set AND Year(bar) >= start year AND Year(bar) <= stop year
Long: bar is first bar of its T1 period AND Rank(Gap, ascending) <= top N AND Gap <= -min move threshold AND SeasonQuarter(bar) not in blocked season set AND Year(bar) >= start year AND Year(bar) <= stop year
Long: bar is last bar of its T1 period AND Rank(IntradayReturn, descending) <= top N AND IntradayReturn >= min move threshold AND SeasonQuarter(next T1 bar) not in blocked season set AND Year(next T1 bar) >= start year AND Year(next T1 bar) <= stop year
Exit: long, bar is last bar of its T1 period
Exit: long, bar is first bar of its T1 period