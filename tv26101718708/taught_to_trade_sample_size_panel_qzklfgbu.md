# Taught to Trade - Sample Size Panel

- url: https://www.tradingview.com/script/qZkLfGBu-Taught-to-Trade-Sample-Size-Panel/
- type: indicator
- pine_id: PUB;d296f07cb837428eb09ac1897739650a
- version: 1.0

## Description

You have 30 trades and 60 percent of them worked. Is that a real edge, or a coin flip that had a good month?

This panel answers that with arithmetic, not opinion. Enter the number of trades you have and the rate you observed. It returns the range the true rate plausibly sits in, how wide that range is, whether it can be told apart from 50 percent at all, and how many trades it would take to narrow it.

The usual answer is: far more trades than you have. That is the point.

WHAT IT SHOWS

- True rate is between: the Wilson score interval around your observed rate, at 90, 95 or 99 percent confidence. Wilson is used instead of the textbook normal interval because it behaves sensibly at small samples and at rates near 0 or 100 percent.
- Interval width: the gap between the two ends, in percentage points. Green under 10, amber 10 to 20, red above 20.
- Tells apart from 50%?: Yes only when the whole interval sits above or below 50 percent.
- Trades for +/-10pp, +/-5pp, +/-2pp: roughly how many trades it takes for the interval to shrink to that half-width at your observed rate.
- This chart could give: how many non-overlapping trades this chart's history could have produced at your holding period. If it is fewer than the trades you need, no amount of backtesting on this chart can settle the question.

A WORKED EXAMPLE (the defaults)

30 trades at 60 percent, 95 percent confidence: the true rate is plausibly anywhere from about 42 to 75 percent. That range includes 50. Narrowing it to plus or minus 5 points takes about 369 trades.

HOW TO USE IT

Take the trade count and the rate from your own trade list or a strategy report, type them in, and read the table before you read anything else about the result. It draws nothing on the chart and has no alerts: it is a calculator, and there is no market state to alert on.

WHERE IT FAILS

- It assumes every trade is an independent draw with the same underlying rate. Real trades cluster: regimes change, and trades taken close together share the same conditions. Both make the true uncertainty wider than this panel shows.
- It is about a rate only. A 60 percent rate says nothing about the size of wins and losses, costs, or drawdown; a strategy can be right most of the time and still lose money.
- The trades-needed rows use the normal approximation, which is rough at very small samples and at rates near 0 or 100 percent.
- If you tried many parameter sets and kept the best one, the rate you enter is already inflated by selection. No interval corrects for that.
- "This chart could give" is a rough count: history length divided by holding period, ignoring gaps and the time between trades.

This is an educational tool. It does not generate signals, and nothing it shows is a recommendation to buy or sell anything. Past results, including your own, do not guarantee future ones.

## Source Code

````pine
//@version=6

// Taught to Trade - Sample Size Panel
//
// You enter the number of trades you have and the rate you observed. It returns the
// confidence interval around that rate, how wide it is, whether it can be told apart
// from a coin flip, and how many trades it would take to narrow it.
//
// The usual answer is "far more than you have". That is the point.
//
// All maths is scalar arithmetic on inputs plus bar_index. Nothing repaints,
// nothing reads the future, and nothing here is a signal.
indicator("Taught to Trade - Sample Size Panel", shorttitle = "TT SAMPLE", overlay = true)

// ─────────────────────────────── Inputs ───────────────────────────────
grpR = "Your result"
nTrades = input.int(30,   "Number of trades", minval = 1, group = grpR,
     tooltip = "The real count from your trade list, not an estimate.")
winPct  = input.float(60.0, "Observed win rate (%)", minval = 0.0, maxval = 100.0, step = 0.5, group = grpR)
confIn  = input.string("95%", "Confidence level", options = ["90%", "95%", "99%"], group = grpR)

grpC = "Chart context"
holdBars = input.int(20, "Bars held per trade", minval = 1, group = grpC,
     tooltip = "Used only to estimate how many trades this chart's history could have produced.")

grpT = "Table"
posIn = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT)
szIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

// ─────────────────────────────── Wilson score interval ───────────────────────────────
z = confIn == "90%" ? 1.6449 : confIn == "99%" ? 2.5758 : 1.9600
p = winPct / 100.0
n = math.max(nTrades, 1)

denom  = 1.0 + z * z / n
centre = (p + z * z / (2.0 * n)) / denom
margin = (z / denom) * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))

lo = math.max(0.0, centre - margin)
hi = math.min(1.0, centre + margin)
widthPP = (hi - lo) * 100.0

// Can the observed rate be told apart from a coin flip at this confidence?
beatsCoin = lo > 0.5
worseCoin = hi < 0.5
verdict   = beatsCoin ? "Yes, above 50%" : worseCoin ? "Yes, below 50%" : "No"

// Sample size needed for a target half-width, using the normal approximation.
f_need(float halfWidthPP) =>
    e = halfWidthPP / 100.0
    e > 0 ? math.ceil(z * z * p * (1.0 - p) / (e * e)) : na

need10 = f_need(10.0)
need5  = f_need(5.0)
need2  = f_need(2.0)

// Chart context
barsHere     = bar_index + 1
tradesOnChart = math.floor(barsHere / math.max(holdBars, 1))

f_pc(float v01) => str.tostring(v01 * 100.0, "#.#") + "%"

// ─────────────────────────────── Table ───────────────────────────────
tblPos = posIn == "Top left" ? position.top_left : posIn == "Bottom right" ? position.bottom_right : posIn == "Bottom left" ? position.bottom_left : position.top_right
tblSz  = szIn == "Tiny" ? size.tiny : szIn == "Normal" ? size.normal : size.small

bgCol  = color.new(#0E1526, 10)
txtCol = color.new(#E6EAF2, 0)
hdrCol = color.new(#2F6FED, 0)
badCol = color.new(#B3261E, 25)
okCol  = color.new(#2E7D32, 25)
warnCol = color.new(#B26A00, 25)

var table t = table.new(tblPos, 2, 10, border_width = 1, border_color = color.new(#2F6FED, 70))

f_l(int r, string s, color bc) => table.cell(t, 0, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_left, bgcolor = bc)
f_v(int r, string s, color bc) => table.cell(t, 1, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_right, bgcolor = bc)

if barstate.islast
    table.cell(t, 0, 0, "SAMPLE SIZE", text_color = color.white, text_size = tblSz, text_halign = text.align_left, bgcolor = hdrCol)
    table.cell(t, 1, 0, confIn + " confidence", text_color = color.white, text_size = tblSz, text_halign = text.align_right, bgcolor = hdrCol)

    f_l(1, "Trades", bgCol)
    f_v(1, str.tostring(n), n < 30 ? badCol : n < 100 ? warnCol : okCol)

    f_l(2, "Observed rate", bgCol)
    f_v(2, str.tostring(winPct, "#.#") + "%", bgCol)

    f_l(3, "True rate is between", bgCol)
    f_v(3, f_pc(lo) + "  and  " + f_pc(hi), bgCol)

    f_l(4, "Interval width", bgCol)
    f_v(4, str.tostring(widthPP, "#.#") + " pp", widthPP > 20.0 ? badCol : widthPP > 10.0 ? warnCol : okCol)

    f_l(5, "Tells apart from 50%?", bgCol)
    f_v(5, verdict, beatsCoin or worseCoin ? okCol : badCol)

    f_l(6, "Trades for +/-10pp", bgCol)
    f_v(6, na(need10) ? "-" : str.tostring(need10), bgCol)

    f_l(7, "Trades for +/-5pp", bgCol)
    f_v(7, na(need5) ? "-" : str.tostring(need5), bgCol)

    f_l(8, "Trades for +/-2pp", bgCol)
    f_v(8, na(need2) ? "-" : str.tostring(need2), bgCol)

    f_l(9, "This chart could give", bgCol)
    f_v(9, str.tostring(tradesOnChart) + " at " + str.tostring(holdBars) + " bars", tradesOnChart < nTrades ? warnCol : bgCol)

// ─────────────────────────────── No alerts, deliberately ───────────────────────────────
// This is a calculator. It has no market state to alert on, so it ships with no
// alert conditions rather than a placeholder that can never fire.
````
