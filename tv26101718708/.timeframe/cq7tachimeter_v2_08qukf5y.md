# CQ_(7)_[TACHIMETER] v2

- url: https://www.tradingview.com/script/08QUkF5y-CQ-7-TACHIMETER-v2/
- type: indicator
- pine_id: PUB;6043d22a344f4573a9d5da6a9b260023
- version: 3.0

## Description

================================================================================
         CQ_(7)_[TACHIMETER] v2  —  USER MANUAL
         © CQuevedo345
         Pine Script v6  |  TradingView Indicator
================================================================================


────────────────────────────────────────────────────────────────────────────────
WHAT IT DOES
────────────────────────────────────────────────────────────────────────────────

The Tachimeter is a real-time momentum speed gauge displayed as a table overlay
on your TradingView chart. It measures how fast price is moving by comparing the
current close to the close of the previous 20-minute bar (RPM = price delta).

The result is visualized as two emoji-based bar gauges — similar to a rev counter
on a car dashboard — that fill up as momentum increases. A label describes the
strength of the move in plain English, and the current price is shown with a
colored background that reflects the current trend direction.

The indicator is LIVE-ONLY: it only renders during real-time bars and hides on
historical bars to avoid repainting.


────────────────────────────────────────────────────────────────────────────────
KEY CONCEPTS
────────────────────────────────────────────────────────────────────────────────

RPM (Rate of Price Movement)
    RPM = Current Close  minus  Close of the previous 20-minute bar.
    Positive RPM = bullish momentum. Negative RPM = bearish momentum.
    The absolute value of RPM drives how many blocks fill up on the gauges.

Daily Tendency
    Compares current close to the daily open.
    Close >= Daily Open  →  Bullish  (teal header/footer)
    Close <  Daily Open  →  Bearish  (red header/footer)

Bull / Bear (RPM Tendency)
    Determined by whether RPM is positive or negative.
    Drives gauge square colors, overdrive colors, and price cell background.


────────────────────────────────────────────────────────────────────────────────
THE GAUGES
────────────────────────────────────────────────────────────────────────────────

Two 13-block bar gauges are shown stacked:

  X10 Bar (top gauge)
      One block lights up per 10 RPM, up to a maximum of 10 blocks (100 RPM).
      If |RPM| reaches 101 or above, all 13 blocks fill instantly — indicating
      the move has gone into overdrive range.

  X100 Bar (bottom gauge)
      Only activates when |RPM| >= 101.
      Each block represents 100 RPM of additional momentum beyond the first 100.
      Blocks 1–10 use the primary color. Blocks 11–13 use the overdrive color,
      signaling extreme momentum.

  X100 Block Mapping:
      101–199   →  1 block
      200–299   →  2 blocks
      300–399   →  3 blocks
      400–499   →  4 blocks
      500–599   →  5 blocks
      600–699   →  6 blocks
      700–799   →  7 blocks
      800–899   →  8 blocks
      900–999   →  9 blocks
      1000–1099 →  10 blocks
      1100–1199 →  11 blocks  (overdrive zone begins)
      1200–1299 →  12 blocks
      1300+     →  13 blocks


────────────────────────────────────────────────────────────────────────────────
ACCELERATION LABELS
────────────────────────────────────────────────────────────────────────────────

A text label below the title describes the strength of the current move.
The label applies to both bullish and bearish directions equally.

  |RPM|  0  –   9   →   S T O P P E D
  |RPM| 10  – 100   →   I D L I N G
  |RPM| 101 – 199   →   E X T R E M E L Y   W E A K
  |RPM| 200 – 299   →   V E R Y   W E A K
  |RPM| 300 – 399   →   W E A K
  |RPM| 400 – 499   →   M O S T L Y   W E A K
  |RPM| 500 – 599   →   S O M E W H A T   W E A K
  |RPM| 600 – 699   →   M O D E R A T E L Y   W E A K
  |RPM| 700 – 799   →   M O D E R A T E
  |RPM| 800 – 899   →   M O D E R A T E L Y   S T R O N G
  |RPM| 900 – 999   →   M O S T L Y   S T R O N G
  |RPM| 1000 – 1099 →     S T R O N G
  |RPM| 1100 – 1199 →   V E R Y   S T R O N G
  |RPM| 1200 – 1299 →   E X C E P T I O N A L L Y   S T R O N G
  |RPM| 1300+       →   U L T R A   S T R O N G


────────────────────────────────────────────────────────────────────────────────
TABLE LAYOUT
────────────────────────────────────────────────────────────────────────────────

The dashboard is a 5-column × 5-row table. Here is what each cell displays:

  Row 0, Cols 0–2 (merged)  →  Title: "T A C H I M E T E R" in Rounded font
                                Background: teal (bullish) or red (bearish)
                                based on daily open vs. close.

  Row 0, Col 3              →  Acceleration label (strength of move in text).
                                Same background color as the title.

  Row 1, Col 0              →  Scale labels: "X10" and "X100"

  Row 1, Col 1              →  The gauge display:
                                  Scale ruler (⏒ tick marks)
                                  X10 bar  (13 emoji blocks)
                                  Number scale (₂ ₄ ₆ ₈ ₁₀ ₁₁ ₁₂ ₁₃)
                                  X100 bar (13 emoji blocks)
                                  Scale ruler (⏒ tick marks)

  Row 1, Col 2              →  Raw RPM value (formatted as a 2-digit number).

  Row 1, Col 3              →  Current price + tendency dot (🟢 or 🔴).
                                Background: teal (bull) or red (bear) at 50%
                                transparency, based on RPM tendency.


────────────────────────────────────────────────────────────────────────────────
COLOR GUIDE
────────────────────────────────────────────────────────────────────────────────

  Gauge squares — Trend Color mode (default):
      🟩  Bullish fill (X10 and X100 bars, blocks 1–10)
      🟦  Bullish overdrive (X100 bar, blocks 11–13)
      🟥  Bearish fill (X10 and X100 bars, blocks 1–10)
      🟨  Bearish overdrive (X100 bar, blocks 11–13)
      ⬛  Empty block

  Gauge squares — White mode:
      ⬜  All active blocks (both bars, all slots)
      ⬛  Empty block

  Tendency dot (price cell):
      🟢  RPM is positive (bullish)
      🔴  RPM is negative (bearish)

  Header / Acceleration cell background:
      Teal  →  Close >= Daily Open
      Red   →  Close <  Daily Open

  Price cell background:
      Teal at 50% transparency  →  RPM bullish
      Red  at 50% transparency  →  RPM bearish


────────────────────────────────────────────────────────────────────────────────
SETTINGS & INPUTS
────────────────────────────────────────────────────────────────────────────────

Group: PRICE LABELS
  Show Current Price and Tachimeter  (toggle, default: ON)
      Master on/off switch. When disabled, the entire table is hidden.

Group: EMA Dashboard
  Dashboard Position  (dropdown, default: Top Center)
      Controls where the table is anchored on the chart.
      Options: Bottom Left, Top Center, Middle Left, Middle Right,
               Bottom Right, Top Right.

  Dashboard Size  (dropdown, default: Tiny)
      Controls the text size of the gauge content.
      Options: Auto, Tiny, Small, Normal, Large, Huge.
      Recommendation: Tiny for mobile, Small for desktop browser.

Group: GAUGE STYLE
  Gauge Square Color Mode  (dropdown, default: Trend Color)
      Trend Color (Green/Red): squares reflect bull/bear direction.
      White: all active squares display as white (⬜) regardless of direction.
             Useful for minimalist or light-theme charts.


────────────────────────────────────────────────────────────────────────────────
IMPORTANT NOTES
────────────────────────────────────────────────────────────────────────────────

  - The indicator renders ONLY on real-time, unconfirmed bars. It will not
    display on historical bars. This is by design to prevent repainting.

  - RPM is measured against the 20-minute timeframe close[1], making it most
    meaningful on intraday charts (1m, 3m, 5m, 15m, etc.).

  - On slower timeframes (Daily, Weekly) the RPM values will be very large
    and the X100 bar will almost always be fully lit. The indicator is
    optimized for intraday use.

  - The weekly_open and monthly_open security calls are fetched but currently
    reserved for future use. They do not affect the current display.


────────────────────────────────────────────────────────────────────────────────
CREDITS
────────────────────────────────────────────────────────────────────────────────

  Author   : © CQuevedo345
  Library  : fikira/Text/1  (used for Rounded font rendering in title)
  License  : Mozilla Public License 2.0
             https://mozilla.org/MPL/2.0/

================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345
//@version=6
indicator('CQ_(7)_[TACHIMETER] v3.0', overlay = true)

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
     tooltip = 'If the price has not changed for this many seconds, the price-change reading (RPM) is reset to 0 in every gauge mode: the Classic bars empty, both dial needles drop to rest (X10 → 0, X100 → its 100 start), the RPM tag shows +0 and the gauge reads S T O P P E D. The peak trail then decays normally.\nThe current price also becomes the new reference: when price moves again, the change is measured from where it was resting (not from the old Reaction Window), until one full Reaction Window has passed since the reset.\n0 = never reset.\nRealtime only. Pine only runs on incoming ticks, so the reset happens on the first tick after the time is up — on a market with no trades at all the reading stays where it is until the next tick.')

i_stoppedColor = input.color(
     title   = 'Stopped Value Cell Background',
     defval  = color.rgb(64, 64, 64),
     group   = 'GENERAL (ALL MODES)',
     tooltip = 'Background color used for the RPM and Price value cells whenever the gauge reads "S T O P P E D" (no meaningful price change over the Reaction Window Length). Overrides the usual bullish/bearish teal-or-red value cell background for as long as the gauge stays stopped.')


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
     defval  = 3.0,
     minval  = 0.5,
     maxval  = 60.0,
     step    = 0.5,
     group   = '2 · PIXEL DIAL — NEEDLE & ARC',
     tooltip = 'How fast the peak marker falls back toward the live reading. Every this-many seconds, the gap between the held peak and zero is cut in half (a new higher reading resets it instantly).\nUsed by the Pixel Dial peak trail. Updates tick-by-tick in realtime.')

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
     tooltip = "Static: uses the Lit color.\nDirection: Bull when close ≥ previous close, Bear otherwise.")
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

if barstate.islast
    absRPM        = math.abs(RPM)
    atrNormalized = i_useAdaptiveSensitivity and atrValue > 0 ? (absRPM / atrValue) * 100 : absRPM
    sRPM          = atrNormalized * i_sensitivity
    bull          := RPM >= 0
    isStopped     := sRPM < 10
    whiteMode     = i_gaugeColorMode == 'White'
    sRPMv         := sRPM

    // Peak hold: jump up instantly, decay toward zero by the half-life.
    float elapsed = peakMs == 0 ? 0.0 : (timenow - peakMs) / 1000.0
    peakV  := math.max(sRPMv, peakV * math.pow(0.5, elapsed / i_peakHalfLife))
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
         bgcolor = BGcolor, frame_color = color.rgb(0, 0, 0),
         frame_width = 1, border_width = 1)

    gaugeText = Scale2 + '\n' + Tachimeter + '\n' + Scale + '\n' + Tachimeter2 + '\n' + Scale2

    // RPM and Price value cells share this background: the usual
    // bullish/bearish teal-or-red while the gauge is actively reading a
    // move, swapped to the user-selectable Stopped Value Cell Background
    // whenever the gauge is STOPPED (see isStopped above).
    valueCellBg = isStopped ? color.new(i_stoppedColor, 50) : color.new(bull ? color.teal : color.red, 50)

    // ── Gap row ───────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 0, '',
          bgcolor = BGcolor)
    table.merge_cells(TACHIMETER, 0, 0, 3, 0)

    // ── Title row ─────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 1,
         t.toFont(fromText = 'P  R  I  C  E  -  T  A  C  H', font = "Rounded"),
         bgcolor = color.new(daily_color, 65),
         text_color = text_color2,
         text_size = tableTextSize)
    table.merge_cells(TACHIMETER, 0, 1, 2, 1)

    table.cell(TACHIMETER, 3, 1, Acceleration,
         bgcolor = color.new(daily_color, 65),
         text_color = text_color2,
         text_size = size.tiny,
         width = 9)

    // ── Gauge row ─────────────────────────────────────────────────────────────
    table.cell(TACHIMETER, 0, 2, 'X10\n\nX100',
         bgcolor = color.new(bull ? color.teal : color.red, 50),
         text_color = TachColor,
         text_size = tableTextSize,
         text_halign = text.align_right)

    table.cell(TACHIMETER, 1, 2, gaugeText,
         bgcolor = color.new(bull ? color.rgb(0, 85, 76) : color.rgb(146, 1, 1), 50),
         text_color = TachColor,
         text_size = tableTextSize,
         text_halign = text.align_left)

    table.cell(TACHIMETER, 2, 2,
         t.toFont(fromText = (RPM >= 0 ? '+' : '') + str.tostring(RPM, '00'), font = 'Monospace'),
         bgcolor = valueCellBg,
         text_color = TachColor,
         text_size = size.normal)

    table.cell(TACHIMETER, 3, 2,
         t.toFont(fromText = str.tostring(close, '$' + '00,000 ') + Tendency, font = str.tostring(i_priceFont)),
         bgcolor = valueCellBg,
         text_color = TachColor,
         text_size = i_priceSize)

    // ── Bottom bar row ────────────────────────────────────────────────────────
    if i_showBottomBar
        table.cell(TACHIMETER, 0, 3, ' ',
             bgcolor = color.new(daily_color, 65),
             text_color = text_color2,
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
    float tRad  = math.toradians(math.min(f_angDeg(sRPMv, lo, hi), 120.0))
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
            // Arc ring: lit up to the live reading, faded trail up to the peak.
            if math.abs(d - PX_R) < 1.2 and math.abs(a) <= sweep
                float cv = f_valFromDeg(math.todegrees(a), lo, hi)
                color zc = f_zoneColor(cv, f_gradColor(cv, bull, wm, lo, cau), cau, red)
                col := cv <= sRPMv ? zc : cv <= peakV ? color.new(zc, 60) : thTrack
            // Needle and hub.
            if f_pxNeedle(dx, dy, tRad, nPerp, nLen) or d < hubR
                col := thNeedle
            table.cell(tb, ox + i, j + 1, '', width = pw, height = ph, bgcolor = col)

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
                 text_color = thScale, text_size = i_pxScaleNumSize, bgcolor = f_faceAt(j0))
            table.merge_cells(tb, ox + i0, j0 + 1, ox + i0 + 3, j0 + 2)

    // Scale caption (X10 / X100) in the open bottom, clear of the needle at
    // any thickness.
    table.cell(tb, ox + 17, 24, cap, width = pw, height = ph,
         text_color = thScale, text_size = i_pxScaleNumSize, bgcolor = f_faceAt(23))
    table.merge_cells(tb, ox + 17, 24, ox + 23, 27)

if barstate.islast and i_gaugeMode == 'Pixel Dial'
    float pw    = i_pxW * i_pxScale
    float ph    = i_pxH * i_pxScale
    int   nCols = 2 * PX_COLS + PX_GAP
    DIAL = table.new(position = i_pxPos, columns = nCols, rows = PX_ROWS + 4,
         bgcolor = BGcolor, border_width = 1, border_color = BGcolor)
    f_pxDial(DIAL, 0, X10_LO, X10_HI, X10_CAU, X10_RED, x10V, x10T, 'X10', pw, ph)
    f_pxDial(DIAL, PX_COLS + PX_GAP, X100_LO, X100_HI, X100_CAU, X100_RED, x100V, x100T, 'X100', pw, ph)
    // Blank gap columns between the dials.
    for g = 0 to PX_GAP - 1
        for j = 1 to PX_ROWS
            table.cell(DIAL, PX_COLS + g, j, '', width = pw, height = ph, bgcolor = BGcolor)

    // ── Dashboard info on the dials ───────────────────────────────────────────
    // Same color logic as the dashboard: header items use the daily-open
    // color, value items use teal/red (or the Stopped background). Text uses
    // the Dial Color Theme's tag text color.
    color pxValBg = isStopped ? color.new(i_stoppedColor, 50) : color.new(bull ? color.teal : color.red, 50)
    color pxHdrBg = color.new(daily_color, 65)

    // Title above the dials.
    table.cell(DIAL, 0, 0, t.toFont(fromText = 'P  R  I  C  E  -  T  A  C  H', font = 'Rounded'),
         width = pw, text_color = thText, text_size = i_pxTitleSize, bgcolor = pxHdrBg)
    table.merge_cells(DIAL, 0, 0, nCols - 1, 0)

    // Signed RPM (raw price move) + normalized reading + the reference price
    // the move is measured from (lookback close, or the resting price after
    // an idle reset).
    table.cell(DIAL, 0, PX_ROWS + 1,
         t.toFont(fromText = (RPM >= 0 ? '+' : '') + str.tostring(RPM, '00'), font = 'Monospace') +
         '   ' + str.tostring(sRPMv, '#') + (i_useAdaptiveSensitivity ? ' % ATR' : ' sRPM') +
         '   REF ' + str.tostring(refPrice, '$' + '00,000'),
         width = pw, text_color = thText, text_size = i_pxRpmSize, bgcolor = pxValBg)
    table.merge_cells(DIAL, 0, PX_ROWS + 1, nCols - 1, PX_ROWS + 1)

    // Current price + direction marker.
    table.cell(DIAL, 0, PX_ROWS + 2,
         t.toFont(fromText = str.tostring(close, '$' + '00,000 ') + Tendency, font = str.tostring(i_priceFont)),
         width = pw, text_color = thText, text_size = i_pxPriceSize, bgcolor = pxValBg)
    table.merge_cells(DIAL, 0, PX_ROWS + 2, nCols - 1, PX_ROWS + 2)

    // Acceleration label.
    table.cell(DIAL, 0, PX_ROWS + 3, Acceleration,
         width = pw, text_color = thText, text_size = i_pxAccelSize, bgcolor = pxHdrBg)
    table.merge_cells(DIAL, 0, PX_ROWS + 3, nCols - 1, PX_ROWS + 3)

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
    color  onCol  = iColMode == "Static" ? iOnCol : isUp ? iBullCol : iBearCol
    color  offCol = iGhost ? iGhostCol : CLEAR

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
    tbl := table.new(posFrom(iPos), math.max(nCols, 1), GH, bgcolor = iBgCol, frame_color = iFrameCol, frame_width = iFrameW,
         border_color = iBgCol, border_width = iBorderW)

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
