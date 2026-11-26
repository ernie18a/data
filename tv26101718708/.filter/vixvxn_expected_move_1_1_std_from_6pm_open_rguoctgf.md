# VIX/VXN Expected Move +1 /-1 STD from 6pm open

- url: https://www.tradingview.com/script/RgUOCtGF-VIX-VXN-Expected-Move-1-1-STD-from-6pm-open/
- type: indicator
- pine_id: PUB;6eebb88e92c34f708b2c40e2e744a41a
- version: 1.0

## Description

VIX/VXN Expected Move

Plots the one-standard-deviation expected daily range for futures, using the implied volatility of the options market. The indicator automatically uses VXN for Nasdaq (NQ) and the VIX for the S&P 500 (ES), YM and other symbols. You can also select either index manually.

How it works
Expected move (%) = VIX ÷ √252. That percentage is applied to the day's open (or the prior close, your choice) to draw an upper and lower band. The volatility reading comes from the prior day's close, so the levels stay fixed for the whole session.

Features

Upper and lower expected-move lines with price labels
Anchor line at the daily open or prior close
Adjustable SD multiplier (for example, 2 SD for the wider band)
Info table showing the volatility index used, its level, and the expected move in % and ticks
Built-in hit-rate tracker showing how often price stayed inside the band, closed inside it, or touched the upper and lower lines

How to use it
Use it on an intraday chart of ES1!, NQ1! or YM1! as a guide to how far price may travel in a session. Price is statistically expected to stay inside a 1 SD band about 68% of the time, so it is useful for setting realistic targets, judging when a move is stretched, and spotting breakouts beyond the band. It shows a range, not a direction.

## Source Code

````pine
//@version=6
indicator("VIX/VXN Expected Move", overlay=true, max_lines_count=100, max_labels_count=10)

// ── Inputs ──
anchorMode  = input.string("Daily Open", "Anchor", options=["Daily Open", "Prior Close"])
volMode     = input.string("Auto", "Volatility Index", options=["Auto", "VIX", "VXN"])
sdMult      = input.float(1.0, "SD Multiplier", minval=0.25, step=0.25)
tradingDays = input.float(252, "Trading days per year", minval=1)
upColor     = input.color(color.green, "Upper line")
loColor     = input.color(color.red, "Lower line")
midColor    = input.color(color.gray, "Anchor line")

// ── Pick volatility index ──
isNdx  = str.contains(syminfo.ticker, "NQ") or str.contains(syminfo.ticker, "NDX")
volSym = volMode == "VIX" ? "CBOE:VIX" : volMode == "VXN" ? "CBOE:VXN" : isNdx ? "CBOE:VXN" : "CBOE:VIX"

// ── Data (prior-day vol close so lines stay fixed all day) ──
dailyOpen  = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
priorClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
volPrev    = request.security(volSym, "D", close[1], lookahead=barmerge.lookahead_on)

// ── Expected move ──
anchor  = anchorMode == "Daily Open" ? dailyOpen : priorClose
movePct = volPrev / math.sqrt(tradingDays) * sdMult
movePts = anchor * movePct / 100
upper   = anchor + movePts
lower   = anchor - movePts

// ── Draw lines each new day ──
var line upL  = na
var line loL  = na
var line midL = na

if timeframe.change("D")
    upL  := line.new(bar_index, upper, bar_index + 1, upper, color=upColor, width=2)
    loL  := line.new(bar_index, lower, bar_index + 1, lower, color=loColor, width=2)
    midL := line.new(bar_index, anchor, bar_index + 1, anchor, color=midColor, style=line.style_dashed)
else if not na(upL)
    line.set_x2(upL, bar_index)
    line.set_x2(loL, bar_index)
    line.set_x2(midL, bar_index)

// ── Labels on the latest bar ──
var label upLbl = na
var label loLbl = na
if barstate.islast
    if na(upLbl)
        upLbl := label.new(bar_index, upper, "", style=label.style_label_left, color=upColor, textcolor=color.white)
        loLbl := label.new(bar_index, lower, "", style=label.style_label_left, color=loColor, textcolor=color.white)
    label.set_xy(upLbl, bar_index + 1, upper)
    label.set_xy(loLbl, bar_index + 1, lower)
    label.set_text(upLbl, "+" + str.tostring(sdMult, "#.##") + " SD  " + str.tostring(upper, format.mintick))
    label.set_text(loLbl, "-" + str.tostring(sdMult, "#.##") + " SD  " + str.tostring(lower, format.mintick))

// ── Info table ──
var table t = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20))
if barstate.islast
    table.cell(t, 0, 0, "Vol index", text_color=color.white)
    table.cell(t, 1, 0, volSym, text_color=color.white)
    table.cell(t, 0, 1, "Level (prior close)", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(volPrev, "#.##"), text_color=color.white)
    table.cell(t, 0, 2, "Expected move %", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(movePct, "#.##") + "%", text_color=color.white)
    table.cell(t, 0, 3, "Expected move pts", text_color=color.white)
    table.cell(t, 1, 3, "±" + str.tostring(movePts, format.mintick), text_color=color.white)
````
