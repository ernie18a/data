# HARSI Suite Divergneces [Market Breakers]

- url: https://www.tradingview.com/script/xMuS9LAI-HARSI-Suite-Divergneces-Market-Breakers/
- type: indicator
- pine_id: PUB;6d88548db34246d5b9f0644964fdd727
- version: 1.0

## Description

HARSI Suite Divergences is an oscillator-pane indicator that merges three open-source HARSI works into one coherent workflow: HARSI candles for momentum, WaveTrend-gated buy/sell dots, a fractal divergence engine that draws lines on both this pane AND the main chart, higher-timeframe HARSI candle boxes for top-down context, and independent HH/LL structure labels. The reason for the merge is that these components describe momentum at different scales, and running them as one script lets each engine be styled without moving the others.

BACKGROUND — WHAT HARSI IS
The Heikin Ashi RSI ("HARSI") reinterprets the RSI series as a Heikin-Ashi–style candle sequence. Where a raw RSI line asks you to read momentum from a jagged plot, HARSI presents the same information as body-and-wick candles you can read the way you read price. This oscillator is centered on zero (RSI − 50) so overbought/oversold zones sit symmetrically above and below the midline.

HOW THE ENGINES ARE SEPARATED
The build's design choice is to run four independent engines so restyling one thing doesn't move another. This is the primary architectural addition over the source works.
1. Display engine — draws the HARSI candles on this pane and the HTF HARSI candle boxes when enabled. A preset system (Raw 14/1 for the classic HARSI look, Smoothed 10/5 for a noise-reduced pairing with the HTF boxes, Custom for direct parameter control) lets you switch display profiles without touching the other engines.
2. Structure engine — a dedicated HARSI (default 14/1) drives the HH/LL pivot detection. Because it's independent of the display, changing the display candles' smoothing never shifts where the HH/LL labels land.
3. Gate RSI — a dedicated RSI (default 7-length, smoothed) whose prior-bar cross of ±gate level is required for a WaveTrend buy/sell dot to fire. Decoupled from the display so restyling the candles never changes when signals appear.
4. WaveTrend + Divergence engine — WaveTrend cross-in-zone conditions produce the dots (regular vs. divergence-confirmed distinctly), and a fractal-based divergence scanner captures the two swings for the divergence lines.

FEATURES
Dual-pane divergence lines — When the divergence engine confirms a regular or hidden divergence, the connecting line is drawn twice off the same two swing points: once across the HARSI candle highs/lows on this pane (in-scale, riding the visible candles), and once via force_overlay across the corresponding price highs/lows on the main chart. Optional +RD / −RD / +HD / −HD labels on both. Oscillator and price stay in agreement because both lines share the exact same endpoints captured at fractal-confirmation time.

HTF HARSI candles — Higher-timeframe HARSI candles rendered as boxes with independently stylable outline, body, wicks, midline, and range label. A shared auto-pair table maps chart timeframe to a sensible HTF (five default LTF→HTF pairs, all user-editable), with a manual override and a safety fallback if the resolved HTF is somehow at or below the chart timeframe. The in-progress HTF candle grows live on the current bar so you can watch it develop between closes.

WaveTrend buy/sell dots — Triangles fire when the WT oscillator crosses inside its OB/OS zone AND the dedicated gate RSI has crossed its ±threshold on the prior bar. Divergence-confirmed dots (WT signal + WT divergence agreeing) plot fully opaque; plain WT-only dots plot faded, so you can tell the two apart at a glance.

HH/LL structure labels — Higher-highs and lower-lows are identified on the structure HARSI's pivots and labeled at the candle high/low with configurable offset, color, text color, and size.

OB/OS boundary bands — Three colored fill zones (OB extreme, main channel, OS extreme) spanning the full pane width via extend.both, so the oscillator's zonal context reads clearly and stays visible past the last candle.

ALERTS
- Buy/Sell (Divergence + WT) — divergence-confirmed dots
- Buy/Sell (WT Cross) — regular WT dots
- HARSI Higher High / Lower Low — structure prints
- Bearish/Bullish Divergence Line — fires on the confirmation bar of a drawn line, so the alert and the line always agree

HOW TO USE
Add it to any liquid instrument on the timeframe you actually trade — HARSI is a momentum interpretation and works on any chart timeframe, though intraday-to-swing timeframes are where most of the design attention went. Start on the Raw (14/1) preset for the classic look; try Smoothed (10/5) if you're using the HTF candle boxes. Leave HTF on Auto until you have a preferred mapping, then switch to Manual to lock it. Use the divergence lines on either pane alone if the dual-pane display is too busy for your layout.

LIMITATIONS
- HARSI is a momentum interpretation, not a directional prediction. It smooths noise but does not create predictive edge on its own.
- Structure labels lag by the right-bar setting (default 5 bars) because a pivot cannot be confirmed until N bars after it forms.
- Divergences are pattern annotations describing momentum vs. price behavior, not entry signals in themselves.
- HTF candle boxes on very long histories may recycle older elements because of TradingView's 500-drawings-per-script cap.
- Works best on standard candle/bar charts. Non-standard chart types (Heikin Ashi, Renko, P&F, Range, Kagi) alter the underlying series and will produce unrealistic HARSI and WaveTrend behavior.

CREDITS

Full credit to the original authors whose open-source work this script builds on:
@JayRogers — Heikin Ashi RSI Oscillator. This is the foundational work the entire Suite is built around. The core HARSI candle engine — the zero-median RSI helper, the RSI Heikin-Ashi OHLC derivation, the OB/OS boundary architecture with its three-zone fill approach, and the mode-selectable smoothed RSI overlay — all originate with Jay's script. This build parameterizes the HARSI generator so multiple independent engines (Display, Structure) can run off the same math with different settings, but the math itself is Jay's. He released the original under an explicitly permissive grant ("free to use, copy, and alter in any way you choose").

@LordKaan — Overlay - HARSI + Divergences + TTF. The WaveTrend oscillator + fractal-based divergence engine architecture was adapted from this work. The 3LS Oscillator and Stochastic modules present in the original were removed for this build; the WT + divergence portion was kept and extended.

@krollo041 (Kevin Rollo) — HTF Candle Boxes for LTF Charts. The HTF candle-box rendering approach (aggregating OHLC across an HTF interval into a drawn box + wicks between chart bars) was adapted for HARSI values rather than price.

Additions in this build, over the source works:
- A dedicated Structure engine (a second HARSI instance) driving HH/LL pivots, so structure labels are independent of the Display preset
- A dedicated Gate RSI for the WT buy/sell dots, so restyling the display never changes when signals fire
- Dual-pane divergence lines drawing simultaneously on the oscillator AND via force_overlay on the main chart, from the same fractal-confirmed swing points
- Shared HTF auto-pair table with manual override and a same-or-lower-TF safety fallback, unified across the HTF module
- Preset system for the display candles (Raw / Smoothed / Custom)
- Live in-progress HTF candle rendering that grows on the current bar
- Consolidated alert layer covering dots, structure prints, and confirmed divergence lines

Source is published open under the Mozilla Public License 2.0.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © manny_mailbox2

// HARSI Suite V1 [Market Breakers] — Pine Script v6
// Merged by Claude from:
//   - HARSI + Divergences + 3LS Oscillator      (3LS + Stoch removed)
//   - HARSI HTF Candles V4                      (HTF HARSI candle boxes)
//   - HARSI HH/LL V3                            (structure pivots; OR boxes removed)
// Original sources:
//   - Heikin Ashi RSI Oscillator by @JayRogers
//   - Overlay - HARSI + Divergences + TTF by @LordKaan
//   - HTF Candle Boxes for LTF Charts by @krollo041 (Kevin Rollo)
//
// Architecture:
//   * DISPLAY engine  -> HARSI candles + HTF candle boxes (preset: Raw/Smoothed/Custom)
//   * STRUCTURE engine -> HH/LL pivot labels (independent, default 14/1)
//   * GATE RSI        -> dedicated RSI powering the WT buy/sell dot gate
//   * DIVERGENCE lines -> dual-pane (oscillator + main chart) drawn off the WT div engine
//   * One shared HTF pair table + manual override

//@version=6
indicator("HARSI Suite Divergneces [Market Breakers]", "HARSI•Suite Divergences [Market Breakers]", false, format.price, 2,
  max_boxes_count=500, max_lines_count=500, max_labels_count=500)

////////////////////////////////////////////////////////////////////////////////
//                          ====== TOOLTIPS ======
////////////////////////////////////////////////////////////////////////////////

string TT_PRESET   = "Raw (14/1): classic HARSI candles.\n\nSmoothed (10/5): noise-reduced look, pairs well with the HTF candle boxes.\n\nCustom: uses the Custom Length / Custom Open Smoothing fields below."
string TT_HARSI    = "Period for the RSI calculations used to generate the candles. Only used when Preset = Custom."
string TT_PBIAS    = "Smoothing feature for the OPEN of the HARSI candles. Only used when Preset = Custom.\n\nIncreases bias toward the prior open value which can help provide better visualisation of trend strength."
string TT_SMRSI    = "This option smoothes the RSI in a manner similar to HA open, but uses the realtime rsi rather than the prior close value."
string TT_STRUCT   = "The HH/LL pivot engine runs on its OWN HARSI values so structure labels don't move when you change the display preset. Match these to whichever HARSI profile you want structure measured on."
string TT_GATE     = "The WT buy/sell dots require this dedicated gate RSI to have been beyond ±Gate Level on the prior bar. Decoupled from the display RSI so restyling never changes signals."
string TT_HTF_MODE = "Auto: HTF is selected based on your chart TF using the pair table below.\n\nManual: HTF uses the timeframe specified in the Manual HTF field, ignoring the pair table."
string TT_HTF_INT  = "Manual HTF override. Only used when Mode = Manual. Should be greater than your chart TF."
string TT_HTF_RNG  = "Display the HTF HARSI range (HH-LL) as a label above each completed HTF candle."
string TT_HTF_WICK = "Wicks are the vertical lines from the body to the HH (upper wick) and from the body to the LL (lower wick)."
string TT_PAIRS    = "When chart TF matches the LTF column, the corresponding HTF column is used. If chart TF doesn't match any LTF exactly, the closest pair (LTF ≤ chart TF) is used. Falls back to Manual HTF if no pair matches."

////////////////////////////////////////////////////////////////////////////////
//                            ====== INPUTS ======
////////////////////////////////////////////////////////////////////////////////

// -- Display HARSI Candles
string GROUP_CAND = "Display » HARSI Candles"
i_preset    = input.string("Raw (14/1)", "Candle Preset", options=["Raw (14/1)", "Smoothed (10/5)", "Custom"], group=GROUP_CAND, tooltip=TT_PRESET)
i_lenCust   = input.int(14,         "Custom Length",         group=GROUP_CAND, minval=1, tooltip=TT_HARSI)
i_smCust    = input.int(1,          "Custom Open Smoothing", group=GROUP_CAND, minval=1, maxval=100, tooltip=TT_PBIAS)
string INLINE_COL = "Colour Palette"
i_colUp     = input.color(color.teal,  "Colour Palette  ",  group=GROUP_CAND, inline=INLINE_COL)
i_colDown   = input.color(color.red,   " ",                 group=GROUP_CAND, inline=INLINE_COL)
i_colWick   = input.color(color.gray,  " ",                 group=GROUP_CAND, inline=INLINE_COL)
i_colBordUp = input.color(color.teal,  "Border Up / Down",  group=GROUP_CAND, inline="BORD")
i_colBordDn = input.color(color.red,   " ",                 group=GROUP_CAND, inline="BORD")

// -- RSI plot (display only)
string GROUP_PLOT = "Display » RSI Plot"
i_source    = input.source(ohlc4,   "Source",               group=GROUP_PLOT)
i_lenRSI    = input.int(7,          "Length",               group=GROUP_PLOT, minval=1)
i_mode      = input.bool(true,      "Smoothed Mode RSI?",   group=GROUP_PLOT, tooltip=TT_SMRSI)
i_showPlot  = input.bool(false,     "Show RSI Plot?",       group=GROUP_PLOT)
i_showHist  = input.bool(false,     "Show RSI Histogram?",  group=GROUP_PLOT)

// -- Channel OB/OS
string GROUP_CHAN = "Display » OB/OS Boundaries"
i_upper     = input.int(20,         "OB",                   group=GROUP_CHAN, inline="OB", minval=1, maxval=50)
i_upperx    = input.int(30,         "OB Extreme",           group=GROUP_CHAN, inline="OB", minval=1, maxval=50)
i_lower     = input.int(-20,        "OS",                   group=GROUP_CHAN, inline="OS", minval=-50, maxval=-1)
i_lowerx    = input.int(-30,        "OS Extreme",           group=GROUP_CHAN, inline="OS", minval=-50, maxval=-1)
i_colOB     = input.color(color.new(color.silver, 80),  "OB Line",         group=GROUP_CHAN, inline="LC1")
i_colOBX    = input.color(color.new(color.silver, 60),  "OB Extreme Line", group=GROUP_CHAN, inline="LC1")
i_colOS     = input.color(color.new(color.silver, 80),  "OS Line",         group=GROUP_CHAN, inline="LC2")
i_colOSX    = input.color(color.new(color.silver, 60),  "OS Extreme Line", group=GROUP_CHAN, inline="LC2")
i_colMed    = input.color(color.rgb(71, 67, 61),        "Median Line",     group=GROUP_CHAN)
i_fillOB    = input.color(color.new(color.red,   90),   "OB Fill",         group=GROUP_CHAN, inline="FC")
i_fillChan  = input.color(color.new(color.blue,  90),   "Channel Fill",    group=GROUP_CHAN, inline="FC")
i_fillOS    = input.color(color.new(color.green, 90),   "OS Fill",         group=GROUP_CHAN, inline="FC")

// -- WaveTrend
string GROUP_WT = "Signals » WaveTrend"
wtShow          = input.bool(true,  "Show WaveTrend Signals",   group=GROUP_WT)
wtBuyShow       = input.bool(true,  "Show Buy Signals",         group=GROUP_WT)
wtSellShow      = input.bool(true,  "Show Sell Signals",        group=GROUP_WT)
wtDivShow       = input.bool(true,  "Show Divergence Signals",  group=GROUP_WT)
wtChannelLen    = input.int(9,      "WT Channel Length",        group=GROUP_WT)
wtAverageLen    = input.int(12,     "WT Average Length",        group=GROUP_WT)
wtMALen         = input.int(3,      "WT MA Length",             group=GROUP_WT)
wtMASource      = input.source(hlc3,"WT Source",                group=GROUP_WT)

obLevel  = 53
osLevel  = -53

// -- Signal Gate RSI (dedicated)
string GROUP_GATE = "Signals » Gate RSI"
i_gateSrc   = input.source(ohlc4,   "Gate RSI Source",      group=GROUP_GATE, tooltip=TT_GATE)
i_gateLen   = input.int(7,          "Gate RSI Length",      group=GROUP_GATE, minval=1)
i_gateMode  = input.bool(true,      "Smoothed Gate RSI?",   group=GROUP_GATE)
i_gateLvl   = input.int(30,         "Gate Level (±)",       group=GROUP_GATE, minval=1, maxval=50)

// -- Divergences
string GROUP_DIV = "Signals » Divergences"
wtShowDiv       = input.bool(true,  "Show WT Divergences",          group=GROUP_DIV)
wtShowHiddenDiv = input.bool(false, "Show WT Hidden Divergences",   group=GROUP_DIV)
showHiddenDiv_nl= input.bool(true,  "Use No-Limit Hidden Divs",     group=GROUP_DIV)
wtDivOBLevel    = input.int(45,     "WT Div OB Level",              group=GROUP_DIV)
wtDivOSLevel    = input.int(-65,    "WT Div OS Level",              group=GROUP_DIV)
wtDivOBLevel_addshow = input.bool(true, "Show Extra Range Divs",    group=GROUP_DIV)
wtDivOBLevel_add= input.int(15,     "Extra OB Level",               group=GROUP_DIV)
wtDivOSLevel_add= input.int(-40,    "Extra OS Level",               group=GROUP_DIV)

// -- Signal dots
string GROUP_SIG = "Signals » Dots"
i_dotOffset = input.int(20, "Dot Offset from OB/OS", group=GROUP_SIG, minval=1, maxval=40, tooltip="How far beyond the OB/OS boundary the buy/sell triangles appear.")
i_buyCol    = input.color(#3fff00, "Buy Colour",  group=GROUP_SIG, inline="SC")
i_sellCol   = input.color(#ff0000, "Sell Colour", group=GROUP_SIG, inline="SC")

// -- Divergence Lines (dual-pane)
string GROUP_DIVLN = "Divergences » Lines"
divShow      = input.bool(true,  "Draw Divergence Lines",       group=GROUP_DIVLN, tooltip="Connects the two divergent WT pivots with a line. Uses the same WT divergence engine that gates the buy/sell dots (in-zone fractals), so lines and dots stay in agreement.")
divRegular   = input.bool(true,  "Regular Divergences",         group=GROUP_DIVLN)
divHidden    = input.bool(false, "Hidden Divergences (dashed)", group=GROUP_DIVLN)
divOnOsc     = input.bool(true,  "Show on Oscillator",          group=GROUP_DIVLN, tooltip="Draws the line across the HARSI candle highs (bearish) / lows (bullish) in this pane, so it stays in-scale and rides the visible candles.")
divOnChart   = input.bool(true,  "Show on Main Chart",          group=GROUP_DIVLN, tooltip="Draws the matching line on price via force_overlay, connecting the swing highs (bearish) / lows (bullish).")
divShowLabel = input.bool(true,  "Show Labels",                 group=GROUP_DIVLN, tooltip="+RD/-RD = regular divergence, +HD/-HD = hidden divergence.")
divBullCol   = input.color(color.rgb(21, 151, 25), "Bull / Bear Colour", group=GROUP_DIVLN, inline="DLC")
divBearCol   = input.color(color.rgb(212, 44, 44), "",                   group=GROUP_DIVLN, inline="DLC")
divWidth     = input.int(2, "Line Width", group=GROUP_DIVLN, minval=1, maxval=5)

// -- Structure (HH/LL) engine
string GROUP_STRUCT = "Structure » HH/LL Pivots"
i_showHHLL   = input.bool(true, "Show HH/LL Labels",   group=GROUP_STRUCT)
i_lenStruct  = input.int(14,    "Structure HARSI Length",   group=GROUP_STRUCT, minval=1, tooltip=TT_STRUCT)
i_smStruct   = input.int(1,     "Structure Open Smoothing", group=GROUP_STRUCT, minval=1, maxval=100)
lb           = input.int(5,     "Left Bars",  group=GROUP_STRUCT, minval=1, tooltip="Lower = faster signals, more noise.")
rb           = input.int(5,     "Right Bars", group=GROUP_STRUCT, minval=1, tooltip="Confirmation lag. HH/LL labels appear this many bars after the actual pivot.")

string GROUP_STYLE = "Structure » Label Style"
i_hhCol    = input.color(color.blue,  "HH Color",    group=GROUP_STYLE, inline="C1")
i_llCol    = input.color(color.red,   "LL Color",    group=GROUP_STYLE, inline="C1")
i_txtUp    = input.color(color.white, "HH Text",     group=GROUP_STYLE, inline="C2")
i_txtDn    = input.color(color.white, "LL Text",     group=GROUP_STYLE, inline="C2")
i_size     = input.string("tiny", "Label Size", options=["tiny","small","normal","large","huge"], group=GROUP_STYLE)
i_hhOffset = input.float(20.0, "HH Vertical Offset", group=GROUP_STYLE, step=0.5, tooltip="Raises (positive) or lowers (negative) the HH label relative to the structure HARSI high.")
i_llOffset = input.float(20.0, "LL Vertical Offset", group=GROUP_STYLE, step=0.5, tooltip="Lowers (positive) or raises (negative) the LL label relative to the structure HARSI low.")

// -- HTF HARSI Candle Boxes
string GROUP_HTF = "HTF » HARSI Candles"
htfShow         = input.bool(true,  "Show HTF HARSI Candles",   group=GROUP_HTF)
htfMode         = input.string("Auto", "HTF Mode", options=["Auto", "Manual"], group=GROUP_HTF, tooltip=TT_HTF_MODE)
htfManual       = input.timeframe('60', "Manual HTF",           group=GROUP_HTF, tooltip=TT_HTF_INT)

// Outline Box (HH→LL bounding rectangle)
htfBoxShow      = input.bool(false, "Outline Box (HH→LL)",      group=GROUP_HTF, inline='10')
htfBoxColor     = input.color(color.new(#9598a1, 50), '',       group=GROUP_HTF, inline='10')
htfBoxWidth     = input.int(1,      '',                         group=GROUP_HTF, inline='10', minval=0, display=display.none)
htfBoxDashed    = input.bool(false, '---',                      group=GROUP_HTF, inline='10')

// Body (Open→Close)
htfBodyShow     = input.bool(true,  "Body (Open→Close)",        group=GROUP_HTF, inline='11')
htfBodyColor    = input.color(color.new(#9598a1, 50), '',       group=GROUP_HTF, inline='11')
htfBodyWidth    = input.int(1,      '',                         group=GROUP_HTF, inline='11', minval=0, display=display.none)
htfBodyDashed   = input.bool(false, '---',                      group=GROUP_HTF, inline='11')

// Wicks
htfWickShow     = input.bool(true,  "Wicks",                    group=GROUP_HTF, inline='12', tooltip=TT_HTF_WICK)
htfWickColor    = input.color(color.new(#B266FF, 0), '',        group=GROUP_HTF, inline='12')
htfWickWidth    = input.int(5,      '',                         group=GROUP_HTF, inline='12', minval=1, display=display.none)
htfWickDashed   = input.bool(false, '---',                      group=GROUP_HTF, inline='12')

// Mid line
htfMidShow      = input.bool(false, "Mid Line",                 group=GROUP_HTF, inline='13')
htfMidColor     = input.color(color.new(#9598a1, 50), '',       group=GROUP_HTF, inline='13')
htfMidWidth     = input.int(1,      '',                         group=GROUP_HTF, inline='13', minval=0, display=display.none)
htfMidDashed    = input.bool(true,  '---',                      group=GROUP_HTF, inline='13')

// Body bg colors
htfBgLong       = input.color(color.new(#66bb6a, 80), "Long Boxes",  group=GROUP_HTF, inline='14')
htfBgShort      = input.color(color.new(#f7525f, 80), "Short Boxes", group=GROUP_HTF, inline='14')

// Range label
htfShowRange    = input.bool(false, "Show HTF Range Label",     group=GROUP_HTF, inline='15', tooltip=TT_HTF_RNG)
htfRangeColor   = input.color(color.silver, '',                 group=GROUP_HTF, inline='15')

// -- Shared HTF Auto-Pair Table
string GROUP_PAIRS = "HTF » Auto-Pair Table (shared)"
i_pairsEnabled = input.bool(true, "Use Pair Table (Auto Mode)", group=GROUP_PAIRS, tooltip=TT_PAIRS)
i_ltf1 = input.timeframe("1",   "Pair 1 LTF", group=GROUP_PAIRS, inline="P1")
i_htf1 = input.timeframe("15",  "→ HTF",      group=GROUP_PAIRS, inline="P1")
i_ltf2 = input.timeframe("3",   "Pair 2 LTF", group=GROUP_PAIRS, inline="P2")
i_htf2 = input.timeframe("30",  "→ HTF",      group=GROUP_PAIRS, inline="P2")
i_ltf3 = input.timeframe("5",   "Pair 3 LTF", group=GROUP_PAIRS, inline="P3")
i_htf3 = input.timeframe("60",  "→ HTF",      group=GROUP_PAIRS, inline="P3")
i_ltf4 = input.timeframe("15",  "Pair 4 LTF", group=GROUP_PAIRS, inline="P4")
i_htf4 = input.timeframe("240", "→ HTF",      group=GROUP_PAIRS, inline="P4")
i_ltf5 = input.timeframe("60",  "Pair 5 LTF", group=GROUP_PAIRS, inline="P5")
i_htf5 = input.timeframe("D",   "→ HTF",      group=GROUP_PAIRS, inline="P5")

////////////////////////////////////////////////////////////////////////////////
//                  ====== HTF RESOLUTION (shared) ======
////////////////////////////////////////////////////////////////////////////////

f_resolveHTF() =>
    string _htf = htfManual
    if htfMode == "Auto" and i_pairsEnabled
        float chartMin = timeframe.in_seconds(timeframe.period) / 60.0
        float ltf1m = timeframe.in_seconds(i_ltf1) / 60.0
        float ltf2m = timeframe.in_seconds(i_ltf2) / 60.0
        float ltf3m = timeframe.in_seconds(i_ltf3) / 60.0
        float ltf4m = timeframe.in_seconds(i_ltf4) / 60.0
        float ltf5m = timeframe.in_seconds(i_ltf5) / 60.0

        // Find the closest pair where LTF <= chart TF (use highest matching LTF)
        string _matched = na
        float  _bestLtf = -1.0

        if ltf1m <= chartMin and ltf1m > _bestLtf
            _matched := i_htf1
            _bestLtf := ltf1m
        if ltf2m <= chartMin and ltf2m > _bestLtf
            _matched := i_htf2
            _bestLtf := ltf2m
        if ltf3m <= chartMin and ltf3m > _bestLtf
            _matched := i_htf3
            _bestLtf := ltf3m
        if ltf4m <= chartMin and ltf4m > _bestLtf
            _matched := i_htf4
            _bestLtf := ltf4m
        if ltf5m <= chartMin and ltf5m > _bestLtf
            _matched := i_htf5
            _bestLtf := ltf5m

        // If chart TF is below all pair LTFs, use the smallest pair's HTF
        if na(_matched)
            float _minLtf = math.min(ltf1m, math.min(ltf2m, math.min(ltf3m, math.min(ltf4m, ltf5m))))
            if      ltf1m == _minLtf
                _matched := i_htf1
            else if ltf2m == _minLtf
                _matched := i_htf2
            else if ltf3m == _minLtf
                _matched := i_htf3
            else if ltf4m == _minLtf
                _matched := i_htf4
            else
                _matched := i_htf5

        _htf := _matched
    _htf

string htfInterval = f_resolveHTF()

// Safety: if resolved HTF is somehow <= chart TF, fall back to manual
float _htfSec   = timeframe.in_seconds(htfInterval)
float _chartSec = timeframe.in_seconds(timeframe.period)
if _htfSec <= _chartSec
    htfInterval := htfManual

////////////////////////////////////////////////////////////////////////////////
//                         ====== FUNCTIONS ======
////////////////////////////////////////////////////////////////////////////////

// Zero-median RSI (subtracts 50)
f_zrsi(_source, _length) =>
    ta.rsi(_source, _length) - 50

// Mode-selectable RSI (standard or smoothed)
f_rsi(_source, _length, _mode) =>
    float _zrsi     = f_zrsi(_source, _length)
    var float _smoothed = na
    _smoothed      := na(_smoothed[1]) ? _zrsi : (_smoothed[1] + _zrsi) / 2
    _mode ? _smoothed : _zrsi

// RSI Heikin-Ashi candle generation (parameterized smoothing so we can run
// independent Display and Structure engines)
f_rsiHeikinAshi(_length, _smooth) =>
    float _closeRSI     = f_zrsi(close, _length)
    float _openRSI      = nz(_closeRSI[1], _closeRSI)
    float _highRSI_raw  = f_zrsi(high, _length)
    float _lowRSI_raw   = f_zrsi(low, _length)
    float _highRSI      = math.max(_highRSI_raw, _lowRSI_raw)
    float _lowRSI       = math.min(_highRSI_raw, _lowRSI_raw)
    float _close        = (_openRSI + _highRSI + _lowRSI + _closeRSI) / 4
    var float _open     = na
    _open              := na(_open[_smooth]) ? (_openRSI + _closeRSI) / 2 :
                          ((_open[1] * _smooth) + _close[1]) / (_smooth + 1)
    float _high         = math.max(_highRSI, math.max(_open, _close))
    float _low          = math.min(_lowRSI,  math.min(_open, _close))
    [_open, _high, _low, _close]

// Divergence fractal helpers
f_top_fractal(src) =>
    src[4] < src[2] and src[3] < src[2] and src[2] > src[1] and src[2] > src[0]
f_bot_fractal(src) =>
    src[4] > src[2] and src[3] > src[2] and src[2] < src[1] and src[2] < src[0]
f_fractalize(src) =>
    f_top_fractal(src) ? 1 : f_bot_fractal(src) ? -1 : 0

f_findDivs(src, topLimit, botLimit, useLimits) =>
    float fractalTop = f_fractalize(src) > 0 and (useLimits ? src[2] >= topLimit : true) ? src[2] : na
    float fractalBot = f_fractalize(src) < 0 and (useLimits ? src[2] <= botLimit : true) ? src[2] : na
    bool  isTop      = not na(fractalTop)
    bool  isBot      = not na(fractalBot)
    highPrev    = ta.valuewhen(isTop, src[2], 0)[2]
    highPrice   = ta.valuewhen(isTop, high[2], 0)[2]
    lowPrev     = ta.valuewhen(isBot, src[2], 0)[2]
    lowPrice    = ta.valuewhen(isBot, low[2], 0)[2]
    bearSignal  = isTop and high[2] > highPrice and src[2] < highPrev
    bullSignal  = isBot and low[2] < lowPrice  and src[2] > lowPrev
    bearDivHidden = isTop and high[2] < highPrice and src[2] > highPrev
    bullDivHidden = isBot and low[2] > lowPrice  and src[2] < lowPrev
    [fractalTop, fractalBot, lowPrev, bearSignal, bullSignal, bearDivHidden, bullDivHidden]

// WaveTrend oscillator
f_wavetrend(src, chlen, avg, malen, tf) =>
    tfsrc   = request.security(syminfo.tickerid, tf, src)
    esa     = ta.ema(tfsrc, chlen)
    de      = ta.ema(math.abs(tfsrc - esa), chlen)
    ci      = (tfsrc - esa) / (0.015 * de)
    wt1     = request.security(syminfo.tickerid, tf, ta.ema(ci, avg))
    wt2     = request.security(syminfo.tickerid, tf, ta.sma(wt1, malen))
    wtOversold   = wt2 <= osLevel
    wtOverbought = wt2 >= obLevel
    wtCross      = ta.cross(wt1, wt2)
    wtCrossUp    = wt2 - wt1 <= 0
    wtCrossDown  = wt2 - wt1 >= 0
    [wt1, wt2, wtOversold, wtOverbought, wtCross, wtCrossUp, wtCrossDown]

////////////////////////////////////////////////////////////////////////////////
//                      ====== CALCULATIONS ======
////////////////////////////////////////////////////////////////////////////////

// Resolve display preset
int dispLen = i_preset == "Raw (14/1)" ? 14 : i_preset == "Smoothed (10/5)" ? 10 : i_lenCust
int dispSm  = i_preset == "Raw (14/1)" ? 1  : i_preset == "Smoothed (10/5)" ? 5  : i_smCust

// DISPLAY engine — HARSI candles + HTF boxes
[O, H, L, C] = f_rsiHeikinAshi(dispLen, dispSm)

// STRUCTURE engine — HH/LL pivots
[sO, sH, sL, sC] = f_rsiHeikinAshi(i_lenStruct, i_smStruct)

// Display RSI plot
float RSI = f_rsi(i_source, i_lenRSI, i_mode)

// Dedicated signal gate RSI
float gateRSI = f_rsi(i_gateSrc, i_gateLen, i_gateMode)

// WaveTrend
[wt1, wt2, wtOversold, wtOverbought, wtCross, wtCrossUp, wtCrossDown] =
  f_wavetrend(wtMASource, wtChannelLen, wtAverageLen, wtMALen, timeframe.period)

// WT Divergences
[wtFractalTop,     wtFractalBot,     wtLow_prev,     wtBearDiv,     wtBullDiv,     wtBearDivHidden,     wtBullDivHidden]     = f_findDivs(wt2, wtDivOBLevel,     wtDivOSLevel,     true)
[wtFractalTop_add, wtFractalBot_add, wtLow_prev_add, wtBearDiv_add, wtBullDiv_add, wtBearDivHidden_add, wtBullDivHidden_add] = f_findDivs(wt2, wtDivOBLevel_add,  wtDivOSLevel_add, true)
[wtFractalTop_nl,  wtFractalBot_nl,  wtLow_prev_nl,  wtBearDiv_nl,  wtBullDiv_nl,  wtBearDivHidden_nl,  wtBullDivHidden_nl]  = f_findDivs(wt2, 0,                 0,                false)

wtBearDivHidden_ = showHiddenDiv_nl ? wtBearDivHidden_nl : wtBearDivHidden
wtBullDivHidden_ = showHiddenDiv_nl ? wtBullDivHidden_nl : wtBullDivHidden

// Buy / Sell signals
buySignal    = wtCross and wtCrossUp   and wtOversold
sellSignal   = wtCross and wtCrossDown and wtOverbought

buySignalDiv  = (wtShowDiv and wtBullDiv) or (wtShowDiv and wtBullDiv_add)
sellSignalDiv = (wtShowDiv and wtBearDiv) or (wtShowDiv and wtBearDiv_add)

// Gate: dedicated RSI must have been beyond ±level on prior bar
crossdDown_prev = gateRSI[1] < -i_gateLvl
crossdUp_prev   = gateRSI[1] >  i_gateLvl

showBuyDotDiv  = crossdDown_prev and wtBuyShow  and buySignal[2]  and wtDivShow and buySignalDiv
showSellDotDiv = crossdUp_prev   and wtSellShow and sellSignal[2] and wtDivShow and sellSignalDiv
showBuyDot     = crossdDown_prev and wtBuyShow  and buySignal[2]
showSellDot    = crossdUp_prev   and wtSellShow and sellSignal[2]

buyDotY  = float(i_lower)  - i_dotOffset
sellDotY = float(i_upper)  + i_dotOffset

////////////////////////////////////////////////////////////////////////////////
//              ====== DIVERGENCE LINES (dual-pane) ======
////////////////////////////////////////////////////////////////////////////////
// Reuses the existing WT divergence engine (regular + hidden, in-zone fractals).
// Endpoints are captured at fractal-confirmation time so the oscillator line and
// the main-chart line share the exact same two swing points. Oscillator lines
// ride the HARSI candle high/low (in-scale); chart lines ride price high/low.

var int   dTopBar = na
var float dTopHa  = na   // HARSI candle high at the previous top fractal
var float dTopPx  = na   // price high at the previous top fractal
var int   dBotBar = na
var float dBotHa  = na   // HARSI candle low at the previous bottom fractal
var float dBotPx  = na   // price low at the previous bottom fractal

// --- Top fractal → bearish divergence ---
if divShow and not na(wtFractalTop)
    int   curBar   = bar_index - 2
    float curHa    = H[2]
    float curPx    = high[2]
    bool  drawBear = (divRegular and wtBearDiv) or (divHidden and wtBearDivHidden)
    if drawBear and not na(dTopBar)
        string lbl = wtBearDiv ? "-RD" : "-HD"
        string sty = wtBearDiv ? line.style_solid : line.style_dashed
        if divOnOsc
            line.new(dTopBar, dTopHa, curBar, curHa, xloc=xloc.bar_index, color=divBearCol, width=divWidth, style=sty)
            if divShowLabel
                label.new(curBar, curHa, lbl, xloc=xloc.bar_index, style=label.style_label_down, color=divBearCol, textcolor=color.white, size=size.tiny)
        if divOnChart
            line.new(dTopBar, dTopPx, curBar, curPx, xloc=xloc.bar_index, color=divBearCol, width=divWidth, style=sty, force_overlay=true)
            if divShowLabel
                label.new(curBar, curPx, lbl, xloc=xloc.bar_index, style=label.style_label_down, color=divBearCol, textcolor=color.white, size=size.tiny, force_overlay=true)
    dTopBar := curBar
    dTopHa  := curHa
    dTopPx  := curPx

// --- Bottom fractal → bullish divergence ---
if divShow and not na(wtFractalBot)
    int   curBar   = bar_index - 2
    float curHa    = L[2]
    float curPx    = low[2]
    bool  drawBull = (divRegular and wtBullDiv) or (divHidden and wtBullDivHidden)
    if drawBull and not na(dBotBar)
        string lbl = wtBullDiv ? "+RD" : "+HD"
        string sty = wtBullDiv ? line.style_solid : line.style_dashed
        if divOnOsc
            line.new(dBotBar, dBotHa, curBar, curHa, xloc=xloc.bar_index, color=divBullCol, width=divWidth, style=sty)
            if divShowLabel
                label.new(curBar, curHa, lbl, xloc=xloc.bar_index, style=label.style_label_up, color=divBullCol, textcolor=color.white, size=size.tiny)
        if divOnChart
            line.new(dBotBar, dBotPx, curBar, curPx, xloc=xloc.bar_index, color=divBullCol, width=divWidth, style=sty, force_overlay=true)
            if divShowLabel
                label.new(curBar, curPx, lbl, xloc=xloc.bar_index, style=label.style_label_up, color=divBullCol, textcolor=color.white, size=size.tiny, force_overlay=true)
    dBotBar := curBar
    dBotHa  := curHa
    dBotPx  := curPx

////////////////////////////////////////////////////////////////////////////////
//              ====== STRUCTURE: HH/LL PIVOT ENGINE ======
////////////////////////////////////////////////////////////////////////////////

ph = ta.pivothigh(sH, lb, rb)
pl = ta.pivotlow(sL,  lb, rb)

var int   hl_state = na
var float zz_val   = na

if not na(ph)
    hl_state := 1
    zz_val   := ph
else if not na(pl)
    hl_state := -1
    zz_val   := pl
else
    hl_state := na
    zz_val   := na

prevHL = ta.valuewhen(not na(hl_state[1]), hl_state[1], 0)
prevZZ = ta.valuewhen(not na(zz_val[1]),   zz_val[1],   0)

if not na(pl) and hl_state == -1 and prevHL == -1 and not na(prevZZ) and pl > prevZZ
    zz_val   := na
    hl_state := na
if not na(ph) and hl_state == 1 and prevHL == 1 and not na(prevZZ) and ph < prevZZ
    zz_val   := na
    hl_state := na

if hl_state == -1 and prevHL == 1 and not na(zz_val) and not na(prevZZ) and zz_val > prevZZ
    hl_state := na
    zz_val   := na
if hl_state == 1 and prevHL == -1 and not na(zz_val) and not na(prevZZ) and zz_val < prevZZ
    hl_state := na
    zz_val   := na

findprevious() =>
    int ehl = hl_state == 1 ? -1 : 1
    float loc1 = 0.0
    float loc2 = 0.0
    float loc3 = 0.0
    int xx = 0
    for x = 1 to 1000
        if hl_state[x] == ehl and not na(zz_val[x])
            loc1 := zz_val[x]
            xx := x + 1
            break
    ehl := hl_state
    for x = xx to 1000
        if hl_state[x] == ehl and not na(zz_val[x])
            loc2 := zz_val[x]
            xx := x + 1
            break
    ehl := hl_state == 1 ? -1 : 1
    for x = xx to 1000
        if hl_state[x] == ehl and not na(zz_val[x])
            loc3 := zz_val[x]
            break
    [loc1, loc2, loc3]

float a = na
float b = na
float c = na
float d = na
if not na(hl_state)
    [loc1, loc2, loc3] = findprevious()
    a := zz_val
    b := loc1
    c := loc2
    d := loc3

_hh = i_showHHLL and not na(zz_val) and hl_state ==  1 and (a > b and a > c and c > b and c > d)
_ll = i_showHHLL and not na(zz_val) and hl_state == -1 and (a < b and a < c and c < b and c < d)

float hhY = _hh ? sH + i_hhOffset : na
float llY = _ll ? sL - i_llOffset : na

////////////////////////////////////////////////////////////////////////////////
//              ====== HTF HARSI CANDLE BOXES (krollo-style) ======
////////////////////////////////////////////////////////////////////////////////

var float aggH      = na
var float aggL      = na
var float aggOpen   = na
var int   aggIdx    = na

bool htfChange = ta.change(time(htfInterval)) != 0

htfBarClose = barstate.islast ? C : C[1]
htfBarIdx   = barstate.islast ? bar_index : bar_index - 1
htfLong     = htfBarClose > aggOpen
htfBgColor  = htfLong ? htfBgLong : htfBgShort

htfBoxStyle  = htfBoxDashed  ? line.style_dashed : line.style_solid
htfBodyStyle = htfBodyDashed ? line.style_dashed : line.style_solid
htfWickStyle = htfWickDashed ? line.style_dashed : line.style_solid
htfMidStyle  = htfMidDashed  ? line.style_dashed : line.style_solid

var box  curBox      = na
var box  curBody     = na
var line curWickHi   = na
var line curWickLo   = na
var line curMid      = na
var label curLbl     = na

if htfChange and not na(aggOpen)
    bodyTop = math.max(aggOpen, C[1])
    bodyBot = math.min(aggOpen, C[1])
    midX    = math.round((aggIdx + htfBarIdx) / 2)

    if htfShow and htfBoxShow
        box.new(left=aggIdx, top=aggH, right=htfBarIdx, bottom=aggL,
             border_width=htfBoxWidth, border_style=htfBoxStyle, border_color=htfBoxColor,
             bgcolor=htfBodyShow ? na : htfBgColor)

    if htfShow and htfBodyShow
        if htfLong
            box.new(left=aggIdx, top=C[1], right=htfBarIdx, bottom=aggOpen,
                 border_width=htfBodyWidth, border_style=htfBodyStyle,
                 border_color=htfBodyColor, bgcolor=htfBgColor)
        else
            box.new(left=aggIdx, top=aggOpen, right=htfBarIdx, bottom=C[1],
                 border_width=htfBodyWidth, border_style=htfBodyStyle,
                 border_color=htfBodyColor, bgcolor=htfBgColor)

    if htfShow and htfWickShow
        if aggH > bodyTop
            line.new(midX, bodyTop, midX, aggH, xloc=xloc.bar_index,
                 color=htfWickColor, style=htfWickStyle, width=htfWickWidth)
        if aggL < bodyBot
            line.new(midX, bodyBot, midX, aggL, xloc=xloc.bar_index,
                 color=htfWickColor, style=htfWickStyle, width=htfWickWidth)

    if htfShow and htfMidShow
        mp = math.avg(aggH, aggL)
        line.new(aggIdx, mp, htfBarIdx, mp, xloc=xloc.bar_index,
             color=htfMidColor, style=htfMidStyle, width=htfMidWidth)

    if htfShow and htfShowRange
        rng = math.abs(aggH - aggL)
        label.new(midX, aggH + 2,
             str.tostring(rng, '#,##0.0#'),
             style=label.style_none, textcolor=htfRangeColor, textalign=text.align_center)

    // start fresh aggregate for this new HTF candle
    aggOpen := O
    aggIdx  := bar_index
    aggH    := H
    aggL    := L
else
    if na(aggOpen)
        aggOpen := O
        aggIdx  := bar_index
        aggH    := H
        aggL    := L
    else
        if H > aggH
            aggH := H
        if L < aggL
            aggL := L

// In-progress HTF candle (redrawn on the last bar so it grows live)
if barstate.islast and htfShow and not na(aggOpen)
    box.delete(curBox)
    box.delete(curBody)
    line.delete(curWickHi)
    line.delete(curWickLo)
    line.delete(curMid)
    label.delete(curLbl)

    bodyTopLive = math.max(aggOpen, C)
    bodyBotLive = math.min(aggOpen, C)
    midXLive    = math.round((aggIdx + bar_index) / 2)
    bgLive      = C > aggOpen ? htfBgLong : htfBgShort

    if htfBoxShow
        curBox := box.new(left=aggIdx, top=aggH, right=bar_index, bottom=aggL,
             border_width=htfBoxWidth, border_style=htfBoxStyle, border_color=htfBoxColor,
             bgcolor=htfBodyShow ? na : bgLive)

    if htfBodyShow
        if C > aggOpen
            curBody := box.new(left=aggIdx, top=C, right=bar_index, bottom=aggOpen,
                 border_width=htfBodyWidth, border_style=htfBodyStyle,
                 border_color=htfBodyColor, bgcolor=bgLive)
        else
            curBody := box.new(left=aggIdx, top=aggOpen, right=bar_index, bottom=C,
                 border_width=htfBodyWidth, border_style=htfBodyStyle,
                 border_color=htfBodyColor, bgcolor=bgLive)

    if htfWickShow
        if aggH > bodyTopLive
            curWickHi := line.new(midXLive, bodyTopLive, midXLive, aggH, xloc=xloc.bar_index,
                 color=htfWickColor, style=htfWickStyle, width=htfWickWidth)
        if aggL < bodyBotLive
            curWickLo := line.new(midXLive, bodyBotLive, midXLive, aggL, xloc=xloc.bar_index,
                 color=htfWickColor, style=htfWickStyle, width=htfWickWidth)

    if htfMidShow
        mp = math.avg(aggH, aggL)
        curMid := line.new(aggIdx, mp, bar_index, mp, xloc=xloc.bar_index,
             color=htfMidColor, style=htfMidStyle, width=htfMidWidth)

    if htfShowRange
        rng = math.abs(aggH - aggL)
        curLbl := label.new(midXLive, aggH + 2,
             str.tostring(rng, '#,##0.0#'),
             style=label.style_none, textcolor=htfRangeColor, textalign=text.align_center)

////////////////////////////////////////////////////////////////////////////////
//                    ====== COLORS (for plots) ======
////////////////////////////////////////////////////////////////////////////////

color bodyColour    = C > O ? i_colUp : i_colDown
color borderColour  = C > O ? i_colBordUp : i_colBordDn
color wickColour    = i_colWick
color colShadow     = color.rgb(0, 0, 0, 20)
color colRSI        = RSI < -31 ? color.new(#00e677, 70) : RSI > 31 ? color.new(#ff5252, 90) : color.white

////////////////////////////////////////////////////////////////////////////////
//                   ====== DRAWING and PLOTTING ======
////////////////////////////////////////////////////////////////////////////////

upperx = hline(i_upperx, "OB Extreme", i_colOBX)
upper  = hline(i_upper,  "OB",         i_colOB)
median = hline(0,        "Median",     i_colMed, hline.style_dashed)
lower  = hline(i_lower,  "OS",         i_colOS)
lowerx = hline(i_lowerx, "OS Extreme", i_colOSX)

// Full-width zone fills — boxes with extend.both so the bands run uniformly
// across the entire pane (past the last candle and into future space).
var box zoneOB   = na
var box zoneChan = na
var box zoneOS   = na
if barstate.isfirst
    zoneOB   := box.new(bar_index, i_upperx, bar_index + 1, i_upper,
         border_color=color(na), bgcolor=i_fillOB,   extend=extend.both, xloc=xloc.bar_index)
    zoneChan := box.new(bar_index, i_upper,  bar_index + 1, i_lower,
         border_color=color(na), bgcolor=i_fillChan, extend=extend.both, xloc=xloc.bar_index)
    zoneOS   := box.new(bar_index, i_lower,  bar_index + 1, i_lowerx,
         border_color=color(na), bgcolor=i_fillOS,   extend=extend.both, xloc=xloc.bar_index)

plot(i_showHist ? RSI : na, "RSI Histogram", color.new(color.silver, 80), 1, plot.style_histogram)

plotcandle(O, H, L, C, "HARSI", bodyColour, wickColour, bordercolor=borderColour)

plot(i_showPlot ? RSI : na, "RSI Shadow",  colShadow, 3)
plot_rsi = plot(i_showPlot ? RSI : na, "RSI Overlay", colRSI, 1)

// ── BUY / SELL signals — small unicode triangles ─────────────────────────────
plotchar(wtShow and showBuyDotDiv  ? buyDotY  : na,
  title="Buy Dot (Div+WT)", char="▲",
  color=color.new(i_buyCol, 0), location=location.absolute, size=size.tiny)

plotchar(wtShow and showSellDotDiv ? sellDotY : na,
  title="Sell Dot (Div+WT)", char="▼",
  color=color.new(i_sellCol, 0), location=location.absolute, size=size.tiny)

plotchar(wtShow and showBuyDot  and not showBuyDotDiv  ? buyDotY  : na,
  title="Buy Dot (WT only)", char="▲",
  color=color.new(i_buyCol, 60), location=location.absolute, size=size.tiny)

plotchar(wtShow and showSellDot and not showSellDotDiv ? sellDotY : na,
  title="Sell Dot (WT only)", char="▼",
  color=color.new(i_sellCol, 60), location=location.absolute, size=size.tiny)

// ── HH/LL structure labels (one plotshape per size — size must be const) ────
plotshape(i_size == "tiny"   and _hh ? hhY : na, title="HH (tiny)",   text="HH", style=shape.labeldown, color=i_hhCol, textcolor=i_txtUp, location=location.absolute, offset=-rb, size=size.tiny)
plotshape(i_size == "small"  and _hh ? hhY : na, title="HH (small)",  text="HH", style=shape.labeldown, color=i_hhCol, textcolor=i_txtUp, location=location.absolute, offset=-rb, size=size.small)
plotshape(i_size == "normal" and _hh ? hhY : na, title="HH (normal)", text="HH", style=shape.labeldown, color=i_hhCol, textcolor=i_txtUp, location=location.absolute, offset=-rb, size=size.normal)
plotshape(i_size == "large"  and _hh ? hhY : na, title="HH (large)",  text="HH", style=shape.labeldown, color=i_hhCol, textcolor=i_txtUp, location=location.absolute, offset=-rb, size=size.large)
plotshape(i_size == "huge"   and _hh ? hhY : na, title="HH (huge)",   text="HH", style=shape.labeldown, color=i_hhCol, textcolor=i_txtUp, location=location.absolute, offset=-rb, size=size.huge)

plotshape(i_size == "tiny"   and _ll ? llY : na, title="LL (tiny)",   text="LL", style=shape.labelup, color=i_llCol, textcolor=i_txtDn, location=location.absolute, offset=-rb, size=size.tiny)
plotshape(i_size == "small"  and _ll ? llY : na, title="LL (small)",  text="LL", style=shape.labelup, color=i_llCol, textcolor=i_txtDn, location=location.absolute, offset=-rb, size=size.small)
plotshape(i_size == "normal" and _ll ? llY : na, title="LL (normal)", text="LL", style=shape.labelup, color=i_llCol, textcolor=i_txtDn, location=location.absolute, offset=-rb, size=size.normal)
plotshape(i_size == "large"  and _ll ? llY : na, title="LL (large)",  text="LL", style=shape.labelup, color=i_llCol, textcolor=i_txtDn, location=location.absolute, offset=-rb, size=size.large)
plotshape(i_size == "huge"   and _ll ? llY : na, title="LL (huge)",   text="LL", style=shape.labelup, color=i_llCol, textcolor=i_txtDn, location=location.absolute, offset=-rb, size=size.huge)

/////////////////////////////////////////////////////////////////////////////////
//                          ====== ALERTS ======
/////////////////////////////////////////////////////////////////////////////////

alertcondition(showBuyDotDiv or showSellDotDiv,
  title="Buy/Sell Signal (Divergence + WT)",
  message="Buy/Sell Div+WT Signal {{exchange}}:{{ticker}}")

alertcondition(showBuyDot or showSellDot,
  title="Buy/Sell Signal (WT Cross)",
  message="Buy/Sell WT Signal {{exchange}}:{{ticker}}")

alertcondition(_hh, title="HARSI Higher High", message="HARSI HH printed on {{exchange}}:{{ticker}} {{interval}}")
alertcondition(_ll, title="HARSI Lower Low",   message="HARSI LL printed on {{exchange}}:{{ticker}} {{interval}}")

// Divergence-line alerts (fire on the fractal-confirmation bar, matching the drawn line)
divBearFired = divShow and not na(wtFractalTop) and not na(dTopBar) and ((divRegular and wtBearDiv) or (divHidden and wtBearDivHidden))
divBullFired = divShow and not na(wtFractalBot) and not na(dBotBar) and ((divRegular and wtBullDiv) or (divHidden and wtBullDivHidden))
alertcondition(divBearFired, title="Bearish Divergence Line", message="HARSI bearish divergence on {{exchange}}:{{ticker}} {{interval}}")
alertcondition(divBullFired, title="Bullish Divergence Line", message="HARSI bullish divergence on {{exchange}}:{{ticker}} {{interval}}")
````
