# Index Futures Position Size Calculator

- url: https://www.tradingview.com/script/RRz9MEkF-Index-Futures-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;290c70a3e8724e23923ebc9806ce3bd6
- version: 1.0

## Description

[b]A simple, free position size calculator for CME index futures.[/b]

Click Entry, click Stop Loss, pick your asset, get your contract size. That's it.
═══════════════════════════════════
✦ SUPPORTED INSTRUMENTS
MNQ • MES • NQ • ES — all CME tick values hardcoded.
═══════════════════════════════════
✦ FEATURES
→ One-click Entry & Stop Loss directly on chart
→ Auto 1-handle SL buffer (protects against wick hunts)
→ Asset dropdown — no manual tick value entry
→ Custom rounding (≥0.75 rounds up, else down)
→ Green Entry / Red SL lines with price labels
→ Clean black-on-white size panel, top right
═══════════════════════════════════
✦ HOW TO USE

Add to chart → click Entry → click Stop Loss
Settings → pick asset, enter Account Size & Risk %
Read your size from the top-right panel

═══════════════════════════════════
✦ TIP
If you're trading a funded challenge, here are two clean ways to use this tool with your max loss limit:
Method 1 — Loss budget split
Decide how many consecutive losses you can take before you're out. Divide your max loss by that number, and use the result as your "Account Size" with Risk % at 100.
Example: $2,000 max loss ÷ 5 losses = $400 per trade
→ Account Size: $400 | Risk %: 100
Method 2 — Direct percentage
Enter your full max loss as Account Size and set Risk % to your per-trade percentage.
Example: $2,000 max loss, risking 20% per trade
→ Account Size: $2,000 | Risk %: 20
Both give the same result — pick whichever feels more natural.
═══════════════════════════════════
✦ A NOTE FROM THE AUTHOR
Built with Claude AI for my own daily trading. Sharing it free because clean tools shouldn't be locked behind paywalls.
100% free. 100% open source. No Discord, no course, no affiliate links, nothing to buy. Copy it, modify it, republish your own version — it's yours.
═══════════════════════════════════
✦ DISCLAIMER
Educational tool only. Not financial advice. Futures trading carries substantial risk of loss. Always verify calculations against your broker's parameters before trading.
Built with ❤️ by REDz & Claude

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
//   • Large black-on-white panel showing asset and contract size
//
// Authors: Claude & REDz
// License: Mozilla Public License 2.0
// ============================================================================

// © TradeWithRedz
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/

indicator("Index Futures Position Size Calculator", shorttitle="PosSize", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================
account = input.float(200, "Account Size ($)", minval=0, group="Risk Settings")
riskPct = input.float(1, "Risk %", minval=0, step=0.1, group="Risk Settings")

asset = input.string("MNQ", "Select Asset", options=["MNQ","MES","NQ","ES"], group="Instrument")

// Paired time + price inputs — single click captures both
entryTime = input.time(0,    "Entry",     confirm=true, inline="entry", group="Trade Levels")
entry     = input.price(0.0, "",          confirm=true, inline="entry", group="Trade Levels")

slTime    = input.time(0,    "Stop Loss", confirm=true, inline="sl",    group="Trade Levels")
slUser    = input.price(0.0, "",          confirm=true, inline="sl",    group="Trade Levels")

// ============================================================================
// CME TICK VALUES (tick size is 0.25 for all four instruments)
// ============================================================================
tickValue = asset == "MNQ" ? 0.50 : asset == "MES" ? 1.25 : asset == "NQ" ? 5.00 : 12.50
tickSize  = 0.25

// ============================================================================
// AUTO SL OFFSET — 1 full handle beyond clicked level
// Buy trade  (SL below entry) → SL drops 1 handle lower
// Sell trade (SL above entry) → SL lifts 1 handle higher
// ============================================================================
sl = slUser < entry ? slUser - 1.0 : slUser + 1.0

// ============================================================================
// POSITION SIZE CALCULATION
// ============================================================================
riskDollars  = account * riskPct / 100.0
stopTicks    = math.abs(entry - sl) / tickSize
riskPerCt    = stopTicks * tickValue
contractsRaw = riskPerCt > 0 ? riskDollars / riskPerCt : 0.0

// Custom rounding: round up only if fractional part >= 0.75, else round down
frac      = contractsRaw - math.floor(contractsRaw)
contracts = frac >= 0.75 ? math.floor(contractsRaw) + 1 : math.floor(contractsRaw)

// ============================================================================
// ENTRY & STOP LOSS LINES + PRICE LABELS
// Lines start exactly at the click point and extend right indefinitely
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

    eLine := line.new(x1=entryTime, y1=entry, x2=entryTime + 1000, y2=entry, xloc=xloc.bar_time, color=color.green, width=2, extend=extend.right)
    sLine := line.new(x1=slTime,    y1=sl,    x2=slTime + 1000,    y2=sl,    xloc=xloc.bar_time, color=color.red,   width=2, extend=extend.right)

    eLbl := label.new(x=entryTime, y=entry, text="Entry " + str.tostring(entry, format.mintick), xloc=xloc.bar_time, style=label.style_label_right, color=color.green, textcolor=color.white, size=size.small)
    sLbl := label.new(x=slTime,    y=sl,    text="SL "    + str.tostring(sl,    format.mintick), xloc=xloc.bar_time, style=label.style_label_right, color=color.red,   textcolor=color.white, size=size.small)

// ============================================================================
// OUTPUT PANEL
// ============================================================================
if barstate.islast
    t = table.new(position.top_right, 1, 1, bgcolor=color.white, border_width=1, border_color=color.gray)
    table.cell(t, 0, 0, asset + " : " + str.tostring(contracts, "#"), text_color=color.black, text_size=size.large)
````
