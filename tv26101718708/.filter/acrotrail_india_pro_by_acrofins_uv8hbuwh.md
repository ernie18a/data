# AcroTrail India Pro - By Acrofins

- url: https://www.tradingview.com/script/Uv8HBUwH-AcroTrail-India-Pro-By-Acrofins/
- type: indicator
- pine_id: PUB;a647272cbc9449e89ac7469406d95d32
- version: 1.0

## Description

AcroTrail India Pro is a professional-grade trailing signal system built specifically for Indian markets — NSE indices, BSE indices, and NSE/BSE equities. Developed by Acrofins (Kiva Financial Services), it combines a high-quality trailing band engine with a multi-factor signal scoring system, full risk management levels, and India-specific session intelligence that most global indicators completely ignore.

What makes this different from generic trail indicators
Most trailing indicators give you a line and a signal. AcroTrail India Pro gives you a signal with a quality score, a grade, a risk/reward framework, and context about whether that signal should be trusted right now given the time of day, the market regime, and where we are in the expiry cycle.
It is built for how Indian markets actually behave, not how Western markets do.

Core engine
The trail is built on an ATR-based adaptive band with an EMA center. The band ratchets in the direction of the position, meaning it only tightens and never loosens during an active trade. Defaults are tuned for NSE intraday: ATR period 9 (vs the typical 14), a base multiplier of 2.0 for Nifty and 2.25 for BankNifty, and a 14-period trail EMA.
An optional adaptive volatility multiplier reads the 100-bar ATR percentile rank and automatically widens the band in high-volatility regimes and tightens it in low-volatility ones.

Dynamic Quality Score (0 to 100)
Every signal is scored across five components. The weights are not fixed. They shift automatically based on what is happening in the market right now.
HTF Bias checks whether the higher-timeframe trend aligns with the signal. On a 15-minute chart, it reads the 1-hour. On a daily chart, it reads the weekly. The score is graduated: full marks for alignment, partial for neutral, zero for opposition.
Volume confirms whether institutional participation is present. For index charts where TradingView reports zero volume, this weight is automatically redistributed to regime and HTF so the score stays meaningful.
RSI Momentum uses a gradient rather than a binary switch. A strong trending RSI scores full marks. A marginal RSI near the 50 line scores partial. An opposing RSI scores zero. This prevents overbought long signals from scoring the same as ideal momentum entries.
Market Regime combines ADX, Choppiness Index, and linear regression R-squared into a composite 0-100 regime score. Trending markets score high. Choppy markets score low. This score flows directly into the quality calculation.
Breakout Strength measures how decisively price pierced the trail band, capped at 3x ATR. Clean decisive breakouts score higher than marginal ones.
Signals are graded A (75 and above), B (55 to 74), or C (below 55). You can set a minimum quality threshold to filter out lower-conviction signals entirely.

Smart auto-adjust weight model
Three layers work together:
The base preset differs by instrument type. Index charts redistribute the volume weight (unavailable) to regime and HTF. Equity charts keep volume as a full component.
The auto-adjust layer shifts weights in real time based on session context. During the opening volatility window (09:15 to 09:45), HTF weight increases and breakout weight falls because gap-open band pierces are unreliable. During the expiry last-90-minute window, regime weight rises because IV-driven choppiness dominates. In high-volatility environments, regime rises and RSI falls.
The custom override layer lets you set your own weights via sliders if you want full control. The dashboard shows a live weight sum check to confirm your sliders add up correctly.

India-specific session intelligence
Session gate. Signals are blocked outside 09:15 to 15:30 IST. No false signals from pre-market or after-hours data.
Opening volatility window. Signals between 09:15 and 09:45 carry a ⚡ warning flag. This is the highest-noise window on NSE, where gap opens, institutional order flow, and retail panic all collide.
Expiry warning. Tuesday is Nifty and FinNifty expiry. Thursday is Sensex and BankNifty expiry. Signals during the last 90 minutes of those days (13:00 to 15:30) carry a 🔔 warning flag. Signals still appear so you can make your own judgment, but the flag tells you to apply extra scrutiny.
All three flags can appear together on the same signal. The dashboard also shows a live session status row so you always know which context you are trading in.

Risk management
Four presets: Conservative (SL 2.5x ATR), Balanced (SL 1.5x ATR, recommended for index), Aggressive (SL 1.0x ATR), and Scalping (SL 0.8x ATR). All three TP levels are expressed as R-multiples of the SL distance so the reward-to-risk relationship scales automatically with volatility.
Break-even option moves the stop to entry after TP1 is hit, letting the trade run to TP2 and TP3 risk-free. For intraday options trading, consider disabling this as IV spikes can trigger the BE stop before the real move to TP2 develops.

Dashboard
A unified four-section panel shows live trade status (direction, grade, SL/TP levels, R:R gauge, bars in trade, session status), market context (regime with visual gauge, HTF bias, volume, RSI, ATR), active weights (live readout of all five components plus mode indicator), and session statistics (signals by grade, win/loss count, win rate, average R-multiple, break-even saves, position flips).

How to set it up
Set the instrument type first: Index or Equity. For indices, also select the subtype (Nifty/FinNifty, BankNifty/Sensex, or MidcapNifty). This drives the base weight preset and shows ATR multiplier guidance on the dashboard.
For Nifty on 15-minute charts, the recommended starting configuration is ATR 9, multiplier 2.0, trail EMA 14, Balanced risk preset, adaptive multiplier on, ratchet on.
For BankNifty or Sensex, raise the multiplier to 2.25 or 2.5 to account for the wider intraday range.
For daily chart swing trading on equities, use ATR 13, trail EMA 21, Conservative or Balanced preset.

Built by Acrofins (Kiva Financial Services Private Limited). For educational and analytical purposes. Not financial advice.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// ACROTRAIL INDIA PRO [Acrofins / Kiva Financial Services]
// ══════════════════════════════════════════════════════════
// Version: 1.0.0
//
// Key modifications from original:
//   - Manual Index / Equity instrument selector
//   - Dynamic weight model: base presets + smart auto-adjust
//     + optional custom weight sliders
//   - NSE/BSE session gate (09:15 - 15:30 IST)
//   - Expiry day flags: Tuesday (Nifty) + Thursday (Sensex/FinNifty)
//   - Expiry last-90-min warning flag (13:00 - 15:30 on expiry days)
//   - Opening volatility flag (09:15 - 09:45)
//   - Auto HTF: 15-min chart uses 1H, daily chart uses Weekly
//   - ATR defaults tuned for Indian indices and equities
//   - RSI gradient scoring (replaces binary on/off)
//   - Volume filter ON by default with 1.2x threshold
//   - BankNifty / high-beta ATR multiplier suggestion via dashboard
// ══════════════════════════════════════════════════════════

indicator(
     title           = "AcroTrail India Pro - By Acrofins",
     shorttitle      = "AcroTrail - AFN",
     overlay         = true,
     max_lines_count = 500,
     max_labels_count= 500,
     max_boxes_count = 100,
     max_bars_back   = 5000)


// ══════════════════════════════════════════════════════════
// 2. CONSTANTS
// ══════════════════════════════════════════════════════════

INDICATOR_VERSION = "v1.0.0"

GRP_INSTRUMENT = "🇮🇳 Instrument Settings"
GRP_MAIN       = "⚙️ Main Settings"
GRP_WEIGHTS    = "⚖️ Dynamic Weight Model"
GRP_FILTER     = "🔍 Signal Filters"
GRP_REGIME     = "🌊 Market Regime"
GRP_RISK       = "🛡️ Risk Management"
GRP_SESSION    = "🕐 Session & Expiry (IST)"
GRP_VISUAL     = "🎨 Visual"
GRP_DASH       = "📊 Dashboard"
GRP_ALERT      = "🔔 Alerts"
GRP_COLORS     = "🎨 Colors"

// Grade thresholds
GRADE_A_THRESHOLD = 75
GRADE_B_THRESHOLD = 55

// Regime thresholds
REGIME_TRENDING = 60
REGIME_CHOPPY   = 35

// Visual constants
LINE_FORWARD_BARS  = 20
LINE_UPDATE_BARS   = 5
LABEL_OFFSET_BARS  = 1
ENTRY_BAR_HOLD     = 1

// IST session boundaries (minutes from midnight IST)
// 09:15 = 555 min, 09:45 = 585 min, 13:00 = 780 min, 15:30 = 930 min
SESSION_OPEN_MIN    = 555
SESSION_CLOSE_MIN   = 930
OPEN_VOL_END_MIN    = 585
EXPIRY_WARN_MIN     = 780


// ══════════════════════════════════════════════════════════
// 3. INPUTS
// ══════════════════════════════════════════════════════════

// ── Instrument Settings ─────────────────────────────────
instrTypeInput = input.string("Index", "Instrument Type",
     options = ["Index", "Equity"],
     group   = GRP_INSTRUMENT,
     tooltip = "Index: Nifty, BankNifty, Sensex, FinNifty, MidcapNifty.\n" +
               "Equity: Individual NSE/BSE stocks.\n\n" +
               "This drives the base weight preset and ATR defaults.\n" +
               "Index: higher ATR multiplier, no volume filter (index has no volume).\n" +
               "Equity: tighter ATR, volume filter active.")

indexSubtypeInput = input.string("Nifty / FinNifty", "Index Subtype",
     options = ["Nifty / FinNifty", "BankNifty / Sensex", "MidcapNifty"],
     group   = GRP_INSTRUMENT,
     tooltip = "Used to suggest ATR multiplier. BankNifty and Sensex are\n" +
               "significantly more volatile than Nifty.\n" +
               "Does NOT affect calculations unless you override the multiplier below.")

// ── Main Settings ───────────────────────────────────────
atrLenInput = input.int(9, "ATR Length", minval = 5, maxval = 100, group = GRP_MAIN,
     tooltip = "Indian markets default: 9 (faster than the original 13).\n" +
               "9 is responsive to intraday volatility on NSE.\n" +
               "Increase to 13-14 for daily chart swing trading.")

baseMultInput = input.float(2.0, "Base ATR Multiplier", minval = 0.5, maxval = 6.0, step = 0.1, group = GRP_MAIN,
     tooltip = "Default 2.0 for Nifty/FinNifty.\n" +
               "Recommended: 2.25-2.5 for BankNifty/Sensex.\n" +
               "The original 1.618 was too tight for NSE intraday.\n" +
               "Increase if getting too many whipsaw stops.")

trailLenInput = input.int(14, "Trail EMA Length", minval = 5, maxval = 100, group = GRP_MAIN,
     tooltip = "EMA period for trail center.\n" +
               "Default 14 (reduced from original 21) for faster response\n" +
               "on Indian intraday charts. Use 21 for daily charts.")

useAdaptiveMultInput = input.bool(true, "Adaptive Volatility Multiplier", group = GRP_MAIN,
     tooltip = "Recommended ON. Auto-adjusts multiplier based on\n" +
               "100-bar volatility percentile rank.\n" +
               "Especially useful for NSE which has sharp vol spikes.")

useRatchetInput = input.bool(true, "Ratchet Trail (never loosens)", group = GRP_MAIN,
     tooltip = "Trail band only tightens in the direction of the position.\n" +
               "Standard SuperTrend behavior. Recommended ON.")

// ── Dynamic Weight Model ────────────────────────────────
useCustomWeightsInput = input.bool(false, "Use Custom Weights (overrides auto-adjust)", group = GRP_WEIGHTS,
     tooltip = "OFF: Smart auto-adjust runs based on instrument type,\n" +
               "session time, expiry day, and volatility regime.\n" +
               "ON: Your manual sliders below control all weights.\n" +
               "Weights must sum to 100 — use the dashboard to check.")

// Custom weight sliders (only active when useCustomWeightsInput = true)
wHtfInput  = input.int(30, "  HTF Bias Weight",       minval = 0, maxval = 50, group = GRP_WEIGHTS,
     tooltip = "Weight for HTF trend alignment (0-50). Default 30.")
wVolInput  = input.int(20, "  Volume Weight",          minval = 0, maxval = 40, group = GRP_WEIGHTS,
     tooltip = "Weight for volume confirmation (0-40). Default 20.\n" +
               "Set to 0 for index charts where volume is unavailable.")
wRsiInput  = input.int(20, "  RSI Momentum Weight",    minval = 0, maxval = 40, group = GRP_WEIGHTS,
     tooltip = "Weight for RSI gradient score (0-40). Default 20.")
wRegInput  = input.int(20, "  Regime Weight",          minval = 0, maxval = 40, group = GRP_WEIGHTS,
     tooltip = "Weight for composite market regime (0-40). Default 20.")
wBrkInput  = input.int(10, "  Breakout Strength Weight", minval = 0, maxval = 30, group = GRP_WEIGHTS,
     tooltip = "Weight for how far price pierced the band (0-30). Default 10.")

// ── Signal Filters ──────────────────────────────────────
minQualityInput = input.int(0, "Min Quality Score (0 = show all)", minval = 0, maxval = 100, group = GRP_FILTER,
     tooltip = "Hide signals below this score.\n" +
               "55 = B grade or higher. 75 = A grade only.")

skipChoppyInput = input.bool(false, "Hard-skip Choppy Signals", group = GRP_FILTER,
     tooltip = "Fully suppress signals in choppy regime.\n" +
               "OFF (default): show with warning flag.")

useHtfFilterInput = input.bool(true, "Use HTF Bias Filter", group = GRP_FILTER,
     tooltip = "Auto HTF logic:\n" +
               "15-min chart → 1H HTF\n" +
               "Daily chart  → Weekly HTF\n" +
               "Other TFs    → 4x current TF (original logic)")

htfTfInput = input.timeframe("", "HTF Override (empty = auto)", group = GRP_FILTER,
     tooltip = "Leave empty for automatic HTF selection (recommended).\n" +
               "Set manually only if you need a specific HTF.")

useVolumeFilterInput = input.bool(true, "Use Volume Confirmation", group = GRP_FILTER,
     tooltip = "ON by default for equities.\n" +
               "Auto-bypassed when instrument type = Index\n" +
               "because index charts report zero volume on TradingView.")

volMultInput = input.float(1.2, "Volume Threshold (× SMA20)", minval = 1.0, maxval = 3.0, step = 0.1, group = GRP_FILTER,
     tooltip = "Default 1.2x for Indian equities (lower than original 1.3x\n" +
               "because NSE stocks have lower average volume density\n" +
               "compared to US equities).")

// ── Market Regime ───────────────────────────────────────
adxLenInput        = input.int(14, "ADX Length",            minval = 5,  maxval = 50,  group = GRP_REGIME)
choppinessLenInput = input.int(14, "Choppiness Length",     minval = 5,  maxval = 50,  group = GRP_REGIME)
regimeLenInput     = input.int(50, "R² Regression Length",  minval = 20, maxval = 200, group = GRP_REGIME)

// ── Session & Expiry ────────────────────────────────────
useSessionGateInput = input.bool(true, "Block Signals Outside NSE Session (09:15-15:30 IST)", group = GRP_SESSION,
     tooltip = "No signals generated outside the NSE/BSE trading session.\n" +
               "Prevents false signals from pre-market or after-hours data.")

showOpeningFlagInput = input.bool(true, "Flag Opening Volatility Window (09:15-09:45)", group = GRP_SESSION,
     tooltip = "Signals during 09:15-09:45 get an ⚡ warning flag.\n" +
               "This is the highest-noise window on NSE — gap opens,\n" +
               "institutional order flow, retail panic all collide here.")

useExpiryFlagInput = input.bool(true, "Flag Expiry Last-90-min (13:00-15:30)", group = GRP_SESSION,
     tooltip = "Tue = Nifty/FinNifty expiry. Thu = Sensex/BankNifty expiry.\n" +
               "Signals during last 90 min on expiry days get an 🔔 flag.\n" +
               "Extreme IV crush and directional whipsaw in this window.")

// ── Risk Management ─────────────────────────────────────
riskPresetInput = input.string("Balanced", "Risk Preset",
     options = ["Conservative", "Balanced", "Aggressive", "Scalping", "Custom"],
     group   = GRP_RISK,
     tooltip = "Conservative: SL 2.5×ATR, TP 1R/2R/4R\n" +
               "Balanced:     SL 1.5×ATR, TP 1R/2R/3R  (recommended for Index)\n" +
               "Aggressive:   SL 1.0×ATR, TP 1.5R/2.5R/4R\n" +
               "Scalping:     SL 0.8×ATR, TP 0.8R/1.5R/2R\n" +
               "NOTE: For options trading, use Balanced minimum.\n" +
               "Scalping SL is too tight for ATM option premium spread.")

slMultInput  = input.float(1.5, "Custom SL ×ATR",   minval = 0.3, maxval = 5.0, step = 0.1, group = GRP_RISK)
tp1MultInput = input.float(1.0, "Custom TP1 ×Risk", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK)
tp2MultInput = input.float(2.0, "Custom TP2 ×Risk", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_RISK)
tp3MultInput = input.float(3.0, "Custom TP3 ×Risk", minval = 1.5, maxval = 15.0, step = 0.1, group = GRP_RISK)

showSlTpInput        = input.bool(true,  "Show SL/TP Lines",          group = GRP_RISK)
showSlTpLabelsInput  = input.bool(true,  "Show SL/TP Labels",         group = GRP_RISK)
showPctOnLabelsInput = input.bool(true,  "Show % Distance on Labels", group = GRP_RISK)
useBreakEvenInput    = input.bool(true,  "Break-Even After TP1",      group = GRP_RISK,
     tooltip = "Moves SL to entry after TP1 hit.\n" +
               "NOTE: For intraday options, consider disabling this.\n" +
               "IV spikes and spread widening can trigger BE stops\n" +
               "before the real TP2/TP3 move develops.")

entryLineStyleInput = input.string("Dotted", "Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)
slLineStyleInput    = input.string("Solid",  "SL Line Style",    options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)
tpLineStyleInput    = input.string("Dashed", "TP Line Style",    options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)

// ── Visual ──────────────────────────────────────────────
themeInput           = input.string("Auto",  "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL)
showTrailInput       = input.bool(true,  "Show Trail Line",        group = GRP_VISUAL)
trailStyleInput      = input.string("Adaptive (Bull/Bear)", "Trail Color Scheme",
     options = ["Adaptive (Bull/Bear)", "Premium Indigo", "Monochrome"], group = GRP_VISUAL)
trailWidthInput      = input.int(2, "Trail Line Width",  minval = 1, maxval = 4,   group = GRP_VISUAL)
trailHistoryBarsInput= input.int(0, "Trail History Bars (0 = all)", minval = 0, maxval = 500, group = GRP_VISUAL)
trailDoubleInput     = input.bool(true, "Double Trail Line",       group = GRP_VISUAL)
trailOffsetInput     = input.float(0.25, "  Double Trail Offset (× ATR)", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_VISUAL)
showSignalsInput     = input.bool(true,  "Show Buy/Sell Labels",   group = GRP_VISUAL)
showGradeInput       = input.bool(true,  "Show Grade in Label",    group = GRP_VISUAL)
showRegimeBgInput    = input.bool(false, "Show Regime Background", group = GRP_VISUAL)
showWatermarkInput   = input.bool(true,  "Show Watermark",         group = GRP_VISUAL)
labelFontSizeInput   = input.string("Small", "SL/TP Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL)
signalFontSizeInput  = input.string("Small", "Signal Marker Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL)

// ── Dashboard ───────────────────────────────────────────
showDashInput         = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosStr            = input.string("Top Right", "Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right", "Middle Left"],
     group = GRP_DASH)
showTradeSectionInput  = input.bool(true, "  ├ Trade Section",      group = GRP_DASH)
showMarketSectionInput = input.bool(true, "  ├ Market Section",     group = GRP_DASH)
showWeightSectionInput = input.bool(true, "  ├ Active Weights",     group = GRP_DASH,
     tooltip = "Shows the live weight values being applied to each\n" +
               "Quality Score component. Useful for understanding how\n" +
               "auto-adjust is shifting weights in real time.")
showStatsInput         = input.bool(true, "  └ Statistics Section", group = GRP_DASH)
resetStatsInput        = input.int(0, "Reset Stats Counter", minval = 0, maxval = 999, group = GRP_DASH)

// ── Alerts ──────────────────────────────────────────────
webhookInput    = input.bool(false, "Webhook JSON Format",   group = GRP_ALERT)
alertTpHitInput = input.bool(false, "Alert on TP Hits",      group = GRP_ALERT)
alertSlHitInput = input.bool(true,  "Alert on SL Hit",       group = GRP_ALERT)
alertFlipInput  = input.bool(true,  "Alert on Position Flip",group = GRP_ALERT)

// ── Colors ──────────────────────────────────────────────
bullColorInput    = input.color(#00E676, "Bull",    inline = "c1", group = GRP_COLORS)
bearColorInput    = input.color(#FF5252, "Bear",    inline = "c1", group = GRP_COLORS)
neutralColorInput = input.color(#FFEB3B, "Warn",    inline = "c1", group = GRP_COLORS)


// ══════════════════════════════════════════════════════════
// 4. THEME & PALETTE
// ══════════════════════════════════════════════════════════

isDark = themeInput == "Dark" ? true : themeInput == "Light" ? false : color.r(chart.bg_color) < 128

TEXT_COLOR   = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TEXT_BRIGHT  = isDark ? #FFFFFF : #000000
BULL_TEXT    = isDark ? #00E676 : #00A152
BEAR_TEXT    = isDark ? #FF5252 : #D32F2F
NEUTRAL_TEXT = isDark ? #FFEB3B : #BF360C

BULL_LABEL_TEXT = #004D25
BEAR_LABEL_TEXT = #FFFFFF
WARN_LABEL_TEXT = #3E2C00

TABLE_BG      = isDark ? color.new(#131722, 5)  : color.new(#FFFFFF, 5)
TABLE_BORDER  = isDark ? color.new(#2A2E39, 0)  : color.new(#D0D0D0, 0)
TABLE_ROW_ALT = isDark ? color.new(#1C2030, 0)  : color.new(#F0F4F8, 0)
HEADER_BG     = isDark ? color.new(#1A3A1A, 0)  : color.new(#0D2B0D, 0)
HEADER_TEXT   = #FFFFFF
LINE_SUBTLE   = isDark ? color.new(#666666, 0)  : color.new(#999999, 0)
WM_COLOR      = isDark ? color.new(#FFFFFF, 88) : color.new(#000000, 88)

SL_COLOR       = isDark ? color.new(#E57373, 0)  : color.new(#B71C1C, 0)
TP1_COLOR      = isDark ? color.new(#66BB6A, 30) : color.new(#388E3C, 30)
TP2_COLOR      = isDark ? color.new(#66BB6A, 40) : color.new(#388E3C, 40)
TP3_COLOR      = isDark ? color.new(#66BB6A, 0)  : color.new(#388E3C, 0)
ENTRY_COLOR    = isDark ? color.new(#5C8AAE, 0)  : color.new(#34495E, 0)
TP_LABEL_COLOR = isDark ? color.new(#66BB6A, 0)  : color.new(#388E3C, 0)
LABEL_TEXT     = isDark ? #1A1A1A : #FFFFFF
TP_HIT_COLOR   = isDark ? color.new(#4DB6AC, 0)  : color.new(#00695C, 0)
BE_COLOR       = isDark ? color.new(#FFA726, 0)  : color.new(#E65100, 0)

TREND_BG_BULL = color.new(#00E676, 92)
TREND_BG_BEAR = color.new(#FF5252, 92)
CHOPPY_BG     = isDark ? color.new(#FFEB3B, 94) : color.new(#FFC107, 94)

TRAIL_INDIGO_LONG  = isDark ? color.new(#7986CB, 30) : color.new(#283593, 30)
TRAIL_INDIGO_SHORT = isDark ? color.new(#A1887F, 30) : color.new(#4E342E, 30)
TRAIL_MONO_LONG    = isDark ? color.new(#9E9E9E, 40) : color.new(#616161, 40)
TRAIL_MONO_SHORT   = isDark ? color.new(#9E9E9E, 40) : color.new(#616161, 40)

// Expiry warning color — saffron (Indian flag accent, distinct from all other indicator colors)
EXPIRY_COLOR = isDark ? color.new(#FF9933, 0) : color.new(#CC6600, 0)
// Opening volatility color — electric blue
OPEN_VOL_COLOR = isDark ? color.new(#40C4FF, 0) : color.new(#0077AA, 0)


// ══════════════════════════════════════════════════════════
// 5. HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════

safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

rSquared(float src, int len) =>
    float corr = ta.correlation(src, bar_index, len)
    na(corr) ? 0.0 : math.pow(corr, 2)

// Auto HTF: India-specific logic
// 15-min → 60 (1H), daily → W (weekly), others → 4x current TF
autoHtf() =>
    string tf = timeframe.period
    tf == "15" ? "60" :
     tf == "D"  ? "W"  :
     tf == "1D" ? "W"  :
     (timeframe.in_seconds(tf) / 60 * 4 <= 5    ? "5"   :
      timeframe.in_seconds(tf) / 60 * 4 <= 15   ? "15"  :
      timeframe.in_seconds(tf) / 60 * 4 <= 30   ? "30"  :
      timeframe.in_seconds(tf) / 60 * 4 <= 60   ? "60"  :
      timeframe.in_seconds(tf) / 60 * 4 <= 240  ? "240" :
      timeframe.in_seconds(tf) / 60 * 4 <= 1440 ? "D"   : "W")

fmtPrice(float v)  => na(v) ? "—" : str.tostring(v, format.mintick)
fmtActive(float v) => na(v) ? "n/a" : str.tostring(v, format.mintick)

formatPctFromEntry(float level, float entry) =>
    string res = ""
    if showPctOnLabelsInput and not na(level) and not na(entry) and entry != 0
        float pct  = (level - entry) / entry * 100.0
        string sign = pct >= 0 ? "+" : ""
        res := " (" + sign + str.tostring(pct, "#.##") + "%)"
    res

buildGauge(float value, float maxVal, int width) =>
    string result = ""
    int filledCount = maxVal <= 0 ? 0 : math.round(math.min(width, math.max(0.0, value / maxVal * width)))
    for i = 0 to width - 1
        result += i < filledCount ? "▰" : "▱"
    result

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny  :
     s == "Small"  ? size.small :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large  :
     s == "Huge"   ? size.huge   : size.small

lineStyleFromString(string s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted : line.style_solid

resolveDashPos(string s) =>
    s == "Top Left"     ? position.top_left    :
     s == "Top Right"    ? position.top_right   :
     s == "Bottom Left"  ? position.bottom_left :
     s == "Bottom Right" ? position.bottom_right :
     s == "Middle Right" ? position.middle_right :
     s == "Middle Left"  ? position.middle_left  :
     position.top_right

entryLineStyle   = lineStyleFromString(entryLineStyleInput)
slLineStyle      = lineStyleFromString(slLineStyleInput)
tpLineStyle      = lineStyleFromString(tpLineStyleInput)
labelSize        = sizeFromString(labelFontSizeInput)
signalMarkerSize = sizeFromString(signalFontSizeInput)


// ══════════════════════════════════════════════════════════
// 6. SESSION & EXPIRY LOGIC (IST)
// ══════════════════════════════════════════════════════════
// TradingView `hour` and `minute` are in the chart's exchange timezone.
// For NSE/BSE charts this is already IST (UTC+5:30).
// For non-NSE charts loaded with this indicator, the user should
// ensure the chart exchange is set to NSE or BSE.

int  istMinutes    = hour * 60 + minute
bool isInSession   = istMinutes >= SESSION_OPEN_MIN and istMinutes < SESSION_CLOSE_MIN
bool isOpeningWind = istMinutes >= SESSION_OPEN_MIN and istMinutes < OPEN_VOL_END_MIN
bool isExpiryDay   = dayofweek == dayofweek.tuesday or dayofweek == dayofweek.thursday
bool isExpiryWarn  = isExpiryDay and istMinutes >= EXPIRY_WARN_MIN and istMinutes < SESSION_CLOSE_MIN
// On daily charts, session/time flags should not block signals
bool isDailyChart  = timeframe.period == "D" or timeframe.period == "1D" or timeframe.isweekly or timeframe.ismonthly
bool sessionOk     = isDailyChart or not useSessionGateInput or isInSession

// Determine if this is an index chart (for volume bypass and weight logic)
bool isIndex = instrTypeInput == "Index"

// Volume support: indices report zero volume on TV; bypass cleanly
bool hasVolume     = nz(volume, 0) > 0 and ta.sma(volume, 20) > 0
bool volAvailable  = not isIndex and hasVolume


// ══════════════════════════════════════════════════════════
// 7. CORE CALCULATIONS
// ══════════════════════════════════════════════════════════

int   WARMUP_BARS = math.max(math.max(atrLenInput, trailLenInput), regimeLenInput) + 5
bool  isWarmedUp  = bar_index >= WARMUP_BARS

float atrVal  = nz(ta.atr(atrLenInput), 0.0)
float volRank = useAdaptiveMultInput ? nz(ta.percentrank(atrVal, 100), 50.0) : 50.0
float multAdjust = useAdaptiveMultInput ? (volRank < 30 ? 0.8 : volRank > 70 ? 1.25 : 1.0) : 1.0
float effectiveMult = baseMultInput * multAdjust

float trailCenter = ta.ema(close, trailLenInput)
float rawUpper    = trailCenter + atrVal * effectiveMult
float rawLower    = trailCenter - atrVal * effectiveMult

var float upperBand = na
var float lowerBand = na
var int   dir       = 0

if isWarmedUp
    if close > nz(upperBand[1], close)
        dir := 1
    else if close < nz(lowerBand[1], close)
        dir := -1

bool dirFlipped = dir != nz(dir[1], 0)

if useRatchetInput
    if dir == 1
        lowerBand := dirFlipped ? rawLower : math.max(rawLower, nz(lowerBand[1], rawLower))
        upperBand := rawUpper
    else if dir == -1
        upperBand := dirFlipped ? rawUpper : math.min(rawUpper, nz(upperBand[1], rawUpper))
        lowerBand := rawLower
    else
        upperBand := rawUpper
        lowerBand := rawLower
else
    upperBand := rawUpper
    lowerBand := rawLower

float trailLine = dir == 1 ? lowerBand : dir == -1 ? upperBand : na

bool rawBuy  = dir == 1  and dir[1] == -1 and isWarmedUp
bool rawSell = dir == -1 and dir[1] == 1  and isWarmedUp


// ══════════════════════════════════════════════════════════
// 8. MARKET REGIME
// ══════════════════════════════════════════════════════════

[diPlus, diMinus, adxRaw] = ta.dmi(adxLenInput, adxLenInput)
float adxVal   = nz(adxRaw, 0.0)
float adxScore = math.min(adxVal / 50.0 * 100.0, 100.0)

float ciHigh   = ta.highest(high, choppinessLenInput)
float ciLow    = ta.lowest(low, choppinessLenInput)
float ciAtrSum = math.sum(ta.tr(true), choppinessLenInput)
float ciRange  = ciHigh - ciLow
float chopLogN = math.log10(math.max(choppinessLenInput, 2))
float chopRaw  = ciRange <= 0 ? 100.0 : ciAtrSum > 0 ? 100.0 * math.log10(ciAtrSum / ciRange) / chopLogN : 50.0
float chopScore = math.max(0.0, math.min(100.0, 100.0 - chopRaw))

float r2      = rSquared(close, regimeLenInput)
float r2Score = r2 * 100.0

float regimeScore = adxScore * 0.40 + chopScore * 0.35 + r2Score * 0.25

bool isTrending = regimeScore >= REGIME_TRENDING
bool isChoppy   = regimeScore <  REGIME_CHOPPY

string regimeLabel = isTrending ? "Trending" : isChoppy ? "Choppy" : "Mixed"
color  regimeColor = isTrending ? BULL_TEXT  : isChoppy ? BEAR_TEXT : NEUTRAL_TEXT


// ══════════════════════════════════════════════════════════
// 9. DYNAMIC WEIGHT MODEL
// ══════════════════════════════════════════════════════════
//
// Three-layer system:
//   Layer 1 — Base preset (Index vs Equity)
//   Layer 2 — Smart auto-adjust (time of day, expiry, volatility)
//   Layer 3 — Custom override sliders (when useCustomWeightsInput = true)
//
// All weights are floats that sum to 100.
// The quality score uses these as max-point ceilings for each component.

// Layer 1: Base presets
// Index: volume is unavailable, so that weight shifts to regime and HTF.
// Equity: volume is a meaningful filter, gets full 20 points.
float baseWHtf = isIndex ? 30.0 : 25.0
float baseWVol = isIndex ?  0.0 : 20.0
float baseWRsi = isIndex ? 20.0 : 20.0
float baseWReg = isIndex ? 35.0 : 25.0
float baseWBrk = isIndex ? 15.0 : 10.0

// Layer 2: Smart auto-adjust modifiers
// These are ADDITIVE deltas applied to the base preset, then re-normalised.
// Rules:
//   Opening window (09:15-09:45): boost HTF (trend context matters most),
//     reduce breakout (breakouts are unreliable on gap-open candles)
//   Expiry warning window: boost regime (choppiness dominates),
//     reduce breakout (breakouts are whipsaws near expiry)
//   High vol (volRank > 70): boost regime, reduce RSI
//     (RSI is less meaningful in fast trending markets)
//   Choppy regime: boost RSI (momentum divergence more actionable),
//     reduce breakout (band pierces are noise, not breakouts)
//   Trending regime: boost breakout (pierces are meaningful in trends),
//     reduce RSI slightly

float dHTF = 0.0
float dVol = 0.0
float dRsi = 0.0
float dReg = 0.0
float dBrk = 0.0

if not isDailyChart and showOpeningFlagInput and isOpeningWind
    dHTF += 8.0
    dBrk -= 5.0
    dRsi -= 3.0

if useExpiryFlagInput and isExpiryWarn
    dReg += 8.0
    dBrk -= 5.0
    dHTF += 2.0
    dRsi -= 5.0

if volRank > 70
    dReg += 5.0
    dRsi -= 5.0

if isChoppy
    dRsi += 5.0
    dBrk -= 5.0

if isTrending
    dBrk += 5.0
    dRsi -= 2.0

// Apply deltas to base
float autoWHtf = math.max(0.0, baseWHtf + dHTF)
float autoWVol = math.max(0.0, baseWVol + dVol)
float autoWRsi = math.max(0.0, baseWRsi + dRsi)
float autoWReg = math.max(0.0, baseWReg + dReg)
float autoWBrk = math.max(0.0, baseWBrk + dBrk)

// Re-normalise so weights always sum to 100
float autoWTotal = autoWHtf + autoWVol + autoWRsi + autoWReg + autoWBrk
float normFactor = autoWTotal > 0 ? 100.0 / autoWTotal : 1.0
autoWHtf := autoWHtf * normFactor
autoWVol := autoWVol * normFactor
autoWRsi := autoWRsi * normFactor
autoWReg := autoWReg * normFactor
autoWBrk := autoWBrk * normFactor

// Layer 3: Apply custom overrides if toggled
float wHtf = useCustomWeightsInput ? float(wHtfInput) : autoWHtf
float wVol = useCustomWeightsInput ? float(wVolInput) : autoWVol
float wRsi = useCustomWeightsInput ? float(wRsiInput) : autoWRsi
float wReg = useCustomWeightsInput ? float(wRegInput) : autoWReg
float wBrk = useCustomWeightsInput ? float(wBrkInput) : autoWBrk

// Validate custom weights sum (dashboard will flag if off)
float customWTotal = wHtf + wVol + wRsi + wReg + wBrk


// ══════════════════════════════════════════════════════════
// 10. QUALITY SCORE
// ══════════════════════════════════════════════════════════

string htfRes = htfTfInput == "" ? autoHtf() : htfTfInput

[htfClose, htfEma] = request.security(syminfo.tickerid, htfRes,
     [close[1], ta.ema(close, 50)[1]],
     barmerge.gaps_off, barmerge.lookahead_on)

bool htfBull = useHtfFilterInput and not na(htfEma) and not na(htfClose) and htfClose > htfEma
bool htfBear = useHtfFilterInput and not na(htfEma) and not na(htfClose) and htfClose < htfEma

float volSma    = volAvailable ? ta.sma(volume, 20) : na
bool  volConfirm = useVolumeFilterInput and volAvailable and volume > volSma * volMultInput

// RSI gradient scoring (replaces binary 0/20)
// Scoring rationale:
//   Long signal: RSI > 65 = strong momentum (full)
//                RSI 50-65 = moderate momentum (65% of weight)
//                RSI 40-50 = neutral / marginal (25% of weight)
//                RSI < 40  = against momentum (0)
//   Short signal: mirror image
//   This prevents overbought longs (RSI 72) scoring equal to RSI 52
//   while still rewarding clear directional momentum
float rsiVal = nz(ta.rsi(close, 14), 50.0)

rsiGradientScore(bool isBuy) =>
    float s = 0.0
    if isBuy
        s := rsiVal >= 65 ? 1.0 : rsiVal >= 50 ? 0.65 : rsiVal >= 40 ? 0.25 : 0.0
    else
        s := rsiVal <= 35 ? 1.0 : rsiVal <= 50 ? 0.65 : rsiVal <= 60 ? 0.25 : 0.0
    s

// Breakout strength
float breakDist     = dir == 1 ? close - nz(upperBand[1], close) : dir == -1 ? nz(lowerBand[1], close) - close : 0.0
float breakStrength = atrVal != 0 ? math.min(math.abs(breakDist) / atrVal, 3.0) / 3.0 : 0.0

// Main quality score calculator using dynamic weights
calcQualityScore(bool isBuy) =>
    bool htfDataValid = useHtfFilterInput and not na(htfEma) and not na(htfClose)
    bool htfMatches   = htfDataValid and ((isBuy and htfBull) or (not isBuy and htfBear))
    bool htfAgainst   = htfDataValid and ((isBuy and htfBear) or (not isBuy and htfBull))
    // HTF gradient: full / partial / zero
    float htfMult  = htfMatches ? 1.0 : htfAgainst ? 0.0 : 0.5
    float htfPart  = wHtf * htfMult

    // Volume: full credit when filter off or index (no volume data)
    float volPart = (not useVolumeFilterInput) or (not volAvailable) ? wVol : (volConfirm ? wVol : 0.0)

    float rsiPart    = wRsi * rsiGradientScore(isBuy)
    float regimePart = wReg * (regimeScore / 100.0)
    float breakPart  = wBrk * breakStrength
    htfPart + volPart + rsiPart + regimePart + breakPart

float buyQuality  = rawBuy  ? calcQualityScore(true)  : na
float sellQuality = rawSell ? calcQualityScore(false) : na

gradeFromScore(float s) =>
    na(s) ? "—" : s >= GRADE_A_THRESHOLD ? "A" : s >= GRADE_B_THRESHOLD ? "B" : "C"


// ══════════════════════════════════════════════════════════
// 11. FINAL SIGNAL LOGIC
// ══════════════════════════════════════════════════════════

bool buyPasses  = rawBuy  and barstate.isconfirmed and sessionOk and
     (na(buyQuality)  or buyQuality  >= minQualityInput) and
     not (skipChoppyInput and isChoppy)

bool sellPasses = rawSell and barstate.isconfirmed and sessionOk and
     (na(sellQuality) or sellQuality >= minQualityInput) and
     not (skipChoppyInput and isChoppy)

string buyGrade  = gradeFromScore(buyQuality)
string sellGrade = gradeFromScore(sellQuality)

// Warning flags — combined into a suffix string
// Choppy flag (original), Opening volatility flag, Expiry warning flag
string chopFlag   = isChoppy ? " ⚠" : ""
string openFlag   = (not isDailyChart and showOpeningFlagInput and isOpeningWind) ? " ⚡" : ""
string expiryFlag = (useExpiryFlagInput and isExpiryWarn) ? " 🔔" : ""
string warnSuffix = chopFlag + openFlag + expiryFlag


// ══════════════════════════════════════════════════════════
// 12. RISK MANAGEMENT
// ══════════════════════════════════════════════════════════

float effSlMult  = riskPresetInput == "Conservative" ? 2.5 : riskPresetInput == "Aggressive" ? 1.0  : riskPresetInput == "Scalping" ? 0.8 : riskPresetInput == "Custom" ? slMultInput  : 1.5
float effTp1Mult = riskPresetInput == "Conservative" ? 1.0 : riskPresetInput == "Aggressive" ? 1.5  : riskPresetInput == "Scalping" ? 0.8 : riskPresetInput == "Custom" ? tp1MultInput : 1.0
float effTp2Mult = riskPresetInput == "Conservative" ? 2.0 : riskPresetInput == "Aggressive" ? 2.5  : riskPresetInput == "Scalping" ? 1.5 : riskPresetInput == "Custom" ? tp2MultInput : 2.0
float effTp3Mult = riskPresetInput == "Conservative" ? 4.0 : riskPresetInput == "Aggressive" ? 4.0  : riskPresetInput == "Scalping" ? 2.0 : riskPresetInput == "Custom" ? tp3MultInput : 3.0

float slDistance = atrVal * effSlMult

var float  activeEntry   = na
var float  activeSL      = na
var float  activeTP1     = na
var float  activeTP2     = na
var float  activeTP3     = na
var int    activeDir     = 0
var int    activeBar     = 0
var float  activeQual    = na
var string activeGrade   = ""
var float  activeTP1Mult = 0.0
var float  activeTP2Mult = 0.0
var float  activeTP3Mult = 0.0
var bool   tp1Reached    = false
var bool   tp2Reached    = false
var bool   tp3Reached    = false
var bool   beActive      = false

bool buyFlip      = buyPasses  and activeDir == -1
bool sellFlip     = sellPasses and activeDir ==  1
bool flipDetected = buyFlip or sellFlip

string flipFromDir   = flipDetected ? (activeDir == 1 ? "LONG" : "SHORT") : ""
string flipToDir     = flipDetected ? (buyFlip ? "LONG" : "SHORT") : ""
float  flipFromEntry = flipDetected ? activeEntry : na


// ══════════════════════════════════════════════════════════
// 12a. STATS COUNTERS
// ══════════════════════════════════════════════════════════

var int   statTotalSignals = 0
var int   statGradeA       = 0
var int   statGradeB       = 0
var int   statGradeC       = 0
var int   statSlHits       = 0
var int   statTp1Hits      = 0
var int   statTp2Hits      = 0
var int   statTp3Hits      = 0
var int   statFlips        = 0
var int   statBuySignals   = 0
var int   statSellSignals  = 0
var int   statWins         = 0
var int   statLosses       = 0
var int   statBeSaves      = 0
var float statRSum         = 0.0

classifyClosedTrade(string closeReason, bool wasBeAtBarStart) =>
    int outWin = 0
    int outLoss = 0
    int outBeSave = 0
    float outR = 0.0
    if activeDir != 0
        if tp1Reached
            float r1 = (1.0 / 3.0) * activeTP1Mult
            float r2 = tp2Reached ? (1.0 / 3.0) * activeTP2Mult : 0.0
            float r3 = tp3Reached ? (1.0 / 3.0) * activeTP3Mult : 0.0
            outR    := r1 + r2 + r3
            outWin  := 1
            if closeReason == "sl" and wasBeAtBarStart
                outBeSave := 1
        else
            outR    := -1.0
            outLoss := 1
    [outWin, outLoss, outBeSave, outR]


// ══════════════════════════════════════════════════════════
// 12b. POSITION OPEN
// ══════════════════════════════════════════════════════════

if flipDetected
    [w, l, b, r] = classifyClosedTrade("flip", beActive)
    statWins    += w
    statLosses  += l
    statBeSaves += b
    statRSum    += r
    statFlips   += 1

if buyPasses
    activeEntry   := close
    activeSL      := close - slDistance
    activeTP1     := close + slDistance * effTp1Mult
    activeTP2     := close + slDistance * effTp2Mult
    activeTP3     := close + slDistance * effTp3Mult
    activeDir     := 1
    activeBar     := bar_index
    activeQual    := buyQuality
    activeGrade   := buyGrade
    activeTP1Mult := effTp1Mult
    activeTP2Mult := effTp2Mult
    activeTP3Mult := effTp3Mult
    tp1Reached    := false
    tp2Reached    := false
    tp3Reached    := false
    beActive      := false

if sellPasses
    activeEntry   := close
    activeSL      := close + slDistance
    activeTP1     := close - slDistance * effTp1Mult
    activeTP2     := close - slDistance * effTp2Mult
    activeTP3     := close - slDistance * effTp3Mult
    activeDir     := -1
    activeBar     := bar_index
    activeQual    := sellQuality
    activeGrade   := sellGrade
    activeTP1Mult := effTp1Mult
    activeTP2Mult := effTp2Mult
    activeTP3Mult := effTp3Mult
    tp1Reached    := false
    tp2Reached    := false
    tp3Reached    := false
    beActive      := false


// ══════════════════════════════════════════════════════════
// 12c. HIT DETECTION & BREAK-EVEN
// ══════════════════════════════════════════════════════════

bool beActiveAtBarStart = beActive
float effectiveSL = activeSL

bool canHit = barstate.isconfirmed and activeDir != 0 and (bar_index - activeBar) >= ENTRY_BAR_HOLD

bool slHit  = canHit and (activeDir == 1 ? low  <= effectiveSL : high >= effectiveSL)
bool tp1Hit = canHit and (activeDir == 1 ? high >= activeTP1   : low  <= activeTP1)
bool tp2Hit = canHit and (activeDir == 1 ? high >= activeTP2   : low  <= activeTP2)
bool tp3Hit = canHit and (activeDir == 1 ? high >= activeTP3   : low  <= activeTP3)

bool tp1FirstTouch = tp1Hit and not tp1Reached and not slHit
bool tp2FirstTouch = tp2Hit and not tp2Reached and not slHit
bool tp3FirstTouch = tp3Hit and not tp3Reached and not slHit

if tp1FirstTouch
    tp1Reached := true
if tp2FirstTouch
    tp2Reached := true
if tp3FirstTouch
    tp3Reached := true

bool beJustActivated = false
if useBreakEvenInput and tp1FirstTouch and not beActive
    activeSL         := activeEntry
    beActive         := true
    beJustActivated  := true


// ══════════════════════════════════════════════════════════
// 12d. EXIT SNAPSHOTS
// ══════════════════════════════════════════════════════════

float exitEntry    = activeEntry
float exitSL       = effectiveSL
float exitTP1      = activeTP1
float exitTP2      = activeTP2
float exitTP3      = activeTP3
bool  exitBeActive = beActiveAtBarStart

bool displayTp1Reached = tp1Reached
bool displayTp2Reached = tp2Reached
bool displayTp3Reached = tp3Reached


// ══════════════════════════════════════════════════════════
// 12e. CLOSURE
// ══════════════════════════════════════════════════════════

bool resetCondition = (slHit or tp3Hit) and activeDir != 0 and barstate.isconfirmed

if tp1FirstTouch
    statTp1Hits += 1
if tp2FirstTouch
    statTp2Hits += 1
if tp3FirstTouch
    statTp3Hits += 1
if slHit and activeDir != 0 and barstate.isconfirmed
    statSlHits += 1

if resetCondition
    string reason = slHit ? "sl" : "tp3"
    [w, l, b, r]  = classifyClosedTrade(reason, beActiveAtBarStart)
    statWins      += w
    statLosses    += l
    statBeSaves   += b
    statRSum      += r
    activeDir      := 0
    activeSL       := na
    activeTP1      := na
    activeTP2      := na
    activeTP3      := na
    activeEntry    := na
    activeBar      := 0
    activeQual     := na
    activeGrade    := ""
    activeTP1Mult  := 0.0
    activeTP2Mult  := 0.0
    activeTP3Mult  := 0.0
    tp1Reached     := false
    tp2Reached     := false
    tp3Reached     := false
    beActive       := false


// ══════════════════════════════════════════════════════════
// 13. PLOTS — trail + regime background
// ══════════════════════════════════════════════════════════

color trailColorBull = trailStyleInput == "Premium Indigo" ? TRAIL_INDIGO_LONG  : trailStyleInput == "Monochrome" ? TRAIL_MONO_LONG  : bullColorInput
color trailColorBear = trailStyleInput == "Premium Indigo" ? TRAIL_INDIGO_SHORT : trailStyleInput == "Monochrome" ? TRAIL_MONO_SHORT : bearColorInput
color trailColor     = dir == 1 ? trailColorBull : dir == -1 ? trailColorBear : color.new(color.gray, 50)

bool  inTrailWindow   = trailHistoryBarsInput == 0 or (last_bar_index - bar_index) < trailHistoryBarsInput
float displayedTrail  = showTrailInput and inTrailWindow and not na(trailLine) ? trailLine : na

float trailOffsetVal      = atrVal * trailOffsetInput
float trailSecondaryNow   = trailDoubleInput and showTrailInput and inTrailWindow and not na(trailLine) ?
     (dir == 1 ? trailLine - trailOffsetVal : dir == -1 ? trailLine + trailOffsetVal : na) : na

color trailColorSecondary = color.new(trailColor, math.min(95, color.t(trailColor) + 20))

var int dashBufferSize    = math.max(1, math.min(490, trailHistoryBarsInput == 0 ? 490 : trailHistoryBarsInput))
var array<line> dashSegments = array.new<line>(dashBufferSize, na)
var int dashWriteIdx      = 0

float prevSecondary = trailSecondaryNow[1]
int   prevDir       = nz(dir[1], 0)
bool  drawDashSegment = trailDoubleInput and not na(trailSecondaryNow) and not na(prevSecondary) and dir == prevDir and dir != 0

if drawDashSegment
    line oldSeg = array.get(dashSegments, dashWriteIdx)
    if not na(oldSeg)
        line.delete(oldSeg)
    line newSeg = line.new(bar_index - 1, prevSecondary, bar_index, trailSecondaryNow,
         color = trailColorSecondary, style = line.style_dashed, width = 1)
    array.set(dashSegments, dashWriteIdx, newSeg)
    if barstate.isconfirmed
        dashWriteIdx := (dashWriteIdx + 1) % dashBufferSize

if dir != prevDir and prevDir != 0
    for i = 0 to dashBufferSize - 1
        line ghost = array.get(dashSegments, i)
        if not na(ghost)
            line.delete(ghost)
            array.set(dashSegments, i, na)

plot(displayedTrail, "AcroTrail",
     color = trailColor, linewidth = trailWidthInput, style = plot.style_linebr)

color bgRegimeColor = not showRegimeBgInput ? na :
     isTrending and dir == 1  ? TREND_BG_BULL :
     isTrending and dir == -1 ? TREND_BG_BEAR :
     isChoppy                 ? CHOPPY_BG     : na

bgcolor(bgRegimeColor, title = "Regime Background")


// ══════════════════════════════════════════════════════════
// 14. SIGNAL LABELS
// ══════════════════════════════════════════════════════════

if showSignalsInput and buyPasses
    string buyHtfStr  = useHtfFilterInput ? (htfBull ? "Bullish ✓" : "Bearish ✗") : "off"
    string buyVolStr  = not useVolumeFilterInput ? "off" : not volAvailable ? "no data (index)" : volConfirm ? "✓" : "✗"
    string flipPrefix = buyFlip ? "FLIP→LONG\n" : ""
    string expiryNote = isExpiryWarn ? "\nExpiry window — use caution" : ""
    string openNote   = isOpeningWind and not isDailyChart ? "\nOpening volatility window" : ""
    string tipBuy = flipPrefix + "BUY Signal\nGrade: " + buyGrade +
         " (" + str.tostring(buyQuality, "#") + "/100)\n" +
         "Regime: " + regimeLabel + " (" + str.tostring(regimeScore, "#") + ")\n" +
         "HTF (" + htfRes + "): " + buyHtfStr + "\n" +
         "Volume: " + buyVolStr + "\nRSI: " + str.tostring(rsiVal, "#.0") +
         "\nWeights: HTF " + str.tostring(wHtf, "#.#") +
         " Vol " + str.tostring(wVol, "#.#") +
         " RSI " + str.tostring(wRsi, "#.#") +
         " Reg " + str.tostring(wReg, "#.#") +
         " Brk " + str.tostring(wBrk, "#.#") +
         expiryNote + openNote
    string buyLabelText = showGradeInput ?
         "Long ▲ " + buyGrade + warnSuffix : "Long ▲" + warnSuffix
    // Label color changes on warning conditions
    color buyBgColor  = isExpiryWarn ? EXPIRY_COLOR : isOpeningWind and not isDailyChart ? OPEN_VOL_COLOR : isChoppy ? neutralColorInput : bullColorInput
    color buyTxtColor = isChoppy ? WARN_LABEL_TEXT : BULL_LABEL_TEXT
    label.new(bar_index, low, buyLabelText,
         color     = buyBgColor,
         textcolor = buyTxtColor,
         style     = label.style_label_up,
         size      = signalMarkerSize,
         yloc      = yloc.belowbar,
         tooltip   = tipBuy)

if showSignalsInput and sellPasses
    string sellHtfStr = useHtfFilterInput ? (htfBear ? "Bearish ✓" : "Bullish ✗") : "off"
    string sellVolStr = not useVolumeFilterInput ? "off" : not volAvailable ? "no data (index)" : volConfirm ? "✓" : "✗"
    string flipPrefix = sellFlip ? "FLIP→SHORT\n" : ""
    string expiryNote = isExpiryWarn ? "\nExpiry window — use caution" : ""
    string openNote   = isOpeningWind and not isDailyChart ? "\nOpening volatility window" : ""
    string tipSell = flipPrefix + "SELL Signal\nGrade: " + sellGrade +
         " (" + str.tostring(sellQuality, "#") + "/100)\n" +
         "Regime: " + regimeLabel + " (" + str.tostring(regimeScore, "#") + ")\n" +
         "HTF (" + htfRes + "): " + sellHtfStr + "\n" +
         "Volume: " + sellVolStr + "\nRSI: " + str.tostring(rsiVal, "#.0") +
         "\nWeights: HTF " + str.tostring(wHtf, "#.#") +
         " Vol " + str.tostring(wVol, "#.#") +
         " RSI " + str.tostring(wRsi, "#.#") +
         " Reg " + str.tostring(wReg, "#.#") +
         " Brk " + str.tostring(wBrk, "#.#") +
         expiryNote + openNote
    string sellLabelText = showGradeInput ?
         "Short ▼ " + sellGrade + warnSuffix : "Short ▼" + warnSuffix
    color sellBgColor  = isExpiryWarn ? EXPIRY_COLOR : isOpeningWind and not isDailyChart ? OPEN_VOL_COLOR : isChoppy ? neutralColorInput : bearColorInput
    color sellTxtColor = isChoppy ? WARN_LABEL_TEXT : BEAR_LABEL_TEXT
    label.new(bar_index, high, sellLabelText,
         color     = sellBgColor,
         textcolor = sellTxtColor,
         style     = label.style_label_down,
         size      = signalMarkerSize,
         yloc      = yloc.abovebar,
         tooltip   = tipSell)


// ══════════════════════════════════════════════════════════
// 15. SL/TP LINES & LABELS
// ══════════════════════════════════════════════════════════

var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na
var line entryLine = na

var label slLabel    = na
var label tp1Label   = na
var label tp2Label   = na
var label tp3Label   = na
var label entryLabel = na

var bool riskLinesActive = false

if (buyPasses or sellPasses) and showSlTpInput
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(entryLine)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    label.delete(entryLabel)

    int x1 = bar_index
    int x2 = bar_index + LINE_FORWARD_BARS

    entryLine := line.new(x1, activeEntry, x2, activeEntry, color = ENTRY_COLOR, style = entryLineStyle, width = 1)
    slLine    := line.new(x1, activeSL,    x2, activeSL,    color = SL_COLOR,    style = slLineStyle,    width = 1)
    tp1Line   := line.new(x1, activeTP1,   x2, activeTP1,   color = TP1_COLOR,   style = tpLineStyle,    width = 1)
    tp2Line   := line.new(x1, activeTP2,   x2, activeTP2,   color = TP2_COLOR,   style = tpLineStyle,    width = 1)
    tp3Line   := line.new(x1, activeTP3,   x2, activeTP3,   color = TP3_COLOR,   style = tpLineStyle,    width = 1)

    if showSlTpLabelsInput
        int lblX    = x2 + LABEL_OFFSET_BARS
        string entryS = str.tostring(activeEntry, format.mintick)
        string slS    = fmtPrice(activeSL)  + formatPctFromEntry(activeSL,  activeEntry)
        string tp1S   = fmtPrice(activeTP1) + formatPctFromEntry(activeTP1, activeEntry)
        string tp2S   = fmtPrice(activeTP2) + formatPctFromEntry(activeTP2, activeEntry)
        string tp3S   = fmtPrice(activeTP3) + formatPctFromEntry(activeTP3, activeEntry)

        entryLabel := label.new(lblX, activeEntry, "ENTRY " + entryS,
             color = ENTRY_COLOR,    textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        slLabel    := label.new(lblX, activeSL,    "SL " + slS,
             color = SL_COLOR,       textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp1Label   := label.new(lblX, activeTP1,   "TP1 " + tp1S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp2Label   := label.new(lblX, activeTP2,   "TP2 " + tp2S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp3Label   := label.new(lblX, activeTP3,   "TP3 " + tp3S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)

    riskLinesActive := true

if showSlTpInput and not na(tp1Line) and displayTp1Reached
    line.set_color(tp1Line, TP_HIT_COLOR)
    line.set_style(tp1Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp1Label)
        label.set_text(tp1Label, "TP1 ✓ " + fmtPrice(exitTP1) + formatPctFromEntry(exitTP1, exitEntry))
        label.set_color(tp1Label, TP_HIT_COLOR)
if showSlTpInput and not na(tp2Line) and displayTp2Reached
    line.set_color(tp2Line, TP_HIT_COLOR)
    line.set_style(tp2Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp2Label)
        label.set_text(tp2Label, "TP2 ✓ " + fmtPrice(exitTP2) + formatPctFromEntry(exitTP2, exitEntry))
        label.set_color(tp2Label, TP_HIT_COLOR)
if showSlTpInput and not na(tp3Line) and displayTp3Reached
    line.set_color(tp3Line, TP_HIT_COLOR)
    line.set_style(tp3Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp3Label)
        label.set_text(tp3Label, "TP3 ✓ " + fmtPrice(exitTP3) + formatPctFromEntry(exitTP3, exitEntry))
        label.set_color(tp3Label, TP_HIT_COLOR)

if showSlTpInput and beActive and activeDir != 0
    if not na(slLine)
        line.set_color(slLine, color.new(SL_COLOR, 70))
    if showSlTpLabelsInput
        if not na(slLabel)
            label.set_color(slLabel, color.new(SL_COLOR, 70))
        if not na(entryLabel)
            string entryS = str.tostring(activeEntry, format.mintick)
            label.set_text(entryLabel, "ENTRY " + entryS + "  → SL (BE)")
            label.set_color(entryLabel, BE_COLOR)

if activeDir != 0 and showSlTpInput and not na(slLine)
    int newX2  = bar_index + LINE_UPDATE_BARS
    int newLblX = newX2 + LABEL_OFFSET_BARS
    line.set_x2(slLine,    newX2)
    line.set_x2(tp1Line,   newX2)
    line.set_x2(tp2Line,   newX2)
    line.set_x2(tp3Line,   newX2)
    line.set_x2(entryLine, newX2)
    if showSlTpLabelsInput and not na(slLabel)
        label.set_x(slLabel,    newLblX)
        label.set_x(tp1Label,   newLblX)
        label.set_x(tp2Label,   newLblX)
        label.set_x(tp3Label,   newLblX)
        label.set_x(entryLabel, newLblX)

if activeDir == 0 and riskLinesActive
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(entryLine)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    label.delete(entryLabel)
    riskLinesActive := false


// ══════════════════════════════════════════════════════════
// 16. SIGNAL STATS TALLIES
// ══════════════════════════════════════════════════════════

if buyPasses
    statTotalSignals += 1
    statBuySignals   += 1
    if buyGrade == "A"
        statGradeA += 1
    else if buyGrade == "B"
        statGradeB += 1
    else
        statGradeC += 1

if sellPasses
    statTotalSignals += 1
    statSellSignals  += 1
    if sellGrade == "A"
        statGradeA += 1
    else if sellGrade == "B"
        statGradeB += 1
    else
        statGradeC += 1

int   closedTrades = statWins + statLosses
float winRate      = closedTrades > 0 ? statWins / float(closedTrades) * 100.0 : 0.0
float avgR         = closedTrades > 0 ? statRSum / float(closedTrades) : 0.0


// ══════════════════════════════════════════════════════════
// 17. UNIFIED DASHBOARD
// ══════════════════════════════════════════════════════════

dashPos = resolveDashPos(dashPosStr)
float currentRR = activeDir != 0 and activeEntry != activeSL ?
     math.abs(activeTP1 - activeEntry) / math.abs(activeEntry - activeSL) : 0.0

var string dashDirGrade  = "FLAT"
var color  dashDirCol    = na
var string dashSl        = "—"
var string dashTp1       = "—"
var string dashTp2       = "—"
var string dashTp3       = "—"
var color  dashSlCol     = na
var color  dashTp1Col    = na
var color  dashTp2Col    = na
var color  dashTp3Col    = na
var string dashRiskRR    = "—"
var color  dashRiskCol   = na
var string dashBars      = "—"
var string dashRegime    = ""
var string dashHtfBias   = "off"
var color  dashHtfCol    = na
var string dashVol       = "off"
var color  dashVolCol    = na
var string dashRsi       = "0"
var color  dashRsiCol    = na
var string dashVolReg    = "—"
var string dashSession   = ""
var color  dashSessionCol = na
var string dashWHtf      = "—"
var string dashWVol      = "—"
var string dashWRsi      = "—"
var string dashWReg      = "—"
var string dashWBrk      = "—"
var string dashWMode     = ""
var string dashSignals   = "0"
var string dashBuySell   = "0 / 0"
var string dashClosed    = "0"
var string dashWL        = "0 / 0"
var string dashWinRate   = "—"
var string dashAvgR      = "—"
var string dashBeSaves   = "0"
var string dashFlips     = "0"
var color  winRateCol    = na
var color  avgRCol       = na

if showDashInput and barstate.islast
    // Trade section
    string gradeSuffix = activeGrade != "" ? " (" + activeGrade + ")" : ""
    dashDirGrade := activeDir == 1 ? "LONG" + gradeSuffix : activeDir == -1 ? "SHORT" + gradeSuffix : "FLAT"
    dashDirCol   := activeDir == 1 ? BULL_TEXT : activeDir == -1 ? BEAR_TEXT : TEXT_MUTED
    dashSl  := activeDir != 0 ? (beActive ? "BE @ " : "") + fmtPrice(activeSL)  : "—"
    dashTp1 := activeDir != 0 ? (tp1Reached ? "✓ " : "") + fmtPrice(activeTP1) : "—"
    dashTp2 := activeDir != 0 ? (tp2Reached ? "✓ " : "") + fmtPrice(activeTP2) : "—"
    dashTp3 := activeDir != 0 ? (tp3Reached ? "✓ " : "") + fmtPrice(activeTP3) : "—"
    dashSlCol  := activeDir == 0 ? TEXT_MUTED : beActive ? BE_COLOR : SL_COLOR
    dashTp1Col := activeDir == 0 ? TEXT_MUTED : tp1Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    dashTp2Col := activeDir == 0 ? TEXT_MUTED : tp2Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    dashTp3Col := activeDir == 0 ? TEXT_MUTED : tp3Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    float riskPctVal = activeDir != 0 and activeEntry != 0 ? math.abs(activeEntry - activeSL) / activeEntry * 100.0 : 0.0
    string riskPctStr = activeDir != 0 ? str.tostring(riskPctVal, "#.##") + "%" : "—"
    string rrStr      = activeDir != 0 ? str.tostring(currentRR, "#.#") + "R" : "—"
    string rrGauge    = activeDir != 0 ? buildGauge(currentRR, 3.0, 6) : ""
    dashRiskRR  := activeDir != 0 ? rrGauge + "  " + riskPctStr + " / " + rrStr : "—"
    dashRiskCol := riskPctVal > 3.0 ? BEAR_TEXT : riskPctVal > 1.0 ? NEUTRAL_TEXT : riskPctVal > 0 ? BULL_TEXT : TEXT_MUTED
    int barsInTrade = activeDir != 0 and activeBar > 0 ? bar_index - activeBar : 0
    dashBars := activeDir != 0 ? str.tostring(barsInTrade) : "—"

    // Market section
    dashRegime  := regimeLabel + "  " + buildGauge(regimeScore, 100, 8)
    dashHtfBias := not useHtfFilterInput ? "off" : htfBull ? "Bullish" : htfBear ? "Bearish" : "Flat"
    dashHtfCol  := not useHtfFilterInput ? TEXT_MUTED : htfBull ? BULL_TEXT : htfBear ? BEAR_TEXT : NEUTRAL_TEXT
    dashVol     := not useVolumeFilterInput ? "off" : not volAvailable ? "no data" : volConfirm ? "Confirmed" : "Weak"
    dashVolCol  := not useVolumeFilterInput or not volAvailable ? TEXT_MUTED : volConfirm ? BULL_TEXT : NEUTRAL_TEXT
    dashRsi     := str.tostring(rsiVal, "#.0")
    dashRsiCol  := rsiVal > 60 ? BULL_TEXT : rsiVal < 40 ? BEAR_TEXT : TEXT_MUTED
    dashVolReg  := useAdaptiveMultInput ?
         str.tostring(atrVal, format.mintick) + " | " + str.tostring(volRank, "#") + "% (×" + str.tostring(multAdjust, "#.##") + ")" :
         str.tostring(atrVal, format.mintick) + " | (off)"

    // Session status for dashboard
    string sessionStr = isDailyChart ? "Daily (no gate)" :
         not isInSession ? "Outside session" :
         isExpiryWarn    ? (dayofweek == dayofweek.tuesday ? "Tue Expiry 🔔" : "Thu Expiry 🔔") :
         isOpeningWind   ? "Opening ⚡" : "Active"
    dashSession    := sessionStr
    dashSessionCol := isDailyChart ? TEXT_MUTED :
         not isInSession ? BEAR_TEXT :
         isExpiryWarn    ? EXPIRY_COLOR :
         isOpeningWind   ? OPEN_VOL_COLOR : BULL_TEXT

    // Active weights section
    dashWMode := useCustomWeightsInput ? "Custom" : "Auto-adjust"
    dashWHtf  := str.tostring(wHtf, "#.#")
    dashWVol  := str.tostring(wVol, "#.#")
    dashWRsi  := str.tostring(wRsi, "#.#")
    dashWReg  := str.tostring(wReg, "#.#")
    dashWBrk  := str.tostring(wBrk, "#.#")

    // Stats section
    dashSignals := str.tostring(statTotalSignals) +
         " (A:" + str.tostring(statGradeA) +
         " B:" + str.tostring(statGradeB) +
         " C:" + str.tostring(statGradeC) + ")"
    dashBuySell := str.tostring(statBuySignals) + " / " + str.tostring(statSellSignals)
    dashClosed  := str.tostring(closedTrades)
    dashWL      := str.tostring(statWins) + " / " + str.tostring(statLosses)
    dashWinRate := closedTrades > 0 ? str.tostring(winRate, "#.#") + "%" : "—"
    dashAvgR    := closedTrades > 0 ? str.tostring(avgR, "+0.00;-0.00") + "R" : "—"
    dashBeSaves := statWins > 0 ?
         str.tostring(statBeSaves) + " (" + str.tostring(statBeSaves / float(statWins) * 100.0, "#") + "%)" :
         str.tostring(statBeSaves)
    dashFlips   := str.tostring(statFlips)
    winRateCol  := closedTrades == 0 ? TEXT_MUTED : winRate >= 55.0 ? BULL_TEXT : winRate >= 45.0 ? NEUTRAL_TEXT : BEAR_TEXT
    avgRCol     := closedTrades == 0 ? TEXT_MUTED : avgR > 0 ? BULL_TEXT : avgR < 0 ? BEAR_TEXT : TEXT_MUTED

    // Table sizing
    int tradeRows  = showTradeSectionInput  ? 9 : 0
    int marketRows = showMarketSectionInput ? 7 : 0
    int weightRows = showWeightSectionInput ? 7 : 0
    int statsRows  = showStatsInput         ? 9 : 0
    int totalRows  = 2 + tradeRows + marketRows + weightRows + statsRows

    // Dynamic section headers with live context
    int barsInTradeNow = activeDir != 0 and activeBar > 0 ? bar_index - activeBar : 0
    string tradeHeaderTxt  = activeDir == 0 ? "───  Trade · FLAT  ───" :
         "───  Trade · " + (activeDir == 1 ? "LONG" : "SHORT") + " · " + str.tostring(barsInTradeNow) + " bars  ───"
    string marketHeaderTxt = "───  Market · " + regimeLabel + "  ───"
    string weightHeaderTxt = "───  Weights · " + dashWMode + "  ───"
    string statsHeaderTxt  = closedTrades == 0 ? "───  Statistics · no trades  ───" :
         "───  Statistics · " + str.tostring(closedTrades) + " trades  ───"

    var table dashTable = table.new(dashPos, 2, totalRows,
         bgcolor      = TABLE_BG,
         border_color = TABLE_BORDER,
         border_width = 1,
         frame_color  = TABLE_BORDER,
         frame_width  = 1)

    int r = 0

    // Header
    table.cell(dashTable, 0, r, "◆  ACROTRAIL INDIA PRO",
         text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = size.small,
         text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)
    r += 1

    // Trade section
    if showTradeSectionInput
        table.cell(dashTable, 0, r, tradeHeaderTxt,
             text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny,
             text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        table.cell(dashTable, 0, r, "Direction",    text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashDirGrade,   text_color = dashDirCol,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "SL",           text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashSl,         text_color = dashSlCol,   text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "TP1",          text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashTp1,        text_color = dashTp1Col,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "TP2",          text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashTp2,        text_color = dashTp2Col,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "TP3",          text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashTp3,        text_color = dashTp3Col,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Risk / R:R",   text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashRiskRR,     text_color = dashRiskCol, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Bars in Trade", text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashBars,        text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Session",      text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT,
             tooltip = "NSE session status (IST).\n⚡ = opening volatility window (09:15-09:45)\n🔔 = expiry last 90 min (13:00-15:30)")
        table.cell(dashTable, 1, r, dashSession,    text_color = dashSessionCol, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1

    // Market section
    if showMarketSectionInput
        table.cell(dashTable, 0, r, marketHeaderTxt,
             text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny,
             text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        table.cell(dashTable, 0, r, "Regime",       text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashRegime,     text_color = regimeColor,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "HTF (" + htfRes + ")", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashHtfBias,    text_color = dashHtfCol,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Volume",       text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashVol,        text_color = dashVolCol,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "RSI",          text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashRsi,        text_color = dashRsiCol,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "ATR | Vol%",   text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashVolReg,     text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Instrument",   text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, instrTypeInput + (isIndex ? " · " + indexSubtypeInput : ""),
             text_color = TEXT_COLOR, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1

    // Weights section
    if showWeightSectionInput
        table.cell(dashTable, 0, r, weightHeaderTxt,
             text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny,
             text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        // Weight sum warning: only matters for custom mode
        string wSumStr = useCustomWeightsInput ?
             (customWTotal == 100.0 ? "100 ✓" : str.tostring(customWTotal, "#.#") + " ⚠ (need 100)") :
             str.tostring(math.round(customWTotal), "#") + " (auto)"
        color wSumCol = useCustomWeightsInput and customWTotal != 100.0 ? BEAR_TEXT : BULL_TEXT
        table.cell(dashTable, 0, r, "Σ Weights",    text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, wSumStr,        text_color = wSumCol,    text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "HTF Bias",     text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashWHtf,       text_color = TEXT_COLOR,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Volume",       text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashWVol,       text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "RSI",          text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashWRsi,       text_color = TEXT_COLOR,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Regime",       text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashWReg,       text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Breakout",     text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashWBrk,       text_color = TEXT_COLOR,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1

    // Stats section
    if showStatsInput
        table.cell(dashTable, 0, r, statsHeaderTxt,
             text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny,
             text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        table.cell(dashTable, 0, r, "Signals",      text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashSignals,    text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Buy / Sell",   text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashBuySell,    text_color = TEXT_COLOR,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Closed",       text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashClosed,     text_color = TEXT_COLOR,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "W / L",        text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashWL,         text_color = TEXT_COLOR,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "Win Rate",     text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashWinRate,    text_color = winRateCol,  text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Avg R",        text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashAvgR,       text_color = avgRCol,    text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1
        table.cell(dashTable, 0, r, "BE Saves",     text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashBeSaves,    text_color = BE_COLOR,    text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Flips",        text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, r, dashFlips,      text_color = NEUTRAL_TEXT, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        r += 1

    // Version footer
    table.cell(dashTable, 0, r, "ATP " + INDICATOR_VERSION + "  |  Acrofins",
         text_color = TEXT_MUTED, text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)


// ══════════════════════════════════════════════════════════
// 18. WATERMARK
// ══════════════════════════════════════════════════════════

if barstate.islast and showWatermarkInput
    var table wmTable = table.new(
         position     = position.bottom_center,
         columns      = 1,
         rows         = 1,
         bgcolor      = color.new(color.black, 100),
         border_color = color.new(color.black, 100),
         border_width = 0,
         frame_color  = color.new(color.black, 100),
         frame_width  = 0)
    table.cell(wmTable, 0, 0, "Acrofins | AcroTrail India Pro",
         text_color  = WM_COLOR,
         text_size   = size.tiny,
         text_halign = text.align_center,
         bgcolor     = color.new(color.black, 100))


// ══════════════════════════════════════════════════════════
// 19. ALERTS
// ══════════════════════════════════════════════════════════

bool entryAlertFires = buyPasses or sellPasses
bool exitAlertFires  = slHit or tp1FirstTouch or tp2FirstTouch or tp3FirstTouch or beJustActivated

if entryAlertFires
    string aPrice    = str.tostring(close, format.mintick)
    string aSl       = fmtActive(activeSL)
    string aTp1      = fmtActive(activeTP1)
    string aTp2      = fmtActive(activeTP2)
    string aTp3      = fmtActive(activeTP3)
    string aRR       = str.tostring(currentRR, "#.#")
    string aTime     = str.format_time(time, "yyyy-MM-dd HH:mm", "Asia/Kolkata")
    string flipTag   = flipDetected ? " (FLIP)" : ""
    string expiryTag = isExpiryWarn ? " [EXPIRY]" : ""
    string openTag   = isOpeningWind and not isDailyChart ? " [OPEN-VOL]" : ""
    string warnTag   = expiryTag + openTag
    string flipJsonBool = flipDetected ? "true" : "false"
    string instrTag  = instrTypeInput + (isIndex ? "-" + indexSubtypeInput : "")

    if buyPasses
        string buyText = "🟢 BUY [" + buyGrade + "]" + chopFlag + warnTag + flipTag +
             " | " + syminfo.tickerid + " | " + instrTag +
             " | TF: " + timeframe.period +
             " | Price: " + aPrice + " | SL: " + aSl +
             " | TP1: " + aTp1 + " | TP2: " + aTp2 + " | TP3: " + aTp3 +
             " | R:R: " + aRR +
             " | Regime: " + regimeLabel +
             " | Score: " + str.tostring(buyQuality, "#") +
             " | Time IST: " + aTime
        string buyJson = '{"action":"buy","ticker":"' + syminfo.tickerid +
             '","instrument":"' + instrTag +
             '","tf":"' + timeframe.period +
             '","price":' + aPrice +
             ',"sl":' + aSl + ',"tp1":' + aTp1 + ',"tp2":' + aTp2 + ',"tp3":' + aTp3 +
             ',"rr":' + aRR + ',"grade":"' + buyGrade +
             '","quality":' + str.tostring(buyQuality, "#") +
             ',"regime":"' + regimeLabel +
             '","choppy":' + (isChoppy ? "true" : "false") +
             ',"expiry_warn":' + (isExpiryWarn ? "true" : "false") +
             ',"open_vol":' + (isOpeningWind and not isDailyChart ? "true" : "false") +
             ',"flip":' + flipJsonBool + '}'
        alert(webhookInput ? buyJson : buyText, alert.freq_once_per_bar_close)

    if sellPasses
        string sellText = "🔴 SELL [" + sellGrade + "]" + chopFlag + warnTag + flipTag +
             " | " + syminfo.tickerid + " | " + instrTag +
             " | TF: " + timeframe.period +
             " | Price: " + aPrice + " | SL: " + aSl +
             " | TP1: " + aTp1 + " | TP2: " + aTp2 + " | TP3: " + aTp3 +
             " | R:R: " + aRR +
             " | Regime: " + regimeLabel +
             " | Score: " + str.tostring(sellQuality, "#") +
             " | Time IST: " + aTime
        string sellJson = '{"action":"sell","ticker":"' + syminfo.tickerid +
             '","instrument":"' + instrTag +
             '","tf":"' + timeframe.period +
             '","price":' + aPrice +
             ',"sl":' + aSl + ',"tp1":' + aTp1 + ',"tp2":' + aTp2 + ',"tp3":' + aTp3 +
             ',"rr":' + aRR + ',"grade":"' + sellGrade +
             '","quality":' + str.tostring(sellQuality, "#") +
             ',"regime":"' + regimeLabel +
             '","choppy":' + (isChoppy ? "true" : "false") +
             ',"expiry_warn":' + (isExpiryWarn ? "true" : "false") +
             ',"open_vol":' + (isOpeningWind and not isDailyChart ? "true" : "false") +
             ',"flip":' + flipJsonBool + '}'
        alert(webhookInput ? sellJson : sellText, alert.freq_once_per_bar_close)

    if flipDetected and alertFlipInput
        string flipText = "🔄 FLIP " + flipFromDir + "→" + flipToDir +
             " | " + syminfo.tickerid + " | TF: " + timeframe.period +
             " | Prior Entry: " + fmtActive(flipFromEntry) +
             " | New Entry: " + aPrice + " | Time IST: " + aTime
        string flipJson = '{"action":"flip","from":"' + flipFromDir + '","to":"' + flipToDir +
             '","ticker":"' + syminfo.tickerid +
             '","tf":"' + timeframe.period +
             '","prior_entry":' + fmtActive(flipFromEntry) +
             ',"new_entry":' + aPrice + '}'
        alert(webhookInput ? flipJson : flipText, alert.freq_once_per_bar_close)

if exitAlertFires
    string eEntry = fmtActive(exitEntry)
    string eSL    = fmtActive(exitSL)
    string eTp1   = fmtActive(exitTP1)
    string eTp2   = fmtActive(exitTP2)
    string eTp3   = fmtActive(exitTP3)
    string aTime  = str.format_time(time, "yyyy-MM-dd HH:mm", "Asia/Kolkata")

    if slHit and alertSlHitInput
        string slMsg = (exitBeActive ? "🛡️ BE STOP-OUT | " : "🛑 SL HIT | ") +
             syminfo.tickerid + " | Entry: " + eEntry + " | SL: " + eSL +
             " | Time IST: " + aTime
        alert(slMsg, alert.freq_once_per_bar_close)

    if beJustActivated and alertTpHitInput
        alert("🛡️ BREAK-EVEN | " + syminfo.tickerid + " | SL moved to " + eEntry, alert.freq_once_per_bar_close)

    if tp1FirstTouch and alertTpHitInput
        alert("🎯 TP1 HIT | " + syminfo.tickerid + " | " + eTp1, alert.freq_once_per_bar_close)
    if tp2FirstTouch and alertTpHitInput
        alert("🎯🎯 TP2 HIT | " + syminfo.tickerid + " | " + eTp2, alert.freq_once_per_bar_close)
    if tp3FirstTouch and alertTpHitInput
        alert("🏆 TP3 HIT | " + syminfo.tickerid + " | " + eTp3, alert.freq_once_per_bar_close)
````
