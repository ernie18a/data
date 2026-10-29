Calculation: JFATL = JMA-smoothed 39-bar FATL digital filter of the configured applied price, rounded to configured digits; direction is up when JFATL rises, down when it falls, and unchanged inherits the prior direction. Use bars on the configured indicator timeframe, which may be higher or lower than the chart timeframe; evaluate the selected signal bar and the immediately older bar. The selected bar is completed when its shift is greater than zero and still forming at shift zero.
Long: selected bar direction is up AND older bar direction is not up
Short: selected bar direction is down AND older bar direction is not down
Exit: long, selected bar direction is down
Exit: short, selected bar direction is up