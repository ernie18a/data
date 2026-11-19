Calculation: call premium level n = max(0, configured spot high - option strike price) + premium step size × n, for n from 1 through 7
Calculation: put premium level n = max(0, option strike price - configured spot low) + premium step size × n, for n from 1 through 7
Option: buy call, call selected AND entry display enabled AND close crosses above call premium level n for some n from 1 through 6 AND configured level count >= n + 1
Option: buy put, put selected AND entry display enabled AND close crosses above put premium level n for some n from 1 through 6 AND configured level count >= n + 1
Exit: long, target-hit marking enabled AND high >= the next premium level above the lowest premium level crossed upward by the entry close
Exit: long, stop-loss marking enabled AND close <= the low of the bar before entry AND (target-hit marking disabled OR high < the next premium level above the lowest premium level crossed upward by the entry close)