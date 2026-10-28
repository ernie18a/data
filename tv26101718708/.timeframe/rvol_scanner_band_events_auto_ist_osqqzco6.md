# RVOL Scanner + Band + Events [Auto IST]

- url: https://www.tradingview.com/script/OSqqZCO6-RVOL-Scanner-Band-Events-Auto-IST/
- type: indicator
- pine_id: PUB;3d7007719e0442fe814118a672f1a9da
- version: 1.0

## Description

This script is to filter out tredning stock excluding 2=5% ciurciut

## Source Code

````pine
//@version=6
indicator("RVOL Scanner + Band + Events [Auto IST]", overlay=true)

// ============================ INPUTS =================================
autoMode      = input.bool(true,  "Auto Mode (threshold switches by IST time)")
manualThresh  = input.float(15.0, "Manual Threshold % (used if Auto OFF)")
priceMovePct  = input.float(2.0,  "Min Price Move % (from open)")
minTurnoverCr = input.float(10.0, "Min 30D AVG Daily Turnover (Cr)")
advLookback   = input.int(30,     "ADV / Turnover Lookback (days)")
useSeed       = input.bool(false, "Use NSE Seed Data (turn ON after pipeline live)")
excludeBands  = input.bool(true,  "Exclude stocks in 2% / 5% band")

// ===================== 30-DAY ADV (completed days only) ==============
advDaily = request.security(syminfo.tickerid, "D", ta.sma(volume, advLookback)[1], lookahead=barmerge.lookahead_off)

// ===================== 30-DAY AVERAGE TURNOVER (Cr) ==================
avgTurnover   = request.security(syminfo.tickerid, "D", ta.sma(close * volume, advLookback)[1], lookahead=barmerge.lookahead_off)
avgTurnoverCr = avgTurnover / 10000000.0

// ===================== CUMULATIVE VOLUME SINCE OPEN =================
newDay = ta.change(time("D")) != 0
var float cumVol = 0.0
cumVol := newDay ? volume : cumVol + volume

// ===================== % OF ADV DONE ================================
pctADVdone = advDaily > 0 ? (cumVol / advDaily) * 100.0 : 0.0

// ===================== PRICE MOVE % FROM OPEN =======================
var float dayOpen = na
dayOpen := newDay ? open : dayOpen
priceChg = dayOpen > 0 ? ((close - dayOpen) / dayOpen) * 100.0 : 0.0

// ===================== IST TIME-BASED THRESHOLD =====================
istH = hour(time, "Asia/Kolkata")
istM = minute(time, "Asia/Kolkata")
mins = istH * 60 + istM
// IST marks: 555=09:15 556=09:16 560=09:20 570=09:30 600=10:00
autoThresh = mins < 555 ? 999.0 : mins < 556 ? 0.0 : mins < 560 ? 7.0 : mins < 570 ? 15.0 : mins < 600 ? 50.0 : 100.0
threshold = autoMode ? autoThresh : manualThresh

// ===================== SEED DATA (band% + events) ===================
// After NSE->GitHub pipeline is live: uncomment the two request.seed lines,
// delete the two `na` lines, swap repo/file names, set Use NSE Seed = ON.
// bandSeed  = request.seed("seed_yourusername_nsedata", "BAND_" + syminfo.ticker, close)
// eventSeed = request.seed("seed_yourusername_nsedata", "EVT_"  + syminfo.ticker, close)
float bandSeed  = na
float eventSeed = na

// ===================== BAND FILTER ==================================
bandKnown = useSeed and not na(bandSeed)
bandPass  = not excludeBands ? true : bandKnown ? (bandSeed > 5) : true

// ===================== EVENT FLAGS (mark only) ======================
evtKnown   = useSeed and not na(eventSeed)
isEarning  = evtKnown and (eventSeed == 1 or eventSeed == 3)
isConcall  = evtKnown and (eventSeed == 2 or eventSeed == 3)

// ===================== FINAL SIGNAL =================================
volPass  = pctADVdone >= threshold
movePass = math.abs(priceChg) >= priceMovePct
liqPass  = avgTurnoverCr >= minTurnoverCr
signal   = volPass and movePass and liqPass and bandPass

// ===================== VISUALS =====================================
plotshape(signal, "Trending", shape.triangleup, location.belowbar, color.lime, size=size.small)
bgcolor(signal ? color.new(color.lime, 85) : na)
plotshape(isEarning, "Earnings", shape.labeldown, location.abovebar, color.orange, text="E", textcolor=color.white, size=size.tiny)
plotshape(isConcall, "Concall",  shape.labeldown, location.abovebar, color.aqua,   text="C", textcolor=color.black, size=size.tiny)

// ===================== SCREENER COLUMN =============================
plotchar(pctADVdone, "ADV% Done", "", location.top, color.gray, size=size.tiny)

// ===================== ON-CHART DATA TABLE =========================
if barstate.islast
    var table t = table.new(position.top_right, 2, 6, border_width=1, bgcolor=color.new(color.black, 20))
    table.cell(t, 0, 0, "ADV% Done",   text_color=color.white)
    table.cell(t, 1, 0, str.tostring(pctADVdone, "#.0") + "%", text_color = volPass ? color.lime : color.red)
    table.cell(t, 0, 1, "Price Move",  text_color=color.white)
    table.cell(t, 1, 1, str.tostring(priceChg, "#.0") + "%",   text_color = movePass ? color.lime : color.red)
    table.cell(t, 0, 2, "AvgTurnover", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(avgTurnoverCr, "#.0") + "Cr", text_color = liqPass ? color.lime : color.red)
    table.cell(t, 0, 3, "Band",        text_color=color.white)
    table.cell(t, 1, 3, bandKnown ? (str.tostring(bandSeed,"#") + "%") : "proxy", text_color = bandPass ? color.lime : color.red)
    table.cell(t, 0, 4, "Threshold",   text_color=color.white)
    table.cell(t, 1, 4, str.tostring(threshold, "#.0") + "%", text_color=color.yellow)
    table.cell(t, 0, 5, "SIGNAL",      text_color=color.white)
    table.cell(t, 1, 5, signal ? "PASS" : "—", text_color = signal ? color.lime : color.gray)

// ===================== ALERT =======================================
alertcondition(signal, "Trending Stock Detected", "RVOL scanner: stock passed all conditions")
````
