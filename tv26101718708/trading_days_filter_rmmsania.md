# trading days filter

- url: https://www.tradingview.com/script/rmmSaNIa-trading-days-filter/
- type: indicator
- pine_id: PUB;421de47d8fe946d6856e843ae597628c
- version: 1.0

## Description

"A trading days filter that allows you to mark non-trading days based on your backtest, ensuring you never miss a beat or get confused by days you shouldn’t be trading."

## Source Code

````pine
//@version=6
indicator("מסנן ימי מסחר [בקטסט]", overlay=true)

// === הגדרות קלט (Inputs) ===
showSun       = input.bool(false, title="יום ראשון (כל היום)", group="מסנן ימי מסחר")
showMon       = input.bool(false, title="יום שני (כל היום)", group="מסנן ימי מסחר")
showTue       = input.bool(false, title="יום שלישי (כל היום)", group="מסנן ימי מסחר")
showWed       = input.bool(false, title="יום רביעי (כל היום)", group="מסנן ימי מסחר")
showThu       = input.bool(false, title="יום חמישי (כל היום)", group="מסנן ימי מסחר")
showFriFull   = input.bool(false, title="יום שישי (כל היום)", group="מסנן ימי מסחר")
showFriCustom = input.bool(true, title="יום שישי אחרי שעה 12:30", group="מסנן ימי מסחר")
showSat       = input.bool(true, title="יום שבת (כל היום)", group="מסנן ימי מסחר")
tzInput       = input.string("Asia/Jerusalem", title="אזור זמן לפיו מחושבת השעה", group="מסנן ימי מסחר")
bgColorFilter = input.color(color.new(color.red, 85), title="צבע רקע לימים חסומים", group="מסנן ימי מסחר")

// === חילוץ נתוני זמן לפי אזור הזמן שנבחר ===
currentDay    = dayofweek(time, tzInput)
currentHour   = hour(time, tzInput)
currentMinute = minute(time, tzInput)

// === לוגיקת בדיקת ימים ושעות ===
isSun     = currentDay == dayofweek.sunday and showSun
isMon     = currentDay == dayofweek.monday and showMon
isTue     = currentDay == dayofweek.tuesday and showTue
isWed     = currentDay == dayofweek.wednesday and showWed
isThu     = currentDay == dayofweek.thursday and showThu
isFriFull = currentDay == dayofweek.friday and showFriFull
isSat     = currentDay == dayofweek.saturday and showSat

// חישוב מיוחד ליום שישי מהשעה 12:30
isAfter1230  = currentHour > 12 or (currentHour == 12 and currentMinute >= 30)
isFriSpecial = currentDay == dayofweek.friday and isAfter1230 and showFriCustom

// שילוב כל התנאים לחסימה (ללא הגבלת אינטרוול מובנית בקוד)
isNoTradeDay = isSun or isMon or isTue or isWed or isThu or isFriFull or isFriSpecial or isSat

// === צביעת הרקע על הגרף ===
bgcolor(isNoTradeDay ? bgColorFilter : na)
````
