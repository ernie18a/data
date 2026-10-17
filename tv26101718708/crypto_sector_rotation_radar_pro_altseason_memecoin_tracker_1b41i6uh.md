# Crypto Sector Rotation Radar Pro | Altseason & Memecoin Tracker

- url: https://www.tradingview.com/script/1b41I6UH-Crypto-Sector-Rotation-Radar-Pro-Altseason-Memecoin-Tracker/
- type: indicator
- pine_id: PUB;600a1840bb844d4bae58f095e1237c35
- version: 1.0

## Description

A live cross-sectional ranking of 7 crypto sectors that answers a question every alt and memecoin trader asks: where is capital actually flowing right now?

Most existing sector-rotation visualizations on TradingView normalize each sector independently against its own historical range. That approach has a fundamental flaw — when one sector reads "80" and another reads "70," those numbers are not comparable to each other, because each one is relative to its own past, not to the other sectors. You cannot rank sectors that way.

This script does it differently. Every sector's momentum is measured against the same benchmark — TOTAL crypto market cap — so the resulting scores are directly comparable. Then sectors are ranked #1 through #7 in real time. The output is a single dashboard table that tells you, at a glance, which sectors are leading, which are lagging, and which are accelerating or fading.


▸ WHAT IT DOES

For each of 7 crypto sectors, the script:

1. Computes the sector-cap-to-TOTAL ratio
2. Measures rate-of-change of that ratio across three windows (default: 7, 14, 30 bars)
3. Blends the three windows by user-configurable weights into a single raw RS reading
4. Cross-sectionally ranks all 7 sectors against each other (#1 strongest, #7 weakest)
5. Converts rank to a 0–100 RS Score (rank 1 → 100, rank 4 → 50, rank 7 → 0)
6. Tracks rank change over 3 and 7 bars to surface acceleration and rotation
7. Classifies each sector's flow as IN, OUT, or NEU based on rank and momentum

All of this is rendered in a sortable dashboard table, with optional smoothed RS lines plotted below for historical pattern context.


▸ SECTORS TRACKED

  •  🚀 Memecoins       (CRYPTOCAP:MEME.C)
  •  Ξ  Ethereum Eco   (CRYPTOCAP:ETHEREUM.C)
  •  🏛 RWA              (CRYPTOCAP:RWA.C)
  •  🤖 AI               (CRYPTOCAP:AI.C)
  •  ◎  Solana Eco     (CRYPTOCAP:SOLANA.C)
  •  🏢 Exchange Tokens (CRYPTOCAP:EXCHANGES.C)
  •  🏦 DeFi             (CRYPTOCAP:TOTALDEFI)

The benchmark for all RS calculations is CRYPTOCAP:TOTAL.


▸ HOW TO READ THE TABLE

Each row shows one sector with six columns:

  •  SECTOR — emoji and name
  •  RANK  — current cross-sectional rank (#1 = strongest, #7 = weakest)
  •  RS    — 0–100 score derived from rank
  •  Δ3D   — rank change over the last 3 bars, with a heat badge (🔥 ▲ ↗ · ↘ ▼ ❄️)
  •  Δ7D   — rank change over the last 7 bars
  •  FLOW  — IN (top 3 + positive momentum), OUT (bottom 3 + negative momentum), NEU (mixed)

A footer row summarizes the regime in plain language:
  •  🔥 Memes in Top 2 — Meme Rotation
  •  ⚠️ Risk-Off Regime — defensive sectors leading while risk-on lagging
  •  ❄️ Memes in Bottom 2 — sector weak
  •  Mixed Rotation — no clear leader pattern

The memecoin row is highlighted by default to make it stand out at a glance for memecoin-focused traders. This can be toggled off in settings.


▸ HOW TO READ THE LINES

Below the table, each sector's RS Score is plotted as a smoothed line using EMA smoothing (default: 5 bars). Because the raw RS Score takes only 7 discrete values (rank-derived), a small amount of smoothing turns step-function jumps into readable curves while preserving the cross-sectional comparability.

  •  Lines above 83 = sector is currently in top 2 by RS
  •  Lines below 17 = sector is currently in bottom 2 by RS
  •  Lines crossing through the middle band = active rotation in or out
  •  Multiple lines bunched together = no clear sector leadership

Smoothing length is user-adjustable. Set to 1 for raw stepped lines.


▸ INPUT SETTINGS

Calculation:
  •  Calculation Timeframe — default Daily, locked regardless of chart TF
  •  Short / Medium / Long Window — three momentum lookbacks (default 7, 14, 30 bars)
  •  Three weight inputs to blend the windows (default 40 / 35 / 25 %)

Display:
  •  Toggle the dashboard table
  •  Choose table position and size
  •  Toggle the memecoin row highlight
  •  Toggle the RS score lines
  •  Adjust line smoothing (EMA length)

Colors — all six dashboard color states are individually configurable.


▸ BUILT-IN ALERTS

The script defines 17 alert conditions, available through TradingView's standard Add Alert dialog:

Per-sector surges (rank improved by 2+ over 3 bars):
  •  🚀 MEME surged
  •  Ξ  Ethereum surged
  •  🏛 RWA surged
  •  🤖 AI surged
  •  ◎  Solana surged
  •  🏢 Exchange surged
  •  🏦 DeFi surged

Per-sector drops (rank declined by 2+ over 3 bars):
  •  same 7 sectors, mirrored

Memecoin-specific:
  •  🔥 MEMES entered Top 2
  •  ❄️ MEMES dropped to Bottom 2

Regime:
  •  ⚠️ Risk-Off Regime — defensives leading, risk-on lagging


▸ HOW TO USE IT

The script pulls all of its data from CRYPTOCAP indices via request.security, so the chart symbol does not affect the calculation. Putting it on CRYPTOCAP:TOTAL on the Daily timeframe gives the cleanest macro context, but the radar will work identically on any chart.

Default timeframe is Daily, which is appropriate for sector-rotation analysis. Higher-timeframe rotations are typically slower-moving signals; lower timeframes will produce noisier rankings.


▸ LIMITATIONS AND HONEST CAVEATS

  •  This is a contextual / regime tool, not a predictive one. The radar tells you the current state of cross-sector capital flow. It does not predict which sector will lead next.

  •  Rank is a relative measure. A sector at rank #1 with weak absolute momentum is still rank #1 — but the broader market may be in a downtrend. Pair this with absolute price/cap context.

  •  When two or more sectors have very similar momentum, ranks can flip frequently. The Δ3D and Δ7D columns help filter noise from real rotation.

  •  Sector definitions follow TradingView's CRYPTOCAP indices, which themselves are subject to TradingView's classification logic. If a token is reclassified, all sectors will reflect that change.

  •  RS Score is derived from rank, so it can only take 7 discrete values (0, 16.7, 33.3, 50, 66.7, 83.3, 100). The smoothing on the plotted lines is purely cosmetic; the table values are exact.


▸ TECHNICAL NOTES

  •  Pine Script v6
  •  Open-source under the Mozilla Public License 2.0
  •  Uses 8 request.security calls (well below the 40-call limit), all to official CRYPTOCAP indices
  •  No repainting — all calculations use confirmed bar close values from the requested timeframe
  •  Designed to coexist with other indicators on the same chart


▸ DISCLAIMER

For educational and informational purposes only. This script is a market analysis tool, not financial advice. Nothing here constitutes a recommendation to buy or sell any asset. Past behavior of the radar in historical data is not a guarantee of future behavior. Cryptocurrency markets are highly volatile and can result in substantial losses. Always do your own research and trade with risk you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DeltaSpeedEdge

// ─────────────────────────────────────────────────────────────────────────────
//  Crypto Sector Rotation Radar Pro | Altseason & Memecoin Tracker
//  v1.0.0  —  Free open-source indicator from the Memecoin Momentum Suite
//
//  Ranks 7 crypto sectors in real time by cross-sectional momentum. Unlike
//  tools that normalize each sector to its own history (which makes
//  "sector A at 80" meaningless against "sector B at 80"), this script
//  benchmarks every sector against the TOTAL market cap so that ranks,
//  scores, and deltas are directly comparable across sectors.
//
//  Sectors tracked:
//    🚀 Memecoins       (CRYPTOCAP:MEME.C)
//    🤖 AI              (CRYPTOCAP:AI.C)
//    🏛️ RWA             (CRYPTOCAP:RWA.C)
//    🏦 DeFi            (CRYPTOCAP:TOTALDEFI)
//    Ξ  Ethereum Eco   (CRYPTOCAP:ETHEREUM.C)
//    ◎  Solana Eco     (CRYPTOCAP:SOLANA.C)
//    🏢 Exchange Tokens (CRYPTOCAP:EXCHANGES.C)
//
//  For educational and informational purposes only. Not financial advice.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Crypto Sector Rotation Radar Pro | Altseason & Memecoin Tracker", shorttitle="📊 Sector Rotation", overlay=false, precision=1)

// ═════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═════════════════════════════════════════════════════════════════════════════

grpCalc = "═══ Calculation Settings ═══"
tfInput = input.timeframe("D", "Calculation Timeframe", group=grpCalc, tooltip="Daily is recommended for sector rotation analysis. The script pulls all data from this timeframe regardless of your chart's TF.")
b1 = input.int(7,  "Short Window (bars)",  minval=2, maxval=30,  group=grpCalc, tooltip="Short-term momentum window (default 7 bars / ~1 week on daily)")
b2 = input.int(14, "Medium Window (bars)", minval=5, maxval=60,  group=grpCalc, tooltip="Medium-term momentum window (default 14 bars / ~2 weeks on daily)")
b3 = input.int(30, "Long Window (bars)",   minval=10, maxval=120, group=grpCalc, tooltip="Long-term momentum window (default 30 bars / ~1 month on daily)")
w1 = input.float(40, "Short Window Weight %",  minval=0, maxval=100, step=5, group=grpCalc, tooltip="Weight applied to the short window. Higher = more reactive.")
w2 = input.float(35, "Medium Window Weight %", minval=0, maxval=100, step=5, group=grpCalc, tooltip="Weight applied to the medium window.")
w3 = input.float(25, "Long Window Weight %",   minval=0, maxval=100, step=5, group=grpCalc, tooltip="Weight applied to the long window. Higher = smoother.")

grpDisplay = "═══ Display ═══"
showTable    = input.bool(true, "Show Dashboard Table", group=grpDisplay)
tablePos     = input.string("top_right", "Table Position", options=["top_right", "top_left", "middle_right", "middle_left", "bottom_right", "bottom_left"], group=grpDisplay)
tableSize    = input.string("normal",    "Table Size",     options=["tiny", "small", "normal", "large", "huge"], group=grpDisplay)
highlightMeme = input.bool(true, "Highlight Memecoin Row", group=grpDisplay, tooltip="Adds a subtle highlight to the memecoin row to make it stand out for memecoin traders.")
showLines    = input.bool(true, "Show RS Score Lines", group=grpDisplay, tooltip="Plots all 7 sector RS scores as smoothed lines in the sub-pane below the table.")
lineSmoothing = input.int(5, "RS Line Smoothing (EMA bars)", minval=1, maxval=30, group=grpDisplay, tooltip="EMA smoothing applied to the RS score lines so they flow instead of stepping. The table values stay raw and exact.")

grpColors = "═══ Colors ═══"
colHot   = input.color(#00C853, "Hot (improving)",       group=grpColors)
colCool  = input.color(#F44336, "Cool (declining)",      group=grpColors)
colWarm  = input.color(#FF9800, "Warm (slight up)",      group=grpColors)
colMild  = input.color(#90A4AE, "Mild (slight down)",    group=grpColors)
colNeu   = input.color(#78909C, "Neutral",               group=grpColors)
colMeme  = input.color(color.new(#FFD600, 80), "Memecoin Highlight", group=grpColors)

// ═════════════════════════════════════════════════════════════════════════════
//  DATA FETCH — 8 request.security calls (well under the 40-call limit)
// ═════════════════════════════════════════════════════════════════════════════

totalC = request.security("CRYPTOCAP:TOTAL",       tfInput, close, lookahead=barmerge.lookahead_off)
memeC  = request.security("CRYPTOCAP:MEME.C",      tfInput, close, lookahead=barmerge.lookahead_off)
aiC    = request.security("CRYPTOCAP:AI.C",        tfInput, close, lookahead=barmerge.lookahead_off)
rwaC   = request.security("CRYPTOCAP:RWA.C",       tfInput, close, lookahead=barmerge.lookahead_off)
defiC  = request.security("CRYPTOCAP:TOTALDEFI",   tfInput, close, lookahead=barmerge.lookahead_off)
ethC   = request.security("CRYPTOCAP:ETHEREUM.C",  tfInput, close, lookahead=barmerge.lookahead_off)
solC   = request.security("CRYPTOCAP:SOLANA.C",    tfInput, close, lookahead=barmerge.lookahead_off)
exchC  = request.security("CRYPTOCAP:EXCHANGES.C", tfInput, close, lookahead=barmerge.lookahead_off)

// ═════════════════════════════════════════════════════════════════════════════
//  RAW RS CALCULATION
//  For each sector: compute (sector / TOTAL) ratio, then blend rate-of-change
//  across three windows. Result is the sector's excess momentum vs the market.
// ═════════════════════════════════════════════════════════════════════════════

totalWeight = w1 + w2 + w3

calcRsRaw(sectorClose) =>
    ratio = sectorClose / totalC
    r1 = ta.roc(ratio, b1)
    r2 = ta.roc(ratio, b2)
    r3 = ta.roc(ratio, b3)
    totalWeight > 0 ? (r1 * w1 + r2 * w2 + r3 * w3) / totalWeight : 0.0

memeRaw  = calcRsRaw(memeC)
aiRaw    = calcRsRaw(aiC)
rwaRaw   = calcRsRaw(rwaC)
defiRaw  = calcRsRaw(defiC)
ethRaw   = calcRsRaw(ethC)
solRaw   = calcRsRaw(solC)
exchRaw  = calcRsRaw(exchC)

// ═════════════════════════════════════════════════════════════════════════════
//  CROSS-SECTIONAL RANKING
//  Rank 1 = strongest sector, Rank 7 = weakest. Built by counting how many
//  sectors have a higher raw RS than each given sector.
// ═════════════════════════════════════════════════════════════════════════════

rankOf(target, a, b, c, d, e, f) =>
    var int rank = 1
    rank := 1
    rank := a > target ? rank + 1 : rank
    rank := b > target ? rank + 1 : rank
    rank := c > target ? rank + 1 : rank
    rank := d > target ? rank + 1 : rank
    rank := e > target ? rank + 1 : rank
    rank := f > target ? rank + 1 : rank
    rank

memeRank = rankOf(memeRaw, aiRaw, rwaRaw, defiRaw, ethRaw, solRaw, exchRaw)
aiRank   = rankOf(aiRaw,   memeRaw, rwaRaw, defiRaw, ethRaw, solRaw, exchRaw)
rwaRank  = rankOf(rwaRaw,  memeRaw, aiRaw, defiRaw, ethRaw, solRaw, exchRaw)
defiRank = rankOf(defiRaw, memeRaw, aiRaw, rwaRaw, ethRaw, solRaw, exchRaw)
ethRank  = rankOf(ethRaw,  memeRaw, aiRaw, rwaRaw, defiRaw, solRaw, exchRaw)
solRank  = rankOf(solRaw,  memeRaw, aiRaw, rwaRaw, defiRaw, ethRaw, exchRaw)
exchRank = rankOf(exchRaw, memeRaw, aiRaw, rwaRaw, defiRaw, ethRaw, solRaw)

// ═════════════════════════════════════════════════════════════════════════════
//  RS SCORE (0–100)
//  Convert rank to a clean 0–100 score: rank 1 → 100, rank 4 → 50, rank 7 → 0.
// ═════════════════════════════════════════════════════════════════════════════

rankToScore(r) => (7.0 - r) / 6.0 * 100.0

memeScore = rankToScore(memeRank)
aiScore   = rankToScore(aiRank)
rwaScore  = rankToScore(rwaRank)
defiScore = rankToScore(defiRank)
ethScore  = rankToScore(ethRank)
solScore  = rankToScore(solRank)
exchScore = rankToScore(exchRank)

// ═════════════════════════════════════════════════════════════════════════════
//  DELTAS — rank change vs 3 and 7 bars ago (positive = improving)
// ═════════════════════════════════════════════════════════════════════════════

memeD3 = nz(memeRank[3]) - memeRank
aiD3   = nz(aiRank[3])   - aiRank
rwaD3  = nz(rwaRank[3])  - rwaRank
defiD3 = nz(defiRank[3]) - defiRank
ethD3  = nz(ethRank[3])  - ethRank
solD3  = nz(solRank[3])  - solRank
exchD3 = nz(exchRank[3]) - exchRank

memeD7 = nz(memeRank[7]) - memeRank
aiD7   = nz(aiRank[7])   - aiRank
rwaD7  = nz(rwaRank[7])  - rwaRank
defiD7 = nz(defiRank[7]) - defiRank
ethD7  = nz(ethRank[7])  - ethRank
solD7  = nz(solRank[7])  - solRank
exchD7 = nz(exchRank[7]) - exchRank

// ═════════════════════════════════════════════════════════════════════════════
//  FLOW CLASSIFICATION
//  IN  = top-half rank with positive momentum
//  OUT = bottom-half rank with negative momentum
//  NEU = mixed signals
// ═════════════════════════════════════════════════════════════════════════════

flowOf(rank, raw) =>
    switch
        rank <= 3 and raw > 0 => "IN"
        rank >= 5 and raw < 0 => "OUT"
        =>                       "NEU"

memeFlow = flowOf(memeRank, memeRaw)
aiFlow   = flowOf(aiRank,   aiRaw)
rwaFlow  = flowOf(rwaRank,  rwaRaw)
defiFlow = flowOf(defiRank, defiRaw)
ethFlow  = flowOf(ethRank,  ethRaw)
solFlow  = flowOf(solRank,  solRaw)
exchFlow = flowOf(exchRank, exchRaw)

// ═════════════════════════════════════════════════════════════════════════════
//  HEAT BADGES — emoji indicator for big rank moves
// ═════════════════════════════════════════════════════════════════════════════

heatBadge(d3) =>
    switch
        d3 >= 3  => "🔥"
        d3 >= 2  => "▲"
        d3 >= 1  => "↗"
        d3 <= -3 => "❄️"
        d3 <= -2 => "▼"
        d3 <= -1 => "↘"
        =>          "·"

// ═════════════════════════════════════════════════════════════════════════════
//  RANK COLOR
// ═════════════════════════════════════════════════════════════════════════════

rankColor(r) =>
    switch
        r == 1 => colHot
        r == 2 => colHot
        r == 3 => colWarm
        r == 4 => colNeu
        r == 5 => colMild
        r == 6 => colCool
        =>        colCool

deltaColor(d) =>
    switch
        d >= 2  => colHot
        d == 1  => colWarm
        d == 0  => colNeu
        d == -1 => colMild
        =>         colCool

flowColor(f) =>
    switch f
        "IN"  => colHot
        "OUT" => colCool
        =>       colNeu

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD TABLE
// ═════════════════════════════════════════════════════════════════════════════

posLookup = switch tablePos
    "top_right"     => position.top_right
    "top_left"      => position.top_left
    "middle_right"  => position.middle_right
    "middle_left"   => position.middle_left
    "bottom_right"  => position.bottom_right
    =>                 position.bottom_left

sizeLookup = switch tableSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    =>          size.huge

var table dash = table.new(posLookup, 7, 10, border_width=1)

drawRow(int row, string emoji, string sectorName, int rnk, float scr, int d3, int d7, string flow, bool highlight) =>
    bg = highlight ? colMeme : color.new(#1A1A1A, 70)
    table.cell(dash, 0, row, emoji + " " + sectorName, text_color=color.white, text_size=sizeLookup, bgcolor=bg)
    table.cell(dash, 1, row, "#" + str.tostring(rnk),  text_color=rankColor(rnk),  text_size=sizeLookup, bgcolor=bg)
    table.cell(dash, 2, row, str.tostring(scr, "#"),   text_color=rankColor(rnk),  text_size=sizeLookup, bgcolor=bg)
    d3str = (d3 > 0 ? "+" : "") + str.tostring(d3) + " " + heatBadge(d3)
    table.cell(dash, 3, row, d3str, text_color=deltaColor(d3), text_size=sizeLookup, bgcolor=bg)
    d7str = (d7 > 0 ? "+" : "") + str.tostring(d7)
    table.cell(dash, 4, row, d7str, text_color=deltaColor(d7), text_size=sizeLookup, bgcolor=bg)
    table.cell(dash, 5, row, flow, text_color=flowColor(flow), text_size=sizeLookup, bgcolor=bg)

if barstate.islast and showTable
    // Title row
    table.cell(dash, 0, 0, "📊 SECTOR ROTATION RADAR", text_color=color.white,  text_size=sizeLookup, bgcolor=color.new(#0D47A1, 30))
    table.merge_cells(dash, 0, 0, 5, 0)

    // Header row
    headerBg = color.new(#0D47A1, 60)
    table.cell(dash, 0, 1, "SECTOR", text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)
    table.cell(dash, 1, 1, "RANK",   text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)
    table.cell(dash, 2, 1, "RS",     text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)
    table.cell(dash, 3, 1, "Δ3D",    text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)
    table.cell(dash, 4, 1, "Δ7D",    text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)
    table.cell(dash, 5, 1, "FLOW",   text_color=color.white, text_size=sizeLookup, bgcolor=headerBg)

    // Rows: ordered by rank for readability
    // We need to draw rows in rank order. Build a small list.
    sectorList = array.from(memeRank, aiRank, rwaRank, defiRank, ethRank, solRank, exchRank)
    drawn = array.new_bool(7, false)
    for displayRow = 1 to 7
        // Find the sector with the matching rank
        for sIdx = 0 to 6
            if not array.get(drawn, sIdx) and array.get(sectorList, sIdx) == displayRow
                array.set(drawn, sIdx, true)
                if sIdx == 0
                    drawRow(displayRow + 1, "🚀", "MEME",      memeRank, memeScore, memeD3, memeD7, memeFlow, highlightMeme)
                else if sIdx == 1
                    drawRow(displayRow + 1, "🤖", "AI",        aiRank,   aiScore,   aiD3,   aiD7,   aiFlow,   false)
                else if sIdx == 2
                    drawRow(displayRow + 1, "🏛", "RWA",       rwaRank,  rwaScore,  rwaD3,  rwaD7,  rwaFlow,  false)
                else if sIdx == 3
                    drawRow(displayRow + 1, "🏦", "DeFi",      defiRank, defiScore, defiD3, defiD7, defiFlow, false)
                else if sIdx == 4
                    drawRow(displayRow + 1, "Ξ",  "Ethereum",  ethRank,  ethScore,  ethD3,  ethD7,  ethFlow,  false)
                else if sIdx == 5
                    drawRow(displayRow + 1, "◎",  "Solana",    solRank,  solScore,  solD3,  solD7,  solFlow,  false)
                else
                    drawRow(displayRow + 1, "🏢", "Exchange",  exchRank, exchScore, exchD3, exchD7, exchFlow, false)
                break

    // Footer row
    riskOff = (rwaRank <= 3 or defiRank <= 3) and memeRank >= 5 and aiRank >= 5
    regimeText = riskOff ? "⚠️ Risk-Off Regime (defensives leading)" : memeRank <= 2 ? "🔥 Memes in Top 2 — Meme Rotation" : memeRank >= 6 ? "❄️ Memes in Bottom 2 — Sector Weak" : "Mixed Rotation"
    regimeBg = riskOff ? color.new(#F44336, 50) : memeRank <= 2 ? color.new(#FF9100, 40) : memeRank >= 6 ? color.new(#0D47A1, 50) : color.new(#1A1A1A, 50)
    table.cell(dash, 0, 9, regimeText, text_color=color.white, text_size=sizeLookup, bgcolor=regimeBg)
    table.merge_cells(dash, 0, 9, 5, 9)

// ═════════════════════════════════════════════════════════════════════════════
//  RS SCORE LINES (sub-pane) — smoothed with EMA so lines flow instead of
//  stepping between the 7 discrete rank-derived levels.
// ═════════════════════════════════════════════════════════════════════════════

memeLine = ta.ema(memeScore, lineSmoothing)
aiLine   = ta.ema(aiScore,   lineSmoothing)
rwaLine  = ta.ema(rwaScore,  lineSmoothing)
defiLine = ta.ema(defiScore, lineSmoothing)
ethLine  = ta.ema(ethScore,  lineSmoothing)
solLine  = ta.ema(solScore,  lineSmoothing)
exchLine = ta.ema(exchScore, lineSmoothing)

plot(showLines ? memeLine : na, "Memecoins", color=#FF9100,  linewidth=2)
plot(showLines ? aiLine   : na, "AI",        color=#00E5FF,  linewidth=2)
plot(showLines ? rwaLine  : na, "RWA",       color=#9C27B0,  linewidth=2)
plot(showLines ? defiLine : na, "DeFi",      color=#FFC107,  linewidth=2)
plot(showLines ? ethLine  : na, "Ethereum",  color=#7B1FA2,  linewidth=2)
plot(showLines ? solLine  : na, "Solana",    color=#00C853,  linewidth=2)
plot(showLines ? exchLine : na, "Exchange",  color=#E91E63,  linewidth=2)

hline(showLines ? 50 : na, "Mid",   color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(showLines ? 83 : na, "Top 2", color=color.new(#00C853,    60), linestyle=hline.style_dashed)
hline(showLines ? 17 : na, "Bot 2", color=color.new(#F44336,    60), linestyle=hline.style_dashed)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════

// Per-sector surge / drop (rank improved / declined by 2+ over 3 bars)
alertcondition(memeD3 >= 2, title="🚀 MEME surged",     message="MEME sector moved up 2+ ranks in 3 days. Memecoin rotation strengthening.")
alertcondition(aiD3   >= 2, title="🤖 AI surged",       message="AI sector moved up 2+ ranks in 3 days.")
alertcondition(rwaD3  >= 2, title="🏛 RWA surged",      message="RWA sector moved up 2+ ranks in 3 days.")
alertcondition(defiD3 >= 2, title="🏦 DeFi surged",     message="DeFi sector moved up 2+ ranks in 3 days.")
alertcondition(ethD3  >= 2, title="Ξ Ethereum surged",  message="Ethereum sector moved up 2+ ranks in 3 days.")
alertcondition(solD3  >= 2, title="◎ Solana surged",    message="Solana sector moved up 2+ ranks in 3 days.")
alertcondition(exchD3 >= 2, title="🏢 Exchange surged", message="Exchange sector moved up 2+ ranks in 3 days.")

alertcondition(memeD3 <= -2, title="🚀 MEME dropped",     message="MEME sector dropped 2+ ranks in 3 days. Memecoin rotation weakening.")
alertcondition(aiD3   <= -2, title="🤖 AI dropped",       message="AI sector dropped 2+ ranks in 3 days.")
alertcondition(rwaD3  <= -2, title="🏛 RWA dropped",      message="RWA sector dropped 2+ ranks in 3 days.")
alertcondition(defiD3 <= -2, title="🏦 DeFi dropped",     message="DeFi sector dropped 2+ ranks in 3 days.")
alertcondition(ethD3  <= -2, title="Ξ Ethereum dropped",  message="Ethereum sector dropped 2+ ranks in 3 days.")
alertcondition(solD3  <= -2, title="◎ Solana dropped",    message="Solana sector dropped 2+ ranks in 3 days.")
alertcondition(exchD3 <= -2, title="🏢 Exchange dropped", message="Exchange sector dropped 2+ ranks in 3 days.")

// MEME-specific alerts
alertcondition(ta.crossunder(memeRank, 3), title="🔥 MEMES entered Top 2",      message="Memecoin sector entered the top 2 by relative strength. Meme rotation active.")
alertcondition(ta.crossover(memeRank, 5),  title="❄️ MEMES dropped to Bottom 2", message="Memecoin sector dropped to the bottom 2 by relative strength. Risk-off for memes.")

// Risk-off regime
riskOffAlert = (rwaRank <= 3 or defiRank <= 3) and memeRank >= 5 and aiRank >= 5
alertcondition(riskOffAlert, title="⚠️ Risk-Off Regime", message="Defensive sectors (RWA/DeFi) leading while risk-on sectors (MEME/AI) lagging. Capital rotating to safer assets.")
````
