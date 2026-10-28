# SPX Iron Condor Context  IV/RV and Mandatory Exit

- url: https://www.tradingview.com/script/45lorqJt-spx-iron-condor-context-iv-rv-and-mandatory-exit/
- type: indicator
- pine_id: PUB;5e7ca853415e4ffbac5681ea9a4bdfb4
- version: 1.0

## Description

**SPX Iron Condor Context — IV/RV and Mandatory Exit**

This indicator is a chart overlay for a manually specified SPX iron condor. It brings the short strikes, an IV-based expected move to a chosen exit time, and credit-based TP/SL levels into one view. It was designed for short-dated positions that must be closed before expiration.

**What the chart shows**

Orange lines mark the short put and short call strikes. Blue lines show the current SPX price plus and minus an approximate one-standard-deviation move to the mandatory exit time:

Expected move = SPX price × annualized IV × √(calendar time remaining / 365 days).

The blue lines recalculate as SPX and the remaining time change. They describe a possible price range *at the selected exit time*, not a guaranteed trading range or a forecast of the position’s P&L.

The dashboard displays the distance to each short strike, the nearest distance in expected-move units, entered IV versus an optional user forecast of realized volatility, and historical realized volatility calculated from completed daily returns. It also shows the opening credit as a percentage of wing width, the debit required for a 60% profit target (`0.40 × credit`), the debit corresponding to a loss equal to the opening credit (`2.00 × credit`), and theoretical maximum loss at expiration for one equal-width condor.

**Setup and alerts**

Use a time-based intraday SPX chart. Enter the short strikes, wing width, actual opening credit in index points, contract multiplier, annualized IV for the relevant expiration, and the exact mandatory exit date and time. Forecast RV is optional. The sample credit and exit date in the inputs must be changed for each position. Set the chart timezone to New York when entering the exit time.

Alerts report a crossing of either short strike or the selected exit time. They do not report a four-leg TP or SL fill.

**Scope of the calculations**

The indicator does not select 16-delta options, read an option chain or broker position, price the four option legs, or place orders. TP and SL values are *option closing-debit thresholds*, not SPX price targets. Commissions, slippage, changes in IV and skew, and quote quality are not included. Historical bars use the currently entered IV and exit date, so the plotted history is not a backtest.

The position-specific exit horizon is the central feature: strike distance, the projected move, and the credit-based risk levels are shown together for the time the trader actually plans to hold the condor.

---

**Русское описание**

Индикатор накладывается на график SPX и помогает оценивать Iron Condor с вручную заданными страйками. Он объединяет расстояние до проданных опционов, ожидаемое движение на основе IV **до выбранного времени обязательного выхода** и уровни TP/SL, рассчитанные от полученной премии.

Оранжевые линии показывают проданные Put и Call. Синие линии — текущую цену SPX ± приблизительное движение в одну сигму до времени выхода. Они пересчитываются при изменении SPX и оставшегося времени. Это оценка диапазона цены к моменту выхода, а не границы, внутри которых позиция обязательно останется прибыльной.

Таблица показывает расстояние до обоих коротких страйков, расстояние до ближайшего страйка в сигмах, введённую IV и необязательный прогноз RV, историческую RV по завершённым дневным барам, отношение кредита к ширине крыла, дебет TP (`0,40 × кредит`) и дебет SL (`2,00 × кредит`). Максимальный убыток на экспирации рассчитан для одного кондора с одинаковой шириной крыльев.

Для настройки нужен внутридневной график SPX. Введите фактический кредит в пунктах индекса, страйки, ширину крыла, IV выбранной экспирации и точную дату выхода. Значения премии и даты в настройках служат примером; их нужно менять для каждой позиции.

Оповещения относятся только к пересечению коротких страйков и наступлению времени выхода. Индикатор не получает котировки четырёх опционов, не выбирает контракты по дельте, не рассчитывает исполнимый дебет закрытия и не отправляет заявки. Комиссии, проскальзывание и изменение IV или skew не учтены. Исторические линии пересчитываются с введёнными сейчас IV и датой выхода, поэтому их нельзя использовать как результат бэктеста.

## Source Code

````pine
//@version=6
indicator("SPX IC | strikes, IV/RV and exit", overlay = true)

shortPut = input.float(0.0, "Short put strike", minval = 0, group = "Position")
shortCall = input.float(0.0, "Short call strike", minval = 0, group = "Position")
wingWidth = input.float(10.0, "Wing width (index points)", minval = 0.01, group = "Position")
credit = input.float(2.5, "Actual opening credit (index points)", minval = 0, group = "Position")
multiplier = input.int(100, "Contract multiplier", minval = 1, group = "Position")

ivPct = input.float(0.0, "Expiry IV, annualized %", minval = 0, group = "Volatility")
forecastRvPct = input.float(0.0, "Forecast RV to exit, annualized % (optional)", minval = 0, group = "Volatility")
rvLookback = input.int(10, "Historical RV lookback (completed days)", minval = 3, maxval = 252, group = "Volatility")

exitAt = input.time(timestamp("24 Sep 2026 15:55 -0400"), "Mandatory exit (set chart timezone to New York)", group = "Risk")

histRvPct = request.security(syminfo.tickerid, "D",
     ta.stdev(math.log(close / close[1]), rvLookback)[1] * math.sqrt(252.0) * 100.0,
     lookahead = barmerge.lookahead_on)

nowMs = barstate.isrealtime ? timenow : time_close
yearsRemaining = na(nowMs) ? na : math.max(exitAt - nowMs, 0) / (365.0 * 24.0 * 60.0 * 60.0 * 1000.0)
em = close * ivPct / 100.0 * math.sqrt(yearsRemaining)

configured = timeframe.isintraday and not na(nowMs) and shortPut > 0 and shortCall > shortPut and wingWidth > 0 and credit > 0 and credit < wingWidth and ivPct > 0
active = configured and nowMs < exitAt
putGap = close - shortPut
callGap = shortCall - close
nearGap = math.min(putGap, callGap)
gapInEm = active and em > 0 ? nearGap / em : na

tpDebit = 0.40 * credit
slDebit = 2.00 * credit
maxExpiryLoss = wingWidth - credit

plot(configured ? shortPut : na, "Short put", color = color.orange, linewidth = 2)
plot(configured ? shortCall : na, "Short call", color = color.orange, linewidth = 2)
plot(active ? close - em : na, "Lower 1 sigma to exit", color = color.new(color.blue, 15))
plot(active ? close + em : na, "Upper 1 sigma to exit", color = color.new(color.blue, 15))

panelBg = color.rgb(24, 27, 34)
var table dashboard = table.new(position.top_right, 2, 9, bgcolor = panelBg, border_width = 1)
if barstate.islast
    table.cell(dashboard, 0, 0, "SPX Iron Condor", text_color = color.white, bgcolor = color.navy)
    table.cell(dashboard, 1, 0, not configured ? "SET INPUTS / 1-5m" : active ? "ACTIVE" : "EXIT TIME PASSED", text_color = color.white, bgcolor = not configured ? color.gray : active ? color.teal : color.red)
    table.cell(dashboard, 0, 1, "Short P / C", text_color = color.white)
    table.cell(dashboard, 1, 1, configured ? str.tostring(shortPut, "#.##") + " / " + str.tostring(shortCall, "#.##") : "—", text_color = color.white)
    table.cell(dashboard, 0, 2, "Gap P / C (pts)", text_color = color.white)
    table.cell(dashboard, 1, 2, configured ? str.tostring(putGap, "#.##") + " / " + str.tostring(callGap, "#.##") : "—", text_color = nearGap <= 0 and configured ? color.red : color.white)
    table.cell(dashboard, 0, 3, "IV / forecast RV (%)", text_color = color.white)
    table.cell(dashboard, 1, 3, ivPct > 0 ? str.tostring(ivPct, "#.##") + " / " + (forecastRvPct > 0 ? str.tostring(forecastRvPct, "#.##") + " (" + str.tostring(ivPct / forecastRvPct, "#.##") + "x)" : "set forecast") : "set IV", text_color = color.white)
    table.cell(dashboard, 0, 4, "Historic RV (%)", text_color = color.white)
    table.cell(dashboard, 1, 4, na(histRvPct) ? "—" : str.tostring(histRvPct, "#.##"), text_color = color.white)
    table.cell(dashboard, 0, 5, "1σ move / nearest gap", text_color = color.white)
    table.cell(dashboard, 1, 5, active ? str.tostring(em, "#.##") + " / " + str.tostring(gapInEm, "#.##") + "σ" : "—", text_color = color.white)
    table.cell(dashboard, 0, 6, "Credit / wing", text_color = color.white)
    table.cell(dashboard, 1, 6, configured ? str.tostring(100.0 * credit / wingWidth, "#.##") + "%" : "—", text_color = color.white)
    table.cell(dashboard, 0, 7, "TP / SL close debit", text_color = color.white)
    table.cell(dashboard, 1, 7, configured ? str.tostring(tpDebit, "#.##") + " / " + str.tostring(slDebit, "#.##") : "—", text_color = color.white)
    table.cell(dashboard, 0, 8, "Max expiry loss / 1 lot", text_color = color.white)
    table.cell(dashboard, 1, 8, configured ? "$" + str.tostring(maxExpiryLoss * multiplier, "#.##") : "—", text_color = color.white)

putCross = ta.crossunder(close, shortPut)
callCross = ta.crossover(close, shortCall)
alertcondition(active and putCross, "SPX crosses short put", "SPX crossed below the IC short put. Check the actual four-leg close debit.")
alertcondition(active and callCross, "SPX crosses short call", "SPX crossed above the IC short call. Check the actual four-leg close debit.")
alertcondition(configured and barstate.isrealtime and timenow >= exitAt, "Mandatory exit time", "Iron Condor mandatory exit time reached. Check the position and broker quotes.")
````
