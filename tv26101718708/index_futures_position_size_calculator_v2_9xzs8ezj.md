# Index Futures Position Size Calculator V2

- url: https://www.tradingview.com/script/9xZs8EZj-Index-Futures-Position-Size-Calculator-V2/
- type: indicator
- pine_id: PUB;9b8cce38a9a540059a2fb79a7cf01e3e
- version: 1.0

## Description

[b]A simple, free position size calculator for CME index futures traders.[/b]

Click Entry, click Stop Loss, pick your asset, get your contract size instantly. Built for fast NY session execution — no spreadsheets, no manual maths, no noise.

This is the updated version. The first release was a bare-bones calculator showing contract size only with a fixed SL buffer. This version is a full rebuild — every feature below came from real trading feedback, not theory.

═══════════════════════════════════

[b]✦ SUPPORTED INSTRUMENTS[/b]

MNQ · MES · NQ · ES — all CME tick values hardcoded. No manual lookup, no mistakes.

═══════════════════════════════════

[b]✦ WHAT IS NEW IN THIS VERSION[/b]

→ SL buffer is now a toggle — switch the auto ±1 handle offset on or off anytime from settings. When on, the SL label shows +1H so you always know what was calculated
→ Panel now shows four live values — asset, contract size, real USD risk after rounding, and full stop distance in points
→ Direction arrow — ▲ Buy or ▼ Sell auto-detected from your Entry and SL position
→ Panel size control — choose Small, Medium, Large or XL to fit any screen or preference
→ Lines now start exactly at your click point and extend right — no more lines appearing from far left
→ Price labels on both lines — see your exact Entry and adjusted SL price at a glance
→ Ghost line bug fixed — no more phantom line appearing at the bottom when switching timeframes
→ Dark TradingView-native panel design — colour-coded values, clean two-column layout, easy to read at a glance during live sessions

═══════════════════════════════════

[b]✦ FEATURES[/b]

→ One-click Entry and Stop Loss directly on the chart
→ Optional auto ±1 handle SL buffer — structural protection against wick hunts built in
→ Asset dropdown — MNQ, MES, NQ, ES with correct tick value loading automatically
→ Smart rounding — fractional contracts of 0.75 or higher round up, otherwise round down
→ Green Entry line and Red SL line from your exact click, both extending right
→ Live panel updates instantly when you move Entry or SL

═══════════════════════════════════

[b]✦ HOW TO USE[/b]

Add to chart → click Entry → click Stop Loss → pick asset → set Account Size and Risk %. Read your size from the top-right panel. Three clicks and you are sized.

═══════════════════════════════════

[b]✦ PROP FIRM CHALLENGE SIZING[/b]

Two clean methods to work within your max drawdown limit.

Method 1 — Loss budget split Divide your max loss by how many consecutive losses you can afford. Enter the result as Account Size with Risk at 100%. Example: $2,000 max loss ÷ 5 losses → Account Size $400 · Risk 100%

Method 2 — Direct percentage Enter your full max loss as Account Size and set your per-trade percentage. Example: $2,000 max loss, 20% per trade → Account Size $2,000 · Risk 20%

Both give the same result — use whichever feels natural.

═══════════════════════════════════
[b]
✦ A NOTE FROM THE AUTHOR[/b]

Built together with Claude AI through real iterative development — every single feature in this indicator exists because a real trade needed it.

[b]This is 100% free and open source. No Discord, no course, no affiliate links, nothing to buy — ever.[/b]

You are completely free to copy this, modify it, rename it, improve it and republish it as your own. Seriously — go ahead. If you build something better on top of this, that is exactly the point. Clean tools should be free and open to everyone.

If it helps even one trader size their positions properly and protect their capital, it was worth sharing.

═══════════════════════════════════

[b]✦ DISCLAIMER

Educational tool only. I do not take any responsibility when you use this indicator in your trading — always check the calculations before use. Futures trading carries substantial risk of loss. Not financial advice.[/b]

[i]Built with ❤️ by REDz and Claude[/i]

## Source Code

````pine
//@version=6
// ============================================================================
// Index Futures Position Size Calculator
// ----------------------------------------------------------------------------
// Risk-based contract sizing for CME index futures: MNQ, MES, NQ and ES.
// Click Entry, click Stop Loss, pick your asset — get your size instantly.
//
// Features:
//   • Hardcoded CME tick values — no manual lookup needed
//   • Optional auto ±1 handle SL buffer (toggle on/off)
//   • Custom rounding — ≥ 0.75 rounds up, else rounds down
//   • Entry (green) and SL (red) lines from exact click, extending right
//   • Price labels confirming exact adjusted levels
//   • Direction arrow — ▲ Buy / ▼ Sell auto-detected
//   • Dark panel — asset, size, USD risk, stop distance, all live
//   • Panel size control — Small / Medium / Large / XL
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

// Risk
account = input.float(200,  "Account Size ($)", minval=0, step=100, group="⚙️ Risk Settings")
riskPct = input.float(1.0,  "Risk %",           minval=0.1, step=0.1, group="⚙️ Risk Settings")

// Instrument
asset = input.string("MNQ", "Select Asset", options=["MNQ","MES","NQ","ES"], group="📈 Instrument")

// SL Buffer
useBuffer = input.bool(true, "Auto ±1 Handle SL Buffer", group="🛡️ SL Buffer",
     tooltip="ON — SL shifts 1 full point beyond your click for wick protection.\nOFF — SL stays exactly at your clicked price.")

// Trade Levels
entryTime = input.time(0,    "Entry",     confirm=true, inline="entry", group="🎯 Trade Levels")
entry     = input.price(0.0, "",          confirm=true, inline="entry", group="🎯 Trade Levels")

slTime    = input.time(0,    "Stop Loss", confirm=true, inline="sl",    group="🎯 Trade Levels")
slUser    = input.price(0.0, "",          confirm=true, inline="sl",    group="🎯 Trade Levels")

// Panel Size
panelSize = input.string("Large", "Panel Size", options=["Small","Medium","Large","XL"], group="🖥️ Display")

// ============================================================================
// CME TICK VALUES (tick size 0.25 for all instruments)
// ============================================================================
tickValue = asset == "MNQ" ? 0.50 : asset == "MES" ? 1.25 : asset == "NQ" ? 5.00 : 12.50
tickSize  = 0.25

// ============================================================================
// AUTO SL OFFSET — toggle on/off
// Buy  (SL below entry) → drops 1 handle lower
// Sell (SL above entry) → lifts 1 handle higher
// ============================================================================
isBuy = slUser < entry
sl    = useBuffer ? (isBuy ? slUser - 1.0 : slUser + 1.0) : slUser

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

// ============================================================================
// PANEL SIZE MAPPING
// ============================================================================
mainSize = panelSize == "Small"  ? size.small  :
           panelSize == "Medium" ? size.normal  :
           panelSize == "Large"  ? size.large   :
                                   size.huge
subSize  = panelSize == "Small"  ? size.tiny   :
           panelSize == "Medium" ? size.small   :
           panelSize == "Large"  ? size.normal  :
                                   size.large

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
col_yellow = color.rgb(255, 200, 60)

// ============================================================================
// ENTRY & STOP LOSS LINES + LABELS
// Guard: only draw when valid prices are set
// ============================================================================
var line  eLine = na
var line  sLine = na
var label eLbl  = na
var label sLbl  = na

validLevels = entry > 0 and slUser > 0 and entryTime > 0 and slTime > 0

if barstate.islast
    line.delete(eLine)
    line.delete(sLine)
    label.delete(eLbl)
    label.delete(sLbl)

    if validLevels
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

        bufferTag = useBuffer ? "  (+1H)" : ""

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
             text=" SL  " + str.tostring(sl, format.mintick) + bufferTag + " ",
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
         position.top_right, 2, 4,
         bgcolor=col_bg1,
         border_width=1,
         border_color=col_border,
         frame_width=1,
         frame_color=col_border)

    // ── Row 0: Header ──
    table.cell(t, 0, 0, " INDEX FUTURES  ",
         text_color=col_yellow,
         text_size=size.tiny,
         bgcolor=col_bg1)
    table.cell(t, 1, 0, "  POS SIZE ",
         text_color=col_dim,
         text_size=size.tiny,
         bgcolor=col_bg1)

    // ── Row 1: Asset + Contract size ──
    table.cell(t, 0, 1, " " + asset + " ",
         text_color=col_dim,
         text_size=subSize,
         bgcolor=col_bg2)
    table.cell(t, 1, 1, " " + str.tostring(contracts, "#") + " ",
         text_color=col_white,
         text_size=mainSize,
         bgcolor=col_bg2)

    // ── Row 2: USD Risk ──
    table.cell(t, 0, 2, " Risk $ ",
         text_color=col_dim,
         text_size=subSize,
         bgcolor=col_bg3)
    table.cell(t, 1, 2, " $" + str.tostring(actualRisk, "#.##") + " ",
         text_color=col_red,
         text_size=subSize,
         bgcolor=col_bg3)

    // ── Row 3: Stop distance ──
    dirArrow  = isBuy ? " ▲" : " ▼"
    bufferLbl = useBuffer ? " +1H" : ""
    table.cell(t, 0, 3, " Stop ",
         text_color=col_dim,
         text_size=subSize,
         bgcolor=col_bg2)
    table.cell(t, 1, 3, " " + str.tostring(stopPoints, "#.##") + " pts" + bufferLbl + dirArrow + " ",
         text_color=col_green,
         text_size=subSize,
         bgcolor=col_bg2)
````
