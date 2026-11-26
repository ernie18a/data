Calculation: wing width = fixed width input when width mode is fixed; otherwise low-volatility width when VIX close < low-volatility threshold, middle width when VIX close <= high-volatility threshold, and high-volatility width otherwise
Calculation: minimum fly debit = wing width / (maximum reward-to-risk input + 1)
Calculation: maximum fly debit = wing width / (minimum reward-to-risk input + 1)
Option: buy call, 0 < minutes until New York session close <= minutes-before-close input AND chart bar is confirmed AND call-fly debit >= minimum fly debit AND call-fly debit <= maximum fly debit
Option: buy put, 0 < minutes until New York session close <= minutes-before-close input AND chart bar is confirmed AND put-fly debit >= minimum fly debit AND put-fly debit <= maximum fly debit