# Liquidity Magnet Compass [forexobroker]

- url: https://www.tradingview.com/script/7wUzaia6-Liquidity-Magnet-Compass-forexobroker/
- type: indicator
- pine_id: PUB;1d06fe19a8ae4e7c9c46018627640428
- version: 1.0

## Description

Liquidity Magnet Compass maps every swing high and swing low on the chart as a liquidity zone where stop orders tend to cluster -- Buy-Side Liquidity (BSL) above highs and Sell-Side Liquidity (SSL) below lows. It then watches for the signature "liquidity sweep" event: a bar that pierces an untaken zone with a wick of at least the configured size and (optionally) closes back through the swept level. Every sweep flips the zone from active to swept and prints a directional signal with a projected target.

This indicator is designed for smart-money and ICT-style traders who enter reversals immediately after stop hunts. The compass dashboard tracks the net liquidity pull -- how much untaken liquidity sits above versus below current price -- so you always know which direction the market is most likely to reach for next.

🔶 CONCEPTS

In institutional order flow, price often gravitates toward clusters of resting stop orders because those stops represent guaranteed fills for large participants. Equal highs and equal lows are the most obvious such clusters. When price "sweeps" one of these levels -- wicks through it, triggers the stops, then reverses -- a real reversal is often beginning. The compass reading quantifies which side has more untaken liquidity: if more zones sit above price, the market is magnetically pulled higher; if more sit below, pulled lower. Signals fire when a sweep confirms the opposite of the dominant pull -- a classic mean-reversion setup.

🔶 HOW IT WORKS

- Detects pivot highs as BSL zones and pivot lows as SSL zones using the configured pivot length
- Draws each zone as an extending horizontal line with a BSL or SSL tag
- Detects a sweep when the bar's high/low pierces an unswept zone by at least the Min Sweep Size (in ATR units)
- Flips the swept zone to dashed-gray, marks it ⊘, and counts it in total sweeps
- Fires BUY on a sell-side sweep with volume confirmation; SELL on a buy-side sweep with volume confirmation
- Projects target lines to the next unswept zone on the opposite side

🔶 HOW TO USE

1. Add the indicator -- every pivot prints as a horizontal BSL (pink) or SSL (cyan) line extending right
2. Watch the compass dashboard (top-right) for active zone counts, nearest zones, magnet strength, and the dominant direction arrow
3. Green BUY triangle with "SSL SWEEP ↑" label fires on a sell-side sweep that volume confirms; pink SELL triangle fires on a buy-side sweep
4. A target line draws from the signal bar to the next unswept opposite-side zone -- use this as T1
5. Tighten Min Sweep Size (ATR) to only catch clean, decisive sweeps; loosen it to catch smaller sweeps on faster timeframes

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Persistent liquidity zone tracking with automatic sweep detection
- Compass needle overlay at the right edge showing live cardinal magnet reading

🔶 SETTINGS GUIDE

- Pivot Length -- Lookback for swing high/low detection that defines a liquidity pool
- Max Active Pools -- Cap on simultaneously tracked zones
- Pool Lookback Bars -- Maximum zone age before expiration
- Min Sweep Size (ATR) -- Wick piercing must exceed this ATR fraction to qualify as a sweep
- Volume SMA Length -- Baseline for volume confirmation
- Volume Confirm Multiplier -- Sweep bar volume vs SMA; 1.0 accepts average volume
- Signal Cooldown Bars -- Minimum bars between consecutive signals
- Require Rejection Close -- Enforce classical sweep (close back through level); relax to accept any pierce

🔶 ALERTS

- LMC Buy SSL Sweep -- Sell-side liquidity swept with volume, buy signal fired
- LMC Sell BSL Sweep -- Buy-side liquidity swept with volume, sell signal fired
- LMC Any Signal -- Any directional sweep signal
- LMC Sell-Side Swept -- Sell-side liquidity swept (before volume filter)
- LMC Buy-Side Swept -- Buy-side liquidity swept (before volume filter)
- LMC Strong North -- North magnet strength reaches 75+
- LMC Strong South -- South magnet strength reaches 75+
- LMC New Pool -- A new liquidity zone formed (new pivot confirmed)
- LMC Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past liquidity sweeps do not guarantee future price movements.
- Pool detection depends on pivot confirmation, which lags by the pivot length; pools only appear after a pivot is confirmed.
- Magnet strength is a heuristic based on active-zone count and distance, not a statistically calibrated probability of reversal.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Liquidity Magnet Compass [forexobroker]", shorttitle="LMC [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_zone   = "Liquidity Zones"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_pivotLen     = input.int(8, "Pivot Length", minval=3, maxval=25, group=g_zone, tooltip="Lookback for swing high/low that defines a liquidity pool")
int    i_maxPools     = input.int(14, "Max Active Pools", minval=4, maxval=30, group=g_zone)
int    i_lookback     = input.int(300, "Pool Lookback Bars", minval=50, maxval=1000, group=g_zone, tooltip="Prune pools older than this")
float  i_sweepMinAtr  = input.float(0.3, "Min Sweep Size (ATR)", minval=0.1, maxval=2.0, step=0.1, group=g_signal, tooltip="Sweep wick must exceed this ATR fraction")
int    i_volLen       = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_signal)
float  i_volMult      = input.float(1.0, "Volume Confirm Multiplier", minval=0.5, maxval=3.0, step=0.1, group=g_signal, tooltip="Sweep bar volume vs SMA")
int    i_cooldown     = input.int(3, "Signal Cooldown Bars", minval=1, maxval=30, group=g_signal)
bool   i_reqReject    = input.bool(true, "Require Rejection Close", group=g_signal, tooltip="Require close back through swept level (classic sweep)")
bool   i_showTable    = input.bool(true, "Show Compass Dashboard", group=g_visual)
bool   i_showZones    = input.bool(true, "Show Liquidity Zones", group=g_visual)
bool   i_showNeedle   = input.bool(true, "Show Compass Needle Label", group=g_visual)
bool   i_showGlow     = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor     = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor    = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── UDT: Liquidity Zone ───────────────────────────────────────────────────────
type LiqZone
    float price
    int   bornBar
    bool  isHigh
    bool  swept
    int   sweptBar
    line  lineRef
    label lblRef

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(14)
float volSma = ta.sma(volume, i_volLen)
float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low,   i_pivotLen, i_pivotLen)

var array<LiqZone> zones = array.new<LiqZone>()

// Add new pivot high → buy-side liquidity zone (stops above)
if not na(ph)
    line ln = i_showZones ? line.new(bar_index - i_pivotLen, ph, bar_index, ph, color=color.new(c_pink, 40), width=1, extend=extend.right) : na
    label lb = i_showZones ? label.new(bar_index, ph, "BSL", xloc=xloc.bar_index, color=color.new(c_pink, 70), textcolor=c_pink, style=label.style_label_left, size=size.tiny) : na
    array.push(zones, LiqZone.new(ph, bar_index - i_pivotLen, true, false, 0, ln, lb))
    if array.size(zones) > i_maxPools
        LiqZone old = array.shift(zones)
        if not na(old.lineRef)
            line.delete(old.lineRef)
        if not na(old.lblRef)
            label.delete(old.lblRef)

// Add new pivot low → sell-side liquidity zone (stops below)
if not na(pl)
    line ln = i_showZones ? line.new(bar_index - i_pivotLen, pl, bar_index, pl, color=color.new(c_cyan, 40), width=1, extend=extend.right) : na
    label lb = i_showZones ? label.new(bar_index, pl, "SSL", xloc=xloc.bar_index, color=color.new(c_cyan, 70), textcolor=c_cyan, style=label.style_label_left, size=size.tiny) : na
    array.push(zones, LiqZone.new(pl, bar_index - i_pivotLen, false, false, 0, ln, lb))
    if array.size(zones) > i_maxPools
        LiqZone old = array.shift(zones)
        if not na(old.lineRef)
            line.delete(old.lineRef)
        if not na(old.lblRef)
            label.delete(old.lblRef)

// Prune by age
if array.size(zones) > 0
    int i = 0
    while i < array.size(zones)
        LiqZone z = array.get(zones, i)
        if bar_index - z.bornBar > i_lookback
            if not na(z.lineRef)
                line.delete(z.lineRef)
            if not na(z.lblRef)
                label.delete(z.lblRef)
            array.remove(zones, i)
        else
            i := i + 1

// ─── SWEEP DETECTION ───────────────────────────────────────────────────────────
bool bullSweep = false  // sell-side liquidity (low) swept + closed back up
bool bearSweep = false  // buy-side liquidity (high) swept + closed back down
float sweptPx = na

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        LiqZone z = array.get(zones, i)
        if not z.swept
            // Bear sweep: high exceeds buy-side pool, close back below (if required)
            if z.isHigh and high > z.price and (high - z.price) >= atrVal * i_sweepMinAtr
                bool closedBack = close < z.price
                if closedBack or not i_reqReject
                    z.swept := true
                    z.sweptBar := bar_index
                    bearSweep := true
                    sweptPx := z.price
                    if not na(z.lineRef)
                        line.set_color(z.lineRef, color.new(color.gray, 70))
                        line.set_style(z.lineRef, line.style_dashed)
                    if not na(z.lblRef)
                        label.set_text(z.lblRef, "⊘ BSL")
                        label.set_textcolor(z.lblRef, color.gray)
            // Bull sweep: low exceeds sell-side pool, close back above (if required)
            if not z.isHigh and low < z.price and (z.price - low) >= atrVal * i_sweepMinAtr
                bool closedBack = close > z.price
                if closedBack or not i_reqReject
                    z.swept := true
                    z.sweptBar := bar_index
                    bullSweep := true
                    sweptPx := z.price
                    if not na(z.lineRef)
                        line.set_color(z.lineRef, color.new(color.gray, 70))
                        line.set_style(z.lineRef, line.style_dashed)
                    if not na(z.lblRef)
                        label.set_text(z.lblRef, "⊘ SSL")
                        label.set_textcolor(z.lblRef, color.gray)

// ─── COMPASS CARDINAL READING ──────────────────────────────────────────────────
int upActive = 0
int downActive = 0
int totalSwept = 0
float nearestUp = na
float nearestDown = na

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        LiqZone z = array.get(zones, i)
        if z.swept
            totalSwept := totalSwept + 1
        else
            if z.price > close
                upActive := upActive + 1
                if na(nearestUp) or z.price < nearestUp
                    nearestUp := z.price
            if z.price < close
                downActive := downActive + 1
                if na(nearestDown) or z.price > nearestDown
                    nearestDown := z.price

// Normalize pulls
float distUp   = not na(nearestUp)   ? (nearestUp - close) / atrVal : 100.0
float distDown = not na(nearestDown) ? (close - nearestDown) / atrVal : 100.0
float magnetN = distUp   > 0 ? math.min(float(upActive)   * 15.0 + 40.0 / distUp * 20.0, 100.0) : 0.0
float magnetS = distDown > 0 ? math.min(float(downActive) * 15.0 + 40.0 / distDown * 20.0, 100.0) : 0.0

string compassDir = magnetN > magnetS + 10.0 ? "↑ N" : magnetS > magnetN + 10.0 ? "↓ S" : "⊙ CTR"
color  compassCol = magnetN > magnetS + 10.0 ? c_pink : magnetS > magnetN + 10.0 ? c_cyan : c_gold

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool volConfirm = volume >= volSma * i_volMult
bool confirmed  = barstate.isconfirmed

bool buySignal  = bullSweep and volConfirm and cooldownOk and confirmed
bool sellSignal = bearSweep and volConfirm and cooldownOk and confirmed

// If both fire same bar, choose based on close direction
if buySignal and sellSignal
    if close >= open
        sellSignal := false
    else
        buySignal := false

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── STATS ─────────────────────────────────────────────────────────────────────
var int buyCount  = 0
var int sellCount = 0
var int totalSweeps = 0
if bullSweep or bearSweep
    totalSweeps := totalSweeps + 1
if buySignal
    buyCount := buyCount + 1
if sellSignal
    sellCount := sellCount + 1

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="SSL SWEEP ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BSL SWEEP ↓", textcolor=color.white)

// ─── VISUAL: Compass Needle Label at Last Bar ──────────────────────────────────
var label needleLbl = na
if i_showNeedle and barstate.islast
    if not na(needleLbl)
        label.delete(needleLbl)
    string needleTxt = compassDir + "\nN " + str.tostring(math.round(magnetN)) + " / S " + str.tostring(math.round(magnetS))
    needleLbl := label.new(bar_index + 3, close, needleTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(compassCol, 20), textcolor=color.white, size=size.small)

// ─── VISUAL: Signal Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.2, "SWEEP ↑\nSSL @ " + str.tostring(math.round(sweptPx, 4)) + "\nTarget: " + (not na(nearestUp) ? str.tostring(math.round(nearestUp, 4)) : "—"), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.2, "SWEEP ↓\nBSL @ " + str.tostring(math.round(sweptPx, 4)) + "\nTarget: " + (not na(nearestDown) ? str.tostring(math.round(nearestDown, 4)) : "—"), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

// ─── VISUAL: Target Lines on Signal ────────────────────────────────────────────
if buySignal and not na(nearestUp)
    line.new(bar_index, close, bar_index + 20, nearestUp, color=color.new(i_buyColor, 30), style=line.style_dotted, width=1, extend=extend.none)
if sellSignal and not na(nearestDown)
    line.new(bar_index, close, bar_index + 20, nearestDown, color=color.new(i_sellColor, 30), style=line.style_dotted, width=1, extend=extend.none)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : bullSweep ? color.new(c_cyan, 40) : bearSweep ? color.new(c_pink, 40) : na)
bgcolor(buySignal ? color.new(i_buyColor, 90) : sellSignal ? color.new(i_sellColor, 90) : na)

// ─── VISUAL: Compass Dashboard ─────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Liquidity Magnet Compass", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, compassDir, text_color=compassCol, text_size=size.normal)
    table.cell(dash, 0, 1, "Magnet N (up)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(math.round(magnetN)) + "/100", text_color=magnetN >= 60 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 2, "Magnet S (down)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(magnetS)) + "/100", text_color=magnetS >= 60 ? c_cyan : color.white, text_size=size.small)
    table.cell(dash, 0, 3, "Nearest BSL ↑", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, not na(nearestUp) ? str.tostring(math.round(nearestUp, 4)) : "—", text_color=c_pink, text_size=size.small)
    table.cell(dash, 0, 4, "Nearest SSL ↓", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, not na(nearestDown) ? str.tostring(math.round(nearestDown, 4)) : "—", text_color=c_cyan, text_size=size.small)
    table.cell(dash, 0, 5, "Active Pools", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(upActive + downActive) + " (↑" + str.tostring(upActive) + " ↓" + str.tostring(downActive) + ")", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Swept Pools", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(totalSwept), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Total Sweeps", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(totalSweeps), text_color=c_gold, text_size=size.small)
    table.cell(dash, 0, 8, "Buy Signals", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(buyCount), text_color=c_green, text_size=size.small)
    table.cell(dash, 0, 9, "Sell Signals", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(sellCount), text_color=c_pink, text_size=size.small)
    table.cell(dash, 0, 10, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"LMC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"sweptLevel":' + str.tostring(sweptPx) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LMC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"sweptLevel":' + str.tostring(sweptPx) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                "LMC Buy SSL Sweep",     "Liquidity Magnet BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,               "LMC Sell BSL Sweep",    "Liquidity Magnet SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,  "LMC Any Signal",        "Any liquidity sweep signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullSweep,                "LMC Sell-Side Swept",   "Sell-side liquidity swept on {{ticker}} {{interval}}")
alertcondition(bearSweep,                "LMC Buy-Side Swept",    "Buy-side liquidity swept on {{ticker}} {{interval}}")
alertcondition(magnetN >= 75,            "LMC Strong North",      "Strong overhead liquidity pull on {{ticker}} {{interval}}")
alertcondition(magnetS >= 75,            "LMC Strong South",      "Strong underhead liquidity pull on {{ticker}} {{interval}}")
alertcondition(not na(ph) or not na(pl), "LMC New Pool",          "New liquidity pool formed on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "LMC Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"LMC\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
