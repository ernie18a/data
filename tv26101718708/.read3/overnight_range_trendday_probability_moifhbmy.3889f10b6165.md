Calculation: each enabled open-anchor price = open of the first chart bar starting at or after its configured anchor time, if it starts within the configured capture lag; reset each day
Long: on a confirmed chart bar, at least one enabled open anchor has been captured AND close is above every enabled captured open-anchor price
Short: on a confirmed chart bar, at least one enabled open anchor has been captured AND close is below every enabled captured open-anchor price
Calculation: overnight range = highest(high) - lowest(low) across chart bars in the configured overnight window; freeze when the window ends
Calculation: Asia kill-zone range = highest(high) - lowest(low) across chart bars in the configured Asia kill-zone window; freeze when the window ends
Long: after the overnight range is frozen, both ranges are available, and overnight range is positive, Asia kill-zone range / overnight range is no greater than both the elevated and inverted thresholds
Short: after the overnight range is frozen, both ranges are available, and overnight range is positive, Asia kill-zone range / overnight range is greater than the inverted threshold