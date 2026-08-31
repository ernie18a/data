<!-- tradingview-pine-id: PUB;6e449951cb2b404ebb534b80dec6d641 -->
<!-- tradingviewscripts-format: 1 -->
# Elite Hybrid ORB [Artillery]

Source: https://www.tradingview.com/script/SPvazS2g-Elite-Hybrid-ORB-Artillery/

## Description

Elite Hybrid ORB is a session opening-range breakout (ORB) strategy with a session-anchored VWAP, an EMA trend ribbon and a live status dashboard. This publication consolidates the previous per-market "MNQ Elite Hybrid" and "NKD Elite Hybrid" scripts into one configurable engine: the trading logic was identical in both, so instead of separate market-specific publications there is now a single script with a session preset input (US Open, Asia/Nikkei hours, or a fully custom window). Pick the preset that matches your market and session - nothing else about the engine changes.

WHAT IT DOES

1) Opening range - at the start of the selected session, the script records the high and low of the first N minutes (default 30). That range becomes the day's decision zone.
2) Breakout entries - after the range completes, a close above the range high plus a buffer (a percentage of the range width) signals a long; a close below the range low minus the buffer signals a short. A long-only mode is included for markets or sessions where you do not want to fade strength.
3) Bracket exits - every entry ships with a stop at the opposite side of the range and a take-profit at a multiple of the range width (default 1x). Positions are force-flattened 15 minutes before the session ends, so nothing is held past the window.
4) Guard rails - a maximum number of trades per session, a sanity cap on the opening-range width in ticks (abnormally wide ranges are skipped), and one position at a time.

The session VWAP and the 9/21 EMA ribbon are context layers: they do not gate entries, they show at a glance whether the breakout is travelling with or against the session's volume-weighted mean and the short-term trend.

WHY ONE SCRIPT INSTEAD OF TWO

The old MNQ and NKD versions shared this exact engine and differed only in the hard-coded session window and the long-only default. That is configuration, not logic, so it belongs in an input. The preset selects only the time window (all times anchored to New York): US Open covers 9:30-13:00 ET, Asia covers 19:00-23:00 ET (the Tokyo morning), and Custom exposes the window directly for any other market.

BACKTEST PROPERTIES (documented so you can judge the report)

The report uses realistic properties for one micro futures contract: 50,000 initial capital, fixed size of 1 contract, commission of 4.00 per contract per side, 2 ticks of slippage, 10% margin. Risk per trade is defined by the opening-range width (stop at the far side of the range), which on a micro contract is a small fraction of capital. The defaults shown were run on MNQ, 5-minute bars, US Open preset. Other symbols, sessions or timeframes need their own settings - especially the max-range-width cap, which should be set relative to the symbol's tick size. Backtest results are historical, vary with the tested window, and do not predict future performance.

WHAT YOU SEE ON THE CHART

- The opening range as a shaded zone with high/low lines, midpoint crosses and dotted buffer levels
- The session VWAP (gold) and the EMA 9/21 ribbon tinted by trend direction
- Entry labels with the exact entry, stop and target prices, plus the strategy's own trade markers
- Background tints for the range-building phase, the active trading window and the pre-close flatten warning
- A dashboard with the range status and width, VWAP bias, trend state, ATR, fill count, position and the active session preset

Each visual layer has its own on/off input.

BEHAVIOUR NOTES

Entries are evaluated on closed bars only (no intrabar order generation, no higher-timeframe requests, no lookahead). The opening range only becomes tradable after its build window has fully elapsed, so the zone does not repaint. Strategies in Pine v6 alert through their order fills - create an alert on the strategy and select order-fill events.

This is an educational and analytical tool for studying session breakout behaviour. It is not financial advice.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// Elite Hybrid ORB [Artillery] - session opening-range breakout engine
// with session VWAP, EMA trend ribbon and a live status dashboard.
// Consolidated edition: one configurable script replacing the separate
// per-market "MNQ Elite Hybrid" and "NKD Elite Hybrid" publications.
// Pick a session preset (US Open / Asia) or define any custom window.
// Educational tool. Not financial advice.
// ═══════════════════════════════════════════════════════════════════
strategy("Elite Hybrid ORB [Artillery]", shorttitle="EH ORB", overlay=true,
     initial_capital=50000, default_qty_type=strategy.fixed, default_qty_value=1,
     commission_type=strategy.commission.cash_per_contract, commission_value=4.0,
     slippage=2, margin_long=10, margin_short=10)

// ═══════════ COLORS ═══════════
var color C_BULL   = #00dcb4
var color C_BEAR   = #ff4976
var color C_GOLD   = #f0b90b
var color C_ICE    = #4fc3f7
var color C_SILVER = #8a919e
var color C_DIM    = #5f6368
var color C_PANEL  = #0e1726
var color C_BORDER = #1e3a5f
var color C_WHITE  = #e8eaed
var color C_PURPLE = #b388ff
var color C_CYAN   = #18ffff
var color C_ORANGE = #ff9100
var color C_NEON   = #76ff03

// ═══════════ INPUTS ═══════════
grpS = "Session"
i_preset       = input.string("US Open (RTH)", "Session preset", options=["US Open (RTH)", "Asia (Nikkei hours)", "Custom"], group=grpS, tooltip="All times are New York (ET). US Open = 9:30-13:00. Asia = 19:00-23:00 (Tokyo morning). Custom uses the fields below.")
i_cStartH      = input.int(9,  "Custom start hour ET", minval=0, maxval=23, group=grpS)
i_cStartM      = input.int(30, "Custom start minute", minval=0, maxval=59, group=grpS)
i_cEndH        = input.int(13, "Custom end hour ET", minval=1, maxval=24, group=grpS)
i_orbMin       = input.int(30, "ORB period (minutes)", minval=5, group=grpS)
i_maxTrades    = input.int(4, "Max trades per session", minval=1, group=grpS)
i_maxOrbTicks  = input.int(4000, "Max ORB width (ticks)", minval=2, group=grpS, tooltip="Sessions with an opening range wider than this are skipped as abnormal. Set relative to your symbol's tick size.")

grpE = "Entry"
i_orbBuf       = input.float(5.0, "ORB buffer (% of range)", minval=0.0, group=grpE)
i_longOnly     = input.bool(false, "Long only mode", group=grpE)

grpR = "Risk"
i_tpMult       = input.float(1.0, "TP multiplier (x ORB width)", minval=0.1, group=grpR)

grpV = "Visuals"
show_zone      = input.bool(true, "ORB zone and buffer lines", group=grpV)
show_vwap      = input.bool(true, "Session VWAP", group=grpV)
show_ribbon    = input.bool(true, "EMA trend ribbon", group=grpV)
show_bg        = input.bool(true, "Session backgrounds", group=grpV)
show_dash      = input.bool(true, "Dashboard", group=grpV)

// ═══════════ TIME ENGINE ═══════════
etH = hour(time, "America/New_York")
etM = minute(time, "America/New_York")
etT = etH * 60 + etM

sStart = i_preset == "US Open (RTH)" ? 570 : i_preset == "Asia (Nikkei hours)" ? 1140 : i_cStartH * 60 + i_cStartM
sEnd   = i_preset == "US Open (RTH)" ? 780 : i_preset == "Asia (Nikkei hours)" ? 1380 : i_cEndH * 60
orbEnd = sStart + i_orbMin
flatAt = sEnd - 15

inSess    = etT >= sStart and etT < sEnd
inOrb     = etT >= sStart and etT < orbEnd
inTrading = etT >= orbEnd and etT < flatAt
atFlatten = etT >= flatAt and etT < flatAt + 5

var bool wasSess = false
newSess = inSess and not wasSess
wasSess := inSess

// ═══════════ ORB ENGINE ═══════════
var float oH = na
var float oL = na
var bool oReady = false
var int tCount = 0
var float svNum = 0.0
var float svDen = 0.0
var float sVwap = na

if newSess
    oH := high
    oL := low
    oReady := false
    tCount := 0
    svNum := 0.0
    svDen := 0.0
    sVwap := na

if inOrb and not newSess
    oH := math.max(oH, high)
    oL := math.min(oL, low)

if inSess and etT >= orbEnd and not oReady and not na(oH) and not na(oL)
    oReady := true

if inSess
    svNum += ((high + low + close) / 3.0) * math.max(volume, 1.0)
    svDen += math.max(volume, 1.0)
    sVwap := svDen > 0 ? svNum / svDen : close

tick   = syminfo.mintick
oW     = oReady ? oH - oL : na
oTicks = oReady ? oW / tick : na
oMid   = oReady ? (oH + oL) / 2.0 : na
oBuf   = oReady ? oW * (i_orbBuf / 100.0) : na
oValid = oReady and not na(oTicks) and oTicks >= 2 and oTicks <= i_maxOrbTicks

// ═══════════ TREND CONTEXT ═══════════
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
atr14 = ta.atr(14)
emaBull = ema9 > ema21
emaBear = ema9 < ema21

// ═══════════ ENTRY SIGNALS ═══════════
orbLong  = oValid and close > oH + oBuf
orbShort = oValid and close < oL - oBuf and not i_longOnly

canTrade = inTrading and oReady and tCount < i_maxTrades and strategy.position_size == 0
goLong   = canTrade and orbLong
goShort  = canTrade and orbShort

// ═══════════ EXECUTION ═══════════
if goLong
    strategy.entry("Long", strategy.long)
    strategy.exit("XL", "Long", stop=oL, limit=close + oW * i_tpMult)
    tCount += 1

if goShort
    strategy.entry("Short", strategy.short)
    strategy.exit("XS", "Short", stop=oH, limit=close - oW * i_tpMult)
    tCount += 1

// Flatten before session end
if atFlatten and strategy.position_size != 0
    strategy.close_all("EOD")

// ═══════════ VISUALS ═══════════
pH = plot(show_zone and oReady ? oH : na, "ORB H", color=color.new(C_CYAN, 20), linewidth=2, style=plot.style_linebr)
pL = plot(show_zone and oReady ? oL : na, "ORB L", color=color.new(C_CYAN, 20), linewidth=2, style=plot.style_linebr)
fill(pH, pL, color=color.new(C_CYAN, 90), title="ORB Zone")

plot(show_zone and oReady ? oMid : na, "Mid", color=color.new(C_PURPLE, 50), style=plot.style_cross, linewidth=1)
plot(show_zone and oReady and not na(oBuf) ? oH + oBuf : na, "Buf H", color=color.new(C_NEON, 60), style=plot.style_circles, linewidth=1)
plot(show_zone and oReady and not na(oBuf) and not i_longOnly ? oL - oBuf : na, "Buf L", color=color.new(C_ORANGE, 60), style=plot.style_circles, linewidth=1)

plot(show_vwap and inSess ? sVwap : na, "VWAP", color=color.new(C_GOLD, 15), linewidth=2)

p9  = plot(show_ribbon and inSess ? ema9 : na, "EMA9", color=color.new(C_PURPLE, 40), linewidth=1)
p21 = plot(show_ribbon and inSess ? ema21 : na, "EMA21", color=color.new(C_ICE, 40), linewidth=1)
fill(p9, p21, color=emaBull ? color.new(C_BULL, 90) : color.new(C_BEAR, 90), title="EMA Ribbon")

if goLong
    label.new(bar_index, low,
         "LONG\n" + str.tostring(close, format.mintick) + "\n" +
         "SL: " + str.tostring(oL, format.mintick) + "\n" +
         "TP: " + str.tostring(close + oW * i_tpMult, format.mintick),
         style=label.style_label_up, color=C_BULL, textcolor=#0e1726, size=size.small)

if goShort
    label.new(bar_index, high,
         "SHORT\n" + str.tostring(close, format.mintick) + "\n" +
         "SL: " + str.tostring(oH, format.mintick) + "\n" +
         "TP: " + str.tostring(close - oW * i_tpMult, format.mintick),
         style=label.style_label_down, color=C_BEAR, textcolor=C_WHITE, size=size.small)

plotshape(goLong, "Buy", shape.diamond, location.belowbar, color=C_NEON, size=size.small)
plotshape(goShort, "Sell", shape.diamond, location.abovebar, color=C_ORANGE, size=size.small)

barcolor(strategy.position_size > 0 ? color.new(C_BULL, 30) :
     strategy.position_size < 0 ? color.new(C_BEAR, 30) :
     inOrb ? color.new(C_CYAN, 60) : na)

bgcolor(show_bg and inOrb ? color.new(C_CYAN, 95) : na, title="ORB Build")
bgcolor(show_bg and inTrading and oValid ? color.new(C_PURPLE, 97) : na, title="Trading Active")
bgcolor(show_bg and atFlatten ? color.new(C_ORANGE, 93) : na, title="Flatten Warning")

// ═══════════ DASHBOARD ═══════════
if show_dash and barstate.islast
    var table d = table.new(position.top_right, 4, 6, bgcolor=color.new(C_PANEL, 0), border_color=C_BORDER, border_width=1, frame_color=C_BORDER, frame_width=2)

    table.cell(d, 0, 0, "◆", text_color=C_NEON, text_size=size.small)
    table.cell(d, 1, 0, "ELITE", text_color=C_BULL, text_size=size.small)
    table.cell(d, 2, 0, "HYBRID", text_color=C_PURPLE, text_size=size.small)
    table.cell(d, 3, 0, syminfo.ticker, text_color=C_GOLD, text_size=size.small)

    table.cell(d, 0, 1, "ORB", text_color=C_DIM, text_size=size.tiny)
    table.cell(d, 1, 1, oReady ? str.tostring(oTicks, "#") + "t" : "...", text_color=oValid ? C_CYAN : C_DIM, text_size=size.tiny)
    table.cell(d, 2, 1, oValid ? "VALID" : "WAIT", text_color=oValid ? C_NEON : C_DIM, text_size=size.tiny)
    table.cell(d, 3, 1, oReady ? str.tostring(oW, format.mintick) : "---", text_color=C_ICE, text_size=size.tiny)

    table.cell(d, 0, 2, "VWAP", text_color=C_DIM, text_size=size.tiny)
    table.cell(d, 1, 2, not na(sVwap) ? str.tostring(sVwap, format.mintick) : "---", text_color=C_GOLD, text_size=size.tiny)
    vBias = not na(sVwap) ? (close > sVwap ? "ABOVE" : "BELOW") : "---"
    table.cell(d, 2, 2, vBias, text_color=not na(sVwap) ? (close > sVwap ? C_BULL : C_BEAR) : C_DIM, text_size=size.tiny)
    table.cell(d, 3, 2, emaBull ? "UP TREND" : emaBear ? "DN TREND" : "FLAT", text_color=emaBull ? C_BULL : emaBear ? C_BEAR : C_DIM, text_size=size.tiny)

    table.cell(d, 0, 3, "ATR", text_color=C_DIM, text_size=size.tiny)
    table.cell(d, 1, 3, not na(atr14) ? str.tostring(atr14, "#.#") : "---", text_color=C_SILVER, text_size=size.tiny)
    table.cell(d, 2, 3, "TPx" + str.tostring(i_tpMult, "#.#"), text_color=C_PURPLE, text_size=size.tiny)
    table.cell(d, 3, 3, i_longOnly ? "LONG ONLY" : "DUAL", text_color=i_longOnly ? C_NEON : C_CYAN, text_size=size.tiny)

    table.cell(d, 0, 4, "MODE", text_color=C_DIM, text_size=size.tiny)
    status = inOrb ? "BUILD" : inTrading ? "LIVE" : atFlatten ? "CLOSE" : "OFF"
    table.cell(d, 1, 4, status, text_color=inTrading ? C_NEON : inOrb ? C_GOLD : atFlatten ? C_ORANGE : C_DIM, text_size=size.tiny)
    table.cell(d, 2, 4, str.tostring(tCount) + "/" + str.tostring(i_maxTrades) + " FILLS", text_color=C_WHITE, text_size=size.tiny)
    posTxt = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    table.cell(d, 3, 4, posTxt, text_color=strategy.position_size > 0 ? C_BULL : strategy.position_size < 0 ? C_BEAR : C_DIM, text_size=size.tiny)

    sessTxt = i_preset == "US Open (RTH)" ? "US OPEN" : i_preset == "Asia (Nikkei hours)" ? "ASIA" : "CUSTOM"
    table.cell(d, 0, 5, timeframe.period, text_color=C_DIM, text_size=size.tiny)
    table.cell(d, 1, 5, sessTxt, text_color=C_PURPLE, text_size=size.tiny)
    table.cell(d, 2, 5, "", text_color=C_DIM, text_size=size.tiny)
    table.cell(d, 3, 5, "ARTILLERY", text_color=C_GOLD, text_size=size.tiny)
````
