# LinReg Channel (No Repaint + Alerts)

- url: https://www.tradingview.com/script/5ebuspQU-linreg-channel-no-repaint-alerts/
- type: indicator
- pine_id: PUB;f48200cc9c934430b953806bfadee542
- version: 1.0

## Description

💡 Если хочешь усилить систему

Следующий шаг (очень рекомендую):

добавить slope фильтр:
trendUp = lr > lr[1]
trendDown = lr < lr[1]

и тогда:

лонг = выше LR + slope вверх
шорт = ниже LR + slope вниз

Если хочешь — соберу тебе версию уровня проп-трейдинга:

с volatility фильтром
с FVG
с точками входа/SL/TP

Скажи, на каком ТФ ты реально торгуешь (1m / 5m / 15m).

## Source Code

````pine
//@version=5
indicator("LinReg Channel (No Repaint + Alerts)", overlay=true)

// ===== INPUTS =====
len  = input.int(100, "Length", minval=2)
mult1 = input.float(1.0, "Small Dev")
mult2 = input.float(2.0, "Medium Dev")
mult3 = input.float(3.0, "Large Dev")

// ===== BASE LINE (NO REPAINT) =====
lr = ta.linreg(close, len, 0)

// стандартное отклонение от регрессии
dev = ta.stdev(close - lr, len)

// каналы
upper1 = lr + dev * mult1
lower1 = lr - dev * mult1

upper2 = lr + dev * mult2
lower2 = lr - dev * mult2

upper3 = lr + dev * mult3
lower3 = lr - dev * mult3

// ===== PLOTS =====
plot(lr, color=color.white, linewidth=2)
plot(upper1, color=color.new(color.blue, 30))
plot(lower1, color=color.new(color.blue, 30))

plot(upper2, color=color.new(color.orange, 20))
plot(lower2, color=color.new(color.orange, 20))

plot(upper3, color=color.new(color.red, 0))
plot(lower3, color=color.new(color.red, 0))

// ===== SIGNALS (ТОЛЬКО НА ЗАКРЫТИИ) =====
confirmed = barstate.isconfirmed

// пробой верхнего канала (перекупленность)
breakUpper = confirmed and ta.crossover(close, upper3)

// пробой нижнего канала (перепроданность)
breakLower = confirmed and ta.crossunder(close, lower3)

// возврат внутрь канала (mean reversion)
revertShort = confirmed and ta.crossunder(close, upper2)
revertLong  = confirmed and ta.crossover(close, lower2)

// ===== ALERTS =====
alertcondition(breakUpper, "Break Upper", "Price broke ABOVE upper channel")
alertcondition(breakLower, "Break Lower", "Price broke BELOW lower channel")

alertcondition(revertShort, "Revert Short", "Price returned from upper zone")
alertcondition(revertLong,  "Revert Long",  "Price returned from lower zone")

// ===== VISUAL SIGNALS =====
plotshape(breakUpper, title="Break Up", location=location.abovebar, color=color.red, style=shape.triangledown)
plotshape(breakLower, title="Break Down", location=location.belowbar, color=color.green, style=shape.triangleup)

plotshape(revertShort, title="Short", location=location.abovebar, color=color.orange, style=shape.labeldown, text="SELL")
plotshape(revertLong,  title="Long",  location=location.belowbar, color=color.lime,   style=shape.labelup,   text="BUY")
````
