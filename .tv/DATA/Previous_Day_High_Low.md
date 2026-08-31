<!-- tradingview-pine-id: PUB;f90b5b58afdb4597a941f9a57d0eb142 -->
<!-- tradingviewscripts-format: 1 -->
# Previous Day High / Low

Source: https://www.tradingview.com/script/rOhzH5GP-Previous-Day-High-Low/

## Description

It marks three price levels from yesterday's session and holds them on the chart as horizontal reference lines.

**What it plots**

PDH and PDL are the previous day's high and low, drawn as solid light-blue lines at width 3. PDM sits halfway between them, dotted and light yellow. All three extend infinitely in both directions, so they're visible no matter where you scroll.

**How the values are pulled**

A single `request.security` call fetches `high[1]` and `low[1]` off the daily series. Because it references the bar *before* the current daily bar, the values are locked in from a session that has already closed. `lookahead_on` is safe in that context and nothing repaints intraday. Mid is just the average of the two.

There's an RTH toggle. Left off, you get the full Globex range on futures. Switched on, `ticker.modify` swaps to the regular session so the levels come from 8:30–3:00 CT only.

**How it draws**

Rather than creating new line objects each session, it makes six objects once (three lines, three labels) and repositions them on the last bar. That's why it runs on any timeframe and why the lines are continuous instead of segmented per day. Labels sit three bars right of the last candle showing the level name and price.

**Alerts**

Two conditions fire on a close crossing PDH or PDL, in either direction.

**Practical use for MNQ**

These are the levels a lot of order flow references at the open. Yesterday's high and low act as the obvious liquidity pools, and the midpoint often works as a mean-reversion magnet when the session opens inside the prior range. Given your 9/21 EMA stack, the useful reads are when a level lines up with the fast EMAs, and when price opens outside the prior range entirely, since that changes whether PDH/PDL are targets or support.

---

## Source Code

````pine
//@version=6
// Previous Day High / Low / Mid — single continuous levels, works on any chart timeframe.

indicator("Previous Day High / Low", shorttitle = "PDH / PDL", overlay = true)

// ─── Inputs ──────────────────────────────────────────────────────────────────
hlCol    = input.color(#7FDBFF, "High / Low color")
hlWid    = input.int(3, "High / Low width", minval = 1, maxval = 5)
midCol   = input.color(#FFF2A6, "Mid color")
midWid   = input.int(1, "Mid width", minval = 1, maxval = 5)
showMid  = input.bool(true,  "Show midpoint")
showLbls = input.bool(true,  "Show labels")
useRTH   = input.bool(false, "Use regular session only",
     tooltip = "On for futures if you want the RTH high/low instead of the full session.")

// ─── Previous day values ─────────────────────────────────────────────────────
src = useRTH ? ticker.modify(syminfo.tickerid, session = session.regular) : syminfo.tickerid

[pdh, pdl] = request.security(src, "1D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
pdm = math.avg(pdh, pdl)

// ─── One line object per level, extended both directions ─────────────────────
mkLine(color c, int w, string st) =>
    line.new(bar_index, close, bar_index + 1, close,
         extend = extend.both, color = c, style = st, width = w)

mkLabel(color c) =>
    label.new(bar_index, close, "", style = label.style_none,
         textcolor = c, size = size.small)

var line  lnH = mkLine(hlCol,  hlWid,  line.style_solid)
var line  lnL = mkLine(hlCol,  hlWid,  line.style_solid)
var line  lnM = mkLine(midCol, midWid, line.style_dotted)
var label lbH = mkLabel(hlCol)
var label lbL = mkLabel(hlCol)
var label lbM = mkLabel(midCol)

place(line ln, label lb, float y, string tag, color c, bool on) =>
    line.set_xy1(ln, bar_index, y)
    line.set_xy2(ln, bar_index + 1, y)
    line.set_color(ln, on ? c : color.new(color.white, 100))
    label.set_xy(lb, bar_index + 3, y)
    label.set_text(lb, on and showLbls ? tag + "  " + str.tostring(y, format.mintick) : "")

if barstate.islast and not na(pdh)
    place(lnH, lbH, pdh, "PDH", hlCol,  true)
    place(lnL, lbL, pdl, "PDL", hlCol,  true)
    place(lnM, lbM, pdm, "PDM", midCol, showMid)

// ─── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(ta.cross(close, pdh), "Cross PDH", "Price crossed previous day high")
alertcondition(ta.cross(close, pdl), "Cross PDL", "Price crossed previous day low")
````
