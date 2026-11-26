# x5 mm black po

- url: https://www.tradingview.com/script/s7s5Jfdr/
- type: indicator
- pine_id: PUB;6806484af6524b2185b014c4d32c27de
- version: 1.0

## Description

x5 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// Fau InfoPanel - TradingView port
// Original: "InfoPanel.ex4" / "[Fau]InfoPanel" (Fauzaan Gasim, BTMM template)
//
// Pannello info nell'angolo del chart con dati di contesto:
//   - Symbol / Timeframe
//   - Spread (bid-ask diff, se disponibile)
//   - Daily High / Low / Range / ADR e completion %
//   - ATR
//   - Sessione attiva (Asia / FFM / London / NY)
//   - Tempo al prossimo evento (daily close / next session)
// =============================================================================
indicator("x5 mm black po", overlay=true, max_labels_count=1)

// ---- Inputs ----
cornerIn   = input.string("top_right", "Corner", options=["top_left","top_right","bottom_left","bottom_right","middle_right","middle_left"])
adrPeriod  = input.int(14, "ADR period (giorni)", minval=2, maxval=200)
atrPeriod  = input.int(14, "ATR period",          minval=2, maxval=200)
textSize   = input.string("normal", "Text size",  options=["tiny","small","normal","large"])
bgCol      = input.color(color.new(color.black, 20), "Background")
hdrCol     = input.color(color.new(color.gray, 30),  "Header bg")
txtCol     = input.color(color.white, "Text color")
showSpread = input.bool(true,  "Mostra spread")
showADR    = input.bool(true,  "Mostra ADR")
showATR    = input.bool(true,  "Mostra ATR")
showSess   = input.bool(true,  "Mostra session info")

// ---- Pip helpers ----
pipSize  = syminfo.mintick * (syminfo.type == "forex" and (syminfo.basecurrency == "JPY" or syminfo.currency == "JPY") ? 100 : 10)
toPips(x) => x / pipSize

// ---- Data ----
dHigh = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_off)
dLow  = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_off)
dOpen = request.security(syminfo.tickerid, "D", open,  lookahead=barmerge.lookahead_off)
adr   = request.security(syminfo.tickerid, "D", ta.sma(high[1] - low[1], adrPeriod), lookahead=barmerge.lookahead_off)
atr   = ta.atr(atrPeriod)

dRange = dHigh - dLow
adrPct = adr > 0 ? dRange / adr * 100 : 0
// Spread non esposto da Pine (TV non passa quote bid/ask separati come MT4)

// ---- Sessions (NY time) ----
ny = "America/New_York"
hmNY = hour(time, ny) * 100 + minute(time, ny)
inAsia   = hmNY >= 1800 or hmNY < 300   // 18:00-03:00 NY ≈ Tokyo session
inFFM    = hmNY >= 200  and hmNY < 400  // 02:00-04:00 NY ≈ Frankfurt open
inLondon = hmNY >= 300  and hmNY < 1130 // 03:00-11:30 NY ≈ London
inNY     = hmNY >= 800  and hmNY < 1700 // 08:00-17:00 NY ≈ New York

sessTxt = inLondon and inNY ? "LDN+NY" : inLondon ? "LONDON" : inNY ? "NEW YORK" : inFFM ? "FRANKFURT" : inAsia ? "ASIA" : "CLOSED"
sessCol = inLondon and inNY ? color.new(color.lime, 30) : inLondon ? color.new(color.green, 30) : inNY ? color.new(color.blue, 30) : inAsia ? color.new(color.yellow, 30) : color.new(color.gray, 30)

// ---- Time to daily close (UTC midnight by default — TV chart timezone) ----
// Calcolo minuti rimanenti al daily candle close
timeUntilDailyClose = (24 * 60 * 60 * 1000) - (time % (24 * 60 * 60 * 1000))
hoursLeft = math.floor(timeUntilDailyClose / 3600000)
minsLeft  = math.floor((timeUntilDailyClose % 3600000) / 60000)

// ---- Position ----
pos = cornerIn == "top_left" ? position.top_left : cornerIn == "top_right" ? position.top_right : cornerIn == "bottom_left" ? position.bottom_left : cornerIn == "bottom_right" ? position.bottom_right : cornerIn == "middle_right" ? position.middle_right : position.middle_left
sz  = textSize == "tiny" ? size.tiny : textSize == "small" ? size.small : textSize == "large" ? size.large : size.normal

// ---- Build table ----
var table tbl = na
if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(position=pos, columns=2, rows=10, border_width=1, border_color=color.new(color.gray, 50))
    r = 0
    table.cell(tbl, 0, r, "Symbol",   bgcolor=hdrCol, text_color=txtCol, text_size=sz)
    table.cell(tbl, 1, r, syminfo.ticker, bgcolor=bgCol, text_color=txtCol, text_size=sz)
    r += 1
    table.cell(tbl, 0, r, "TF",       bgcolor=hdrCol, text_color=txtCol, text_size=sz)
    table.cell(tbl, 1, r, timeframe.period, bgcolor=bgCol, text_color=txtCol, text_size=sz)
    r += 1
    table.cell(tbl, 0, r, "Price",    bgcolor=hdrCol, text_color=txtCol, text_size=sz)
    table.cell(tbl, 1, r, str.tostring(close, format.mintick), bgcolor=bgCol, text_color=txtCol, text_size=sz)
    if showADR
        r += 1
        table.cell(tbl, 0, r, "ADR("+str.tostring(adrPeriod)+")", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
        table.cell(tbl, 1, r, str.tostring(toPips(adr), "#.0")+" p", bgcolor=bgCol, text_color=color.aqua, text_size=sz)
        r += 1
        table.cell(tbl, 0, r, "Range/ADR", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
        rangeBg = adrPct >= 100 ? color.new(color.red, 40) : adrPct >= 70 ? color.new(color.orange, 40) : color.new(color.green, 40)
        table.cell(tbl, 1, r, str.tostring(adrPct, "#.0")+"%", bgcolor=rangeBg, text_color=color.white, text_size=sz)
    if showATR
        r += 1
        table.cell(tbl, 0, r, "ATR("+str.tostring(atrPeriod)+")", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
        table.cell(tbl, 1, r, str.tostring(toPips(atr), "#.0")+" p", bgcolor=bgCol, text_color=color.aqua, text_size=sz)
    if showSess
        r += 1
        table.cell(tbl, 0, r, "Session", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
        table.cell(tbl, 1, r, sessTxt,  bgcolor=sessCol, text_color=color.white, text_size=sz)
    r += 1
    table.cell(tbl, 0, r, "Day Close", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
    table.cell(tbl, 1, r, str.tostring(hoursLeft, "00")+"h"+str.tostring(minsLeft, "00")+"m", bgcolor=bgCol, text_color=color.yellow, text_size=sz)
    if showSpread
        r += 1
        table.cell(tbl, 0, r, "Spread", bgcolor=hdrCol, text_color=txtCol, text_size=sz)
        table.cell(tbl, 1, r, "n/a (TV)", bgcolor=bgCol, text_color=color.new(color.gray, 30), text_size=sz)
````
