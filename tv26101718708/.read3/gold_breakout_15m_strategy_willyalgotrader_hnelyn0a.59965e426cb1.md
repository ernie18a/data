Calculation: Range High = highest high of chart bars opening on the current broker-clock date at or after the range-start-hour parameter and before the range-end-hour parameter
Calculation: Range Low = lowest low of chart bars opening on the current broker-clock date at or after the range-start-hour parameter and before the range-end-hour parameter
Long: close > Range High AND Range High > Range Low
Short: close < Range Low AND Range High > Range Low
Long: high >= Range High AND Range High > Range Low AND range-start hour parameter < range-end hour parameter < close-hour parameter AND the next bar opens at or after the range-end hour and before the close hour AND the current broker-clock date is not the first date in chart history AND no trade has been taken and no position is open on this date AND the equity guard has not halted trading; the first filled boundary cancels the other entry
Short: low <= Range Low AND Range High > Range Low AND range-start hour parameter < range-end hour parameter < close-hour parameter AND the next bar opens at or after the range-end hour and before the close hour AND the current broker-clock date is not the first date in chart history AND no trade has been taken and no position is open on this date AND the equity guard has not halted trading; the first filled boundary cancels the other entry
Calculation: Long stop = Range Low in opposite-range-boundary mode; otherwise round Range High × (1 − stop-percent parameter / 100) to the instrument minimum tick, then at entry-bar close reset once to entry price × (1 − stop-percent parameter / 100) and keep fixed
Calculation: Short stop = Range High in opposite-range-boundary mode; otherwise round Range Low × (1 + stop-percent parameter / 100) to the instrument minimum tick, then at entry-bar close reset once to entry price × (1 + stop-percent parameter / 100) and keep fixed
Calculation: Daily drawdown = max(0, 100 × (day equity peak before the bar − worst equity) / day equity peak before the bar), where worst equity = equity at bar close − the account-currency value of adverse price move × absolute position size × point value; adverse price move is close − low for a long, high − close for a short, and zero when flat or on the entry bar; reset the peak each broker-clock date and update it to the greater of the previous peak and equity at bar close
Exit: Long, low <= Long stop
Exit: Short, high >= Short stop
Exit: Long, next bar opens at or after the close hour or before the range-end hour
Exit: Short, next bar opens at or after the close hour or before the range-end hour
Exit: Long, equity guard is enabled AND Daily drawdown >= drawdown-limit parameter
Exit: Short, equity guard is enabled AND Daily drawdown >= drawdown-limit parameter