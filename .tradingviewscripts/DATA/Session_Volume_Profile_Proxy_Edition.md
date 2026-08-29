<!-- tradingview-pine-id: PUB;6e3cbe92aefa43e69389d5dc486ed341 -->
<!-- tradingviewscripts-format: 1 -->
# Session Volume Profile — Proxy Edition

Source: https://www.tradingview.com/script/o6z5CgpU/

## Description

The native TradingView Volume Profile does not work on CFD/OTC 
brokers like EasyMarkets, OANDA, Pepperstone, and others — because 
these feeds provide zero or no real volume data.

This indicator solves that problem by automatically fetching volume 
from a liquid proxy symbol that matches your chart instrument.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator detects your chart symbol and automatically selects 
a real-volume proxy from a regulated exchange:

- (60+ instruments mapped automatically)

If no proxy is found, it falls back to bar range (High–Low) so 
the profile always renders regardless of the instrument.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT YOU GET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 Session Volume Profile
A classic histogram anchored to each trading session. Bars are 
split into bullish (up) and bearish (down) volume side by side. 
The Value Area is highlighted in separate colors for quick reading.

🔷 POC — Point of Control
The price level with the highest traded volume in the session. 
Extends to the right edge of the chart on the current session.

🔷 VAH / VAL — Value Area High & Low
Upper and lower boundaries of the configurable Value Area 
(default 70% of total volume).

🔷 Info Panel
Shows the active proxy symbol, current session POC, VAH and VAL 
prices updated in real time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SESSION MODES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Day mode (default)
One profile per calendar day (UTC). Resets automatically at 
midnight. Works on any intraday timeframe.

Candles mode
One profile every N bars. Fully configurable — examples:
  • 15m chart → 96 candles = 1 full day
  • 15m chart → 32 candles = 8 hours (London session)
  • 15m chart → 16 candles = 4 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session Settings
  • Sessions to Show — 1 to 10 past sessions
  • Session Mode — Day or Candles
  • Candles per Session — bars per profile in Candles mode
  • Min Bars to Draw — skip incomplete sessions (weekends,
    holidays) that have fewer than N bars
  • Extend POC to Right — current session POC extends to 
    the right edge of the chart

Profile Settings
  • Number of Rows — resolution of the histogram
    (fewer rows = thicker, more readable bars)
  • Value Area % — volume percentage defining the VA
  • Profile Width — histogram width as % of session duration

Style
  • Up / Down volume colors
  • Value Area Bull / Bear colors (highlighted rows)
  • POC line color and width
  • VAH / VAL line colors and visibility

Volume Proxy
  • Auto-detect ON (default) — built-in symbol map
  • Auto-detect OFF — enter any TradingView symbol manually

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPATIBLE BROKERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EasyMarkets · OANDA · Pepperstone · IC Markets · FP Markets
· Any CFD or OTC feed where native volume profile shows no data

⚠️ DISCLAIMER
Volumes displayed are sourced from external proxy symbols 
(Binance, FX, CME, COMEX, etc.) and do not represent the actual 
volume of your broker or chart feed. Use for analysis and trend 
confirmation only. Do not use as the sole basis for trading 
decisions.

Requires TradingView Pro or above.

⚠️ IMPORTANT:
- This indicator uses volume from EXTERNAL SOURCES, not broker volume
- Volumes may NOT match what you see on the chart
- Use as a secondary tool, as a SUPPLEMENT, not as the sole basis for decisions
- It is the user’s responsibility to validate the data

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// ═══════════════════════════════════════════════════════════════════
// Session Volume Profile — Proxy Edition
// ═══════════════════════════════════════════════════════════════════
// Author : Fabricio Nicolau
// ═══════════════════════════════════════════════════════════════════

//@version=6
indicator(
     title           = 'Session Volume Profile — Proxy Edition',
     shorttitle      = 'VolumeProfilePro',
     overlay         = true,
     max_boxes_count = 500,
     max_lines_count = 100)

// ─────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────
G_SESS  = 'Session Settings'
G_PROF  = 'Profile Settings'
G_STYLE = 'Style'
G_PROXY = 'Volume Proxy'

sessionsBack = input.int(3,     'Sessions to Show',           group = G_SESS, minval = 1, maxval = 5)
minBarsReq   = input.int(5,     'Min Bars to Draw Profile',   group = G_SESS, minval = 2, maxval = 20,
     tooltip = 'Minimum number of bars a session must have to render a profile. Avoids drawing on incomplete weekend/holiday sessions.')
extendPOC    = input.bool(true, 'Extend POC to Right',        group = G_SESS)

numRows      = input.int(18,   'Number of Rows',              group = G_PROF, minval = 5, maxval = 200,
     tooltip = 'Fewer rows = thicker bars, easier to read. Try 30-50 for 15m charts.')
vaPercent    = input.float(70, 'Value Area %',                group = G_PROF, minval = 1, maxval = 99, step = 1)
profileWidth = input.float(70, 'Profile Width (% of session)',group = G_PROF, minval = 5, maxval = 100, step = 5,
     tooltip = 'Width of the histogram relative to the session duration. 20-30% works well on 15m.')

colorUp      = input.color(color.new(#26c6da, 0),  'Up Volume Color',       group = G_STYLE)
colorDn      = input.color(color.new(#e53935, 0),  'Down Volume Color',     group = G_STYLE)
colorVAUp    = input.color(color.new(#6a0dad, 20), 'Value Area Bull',       group = G_STYLE)
colorVADn    = input.color(color.new(#6a0dad, 20), 'Value Area Bear',       group = G_STYLE)
colorPOC     = input.color(#ff3b3b,                'POC Color',             group = G_STYLE)
colorVAH     = input.color(color.new(#b2b5be, 30), 'VAH Color',             group = G_STYLE)
colorVAL     = input.color(color.new(#b2b5be, 30), 'VAL Color',             group = G_STYLE)
showPOC      = input.bool(true,  'Show POC Line',             group = G_STYLE)
showVAH      = input.bool(true,  'Show VAH Line',             group = G_STYLE)
showVAL      = input.bool(true,  'Show VAL Line',             group = G_STYLE)
pocWidth     = input.int(2,      'POC Line Width',            group = G_STYLE, minval = 1, maxval = 4)

autoProxy    = input.bool(true, 'Auto-detect Proxy Symbol',   group = G_PROXY)
manualProxy  = input.symbol('COMEX:GC1!', 'Custom Proxy Symbol', group = G_PROXY)

// ─────────────────────────────────────────────────────────────────
// PROXY MAP
// ─────────────────────────────────────────────────────────────────
getProxySymbol() =>
    sym = str.upper(syminfo.ticker)
    result = if str.contains(sym, "BTC")
        "BINANCE:BTCUSDT"
    else if str.contains(sym, "ETH")
        "BINANCE:ETHUSDT"
    else if str.contains(sym, "BCH")
        "BINANCE:BCHUSDT"
    else if str.contains(sym, "LTC")
        "BINANCE:LTCUSDT"
    else if str.contains(sym, "XRP")
        "BINANCE:XRPUSDT"
    else if str.contains(sym, "DOG") or str.contains(sym, "DOGE")
        "BINANCE:DOGEUSDT"
    else if str.contains(sym, "DOT")
        "BINANCE:DOTUSDT"
    else if str.contains(sym, "SOL")
        "BINANCE:SOLUSDT"
    else if str.contains(sym, "EURUSD")
        "FX:EURUSD"
    else if str.contains(sym, "EURJPY")
        "FX:EURJPY"
    else if str.contains(sym, "EURGBP")
        "FX:EURGBP"
    else if str.contains(sym, "EURCHF")
        "FX:EURCHF"
    else if str.contains(sym, "EURCAD")
        "FX:EURCAD"
    else if str.contains(sym, "EURAUD")
        "FX:EURAUD"
    else if str.contains(sym, "EURNOK")
        "FX:EURNOK"
    else if str.contains(sym, "EURNZD")
        "FX:EURNZD"
    else if str.contains(sym, "GBPUSD")
        "FX:GBPUSD"
    else if str.contains(sym, "GBPJPY")
        "FX:GBPJPY"
    else if str.contains(sym, "GBPAUD")
        "FX:GBPAUD"
    else if str.contains(sym, "GBPCHF")
        "FX:GBPCHF"
    else if str.contains(sym, "GBPCAD")
        "FX:GBPCAD"
    else if str.contains(sym, "GBPNZD")
        "FX:GBPNZD"
    else if str.contains(sym, "GBPSGD")
        "FX:GBPSGD"
    else if str.contains(sym, "USDJPY")
        "FX:USDJPY"
    else if str.contains(sym, "CADJPY")
        "FX:CADJPY"
    else if str.contains(sym, "AUDJPY")
        "FX:AUDJPY"
    else if str.contains(sym, "CHFJPY")
        "FX:CHFJPY"
    else if str.contains(sym, "NZDJPY")
        "FX:NZDJPY"
    else if str.contains(sym, "AUDUSD")
        "FX:AUDUSD"
    else if str.contains(sym, "AUDNZD")
        "FX:AUDNZD"
    else if str.contains(sym, "AUDCAD")
        "FX:AUDCAD"
    else if str.contains(sym, "CHFAUD") or str.contains(sym, "AUDCHF")
        "FX:AUDCHF"
    else if str.contains(sym, "USDCAD")
        "FX:USDCAD"
    else if str.contains(sym, "CADCHF")
        "FX:CADCHF"
    else if str.contains(sym, "USDCHF")
        "FX:USDCHF"
    else if str.contains(sym, "NZDCHF")
        "FX:NZDCHF"
    else if str.contains(sym, "NZDUSD")
        "FX:NZDUSD"
    else if str.contains(sym, "USDCNH")
        "FX:USDCNH"
    else if str.contains(sym, "USDMXN")
        "FX:USDMXN"
    else if str.contains(sym, "XAU") or str.contains(sym, "GOLD")
        "COMEX:GC1!"
    else if str.contains(sym, "XAG") or str.contains(sym, "SILVER")
        "COMEX:SI1!"
    else if str.contains(sym, "XPT") or str.contains(sym, "PLAT")
        "NYMEX:PL1!"
    else if str.contains(sym, "XPD") or str.contains(sym, "PALL")
        "NYMEX:PA1!"
    else if str.contains(sym, "CPU") or str.contains(sym, "COPP")
        "COMEX:HG1!"
    else if str.contains(sym, "BRT") or str.contains(sym, "BRENT")
        "ICEEUR:BRN1!"
    else if str.contains(sym, "OIL") or str.contains(sym, "WTI")
        "NYMEX:CL1!"
    else if str.contains(sym, "NGS") or str.contains(sym, "NGAS")
        "NYMEX:NG1!"
    else if str.contains(sym, "CRN") or str.contains(sym, "CORN")
        "CBOT:ZC1!"
    else if str.contains(sym, "WHT") or str.contains(sym, "WHEAT")
        "CBOT:ZW1!"
    else if str.contains(sym, "SGR") or str.contains(sym, "SUGAR")
        "ICEUS:SB1!"
    else if str.contains(sym, "CTN") or str.contains(sym, "COTTON")
        "ICEUS:CT1!"
    else if str.contains(sym, "CCO") or str.contains(sym, "COCOA")
        "ICEUS:CC1!"
    else if str.contains(sym, "USX") or str.contains(sym, "DXY")
        "ICEUS:DX1!"
    else if str.contains(sym, "DOW") or str.contains(sym, "DJC")
        "CBOT:YM1!"
    else if str.contains(sym, "NDQ") or str.contains(sym, "NQC") or str.contains(sym, "NAS100")
        "OANDA:NAS100USD"
    else if str.contains(sym, "SPI") or str.contains(sym, "SPC") or str.contains(sym, "SPX") or str.contains(sym, "US500")
        "OANDA:SPX500USD"
    else if str.contains(sym, "NKI") or str.contains(sym, "NKC")
        "CME:NKD1!"
    else if str.contains(sym, "DAX") or str.contains(sym, "DEC")
        "EUREX:FDAX1!"
    else if str.contains(sym, "FTS") or str.contains(sym, "UKC")
        "ICEEUR:Z1!"
    else if str.contains(sym, "CAC")
        "EURONEXT:FCE1!"
    else if str.contains(sym, "MIB") or str.contains(sym, "EUC")
        "EUREX:FESX1!"
    else if str.contains(sym, "AUC") or str.contains(sym, "AUS200")
        "ASX24:AP1!"
    else if str.contains(sym, "HSX") or str.contains(sym, "HSI")
        "HKEX:MHI1!"
    else if str.contains(sym, "APL") or str.contains(sym, "AAPL")
        "NASDAQ:AAPL"
    else if str.contains(sym, "AMZ") or str.contains(sym, "AMZN")
        "NASDAQ:AMZN"
    else if str.contains(sym, "GOO") or str.contains(sym, "GOOGL")
        "NASDAQ:GOOGL"
    else if str.contains(sym, "MSF") or str.contains(sym, "MSFT")
        "NASDAQ:MSFT"
    else if str.contains(sym, "NFX") or str.contains(sym, "NFLX")
        "NASDAQ:NFLX"
    else if str.contains(sym, "NVD") or str.contains(sym, "NVDA")
        "NASDAQ:NVDA"
    else if str.contains(sym, "TSL") or str.contains(sym, "TSLA")
        "NASDAQ:TSLA"
    else if str.contains(sym, "FBK") or str.contains(sym, "META")
        "NASDAQ:META"
    else if str.contains(sym, "JPM")
        "NYSE:JPM"
    else if str.contains(sym, "UBE") or str.contains(sym, "UBER")
        "NYSE:UBER"
    else if str.contains(sym, "EXO") or str.contains(sym, "XOM")
        "NYSE:XOM"
    else if str.contains(sym, "DIS")
        "NYSE:DIS"
    else if str.contains(sym, "MCD")
        "NYSE:MCD"
    else if str.contains(sym, "FRD") or str.contains(sym, "FORD")
        "NYSE:F"
    else if str.contains(sym, "ADS")
        "XETR:ADS"
    else if str.contains(sym, "HBC") or str.contains(sym, "HSBC")
        "HKEX:5"
    else
        "BINANCE:BTCUSDT"
    result

// ─────────────────────────────────────────────────────────────────
// EFFECTIVE VOLUME
// ─────────────────────────────────────────────────────────────────
proxySymbol = autoProxy ? getProxySymbol() : manualProxy
proxyVol    = request.security(proxySymbol, timeframe.period, volume,
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)
effVol = not na(volume) and volume > 0 ? volume
     : not na(proxyVol) and proxyVol > 0 ? proxyVol
     : (high - low)

// ─────────────────────────────────────────────────────────────────
// SESSION DATA COLLECTION
// ─────────────────────────────────────────────────────────────────
isNewDay = ta.change(time("D")) != 0

// We store per-session data in flat arrays indexed by session number
// Max 5 sessions × up to 2000 bars each = manageable
type Session
    array<float> highs
    array<float> lows
    array<float> vols
    array<bool>  bulls
    array<int>   times

var array<Session> sess = array.new<Session>()

if isNewDay or barstate.isfirst
    sess.unshift(Session.new(
         array.new<float>(), array.new<float>(),
         array.new<float>(), array.new<bool>(),
         array.new<int>()))
    while sess.size() > sessionsBack + 1
        sess.pop()

if sess.size() > 0
    Session cur = sess.first()
    cur.highs.push(high)
    cur.lows.push(low)
    cur.vols.push(effVol)
    cur.bulls.push(close >= open)
    cur.times.push(time)

// ─────────────────────────────────────────────────────────────────
// PROFILE CALCULATION
// Returns parallel arrays + key levels
// ─────────────────────────────────────────────────────────────────
calcProfile(Session s, int rows) =>
    float sHi  = s.highs.max()
    float sLo  = s.lows.min()
    float rng  = sHi - sLo
    float rowH = rng / rows

    array<float> vUp = array.new<float>(rows, 0.0)
    array<float> vDn = array.new<float>(rows, 0.0)

    if rng > 0
        for b = 0 to s.highs.size() - 1
            float bH  = s.highs.get(b)
            float bL  = s.lows.get(b)
            float bV  = s.vols.get(b)
            bool  bUp = s.bulls.get(b)
            float bRng = math.max(bH - bL, rowH)
            int rFrom = math.max(0,      math.floor((bL - sLo) / rowH))
            int rTo   = math.min(rows-1, math.floor((bH - sLo) / rowH))
            for r = rFrom to rTo
                float rB  = sLo + r * rowH
                float rT  = rB + rowH
                float ov  = (math.min(bH, rT) - math.max(bL, rB)) / bRng
                float rv  = bV * math.max(ov, 0.0)
                if bUp
                    vUp.set(r, vUp.get(r) + rv)
                else
                    vDn.set(r, vDn.get(r) + rv)

    // POC
    float totV = 0.0
    float maxV = 0.0
    int   pocI = 0
    for r = 0 to rows - 1
        float rv = vUp.get(r) + vDn.get(r)
        totV += rv
        if rv > maxV
            maxV := rv
            pocI := r

    float pocP = sLo + pocI * rowH + rowH * 0.5

    // Value Area
    float vaT  = totV * vaPercent / 100
    float vaV  = vUp.get(pocI) + vDn.get(pocI)
    int   vaHi = pocI
    int   vaLo = pocI
    while vaV < vaT and (vaHi < rows-1 or vaLo > 0)
        float volAbove = vaHi < rows-1 ? vUp.get(vaHi+1) + vDn.get(vaHi+1) : 0.0
        float volBelow = vaLo > 0      ? vUp.get(vaLo-1) + vDn.get(vaLo-1) : 0.0
        if volAbove >= volBelow and vaHi < rows-1
            vaHi += 1
            vaV  += volAbove
        else if vaLo > 0
            vaLo -= 1
            vaV  += volBelow
        else
            vaHi += 1
            vaV  += volAbove

    float vahP = sLo + vaHi * rowH + rowH
    float valP = sLo + vaLo * rowH

    [vUp, vDn, pocP, vahP, valP, sHi, sLo, rowH, maxV]

// ─────────────────────────────────────────────────────────────────
// DRAWING
// ─────────────────────────────────────────────────────────────────
var array<box>  drawnBoxes = array.new<box>()
var array<line> drawnLines = array.new<line>()

drawProfile(Session s, int si) =>
    // Skip sessions with too few bars
    if s.times.size() < minBarsReq
        false
    else
        [vUp, vDn, pocP, vahP, valP, sHi, sLo, rowH, maxV] = calcProfile(s, numRows)

        int tStart = s.times.first()
        int tEnd   = s.times.last()
        int sessMs = math.abs(tEnd - tStart)

        // Histogram bars anchored to LEFT edge of session
        // Width grows rightward — classic histogram look
        float maxBarMs = sessMs * profileWidth / 100

        for r = 0 to numRows - 1
            float rBot = sLo + r * rowH
            float rTop = rBot + rowH
            float vU   = vUp.get(r)
            float vD   = vDn.get(r)
            float vT   = vU + vD
            if vT <= 0
                continue

            float barMs  = maxV > 0 ? maxBarMs * vT / maxV : 0.0
            bool  inVA   = rTop > valP and rBot < vahP

            // Split: bullish portion left, bearish portion right
            float upMs = barMs * (vT > 0 ? vU / vT : 0.5)
            float dnMs = barMs - upMs

            color cUp = inVA ? colorVAUp : colorUp
            color cDn = inVA ? colorVADn : colorDn

            // Bullish box (left portion)
            if upMs > 0
                box bU = box.new(
                     xloc         = xloc.bar_time,
                     left         = tStart,
                     top          = rTop,
                     right        = tStart + math.round(upMs),
                     bottom       = rBot,
                     border_color = color.new(color.black, 70),
                     border_width = 1,
                     bgcolor      = cUp)
                drawnBoxes.push(bU)

            // Bearish box (right of bullish)
            if dnMs > 0
                box bD = box.new(
                     xloc         = xloc.bar_time,
                     left         = tStart + math.round(upMs),
                     top          = rTop,
                     right        = tStart + math.round(barMs),
                     bottom       = rBot,
                     border_color = color.new(color.black, 70),
                     border_width = 1,
                     bgcolor      = cDn)
                drawnBoxes.push(bD)

        bool isCurrent = si == 0
        int  pocRight  = extendPOC and isCurrent
             ? last_bar_time + 20 * math.max(time - time[1], 1)
             : tEnd

        // POC
        if showPOC
            line lp = line.new(
                 x1 = tStart, y1 = pocP, x2 = pocRight, y2 = pocP,
                 xloc = xloc.bar_time, color = colorPOC,
                 style = line.style_solid, width = pocWidth)
            drawnLines.push(lp)

        // VAH
        if showVAH
            line lh = line.new(
                 x1 = tStart, y1 = vahP, x2 = tEnd, y2 = vahP,
                 xloc = xloc.bar_time, color = colorVAH,
                 style = line.style_dashed, width = 1)
            drawnLines.push(lh)

        // VAL
        if showVAL
            line ll = line.new(
                 x1 = tStart, y1 = valP, x2 = tEnd, y2 = valP,
                 xloc = xloc.bar_time, color = colorVAL,
                 style = line.style_dashed, width = 1)
            drawnLines.push(ll)
        true

if barstate.islastconfirmedhistory or barstate.islast
    // Clear all previous drawings
    for b in drawnBoxes
        b.delete()
    drawnBoxes.clear()
    for l in drawnLines
        l.delete()
    drawnLines.clear()

    // Draw each session
    int total = math.min(sess.size(), sessionsBack)
    for si = 0 to total - 1
        drawProfile(sess.get(si), si)

// ─────────────────────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 5,
     bgcolor      = color.new(color.black, 65),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 60),
     frame_width  = 1)

if barstate.islast and sess.size() > 0
    Session cur = sess.first()
    if cur.times.size() >= minBarsReq
        [vUp, vDn, pocP, vahP, valP, sHi, sLo, rowH, maxV] = calcProfile(cur, numRows)
        table.cell(tbl, 0, 0, 'SVP-Pro',
             text_color = color.white, text_size = size.small)
        table.cell(tbl, 1, 0, proxySymbol,
             text_color = color.new(#26c6da, 0), text_size = size.tiny)
        table.cell(tbl, 0, 1, 'POC',
             text_color = colorPOC, text_size = size.tiny)
        table.cell(tbl, 1, 1, str.tostring(pocP, format.mintick),
             text_color = colorPOC, text_size = size.tiny)
        table.cell(tbl, 0, 2, 'VAH',
             text_color = colorVAH, text_size = size.tiny)
        table.cell(tbl, 1, 2, str.tostring(vahP, format.mintick),
             text_color = colorVAH, text_size = size.tiny)
        table.cell(tbl, 0, 3, 'VAL',
             text_color = colorVAL, text_size = size.tiny)
        table.cell(tbl, 1, 3, str.tostring(valP, format.mintick),
             text_color = colorVAL, text_size = size.tiny)
        table.cell(tbl, 0, 4, 'Proxy',
             text_color = color.gray, text_size = size.tiny)
        table.cell(tbl, 1, 4, proxySymbol,
             text_color = color.gray, text_size = size.tiny)
````
