# Multi-Anchor VWAP

- url: https://www.tradingview.com/script/OIZR3vMv-Multi-Anchor-VWAP/
- type: indicator
- pine_id: PUB;3866dfeceba74481a4accf8134132529
- version: 2.0

## Description

Just a simple script to manually input some Anchored VWAPs - Can add more if you want.
I prefer to use these on futures or individual stocks for a view of "auction" over time.

## Source Code

````pine
//@version=6
indicator('Multi-Anchor VWAP', overlay = true)

// ─────────────────────────────────────────────
// Anchor times - Careful with AVWAP anchors, obscure times won't be shown if a candle doesn't start there sometimes.
// ─────────────────────────────────────────────
t1 = input.time(timestamp('2024-08-05 02:00'), 'Light Purple — Since 8/05/2024', group = 'Anchor Times')
t2 = input.time(timestamp('2025-02-20 04:00'), 'Teal — Since 2/20/2025', group = 'Anchor Times')
t3 = input.time(timestamp('2025-04-07 06:00'), 'Orange — Since Liberation Day', group = 'Anchor Times')
t4 = input.time(timestamp('2025-08-01 11:00'), 'Purple — Since 8/01/2025', group = 'Anchor Times')
t5 = input.time(timestamp('2025-10-10 08:00'), 'Blue — Since 10/10/2025', group = 'Anchor Times')
t6 = input.time(timestamp('2026-04-17 16:00'), 'Red — Since April OPEX', group = 'Anchor Times')
t7 = input.time(timestamp('2025-11-21 05:00'), 'Green — Since 11/21/2025', group = 'Anchor Times')
t8 = input.time(timestamp('2025-11-26 02:00'), 'Yellow — Since 11/26/2025', group = 'Anchor Times')
t9 = input.time(timestamp('2025-12-17 11:00'), 'Pink — Since 12/17/2025', group = 'Anchor Times')
t10 = input.time(timestamp('2026-01-01 02:00'), 'Light Blue — YTD (2026)', group = 'Anchor Times')
t11 = input.time(timestamp('2026-01-27 22:00'), 'Grey — Since 1/27/2026 (YTD High)', group = 'Anchor Times')
t12 = input.time(timestamp('2026-04-07 16:00'), 'Maroon — Since Peace', group = 'Anchor Times')
t13 = input.time(timestamp('2026-03-30 18:00'), 'Black — Since 3/30 Low', group = 'Anchor Times')
t14 = input.time(timestamp('2026-05-01 09:30'), 'Since May 1st Cash Open', group = 'Anchor Times')
t15 = input.time(timestamp('2026-05-17 16:00'), 'Teal', group = 'Anchor Times')

// ─────────────────────────────────────────────
// VISIBILITY TOGGLES
// ─────────────────────────────────────────────
show1 = input.bool(true, 'Show', group = 'Visibility', inline = 'v1')
show2 = input.bool(true, 'Show', group = 'Visibility', inline = 'v2')
show3 = input.bool(true, 'Show', group = 'Visibility', inline = 'v3')
show4 = input.bool(true, 'Show', group = 'Visibility', inline = 'v4')
show5 = input.bool(true, 'Show', group = 'Visibility', inline = 'v5')
show6 = input.bool(true, 'Show', group = 'Visibility', inline = 'v6')
show7 = input.bool(true, 'Show', group = 'Visibility', inline = 'v7')
show8 = input.bool(true, 'Show', group = 'Visibility', inline = 'v8')
show9 = input.bool(true, 'Show', group = 'Visibility', inline = 'v9')
show10 = input.bool(true, 'Show', group = 'Visibility', inline = 'v10')
show11 = input.bool(true, 'Show', group = 'Visibility', inline = 'v11')
show12 = input.bool(true, 'Show', group = 'Visibility', inline = 'v12')
show13 = input.bool(true, 'Show', group = 'Visibility', inline = 'v13')
show14 = input.bool(true, 'Show', group = 'Visibility', inline = 'v14')
show15 = input.bool(true, 'Show', group = 'Visibility', inline = 'v15')

// ─────────────────────────────────────────────
// COLOR INPUTS — pre-set to your specifications
// ─────────────────────────────────────────────
c1 = input.color(color.new(#CC99FF, 0), 'Light Purple', group = 'Colors', inline = 'v1')
c2 = input.color(color.new(#008080, 0), 'Teal', group = 'Colors', inline = 'v2')
c3 = input.color(color.new(#FF8C00, 0), 'Orange', group = 'Colors', inline = 'v3')
c4 = input.color(color.new(#6600CC, 0), 'Purple', group = 'Colors', inline = 'v4')
c5 = input.color(color.new(#0066FF, 0), 'Blue', group = 'Colors', inline = 'v5')
c6 = input.color(color.new(#FF0000, 0), 'Red', group = 'Colors', inline = 'v6')
c7 = input.color(color.new(#00AA00, 0), 'Green', group = 'Colors', inline = 'v7')
c8 = input.color(color.new(#FFD700, 0), 'Yellow', group = 'Colors', inline = 'v8')
c9 = input.color(color.new(#FF69B4, 0), 'Pink', group = 'Colors', inline = 'v9')
c10 = input.color(color.new(#00BFFF, 0), 'Light Blue', group = 'Colors', inline = 'v10')
c11 = input.color(color.new(#808080, 0), 'Grey', group = 'Colors', inline = 'v11')
c12 = input.color(color.new(#800000, 0), 'Maroon', group = 'Colors', inline = 'v12')
c13 = input.color(color.new(#1A1A1A, 0), 'Black', group = 'Colors', inline = 'v13')
c14 = input.color(color.new(#c58b1e, 0), 'Black', group = 'Colors', inline = 'v14')
c15 = input.color(color.new(#22fdce, 0), 'Teal', group = 'Colors', inline = 'v15')

// ─────────────────────────────────────────────
// LINE WIDTH — shared across all AVWAPs
// ─────────────────────────────────────────────
lw = input.int(2, 'Line Width', minval = 1, maxval = 4, group = 'Style')

// ─────────────────────────────────────────────
// PRICE SOURCE — OHLC4
// ─────────────────────────────────────────────
price = (open + high + low + close) / 4

// ─────────────────────────────────────────────
// AVWAP CALCULATION FUNCTION
// Each call maintains its own independent
// cumulative state via var declarations
// ─────────────────────────────────────────────
avwapCalc(anchorT) =>
    var float cumVol = 0.0
    var float cumPV = 0.0
    var float lastT = na
    if na(lastT) or anchorT != lastT
        cumVol := 0.0
        cumPV := 0.0
        lastT := anchorT
        lastT
    if time >= anchorT
        cumVol := cumVol + volume
        cumPV := cumPV + price * volume
        cumPV
    cumVol > 0 ? cumPV / cumVol : na

// ─────────────────────────────────────────────
// COMPUTE ALL 13 AVWAPs
// ─────────────────────────────────────────────
av1 = avwapCalc(t1)
av2 = avwapCalc(t2)
av3 = avwapCalc(t3)
av4 = avwapCalc(t4)
av5 = avwapCalc(t5)
av6 = avwapCalc(t6)
av7 = avwapCalc(t7)
av8 = avwapCalc(t8)
av9 = avwapCalc(t9)
av10 = avwapCalc(t10)
av11 = avwapCalc(t11)
av12 = avwapCalc(t12)
av13 = avwapCalc(t13)
av14 = avwapCalc(t14)
av15 = avwapCalc(t15)

// ─────────────────────────────────────────────
// PLOT ALL 13 AVWAPs
// Passes na when hidden — no rendering artifacts
// ─────────────────────────────────────────────
plot(show1 ? av1 : na, 'Light Purple — 8/05/24', color = c1, linewidth = math.max(1, lw))
plot(show2 ? av2 : na, 'Teal — 2/20/25', color = c2, linewidth = math.max(1, lw))
plot(show3 ? av3 : na, 'Orange — 4/07/25', color = c3, linewidth = math.max(1, lw))
plot(show4 ? av4 : na, 'Purple — 8/01/25', color = c4, linewidth = math.max(1, lw))
plot(show5 ? av5 : na, 'Blue — 10/10/25', color = c5, linewidth = math.max(1, lw))
plot(show6 ? av6 : na, 'Red — 10/29/25', color = c6, linewidth = math.max(1, lw))
plot(show7 ? av7 : na, 'Green — 11/21/25', color = c7, linewidth = math.max(1, lw))
plot(show8 ? av8 : na, 'Yellow — 11/26/25', color = c8, linewidth = math.max(1, lw))
plot(show9 ? av9 : na, 'Pink — 12/17/25', color = c9, linewidth = math.max(1, lw))
plot(show10 ? av10 : na, 'Light Blue — YTD', color = c10, linewidth = math.max(1, lw))
plot(show11 ? av11 : na, 'Grey — 1/27/26 YTD High', color = c11, linewidth = math.max(1, lw))
plot(show12 ? av12 : na, 'Maroon — March 1st', color = c12, linewidth = math.max(1, lw))
plot(show13 ? av13 : na, 'Black — 3/30 Low', color = c13, linewidth = math.max(1, lw))
plot(show14 ? av14 : na, 'May 1st', color = c14, linewidth = math.max(1, lw))
plot(show15 ? av15 : na, 'Weekly', color = c15, linewidth = math.max(1, lw))
````
