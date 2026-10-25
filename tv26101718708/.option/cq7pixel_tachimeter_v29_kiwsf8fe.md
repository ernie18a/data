# CQ_(7)_[PIXEL TACHIMETER] v2.9

- url: https://www.tradingview.com/script/KiWSf8fE-CQ-7-PIXEL-TACHIMETER-v2-9/
- type: indicator
- pine_id: PUB;66bcb4c845794f41b6f357092a152de3
- version: 4.0

## Description

================================================================================
  CQ_(7)_[TACHIMETER] v2.9
  Description & User Manual
  Pine Script v6 indicator for TradingView  ·  © CQuevedo345
================================================================================


--------------------------------------------------------------------------------
1. WHAT IT IS
--------------------------------------------------------------------------------

The Tachimeter is a "speedometer for price". Instead of showing where price
is, it shows how fast price is moving right now, the way a car's tachometer
shows engine RPM.

Every tick, it measures how far price has moved over a short, recent window
(by default the last 10 seconds) and displays that move on a gauge:

  - A small move reads near zero and the gauge sits at "IDLING".
  - A sharp, fast move pushes the needle up the scale, through the caution
    zone and into the redline.
  - If price stops changing for a few seconds, the gauge drops back to rest
    and reads "STOPPED".

PURPOSE

  - Spot bursts of momentum the moment they start (useful for scalping and
    short-term entries/exits).
  - Tell the difference between a market that is drifting and one that is
    accelerating.
  - Keep a large, glanceable price display on screen alongside the speed
    reading.

The indicator overlays the chart and draws only tables. It does not plot
lines or signals and does not repaint price.


--------------------------------------------------------------------------------
2. HOW THE READING IS CALCULATED
--------------------------------------------------------------------------------

RPM (signed price change)
  RPM = current close − close from one Reaction Window ago

  The Reaction Window is set in GENERAL (default: 10 seconds). RPM is in
  price units: on BTC, an RPM of +412 means price is $412 higher than it was
  10 seconds ago.

sRPM (gauge reading)
  The gauges show the size of the move, without its sign:

  - Auto-Adaptive Sensitivity OFF (default):
        sRPM = |RPM| × Sensitivity Multiplier
    The scales read directly in price units: a +412 move reads 412.

  - Auto-Adaptive Sensitivity ON:
        sRPM = (|RPM| ÷ ATR) × 100 × Sensitivity Multiplier
    The reading becomes "% of ATR", so the gauge reacts at a similar speed on
    any symbol or timeframe. With this on, the reading no longer matches the
    dollar move (e.g. +412 with an ATR of ~1,000 reads only ~40).

Direction
  ▲ = price is up over the window (bullish), ▼ = down (bearish),
  🛑 = gauge is STOPPED (reading below 10).

Idle reset
  If the price has not changed for "Reset Reading After No Price Change"
  seconds (default 5), RPM is forced to 0 in every mode: the bars empty, the
  needles drop to rest, and the gauge reads STOPPED. The next price change
  restores the live reading instantly.

Acceleration label (shown in every mode)

  sRPM below 10 ............ S T O P P E D
  10 – 100 ................. I D L I N G
  101 – 199 ................ EXTREMELY WEAK
  200 – 299 ................ VERY WEAK
  300 – 399 ................ WEAK
  400 – 499 ................ MOSTLY WEAK
  500 – 599 ................ SOMEWHAT WEAK
  600 – 699 ................ MODERATELY WEAK
  700 – 799 ................ MODERATE
  800 – 899 ................ MODERATELY STRONG
  900 – 999 ................ MOSTLY STRONG
  1000 – 1099 .............. STRONG
  1100 – 1199 .............. VERY STRONG
  1200 – 1299 .............. EXCEPTIONALLY STRONG
  1300 and above ........... ULTRA STRONG


--------------------------------------------------------------------------------
3. GAUGE MODES
--------------------------------------------------------------------------------

Choose the mode in GENERAL > Gauge Mode. Only one gauge is drawn at a time.

3.1  CLASSIC X10/X100 BARS

  The original dashboard table (default position: Top Left) with:

  - Title row: "P R I C E - T A C H" and the acceleration label.
  - Two stacked 13-segment bars:
      X10 bar  — one block per 10 of sRPM (0–100); fills completely once the
                 reading passes 101.
      X100 bar — one block per 100 of sRPM, from 100 up to 1300. The last
                 three blocks light in a "hot" color (🟦 bullish / 🟨 bearish).
    Scale under the bars: 2 4 6 8 10 11 12 13 (multiply by X10 or X100).
  - RPM cell: the signed price change (e.g. +412).
  - Price cell: current price plus ▲ / ▼ / 🛑.
  - Optional colored accent bar along the bottom.

  The Dot Matrix Price table is never drawn in this mode.

3.2  PIXEL DIAL (default)

  Two round 240° dials built from table cells, pinned to the screen
  (default position: Middle Right):

    LEFT dial  — X10   — scope 0 to 500
                 Numbers: 0 5 10 15 20 25 30 35 40 45 50   (× 10)
                 Caution zone 400–450, redline 450+
    RIGHT dial — X100  — scope 100 to 1500
                 Numbers: 1 2 4 6 8 10 12 14 15             (× 100)
                 Caution zone 1000–1200, redline 1200+

  Both dials follow the same reading, so they move together: when the left
  needle reads 41 (412), the right needle reads just past 4 (412). Below 100
  the right needle rests at its start ("1").

  Scale numbers are printed at 1x; the X10 / X100 caption in the bottom of
  each dial is the multiplier.

  Arc colors:
    - From the start of each dial up to its caution zone, the arc fades from
      a dark to a bright bull (green) or bear (red) color.
    - Caution zone in orange, redline in fuchsia (all adjustable).
    - The lit part of the arc runs up to the live reading.
    - A faded "peak trail" shows the highest recent reading and falls back
      by the Peak Hold Half-Life.
    - The unlit part of the arc is dim gray.

  Below the dials (spanning both):
    - Title tag above:   P R I C E - T A C H
    - RPM tag:           signed RPM + sRPM (or % ATR)
    - Price tag:         current price + ▲ / ▼ / 🛑
    - Acceleration tag:  STOPPED … ULTRA STRONG

  The Classic dashboard is turned off in this mode, and the Dot Matrix Price
  table (section 4) is turned on automatically (unless you switch it off).

  Note: the left dial runs to 500, so it does not peg at 101 the way the
  Classic X10 bar does.


--------------------------------------------------------------------------------
4. DOT MATRIX PRICE TABLE
--------------------------------------------------------------------------------

A large LED-panel style display drawn with a 5×7 dot-matrix font
(default position: Top Center). Shown only in Pixel Dial mode, and only when
"Show Price Table" is on.

  Display modes:
    Price      — current close, rounded to whole units, up to 9,999,999.
    Time       — current clock time (with or without seconds).
    Countdown  — time remaining until the current bar closes.

  The ticker (e.g. BTCUSD) can be printed in front of the price, in the same
  dot-matrix font. In Direction color mode the price lights green when the
  close is at or above the previous close, red when below.


--------------------------------------------------------------------------------
5. SETTINGS REFERENCE (defaults in brackets)
--------------------------------------------------------------------------------

GENERAL (ALL MODES)
  Gauge Mode ............................ Classic X10/X100 Bars / Pixel Dial
                                          [Pixel Dial]
  Gauge Square Color Mode ............... Trend Color (green/red) or White
                                          [Trend Color]
  Price Font ............................ Font used for the price in the
                                          dashboard and on the dial tags
                                          [Monospace]
  Reaction Window Unit .................. Seconds / Minutes [Seconds]
  Reaction Window Length ................ How far back the move is measured.
                                          Seconds are capped at 59. [10]
  Auto-Adaptive Sensitivity (ATR) ....... See section 2 [OFF]
  ATR Length ............................ Used only when adaptive is ON [14]
  Sensitivity Multiplier ................ Scales the reading [1.0]
  Reset Reading After No Price Change ... Seconds; 0 = never [5]
  Stopped Value Cell Background ......... Color of the RPM/price cells and
                                          tags while STOPPED [dark gray]

1 · CLASSIC X10/X100 BARS
  Show Current Price and Tachimeter ..... Dashboard on/off [ON]
  Dashboard Position .................... [Top Left]
  Dashboard Size ........................ Tiny for mobile, Small for web
                                          [Tiny]
  Price Cell Font Size .................. [Large]
  Show Bottom Accent Bar ................ [ON]

2 · PIXEL DIAL — NEEDLE & ARC
  Peak Hold Half-Life (seconds) ......... How fast the peak trail falls back
                                          [3.0]
  Needle Color .......................... [White]
  Caution Zone Color .................... X10 400–450, X100 1000–1200
                                          [Orange]
  Redline Zone Color .................... X10 450+, X100 1200+ [Fuchsia]
  Bull Arc Gradient Dark / Bright ....... [dark green / bright green]
  Bear Arc Gradient Dark / Bright ....... [dark red / bright red]

2 · PIXEL DIAL
  Pixel Dial Position ................... [Middle Right]
  Pixel Width (% of chart) .............. [0.15]
  Pixel Height (% of chart) ............. [0.3]
  Dial Size (×) ......................... Scales width and height together
                                          [1.0]
  Scale Number Size ..................... Numbers and X10/X100 captions
                                          [Tiny]
  Needle Thickness ...................... 1–10 [4]
  Dial Price Size ....................... [Normal]
  Dial Title Tag Size ................... [Small]
  Dial RPM Tag Size ..................... [Small]
  Dial Acceleration Tag Size ............ [Tiny]
  Dial Face Color ....................... [black, 35% transparent]
  Scale Number Color .................... [Gray]

3 · DOT MATRIX PRICE — Display
  Show Price Table ...................... [ON]
  Mode .................................. Price / Time / Countdown [Price]
  Show Seconds (Time) ................... [ON]
  Timezone .............................. Blank = exchange timezone.
                                          Examples: America/Chicago, UTC,
                                          GMT-5 [blank]

3 · DOT MATRIX PRICE — Format
  Prefix / Suffix ....................... Text before / after the price
                                          (Price mode only) [$ / blank]
  Thousands Separators .................. [ON]
  Show Unlit Leading Digits (fixed 7) ... Pads to 7 digits with unlit
                                          digits [OFF]
  Glyph Spacing (columns) ............... 0–3 [1]

3 · DOT MATRIX PRICE — Style
  Render ................................ Character (draws the dot symbol) or
                                          Cell Background (fills cells)
                                          [Character]
  Cell Gap px ........................... Gap between cells; use 1–2 with
                                          Cell Background for a dotted look
                                          [0]
  Dot ................................... ● ■ ◆ █ [●]
  Size .................................. Auto … Huge [Tiny]
  Color Mode ............................ Static (Lit color) or Direction
                                          (Bull / Bear) [Direction]
  Lit / Bull / Bear ..................... [green / green / red]
  Unlit Dots + color .................... Shows the dark panel dots [ON]
  Background / Frame / Frame width ...... [black / dark gray / 1]

3 · DOT MATRIX PRICE — Layout
  Position .............................. [Top Center]
  Cell W % / Cell H % ................... 0 = auto (fits the dot) [0 / 0]
  Ticker Caption ........................ Prints the ticker before the price
                                          [ON]


--------------------------------------------------------------------------------
6. QUICK START
--------------------------------------------------------------------------------

  1. Add the indicator to a chart. For the fastest reaction use a 1-second
     to 15-second chart (or any chart, if your plan supports second-based
     data for the Reaction Window).
  2. It opens in Pixel Dial mode with the Dot Matrix Price table on top.
  3. If the dials look oval, adjust Pixel Width and Pixel Height (2 · PIXEL
     DIAL) until they look round on your screen. Wide monitors need a
     smaller width than height.
  4. Use Dial Size to make both dials larger or smaller without changing
     their shape.
  5. Make sure the Pixel Dial, the Dot Matrix table and (in Classic mode)
     the dashboard are in different screen positions. Two tables in the same
     position draw on top of each other.
  6. Tune the reading:
       - Gauge too jumpy  → raise Reaction Window Length.
       - Gauge too slow   → lower it.
       - Readings too small or too large for the scale → change the
         Sensitivity Multiplier.
       - Trading many different symbols → consider turning
         Auto-Adaptive Sensitivity ON (the scale then reads % of ATR).


--------------------------------------------------------------------------------
7. TIPS & TROUBLESHOOTING
--------------------------------------------------------------------------------

  The needles barely move / the reading looks too low
    Check GENERAL > Auto-Adaptive Sensitivity. When ON, the gauge reads % of
    ATR instead of price units. The RPM tag ends in "% ATR" when it is on and
    "sRPM" when it is off.

  The gauge never leaves STOPPED or IDLING
    The market may be quiet, or the Reaction Window may be too short. Raise
    the window length or the Sensitivity Multiplier.

  The needles don't drop back to rest the instant price stops
    Pine scripts only run when a new tick arrives; there is no timer. The
    reset happens on the first tick after the reset time is up. On a market
    with no trades at all, the gauge stays where it is until the next tick.

  The peak trail doesn't fade on historical bars
    Peak decay and the idle reset work in realtime only.

  Seconds-based Reaction Window shows nothing
    Second-based data requires a TradingView plan that supports it. Switch
    Reaction Window Unit to Minutes if needed.

  Scale numbers or tags are cut off
    Increase Dial Size, or reduce the font sizes in 2 · PIXEL DIAL. Long
    acceleration labels (e.g. EXCEPTIONALLY STRONG) are the widest.

  A scale number disappears now and then
    This is intentional: a number is hidden while the needle passes over it,
    so the needle is never covered.

  "Script takes too long to execute"
    Pixel Dial mode redraws a few thousand table cells every tick (both
    dials plus the Dot Matrix table). To lighten the load, turn off Show
    Price Table, turn off Unlit Dots, or lower Dial Size.

  Settings reset after updating the script
    When setting groups are renamed between versions, TradingView may reset
    some saved values. Re-check your settings after each update.


--------------------------------------------------------------------------------
8. GLOSSARY
--------------------------------------------------------------------------------

  RPM ........... Signed price change over the Reaction Window.
  sRPM .......... Gauge reading: size of the move, after sensitivity
                  (and ATR normalization, if enabled).
  Reaction Window The time span the price change is measured over.
  X10 / X100 .... Scale multipliers. A "4" on the X100 dial means 400.
  Caution zone .. Orange arc section before the redline.
  Redline ....... Fuchsia arc section at the top of each scale.
  Peak trail .... Faded arc showing the highest recent reading.
  Daily open color  Header tags are teal when price is above the day's open,
                  dark red when below.

================================================================================
  End of manual
================================================================================================================================================================
  CQ_(7)_[TACHIMETER] v2.9
  Description & User Manual
  Pine Script v6 indicator for TradingView  ·  © CQuevedo345
================================================================================


--------------------------------------------------------------------------------
1. WHAT IT IS
--------------------------------------------------------------------------------

The Tachimeter is a "speedometer for price". Instead of showing where price
is, it shows how fast price is moving right now, the way a car's tachometer
shows engine RPM.

Every tick, it measures how far price has moved over a short, recent window
(by default the last 10 seconds) and displays that move on a gauge:

  - A small move reads near zero and the gauge sits at "IDLING".
  - A sharp, fast move pushes the needle up the scale, through the caution
    zone and into the redline.
  - If price stops changing for a few seconds, the gauge drops back to rest
    and reads "STOPPED".

PURPOSE

  - Spot bursts of momentum the moment they start (useful for scalping and
    short-term entries/exits).
  - Tell the difference between a market that is drifting and one that is
    accelerating.
  - Keep a large, glanceable price display on screen alongside the speed
    reading.

The indicator overlays the chart and draws only tables. It does not plot
lines or signals and does not repaint price.


--------------------------------------------------------------------------------
2. HOW THE READING IS CALCULATED
--------------------------------------------------------------------------------

RPM (signed price change)
  RPM = current close − close from one Reaction Window ago

  The Reaction Window is set in GENERAL (default: 10 seconds). RPM is in
  price units: on BTC, an RPM of +412 means price is $412 higher than it was
  10 seconds ago.

sRPM (gauge reading)
  The gauges show the size of the move, without its sign:

  - Auto-Adaptive Sensitivity OFF (default):
        sRPM = |RPM| × Sensitivity Multiplier
    The scales read directly in price units: a +412 move reads 412.

  - Auto-Adaptive Sensitivity ON:
        sRPM = (|RPM| ÷ ATR) × 100 × Sensitivity Multiplier
    The reading becomes "% of ATR", so the gauge reacts at a similar speed on
    any symbol or timeframe. With this on, the reading no longer matches the
    dollar move (e.g. +412 with an ATR of ~1,000 reads only ~40).

Direction
  ▲ = price is up over the window (bullish), ▼ = down (bearish),
  🛑 = gauge is STOPPED (reading below 10).

Idle reset
  If the price has not changed for "Reset Reading After No Price Change"
  seconds (default 5), RPM is forced to 0 in every mode: the bars empty, the
  needles drop to rest, and the gauge reads STOPPED. The next price change
  restores the live reading instantly.

Acceleration label (shown in every mode)

  sRPM below 10 ............ S T O P P E D
  10 – 100 ................. I D L I N G
  101 – 199 ................ EXTREMELY WEAK
  200 – 299 ................ VERY WEAK
  300 – 399 ................ WEAK
  400 – 499 ................ MOSTLY WEAK
  500 – 599 ................ SOMEWHAT WEAK
  600 – 699 ................ MODERATELY WEAK
  700 – 799 ................ MODERATE
  800 – 899 ................ MODERATELY STRONG
  900 – 999 ................ MOSTLY STRONG
  1000 – 1099 .............. STRONG
  1100 – 1199 .............. VERY STRONG
  1200 – 1299 .............. EXCEPTIONALLY STRONG
  1300 and above ........... ULTRA STRONG


--------------------------------------------------------------------------------
3. GAUGE MODES
--------------------------------------------------------------------------------

Choose the mode in GENERAL > Gauge Mode. Only one gauge is drawn at a time.

3.1  CLASSIC X10/X100 BARS

  The original dashboard table (default position: Top Left) with:

  - Title row: "P R I C E - T A C H" and the acceleration label.
  - Two stacked 13-segment bars:
      X10 bar  — one block per 10 of sRPM (0–100); fills completely once the
                 reading passes 101.
      X100 bar — one block per 100 of sRPM, from 100 up to 1300. The last
                 three blocks light in a "hot" color (🟦 bullish / 🟨 bearish).
    Scale under the bars: 2 4 6 8 10 11 12 13 (multiply by X10 or X100).
  - RPM cell: the signed price change (e.g. +412).
  - Price cell: current price plus ▲ / ▼ / 🛑.
  - Optional colored accent bar along the bottom.

  The Dot Matrix Price table is never drawn in this mode.

3.2  PIXEL DIAL (default)

  Two round 240° dials built from table cells, pinned to the screen
  (default position: Middle Right):

    LEFT dial  — X10   — scope 0 to 500
                 Numbers: 0 5 10 15 20 25 30 35 40 45 50   (× 10)
                 Caution zone 400–450, redline 450+
    RIGHT dial — X100  — scope 100 to 1500
                 Numbers: 1 2 4 6 8 10 12 14 15             (× 100)
                 Caution zone 1000–1200, redline 1200+

  Both dials follow the same reading, so they move together: when the left
  needle reads 41 (412), the right needle reads just past 4 (412). Below 100
  the right needle rests at its start ("1").

  Scale numbers are printed at 1x; the X10 / X100 caption in the bottom of
  each dial is the multiplier.

  Arc colors:
    - From the start of each dial up to its caution zone, the arc fades from
      a dark to a bright bull (green) or bear (red) color.
    - Caution zone in orange, redline in fuchsia (all adjustable).
    - The lit part of the arc runs up to the live reading.
    - A faded "peak trail" shows the highest recent reading and falls back
      by the Peak Hold Half-Life.
    - The unlit part of the arc is dim gray.

  Below the dials (spanning both):
    - Title tag above:   P R I C E - T A C H
    - RPM tag:           signed RPM + sRPM (or % ATR)
    - Price tag:         current price + ▲ / ▼ / 🛑
    - Acceleration tag:  STOPPED … ULTRA STRONG

  The Classic dashboard is turned off in this mode, and the Dot Matrix Price
  table (section 4) is turned on automatically (unless you switch it off).

  Note: the left dial runs to 500, so it does not peg at 101 the way the
  Classic X10 bar does.


--------------------------------------------------------------------------------
4. DOT MATRIX PRICE TABLE
--------------------------------------------------------------------------------

A large LED-panel style display drawn with a 5×7 dot-matrix font
(default position: Top Center). Shown only in Pixel Dial mode, and only when
"Show Price Table" is on.

  Display modes:
    Price      — current close, rounded to whole units, up to 9,999,999.
    Time       — current clock time (with or without seconds).
    Countdown  — time remaining until the current bar closes.

  The ticker (e.g. BTCUSD) can be printed in front of the price, in the same
  dot-matrix font. In Direction color mode the price lights green when the
  close is at or above the previous close, red when below.


--------------------------------------------------------------------------------
5. SETTINGS REFERENCE (defaults in brackets)
--------------------------------------------------------------------------------

GENERAL (ALL MODES)
  Gauge Mode ............................ Classic X10/X100 Bars / Pixel Dial
                                          [Pixel Dial]
  Gauge Square Color Mode ............... Trend Color (green/red) or White
                                          [Trend Color]
  Price Font ............................ Font used for the price in the
                                          dashboard and on the dial tags
                                          [Monospace]
  Reaction Window Unit .................. Seconds / Minutes [Seconds]
  Reaction Window Length ................ How far back the move is measured.
                                          Seconds are capped at 59. [10]
  Auto-Adaptive Sensitivity (ATR) ....... See section 2 [OFF]
  ATR Length ............................ Used only when adaptive is ON [14]
  Sensitivity Multiplier ................ Scales the reading [1.0]
  Reset Reading After No Price Change ... Seconds; 0 = never [5]
  Stopped Value Cell Background ......... Color of the RPM/price cells and
                                          tags while STOPPED [dark gray]

1 · CLASSIC X10/X100 BARS
  Show Current Price and Tachimeter ..... Dashboard on/off [ON]
  Dashboard Position .................... [Top Left]
  Dashboard Size ........................ Tiny for mobile, Small for web
                                          [Tiny]
  Price Cell Font Size .................. [Large]
  Show Bottom Accent Bar ................ [ON]

2 · PIXEL DIAL — NEEDLE & ARC
  Peak Hold Half-Life (seconds) ......... How fast the peak trail falls back
                                          [3.0]
  Needle Color .......................... [White]
  Caution Zone Color .................... X10 400–450, X100 1000–1200
                                          [Orange]
  Redline Zone Color .................... X10 450+, X100 1200+ [Fuchsia]
  Bull Arc Gradient Dark / Bright ....... [dark green / bright green]
  Bear Arc Gradient Dark / Bright ....... [dark red / bright red]

2 · PIXEL DIAL
  Pixel Dial Position ................... [Middle Right]
  Pixel Width (% of chart) .............. [0.15]
  Pixel Height (% of chart) ............. [0.3]
  Dial Size (×) ......................... Scales width and height together
                                          [1.0]
  Scale Number Size ..................... Numbers and X10/X100 captions
                                          [Tiny]
  Needle Thickness ...................... 1–10 [4]
  Dial Price Size ....................... [Normal]
  Dial Title Tag Size ................... [Small]
  Dial RPM Tag Size ..................... [Small]
  Dial Acceleration Tag Size ............ [Tiny]
  Dial Face Color ....................... [black, 35% transparent]
  Scale Number Color .................... [Gray]

3 · DOT MATRIX PRICE — Display
  Show Price Table ...................... [ON]
  Mode .................................. Price / Time / Countdown [Price]
  Show Seconds (Time) ................... [ON]
  Timezone .............................. Blank = exchange timezone.
                                          Examples: America/Chicago, UTC,
                                          GMT-5 [blank]

3 · DOT MATRIX PRICE — Format
  Prefix / Suffix ....................... Text before / after the price
                                          (Price mode only) [$ / blank]
  Thousands Separators .................. [ON]
  Show Unlit Leading Digits (fixed 7) ... Pads to 7 digits with unlit
                                          digits [OFF]
  Glyph Spacing (columns) ............... 0–3 [1]

3 · DOT MATRIX PRICE — Style
  Render ................................ Character (draws the dot symbol) or
                                          Cell Background (fills cells)
                                          [Character]
  Cell Gap px ........................... Gap between cells; use 1–2 with
                                          Cell Background for a dotted look
                                          [0]
  Dot ................................... ● ■ ◆ █ [●]
  Size .................................. Auto … Huge [Tiny]
  Color Mode ............................ Static (Lit color) or Direction
                                          (Bull / Bear) [Direction]
  Lit / Bull / Bear ..................... [green / green / red]
  Unlit Dots + color .................... Shows the dark panel dots [ON]
  Background / Frame / Frame width ...... [black / dark gray / 1]

3 · DOT MATRIX PRICE — Layout
  Position .............................. [Top Center]
  Cell W % / Cell H % ................... 0 = auto (fits the dot) [0 / 0]
  Ticker Caption ........................ Prints the ticker before the price
                                          [ON]


--------------------------------------------------------------------------------
6. QUICK START
--------------------------------------------------------------------------------

  1. Add the indicator to a chart. For the fastest reaction use a 1-second
     to 15-second chart (or any chart, if your plan supports second-based
     data for the Reaction Window).
  2. It opens in Pixel Dial mode with the Dot Matrix Price table on top.
  3. If the dials look oval, adjust Pixel Width and Pixel Height (2 · PIXEL
     DIAL) until they look round on your screen. Wide monitors need a
     smaller width than height.
  4. Use Dial Size to make both dials larger or smaller without changing
     their shape.
  5. Make sure the Pixel Dial, the Dot Matrix table and (in Classic mode)
     the dashboard are in different screen positions. Two tables in the same
     position draw on top of each other.
  6. Tune the reading:
       - Gauge too jumpy  → raise Reaction Window Length.
       - Gauge too slow   → lower it.
       - Readings too small or too large for the scale → change the
         Sensitivity Multiplier.
       - Trading many different symbols → consider turning
         Auto-Adaptive Sensitivity ON (the scale then reads % of ATR).


--------------------------------------------------------------------------------
7. TIPS & TROUBLESHOOTING
--------------------------------------------------------------------------------

  The needles barely move / the reading looks too low
    Check GENERAL > Auto-Adaptive Sensitivity. When ON, the gauge reads % of
    ATR instead of price units. The RPM tag ends in "% ATR" when it is on and
    "sRPM" when it is off.

  The gauge never leaves STOPPED or IDLING
    The market may be quiet, or the Reaction Window may be too short. Raise
    the window length or the Sensitivity Multiplier.

  The needles don't drop back to rest the instant price stops
    Pine scripts only run when a new tick arrives; there is no timer. The
    reset happens on the first tick after the reset time is up. On a market
    with no trades at all, the gauge stays where it is until the next tick.

  The peak trail doesn't fade on historical bars
    Peak decay and the idle reset work in realtime only.

  Seconds-based Reaction Window shows nothing
    Second-based data requires a TradingView plan that supports it. Switch
    Reaction Window Unit to Minutes if needed.

  Scale numbers or tags are cut off
    Increase Dial Size, or reduce the font sizes in 2 · PIXEL DIAL. Long
    acceleration labels (e.g. EXCEPTIONALLY STRONG) are the widest.

  A scale number disappears now and then
    This is intentional: a number is hidden while the needle passes over it,
    so the needle is never covered.

  "Script takes too long to execute"
    Pixel Dial mode redraws a few thousand table cells every tick (both
    dials plus the Dot Matrix table). To lighten the load, turn off Show
    Price Table, turn off Unlit Dots, or lower Dial Size.

  Settings reset after updating the script
    When setting groups are renamed between versions, TradingView may reset
    some saved values. Re-check your settings after each update.


--------------------------------------------------------------------------------
8. GLOSSARY
--------------------------------------------------------------------------------

  RPM ........... Signed price change over the Reaction Window.
  sRPM .......... Gauge reading: size of the move, after sensitivity
                  (and ATR normalization, if enabled).
  Reaction Window The time span the price change is measured over.
  X10 / X100 .... Scale multipliers. A "4" on the X100 dial means 400.
  Caution zone .. Orange arc section before the redline.
  Redline ....... Fuchsia arc section at the top of each scale.
  Peak trail .... Faded arc showing the highest recent reading.
  Daily open color  Header tags are teal when price is above the day's open,
                  dark red when below.

================================================================================
  End of manual
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345
//@version=6
indicator('CQ_(7)_[TACHIMETER] v3.10', overlay = true)

import fikira/Text/1 as t

// ── General (all gauge modes) ────────────────────────────────────────────────
i_gaugeMode = input.string(
     title   = 'Gauge Mode',
     defval  = 'Pixel Dial',
     options = ['Classic X10/X100 Bars', 'Pixel Dial'],
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Only one gauge is drawn at a time.\nClassic X10/X100 Bars: the original two stacked 13-segment bars, inside the dashboard.\nPixel Dial: two round 240° dials built from table cells, pinned to the screen — X10 (0–500) and X100 (100–1500) (settings in 2 · PIXEL DIAL). The dashboard table is turned off in this mode (the dials carry the title, RPM, price and acceleration tags).\nIn Pixel Dial mode the Dot Matrix Price table (settings in 3 · DOT MATRIX PRICE) is turned on automatically; it is removed in Classic mode.')

i_gaugeColorMode = input.string(
     title   = 'Gauge Square Color Mode',
     defval  = 'Trend Color (Green/Red)',
     options = ['Trend Color (Green/Red)', 'White'],
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Trend Color: squares light up green when bullish, red when bearish.\nWhite: all active squares show as white regardless of direction.')

i_priceFont = input.enum(t.Efont.Monospace, title = 'Price Font',
     group = 'GENERAL (ALL MODES)',
     tooltip = 'Font style applied to the current price value (the number itself, plus the ▲/▼/🛑 direction marker next to it) in every gauge mode: the dashboard Price cell and the price tag on both dials. Defaults to the script\'s original Monospace look.')

i_lookbackUnit = input.string(
     title   = 'Reaction Window Unit',
     defval  = 'Seconds',
     options = ['Seconds', 'Minutes'],
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Unit for "Reaction Window Length" below — this is the time span RPM measures price change over.\nSeconds: fastest reaction, tracks the price move over the last few seconds (needs a feed/plan that supports second-based bars; best for scalping or 1s-15s charts).\nMinutes: the original v2.1 behavior, tracks the price move over the last N minutes (smoother, better for swing charts).')

i_lookbackLength = input.int(
     title   = 'Reaction Window Length',
     defval  = 10,
     minval  = 1,
     maxval  = 240,
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'How far back the gauge looks to measure price movement, in the unit chosen above.\nLower = faster reaction to recent price/time action (more noise).\nHigher = smoother, slower reaction.\nSeconds values are automatically capped at 59 (Pine\'s limit for second-based timeframes).\nv2.1 always used a fixed 20 minutes; the new default of 10 seconds gives a much snappier read on current price/time action — raise it if the gauge feels too jumpy.')

i_useAdaptiveSensitivity = input.bool(
     title   = 'Auto-Adaptive Sensitivity (ATR-based)',
     defval  = false,
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'OFF (default): the gauge reads the raw price change × Sensitivity Multiplier, so the scales are in price units — a +412 move puts the X10 dial just past 41 (412) and the X100 dial just past 4 (400). Same as v2.1.\nON: the gauge reads the price change as a % of ATR instead (× Sensitivity Multiplier), so it reacts at a consistent speed across symbols and timeframes — but the dials and bars then no longer match the dollar change (e.g. +412 with an ATR of ~1,000 reads only ~40).')

i_atrLength = input.int(
     title   = 'ATR Length (Adaptive Sensitivity)',
     defval  = 14,
     minval  = 1,
     maxval  = 200,
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Number of bars used to calculate the ATR that drives Auto-Adaptive Sensitivity.\nShorter = ATR itself adapts faster to fresh volatility, so the gauge\'s reaction speed keeps pace with changing conditions.\nLonger = smoother, slower-changing baseline.\nOnly used when Auto-Adaptive Sensitivity is ON.')

i_sensitivity = input.float(
     title   = 'Sensitivity Multiplier',
     defval  = 1.0,
     minval  = 0.1,
     maxval  = 10.0,
     step    = 0.1,
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Fine-tune multiplier applied on top of the sensitivity calculation.\nWith Auto-Adaptive Sensitivity ON: scales the ATR-normalized reading (1.0 = no change, above 1 = more sensitive, below 1 = less).\nWith Auto-Adaptive Sensitivity OFF: works like v2.1 — 1.0 = default (tuned for BTC/crypto), increase for slower-moving assets (stocks, forex), decrease if the gauge rarely moves off zero.')

i_idleReset = input.int(
     title   = 'Reset Reading After No Price Change (seconds)',
     defval  = 5,
     minval  = 0,
     maxval  = 300,
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'If the price has not changed for this many seconds, the price-change reading (RPM) is reset to 0 in every gauge mode: the Classic bars empty, both dial needles glide back to rest (X10 → 0, X100 → its 100 start) at the Needle Return Half-Life speed (2 · PIXEL DIAL — NEEDLE & ARC), the RPM tag shows +0 and the gauge reads S T O P P E D. The peak trail then decays normally.\nThe current price also becomes the new reference: when price moves again, the change is measured from where it was resting (not from the old Reaction Window), until one full Reaction Window has passed since the reset.\n0 = never reset.\nRealtime only. Pine only runs on incoming ticks, so the reset happens on the first tick after the time is up — on a market with no trades at all the reading stays where it is until the next tick.')

i_stoppedColor = input.color(
     title   = 'Stopped Value Cell Background',
     defval  = color.rgb(64, 64, 64),
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Background color used for the RPM and Price value cells whenever the gauge reads "S T O P P E D" (no meaningful price change over the Reaction Window Length). Overrides the usual bullish/bearish teal-or-red value cell background for as long as the gauge stays stopped.')

// ── Auto Dim (all gauges) ────────────────────────────────────────────────────
i_dimOn = input.bool(
     title   = 'Auto Dim Gauges',
     defval  = true,
     group   = 'AUTO DIM (ALL GAUGES)',
     tooltip = 'Dims every gauge during the Dim Period below: the Classic dashboard, all Pixel Dials (X10, X100, Fear & Greed, VIX) with their tags, and the Dot Matrix Price table.\nDimming cuts the opacity of each color by Dim Amount %, so every Dial Color Theme dims evenly.\nThe emoji squares in the Classic bars are drawn by the font and cannot be dimmed; the cells around them are.\nUses the real clock, not bar time, so it works on any chart timeframe. Pine only redraws on incoming ticks, so the change happens on the first tick after the period starts or ends.')

i_dimPct = input.int(
     title   = 'Dim Amount %',
     defval  = 30,
     minval  = 0,
     maxval  = 100,
     step    = 5,
     group   = 'AUTO DIM (ALL GAUGES)',
     tooltip = 'How much to dim during the Dim Period. 30 = colors drawn at 70% of their normal opacity. 0 = no dimming, 100 = gauges fully hidden.')

i_dimSess = input.session(
     title   = 'Dim Period',
     defval  = '1900-0700',
     group   = 'AUTO DIM (ALL GAUGES)',
     tooltip = 'Start and end time of the dim period, in the Dim Timezone below. The period may cross midnight (default 7:00 PM to 7:00 AM). Start equal to end = never dims.')

i_dimTz = input.string(
     title   = 'Dim Timezone',
     defval  = 'America/Chicago',
     group   = 'AUTO DIM (ALL GAUGES)',
     tooltip = 'Timezone the Dim Period is read in. Examples: America/Chicago, America/New_York, UTC, GMT-5.\nBlank = the symbol\'s exchange timezone (crypto exchanges usually use UTC).')

// Minutes since midnight from an "HHMM" string.
f_hhmm(string s) =>
    int(str.tonumber(str.substring(s, 0, 2))) * 60 + int(str.tonumber(str.substring(s, 2, 4)))

string dimTz    = i_dimTz == '' ? syminfo.timezone : i_dimTz
int    dimStart = f_hhmm(str.substring(i_dimSess, 0, 4))
int    dimEnd   = f_hhmm(str.substring(i_dimSess, 5, 9))
int    nowMin   = hour(timenow, dimTz) * 60 + minute(timenow, dimTz)
bool   dimNow   = i_dimOn and i_dimPct > 0 and
     (dimStart <= dimEnd ? nowMin >= dimStart and nowMin < dimEnd : nowMin >= dimStart or nowMin < dimEnd)

// Cuts a color's opacity by Dim Amount % while the dim period is active.
f_dim(color c) =>
    dimNow ? color.new(c, 100 - (100 - color.t(c)) * (1 - i_dimPct / 100.0)) : c


// ── 1 · Classic X10/X100 Bars (dashboard) ────────────────────────────────────
currentPrice  = input(defval = true,  title = 'Show Current Price and Tachimeter',
     group = '1 · CLASSIC X10/X100 BARS',
     tooltip = 'Toggles the entire dashboard table (price, gauge, and acceleration label) on or off. The dashboard is only drawn in Classic X10/X100 Bars mode.')

tablePosition = input.string(title = 'Dashboard Position?', defval = position.top_left,
     options = [position.bottom_left, position.top_center, position.top_left,
                position.middle_right, position.bottom_right, position.top_right],
     group = '1 · CLASSIC X10/X100 BARS',
     tooltip = 'Allows you to change the position of the dashboard on the chart.')

tableTextSize = input.string(title = 'Dashboard Size?', defval = size.tiny,
     options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
     group = '1 · CLASSIC X10/X100 BARS',
     tooltip = 'Use Tiny if on Mobile, Use Small if on Web browser.')

i_priceSize   = input.string(title = 'Price Cell Font Size?', defval = size.large,
     options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
     group = '1 · CLASSIC X10/X100 BARS',
     tooltip = 'Controls the font size of the current price display.')

i_showBottomBar = input.bool(
     title   = 'Show Bottom Accent Bar',
     defval  = true,
     group   = '1 · CLASSIC X10/X100 BARS',
     tooltip = 'Toggles the thin colored bar at the bottom of the dashboard.')


// ── 2 · Pixel Dial — needle & arc ──────────────────────────────────────────
i_peakHalfLife = input.float(
     title   = 'Peak Hold Half-Life (seconds)',
     defval  = 5.0,
     minval  = 0.5,
     maxval  = 60.0,
     step    = 0.5,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'How fast the held peak falls back to the needle. Every this-many seconds, the gap between the held peak and the live reading is cut in half; a new higher reading moves the peak up instantly.\nExample at 5 s: peak 400, live 200 → 300 after 5 s, 250 after 10 s, 225 after 15 s.\nWhen the reading resets to 0 after no price change, the peak falls toward 0 at the same rate.\nRealtime only: Pine runs on incoming ticks, so the peak moves on each new tick.')

i_needleReturnHL = input.float(
     title   = 'Needle Return Half-Life (seconds)',
     defval  = 1.5,
     minval  = 0.0,
     maxval  = 30.0,
     step    = 0.5,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'After the reading is reset by "Reset Reading After No Price Change", the dial needles (and the lit arc) glide back to rest instead of dropping there at once. Every this-many seconds the distance left to travel is cut in half.\nExample at 1.5 s: needle at 400 → 200 after 1.5 s, 100 after 3 s, 50 after 4.5 s.\nIf price moves again during the return, the needle jumps to the new reading as soon as it is higher than where the needle is.\n0 = drop to rest instantly (old behavior).\nRealtime only: Pine runs on incoming ticks, so the needle moves on each new tick.')

i_peakTrailTransp = input.int(
     title   = 'Peak Trail Transparency',
     defval  = 40,
     minval  = 0,
     maxval  = 100,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'Transparency of the arc segment between the needle and the held peak. 0 = as bright as the lit arc, 100 = hidden (only the peak marker shows).')

i_peakMarker = input.bool(
     title   = 'Show Peak Marker',
     defval  = true,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'Draws a bright marker on the arc at the held peak, in the needle color. Hidden once the peak has fallen back to the needle.')

i_needleColor = input.color(
     title   = 'Needle Color',
     defval  = color.white,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'Color of the needle and hub on both Pixel Dials.\nCustom theme only — a preset Dial Color Theme supplies its own needle color.')

i_cautionColor = input.color(
     title   = 'Caution Zone Color (X10 400–450 · X100 1000–1200)',
     defval  = color.orange,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'Arc color for readings between 400 and 450 on the X10 dial and between 1000 and 1200 on the X100 dial. Below the caution zone the arc uses the bull/bear gradient (or white in White mode).\nCustom theme only — a preset Dial Color Theme supplies its own caution color.')

i_redlineColor = input.color(
     title   = 'Redline Zone Color (X10 450–500 · X100 1200–1500)',
     defval  = color.fuchsia,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'Arc color for readings of 450 and above on the X10 dial and 1200 and above on the X100 dial. Kept distinct from the bearish red so the redline stays readable in downtrends.\nCustom theme only — a preset Dial Color Theme supplies its own redline color.')

i_bullDark   = input.color(title = 'Bull Arc Gradient  Dark',   defval = color.rgb(0, 80, 40),
     group = '2 · PIXEL DIAL — NEEDLE & ARC', inline = 'BULLG')
i_bullBright = input.color(title = 'Bright', defval = color.rgb(0, 255, 100),
     group = '2 · PIXEL DIAL — NEEDLE & ARC', inline = 'BULLG',
     tooltip = 'Bullish arc fades from the Dark color at the start of each dial to the Bright color where its caution zone begins (X10: 0 → 400, X100: 100 → 1000). Not used in White mode.')

i_bearDark   = input.color(title = 'Bear Arc Gradient  Dark',   defval = color.rgb(90, 0, 0),
     group = '2 · PIXEL DIAL — NEEDLE & ARC', inline = 'BEARG')
i_bearBright = input.color(title = 'Bright', defval = color.rgb(255, 40, 40),
     group = '2 · PIXEL DIAL — NEEDLE & ARC', inline = 'BEARG',
     tooltip = 'Bearish arc fades from the Dark color at the start of each dial to the Bright color where its caution zone begins (X10: 0 → 400, X100: 100 → 1000). Not used in White mode.')


// ── 2 · Pixel Dial (table) ───────────────────────────────────────────────────
i_pxPos = input.string(
     title   = 'Pixel Dial Position?',
     defval  = position.bottom_center,
     options = [position.top_left, position.top_center, position.top_right,
                position.middle_left, position.middle_center, position.middle_right,
                position.bottom_left, position.bottom_center, position.bottom_right],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Screen position of the Pixel Dial. Pick a different spot than Dashboard Position — two tables in the same position draw on top of each other.')

i_pxW = input.float(
     title   = 'Pixel Width (% of chart)',
     defval  = 0.15,
     minval  = 0.05,
     maxval  = 5.0,
     step    = 0.05,
     group   = '2 · PIXEL DIAL',
     tooltip = 'Width of each dial pixel as a percentage of the chart pane width. Adjust together with Pixel Height until the dial looks round on your screen (wide monitors need a smaller width than height).\nThe dial grid is 41 × 27 pixels (double resolution), so the defaults are half the old 21 × 13 values and the dial keeps the same overall size.')

i_pxH = input.float(
     title   = 'Pixel Height (% of chart)',
     defval  = 0.3,
     minval  = 0.05,
     maxval  = 10.0,
     step    = 0.05,
     group   = '2 · PIXEL DIAL',
     tooltip = 'Height of each dial pixel as a percentage of the chart pane height.')

i_pxScale = input.float(
     title   = 'Dial Size (×)',
     defval  = 1.0,
     minval  = 0.25,
     maxval  = 5.0,
     step    = 0.05,
     group   = '2 · PIXEL DIAL',
     tooltip = 'Overall size multiplier for both Pixel Dials. Scales Pixel Width and Pixel Height together, so the dial grows or shrinks without changing its shape.\n1.0 = size set by the two pixel inputs above. 2.0 = twice as large, 0.5 = half size.')

i_pxScaleNumSize = input.string(
     title   = 'Scale Number Size',
     defval  = size.tiny,
     options = [size.tiny, size.small, size.normal, size.large, size.huge],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Font size of the scale numbers and the X10 / X100 captions on the Pixel Dials. The Pixel Dials have no tick marks; the numbers are shown at 1x like the Classic scale (X10: 0, 5, 10 … 45, 50 · X100: 1, 2, 4, 6, 8, 10, 12, 14, 15 — multiply by the dial\'s caption) and sit where the ticks would be, each in a 4 × 2 pixel block, so increase together with Dial Size if they get cut off.\nA number is hidden while the needle passes over it, so the needle is never covered.')

i_pxNeedleWidth = input.int(
     title   = 'Needle Thickness',
     defval  = 2,
     minval  = 1,
     maxval  = 10,
     group   = '2 · PIXEL DIAL',
     tooltip = 'Thickness of the Pixel Dial needle. The center hub grows with it so the needle pivot stays covered.')

i_pxPriceSize = input.string(
     title   = 'Dial Price Size',
     defval  = size.normal,
     options = [size.tiny, size.small, size.normal, size.large, size.huge],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Font size of the current price (with its ▲/▼/🛑 marker) shown below the Pixel Dials. Uses the same Price Font as the dashboard.')

i_pxTitleSize = input.string(
     title   = 'Dial Title Tag Size',
     defval  = size.small,
     options = [size.tiny, size.small, size.normal, size.large, size.huge],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Font size of the P R I C E - T A C H title tag above the Pixel Dials.')

i_pxRpmSize = input.string(
     title   = 'Dial RPM Tag Size',
     defval  = size.small,
     options = [size.tiny, size.small, size.normal, size.large, size.huge],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Font size of the tag below the dials showing the signed RPM, the normalized reading and the reference price (REF) the move is measured from.')

i_pxAccelSize = input.string(
     title   = 'Dial Acceleration Tag Size',
     defval  = size.tiny,
     options = [size.tiny, size.small, size.normal, size.large, size.huge],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Font size of the acceleration tag (STOPPED, IDLING, WEAK … ULTRA STRONG) below the dials. Tags are as wide as both dials together, so long labels at big sizes may need a larger Dial Size.')

i_pxTheme = input.string(
     title   = 'Dial Color Theme',
     defval  = 'Aircraft Instrument',
     options = ['Custom', 'Beige VU Meter', 'Aircraft Instrument', 'Volkswagen Tacho', 'Racing White Face', 'Amber Night', 'Marine Brass', 'Night Vision Green'],
     group   = '2 · PIXEL DIAL',
     tooltip = 'Color palette for the Pixel Dials: face, scale numbers and X10/X100 captions, needle and hub, unlit arc track, caution and redline zones, and the text of the dial tags (title, RPM, price, acceleration).\nCustom: uses the Dial Face, Scale Number, Needle, Caution and Redline color inputs.\nBeige VU Meter: cream face, dark brown numbers, black needle, red peak zone.\nAircraft Instrument: matte black face, white numbers and needle, yellow caution, red redline.\nVolkswagen Tacho: black face, blue-lit numbers, red needle.\nRacing White Face: white face, black numbers, red needle.\nAmber Night: dark face with amber backlit numbers and needle.\nMarine Brass: navy face with brass numbers and cream needle.\nNight Vision Green: dark face with green NVG-style numbers.\nThe bull/bear arc gradient (or White mode) still colors the lit arc below the caution zone.')

i_pxFaceGrad = input.bool(
     title   = 'Dial Face Gradient',
     defval  = true,
     group   = '2 · PIXEL DIAL',
     inline  = 'FACEG')

i_pxFaceGradPct = input.int(
     title   = 'Bottom Opacity %',
     defval  = 60,
     minval  = 0,
     maxval  = 100,
     group   = '2 · PIXEL DIAL',
     inline  = 'FACEG',
     tooltip = 'Fades the dial face from top to bottom. The top row uses the face color as-is; the bottom row is drawn at this percentage of the face color\'s own opacity (100 = no fade, 60 = 60% as opaque, 0 = fully transparent at the bottom).\nApplies to the face color of every Dial Color Theme, including Custom.')

i_pxFaceColor = input.color(
     title   = 'Dial Face Color',
     defval  = color.new(color.black, 35),
     group   = '2 · PIXEL DIAL',
     tooltip = 'Fill color of the round dial face behind the scale.\nCustom theme only — a preset Dial Color Theme supplies its own face color.')

i_pxScaleColor = input.color(
     title   = 'Scale Number Color',
     defval  = color.gray,
     group   = '2 · PIXEL DIAL',
     tooltip = 'Color of the scale numbers on the Pixel Dial.\nCustom theme only — a preset Dial Color Theme supplies its own number color.')

// ── Dial color theme ──────────────────────────────────────────────────────────
// Returns [face, scale numbers, needle, unlit track, caution, redline, tag text].
f_theme(string th) =>
    color face   = i_pxFaceColor
    color scale  = i_pxScaleColor
    color needle = i_needleColor
    color track  = color.new(color.gray, 75)
    color cau    = i_cautionColor
    color red    = i_redlineColor
    color txt    = color.white
    if th == 'Beige VU Meter'
        face   := #E9DDB5
        scale  := #2A2016
        needle := #141414
        track  := color.new(#7A6A48, 55)
        cau    := #C27C1E
        red    := #C62828
        txt    := #F3E9D2
    else if th == 'Aircraft Instrument'
        face   := #15181B
        scale  := #F4F4F4
        needle := #FFFFFF
        track  := color.new(#5A5F66, 55)
        cau    := #FFC107
        red    := #E53935
        txt    := #FFFFFF
    else if th == 'Volkswagen Tacho'
        face   := #07080C
        scale  := #5B9BFF
        needle := #FF3B1F
        track  := color.new(#1F3A66, 40)
        cau    := #FF8C1A
        red    := #FF2414
        txt    := #A8C8FF
    else if th == 'Racing White Face'
        face   := #F4F2EC
        scale  := #121212
        needle := #E3221B
        track  := color.new(#9A9A9A, 55)
        cau    := #FF8F00
        red    := #D50000
        txt    := #FFFFFF
    else if th == 'Amber Night'
        face   := #160D02
        scale  := #FFB000
        needle := #FFC24D
        track  := color.new(#5A3A00, 40)
        cau    := #FF7A00
        red    := #FF3300
        txt    := #FFC95A
    else if th == 'Marine Brass'
        face   := #0F2236
        scale  := #D9B44A
        needle := #F4E6BC
        track  := color.new(#3C5670, 45)
        cau    := #E8962E
        red    := #D63A2E
        txt    := #E8CF83
    else if th == 'Night Vision Green'
        face   := #081408
        scale  := #79FF66
        needle := #C2FFB8
        track  := color.new(#1E4A1E, 40)
        cau    := #D8FF3A
        red    := #FF4B3A
        txt    := #9CFF8F
    [face, scale, needle, track, cau, red, txt]

[thFace, thScale, thNeedle, thTrack, thCau, thRed, thText] = f_theme(i_pxTheme)


// ── 3 · Dot Matrix Price (shown in Pixel Dial mode) ─────────────────────────
string G_DSP = "3 · DOT MATRIX PRICE — 🕒 Display"
bool   iShow  = input.bool(true, "Show Price Table", group = G_DSP,
     tooltip = "Turns the Dot Matrix Price table on or off. It is only drawn in Pixel Dial mode, and never in Classic X10/X100 Bars mode.")
string iMode  = input.string("Price", "Mode", options = ["Price", "Time", "Countdown"], group = G_DSP,
     tooltip = "The Dot Matrix Price table is drawn automatically in Pixel Dial mode, and removed in Classic X10/X100 Bars mode.\nPrice: current close.\nTime: current clock time.\nCountdown: time remaining until the current bar closes.\nTime / Countdown refresh on each realtime tick.")
bool   iSecs  = input.bool(true, "Show Seconds (Time)", group = G_DSP)
string iTz    = input.string("", "Timezone", group = G_DSP,
     tooltip = "Blank = exchange timezone. Examples: America/Chicago, UTC, GMT-5.")

string G_FMT = "3 · DOT MATRIX PRICE — 🔢 Format"
string iPrefix  = input.string("$", "Prefix", group = G_FMT, inline = "f0")
string iSuffix  = input.string("",  "Suffix", group = G_FMT, inline = "f0",
     tooltip = "Text drawn before / after the price (Price mode only).\nSupported: A–Z a–z 0–9 space and ! ? / : + - × ÷ = % & # ( ) > < $ , . — other characters are skipped.")
bool   iCommas  = input.bool(true,  "Thousands Separators", group = G_FMT)
bool   iPad     = input.bool(false, "Show Unlit Leading Digits (fixed 7)", group = G_FMT)
int    iGap     = input.int(1, "Glyph Spacing (columns)", minval = 0, maxval = 3, group = G_FMT)

string G_STY = "3 · DOT MATRIX PRICE — 🎨 Style"
string iFill     = input.string("Character", "Render", options = ["Character", "Cell Background"], group = G_STY, inline = "s0")
int    iBorderW  = input.int(0, "Cell Gap px", minval = 0, maxval = 5, group = G_STY, inline = "s0",
     tooltip = "Pixel gap between cells, drawn in the Background color. Use 1–2 with Cell Background for a dot-matrix look; 0 = solid segments.")
string iDot      = input.string("█", "Dot", options = ["●", "■", "▯", "█"], group = G_STY, inline = "s1")
string iSizeStr  = input.string("Tiny", "Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = G_STY, inline = "s1",
     tooltip = "In Cell Background mode the dot character is invisible and only sets the cell size (when Cell W/H are 0).")
string iColMode  = input.string("Direction", "Color Mode", options = ["Static", "Direction"], group = G_STY,
     tooltip = "Static: uses the Lit color.\nDirection: Bull when close ≥ previous close, Bear otherwise (colors set by Palette below).")
string iPalette  = input.string("Custom", "Palette",
     options = ["Custom", "Classic", "Ocean", "Sunset", "Neon", "Monochrome", "Desert", "Oldbook", "OldWest", "Default"],
     group = G_STY,
     tooltip = "Bull/Bear color pair used in Direction mode.\nCustom: uses the Bull and Bear color inputs below.\nAny other choice overrides them with that palette's preset pair.")
color  iOnCol    = input.color(#00E676, "Lit",  group = G_STY, inline = "c1")
color  iBullCol  = input.color(#00E676, "Bull", group = G_STY, inline = "c1")
color  iBearCol  = input.color(#FF5252, "Bear", group = G_STY, inline = "c1")
bool   iGhost    = input.bool(true, "Unlit Dots", group = G_STY, inline = "c2")
color  iGhostCol = input.color(color.new(#787B86, 80), "", group = G_STY, inline = "c2")
color  iBgCol    = input.color(#000000, "Background", group = G_STY, inline = "c3")
color  iFrameCol = input.color(#363A45, "Frame", group = G_STY, inline = "c3")
int    iFrameW   = input.int(1, "", minval = 0, maxval = 5, group = G_STY, inline = "c3")

string G_LAY = "3 · DOT MATRIX PRICE — 📐 Layout"
string iPos     = input.string("Top Center", "Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = G_LAY,
     tooltip = "Pick a different spot than Pixel Dial Position — two tables in the same position draw on top of each other.")
float  iCellW   = input.float(0.0, "Cell W %", minval = 0.0, step = 0.1, group = G_LAY, inline = "l1")
float  iCellH   = input.float(0.0, "Cell H %", minval = 0.0, step = 0.1, group = G_LAY, inline = "l1", tooltip = "0 = auto (fits the dot character).")
bool   iCaption = input.bool(false, "Ticker Caption", group = G_LAY,
     tooltip = "Ticker drawn before the price, in dot-matrix characters (same color as the price).")

// ── Dot Matrix Price — palette (Direction mode Bull/Bear colors) ─────────────
color bullBase = switch iPalette
    "Classic"    => color.rgb(0, 177, 171)
    "Ocean"      => color.rgb(0, 104, 179)
    "Sunset"     => color.rgb(180, 108, 0)
    "Neon"       => color.rgb(0, 105, 190)
    "Monochrome" => color.rgb(172, 172, 172)
    "Desert"     => color.rgb(0, 179, 161)
    "Oldbook"    => color.rgb(139, 163, 0)
    "OldWest"    => color.rgb(148, 182, 0)
    "Default"    => color.rgb(0, 187, 140)
    => iBullCol

color bearBase = switch iPalette
    "Classic"    => color.rgb(182, 0, 0)
    "Ocean"      => color.rgb(0, 43, 185)
    "Sunset"     => color.rgb(151, 147, 140)
    "Neon"       => color.rgb(112, 119, 133)
    "Monochrome" => color.rgb(119, 116, 116)
    "Desert"     => color.rgb(173, 104, 0)
    "Oldbook"    => color.rgb(168, 146, 0)
    "OldWest"    => color.rgb(165, 33, 0)
    "Default"    => color.rgb(206, 0, 0)
    => iBearCol

// ── 4 · Fear & Greed Dial (shown in Pixel Dial mode) ─────────────────────────
string G_FGD = "4 · FEAR & GREED DIAL — 📊 Data"
bool   i_fgShow     = input.bool(true, "Show Fear & Greed Dial", group = G_FGD,
     tooltip = "Adds a third Pixel Dial to the right of the X100 dial, built with the same grid, face gradient, needle, Dial Color Theme and size settings as the tach dials (2 · PIXEL DIAL). Only drawn in Pixel Dial mode.\nTradingView has no built-in Fear & Greed feed and Pine cannot read web APIs (CNN, alternative.me), so the index is calculated here as a 0–100 composite of five equally weighted components: RSI momentum, price vs its trend SMA, volatility (inverted: rising volatility = fear), up-volume share, and position inside the recent high/low range.")
bool   i_fgUseChart = input.bool(true, "Use Chart Symbol", group = G_FGD, inline = "fgs")
string i_fgSym      = input.symbol("BITSTAMP:BTCUSD", "", group = G_FGD, inline = "fgs",
     tooltip = "ON: the index is calculated from the chart's own symbol.\nOFF: calculated from the symbol on the right (e.g. keep a BTC Fear & Greed reading while viewing another chart).")
string i_fgTf       = input.timeframe("D", "Timeframe", group = G_FGD,
     tooltip = "Timeframe the components are calculated on. D matches how the popular Fear & Greed indexes update (once per day). PREV and Δ compare against the previous bar of this timeframe; the current bar updates live in realtime.")
int    i_fgSmooth   = input.int(1, "Smoothing (EMA)", minval = 1, maxval = 20, group = G_FGD,
     tooltip = "EMA length applied to the composite. 1 = no smoothing.")
int    i_fgRsiLen   = input.int(14,  "RSI",       minval = 2,  group = G_FGD, inline = "fgl1")
int    i_fgTrendLen = input.int(125, "Trend SMA", minval = 10, group = G_FGD, inline = "fgl1")
int    i_fgVolLen   = input.int(30,  "Volatility / Volume", minval = 5,  group = G_FGD, inline = "fgl2")
int    i_fgRangeLen = input.int(90,  "Range",     minval = 10, group = G_FGD, inline = "fgl2")
int    i_fgRankLen  = input.int(365, "Percent-Rank Lookback", minval = 20, group = G_FGD,
     tooltip = "How many bars the trend and volatility components are ranked against (0 = lowest in this window, 100 = highest). 365 on D = one year.")

string G_FGS = "4 · FEAR & GREED DIAL — 🎨 Style"
int    i_fgGap      = input.int(0, "Separation from Tach Dials (pixels)", minval = 0, maxval = 40, group = G_FGS,
     tooltip = "Blank space between the X100 dial and the Fear & Greed dial, in dial pixels (each step = one Pixel Width × Dial Size). 0 = touching, 2 = same spacing as between the X10 and X100 dials.")
color  i_fgExFear   = input.color(#D50000, "Extreme Fear", group = G_FGS, inline = "fgc1")
color  i_fgFear     = input.color(#FF6D00, "Fear",         group = G_FGS, inline = "fgc1")
color  i_fgNeutral  = input.color(#FFD600, "Neutral",      group = G_FGS, inline = "fgc2")
color  i_fgGreed    = input.color(#64DD17, "Greed",        group = G_FGS, inline = "fgc2")
color  i_fgExGreed  = input.color(#00C853, "Extreme Greed", group = G_FGS,
     tooltip = "Arc zone colors: Extreme Fear 0–25 · Fear 25–45 · Neutral 45–55 · Greed 55–75 · Extreme Greed 75–100. The same color tints the dial's tags.")
int    i_fgUnlitTransp = input.int(75, "Unlit Arc Transparency", minval = 0, maxval = 100, group = G_FGS,
     tooltip = "The arc is fully lit up to the reading; the rest of the zone map stays visible at this transparency (100 = hidden).")

// Fear & Greed composite (0–100), evaluated on the chosen symbol/timeframe.
f_fgCalc() =>
    float rsiC   = ta.rsi(close, i_fgRsiLen)
    float sma    = ta.sma(close, i_fgTrendLen)
    float trendC = ta.percentrank((close - sma) / sma, i_fgRankLen)
    float vol    = ta.stdev(math.log(close / close[1]), i_fgVolLen)
    float volC   = 100 - ta.percentrank(vol, i_fgRankLen)
    float upV    = math.sum(close > close[1] ? nz(volume) : 0.0, i_fgVolLen)
    float allV   = math.sum(nz(volume), i_fgVolLen)
    float flowC  = allV > 0 ? upV / allV * 100 : 50.0
    float hiR    = ta.highest(high, i_fgRangeLen)
    float loR    = ta.lowest(low, i_fgRangeLen)
    float strC   = hiR > loR ? (close - loR) / (hiR - loR) * 100 : 50.0
    float raw    = (nz(rsiC, 50) + nz(trendC, 50) + nz(volC, 50) + nz(flowC, 50) + nz(strC, 50)) / 5
    float fgv    = ta.ema(raw, i_fgSmooth)
    [fgv, fgv[1]]

string fgSym = i_fgUseChart ? syminfo.tickerid : i_fgSym
[fgVal, fgPrev] = request.security(fgSym, i_fgTf, f_fgCalc(), lookahead = barmerge.lookahead_off)

// ── 5 · VIX Dial (shown in Pixel Dial mode) ──────────────────────────────────
string G_VXD = "5 · VIX DIAL — 📊 Data"
bool   i_vixShow    = input.bool(true, "Show VIX Dial", group = G_VXD,
     tooltip = "Adds a Pixel Dial showing the CBOE Volatility Index (position set by Placement in 5 · VIX DIAL — 🎨 Style), built with the same grid, face gradient, needle, Dial Color Theme and size settings as the tach dials (2 · PIXEL DIAL). Only drawn in Pixel Dial mode.\nThe VIX is the market's expected 30-day volatility of the S&P 500, read from SPX options. It usually rises when stocks fall (fear, hedging demand) and sinks when stocks grind higher (calm, complacency).")
string i_vixSym     = input.symbol("TVC:VIX", "Symbol", group = G_VXD,
     tooltip = "Volatility index to read. TVC:VIX (default) or CBOE:VIX for the S&P 500 VIX. Other volatility indexes (e.g. Nasdaq VXN) also work, but the zones below are tuned for the VIX.")
string i_vixTf      = input.timeframe("D", "Timeframe", group = G_VXD,
     tooltip = "Timeframe of the VIX bars. PREV and Δ compare against the previous bar of this timeframe (D = previous daily close); the current bar updates live during the session.")
int    i_vixAvgLen  = input.int(20,  "Average Length",     minval = 2,  group = G_VXD, inline = "vxl")
int    i_vixRankLen = input.int(252, "Percentile Lookback", minval = 20, group = G_VXD, inline = "vxl",
     tooltip = "Average Length: SMA the analysis compares the VIX against (above it = volatility rising, below = easing).\nPercentile Lookback: bars used for the percentile and the high/low range in the analysis. 252 on D ≈ one trading year.")
float  i_vixL1 = input.float(12, "Zones: Calm ≥",     minval = 1, maxval = 50, step = 0.5, group = G_VXD, inline = "vxz1")
float  i_vixL2 = input.float(20, "Elevated ≥",        minval = 1, maxval = 50, step = 0.5, group = G_VXD, inline = "vxz1")
float  i_vixL3 = input.float(30, "High Fear ≥",       minval = 1, maxval = 50, step = 0.5, group = G_VXD, inline = "vxz2")
float  i_vixL4 = input.float(40, "Panic ≥",           minval = 1, maxval = 50, step = 0.5, group = G_VXD, inline = "vxz2",
     tooltip = "VIX zone boundaries (keep them in increasing order). Defaults: Complacency below 12 · Calm 12–20 · Elevated 20–30 · High Fear 30–40 · Panic 40 and above.\nThe dial scale runs 0–50; readings above 50 peg the needle at the end.")

string G_VXS = "5 · VIX DIAL — 🎨 Style"
string i_vixSide    = input.string("Right of Fear & Greed", "Placement", options = ["Right of Fear & Greed", "Left of X10"], group = G_VXS,
     tooltip = "Right of Fear & Greed (default): the VIX dial sits at the far right, after the Fear & Greed dial (or after the X100 dial when Fear & Greed is off).\nLeft of X10: the VIX dial sits at the far left, before the X10 dial.")
int    i_vixGap     = input.int(0, "Separation (pixels)", minval = 0, maxval = 40, group = G_VXS,
     tooltip = "Blank space between the VIX dial and the dial next to it (Fear & Greed or X100 when placed on the right, X10 when placed on the left), in dial pixels (each step = one Pixel Width × Dial Size). 0 = touching, 2 = same spacing as between the X10 and X100 dials.")
color  i_vixCompl   = input.color(#00B8D4, "Complacency", group = G_VXS, inline = "vxc1")
color  i_vixCalm    = input.color(#00C853, "Calm",        group = G_VXS, inline = "vxc1")
color  i_vixElev    = input.color(#FFD600, "Elevated",    group = G_VXS, inline = "vxc2")
color  i_vixHigh    = input.color(#FF6D00, "High Fear",   group = G_VXS, inline = "vxc2")
color  i_vixPanic   = input.color(#D50000, "Panic",       group = G_VXS,
     tooltip = "Arc zone colors. The current zone's color also tints the VIX tags and analysis rows.")
int    i_vixUnlitTransp = input.int(75, "Unlit Arc Transparency", minval = 0, maxval = 100, group = G_VXS,
     tooltip = "The arc is fully lit up to the reading; the rest of the zone map stays visible at this transparency (100 = hidden).")
bool   i_vixAnalysis = input.bool(true, "Show Analysis Tooltip", group = G_VXS,
     tooltip = "Hover over any VIX tag (title, change, value or zone) to see the analysis:\n1) Percentile of the current VIX inside the Percentile Lookback, its distance from the average, and the lookback high/low range.\n2) Implied S&P 500 move: VIX ÷ √252 = expected 1-σ daily move, VIX ÷ √12 = expected 1-σ monthly move.\n3) Reading: the zone combined with the direction (above the average = volatility rising, below = easing).\nInformational only, not a trade signal.")
int    i_vixWrap     = input.int(16, "Text Line Width (chars)", minval = 8, maxval = 60, group = G_VXS,
     tooltip = "Longest line allowed in the VIX change tag; longer text wraps onto extra lines. Table cells grow to fit their text, so long single lines stretch the VIX dial sideways. Lower this if the dial looks wider than the others, raise it if you use a large Dial Size.")

f_vixCalc() =>
    [close, close[1], ta.sma(close, i_vixAvgLen), ta.percentrank(close, i_vixRankLen),
     ta.highest(high, i_vixRankLen), ta.lowest(low, i_vixRankLen)]

[vixVal, vixPrev, vixAvg, vixPct, vixHi, vixLo] = request.security(i_vixSym, i_vixTf, f_vixCalc(),
     lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// ── Security calls ────────────────────────────────────────────────────────────
daily_open   = request.security(syminfo.tickerid, 'D', open,  lookahead = barmerge.lookahead_on)
weekly_open  = request.security(syminfo.tickerid, 'W', open,  lookahead = barmerge.lookahead_on)
monthly_open = request.security(syminfo.tickerid, 'M', open,  lookahead = barmerge.lookahead_on)

// ── Reaction window (time/price lookback) ─────────────────────────────────────
secondsLen         = math.min(i_lookbackLength, 59)
lookbackTF         = i_lookbackUnit == 'Seconds' ? str.tostring(secondsLen) + 'S' : str.tostring(i_lookbackLength)
Close_lookback_ago = request.security(syminfo.tickerid, lookbackTF, close[1], lookahead = barmerge.lookahead_on)
atrValue           = ta.atr(i_atrLength)

// ── Colors ────────────────────────────────────────────────────────────────────
DOcolor     = close >= daily_open
daily_color = DOcolor ? color.teal : color.rgb(172, 0, 0)

BGcolor     = color.rgb(0, 0, 0, 100)
TachColor   = color.rgb(255, 255, 255)
text_color2 = color.rgb(255, 255, 255)

// ── RPM calculation ───────────────────────────────────────────────────────────
// Idle reset: last realtime price and when it last changed. Once the price
// has not changed for Reset Reading seconds, RPM reads 0 in every mode.
varip float lastPx    = na
varip int   lastChgMs = 0
if barstate.isrealtime and (na(lastPx) or close != lastPx)
    lastPx    := close
    lastChgMs := timenow
bool  idle = i_idleReset > 0 and barstate.isrealtime and lastChgMs > 0 and timenow - lastChgMs >= i_idleReset * 1000

// Reference price: normally the close one Reaction Window ago. After an idle
// reset the current price becomes the new reference, so the next move is
// measured from where price was resting instead of jumping back to the old
// window. The saved reference is used until one full Reaction Window has
// passed since the reset; after that the window is newer than the reset and
// the lookback close takes over again.
varip float refPx = na
varip int   refMs = 0
if idle
    refPx := close
    refMs := timenow
int   winMs    = i_lookbackUnit == 'Seconds' ? secondsLen * 1000 : i_lookbackLength * 60000
bool  useRef   = barstate.isrealtime and not na(refPx) and timenow - refMs < winMs
float refPrice = useRef ? refPx : Close_lookback_ago
float RPM      = idle ? 0.0 : close - refPrice

// ── Gauge builder ─────────────────────────────────────────────────────────────
f_bar(n, col) =>
    B = '⬛'
    C = col
    s7  = (n >= 1  ? C : B) + (n >= 2  ? C : B) + (n >= 3  ? C : B) +
          (n >= 4  ? C : B) + (n >= 5  ? C : B) + (n >= 6  ? C : B) + (n >= 7  ? C : B)
    s3a = (n >= 8  ? C : B) + (n >= 9  ? C : B) + (n >= 10 ? C : B)
    s3b = (n >= 11 ? C : B) + (n >= 12 ? C : B) + (n >= 13 ? C : B)
    s7 + '|' + s3a + '|' + s3b

// ── Dial helpers ──────────────────────────────────────────────────────────────
// Each dial mode draws two dials, mirroring the Classic bars:
//   X10 dial  :   0 – 500   (caution 400–450, redline 450+)
//   X100 dial : 100 – 1500  (caution 1000–1200, redline 1200+)
// Each is a linear 240° sweep from -120° (lo) to +120° (hi), angle measured
// clockwise from straight up. Readings past hi peg the needle 10° beyond the end.
X10_LO   = 0.0
X10_HI   = 500.0
X10_CAU  = 400.0
X10_RED  = 450.0
X100_LO  = 100.0
X100_HI  = 1500.0
X100_CAU = 1000.0
X100_RED = 1200.0

f_angDeg(float v, float lo, float hi) =>
    float vv = math.max(lo, math.min(v, hi + (hi - lo) / 24))
    -120 + (vv - lo) / (hi - lo) * 240

f_valFromDeg(float deg, float lo, float hi) =>
    lo + (deg + 120) / 240 * (hi - lo)

f_atan2(float y, float x) =>
    x > 0 ? math.atan(y / x) :
     x < 0 and y >= 0 ? math.atan(y / x) + math.pi :
     x < 0 ? math.atan(y / x) - math.pi :
     y > 0 ? math.pi / 2 : y < 0 ? -math.pi / 2 : 0.0

f_zoneColor(float v, color base, float cau, float red) =>
    v < cau ? base : v < red ? thCau : thRed

// Directional arc gradient (lo → caution start): dark → bright.
f_gradColor(float v, bool isBull, bool isWhite, float lo, float cau) =>
    isWhite ? color.white : color.from_gradient(v, lo, cau,
         isBull ? i_bullDark : i_bearDark, isBull ? i_bullBright : i_bearBright)

// Pixel Dial needle test: pixel (dx, dy from hub) lies on the ray at angle tRad.
f_pxNeedle(float dx, float dy, float tRad, float perpMax, float len) =>
    float proj = dx * math.sin(tRad) + dy * math.cos(tRad)
    float perp = math.abs(dx * math.cos(tRad) - dy * math.sin(tRad))
    proj > 0 and proj < len and perp < perpMax

// Scale numbers for each dial. Labels are shown at 1x (value ÷ 10 on
// X10, value ÷ 100 on X100); the X10 / X100 caption on each dial gives the
// multiplier, like the Classic bars.
x10V    = array.from(0.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0)
x10T    = array.from('0', '5', '10', '15', '20', '25', '30', '35', '40', '45', '50')
x100V   = array.from(100.0, 200.0, 400.0, 600.0, 800.0, 1000.0, 1200.0, 1400.0, 1500.0)
x100T   = array.from('1', '2', '4', '6', '8', '10', '12', '14', '15')

// ── State ─────────────────────────────────────────────────────────────────────
var bool   bull         = false
var bool   isStopped    = false
var string Tachimeter   = f_bar(0, '🟩')
var string Tachimeter2  = f_bar(0, '🟩')
var string Acceleration = 'None'
var string Tendency     = ''
var float  sRPMv        = 0.0
// varip so the peak survives realtime tick rollback and decays tick-by-tick.
varip float peakV       = 0.0
varip int   peakMs      = 0
// Displayed needle reading on the tach dials. Follows the live reading,
// except after an idle reset, when it glides back to rest.
varip float needleV     = 0.0
varip int   needleMs    = 0
varip bool  needleRet   = false

if barstate.islast
    absRPM        = math.abs(RPM)
    atrNormalized = i_useAdaptiveSensitivity and atrValue > 0 ? (absRPM / atrValue) * 100 : absRPM
    sRPM          = atrNormalized * i_sensitivity
    bull          := RPM >= 0
    isStopped     := sRPM < 10
    whiteMode     = i_gaugeColorMode == 'White'
    sRPMv         := nz(sRPM)

    // Needle return: an idle reset starts a return; while returning, the gap
    // between the needle and the live reading is halved every Needle Return
    // Half-Life seconds. A live reading above the needle takes over at once.
    if not barstate.isrealtime
        needleV   := sRPMv
        needleMs  := 0
        needleRet := false
    else
        if idle and needleV > sRPMv
            needleRet := true
        if needleRet and i_needleReturnHL > 0 and needleMs > 0
            float nEl  = math.max(0.0, (timenow - needleMs) / 1000.0)
            float nDec = sRPMv + (needleV - sRPMv) * math.pow(0.5, nEl / i_needleReturnHL)
            needleV := math.max(sRPMv, nDec)
            if needleV - sRPMv < 0.5
                needleV   := sRPMv
                needleRet := false
        else
            needleV   := sRPMv
            needleRet := false
        needleMs := timenow

    // Peak hold: jumps up instantly; otherwise the gap between the held peak
    // and the needle is halved every Peak Hold Half-Life seconds.
    // Runs on live ticks only. The historical load pass parks the peak on the
    // reading, and the first live tick starts it fresh, so a value left over
    // from the load (or an na reading) can't hide or replace the first peak.
    if not barstate.isrealtime
        peakV  := needleV
        peakMs := 0
    else if peakMs == 0 or na(peakV)
        peakV  := needleV
        peakMs := timenow
    else
        float elapsed = math.max(0.0, (timenow - peakMs) / 1000.0)
        float decayed = needleV + (peakV - needleV) * math.pow(0.5, elapsed / i_peakHalfLife)
        peakV  := needleV >= peakV ? needleV : decayed
        // Snap once the gap is negligible so the marker doesn't hover at the needle.
        if peakV - needleV < 0.5
            peakV := needleV
        peakMs := timenow

    cFill = whiteMode ? '⬜' : (bull ? '🟩' : '🟥')
    cHot  = whiteMode ? '⬜' : (bull ? '🟦' : '🟨')
    // Directional arrow is only meaningful once price has actually moved —
    // while the gauge is STOPPED (no reading past the Reaction Window
    // Length) it's replaced with a neutral ⬜ instead of the last
    // stale ▲/▼ direction.
    tend  = isStopped ? '🛑' : (bull ? '▲' : '▼')
    Tendency := tend

    // ── X10 bar ───────────────────────────────────────────────────────────────
    if sRPM >= 101
        Tachimeter := f_bar(13, cFill)
    else
        int t1blocks = sRPM < 10 ? 0 : int(sRPM / 10)
        Tachimeter := f_bar(t1blocks, cFill)

    // ── X100 bar ──────────────────────────────────────────────────────────────
    if sRPM < 101
        Tachimeter2 := f_bar(0, cFill)
    else
        int t2blocks = sRPM < 200  ? 1  :
                       sRPM < 300  ? 2  :
                       sRPM < 400  ? 3  :
                       sRPM < 500  ? 4  :
                       sRPM < 600  ? 5  :
                       sRPM < 700  ? 6  :
                       sRPM < 800  ? 7  :
                       sRPM < 900  ? 8  :
                       sRPM < 1000 ? 9  :
                       sRPM < 1100 ? 10 :
                       sRPM < 1200 ? 11 :
                       sRPM < 1300 ? 12 : 13

        s7  = ''
        for i = 1 to 7
            s7 += t2blocks >= i ? cFill : '⬛'
        s3a = ''
        for i = 8 to 10
            s3a += t2blocks >= i ? cFill : '⬛'
        s3b = ''
        for i = 11 to 13
            s3b += t2blocks >= i ? cHot : '⬛'
        Tachimeter2 := s7 + '|' + s3a + '|' + s3b

    // ── Acceleration label ────────────────────────────────────────────────────
    Acceleration :=
         sRPM < 10   ? 'S  T  O  P  P  E  D'                     :
         sRPM < 101  ? 'I  D  L  I  N  G'                        :
         sRPM < 200  ? 'E X T R E M E L Y   W E A K'             :
         sRPM < 300  ? 'V E R Y   W E A K'                       :
         sRPM < 400  ? 'W E A K'                                  :
         sRPM < 500  ? 'M O S T L Y   W E A K'                   :
         sRPM < 600  ? 'S O M E W H A T   W E A K'               :
         sRPM < 700  ? 'M O D E R A T E L Y   W E A K'           :
         sRPM < 800  ? 'M O D E R A T E'                         :
         sRPM < 900  ? 'M O D E R A T E L Y   S T R O N G'       :
         sRPM < 1000 ? 'M O S T L Y   S T R O N G'               :
         sRPM < 1100 ? '  S T R O N G'                           :
         sRPM < 1200 ? 'V E R Y   S T R O N G'                   :
         sRPM < 1300 ? 'E X C E P T I O N A L L Y   S T R O N G' :
                       'U L T R A   S T R O N G'

// ── Table ─────────────────────────────────────────────────────────────────────
Scale  = '      ₂        ₄        ₆         ₈       ₁₀   ₁₁  ₁₂  ₁₃'
Scale2 = ' ⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒⏒'

// Dashboard is only drawn in Classic mode (the Pixel Dials carry the
// title, RPM, price and acceleration info themselves).
if barstate.islast and currentPrice and i_gaugeMode == 'Classic X10/X100 Bars'
    TACHIMETER = table.new(position = tablePosition, columns = 5, rows = 7,
         bgcolor = BGcolor, frame_color = f_dim(color.rgb(0, 0, 0)),
         frame_width = 1, border_width = 1)

    gaugeText = Scale2 + '\n' + Tachimeter + '\n' + Scale + '\n' + Tachimeter2 + '\n' + Scale2

    // RPM and Price value cells share this background: the usual
    // bullish/bearish teal-or-red while the gauge is actively reading a
    // move, swapped to the user-selectable Stopped Value Cell Background
    // whenever the gauge is STOPPED (see isStopped above).
    valueCellBg = f_dim(isStopped ? color.new(i_stoppedColor, 50) : color.new(bull ? color.teal : color.red, 50))

    // ── Gap row ───────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 0, '',
          bgcolor = BGcolor)
    table.merge_cells(TACHIMETER, 0, 0, 3, 0)

    // ── Title row ─────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 1,
         t.toFont(fromText = 'P  R  I  C  E  -  T  A  C  H', font = "Rounded"),
         bgcolor = f_dim(color.new(daily_color, 65)),
         text_color = f_dim(text_color2),
         text_size = tableTextSize)
    table.merge_cells(TACHIMETER, 0, 1, 2, 1)

    table.cell(TACHIMETER, 3, 1, Acceleration,
         bgcolor = f_dim(color.new(daily_color, 65)),
         text_color = f_dim(text_color2),
         text_size = size.tiny,
         width = 9)

    // ── Gauge row ─────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 2, 'X10\n\nX100',
         bgcolor = f_dim(color.new(bull ? color.teal : color.red, 50)),
         text_color = f_dim(TachColor),
         text_size = tableTextSize,
         text_halign = text.align_right)

    table.cell(TACHIMETER, 1, 2, gaugeText,
         bgcolor = f_dim(color.new(bull ? color.rgb(0, 85, 76) : color.rgb(146, 1, 1), 50)),
         text_color = f_dim(TachColor),
         text_size = tableTextSize,
         text_halign = text.align_left)

    table.cell(TACHIMETER, 2, 2,
         t.toFont(fromText = (RPM >= 0 ? '+' : '') + str.tostring(RPM, '00'), font = 'Monospace'),
         bgcolor = valueCellBg,
         text_color = f_dim(TachColor),
         text_size = size.normal)

    table.cell(TACHIMETER, 3, 2,
         t.toFont(fromText = str.tostring(close, '$' + '00,000 ') + Tendency, font = str.tostring(i_priceFont)),
         bgcolor = valueCellBg,
         text_color = f_dim(TachColor),
         text_size = i_priceSize)

    // ── Bottom bar row ────────────────────────────────────────────────────────
    if i_showBottomBar
        table.cell(TACHIMETER, 0, 3, ' ',
             bgcolor = f_dim(color.new(daily_color, 65)),
             text_color = f_dim(text_color2),
             text_size = size.tiny)
        table.merge_cells(TACHIMETER, 0, 3, 3, 3)
    else
        table.cell(TACHIMETER, 0, 3, '',
             bgcolor = BGcolor)
        table.merge_cells(TACHIMETER, 0, 3, 3, 3)

// ── Pixel Dial (table cells as pixels) ────────────────────────────────────────
// Two dials side by side in one table — X10 (0–500) left, X100 (100–1500)
// right — separated by PX_GAP blank columns. Each dial is a 41 × 27 grid in
// pixel units (odd column count keeps a true center column for the hub).
// Table row 0 holds the title tag, rows 1..PX_ROWS the dials, and the last
// three rows the RPM / price / acceleration tags.
PX_COLS = 41
PX_ROWS = 27
PX_CX   = 20.0
PX_CY   = 18.5
PX_R    = 17.2
PX_GAP  = 2

// Dial face color for grid row j: the theme face color at the top, fading
// to Bottom Opacity % of its own opacity at the last row.
f_faceAt(int j) =>
    float topOp = 100 - color.t(thFace)
    float frac  = i_pxFaceGrad ? j / (PX_ROWS - 1.0) : 0.0
    float op    = topOp * (1 - frac * (1 - i_pxFaceGradPct / 100.0))
    color.new(thFace, 100 - op)

// Draws one dial into tb starting at column ox.
f_pxDial(table tb, int ox, float lo, float hi, float cau, float red, array<float> numV, array<string> numT, string cap, float pw, float ph) =>
    bool  wm    = i_gaugeColorMode == 'White'
    // Needle is capped at the end of the scale here (no room to peg past it).
    float tRad  = math.toradians(math.min(f_angDeg(needleV, lo, hi), 120.0))
    float sweep = math.toradians(120.0)
    float nPerp = 0.3 + 0.2 * i_pxNeedleWidth
    float nLen  = PX_R - 2.4
    float hubR  = 1.0 + 0.15 * i_pxNeedleWidth
    float faceR = PX_R * 1.08
    // Peak marker angle; hidden when the peak is back at (or within one arc
    // pixel of) the needle, or below this dial's start.
    float pRad   = math.toradians(math.min(f_angDeg(peakV, lo, hi), 120.0))
    bool  showPk = i_peakMarker and peakV > needleV and peakV > lo and math.abs(pRad - tRad) > 0.06
    for j = 0 to PX_ROWS - 1
        color rowFace = f_faceAt(j)
        for i = 0 to PX_COLS - 1
            float dx  = i - PX_CX
            float dy  = PX_CY - j
            float d   = math.sqrt(dx * dx + dy * dy)
            float a   = f_atan2(dx, dy)
            color col = d <= faceR ? rowFace : BGcolor
            // Arc ring: lit up to the needle, faded trail up to the peak,
            // bright marker at the peak.
            if math.abs(d - PX_R) < 1.2 and math.abs(a) <= sweep
                float cv = f_valFromDeg(math.todegrees(a), lo, hi)
                color zc = f_zoneColor(cv, f_gradColor(cv, bull, wm, lo, cau), cau, red)
                col := cv <= needleV ? zc : cv <= peakV ? color.new(zc, i_peakTrailTransp) : thTrack
                if showPk and math.abs(a - pRad) < 0.045
                    col := thNeedle
            // Needle and hub.
            if f_pxNeedle(dx, dy, tRad, nPerp, nLen) or d < hubR
                col := thNeedle
            table.cell(tb, ox + i, j + 1, '', width = pw, height = ph, bgcolor = f_dim(col))

    // Scale numbers in 4 × 2 blocks at 0.80 of the radius (inside the old
    // tick-mark band); skipped while the needle crosses a block so it stays
    // visible. Layout verified for both scales: no block overlaps another
    // block, the arc ring or the scale caption.
    for [k, mv] in numV
        float ta = math.toradians(f_angDeg(mv, lo, hi))
        int   i0 = int(math.round(PX_CX + PX_R * 0.80 * math.sin(ta) - 1.5))
        int   j0 = int(math.round(PX_CY - PX_R * 0.80 * math.cos(ta) - 0.5))
        bool  hit = false
        for jj = j0 to j0 + 1
            for ii = i0 to i0 + 3
                float bdx = ii - PX_CX
                float bdy = PX_CY - jj
                if f_pxNeedle(bdx, bdy, tRad, nPerp, nLen) or math.sqrt(bdx * bdx + bdy * bdy) < hubR
                    hit := true
        if not hit
            table.cell(tb, ox + i0, j0 + 1, numT.get(k), width = pw, height = ph,
                 text_color = f_dim(thScale), text_size = i_pxScaleNumSize, bgcolor = f_dim(f_faceAt(j0)))
            table.merge_cells(tb, ox + i0, j0 + 1, ox + i0 + 3, j0 + 2)

    // Scale caption (X10 / X100) in the open bottom, clear of the needle at
    // any thickness.
    table.cell(tb, ox + 17, 24, cap, width = pw, height = ph,
         text_color = f_dim(thScale), text_size = i_pxScaleNumSize, bgcolor = f_dim(f_faceAt(23)))
    table.merge_cells(tb, ox + 17, 24, ox + 23, 27)

// ── Fear & Greed Pixel Dial ───────────────────────────────────────────────────
// Same 41 × 27 grid, face, needle and number geometry as the tach dials,
// on a 0–100 scale with fixed sentiment zones.
FG_LO = 0.0
FG_HI = 100.0
fgScaleV = array.from(0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0)
fgScaleT = array.from('0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100')

f_fgZoneColor(float v) =>
    v < 25 ? i_fgExFear : v < 45 ? i_fgFear : v < 55 ? i_fgNeutral : v < 75 ? i_fgGreed : i_fgExGreed

f_fgLabel(float v) =>
    v < 25 ? 'E X T R E M E   F E A R' : v < 45 ? 'F E A R' : v < 55 ? 'N E U T R A L' :
     v < 75 ? 'G R E E D' : 'E X T R E M E   G R E E D'

// ── VIX Pixel Dial ────────────────────────────────────────────────────────────
// Same geometry, 0–50 scale (numbers every 5, X10 block positions).
VIX_LO = 0.0
VIX_HI = 50.0
vixScaleV = array.from(0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0)
vixScaleT = array.from('0', '5', '10', '15', '20', '25', '30', '35', '40', '45', '50')

f_vixZoneColor(float v) =>
    v < i_vixL1 ? i_vixCompl : v < i_vixL2 ? i_vixCalm : v < i_vixL3 ? i_vixElev : v < i_vixL4 ? i_vixHigh : i_vixPanic

f_vixLabel(float v) =>
    v < i_vixL1 ? 'COMPLACENCY' : v < i_vixL2 ? 'C A L M' : v < i_vixL3 ? 'ELEVATED' :
     v < i_vixL4 ? 'HIGH FEAR' : 'P A N I C'

// Joins parts with sep, starting a new line whenever a line would pass w
// characters, so text stays inside the dial's width.
f_wrap(array<string> parts, string sep, int w) =>
    string out  = ''
    string line = ''
    for p in parts
        if p != ''
            if line == ''
                line := p
            else if str.length(line) + str.length(sep) + str.length(p) <= w
                line := line + sep + p
            else
                out  := out == '' ? line : out + '\n' + line
                line := p
    out == '' ? line : line == '' ? out : out + '\n' + line

// Zone + direction reading for the analysis row.
f_vixRead(float v, bool rising) =>
    v < i_vixL1 ? (rising ? 'Complacent, but volatility is waking up' : 'Complacent: cheap hedging, spike risk') :
     v < i_vixL2 ? (rising ? 'Normal range, volatility edging up'     : 'Normal range, calm conditions')        :
     v < i_vixL3 ? (rising ? 'Stress building, risk-off pressure'      : 'Elevated but easing')                  :
     v < i_vixL4 ? (rising ? 'High fear, heavy hedging demand'         : 'High fear, starting to cool')          :
                   (rising ? 'Panic levels, extreme market stress'     : 'Panic levels, stress may be peaking')

// Zone dial shared by the Fear & Greed and VIX dials (isVix picks the zones).
f_pxZoneDial(table tb, int ox, float v, float lo, float hi, array<float> numV, array<string> numT, string cap, bool isVix, float pw, float ph) =>
    int   unlitT = isVix ? i_vixUnlitTransp : i_fgUnlitTransp
    float vv    = nz(v, lo)
    float tRad  = math.toradians(math.min(f_angDeg(vv, lo, hi), 120.0))
    float sweep = math.toradians(120.0)
    float nPerp = 0.3 + 0.2 * i_pxNeedleWidth
    float nLen  = PX_R - 2.4
    float hubR  = 1.0 + 0.15 * i_pxNeedleWidth
    float faceR = PX_R * 1.08
    for j = 0 to PX_ROWS - 1
        color rowFace = f_faceAt(j)
        for i = 0 to PX_COLS - 1
            float dx  = i - PX_CX
            float dy  = PX_CY - j
            float d   = math.sqrt(dx * dx + dy * dy)
            float a   = f_atan2(dx, dy)
            color col = d <= faceR ? rowFace : BGcolor
            // Arc ring: zone map, fully lit up to the reading.
            if math.abs(d - PX_R) < 1.2 and math.abs(a) <= sweep
                float cv = f_valFromDeg(math.todegrees(a), lo, hi)
                color zc = isVix ? f_vixZoneColor(cv) : f_fgZoneColor(cv)
                col := not na(v) and cv <= vv ? zc : color.new(zc, unlitT)
            if f_pxNeedle(dx, dy, tRad, nPerp, nLen) or d < hubR
                col := thNeedle
            table.cell(tb, ox + i, j + 1, '', width = pw, height = ph, bgcolor = f_dim(col))

    // Scale numbers (11 evenly spaced, same block positions as the X10 dial).
    for [k, mv] in numV
        float ta = math.toradians(f_angDeg(mv, lo, hi))
        int   i0 = int(math.round(PX_CX + PX_R * 0.80 * math.sin(ta) - 1.5))
        int   j0 = int(math.round(PX_CY - PX_R * 0.80 * math.cos(ta) - 0.5))
        bool  hit = false
        for jj = j0 to j0 + 1
            for ii = i0 to i0 + 3
                float bdx = ii - PX_CX
                float bdy = PX_CY - jj
                if f_pxNeedle(bdx, bdy, tRad, nPerp, nLen) or math.sqrt(bdx * bdx + bdy * bdy) < hubR
                    hit := true
        if not hit
            table.cell(tb, ox + i0, j0 + 1, numT.get(k), width = pw, height = ph,
                 text_color = f_dim(thScale), text_size = i_pxScaleNumSize, bgcolor = f_dim(f_faceAt(j0)))
            table.merge_cells(tb, ox + i0, j0 + 1, ox + i0 + 3, j0 + 2)

    table.cell(tb, ox + 17, 24, cap, width = pw, height = ph,
         text_color = f_dim(thScale), text_size = i_pxScaleNumSize, bgcolor = f_dim(f_faceAt(23)))
    table.merge_cells(tb, ox + 17, 24, ox + 23, 27)

if barstate.islast and i_gaugeMode == 'Pixel Dial'
    float pw    = i_pxW * i_pxScale
    float ph    = i_pxH * i_pxScale
    int   tachCols = 2 * PX_COLS + PX_GAP
    // Column layout, left to right:
    //   VIX right (default): [X10 | gap | X100] [gap + F&G] [gap + VIX]
    //   VIX left           : [VIX + gap] [X10 | gap | X100] [gap + F&G]
    bool  vixRight = i_vixSide == "Right of Fear & Greed"
    int   tx       = i_vixShow and not vixRight ? PX_COLS + i_vixGap : 0
    int   tachEnd  = tx + tachCols
    int   fgOx     = tachEnd + i_fgGap
    int   fgEnd    = i_fgShow ? fgOx + PX_COLS : tachEnd
    int   vixGap0  = vixRight ? fgEnd : PX_COLS
    int   vixOx    = vixRight ? fgEnd + i_vixGap : 0
    int   nCols    = i_vixShow and vixRight ? vixOx + PX_COLS : fgEnd
    DIAL = table.new(position = i_pxPos, columns = nCols, rows = PX_ROWS + 4,
         bgcolor = BGcolor, border_width = 1, border_color = BGcolor)
    f_pxDial(DIAL, tx, X10_LO, X10_HI, X10_CAU, X10_RED, x10V, x10T, 'X10', pw, ph)
    f_pxDial(DIAL, tx + PX_COLS + PX_GAP, X100_LO, X100_HI, X100_CAU, X100_RED, x100V, x100T, 'X100', pw, ph)
    // Blank gap columns between the dials.
    for g = 0 to PX_GAP - 1
        for j = 1 to PX_ROWS
            table.cell(DIAL, tx + PX_COLS + g, j, '', width = pw, height = ph, bgcolor = BGcolor)
    // Fear & Greed dial to the right of the X100 dial.
    if i_fgShow
        if i_fgGap > 0
            for g = 0 to i_fgGap - 1
                for j = 1 to PX_ROWS
                    table.cell(DIAL, tachEnd + g, j, '', width = pw, height = ph, bgcolor = BGcolor)
        f_pxZoneDial(DIAL, fgOx, fgVal, FG_LO, FG_HI, fgScaleV, fgScaleT, 'F&G', false, pw, ph)
    // VIX dial (far right or far left, see Placement).
    if i_vixShow
        f_pxZoneDial(DIAL, vixOx, vixVal, VIX_LO, VIX_HI, vixScaleV, vixScaleT, 'VIX', true, pw, ph)
        if i_vixGap > 0
            for g = 0 to i_vixGap - 1
                for j = 1 to PX_ROWS
                    table.cell(DIAL, vixGap0 + g, j, '', width = pw, height = ph, bgcolor = BGcolor)

    // ── Dashboard info on the dials ───────────────────────────────────────────
    // Same color logic as the dashboard: header items use the daily-open
    // color, value items use teal/red (or the Stopped background). Text uses
    // the Dial Color Theme's tag text color.
    color pxValBg = f_dim(isStopped ? color.new(i_stoppedColor, 50) : color.new(bull ? color.teal : color.red, 50))
    color pxHdrBg = f_dim(color.new(daily_color, 65))

    // Title above the dials.
    table.cell(DIAL, tx, 0, t.toFont(fromText = 'P  R  I  C  E  -  T  A  C  H', font = 'Rounded'),
         width = pw, text_color = f_dim(thText), text_size = i_pxTitleSize, bgcolor = pxHdrBg)
    table.merge_cells(DIAL, tx, 0, tachEnd - 1, 0)

    // Signed RPM (raw price move) + normalized reading + the reference price
    // the move is measured from (lookback close, or the resting price after
    // an idle reset).
    table.cell(DIAL, tx, PX_ROWS + 1,
         t.toFont(fromText = (RPM >= 0 ? '+' : '') + str.tostring(RPM, '00'), font = 'Monospace') +
         '   ' + str.tostring(sRPMv, '#') + (i_useAdaptiveSensitivity ? ' % ATR' : ' sRPM') +
         '   REF ' + str.tostring(refPrice, '$' + '00,000'),
         width = pw, text_color = f_dim(thText), text_size = i_pxRpmSize, bgcolor = pxValBg)
    table.merge_cells(DIAL, tx, PX_ROWS + 1, tachEnd - 1, PX_ROWS + 1)

    // Current price + direction marker.
    table.cell(DIAL, tx, PX_ROWS + 2,
         t.toFont(fromText = str.tostring(close, '$' + '00,000 ') + Tendency, font = str.tostring(i_priceFont)),
         width = pw, text_color = f_dim(thText), text_size = i_pxPriceSize, bgcolor = pxValBg)
    table.merge_cells(DIAL, tx, PX_ROWS + 2, tachEnd - 1, PX_ROWS + 2)

    // Acceleration label.
    table.cell(DIAL, tx, PX_ROWS + 3, Acceleration,
         width = pw, text_color = f_dim(thText), text_size = i_pxAccelSize, bgcolor = pxHdrBg)
    table.merge_cells(DIAL, tx, PX_ROWS + 3, tachEnd - 1, PX_ROWS + 3)

    // ── Fear & Greed tags (same rows / sizes as the tach tags) ────────────────
    if i_fgShow
        bool   fgNa    = na(fgVal)
        float  fgR     = math.round(nz(fgVal))
        color  fgCol   = fgNa ? i_stoppedColor : f_fgZoneColor(fgR)
        float  fgChg   = fgVal - fgPrev
        string fgPrevS = na(fgPrev) ? '--' : str.tostring(fgPrev, '0')
        string fgChgS  = na(fgChg) ? '--' : (fgChg >= 0 ? '+' : '') + str.tostring(fgChg, '0')
        string fgArrow = na(fgChg) ? '' : fgChg > 0 ? ' ▲' : fgChg < 0 ? ' ▼' : ''

        table.cell(DIAL, fgOx, 0, t.toFont(fromText = 'F  E  A  R  &  G  R  E  E  D', font = 'Rounded'),
             width = pw, text_color = f_dim(thText), text_size = i_pxTitleSize, bgcolor = f_dim(color.new(fgCol, 65)))
        table.merge_cells(DIAL, fgOx, 0, fgEnd - 1, 0)

        table.cell(DIAL, fgOx, PX_ROWS + 1, fgNa ? 'NO DATA' : 'PREV ' + fgPrevS + '   Δ ' + fgChgS,
             width = pw, text_color = f_dim(thText), text_size = i_pxRpmSize, bgcolor = f_dim(color.new(fgCol, 50)))
        table.merge_cells(DIAL, fgOx, PX_ROWS + 1, fgEnd - 1, PX_ROWS + 1)

        table.cell(DIAL, fgOx, PX_ROWS + 2,
             t.toFont(fromText = fgNa ? '--' : str.tostring(fgR, '0') + ' / 100' + fgArrow, font = str.tostring(i_priceFont)),
             width = pw, text_color = f_dim(thText), text_size = i_pxPriceSize, bgcolor = f_dim(color.new(fgCol, 50)))
        table.merge_cells(DIAL, fgOx, PX_ROWS + 2, fgEnd - 1, PX_ROWS + 2)

        table.cell(DIAL, fgOx, PX_ROWS + 3, fgNa ? '—' : f_fgLabel(fgR),
             width = pw, text_color = f_dim(thText), text_size = i_pxAccelSize, bgcolor = f_dim(color.new(fgCol, 65)))
        table.merge_cells(DIAL, fgOx, PX_ROWS + 3, fgEnd - 1, PX_ROWS + 3)

    // ── VIX tags (same rows / sizes as the tach tags); analysis in tooltip ────
    if i_vixShow
        bool   vxNa    = na(vixVal)
        color  vxCol   = vxNa ? i_stoppedColor : f_vixZoneColor(vixVal)
        float  vxChg   = vixVal - vixPrev
        float  vxChgP  = vixPrev > 0 ? vxChg / vixPrev * 100 : na
        string vxChgS  = na(vxChg) ? '--' : (vxChg >= 0 ? '+' : '') + str.tostring(vxChg, '0.00') +
                         (na(vxChgP) ? '' : ' (' + (vxChgP >= 0 ? '+' : '') + str.tostring(vxChgP, '0.0') + '%)')
        string vxArrow = na(vxChg) ? '' : vxChg > 0 ? ' ▲' : vxChg < 0 ? ' ▼' : ''
        int    vxEnd   = vixOx + PX_COLS - 1

        // Analysis text shown on hover.
        string vxTip = ''
        if i_vixAnalysis and not vxNa
            bool   rising  = not na(vixAvg) and vixVal > vixAvg
            float  avgDist = vixAvg > 0 ? (vixVal - vixAvg) / vixAvg * 100 : na
            vxTip := 'VIX ' + str.tostring(vixVal, '0.00') + '  ·  ' + f_vixLabel(vixVal) +
                 '\nPrevious: ' + (na(vixPrev) ? '--' : str.tostring(vixPrev, '0.00')) + '   Δ ' + vxChgS +
                 '\nPercentile (' + str.tostring(i_vixRankLen) + ' bars): ' + (na(vixPct) ? '--' : str.tostring(vixPct, '0')) +
                 '\n' + str.tostring(i_vixAvgLen) + '-bar average: ' + (na(vixAvg) ? '--' : str.tostring(vixAvg, '0.00')) +
                 (na(avgDist) ? '' : ' (' + (avgDist >= 0 ? '+' : '') + str.tostring(avgDist, '0.0') + '%)') +
                 (rising ? ' → rising' : ' → easing') +
                 '\nRange: ' + str.tostring(vixLo, '0.00') + ' – ' + str.tostring(vixHi, '0.00') +
                 '\nImplied SPX move: ±' + str.tostring(vixVal / math.sqrt(252), '0.00') + '% / day  ·  ±' +
                 str.tostring(vixVal / math.sqrt(12), '0.00') + '% / month' +
                 '\nReading: ' + f_vixRead(vixVal, rising) +
                 '\nInformational only, not a trade signal.'

        table.cell(DIAL, vixOx, 0, t.toFont(fromText = 'V  I  X', font = 'Rounded'),
             width = pw, text_color = f_dim(thText), text_size = i_pxTitleSize, bgcolor = f_dim(color.new(vxCol, 65)), tooltip = vxTip)
        table.merge_cells(DIAL, vixOx, 0, vxEnd, 0)

        table.cell(DIAL, vixOx, PX_ROWS + 1,
             vxNa ? 'NO DATA' : f_wrap(str.split('Δ ' + vxChgS, ' '), ' ', i_vixWrap),
             width = pw, text_color = f_dim(thText), text_size = i_pxRpmSize, bgcolor = f_dim(color.new(vxCol, 50)), tooltip = vxTip)
        table.merge_cells(DIAL, vixOx, PX_ROWS + 1, vxEnd, PX_ROWS + 1)

        table.cell(DIAL, vixOx, PX_ROWS + 2,
             t.toFont(fromText = vxNa ? '--' : str.tostring(vixVal, '0.00') + vxArrow, font = str.tostring(i_priceFont)),
             width = pw, text_color = f_dim(thText), text_size = i_pxPriceSize, bgcolor = f_dim(color.new(vxCol, 50)), tooltip = vxTip)
        table.merge_cells(DIAL, vixOx, PX_ROWS + 2, vxEnd, PX_ROWS + 2)

        table.cell(DIAL, vixOx, PX_ROWS + 3, vxNa ? '—' : f_vixLabel(vixVal),
             width = pw, text_color = f_dim(thText), text_size = i_pxAccelSize, bgcolor = f_dim(color.new(vxCol, 65)), tooltip = vxTip)
        table.merge_cells(DIAL, vixOx, PX_ROWS + 3, vxEnd, PX_ROWS + 3)

// ── Dot Matrix Price — constants / geometry ──────────────────────────────────
int    MAX_DIGITS  = 7
int    MAX_PRICE   = 9999999
string U_DIGIT     = "<U8>"     // token: unlit digit placeholder
string U_COMMA     = "<U,>"     // token: unlit comma placeholder
color  CLEAR       = color.new(#000000, 100)

int  T     = 1                  // top / bottom panel margin
int  GW    = 5                  // digit width
int  BH    = 7                  // glyph body height
int  GH    = BH + 2 * T         // canvas height

// 5×7 panel font: char → row-major bitmap, 7 rows, width = length / 7
var map<string, string> FONT = map.new<string, string>()

// ── Dot Matrix Price — functions ─────────────────────────────────────────────
posFrom(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

sizeFrom(string s) =>
    switch s
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

lowWidth(string ch) =>
    int(str.length(FONT.get(ch)) / BH)

tokenWidth(string tok) =>
    tok == U_DIGIT ? GW : tok == U_COMMA ? lowWidth(",") : lowWidth(tok)

// Font pixel. Returns 1 lit, 0 unlit dot inside the glyph, -1 outside / placeholder
lowPixel(string tok, int c, int r) =>
    int st = -1
    if r >= T and r < T + BH and tok != U_DIGIT and tok != U_COMMA
        string bits = FONT.get(tok)
        int    i    = (r - T) * lowWidth(tok) + c
        st := str.substring(bits, i, i + 1) == "#" ? 1 : 0
    st

// Appends every renderable character of txt
pushText(array<string> arr, string txt) =>
    if str.length(txt) > 0
        for ch in str.split(txt, "")
            if FONT.contains(ch)
                arr.push(ch)
    arr

// tb (not t) so the fikira Text library alias isn't shadowed
drawCell(table tb, int c, int r, color clr, string sz, bool bgMode) =>
    if bgMode
        tb.cell(c, r, iDot, width = iCellW, height = iCellH, text_color = CLEAR, text_size = sz, bgcolor = clr, text_font_family = font.family_monospace)
    else
        tb.cell(c, r, iDot, width = iCellW, height = iCellH, text_color = clr, text_size = sz, text_font_family = font.family_monospace)

// ── Dot Matrix Price — glyph maps ────────────────────────────────────────────
// 5×7 panel font (digits, $ , . space, A–Z, a–z, symbols)
if barstate.isfirst
    FONT.put("0", ".###.#...##...##...##...##...#.###.")
    FONT.put("1", "..#...##....#....#....#....#....#..")
    FONT.put("2", "####.....#....#.###.#....#....#####")
    FONT.put("3", ".###.#...#....#..##.....##...#.###.")
    FONT.put("4", "...#...##..#.#.#..#.#####...#....#.")
    FONT.put("5", "######....#....####.....##...#.###.")
    FONT.put("6", ".###.#...##....####.#...##...#.###.")
    FONT.put("7", "######...##...#...#...#....#....#..")
    FONT.put("8", ".###.#...##...#.###.#...##...#.###.")
    FONT.put("9", ".###.#...##...#.####....##...#.###.")
    FONT.put("$", "..#...#####.#...###...#.#####...#..")
    FONT.put(",", "........##.##.")
    FONT.put(".", "..........####")
    FONT.put(" ", ".....................")
    FONT.put("A", ".###.#...##...#######...##...##...#")
    FONT.put("B", "####.#...##...#####.#...##...#####.")
    FONT.put("C", ".###.#...##....#....#....#...#.###.")
    FONT.put("D", "####.#...##...##...##...##...#####.")
    FONT.put("E", "######....#....######....#....#####")
    FONT.put("F", "######....#....######....#....#....")
    FONT.put("G", ".###.#...##....#.####...##...#.###.")
    FONT.put("H", "#...##...##...#######...##...##...#")
    FONT.put("I", ".###...#....#....#....#....#...###.")
    FONT.put("J", "..###....#....#....##...##...#.###.")
    FONT.put("K", "#...##..#.#.#..##...#.#..#..#.#...#")
    FONT.put("L", "#....#....#....#....#....#....#####")
    FONT.put("M", "#...###.###.#.##.#.##...##...##...#")
    FONT.put("N", "#...##...###..##.#.##..###...##...#")
    FONT.put("O", ".###.#...##...##...##...##...#.###.")
    FONT.put("P", "####.#...##...#####.#....#....#....")
    FONT.put("Q", ".###.#...##...##...##.#.##..##.####")
    FONT.put("R", "####.#...##...#####.#.#..#..#.#...#")
    FONT.put("S", ".###.#...##.....###.....##...#.###.")
    FONT.put("T", "#####..#....#....#....#....#....#..")
    FONT.put("U", "#...##...##...##...##...##...#.###.")
    FONT.put("V", "#...##...##...##...##...#.#.#...#..")
    FONT.put("W", "#...##...##...##.#.##.#.###.###...#")
    FONT.put("X", "#...##...#.#.#...#...#.#.#...##...#")
    FONT.put("Y", "#...##...##...#.#.#...#....#....#..")
    FONT.put("Z", "#####....#...#...#...#...#....#####")
    FONT.put("a", "......###.....#.#####...##...#.####")
    FONT.put("b", "#....#....#....####.#...##...#####.")
    FONT.put("c", "...........###.#...##....#...#.###.")
    FONT.put("d", "....#....#....#.#####...##...#.####")
    FONT.put("e", "...........###.#...#######.....###.")
    FONT.put("f", "..##..#....#...####..#....#....#...")
    FONT.put("g", "......#####...##...#.####....#.###.")
    FONT.put("h", "#....#....#....####.#...##...##...#")
    FONT.put("i", ".......#.........#....#....#....#..")
    FONT.put("j", "....#.........#....##...##...#.###.")
    FONT.put("k", "#....#....#..#.#.#..##...#.#..#..#.")
    FONT.put("l", "..#....#....#....#....#....#....##.")
    FONT.put("m", "...............##.#.#.#.##.#.##.#.#")
    FONT.put("n", "..........#.##.##..##...##...##...#")
    FONT.put("o", "...........###.#...##...##...#.###.")
    FONT.put("p", "..........####.#...#####.#....#....")
    FONT.put("q", "...........#####...#.####....#....#")
    FONT.put("r", "..........#.##.##..##....#....#....")
    FONT.put("s", "...........#####.....###.....#####.")
    FONT.put("t", ".......#....#...###...#....#....##.")
    FONT.put("u", "..........#...##...##...##..##.##.#")
    FONT.put("v", "..........#...##...##...#.#.#...#..")
    FONT.put("w", "..........#...##.#.##.#.###.###...#")
    FONT.put("x", "..........#...#.#.#...#...#.#.#...#")
    FONT.put("y", "..........#...##...#.####....#.###.")
    FONT.put("z", "..........#####...#...#...#...#####")
    FONT.put("!", "..#....#....#....#....#.........#..")
    FONT.put("?", ".###.#...##...#...#...#.........#..")
    FONT.put("/", ".........#...#...#...#...#.........")
    FONT.put(":", ".......#...................#.......")
    FONT.put("+", ".......#....#..#####..#....#.......")
    FONT.put("-", "...............#####...............")
    FONT.put("×", ".....#...#.#.#...#...#.#.#...#.....")
    FONT.put("÷", ".......#.......#####.......#.......")
    FONT.put("=", "..........#####.....#####..........")
    FONT.put("%", ".....##..###.#...#...#.###..##.....")
    FONT.put("&", ".##..#..#.#..#..##..#.#.##..#..##.#")
    FONT.put("#", ".#.#.#####.#.#..#.#..#.#.#####.#.#.")
    FONT.put("(", "..##..#....#....#....#....#.....##.")
    FONT.put(")", ".##.....#....#....#....#....#..##..")
    FONT.put(">", ".#.....#.....#.....#...#...#...#...")
    FONT.put("<", "...#...#...#...#.....#.....#.....#.")

// ── Dot Matrix Price — render (Pixel Dial mode only; never created in Classic)
var table tbl = na
bool isUp = close >= nz(close[1], close)

if barstate.islast and iShow and i_gaugeMode == 'Pixel Dial'
    bool   bgMode = iFill == "Cell Background"
    string sz     = sizeFrom(iSizeStr)
    color  onCol  = f_dim(iColMode == "Static" ? iOnCol : isUp ? bullBase : bearBase)
    color  offCol = f_dim(iGhost ? iGhostCol : CLEAR)

    // ── Build token sequence
    array<string> glyphs = array.new<string>()
    if iCaption
        pushText(glyphs, syminfo.ticker + " ")
    if iMode == "Price"
        int    px    = math.max(0, math.min(math.round(close), MAX_PRICE))
        string s     = str.tostring(px, "0")
        int    n     = str.length(s)
        int    total = iPad ? MAX_DIGITS : n
        pushText(glyphs, iPrefix)
        for i = 0 to total - 1
            int di = i - (total - n)
            glyphs.push(di >= 0 ? str.substring(s, di, di + 1) : U_DIGIT)
            int rem = total - 1 - i
            if iCommas and rem > 0 and rem % 3 == 0
                glyphs.push(di >= 0 ? "," : U_COMMA)
        pushText(glyphs, iSuffix)
    else if iMode == "Time"
        string tz = iTz == "" ? syminfo.timezone : iTz
        pushText(glyphs, str.format_time(timenow, iSecs ? "HH:mm:ss" : "HH:mm", tz))
    else
        int secs = int(math.max(0, nz(time_close, timenow) - timenow) / 1000)
        int h    = int(math.floor(secs / 3600))
        int m    = int(math.floor((secs % 3600) / 60))
        int sec  = secs % 60
        string mmss = str.tostring(m, "00") + ":" + str.tostring(sec, "00")
        pushText(glyphs, h > 0 ? str.tostring(h) + ":" + mmss : mmss)

    // ── Size table exactly
    int last  = glyphs.size() - 1
    int nCols = 0
    for [gi, tok] in glyphs
        nCols += tokenWidth(tok) + (gi < last ? iGap : 0)

    if not na(tbl)
        tbl.delete()
    tbl := table.new(posFrom(iPos), math.max(nCols, 1), GH, bgcolor = f_dim(iBgCol), frame_color = f_dim(iFrameCol), frame_width = iFrameW,
         border_color = f_dim(iBgCol), border_width = iBorderW)

    // ── Draw dots (every non-lit dot is an unlit panel dot)
    int col = 0
    for [gi, tok] in glyphs
        int w = tokenWidth(tok)
        for c = 0 to w - 1
            for r = 0 to GH - 1
                color tc = lowPixel(tok, c, r) == 1 ? onCol : offCol
                drawCell(tbl, col + c, r, tc, sz, bgMode)
        col += w
        if gi < last and iGap > 0
            for g = 0 to iGap - 1
                for r = 0 to GH - 1
                    drawCell(tbl, col + g, r, offCol, sz, bgMode)
            col += iGap
//EOF
````
