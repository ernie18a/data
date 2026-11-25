Calculation: Long trailing step count = floor((highest bid price since entry − entry price) / trailing step)
Calculation: Short trailing step count = floor((entry price − lowest ask price since entry) / trailing step)
Calculation: Long trailing stop = entry price + trailing step × long trailing step count − trailing distance, capped at entry price + break-even offset when trail-to-break-even is enabled
Calculation: Short trailing stop = entry price − trailing step × short trailing step count + trailing distance, raised to entry price − break-even offset when trail-to-break-even is enabled
Exit: Long, take-profit distance > 0 AND bid price >= entry price + max(take-profit distance, broker minimum stop distance)
Exit: Long, stop-loss distance > 0 AND bid price <= entry price − max(stop-loss distance, broker minimum stop distance)
Exit: Short, take-profit distance > 0 AND ask price <= entry price − max(take-profit distance, broker minimum stop distance)
Exit: Short, stop-loss distance > 0 AND ask price >= entry price + max(stop-loss distance, broker minimum stop distance)
Exit: Long, trailing-stop mode enabled AND highest bid price since entry − entry price > trailing activation AND long trailing step count > 0 AND bid price <= long trailing stop
Exit: Short, trailing-stop mode enabled AND entry price − lowest ask price since entry > trailing activation AND short trailing step count > 0 AND ask price >= short trailing stop
Exit: Short, trailing-stop mode enabled AND trail-to-break-even enabled AND entry price − lowest ask price since entry > trailing activation AND short trailing step count = 0 AND ask price >= entry price − break-even offset
Exit: Long, trailing-stop mode disabled AND break-even mode enabled AND highest bid price since entry − entry price >= break-even activation AND bid price <= entry price + break-even offset
Exit: Short, trailing-stop mode disabled AND break-even mode enabled AND entry price − lowest ask price since entry >= break-even activation AND ask price >= entry price − break-even offset