# Index Futures Position Size Calculator with values

- url: https://www.tradingview.com/script/ICHyof8G-Index-Futures-Position-Size-Calculator-with-values/
- type: indicator
- pine_id: PUB;0dca537e5701408395283711d99cc006
- version: 1.0

## Description

[b]A simple, free position size calculator for CME index futures traders.[/b]

Click Entry, click Stop Loss, pick your asset, get your contract size instantly. Built for fast NY session execution — no spreadsheets, no manual maths, no noise.
═══════════════════════════════════
[b]✦ SUPPORTED INSTRUMENTS[/b]
MNQ · MES · NQ · ES — all CME tick values hardcoded. No manual lookup, no mistakes.
═══════════════════════════════════
[b]✦ FEATURES[/b]
→ One-click Entry and Stop Loss directly on the chart
→ Auto 1-handle SL buffer — stop shifts 1 full point beyond your click, protecting against wick hunts
→ Asset dropdown — correct tick value loads automatically, zero manual entry
→ Smart rounding — fractional contracts of 0.75 or higher round up, otherwise round down
→ Green Entry line and Red SL line — both start at your exact click and extend right
→ Price labels on both lines — confirm your exact adjusted levels instantly
→ Direction arrow — ▲ Buy or ▼ Sell auto-detected from your Entry and SL position
→ Live dark panel — asset name, contract size, real USD risk and stop distance, all updating in real time
═══════════════════════════════════
[b]✦ HOW TO USE[/b]
Add to chart → click Entry → click Stop Loss → pick asset → set Account Size and Risk %. Read your size from the top-right panel. Three clicks and you are sized.
═══════════════════════════════════
[b]✦ PROP FIRM CHALLENGE SIZING[/b]
Two clean methods to work within your max drawdown limit.
Method 1 — Loss budget split
Divide your max loss by how many consecutive losses you can afford. Enter that result as Account Size with Risk at 100%.
Example: $2,000 max loss ÷ 5 losses → Account Size $400, Risk 100%
Method 2 — Direct percentage
Enter your full max loss as Account Size and set your per-trade risk percentage directly.
Example: $2,000 max loss, 20% per trade → Account Size $2,000, Risk 20%
Both give the same result — use whichever feels natural.
═══════════════════════════════════
[b]✦ HOW THIS WAS BUILT[/b]
Developed step by step through real trading feedback, not theory.
Started as a basic calculator with manual tick inputs. Then came the asset dropdown with hardcoded CME values, smart rounding, exact click-point line rendering, the auto 1-handle SL buffer with price labels, real-time USD risk display, stop distance row, and finally a full dark panel redesign with colour-coded values and direction detection.
Every feature exists because a real trade needed it.
═══════════════════════════════════
[b]✦ A NOTE FROM THE AUTHOR[/b]
Built together with Claude AI through real iterative development. Sharing it free because clean tools should not be locked behind paywalls. No Discord, no course, no affiliate links, nothing to buy. Copy it, modify it, build something better — it is yours.
═══════════════════════════════════
[b]✦ DISCLAIMER[/b]
Educational tool only. I do not take any responsibility when you use this indicator in your trading — always check the calculations before use. Futures trading carries substantial risk of loss. Not financial advice.
Built with ❤️ by REDz and Claude

## Source Code

````pine
//@version=6
// ============================================================================
// Index Futures Position Size Calculator
// ----------------------------------------------------------------------------
// A simple, no-nonsense risk-based position size calculator for CME index
// futures: MNQ, MES, NQ and ES. Click Entry, then click Stop Loss, pick your
// asset, set account size and risk %, and get your contract count instantly.
//
// Features:
//   • Hardcoded CME tick values — no manual lookup needed
//   • Auto SL offset of 1 handle beyond your clicked level (safety buffer)
//   • Custom rounding rule: ≥ 0.75 rounds up, otherwise rounds down
//   • Entry (green) and Stop Loss (red) lines start at click and extend right
//   • Price labels on both lines for instant verification
//   • Enhanced panel showing asset, contracts, real USD risk and stop distance
//
// Authors: Claude & REDz (Trade with Redz)
// License: Mozilla Public License 2.0
// ============================================================================

// © TradeWithRedz
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/

indicator("Index Futures Position Size Calculator", shorttitle="PosSize", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================
account = input.float(200,  "Account Size ($)", minval=0,   step=100, group="Risk Settings")
riskPct = input.float(1.0,  "Risk %",           minval=0.1, step=0.1, group="Risk Settings")

asset = input.string("MNQ", "Select Asset", options=["MNQ","MES","NQ","ES"], group="Instrument")

entryTime = input.time(0,    "Entry",     confirm=true, inline="entry", group="Trade Levels")
entry     = input.price(0.0, "",          confirm=true, inline="entry", group="Trade Levels")

slTime    = input.time(0,    "Stop Loss", confirm=true, inline="sl",    group="Trade Levels")
slUser    = input.price(0.0, "",          confirm=true, inline="sl",    group="Trade Levels")

// ============================================================================
// CME TICK VALUES (tick size 0.25 for all instruments)
// ============================================================================
tickValue = asset == "MNQ" ? 0.50 : asset == "MES" ? 1.25 : asset == "NQ" ? 5.00 : 12.50
tickSize  = 0.25

// ============================================================================
// AUTO SL OFFSET — 1 full handle beyond clicked level
// Buy  (SL below entry) → drops 1 handle lower
// Sell (SL above entry) → lifts 1 handle higher
// ============================================================================
sl = slUser < entry ? slUser - 1.0 : slUser + 1.0

// ============================================================================
// POSITION SIZE CALCULATION
// ============================================================================
riskDollars  = account * riskPct / 100.0
stopPoints   = math.abs(entry - sl)
stopTicks    = stopPoints / tickSize
riskPerCt    = stopTicks * tickValue
contractsRaw = riskPerCt > 0 ? riskDollars / riskPerCt : 0.0

// Custom rounding: ≥ 0.75 rounds up, else rounds down
frac      = contractsRaw - math.floor(contractsRaw)
contracts = frac >= 0.75 ? math.floor(contractsRaw) + 1 : math.floor(contractsRaw)

// Actual dollar risk after rounding
actualRisk = contracts * riskPerCt

// Trade direction
isBuy = slUser < entry

// ============================================================================
// COLOURS
// ============================================================================
col_green  = color.rgb(0,   192, 135)
col_red    = color.rgb(255, 59,  92)
col_bg1    = color.rgb(19,  23,  34)
col_bg2    = color.rgb(30,  34,  45)
col_bg3    = color.rgb(26,  30,  45)
col_border = color.rgb(42,  46,  57)
col_white  = color.rgb(255, 255, 255)
col_dim    = color.rgb(178, 181, 190)

// ============================================================================
// ENTRY & STOP LOSS LINES + LABELS
// ============================================================================
var line  eLine = na
var line  sLine = na
var label eLbl  = na
var label sLbl  = na

if barstate.islast
    line.delete(eLine)
    line.delete(sLine)
    label.delete(eLbl)
    label.delete(sLbl)

    eLine := line.new(
         x1=entryTime, y1=entry,
         x2=entryTime + 1000, y2=entry,
         xloc=xloc.bar_time,
         color=col_green, width=2,
         extend=extend.right)

    sLine := line.new(
         x1=slTime, y1=sl,
         x2=slTime + 1000, y2=sl,
         xloc=xloc.bar_time,
         color=col_red, width=2,
         extend=extend.right)

    eLbl := label.new(
         x=entryTime, y=entry,
         text=" ENTRY  " + str.tostring(entry, format.mintick) + " ",
         xloc=xloc.bar_time,
         style=label.style_label_right,
         color=col_green,
         textcolor=col_white,
         size=size.small)

    sLbl := label.new(
         x=slTime, y=sl,
         text=" SL  " + str.tostring(sl, format.mintick) + " ",
         xloc=xloc.bar_time,
         style=label.style_label_right,
         color=col_red,
         textcolor=col_white,
         size=size.small)

// ============================================================================
// OUTPUT PANEL
// ============================================================================
if barstate.islast
    t = table.new(
         position.top_right, 2, 3,
         bgcolor=col_bg1,
         border_width=1,
         border_color=col_border,
         frame_width=1,
         frame_color=col_border)

    // ── Row 1: Contract size ──
    table.cell(t, 0, 0, " " + asset + " ",
         text_color=col_dim,
         text_size=size.normal,
         bgcolor=col_bg2)
    table.cell(t, 1, 0, str.tostring(contracts, "#") + " contracts ",
         text_color=col_white,
         text_size=size.large,
         bgcolor=col_bg2)

    // ── Row 2: Risk in USD ──
    table.cell(t, 0, 1, " Risk $ ",
         text_color=col_dim,
         text_size=size.normal,
         bgcolor=col_bg3)
    table.cell(t, 1, 1, str.tostring(actualRisk, "#.##") + " ",
         text_color=col_red,
         text_size=size.normal,
         bgcolor=col_bg3)

    // ── Row 3: Stop distance ──
    table.cell(t, 0, 2, " Stop ",
         text_color=col_dim,
         text_size=size.normal,
         bgcolor=col_bg2)
    table.cell(t, 1, 2, str.tostring(stopPoints, "#.##") + " pts " + (isBuy ? "▲" : "▼") + " ",
         text_color=col_green,
         text_size=size.normal,
         bgcolor=col_bg2)
````
