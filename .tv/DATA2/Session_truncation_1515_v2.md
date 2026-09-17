<!-- tradingview-pine-id: PUB;83e5cf6223b14fd2996f3384e243779c -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Session truncation @ 15:15 v2

Source: https://www.tradingview.com/script/FwtrpGvL-Hide-CAS-candles-post-3-15-PM/

## Description

Hide CAS ticks/ candles post 3.15 pm for NSE and BSE F&O equivalent cash stocks & Indices.

- Since 3 August 2026, F&O stocks on NSE no longer trade continuously till the close. Continuous trading stops at 15:15, and the last 20 minutes run as a Closing Auction Session (CAS) — a single-price auction that only prints at the end.
- The candles between 15:15 and the auction print stop reflecting normal supply and demand. You see wicks, gaps, and sudden spikes that have nothing to do with what buyers and sellers were actually doing.
- On higher timeframes (hourly, daily, weekly), that distorted tail gets baked into the bar's close, high, or low — quietly poisoning every study, moving average, and pattern you're looking at.
- Even the official Nifty closing level has jumped ~200 points at the fag end on some days purely because of CAS mechanics, catching seasoned participants off guard.

What this indicator does

- For NSE and BSE F&O equivalent cash stocks & Indices, ends every trading day at 15:15 on your chart, the moment continuous trading actually stops.
- Bars starting after 15:15 vanish. The 15:15 print shows as a small tick so you can see where the day closed.
- On hourly/daily/weekly bars, the close, high, and low are recomputed as if the market ended at 15:15 — no CAS contamination.
- Bars before the cutoff are left completely untouched. You see the real market, minus the auction noise.

Practical notes

- Only runs on NSE/BSE symbols that have an F&O contract (those are the ones CAS affects).
- Only works on candles starting 3 Aug 2026
- Cutoff time and start date are configurable — leave defaults for CAS, or shift them if a future rule change moves the auction window.
- Turn off Borders in Settings → Symbol once, or you'll see faint outlines of the original bars showing through.
- Detects F&O names using the symbol on display and identifying if there is an equivalent F&O name for this (e.g., BankNifty <---> BankNifty1!). As a result there could be a few edge cases.
- Ignores F&O symbols themselves.

Example of bar truncation on Bank Nifty Daily chart
[image]https://www.tradingview.com/x/q742DmpT/[/image]

---

## Source Code

````pine
//@version=6
// Truncates the trading session at a cutoff time (default 15:15 IST) from a
// given date onward.
//
// Rules implemented:
//   * chart TF == 1m (or tick) : the bar starting exactly at 15:15 collapses
//     to O=H=L=C=open; every bar starting after 15:15 is removed. Decided
//     from the bar's own timestamp - no intrabar request is involved.
//   * chart TF >  1m : the bar is rebuilt from lower-TF intrabars (1m for
//     charts up to 15m, 15m for hourly and above), using only the data
//     before 15:15 plus the 15:15 open as a single closing tick
//         open  = open of the first pre-cutoff intrabar (or native open on D/W/M)
//         close = open at 15:15
//         high  = max(high made up to 15:15 exclusive, open at 15:15)
//         low   = min(low  made up to 15:15 exclusive, open at 15:15)
//     This handles both aligned TFs (5m, 15m, 30m ...) and non-aligned
//     TFs (7m, 10m, 11m ...) that straddle 15:15 - the straddling bar
//     is closed at 15:15 and no separate dash is needed.
//
// Only bars the rule actually changes are repainted; before 15:15 on the current
// live bar, the native candle remains untouched.
//
// ONE-TIME CHART SETTING: Settings -> Symbol -> uncheck "Borders".
// barcolor() cannot reach the native candle's border, so a masked bar would
// otherwise leave its outline behind. Leave Body and Wick checked.

indicator("Session truncation @ 15:15 v2", overlay = true, max_bars_back = 500)

// ─────────────────────────────── inputs
tz       = input.string("Asia/Kolkata", "Timezone",                group = "Rule")
startTs  = input.time(timestamp("3 Aug 2026 00:00 +0530"), "Apply from", group = "Rule")
cutH     = input.int(15, "Cutoff hour",   minval = 0, maxval = 23, group = "Rule")
cutM     = input.int(15, "Cutoff minute", minval = 0, maxval = 59, group = "Rule")
upCol    = input.color(#089981, "Up",   inline = "c", group = "Display")
dnCol    = input.color(#f23645, "Down", inline = "c", group = "Display")

cutoff = cutH * 60 + cutM
tfSec  = timeframe.in_seconds()
tfMin  = tfSec / 60
useLTF = tfSec > 60                      // intrabars for any chart above 1m

tod(t) => hour(t, tz) * 60 + minute(t, tz)

// ─────────────────────────────── symbol gate: NSE/BSE underlyings with F&O
// Only the underlying (cash equity or index) should be truncated - the
// F&O contract itself trades on a different schedule and must be left
// alone. F&O eligibility of the underlying is probed by trying the
// TradingView continuous-futures ticker (SYMBOL1!).
mapIndex(t) =>
    switch t
        "NIFTY50"                  => "NIFTY"
        "NIFTY 50"                 => "NIFTY"
        "CNXNIFTY"                 => "NIFTY"
        "NIFTYBANK"                => "BANKNIFTY"
        "NIFTY BANK"               => "BANKNIFTY"
        "CNXBAN"                   => "BANKNIFTY"
        "CNXFINANCE"               => "FINNIFTY"
        "NIFTY FINANCIAL SERVICES" => "FINNIFTY"
        "NIFTY FIN SERVICE"        => "FINNIFTY"
        "NIFTY MID SELECT"         => "MIDCPNIFTY"
        "NIFTY NEXT 50"            => "NIFTYNXT50"
        "CNXJUNIOR"                => "NIFTYNXT50"
        "BSX"                      => "SENSEX"
        => t

cleanTicker  = mapIndex(syminfo.ticker)
isFOContract = syminfo.type == "futures"                 // futures / options chart

// Probe continuous futures contract on NSE or BSE (e.g. NSE:NIFTY1!, BSE:SENSEX1!)
probeNSE = request.security("NSE:" + cleanTicker + "1!", "D", close, ignore_invalid_symbol = true)
probeBSE = request.security("BSE:" + cleanTicker + "1!", "D", close, ignore_invalid_symbol = true)
hasFO    = not na(probeNSE) or not na(probeBSE)

// Restrict to NSE / BSE symbols
allowedExch = syminfo.prefix == "NSE" or syminfo.prefix == "BSE"
allowed     = allowedExch and hasFO and not isFOContract

if barstate.islast and not allowed
    // log.error("[Gate Error] prefix=" + syminfo.prefix + ", ticker=" + syminfo.ticker + ", type=" + syminfo.type + ", cleanTicker=" + cleanTicker + ", probeNSE=" + str.tostring(probeNSE) + ", probeBSE=" + str.tostring(probeBSE) + ", hasFO=" + str.tostring(hasFO) + ", allowedExch=" + str.tostring(allowedExch) + ", isFOContract=" + str.tostring(isFOContract))
    runtime.error("Session truncation @ 15:15 runs only on NSE/BSE cash or index symbols whose underlying has an F&O contract - not on the F&O contract itself.")

// ─────────────────────────────── intrabar feed (only consumed when useLTF)
useFineLTF = tfSec <= 900 or (timeframe.isintraday and (tfMin % 15) != 0)
ltf        = useFineLTF ? "1" : "15"
// Request extended session data so post-3:15 ETH ticks (CAS) on Nifty are included
extTickerId = ticker.modify(syminfo.tickerid, session = session.extended)
[ltfT, ltfO, ltfH, ltfL, ltfC] = request.security_lower_tf(extTickerId, ltf, [time, open, high, low, close])

// ─────────────────────────────── rebuild
float O        = open
float H        = high
float L        = low
float C        = close
bool  hideBar  = false
bool  modified = false
float preO     = na
float preH     = na
float preL     = na
float preLastC = na
float cutLast  = na
float cutHi    = na
float cutLo    = na

if allowed and time >= startTs
    if not useLTF
        // ── 1m (or tick) chart: the bar's own start time decides everything
        bt = tod(time)
        if bt > cutoff
            hideBar  := true                         // wholly after 15:15
            modified := true
        else if bt == cutoff
            H        := open
            L        := open
            C        := open
            modified := true
    else if array.size(ltfT) > 0
        for i = 0 to array.size(ltfT) - 1
            m = tod(array.get(ltfT, i))
            if m < cutoff
                preO     := na(preO) ? array.get(ltfO, i) : preO
                preH     := na(preH) ? array.get(ltfH, i) : math.max(preH, array.get(ltfH, i))
                preL     := na(preL) ? array.get(ltfL, i) : math.min(preL, array.get(ltfL, i))
                preLastC := array.get(ltfC, i)
            else if m == cutoff
                op      = array.get(ltfO, i)
                cutLast := op
                cutHi   := na(cutHi) ? op : math.max(cutHi, op)
                cutLo   := na(cutLo) ? op : math.min(cutLo, op)
            // m > cutoff -> discarded entirely

        // CAS / Session fallback:
        // If continuous session completed up to cutoff (e.g. 24 bars ending at 15:00)
        // and no separate 15:15 bar exists, use the close of the final pre-cutoff bar.
        nowM = tod(timenow)
        cutoffPassed = not barstate.islast or nowM >= cutoff
        if na(cutLast) and not na(preLastC) and cutoffPassed
            cutLast := preLastC
            cutHi   := na(cutHi) ? preLastC : math.max(cutHi, preLastC)
            cutLo   := na(cutLo) ? preLastC : math.min(cutLo, preLastC)

        if na(preO)
            if na(cutLast)
                hideBar  := true                     // wholly after 15:15
                modified := true
            else
                O        := cutLast                  // e.g. the 15:15-15:30 hourly stub
                H        := cutLast
                L        := cutLast
                C        := cutLast
                modified := true
        else
            // Bar has data before cutoff: only modify if cutoff was reached inside this bar
            if not na(cutLast)
                O        := (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly) ? open : preO
                H        := math.max(preH, cutHi)
                L        := math.min(preL, cutLo)
                C        := cutLast
                modified := true

// ─────────────────────────────── draw
draw = modified and not hideBar

col = C >= O ? upCol : dnCol
plotcandle(draw ? O : na, draw ? H : na, draw ? L : na, draw ? C : na,
     title       = "Truncated",
     color       = col,
     wickcolor   = col,
     bordercolor = col)

// na = leave the built-in candle alone; transparent = suppress it
barcolor(modified ? color.new(color.white, 100) : na, title = "Native candle mask")

// ─────────────────────────────── debug logs (only 31st Aug & 1st Sept)
// barD  = dayofmonth(time, tz)
// barMo = month(time, tz)
// isTargetDate = (barMo == 9 and barD == 1) or (barMo == 8 and barD == 31)
//
// if isTargetDate
//     log.info("=== TARGET DATE: " + str.format_time(time, "yyyy-MM-dd", tz) + " ===")
//     log.info("1. Symbol: " + syminfo.prefix + ":" + syminfo.ticker + " | allowed=" + str.tostring(allowed) + " | inRange=" + str.tostring(time >= startTs))
//     log.info("2. LTF Info: ltf=" + ltf + " | arraySize=" + str.tostring(array.size(ltfT)))
//     if array.size(ltfT) > 0
//         string timesList = ""
//         bool foundCutoff = false
//         for i = 0 to array.size(ltfT) - 1
//             t_bar = array.get(ltfT, i)
//             if tod(t_bar) == cutoff
//                 foundCutoff := true
//             timesList := timesList + str.format_time(t_bar, "HH:mm", tz) + " "
//         log.info("3. Intrabar Start Times: " + timesList)
//         log.info("4. Cutoff Check: cutoff=" + str.tostring(cutoff) + " (15:15) | foundCutoff=" + str.tostring(foundCutoff))
//         log.info("5. Rebuilt Vars: preO=" + str.tostring(preO) + ", preLastC=" + str.tostring(preLastC) + ", cutLast=" + str.tostring(cutLast) + ", cutHi=" + str.tostring(cutHi) + ", cutLo=" + str.tostring(cutLo))
//         log.info("6. State: hideBar=" + str.tostring(hideBar) + ", modified=" + str.tostring(modified) + ", draw=" + str.tostring(draw))
//         log.info("7. Native: O=" + str.tostring(open) + " H=" + str.tostring(high) + " L=" + str.tostring(low) + " C=" + str.tostring(close))
//         log.info("8. Plotted: O=" + str.tostring(O) + " H=" + str.tostring(H) + " L=" + str.tostring(L) + " C=" + str.tostring(C))
//     else
//         log.warning("LTF array is EMPTY! request.security_lower_tf returned 0 intrabars for this day.")
````
