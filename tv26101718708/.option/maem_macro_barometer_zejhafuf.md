# MAEM - Macro Barometer

- url: https://www.tradingview.com/script/ZejHafUF/
- type: indicator
- pine_id: PUB;a874bff92c784df0a0e8df227d1cfc1f
- version: 3.0

## Description

[image]https://www.tradingview.com/x/RvBzRsaG/[/image]

A compact macro dashboard for traders who can't watch four charts at once. MAEM - Macro Barometer places a single table on your active chart showing the live bias (Bullish / Bearish / Flat) and an RSI extreme flag (OB/OS) for four classic macro references: DXY, VIX, US10Y and WTI Crude Oil — the barometers most traders check before pulling the trigger on Gold, indices, or FX, regardless of what you're actually trading.

HOW IT WORKS
- Bias per barometer = price vs EMA + EMA slope (filters out single-tick whipsaws): Bullish only when price is above a rising EMA, Bearish only when price is below a falling EMA, otherwise Flat.
- The RSI column flags OB (overbought) / OS (oversold) on each barometer, so you catch when a macro driver may be running out of steam before it reverses against your position.
- All four barometers are read on your chart's own timeframe via request.security(), non-repainting (lookahead_off).

CUSTOMIZATION
- Toggle each barometer on/off individually.
- Override any of the four symbols if your broker/feed doesn't carry TVC: data.
- Adjust EMA length, RSI length/thresholds, panel position and text size.

Built for traders who want the macro backdrop at a glance without tab-hopping between separate charts — part of the MAEM suite alongside Structure Suite and Volume Suite.

## Source Code

````pine
//@version=6
indicator('MAEM - Macro Barometer', overlay = true)

// ============================================================
// Macro barometer panel (DXY / VIX / US10Y / WTI Oil)
// Goal: read the bias of the classic reference markets without
// leaving the chart of the asset you're trading.
// ============================================================

// --- Enable per barometer ---
enableDXY = input.bool(true, 'Enable DXY', group = 'MAEM · Barometers')
symDXY = input.symbol('TVC:DXY', 'DXY Symbol', group = 'MAEM · Barometers')
enableVIX = input.bool(true, 'Enable VIX', group = 'MAEM · Barometers')
symVIX = input.symbol('TVC:VIX', 'VIX Symbol', group = 'MAEM · Barometers')
enableUS10Y = input.bool(true, 'Enable US10Y', group = 'MAEM · Barometers')
symUS10Y = input.symbol('TVC:US10Y', 'US10Y Symbol', group = 'MAEM · Barometers')
enableOil = input.bool(true, 'Enable WTI Oil', group = 'MAEM · Barometers')
symOil = input.symbol('TVC:USOIL', 'WTI Oil Symbol', group = 'MAEM · Barometers')

// --- Bias logic (price vs EMA + EMA slope) ---
emaLen = input.int(20, 'EMA Length (bias)', minval = 2, maxval = 200, group = 'MAEM · Bias')

// --- RSI (overbought/oversold flag) ---
rsiLen = input.int(14, 'RSI Length', minval = 2, maxval = 100, group = 'MAEM · RSI')
rsiOB = input.float(70, 'Overbought threshold', minval = 50, maxval = 100, group = 'MAEM · RSI')
rsiOS = input.float(30, 'Oversold threshold', minval = 0, maxval = 50, group = 'MAEM · RSI')

// --- Visual ---
tablePos = input.string('top_right', 'Panel position', options = ['top_left', 'top_right', 'bottom_left', 'bottom_right'], group = 'MAEM · Visual')
txtSize = input.string('small', 'Text size', options = ['tiny', 'small', 'normal'], group = 'MAEM · Visual')

// --- Pulpo Bot webhook bridge (optional, off by default) ---
enableWebhook = input.bool(false, 'Send macro bias to Pulpo Bot', group = 'MAEM · Pulpo Bot Webhook', tooltip = 'Fires a webhook-ready alert() payload once per bar close with the bias/RSI of all 4 barometers. You still need to create a TradingView Alert on this indicator with "Any alert() function call" pointing at your Pulpo Bot webhook URL for this to actually reach the bot. Used only as a visual cross-check by MacroAgent, never as its primary macro source.')
tvSecret = input.string('', 'Webhook secret', group = 'MAEM · Pulpo Bot Webhook', tooltip = 'Paste your own TRADINGVIEW_WEBHOOK_SECRET here, in YOUR chart only. This value is never saved into the published script — it only lives in your local indicator settings.')

f_sendWebhook(sig, msg) =>
    payload = '{"secret":"' + tvSecret + '","symbol":"MACRO_BAROMETER","exchange":"","price":0,"signal":"' + sig + '","timeframe":"' + timeframe.period + '","message":"' + msg + '"}'
    alert(payload, alert.freq_once_per_bar_close)

f_position(p) =>
    switch p
        'top_left' => position.top_left
        'top_right' => position.top_right
        'bottom_left' => position.bottom_left
        'bottom_right' => position.bottom_right
        => position.top_right

f_textsize(s) =>
    switch s
        'tiny' => size.tiny
        'small' => size.small
        'normal' => size.normal
        => size.small

// ============================================================
// Per-barometer data: [close, EMA, previous EMA, RSI]
// ============================================================
[cDXY, eDXY, ePrevDXY, rDXY] = request.security(symDXY, timeframe.period, [close, ta.ema(close, emaLen), ta.ema(close, emaLen)[1], ta.rsi(close, rsiLen)], lookahead = barmerge.lookahead_off)
[cVIX, eVIX, ePrevVIX, rVIX] = request.security(symVIX, timeframe.period, [close, ta.ema(close, emaLen), ta.ema(close, emaLen)[1], ta.rsi(close, rsiLen)], lookahead = barmerge.lookahead_off)
[cUS10Y, eUS10Y, ePrevUS10Y, rUS10Y] = request.security(symUS10Y, timeframe.period, [close, ta.ema(close, emaLen), ta.ema(close, emaLen)[1], ta.rsi(close, rsiLen)], lookahead = barmerge.lookahead_off)
[cOil, eOil, ePrevOil, rOil] = request.security(symOil, timeframe.period, [close, ta.ema(close, emaLen), ta.ema(close, emaLen)[1], ta.rsi(close, rsiLen)], lookahead = barmerge.lookahead_off)

// ============================================================
// Helpers
// ============================================================
f_biasText(c, e, ePrev) =>
    up = c > e and e > ePrev
    down = c < e and e < ePrev
    up ? 'BULLISH' : down ? 'BEARISH' : 'FLAT'

f_biasColor(c, e, ePrev) =>
    up = c > e and e > ePrev
    down = c < e and e < ePrev
    up ? color.new(color.green, 30) : down ? color.new(color.red, 30) : color.new(color.gray, 40)

f_rsiText(r) =>
    r >= rsiOB ? 'OB' : r <= rsiOS ? 'OS' : '—'

f_rsiColor(r) =>
    r >= rsiOB ? color.new(color.red, 20) : r <= rsiOS ? color.new(color.green, 20) : color.new(color.gray, 20)

f_nameBg() =>
    color.new(color.black, 0)

// ============================================================
// Table
// ============================================================
var table panel = table.new(f_position(tablePos), 3, 5, border_width = 1, border_color = color.new(color.gray, 50))

if barstate.islast
    table.cell(panel, 0, 0, 'MAEM · Barometers', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = f_textsize(txtSize))
    table.cell(panel, 1, 0, 'Bias', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = f_textsize(txtSize))
    table.cell(panel, 2, 0, 'RSI', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = f_textsize(txtSize))

    row = 1
    if enableDXY
        table.cell(panel, 0, row, 'DXY', text_color = color.white, bgcolor = f_nameBg(), text_size = f_textsize(txtSize))
        table.cell(panel, 1, row, f_biasText(cDXY, eDXY, ePrevDXY), text_color = color.white, bgcolor = f_biasColor(cDXY, eDXY, ePrevDXY), text_size = f_textsize(txtSize))
        table.cell(panel, 2, row, f_rsiText(rDXY), text_color = color.white, bgcolor = f_rsiColor(rDXY), text_size = f_textsize(txtSize))
        row += 1
    if enableVIX
        table.cell(panel, 0, row, 'VIX', text_color = color.white, bgcolor = f_nameBg(), text_size = f_textsize(txtSize))
        table.cell(panel, 1, row, f_biasText(cVIX, eVIX, ePrevVIX), text_color = color.white, bgcolor = f_biasColor(cVIX, eVIX, ePrevVIX), text_size = f_textsize(txtSize))
        table.cell(panel, 2, row, f_rsiText(rVIX), text_color = color.white, bgcolor = f_rsiColor(rVIX), text_size = f_textsize(txtSize))
        row += 1
    if enableUS10Y
        table.cell(panel, 0, row, 'US10Y', text_color = color.white, bgcolor = f_nameBg(), text_size = f_textsize(txtSize))
        table.cell(panel, 1, row, f_biasText(cUS10Y, eUS10Y, ePrevUS10Y), text_color = color.white, bgcolor = f_biasColor(cUS10Y, eUS10Y, ePrevUS10Y), text_size = f_textsize(txtSize))
        table.cell(panel, 2, row, f_rsiText(rUS10Y), text_color = color.white, bgcolor = f_rsiColor(rUS10Y), text_size = f_textsize(txtSize))
        row += 1
    if enableOil
        table.cell(panel, 0, row, 'WTI Oil', text_color = color.white, bgcolor = f_nameBg(), text_size = f_textsize(txtSize))
        table.cell(panel, 1, row, f_biasText(cOil, eOil, ePrevOil), text_color = color.white, bgcolor = f_biasColor(cOil, eOil, ePrevOil), text_size = f_textsize(txtSize))
        table.cell(panel, 2, row, f_rsiText(rOil), text_color = color.white, bgcolor = f_rsiColor(rOil), text_size = f_textsize(txtSize))
        row += 1

// ============================================================
// Pulpo Bot webhook bridge — combined payload, once per bar close.
// Not gated to barstate.islast (unlike the table) so it fires on every
// confirmed bar, not only on the realtime last bar.
// ============================================================
if enableWebhook and tvSecret != ''
    macroMsg = 'DXY:' + f_biasText(cDXY, eDXY, ePrevDXY) + ' RSI:' + f_rsiText(rDXY) + ' | VIX:' + f_biasText(cVIX, eVIX, ePrevVIX) + ' RSI:' + f_rsiText(rVIX) + ' | US10Y:' + f_biasText(cUS10Y, eUS10Y, ePrevUS10Y) + ' RSI:' + f_rsiText(rUS10Y) + ' | WTI:' + f_biasText(cOil, eOil, ePrevOil) + ' RSI:' + f_rsiText(rOil)
    f_sendWebhook(f_biasText(cDXY, eDXY, ePrevDXY), macroMsg)

// cover: chart preview cleanup (2026-07-26)
````
