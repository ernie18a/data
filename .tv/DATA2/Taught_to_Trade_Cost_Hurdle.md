<!-- tradingview-pine-id: PUB;d52b2e08e9da4b7e9a9b6273b12a0c1f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Taught to Trade - Cost Hurdle

Source: https://www.tradingview.com/script/yfw8wzma-Taught-to-Trade-Cost-Hurdle/

## Description

🔵 OVERVIEW

Costs are usually treated as a fee subtracted at the end. They are better understood as a hurdle: a distance price must travel before a trade is worth anything at all, in either direction.

This measures how tall that hurdle is on the chart you are looking at — as a percentage, in price, and in ATR — and then reports how often this instrument has actually produced a move that size over the sample window, for four different holding periods.

Everything is computed from closed bars, looking backward only. Nothing repaints.

🔵 HOW THE HURDLE IS BUILT

Commission per side and slippage per side are both doubled, because a round trip pays each of them twice. An optional spread is added once. That total is the hurdle.

It is then expressed three ways. As a percentage, which is comparable across instruments. In price, which is what you actually see on the chart. And in ATR(14), which is the one worth paying attention to — it tells you what fraction of a typical bar's movement is consumed before you are level.

🔵 HOW TO READ THE TABLE

Each row is a holding period measured in bars. Bars is how many observations the window produced for that period.

Cleared is the share of those observations where price moved further than the hurdle, in absolute terms. It turns red below 50 percent, because at that point most of the moves this instrument produces over that holding period are smaller than what it costs you to participate in them.

Median move is the middle-sized absolute move over that period. Compare it directly with the hurdle. If the hurdle is close to the median, the typical trade is a coin flip against a fee.

🔵 WHAT THIS DOES NOT MEAN

Clearing the hurdle is not profit. It only means the move was big enough to have been worth trading — the direction still has to be right, and this measures absolute distance, so a move that cleared the hurdle downward counts exactly the same as one that cleared it upward.

A table that is entirely green does not mean a strategy will work here. It means costs are not the thing stopping it. That is a much smaller claim, and it is the only one this tool is entitled to make.

🔵 SETTINGS

Commission and slippage per side, plus an optional spread. Four holding periods, defaulting to 1, 5, 10 and 20 bars. Sample window length. Table position and text size.

Two alert conditions fire when a round trip costs more than half an ATR, and more than a full ATR. Neither fires on its own; you arm them in the alerts dialog. This script does not send buy or sell signals and never will.

🔵 WHERE IT FAILS

The cost inputs are yours, and the tool cannot verify them. Enter zero slippage and you will get a flattering table that means nothing. Zero slippage is the most common dishonest backtest setting there is, and this will not catch it for you.

It uses a single fixed cost figure. Real slippage is worse in fast markets and worse on larger size, which is exactly when it matters most. A constant understates the tail.

Absolute moves ignore direction entirely. Half of every number in the Cleared column came from moves that would have gone against you.

Close-to-close movement is not the path. A move that ends 1% away may have travelled 3% getting there and taken out a stop on the way. This says nothing about the route.

The median is a poor summary of a fat-tailed distribution. A large share of real trading outcomes live in the tails this column deliberately ignores.

The holding periods are fixed bar counts, not your actual holding times, and a strategy that exits on a condition rather than a bar count will not match any row here.

Percentage-based costs suit crypto and equities. Futures and forex price commissions per contract or per lot, and converting those into a percentage of notional is an approximation that gets worse at small position sizes.

Open source, so you can read every calculation instead of taking any of this on trust.

Educational tool only, not investment advice. It does not predict anything and does not generate signals. Trading involves substantial risk of loss.

---

## Source Code

````pine
//@version=6
// Taught to Trade - Cost Hurdle
// Costs are not a fee taken off the end. They are a hurdle height you must clear
// before a trade is worth anything. This measures how tall that hurdle is here,
// and how often this instrument has actually produced a move that size.
// No buy/sell signals. Alerts are yours to configure.
indicator("Taught to Trade - Cost Hurdle", shorttitle = "TT HURDLE", overlay = true, max_bars_back = 1000)

grpC = "Your real costs"
commPct = input.float(0.04, "Commission per side (%)", minval = 0.0, step = 0.01, group = grpC)
slipPct = input.float(0.02, "Slippage per side (%)", minval = 0.0, step = 0.01, group = grpC)
spreadPct = input.float(0.0, "Spread paid once (%)", minval = 0.0, step = 0.01, group = grpC, tooltip = "Leave at zero if your commission figure already includes the spread.")

grpH = "Holding periods"
h1 = input.int(1, "Hold A (bars)", minval = 1, group = grpH)
h2 = input.int(5, "Hold B (bars)", minval = 1, group = grpH)
h3 = input.int(10, "Hold C (bars)", minval = 1, group = grpH)
h4 = input.int(20, "Hold D (bars)", minval = 1, group = grpH)
lookback = input.int(500, "Sample window (bars)", minval = 60, maxval = 1000, group = grpH)

grpT = "Table"
posIn = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT)
szIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

hurdlePct = (commPct + slipPct) * 2.0 + spreadPct
atr    = ta.atr(14)
atrPct = close > 0 ? atr / close * 100.0 : na
hurdleInAtr = nz(atrPct, 0) > 0 ? hurdlePct / atrPct : na
hurdleInPrice = close * hurdlePct / 100.0

f_move(int n) => close[n] > 0 ? math.abs(close - close[n]) / close[n] * 100.0 : na

m1 = f_move(h1)
m2 = f_move(h2)
m3 = f_move(h3)
m4 = f_move(h4)

c1 = math.sum(nz(m1, -1) > hurdlePct ? 1 : 0, lookback)
c2 = math.sum(nz(m2, -1) > hurdlePct ? 1 : 0, lookback)
c3 = math.sum(nz(m3, -1) > hurdlePct ? 1 : 0, lookback)
c4 = math.sum(nz(m4, -1) > hurdlePct ? 1 : 0, lookback)

v1 = math.sum(na(m1) ? 0 : 1, lookback)
v2 = math.sum(na(m2) ? 0 : 1, lookback)
v3 = math.sum(na(m3) ? 0 : 1, lookback)
v4 = math.sum(na(m4) ? 0 : 1, lookback)

med1 = ta.percentile_linear_interpolation(nz(m1, 0), lookback, 50)
med2 = ta.percentile_linear_interpolation(nz(m2, 0), lookback, 50)
med3 = ta.percentile_linear_interpolation(nz(m3, 0), lookback, 50)
med4 = ta.percentile_linear_interpolation(nz(m4, 0), lookback, 50)

f_safe(float num, float den) => den > 0 ? num / den : na
f_pc(float v)  => na(v) ? "-" : str.tostring(v, "#") + "%"
f_pc2(float v) => na(v) ? "-" : str.tostring(v, "#.###") + "%"

s1 = f_safe(c1 * 100.0, v1)
s2 = f_safe(c2 * 100.0, v2)
s3 = f_safe(c3 * 100.0, v3)
s4 = f_safe(c4 * 100.0, v4)

tblPos = posIn == "Top left" ? position.top_left : posIn == "Bottom right" ? position.bottom_right : posIn == "Bottom left" ? position.bottom_left : position.top_right
tblSz  = szIn == "Tiny" ? size.tiny : szIn == "Normal" ? size.normal : size.small

bgCol  = color.new(#0E1526, 10)
txtCol = color.new(#E6EAF2, 0)
hdrCol = color.new(#2F6FED, 0)
badCol = color.new(#B3261E, 25)
okCol  = color.new(#2E7D32, 25)

f_flag(float share) => na(share) ? bgCol : share < 50.0 ? badCol : okCol

var table t = table.new(tblPos, 4, 8, border_width = 1, border_color = color.new(#2F6FED, 70))

f_h(int c, string s) => table.cell(t, c, 0, s, text_color = color.white, text_size = tblSz, bgcolor = hdrCol)
f_r(int c, int r, string s, color bc) => table.cell(t, c, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_right, bgcolor = bc)
f_l(int c, int r, string s, color bc) => table.cell(t, c, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_left, bgcolor = bc)

if barstate.islast
    f_h(0, "HOLD")
    f_h(1, "Bars")
    f_h(2, "Cleared")
    f_h(3, "Median move")
    f_l(0, 1, str.tostring(h1) + " bars", bgCol)
    f_r(1, 1, str.tostring(v1), bgCol)
    f_r(2, 1, f_pc(s1), f_flag(s1))
    f_r(3, 1, f_pc2(med1), bgCol)
    f_l(0, 2, str.tostring(h2) + " bars", bgCol)
    f_r(1, 2, str.tostring(v2), bgCol)
    f_r(2, 2, f_pc(s2), f_flag(s2))
    f_r(3, 2, f_pc2(med2), bgCol)
    f_l(0, 3, str.tostring(h3) + " bars", bgCol)
    f_r(1, 3, str.tostring(v3), bgCol)
    f_r(2, 3, f_pc(s3), f_flag(s3))
    f_r(3, 3, f_pc2(med3), bgCol)
    f_l(0, 4, str.tostring(h4) + " bars", bgCol)
    f_r(1, 4, str.tostring(v4), bgCol)
    f_r(2, 4, f_pc(s4), f_flag(s4))
    f_r(3, 4, f_pc2(med4), bgCol)
    f_l(0, 5, "Hurdle", hdrCol)
    f_l(1, 5, str.tostring(hurdlePct, "#.###") + "% round trip", bgCol)
    f_l(0, 6, "In price", bgCol)
    f_l(1, 6, str.tostring(hurdleInPrice, format.mintick), bgCol)
    f_l(0, 7, "In ATR(14)", bgCol)
    f_l(1, 7, na(hurdleInAtr) ? "-" : str.tostring(hurdleInAtr, "#.##") + " x ATR", bgCol)

alertcondition(not na(hurdleInAtr) and hurdleInAtr > 1.0, title = "Round-trip cost now exceeds one ATR", message = "Cost Hurdle: a round trip on this chart now costs more than one ATR of movement.")
alertcondition(not na(hurdleInAtr) and hurdleInAtr > 0.5 and hurdleInAtr <= 1.0, title = "Round-trip cost now exceeds half an ATR", message = "Cost Hurdle: a round trip on this chart now costs more than half an ATR of movement.")
````
