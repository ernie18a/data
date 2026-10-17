# Intraday Momentum Panel

- url: https://www.tradingview.com/script/vEkxgS2b-Intraday-Momentum-Panel/
- type: indicator
- pine_id: PUB;e29c64f48aba4932b66c121d40080b2a
- version: 1.0

## Description

Intraday Momentum Panel - a fixed info panel that tracks intraday momentum relative to the premarket high and the regular-session open.

Shows five live metrics (updating tick-by-tick on the last bar):

- PMH → Open — premarket high to session open (gap into the open)
- Open → Now — current % change since the 09:30 open
- Peak → Now — pullback % from the session high
- Open → Peak — max gain since open
- MktCap — shares outstanding × price (when available)

Current trading day only, anchored to the chart corner so it never scrolls away.

## Source Code

````pine
//@version=6
indicator("Intraday Momentum Panel", overlay = true)

// ===== Inputs =====
tz       = input.string("America/New_York", "Timezone")
pmSess   = input.session("0400-0930", "Premarket")
rthSess  = input.session("0930-1600", "Regular session (RTH)")
hudPos   = input.string(position.bottom_right, "HUD position", options = [position.bottom_right, position.bottom_left, position.top_right, position.top_left])
fontSz   = input.int(16, "HUD font size", minval = 6, maxval = 40)

// ===== Session flags =====
inPM   = not na(time(timeframe.period, pmSess,  tz))
inRTH  = not na(time(timeframe.period, rthSess, tz))

var bool inPM_p  = false
var bool inRTH_p = false
newPM  = inPM  and not inPM_p
newRTH = inRTH and not inRTH_p
inPM_p  := inPM
inRTH_p := inRTH

// ===== State =====
var float pmHigh  = na
var float rthOpen = na
var float rthHigh = na

// Premarket high (resets each PM, persists into RTH)
if newPM
    pmHigh := high
else if inPM
    pmHigh := math.max(nz(pmHigh, high), high)

// RTH open + running session high
if newRTH
    rthOpen := open
    rthHigh := high
else if inRTH
    rthHigh := na(rthHigh) ? high : math.max(rthHigh, high)

// ===== Metrics =====
chgPct  = not na(rthOpen) ? (close   - rthOpen) / rthOpen * 100.0 : na
distHi  = not na(rthHigh) ? (close   - rthHigh) / rthHigh * 100.0 : na
peakPct = not na(rthOpen) ? (rthHigh - rthOpen) / rthOpen * 100.0 : na
pm2open = (not na(pmHigh) and not na(rthOpen)) ? (rthOpen - pmHigh) / pmHigh * 100.0 : na

// Market cap (shares outstanding × current price)
shares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
mktCap = na(shares) ? na : shares * close

// ===== Formatters =====
f_fmt(x) => na(x) ? "—" : str.format("{0,number,#.##}%", x)
f_col(x) => na(x) ? color.gray : (x >= 0 ? #00E676 : #FF1744)
f_cap(v) => na(v) ? "—" : v >= 1e9 ? str.format("${0,number,#.##}B", v / 1e9) : v >= 1e6 ? str.format("${0,number,#.##}M", v / 1e6) : str.format("${0,number,#.##}K", v / 1e3)

// ===== Fixed HUD (always visible, never scrolls) =====
var table hud = table.new(hudPos, 2, 5, bgcolor = color.new(color.black, 0), frame_color = color.white, frame_width = 2, border_color = color.new(color.gray, 30), border_width = 1)

if barstate.islast
    table.cell(hud, 0, 0, "PMH → Open",  text_color = color.white, text_size = fontSz, text_halign = text.align_left)
    table.cell(hud, 1, 0, f_fmt(pm2open), text_color = f_col(pm2open), text_size = fontSz)
    table.cell(hud, 0, 1, "Open → Now",  text_color = color.white, text_size = fontSz, text_halign = text.align_left)
    table.cell(hud, 1, 1, f_fmt(chgPct),  text_color = f_col(chgPct),  text_size = fontSz)
    table.cell(hud, 0, 2, "Peak → Now",  text_color = color.white, text_size = fontSz, text_halign = text.align_left)
    table.cell(hud, 1, 2, f_fmt(distHi),  text_color = f_col(distHi),  text_size = fontSz)
    table.cell(hud, 0, 3, "Open → Peak", text_color = color.white, text_size = fontSz, text_halign = text.align_left)
    table.cell(hud, 1, 3, f_fmt(peakPct), text_color = f_col(peakPct), text_size = fontSz)
    table.cell(hud, 0, 4, "MktCap",      text_color = color.white, text_size = fontSz, text_halign = text.align_left)
    table.cell(hud, 1, 4, f_cap(mktCap),  text_color = color.aqua,     text_size = fontSz)
````
