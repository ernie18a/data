# Currency Strength Meter [ForexCracked]

- url: https://www.tradingview.com/script/Bu6t04a5-Currency-Strength-Meter-ForexCracked/
- type: indicator
- pine_id: PUB;6cad96cd623549a79f639ff801d9ded3
- version: 1.0

## Description

🔵 OVERVIEW

A currency strength meter that ranks the eight major currencies against each other in real time, and then tells you the one thing you actually opened it for: which pair to trade right now.

It reads all 28 major crosses, so every currency is measured across all seven of its pairs, not just against the dollar.

🔵 WHAT MAKES THIS ONE DIFFERENT

Almost every strength meter measures each pair's percent change and averages it. That has a flaw nobody talks about: a 40 pip move in a quiet pair and a 40 pip move in a violent one are treated as the same event, when they are not remotely the same event.

This meter measures every move in ATR units instead. A currency only scores highly if it has moved far relative to how far that pair normally moves. Quiet pairs stop being drowned out by naturally volatile ones, and the ranking stops flattering whichever currency happens to be paired with the wildest counterpart that week.

🔵 WHAT IT SHOWS

• A live ranking of USD, EUR, GBP, JPY, CHF, AUD, NZD and CAD, strongest to weakest

• Each currency's strength in ATR units, so the numbers mean something rather than being an index

• Whether each currency is strengthening or weakening against its own recent reading, not just where it sits

• The Best Pair line: long the strongest currency, short the weakest

• The Spread: the distance between strongest and weakest

🔵 THE SPREAD (read this one first)

The spread is the gap between the strongest and the weakest currency. It answers a question most traders skip: is anything actually happening?

A wide spread means currencies are genuinely diverging and a strength-based trade has something to work with. A narrow spread means everything is drifting together, the ranking is mostly noise, and the best trade is usually no trade. Check the spread before you trust the ranking.

🔵 HOW TO USE

• Read the spread. If it is small, the ranking is not telling you much, so wait.

• Take the Best Pair as a starting point, not an entry. It tells you where the divergence is, not when to get in.

• Prefer a currency that is both highly ranked and still strengthening over one that is highly ranked and already fading, since the second one has usually made its move.

• Confirm the pair on the chart with your own entry method. A strength meter frames the trade. It does not time it.

• Lengthen the Lookback for swing trading and shorten it for intraday.

🔵 SETTINGS

• Strength Lookback: how many bars back the move is measured over (default 24)

• ATR Length: the volatility yardstick every move is divided by (default 14)

• Symbol Prefix: leave blank on most charts. If the pairs do not load, set it to your data provider, for example OANDA: or FX:

• Show Ranking Table: toggles the strongest-to-weakest table in the top right (default on)

• Plot Strength Lines: toggles the eight strength curves in the pane (default on)

⚠️ DISCLAIMER

Relative strength tells you which currencies are moving and which are not. It does not tell you when to enter, and strong currencies reverse. Results depend on market conditions, settings, and your own execution and risk management. Shared for educational and research purposes. Not financial advice.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ForexCracked

//@version=6
indicator("Currency Strength Meter [ForexCracked]", shorttitle="CSM [FXC]", overlay=false)

// =====================================================================
// Currency Strength Meter - original work.
// ---------------------------------------------------------------------
// Ranks the 8 majors across all 28 crosses, so every currency is measured
// against all 7 of its counterparts rather than only against the dollar.
//
// THE DIFFERENCE: strength is measured in ATR UNITS, not percent change.
// A conventional meter treats a 40 pip move in a quiet pair and a 40 pip
// move in a violent one as the same event. They are not. Dividing every
// move by that pair's own ATR makes the pairs comparable, so a currency
// only ranks highly when it has moved far RELATIVE TO HOW FAR IT NORMALLY
// MOVES.
//
// It also outputs the two things a strength meter is actually opened for:
//   Best Pair - long the strongest currency, short the weakest
//   Spread    - the gap between them, which says whether currencies are
//               genuinely diverging or just drifting together (and so
//               whether the ranking is worth acting on at all)
// =====================================================================

// ---------------- INPUTS ----------------
lookback = input.int(24, "Strength Lookback (bars)", minval = 2, tooltip = "How far back each move is measured.")
atrLen   = input.int(14, "ATR Length", minval = 2, tooltip = "The volatility yardstick every move is divided by.")
prefix   = input.string("", "Symbol Prefix", tooltip = "Leave blank on most charts. If the pairs do not load, set your provider, e.g. OANDA: or FX:")
showDash = input.bool(true, "Show Ranking Table", group = "Visuals")
showLines= input.bool(true, "Plot Strength Lines", group = "Visuals")

// ---------------- MOVE, MEASURED IN ATR UNITS ----------------
// This is the core of the script. Not percent change: distance travelled
// divided by that pair's own normal distance.
f_mv(simple string sym) =>
    v = request.security(sym, timeframe.period, ta.atr(atrLen) > 0 ? (close - close[lookback]) / ta.atr(atrLen) : 0.0)
    nz(v)

// The 7 USD pairs
eurusd = f_mv(prefix + "EURUSD")
gbpusd = f_mv(prefix + "GBPUSD")
audusd = f_mv(prefix + "AUDUSD")
nzdusd = f_mv(prefix + "NZDUSD")
usdjpy = f_mv(prefix + "USDJPY")
usdchf = f_mv(prefix + "USDCHF")
usdcad = f_mv(prefix + "USDCAD")
// EUR crosses
eurgbp = f_mv(prefix + "EURGBP")
eurjpy = f_mv(prefix + "EURJPY")
eurchf = f_mv(prefix + "EURCHF")
euraud = f_mv(prefix + "EURAUD")
eurnzd = f_mv(prefix + "EURNZD")
eurcad = f_mv(prefix + "EURCAD")
// GBP crosses
gbpjpy = f_mv(prefix + "GBPJPY")
gbpchf = f_mv(prefix + "GBPCHF")
gbpaud = f_mv(prefix + "GBPAUD")
gbpnzd = f_mv(prefix + "GBPNZD")
gbpcad = f_mv(prefix + "GBPCAD")
// AUD crosses
audjpy = f_mv(prefix + "AUDJPY")
audchf = f_mv(prefix + "AUDCHF")
audnzd = f_mv(prefix + "AUDNZD")
audcad = f_mv(prefix + "AUDCAD")
// NZD crosses
nzdjpy = f_mv(prefix + "NZDJPY")
nzdchf = f_mv(prefix + "NZDCHF")
nzdcad = f_mv(prefix + "NZDCAD")
// CAD crosses
cadjpy = f_mv(prefix + "CADJPY")
cadchf = f_mv(prefix + "CADCHF")
// CHF cross
chfjpy = f_mv(prefix + "CHFJPY")

// ---------------- STRENGTH: each currency across all 7 of its pairs ----------------
// A pair rising means the BASE strengthened and the QUOTE weakened, so the
// quote currency takes the move with a negative sign.
usdStr = (-eurusd - gbpusd - audusd - nzdusd + usdjpy + usdchf + usdcad) / 7.0
eurStr = ( eurusd + eurgbp + eurjpy + eurchf + euraud + eurnzd + eurcad) / 7.0
gbpStr = ( gbpusd - eurgbp + gbpjpy + gbpchf + gbpaud + gbpnzd + gbpcad) / 7.0
jpyStr = (-usdjpy - eurjpy - gbpjpy - audjpy - nzdjpy - cadjpy - chfjpy) / 7.0
chfStr = (-usdchf - eurchf - gbpchf - audchf - nzdchf - cadchf + chfjpy) / 7.0
audStr = ( audusd - euraud - gbpaud + audjpy + audchf + audnzd + audcad) / 7.0
nzdStr = ( nzdusd - eurnzd - gbpnzd - audnzd + nzdjpy + nzdchf + nzdcad) / 7.0
cadStr = (-usdcad - eurcad - gbpcad - audcad - nzdcad + cadjpy + cadchf) / 7.0

// ---------------- RANKING (fixed 8-element arrays, no bounds risk) ----------------
names = array.from("USD", "EUR", "GBP", "JPY", "CHF", "AUD", "NZD", "CAD")
vals  = array.from(usdStr, eurStr, gbpStr, jpyStr, chfStr, audStr, nzdStr, cadStr)
prevs = array.from(usdStr[lookback], eurStr[lookback], gbpStr[lookback], jpyStr[lookback], chfStr[lookback], audStr[lookback], nzdStr[lookback], cadStr[lookback])

idx = array.sort_indices(vals, order.descending)

strongIdx = array.get(idx, 0)
weakIdx   = array.get(idx, 7)
strongCur = array.get(names, strongIdx)
weakCur   = array.get(names, weakIdx)
strongVal = array.get(vals, strongIdx)
weakVal   = array.get(vals, weakIdx)
spread    = strongVal - weakVal

// ---------------- PLOTS ----------------
plot(showLines ? usdStr : na, "USD", color = #4caf50, linewidth = 2)
plot(showLines ? eurStr : na, "EUR", color = #2196f3, linewidth = 2)
plot(showLines ? gbpStr : na, "GBP", color = #e91e63, linewidth = 2)
plot(showLines ? jpyStr : na, "JPY", color = #ff9800, linewidth = 2)
plot(showLines ? chfStr : na, "CHF", color = #9c27b0, linewidth = 2)
plot(showLines ? audStr : na, "AUD", color = #00bcd4, linewidth = 2)
plot(showLines ? nzdStr : na, "NZD", color = #8bc34a, linewidth = 2)
plot(showLines ? cadStr : na, "CAD", color = #f44336, linewidth = 2)
hline(0, "Neutral", linestyle = hline.style_dotted, color = color.new(color.gray, 50))

// ---------------- RANKING TABLE ----------------
var table dash = table.new(position.top_right, 4, 11, bgcolor = color.new(#1a1a2e, 10), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast and showDash
    table.cell(dash, 0, 0, "#",        text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 1, 0, "Currency", text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 2, 0, "Strength", text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 3, 0, "Trend",    text_color = color.white, text_size = size.tiny, bgcolor = color.new(#0d47a1, 20))

    for i = 0 to 7
        slot   = array.get(idx, i)
        cur    = array.get(names, slot)
        val    = array.get(vals, slot)
        was    = array.get(prevs, slot)
        rising = val > was
        col    = val > 0 ? #26a69a : #ef5350
        table.cell(dash, 0, i + 1, str.tostring(i + 1), text_color = color.gray, text_size = size.tiny)
        table.cell(dash, 1, i + 1, cur, text_color = color.white, text_size = size.tiny)
        table.cell(dash, 2, i + 1, str.tostring(val, "#.00"), text_color = col, text_size = size.tiny)
        table.cell(dash, 3, i + 1, rising ? "up" : "down", text_color = rising ? #26a69a : #ef5350, text_size = size.tiny)

    table.cell(dash, 0, 9, "Best", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 9, "Long " + strongCur, text_color = #26a69a, text_size = size.tiny)
    table.cell(dash, 2, 9, "Short " + weakCur,  text_color = #ef5350, text_size = size.tiny)
    table.cell(dash, 3, 9, "", text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 10, "Spread", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 10, str.tostring(spread, "#.00"), text_color = color.white, text_size = size.tiny)
    table.cell(dash, 2, 10, spread > 1.5 ? "Diverging" : "Drifting", text_color = spread > 1.5 ? #26a69a : color.gray, text_size = size.tiny)
    table.cell(dash, 3, 10, "", text_color = color.white, text_size = size.tiny)

// ---------------- ALERTS ----------------
alertcondition(ta.change(spread) != 0 and spread > 2.0, title = "Strong Divergence", message = "Currency strength spread is wide on {{ticker}} {{interval}}")
````
