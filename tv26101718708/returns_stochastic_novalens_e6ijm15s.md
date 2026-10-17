# Returns Stochastic [NovaLens]

- url: https://www.tradingview.com/script/e6iJM15s-Returns-Stochastic-NovaLens/
- type: indicator
- pine_id: PUB;5998e037830b41eab25a88c0517eb52c
- version: 1.0

## Description

Returns Stochastic is a bounded 0-100 momentum oscillator that ranks each bar's return, not price, and dims its extremes in low-efficiency tape. The line burns vivid at overbought/oversold extremes on a directional tape; the same extreme reads dim when the tape is chop.

Many oscillators show overbought and oversold extremes the same way on clean directional moves, noisy ranges, and dead chop. Returns Stochastic separates the return extreme from the tape quality behind it: a bounded 0-100 read built on percent-change (unitless and normalized within each asset's own recent return range), plus a second, independent measurement of how directional versus choppy the recent tape is, using the Kaufman Efficiency Ratio (KER). The working hypothesis behind the lens: an extreme on a directional tape and the same extreme in chop may carry different information, so the two are shown as separate channels rather than folded into one number. A vivid extreme is not a buy or sell signal.

════════════════════════════════════════════

◉ [b]HOW IT WORKS[/b]

[b]1. Percent change per bar.[/b] pct = (Close - Close(1)) / Close(1).

[b]2. Rank that return in its recent range.[/b] Rescale each return in its last 10 bars to 0-100; average 4 readings by default. When returns differ within the window, the highest scores 100 before smoothing; the lowest scores 0. The plotted average need not be near either end.

[pine]
hh     = ta.highest(pct, rankLen)
ll     = ta.lowest(pct, rankLen)
raw    = (hh - ll) != 0 ? (pct - ll) / (hh - ll) * 100 : 0.0
rstoch = ta.sma(raw, smoothLen)
[/pine]
Simplified; the shipped code adds na-guards. Result: rstoch is the smoothed 0-100 position of recent returns in their rolling ranges.

[b]3. Measure tape efficiency separately.[/b] The tool ranks smoothed KER against its recent history (30-100 bars in the preset profiles). Preset colour emphasis turns on at a higher rank and off at a lower one, reducing rapid switches near the middle. Efficiency never alters the value.

[b]Kaufman Efficiency Ratio[/b] - net directional travel over a window divided by the total path length; near 1 means a clean directional move, near 0 means the tape covered ground going nowhere.

[b]Why it is original.[/b] Feeding [b]returns[/b] through a stochastic rank is uncommon in published work, but the contribution is the composition: the returns-based value remains visible while an independent Kaufman-efficiency lens controls its visual emphasis, zone fills, event markers, and alerts.

════════════════════════════════════════════

◈ [b]HOW TO READ IT[/b]

Efficiency gates the [b]rendering[/b], not the value. The level shows where the return sits; the efficiency lens shows whether that extreme occurred in a directional or choppy tape. Check the [b]color[/b] at an extreme before the level:

[list]
[*][b]Vivid green at or below the Oversold level[/b]: an oversold return extreme while the recent price path is relatively directional rather than choppy.
[*][b]Vivid amber at or above the Overbought level[/b]: an overbought return extreme while the recent price path is relatively directional rather than choppy.
[*][b]Dim green or amber at either extreme[/b]: the same overbought or oversold zone, but on a choppy tape, so it is dimmed, not hidden.
[/list]

[b]Supporting layers:[/b]

[list]
[*][b]Glow and fill[/b]: past a level on a directional tape the line glows and fills back to the level; in chop neither shows. Inside the levels the line is slate.
[*][b]Event marks[/b]: a pane dot plus green OS below price or amber OB above it. Both require a confirmed cross with Trust Efficient and a down-close (OS) or up-close (OB). No event prints in Chop; the line stays visible.
[*][b]Level bands[/b]: a faint channel between the levels and, in the default Bold look, soft strips beyond them.
[/list]

The panel names the zone in plain English even when the line is dim (zone, Trust as Efficient or Chop, bars since the last signal, all with hover), so a dimmed extreme is never mistaken for "no signal".

════════════════════════════════════════════

✦ [b]HOW WE USE IT: BTCUSDT DAILY, SUMMER 2026[/b]

Default settings on BINANCE:BTCUSDT 1D (Balanced, Auto resolves to Daily), read on closed bars from May to October 2026. Three oversold readings at similar levels, read three ways:

[list]
[*][b]3 June[/b]: during the early-June selloff the line drops to about 23. The panel reads Oversold with Trust Efficient (trust rank 100 in the hover), and a green OS tag prints under the confirmed bar.
[*][b]25 July[/b]: inside the July range the line reaches about 20, deeper than the 3 June reading. The panel reads Oversold with Trust Chop (trust rank 8); the line is a dim green and no mark or alert fires.
[*][b]25 August[/b]: after the August run-up even a small down-day sits low in the recent return range, pulling the line to about 19 while efficiency ranks 96th; the line turns vivid green and a new OS tag prints.
[/list]

The level alone would treat the three alike. The lens separates the two that formed on directional tape from the one that formed in chop, and the July reading stays visible as a dim line rather than disappearing.

What it does not do: it does not say where a move ends. After the 3 June mark price kept falling, closing below 60,000 in late June, and the line printed further oversold readings on the way. The lens describes the tape an extreme formed in; it does not forecast the next bar.

════════════════════════════════════════════

❖ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Second opinion on a classic oscillator[/b]: swing traders who watch a 70/30 stochastic or RSI can see which of its extremes formed on directional tape and which in chop.
[*][b]Chop mapping for range traders[/b]: long stretches where the panel reads Chop and no tag prints, like July 2026 on BTC daily, mark tape the lens reads as inefficient.
[*][b]Timeframe comparison[/b]: Auto resolves a profile per chart, so the same symbol can read efficient on 4H and choppy on 1D.
[*][b]Alert-driven workflow[/b]: subscribe to Efficient Oversold Cross Down and Efficient Overbought Cross Up; check the chart only when an efficient extreme forms.
[/list]

════════════════════════════════════════════

❂ [b]GETTING STARTED[/b]

Add to chart. Default Balanced responsiveness plus the Auto trust profile need no changes; Auto picks a bar-count profile from your chart timeframe and applies it to the current bars (it only looks at the chart you're already on). The panel shows the last closed bar, not the bar under the cursor. It starts top right in the pane and can cover the line on small charts. Panel and Panel on move or hide it.

[b]Settings that matter:[/b]

[list]
[*][b]Responsiveness[/b]: Balanced (default, Rank length 10 / Smoothing 4). Start here. Longer smooths but delays: Reactive (6 / 3) fires more often with more noise, Smooth (16 / 6) gives fewer, cleaner extremes.
[*][b]Trust profile[/b]: Auto (default), or lock Weekly, Daily, 8H, 4H or 30m. Auto matches the chart to the nearest anchor by bar-count boundaries: below 90 minutes (plus tick and range) uses 30m; 90 min through about 5h 40m uses 4H.
[*][b]Overbought / Oversold level[/b] (70 / 30): the level bar itself counts as in-zone.
[/list]

[b]Groups, as in the script:[/b]

[list]
[*][b]Profile[/b]: Responsiveness, Trust profile.
[*][b]Core[/b]: Rank length and Smoothing under Custom; Overbought (70) / Oversold (30) level.
[*][b]Advanced[/b]: Trust length, smoothing, window and stability under Custom (stability = total hysteresis band width around 50).
[*][b]Marks[/b]: price tags, pane dots. [b]Display[/b]: Look (Clean / Glow / Bold), Theme, glow, Panel, Panel on.
[*][b]Colours[/b]: Line (slate), Overbought (amber), Oversold (green).
[/list]

════════════════════════════════════════════

△ [b]LIMITATIONS[/b]

This is a state read, not a prediction, and not a buy/sell system.

[list]
[*][b]A single large return compresses the scale.[/b] One outlier can pin later bars toward the opposite end of the 0-100 range until it ages out of the window.
[*][b]Choppy tapes are dimmed on purpose.[/b] Dim is a relative state, not a quality score.
[*][b]Efficiency is relative.[/b] Ranked against its own recent window: efficient for this symbol and timeframe lately, not a universal threshold.
[*][b]Thin symbols can sit in Flat or Settling.[/b] On illiquid or halted tapes the guard holds the read closed after each flat stretch and the panel names it, so a long flat line at the middle is the guard working, not a fault.
[*][b]Auto reads only this chart.[/b] It requests no other timeframe's data.
[*][b]Warm-up.[/b] No line until the longer of Rank length + Smoothing or Trust window + Trust length passes (Daily defaults: 60 bars).
[*][b]Hover detail is desktop.[/b] On mobile, read the info panel.
[/list]

[b]Repaint:[/b] Confirmed-bar. The line updates live on the forming bar and finalizes on close; the panel latches to the last closed bar; markers and alerts fire only on confirmed bar close.

════════════════════════════════════════════

◭ [b]ALERTS[/b]

[list]
[*][b]Efficient Oversold Cross Down[/b] - fires when Returns Stochastic crosses below the Oversold level while the efficiency state is open and the crossing bar's own return is negative. Confirmed bar close (set to Once Per Bar Close).
[*][b]Efficient Overbought Cross Up[/b] - fires when Returns Stochastic crosses above the Overbought level while the efficiency state is open and the crossing bar's own return is positive. Confirmed bar close (set to Once Per Bar Close).
[/list]

Both messages are observational plain text naming the event, symbol, timeframe, close and bar time (the bar's open time), confirmed on bar close. No events fire during Flat or Settling windows.

════════════════════════════════════════════

⌁ [b]NOTES[/b]

[list]
[*]The C% returns-stochastic concept is credited to Ali Casey / StatOasis. NovaLens adds the percentile-ranked, hysteresis-gated Kaufman lens, the glow, confirmed-bar markers and the flat-tape safeguards.
[*]Efficiency Ratio: Perry J. Kaufman, Smarter Trading (1995).
[*]Repaint: Confirmed-bar.
[*]Open-source under the Mozilla Public License 2.0 - read the code and verify the math.
[/list]

## Source Code

````pine
// This Pine Script source code is subject to the Mozilla Public License 2.0.
// Copyright NovaLens
//@version=6
// Returns Stochastic [NovaLens] (CC-01) v11, TV-38 redesign: the approved cc_v21 maths on the K-B oscillator kit, look Option A (owner pick).
// The returns-stochastic idea is credited to Ali Casey / StatOasis. NovaLens adds the efficiency lens (how one-way the recent path is),
// honest warm-up, the flat-tape and post-halt guards, the marks, the reading panel and the alerts.
// Picture: a slate line between the two level bands; past a band it takes the zone colour, full with glow and fill on an efficient (one-way) path, dim in chop; a dot on the line and a small OS or OB word tag beside the candle at each efficient event.
// Repaint: the line updates on the live candle; marks, the panel and alerts use closed candles only.
// An observational reading, not a trading system.
indicator("Returns Stochastic [NovaLens]", shorttitle="Returns Stochastic [NovaLens]", overlay=false, precision=0, max_bars_back=1000, max_labels_count=500)
const string BUILD_TOKEN = "cb2dcb1f00ed"

// ==== KIT T6 START ====
// T6 theme presets. Every colour the kit draws is defined here, once per theme; no hex appears outside this block.
// Roles: bull, bear, neutral (direction), extreme high and extreme low (rare levels), the reading panel's base, inks, frame and inner border.
// The panel values are the TV-35 v12 panel's (LESSON 13.11): base, title, label and value inks, frame and inner border, dark and light.
// Light values are darkened so lines reach 3:1 and text 4.5:1 on white; the design-kit tests recompute every ratio from these hex values.
// The light bull and bear text grades are the first darker step on the same hue and saturation (HSL lightness only) that reads 4.5:1 on the v12 light panel base.
const color KIT_BULL_DARK = #33BD68
const color KIT_BULL_LIGHT = #2DA85D
const color KIT_BULL_DARK_TEXT = #33BD68
const color KIT_BULL_LIGHT_TEXT = #248449
const color KIT_BEAR_DARK = #EF5350
const color KIT_BEAR_LIGHT = #EF5350
const color KIT_BEAR_DARK_TEXT = #EF5350
const color KIT_BEAR_LIGHT_TEXT = #CD4341
const color KIT_NEUTRAL_DARK = #787B86
const color KIT_NEUTRAL_LIGHT = #787B86
const color KIT_NEUTRAL_DARK_TEXT = #787B86
const color KIT_NEUTRAL_LIGHT_TEXT = #737681
const color KIT_EXT_HIGH_DARK = #FF9800
const color KIT_EXT_HIGH_LIGHT = #D68000
const color KIT_EXT_LOW_DARK = #42A5F5
const color KIT_EXT_LOW_LIGHT = #3D99E4
const color KIT_TABLE_BASE_DARK = #363A45
const color KIT_TABLE_BASE_LIGHT = #FAFAFC
const color KIT_TITLE_INK_DARK = #FFFFFF
const color KIT_TITLE_INK_LIGHT = #0F1423
const color KIT_LABEL_INK_DARK = #787B86
const color KIT_LABEL_INK_LIGHT = #5A5F73
const color KIT_VALUE_INK_DARK = #FFFFFF
const color KIT_VALUE_INK_LIGHT = #191E2D
const color KIT_TABLE_FRAME_DARK = #787B86
const color KIT_TABLE_FRAME_LIGHT = #AAAFBE
const color KIT_TABLE_BORDER_DARK = #787B86
const color KIT_TABLE_BORDER_LIGHT = #C8CDD7
const color KIT_INK_BLACK = #000000
const color KIT_INK_WHITE = #FFFFFF
// Transparency (0 opaque, 100 invisible) of the theme-level fills that carry text or a weak line, and of the panel chrome.
const int KIT_TABLE_BASE_FADE_DARK = 15
const int KIT_TABLE_BASE_FADE_LIGHT = 10
const int KIT_TABLE_FRAME_FADE_DARK = 30
const int KIT_TABLE_FRAME_FADE_LIGHT = 30
const int KIT_TABLE_BORDER_FADE_DARK = 50
const int KIT_TABLE_BORDER_FADE_LIGHT = 40
const int KIT_WEAK_FADE_DARK = 25
const int KIT_WEAK_FADE_LIGHT = 15
// Structure ink (zero line, levels) is the chart's own text colour at a fixed fade, so it follows any theme.
const int KIT_ZERO_FADE = 80
const int KIT_LEVEL_FADE = 60

type KitPalette
    bool light
    color up
    color down
    color flat
    color high
    color low
    color upText
    color downText
    color flatText
    color upWeak
    color downWeak
    color base
    color labelInk
    color valueInk
    color titleInk
    color frame
    color border

// Auto reads the chart background: an average channel above 128 is a light chart.
kitIsLight(string theme) =>
    float bgAverage = (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3.0
    theme == "Light" or (theme == "Auto" and bgAverage > 128.0)

// A colour the user left at its dark default switches to the light value on a light chart; a colour the user changed is kept.
kitPick(color userColor, color darkDefault, color lightValue, bool light) =>
    light and userColor == darkDefault ? lightValue : userColor

kitPalette(string theme, color upIn, color downIn, color flatIn, color highIn, color lowIn) =>
    bool light = kitIsLight(theme)
    color upText = kitPick(upIn, KIT_BULL_DARK, KIT_BULL_LIGHT_TEXT, light)
    color downText = kitPick(downIn, KIT_BEAR_DARK, KIT_BEAR_LIGHT_TEXT, light)
    color flatText = kitPick(flatIn, KIT_NEUTRAL_DARK, KIT_NEUTRAL_LIGHT_TEXT, light)
    int weakFade = light ? KIT_WEAK_FADE_LIGHT : KIT_WEAK_FADE_DARK
    color upWeakBase = light and upIn == KIT_BULL_DARK ? KIT_BULL_LIGHT_TEXT : upIn
    color downWeakBase = light and downIn == KIT_BEAR_DARK ? KIT_BEAR_LIGHT_TEXT : downIn
    KitPalette.new(light, kitPick(upIn, KIT_BULL_DARK, KIT_BULL_LIGHT, light), kitPick(downIn, KIT_BEAR_DARK, KIT_BEAR_LIGHT, light), kitPick(flatIn, KIT_NEUTRAL_DARK, KIT_NEUTRAL_LIGHT, light), kitPick(highIn, KIT_EXT_HIGH_DARK, KIT_EXT_HIGH_LIGHT, light), kitPick(lowIn, KIT_EXT_LOW_DARK, KIT_EXT_LOW_LIGHT, light), upText, downText, flatText, color.new(upWeakBase, weakFade), color.new(downWeakBase, weakFade), light ? color.new(KIT_TABLE_BASE_LIGHT, KIT_TABLE_BASE_FADE_LIGHT) : color.new(KIT_TABLE_BASE_DARK, KIT_TABLE_BASE_FADE_DARK), light ? KIT_LABEL_INK_LIGHT : KIT_LABEL_INK_DARK, light ? KIT_VALUE_INK_LIGHT : KIT_VALUE_INK_DARK, light ? KIT_TITLE_INK_LIGHT : KIT_TITLE_INK_DARK, light ? color.new(KIT_TABLE_FRAME_LIGHT, KIT_TABLE_FRAME_FADE_LIGHT) : color.new(KIT_TABLE_FRAME_DARK, KIT_TABLE_FRAME_FADE_DARK), light ? color.new(KIT_TABLE_BORDER_LIGHT, KIT_TABLE_BORDER_FADE_LIGHT) : color.new(KIT_TABLE_BORDER_DARK, KIT_TABLE_BORDER_FADE_DARK))

// Line and mark colour for a direction (+1, -1, 0) and a strength step (1 weak, 2 normal, 3 strong).
kitDirColor(KitPalette p, int dir, int step) =>
    dir > 0 ? (step <= 1 ? p.upWeak : p.up) : dir < 0 ? (step <= 1 ? p.downWeak : p.down) : p.flat

// Text colour for a direction word on the table or a pill.
kitDirText(KitPalette p, int dir) =>
    dir > 0 ? p.upText : dir < 0 ? p.downText : p.valueInk

// Black or white, whichever reads better on a filled cell or pill (WCAG relative luminance).
kitChannel(float channel) =>
    float v = channel / 255.0
    v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4)
kitInkOn(color fillColor) =>
    float lum = 0.2126 * kitChannel(color.r(fillColor)) + 0.7152 * kitChannel(color.g(fillColor)) + 0.0722 * kitChannel(color.b(fillColor))
    (lum + 0.05) / 0.05 >= 1.05 / (lum + 0.05) ? KIT_INK_BLACK : KIT_INK_WHITE

kitStructure(int fade) =>
    color.new(chart.fg_color, fade)
// ==== KIT T6 END ====

// ==== ENGINE INPUTS: the cc_v21 inputs (names, options, min, max and step unchanged; defaults unchanged except Trust length 8 -> 10, so Custom starts at the Daily profile, TV-38 L7), in the kit groups ====
const string CC_TIP_RESP = "Sets how quickly the reading reacts to new candles.\n\n• Reactive (Rank length 6, Smoothing 3): more readings at the extremes, more noise.\n• Balanced (10, 4): the default.\n• Smooth (16, 6): fewer, cleaner extremes.\n• Custom: uses Rank length and Smoothing below."
const string CC_TIP_LENS = "Trust is how clean the recent move was: how far price got, against all the up and down on the way. A straight run is high trust; back-and-forth chop is low trust.\n\nThis picks its candle counts.\n• Auto: 30m under 90 minutes, 4H under 5h 40m, 8H under 14h, Daily under 3 days, else Weekly.\n• Custom: the Advanced Trust inputs, which start at Daily."
const string CC_TIP_RANK = "Sets how many recent candles this candle's move is ranked against.\n\nLower = more frequent extremes. Counted in candles. Used when Responsiveness = Custom."
const string CC_TIP_SMOOTH = "Sets how smooth the reading line is.\n\nHigher = smoother and later. Counted in candles. Used when Responsiveness = Custom."
const string CC_TIP_UPPER = "Sets the overbought level.\n\nA reading at or above it is overbought. It must sit above the oversold level.\n\nIf it does not, zones, tags and alerts switch off and the panel shows Bad levels."
const string CC_TIP_LOWER = "Sets the oversold level.\n\nA reading at or below it is oversold. It must sit below the overbought level.\n\nIf it does not, zones, tags and alerts switch off and the panel shows Bad levels."
const string CC_TIP_ERLEN = "Sets how many candles the trust read looks back.\n\nTrust compares how far price got over these candles with all the up and down along the way. Used when Trust profile = Custom."
const string CC_TIP_KERS = "Sets how much the trust read is smoothed.\n\nOne means no smoothing. Used when Trust profile = Custom."
const string CC_TIP_RANKW = "Sets how many past candles the trust read is compared with.\n\nTrust counts as high when the recent move is cleaner than usual for that history. It needs this many candles plus Trust length to start. Used when Trust profile = Custom."
const string CC_TIP_STAB = "Sets how clear the change must be before trust switches on or off.\n\nHigher = fewer switches; zero = it switches at the middle of its history. It moves in steps, so on a short Trust window a small change can do nothing. Used when Trust profile = Custom."
corePreset = input.string("Balanced", "Responsiveness", options=["Reactive", "Balanced", "Smooth", "Custom"], group="1. Profile", display=display.none, tooltip=CC_TIP_RESP)
lensPreset = input.string("Auto", "Trust profile", options=["Auto", "Weekly", "Daily", "8H", "4H", "30m", "Custom"], group="1. Profile", display=display.none, tooltip=CC_TIP_LENS)
rankLenInput   = input.int(10, "Rank length", minval=2, maxval=200, group="2. Core", active=corePreset == "Custom", display=display.none, tooltip=CC_TIP_RANK)
smoothLenInput = input.int(4,  "Smoothing",   minval=1, maxval=100, group="2. Core", active=corePreset == "Custom", display=display.none, tooltip=CC_TIP_SMOOTH)
upperLevel = input.int(70, "Overbought level", minval=0, maxval=100, group="2. Core", display=display.none, tooltip=CC_TIP_UPPER)
lowerLevel = input.int(30, "Oversold level", minval=0, maxval=100, group="2. Core", display=display.none, tooltip=CC_TIP_LOWER)
erLen        = input.int(10, "Trust length",    minval=2,  maxval=100, group="3. Advanced", active=lensPreset == "Custom", display=display.none, tooltip=CC_TIP_ERLEN)
kerSmoothLen = input.int(2,  "Trust smoothing", minval=1,  maxval=50,  group="3. Advanced", active=lensPreset == "Custom", display=display.none, tooltip=CC_TIP_KERS)
rankWin      = input.int(50, "Trust window",    minval=20, maxval=300, group="3. Advanced", active=lensPreset == "Custom", display=display.none, tooltip=CC_TIP_RANKW)
stability    = input.int(10, "Trust stability", minval=0, maxval=50, step=2, group="3. Advanced", active=lensPreset == "Custom", display=display.none, tooltip=CC_TIP_STAB)

// ---- CC_V21 ENGINE START (approved file lines 101-237, byte for byte except the 4H Trust length 7 -> 14 and its comment line, TV-38 L7; __tests__/tv-38-redesign/engine-identity.sh) ----
// ─── Core preset resolution (single-line const-int ternaries - v6 continuation-safe) ─
int rankLenEff   = corePreset == "Reactive" ? 6 : corePreset == "Balanced" ? 10 : corePreset == "Smooth" ? 16 : rankLenInput
int smoothLenEff = corePreset == "Reactive" ? 3 : corePreset == "Balanced" ? 4  : corePreset == "Smooth" ? 6  : smoothLenInput

// ─── Confidence Lens: AUTO resolution ──────────────────────────────────────────
// AUTO reads the chart timeframe and picks the nearest bar-count profile. Thresholds
// are rounded near-geometric anchors between adjacent profile anchors (Weekly 7d, Daily 1d,
// 8H, 4H, 30m), so each real chart resolution lands on its closest profile. These are
// bar-count tuning profiles, NOT higher-timeframe data - picking one only applies its
// lookback counts to the CURRENT chart's bars (no request.security). Manual and Custom
// overrides stay available so a chart can borrow another profile's bar-count rhythm.
int tfSec = timeframe.in_seconds()
string autoLens = tfSec >= 259200 ? "Weekly" : tfSec >= 50400 ? "Daily" : tfSec >= 20400 ? "8H" : tfSec >= 5400 ? "4H" : "30m"
string lensEff  = lensPreset == "Auto" ? autoLens : lensPreset

// ─── Lens preset resolution (drives off the resolved lens) ─────────────────────
// These are input-resolution ternaries, not the frozen formula. The hysteresis band is
// at least 6 (Daily uses 10): stability 2 would give enter 51 / exit 49, a near-zero
// deadband where the gate strobes; 6 gives enter 53 / exit 47, a real deadband. erLen
// is Weekly 10 / Daily 10 / 8H 8 / 4H 14 / 30m 5; 4H 14 matches ER-01, measured calmer on noisy 4H bars (evidence/tv-38/L7-presets).
int erLenEff     = lensEff == "Weekly" ? 10  : lensEff == "Daily" ? 10 : lensEff == "8H" ? 8  : lensEff == "4H" ? 14 : lensEff == "30m" ? 5  : erLen
int kerSmoothEff = lensEff == "Weekly" ? 2   : lensEff == "Daily" ? 2  : lensEff == "8H" ? 2  : lensEff == "4H" ? 2  : lensEff == "30m" ? 5  : kerSmoothLen
int rankWinEff   = lensEff == "Weekly" ? 100 : lensEff == "Daily" ? 50 : lensEff == "8H" ? 50 : lensEff == "4H" ? 30 : lensEff == "30m" ? 30 : rankWin
int stabilityEff = lensEff == "Weekly" ? 6   : lensEff == "Daily" ? 10 : lensEff == "8H" ? 6  : lensEff == "4H" ? 6  : lensEff == "30m" ? 6  : stability

float enterPct = 50.0 + stabilityEff / 2.0
float exitPct  = 50.0 - stabilityEff / 2.0

// ─── Core returns-stochastic (parity-locked to the reference implementation) ───
pct = na(close[1]) ? na : (close - close[1]) / close[1]

hh   = ta.highest(pct, rankLenEff)
ll   = ta.lowest(pct, rankLenEff)
diff = hh - ll

raw       = (not na(diff)) and diff != 0 ? (pct - ll) / diff * 100 : 0.0
rawFilled = na(raw) ? 0.0 : raw

caseyC = ta.sma(rawFilled, smoothLenEff)

// ─── Confidence lens (Kaufman Efficiency Ratio) ────────────────────────────────
direction  = math.abs(close - close[erLenEff])
volatility = math.sum(math.abs(close - close[1]), erLenEff)
ker        = volatility != 0 ? direction / volatility : 0.0

kerEma     = ta.ema(ker, kerSmoothEff)                 // hoisted: ta.* runs every bar (no conditional-history warning)
kerSmooth  = kerSmoothEff <= 1 ? ker : kerEma
pctRank    = nz(ta.percentrank(kerSmooth, rankWinEff), 50.0)

var bool efficient = false
if not efficient and pctRank >= enterPct
    efficient := true
else if efficient and pctRank <= exitPct
    efficient := false

// ─── Honest warmup gate (NA must never collapse to a fake default state) ───────
// The parity core fills raw NA to 0, which without this gate paints a fake vivid
// oversold before data warms. Every zone/state branch checks warm.
int warmBars = math.max(rankLenEff + smoothLenEff, rankWinEff + erLenEff)
bool warm    = bar_index >= warmBars

// ─── Flat / zero-information tape guard (render-only; engine untouched) ─────────
// A dead / halted / illiquid tape prints identical closes across the KER window, so
// volatility = sum(|close - close[1]|) = 0. The constant KER series then makes
// ta.percentrank return 100 (tie-inclusive: previous values <= current), which would
// open the efficiency gate and paint a fake vivid oversold extreme (caseyC pins
// to 0 on flat returns). A zero-movement tape is the LEAST trustworthy read there is,
// so we render it as low-efficiency chop. This reads an already-computed engine value
// and only gates rendering, exactly like the warm gate (engine math is untouched).
// The guard now also covers RETURN-DISPERSION collapse, not just price volatility==0:
// on a steady grind (e.g. +x%/bar) price moves but the return range diff = hh - ll
// collapses to 0 (or na), pinning raw -> 0 -> a fake "oversold" while the KER gate can
// still read high. Folding noDispersion into flatTape renders that as flat / low-
// efficiency too, never a false extreme. diff is READ ONLY here (engine untouched).
// Adaptive dispersion floor. Tick-rounding on a constant grind produces a
// tiny non-zero diff that slips an exact "diff == 0" test, so we compare diff to a
// per-bar floor scaled off the symbol's minimum return tick (mintick / |close|).
// zeroMovement (volatility == 0) and noDispersion (moved but no return range) stay
// as separate booleans so the panel can name each case. All render-only.
float returnTick      = syminfo.mintick / math.max(math.abs(close), syminfo.mintick)
float dispersionFloor = math.max(1e-10, returnTick * 0.25)
// Pre-warm halt hole: the zero-movement leg latches PRE-warm too (na-guarded, replacing
// warm's role) so a symbol that goes dead before warmBars still trips the cooldown;
// noDispersion stays warm-gated (its na(diff) term would false-latch warmup).
bool  zeroMovement    = not na(volatility) and volatility == 0
bool  noDispersion    = warm and not zeroMovement and (na(diff) or diff <= dispersionFloor)
bool  flatTape        = zeroMovement or noDispersion

// ─── Post-flat cooldown (render-only halt-residue guard) ───────────────────────
// On the first bar after a flat / halt window the guard releases, but the SMA still
// holds injected zeros and percentrank of a constant-then-jump series reads ~100, so a
// vivid "efficient" read can spuriously flash on resume. The flat zeros contaminate the
// pctRank window for up to rankWinEff bars, so hold the render gate closed for rankWinEff
// bars (the full percentile-rank horizon) - the shorter smoothing-window horizon released
// the gate while the rank was still biased open.
// Engine untouched; this only gates rendering + the (already render-layer) event markers.
var int lastFlatBar = -100000
if flatTape
    lastFlatBar := bar_index
bool postFlatCool = (bar_index - lastFlatBar) <= rankWinEff
bool effRender = efficient and not flatTape and not postFlatCool

// ─── Render-only neutral value on unusable tape ────────────────────────────────
// On a flat / no-dispersion tape the frozen engine pins caseyC to 0, which visually
// reads as a hard oversold extreme. caseyRender sits the VISIBLE line at the neutral
// midline (50) on those bars instead. Engine caseyC is untouched (event detection and
// the data-window export still use raw caseyC); on a normal bar caseyRender == caseyC.
float caseyRender = (flatTape or postFlatCool) ? 50.0 : caseyC

// ─── Invalid-levels guard ──────────────────────────────────────────────────────
// If the user sets Upper <= Lower the zones are undefined; suppress zones/fills/
// markers/alerts and name it in the panel rather than paint a contradictory read.
bool validLevels = upperLevel > lowerLevel

// ─── Zone + event logic ────────────────────────────────────────────────────────
// inOB takes precedence so an inverted Upper<=Lower misconfig can never paint both
// zones at once (line color would say one thing, panel the other). For a valid
// Upper>Lower config the two are already mutually exclusive, so this is a no-op there.
// Zones read from caseyRender (render-only neutral on flat tape) and require
// validLevels, so a flat tape or an inverted Upper<=Lower config never paints a zone.
inOB       = validLevels and warm and caseyRender >= upperLevel
inOS       = validLevels and warm and caseyRender <= lowerLevel and not inOB
// ta.crossunder/crossover hoisted to globals so they evaluate every bar, not inside
// the conditional AND - satisfies the Pine v6 consistency linter. They already ran
// every bar (Pine evaluates ta.* unconditionally), so this is a lint-clean no-op
// with zero behavior change.
bool crossDnLower = ta.crossunder(caseyC, lowerLevel)
bool crossUpUpper = ta.crossover(caseyC, upperLevel)
// Directional-agreement filter. min-max-on-returns + KER can share one opposite-direction
// outlier, so an "efficient oversold" could print on flat drift right after an UP-spike
// (spike-shadow / wrong-direction certification). Require the cross bar's own return to
// agree with the zone (pct<0 for oversold, pct>0 for overbought) using the engine's
// existing pct read-only. effRender is the single source of truth for efficient and not
// flat/cooling. Tradeoff: a genuine flush whose exact cross-bar return is >=0 is
// filtered - acceptable to kill wrong-direction prints.
osCrossEff = warm and crossDnLower and effRender and validLevels and barstate.isconfirmed and pct < 0
obCrossEff = warm and crossUpUpper and effRender and validLevels and barstate.isconfirmed and pct > 0
// ---- CC_V21 ENGINE END ----

// K-B engine contract. The pane line is caseyRender (the engine value, parked at the middle on a flat or settling tape);
// events and the data-window exports read caseyC, as in cc_v21. Trust is the efficiency gate as drawn (effRender).
engValid = chart.is_standard and not na(close)
engReady = engValid and warm
engWarmBars = warmBars
engOsc = caseyRender
engTrust = effRender

// ==== KIT KB1 START ====
// KB1 bands and zones (template K-B) in Fixed mode: this reading's levels mean something on their own, so the two bands are the
// overbought and oversold level inputs and the Adaptive band inputs are removed (Kit defaults changed). The zone and the two
// events are the engine's own, unchanged: kbZone +1 = overbought (inOB), -1 = oversold (inOS), 0 between the levels;
// kbUpEvent = osCrossEff (efficient oversold), kbDownEvent = obCrossEff (efficient overbought). The kit's turn events are not used.
const float KIT_KB_LOW = 0.0
const float KIT_KB_HIGH = 100.0
const float KIT_KB_MID = 50.0
const string KIT_KB1_MODE = "Fixed"
kbReady = engReady
kbWarmBars = engWarmBars
kbUpper = not kbReady ? na : math.max(upperLevel, lowerLevel)
kbLower = not kbReady ? na : math.min(upperLevel, lowerLevel)
kbZone = not kbReady ? 0 : inOB ? 1 : inOS ? -1 : 0
kbUpEvent = osCrossEff
kbDownEvent = obCrossEff
// ==== KIT KB1 END ====

// ==== KIT KB7 START ====
// KB7 settings and alerts for K-B (the T7 pattern: groups, the palette, the honest gate, one alert payload). The indicator's own
// inputs come first, in groups "1. Profile", "2. Core" and "3. Advanced"; this block adds Marks, Display and Colours in that order,
// then the alerts. Every input here changes only the picture. Kit defaults changed (TV-38 v11): Panel on defaults to the indicator
// pane, top right, so the panel never covers the latest candles on the price chart. Kit defaults changed (TV-38 v11 L2b): the pane
// room is 0.15 of the line's recent range, not the kit's 0.8, so the line fills most of the pane (KB3 KIT_KB3_ROOM). This is
// not a guarantee: on a compact layout a recent high can still sit behind a pane panel (Panel on tooltip says so).
// Colour roles follow the owner-approved cc_v21 meaning (Kit defaults
// changed): the high zone (overbought) is T6's extreme-high amber, the low zone (oversold) is T6's bull green (Nova Green).
// Alerts: the two cc_v21 alerts only, condition and title unchanged, in the kit's payload form (Kit defaults changed: 2 alerts,
// below the kit's 3, because the card forbids new signals).
const string KIT_G_MARKS = "4. Marks"
const string KIT_G_DISPLAY = "5. Display"
const string KIT_G_COLOURS = "6. Colours"
const string KIT_INDICATOR = "Returns Stochastic"
const string KIT_TURN_MARKS = "price tags"
const string KIT_TURN_DOTS = "pane dots"
const string KIT_ALERT_OS = "Efficient Oversold Cross Down"
const string KIT_ALERT_OB = "Efficient Overbought Cross Up"
const string KIT_DISPLAY_ONLY = "Display only; it does not change the calculation."
const string KIT_LOOK_CLEAN = "• Clean: the line and the levels only, single dots, and the reading panel."
const string KIT_LOOK_GLOW = "• Glow: a glow and a fill past a level on a path that turned cleaner than usual, ringed pane dots and the panel."
const string KIT_LOOK_BOLD = "• Bold: denser fills, shaded strips beyond the levels, stronger pane rings and the panel."

kitShowTurnMarks = input.bool(true, "Show " + KIT_TURN_MARKS, group=KIT_G_MARKS, display=display.none, tooltip="Shows a small word tag beside the candle where an efficient oversold or overbought event closes.\n\nOS under the candle for oversold, OB over it for overbought. Drawn when that candle closes and never moved.\n\nHiding tags does not change the alerts.")
kitShowTurnDots = input.bool(true, "Show " + KIT_TURN_DOTS, group=KIT_G_MARKS, display=display.none, tooltip="Shows a dot on the pane line where the same event closes.\n\nIn the colour of the zone it entered: green for oversold, amber for overbought.\n\nHiding dots does not change the alerts.")
kitLook = input.string("Bold", "Look", options=["Clean", "Glow", "Bold"], group=KIT_G_DISPLAY, display=display.none, tooltip="Sets how bold the whole indicator looks.\n\n" + KIT_LOOK_CLEAN + "\n" + KIT_LOOK_GLOW + "\n" + KIT_LOOK_BOLD)
kitTheme = input.string("Auto", "Theme", options=["Auto", "Dark", "Light"], group=KIT_G_DISPLAY, display=display.none, tooltip="Matches the colours to your chart background.\n\n• Auto: reads the chart background.\n• Dark, Light: force one set.\n\n" + KIT_DISPLAY_ONLY)
kitShowGlow = input.bool(true, "Show glow", group=KIT_G_DISPLAY, display=display.none, active=kitLook != "Clean", tooltip="Shows a soft glow on the line where it is past a level on a path that turned cleaner than usual.\n\nThe Clean look has no glow, so this box is greyed out there.\n\n" + KIT_DISPLAY_ONLY)
kitPanelPos = input.string("Top Right", "Panel", options=["Top Right", "Bottom Right", "Bottom Left", "Off"], group=KIT_G_DISPLAY, display=display.none, tooltip="Places the reading panel, or turns it off.\n\nThe panel reads the last closed candle.\n\n" + KIT_DISPLAY_ONLY)
kitPanelOn = input.string("Indicator pane", "Panel on", options=["Price chart", "Indicator pane"], group=KIT_G_DISPLAY, display=display.none, active=kitPanelPos != "Off", tooltip="Chooses which chart area holds the reading panel.\n\n• Price chart: a corner of the price chart, so the pane line is never covered.\n• Indicator pane: a corner of this pane, with room made above or below the line. On a compact layout the panel can sit over a recent high; move it or turn it off.\n\n" + KIT_DISPLAY_ONLY)
kitFlatIn = input.color(KIT_NEUTRAL_DARK, "Line", group=KIT_G_COLOURS, inline="zone", display=display.none)
kitUpIn = input.color(KIT_EXT_HIGH_DARK, "Overbought", group=KIT_G_COLOURS, inline="zone", display=display.none)
kitDownIn = input.color(KIT_BULL_DARK, "Oversold", group=KIT_G_COLOURS, inline="zone", display=display.none, tooltip="Colours for the line between the levels, the overbought zone and the oversold zone.\n\nThey colour the line, the fills, the marks and the panel. On a light chart, colours left at their default switch to darker versions that stay readable.")

// The kit palette with the cc_v21 colour roles: up = the high zone (overbought, amber), down = the low zone (oversold, green).
// A colour left at its default switches to its T6 light value on a light chart. The weak step is the kit's fade on a dark chart; on a
// light chart it is a half mix toward the line colour, because the faded light amber reads under 3:1 on white (Kit defaults changed).
ccPalette(string theme, color highIn, color lowIn, color flatIn) =>
    KitPalette p = kitPalette(theme, highIn, lowIn, flatIn, KIT_EXT_HIGH_DARK, KIT_EXT_LOW_DARK)
    bool light = p.light
    color hi = kitPick(highIn, KIT_EXT_HIGH_DARK, KIT_EXT_HIGH_LIGHT, light)
    color lo = kitPick(lowIn, KIT_BULL_DARK, KIT_BULL_LIGHT, light)
    p.up := hi
    p.down := lo
    p.upText := hi
    p.downText := kitPick(lowIn, KIT_BULL_DARK, KIT_BULL_LIGHT_TEXT, light)
    p.upWeak := light ? color.from_gradient(0.5, 0.0, 1.0, hi, p.flat) : color.new(hi, KIT_WEAK_FADE_DARK)
    p.downWeak := light ? color.from_gradient(0.5, 0.0, 1.0, lo, p.flat) : color.new(lo, KIT_WEAK_FADE_DARK)
    p

kitPal = ccPalette(kitTheme, kitUpIn, kitDownIn, kitFlatIn)
kitClean = kitLook == "Clean"
kitBold = kitLook == "Bold"

// Honest warm-up and bar-close gating. The two events are the engine's own osCrossEff and obCrossEff, which already require a
// warm engine and a closed candle; engValid adds the kit's readable-chart check for the marks (the alerts keep cc_v21's condition).
kitReady = kbReady
kitUpMark = kbUpEvent and engValid
kitDownMark = kbDownEvent and engValid

// Payload: indicator, event, symbol, timeframe, close and bar time, always confirmed on the bar close.
const string KIT_ALERT_HEAD = KIT_INDICATOR + " [NovaLens]: "
const string KIT_PAYLOAD = " on {{exchange}}:{{ticker}} ({{interval}}), close {{close}}, bar time {{time}}. Confirmed on bar close."
alertcondition(osCrossEff, KIT_ALERT_OS, KIT_ALERT_HEAD + "EFFICIENT OVERSOLD: the reading crossed under the oversold level on a path that turned cleaner than usual" + KIT_PAYLOAD)
alertcondition(obCrossEff, KIT_ALERT_OB, KIT_ALERT_HEAD + "EFFICIENT OVERBOUGHT: the reading crossed over the overbought level on a path that turned cleaner than usual" + KIT_PAYLOAD)
// ==== KIT KB7 END ====

// ==== KIT T4 START ====
// T4 tooltips. House layout: a plain first block, a blank line, short blocks, the caveat last.
// The first two blocks use plain trader words: no digits, no units, no engine words (the kit lint checks every KIT_TIP_ constant).
// Numbers a trader uses go in one short block near the end, with plain names. Every head is a named KIT_TIP_ constant.
const string KIT_CAVEAT = "A reading, not an entry."

kitJoin(string first, string galSecond) =>
    first == "" ? galSecond : galSecond == "" ? first : first + "\n\n" + galSecond

// head = the two plain blocks; timing = when the mark or reading appears; numbers = the short number block; caveat last.
kitTip(string head, string timing, string numbers, string caveat) =>
    kitJoin(kitJoin(kitJoin(head, timing), numbers), caveat)

kitWhen() =>
    timeframe.isintraday ? str.format_time(time_close, "d MMM yyyy HH:mm", syminfo.timezone) : str.format_time(time, "d MMM yyyy", syminfo.timezone)

kitClosedOn(string when) =>
    "Confirmed on the " + when + " close. " + KIT_CAVEAT

kitPrice(float value) =>
    "Close " + str.tostring(value, format.mintick)
// ==== KIT T4 END ====

// ==== KIT KB5 START ====
// KB5 oscillator pane (template K-B), look option A. The kit picture: a slate line between the two
// level bands, coloured only past a level. Trust picks the strength step there: on a one-way path the zone colour at full
// strength with glow and fill, in chop the zone colour at the weak step (dim, never plain grey).
// Band, channel and mid inks are chart ink at fixed fades, so they follow any theme; the bands sit well below the line's contrast.
const string KIT_KB5_TITLE = "Returns Stoch"
const int KIT_KB5_WIDTH_CLEAN = 1
const int KIT_KB5_WIDTH = 2
const int KIT_KB5_GLOW_OUTER_WIDTH = 10
const int KIT_KB5_GLOW_INNER_WIDTH = 6
const int KIT_KB5_GLOW_OUTER_FADE_DARK = 86
const int KIT_KB5_GLOW_INNER_FADE_DARK = 70
const int KIT_KB5_GLOW_OUTER_FADE_LIGHT = 89
const int KIT_KB5_GLOW_INNER_FADE_LIGHT = 76
const int KIT_KB5_FILL_FADE_DARK = 60
const int KIT_KB5_FILL_FADE_LIGHT = 50
const int KIT_KB5_FILL_FADE_BOLD_DARK = 35
const int KIT_KB5_FILL_FADE_BOLD_LIGHT = 25
const int KIT_KB5_ZONE_FADE_DARK = 80
const int KIT_KB5_ZONE_FADE_LIGHT = 80
const int KIT_KB5_BAND_FADE = 75
const int KIT_KB5_CHANNEL_FADE = 95
const int KIT_KB5_MID_FADE = KIT_ZERO_FADE
const float KIT_KB5_SHADE = 0.25

k5Osc = kitReady ? engOsc : na
k5Upper = kitReady ? kbUpper : na
k5Lower = kitReady ? kbLower : na
k5Ink = kitDirColor(kitPal, kbZone, engTrust ? 3 : 1)
k5Past = kitReady and kbZone != 0
k5Trusted = kitReady and engTrust
k5FillOn = kitReady and not kitClean
k5GlowOn = kitShowGlow and not kitClean
k5FillFade = kitBold ? (kitPal.light ? KIT_KB5_FILL_FADE_BOLD_LIGHT : KIT_KB5_FILL_FADE_BOLD_DARK) : kitPal.light ? KIT_KB5_FILL_FADE_LIGHT : KIT_KB5_FILL_FADE_DARK
k5ZoneFade = kitPal.light ? KIT_KB5_ZONE_FADE_LIGHT : KIT_KB5_ZONE_FADE_DARK
k5OuterFade = kitPal.light ? KIT_KB5_GLOW_OUTER_FADE_LIGHT : KIT_KB5_GLOW_OUTER_FADE_DARK
k5InnerFade = kitPal.light ? KIT_KB5_GLOW_INNER_FADE_LIGHT : KIT_KB5_GLOW_INNER_FADE_DARK
k5ShadeWidth = KIT_KB5_SHADE * (k5Upper - k5Lower)
// Glow and the past-level fill only where the line is past a level on a one-way path (trust); in chop the line alone carries the zone.
k5Glow = k5Past and k5Trusted and k5GlowOn
k5FillTrust = k5FillOn and k5Trusted
plot(kitReady and k5Lower <= KIT_KB_MID and KIT_KB_MID <= k5Upper ? KIT_KB_MID : na, "Mid line", color=kitStructure(KIT_KB5_MID_FADE), linewidth=1, linestyle=plot.linestyle_dotted, display=display.pane, editable=false)
k5Up = plot(k5Upper, "Overbought level", color=kitStructure(KIT_KB5_BAND_FADE), linewidth=1, display=display.pane)
k5Lo = plot(k5Lower, "Oversold level", color=kitStructure(KIT_KB5_BAND_FADE), linewidth=1, display=display.pane)
fill(k5Up, k5Lo, k5FillOn ? kitStructure(KIT_KB5_CHANNEL_FADE) : na, title="Level channel")
plot(k5Osc, "Glow outer", color=k5Glow ? color.new(k5Ink, k5OuterFade) : na, linewidth=KIT_KB5_GLOW_OUTER_WIDTH, display=display.pane, editable=false)
plot(k5Osc, "Glow inner", color=k5Glow ? color.new(k5Ink, k5InnerFade) : na, linewidth=KIT_KB5_GLOW_INNER_WIDTH, display=display.pane, editable=false)
k5Line = plot(k5Osc, KIT_KB5_TITLE, color=k5Ink, linewidth=kitClean ? KIT_KB5_WIDTH_CLEAN : KIT_KB5_WIDTH, display=display.pane + display.status_line + display.price_scale)
// The fill runs from the level to the line, so it has no area while the line is inside (the anchor sits on the line there).
k5HighBase = plot(k5FillOn ? math.min(k5Osc, k5Upper) : na, "High fill anchor", display=display.none, editable=false)
k5LowBase = plot(k5FillOn ? math.max(k5Osc, k5Lower) : na, "Low fill anchor", display=display.none, editable=false)
fill(k5Line, k5HighBase, k5Osc, k5Upper, k5FillTrust ? color.new(kitPal.up, k5FillFade) : na, k5FillTrust ? color.new(kitPal.up, 100) : na, title="Overbought fill", fillgaps=false)
fill(k5LowBase, k5Line, k5Lower, k5Osc, k5FillTrust ? color.new(kitPal.down, 100) : na, k5FillTrust ? color.new(kitPal.down, k5FillFade) : na, title="Oversold fill", fillgaps=false)
// The Bold strip edges are hidden plots, so the strip never widens the pane.
k5HighEdge = plot(kitBold ? k5Upper + k5ShadeWidth : na, "High shade edge", display=display.none, editable=false)
k5LowEdge = plot(kitBold ? k5Lower - k5ShadeWidth : na, "Low shade edge", display=display.none, editable=false)
fill(k5HighEdge, k5Up, k5Upper + k5ShadeWidth, k5Upper, kitBold ? color.new(kitPal.up, 100) : na, kitBold ? color.new(kitPal.up, k5ZoneFade) : na, title="Overbought shade", fillgaps=false)
fill(k5Lo, k5LowEdge, k5Lower, k5Lower - k5ShadeWidth, kitBold ? color.new(kitPal.down, k5ZoneFade) : na, kitBold ? color.new(kitPal.down, 100) : na, title="Oversold shade", fillgaps=false)
// ==== KIT KB5 END ====

// ==== KIT KB2 START ====
// KB2 event marks for K-B, look Option A with word tags on price (v11). One mark per confirmed event: osCrossEff (efficient oversold) and obCrossEff (efficient
// overbought), on the closed candle where it happens, never moved afterwards, in the colour of the zone entered. Two places, each with
// its own box: beside the candle on the price chart (under it for oversold, over it for overbought) and on the pane line. On the pane
// line the kit's dot family: a core dot with a fainter ring in Glow and Bold. Beside the candle a word tag instead of the kit dot (Kit
// defaults changed: word tags on price instead of the kit dot, owner msg 1557651402459844699): OS under the candle, OB over it, one
// small label per event with a soft zone-tinted fill, placed below or above the bar so a small gap keeps it off the wick and it never
// stretches the price scale. The word takes the zone colour and drops to black or white where that would read under 4.5:1 on the
// fill as seen on this chart.
const string KIT_T2_DOT_GLYPH = "●"
const string KIT_T2_UP_GLYPH = "▲"
const string KIT_T2_DOWN_GLYPH = "▼"
const string CC_TAG_OS = "OS"
const string CC_TAG_OB = "OB"
const string CC_TAG_SIZE = size.small
const int CC_TAG_FILL_FADE = 45
const float CC_TAG_TEXT_FLOOR = 4.5
const string CC_RING_GLYPH = "○"
const int KIT_T2_CORE_SIZE = 13
const int KIT_T2_RING_SIZE = 16
const int KIT_T2_RING_FADE_GLOW = 72
const int KIT_T2_RING_FADE_BOLD = 65
const float KIT_T2_GAP_BELOW = 1.6
const float KIT_T2_GAP_ABOVE = 0.6
const int KIT_T2_KEEP = 100
const string KIT_TIP_MARK_OS = "Efficient oversold: the reading dropped into its low zone while the recent path had turned cleaner than usual for this chart.\n\nIt crossed under the oversold level on this candle and the candle closed lower. Trust reads how clean the path was, not which way. A low reading describes recent moves, not where price goes next."
const string KIT_TIP_MARK_OB = "Efficient overbought: the reading rose into its high zone while the recent path had turned cleaner than usual for this chart.\n\nIt crossed over the overbought level on this candle and the candle closed higher. Trust reads how clean the path was, not which way. A high reading describes recent moves, not where price goes next."
const string KIT_TIP_TIMING_TURN = "This mark appears when that candle closes and is never moved."

// A tag fill as seen on the chart background, and the word ink that reads at least 4.5:1 on it.
ccOver(color top, color under) =>
    color.from_gradient(1 - color.t(top) / 100, 0, 1, under, color.new(top, 0))
ccLum(color c) =>
    0.2126 * kitChannel(color.r(c)) + 0.7152 * kitChannel(color.g(c)) + 0.0722 * kitChannel(color.b(c))
ccReadable(color ink, color seen) =>
    float hi = math.max(ccLum(ink), ccLum(seen))
    float lo = math.min(ccLum(ink), ccLum(seen))
    (hi + 0.05) / (lo + 0.05) >= CC_TAG_TEXT_FLOOR ? ink : kitInkOn(seen)

t2RingFade = kitBold ? KIT_T2_RING_FADE_BOLD : KIT_T2_RING_FADE_GLOW

// Each place keeps its last KIT_T2_KEEP marks in every Look (one label per glyph drawn).
t2Keep(array<label> marks, label mark, int cap) =>
    array.push(marks, mark)
    while array.size(marks) > cap
        label.delete(array.shift(marks))

var array<label> k2PriceMarks = array.new<label>()
var array<label> k2PaneDots = array.new<label>()
if (kitShowTurnMarks or kitShowTurnDots) and (kitUpMark or kitDownMark)
    bool fromHigh = kitDownMark
    color tone = fromHigh ? kitPal.up : kitPal.down
    string tip = kitTip(fromHigh ? KIT_TIP_MARK_OB : KIT_TIP_MARK_OS, KIT_TIP_TIMING_TURN, kitPrice(close) + "\nReading " + str.tostring(caseyC, "#.#") + ", trust rank " + str.tostring(math.round(pctRank)), kitClosedOn(kitWhen()))
    if kitShowTurnMarks
        int priceCap = KIT_T2_KEEP
        color tagFill = color.new(tone, CC_TAG_FILL_FADE)
        color tagInk = ccReadable(fromHigh ? kitPal.upText : kitPal.downText, ccOver(tagFill, chart.bg_color))
        t2Keep(k2PriceMarks, label.new(bar_index, fromHigh ? high : low, fromHigh ? CC_TAG_OB : CC_TAG_OS, yloc=fromHigh ? yloc.abovebar : yloc.belowbar, style=fromHigh ? label.style_label_down : label.style_label_up, color=tagFill, textcolor=tagInk, size=CC_TAG_SIZE, tooltip=tip, force_overlay=true), priceCap)
    if kitShowTurnDots
        int paneCap = (kitClean ? 1 : 2) * KIT_T2_KEEP
        if not kitClean
            t2Keep(k2PaneDots, label.new(bar_index, engOsc, KIT_T2_DOT_GLYPH, yloc=yloc.price, style=label.style_none, textcolor=color.new(tone, t2RingFade), size=KIT_T2_RING_SIZE, tooltip=tip), paneCap)
        t2Keep(k2PaneDots, label.new(bar_index, engOsc, KIT_T2_DOT_GLYPH, yloc=yloc.price, style=label.style_none, textcolor=tone, size=KIT_T2_CORE_SIZE, tooltip=tip), paneCap)
// ==== KIT KB2 END ====

// ==== KIT KB3 START ====
// KB3 reading panel for K-B: the T3 face (the TV-35 v12 panel's display values, LESSON 13.11) read from the last closed candle.
// Three rows (the kit default count): the header names the zone (Oversold, Overbought, Neutral) in the zone colour, Trust names the
// efficiency gate (Efficient or Chop) and Last signal counts the closed candles since the last efficient event. Status faces, in the
// header state cell with "-" in each row: Waiting, Warming up, No reading, Bad levels (overbought level not above oversold), Flat (no
// movement or no spread of returns) and Settling (the post-flat hold). Every word follows the engine on that closed candle.
const int KIT_T3_ROWS = 3
const string KIT_T3_ROWS_REASON = ""
const string KIT_T3_TITLE = "Returns Stoch"
const string KIT_T3_HIGH = "Overbought"
const string KIT_T3_LOW = "Oversold"
const string KIT_T3_MIDDLE = "Neutral"
const string KIT_T3_LABEL_1 = "Trust"
const string KIT_T3_LABEL_2 = "Last signal"
const string KIT_T3_EFFICIENT = "Efficient"
const string KIT_T3_CHOP = "Chop"
const string KIT_T3_BAR = " bar"
const string KIT_T3_BARS = " bars"
const string KIT_T3_AGO = " ago"
const string KIT_T3_WAITING = "Waiting"
const string KIT_T3_WARMING = "Warming up"
const string KIT_T3_NO_READING = "No reading"
const string KIT_T3_BAD_LEVELS = "Bad levels"
const string KIT_T3_FLAT = "Flat"
const string KIT_T3_SETTLING = "Settling"
const string KIT_T3_EMPTY = "-"
const string KIT_T3_TITLE_SIZE = size.normal
const string KIT_T3_STATE_SIZE = size.large
const string KIT_T3_ROW_SIZE = size.normal
const int KIT_T3_FRAME_PX = 2
const int KIT_T3_BORDER_PX = 1
const bool KIT_T3_TOP_CLEARANCE = true
const float KIT_KB3_ROOM = 0.15
const int KIT_KB3_ROOM_BARS = 200
const int KIT_KB3_ZONE_TINT_FADE = 75
const int KIT_KB3_INSIDE_TINT_FADE = 80
const float KIT_KB3_TEXT_FLOOR = 4.5
const string KIT_TIP_ZONE_HIGH = "This row shows where the reading sits against its two levels.\n\nThe reading is at or above the overbought level: recent moves sit near the top of their range. It describes the reading, not a trade."
const string KIT_TIP_ZONE_LOW = "This row shows where the reading sits against its two levels.\n\nThe reading is at or below the oversold level: recent moves sit near the bottom of their range. It describes the reading, not a trade."
const string KIT_TIP_ZONE_MIDDLE = "This row shows where the reading sits against its two levels.\n\nThe reading is between the levels, its usual range."
const string KIT_TIP_TRUST_ON = "This row shows how clean the recent move was.\n\nEfficient: the recent move became cleaner than usual for this chart and has not clearly dropped back since. A reading at a level is worth a look; at or past a level the line is coloured at full strength."
const string KIT_TIP_TRUST_OFF = "This row shows how clean the recent move was.\n\nChop: the recent move was not clean enough, compared with what is usual for this chart, to count as Efficient. A reading at a level says less here, so no tag or alert prints."
const string KIT_TIP_SIGNAL = "This row counts the closed candles since the last efficient oversold or overbought signal.\n\nThe marks on the chart show where it happened."
const string KIT_TIP_SIGNAL_NONE = "This row counts the closed candles since the last efficient oversold or overbought signal.\n\nThere has been no signal on this chart yet."
const string KIT_TIP_WAITING = "The reading starts after a candle closes.\n\nThe panel uses closed candles only."
const string KIT_TIP_WARMING = "The reading needs more closed candles first.\n\nThe panel uses closed candles only."
const string KIT_TIP_NO_READING = "The indicator cannot read this chart.\n\nThe chart has a missing price or is not a standard candle chart."
const string KIT_TIP_BAD_LEVELS = "The two levels cannot define the zones.\n\nSet the overbought level above the oversold level in the settings."
const string KIT_TIP_FLAT = "The tape is flat: prices did not move, or every move was the same size.\n\nThere is nothing to rank, so the line rests at the middle and no signal prints."
const string KIT_TIP_SETTLING = "The tape was flat a short while ago.\n\nThe line rests at the middle until the trust read has a clean window again."

// Last closed candle snapshot: the panel never shows an unfinished candle.
var string t3Status = KIT_T3_WAITING
var int t3Zone = 0
var bool t3Trust = false
var int t3SignalBar = na
var int t3SignalSide = 0
var float t3SinceSignal = na
var float t3Reading = na
var float t3Rank = na
var string t3When = ""
if barstate.isconfirmed
    t3Status := not engValid ? KIT_T3_NO_READING : not validLevels ? KIT_T3_BAD_LEVELS : not kitReady ? KIT_T3_WARMING : flatTape ? KIT_T3_FLAT : postFlatCool ? KIT_T3_SETTLING : ""
    t3Zone := t3Status == "" ? kbZone : 0
    t3Trust := t3Status == "" and engTrust
    t3SignalSide := kitUpMark ? -1 : kitDownMark ? 1 : t3SignalSide
    t3SignalBar := kitUpMark or kitDownMark ? bar_index : t3SignalBar
    t3SinceSignal := na(t3SignalBar) ? na : bar_index - t3SignalBar
    t3Reading := caseyC
    t3Rank := pctRank
    t3When := kitWhen()

t3Pos = kitPanelPos == "Top Left" ? position.top_left : kitPanelPos == "Bottom Right" ? position.bottom_right : kitPanelPos == "Bottom Left" ? position.bottom_left : position.top_right
t3ShowTable = kitPanelPos != "Off"
t3OnPrice = kitPanelOn == "Price chart"
// Room in the pane: a hidden anchor just past the recent range on the panel's side (0.15 of it, Kit defaults changed), so the line
// fills most of the pane and usually stays under a top panel; the panel is sized in pixels and the range in values, so on a
// compact layout a reading near the top of its last 200 candles can still sit behind it.
t3RoomTop = kitPanelPos == "Top Right" or kitPanelPos == "Top Left"
t3RangeHigh = ta.highest(kitReady ? math.max(engOsc, kbUpper) : KIT_KB_LOW, KIT_KB3_ROOM_BARS)
t3RangeLow = ta.lowest(kitReady ? math.min(engOsc, kbLower) : KIT_KB_HIGH, KIT_KB3_ROOM_BARS)
t3RoomValue = t3RoomTop ? t3RangeHigh + KIT_KB3_ROOM * (t3RangeHigh - t3RangeLow) : t3RangeLow - KIT_KB3_ROOM * (t3RangeHigh - t3RangeLow)
plot(t3ShowTable and not t3OnPrice and kitReady ? t3RoomValue : na, "Panel room", color=color.new(kitPal.flat, 100), display=display.pane, editable=false)
t3Spacer = KIT_T3_TOP_CLEARANCE and kitPanelPos == "Top Left"
t3Row0 = t3Spacer ? 1 : 0
t3CellBg = t3Spacer ? kitPal.base : color(na)
// force_overlay takes a constant, so the panel exists twice, once per chart area; only the chosen one is filled.
var table t3PriceTable = table.new(t3Pos, 2, KIT_T3_ROWS + t3Row0, bgcolor=t3Spacer ? color(na) : kitPal.base, frame_color=t3Spacer ? color(na) : kitPal.frame, frame_width=t3Spacer ? 0 : KIT_T3_FRAME_PX, border_color=t3Spacer ? color(na) : kitPal.border, border_width=KIT_T3_BORDER_PX, force_overlay=true)
var table t3PaneTable = table.new(t3Pos, 2, KIT_T3_ROWS + t3Row0, bgcolor=t3Spacer ? color(na) : kitPal.base, frame_color=t3Spacer ? color(na) : kitPal.frame, frame_width=t3Spacer ? 0 : KIT_T3_FRAME_PX, border_color=t3Spacer ? color(na) : kitPal.border, border_width=KIT_T3_BORDER_PX)
t3Table = t3OnPrice ? t3PriceTable : t3PaneTable

t3Head(string state, color stateColor, color headBg, string tip) =>
    table.cell(t3Table, 0, t3Row0, KIT_T3_TITLE, text_color=kitPal.titleInk, bgcolor=headBg, text_size=KIT_T3_TITLE_SIZE, text_halign=text.align_left, tooltip=tip)
    table.cell(t3Table, 1, t3Row0, state, text_color=stateColor, bgcolor=headBg, text_size=KIT_T3_STATE_SIZE, text_halign=text.align_right, tooltip=tip)
t3Row(int row, string labelText, string valueText, color valueColor, string tip) =>
    table.cell(t3Table, 0, t3Row0 + row, labelText, text_color=kitPal.labelInk, bgcolor=t3CellBg, text_size=KIT_T3_ROW_SIZE, text_halign=text.align_left, tooltip=tip)
    table.cell(t3Table, 1, t3Row0 + row, valueText, text_color=valueColor, bgcolor=t3CellBg, text_size=KIT_T3_ROW_SIZE, text_halign=text.align_right, tooltip=tip)
t3Over(color top, color under) =>
    color.from_gradient(1 - color.t(top) / 100, 0, 1, under, color.new(top, 0))
t3Lum(color c) =>
    0.2126 * kitChannel(color.r(c)) + 0.7152 * kitChannel(color.g(c)) + 0.0722 * kitChannel(color.b(c))
t3Readable(color ink, color seen) =>
    float hi = math.max(t3Lum(ink), t3Lum(seen))
    float lo = math.min(t3Lum(ink), t3Lum(seen))
    (hi + 0.05) / (lo + 0.05) >= KIT_KB3_TEXT_FLOOR ? ink : kitInkOn(seen)

if barstate.islast
    bool face = t3Status != ""
    color baseSeen = t3Over(kitPal.base, chart.bg_color)
    color headTint = t3Zone > 0 ? color.new(kitPal.up, KIT_KB3_ZONE_TINT_FADE) : t3Zone < 0 ? color.new(kitPal.down, KIT_KB3_ZONE_TINT_FADE) : color.new(kitPal.flat, KIT_KB3_INSIDE_TINT_FADE)
    color headSeen = t3Over(headTint, baseSeen)
    color headBg = face ? t3CellBg : t3Spacer ? headSeen : headTint
    string closedOn = t3When == "" ? KIT_CAVEAT : kitClosedOn(t3When)
    string zoneWord = face ? t3Status : t3Zone > 0 ? KIT_T3_HIGH : t3Zone < 0 ? KIT_T3_LOW : KIT_T3_MIDDLE
    string statusHead = t3Status == KIT_T3_WAITING ? KIT_TIP_WAITING : t3Status == KIT_T3_WARMING ? KIT_TIP_WARMING : t3Status == KIT_T3_BAD_LEVELS ? KIT_TIP_BAD_LEVELS : t3Status == KIT_T3_FLAT ? KIT_TIP_FLAT : t3Status == KIT_T3_SETTLING ? KIT_TIP_SETTLING : KIT_TIP_NO_READING
    string statusNumbers = t3Status == KIT_T3_WARMING ? "Closed candles still needed: " + str.tostring(math.max(kbWarmBars - bar_index, 1)) : ""
    string readNumbers = na(t3Reading) ? "" : "Reading " + str.tostring(t3Reading, "#.#") + " of 100, levels " + str.tostring(lowerLevel) + " and " + str.tostring(upperLevel)
    string zoneTip = face ? kitTip(statusHead, "", statusNumbers, closedOn) : kitTip(t3Zone > 0 ? KIT_TIP_ZONE_HIGH : t3Zone < 0 ? KIT_TIP_ZONE_LOW : KIT_TIP_ZONE_MIDDLE, "", readNumbers, closedOn)
    table.clear(t3Table, 0, 0, 1, KIT_T3_ROWS - 1 + t3Row0)
    if t3ShowTable
        if t3Spacer
            table.cell(t3Table, 0, 0, " \n \n ", text_color=color.new(kitPal.valueInk, 100), bgcolor=na, text_size=size.small)
        t3Head(zoneWord, face ? kitPal.valueInk : t3Readable(kitDirText(kitPal, t3Zone), headSeen), headBg, zoneTip)
        string trustText = t3Trust ? KIT_T3_EFFICIENT : KIT_T3_CHOP
        color trustInk = t3Trust and t3Zone != 0 ? t3Readable(kitDirText(kitPal, t3Zone), baseSeen) : kitPal.valueInk
        string trustTip = kitTip(t3Trust ? KIT_TIP_TRUST_ON : KIT_TIP_TRUST_OFF, "", na(t3Rank) ? "" : "Trust rank " + str.tostring(math.round(t3Rank)) + " of 100", closedOn)
        t3Row(1, KIT_T3_LABEL_1, face ? KIT_T3_EMPTY : trustText, face ? kitPal.valueInk : trustInk, face ? zoneTip : trustTip)
        string signalText = na(t3SinceSignal) ? KIT_T3_EMPTY : str.tostring(t3SinceSignal, "#") + (t3SinceSignal == 1 ? KIT_T3_BAR : KIT_T3_BARS) + KIT_T3_AGO
        color signalInk = na(t3SinceSignal) ? kitPal.valueInk : t3Readable(kitDirText(kitPal, t3SignalSide), baseSeen)
        string signalNumbers = na(t3SinceSignal) ? "" : (t3SignalSide < 0 ? "Oversold" : "Overbought") + " signal, closed candles since: " + str.tostring(t3SinceSignal, "#")
        t3Row(2, KIT_T3_LABEL_2, face ? KIT_T3_EMPTY : signalText, face ? kitPal.valueInk : signalInk, face ? zoneTip : kitTip(na(t3SinceSignal) ? KIT_TIP_SIGNAL_NONE : KIT_TIP_SIGNAL, "", signalNumbers, closedOn))
// ==== KIT KB3 END ====

// Data-window engine exports, unchanged from cc_v21 (titles and values): na before warm; the trust export mirrors the drawn verdict.
plot(warm ? caseyC : na,             "Returns Stoch (engine)", color=KIT_NEUTRAL_DARK, display=display.data_window, editable=false)
plot(warm ? pctRank : na,            "KER pct rank (engine)",  color=KIT_NEUTRAL_DARK, display=display.data_window, editable=false)
plot(warm ? (effRender ? 1 : 0) : na, "Efficient (engine)",    color=KIT_NEUTRAL_DARK, display=display.data_window, editable=false)
````
