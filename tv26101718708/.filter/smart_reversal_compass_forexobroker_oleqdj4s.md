# Smart Reversal Compass [forexobroker]

- url: https://www.tradingview.com/script/OleQDj4S-Smart-Reversal-Compass-forexobroker/
- type: indicator
- pine_id: PUB;2d0b0cf4ade04054b6abbab4e55ab0ac
- version: 1.0

## Description

Smart Reversal Compass combines four independent reversal signals -- RSI divergence, volume climax, reversal candle pattern (pin bar or engulfing), and support/resistance touch -- into a single cardinal compass reading. North means an up-reversal is forming; South means a down-reversal is forming. The compass only fires a signal when at least the configured minimum number of confluences (default 3 of 4) are lit simultaneously on the same bar.

This indicator is designed for traders who reject single-signal reversal trades because they understand that any one pattern is weak on its own, but the coincidence of four unrelated signals at the same price level is a genuinely rare and significant event. The dashboard shows every component's live state so you can see the compass "light up" in real time as conditions align.

🔶 CONCEPTS

Reversals almost never begin from a single condition. A pin bar in isolation is noise. Oversold RSI in isolation is noise. A volume spike in isolation is noise. But when a pin bar prints at a prior swing low, with volume spiking and RSI forming a higher low as price forms a lower low, the probability of a reversal rises dramatically. This indicator formalizes that truth: it asks four independent questions, tallies the answers, and only points a directional arrow when enough of them agree. The compass metaphor makes the reading intuitive -- you see where the market is pointing at a glance.

🔶 HOW IT WORKS

- Monitors RSI at each new pivot high and pivot low and compares to the previous pivot to detect divergence
- Checks if current bar volume exceeds the SMA by the climax multiplier
- Classifies the current bar as a pin bar (wick ratio >= threshold) or engulfing (opposite-side engulfing pattern)
- Tests if the bar's high or low is within ATR tolerance of the last pivot high or low (S/R touch)
- Tallies confluence counts; fires BUY if bull count >= minimum and exceeds bear count, SELL in the mirror case

🔶 HOW TO USE

1. Add the indicator -- the dashboard (top-right) shows every component state and live confluence tallies
2. Green BUY triangle with "↑ N" label fires when bullish confluences reach the minimum and exceed bearish; pink SELL triangle with "↓ S" fires for the mirror
3. The signal label shows which components were lit using ● (lit) and ○ (dark) markers for fast postmortem review
4. Increase Min Confluences to 4 for only textbook-perfect reversals; lower to 2 for more frequent but less confirmed signals
5. Adjust S/R Tolerance wider to allow approximate level touches; narrower for stricter S/R proximity

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Four-factor confluence tally with live per-component dashboard
- Cardinal compass reading (N/S) on both chart labels and dashboard header

🔶 SETTINGS GUIDE

- RSI Length -- Period for RSI divergence detection
- Divergence Lookback -- Maximum bars since last pivot to still qualify as divergence
- Pivot Length -- Lookback for swing high/low detection
- Volume SMA Length -- Baseline for volume climax detection
- Volume Climax Multiplier -- Volume must exceed this multiple of SMA
- Pin Bar Wick Ratio -- Rejection wick must be at least this fraction of total range
- S/R Tolerance (ATR) -- Distance in ATR units for S/R touch qualification
- Min Confluences -- Minimum lit confluences to trigger signal (2-4)
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- SRC Buy Compass N -- Bullish compass signal (N) fired
- SRC Sell Compass S -- Bearish compass signal (S) fired
- SRC Any Signal -- Any directional compass signal
- SRC Bull Divergence -- Bullish RSI divergence detected
- SRC Bear Divergence -- Bearish RSI divergence detected
- SRC Volume Climax -- Volume climax detected on the bar
- SRC Reversal Candle -- Pin bar or engulfing candle detected
- SRC Perfect 4/4 -- All four confluences lit simultaneously
- SRC Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past confluence setups do not guarantee future price movements.
- Divergence detection depends on confirmed pivots and therefore lags by the pivot length.
- A compass reading of N or S indicates reversal potential based on confluence, not a probability guarantee of a successful trade.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Smart Reversal Compass [forexobroker]", shorttitle="SRC [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_conf   = "Confluence Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_rsiLen      = input.int(14, "RSI Length", minval=5, maxval=50, group=g_conf)
int    i_divLookback = input.int(40, "Divergence Lookback", minval=10, maxval=100, group=g_conf, tooltip="Bars to scan back for divergence pivots")
int    i_pivotLen    = input.int(5, "Pivot Length", minval=2, maxval=15, group=g_conf, tooltip="Lookback for swing high/low detection")
int    i_volLen      = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_conf)
float  i_volClimax   = input.float(1.8, "Volume Climax Multiplier", minval=1.2, maxval=4.0, step=0.1, group=g_conf, tooltip="Volume must be this multiple of SMA")
float  i_pinRatio    = input.float(0.6, "Pin Bar Wick Ratio", minval=0.4, maxval=0.8, step=0.05, group=g_conf, tooltip="Rejection wick must be this fraction of total range")
float  i_srTol       = input.float(0.3, "S/R Tolerance (ATR)", minval=0.1, maxval=1.0, step=0.1, group=g_conf, tooltip="Distance in ATR units to qualify as S/R touch")
int    i_minConf     = input.int(3, "Min Confluences (0-4)", minval=2, maxval=4, group=g_signal, tooltip="Minimum number of confluences lit to fire signal")
int    i_cooldown    = input.int(15, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable   = input.bool(true, "Show Compass Dashboard", group=g_visual)
bool   i_showCompass = input.bool(true, "Show Compass Label on Chart", group=g_visual)
bool   i_showGlow    = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor    = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor   = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float rsiVal = ta.rsi(close, i_rsiLen)
float atrVal = ta.atr(14)
float volSma = ta.sma(volume, i_volLen)
float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low,   i_pivotLen, i_pivotLen)

// Track last 2 pivot highs + RSI for bearish divergence
var float ph1 = na
var float ph2 = na
var float rsiAtPh1 = na
var float rsiAtPh2 = na
var int phBar1 = 0
var int phBar2 = 0
if not na(ph)
    ph2 := ph1
    rsiAtPh2 := rsiAtPh1
    phBar2 := phBar1
    ph1 := ph
    rsiAtPh1 := rsiVal[i_pivotLen]
    phBar1 := bar_index - i_pivotLen

var float pl1 = na
var float pl2 = na
var float rsiAtPl1 = na
var float rsiAtPl2 = na
var int plBar1 = 0
var int plBar2 = 0
if not na(pl)
    pl2 := pl1
    rsiAtPl2 := rsiAtPl1
    plBar2 := plBar1
    pl1 := pl
    rsiAtPl1 := rsiVal[i_pivotLen]
    plBar1 := bar_index - i_pivotLen

// ─── CONFLUENCE 1: RSI Divergence ──────────────────────────────────────────────
bool bullDiv = not na(pl1) and not na(pl2) and (bar_index - plBar1) <= i_divLookback and pl1 < pl2 and rsiAtPl1 > rsiAtPl2
bool bearDiv = not na(ph1) and not na(ph2) and (bar_index - phBar1) <= i_divLookback and ph1 > ph2 and rsiAtPh1 < rsiAtPh2

// ─── CONFLUENCE 2: Volume Climax ───────────────────────────────────────────────
bool volClimax = volume >= volSma * i_volClimax

// ─── CONFLUENCE 3: Reversal Candle ─────────────────────────────────────────────
float barRange = high - low
float upperWick = high - math.max(close, open)
float lowerWick = math.min(close, open) - low
bool  bullPin = barRange > 0 and lowerWick / barRange >= i_pinRatio and close > open
bool  bearPin = barRange > 0 and upperWick / barRange >= i_pinRatio and close < open
bool  bullEngulf = close > open and close > high[1] and open < low[1]
bool  bearEngulf = close < open and close < low[1] and open > high[1]
bool  bullRev = bullPin or bullEngulf
bool  bearRev = bearPin or bearEngulf

// ─── CONFLUENCE 4: S/R Touch ───────────────────────────────────────────────────
float nearestHigh = not na(ph1) ? ph1 : na
float nearestLow  = not na(pl1) ? pl1 : na
bool  nearResist  = not na(nearestHigh) and math.abs(high - nearestHigh) <= atrVal * i_srTol
bool  nearSupport = not na(nearestLow)  and math.abs(low  - nearestLow)  <= atrVal * i_srTol

// ─── COMPASS SCORE ─────────────────────────────────────────────────────────────
int bullCount = (bullDiv ? 1 : 0) + (volClimax ? 1 : 0) + (bullRev ? 1 : 0) + (nearSupport ? 1 : 0)
int bearCount = (bearDiv ? 1 : 0) + (volClimax ? 1 : 0) + (bearRev ? 1 : 0) + (nearResist ? 1 : 0)

string compassDir = bullCount >= i_minConf and bullCount > bearCount ? "N" : bearCount >= i_minConf and bearCount > bullCount ? "S" : "—"
color  compassCol = compassDir == "N" ? c_green : compassDir == "S" ? c_pink : color.gray
string compassArrow = compassDir == "N" ? "↑" : compassDir == "S" ? "↓" : "◎"

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool rawBuy  = bullCount >= i_minConf and bullCount > bearCount and cooldownOk and confirmed
bool rawSell = bearCount >= i_minConf and bearCount > bullCount and cooldownOk and confirmed

bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="↑ N",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="↓ S", textcolor=color.white)

// ─── VISUAL: Compass Label on Signal Bar ───────────────────────────────────────
if i_showCompass and buySignal
    label.new(bar_index, low - atrVal * 1.5, "↑ N " + str.tostring(bullCount) + "/4\nDIV:" + (bullDiv ? "●" : "○") + " VOL:" + (volClimax ? "●" : "○") + "\nREV:" + (bullRev ? "●" : "○") + " S/R:" + (nearSupport ? "●" : "○"), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if i_showCompass and sellSignal
    label.new(bar_index, high + atrVal * 1.5, "↓ S " + str.tostring(bearCount) + "/4\nDIV:" + (bearDiv ? "●" : "○") + " VOL:" + (volClimax ? "●" : "○") + "\nREV:" + (bearRev ? "●" : "○") + " S/R:" + (nearResist ? "●" : "○"), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(buySignal ? color.new(i_buyColor, 93) : sellSignal ? color.new(i_sellColor, 93) : na)

// ─── VISUAL: Compass Dashboard ─────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Smart Reversal Compass", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, compassArrow + " " + compassDir, text_color=compassCol, text_size=size.normal)
    table.cell(dash, 0, 1, "Bull Confluences", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(bullCount) + "/4", text_color=bullCount >= i_minConf ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 2, "Bear Confluences", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(bearCount) + "/4", text_color=bearCount >= i_minConf ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 3, "RSI Div (Bull/Bear)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, (bullDiv ? "● " : "○ ") + " / " + (bearDiv ? " ●" : " ○"), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Volume Climax", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, volClimax ? "● YES" : "○ NO", text_color=volClimax ? c_gold : color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Bull Reversal Bar", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, bullRev ? "● " + (bullEngulf ? "ENGULF" : "PIN") : "○ NO", text_color=bullRev ? c_green : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Bear Reversal Bar", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, bearRev ? "● " + (bearEngulf ? "ENGULF" : "PIN") : "○ NO", text_color=bearRev ? c_pink : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "At Support", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, nearSupport ? "● YES" : "○ NO", text_color=nearSupport ? c_cyan : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "At Resistance", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, nearResist ? "● YES" : "○ NO", text_color=nearResist ? c_purple : color.gray, text_size=size.small)
    table.cell(dash, 0, 9, "RSI", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(math.round(rsiVal, 1)), text_color=rsiVal > 70 ? c_pink : rsiVal < 30 ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 10, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"SRC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"conf":' + str.tostring(bullCount) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"SRC","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"conf":' + str.tostring(bearCount) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                 "SRC Buy Compass N",     "Smart Reversal Compass BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                "SRC Sell Compass S",    "Smart Reversal Compass SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,   "SRC Any Signal",        "Any reversal compass signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullDiv,                   "SRC Bull Divergence",   "Bullish RSI divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv,                   "SRC Bear Divergence",   "Bearish RSI divergence on {{ticker}} {{interval}}")
alertcondition(volClimax,                 "SRC Volume Climax",     "Volume climax detected on {{ticker}} {{interval}}")
alertcondition(bullRev or bearRev,        "SRC Reversal Candle",   "Reversal candle printed on {{ticker}} {{interval}}")
alertcondition(bullCount == 4 or bearCount == 4, "SRC Perfect 4/4","All four confluences lit on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,   "SRC Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"SRC\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
