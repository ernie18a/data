<!-- tradingview-pine-id: PUB;0622d5feffbf4511851afa14621e1bac -->
<!-- tradingviewscripts-format: 1 -->
# Gravity Bands [JOAT] 

Source: https://www.tradingview.com/script/FAL29iGM-Gravity-Bands-JOAT/

## Description

Price orbits value. An anchored VWAP core with true volume-weighted deviation shells, on clean monochrome candles.

◆ WHAT IT IS

Gravity Bands treats fair value as a gravity core that price orbits and keeps returning to. The core is an anchored VWAP, and the bands around it are true volume-weighted standard deviations — not simple percentage or ATR envelopes. A signature "Lunar Mono" candle mode repaints the chart in clean white/grey so the gravity field is the only color on screen. It is a pure context tool with no buy/sell signals.

This is 100% original code, written from scratch. It is not a repackaged VWAP or bands script.

[image]https://www.tradingview.com/x/IkCoVrAd/[/image]

◆ HOW IT WORKS

1. The gravity core. A volume-weighted average price is accumulated from a chosen anchor — Session, Week or Month — resetting each new period. This is the center of value that price gravitates toward.

2. Volume-weighted shells. The bands are computed from the volume-weighted variance of price around the core, giving genuine ±1σ, ±2σ and ±3σ deviation shells. Because they are volume-weighted, the shells reflect where real activity occurred, not just where price ranged.

3. Stretch. The core distance is expressed in sigma — how many standard deviations price has escaped value. Small stretch means price is orbiting fair value; large stretch means it is extended and statistically stretched from the mean.

4. Lunar Mono candles. An optional mode repaints candles in white (up) and slate grey (down) so the colored gravity field reads instantly without competing with candle colors — the signature look of this tool.

◆ WHAT YOU SEE

 • The gravity core (anchored VWAP) with a soft ±1σ / ±2σ / ±3σ gravity field
 • Optional Lunar Mono monochrome candles
 • An extreme-stretch background wash when price escapes the outer shell
 • A resizable dashboard showing the core value, the stretch state and an orbit gauge, the upper and lower shell prices, the 1σ width in price and as a percent, the anchor mode, and a volume-feed check

◆ HOW TO USE IT

 • Treat the core as the day's (or week's/month's) fair value — a magnet price often reverts to.
 • Use the shells as objective stretch zones: reaching ±2σ or ±3σ marks a statistically extended condition where mean-reversion or exhaustion becomes more likely.
 • Reclaiming or losing the core is a simple bias flip.
 • Match the anchor to your horizon — Session for intraday, Week/Month for swing context.
 • Requires a symbol with a real volume feed.

◆ NOTES & LIMITATIONS

Gravity Bands needs a genuine volume feed — without one the core approximates price and the shells lose meaning (the dashboard flags this). Deviation shells describe statistical stretch, not direction: price can stay extended in a strong trend. It is a context tool, not financial advice. Use it with your own method and risk management.

— made with passion by officialjackofalltrade

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JackOfAllTrades — [JOAT] Series
//
// ─────────────────────────────────────────────────────────────────────────────
//  [JOAT] GRAVITY BANDS
//  Price orbits value. The Gravity Core is an anchored VWAP (session, week,
//  or month) and the bands are true volume-weighted standard deviations —
//  ±1σ, ±2σ, ±3σ gravity shells rendered as a soft field. A Stretch reading
//  reports how many σ price has escaped the core, and the signature
//  "Lunar Mono" candle mode repaints the chart in clean white/grey so the
//  gravity field is the only color on screen. Pure context — no signals.
//  Color identity: Moonlight silver-blue field on monochrome candles.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator('Gravity Bands [JOAT] ', shorttitle='GRAVITY [JOAT]', overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════ INPUTS ═══════════════════════════════════

// ── Gravity Core ──
anchorMode = input.string('Session', 'Gravity Anchor', options = ['Session', 'Week', 'Month'], group = 'Gravity Core',
     tooltip = 'Where the volume-weighted core resets:\n\nSession → classic daily VWAP.\nWeek → weekly anchored VWAP.\nMonth → monthly anchored VWAP.')
srcGrav = input.source(hlc3, 'Core Source', group = 'Gravity Core')
showCore = input.bool(true, 'Show Gravity Core (VWAP)', group = 'Gravity Core')

// ── Gravity Shells ──
show1 = input.bool(true, 'Show ±1σ Shell', group = 'Gravity Shells')
show2 = input.bool(true, 'Show ±2σ Shell', group = 'Gravity Shells')
show3 = input.bool(true, 'Show ±3σ Shell', group = 'Gravity Shells')
fillShells = input.bool(true, 'Fill Gravity Field', group = 'Gravity Shells',
     tooltip = 'Soft gradient fill between shells — the visible gravity field.')
shellTransp = input.int(35, 'Shell Line Transparency', minval = 0, maxval = 100, group = 'Gravity Shells')
fieldTransp = input.int(92, 'Field Fill Transparency', minval = 70, maxval = 100, group = 'Gravity Shells')

// ── Moonlight Palette ──
coreColor = input.color(#93c5fd, 'Core Color (Moonlight)', group = 'Moonlight Palette')
upperColor = input.color(#f472b6, 'Upper Field Color', group = 'Moonlight Palette',
     tooltip = 'Tint of the field above the core — price here is expensive relative to value.')
lowerColor = input.color(#5eead4, 'Lower Field Color', group = 'Moonlight Palette',
     tooltip = 'Tint of the field below the core — price here is cheap relative to value.')
lunarMono = input.bool(true, 'Lunar Mono Candles (white / grey)', group = 'Moonlight Palette',
     tooltip = 'Repaints candles in clean monochrome — white-bodied up candles, slate-grey down candles — so the gravity field carries all the color. The signature look of this indicator.')
monoUpColor = input.color(#e8eaed, 'Mono Up Candle', group = 'Moonlight Palette')
monoDownColor = input.color(#6b7280, 'Mono Down Candle', group = 'Moonlight Palette')
tintExtremes = input.bool(true, 'Tint Background Beyond ±3σ', group = 'Moonlight Palette',
     tooltip = 'Faint background wash when price escapes the outermost shell — an extreme stretch condition.')

// ── Gravity Dashboard ──
showDash = input.bool(true, 'Show Gravity Dashboard', group = 'Gravity Dashboard')
dashPos = input.string('Top Right', 'Dashboard Position',
     options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Top Center', 'Bottom Center', 'Middle Left', 'Middle Right'],
     group = 'Gravity Dashboard')
dashSize = input.string('Normal', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Gravity Dashboard')

// ══════════════════════════════ GRAVITY ENGINE ══════════════════════════════

bool anchD = timeframe.change('D')
bool anchW = timeframe.change('W')
bool anchM = timeframe.change('M')
// On non-intraday charts a Session anchor would never fire — fall back to weekly.
bool newAnchor = anchorMode == 'Session' ? (timeframe.isdwm ? anchW : anchD) :
     anchorMode == 'Week' ? anchW : anchM

float vol = nz(volume)
bool hasVolume = not na(volume)

var float cumPV = 0.0
var float cumV = 0.0
var float cumPV2 = 0.0

if newAnchor or barstate.isfirst
    cumPV := 0.0
    cumV := 0.0
    cumPV2 := 0.0

cumPV += srcGrav * vol
cumV += vol
cumPV2 += srcGrav * srcGrav * vol

float core = cumV > 0 ? cumPV / cumV : srcGrav
float variance = cumV > 0 ? math.max(cumPV2 / cumV - core * core, 0.0) : 0.0
float sigma = math.sqrt(variance)

float u1 = core + sigma
float u2 = core + sigma * 2
float u3 = core + sigma * 3
float d1 = core - sigma
float d2 = core - sigma * 2
float d3 = core - sigma * 3

// Stretch: how many σ price is from the core
float stretch = sigma > 0 ? (close - core) / sigma : 0.0

// ═══════════════════════════════ RENDERING ══════════════════════════════════

// Hide plots on the anchor-reset bar to avoid vertical jumps
bool hideBar = newAnchor and not barstate.isfirst
float pCoreV = hideBar ? na : core

pCore = plot(showCore ? pCoreV : na, 'Gravity Core', color = color.new(coreColor, 0), linewidth = 2, style = plot.style_linebr)
pU1 = plot(show1 ? (hideBar ? na : u1) : na, '+1σ', color = color.new(upperColor, shellTransp + 20 > 100 ? 100 : shellTransp + 20), linewidth = 1, style = plot.style_linebr)
pU2 = plot(show2 ? (hideBar ? na : u2) : na, '+2σ', color = color.new(upperColor, shellTransp + 10 > 100 ? 100 : shellTransp + 10), linewidth = 1, style = plot.style_linebr)
pU3 = plot(show3 ? (hideBar ? na : u3) : na, '+3σ', color = color.new(upperColor, shellTransp), linewidth = 1, style = plot.style_linebr)
pD1 = plot(show1 ? (hideBar ? na : d1) : na, '-1σ', color = color.new(lowerColor, shellTransp + 20 > 100 ? 100 : shellTransp + 20), linewidth = 1, style = plot.style_linebr)
pD2 = plot(show2 ? (hideBar ? na : d2) : na, '-2σ', color = color.new(lowerColor, shellTransp + 10 > 100 ? 100 : shellTransp + 10), linewidth = 1, style = plot.style_linebr)
pD3 = plot(show3 ? (hideBar ? na : d3) : na, '-3σ', color = color.new(lowerColor, shellTransp), linewidth = 1, style = plot.style_linebr)

fill(pU1, pU2, color = fillShells ? color.new(upperColor, fieldTransp) : na, title = 'Upper Field Inner')
fill(pU2, pU3, color = fillShells ? color.new(upperColor, fieldTransp - 4 < 0 ? 0 : fieldTransp - 4) : na, title = 'Upper Field Outer')
fill(pD1, pD2, color = fillShells ? color.new(lowerColor, fieldTransp) : na, title = 'Lower Field Inner')
fill(pD2, pD3, color = fillShells ? color.new(lowerColor, fieldTransp - 4 < 0 ? 0 : fieldTransp - 4) : na, title = 'Lower Field Outer')

// Lunar Mono candles
barcolor(lunarMono ? (close >= open ? monoUpColor : monoDownColor) : na, title = 'Lunar Mono Candles')

// Extreme stretch wash
bgcolor(tintExtremes and sigma > 0 and math.abs(stretch) >= 3 ?
     color.new(stretch > 0 ? upperColor : lowerColor, 90) : na, title = 'Extreme Stretch Wash')

// ═══════════════════════════ GRAVITY DASHBOARD ══════════════════════════════

finalDashPos =
     dashPos == 'Top Left' ? position.top_left :
     dashPos == 'Top Right' ? position.top_right :
     dashPos == 'Bottom Left' ? position.bottom_left :
     dashPos == 'Bottom Right' ? position.bottom_right :
     dashPos == 'Top Center' ? position.top_center :
     dashPos == 'Bottom Center' ? position.bottom_center :
     dashPos == 'Middle Left' ? position.middle_left :
     dashPos == 'Middle Right' ? position.middle_right : position.top_right
finalDashSize =
     dashSize == 'Tiny' ? size.tiny :
     dashSize == 'Small' ? size.small :
     dashSize == 'Large' ? size.large : size.normal

// Stretch gauge: -3σ … +3σ rendered as a 13-slot orbit strip
f_orbitGauge(float s) =>
    int slot = math.round(math.max(math.min(s, 3.0), -3.0) * 2) + 6   // 0..12
    string g = ''
    for i = 0 to 12
        g += i == slot ? '●' : i == 6 ? '│' : '·'
    g

var table dash = na
if barstate.islast and showDash
    if not na(dash)
        table.delete(dash)
        dash := na
    dash := table.new(finalDashPos, columns = 3, rows = 10, bgcolor = color.new(#0f1320, 8),
         border_width = 1, border_color = color.new(#000000, 100),
         frame_width = 2, frame_color = color.new(coreColor, 35))

    color rowBg = color.new(#131a2c, 22)
    color rowBgAlt = color.new(#0d1322, 22)
    color lblCol = color.new(color.white, 18)

    string zoneTxt = sigma <= 0 ? '—' :
         math.abs(stretch) < 1 ? 'ORBIT — fair value' :
         math.abs(stretch) < 2 ? (stretch > 0 ? 'LIFTED +' : 'SINKING −') + str.tostring(math.abs(stretch), '0.0') + 'σ' :
         math.abs(stretch) < 3 ? 'STRETCHED ' + str.tostring(stretch, '0.0') + 'σ' :
         'ESCAPE VELOCITY ' + str.tostring(stretch, '0.0') + 'σ'
    color zoneCol = sigma <= 0 ? color.new(color.white, 45) :
         math.abs(stretch) < 1 ? coreColor :
         stretch > 0 ? upperColor : lowerColor

    // ── Title band (lower field → core → upper field, the gravity spectrum) ──
    table.cell(dash, 0, 0, '☾ GRAVITY BANDS', text_color = color.rgb(10, 14, 26), bgcolor = color.new(lowerColor, 25), text_size = finalDashSize)
    table.cell(dash, 1, 0, '', bgcolor = color.new(coreColor, 30), text_size = finalDashSize)
    table.cell(dash, 2, 0, syminfo.ticker + ' · ' + timeframe.period, text_color = color.rgb(26, 10, 18), bgcolor = color.new(upperColor, 25), text_size = finalDashSize)
    // ── Gradient accent strip ──
    table.cell(dash, 0, 1, '', bgcolor = color.new(lowerColor, 50), text_size = size.tiny)
    table.cell(dash, 1, 1, '', bgcolor = color.new(coreColor, 45), text_size = size.tiny)
    table.cell(dash, 2, 1, '', bgcolor = color.new(upperColor, 50), text_size = size.tiny)
    // ── Core ──
    table.cell(dash, 0, 2, 'Gravity Core', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 2, str.tostring(core, format.mintick), text_color = color.new(coreColor, 5), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 2, close >= core ? 'price above ▲' : 'price below ▼', text_color = close >= core ? color.new(upperColor, 10) : color.new(lowerColor, 10), bgcolor = rowBg, text_size = finalDashSize)
    // ── Stretch ──
    table.cell(dash, 0, 3, 'Stretch', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 3, zoneTxt, text_color = color.white, bgcolor = sigma > 0 and math.abs(stretch) >= 2 ? color.new(zoneCol, 45) : rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 3, f_orbitGauge(stretch), text_color = zoneCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Shells ──
    table.cell(dash, 0, 4, 'Upper Shells', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 4, sigma > 0 ? '+1σ ' + str.tostring(u1, format.mintick) : '—', text_color = color.new(upperColor, 20), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 4, sigma > 0 ? '+2σ ' + str.tostring(u2, format.mintick) : '', text_color = color.new(upperColor, 10), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 0, 5, 'Lower Shells', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 5, sigma > 0 ? '−1σ ' + str.tostring(d1, format.mintick) : '—', text_color = color.new(lowerColor, 20), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 5, sigma > 0 ? '−2σ ' + str.tostring(d2, format.mintick) : '', text_color = color.new(lowerColor, 10), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Sigma width ──
    table.cell(dash, 0, 6, '1σ Width', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 6, sigma > 0 ? str.tostring(sigma, format.mintick) : '—', text_color = color.new(color.white, 20), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 6, sigma > 0 and close != 0 ? str.tostring(sigma / close * 100, '0.00') + '% of price' : '', text_color = color.new(color.white, 40), bgcolor = rowBg, text_size = finalDashSize)
    // ── Anchor ──
    table.cell(dash, 0, 7, 'Anchor', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 7, anchorMode, text_color = color.new(coreColor, 15), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 7, 'resets ' + (anchorMode == 'Session' ? 'daily' : anchorMode == 'Week' ? 'weekly' : 'monthly'), text_color = color.new(color.white, 40), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Volume feed ──
    table.cell(dash, 0, 8, 'Volume Feed', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 8, hasVolume ? '✓ OK' : '⚠ NO VOLUME', text_color = hasVolume ? color.new(#5eead4, 10) : color.new(#f59e0b, 5), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 8, hasVolume ? '' : 'core ≈ price', text_color = color.new(#f59e0b, 25), bgcolor = rowBg, text_size = finalDashSize)
    // ── Mono mode ──
    table.cell(dash, 0, 9, 'Lunar Mono', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 9, lunarMono ? '☾ ON' : 'off', text_color = lunarMono ? monoUpColor : color.new(color.white, 45), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 9, lunarMono ? 'white / grey candles' : 'native candles', text_color = color.new(color.white, 40), bgcolor = rowBgAlt, text_size = finalDashSize)

// ════════════════════════════════ ALERTS ════════════════════════════════════

alertcondition(ta.crossover(close, core), title = 'Core Reclaimed', message = '[JOAT] Gravity Bands — {{ticker}} crossed ABOVE the gravity core ({{interval}})')
alertcondition(ta.crossunder(close, core), title = 'Core Lost', message = '[JOAT] Gravity Bands — {{ticker}} crossed BELOW the gravity core ({{interval}})')
alertcondition(ta.crossover(stretch, 2), title = 'Stretched +2σ', message = '[JOAT] Gravity Bands — {{ticker}} stretched beyond +2σ ({{interval}})')
alertcondition(ta.crossunder(stretch, -2), title = 'Stretched −2σ', message = '[JOAT] Gravity Bands — {{ticker}} stretched beyond −2σ ({{interval}})')
alertcondition(math.abs(stretch) >= 3 and math.abs(stretch[1]) < 3, title = 'Escape Velocity ±3σ', message = '[JOAT] Gravity Bands — {{ticker}} at escape velocity beyond ±3σ ({{interval}})')
````
