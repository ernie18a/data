# Meme Season Score | Memecoin Cycle Timing

- url: https://www.tradingview.com/script/6UCU4edl-Meme-Season-Score-Memecoin-Cycle-Timing/
- type: indicator
- pine_id: PUB;93521980ae95473cb8a6f0e5e7bb0938
- version: 1.0

## Description

One number, 0 to 100, that answers a single question: is it meme season right now?

The Meme Season Score is a composite oscillator that condenses six different memecoin-cycle factors into one decision-relevant signal. Instead of staring at half a dozen separate dominance and market-cap charts trying to interpret what the data is saying together, you get a single weighted reading and a climate label.


▸ WHY THIS INDICATOR EXISTS

Existing memecoin tools on TradingView each do one narrow thing: one plots a meme dominance ratio, one shows Z-scores of individual coins, one is an EMA crossover on a single sector index. None of them blend multiple cycle factors into a single comparable score.

Generic "altseason indices" treat all alts as a homogeneous block — they cannot tell you whether memecoins specifically are leading or lagging the broader alt rotation. Memecoins behave differently from L1s, DeFi, or RWAs. They need their own framework.

This script is that framework: six factors, all relevant to memecoin cycle behavior, all weighted by their historical importance, all blended into one number you can act on.


▸ METHODOLOGY

Each of the six input factors is first converted to a rate-of-change over a rolling momentum window (default: 14 bars). That ROC is then converted to a percentile rank within a longer normalization window (default: 180 bars), giving a 0–100 score that reflects "where does today's reading sit within the recent distribution."

Inverse factors (where falling values are bullish for memes) have their percentile rank flipped before contributing to the composite.

The six factors and default weights:

  •  MEME.D trend  —  25%  —  meme sector dominance rising = bullish
  •  MEME.C momentum  —  20%  —  meme sector market cap accelerating = bullish
  •  BTC.D inverse  —  20%  —  BTC dominance falling = capital rotating to alts
  •  OTHERS.D trend  —  15%  —  altcoin dominance rising = risk-on environment
  •  STABLE.C inverse  —  10%  —  stablecoin cap declining = stables being deployed
  •  MEME.C/TOTAL acceleration  —  10%  —  meme share growing faster than market

All weights are user-adjustable in the inputs and are auto-normalized, so they don't have to sum to 100.

Note: MEME.D is not currently a native CRYPTOCAP ticker on TradingView, so it is derived as MEME.C / TOTAL × 100 inside the script.


▸ CLIMATE ZONES

The score is divided into five regimes, each with its own color and emoji label that appears on the chart:

  •   0–20    ❄️  Meme Winter           Capital fleeing memes (deep accumulation zone)
  •  20–40    🌧️  Cool                   Mixed signals — selective plays only
  •  40–60    ☀️  Warming Up             Rotation beginning — early meme season
  •  60–80    🔥  Meme Season Active     Broad memecoin pumps — high conviction window
  •  80–100   🚀  Peak Mania             Extreme readings — historically precedes retracements

The main score line shifts color as it crosses zone boundaries. Background of the pane tints faintly with the current zone color (toggleable). A label on the last bar shows the live score and zone name.


▸ HOW TO READ IT

  •  Score above its 50-period EMA = momentum is strengthening
  •  Score below its 50-period EMA = momentum is weakening
  •  Cross above 60 = season conditions activating
  •  Cross above 80 = extreme conditions, historical risk zone
  •  Cross below 40 = season cooling off
  •  Cross below 20 = winter conditions, sentiment capitulation

The 50-EMA line is the slower trend reference; the colored line is the live signal. Watching their relationship is often more useful than watching either one alone.


▸ HOW TO USE IT

The script pulls all of its data from CRYPTOCAP indices via request.security, so the chart symbol does not affect the calculation. Putting it on CRYPTOCAP:MEME.C on the Daily timeframe gives the cleanest visual context (price chart of the meme sector above, score sub-pane below) but you can use any chart.

The default calculation timeframe is Daily, which is appropriate for cycle-level analysis. The score will show the same Daily-derived value regardless of what chart timeframe you are viewing.


▸ INPUT SETTINGS

Calculation Settings:
  •  Calculation Timeframe (default: Daily)
  •  Momentum Lookback in bars (default: 14)
  •  Normalization Lookback in bars (default: 180)
  •  Score Smoothing EMA (default: 3 — set to 1 for raw unsmoothed score)

Factor Weights — all six factor weights are individually adjustable from 0 to 100. Weights are auto-normalized so any combination is valid.

Display Options:
  •  Toggle the 50-period EMA of the score
  •  Toggle the floating score label
  •  Toggle the background climate tint
  •  Label size (small / normal / large / huge — use huge for screenshots)


▸ BUILT-IN ALERTS

Four alert conditions are defined and can be activated through the standard Add Alert dialog:

  •  🔥 Meme Season Starting (score crosses above 60)
  •  🚀 Peak Mania Warning (score crosses above 80)
  •  ☁️ Meme Season Ending (score crosses below 40)
  •  ❄️ Meme Winter (score crosses below 20)


▸ LIMITATIONS AND HONEST CAVEATS

  •  This is a contextual/regime tool, not a predictive one. The score tells you the current state of the meme cycle based on factors that have historically mattered. It does not predict future prices or guarantee any outcome.

  •  Percentile rank is by definition backward-looking. The score reflects how today's momentum compares to the recent past, not where prices are going.

  •  With default settings, the script needs roughly 194 daily bars of valid CRYPTOCAP data to warm up before producing a meaningful score (14-bar ROC plus 180-bar percentile window). MEME.C history begins in early 2024, so this is not a constraint for current charts.

  •  Memecoin market structure changes quickly. Tokens that drove the sector last cycle may be irrelevant in the next. The score works at the sector level and is robust to individual token churn, but it cannot tell you which specific memecoin to buy.

  •  Factor weights are calibrated to behavior observed in available CRYPTOCAP history. If the underlying market structure shifts substantially, weights may need adjustment.


▸ TECHNICAL NOTES

  •  Pine Script v6
  •  Open-source under the Mozilla Public License 2.0
  •  Uses 5 request.security calls (well below the 40-call limit), all to official CRYPTOCAP indices
  •  No repainting — all calculations use confirmed bar close values from the requested timeframe


▸ DISCLAIMER

For educational and informational purposes only. This script is a market analysis tool, not financial advice. Nothing here constitutes a recommendation to buy or sell any asset. Past behavior of the score in historical data is not a guarantee of future behavior. Cryptocurrency markets, and memecoin markets in particular, are highly volatile and can result in substantial losses. Always do your own research and trade with risk you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DeltaSpeedEdge

// ─────────────────────────────────────────────────────────────────────────────
//  Meme Season Score | Memecoin Cycle Timing
//  v1.0.0  —  Free open-source indicator from the Memecoin Momentum Suite
//
//  Answers ONE question with ONE number (0–100): is it meme season right now?
//
//  Methodology: 6-factor weighted composite using TradingView's CRYPTOCAP
//  sector data. Each factor is converted to a percentile rank (0–100) over a
//  rolling lookback window, then weighted and blended into the final score.
//
//  Climate zones:
//    0–20   ❄️ Meme Winter        (capital fleeing memes — accumulation zone)
//    20–40  🌧️ Cool                (mixed signals — selective plays only)
//    40–60  ☀️ Warming Up          (rotation beginning — early meme season)
//    60–80  🔥 Meme Season Active  (broad memecoin pumps — high conviction)
//    80–100 🚀 Peak Mania          (extreme — historically precedes crash)
//
//  For educational and informational purposes only. Not financial advice.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Meme Season Score | Memecoin Cycle Timing", shorttitle="🎰 Meme Season", overlay=false, precision=1)

// ═════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═════════════════════════════════════════════════════════════════════════════

grpSettings = "═══ Calculation Settings ═══"
tfInput            = input.timeframe("D", "Calculation Timeframe", group=grpSettings, tooltip="Daily is recommended for cycle timing. Works on any chart timeframe — values are pulled from this timeframe regardless of what you're viewing.")
rocLength          = input.int(14, "Momentum Lookback (bars)", minval=3, maxval=90, group=grpSettings, tooltip="How many bars back to measure rate-of-change. 14 = ~2 weeks on daily.")
percentileLookback = input.int(180, "Normalization Lookback (bars)", minval=30, maxval=500, group=grpSettings, tooltip="The window used to scale each factor to a 0–100 percentile. 180 = ~6 months on daily.")
smoothLength       = input.int(3, "Score Smoothing (EMA)", minval=1, maxval=20, group=grpSettings, tooltip="Light smoothing to reduce noise. Set to 1 for raw score.")

grpWeights = "═══ Factor Weights (auto-normalized) ═══"
wMemeD     = input.float(25, "MEME.D Trend Weight %",              minval=0, maxval=100, step=5, group=grpWeights, tooltip="Meme sector dominance rising = bullish for memes")
wMemeC     = input.float(20, "MEME.C Momentum Weight %",           minval=0, maxval=100, step=5, group=grpWeights, tooltip="Meme sector market cap accelerating = bullish")
wBtcD      = input.float(20, "BTC.D Inverse Weight %",             minval=0, maxval=100, step=5, group=grpWeights, tooltip="BTC dominance falling = capital rotating to alts/memes")
wOthersD   = input.float(15, "OTHERS.D Trend Weight %",            minval=0, maxval=100, step=5, group=grpWeights, tooltip="Altcoin dominance rising = risk-on environment")
wStableC   = input.float(10, "STABLE.C Inverse Weight %",          minval=0, maxval=100, step=5, group=grpWeights, tooltip="Stablecoin cap declining = stables being deployed into risk")
wMemeRatio = input.float(10, "MEME.C/TOTAL Acceleration Weight %", minval=0, maxval=100, step=5, group=grpWeights, tooltip="Meme share of total market growing faster than the market itself")

grpDisplay = "═══ Display ═══"
showEMA      = input.bool(true,  "Show 50-period EMA of Score",     group=grpDisplay, tooltip="The thin gray trend line. Score above EMA = strengthening; below = weakening.")
showLabel    = input.bool(true,  "Show Score Label on Last Bar",    group=grpDisplay, tooltip="The big floating label on the right edge with current score and zone name.")
showBgTint   = input.bool(true,  "Show Background Climate Tint",    group=grpDisplay, tooltip="Faint background color matching the current climate zone. Turn off for cleaner screenshots.")
labelSizeIn  = input.string("large", "Label Size", options=["small", "normal", "large", "huge"], group=grpDisplay, tooltip="Use 'huge' for Twitter screenshots.")

// ═════════════════════════════════════════════════════════════════════════════
//  DATA FETCH — 5 request.security calls (well under the 40-call limit)
//
//  All five symbols are official TradingView CRYPTOCAP indices. STABLE.C is the
//  stablecoin sector total market cap (added by TradingView in May 2025).
//  MEME.D is derived from MEME.C/TOTAL since TradingView hasn't added it yet.
//
//  Warmup: with default settings (14-bar ROC + 180-bar percentile rank) the
//  script needs roughly 194 daily bars of valid data before showing a score.
//  MEME.C history begins in early 2024, so charts opened today will show the
//  score immediately after the indicator loads.
// ═════════════════════════════════════════════════════════════════════════════

memeC   = request.security("CRYPTOCAP:MEME.C",   tfInput, close, lookahead=barmerge.lookahead_off)
btcD    = request.security("CRYPTOCAP:BTC.D",    tfInput, close, lookahead=barmerge.lookahead_off)
othersD = request.security("CRYPTOCAP:OTHERS.D", tfInput, close, lookahead=barmerge.lookahead_off)
stableC = request.security("CRYPTOCAP:STABLE.C", tfInput, close, lookahead=barmerge.lookahead_off)
totalC  = request.security("CRYPTOCAP:TOTAL",    tfInput, close, lookahead=barmerge.lookahead_off)

// MEME.D doesn't exist as a native CRYPTOCAP ticker yet — derive it manually.
memeD = memeC / totalC * 100

// ═════════════════════════════════════════════════════════════════════════════
//  FACTOR CALCULATIONS
//  Each factor produces a raw signal (rate of change), then we convert it to
//  a 0–100 percentile rank over the lookback window. Inverse factors flip the
//  rank because falling values are bullish for memes.
// ═════════════════════════════════════════════════════════════════════════════

// Factor 1 — MEME.D trend (rising = bullish)
memeD_score = ta.percentrank(ta.roc(memeD, rocLength), percentileLookback)

// Factor 2 — MEME.C momentum (rising = bullish)
memeC_score = ta.percentrank(ta.roc(memeC, rocLength), percentileLookback)

// Factor 3 — BTC.D direction (falling = bullish — INVERTED)
btcD_score = 100 - ta.percentrank(ta.roc(btcD, rocLength), percentileLookback)

// Factor 4 — OTHERS.D trend (rising = bullish)
othersD_score = ta.percentrank(ta.roc(othersD, rocLength), percentileLookback)

// Factor 5 — STABLE.C change (declining = bullish — INVERTED)
stableC_score = 100 - ta.percentrank(ta.roc(stableC, rocLength), percentileLookback)

// Factor 6 — MEME.C/TOTAL ratio acceleration (second derivative)
memeShare       = memeC / totalC
memeShareRoc    = ta.roc(memeShare, rocLength)
memeShareAccel  = ta.roc(memeShareRoc, rocLength)
memeRatio_score = ta.percentrank(memeShareAccel, percentileLookback)

// ═════════════════════════════════════════════════════════════════════════════
//  COMPOSITE SCORE — weights are auto-normalized so they don't have to sum to 100
// ═════════════════════════════════════════════════════════════════════════════

totalWeight = wMemeD + wMemeC + wBtcD + wOthersD + wStableC + wMemeRatio
weightedRaw = totalWeight > 0 ? (memeD_score   * wMemeD +
                                 memeC_score   * wMemeC +
                                 btcD_score    * wBtcD +
                                 othersD_score * wOthersD +
                                 stableC_score * wStableC +
                                 memeRatio_score * wMemeRatio) / totalWeight : 50.0

seasonScore = ta.ema(weightedRaw, smoothLength)

// ═════════════════════════════════════════════════════════════════════════════
//  CLIMATE ZONES & COLORS
// ═════════════════════════════════════════════════════════════════════════════

// Color order: Peak Mania (red), Active (orange), Warming (yellow), Cool (blue-gray), Winter (deep blue)
zoneColor = switch
    seasonScore >= 80 => color.new(#FF1744, 0)
    seasonScore >= 60 => color.new(#FF9100, 0)
    seasonScore >= 40 => color.new(#FFD600, 0)
    seasonScore >= 20 => color.new(#607D8B, 0)
    =>                   color.new(#0D47A1, 0)

// Text color: dark on light backgrounds (orange/yellow), white on dark (red/blue/deep blue)
zoneTextColor = switch
    seasonScore >= 80 => color.white
    seasonScore >= 60 => #1A1A1A
    seasonScore >= 40 => #1A1A1A
    seasonScore >= 20 => color.white
    =>                   color.white

zoneLabel = switch
    seasonScore >= 80 => "🚀 Peak Mania"
    seasonScore >= 60 => "🔥 Meme Season Active"
    seasonScore >= 40 => "☀️ Warming Up"
    seasonScore >= 20 => "🌧️ Cool"
    =>                   "❄️ Meme Winter"

// ═════════════════════════════════════════════════════════════════════════════
//  PLOTS
// ═════════════════════════════════════════════════════════════════════════════

// Main score line (color shifts with climate zone)
plot(seasonScore, "Meme Season Score", color=zoneColor, linewidth=4)

// Optional 50-EMA of the score for trend direction
scoreEma = ta.ema(seasonScore, 50)
plot(showEMA ? scoreEma : na, "Score EMA(50)", color=color.new(color.white, 30), linewidth=1)

// Reference threshold lines
hline(80, "Peak Mania",  color=color.new(#FF1744, 50), linestyle=hline.style_dashed)
hline(60, "Meme Season", color=color.new(#FF9100, 50), linestyle=hline.style_dashed)
hline(40, "Warming Up",  color=color.new(#FFD600, 50), linestyle=hline.style_dashed)
hline(20, "Cool",        color=color.new(#607D8B, 50), linestyle=hline.style_dashed)
hline(50, "Neutral",     color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// Background climate tint
bgcolor(showBgTint ? color.new(zoneColor, 90) : na, title="Climate Background")

// ═════════════════════════════════════════════════════════════════════════════
//  SCORE LABEL ON LAST BAR
// ═════════════════════════════════════════════════════════════════════════════

labelSize = switch labelSizeIn
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    =>          size.huge

var label scoreLabel = na

if barstate.islast and showLabel
    label.delete(scoreLabel)
    labelText = str.tostring(seasonScore, "#.0") + " / 100\n" + zoneLabel
    scoreLabel := label.new(bar_index, seasonScore, labelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=zoneColor, textcolor=zoneTextColor, size=labelSize)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(ta.crossover(seasonScore, 60),  title="🔥 Meme Season Starting",      message="Meme Season Score crossed above 60 — Meme Season Active. Broad memecoin pumps incoming.")
alertcondition(ta.crossover(seasonScore, 80),  title="🚀 Peak Mania Warning",        message="Meme Season Score crossed above 80 — Peak Mania zone. Historically precedes major retracements. Consider taking profits.")
alertcondition(ta.crossunder(seasonScore, 40), title="☁️ Meme Season Ending",        message="Meme Season Score dropped below 40 — Season cooling off. Selective plays only.")
alertcondition(ta.crossunder(seasonScore, 20), title="❄️ Meme Winter",               message="Meme Season Score dropped below 20 — Meme Winter. Capital rotating out. Accumulation zone for long-term degens.")
````
