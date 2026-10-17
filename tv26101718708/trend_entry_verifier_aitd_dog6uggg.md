# Trend Entry Verifier [AITD]

- url: https://www.tradingview.com/script/DOg6UggG-Trend-Entry-Verifier-AITD/
- type: indicator
- pine_id: PUB;ad7fa7b671134ef886a0f7d8d0a4f4d8
- version: 1.0

## Description

🎯 Trend Entry Verifier — Lock On Before You Pull The Trigger
 
[b]Stop pulling the trigger when the target isn't locked.[/b]
Most traders fire on partial intel — a trendline here, an RSI hint there — and wonder why their stops keep getting hit. Trend Entry Verifier runs a 3-stage clearance check on every bar. No clearance, no shot. When all three lights turn green, you move with confidence.
 
🛡️ The 3-Stage Clearance Check:
[b]Trend (HMA 13/34)[/b] — fast Hull moving averages confirm the field of engagement
[b]Momentum (RSI)[/b] — pressure check; RSI above 50 = bulls advancing, below 50 = bears advancing
[b]Strength (ADX + DMI)[/b] — power check; ADX above 22 means the move has real force, DI+/DI- confirms who's actually winning

 ✅ GO only fires when all three clear. Anything less = NO-GO. Stand down. The market has to prove itself before you risk capital.
 
💔 The Pain This Eliminates:
 You know the feeling. You see a "clean" move, jump in, and the market immediately turns into a chop-fest that eats your stop. Or worse — the trend you trusted was actually weak, and you're holding a bag while everyone else exits.
 
Most losing trades aren't direction errors. They're timing errors — entering when the field hasn't been cleared. TEV refuses to let you fire on weak intel.
 
🎯 The Confidence This Builds:
 When the ribbon flashes bright and the table says GO, you know three independent systems agreed. Not a guess. Not a gut feel. A verified clearance. You enter with conviction, hold with discipline, and exit when the system tells you the field has changed.
 
🪖 Mission Brief — How To Use It:
🟢 GO + BULLISH → field is clear; favor pullback entries or continuation breakouts
🔴 GO + BEARISH → field is clear; favor rejection entries or breakdown setups
⚫ NO-GO → conditions mixed, weak, or in transition; stand down or scale back
⚪ MIXED trend → trend and momentum disagree; do NOT engage, wait for alignment

🚨 The Visual Ribbon — Your Threat Indicator:
The ribbon at zero shows direction at a glance. When GO conditions clear, the ribbon brightens and thickens — your weapon is hot. When NO-GO, it dims back down. No squinting. No second-guessing. Bright = engage. Dim = stand down.
 
⚠️ Bonus Threat Markers:
🟧 Orange "R" triangles — RSI hit an extreme (above 70 or below 30); enemy is overextended, don't chase
🟧 Orange "B" triangles — price pierced a Bollinger Band; exhaustion zone, watch for reversal

These flag overextension so you don't engage a stretched target.  Why This Hits Different:
🎯 No mystery readings — every state has a clear name and a clear job
🛡️ Conservative by design — NO-GO is the default; you earn the GO
🧹 Single-pane simplicity — one ribbon, one table, one decision per bar
📚 Educational by nature — the table teaches you what to look for, not just what to do

🚫 Built For Traders Who Are Tired Of:
Entering on "looks like a trend" only to get ambushed
Stacking 4 indicators to confirm what one should
Tools that fire during obvious chop
Indicators that look pretty but never tell you when to stay out

One ribbon. One table. One decision. Lock on or stand down.
Defaults: HMA 13/34, RSI 14, DMI 14/14, ADX minimum 22 — fully customizable.
Pairs well with VWRSI Crossovers & Extremes [The AI Trading Desk] — TEV clears the field. VWRSI calls the shot. Use them together for a full recon → engage workflow.
 
🎯 Built by The AI Trading Desk.

## Source Code

````pine
//@version=6
indicator("Trend Entry Verifier [AITD]", "TEV.AITD.1", overlay=false, max_bars_back=3000)

// ---------------------
// Helpers
// ---------------------
hma(src, len) =>
    ta.wma(2 * ta.wma(src, math.round(len / 2)) - ta.wma(src, len), math.round(math.sqrt(len)))

rsiColor(v) =>
    isExtreme = (v > 70.0) or (v < 30.0)
    isExtreme ? color.orange : v >= 50.0 ? color.green : color.red

// ---------------------
// Inputs
// ---------------------
adx_min = input.float(22.0, "ADX Minimum", minval=0, maxval=100, step=0.5)

// ---------------------
// Core Logic
// ---------------------
price     = close
short_hma = hma(price, 13)
long_hma  = hma(price, 34)

hma_up   = short_hma > long_hma
hma_down = short_hma < long_hma

rsi_ct = ta.rsi(price, 14)
[dmiP_ct, dmiM_ct, adx_ct] = ta.dmi(14, 14)

trendUpAlign = hma_up   and rsi_ct >= 50
trendDnAlign = hma_down and rsi_ct < 50

go_up = trendUpAlign and (dmiP_ct > dmiM_ct) and (adx_ct >= adx_min)
go_dn = trendDnAlign and (dmiM_ct > dmiP_ct) and (adx_ct >= adx_min)
go    = go_up or go_dn

// ---------------------
// Ribbon
// ---------------------
ribbon_base_color = trendUpAlign ? color.lime : trendDnAlign ? color.red : color.new(color.gray, 80)

plot(0, title="Ribbon Base", color=color.new(ribbon_base_color, 60),
     style=plot.style_line, linewidth=10,
     display=display.all - display.price_scale - display.status_line)

glow_color = go ? color.new(ribbon_base_color, 20) : na
plot(0, title="Ribbon Glow", color=glow_color,
     style=plot.style_line, linewidth=25,
     display=display.all - display.price_scale - display.status_line)

// ---------------------
// RSI & BB Extreme Markers
// ---------------------
rsi_os_cross = ta.crossunder(rsi_ct, 30)
rsi_ob_cross = ta.crossover(rsi_ct, 70)
plotshape(rsi_os_cross ? 0.0 : na, title="RSI OS", style=shape.triangleup, location=location.absolute, color=color.orange, size=size.small, text="R", textcolor=color.black)
plotshape(rsi_ob_cross ? 0.0 : na, title="RSI OB", style=shape.triangledown, location=location.absolute, color=color.orange, size=size.small, text="R", textcolor=color.black)

bb_len = 20
bb_dev = 2.0
bb_basis = ta.sma(price, bb_len)
bb_std   = ta.stdev(price, bb_len)
bb_upper = bb_basis + bb_dev * bb_std
bb_lower = bb_basis - bb_dev * bb_std

plotshape(ta.crossunder(price, bb_lower) ? 0.0 : na, title="BB Lower", style=shape.triangleup, location=location.absolute, color=color.orange, size=size.small, text="B", textcolor=color.black)
plotshape(ta.crossover(price, bb_upper) ? 0.0 : na, title="BB Upper", style=shape.triangledown, location=location.absolute, color=color.orange, size=size.small, text="B", textcolor=color.black)

// ---------------------
// Status Table
// ---------------------
var table status_table = na

if barstate.islastconfirmedhistory
    if na(status_table)
        status_table := table.new(position.bottom_center, 5, 2)

    table.cell(status_table, 0, 0, "Timeframe",    bgcolor=color.black, text_color=color.white)
    table.cell(status_table, 1, 0, "RSI",          bgcolor=color.black, text_color=color.white)
    table.cell(status_table, 2, 0, "Trend",        bgcolor=color.black, text_color=color.white)
    table.cell(status_table, 3, 0, "Verification", bgcolor=color.black, text_color=color.white)
    table.cell(status_table, 4, 0, "Decision",     bgcolor=color.black, text_color=color.white)

    table.cell(status_table, 0, 1, timeframe.period, bgcolor=color.black, text_color=color.white)
    table.cell(status_table, 1, 1, str.tostring(rsi_ct, "#.0"), bgcolor=rsiColor(rsi_ct), text_color=color.white)

    trend_text = trendUpAlign ? "BULLISH" : trendDnAlign ? "BEARISH" : "MIXED"
    trend_bg   = trendUpAlign ? color.green : trendDnAlign ? color.red : color.gray
    table.cell(status_table, 2, 1, trend_text, bgcolor=trend_bg, text_color=color.white)

    verified_text = go ? "VERIFIED" : "WAITING"
    verified_bg   = go ? color.new(color.green, 20) : color.new(color.gray, 70)
    table.cell(status_table, 3, 1, verified_text, bgcolor=verified_bg, text_color=color.white)

    gng_text = go ? "GO" : "NO-GO"
    gng_bg   = go ? color.green : color.red
    table.cell(status_table, 4, 1, gng_text, bgcolor=gng_bg, text_color=color.white)
````
