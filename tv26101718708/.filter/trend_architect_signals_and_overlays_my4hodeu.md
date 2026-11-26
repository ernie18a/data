# Trend Architect [Signals and Overlays]

- url: https://www.tradingview.com/script/MY4hoDEU-Trend-Architect-Signals-and-Overlays/
- type: indicator
- pine_id: PUB;a66a9fa93bf747e6baa56a57e0091329
- version: 2.0

## Description

[b]TREND ARCHITECT v9[/b]
Trend Architect is a multi-layer overlay and signals indicator built for active traders — scalpers, day traders, and prop traders working on fast timeframes like the 1-minute and 2-minute charts on instruments like MGC, MNQ, or currency pairs. It combines trend identification, volatility bands, momentum filtering, and a signal engine into a single, cohesive all-in-one tool.

The design goal is straightforward: give you a clear read on trend direction and market structure at a glance, and surface buy and sell signals only when multiple independent filters agree.

Everything is controlled through a [b]Simple / Advanced[/b] mode selector. Simple mode gives you clean on/off toggles and runs on carefully tuned defaults. Advanced mode opens every parameter for fine-tuning. Most traders will get full value from Simple mode.

[b]━━━ THEMES & CUSTOMIZATION ━━━[/b]
Trend Architect comes with [b]32 color themes[/b] — 16 for dark chart backgrounds, 16 for light. Every visual element updates together: the cloud, channel bands, candle colors, signal labels, and the info panel.
[image]https://www.tradingview.com/x/vQNboHo0/[/image]

[b]━━━ THE FIVE TOOLS ━━━[/b]

[b]── Trend Cloud ──[/b]
[image]https://www.tradingview.com/x/YxPbFhJy/[/image]
The Trend Cloud is the backbone of the indicator. The base line represents the primary core trend at the longest scale. The shaded fill above it reflects trend spread and strength — a wider, more opaque fill means stronger agreement across timeframes.

The base line glows in your bullish or bearish theme color depending on slope direction. At a glance: if the cloud is wide and the base is rising, the market is trending. If base is narrowing, trend is weakening and if the base is flat markets are ranging.

[b]── Super Channel ──[/b]
[image]https://www.tradingview.com/x/grjB5rZN/[/image]
The Super Channel draws dynamic upper and lower volatility bands around price. It blends three volatility measures — a Keltner Channel, Bollinger Bands, and an internal consensus oscillator — to produce bands that adapt to both volatility and momentum conditions.
When the consensus oscillator reaches overbought or oversold levels, the relevant band highlights in your theme's accent color. This is a useful heads-up that price is extended and conditions may be ripe for a reversal or pause.

[b]── Moving Average Ribbon ──[/b]
[image]https://www.tradingview.com/x/W2ftuBex/[/image]
Two smooth moving average lines with a colored fill between them. When the fast line is above the slow line, the fill is bullish. When reversed, bearish. It's a short-term momentum read. Many use the crossover as signal confirmation.

[b]── Custom Candles ──[/b]
Trend Architect draws its own candles, replacing the chart's native candlesticks. The default type is [b]R-Squared Adaptive Linear Regression[/b]: during trending conditions, candles blend toward a linear regression; during choppy conditions, they stay close to real price. The result is a smoother visual without the price displacement of standard Heikin Ashi.

Four other candle types are available: Regular Candlesticks, Custom Heikin Ashi, Custom LinReg Heikin Ashi, and Standard LinReg Candles.

When buying or selling pressure is unusually one-sided — measured by volume delta — the candle body dims and the border highlights in your theme's accent color. This is the [b]Delta Border Highlight[/b]: a quick flag that a bar had real conviction behind it.

[b]── PRISM Signals ──[/b]
[image]https://www.tradingview.com/x/ZmUDXQOG/[/image]
PRISM is the signal engine. It continuously analyzes price structure and momentum, and provides a [b]B[/b] (buy) or [b]S[/b] (sell) label when a directional shift is detected and several independent filters agree that conditions are good enough to act on.

Every raw signal candidate passes through four filters before a label appears:
[list]
[*][b]Structure Lock[/b] — If short-term momentum is pushing against the signal direction at the moment it triggers, the signal is held to get confirmation. If confirmation doesn't come, the signal is cancelled. This reduces entries during choppy reversals where the signal fires a little early.
[*][b]Bar Quality[/b] — The signal waits for a candle that closed convincingly in the signal direction. An indecisive bar — small body, lots of wick — causes the signal to hold for a cleaner close. If a clean bar doesn't appear in time, the signal is fully cancelled.
[*][b]Quality Gate[/b] — When market conditions are weak — low directional efficiency, flat momentum — the signal is downgraded to a small dot rather than a full B/S label. A dot means the setup was detected but conditions aren't ideal. Dots can still upgrade to full signals if other strong conditions are met simultaneously.
[*][b]Trend Regime Gate[/b] — When the market is clearly trending in one direction, signals triggered against that trend are suppressed and downgraded to dots rather than dropped entirely. A bull regime suppresses counter-trend sells; a bear regime suppresses counter-trend buys. The current regime state is always visible in the info panel.
[/list]

[b]── Boundary Forecast ──[/b]
The Boundary Forecast projects the Trend Cloud and Super Channel bands a few bars into the future. Two modes are available: [b]Regression[/b] fits a curve to recent band movement and can show potential turns ahead; [b]Slope Extension[/b] simply continues the current direction in a straight line.
The lines fade the further out they go to reflect decreasing confidence. Useful for anticipating where the next structural level is likely to be, not for precise entries.

[b]━━━ AUTO-OPTIMIZER ━━━[/b]
The Auto-Optimizer runs three parallel versions of the PRISM signal engine at different lookback lengths (short, mid, long — spaced by a configurable percentage around the base length). Each version tracks its own signal history and scores every signal based on how far price moved favorably within a set number of bars, in ATR tiers.

The optimizer continuously weights the three lengths by recent performance and blends them into a single effective lookback that is applied to the main signal engine.

[b]━━━ INFO PANEL ━━━[/b]
The info panel is a live dashboard showing current conditions across four sections: Trend State, Momentum & Quality, Trend Regime, and PRISM Signals / Auto-Optimizer.

Position it anywhere on the chart using the [b]Info Panel Location[/b] dropdown.

[b]TREND ARCHITECT — QUICK START GUIDE[/b]

[b]━━━ ADDING THE INDICATOR ━━━[/b]
[list]
[*] Open TradingView and navigate to your chart.
[*] Open the Indicators panel (top toolbar or / shortcut).
[*] Search for Trend Architect under your favorited scripts and add it to your chart.
[/list]

[b]━━━ HIDE YOUR DEFAULT CANDLES ━━━[/b]
Trend Architect draws its own custom candles, so you'll want to hide the chart's native candlesticks to avoid visual clutter.

[b]On the chart:[/b]
[list]
[*] Right-click anywhere on the chart → [b]Settings[/b] → go to the [b]Symbol[/b] tab.
[*] Uncheck [b]Body[/b], [b]Borders[/b], and [b]Wick[/b] (all three), then click OK.
[/list]
Your chart background will now be clean and the indicator's candles will be the only ones visible.

[b]━━━ SETTINGS MODE: SIMPLE vs. ADVANCED ━━━[/b]
The very first setting at the top of the indicator controls are unlocked.

[list]
[*] [b]Simple[/b] — Unlocks only the main on/off toggles and visual components. Everything runs on tuned defaults. [i]Start here.[/i]
[*] [b]Advanced[/b] — Opens up every parameter: lookback windows, thresholds, filter toggles, etc. Use this once you're comfortable and want to fine-tune.
[/list]
You can switch between modes at any time without losing your settings.

[b]━━━ CHOOSING A THEME ━━━[/b]
Under [b]Visual Components[/b] in the settings panel:
[list]
[*] [b]Chart Background[/b] — Select whether you're using a dark or light chart background. This determines which theme palette is active.
[*] [b]Dark Theme / Light Theme[/b] — Pick from 16 themes in each category. The theme colors everything: candles, cloud, channel bands, signals, and the info panel.
[/list]


[b]━━━ INFO PANEL ━━━[/b]
Toggle [b]Enable Info Panel[/b] in Visual Components to show a live dashboard with:
[list]
[*] Trend state across multiple timeframes (immediate, short, medium, long term)
[*] Momentum, delta strength, volatility range
[*] Trend Regime Gate status (bull/bear regime active or not)
[*] PRISM Adaptive mode and effective parameter values
[/list]
You can reposition it via the [b]Info Panel Location[/b] dropdown.

[b]━━━ TIPS FOR GETTING STARTED ━━━[/b]

[list]
[*] [b]Start in Simple mode[/b] with all tools enabled. Get a feel for the visual layers before changing anything.
[*] If the chart feels busy, try toggling off the Trend Cloud body or the Boundary Forecast first.
[*] The [b]Signal Offset[/b] setting (under Visual Components) controls how far B/S labels sit from the candles — adjust if they overlap.
[*] If you're on a fast timeframe (1m or below), PRISM Adaptive automatically extends lookback windows to compensate for noise. The info panel shows the effective values.
[/list]

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Trend Architect v9.1
// An indicator by
// ######:   . ####:     :##:    ######:  
// #######   #######:     ##     #######  
// ##   :##  #:.   ##    ####    ##   :## 
// ##    ##        ##    ####    ##    ## 
// ##   :##        ##   :#  #:   ##   :## 
// #######.    #####     #::#    #######: 
// #######.    #####.   ##  ##   ######   
// ##   :##        ##   ######   ##   ##. 
// ##    ##        ##  .######.  ##   ##  
// ##   :##  #:    ##  :##  ##:  ##   :## 
// ########  #######:  ###  ###  ##    ##:
// ######    :#####:   ##:  :##  ##    ##: 
indicator('Trend Architect', shorttitle='TA', overlay=true, max_bars_back=500, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 0 │ MODE
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_MODE = '━━━  SETTINGS MODE  ━━━'

sim_mode = input.string(
     'Simple', 'Settings Mode',
     options = ['Simple', 'Advanced'],
     group   = GRP_MODE,
     tooltip = 'Simple: Provides access to only the essential on/off controls and visual components. The indicator runs on carefully tuned defaults — great for most traders.\n\nAdvanced: reveals every parameter so you can fine-tune exactly how the tool behaves.')

bool IS_SIMPLE = sim_mode == 'Simple'

var string GRP_MAIN_TOOLS = '━━━  MAIN TOOLS  ━━━'

sim_cma_enable      = input.bool(true,  'Enable Moving Average Ribbon',   group = GRP_MAIN_TOOLS)
sim_sc_enable       = input.bool(true,  'Enable Super Channel',            group = GRP_MAIN_TOOLS)
sim_alt_enable      = input.bool(true,  'Enable Indicator Candles',        group = GRP_MAIN_TOOLS)
sim_tc_enable       = input.bool(true,  'Enable Trend Cloud',              group = GRP_MAIN_TOOLS)
sim_prism_enable    = input.bool(true,  'Enable PRISM Signals',            group = GRP_MAIN_TOOLS)
sim_forecast_enable = input.bool(true,  'Enable Boundary Forecast',        group = GRP_MAIN_TOOLS)
sim_trg_enable      = input.bool(true,  'Enable Trend Regime Gate',        group = GRP_MAIN_TOOLS)
sim_ao_enable         = input.bool(true,  'Enable Auto-Optimizer',    group = GRP_MAIN_TOOLS)
sim_candle_col_enable = input.bool(false, 'Enable Candle Coloring',   group = GRP_MAIN_TOOLS)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 │ VISUAL COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_VISUAL = '━━━  VISUAL COMPONENTS  ━━━'

bg_mode = input.string(
     'Dark Background', 'Chart Background',
     options = ['Dark Background', 'Light Background'],
     group   = GRP_VISUAL,
     tooltip = "Match this to your chart's background color. Choose 'Dark Background' for dark charts, 'Light Background' for white or light-colored charts. This ensures all indicator colors are readable and look their best.")

dark_theme = input.string(
     'Modern', 'Dark Theme',
     options = ['Modern', 'Terminal', 'Cyberpunk', 'Neon Noir', 'Phosphor', 'Fire & Ice', 'Slate',
                'Blood & Greed', 'Gold Standard', 'Ultraviolet', 'Infrared', 'Toxic',
                'Crimson Tide', 'Vaporwave', 'Matrix', 'Arctic'],
     group   = GRP_VISUAL,
     tooltip = 'Choose the color style for the whole indicator. All colors — trend lines, candles, buy/sell signals, and the info panel — update together. Pick whatever best to you. Only enable if Dark Background is selected.')

light_theme = input.string(
     'Classic', 'Light Theme',
     options = ['Classic', 'Woodland', 'Solar', 'Twilight', 'Parchment', 'Shoreline', 'Graphite',
                'Harvest', 'Guilded', 'Amethyst', 'Forge', 'Briar', 'Scarlet', 'Dusk', 'Fern', 'Nordic'],
     group   = GRP_VISUAL,
     tooltip = 'Choose the color style for the whole indicator. All colors — trend lines, candles, buy/sell signals, and the info panel — update together. Pick whatever looks best to you. Only enable if Light Background is selected.')

string colorTheme = bg_mode == 'Light Background' ? light_theme : dark_theme

info_enable = input.bool(true, 'Enable Info Panel', group = GRP_VISUAL,
tooltip = 'Toggles the small data table that appears on the chart. The panel shows a plain-English summary of current trend direction, momentum, and market conditions. Turn it off if you prefer a cleaner chart.')
info_location = input.string(
     'Middle Right', 'Info Panel Location',
     options = ['Top Left', 'Middle Left', 'Bottom Left', 'Middle Right', 'Bottom Right'],
     group   = GRP_VISUAL,
     tooltip = 'Moves the info panel to a different corner or side of the chart. Use this if the panel is covering price action or other indicators.')

prism_sig_offset = input.float(0.9, 'Signal Offset (ATR)', minval = 0.0, maxval = 2.0, step = 0.1, group = GRP_VISUAL,
tooltip = "Controls how far the 'B' (buy) and 'S' (sell) labels are placed from the candle. A higher number moves them further away, which keeps them from overlapping wicks. A lower number tucks them closer. The distance adjusts automatically with market volatility.")

// ── Glow Effects ──────────────────────────────────────────────────────────────
glow_tc_enable  = input.bool(true, 'Trend Cloud Base Glow',     group = GRP_VISUAL,
     tooltip = 'Wraps the main Trend Cloud line in a soft colored glow, making it easier to spot at a glance. The color matches the current trend direction. Turn it off if you prefer a cleaner look.')

string _info_pos = switch info_location
    'Top Left'     => position.top_left
    'Middle Left'  => position.middle_left
    'Bottom Left'  => position.bottom_left
    'Middle Right' => position.middle_right
    =>                position.bottom_right

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 │ THEME PROFILE
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_THEME = '━━━  THEME PROFILE  ━━━'

f_theme() =>
    var color bull = na, var color bear = na, var color neutral = na
    var color hilight = na, var color sig_bull = na, var color sig_bear = na
    var color sig_text = na
    switch colorTheme
        // ── Dark Themes ──────────────────────────────────────────────────────
        'Modern'        => bull := #00FFFF, bear := #FF0000, neutral := #888888, hilight := #FFFFFF, sig_bull := #FFD700, sig_bear := #FFFFFF,  sig_text := #000000
        'Terminal'      => bull := #00FF00, bear := #FF6000, neutral := #707070, hilight := #FFFFFF, sig_bull := #FFFFFF, sig_bear := #FF5500,  sig_text := #000000
        'Cyberpunk'     => bull := #00FFFF, bear := #FF00FF, neutral := #9932CC, hilight := #FFFF00, sig_bull := #FFFF00, sig_bear := #FF00CC,  sig_text := #000000
        'Neon Noir'     => bull := #FF1DDF, bear := #00C8FF, neutral := #6A0DAD, hilight := #FFFF00, sig_bull := #FFFF00, sig_bear := #FF6EC7,  sig_text := #000000
        'Phosphor'      => bull := #FFB000, bear := #CC2200, neutral := #7A5000, hilight := #FFFFFF, sig_bull := #FFFFFF, sig_bear := #FF6600,  sig_text := #000000
        'Fire & Ice'    => bull := #C8F0FF, bear := #FF4500, neutral := #6699AA, hilight := #FFD700, sig_bull := #FFD700, sig_bear := #FF6347,  sig_text := #000000
        'Slate'         => bull := #00CED1, bear := #E8735A, neutral := #708090, hilight := #F5F5DC, sig_bull := #F5DEB3, sig_bear := #DC143C,  sig_text := #000000
        'Blood & Greed' => bull := #00FF41, bear := #CC0000, neutral := #555555, hilight := #FFD700, sig_bull := #FFD700, sig_bear := #FF6600,  sig_text := #000000
        'Gold Standard' => bull := #FFD700, bear := #B0B0B0, neutral := #CD7F32, hilight := #FFFFFF, sig_bull := #1E90FF, sig_bear := #FF1111,  sig_text := #000000
        'Ultraviolet'   => bull := #BF00FF, bear := #6600AA, neutral := #5C0080, hilight := #00FF00, sig_bull := #00FF00, sig_bear := #FF1493,  sig_text := #000000
        'Infrared'      => bull := #FFFFFF, bear := #CC0000, neutral := #882200, hilight := #FF6600, sig_bull := #FF6600, sig_bear := #FF2222,  sig_text := #000000
        'Toxic'         => bull := #CCFF00, bear := #33AA00, neutral := #1A5500, hilight := #FFFFFF, sig_bull := #FFFFFF, sig_bear := #00FF66,  sig_text := #000000
        'Crimson Tide'  => bull := #FF2222, bear := #C0C0C0, neutral := #808080, hilight := #FFD700, sig_bull := #FF8800, sig_bear := #FF66FF,  sig_text := #000000
        'Vaporwave'     => bull := #FF6B9D, bear := #9B30FF, neutral := #6622AA, hilight := #00FFFF, sig_bull := #00FFFF, sig_bear := #FF00FF,  sig_text := #000000
        'Matrix'        => bull := #00FF41, bear := #007A1F, neutral := #003D0F, hilight := #FFFFFF, sig_bull := #AAFFBB, sig_bear := #FFFFFF,  sig_text := #000000
        'Arctic'        => bull := #A8D8FF, bear := #4488CC, neutral := #3A5A8A, hilight := #F0F8FF, sig_bull := #F0F8FF, sig_bear := #00BFFF,  sig_text := #000000
        // ── Light Themes ─────────────────────────────────────────────────────
        'Classic'       => bull := #2B58BF, bear := #D42020, neutral := #707070, hilight := #2A2A2A, sig_bull := #0F8C50, sig_bear := #A04810,  sig_text := #FFFFFF
        'Woodland'      => bull := #2E8A2E, bear := #991515, neutral := #7A5A35, hilight := #3E2010, sig_bull := #1080A0, sig_bear := #8A208A,  sig_text := #FFFFFF
        'Solar'         => bull := #009999, bear := #AA20AA, neutral := #7A55A0, hilight := #A07515, sig_bull := #A07515, sig_bear := #108870,  sig_text := #FFFFFF
        'Twilight'      => bull := #AA1570, bear := #1060AA, neutral := #6A3590, hilight := #807010, sig_bull := #807010, sig_bear := #8A1050,  sig_text := #FFFFFF
        'Parchment'     => bull := #A06015, bear := #A03515, neutral := #7A5515, hilight := #3A2010, sig_bull := #3A2010, sig_bear := #A04F15,  sig_text := #FFFFFF
        'Shoreline'     => bull := #106595, bear := #A04515, neutral := #406578, hilight := #807010, sig_bull := #807010, sig_bear := #8A3515,  sig_text := #FFFFFF
        'Graphite'      => bull := #109595, bear := #A05540, neutral := #5A7080, hilight := #2A2A2A, sig_bull := #6A5515, sig_bear := #AA2020,  sig_text := #FFFFFF
        'Harvest'       => bull := #409915, bear := #991818, neutral := #505050, hilight := #807010, sig_bull := #807010, sig_bear := #906515,  sig_text := #FFFFFF
        'Guilded'       => bull := #A08015, bear := #585858, neutral := #7A6A30, hilight := #151560, sig_bull := #2060CC, sig_bear := #AA2020,  sig_text := #FFFFFF
        'Amethyst'      => bull := #7020BB, bear := #4A1599, neutral := #451568, hilight := #108A10, sig_bull := #108A10, sig_bear := #AA2080,  sig_text := #FFFFFF
        'Forge'         => bull := #484848, bear := #BB2020, neutral := #7A3A15, hilight := #A05015, sig_bull := #A05015, sig_bear := #CC2525,  sig_text := #FFFFFF
        'Briar'         => bull := #6A9515, bear := #2D8820, neutral := #304A10, hilight := #2A2A2A, sig_bull := #2A2A2A, sig_bear := #108855,  sig_text := #FFFFFF
        'Scarlet'       => bull := #BB2525, bear := #585858, neutral := #707070, hilight := #807010, sig_bull := #A06015, sig_bear := #8A208A,  sig_text := #FFFFFF
        'Dusk'          => bull := #AA3570, bear := #5A30BB, neutral := #5A2590, hilight := #109090, sig_bull := #109090, sig_bear := #992099,  sig_text := #FFFFFF
        'Fern'          => bull := #2D9915, bear := #106625, neutral := #1A4A10, hilight := #2A2A2A, sig_bull := #408A50, sig_bear := #2A2A2A,  sig_text := #FFFFFF
        'Nordic'        => bull := #2E60A0, bear := #2E5099, neutral := #406080, hilight := #1A3060, sig_bull := #1A3060, sig_bear := #1080BB,  sig_text := #FFFFFF
    [bull, bear, neutral, hilight, sig_bull, sig_bear, sig_text]

[BULL, BEAR, NEUT, HILIGHT, SIG_BULL, SIG_BEAR, SIG_TEXT] = f_theme()


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 │ MOVING AVERAGE RIBBON
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_CMA = '━━━  MOVING AVERAGE RIBBON  ━━━'

cma_enable  = input.bool(true,  'Enable Moving Average Ribbon', group = GRP_CMA,
     tooltip = 'Turns the moving average ribbon on or off. The ribbon is two smoothed lines — when they cross, it signals a short-term momentum change. The fill between them changes color with the direction.')
cma_length  = input.int(20,     'Length', minval = 1, group = GRP_CMA,
     tooltip = 'Sets how responsive the ribbon is. A lower number makes the ribbon react quickly to price moves (useful on fast charts but noisier). A higher number makes it smoother and slower to turn — better for filtering out small wiggles.')
cma_bicolor = input.bool(false, 'Bi-Color Ribbon Lines', group = GRP_CMA)

cma_dir_color = input.bool(true, 'Dynamic Direction Color', group = GRP_CMA,
     tooltip = 'Makes the ribbon change color based on trend direction. When price is moving up, both lines and the fill show your bullish color. When moving down, they switch to bearish. Makes it easy to spot ribbon direction at a glance.')
cma1 = ta.alma(close, cma_length, 0.85, 6.0)
cma2 = ta.alma(close, cma_length, 0.77, 6.0)

cma_fill_color = cma_dir_color
     ? (cma1 > cma2 ? color.new(BULL, 80) : color.new(BEAR, 80))
     : (cma1 > cma2 ? color.new(BULL, 80) : color.new(BEAR, 80))

color _cma_dir_col  = cma1 > cma2 ? color.new(BULL, 0) : color.new(BEAR, 0)
color cma_line1_col = cma_dir_color ? _cma_dir_col : color.new(BULL, 0)
color cma_line2_col = cma_dir_color ? _cma_dir_col : cma_bicolor ? color.new(BEAR, 0) : color.new(BULL, 0)

float ATR14 = ta.atr(14)


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 │ SUPER CHANNEL
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_SC = '━━━  SUPER CHANNEL  ━━━'

sc_enable = input.bool(true, 'Enable Super Channel', group = GRP_SC)

float SC_KELTNER_RATIO = 0.40
float SC_BB_RATIO      = 0.10
float SC_CCO_RATIO     = 1.0 - SC_KELTNER_RATIO - SC_BB_RATIO
float SC_ATR_DIST      = 6.0
float SC_CCO_LO        = 15.0
float SC_CCO_HI        = 85.0
int   SC_SMOOTHING     = 5
int   SC_MFI_LEN       = 14
int   SC_CCI_LEN       = 20
int   SC_PCTRANK_LB    = 100
int   SC_CONSENSUS_SMO = 3
int   SC_KC_EMA_LEN    = 20
int   SC_KC_ATR_LEN    = 10
float SC_KC_MULT       = 2.0
int   SC_BB_LEN        = 20
float SC_BB_MULT       = 2.0
float SC_HI_THRESH     = 75.0
float SC_LO_THRESH     = 25.0

float _srsi_rsi = ta.rsi(close, 14)
float _srsi_raw = ta.stoch(_srsi_rsi, _srsi_rsi, _srsi_rsi, 14)
float SRSI_K    = ta.sma(_srsi_raw, 3)

sc_mfi    = ta.mfi(hlc3, SC_MFI_LEN)
sc_cci_pc = ta.percentrank(ta.cci(close, SC_CCI_LEN), SC_PCTRANK_LB)

sc_raw_cco = (SRSI_K * 0.8 + sc_mfi * 0.9 + sc_cci_pc * 1.2) / (0.8 + 0.9 + 1.2)
sc_cco     = ta.sma(sc_raw_cco, SC_CONSENSUS_SMO)

sc_norm_cco = math.max(0.0, math.min(1.0, (sc_cco - SC_CCO_LO) / (SC_CCO_HI - SC_CCO_LO)))
sc_top_cco  = ta.sma(hlc3 + SC_ATR_DIST * (1.0 - sc_norm_cco) * ATR14, SC_SMOOTHING)
sc_bot_cco  = ta.sma(hlc3 - SC_ATR_DIST * sc_norm_cco          * ATR14, SC_SMOOTHING)

sc_kc_mid = ta.ema(close, SC_KC_EMA_LEN)
sc_kc_atr = ta.atr(SC_KC_ATR_LEN)
sc_top_kc  = ta.sma(sc_kc_mid + SC_KC_MULT * sc_kc_atr, SC_SMOOTHING)
sc_bot_kc  = ta.sma(sc_kc_mid - SC_KC_MULT * sc_kc_atr, SC_SMOOTHING)

sc_bb_mid  = ta.sma(close, SC_BB_LEN)
sc_bb_dev  = ta.stdev(close, SC_BB_LEN)
sc_top_bb  = ta.sma(sc_bb_mid + SC_BB_MULT * sc_bb_dev, SC_SMOOTHING)
sc_bot_bb  = ta.sma(sc_bb_mid - SC_BB_MULT * sc_bb_dev, SC_SMOOTHING)

sc_top = sc_top_cco * SC_CCO_RATIO + sc_top_kc * SC_KELTNER_RATIO + sc_top_bb * SC_BB_RATIO
sc_bot = sc_bot_cco * SC_CCO_RATIO + sc_bot_kc * SC_KELTNER_RATIO + sc_bot_bb * SC_BB_RATIO

sc_top_highlight = sc_cco >= SC_HI_THRESH
sc_bot_highlight = sc_cco <= SC_LO_THRESH

sc_top_color  = sc_top_highlight ? color.new(HILIGHT, 0) : color.new(BULL, 0)
sc_bot_color  = sc_bot_highlight ? color.new(HILIGHT, 0) : color.new(BEAR, 0)
sc_fill_color = color.new(NEUT, 95)


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 │ CANDLE TYPE
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_CANDLE = '━━━  INDICATOR CANDLES  ━━━'

candle_alt_enable = input.bool(true, 'Enable Indicator Candles', group = GRP_CANDLE,
     tooltip = "When on, the indicator replaces your regular candles with a smoother version that filters out some of the noise. This can make trends and reversals clearer. The specific smoothing method is chosen in 'Candle Type' below.")
candle_type = input.string('R-Squared Adaptive', 'Candle Type',
     options = ['Regular', 'Heikin Ashi', 'R-Squared Adaptive', 'LinReg Heikin Ashi', 'LinReg Candles'],
     group   = GRP_CANDLE,
     tooltip = "'R-Squared Adaptive' (the default) is a good all-rounder — it stays close to real prices during choppy markets and smooths more during trends. 'Heikin Ashi' is a simpler classic. The LinReg options are the most smoothed but furthest from actual prices. 'Regular' uses standard OHLC candles with CVD border highlighting only.")
candle_lr_length = input.int(10, 'Regression Length', minval = 2, group = GRP_CANDLE)

// ── Faster HA ────────────────────────────────────
float FHA_RESPONSIVENESS = 0.7
float FHA_VOL_INFLUENCE  = 0.5
float FHA_MAX_VOL_MULT   = 3.0
float _fha_meas_n        = 0.1
float _fha_kg            = 0.7
float _fha_bar_pvp       = (close - open) * volume

var float fha_vol_est  = na, var float fha_vol_err  = 1.0
var float fha_pvp_est  = na, var float fha_pvp_err  = 1.0
var float fha_pvp_var  = 1.0

float _fha_vk_vol = (fha_vol_err + _fha_meas_n) / (fha_vol_err + _fha_meas_n + _fha_meas_n)
fha_vol_est := na(fha_vol_est) ? volume       : fha_vol_est + _fha_vk_vol * (volume       - fha_vol_est)
fha_vol_err := (1.0 - _fha_vk_vol) * (fha_vol_err + _fha_meas_n)

float _fha_vk_pvp = (fha_pvp_err + _fha_meas_n) / (fha_pvp_err + _fha_meas_n + _fha_meas_n)
fha_pvp_est := na(fha_pvp_est) ? _fha_bar_pvp : fha_pvp_est + _fha_vk_pvp * (_fha_bar_pvp - fha_pvp_est)
fha_pvp_err := (1.0 - _fha_vk_pvp) * (fha_pvp_err + _fha_meas_n)

fha_pvp_var := (na(fha_pvp_var) or fha_pvp_var <= 0)
     ? math.pow(_fha_bar_pvp - fha_pvp_est, 2)
     : fha_pvp_var + _fha_kg * (math.pow(_fha_bar_pvp - fha_pvp_est, 2) - fha_pvp_var)

float _fha_pvp_std  = math.sqrt(math.max(fha_pvp_var, 0.0001))
float _fha_vol_rat  = math.min(volume / math.max(fha_vol_est, 1.0), FHA_MAX_VOL_MULT)
float _fha_pvp_norm = _fha_pvp_std > 0 ? (_fha_bar_pvp - fha_pvp_est) / _fha_pvp_std : 0.0
float _fha_comb_vf  = math.sqrt(_fha_vol_rat) * math.max(0.5, math.min(1.5, 1.0 + _fha_pvp_norm * 0.2))
float _fha_vf       = 1.0 + (_fha_comb_vf - 1.0) * FHA_VOL_INFLUENCE

float _fha_cw  = 1.0 + FHA_RESPONSIVENESS * 2.0
float _fha_ow  = 1.0 + FHA_RESPONSIVENESS * 0.5
float _fha_hw  = 1.0 + FHA_RESPONSIVENESS * 0.3
float _fha_tot = (_fha_ow + _fha_hw * 2.0 + _fha_cw) * _fha_vf
float _fha_spd = math.min(FHA_RESPONSIVENESS * (1.0 + FHA_RESPONSIVENESS * 0.5) * math.sqrt(_fha_vf), 1.0)

// Custom HA — using custom HA volume-weighted Kalman internals
float cv_ha_c_raw = (open * _fha_ow + high * _fha_hw + low * _fha_hw + close * _fha_cw) * _fha_vf / _fha_tot
var float cv_ha_o = na
float _ha_trad_o  = na(cv_ha_o) ? (open + close) / 2.0 : (cv_ha_o + nz(cv_ha_c_raw[1])) / 2.0
cv_ha_o := na(cv_ha_o) ? (open * _fha_ow + close * _fha_cw) / ((_fha_ow + _fha_cw) * _fha_vf) : cv_ha_o + _fha_spd * (_ha_trad_o - cv_ha_o)
float cv_ha_c = cv_ha_c_raw
float cv_ha_h = math.max(high, math.max(cv_ha_o, cv_ha_c))
float cv_ha_l = math.min(low,  math.min(cv_ha_o, cv_ha_c))

float cv_r2   = nz(math.pow(ta.correlation(close, bar_index, candle_lr_length), 2), 0.0)
float cv_lr_o = ta.linreg(open,  candle_lr_length, 0)
float cv_lr_h = ta.linreg(high,  candle_lr_length, 0)
float cv_lr_l = ta.linreg(low,   candle_lr_length, 0)
float cv_lr_c = ta.linreg(close, candle_lr_length, 0)

float CV_R2_LO = 0.3, float CV_R2_HI = 0.8, float CV_BLD_MIN = 0.20, float CV_BLD_MAX = 0.80
float cv_r2_norm = math.max(0.0, math.min(1.0, (cv_r2 - CV_R2_LO) / (CV_R2_HI - CV_R2_LO)))
float cv_blend   = CV_BLD_MIN + cv_r2_norm * (CV_BLD_MAX - CV_BLD_MIN)
float cv_ra_o = open  * (1.0 - cv_blend) + cv_lr_o * cv_blend
float cv_ra_h = high  * (1.0 - cv_blend) + cv_lr_h * cv_blend
float cv_ra_l = low   * (1.0 - cv_blend) + cv_lr_l * cv_blend
float cv_ra_c = close * (1.0 - cv_blend) + cv_lr_c * cv_blend
cv_ra_h := math.max(cv_ra_h, math.max(cv_ra_o, cv_ra_c))
cv_ra_l := math.min(cv_ra_l, math.min(cv_ra_o, cv_ra_c))

float cv_lrc_o = cv_lr_o, float cv_lrc_h = cv_lr_h, float cv_lrc_l = cv_lr_l, float cv_lrc_c = cv_lr_c
cv_lrc_h := math.max(cv_lrc_h, math.max(cv_lrc_o, cv_lrc_c))
cv_lrc_l := math.min(cv_lrc_l, math.min(cv_lrc_o, cv_lrc_c))

// LinReg HA — same Faster HA open logic, but seeded from linreg OHLC
float cv_lrha_c_raw = (cv_lr_o * _fha_ow + cv_lr_h * _fha_hw + cv_lr_l * _fha_hw + cv_lr_c * _fha_cw) * _fha_vf / _fha_tot
var float cv_lrha_o = na
float _lrha_trad_o  = na(cv_lrha_o) ? (cv_lr_o + cv_lr_c) / 2.0 : (cv_lrha_o + nz(cv_lrha_c_raw[1])) / 2.0
cv_lrha_o := na(cv_lrha_o) ? (cv_lr_o * _fha_ow + cv_lr_c * _fha_cw) / ((_fha_ow + _fha_cw) * _fha_vf) : cv_lrha_o + _fha_spd * (_lrha_trad_o - cv_lrha_o)
float cv_lrha_c = cv_lrha_c_raw
float cv_lrha_h = math.max(cv_lr_h, math.max(cv_lrha_o, cv_lrha_c))
float cv_lrha_l = math.min(cv_lr_l, math.min(cv_lrha_o, cv_lrha_c))

bool eff_alt_enable = IS_SIMPLE ? sim_alt_enable : candle_alt_enable
bool cv_use_custom  = eff_alt_enable

[cv_o, cv_h, cv_l, cv_c] = switch candle_type
    'Heikin Ashi'        => [cv_ha_o,   cv_ha_h,   cv_ha_l,   cv_ha_c]
    'R-Squared Adaptive' => [cv_ra_o,   cv_ra_h,   cv_ra_l,   cv_ra_c]
    'LinReg Heikin Ashi' => [cv_lrha_o, cv_lrha_h, cv_lrha_l, cv_lrha_c]
    'LinReg Candles'     => [cv_lrc_o,  cv_lrc_h,  cv_lrc_l,  cv_lrc_c]
    =>                      [open,      high,       low,       close]

color cv_bull_col = color.new(BULL, 0)
color cv_bear_col = color.new(BEAR, 0)
color cv_body     = cv_c >= cv_o ? cv_bull_col : cv_bear_col

cvd_border_enable = input.bool(true, 'Delta Border Highlight', group = GRP_CANDLE,
     tooltip = 'Highlights the border of candles where one side (buyers or sellers) dominated unusually strongly. Think of it as a conviction flag — a highlighted candle border means the move had real force behind it.')

int cvd_border_lookback = 50
cvd_border_strong = input.float(95.0, '    Strong Delta Threshold (%ile)', minval = 50.0, maxval = 99.0, step = 1.0, group = GRP_CANDLE,
     tooltip = 'Controls how extreme the buying or selling pressure must be to trigger the highlighted border. 95 means only the top 5% most one-sided bars get highlighted. Lower this to see more highlights; raise it to mark only the most extreme moments.')

float _cvd_tw    = high - math.max(open, close)
float _cvd_bw    = math.min(open, close) - low
float _cvd_body  = math.abs(close - open)
float _cvd_denom = math.max(_cvd_tw + _cvd_bw + _cvd_body, 1e-10)
float _cvd_base  = 0.5 * (_cvd_tw + _cvd_bw) / _cvd_denom
float _cvd_extra = _cvd_body / _cvd_denom

float cvd_up      = volume * math.max(_cvd_base + (open <= close ? _cvd_extra : 0.0), 0.5)
float cvd_dn      = volume * math.max(_cvd_base + (open > close  ? _cvd_extra : 0.0), 0.5)
float cvd_net     = cvd_up - cvd_dn
float cvd_agg_pct = volume > 0 ? math.abs(cvd_net) / volume * 100.0 : 0.0
float cvd_rank    = ta.percentrank(cvd_agg_pct, cvd_border_lookback)

bool  eff_cvd_enable   = (IS_SIMPLE ? sim_alt_enable : candle_alt_enable) and (IS_SIMPLE ? sim_alt_enable : cvd_border_enable)
color cvd_border_color = eff_cvd_enable and cvd_rank >= cvd_border_strong
     ? color.new(HILIGHT, 0)
     : cv_use_custom
         ? cv_body
         : color.new(color.black, 100)

bool  cvd_strong_active = eff_cvd_enable and cvd_rank >= cvd_border_strong
color cv_bull_col_final = color.new(BULL, cvd_strong_active ? 55 : 0)
color cv_bear_col_final = color.new(BEAR, cvd_strong_active ? 55 : 0)
color cv_body_final     = cv_c >= cv_o ? cv_bull_col_final : cv_bear_col_final


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 │ TREND CLOUD
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_TC = '━━━  TREND CLOUD  ━━━'

tc_enable      = input.bool(true, 'Enable Trend Cloud',       group = GRP_TC,   tooltip = 'Toggles the Trend Cloud on and off. The cloud shows the big-picture trend direction — the base line is the core trend, and the fill above represents the full trend zone and strength of the trend.')
tc_body_enable = input.bool(true, 'Enable Trend Cloud Body',  group = GRP_TC,   tooltip = 'Hides the shaded fill of the Trend Cloud while keeping the base line visible. Turn this off if you want a cleaner chart but still want to see where the trend baseline is.')
tc_slope_color = input.bool(true, 'Color Base by Trend Direction', group = GRP_TC,   tooltip = 'When on, the Trend Cloud base line turns your bullish color when the trend is rising and your bearish color when it is falling. Makes it quick to tell direction at a glance.')

bool tc_follow_candles = false
int   TC_BASE_LEN = 100
float TC_MULT     = 10.0

f_kama_vb(float src, int len) =>
    float xvnoise  = math.abs(src - src[1])
    float nsignal  = math.abs(src - src[len])
    float nnoise   = math.sum(xvnoise, len)
    float nefratio = nnoise != 0 ? nsignal / nnoise : 0.0
    float nsmooth  = math.pow(nefratio * (0.666 - 0.0645) + 0.0645, 2)
    var float nAMA = 0.0
    nAMA := nz(nAMA[1]) + nsmooth * (src - nz(nAMA[1]))
    nAMA

float tc_ohlc4 = cv_use_custom and tc_follow_candles
     ? (cv_o + cv_h + cv_l + cv_c) / 4.0
     : (open + high + low + close) / 4.0

float tc_k05  = f_kama_vb(tc_ohlc4,  5),  float tc_k10  = f_kama_vb(tc_ohlc4, 10)
float tc_k15  = f_kama_vb(tc_ohlc4, 15),  float tc_k20  = f_kama_vb(tc_ohlc4, 20)
float tc_k25  = f_kama_vb(tc_ohlc4, 25),  float tc_k30  = f_kama_vb(tc_ohlc4, 30)
float tc_k35  = f_kama_vb(tc_ohlc4, 35),  float tc_k40  = f_kama_vb(tc_ohlc4, 40)
float tc_k45  = f_kama_vb(tc_ohlc4, 45),  float tc_k50  = f_kama_vb(tc_ohlc4, 50)
float tc_k55  = f_kama_vb(tc_ohlc4, 55),  float tc_k60  = f_kama_vb(tc_ohlc4, 60)
float tc_k65  = f_kama_vb(tc_ohlc4, 65),  float tc_k70  = f_kama_vb(tc_ohlc4, 70)
float tc_k75  = f_kama_vb(tc_ohlc4, 75),  float tc_k80  = f_kama_vb(tc_ohlc4, 80)
float tc_k85  = f_kama_vb(tc_ohlc4, 85),  float tc_k90  = f_kama_vb(tc_ohlc4, 90)
float tc_k100 = f_kama_vb(tc_ohlc4, TC_BASE_LEN)

float tc_total_dist =
     (tc_k05 - tc_k10)/tc_k10 + (tc_k10 - tc_k15)/tc_k15 + (tc_k15 - tc_k20)/tc_k20 +
     (tc_k20 - tc_k25)/tc_k25 + (tc_k25 - tc_k30)/tc_k30 + (tc_k30 - tc_k35)/tc_k35 +
     (tc_k35 - tc_k40)/tc_k40 + (tc_k40 - tc_k45)/tc_k45 + (tc_k45 - tc_k50)/tc_k50 +
     (tc_k50 - tc_k55)/tc_k55 + (tc_k55 - tc_k60)/tc_k60 + (tc_k60 - tc_k65)/tc_k65 +
     (tc_k65 - tc_k70)/tc_k70 + (tc_k70 - tc_k75)/tc_k75 + (tc_k75 - tc_k80)/tc_k80 +
     (tc_k80 - tc_k85)/tc_k85 + (tc_k85 - tc_k90)/tc_k90 + (tc_k90 - tc_k100)/tc_k100

float tc_avg_dist  = tc_total_dist / 18.0
float tc_base      = f_kama_vb(close, TC_BASE_LEN)
float tc_cloud_top = tc_base * (1.0 + tc_avg_dist * TC_MULT)

float tc_strength = math.abs(tc_cloud_top - tc_base) / ATR14
float tc_transp   = math.max(55.0, math.min(90.0, 90.0 - tc_strength / 2.0 * 35.0))

color tc_trend_col = tc_cloud_top > tc_base ? color.new(BULL, tc_transp) : color.new(BEAR, tc_transp)
color tc_line_col  = color.new(NEUT, 20)
color tc_base_col  = tc_slope_color
     ? (tc_base > tc_base[1] ? color.new(BULL, 0) : color.new(BEAR, 0))
     : tc_line_col


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6B │ TREND REGIME GATE
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_TRG = '━━━  TREND REGIME GATE  ━━━'

trg_enable = input.bool(true, 'Enable Trend Regime Gate', group = GRP_TRG,
     tooltip = 'When the market is clearly trending in one direction, this filter prevents signals from firing against that trend. It doesnt block them entirely — it downgrades them to small dots that can still become full signals if other strong conditions are met. Great for avoiding entries that fight the trend.')

trg_ka_thresh = input.float(0.62, '    Trend Acceleration Alignment Threshold', minval = 0.40, maxval = 1.00, step = 0.01, group = GRP_TRG,
     tooltip = 'Sets how aligned the internal moving averages need to be before the system considers the market to be in a strong trend. Lower = the gate activates more often, blocking more counter-trend signals. Higher = only very strong, well-confirmed trends trigger it.')

trg_hurst_len = input.int(100, '    Hurst Lookback', minval = 20, maxval = 150, group = GRP_TRG,
     tooltip = 'Number of bars for the rescaled-range Hurst exponent estimate. Shorter = more reactive but noisier.')

trg_hurst_thresh = input.float(0.5, '    Hurst Trending Threshold', minval = 0.40, maxval = 0.70, step = 0.01, group = GRP_TRG,
     tooltip = 'Hurst exponent above this value counts as a trending regime vote. H = 0.50 is a random walk; values above indicate persistent (trending) behavior.')

trg_accel_smooth = input.int(3, '    Acceleration Smoothing', minval = 1, maxval = 15, group = GRP_TRG,
     tooltip = 'EMA length applied to the TC base second derivative. Shorter = more responsive to acceleration changes, longer = fewer false flips.')

trg_votes_required = input.int(2, '    Votes Required', minval = 1, maxval = 3, group = GRP_TRG,
     tooltip = 'The Regime Gate uses three independent measures to judge whether the market is trending. This sets how many must agree before counter-trend signals are suppressed. 2 (default) is a balanced approach — not too aggressive, not too permissive.')

bool eff_trg_enable = IS_SIMPLE ? sim_trg_enable : trg_enable

// ── Measure 1: KAMA Fan Alignment ────────────────────────────────────────────
int _ka_bull_count = 0
_ka_bull_count += tc_k05 > tc_k10  ? 1 : 0
_ka_bull_count += tc_k10 > tc_k15  ? 1 : 0
_ka_bull_count += tc_k15 > tc_k20  ? 1 : 0
_ka_bull_count += tc_k20 > tc_k25  ? 1 : 0
_ka_bull_count += tc_k25 > tc_k30  ? 1 : 0
_ka_bull_count += tc_k30 > tc_k35  ? 1 : 0
_ka_bull_count += tc_k35 > tc_k40  ? 1 : 0
_ka_bull_count += tc_k40 > tc_k45  ? 1 : 0
_ka_bull_count += tc_k45 > tc_k50  ? 1 : 0
_ka_bull_count += tc_k50 > tc_k55  ? 1 : 0
_ka_bull_count += tc_k55 > tc_k60  ? 1 : 0
_ka_bull_count += tc_k60 > tc_k65  ? 1 : 0
_ka_bull_count += tc_k65 > tc_k70  ? 1 : 0
_ka_bull_count += tc_k70 > tc_k75  ? 1 : 0
_ka_bull_count += tc_k75 > tc_k80  ? 1 : 0
_ka_bull_count += tc_k80 > tc_k85  ? 1 : 0
_ka_bull_count += tc_k85 > tc_k90  ? 1 : 0
_ka_bull_count += tc_k90 > tc_k100 ? 1 : 0

int _ka_bear_count = 0
_ka_bear_count += tc_k05 < tc_k10  ? 1 : 0
_ka_bear_count += tc_k10 < tc_k15  ? 1 : 0
_ka_bear_count += tc_k15 < tc_k20  ? 1 : 0
_ka_bear_count += tc_k20 < tc_k25  ? 1 : 0
_ka_bear_count += tc_k25 < tc_k30  ? 1 : 0
_ka_bear_count += tc_k30 < tc_k35  ? 1 : 0
_ka_bear_count += tc_k35 < tc_k40  ? 1 : 0
_ka_bear_count += tc_k40 < tc_k45  ? 1 : 0
_ka_bear_count += tc_k45 < tc_k50  ? 1 : 0
_ka_bear_count += tc_k50 < tc_k55  ? 1 : 0
_ka_bear_count += tc_k55 < tc_k60  ? 1 : 0
_ka_bear_count += tc_k60 < tc_k65  ? 1 : 0
_ka_bear_count += tc_k65 < tc_k70  ? 1 : 0
_ka_bear_count += tc_k70 < tc_k75  ? 1 : 0
_ka_bear_count += tc_k75 < tc_k80  ? 1 : 0
_ka_bear_count += tc_k80 < tc_k85  ? 1 : 0
_ka_bear_count += tc_k85 < tc_k90  ? 1 : 0
_ka_bear_count += tc_k90 < tc_k100 ? 1 : 0

float trg_ka_bull_pct = _ka_bull_count / 18.0
float trg_ka_bear_pct = _ka_bear_count / 18.0

// ── Measure 2: Hurst Exponent (Rescaled Range) ────────────────────────────────
// Throttle to every 5 bars
int _trg_hurst_len = IS_SIMPLE ? 50 : trg_hurst_len

f_hurst_rs(float src, int len) =>
    float _h_mean = ta.sma(src, len)
    float _h_max_dev = -1e10
    float _h_min_dev =  1e10
    float _h_cum     =  0.0
    float _h_sum_sq  =  0.0
    for i = 0 to len - 1
        float _h_diff = src[i] - _h_mean
        _h_cum    += _h_diff
        _h_max_dev := math.max(_h_max_dev, _h_cum)
        _h_min_dev := math.min(_h_min_dev, _h_cum)
        _h_sum_sq += _h_diff * _h_diff
    float _h_R  = _h_max_dev - _h_min_dev
    float _h_S  = math.sqrt(_h_sum_sq / len)
    float _h_RS = _h_S > 1e-10 ? _h_R / _h_S : 0.0
    float _h_H  = _h_RS > 0.0 ? math.log(_h_RS) / math.log(len) : 0.5
    math.max(0.0, math.min(1.0, _h_H))

var float trg_hurst = 0.5
if bar_index % 5 == 0
    trg_hurst := f_hurst_rs(close, _trg_hurst_len)

// ── Measure 3: TC Base Slope Acceleration ────────────────────────────────────
float trg_tc_vel   = ATR14 > 0.0 ? (tc_base - tc_base[1]) / ATR14 : 0.0
float trg_tc_accel = trg_tc_vel - nz(trg_tc_vel[1])

int   _trg_accel_smo     = IS_SIMPLE ? 5 : trg_accel_smooth
float trg_tc_accel_smooth = ta.ema(trg_tc_accel, _trg_accel_smo)

// ── Regime Voting ────────────────────────────────────────────────────────────
float _trg_ka_th    = IS_SIMPLE ? 0.72 : trg_ka_thresh
float _trg_hurst_th = IS_SIMPLE ? 0.55 : trg_hurst_thresh
int   _trg_votes_rq = IS_SIMPLE ? 2    : trg_votes_required

int trg_bull_votes = 0
trg_bull_votes += trg_ka_bull_pct     >= _trg_ka_th                              ? 1 : 0
trg_bull_votes += trg_hurst           >  _trg_hurst_th                           ? 1 : 0
trg_bull_votes += trg_tc_accel_smooth >  0.0 and tc_base > tc_base[1]            ? 1 : 0

int trg_bear_votes = 0
trg_bear_votes += trg_ka_bear_pct     >= _trg_ka_th                              ? 1 : 0
trg_bear_votes += trg_hurst           >  _trg_hurst_th                           ? 1 : 0
trg_bear_votes += trg_tc_accel_smooth <  0.0 and tc_base < tc_base[1]            ? 1 : 0

bool trg_suppress_sell = eff_trg_enable and trg_bull_votes >= _trg_votes_rq
bool trg_suppress_buy  = eff_trg_enable and trg_bear_votes >= _trg_votes_rq

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5B │ CANDLE COLORING
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_CANDLE_COL = '━━━  CANDLE COLORING  ━━━'

candle_col_enable = input.bool(false, 'Enable Candle Coloring', group = GRP_CANDLE_COL,
     tooltip = 'Replaces candle body color with a selected market state indicator. Each mode uses the existing theme bull/bear/neutral colors. Disabled by default.')

candle_col_mode = input.string('Trend Regime', 'Color Mode',
     options = ['MA Ribbon', 'Trend Regime', 'Dual Confirmation', 'Adaptive Impulse', 'Heikin Ashi', 'Trend Cloud Base'],
     group = GRP_CANDLE_COL,
     tooltip = 'MA Ribbon: bull/bear based on ribbon line positions.\nTrend Regime: 5-level color from regime vote count.\nDual Confirmation: full color only when ribbon and TC agree.\nAdaptive Impulse: Elder-style logic using KAMA slope + ALMA MACD histogram direction.\nHeikin Ashi: bull/bear based on smoothed HA candle direction.\nTrend Cloud Base: bull/bear based on TC base slope direction.')

bool eff_candle_col_enable = IS_SIMPLE ? sim_candle_col_enable : candle_col_enable

// ── Mode: MA Ribbon ───────────────────────────────────────────────────────────
color _cc_ribbon = cma1 > cma2 ? color.new(BULL, 0) : color.new(BEAR, 0)

// ── Mode: Trend Regime ────────────────────────────────────────────────────────
int _trg_net_votes = trg_bull_votes - trg_bear_votes
var color _cc_regime = color.new(NEUT, 15)
_cc_regime := _trg_net_votes >= 2  ? color.new(BULL, 0)  :
              _trg_net_votes == 1  ? color.new(BULL, 25)  :
              _trg_net_votes == -1 ? color.new(BEAR, 25)  :
              _trg_net_votes <= -2 ? color.new(BEAR, 0)   :
              color.new(NEUT, 15)

// ── Mode: Dual Confirmation ───────────────────────────────────────────────────
bool _cc_ribbon_bull = cma1 > cma2
bool _cc_tc_bull     = tc_base > tc_base[1]
color _cc_dual = _cc_ribbon_bull and _cc_tc_bull         ? color.new(BULL, 0) :
                 not _cc_ribbon_bull and not _cc_tc_bull ? color.new(BEAR, 0) :
                 color.new(NEUT, 15)

// ── Mode: Adaptive Impulse ────────────────────────────────────────────────────
float _cc_ei_fast  = ta.alma(close, 12, 0.85, 6.0)
float _cc_ei_slow  = ta.alma(close, 26, 0.85, 6.0)
float _cc_ei_macd  = _cc_ei_fast - _cc_ei_slow
float _cc_ei_sig   = ta.alma(_cc_ei_macd, 9, 0.85, 6.0)
float _cc_ei_hist  = _cc_ei_macd - _cc_ei_sig
float _cc_ei_trend = f_kama_vb(close, 13)

bool _cc_ei_trend_bull = _cc_ei_trend > _cc_ei_trend[1]
bool _cc_ei_hist_bull  = _cc_ei_hist  > _cc_ei_hist[1]

color _cc_elder = _cc_ei_trend_bull and _cc_ei_hist_bull         ? color.new(BULL, 0) :
                  not _cc_ei_trend_bull and not _cc_ei_hist_bull ? color.new(BEAR, 0) :
                  color.new(NEUT, 15)

// ── Mode: Heikin Ashi ─────────────────────────────────────────────────────────
color _cc_ha = cv_ha_c >= cv_ha_o ? color.new(BULL, 0) : color.new(BEAR, 0)

// ── Mode: Trend Cloud Base ────────────────────────────────────────────────────
color _cc_tc_base = tc_base > tc_base[1] ? color.new(BULL, 0) : color.new(BEAR, 0)

// ── Final Selection ───────────────────────────────────────────────────────────
var color candle_color_out = color.new(NEUT, 15)

color _cc_selected = switch candle_col_mode
    'MA Ribbon'         => _cc_ribbon
    'Trend Regime'      => _cc_regime
    'Dual Confirmation' => _cc_dual
    'Adaptive Impulse'  => _cc_elder
    'Heikin Ashi'       => _cc_ha
    'Trend Cloud Base'  => _cc_tc_base
    =>                     _cc_regime

candle_color_out := _cc_selected

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 │ PRISM SIGNALS
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_PRISM = '━━━  PRISM SIGNALS  ━━━'

prism_enable = input.bool(true, 'Enable PRISM Signals', group = GRP_PRISM,
     tooltip = 'Shows or hides all PRISM signal outputs. Quality Gate signals appear as small dots when conditions are marginal.')

float prism_source = close
prism_length = input.int(40, 'Base Lookback Window', minval = 10, maxval = 200, step = 5, group = GRP_PRISM,
     tooltip = 'Sets how far back the signal engine looks when studying price. A smaller number catches short, quick moves. A larger number only reacts to bigger, more established patterns. The Auto-Optimizer adjusts this automatically if enabled — this sets the starting point.')
int   prism_degree = 4

prism_st1_factor = input.float(0.2, 'Alpha Rail Factor', step = 0.1, group = GRP_PRISM)
prism_st1_period = input.int(10,    'Alpha Rail Period',  minval = 1,  group = GRP_PRISM)
prism_st2_factor = input.float(0.5, 'Sigma Rail Factor', step = 0.1, group = GRP_PRISM)
prism_st2_period = input.int(20,    'Sigma Rail Period',  minval = 1,  group = GRP_PRISM)

prism_sig_size = input.string('Small', 'Signal Size', options = ['Small', 'Normal'], group = GRP_PRISM)

prism_adaptive_enable = input.bool(true, '⊳ PRISM Adaptive', group = GRP_PRISM,
     tooltip = 'Automatically scales the lookback window based on chart timeframe. Recommended to keep enabled when using PRISM signals')

prism_ns_enable = input.bool(false, '⊳ Noise Suppression', group = GRP_PRISM,
     tooltip = 'Dynamically adjusts the lookback window and rail periods when the when choppy, directionless price action is detected. Works independently or stacked on top of PRISM Adaptive.')

prism_ribbon_filt_enable = input.bool(true, '⊳ Structure Lock',  group = GRP_PRISM,
     tooltip = 'When a signal appears while the moving average ribbon is pushing the opposite direction, Structure Lock pauses it for up to 4 bars. If the ribbon confirms by turning, the signal fires. If it doesnt confirm, the signal is cancelled. Reduces false entries during choppy reversals.')

prism_bq_enable = input.bool(true, '⊳ Bar Quality', group = GRP_PRISM,
     tooltip = 'Makes sure a signal fires on a bar that closed convincingly in the signal direction. If the trigger bar on a poor quality bar, the signal waits up to 3 bars for a better-quality bar. Helps avoid entering on hesitant, indecisive price action.')

prism_bq_min_ratio = input.float(0.30, '    Min Body/Range Ratio', minval = 0.05, maxval = 0.70, step = 0.05, group = GRP_PRISM,
     tooltip = "Sets how large a candle's body must be relative to its full high-to-low range for the Bar Quality filter to accept it. 0.30 means the body must be at least 30% of the total candle range. Higher = stricter, fewer signals pass.")

prism_mq_enable = input.bool(true, '⊳ Quality Gate', group = GRP_PRISM,
     tooltip = 'tooltip = "When market conditions are weak, this filter shows the signal as a small dot instead of a full buy/sell label. Think of it as a proceed with caution flag — the setup appeared but the market quality is poor. The dot can upgrade to a full signal if other strong conditions are met."')

int   prism_er_len          = 14
float prism_er_thresh       = 0.2
int   prism_fast_kama_len   = 20
float prism_fast_kama_slope = 0.03
int   prism_fkama_slope_len = 5

// ── PRISM Adaptive & Noise Suppression ───────────────────────────────────────
float PRISM_NS_MAX_EXT   = 0.25
int   PRISM_NS_ER_SMOOTH = 10
int   PRISM_NS_QUANT     = 5
int   PRISM_REF_SEC      = 120
float PRISM_TF_EXP       = 0.45

bool _eff_adaptive = IS_SIMPLE ? true : prism_adaptive_enable
bool _eff_ns       = IS_SIMPLE ? false : prism_ns_enable

int   _prism_tf_sec = timeframe.in_seconds()
float _prism_tf_ratio = _eff_adaptive and _prism_tf_sec < PRISM_REF_SEC
     ? math.pow(float(PRISM_REF_SEC) / float(_prism_tf_sec), PRISM_TF_EXP)
     : 1.0

float _prism_er_raw_ns = math.sum(math.abs(close - close[1]), prism_er_len)
float _prism_er_val_ns = _prism_er_raw_ns > 0.0
     ? math.abs(close - close[prism_er_len]) / _prism_er_raw_ns : 0.0
float _prism_er_smo = ta.ema(_prism_er_val_ns, PRISM_NS_ER_SMOOTH)

float _prism_ns_weight_full = _eff_ns
     ? 1.0 + (1.0 - _prism_er_smo) * PRISM_NS_MAX_EXT : 1.0
float _prism_ns_weight_half = _eff_ns
     ? 1.0 + (1.0 - _prism_er_smo) * PRISM_NS_MAX_EXT * 0.5 : 1.0

f_quantize(float val, int step) =>
    math.max(step, math.round(val / step) * step)

int _prism_len     = f_quantize(40  * _prism_tf_ratio * _prism_ns_weight_full,  PRISM_NS_QUANT)
int _prism_st1_per = f_quantize(10  * _prism_tf_ratio * _prism_ns_weight_half,  PRISM_NS_QUANT)
int _prism_st2_per = f_quantize(20  * _prism_tf_ratio * _prism_ns_weight_half,  PRISM_NS_QUANT)

// ── Polynomial Regression Function ───────────────────────────────────────────
prism_calcPoly(float src, int len, int deg) =>
    float lenM1   = float(len - 1)
    float sum_y   = 0.0, float sum_x1 = 0.0, float sum_x2  = 0.0, float sum_x3  = 0.0
    float sum_x4  = 0.0, float sum_x5  = 0.0, float sum_x6  = 0.0
    float sum_x7  = 0.0, float sum_x8  = 0.0
    float sum_xy  = 0.0, float sum_x2y = 0.0, float sum_x3y = 0.0, float sum_x4y = 0.0
    for i = 0 to len - 1
        float x = float(i) / lenM1, float y = src[len - 1 - i]
        float x2 = x*x, float x3 = x2*x, float x4 = x2*x2
        sum_y  += y,  sum_x1 += x,  sum_x2 += x2, sum_x3 += x3, sum_x4 += x4
        sum_x5 += x4*x, sum_x6 += x3*x3, sum_x7 += x4*x3, sum_x8 += x4*x4
        sum_xy += x*y, sum_x2y += x2*y, sum_x3y += x3*y, sum_x4y += x4*y
    float n = float(len)
    array<float> psum = array.from(n,sum_x1,sum_x2,sum_x3,sum_x4,sum_x5,sum_x6,sum_x7,sum_x8)
    array<float> dsum = array.from(sum_y,sum_xy,sum_x2y,sum_x3y,sum_x4y)
    int dim = deg + 1
    matrix<float> A = matrix.new<float>(dim, dim+1, 0.0)
    for r = 0 to dim-1
        for c = 0 to dim-1
            matrix.set(A, r, c, array.get(psum, r+c))
        matrix.set(A, r, dim, array.get(dsum, r))
    for col = 0 to dim-2
        int pivRow = col, float pivMax = math.abs(matrix.get(A,col,col))
        for row = col+1 to dim-1
            float v = math.abs(matrix.get(A,row,col))
            if v > pivMax
                pivMax := v, pivRow := row
        if pivRow != col
            for k = 0 to dim
                float tmp = matrix.get(A,col,k)
                matrix.set(A,col,k,matrix.get(A,pivRow,k)), matrix.set(A,pivRow,k,tmp)
        float pivot = matrix.get(A,col,col)
        if math.abs(pivot) > 1e-10
            for row = col+1 to dim-1
                float f = matrix.get(A,row,col)/pivot
                for k = col to dim
                    matrix.set(A,row,k, matrix.get(A,row,k) - f*matrix.get(A,col,k))
    array<float> coeffs = array.new_float(5, 0.0)
    for ii = 0 to dim-1
        int r = dim-1-ii, float val = matrix.get(A,r,dim)
        if r+1 <= dim-1
            for c = r+1 to dim-1
                val -= matrix.get(A,r,c) * array.get(coeffs,c)
        float diag = matrix.get(A,r,r)
        array.set(coeffs, r, math.abs(diag) > 1e-10 ? val/diag : 0.0)
    float polyVal = 0.0
    for k = 0 to deg
        polyVal += array.get(coeffs,k)
    [polyVal, array.get(coeffs,0), array.get(coeffs,1), array.get(coeffs,2), array.get(coeffs,3), array.get(coeffs,4)]

prism_evalPoly(float x, float c0, float c1, float c2, float c3, float c4) =>
    float x2 = x*x, float x3 = x2*x, float x4 = x2*x2
    c0 + c1*x + c2*x2 + c3*x3 + c4*x4

float PRISM_TR = math.max(high-low, math.abs(high-close[1]), math.abs(low-close[1]))

prism_calcST(float src, float factor, int atrPeriod) => 
    int safe_period = math.max(1, nz(atrPeriod, 10)) 
    float atr = ta.sma(PRISM_TR, safe_period)
    float upper = src + factor*atr, float lower = src - factor*atr
    var float prevUpper = na, var float prevLower = na, var int stDir = 1, var float stLine = na
    prevUpper := nz(upper[1], upper), prevLower := nz(lower[1], lower)
    lower := lower > prevLower or src[1] < prevLower ? lower : prevLower
    upper := upper < prevUpper or src[1] > prevUpper ? upper : prevUpper
    if na(stLine[1])
        stDir := 1
    else if stLine[1] == prevUpper
        stDir := src > upper ? -1 : 1
    else
        stDir := src < lower ? 1 : -1
    stLine := stDir == -1 ? lower : upper
    [stLine, stDir]


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7A │ AUTO-OPTIMIZER
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_AO = '━━━  AUTO-OPTIMIZER  ━━━'

ao_enable = input.bool(true, 'Enable Auto-Optimizer', group = GRP_AO,
     tooltip = 'When on, the indicator automatically tests three variations of the lookback setting and tracks which has been working best on recent signals. It then leans toward that length. You can see the current adjustment in the info panel under Auto-Optimizer. No manual input needed — it self-tunes.')

ao_spread = input.float(50, 'Length Spread (%)', minval = 10.0, maxval = 60.0, step = 2.5, group = GRP_AO,
     tooltip = 'Controls how far apart the three test lengths are. With a 50% spread and a base of 40, the three lengths tested are roughly 20, 40, and 60. A bigger spread lets the optimizer explore more aggressively, but can also make larger adjustments. The default is a good middle ground.')

ao_tier1 = input.float(0.75, 'Tier 1 ATR — Weak Win', minval = 0.1, maxval = 2.0, step = 0.1, group = GRP_AO,
     tooltip = 'The minimum favorable price move (measured in ATR units) a signal needs to score 1 point. Signals that never reach this are scored 0. ATR is a measure of average candle size — so this threshold scales automatically with how volatile the market is.')

ao_tier2 = input.float(1.5, 'Tier 2 ATR — Solid Win', minval = 0.2, maxval = 3.0, step = 0.1, group = GRP_AO,
     tooltip = 'Favorable move threshold to score 2 points. Checked incrementally — a signal that hits Tier 2 but not Tier 3 keeps this score.')

ao_tier3 = input.float(2.5, 'Tier 3 ATR — Strong Win', minval = 0.3, maxval = 4.0, step = 0.1, group = GRP_AO,
     tooltip = 'Favorable move threshold to score 3 points. Signal resolves immediately once this tier is reached.')

ao_max_bars = input.int(7, 'Max Bars to Resolve', minval = 3, maxval = 20, group = GRP_AO,
     tooltip = 'Maximum number of bars a signal has to reach its ATR tiers before it expires and gets scored with whatever tier it reached.')

ao_lookback = input.int(20, 'Signal Lookback', minval = 5, maxval = 50, group = GRP_AO,
     tooltip = 'Controls how much signal history the optimizer uses to judge which length is performing best. Lower = reacts faster to recent changes, good when market conditions shift frequently. Higher = more stable but slower to adapt.')

bool eff_ao_enable = IS_SIMPLE ? sim_ao_enable : ao_enable

// ── Test Lengths (proportional to adaptive base) ─────────────────────────────
float _ao_spread_frac = ao_spread / 100.0
int ao_len_s = f_quantize(float(_prism_len) * (1.0 - _ao_spread_frac), PRISM_NS_QUANT)
int ao_len_m = _prism_len
int ao_len_l = f_quantize(float(_prism_len) * (1.0 + _ao_spread_frac), PRISM_NS_QUANT)

// ── Test Pipeline: Short ─────────────────────────────────────────────────────
[ao_poly_s, _aoc0s, _aoc1s, _aoc2s, _aoc3s, _aoc4s] = prism_calcPoly(prism_source, ao_len_s, prism_degree)
[_ao_st1_s, ao_d1_s] = prism_calcST(ao_poly_s, prism_st1_factor, _prism_st1_per)
[_ao_st2_s, ao_d2_s] = prism_calcST(ao_poly_s, prism_st2_factor, _prism_st2_per)

bool ao_now_bull_s = ao_d1_s == -1 and ao_d2_s == -1
bool ao_now_bear_s = ao_d1_s ==  1 and ao_d2_s ==  1
bool ao_was_bull_s = nz(ao_d1_s[1]) == -1 and nz(ao_d2_s[1]) == -1
bool ao_was_bear_s = nz(ao_d1_s[1]) ==  1 and nz(ao_d2_s[1]) ==  1
bool ao_sig_bull_s = ao_now_bull_s and not ao_was_bull_s
bool ao_sig_bear_s = ao_now_bear_s and not ao_was_bear_s
bool ao_sig_any_s  = ao_sig_bull_s or ao_sig_bear_s

// ── Test Pipeline: Mid ───────────────────────────────────────────────────────
[ao_poly_m, _aoc0m, _aoc1m, _aoc2m, _aoc3m, _aoc4m] = prism_calcPoly(prism_source, ao_len_m, prism_degree)
[_ao_st1_m, ao_d1_m] = prism_calcST(ao_poly_m, prism_st1_factor, _prism_st1_per)
[_ao_st2_m, ao_d2_m] = prism_calcST(ao_poly_m, prism_st2_factor, _prism_st2_per)

bool ao_now_bull_m = ao_d1_m == -1 and ao_d2_m == -1
bool ao_now_bear_m = ao_d1_m ==  1 and ao_d2_m ==  1
bool ao_was_bull_m = nz(ao_d1_m[1]) == -1 and nz(ao_d2_m[1]) == -1
bool ao_was_bear_m = nz(ao_d1_m[1]) ==  1 and nz(ao_d2_m[1]) ==  1
bool ao_sig_bull_m = ao_now_bull_m and not ao_was_bull_m
bool ao_sig_bear_m = ao_now_bear_m and not ao_was_bear_m
bool ao_sig_any_m  = ao_sig_bull_m or ao_sig_bear_m

// ── Test Pipeline: Long ──────────────────────────────────────────────────────
[ao_poly_l, _aoc0l, _aoc1l, _aoc2l, _aoc3l, _aoc4l] = prism_calcPoly(prism_source, ao_len_l, prism_degree)
[_ao_st1_l, ao_d1_l] = prism_calcST(ao_poly_l, prism_st1_factor, _prism_st1_per)
[_ao_st2_l, ao_d2_l] = prism_calcST(ao_poly_l, prism_st2_factor, _prism_st2_per)

bool ao_now_bull_l = ao_d1_l == -1 and ao_d2_l == -1
bool ao_now_bear_l = ao_d1_l ==  1 and ao_d2_l ==  1
bool ao_was_bull_l = nz(ao_d1_l[1]) == -1 and nz(ao_d2_l[1]) == -1
bool ao_was_bear_l = nz(ao_d1_l[1]) ==  1 and nz(ao_d2_l[1]) ==  1
bool ao_sig_bull_l = ao_now_bull_l and not ao_was_bull_l
bool ao_sig_bear_l = ao_now_bear_l and not ao_was_bear_l
bool ao_sig_any_l  = ao_sig_bull_l or ao_sig_bear_l

// ── Score Ring Buffers ───────────────────────────────────────────────────────
var array<int> ao_scores_s = array.new<int>(0)
var array<int> ao_scores_m = array.new<int>(0)
var array<int> ao_scores_l = array.new<int>(0)

// ── Pending Signal State ─────────────────────────────────────────────────────
var float ao_ps_price = na, var int ao_ps_dir = 0
var int   ao_ps_bar   = 0,  var int ao_ps_best = 0, var float ao_ps_atr = na

var float ao_pm_price = na, var int ao_pm_dir = 0
var int   ao_pm_bar   = 0,  var int ao_pm_best = 0, var float ao_pm_atr = na

var float ao_pl_price = na, var int ao_pl_dir = 0
var int   ao_pl_bar   = 0,  var int ao_pl_best = 0, var float ao_pl_atr = na

// ── Scoring Engine: Short ────────────────────────────────────────────────────
if not na(ao_ps_price)
    float _fav_s = ao_ps_dir == 1 ? high - ao_ps_price : ao_ps_price - low
    if _fav_s >= ao_ps_atr * ao_tier3
        ao_ps_best := 3
    else if _fav_s >= ao_ps_atr * ao_tier2
        ao_ps_best := math.max(ao_ps_best, 2)
    else if _fav_s >= ao_ps_atr * ao_tier1
        ao_ps_best := math.max(ao_ps_best, 1)
    if ao_ps_best >= 3 or (bar_index - ao_ps_bar >= ao_max_bars) or ao_sig_any_s
        array.push(ao_scores_s, ao_ps_best)
        if array.size(ao_scores_s) > ao_lookback
            array.shift(ao_scores_s)
        ao_ps_price := na

if ao_sig_any_s and na(ao_ps_price)
    ao_ps_price := close
    ao_ps_dir   := ao_sig_bull_s ? 1 : -1
    ao_ps_bar   := bar_index
    ao_ps_best  := 0
    ao_ps_atr   := ATR14

// ── Scoring Engine: Mid ──────────────────────────────────────────────────────
if not na(ao_pm_price)
    float _fav_m = ao_pm_dir == 1 ? high - ao_pm_price : ao_pm_price - low
    if _fav_m >= ao_pm_atr * ao_tier3
        ao_pm_best := 3
    else if _fav_m >= ao_pm_atr * ao_tier2
        ao_pm_best := math.max(ao_pm_best, 2)
    else if _fav_m >= ao_pm_atr * ao_tier1
        ao_pm_best := math.max(ao_pm_best, 1)
    if ao_pm_best >= 3 or (bar_index - ao_pm_bar >= ao_max_bars) or ao_sig_any_m
        array.push(ao_scores_m, ao_pm_best)
        if array.size(ao_scores_m) > ao_lookback
            array.shift(ao_scores_m)
        ao_pm_price := na

if ao_sig_any_m and na(ao_pm_price)
    ao_pm_price := close
    ao_pm_dir   := ao_sig_bull_m ? 1 : -1
    ao_pm_bar   := bar_index
    ao_pm_best  := 0
    ao_pm_atr   := ATR14

// ── Scoring Engine: Long ─────────────────────────────────────────────────────
if not na(ao_pl_price)
    float _fav_l = ao_pl_dir == 1 ? high - ao_pl_price : ao_pl_price - low
    if _fav_l >= ao_pl_atr * ao_tier3
        ao_pl_best := 3
    else if _fav_l >= ao_pl_atr * ao_tier2
        ao_pl_best := math.max(ao_pl_best, 2)
    else if _fav_l >= ao_pl_atr * ao_tier1
        ao_pl_best := math.max(ao_pl_best, 1)
    if ao_pl_best >= 3 or (bar_index - ao_pl_bar >= ao_max_bars) or ao_sig_any_l
        array.push(ao_scores_l, ao_pl_best)
        if array.size(ao_scores_l) > ao_lookback
            array.shift(ao_scores_l)
        ao_pl_price := na

if ao_sig_any_l and na(ao_pl_price)
    ao_pl_price := close
    ao_pl_dir   := ao_sig_bull_l ? 1 : -1
    ao_pl_bar   := bar_index
    ao_pl_best  := 0
    ao_pl_atr   := ATR14

// ── Weighted Blend ───────────────────────────────────────────────────────────

f_convex_weight(int pos, int total) =>
    float r = float(pos) / float(total)
    r * r

float ao_wsum_s = 0.0
float ao_wsum_m = 0.0
float ao_wsum_l = 0.0
float ao_wsum_s_total = 0.0
float ao_wsum_m_total = 0.0
float ao_wsum_l_total = 0.0

int _ao_sz_s = array.size(ao_scores_s)
int _ao_sz_m = array.size(ao_scores_m)
int _ao_sz_l = array.size(ao_scores_l)

if _ao_sz_s > 0
    for i = 0 to _ao_sz_s - 1
        float w = f_convex_weight(i + 1, _ao_sz_s)
        ao_wsum_s       += float(array.get(ao_scores_s, i)) * w
        ao_wsum_s_total += w

if _ao_sz_m > 0
    for i = 0 to _ao_sz_m - 1
        float w = f_convex_weight(i + 1, _ao_sz_m)
        ao_wsum_m       += float(array.get(ao_scores_m, i)) * w
        ao_wsum_m_total += w

if _ao_sz_l > 0
    for i = 0 to _ao_sz_l - 1
        float w = f_convex_weight(i + 1, _ao_sz_l)
        ao_wsum_l       += float(array.get(ao_scores_l, i)) * w
        ao_wsum_l_total += w

float _ao_avg_s = ao_wsum_s_total > 0 ? ao_wsum_s / ao_wsum_s_total : 0.0
float _ao_avg_m = ao_wsum_m_total > 0 ? ao_wsum_m / ao_wsum_m_total : 0.0
float _ao_avg_l = ao_wsum_l_total > 0 ? ao_wsum_l / ao_wsum_l_total : 0.0

float _ao_sharpness = 3.0
float _ao_w_s = math.pow(_ao_avg_s, _ao_sharpness) * float(_ao_sz_s)
float _ao_w_m = math.pow(_ao_avg_m, _ao_sharpness) * float(_ao_sz_m)
float _ao_w_l = math.pow(_ao_avg_l, _ao_sharpness) * float(_ao_sz_l)
float _ao_w_total = _ao_w_s + _ao_w_m + _ao_w_l

float ao_sum_s = _ao_w_s
float ao_sum_m = _ao_w_m
float ao_sum_l = _ao_w_l
float ao_total = _ao_w_total

int ao_eff_len = _ao_w_total > 0
     ? math.round((float(ao_len_s) * _ao_w_s + float(ao_len_m) * _ao_w_m + float(ao_len_l) * _ao_w_l) / _ao_w_total)
     : ao_len_m

// ── Apply Override ───────────────────────────────────────────────────────────
if eff_ao_enable
    _prism_len := ao_eff_len

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7B │ PRISM SIGNAL GENERATION
// ═══════════════════════════════════════════════════════════════════════════════

[prism_poly, prism_c0, prism_c1, prism_c2, prism_c3, prism_c4] = prism_calcPoly(prism_source, _prism_len, prism_degree)
[prism_st1_line, prism_st1_dir] = prism_calcST(prism_poly, prism_st1_factor, _prism_st1_per)
[prism_st2_line, prism_st2_dir] = prism_calcST(prism_poly, prism_st2_factor, _prism_st2_per)

var int prism_last_dir = 1
if prism_st1_dir == -1 and prism_st2_dir == -1
    prism_last_dir := -1
else if prism_st1_dir == 1 and prism_st2_dir == 1
    prism_last_dir := 1
int prism_cur_dir = prism_last_dir

bool prism_now_bull = prism_st1_dir == -1 and prism_st2_dir == -1
bool prism_now_bear = prism_st1_dir ==  1 and prism_st2_dir ==  1
bool prism_was_bull = prism_st1_dir[1] == -1 and prism_st2_dir[1] == -1
bool prism_was_bear = prism_st1_dir[1] ==  1 and prism_st2_dir[1] ==  1
bool prism_raw_bull = prism_now_bull and not prism_was_bull
bool prism_raw_bear = prism_now_bear and not prism_was_bear

// ── Bar Quality ───────────────────────────────────────────────────────────────
float prism_bq_ratio   = math.abs(close - open) / math.max(high - low, 1e-10)
bool  prism_bq_bull_ok = close >= open and prism_bq_ratio >= prism_bq_min_ratio
bool  prism_bq_bear_ok = close <= open and prism_bq_ratio >= prism_bq_min_ratio

// ── Structure Lock ────────────────────────────────────────────────────────────
bool _prism_cma_crossover  = ta.crossover(cma1, cma2)
bool _prism_cma_crossunder = ta.crossunder(cma1, cma2)
bool prism_ribbon_adverse_bull = prism_ribbon_filt_enable and cma1 < cma2 and (cma2-cma1) > (cma2[1]-cma1[1])
bool prism_ribbon_adverse_bear = prism_ribbon_filt_enable and cma1 > cma2 and (cma1-cma2) > (cma1[1]-cma2[1])

var int prism_bull_hold_until = -1, var int prism_bear_hold_until = -1

if prism_raw_bull
    prism_bear_hold_until := -1
if prism_raw_bear
    prism_bull_hold_until := -1
if prism_raw_bull
    prism_bull_hold_until := prism_ribbon_adverse_bull ? bar_index + 4 : -1
if prism_raw_bear
    prism_bear_hold_until := prism_ribbon_adverse_bear ? bar_index + 4 : -1

bool prism_bull_in_hold  = prism_bull_hold_until > 0 and bar_index <= prism_bull_hold_until
bool prism_bear_in_hold  = prism_bear_hold_until > 0 and bar_index <= prism_bear_hold_until
bool prism_bull_released = prism_bull_in_hold and _prism_cma_crossover
bool prism_bear_released = prism_bear_in_hold and _prism_cma_crossunder

if prism_bull_released
    prism_bull_hold_until := -1
if prism_bear_released
    prism_bear_hold_until := -1

// ── Deduplication ─────────────────────────────────────────────────────────────
var int prism_last_sig = 0

bool prism_imm_bull = prism_raw_bull and not prism_ribbon_adverse_bull
     and prism_last_sig != 1  and (not prism_bq_enable or prism_bq_bull_ok)
bool prism_imm_bear = prism_raw_bear and not prism_ribbon_adverse_bear
     and prism_last_sig != -1 and (not prism_bq_enable or prism_bq_bear_ok)

// ── Bar Quality Hold ──────────────────────────────────────────────────────────
var int prism_bq_bull_hold_until = -1, var int prism_bq_bear_hold_until = -1

if prism_raw_bear
    prism_bq_bull_hold_until := -1
if prism_raw_bull
    prism_bq_bear_hold_until := -1
if prism_raw_bull and not prism_ribbon_adverse_bull and prism_last_sig != 1  and prism_bq_enable and not prism_bq_bull_ok
    prism_bq_bull_hold_until := bar_index + 3
if prism_raw_bear and not prism_ribbon_adverse_bear and prism_last_sig != -1 and prism_bq_enable and not prism_bq_bear_ok
    prism_bq_bear_hold_until := bar_index + 3

bool prism_bq_bull_in_hold  = prism_bq_bull_hold_until > 0 and bar_index <= prism_bq_bull_hold_until
bool prism_bq_bear_in_hold  = prism_bq_bear_hold_until > 0 and bar_index <= prism_bq_bear_hold_until
bool prism_bq_bull_released = prism_bq_bull_in_hold and prism_bq_bull_ok
bool prism_bq_bear_released = prism_bq_bear_in_hold and prism_bq_bear_ok

if prism_bq_bull_released
    prism_bq_bull_hold_until := -1
if prism_bq_bear_released
    prism_bq_bear_hold_until := -1

// ── pre-Quality Gate ─────────────────────────────────────────────
bool eff_prism_enable = IS_SIMPLE ? sim_prism_enable : prism_enable

bool prism_would_bull = eff_prism_enable and (prism_imm_bull or prism_bull_released or prism_bq_bull_released)
bool prism_would_bear = eff_prism_enable and (prism_imm_bear or prism_bear_released or prism_bq_bear_released)

if prism_raw_bull
    prism_last_sig := 1
if prism_raw_bear
    prism_last_sig := -1

// ── Quality Gate ──────────────────────────────────────────────────────────────
float prism_er_signal  = math.abs(close - close[prism_er_len])
float prism_er_noise   = math.sum(math.abs(close - close[1]), prism_er_len)
float prism_er         = prism_er_noise > 0.0 ? prism_er_signal / prism_er_noise : 0.0

float prism_fkama      = f_kama_vb(close, prism_fast_kama_len)
float prism_fkama_norm = ATR14 > 0.0
     ? (prism_fkama - prism_fkama[prism_fkama_slope_len]) / ATR14 : 0.0

bool prism_mq_chop_bull = prism_mq_enable and prism_er < prism_er_thresh and prism_fkama_norm < prism_fast_kama_slope
bool prism_mq_chop_bear = prism_mq_enable and prism_er < prism_er_thresh and prism_fkama_norm > -prism_fast_kama_slope

// ── Quality Gate + Trend Regime Gate ──────────────────────────────────────────
bool prism_is_mq_bull = prism_would_bull and (prism_mq_chop_bull or trg_suppress_buy)
bool prism_is_mq_bear = prism_would_bear and (prism_mq_chop_bear or trg_suppress_sell)

// ── Elevation Criteria ────────────────────────────────────────────────────────
bool prism_ct_bull = tc_base < tc_base[1] and cma1 < cma2
bool prism_ct_bear = tc_base > tc_base[1] and cma1 > cma2

// ── Quadratic Regression Fit for TC Reversal ──────────────────────────────────
// Throttle to every 4 bars
f_quadFit(float src, int len) =>
    float lenM1 = float(len - 1)
    float sy=0., sx=0., sx2=0., sx3=0., sx4=0., sxy=0., sx2y=0.
    for i = 0 to len - 1
        float x = float(i) / lenM1, float y = src[len - 1 - i]
        float x2 = x * x
        sy += y, sx += x, sx2 += x2, sx3 += x2*x, sx4 += x2*x2
        sxy += x*y, sx2y += x2*y
    float n = float(len)
    matrix<float> A = matrix.new<float>(3, 4, 0.0)
    matrix.set(A,0,0,n),    matrix.set(A,0,1,sx),  matrix.set(A,0,2,sx2), matrix.set(A,0,3,sy)
    matrix.set(A,1,0,sx),   matrix.set(A,1,1,sx2), matrix.set(A,1,2,sx3), matrix.set(A,1,3,sxy)
    matrix.set(A,2,0,sx2),  matrix.set(A,2,1,sx3), matrix.set(A,2,2,sx4), matrix.set(A,2,3,sx2y)
    for col = 0 to 1
        int pRow = col, float pMax = math.abs(matrix.get(A,col,col))
        for row = col+1 to 2
            float v = math.abs(matrix.get(A,row,col))
            if v > pMax
                pMax := v, pRow := row
        if pRow != col
            for k = 0 to 3
                float tmp = matrix.get(A,col,k)
                matrix.set(A,col,k, matrix.get(A,pRow,k)), matrix.set(A,pRow,k,tmp)
        float piv = matrix.get(A,col,col)
        if math.abs(piv) > 1e-10
            for row = col+1 to 2
                float f = matrix.get(A,row,col) / piv
                for k = col to 3
                    matrix.set(A,row,k, matrix.get(A,row,k) - f*matrix.get(A,col,k))
    array<float> co = array.new_float(3, 0.0)
    for ii = 0 to 2
        int r = 2-ii, float val = matrix.get(A,r,3)
        if r+1 <= 2
            for c = r+1 to 2
                val -= matrix.get(A,r,c) * array.get(co,c)
        float diag = matrix.get(A,r,r)
        array.set(co, r, math.abs(diag) > 1e-10 ? val/diag : 0.0)
    [array.get(co,0), array.get(co,1), array.get(co,2)]

int   _elev_lookback = 25
var float _elev_c0 = 0.0
var float _elev_c1 = 0.0
var float _elev_c2 = 0.0
if bar_index % 4 == 0
    [_qc0, _qc1, _qc2] = f_quadFit(tc_base, _elev_lookback)
    _elev_c0 := _qc0
    _elev_c1 := _qc1
    _elev_c2 := _qc2

float _elev_lenM1    = float(_elev_lookback - 1)
float _elev_vertex_x = math.abs(_elev_c2) > 1e-10 ? -_elev_c1 / (2.0 * _elev_c2) : na
float _elev_fc_near  = 1.0
float _elev_fc_far   = 1.0 + 8.0 / _elev_lenM1

bool elev_tc_rev_bull = not na(_elev_vertex_x) and _elev_c2 > 0
     and _elev_vertex_x >= _elev_fc_near and _elev_vertex_x <= _elev_fc_far
bool elev_tc_rev_bear = not na(_elev_vertex_x) and _elev_c2 < 0
     and _elev_vertex_x >= _elev_fc_near and _elev_vertex_x <= _elev_fc_far

// ── Criterion 1: CT Signal + TC Reversal Forecast ─────────────────────────────
bool elev_c1_bull = prism_ct_bull and elev_tc_rev_bull
bool elev_c1_bear = prism_ct_bear and elev_tc_rev_bear

// ── Criterion 2: Strong Trend Alignment (with-trend only) ────────────────────
bool elev_c2_bull = not prism_ct_bull
     and tc_base > tc_base[1]
     and (tc_k50 - tc_k50[1]) > (tc_base - tc_base[1])
     and close > tc_base

bool elev_c2_bear = not prism_ct_bear
     and tc_base < tc_base[1]
     and (tc_k50 - tc_k50[1]) < (tc_base - tc_base[1])
     and close < tc_base

// ── Criterion 3: TC Bounce (with-trend only) ──────────────────────────────────
float _elev_low  = cv_use_custom ? cv_l : low
float _elev_high = cv_use_custom ? cv_h : high

bool elev_c3_bull = not prism_ct_bull
     and tc_base > tc_base[1]
     and prism_bq_bull_ok
     and math.abs(_elev_low - tc_base) <= ATR14 * 0.5

bool elev_c3_bear = not prism_ct_bear
     and tc_base < tc_base[1]
     and prism_bq_bear_ok
     and math.abs(_elev_high - tc_cloud_top) <= ATR14 * 0.5

// ── Criterion 4: Very Strong Cumulative CVD (with-trend only) ─────────────────
bool elev_c4_bull = not prism_ct_bull and cvd_rank >= 95.0 and cvd_net > 0
bool elev_c4_bear = not prism_ct_bear and cvd_rank >= 95.0 and cvd_net < 0

// ── Elevation: any criterion upgrades the MQ dot to a full B/S ───────────────
bool prism_elev_bull = prism_is_mq_bull and (elev_c1_bull or elev_c2_bull or elev_c3_bull or elev_c4_bull)
bool prism_elev_bear = prism_is_mq_bear and (elev_c1_bear or elev_c2_bear or elev_c3_bear or elev_c4_bear)

// ── Final Signals ─────────────────────────────────────────────────────────────
bool prism_is_bull = (prism_would_bull and not prism_is_mq_bull) or prism_elev_bull
bool prism_is_bear = (prism_would_bear and not prism_is_mq_bear) or prism_elev_bear

float prism_ref_high   = cv_use_custom ? cv_h : high
float prism_ref_low    = cv_use_custom ? cv_l : low
float prism_atr_offset = ATR14 * prism_sig_offset
float prism_bull_y     = prism_is_bull    ? prism_ref_low  - prism_atr_offset : na
float prism_bear_y     = prism_is_bear    ? prism_ref_high + prism_atr_offset : na
float prism_bull_mq_y  = (prism_is_mq_bull and not prism_elev_bull) ? prism_ref_low  - prism_atr_offset : na
float prism_bear_mq_y  = (prism_is_mq_bear and not prism_elev_bear) ? prism_ref_high + prism_atr_offset : na

color prism_mq_bull_col = SIG_BULL
color prism_mq_bear_col = SIG_BEAR

bool prism_is_small = prism_sig_size == 'Small'


// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 │ BOUNDARY FORECAST
// ═══════════════════════════════════════════════════════════════════════════════

var string GRP_FORECAST = '━━━  BOUNDARY FORECAST  ━━━'

forecast_enable   = input.bool(true, 'Enable Boundary Forecast', group = GRP_FORECAST,
     tooltip = 'Projects the Trend Cloud and Super Channel bands a few bars into the future. Think of it as a "where are the boundaries likely heading" guide. The projections fade the further out they go to show decreasing confidence.')
forecast_horizon  = input.int(10, 'Forecast Horizon (bars)', minval = 1, maxval = 20, group = GRP_FORECAST,
     tooltip = 'Sets how many bars into the future the forecast lines extend. A smaller number keeps the projection tight and less speculative. A larger number shows a longer potential path but with less reliability the further out you go.')
forecast_lookback = input.int(25, 'Regression Lookback', minval = 10, maxval = 50, group = GRP_FORECAST)
forecast_mode     = input.string('Slope Extension', 'Forecast Mode', options = ['Regression', 'Slope Extension'], group = GRP_FORECAST,
     tooltip = "'Regression' fits a curve to recent boundary movement and projects it forward — it can show bends or potential turns ahead. 'Slope Extension' simply continues the current direction in a straight line. Use Regression for a nuanced read, Slope Extension for a simpler projection.")
forecast_sc_enable = input.bool(true,  'Show Projected SC Bands', group = GRP_FORECAST)
forecast_tc_enable = input.bool(true,  'Show Projected TC Bands', group = GRP_FORECAST)

f_cubicFit(float src, int len) =>
    float lenM1 = float(len - 1)
    float sy=0., sx1=0., sx2=0., sx3=0., sx4=0., sx5=0., sx6=0., sxy=0., sx2y=0., sx3y=0.
    for i = 0 to len - 1
        float x = float(i)/lenM1, float y = src[len-1-i], float x2=x*x, float x3=x2*x
        sy+=y, sx1+=x, sx2+=x2, sx3+=x3, sx4+=x2*x2, sx5+=x2*x3, sx6+=x3*x3
        sxy+=x*y, sx2y+=x2*y, sx3y+=x3*y
    float fn = float(len)
    matrix<float> A = matrix.new<float>(4, 5, 0.0)
    array<float> rs = array.from(fn,sx1,sx2,sx3,sx4,sx5,sx6)
    array<float> rhs = array.from(sy,sxy,sx2y,sx3y)
    for r = 0 to 3
        for c = 0 to 3
            matrix.set(A,r,c,array.get(rs,r+c))
        matrix.set(A,r,4,array.get(rhs,r))
    for col = 0 to 2
        int pRow=col, float pMax=math.abs(matrix.get(A,col,col))
        for row = col+1 to 3
            float v=math.abs(matrix.get(A,row,col))
            if v > pMax
                pMax:=v, pRow:=row
        if pRow != col
            for k = 0 to 4
                float tmp=matrix.get(A,col,k)
                matrix.set(A,col,k,matrix.get(A,pRow,k)), matrix.set(A,pRow,k,tmp)
        float piv=matrix.get(A,col,col)
        if math.abs(piv) > 1e-10
            for row = col+1 to 3
                float f=matrix.get(A,row,col)/piv
                for k = col to 4
                    matrix.set(A,row,k, matrix.get(A,row,k)-f*matrix.get(A,col,k))
    array<float> co = array.new_float(4, 0.0)
    for ii = 0 to 3
        int r=3-ii, float val=matrix.get(A,r,4)
        if r+1 <= 3
            for c = r+1 to 3
                val -= matrix.get(A,r,c)*array.get(co,c)
        float diag=matrix.get(A,r,r)
        array.set(co,r, math.abs(diag)>1e-10 ? val/diag : 0.0)
    [array.get(co,0), array.get(co,1), array.get(co,2), array.get(co,3)]

f_evalCubic(float x, float c0, float c1, float c2, float c3) =>
    c0 + c1*x + c2*x*x + c3*x*x*x

bool eff_cma_enable = IS_SIMPLE ? sim_cma_enable      : cma_enable
bool eff_sc_enable  = IS_SIMPLE ? sim_sc_enable       : sc_enable
bool eff_tc_enable  = IS_SIMPLE ? sim_tc_enable       : tc_enable
bool eff_bfc_enable = IS_SIMPLE ? sim_forecast_enable : forecast_enable

// Throttle f_cubicFit to every 3 bars
float _fc_lr_tc_b0 = ta.linreg(tc_base,      forecast_lookback, 0)
float _fc_lr_tc_b1 = ta.linreg(tc_base,      forecast_lookback, 1)
float _fc_lr_tc_t0 = ta.linreg(tc_cloud_top, forecast_lookback, 0)
float _fc_lr_tc_t1 = ta.linreg(tc_cloud_top, forecast_lookback, 1)

var float _fc_sc_c0t = 0.0, var float _fc_sc_c1t = 0.0
var float _fc_sc_c2t = 0.0, var float _fc_sc_c3t = 0.0
var float _fc_sc_c0b = 0.0, var float _fc_sc_c1b = 0.0
var float _fc_sc_c2b = 0.0, var float _fc_sc_c3b = 0.0

if bar_index % 3 == 0
    [_ct0, _ct1, _ct2, _ct3] = f_cubicFit(sc_top, forecast_lookback)
    [_cb0, _cb1, _cb2, _cb3] = f_cubicFit(sc_bot, forecast_lookback)
    _fc_sc_c0t := _ct0, _fc_sc_c1t := _ct1, _fc_sc_c2t := _ct2, _fc_sc_c3t := _ct3
    _fc_sc_c0b := _cb0, _fc_sc_c1b := _cb1, _fc_sc_c2b := _cb2, _fc_sc_c3b := _cb3


// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Layer 1a: Trend Cloud Base Glow ──────────────────────────────────────────
plot(eff_tc_enable and glow_tc_enable ? tc_base : na,
     color = color.new(tc_base_col, 80), linewidth = 10, title = 'TC Base Glow 1')
plot(eff_tc_enable and glow_tc_enable ? tc_base : na,
     color = color.new(tc_base_col, 90), linewidth = 20, title = 'TC Base Glow 2')
plot(eff_tc_enable and glow_tc_enable ? tc_base : na,
     color = color.new(tc_base_col, 95), linewidth = 30, title = 'TC Base Glow 3')
plot(eff_tc_enable and glow_tc_enable ? tc_base : na,
     color = color.new(tc_base_col, 98), linewidth = 45, title = 'TC Base Glow 4')

// ── Layer 1b: Trend Cloud ─────────────────────────────────────────────────────
tc_p_base = plot(
     eff_tc_enable ? tc_base      : na, title = 'Trend Cloud Base',
     color = tc_base_col, linewidth = 3)
tc_p_top  = plot(
     eff_tc_enable and tc_body_enable ? tc_cloud_top : na, title = 'Trend Cloud Top',
     color = tc_line_col, linewidth = 2)
fill(tc_p_base, tc_p_top,
     color = eff_tc_enable and tc_body_enable ? tc_trend_col : na,
     title = 'Trend Cloud Fill')

// ── Layer 2: Super Channel ────────────────────────────────────────────────────
sc_p_top = plot(
     eff_sc_enable ? sc_top : na, title = 'Super Channel Top',
     color = sc_top_color, linewidth = 2)
sc_p_bot = plot(
     eff_sc_enable ? sc_bot : na, title = 'Super Channel Bottom',
     color = sc_bot_color, linewidth = 2)
fill(sc_p_top, sc_p_bot,
     color = eff_sc_enable ? sc_fill_color : na,
     title = 'Super Channel Fill')

// ── Layer 3: Moving Average Ribbon ───────────────────────────────────────────
p_cma1 = plot(
     eff_cma_enable ? cma1 : na, title = 'Moving Average Ribbon Line 1',
     color = cma_line1_col, linewidth = 2)
p_cma2 = plot(
     eff_cma_enable ? cma2 : na, title = 'Moving Average Ribbon Line 2',
     color = cma_line2_col, linewidth = 2)
fill(p_cma1, p_cma2,
     color = eff_cma_enable ? cma_fill_color : na,
     title = 'Moving Average Ribbon Fill')

// ── Layer 4: Candles ──────────────────────────────────────────────────────────
color _cv_plot_body = na
color _cv_plot_wick = na
if eff_candle_col_enable
    _cv_plot_body := candle_color_out
    _cv_plot_wick := color.new(candle_color_out, 20)
else
    _cv_plot_body := cv_body_final
    _cv_plot_wick := cv_body_final

plotcandle(
     cv_use_custom ? cv_o : na, cv_use_custom ? cv_h : na,
     cv_use_custom ? cv_l : na, cv_use_custom ? cv_c : na,
     title = 'Custom Candles', color = _cv_plot_body,
     wickcolor = _cv_plot_wick, bordercolor = cvd_border_color)

barcolor(
     not cv_use_custom and eff_candle_col_enable ? candle_color_out : na,
     title = 'Chart Candle Color')

plotcandle(
     not cv_use_custom ? open : na, not cv_use_custom ? high : na,
     not cv_use_custom ? low  : na, not cv_use_custom ? close : na,
     title = 'CVD Border',
     color = color.new(color.black, 100), wickcolor = color.new(color.black, 100),
     bordercolor = eff_cvd_enable ? cvd_border_color : color.new(color.black, 100))

// ── Layer 5: PRISM Signal Labels ─────────────────────────────────────────────
string prism_lbl_size = prism_is_small ? size.small : size.normal

if prism_is_bull
    label.new(bar_index, prism_bull_y, text = 'B', style = label.style_label_up,
         color = SIG_BULL, textcolor = SIG_TEXT, size = prism_lbl_size)
if prism_is_bear
    label.new(bar_index, prism_bear_y, text = 'S', style = label.style_label_down,
         color = SIG_BEAR, textcolor = SIG_TEXT, size = prism_lbl_size)

plotshape(prism_bull_mq_y, 'PRISM Quality Gate Bull', shape.circle, location.absolute, prism_mq_bull_col, size = size.small)
plotshape(prism_bear_mq_y, 'PRISM Quality Gate Bear', shape.circle, location.absolute, prism_mq_bear_col, size = size.small)


// ═══════════════════════════════════════════════════════════════════════════════
// INFO PANEL
// ═══════════════════════════════════════════════════════════════════════════════

if info_enable
    var table info_tbl = table.new(
         position = _info_pos, columns = 2, rows = 25,
         bgcolor = color.new(color.black, 78), frame_color = color.new(NEUT, 55),
         frame_width = 1, border_color = color.new(NEUT, 80), border_width = 1)

    bool   _bias_bull  = prism_cur_dir == -1
    bool   _st_bull    = cma1 > cma2
    bool   _mt_bull    = tc_k20 > tc_k20[1]
    bool   _lt_bull    = tc_base > tc_base[1]
    float  _delta_avg  = (cvd_rank + nz(cvd_rank[1]) + nz(cvd_rank[2])) / 3.0
    bool   _mom_rising = SRSI_K > SRSI_K[1]

    string _mom_state = SRSI_K >= 80.0 and _mom_rising  ? 'Rising & OB'  :
         SRSI_K <= 20.0 and not _mom_rising              ? 'Falling & OS' :
         _mom_rising                                      ? 'Rising'       : 'Falling'

    string _vol_state = sc_cco >= SC_HI_THRESH          ? 'Overbought'      :
         sc_cco >= 60.0  ? 'Near Overbought' : sc_cco > 40.0 ? 'Normal Range' :
         sc_cco > SC_LO_THRESH ? 'Near Oversold'              : 'Oversold'

    string _er_state = prism_er >= 0.6  ? 'Strong Trend' : prism_er >= 0.45 ? 'Trending' :
         prism_er >= 0.3 ? 'Mixed'       : prism_er >= 0.15 ? 'Noisy'        : 'Very Noisy'

    color _lbl = color.new(color.white, 50), color _hdr_text = color.new(color.white, 5)
    color _hdr_bg = color.new(NEUT, 82), color _cell_bg = color.new(color.black, 100)
    color _bull_val = color.new(BULL, 0), color _bear_val = color.new(BEAR, 0)
    color _neut_val = color.new(color.white, 20), color _hilight_val = color.new(HILIGHT, 0)
    color _dim_bull = color.new(BULL, 40), color _dim_bear = color.new(BEAR, 40)

    color _mom_col = _mom_state == 'Rising & OB' ? _bear_val : _mom_state == 'Falling & OS' ? _bull_val :
         _mom_state == 'Rising' ? _bull_val : _bear_val
    color _vol_col = _vol_state == 'Overbought' ? _bear_val : _vol_state == 'Near Overbought' ? _dim_bear :
         _vol_state == 'Normal Range' ? _neut_val : _vol_state == 'Near Oversold' ? _dim_bull : _bull_val
    color _er_col  = _er_state == 'Strong Trend' ? _hilight_val : _er_state == 'Trending' ? _bull_val :
         _er_state == 'Mixed' ? _neut_val : _er_state == 'Noisy' ? _dim_bear : _bear_val
    color _delta_col = _delta_avg >= 80.0 ? _hilight_val : _delta_avg >= 60.0 ? _bull_val :
         _delta_avg >= 40.0 ? _neut_val : _dim_bear

    table.cell(info_tbl, 0, 0, ' TREND STATE',        text_color=_hdr_text, text_size=size.small, text_halign=text.align_left, bgcolor=_hdr_bg)
    table.cell(info_tbl, 1, 0, '',                                                                                               bgcolor=_hdr_bg)
    table.cell(info_tbl, 0, 1, ' Immediate Bias',      text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 1, _bias_bull?'Bullish ':'Bearish ', text_color=_bias_bull?_bull_val:_bear_val, text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 2, ' Short Term',          text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 2, _st_bull?'Bullish ':'Bearish ',   text_color=_st_bull?_bull_val:_bear_val,   text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 3, ' Medium Term',         text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 3, _mt_bull?'Bullish ':'Bearish ',   text_color=_mt_bull?_bull_val:_bear_val,   text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 4, ' Long Term',           text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 4, _lt_bull?'Bullish ':'Bearish ',   text_color=_lt_bull?_bull_val:_bear_val,   text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 5, ' MOMENTUM & QUALITY',  text_color=_hdr_text, text_size=size.small, text_halign=text.align_left, bgcolor=_hdr_bg)
    table.cell(info_tbl, 1, 5, '',                                                                                               bgcolor=_hdr_bg)
    table.cell(info_tbl, 0, 6, ' Delta Strength',      text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 6, str.tostring(math.round(_delta_avg))+'% ', text_color=_delta_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 7, ' Momentum State',      text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 7, _mom_state+' ',         text_color=_mom_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 8, ' Volatility Range',    text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 8, _vol_state+' ',         text_color=_vol_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 9, ' Trend Efficiency',    text_color=_lbl,      text_size=size.small, text_halign=text.align_left, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 9, _er_state+' ',          text_color=_er_col,   text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)

    // ── Trend Regime section ──────────────────────────────────────────────────
    string _trg_regime = trg_suppress_sell ? 'Bull Regime' :
         trg_suppress_buy  ? 'Bear Regime' : 'No Regime'
    color _trg_regime_col = trg_suppress_sell ? _bull_val :
         trg_suppress_buy  ? _bear_val : _neut_val

    string _trg_hurst_str = trg_hurst > 0.55 ? 'Trending' : trg_hurst < 0.45 ? 'Mean Reverting' : 'Mixed'
    color  _trg_hurst_col = trg_hurst > 0.55 ? _hilight_val : trg_hurst < 0.45 ? _bear_val : _neut_val

    float _trg_ka_pct = math.max(trg_ka_bull_pct, trg_ka_bear_pct)
    string _trg_ka_str = _trg_ka_pct >= 0.78 ? 'High' : _trg_ka_pct >= 0.56 ? 'Moderate' : 'Low'
    color  _trg_ka_col = math.max(trg_ka_bull_pct, trg_ka_bear_pct) >= _trg_ka_th
         ? _hilight_val : _neut_val

    string _trg_accel_str = trg_tc_accel_smooth > 0.001 ? 'Accelerating' :
         trg_tc_accel_smooth < -0.001 ? 'Decelerating' : 'Steady'
    color  _trg_accel_col = trg_tc_accel_smooth > 0.001 and tc_base > tc_base[1] ? _bull_val :
         trg_tc_accel_smooth < -0.001 and tc_base < tc_base[1] ? _bear_val :
         trg_tc_accel_smooth > 0.001 ? _dim_bull :
         trg_tc_accel_smooth < -0.001 ? _dim_bear : _neut_val

    table.cell(info_tbl, 0, 11, ' TREND REGIME',        text_color=_hdr_text,       text_size=size.small, text_halign=text.align_left,  bgcolor=_hdr_bg)
    table.cell(info_tbl, 1, 11, '',                                                                                                      bgcolor=_hdr_bg)
    table.cell(info_tbl, 0, 12, ' Regime State',         text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 12, _trg_regime+' ',         text_color=_trg_regime_col, text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 13, ' Trend Alignment',       text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 13, _trg_ka_str+' ',         text_color=_trg_ka_col,     text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 14, ' Market Character',       text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 14, _trg_hurst_str+' ',      text_color=_trg_hurst_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 15, ' Trend Momentum',      text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 15, _trg_accel_str+' ',      text_color=_trg_accel_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)

    // ── PRISM Adaptive section ────────────────────────────────────────────────
    string _adapt_mode = _eff_adaptive and _eff_ns ? 'Adaptive + NS' :
         _eff_adaptive ? 'Adaptive' : _eff_ns ? 'Noise Supp' : 'Fixed'
    color  _adapt_mode_col = _eff_adaptive or _eff_ns ? _bull_val : _neut_val

    string _adapt_len_str = str.tostring(_prism_len)
    color  _adapt_len_col = _prism_len > prism_length ? _hilight_val :
         _prism_len == prism_length ? _neut_val : _dim_bull

    string _adapt_rails_str = str.tostring(_prism_st1_per) + ' / ' + str.tostring(_prism_st2_per)
    color  _adapt_rails_col = _prism_st1_per > prism_st1_period ? _hilight_val : _neut_val

    string _adapt_er_str = str.tostring(math.round(_prism_er_smo * 100.0)) + '%'
    color  _adapt_er_col = _prism_er_smo >= 0.5 ? _bull_val :
         _prism_er_smo >= 0.2 ? _neut_val : _bear_val

    table.cell(info_tbl, 0, 16, ' PRISM ADAPTIVE',        text_color=_hdr_text,       text_size=size.small, text_halign=text.align_left,  bgcolor=_hdr_bg)
    table.cell(info_tbl, 1, 16, '',                                                                                                         bgcolor=_hdr_bg)
    table.cell(info_tbl, 0, 17, ' Mode',                   text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 17, _adapt_mode+' ',           text_color=_adapt_mode_col, text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 18, ' Eff. Lookback',        text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 18, _adapt_len_str+' ',        text_color=_adapt_len_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 19, ' Eff. Rails (α/σ)',       text_color=_lbl,            text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 19, _adapt_rails_str+' ',      text_color=_adapt_rails_col,text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)

    // ── Auto-Optimizer section ────────────────────────────────────────────────
    int _ao_count_s = array.size(ao_scores_s)
    int _ao_count_m = array.size(ao_scores_m)
    int _ao_count_l = array.size(ao_scores_l)

    string _ao_status = eff_ao_enable ? (ao_total > 0 ? 'Active' : 'Warming Up') : 'Disabled'
    color  _ao_status_col = eff_ao_enable ? (ao_total > 0 ? _bull_val : _dim_bull) : _neut_val

    string _ao_lens_str = str.tostring(ao_len_s) + ' / ' + str.tostring(ao_len_m) + ' / ' + str.tostring(ao_len_l)

    string _ao_scores_str = str.tostring(math.round(_ao_avg_s * 100) / 100.0) + ' / ' + str.tostring(math.round(_ao_avg_m * 100) / 100.0) + ' / ' + str.tostring(math.round(_ao_avg_l * 100) / 100.0)
    color _ao_scores_col = ao_sum_l >= ao_sum_m and ao_sum_l >= ao_sum_s ? _hilight_val :
         ao_sum_s >= ao_sum_m ? _dim_bull : _neut_val

    string _ao_eff_str = str.tostring(ao_eff_len)
    color  _ao_eff_col = ao_eff_len > ao_len_m ? _hilight_val :
         ao_eff_len < ao_len_m ? _dim_bull : _neut_val

    string _ao_sigs_str = str.tostring(_ao_count_s) + ' / ' + str.tostring(_ao_count_m) + ' / ' + str.tostring(_ao_count_l)
    color  _ao_sigs_col = math.min(_ao_count_s, math.min(_ao_count_m, _ao_count_l)) >= ao_lookback
         ? _bull_val : _dim_bull

    table.cell(info_tbl, 0, 20, ' AUTO-OPTIMIZER',      text_color=_hdr_text,       text_size=size.small, text_halign=text.align_left,  bgcolor=_hdr_bg)
    table.cell(info_tbl, 1, 20, '',                                                                                                       bgcolor=_hdr_bg)
    table.cell(info_tbl, 0, 21, ' Status',               text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 21, _ao_status+' ',          text_color=_ao_status_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 22, ' Test Lengths',          text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 22, _ao_lens_str+' ',         text_color=_neut_val,       text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    table.cell(info_tbl, 0, 23, ' Scores (S/M/L)',        text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 23, _ao_scores_str+' ',       text_color=_ao_scores_col,  text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)
    int   _ao_adj        = ao_eff_len - ao_len_m
    string _ao_adj_str   = (_ao_adj > 0 ? '+' : '') + str.tostring(_ao_adj)
    color  _ao_adj_col   = _ao_adj > 0 ? _hilight_val : _ao_adj < 0 ? _dim_bull : _neut_val

    table.cell(info_tbl, 0, 24, ' Length Adjustment',     text_color=_lbl,            text_size=size.small, text_halign=text.align_left,  bgcolor=_cell_bg)
    table.cell(info_tbl, 1, 24, _ao_adj_str+' ',          text_color=_ao_adj_col,     text_size=size.small, text_halign=text.align_right, bgcolor=_cell_bg)

// ═══════════════════════════════════════════════════════════════════════════════
// BOUNDARY FORECAST DRAWING
// ═══════════════════════════════════════════════════════════════════════════════

var array<line>     _bfc_lines = array.new<line>()
var array<linefill> _bfc_fills = array.new<linefill>()

if barstate.islast
    for l  in _bfc_lines
        line.delete(l)
    for lf in _bfc_fills
        linefill.delete(lf)
    array.clear(_bfc_lines)
    array.clear(_bfc_fills)

    if eff_bfc_enable
        int   fc_h     = forecast_horizon
        int   fc_lb    = forecast_lookback
        float fc_lenM1 = float(fc_lb - 1)
        bool  fc_slope = forecast_mode == 'Slope Extension'

        if forecast_tc_enable
            float fc_tc_b_slope = fc_slope ? (tc_base      - tc_base[fc_lb-1])      / fc_lenM1 : _fc_lr_tc_b0 - _fc_lr_tc_b1
            float fc_tc_t_slope = fc_slope ? (tc_cloud_top - tc_cloud_top[fc_lb-1]) / fc_lenM1 : _fc_lr_tc_t0 - _fc_lr_tc_t1
            float fc_prev_b = tc_base, float fc_prev_t = tc_cloud_top
            for n = 1 to fc_h
                float fc_fn = float(n)
                float fc_cur_b = tc_base      + fc_tc_b_slope * fc_fn
                float fc_cur_t = tc_cloud_top + fc_tc_t_slope * fc_fn
                float fc_t      = fc_h > 1 ? float(n-1)/float(fc_h-1) : 0.0
                int   fc_base_t = math.round(15 + fc_t*55)
                int   fc_top_t  = math.round(35 + fc_t*45)
                int   fc_fill_t = math.round(75 + fc_t*20)
                line fc_lb_line = line.new(bar_index+n-1,fc_prev_b, bar_index+n,fc_cur_b, color=color.new(NEUT,fc_base_t), width=2, style=line.style_solid,  extend=extend.none)
                line fc_lt_line = line.new(bar_index+n-1,fc_prev_t, bar_index+n,fc_cur_t, color=color.new(NEUT,fc_top_t),  width=1, style=line.style_dotted, extend=extend.none)
                array.push(_bfc_lines, fc_lb_line), array.push(_bfc_lines, fc_lt_line)
                array.push(_bfc_fills, linefill.new(fc_lt_line, fc_lb_line, color.new(NEUT, fc_fill_t)))
                fc_prev_b := fc_cur_b, fc_prev_t := fc_cur_t

        if forecast_sc_enable
            float fc_prev_t = sc_top, float fc_prev_b = sc_bot
            if fc_slope
                float fc_sct_slope = (sc_top - sc_top[fc_lb-1]) / fc_lenM1
                float fc_scb_slope = (sc_bot - sc_bot[fc_lb-1]) / fc_lenM1
                for n = 1 to fc_h
                    float fc_fn  = float(n)
                    float fc_sct = sc_top + fc_sct_slope * fc_fn
                    float fc_scb = sc_bot + fc_scb_slope * fc_fn
                    float fc_t      = fc_h > 1 ? float(n-1)/float(fc_h-1) : 0.0
                    int   fc_line_t = math.round(15 + fc_t*55)
                    int   fc_fill_t = math.round(88 + fc_t*9)
                    line fc_lt = line.new(bar_index+n-1,fc_prev_t, bar_index+n,fc_sct, color=color.new(BULL,fc_line_t), width=2, style=line.style_dashed, extend=extend.none)
                    line fc_lb = line.new(bar_index+n-1,fc_prev_b, bar_index+n,fc_scb, color=color.new(BEAR,fc_line_t), width=2, style=line.style_dashed, extend=extend.none)
                    array.push(_bfc_lines,fc_lt), array.push(_bfc_lines,fc_lb)
                    array.push(_bfc_fills, linefill.new(fc_lt, fc_lb, color.new(NEUT, fc_fill_t)))
                    fc_prev_t := fc_sct, fc_prev_b := fc_scb
            else
                float sc_c0t=_fc_sc_c0t, float sc_c1t=_fc_sc_c1t, float sc_c2t=_fc_sc_c2t, float sc_c3t=_fc_sc_c3t
                float sc_c0b=_fc_sc_c0b, float sc_c1b=_fc_sc_c1b, float sc_c2b=_fc_sc_c2b, float sc_c3b=_fc_sc_c3b
                for n = 1 to fc_h
                    float fc_x   = 1.0 + float(n)/fc_lenM1
                    float fc_sct = f_evalCubic(fc_x, sc_c0t,sc_c1t,sc_c2t,sc_c3t)
                    float fc_scb = f_evalCubic(fc_x, sc_c0b,sc_c1b,sc_c2b,sc_c3b)
                    float fc_t      = fc_h > 1 ? float(n-1)/float(fc_h-1) : 0.0
                    int   fc_line_t = math.round(15 + fc_t*55)
                    int   fc_fill_t = math.round(88 + fc_t*9)
                    line fc_lt = line.new(bar_index+n-1,fc_prev_t, bar_index+n,fc_sct, color=color.new(BULL,fc_line_t), width=2, style=line.style_dashed, extend=extend.none)
                    line fc_lb = line.new(bar_index+n-1,fc_prev_b, bar_index+n,fc_scb, color=color.new(BEAR,fc_line_t), width=2, style=line.style_dashed, extend=extend.none)
                    array.push(_bfc_lines,fc_lt), array.push(_bfc_lines,fc_lb)
                    array.push(_bfc_fills, linefill.new(fc_lt, fc_lb, color.new(NEUT, fc_fill_t)))
                    fc_prev_t := fc_sct, fc_prev_b := fc_scb

// ── Watermark ─────────────────────────────────────────────────────────────────
if barstate.islast
    var table wm = table.new(position.top_right, 1, 1)
    table.cell(wm, 0, 0, text = 'Trend Architect v9.1',
         text_color = color.new(HILIGHT, 55), text_size = size.normal,
         bgcolor = color.new(color.black, 100))


// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Full PRISM Signals ────────────────────────────────────────────────────────
alertcondition(prism_is_bull, title = 'PRISM Buy Signal',
     message = 'Trend Architect — PRISM Buy Signal fired. All filters passed. Check chart for context.')
alertcondition(prism_is_bear, title = 'PRISM Sell Signal',
     message = 'Trend Architect — PRISM Sell Signal fired. All filters passed. Check chart for context.')
alertcondition(prism_is_bull or prism_is_bear, title = 'PRISM Any Signal',
     message = 'Trend Architect — PRISM Signal fired. Check chart for direction and context.')

// ── Marginal (Quality Gate) Signals ──────────────────────────────────────────
bool _mq_bull_only = prism_is_mq_bull and not prism_elev_bull
bool _mq_bear_only = prism_is_mq_bear and not prism_elev_bear

alertcondition(_mq_bull_only, title = 'Marginal Buy Signal',
     message = 'Trend Architect — Marginal Buy Signal. Setup detected but market quality is poor. Proceed with caution.')
alertcondition(_mq_bear_only, title = 'Marginal Sell Signal',
     message = 'Trend Architect — Marginal Sell Signal. Setup detected but market quality is poor. Proceed with caution.')
alertcondition(_mq_bull_only or _mq_bear_only, title = 'Marginal Signal — Either Direction',
     message = 'Trend Architect — Marginal Signal fired. Quality Gate flagged weak conditions. Check chart for direction and context.')
alertcondition(prism_is_bull or prism_is_bear or _mq_bull_only or _mq_bear_only, title = 'Any Signal — PRISM and Marginal',
     message = 'Trend Architect — Signal fired (full or marginal). Check chart for direction and signal strength.')

// ── Ribbon ────────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(cma1, cma2),  title = 'Ribbon Bullish Crossover',
     message = 'Trend Architect — Moving Average Ribbon crossed bullish. Short-term momentum shifting up.')
alertcondition(ta.crossunder(cma1, cma2), title = 'Ribbon Bearish Crossover',
     message = 'Trend Architect — Moving Average Ribbon crossed bearish. Short-term momentum shifting down.')

// ── Super Channel ─────────────────────────────────────────────────────────────
alertcondition(ta.crossover(sc_cco, SC_HI_THRESH),  title = 'Super Channel Overbought',
     message = 'Trend Architect — Super Channel entered Overbought. Upper band is now highlighted on the chart.')
alertcondition(ta.crossunder(sc_cco, SC_LO_THRESH), title = 'Super Channel Oversold',
     message = 'Trend Architect — Super Channel entered Oversold. Lower band is now highlighted on the chart.')

// ── Trend Regime Gate ─────────────────────────────────────────────────────────
alertcondition(trg_suppress_sell and not trg_suppress_sell[1], title = 'Bull Regime Activated',
     message = 'Trend Architect — Bull Regime detected. Counter-trend sell signals suppressed.')
alertcondition(trg_suppress_buy and not trg_suppress_buy[1], title = 'Bear Regime Activated',
     message = 'Trend Architect — Bear Regime detected. Counter-trend buy signals suppressed.')
````
