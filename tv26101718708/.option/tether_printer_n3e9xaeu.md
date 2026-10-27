# Tether Printer

- url: https://www.tradingview.com/script/N3e9XAEU-Tether-Printer/
- type: indicator
- pine_id: PUB;bc49852a76094575b92cbf81a732fe96
- version: 2.0

## Description

Tether Printer — Stablecoin Mint/Burn Histogram

Tether Printer tracks changes in USDT market cap and displays them as a histogram. Green bars mean Tether minted new USDT — fresh liquidity entering the crypto ecosystem. Red bars mean USDT was burned or redeemed — capital leaving. The height of each bar shows the size of the print. When the printer runs hot, crypto tends to follow.

The logic is simple. The indicator pulls the USDT market cap via CRYPTOCAP:USDT and calculates the bar-over-bar change. A positive delta means more USDT exists now than it did one bar ago — that's a mint. A negative delta means supply contracted — that's a burn. No complicated math, no lagging signals, just raw supply changes visualized as a histogram.

A gold SMA line smooths the noise to reveal the trend. When the SMA is above zero and rising, Tether is net printing over time — a tailwind for crypto prices. When the SMA dips below zero, net redemptions are underway and liquidity is draining. The SMA length is configurable (default 14 periods) so you can tune it to your preferred timeframe.

The configurable threshold lets you filter for significant prints only. Set it to 100M on a daily chart and only mints or burns above $100 million will appear at full brightness — everything below gets dimmed. Triangle markers flag significant events so they're visible at a glance even when scrolling through history. Set it to zero to see every change.

The info table in the corner shows the current state at a glance: whether the last bar was a MINT or BURN and the dollar amount, current market cap, SMA trend value, consecutive mint or burn streak count, and net flow over the last 30 bars. A 12-bar mint streak with +3.8B net 30-day flow tells a very different story than a 5-bar burn streak with negative net flow.

The indicator is not limited to USDT. Change the ticker input to CRYPTOCAP:USDC to track Circle's stablecoin, or CRYPTOCAP:FDUSD for First Digital. Any stablecoin with a market cap ticker on TradingView works.

Four alert conditions are included: significant mint, significant burn, any mint, and any burn. Set up alerts on a daily chart and you'll get notified the moment Tether fires up the printer.
Best used on a daily or 4-hour chart overlaid below BTC. When the histogram goes green and stays green, pay attention — the money printer is telling you something the price chart hasn't shown yet.

## Source Code

````pine
//@version=6
indicator("Tether Printer", shorttitle="TethPrt", overlay=false, format=format.volume)

// ═══════════════════════════════════════════════════════════════════════════════
// TETHER PRINTER (TethPrt) — Stablecoin Liquidity Flow Monitor — TheurgyLabs
// ═══════════════════════════════════════════════════════════════════════════════
//
// Tracks changes in stablecoin market cap and displays them as a histogram.
// Green bars = new stablecoins minted (liquidity injection). Red bars =
// burned/redeemed (liquidity withdrawal). Taller bars = bigger prints.
//
// Large mints tend to precede or coincide with bullish moves in crypto because
// freshly printed USDT typically flows into BTC and alts. Large burns signal
// capital leaving the crypto ecosystem.
//
// The SMA line smooths the noise to show the trend — is Tether net printing
// or net burning over time? Threshold highlights only significant events.
// Optional percentage mode normalizes prints relative to total supply.
//
// Works on any timeframe. Best on Daily or 4H for macro context.
//
// COMPANION TO: BTC Structure Tracker, BitcoinOnChain, RiskGauge
//
// ═══════════════════════════════════════════════════════════════════════════════

// ── INPUTS ──────────────────────────────────────────────────────────────────

string G_CORE = "══ CORE ══"
i_ticker    = input.string("CRYPTOCAP:USDT", "Primary Ticker", group=G_CORE, tooltip="CRYPTOCAP:USDT for Tether. CRYPTOCAP:USDC for Circle. CRYPTOCAP:FDUSD for First Digital.")
i_multiMode = input.bool(false, "Multi-Stablecoin Mode", group=G_CORE, tooltip="Sum primary + secondary ticker deltas for total stablecoin flow. Stronger macro signal than any single stablecoin.")
i_ticker2   = input.string("CRYPTOCAP:USDC", "Secondary Ticker", group=G_CORE, tooltip="Only used when Multi-Stablecoin Mode is enabled. USDT+USDC covers ~90% of stablecoin supply.")
i_smaLen    = input.int(14, "SMA Length", minval=2, maxval=200, group=G_CORE, tooltip="Smoothing period for the trend line. 14 = roughly 2 weeks on daily.")
i_threshold = input.float(500000000, "Significant Threshold", minval=0, group=G_CORE, tooltip="Highlight bars above this amount. In $ mode: 500000000 = 500M on daily. In % mode: try 0.25 (0.25%). 0 = disable threshold and show all bars at full color.")
i_pctMode   = input.bool(false, "Percentage Mode", group=G_CORE, tooltip="Show delta as % of market cap instead of absolute dollars. Normalizes across different market cap sizes.")

string G_STYLE = "══ STYLE ══"
i_mintCol   = input.color(#00FF88, "Mint Color", group=G_STYLE)
i_burnCol   = input.color(#FF4444, "Burn Color", group=G_STYLE)
i_smaCol    = input.color(#FFD700, "SMA Color", group=G_STYLE)
i_threshCol = input.color(#FFFFFF, "Threshold Color", group=G_STYLE)
i_dimAlpha  = input.int(70, "Sub-threshold Opacity %", minval=0, maxval=95, group=G_STYLE, tooltip="Bars below threshold are dimmed by this amount. 0 = full color, 95 = nearly invisible.")

string G_TABLE = "══ INFO TABLE ══"
i_showTable = input.bool(true, "Show Info Table", group=G_TABLE)
i_tablePos  = input.string("Bottom Right", "Table Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=G_TABLE)

// ── MARKET CAP DATA ─────────────────────────────────────────────────────────

mcap  = request.security(i_ticker, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
mcap2 = request.security(i_ticker2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// ── DELTA CALCULATION ───────────────────────────────────────────────────────

float rawDelta1 = not na(mcap) and not na(mcap[1]) ? mcap - mcap[1] : 0.0
float rawDelta2 = i_multiMode and not na(mcap2) and not na(mcap2[1]) ? mcap2 - mcap2[1] : 0.0
float rawDelta  = rawDelta1 + rawDelta2
float totalMcap = i_multiMode ? nz(mcap) + nz(mcap2) : nz(mcap)
float prevTotal = i_multiMode ? nz(mcap[1]) + nz(mcap2[1]) : nz(mcap[1])
float pctDelta  = prevTotal > 0 ? rawDelta / prevTotal * 100 : 0.0
float delta     = i_pctMode ? pctDelta : rawDelta
float absDelta  = math.abs(delta)
bool isMint     = delta > 0
bool isBurn     = delta < 0
bool isSignificant = absDelta >= i_threshold and i_threshold > 0

// ── SMOOTHING ───────────────────────────────────────────────────────────────

float deltaSma = ta.sma(delta, i_smaLen)

// ── CUMULATIVE NET (running total of mints - burns) ─────────────────────────

var float cumNet = 0.0
cumNet += rawDelta

// ── NET 7D / 30D ─────────────────────────────────────────────────────────────

float net7  = math.sum(rawDelta, 7)
float net30 = math.sum(rawDelta, 30)

// ── STREAK TRACKING ─────────────────────────────────────────────────────────

var int mintStreak = 0
var int burnStreak = 0
if isMint
    mintStreak += 1
    burnStreak := 0
else if isBurn
    burnStreak += 1
    mintStreak := 0
else
    mintStreak := 0
    burnStreak := 0

// ── SIGNIFICANT EVENT COUNTERS ──────────────────────────────────────────────

var int sigMints = 0
var int sigBurns = 0
if isSignificant and isMint
    sigMints += 1
if isSignificant and isBurn
    sigBurns += 1

// ── HISTOGRAM COLORS ────────────────────────────────────────────────────────

color barCol = na
if delta > 0
    barCol := i_threshold > 0 and not isSignificant ? color.new(i_mintCol, i_dimAlpha) : i_mintCol
else if delta < 0
    barCol := i_threshold > 0 and not isSignificant ? color.new(i_burnCol, i_dimAlpha) : i_burnCol
else
    barCol := color.new(color.gray, 80)

// ── PLOTS ───────────────────────────────────────────────────────────────────

plot(delta, "Mint/Burn Delta", color=barCol, style=plot.style_columns, linewidth=2)
plot(deltaSma, "Trend SMA", color=i_smaCol, linewidth=2)

// Zero line — close/close trick for consistent rendering
float _s = close / close
plot(0 * _s, "Zero", color=color.new(color.gray, 70), linewidth=1, style=plot.style_line)

// Threshold lines (only if threshold > 0)
plot(i_threshold > 0 ? i_threshold : na, "Upper Threshold", color=color.new(i_threshCol, 70), style=plot.style_line, linewidth=1)
plot(i_threshold > 0 ? -i_threshold : na, "Lower Threshold", color=color.new(i_threshCol, 70), style=plot.style_line, linewidth=1)

// Significant print markers
plotshape(isSignificant and isMint, "Big Mint", shape.triangleup, location.top, color.new(i_mintCol, 0), size=size.tiny)
plotshape(isSignificant and isBurn, "Big Burn", shape.triangledown, location.bottom, color.new(i_burnCol, 0), size=size.tiny)

// ── INFO TABLE ──────────────────────────────────────────────────────────────

tablePos = switch i_tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    =>                 position.bottom_right

f_fmt(float val) =>
    float a = math.abs(val)
    string sign = val >= 0 ? "+" : "-"
    a >= 1e12 ? sign + str.tostring(a / 1e12, "#.##") + "T" :
     a >= 1e9 ? sign + str.tostring(a / 1e9, "#.##") + "B" :
     a >= 1e6 ? sign + str.tostring(a / 1e6, "#.#") + "M" :
     a >= 1e3 ? sign + str.tostring(a / 1e3, "#.#") + "K" :
     sign + str.tostring(a, "#.#")

var table infoTable = table.new(tablePos, 4, 5, border_width=1, border_color=#333355, frame_width=1, frame_color=#333355)

if i_showTable and barstate.islast
    string ts = size.small
    color hBg  = #1a1a2e
    color rBg  = #0d0d1a
    color lbl  = #00FFFF
    color dim  = #888888

    // Row 0: Header
    color deltaCol = isMint ? color.new(i_mintCol, 30) : isBurn ? color.new(i_burnCol, 30) : #2a2a4a
    string deltaLabel = isMint ? "MINT" : isBurn ? "BURN" : "FLAT"
    string deltaStr = i_pctMode ? str.tostring(pctDelta, "#.##") + "%" : f_fmt(rawDelta)
    string tickerLabel = i_multiMode ? "MULTI" : i_ticker
    table.cell(infoTable, 0, 0, "TethPrt", bgcolor=#2a2a4a, text_color=lbl, text_size=ts)
    table.cell(infoTable, 1, 0, tickerLabel, bgcolor=hBg, text_color=color.white, text_size=ts)
    table.cell(infoTable, 2, 0, deltaLabel, bgcolor=deltaCol, text_color=color.white, text_size=ts)
    table.cell(infoTable, 3, 0, deltaStr, bgcolor=deltaCol, text_color=color.white, text_size=ts)

    // Row 1: Market Cap + SMA
    table.cell(infoTable, 0, 1, "Mkt Cap", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 1, 1, f_fmt(totalMcap), bgcolor=rBg, text_color=color.white, text_size=ts)
    table.cell(infoTable, 2, 1, "SMA(" + str.tostring(i_smaLen) + ")", bgcolor=hBg, text_color=lbl, text_size=ts)
    float smaDisp = deltaSma
    table.cell(infoTable, 3, 1, i_pctMode ? str.tostring(smaDisp, "#.##") + "%" : f_fmt(smaDisp), bgcolor=rBg, text_color=smaDisp > 0 ? #00FF88 : smaDisp < 0 ? #FF4444 : dim, text_size=ts)

    // Row 2: Streak + Net 7d
    string streakLabel = mintStreak > 0 ? str.tostring(mintStreak) + " mint" : burnStreak > 0 ? str.tostring(burnStreak) + " burn" : "—"
    table.cell(infoTable, 0, 2, "Streak", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 1, 2, streakLabel, bgcolor=rBg, text_color=mintStreak > 0 ? #00FF88 : burnStreak > 0 ? #FF4444 : dim, text_size=ts)
    table.cell(infoTable, 2, 2, "Net 7d", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 3, 2, f_fmt(net7), bgcolor=rBg, text_color=net7 > 0 ? #00FF88 : net7 < 0 ? #FF4444 : dim, text_size=ts)

    // Row 3: Net 30d + Net All
    table.cell(infoTable, 0, 3, "Net 30d", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 1, 3, f_fmt(net30), bgcolor=rBg, text_color=net30 > 0 ? #00FF88 : net30 < 0 ? #FF4444 : dim, text_size=ts)
    table.cell(infoTable, 2, 3, "Net All", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 3, 3, f_fmt(cumNet), bgcolor=rBg, text_color=cumNet > 0 ? #00FF88 : cumNet < 0 ? #FF4444 : dim, text_size=ts)

    // Row 4: Significant event counters
    table.cell(infoTable, 0, 4, "Sig ▲", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 1, 4, str.tostring(sigMints), bgcolor=rBg, text_color=sigMints > 0 ? #00FF88 : dim, text_size=ts)
    table.cell(infoTable, 2, 4, "Sig ▼", bgcolor=hBg, text_color=lbl, text_size=ts)
    table.cell(infoTable, 3, 4, str.tostring(sigBurns), bgcolor=rBg, text_color=sigBurns > 0 ? #FF4444 : dim, text_size=ts)

// ── ALERTS ──────────────────────────────────────────────────────────────────

alertcondition(isSignificant and isMint, title="Significant Mint", message="{{ticker}} {{interval}} TethPrt: Significant MINT detected — USDT printed")
alertcondition(isSignificant and isBurn, title="Significant Burn", message="{{ticker}} {{interval}} TethPrt: Significant BURN detected — USDT burned")
alertcondition(isMint, title="Any Mint", message="{{ticker}} {{interval}} TethPrt: MINT detected")
alertcondition(isBurn, title="Any Burn", message="{{ticker}} {{interval}} TethPrt: BURN detected")
alertcondition(mintStreak == 5, title="5+ Mint Streak", message="{{ticker}} {{interval}} TethPrt: 5 consecutive mints — sustained liquidity injection")
alertcondition(burnStreak == 5, title="5+ Burn Streak", message="{{ticker}} {{interval}} TethPrt: 5 consecutive burns — sustained liquidity withdrawal")
````
