# OxPhoros Gann Continuation (Auto Same-Month, 5yr)

- url: https://www.tradingview.com/script/mVP83RfH-OxPhoros-Gann-Continuation-Auto-Same-Month-5yr/
- type: indicator
- pine_id: PUB;46629a3fc0a04871adacf11a48884364
- version: 1.0

## Description

Classic W.D. Gann continuation charting: instead of rolling to the nearest contract like standard continuous feeds (ZW1!), this indicator splices the same delivery month across years — preserving each month's seasonal character, the way Gann originally charted futures.
How it works
Open any specific futures contract (e.g. CBOT:ZWU2026) and add the indicator. It automatically:

Parses the host symbol into root, month letter, and year (ZWU2026 → ZW / U / 2026)
Builds the same-month contracts for the 5 prior years (ZWU2021 … ZWU2026)
Splices them chronologically, switching contracts on the 14th of the delivery month (≈expiry)
Plots the result as candles on the host chart
Marks every contract transition with a dashed vertical line and a label showing the incoming contract

No inputs, no configuration — the contract set derives entirely from the symbol you open. Works on any futures product with standard month codes (F G H J K M N Q U V X Z).
Notes & limitations

Splices are unadjusted (Gann's original method): price gaps at transitions are real and intentional.
History is limited by the host contract's own listing date — an indicator can only paint on bars the host chart has. For deeper history, host on a longer-lived contract.
Expired-contract data requires a TradingView plan that includes historical futures for the exchange.
Cutoff on the 14th of the delivery month is an approximation of expiry; exact rules vary by product (cosmetic on daily/weekly charts).
Hide the host symbol's own candles (chart settings) so only the spliced series is visible.
Host must be a specific contract; continuous symbols (ZW1!) show an error label.

Not financial advice. Charting/visualization tool only — no signals, no orders.

## Source Code

````pine
//@version=6
indicator("OxPhoros Gann Continuation (Auto Same-Month, 5yr)", overlay=true)

// ── Parse host symbol: e.g. ZWH2026 → root=ZW, month=H, year=2026 ──
tick   = syminfo.ticker
tlen   = str.length(tick)
yrStr  = str.substring(tick, tlen - 4)
mLet   = str.substring(tick, tlen - 5, tlen - 4)
root   = str.substring(tick, 0, tlen - 5)
Y      = int(str.tonumber(yrStr))
valid  = not na(Y) and str.contains("FGHJKMNQUVXZ", mLet)

// ── Month letter → month number ──
mNum = mLet == "F" ? 1 : mLet == "G" ? 2 : mLet == "H" ? 3 : mLet == "J" ? 4 :
       mLet == "K" ? 5 : mLet == "M" ? 6 : mLet == "N" ? 7 : mLet == "Q" ? 8 :
       mLet == "U" ? 9 : mLet == "V" ? 10 : mLet == "X" ? 11 : 12

// ── Build same-month symbols for host year and 5 prior ──
mkSym(yr) => syminfo.prefix + ":" + root + mLet + str.tostring(yr)
s0 = mkSym(Y - 5), s1 = mkSym(Y - 4), s2 = mkSym(Y - 3)
s3 = mkSym(Y - 2), s4 = mkSym(Y - 1), s5 = mkSym(Y)

// ── Pull OHLC ──
[o0, h0, l0, c0] = request.security(s0, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
[o1, h1, l1, c1] = request.security(s1, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
[o2, h2, l2, c2] = request.security(s2, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
[o3, h3, l3, c3] = request.security(s3, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
[o4, h4, l4, c4] = request.security(s4, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)
[o5, h5, l5, c5] = request.security(s5, timeframe.period, [open, high, low, close], ignore_invalid_symbol=true)

// ── Auto cutoffs: 14th of delivery month per year ──
cut(yr) => timestamp(yr, mNum, 14, 0, 0)

int active = time <= cut(Y - 5) ? 0 : time <= cut(Y - 4) ? 1 : time <= cut(Y - 3) ? 2 :
             time <= cut(Y - 2) ? 3 : time <= cut(Y - 1) ? 4 : 5

o = active == 0 ? o0 : active == 1 ? o1 : active == 2 ? o2 : active == 3 ? o3 : active == 4 ? o4 : o5
h = active == 0 ? h0 : active == 1 ? h1 : active == 2 ? h2 : active == 3 ? h3 : active == 4 ? h4 : h5
l = active == 0 ? l0 : active == 1 ? l1 : active == 2 ? l2 : active == 3 ? l3 : active == 4 ? l4 : l5
c = active == 0 ? c0 : active == 1 ? c1 : active == 2 ? c2 : active == 3 ? c3 : active == 4 ? c4 : c5

// ── Plot ──
plotcandle(valid ? o : na, valid ? h : na, valid ? l : na, valid ? c : na, color = c >= o ? color.teal : color.red, wickcolor = color.gray, bordercolor = c >= o ? color.teal : color.red, title = "Spliced Contract")

// ── Transition markers ──
bool switched = valid and active != active[1] and not na(active[1])
if switched
    string newSym = active == 1 ? s1 : active == 2 ? s2 : active == 3 ? s3 : active == 4 ? s4 : s5
    line.new(bar_index, l, bar_index, h, extend=extend.both, color=color.orange, style=line.style_dashed, width=1)
    label.new(bar_index, na, "→ " + newSym, yloc=yloc.abovebar, style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
bgcolor(switched ? color.new(color.orange, 80) : na)

// ── Error state for non-contract hosts (ZW1! etc.) ──
if barstate.islast and not valid
    label.new(bar_index, close, "Host must be a specific contract (e.g. ZWH2026)", style=label.style_label_left, color=color.red, textcolor=color.white)
````
