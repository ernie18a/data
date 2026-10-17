# Gap-Down Breakdown Level [DefinedEdge]

- url: https://www.tradingview.com/script/uAR5ay5a-Gap-Down-Breakdown-Level-DefinedEdge/
- type: indicator
- pine_id: PUB;e4c4243ad5a346c9afd502489924dbba
- version: 1.0

## Description

🎯 WHAT IT DOES

Marks a specific, mechanical setup on the daily chart: a stock that gaps down hard, closes red, then loses the low of that gap-down day. The gap-day low becomes your level. The indicator watches it for several sessions and flags when price breaks below.

💡 THE LOGIC

A gap down is just an event. What matters is what happens after.

When a name gaps down, closes weak, and then breaks the low of that day, it's telling you the sellers who showed up on the gap are still in control and the weakness is following through.

This isn't looking for a bounce or a reversal. It marks the level where continued weakness gets confirmed.

🎨 HOW TO READ IT

The gap-day low is drawn as a dashed line and stays live for a set number of sessions. The color tells you the state at a glance:

🟡 Amber — new setup just formed
🔵 Blue — level is live and being watched
🔴 Red — price broke the level
⚪ Grey — expired without a break

A status panel in the corner spells out the current state in plain language, plus an optional volatility read.

⚙️ INPUTS

▸ Minimum gap-down size + red-body confirmation
▸ How many sessions the level stays live
▸ Minimum price filter
▸ Optional VIX regime gate — this type of setup historically weakens in high-volatility environments, so you can stand it down above a threshold
▸ Full color and display controls

📌 NOTES

Built for the daily timeframe on liquid US equities. The level is set from the prior session, so you can mark it and rest an order rather than waiting on a live signal.

This is a research and education tool for studying gap-down continuation behavior. It does not tell you to buy or sell anything. Not financial advice - do your own work and manage your own risk.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  DefinedEdge · Gap-Down Breakdown Level  (educational / research indicator)
//
//  Marks a specific, mechanical setup on the DAILY timeframe:
//    1) A "gap day" — price gaps down hard in the premarket and closes red.
//    2) The gap day's LOW becomes a level.
//    3) For the next few sessions, if price BREAKS that low intraday, the setup
//       triggers — a short at the level, covered the SAME DAY at the close.
//
//  This paints the level and the state. It does not tell you to trade. The
//  edge is same-day only (no overnight hold) and is regime-conditional — it
//  historically fades when broad volatility is elevated. Not financial advice.
//
//  Use on Daily bars. Works on any liquid US equity. The level is set from the
//  prior session — place a resting order at it rather than waiting for a signal.
// ─────────────────────────────────────────────────────────────────────────────
indicator("DefinedEdge · Gap-Down Breakdown Level", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ── Inputs ───────────────────────────────────────────────────────────────────
grpS   = "Setup thresholds"
gapPct = input.float(10.0, "Min overnight gap-down %",  minval = 1.0, step = 0.5, group = grpS, tooltip = "Today's open vs prior close. Default: 10%.")
redPct = input.float(1.0,  "Min red body % (close vs open)", minval = 0.0, step = 0.5, group = grpS, tooltip = "How far below its own open the gap day must close. Confirms sellers kept control.")
lifeBars = input.int(5, "Level stays live for N sessions", minval = 1, maxval = 20, group = grpS, tooltip = "The gap-day low is watched for this many sessions. Default: 5.")
minPrice = input.float(5.0, "Min price filter", minval = 0.0, step = 1.0, group = grpS, tooltip = "Skip sub-$5 names — untradeable on the short side (borrow).")

grpR   = "Regime gate (optional)"
useVix = input.bool(true, "Only arm setups when VIX below threshold", group = grpR, tooltip = "This setup historically fades in high-volatility regimes. Off = show every setup.")
vixMax = input.float(30.0, "VIX threshold", minval = 10.0, step = 1.0, group = grpR)

grpV   = "Visuals"
cSetup = input.color(color.new(#e0b64a, 0),  "Level / setup",   group = grpV)
cLive  = input.color(color.new(#4aa3e0, 0),  "Live (watching)", group = grpV)
cTrig  = input.color(color.new(#e05a5a, 0),  "Triggered",       group = grpV)
cDead  = input.color(color.new(#5a6070, 0),  "Expired / dead",  group = grpV)
showBg = input.bool(true, "Shade the day a setup triggers", group = grpV)

// ── Regime ───────────────────────────────────────────────────────────────────
vix     = request.security("CBOE:VIX", "D", close, ignore_invalid_symbol = true)
regimeOk = not useVix or na(vix) or vix <= vixMax

// ── Detect the gap day ───────────────────────────────────────────────────────
gapDown  = (open / close[1] - 1) * 100 <= -gapPct
redClose = (close / open - 1) * 100 <= -redPct
priceOk  = close >= minPrice
isGapDay = gapDown and redClose and priceOk and regimeOk

// ── State machine ────────────────────────────────────────────────────────────
// Track the single most-recent live level. (One at a time keeps the chart clean;
// this is the single-level teaching version.)
var float level      = na       // the gap-day low we're watching
var int   barsLeft   = 0        // sessions remaining in its life
var bool  triggered  = false    // has price broken the level during its life?
var line  lvlLine    = na
var label lvlLabel   = na

// New gap day resets the watched level (last one supersedes).
if isGapDay
    level     := low
    barsLeft  := lifeBars
    triggered := false
    if not na(lvlLine)
        line.delete(lvlLine)
    if not na(lvlLabel)
        label.delete(lvlLabel)
    lvlLine  := line.new(bar_index, level, bar_index + lifeBars, level, color = cSetup, width = 2, style = line.style_dashed)
    lvlLabel := label.new(bar_index, level, "Gap-down low  " + str.tostring(level, format.mintick), style = label.style_label_up, color = color.new(cSetup, 85), textcolor = cSetup, size = size.small)

// While a level is live, extend the line and test for a break.
brokeToday = false
if not na(level) and barsLeft > 0 and not isGapDay
    barsLeft -= 1
    line.set_x2(lvlLine, bar_index)
    if low <= level and not triggered
        triggered  := true
        brokeToday := true
        line.set_color(lvlLine, cTrig)
        label.set_textcolor(lvlLabel, cTrig)
        label.new(bar_index, level, "▼ break", style = label.style_label_down, color = color.new(cTrig, 80), textcolor = cTrig, size = size.small)
    else if not triggered
        line.set_color(lvlLine, cLive)
    // life ran out without a break → mark dead
    if barsLeft == 0 and not triggered
        line.set_color(lvlLine, cDead)
        label.set_textcolor(lvlLabel, cDead)

// ── Background on the trigger day ────────────────────────────────────────────
bgcolor(showBg and brokeToday ? color.new(cTrig, 90) : na, title = "Trigger day")

// ── Status panel ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 1, 4, bgcolor = color.new(#0d0f14, 6), border_color = color.new(#2b303c, 0), border_width = 1, frame_color = color.new(#3a4150, 0), frame_width = 1)
if barstate.islast
    stTxt = na(level) ? "NO SETUP" : triggered ? "TRIGGERED" : barsLeft > 0 ? "WATCHING" : "EXPIRED"
    stSub = na(level) ? "no active level" : triggered ? "short the break · cover the close" : barsLeft > 0 ? str.tostring(barsLeft) + " session" + (barsLeft == 1 ? "" : "s") + " remaining" : "level lapsed unbroken"
    acc   = na(level) ? #6b7280 : triggered ? #e05a5a : barsLeft > 0 ? #4aa3e0 : #6b7280

    // brand header
    table.cell(tbl, 0, 0, "  DEFINEDEDGE · gap-down breakdown  ", text_color = color.new(#8b93a3, 0), text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#1a1e27, 0))
    // status headline with dot
    table.cell(tbl, 0, 1, "  ●  " + stTxt + "  ", text_color = acc, text_size = size.large, text_halign = text.align_left)
    // status sub-line
    table.cell(tbl, 0, 2, "  " + stSub + "  ", text_color = color.new(#c8ccd4, 0), text_size = size.small, text_halign = text.align_left)
    // regime footer
    regTxt = not useVix ? "regime gate off" : na(vix) ? "VIX unavailable" : vix <= vixMax ? "VIX " + str.tostring(vix, "#.#") + "  ·  armed" : "VIX " + str.tostring(vix, "#.#") + "  ·  stood down"
    regCol = not useVix or na(vix) ? #6b7280 : vix <= vixMax ? #4ea86f : #e05a5a
    table.cell(tbl, 0, 3, "  " + regTxt + "  ", text_color = regCol, text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#14181f, 0))

// ── Alerts ───────────────────────────────────────────────────────────────────
// Set once with "Any alert() function call" — fires on the events below.
if isGapDay
    alert("Gap-down setup formed on " + syminfo.ticker + " — gap-day low " + str.tostring(low, format.mintick) + " now watched for " + str.tostring(lifeBars) + " sessions.", alert.freq_once_per_bar_close)
if brokeToday
    alert("Trigger on " + syminfo.ticker + " — broke the level " + str.tostring(level, format.mintick) + ". Setup: short the break, cover at today's close (no overnight hold).", alert.freq_once_per_bar_close)

// Plot-based alertcondition alternatives (for the classic alert dialog):
alertcondition(isGapDay,   title = "Setup formed",     message = "Gap-down setup formed on {{ticker}} — watching the gap-day low.")
alertcondition(brokeToday, title = "Trigger (break)",  message = "Trigger on {{ticker}} — level broken. Short the break, cover at the close.")
````
