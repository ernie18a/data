# UM Market Internals Table: TICK / PUT-CALL / ADV-DEC / VIX

- url: https://www.tradingview.com/script/Jxq6iWMW-UM-Market-Internals-Table-TICK-PUT-CALL-ADV-DEC-VIX/
- type: indicator
- pine_id: PUB;6aaf569e65ac4ecd9d45dfe0473c9ef8
- version: 1.0

## Description

[b]MARKET INTERNALS DASHBOARD[/b]
Real-time intraday breadth, sentiment & volatility — all in one table
Inspired by John Carter's book, Mastering the Trade.

━━━━━━━━━━━━━━━━━━━━━━━
[b]SUMMARY[/b]
━━━━━━━━━━━━━━━━━━━━━━━
A real-time dashboard that consolidates four key market internals into a single color-coded table overlay. Designed to give traders an at-a-glance read on intraday market breadth, sentiment, and volatility bias — all configurable to fit individual trading styles.

━━━━━━━━━━━━━━━━━━━━━━━
[b]INDICATOR PARAMETERS[/b]
━━━━━━━━━━━━━━━━━━━━━━━
TICK — Measures the net number of NYSE stocks ticking up versus down at any given moment. A high positive reading signals broad buying pressure; a deeply negative reading signals broad selling. Extreme readings (climax buy / capitulation) often mark short-term exhaustion and potential reversals.

PUT/CALL RATIO — Tracks the ratio of put options traded relative to call options, interpreted on a contrarian basis. A high ratio reflects fear and heavy hedging (bullish signal); a low ratio reflects complacency and call-heavy positioning (bearish signal).

ADV-DEC (Advance/Decline) — Measures the number of advancing stocks minus declining stocks on the NYSE. Strong positive readings confirm broad participation in a rally; strong negative readings confirm broad-based selling. Extreme readings may signal breadth exhaustion.

VIX — Rather than using the raw VIX level, this indicator applies a user-selected moving average (SMA, EMA, WMA, or Nadaraya-Watson Estimator) and reads the direction of that average. A falling VIX MA is interpreted as bullish (fear subsiding); a rising VIX MA is interpreted as bearish (fear increasing). This is a directional bias signal, not a level-based threshold.

━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW IT WORKS[/b]
━━━━━━━━━━━━━━━━━━━━━━━
Each internal is fetched via request.security() on a user-defined timeframe (default 5-minute for TICK, Put/Call, and ADV-DEC). VIX is plotted on the chart's native timeframe.

TICK, Put/Call, and ADV-DEC are evaluated against configurable thresholds to produce a rating label (e.g. BUYING, NEUTRAL, SELLING). The label and its cell background are color-coded: green for bullish readings, red for bearish, and yellow for neutral or mixed conditions.

VIX bias is determined by the slope of the selected moving average. The Nadaraya-Watson Estimator (NWE) option uses a kernel-smoothed regression curve — a shorter bandwidth (h) produces a more reactive curve; a larger h produces a smoother one.

The table displays three rows per column: the indicator label (header), the live numeric value, and the current rating.

━━━━━━━━━━━━━━━━━━━━━━━
[b]DEFAULT SETTINGS[/b]
━━━━━━━━━━━━━━━━━━━━━━━
Internals timeframe: 5-minute

TICK: Neutral |TICK| ≤ 200 | Buying/Selling ≥600/≤−600 | Extreme ≥1000/≤−1000 | Climax/Cap. ≥1200/≤−1200
Put/Call: Extreme bullish ≥1.10 | Bullish ≥0.90 | Neutral 0.65–0.85 | Bearish ≤0.55 | Extreme bearish ≤0.45
ADV-DEC: Neutral |ADV-DEC| ≤500 | Bullish/Bearish ≥800/≤−800 | Strong ≥2000/≤−2000 | Climax/Cap. ≥3500/≤−3500
VIX MA: Type EMA | Length 8 | NWE h/r/length 7.0/6.0/6

Table position: Bottom right | Alerts: Off by default

━━━━━━━━━━━━━━━━━━━━━━━
[b]SUGGESTED USES[/b]
━━━━━━━━━━━━━━━━━━━━━━━
Trend confirmation — When TICK, ADV-DEC, and VIX all agree, treat it as confirmation of an intraday trend. Look for entries aligned with that trend on your primary chart.

Fade setups — Climax Buy on TICK + Extreme Bullish Put/Call can signal short-term exhaustion. TICK Capitulation + Extreme Bearish P/C can flag washout lows worth fading.

Breadth divergence — If price makes new highs but ADV-DEC is weakening, use this as a caution flag rather than a directional signal.

VIX directional bias — A sustained bearish VIX bias suggests wider stops and reduced long exposure. A bullish VIX bias supports a more aggressive long-side approach.

Timeframe alignment — Designed for 1-, 3-, or 5-minute charts. Raise the internals timeframe to 15 minutes if you see "unsupported resolution" errors.

━━━━━━━━━━━━━━━━━━━━━━━
[b]ALERTS[/b]
━━━━━━━━━━━━━━━━━━━━━━━
16 alert conditions available — all off by default.

Step 1: Open Settings → Alerts group → toggle on desired alerts.
Step 2: Click the clock icon in TradingView → Create Alert → set condition to this indicator → pick the specific alert → save.

Alerts fire on bar close at threshold crossings only (not repeatedly).
Tip: right-click the table on your chart and select "Add alert."

Available alerts:
TICK: Buying, Extreme buying, Selling, Extreme selling, Capitulation
Put/Call: Bullish, Extreme bullish, Bearish, Extreme bearish
ADV-DEC: Bullish, Extreme bullish, Bearish, Extreme bearish, Capitulation
VIX: Bullish (MA turns down), Bearish (MA turns up)

Alert quick tip: right click the table and select Alert for quick setup.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © UnderwearMillionaire
//
// ============================================================
// SUMMARY
// ============================================================
// This script is a real-time dashboard that consolidates four key market internals
// and updates continuously throughout the day.
// into a single color-coded table overlay. Designed to give traders
// an at-a-glance read on intraday market breadth, sentiment, and
// volatility bias — all configurable to fit individual trading styles.
// Shout out to John Carter and his book, Mastering the Trade, for giving me this idea.
// ============================================================
// DESCRIPTION
// ============================================================
// TICK — Measures the net number of NYSE stocks ticking up versus
// down at any given moment. A high positive reading signals broad
// buying pressure; a deeply negative reading signals broad selling.
// Extreme readings (climax buy / capitulation) often mark short-term
// exhaustion and potential reversals.
//
// PUT/CALL RATIO — Tracks the ratio of put options traded relative
// to call options. Interpreted on a contrarian basis: a high ratio
// reflects fear and heavy hedging (bullish signal), while a low ratio
// reflects complacency and call-heavy positioning (bearish signal).
//
// ADV-DEC (Advance/Decline) — Measures the number of advancing stocks
// minus declining stocks on the NYSE. Strong positive readings confirm
// broad participation in a rally; strong negative readings confirm
// broad-based selling. Extreme readings may signal breadth exhaustion.
//
// VIX — The CBOE Volatility Index ("fear gauge"). Rather than using
// the raw VIX level, this indicator applies a user-selected moving
// average (SMA, EMA, WMA, or Nadaraya-Watson Estimator) to the VIX
// and reads the direction of that average. A falling VIX MA is
// interpreted as BULLISH (fear subsiding); a rising VIX MA is
// interpreted as BEARISH (fear increasing). This is a directional
// bias signal, not a level-based threshold.
//
// ============================================================
// HOW IT WORKS
// ============================================================
// Each internal is fetched via request.security() on a user-defined
// timeframe (default 5-minute for TICK, PUT/CALL, and ADV-DEC). VIX
// is plotted on the chart's native timeframe.
//
// TICK, PUT/CALL, and ADV-DEC are evaluated against configurable
// thresholds to produce a rating label (e.g. BUYING, NEUTRAL, SELLING).
// The label and its cell background are color-coded: green for bullish
// readings, red for bearish, and yellow for neutral or mixed conditions.
//
// VIX bias is determined by the slope of the selected moving average:
//   - SMA / EMA / WMA: standard moving average of the selected length.
//   - NWE (Nadaraya-Watson Estimator): a kernel-smoothed regression
//     curve. Parameters h (bandwidth), r (relative weight), and length
//     control the smoothness of the fit. A shorter h produces a more
//     reactive curve; a larger h produces a smoother one.
//
// The table displays three rows per column: the indicator label
// (header), the live numeric value, and the current rating.
//
// ============================================================
// DEFAULT SETTINGS
// ============================================================
// Internals Timeframe:     5-minute
//
// TICK Thresholds:
//   Neutral:               |TICK| <= 200
//   Buying / Selling:      >= 600 / <= -600
//   Extreme Buy / Sell:    >= 1000 / <= -1000
//   Climax Buy / Capit.:   >= 1200 / <= -1200
//
// PUT/CALL Thresholds (contrarian):
//   Extreme Bullish:       >= 1.10
//   Bullish:               >= 0.90
//   Neutral Band:          0.65 – 0.85
//   Bearish:               <= 0.55
//   Extreme Bearish:       <= 0.45
//
// ADV-DEC Thresholds:
//   Neutral:               |ADV-DEC| <= 500
//   Bullish / Bearish:     >= 800 / <= -800
//   Strong Bull / Bear:    >= 2000 / <= -2000
//   Breadth Climax / Cap.: >= 3500 / <= -3500
//
// VIX MA:
//   Type:                  EMA
//   Length:                8
//   NWE h / r / length:    7.0 / 6.0 / 6 (used only when NWE selected)
//
// Table Position:          Bottom Right
// All Alerts:              Off
//
// The default Table location  is the lower right.
//
// All settings and symbols are user-configurable.
// ============================================================
// SUGGESTED USES
// ============================================================
// TREND CONFIRMATION — When TICK, ADV-DEC, and VIX all agree
// (e.g. TICK BUYING, ADV-DEC BULLISH, VIX BULLISH), treat it as
// confirmation of an intraday trend in progress. Look for entries
// aligned with that trend on your primary chart.
//
// FADE SETUPS — Climax Buy on TICK combined with an Extreme Bullish
// PUT/CALL reading (heavy calls, complacency) can signal short-term
// exhaustion. Similarly, TICK Capitulation with Extreme Bearish P/C
// can flag washout lows worth fading.
//
// BREADTH DIVERGENCE — If price is making new highs but ADV-DEC is
// weakening (NEUTRAL or BEARISH), internal breadth is not confirming
// the move. Use this as a caution flag rather than a directional signal.
//
// VIX DIRECTIONAL BIAS — Use the VIX MA bias as a session-level
// backdrop. A sustained BEARISH VIX bias (rising fear) suggests using
// wider stops and reducing long exposure. A BULLISH VIX bias (falling
// fear) supports a more aggressive long-side approach.
//
// TIMEFRAME ALIGNMENT — The indicator is designed for intraday use
// on 1-, 3-, or 5-minute charts. The internals timeframe can be raised
// to 15 minutes on symbols that return "unsupported resolution" errors.
//
// I use this on all my charts (daily and intraday) to get a read on market internals
//
// ============================================================
// ALERTS
// ============================================================
// Sixteen individual alert conditions are available, each covering a
// specific threshold crossing. All alerts are disabled by default and
// must be enabled in two steps:
//
//   Step 1 — Open the indicator's Settings panel, navigate to the
//   "Alerts" group, and toggle on each alert you want active.
//
//   Step 2 — In TradingView, click the clock icon to open "Create Alert."
//   Set the Condition to this indicator, then select the specific alert
//   from the dropdown (e.g. "TICK: Buying"). Configure your preferred
//   notification method and save.
//
// Alerts fire on the BAR CLOSE when a threshold is CROSSED — they do
// not fire repeatedly while a value remains above or below a level.
// This keeps notifications meaningful and avoids alert fatigue.
//
// Available alert conditions:
//   TICK:    Buying, Extreme Buying, Selling, Extreme Selling, Capitulation
//   P/C:     Bullish, Extreme Bullish, Bearish, Extreme Bearish
//   ADV-DEC: Bullish, Extreme Bullish, Bearish, Extreme Bearish, Capitulation
//   VIX:     Bullish (MA turns down), Bearish (MA turns up)
//
//  Alert Shortcut:  right click on the table after adding it to your chart
//  and select Add alert.

//@version=6
indicator("UM Market Internals Table: TICK / PUT-CALL / ADV-DEC / VIX", overlay=true)

//==========================
// Inputs
//==========================
symTick   = input.symbol("USI:TICK",      "TICK Symbol")
symPC     = input.symbol("USI:PC",        "Put/Call Ratio Symbol")
symAdvDec = input.symbol("USI:ADVDEC.NY", "ADV-DEC Symbol")
symVix    = input.symbol("CBOE:VIX",      "VIX Symbol")

internalsTF = input.timeframe("5", "Internals TF (TICK/PC/ADV-DEC)", tooltip="Timeframe used for TICK + PUT/CALL + ADV-DEC values.\n\nIf you see unsupported resolution errors, use 5 or 15.")

//--------------------------
// Thresholds (user-configurable)
//--------------------------
// TICK thresholds
tick_neutralAbs = input.int(200, "TICK Neutral Abs (≤)", minval=0, tooltip="If |TICK| ≤ this value, rating is NEUTRAL.")
tick_buying     = input.int(600, "TICK Buying (≥)", minval=0, tooltip="If TICK ≥ this value, rating becomes BUYING.")
tick_extBuy     = input.int(1000, "TICK Extreme Buy (≥)", minval=0, tooltip="If TICK ≥ this value, rating becomes EXTREME BUY.")
tick_climaxBuy  = input.int(1200, "TICK Climax Buy (≥)", minval=0, tooltip="If TICK ≥ this value, rating becomes CLIMAX BUY.")
tick_selling    = input.int(600, "TICK Selling (≤ -)", minval=0, tooltip="If TICK ≤ -this value, rating becomes SELLING.")
tick_extSell    = input.int(1000, "TICK Extreme Sell (≤ -)", minval=0, tooltip="If TICK ≤ -this value, rating becomes EXTREME SELL.")
tick_capit      = input.int(1200, "TICK Capitulation (≤ -)", minval=0, tooltip="If TICK ≤ -this value, rating becomes CAPITULATION.")

// PUT/CALL thresholds (intraday; contrarian)
pc_extBull = input.float(1.10, "P/C Extreme Bullish (≥)", minval=0.0, step=0.01, tooltip="High put/call = fear/hedging (contrarian bullish). ≥ this value = EXTREME BULLISH.")
pc_bull    = input.float(0.90, "P/C Bullish (≥)",         minval=0.0, step=0.01, tooltip="≥ this value (and < Extreme Bullish) = BULLISH (contrarian).")
pc_neuLo   = input.float(0.65, "P/C Neutral Low (≥)",      minval=0.0, step=0.01, tooltip="Neutral band lower bound (inclusive). Default 0.65.")
pc_neuHi   = input.float(0.85, "P/C Neutral High (≤)",     minval=0.0, step=0.01, tooltip="Neutral band upper bound (inclusive). Default 0.85.")
pc_bear    = input.float(0.55, "P/C Bearish (≤)",          minval=0.0, step=0.01, tooltip="Low put/call = complacency/call-heavy (contrarian bearish). ≤ this value = BEARISH.")
pc_extBear = input.float(0.45, "P/C Extreme Bearish (≤)",  minval=0.0, step=0.01, tooltip="≤ this value = EXTREME BEARISH (contrarian).")

// ADV-DEC thresholds
ad_neutralAbs   = input.int(500, "ADV-DEC Neutral Abs (≤)", minval=0, tooltip="If |ADV-DEC| ≤ this value, rating is NEUTRAL.")
ad_bullish      = input.int(800, "ADV-DEC Bullish (≥)", minval=0, tooltip="If ADV-DEC ≥ this value, rating becomes BULLISH.")
ad_strBull      = input.int(2000, "ADV-DEC Strong Bull (≥)", minval=0, tooltip="If ADV-DEC ≥ this value, rating becomes STRONG BULL.")
ad_breadthClmx  = input.int(3500, "ADV-DEC Breadth Climax (≥)", minval=0, tooltip="If ADV-DEC ≥ this value, rating becomes BREADTH CLIMAX.")
ad_bearish      = input.int(800, "ADV-DEC Bearish (≤ -)", minval=0, tooltip="If ADV-DEC ≤ -this value, rating becomes BEARISH.")
ad_strBear      = input.int(2000, "ADV-DEC Strong Bear (≤ -)", minval=0, tooltip="If ADV-DEC ≤ -this value, rating becomes STRONG BEAR.")
ad_capit        = input.int(3500, "ADV-DEC Capitulation (≤ -)", minval=0, tooltip="If ADV-DEC ≤ -this value, rating becomes CAPITULATION.")

// VIX MA type and length
vixMaType = input.string("EMA", "VIX MA Type", options=["SMA", "EMA", "WMA", "NWE"], tooltip="Moving average type for VIX bias direction. NWE uses the Nadaraya-Watson Estimator (configure below).  A rising VIX MA is bearish and a falling VIX MA is bullish")
vixMaLen  = input.int(8, "VIX MA Length", minval=1, tooltip="Length for SMA/EMA/WMA. Ignored when NWE is selected.")

// VIX NWE inputs (only used when MA Type = NWE; defaults 7,6,6)
nweH   = input.float(7.0, "VIX NWE h", minval=1.0, step=0.25, tooltip="[NWE only] Nadaraya-Watson h (lookback window). Default 7.")
nweR   = input.float(6.0, "VIX NWE r", minval=0.25, step=0.25, tooltip="[NWE only] Nadaraya-Watson r (relative weighting). Default 6.")
nweLen = input.int(6, "VIX NWE length", minval=2, tooltip="[NWE only] NWE kernel length (# of bars used). Default 6.")

// Alert toggles (all off by default)
al_tickBuying  = input.bool(false, "TICK Buying",         group="Alerts", tooltip="Alert when TICK crosses above the Buying threshold.")
al_tickExtBuy  = input.bool(false, "TICK Extreme Buying", group="Alerts", tooltip="Alert when TICK crosses above the Extreme Buy threshold.")
al_tickSelling = input.bool(false, "TICK Selling",        group="Alerts", tooltip="Alert when TICK crosses below the Selling threshold.")
al_tickExtSell = input.bool(false, "TICK Extreme Selling",group="Alerts", tooltip="Alert when TICK crosses below the Extreme Sell threshold.")
al_tickCapit   = input.bool(false, "TICK Capitulation",   group="Alerts", tooltip="Alert when TICK crosses below the Capitulation threshold.")
al_pcBull      = input.bool(false, "P/C Bullish",         group="Alerts", tooltip="Alert when Put/Call ratio crosses above the Bullish threshold (contrarian).")
al_pcExtBull   = input.bool(false, "P/C Extreme Bullish", group="Alerts", tooltip="Alert when Put/Call ratio crosses above the Extreme Bullish threshold (contrarian).")
al_pcBear      = input.bool(false, "P/C Bearish",         group="Alerts", tooltip="Alert when Put/Call ratio crosses below the Bearish threshold (contrarian).")
al_pcExtBear   = input.bool(false, "P/C Extreme Bearish", group="Alerts", tooltip="Alert when Put/Call ratio crosses below the Extreme Bearish threshold (contrarian).")
al_adBull      = input.bool(false, "A/D Bullish",         group="Alerts", tooltip="Alert when ADV-DEC crosses above the Bullish threshold.")
al_adExtBull   = input.bool(false, "A/D Extreme Bullish", group="Alerts", tooltip="Alert when ADV-DEC crosses above the Strong Bull threshold.")
al_adBear      = input.bool(false, "A/D Bearish",         group="Alerts", tooltip="Alert when ADV-DEC crosses below the Bearish threshold.")
al_adExtBear   = input.bool(false, "A/D Extreme Bearish", group="Alerts", tooltip="Alert when ADV-DEC crosses below the Strong Bear threshold.")
al_adCapit     = input.bool(false, "A/D Capitulation",    group="Alerts", tooltip="Alert when ADV-DEC crosses below the Capitulation threshold.")
al_vixBull     = input.bool(false, "VIX Bullish",         group="Alerts", tooltip="Alert when the VIX MA turns down (bullish signal).")
al_vixBear     = input.bool(false, "VIX Bearish",         group="Alerts", tooltip="Alert when the VIX MA turns up (bearish signal).")

// Table position
posOpt = input.string("Bottom Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"])
pos = switch posOpt
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_left

//==========================
// Security helper
//==========================
f_sec(_sym, _tf) =>
    request.security(_sym, _tf, close, barmerge.gaps_off, barmerge.lookahead_off)

// Internals (ALL intraday using internalsTF)
tick   = f_sec(symTick,   internalsTF)
pc     = f_sec(symPC,     internalsTF)
advdec = f_sec(symAdvDec, internalsTF)

// VIX on chart TF
vix    = f_sec(symVix, timeframe.period)

//==========================
// Ratings (KEEP AS SINGLE LINE)
//==========================
tickRating(float x) => na(x) ? "NO DATA" : x >= tick_climaxBuy ? "CLIMAX BUY" : x >= tick_extBuy ? "EXTREME BUY" : x >= tick_buying ? "BUYING" : x <= -tick_capit ? "CAPITULATION" : x <= -tick_extSell ? "EXTREME SELL" : x <= -tick_selling ? "SELLING" : math.abs(x) <= tick_neutralAbs ? "NEUTRAL" : "MIXED"
pcRating(float x) => na(x) ? "NO DATA" : x >= pc_extBull ? "EXTREME BULLISH" : x >= pc_bull ? "BULLISH" : (x >= pc_neuLo and x <= pc_neuHi) ? "NEUTRAL" : x <= pc_extBear ? "EXTREME BEARISH" : x <= pc_bear ? "BEARISH" : "MIXED"
advdecRating(float x) => na(x) ? "NO DATA" : x >= ad_breadthClmx ? "BREADTH CLIMAX" : x >= ad_strBull ? "STRONG BULL" : x >= ad_bullish ? "BULLISH" : x <= -ad_capit ? "CAPITULATION" : x <= -ad_strBear ? "STRONG BEAR" : x <= -ad_bearish ? "BEARISH" : math.abs(x) <= ad_neutralAbs ? "NEUTRAL" : "MIXED"

//==========================
// Rating-based colors (green/red/yellow based on rating string)
//==========================
isBull(string s) => str.contains(s, "BULL") or str.contains(s, "BUY")
isBear(string s) => str.contains(s, "BEAR") or str.contains(s, "SELL") or str.contains(s, "CAPITULATION") or str.contains(s, "PANIC")
ratingBg(string s) => isBull(s) ? color.new(color.lime, 75) : isBear(s) ? color.new(color.red, 75) : color.new(color.yellow, 70)
ratingText(string s) => isBull(s) ? color.rgb(0, 100, 0) : isBear(s) ? color.rgb(139, 0, 0) : color.rgb(120, 120, 0)

//==========================
// NWE for VIX (user-configurable, defaults 7,6,6)
//==========================
nwe(src, float h, float r, int len) =>
    float num = 0.0, den = 0.0
    float hr = math.max(0.0001, h * r)
    for i = 0 to len - 1
        float w = math.exp(-(i * i) / (2.0 * hr * hr))
        num += nz(src[i]) * w
        den += w
    den == 0.0 ? na : num / den

float vixNwe_raw = nwe(vix, nweH, nweR, nweLen)

// Select MA based on user type choice
float vixMa = switch vixMaType
    "SMA" => ta.sma(vix, vixMaLen)
    "EMA" => ta.ema(vix, vixMaLen)
    "WMA" => ta.wma(vix, vixMaLen)
    => vixNwe_raw  // NWE

float vixMaFinal = na(vix) ? na : vixMa

// Reversed logic: MA down => BULLISH, MA up => BEARISH
bool vixMaDown  = not na(vixMaFinal) and not na(vixMaFinal[1]) and vixMaFinal < vixMaFinal[1]
string vixBias  = na(vixMaFinal) or na(vixMaFinal[1]) ? "NO DATA" : (vixMaDown ? "BULLISH" : "BEARISH")

color vixTextCol = na(vixMaFinal) or na(vixMaFinal[1]) ? color.gray : (vixMaDown ? color.rgb(0,100,0) : color.rgb(139,0,0))
color vixBgCol   = na(vixMaFinal) or na(vixMaFinal[1]) ? color.new(color.gray, 85) : (vixMaDown ? color.new(color.lime, 75) : color.new(color.red, 75))

//==========================
// Formatting
//==========================
f_num(x, fmt) => na(x) ? "NA" : str.tostring(x, fmt)

//==========================
// Table styling
//==========================
blueBorder  = color.new(color.blue, 0)
headerBg    = color.new(color.silver, 0)
headerText  = color.new(color.black, 0)
cellBg      = color.new(color.white, 85)

//==========================
// Strings + colors used in table
//==========================
string tickStr   = tickRating(tick)
string pcStr     = pcRating(pc)
string advdecStr = advdecRating(advdec)

color tickCol   = ratingText(tickStr)
color pcCol     = ratingText(pcStr)
color advdecCol = ratingText(advdecStr)

//==========================
// Table
//==========================
var table t = table.new(pos, 4, 3,
     bgcolor=color.new(color.white, 100),
     frame_color=blueBorder, frame_width=1,
     border_color=blueBorder, border_width=1)

// Header row (light grey)
table.cell(t, 0, 0, "TICK",      text_size=size.small, text_color=headerText, bgcolor=headerBg)
table.cell(t, 1, 0, "PUT/CALL",  text_size=size.small, text_color=headerText, bgcolor=headerBg)
table.cell(t, 2, 0, "ADV-DEC",   text_size=size.small, text_color=headerText, bgcolor=headerBg)
table.cell(t, 3, 0, "VIX",       text_size=size.small, text_color=headerText, bgcolor=headerBg)

// Live values row
table.cell(t, 0, 1, f_num(tick,   "#"),    text_size=size.small, text_color=tickCol,   bgcolor=cellBg)
table.cell(t, 1, 1, f_num(pc,     "#.##"), text_size=size.small, text_color=pcCol,     bgcolor=cellBg)
table.cell(t, 2, 1, f_num(advdec, "#"),    text_size=size.small, text_color=advdecCol, bgcolor=cellBg)
table.cell(t, 3, 1, f_num(vix,    "#.##"), text_size=size.small, text_color=vixTextCol,bgcolor=cellBg)

// Ratings row (VIX uses custom reversed logic colors)
table.cell(t, 0, 2, tickStr,   text_size=size.small, text_color=ratingText(tickStr),   bgcolor=ratingBg(tickStr))
table.cell(t, 1, 2, pcStr,     text_size=size.small, text_color=ratingText(pcStr),     bgcolor=ratingBg(pcStr))
table.cell(t, 2, 2, advdecStr, text_size=size.small, text_color=ratingText(advdecStr), bgcolor=ratingBg(advdecStr))
table.cell(t, 3, 2, vixBias,   text_size=size.small, text_color=vixTextCol,            bgcolor=vixBgCol)

//==========================
// Alert crossing conditions (pre-computed every bar to avoid Pine Script history warnings)
//==========================
bool cross_tickBuying  = ta.crossover(tick,    tick_buying)
bool cross_tickExtBuy  = ta.crossover(tick,    tick_extBuy)
bool cross_tickSelling = ta.crossunder(tick,  -tick_selling)
bool cross_tickExtSell = ta.crossunder(tick,  -tick_extSell)
bool cross_tickCapit   = ta.crossunder(tick,  -tick_capit)
bool cross_pcBull      = ta.crossover(pc,      pc_bull)
bool cross_pcExtBull   = ta.crossover(pc,      pc_extBull)
bool cross_pcBear      = ta.crossunder(pc,     pc_bear)
bool cross_pcExtBear   = ta.crossunder(pc,     pc_extBear)
bool cross_adBull      = ta.crossover(advdec,  ad_bullish)
bool cross_adExtBull   = ta.crossover(advdec,  ad_strBull)
bool cross_adBear      = ta.crossunder(advdec, -ad_bearish)
bool cross_adExtBear   = ta.crossunder(advdec, -ad_strBear)
bool cross_adCapit     = ta.crossunder(advdec, -ad_capit)
bool cross_vixBull     = vixMaDown and not vixMaDown[1]
bool cross_vixBear     = not vixMaDown and vixMaDown[1]

//==========================
// Alerts
// Each alertcondition fires on a threshold CROSSING (not continuously while above/below).
// Enable individual alerts via the "Alerts" group in indicator settings, then
// add the alert in TradingView using "Create Alert → Condition → [this indicator]".
//==========================
alertcondition(al_tickBuying  and cross_tickBuying,  title="TICK: Buying",          message="TICK crossed into BUYING territory")
alertcondition(al_tickExtBuy  and cross_tickExtBuy,  title="TICK: Extreme Buying",  message="TICK crossed into EXTREME BUY territory")
alertcondition(al_tickSelling and cross_tickSelling, title="TICK: Selling",         message="TICK crossed into SELLING territory")
alertcondition(al_tickExtSell and cross_tickExtSell, title="TICK: Extreme Selling", message="TICK crossed into EXTREME SELL territory")
alertcondition(al_tickCapit   and cross_tickCapit,   title="TICK: Capitulation",    message="TICK crossed into CAPITULATION territory")
alertcondition(al_pcBull      and cross_pcBull,      title="P/C: Bullish",          message="Put/Call ratio entered BULLISH zone (contrarian)")
alertcondition(al_pcExtBull   and cross_pcExtBull,   title="P/C: Extreme Bullish",  message="Put/Call ratio entered EXTREME BULLISH zone (contrarian)")
alertcondition(al_pcBear      and cross_pcBear,      title="P/C: Bearish",          message="Put/Call ratio entered BEARISH zone (contrarian)")
alertcondition(al_pcExtBear   and cross_pcExtBear,   title="P/C: Extreme Bearish",  message="Put/Call ratio entered EXTREME BEARISH zone (contrarian)")
alertcondition(al_adBull      and cross_adBull,      title="A/D: Bullish",          message="ADV-DEC entered BULLISH territory")
alertcondition(al_adExtBull   and cross_adExtBull,   title="A/D: Extreme Bullish",  message="ADV-DEC entered STRONG BULL territory")
alertcondition(al_adBear      and cross_adBear,      title="A/D: Bearish",          message="ADV-DEC entered BEARISH territory")
alertcondition(al_adExtBear   and cross_adExtBear,   title="A/D: Extreme Bearish",  message="ADV-DEC entered STRONG BEAR territory")
alertcondition(al_adCapit     and cross_adCapit,     title="A/D: Capitulation",     message="ADV-DEC entered CAPITULATION territory")
alertcondition(al_vixBull     and cross_vixBull,     title="VIX: Bullish",          message="VIX MA turned down — BULLISH signal")
alertcondition(al_vixBear     and cross_vixBear,     title="VIX: Bearish",          message="VIX MA turned up — BEARISH signal")
````
