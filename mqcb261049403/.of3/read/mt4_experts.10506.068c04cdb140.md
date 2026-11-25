Calculation: account net profit = sum of profit + swap + commission across open managed buy and sell positions
Calculation: account profit percentage = 100 + 100 × account net profit / account balance
Calculation: currency trailing active = true after account net profit reaches the currency trailing-start parameter and remains true while managed positions are open
Calculation: percentage trailing active = true after account profit percentage reaches 100 + the percentage trailing-start parameter and remains true while managed positions are open
Calculation: currency trailing level = maximum account net profit since currency trailing activation − currency trailing-retracement parameter
Calculation: percentage trailing level = maximum account profit percentage since percentage trailing activation − percentage trailing-retracement parameter
Exit: long, partial-close feature enabled AND close − entry price >= the configured distance for the next partial-close stage
Exit: short, partial-close feature enabled AND entry price − close >= the configured distance for the next partial-close stage
Exit: long, (currency mode AND account net profit >= currency take-profit parameter) OR (percentage mode AND account profit percentage >= 100 + percentage take-profit parameter)
Exit: short, (currency mode AND account net profit >= currency take-profit parameter) OR (percentage mode AND account profit percentage >= 100 + percentage take-profit parameter)
Exit: long, (currency mode AND account net profit <= −currency stop-loss parameter) OR (percentage mode AND account profit percentage <= 100 − percentage stop-loss parameter)
Exit: short, (currency mode AND account net profit <= −currency stop-loss parameter) OR (percentage mode AND account profit percentage <= 100 − percentage stop-loss parameter)
Exit: long, (currency mode AND currency trailing active AND account net profit <= currency trailing level) OR (percentage mode AND percentage trailing active AND account profit percentage <= percentage trailing level)
Exit: short, (currency mode AND currency trailing active AND account net profit <= currency trailing level) OR (percentage mode AND percentage trailing active AND account profit percentage <= percentage trailing level)