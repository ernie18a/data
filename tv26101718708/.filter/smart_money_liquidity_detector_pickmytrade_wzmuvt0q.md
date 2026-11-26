# Smart Money Liquidity Detector [PickMyTrade]

- url: https://www.tradingview.com/script/wzMUvT0Q-Smart-Money-Liquidity-Detector-PickMyTrade/
- type: indicator
- pine_id: PUB;fc166b76ea36422fb4c3b73e4b7be2ba
- version: 1.0

## Description

Smart Money Liquidity Detector [PickMyTrade]

This indicator measures market microstructure — the structural signals that institutional activity leaves behind in price and volume data. It combines four academically grounded models into a single Microstructure Stress Score (MSS) ranging from 0 to 100.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MODELS USED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

► Roll (1984)
Synthetic bid-ask spread estimated from the serial covariance of price changes. High Roll spread indicates wider market-maker quotes — historically associated with periods of elevated volatility.

► Corwin-Schultz (2012)
High-low range spread estimator. Uses the relationship between single-period and two-period high-low ranges to back out the effective spread without requiring tick data.

► Amihud (2002)
Illiquidity ratio measuring price move per unit of volume. High Amihud values mean large price impact per dollar traded — a sign of thin order books.

► Kyle Lambda (1985)
Price impact of signed order flow. Derived from the regression of price changes on volume direction. Estimates how aggressively informed participants are moving the market.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MICROSTRUCTURE STRESS SCORE (MSS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each model is z-scored over a rolling window, normalised to [0,1], then averaged and scaled to 0–100.

MSS = (Roll + Corwin-Schultz + Amihud + Kyle Lambda) / 4 × 100

- MSS > 70 → High stress. Spreads wide, illiquidity elevated, price impact high. Consistent with institutional order flow.
- MSS 30–70 → Normal range. No structural signal.
- MSS < 30 → Low stress. Tight spreads, liquid conditions, quiet tape.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANOMALY DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Any individual model z-score crossing ±2σ triggers an anomaly flag. Anomaly bars are highlighted in orange on the chart. Roll and Corwin-Schultz anomalies are marked with coloured circles directly on the MSS line.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INPUTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Spread window (default 20) — lookback for Roll and Corwin-Schultz estimation
- Z-score window (default 60) — rolling window for z-scoring all models
- Impact window (default 20) — lookback for Amihud and Kyle Lambda
- MSS normalise window (default 100) — window for [0,1] normalisation before scoring
- Toggle each model's z-score plot individually
- Highlight anomaly bars on/off
- Info table on/off

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INFO TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Top-right table displays live values and z-scores for all four models, the current MSS reading, and anomaly status on the last closed bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Works on any liquid instrument and any timeframe. Most effective on futures, forex, and equity indices where volume data is reliable.
- This indicator does not generate buy or sell signals. It is a market structure diagnostic tool.
- Powered by PickMyTradeLib — PickMyTrade's open quantitative library.

This script is published for educational and informational purposes only. It does not constitute financial advice. Use at your own risk. Past microstructure behaviour does not guarantee future price outcomes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © PickMyTrade

//@version=6

// @description  Smart Money Liquidity Detector | Spread & Impact [PMT]
// Detects smart money activity through market microstructure — the same signals
// institutional traders leave behind in bid-ask spreads and price impact.
// Uses four academically grounded models:
//   · Roll (1984)           — synthetic bid-ask spread from price serial covariance
//   · Corwin-Schultz (2012) — high-low range spread estimator
//   · Amihud (2002)         — illiquidity ratio (price move per unit of volume)
//   · Kyle Lambda (1985)    — price impact of signed order flow
// All four are z-scored and combined into a Liquidity Stress Score (LSS) 0-100.
// LSS > 70 = smart money active, spreads wide, illiquidity elevated
// LSS < 30 = calm market, tight spreads, liquid conditions

indicator("Smart Money Liquidity Detector [PickMyTrade]",
          shorttitle    = "SMLD [PMT]",
          overlay       = false,
          max_bars_back = 500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

var string GRP_SPREAD  = "Spread Estimators"
var string GRP_IMPACT  = "Illiquidity & Price Impact"
var string GRP_DISP    = "Display"

i_spreadLen  = input.int(20,   "Spread window",            minval=10, maxval=100, group=GRP_SPREAD)
i_zLen       = input.int(60,   "Z-score window",           minval=20, maxval=200, group=GRP_SPREAD)
i_showRoll   = input.bool(true, "Show Roll spread",                               group=GRP_SPREAD)
i_showCS     = input.bool(true, "Show Corwin-Schultz spread",                     group=GRP_SPREAD)

i_impactLen  = input.int(20,   "Impact window",            minval=10, maxval=100, group=GRP_IMPACT)
i_showAmihud = input.bool(true, "Show Amihud illiquidity",                        group=GRP_IMPACT)
i_showKyle   = input.bool(true, "Show Kyle λ impact",                             group=GRP_IMPACT)

i_lssLen     = input.int(100,  "LSS normalise window",     minval=30,             group=GRP_DISP)
i_anomaly    = input.bool(true, "Highlight anomaly bars",                         group=GRP_DISP)
i_table      = input.bool(true, "Show info table",                                group=GRP_DISP)

// ══════════════════════════════════════════════════════════════════════════════
// TYPES
// ══════════════════════════════════════════════════════════════════════════════

type SpreadResult
    float value
    float zscore
    bool  isAnomaly

// ══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

_zscore(series float src, int len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0

normalise(series float src, int len) =>
    lo  = ta.lowest(src,  len)
    hi  = ta.highest(src, len)
    rng = hi - lo
    rng > 0 ? (src - lo) / rng : 0.5

zscoreColor(float z) =>
    z > 2 ? color.red : z > 1 ? color.orange : z < -2 ? color.lime : z < -1 ? color.green : color.gray

_fmt(float v, int dec) =>
    str.tostring(v, dec == 4 ? "#.####" : dec == 2 ? "#.##" : "#.#")

// ══════════════════════════════════════════════════════════════════════════════
// SPREAD ESTIMATORS
// ══════════════════════════════════════════════════════════════════════════════

rollSpread(series float src, int spreadLen, int zLen) =>
    delta     = src - src[1]
    cov       = ta.sma(delta * delta[1], spreadLen)
    rawSpread = cov < 0 ? 2.0 * math.sqrt(-cov) : 0.0
    zs        = _zscore(rawSpread, zLen)
    anom      = zs > 2.5
    SpreadResult.new(rawSpread, zs, anom)

corwinSchultz(series float h, series float l, int zLen) =>
    beta      = math.log(h / l) * math.log(h / l) + math.log(h[1] / l[1]) * math.log(h[1] / l[1])
    gamma     = math.log(math.max(h, h[1]) / math.min(l, l[1])) * math.log(math.max(h, h[1]) / math.min(l, l[1]))
    alpha     = (math.sqrt(2.0 * beta) - math.sqrt(beta)) / (3.0 - 2.0 * math.sqrt(2.0)) - math.sqrt(gamma / (3.0 - 2.0 * math.sqrt(2.0)))
    rawSpread = math.max(2.0 * (math.exp(alpha) - 1.0) / (1.0 + math.exp(alpha)), 0.0)
    zs        = _zscore(rawSpread, zLen)
    anom      = zs > 2.5
    SpreadResult.new(rawSpread, zs, anom)

// ══════════════════════════════════════════════════════════════════════════════
// ILLIQUIDITY & PRICE IMPACT
// ══════════════════════════════════════════════════════════════════════════════

amihud(series float src, series float vol, int impactLen, int zLen) =>
    ret      = math.abs(src / src[1] - 1.0)
    illiq    = vol > 0 ? ret / vol : 0.0
    avgIlliq = ta.sma(illiq, impactLen)
    zs       = _zscore(avgIlliq, zLen)
    anom     = zs > 2.5
    SpreadResult.new(avgIlliq, zs, anom)

kyleLambda(series float src, series float vol, int impactLen) =>
    ret       = src - src[1]
    signedVol = vol * math.sign(ret)
    num       = ta.sma(ret * signedVol, impactLen)
    den       = ta.sma(signedVol * signedVol, impactLen)
    lam       = den != 0 ? math.max(num / den, 0.0) : 0.0
    zs        = _zscore(lam, impactLen)
    anom      = zs > 2.5
    SpreadResult.new(lam, zs, anom)

// ══════════════════════════════════════════════════════════════════════════════
// COMPUTE
// ══════════════════════════════════════════════════════════════════════════════

SpreadResult roll = rollSpread(close, i_spreadLen, i_zLen)
SpreadResult cs   = corwinSchultz(high, low, i_zLen)
SpreadResult ami  = amihud(close, volume, i_impactLen, i_zLen)
SpreadResult kyle = kyleLambda(close, volume, i_impactLen)

float rollN = normalise(roll.zscore, i_lssLen)
float csN   = normalise(cs.zscore,   i_lssLen)
float amiN  = normalise(ami.zscore,  i_lssLen)
float kyleN = normalise(kyle.zscore, i_lssLen)
float lss   = (rollN + csN + amiN + kyleN) / 4.0 * 100.0

bool anyAnomaly = roll.isAnomaly or cs.isAnomaly or ami.isAnomaly or kyle.isAnomaly

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS — LSS Oscillator
// ══════════════════════════════════════════════════════════════════════════════

hline(70, "High Stress", color=color.new(color.red,   60), linestyle=hline.style_dashed, linewidth=1)
hline(50, "Neutral",     color=color.new(color.gray,  70), linestyle=hline.style_dotted, linewidth=1)
hline(30, "Low Stress",  color=color.new(color.green, 60), linestyle=hline.style_dashed, linewidth=1)

p_lss_top = plot(lss, "LSS", color=na)
p_lss_70  = plot(70,  display=display.none)
p_lss_30  = plot(30,  display=display.none)
fill(p_lss_top, p_lss_70, color = lss > 70 ? color.new(color.red,   75) : na, title="High stress fill")
fill(p_lss_top, p_lss_30, color = lss < 30 ? color.new(color.green, 75) : na, title="Low stress fill")

color lssColor = lss > 70 ? color.red : lss < 30 ? color.lime : color.gray
plot(lss, "Liquidity Stress Score", color=lssColor, linewidth=2)

bgcolor(i_anomaly and anyAnomaly ? color.new(color.orange, 88) : na, title="Anomaly bar highlight")

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS — Z-score ribbons
// ══════════════════════════════════════════════════════════════════════════════

plot(i_showRoll   ? roll.zscore : na, "Roll Z",   color=color.new(color.blue,   20), linewidth=1)
plot(i_showCS     ? cs.zscore   : na, "CS Z",     color=color.new(color.purple, 20), linewidth=1)
plot(i_showAmihud ? ami.zscore  : na, "Amihud Z", color=color.new(color.orange, 20), linewidth=1)
plot(i_showKyle   ? kyle.zscore : na, "Kyle λ Z", color=color.new(color.yellow, 20), linewidth=1)

hline( 2,  "2σ", color=color.new(color.red,   70), linestyle=hline.style_dotted)
hline(-2, "-2σ", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline( 0,  "0",  color=color.new(color.gray,  50), linestyle=hline.style_solid, linewidth=1)

// ══════════════════════════════════════════════════════════════════════════════
// SHAPES — Anomaly markers
// ══════════════════════════════════════════════════════════════════════════════

plotshape(i_anomaly and roll.isAnomaly, "Roll Anomaly", shape.circle, location.absolute,
          color.new(color.blue,   10), size=size.tiny, offset=0)
plotshape(i_anomaly and cs.isAnomaly,   "CS Anomaly",   shape.circle, location.absolute,
          color.new(color.purple, 10), size=size.tiny, offset=0)

// ══════════════════════════════════════════════════════════════════════════════
// INFO TABLE
// ══════════════════════════════════════════════════════════════════════════════

if i_table and barstate.islast
    var table T = table.new(position.top_right, 3, 8,
                            bgcolor      = color.new(color.black, 65),
                            border_color = color.new(color.gray,  40),
                            border_width = 1,
                            frame_color  = color.gray,
                            frame_width  = 1)

    // Header
    table.cell(T, 0, 0, "Metric",  text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(T, 1, 0, "Value",   text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(T, 2, 0, "Z-score", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 50))

    // LSS
    color lssC = lss > 70 ? color.red : lss < 30 ? color.lime : color.silver
    table.cell(T, 0, 1, "LSS",          text_color=color.white, text_size=size.small)
    table.cell(T, 1, 1, _fmt(lss, 1),   text_color=lssC,        text_size=size.small)
    table.cell(T, 2, 1, "—",            text_color=color.gray,  text_size=size.small)

    // Roll
    table.cell(T, 0, 2, "Roll Spread",        text_color=color.blue,   text_size=size.small)
    table.cell(T, 1, 2, _fmt(roll.value,  4), text_color=color.white,  text_size=size.small)
    table.cell(T, 2, 2, _fmt(roll.zscore, 2), text_color=zscoreColor(roll.zscore), text_size=size.small)

    // Corwin-Schultz
    table.cell(T, 0, 3, "Corwin-Schultz",   text_color=color.purple, text_size=size.small)
    table.cell(T, 1, 3, _fmt(cs.value,  4), text_color=color.white,  text_size=size.small)
    table.cell(T, 2, 3, _fmt(cs.zscore, 2), text_color=zscoreColor(cs.zscore), text_size=size.small)

    // Amihud
    table.cell(T, 0, 4, "Amihud ILLIQ",     text_color=color.orange, text_size=size.small)
    table.cell(T, 1, 4, _fmt(ami.value,  4), text_color=color.white,  text_size=size.small)
    table.cell(T, 2, 4, _fmt(ami.zscore, 2), text_color=zscoreColor(ami.zscore), text_size=size.small)

    // Kyle Lambda
    table.cell(T, 0, 5, "Kyle λ",             text_color=color.yellow, text_size=size.small)
    table.cell(T, 1, 5, _fmt(kyle.value,  4), text_color=color.white,  text_size=size.small)
    table.cell(T, 2, 5, _fmt(kyle.zscore, 2), text_color=zscoreColor(kyle.zscore), text_size=size.small)

    // Status
    string anoStr = anyAnomaly ? "⚠ SM ACTIVE" : "● Normal"
    color  anoCol = anyAnomaly ? color.orange   : color.green
    table.cell(T, 0, 6, "Status", text_color=color.gray, text_size=size.small)
    table.cell(T, 1, 6, anoStr,   text_color=anoCol,     text_size=size.small)
    table.cell(T, 2, 6, "",       text_color=color.gray, text_size=size.small)

    // Credit
    table.cell(T, 0, 7, "© PickMyTrade", text_color=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(T, 1, 7, "PMT v1.0",      text_color=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(T, 2, 7, "",              text_color=color.new(color.gray, 40), text_size=size.tiny)
````
