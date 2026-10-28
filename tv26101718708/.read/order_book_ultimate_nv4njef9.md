# Order Book Ultimate

- url: https://www.tradingview.com/script/nV4nJeF9-Order-Book-Ultimate/
- type: indicator
- pine_id: PUB;8f925b0500a34406840b446722957bc3
- version: 1.0

## Description

# order book ultimate — synthetic depth, flow pressure and wall map

order book ultimate is a synthetic order book and market pressure tool for traders who want a visual way to study possible bid walls, ask walls, liquidity pressure, absorption, sweeps, imbalance and short-term directional bias.

this script does not read real exchange level 2 data, broker depth of market, or live limit order book data. it builds a synthetic depth model from chart price action, volume, volatility, round-number behavior, intrabar flow when available, and recent reactions around price levels. the goal is to help traders visualize where pressure may be building, where price may react, and when a setup has enough agreement between multiple conditions to deserve attention.

the script is designed as a decision-support tool, not as an automatic trading system. it should be used with market structure, risk management, and personal validation.

---

## what this script does

order book ultimate combines several components into one workflow:

* synthetic bid and ask depth levels around current price
* estimated bid/ask pressure using volume and candle position
* optional lower-timeframe intrabar flow analysis
* wall detection and wall stability tracking
* historical liquidity memory zones
* absorption detection near bid or ask walls
* bullish and bearish sweep detection
* pro score and confidence score
* market regime filter
* visual long and short setup markers
* visual stats for signal follow-up
* compact, full and debug dashboard modes
* alerts for stable walls, imbalance, setups, absorption, sweeps and invalidation

the main idea is to avoid reading one signal alone. the script looks for agreement between pressure, depth imbalance, wall strength, trend, obv flow, absorption, sweeps and market regime.

---

## important note about the order book model

this is a synthetic order book model.

it does not show the real resting orders from an exchange. instead, it estimates possible liquidity concentration by using:

* atr-based spacing
* recent volume
* candle rejection behavior
* round-number magnetism
* intrabar buy/sell pressure when available
* historical reactions around price
* volatility and market regime adjustments

because of this, the script should be treated as a market pressure map, not as real dom or level 2 data.

---

# engine modes

## engine mode

this setting controls how the script measures market pressure.

### classic synthetic

uses the current chart candles only. it estimates buy and sell pressure from candle position, volume, delta approximation and recent flow.

best for:

* higher timeframes
* symbols where lower-timeframe data is not needed
* cleaner and lighter calculations

### intrabar flow

uses lower-timeframe candles inside the current candle to estimate pressure more closely.

best for:

* scalping
* intraday trading
* checking whether the current candle has strong internal buying or selling pressure

### hybrid pro

combines classic synthetic pressure with lower-timeframe intrabar flow. this is the default balanced mode.

best for:

* most traders
* 5m, 15m, 30m and 1h charts
* users who want both stable context and intrabar sensitivity

---

## lower timeframe

this is the lower timeframe used by the intrabar flow engine.

example:

* if your chart is 15m and lower timeframe is 1m, the script studies the 1m candles inside each 15m candle.
* if your chart is 5m and lower timeframe is 1m, it studies the 1m movement inside each 5m candle.

beginner tip:
use 1m for scalping and 3m or 5m for smoother intraday reading.

---

## intrabar weight in hybrid

this controls how much the hybrid engine trusts lower-timeframe flow.

* 0.00 means almost no intrabar influence.
* 0.55 gives a balanced mix.
* 1.00 gives maximum intrabar influence.

beginner tip:
keep it near 0.50 to 0.60 for a balanced setup. raise it only if you want more reactive signals.

---

## use confirmed bars for signals

when enabled, signals only confirm after the candle closes.

this helps reduce noisy live-bar signals. when disabled, signals can appear during the current candle, but they may change before the candle closes.

beginner tip:
keep this enabled if you want cleaner signals.

---

# synthetic depth engine

## levels per side

this controls how many synthetic bid levels and ask levels are calculated around price.

* lower values make the display simpler.
* higher values create a wider synthetic depth map.

beginner tip:
15 is a good balanced setting.

---

## level spacing x atr

this controls the spacing between synthetic levels using atr.

* lower values place levels closer to current price.
* higher values spread them farther away.

beginner tip:
use lower values for scalping and higher values for swing trading.

---

## volume lookback

this sets how many candles are used to build the average volume baseline.

* shorter lookback reacts faster.
* longer lookback is smoother.

beginner tip:
100 is a balanced value for most intraday charts.

---

## refresh rate

this controls how often the synthetic depth levels refresh.

* 1 refreshes every bar.
* higher values refresh less often.

beginner tip:
keep it at 1 for active trading.

---

## depth multiplier

this increases or decreases the strength of the synthetic depth zones.

* higher values create stronger wall readings.
* lower values make the script more conservative.

beginner tip:
2.0 is a balanced default.

---

## depth decay sigma

this controls how quickly synthetic liquidity fades as price levels move farther from current price.

* lower values focus more on nearby levels.
* higher values include farther levels.

beginner tip:
use lower values for scalping and higher values for wider market context.

---

## liquidity memory bars

this tells the script how far back it should remember recent reactions around price levels.

* lower values focus on recent reactions.
* higher values keep more market memory.

beginner tip:
40 is a good starting point.

---

# round number engine

## round number magnetism

this increases the importance of round prices.

markets often react near round numbers because many traders place orders around them. this setting makes the synthetic depth engine give more weight to those areas.

beginner tip:
use higher values on indices and crypto, and lower values on forex if the levels feel too wide.

---

## auto round step

when enabled, the script automatically chooses a round-number step based on the symbol price.

beginner tip:
keep this enabled unless you know exactly which round levels you want to use.

---

## manual round step

this is used only when auto round step is disabled.

example:

* 100 for major crypto round zones
* 10 for some indices
* 1 or 0.5 for stocks depending on price

beginner tip:
leave it at 0.0 when auto round step is enabled.

---

## round zone width %

this controls how close price must be to a round level before the round-number magnet effect becomes important.

* lower values are stricter.
* higher values allow wider round-number zones.

beginner tip:
1.5 is a balanced default.

---

# flow / pressure engine

## delta length

this controls how many candles are used to estimate delta pressure.

* shorter length reacts faster.
* longer length is smoother.

beginner tip:
20 works well for general intraday use.

---

## obv ma length

this is the moving average length used for obv flow.

if obv is above its moving average, the script reads flow as more bullish. if it is below, flow is more bearish.

beginner tip:
20 is a good default.

---

## pressure smoothing

this smooths the pressure reading.

* low values react faster.
* high values reduce noise.

beginner tip:
5 is a balanced value.

---

# wall stability / memory

## wall stable bars

this controls how many bars a wall must remain active before it is considered stable.

* lower values confirm faster.
* higher values require more persistence.

beginner tip:
3 is a good starting point.

---

## same wall zone x tick

this controls how close a new wall must be to the previous wall to be treated as the same wall.

* lower values separate walls more strictly.
* higher values merge nearby walls more easily.

beginner tip:
3.0 is balanced.

---

## max historical zones

this controls how many historical wall zones are kept in memory.

beginner tip:
12 keeps the chart useful without too much clutter.

---

## historical merge x tick

this controls how close historical zones must be to merge together.

* lower values create more separate zones.
* higher values combine nearby levels.

beginner tip:
6.0 is a balanced default.

---

## historical strength decay

this controls how slowly old historical zones lose strength.

* 1.0 means they do not decay.
* lower values make old zones fade faster.

beginner tip:
0.985 keeps useful memory while still allowing old zones to fade.

---

# absorption / sweep / filters

## anti-noise confirmation

when enabled, the script requires extra filters before confirming long or short setups.

it checks for enough volume, pressure agreement, stable walls, absorption or sweep context, and avoids low-liquidity conditions.

beginner tip:
keep this enabled for cleaner signals.

---

## min volume x avg

this is the minimum volume required compared to average volume.

example:
0.90 means current volume should be at least 90% of average volume.

beginner tip:
raise it if you want fewer but stronger signals.

---

## absorption volume x avg

this controls how much volume is required to detect absorption.

absorption means price touches or pushes into a wall area, but the candle shows rejection instead of clean continuation.

beginner tip:
1.20 is balanced. raise it for stricter absorption signals.

---

## absorption zone x atr

this controls how close price must be to a wall for absorption detection.

* lower values require price to be very close to the wall.
* higher values allow a wider absorption area.

beginner tip:
0.18 works well for many intraday charts.

---

## sweep zone x atr

this controls how far price must move beyond a wall before a sweep can be detected.

a bullish sweep happens when price moves below a bid wall or historical bid zone and then closes back above it.

a bearish sweep happens when price moves above an ask wall or historical ask zone and then closes back below it.

beginner tip:
0.10 is a good starting value.

---

## exhaustion rsi high

this level is used to warn when a long setup may be overextended.

if a long setup appears while rsi is very high and the candle shows rejection, the setup can be marked as exhausted.

beginner tip:
72 is a balanced default.

---

## exhaustion rsi low

this level is used to warn when a short setup may be overextended.

if a short setup appears while rsi is very low and the candle shows rejection, the setup can be marked as exhausted.

beginner tip:
28 is a balanced default.

---

# regime / asset calibration

## asset profile

this adjusts the behavior of the script for different markets.

available profiles:

* auto
* crypto
* forex
* index
* stock
* futures
* generic

auto reads the symbol type and applies a matching profile.

beginner tip:
use auto first. switch manually only if the script feels too sensitive or too slow on your market.

---

## auto-calibrate thresholds

when enabled, the script adjusts wall strength, round-number behavior and memory based on the selected asset profile.

beginner tip:
keep this enabled.

---

## adx length

this controls the adx calculation used to identify trending or ranging conditions.

beginner tip:
14 is a standard value.

---

## volatility baseline

this controls the baseline used to compare current volatility with normal volatility.

* lower values react faster.
* higher values are smoother.

beginner tip:
100 is a balanced setting.

---

# spread / range proxy

## spread display

this chooses how the script estimates spread or micro-range conditions.

### adaptive proxy

uses an adaptive estimate based on recent range.

### bar range

uses the full current candle range.

### atr micro

uses a small atr-based estimate.

beginner tip:
use adaptive proxy for most markets.

---

## adaptive spread factor

this controls the size of the adaptive spread proxy.

beginner tip:
0.05 is a balanced default. raise it if the spread reading looks too small.

---

# visual / panel

## show panel

shows or hides the dashboard.

the panel displays score, confidence, regime, bid/ask depth, pressure, wall state, absorption, sweeps, visual stats and more depending on the selected panel mode.

---

## panel mode

### compact

shows only the most important information.

best for:

* small screens
* clean charting
* quick decision making

### full

shows the complete dashboard.

best for:

* normal trading use
* studying pressure, walls, volume and flow

### debug

shows additional internal values.

best for:

* testing settings
* understanding how the engine is reacting
* advanced users

---

## panel position

chooses where the dashboard appears on the chart.

options:

* top right
* top left
* bottom right
* bottom left

---

## show best wall zones

when enabled, the script draws the strongest stable bid and ask wall zones on the chart.

bid wall zones appear below price and can act as possible support areas.

ask wall zones appear above price and can act as possible resistance areas.

---

## show signal markers

when enabled, the script plots markers for:

* long setup
* short setup
* bid absorption
* ask absorption
* bullish sweep
* bearish sweep
* invalidation

---

## wall zone forward bars

this controls how far the wall zone boxes extend into the future.

beginner tip:
30 is a good value for intraday charts.

---

## panel bg

sets the dashboard background color.

---

## bid color

sets the color used for bullish or bid-side elements.

---

## ask color

sets the color used for bearish or ask-side elements.

---

## neutral color

sets the color used for neutral readings.

---

## accent color

sets the color used for highlights and active dashboard elements.

---

## warning color

sets the color used for warnings, exhaustion and invalidation.

---

# alerts / scoring

## wall threshold x avg

this controls how strong a wall must be compared to the average depth before it is considered important.

* lower values create more wall signals.
* higher values require stronger walls.

beginner tip:
2.0 is a balanced default.

---

## imbalance threshold

this controls how strong the bid/ask imbalance must be before the script labels the market as bid heavy or ask heavy.

beginner tip:
1.6 is a good starting point.

---

## long bias score

this is the score level required for a long bias.

example:
70 means the pro score must reach 70 or higher before a long setup can be confirmed.

---

## short bias score

this is the score level required for a short bias.

example:
30 means the pro score must fall to 30 or lower before a short setup can be confirmed.

---

## min confidence

this is the minimum agreement score needed before the script confirms a setup.

confidence is based on agreement between pressure, imbalance, wall direction, trend, obv, intrabar quality, absorption, sweeps and regime.

beginner tip:
55 is a balanced default. raise it for stricter signals.

---

# visual backtest stats

## enable visual stats

when enabled, the script tracks basic visual follow-up stats after confirmed signals.

this is not a full strategy backtest. it is a visual stats module that checks whether a signal reaches an atr-based target or invalidation level within a chosen number of bars.

---

## target x atr

this controls the target distance used by visual stats.

example:
0.75 means the target is 0.75 atr from the signal price.

---

## invalidation x atr

this controls the invalidation distance used by visual stats.

example:
0.55 means the invalidation level is 0.55 atr from the signal price.

---

## max bars in signal

this controls how long the visual stats module gives a signal to reach target or invalidation.

if neither target nor invalidation is reached before this number of bars, the signal is closed by time.

---

# dashboard guide

## score

the score ranges from 0 to 100.

* above the long bias score: long bias
* below the short bias score: short bias
* between both levels: neutral

the score is built from pressure, imbalance, wall strength, trend, obv, rsi, absorption, sweep and regime.

---

## confidence

confidence measures how much agreement exists between the engine components.

a high score with low confidence should be treated carefully. a high score with strong confidence is cleaner.

---

## regime

the regime label describes the current market environment.

possible states include:

* high vol
* low liq
* breakout
* trending
* ranging
* balanced

beginner tip:
avoid forcing trades in low-liquidity conditions.

---

## bid / ask

this shows the estimated synthetic bid depth and ask depth.

if bid depth is much stronger than ask depth, the market may be bid heavy.

if ask depth is much stronger than bid depth, the market may be ask heavy.

---

## pressure

this shows whether buying or selling pressure is dominant.

pressure is not a signal by itself. it should agree with walls, imbalance and confidence.

---

## walls

this shows whether bid and ask walls are:

* none
* weak
* building
* holding

a holding wall is more important than a fresh or weak wall.

---

## abs / sweep

this shows whether absorption or a sweep is currently detected.

absorption can show rejection at a wall.

a sweep can show liquidity being taken before price returns.

---

## bt stats

this shows the visual stats result of recent confirmed signals.

it should be used for observation, not as proof of future performance.

---

# chart markers

## l marker

a long setup marker appears when the script confirms long bias conditions, confidence is high enough, and the noise filter allows the signal.

---

## s marker

a short setup marker appears when the script confirms short bias conditions, confidence is high enough, and the noise filter allows the signal.

---

## abs marker

an absorption marker appears when price interacts with a wall area with strong volume and rejection.

bid absorption appears below price.

ask absorption appears above price.

---

## sw marker

a sweep marker appears when price raids a wall or historical liquidity zone and then closes back through it.

bullish sweep appears below price.

bearish sweep appears above price.

---

## x marker

an invalidation marker appears when a setup is invalidated by price moving beyond the relevant wall area.

---

# available alerts

the script includes alerts for:

* stable synthetic bid wall
* stable synthetic ask wall
* bid heavy imbalance
* ask heavy imbalance
* long setup confirmed
* short setup confirmed
* bid absorption
* ask absorption
* bullish sweep
* bearish sweep
* setup invalidated

beginner tip:
start with only a few alerts. for example:

* stable bid wall
* stable ask wall
* long setup confirmed
* short setup confirmed
* bullish sweep
* bearish sweep

too many alerts can make the workflow noisy.

---

# beginner tutorial

## step 1 — choose the correct engine mode

start with hybrid pro.

hybrid pro is the most balanced mode because it combines classic chart pressure with lower-timeframe flow.

use classic synthetic if you want a smoother reading.

use intrabar flow if you want maximum short-term sensitivity.

---

## step 2 — choose the lower timeframe

for a 15m chart, start with 1m or 3m.

for a 5m chart, start with 1m.

for a 1h chart, try 5m or 15m.

if the script feels too reactive, use a higher lower-timeframe setting or lower the intrabar weight.

---

## step 3 — read the panel first

before looking at markers, read the panel:

1. check the market regime.
2. check the score.
3. check confidence.
4. check bid/ask imbalance.
5. check pressure.
6. check wall state.
7. check absorption or sweep.

do not take a marker if the panel does not make sense.

---

## step 4 — use walls as zones, not exact entries

a stable bid wall can act as a possible support area.

a stable ask wall can act as a possible resistance area.

price may react around the zone, not exactly at one tick.

---

## step 5 — wait for context

a better long idea usually has:

* stable bid wall
* bid-heavy or improving depth
* positive pressure
* bullish sweep or bid absorption
* score above the long bias level
* confidence above the minimum

a better short idea usually has:

* stable ask wall
* ask-heavy or weakening bid depth
* negative pressure
* bearish sweep or ask absorption
* score below the short bias level
* confidence above the minimum

---

# example use cases

## example 1 — bullish wall reaction

price moves down into a stable bid wall.

the panel shows:

* bid wall holding
* bid/ask ratio improving
* pressure turning positive
* confidence rising
* bid absorption appears

a trader may wait for price to hold above the wall and then look for a long setup marker.

possible invalidation:
price closes below the bid wall area and an invalidation marker appears.

---

## example 2 — bearish wall rejection

price moves up into a stable ask wall.

the panel shows:

* ask wall holding
* ask-heavy imbalance
* pressure turning negative
* ask absorption appears
* confidence is above the minimum

a trader may wait for rejection from the ask wall and a short setup marker.

possible invalidation:
price closes above the ask wall area.

---

## example 3 — bullish sweep

price moves below a bid wall or historical bid zone and then closes back above it.

the script marks a bullish sweep.

this can mean sellers pushed price below liquidity, but buyers absorbed the move and price returned above the zone.

a trader may then check:

* is pressure improving?
* is confidence strong enough?
* is the score moving toward long bias?
* is the market not in low-liquidity mode?

---

## example 4 — bearish sweep

price moves above an ask wall or historical ask zone and then closes back below it.

the script marks a bearish sweep.

this can mean buyers pushed price above liquidity, but sellers absorbed the move and price returned below the zone.

a trader may then check:

* is pressure weakening?
* is ask absorption present?
* is confidence strong enough?
* is the score moving toward short bias?

---

## example 5 — avoiding a weak signal

a long marker appears, but the panel shows:

* low liquidity regime
* weak confidence
* no stable bid wall
* no absorption
* no sweep

this is a low-quality context.

the better choice is to wait for stronger agreement.

---

## example 6 — using visual stats

enable visual stats and keep default atr target and invalidation settings.

after each confirmed setup, the panel tracks whether price reached the target, invalidation or timed out.

this is useful for studying the behavior of the signals on your market, but it is not a complete strategy backtest.

---

# suggested starting settings

## scalping

chart:
1m to 5m

settings:

* engine mode: hybrid pro
* lower timeframe: 1m
* intrabar weight: 0.55 to 0.70
* use confirmed bars: enabled
* wall threshold: 2.0 to 2.5
* min confidence: 60 to 70
* panel mode: compact or full

best use:
watch for stable walls, sweeps and absorption during active sessions.

---

## intraday

chart:
5m to 30m

settings:

* engine mode: hybrid pro
* lower timeframe: 1m to 5m
* intrabar weight: 0.45 to 0.60
* use confirmed bars: enabled
* wall stable bars: 3 to 5
* min confidence: 55 to 65
* panel mode: full

best use:
use stable walls as reaction zones and wait for score plus confidence agreement.

---

## swing or higher timeframe

chart:
1h to 4h

settings:

* engine mode: classic synthetic or hybrid pro
* lower timeframe: 5m to 15m
* intrabar weight: 0.25 to 0.45
* volume lookback: 100 to 200
* liquidity memory bars: 60 to 120
* panel mode: full

best use:
focus on larger wall zones, market regime and historical liquidity memory.

---

# practical workflow

1. open the chart and choose the market.
2. set engine mode to hybrid pro.
3. choose a lower timeframe smaller than the chart timeframe.
4. keep confirmed bars enabled.
5. check the panel regime.
6. wait for a stable wall.
7. watch bid/ask imbalance and pressure.
8. wait for absorption, sweep or a confirmed setup marker.
9. define invalidation around the wall zone.
10. use visual stats to observe signal behavior over time.

---

# limitations

this script uses synthetic calculations. it does not access real order book liquidity, real level 2 data, broker depth, or exchange resting orders.

signals may perform differently depending on symbol, timeframe, session, liquidity and volatility.

visual stats are only a simple chart-based follow-up tool. they are not a full trading strategy backtest.

the script should be combined with risk management, market structure, session context and personal testing.

---

# risk notice

this indicator is for technical analysis and education. it does not provide financial advice and does not guarantee future results. every trader is responsible for their own decisions, risk management and testing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//╔════════════════════════════════════════════════════════════════════════════════════╗
//║░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░║
//║░                                                                                  ░║
//║░                         𓂀  A L P H A   W I Z A R D  𓂀                          ░║
//║░                                                                                  ░║
//║░                              ORDER BOOK GRIMOIRE                                 ░║
//║░                                                                                  ░║
//║░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░║
//╠════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                    ║
//║   ┌─[market@root]─[~/orderbook/signals]                                            ║
//║   └──╼ ./alpha_wizard --decode-flow --trace-liquidity --arm-signals                ║
//║                                                                                    ║
//║   [01] LIQUIDITY STREAM      >>>  CONNECTED     ▓▓▓▓▓▓▓▓░░  82%                   ║
//║   [02] ORDER FLOW MATRIX     >>>  SYNCHRONIZED  ▓▓▓▓▓▓▓▓▓░  91%                   ║
//║   [03] BID PRESSURE MAP      >>>  SCANNING      ▓▓▓▓▓▓░░░░  64%                   ║
//║   [04] ASK ABSORPTION WALL   >>>  DETECTED      ▓▓▓▓▓▓▓░░░  73%                   ║
//║   [05] DELTA IMBALANCE       >>>  ACTIVE        ▓▓▓▓▓▓▓▓░░  88%                   ║
//║   [06] SWEEP SEQUENCE        >>>  ARMED         ▓▓▓▓▓▓▓▓▓░  94%                   ║
//║   [07] SPOOF TRACE FILTER    >>>  WATCHING      ▓▓▓▓▓░░░░░  51%                   ║
//║   [08] REACTION GRID         >>>  ONLINE        ▓▓▓▓▓▓▓▓░░  86%                   ║
//║                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                    ║
//║   HEX SIGNAL FEED                                                                  ║
//║   0xA11F :: LIQUIDITY_NODE      :: OPEN                                            ║
//║   0xB42C :: ABSORPTION_CLUSTER  :: LOCKED                                          ║
//║   0xC83D :: ORDERBOOK_PRESSURE  :: RISING                                          ║
//║   0xD90E :: SWEEP_VECTOR        :: TRACKING                                        ║
//║   0xE77A :: IMBALANCE_GATE      :: UNSEALED                                        ║
//║   0xF13B :: MARKET_REACTION     :: PENDING                                         ║
//║                                                                                    ║
//╠════════════════════════════════════════════════════════════════════════════════════╣
//║                                                                                    ║
//║   >>> MODE      : DARK SCROLL TERMINAL                                             ║
//║   >>> ENGINE    : ALPHA WIZARD ORDER BOOK                                          ║
//║   >>> PROTOCOL  : LIQUIDITY • DELTA • ABSORPTION • SWEEP • PRESSURE                ║
//║   >>> STATUS    : SIGNAL GRID ONLINE                                               ║
//║                                                                                    ║
//╚════════════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator("Order Book Ultimate", "Order book", overlay = true, max_labels_count = 100, max_boxes_count = 30, max_lines_count = 30)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS / ENGINE MODES
// ═══════════════════════════════════════════════════════════════════════════════
string G_ENGINE = "═══ 🧠 ENGINE MODES ═══"
i_engine_mode   = input.string("Hybrid Pro", "Engine Mode", options = ["Classic Synthetic", "Intrabar Flow", "Hybrid Pro"], group = G_ENGINE)
i_ltf_tf        = input.timeframe("1", "Lower Timeframe", group = G_ENGINE)
i_ltf_weight    = input.float(0.55, "Intrabar Weight in Hybrid", minval = 0.0, maxval = 1.0, step = 0.05, group = G_ENGINE)
i_confirm_close = input.bool(true, "Use Confirmed Bars for Signals", group = G_ENGINE)

string G_OB = "═══ 📊 SYNTHETIC DEPTH ENGINE ═══"
i_levels       = input.int(15, "Levels Per Side", minval = 5, maxval = 20, group = G_OB)
i_tick_mult    = input.float(1.0, "Level Spacing x ATR", minval = 0.10, maxval = 6.0, step = 0.05, group = G_OB)
i_vol_lb       = input.int(100, "Volume Lookback", minval = 20, maxval = 500, group = G_OB)
i_refresh      = input.int(1, "Refresh Rate (bars)", minval = 1, maxval = 10, group = G_OB)
i_depth_mult   = input.float(2.0, "Depth Multiplier", minval = 0.25, maxval = 10.0, step = 0.25, group = G_OB)
i_decay_sigma  = input.float(3.0, "Depth Decay Sigma", minval = 0.75, maxval = 8.0, step = 0.25, group = G_OB)
i_memory_bars  = input.int(40, "Liquidity Memory Bars", minval = 5, maxval = 200, group = G_OB)

string G_RND = "═══ 🧲 ROUND NUMBER ENGINE ═══"
i_round_mag    = input.float(2.0, "Round Number Magnetism", minval = 0.5, maxval = 8.0, step = 0.25, group = G_RND)
i_round_auto   = input.bool(true, "Auto Round Step", group = G_RND)
i_round_step_m = input.float(0.0, "Manual Round Step", minval = 0.0, step = 0.01, group = G_RND)
i_round_zone   = input.float(1.5, "Round Zone Width %", minval = 0.1, maxval = 10.0, step = 0.1, group = G_RND)

string G_FLW = "═══ 🌊 FLOW / PRESSURE ENGINE ═══"
i_delta_len    = input.int(20, "Delta Length", minval = 5, maxval = 120, group = G_FLW)
i_obv_len      = input.int(20, "OBV MA Length", minval = 5, maxval = 120, group = G_FLW)
i_pressure_smooth = input.int(5, "Pressure Smoothing", minval = 1, maxval = 50, group = G_FLW)

string G_STAB = "═══ 🧱 WALL STABILITY / MEMORY ═══"
i_wall_stable_bars = input.int(3, "Wall Stable Bars", minval = 1, maxval = 30, group = G_STAB)
i_wall_hold_ticks   = input.float(3.0, "Same Wall Zone x Tick", minval = 0.5, maxval = 20.0, step = 0.5, group = G_STAB)
i_hist_max          = input.int(12, "Max Historical Zones", minval = 3, maxval = 30, group = G_STAB)
i_hist_merge_ticks  = input.float(6.0, "Historical Merge x Tick", minval = 1.0, maxval = 50.0, step = 1.0, group = G_STAB)
i_hist_decay         = input.float(0.985, "Historical Strength Decay", minval = 0.90, maxval = 1.0, step = 0.005, group = G_STAB)

string G_MICRO = "═══ 🧪 ABSORPTION / SWEEP / FILTERS ═══"
i_noise_filter = input.bool(true, "Anti-Noise Confirmation", group = G_MICRO)
i_min_vol_mult = input.float(0.90, "Min Volume x Avg", minval = 0.10, maxval = 5.0, step = 0.05, group = G_MICRO)
i_abs_vol_mult = input.float(1.20, "Absorption Volume x Avg", minval = 0.50, maxval = 8.0, step = 0.10, group = G_MICRO)
i_abs_zone_atr = input.float(0.18, "Absorption Zone x ATR", minval = 0.02, maxval = 1.5, step = 0.02, group = G_MICRO)
i_sweep_zone_atr = input.float(0.10, "Sweep Zone x ATR", minval = 0.02, maxval = 1.5, step = 0.02, group = G_MICRO)
i_exhaust_rsi_hi = input.float(72.0, "Exhaustion RSI High", minval = 55.0, maxval = 95.0, step = 1.0, group = G_MICRO)
i_exhaust_rsi_lo = input.float(28.0, "Exhaustion RSI Low", minval = 5.0, maxval = 45.0, step = 1.0, group = G_MICRO)

string G_REGIME = "═══ 🌍 REGIME / ASSET CALIBRATION ═══"
i_asset_profile = input.string("Auto", "Asset Profile", options = ["Auto", "Crypto", "Forex", "Index", "Stock", "Futures", "Generic"], group = G_REGIME)
i_auto_calibrate = input.bool(true, "Auto-Calibrate Thresholds", group = G_REGIME)
i_adx_len = input.int(14, "ADX Length", minval = 5, maxval = 50, group = G_REGIME)
i_regime_smooth = input.int(100, "Volatility Baseline", minval = 20, maxval = 300, group = G_REGIME)

string G_SPR = "═══ 🧪 SPREAD / RANGE PROXY ═══"
i_spread_mode  = input.string("Adaptive Proxy", "Spread Display", options = ["Adaptive Proxy", "Bar Range", "ATR Micro"], group = G_SPR)
i_spread_factor = input.float(0.05, "Adaptive Spread Factor", minval = 0.005, maxval = 0.50, step = 0.005, group = G_SPR)

string G_VIS = "═══ 🎨 VISUAL / PANEL ═══"
i_show_panel   = input.bool(true, "Show Panel", group = G_VIS)
i_ui_mode      = input.string("Full", "Panel Mode", options = ["Compact", "Full", "Debug"], group = G_VIS)
i_panel_pos    = input.string("Bottom Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_VIS)
i_show_zones   = input.bool(true, "Show Best Wall Zones", group = G_VIS)
i_show_signals = input.bool(true, "Show Signal Markers", group = G_VIS)
i_zone_bars    = input.int(30, "Wall Zone Forward Bars", minval = 5, maxval = 200, group = G_VIS)
i_c_panel_bg   = input.color(#050A14, "Panel BG", group = G_VIS)
i_c_bid        = input.color(#00E676, "Bid Color", group = G_VIS)
i_c_ask        = input.color(#FF1744, "Ask Color", group = G_VIS)
i_c_neutral    = input.color(#607D8B, "Neutral Color", group = G_VIS)
i_c_accent     = input.color(#00E5FF, "Accent Color", group = G_VIS)
i_c_warning    = input.color(#FFD600, "Warning Color", group = G_VIS)

string G_ALR = "═══ 📡 ALERTS / SCORING ═══"
i_alert_wall   = input.float(2.0, "Wall Threshold x Avg", minval = 1.1, maxval = 8.0, step = 0.1, group = G_ALR)
i_alert_imb    = input.float(1.6, "Imbalance Threshold", minval = 1.1, maxval = 5.0, step = 0.1, group = G_ALR)
i_score_long   = input.int(70, "Long Bias Score", minval = 51, maxval = 95, group = G_ALR)
i_score_short  = input.int(30, "Short Bias Score", minval = 5, maxval = 49, group = G_ALR)
i_conf_min     = input.int(55, "Min Confidence", minval = 1, maxval = 100, group = G_ALR)

string G_BT = "═══ 📈 VISUAL BACKTEST STATS ═══"
i_bt_enable    = input.bool(true, "Enable Visual Stats", group = G_BT)
i_bt_target_atr = input.float(0.75, "Target x ATR", minval = 0.10, maxval = 10.0, step = 0.05, group = G_BT)
i_bt_stop_atr   = input.float(0.55, "Invalidation x ATR", minval = 0.10, maxval = 10.0, step = 0.05, group = G_BT)
i_bt_max_bars   = input.int(30, "Max Bars In Signal", minval = 1, maxval = 300, group = G_BT)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_safe_div(float a, float b, float fallback) =>
    b != 0.0 and not na(b) ? a / b : fallback

f_fmt_k(float v) =>
    string out = ""
    float av = math.abs(v)
    if av >= 1000000000
        out := str.tostring(v / 1000000000, "#.##") + "B"
    else if av >= 1000000
        out := str.tostring(v / 1000000, "#.##") + "M"
    else if av >= 1000
        out := str.tostring(v / 1000, "#.#") + "K"
    else
        out := str.tostring(v, "#.#")
    out

f_pct_bar(float pct, int len) =>
    float p = f_clamp(pct, 0.0, 100.0)
    int filled = int(math.round(p / (100.0 / len)))
    string bar = ""
    for i = 0 to len - 1
        bar += i < filled ? "█" : "░"
    bar

f_gauss(float x, float sigma) =>
    math.exp(-0.5 * math.pow(x / math.max(sigma, 0.001), 2.0))

f_log10(float x) =>
    math.log(math.max(x, 0.000000001)) / math.log(10.0)

f_auto_round_step(float price) =>
    float p = math.max(math.abs(price), syminfo.mintick)
    float mag = math.pow(10.0, math.floor(f_log10(p)))
    float step = mag / 10.0
    math.max(step, syminfo.mintick)

f_round_score(float price, float _tick_size, float _round_step, float _round_mag, float _zone_pct) =>
    float step = math.max(_round_step, syminfo.mintick)
    float zone = math.max(_tick_size * 2.0, step * _zone_pct / 100.0)
    float nearest_minor = math.round(price / step) * step
    float d_minor = math.abs(price - nearest_minor)
    float minor_boost = f_gauss(d_minor, zone)
    float major = step * 10.0
    float nearest_major = math.round(price / major) * major
    float d_major = math.abs(price - nearest_major)
    float major_boost = f_gauss(d_major, zone * 2.0)
    float score = 1.0 + (_round_mag - 1.0) * minor_boost + (_round_mag - 1.0) * 1.25 * major_boost
    f_clamp(score, 0.5, _round_mag * 2.75)

f_norm_ratio(float r, float threshold) =>
    float rr = math.max(r, 0.0001)
    float t = math.max(threshold, 1.01)
    f_clamp(math.log(rr) / math.log(t), -1.0, 1.0)

f_auto_profile() =>
    syminfo.type == "crypto" ? "Crypto" : syminfo.type == "forex" ? "Forex" : syminfo.type == "index" ? "Index" : syminfo.type == "stock" ? "Stock" : syminfo.type == "futures" ? "Futures" : "Generic"

f_cell(table t, int col, int row, string txt, color txt_col, color bg_col) =>
    table.cell(t, col, row, txt, text_color = txt_col, text_size = size.tiny, bgcolor = bg_col)

// ═══════════════════════════════════════════════════════════════════════════════
// ASSET AUTO CALIBRATION
// ═══════════════════════════════════════════════════════════════════════════════
string profile = i_asset_profile == "Auto" ? f_auto_profile() : i_asset_profile
float profile_wall_adj = profile == "Crypto" ? 1.10 : profile == "Forex" ? 0.88 : profile == "Index" ? 1.00 : profile == "Stock" ? 1.15 : profile == "Futures" ? 1.00 : 1.00
float profile_round_adj = profile == "Forex" ? 0.20 : profile == "Crypto" ? 1.20 : profile == "Stock" ? 1.00 : profile == "Index" ? 1.40 : 1.00
float profile_mem_adj = profile == "Crypto" ? 1.25 : profile == "Forex" ? 0.85 : profile == "Stock" ? 1.10 : 1.00
float eff_wall_thr = i_auto_calibrate ? i_alert_wall * profile_wall_adj : i_alert_wall
float eff_round_mag = i_auto_calibrate ? i_round_mag * profile_round_adj : i_round_mag
int eff_memory_bars = int(math.round(i_memory_bars * (i_auto_calibrate ? profile_mem_adj : 1.0)))

// ═══════════════════════════════════════════════════════════════════════════════
// CORE MARKET METRICS
// ═══════════════════════════════════════════════════════════════════════════════
float atr14       = nz(ta.atr(14), high - low)
float bar_range   = math.max(high - low, syminfo.mintick)
float body        = math.abs(close - open)
float upper_wick  = high - math.max(open, close)
float lower_wick  = math.min(open, close) - low
float range_ema   = nz(ta.ema(bar_range, 10), bar_range)
float vol_sma     = nz(ta.sma(volume, 20), volume)
float vol_sma_l   = nz(ta.sma(volume, i_vol_lb), vol_sma)
float vol_ratio_r = f_safe_div(vol_sma, vol_sma_l, 1.0)
float vol_ratio   = f_clamp(vol_ratio_r, 0.25, 4.0)

float tick_size = math.max(atr14 * 0.006 * i_tick_mult, syminfo.mintick * 10.0)
float raw_round_step = i_round_auto ? f_auto_round_step(close) : math.max(i_round_step_m, syminfo.mintick)
float round_step = math.max(raw_round_step * (profile == "Forex" ? 0.10 : 1.0), syminfo.mintick)

float spread_proxy = switch i_spread_mode
    "Bar Range"      => bar_range
    "ATR Micro"      => math.max(syminfo.mintick, atr14 * 0.002)
    => math.max(syminfo.mintick, range_ema * i_spread_factor)
float spread_pct = close > 0 ? spread_proxy / close * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// MTF / INTRABAR FLOW ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
array<float> ltf_o = request.security_lower_tf(syminfo.tickerid, i_ltf_tf, open, ignore_invalid_timeframe = true)
array<float> ltf_h = request.security_lower_tf(syminfo.tickerid, i_ltf_tf, high, ignore_invalid_timeframe = true)
array<float> ltf_l = request.security_lower_tf(syminfo.tickerid, i_ltf_tf, low, ignore_invalid_timeframe = true)
array<float> ltf_c = request.security_lower_tf(syminfo.tickerid, i_ltf_tf, close, ignore_invalid_timeframe = true)
array<float> ltf_v = request.security_lower_tf(syminfo.tickerid, i_ltf_tf, volume, ignore_invalid_timeframe = true)

int intrabar_n = math.min(array.size(ltf_o), math.min(array.size(ltf_h), math.min(array.size(ltf_l), math.min(array.size(ltf_c), array.size(ltf_v)))))
float ltf_buy = 0.0
float ltf_sell = 0.0
float ltf_delta = 0.0
float ltf_range_sum = 0.0
int ltf_up = 0
int ltf_down = 0

if intrabar_n > 0
    for i = 0 to intrabar_n - 1
        float io = array.get(ltf_o, i)
        float ih = array.get(ltf_h, i)
        float il = array.get(ltf_l, i)
        float ic = array.get(ltf_c, i)
        float iv = array.get(ltf_v, i)
        float ir = math.max(ih - il, syminfo.mintick)
        float ipos = f_clamp((ic - il) / ir, 0.0, 1.0)
        ltf_buy += iv * ipos
        ltf_sell += iv * (1.0 - ipos)
        ltf_delta += iv * f_clamp((ic - io) / ir, -1.0, 1.0)
        ltf_range_sum += ir
        if ic > io
            ltf_up += 1
        else if ic < io
            ltf_down += 1

float ltf_total = ltf_buy + ltf_sell
float ltf_pressure_raw = intrabar_n > 0 ? f_clamp(f_safe_div(ltf_delta, ltf_total, 0.0), -1.0, 1.0) : 0.0
float ltf_bs_ratio = f_safe_div(ltf_buy, ltf_sell, 1.0)
float ltf_participation = f_clamp(float(intrabar_n) / 20.0, 0.0, 1.0)
float ltf_quality = intrabar_n > 0 ? f_clamp(math.abs(float(ltf_up - ltf_down)) / math.max(float(intrabar_n), 1.0) + ltf_participation * 0.35, 0.0, 1.0) : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// PRESSURE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
float close_pos = f_clamp((close - low) / bar_range, 0.0, 1.0)
float buy_vol_est  = volume * close_pos
float sell_vol_est = volume * (1.0 - close_pos)
float cum_buy      = nz(math.sum(buy_vol_est, i_delta_len), buy_vol_est)
float cum_sell     = nz(math.sum(sell_vol_est, i_delta_len), sell_vol_est)
float bs_ratio_syn = f_safe_div(cum_buy, cum_sell, 1.0)

float candle_delta = volume * f_clamp((close - open) / bar_range, -1.0, 1.0)
float delta_sum    = nz(math.sum(candle_delta, i_delta_len), candle_delta)
float vol_sum      = nz(math.sum(volume, i_delta_len), volume)
float raw_pressure = f_clamp(f_safe_div(delta_sum, vol_sum, 0.0), -1.0, 1.0)
float pressure_syn = nz(ta.ema(raw_pressure, i_pressure_smooth), raw_pressure)

float hybrid_w = f_clamp(i_ltf_weight * ltf_quality, 0.0, 1.0)
float pressure = switch i_engine_mode
    "Classic Synthetic" => pressure_syn
    "Intrabar Flow"     => intrabar_n > 0 ? ltf_pressure_raw : pressure_syn
    => pressure_syn * (1.0 - hybrid_w) + ltf_pressure_raw * hybrid_w

float bs_ratio = switch i_engine_mode
    "Classic Synthetic" => bs_ratio_syn
    "Intrabar Flow"     => intrabar_n > 0 ? ltf_bs_ratio : bs_ratio_syn
    => bs_ratio_syn * (1.0 - hybrid_w) + ltf_bs_ratio * hybrid_w

float obv_val  = ta.cum(math.sign(ta.change(close)) * volume)
float obv_ma   = ta.sma(obv_val, i_obv_len)
bool  obv_bull = obv_val > obv_ma
float rsi_val  = ta.rsi(close, 14)

int valid_bars = 0
int bull_bars = 0
int bear_bars = 0
int trend_len = math.min(i_vol_lb - 1, math.min(bar_index, 120))
for i = 0 to trend_len
    if not na(close[i]) and not na(open[i])
        valid_bars += 1
        if close[i] > open[i]
            bull_bars += 1
        else if close[i] < open[i]
            bear_bars += 1
float bull_pct = valid_bars > 0 ? bull_bars / float(valid_bars) : 0.5
float trend_score = f_clamp((bull_pct - 0.5) * 2.0, -1.0, 1.0)

// ═══════════════════════════════════════════════════════════════════════════════
// MARKET REGIME ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
[di_plus, di_minus, adx_val_raw] = ta.dmi(i_adx_len, i_adx_len)
float adx_val = nz(adx_val_raw, 0.0)
float atr_base = nz(ta.sma(atr14, i_regime_smooth), atr14)
float atr_rel = f_safe_div(atr14, atr_base, 1.0)
float vol_rel = f_safe_div(volume, vol_sma, 1.0)
bool high_volatility = atr_rel > 1.35
bool low_liquidity = vol_rel < 0.65
bool trending = adx_val > 24 and math.abs(di_plus - di_minus) > 5
bool ranging = adx_val < 17 and atr_rel < 1.15
bool breakout_mode = volume > vol_sma * 1.35 and bar_range > range_ema * 1.25
string market_mode = high_volatility ? "HIGH VOL" : low_liquidity ? "LOW LIQ" : breakout_mode ? "BREAKOUT" : trending ? "TRENDING" : ranging ? "RANGING" : "BALANCED"
float regime_quality = low_liquidity ? 0.55 : high_volatility ? 0.75 : ranging ? 0.80 : trending ? 0.88 : 0.78

// ═══════════════════════════════════════════════════════════════════════════════
// SYNTHETIC DEPTH ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
f_depth(float level_price, bool is_bid, float _close, float _atr, float _vol_sma, float _pressure, float _vol_ratio, float _tick_size, float _round_step, float _round_mag) =>
    float dist_atr = math.abs(level_price - _close) / math.max(_atr, syminfo.mintick)
    float base = f_gauss(dist_atr, i_decay_sigma) * _vol_sma * i_depth_mult
    float round_mult = f_round_score(level_price, _tick_size, _round_step, _round_mag, i_round_zone)
    float p_mult_raw = is_bid ? 1.0 + _pressure * 0.55 : 1.0 - _pressure * 0.55
    float pressure_mult = f_clamp(p_mult_raw, 0.35, 1.85)
    float obv_mult = is_bid ? (obv_bull ? 1.08 : 0.94) : (obv_bull ? 0.94 : 1.08)
    float regime_mult = market_mode == "LOW LIQ" ? 0.75 : market_mode == "HIGH VOL" ? 1.15 : market_mode == "BREAKOUT" ? 1.08 : 1.0
    float mem = 0.0
    int max_mem = math.min(eff_memory_bars - 1, bar_index)
    for j = 0 to max_mem
        float r = math.max(high[j] - low[j], syminfo.mintick)
        bool touched = level_price >= low[j] and level_price <= high[j]
        if touched
            float recency = 1.0 - float(j) / float(max_mem + 1)
            float reject_quality = is_bid ? f_clamp((close[j] - low[j]) / r, 0.15, 1.25) : f_clamp((high[j] - close[j]) / r, 0.15, 1.25)
            mem += volume[j] * (0.018 + 0.045 * recency) * reject_quality
    float liquidity = (base * round_mult * pressure_mult * obv_mult * regime_mult + mem) * _vol_ratio
    math.max(liquidity, 0.0)

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL ARRAYS
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> ask_prices = array.new_float(20, 0.0)
var array<float> bid_prices = array.new_float(20, 0.0)
var array<float> ask_depths = array.new_float(20, 0.0)
var array<float> bid_depths = array.new_float(20, 0.0)

float total_ask_depth = 0.0
float total_bid_depth = 0.0
float max_depth       = 1.0
float max_ask         = 0.0
float max_bid         = 0.0
int   max_ask_idx     = 0
int   max_bid_idx     = 0

bool do_refresh = barstate.islast or (bar_index % i_refresh == 0)
if do_refresh
    total_ask_depth := 0.0
    total_bid_depth := 0.0
    max_depth       := 1.0
    max_ask         := 0.0
    max_bid         := 0.0
    max_ask_idx     := 0
    max_bid_idx     := 0

    for i = 0 to i_levels - 1
        float spacing = tick_size * (1.0 + i * 0.35)
        float ask_p = close + spacing * (i + 1)
        float bid_p = close - spacing * (i + 1)
        array.set(ask_prices, i, ask_p)
        array.set(bid_prices, i, bid_p)
        float ad = f_depth(ask_p, false, close, atr14, vol_sma, pressure, vol_ratio, tick_size, round_step, eff_round_mag)
        float bd = f_depth(bid_p, true,  close, atr14, vol_sma, pressure, vol_ratio, tick_size, round_step, eff_round_mag)
        array.set(ask_depths, i, ad)
        array.set(bid_depths, i, bd)
        total_ask_depth += ad
        total_bid_depth += bd
        if ad > max_ask
            max_ask := ad
            max_ask_idx := i
        if bd > max_bid
            max_bid := bd
            max_bid_idx := i
    max_depth := math.max(math.max(max_ask, max_bid), 1.0)

// ═══════════════════════════════════════════════════════════════════════════════
// WALLS / IMBALANCE / STABILITY
// ═══════════════════════════════════════════════════════════════════════════════
float avg_bid_depth = f_safe_div(total_bid_depth, i_levels, 0.0)
float avg_ask_depth = f_safe_div(total_ask_depth, i_levels, 0.0)
float bid_wall_ratio = f_safe_div(max_bid, avg_bid_depth, 0.0)
float ask_wall_ratio = f_safe_div(max_ask, avg_ask_depth, 0.0)

bool bid_wall_confirmed = max_bid > avg_bid_depth * eff_wall_thr and bid_wall_ratio > ask_wall_ratio * 0.85
bool ask_wall_confirmed = max_ask > avg_ask_depth * eff_wall_thr and ask_wall_ratio > bid_wall_ratio * 0.85

float bid_ask_ratio = f_safe_div(total_bid_depth, total_ask_depth, 1.0)
float bid_pct = f_safe_div(total_bid_depth, total_bid_depth + total_ask_depth, 0.5) * 100.0
float ask_pct = 100.0 - bid_pct
float best_bid_wall_p = array.get(bid_prices, max_bid_idx)
float best_ask_wall_p = array.get(ask_prices, max_ask_idx)

var float active_bid_wall = na
var float active_ask_wall = na
var int bid_wall_age = 0
var int ask_wall_age = 0
var float prev_bid_wall_ratio = na
var float prev_ask_wall_ratio = na

bool same_bid_wall = not na(active_bid_wall) and math.abs(best_bid_wall_p - active_bid_wall) <= tick_size * i_wall_hold_ticks
bool same_ask_wall = not na(active_ask_wall) and math.abs(best_ask_wall_p - active_ask_wall) <= tick_size * i_wall_hold_ticks

if barstate.isconfirmed or not i_confirm_close
    if bid_wall_confirmed
        if same_bid_wall
            bid_wall_age += 1
            active_bid_wall := (active_bid_wall + best_bid_wall_p) / 2.0
        else
            active_bid_wall := best_bid_wall_p
            bid_wall_age := 1
        prev_bid_wall_ratio := bid_wall_ratio
    else
        bid_wall_age := math.max(bid_wall_age - 1, 0)

    if ask_wall_confirmed
        if same_ask_wall
            ask_wall_age += 1
            active_ask_wall := (active_ask_wall + best_ask_wall_p) / 2.0
        else
            active_ask_wall := best_ask_wall_p
            ask_wall_age := 1
        prev_ask_wall_ratio := ask_wall_ratio
    else
        ask_wall_age := math.max(ask_wall_age - 1, 0)

bool bid_wall_stable = bid_wall_confirmed and bid_wall_age >= i_wall_stable_bars
bool ask_wall_stable = ask_wall_confirmed and ask_wall_age >= i_wall_stable_bars
float bid_wall_power_chg = not na(prev_bid_wall_ratio) and prev_bid_wall_ratio != 0.0 ? (bid_wall_ratio - prev_bid_wall_ratio) / prev_bid_wall_ratio * 100.0 : 0.0
float ask_wall_power_chg = not na(prev_ask_wall_ratio) and prev_ask_wall_ratio != 0.0 ? (ask_wall_ratio - prev_ask_wall_ratio) / prev_ask_wall_ratio * 100.0 : 0.0
string bid_wall_state = bid_wall_stable ? "HOLDING" : bid_wall_confirmed ? "BUILDING" : bid_wall_age > 0 ? "WEAK" : "NONE"
string ask_wall_state = ask_wall_stable ? "HOLDING" : ask_wall_confirmed ? "BUILDING" : ask_wall_age > 0 ? "WEAK" : "NONE"

// ═══════════════════════════════════════════════════════════════════════════════
// HISTORICAL LIQUIDITY MAP
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> hist_prices = array.new_float()
var array<float> hist_strengths = array.new_float()
var array<int> hist_ages = array.new_int()
var array<int> hist_sides = array.new_int()
var array<int> hist_touches = array.new_int()
var array<int> hist_rejects = array.new_int()

if barstate.isconfirmed
    int hz = array.size(hist_prices)
    if hz > 0
        for z = 0 to hz - 1
            array.set(hist_ages, z, array.get(hist_ages, z) + 1)
            array.set(hist_strengths, z, array.get(hist_strengths, z) * i_hist_decay)

    if bid_wall_stable
        int merge_bid = na
        int szb = array.size(hist_prices)
        if szb > 0
            for z = 0 to szb - 1
                if array.get(hist_sides, z) == 1 and math.abs(array.get(hist_prices, z) - best_bid_wall_p) <= tick_size * i_hist_merge_ticks
                    merge_bid := z
                    break
        if na(merge_bid)
            array.unshift(hist_prices, best_bid_wall_p)
            array.unshift(hist_strengths, bid_wall_ratio)
            array.unshift(hist_ages, 0)
            array.unshift(hist_sides, 1)
            array.unshift(hist_touches, 1)
            array.unshift(hist_rejects, close > best_bid_wall_p ? 1 : 0)
        else
            float os = array.get(hist_strengths, merge_bid)
            float op = array.get(hist_prices, merge_bid)
            float ns = math.max(os + bid_wall_ratio * 0.35, bid_wall_ratio)
            array.set(hist_prices, merge_bid, (op * os + best_bid_wall_p * bid_wall_ratio) / math.max(os + bid_wall_ratio, 0.0001))
            array.set(hist_strengths, merge_bid, ns)
            array.set(hist_ages, merge_bid, 0)
            array.set(hist_touches, merge_bid, array.get(hist_touches, merge_bid) + 1)
            array.set(hist_rejects, merge_bid, array.get(hist_rejects, merge_bid) + (close > best_bid_wall_p ? 1 : 0))

    if ask_wall_stable
        int merge_ask = na
        int sza = array.size(hist_prices)
        if sza > 0
            for z = 0 to sza - 1
                if array.get(hist_sides, z) == -1 and math.abs(array.get(hist_prices, z) - best_ask_wall_p) <= tick_size * i_hist_merge_ticks
                    merge_ask := z
                    break
        if na(merge_ask)
            array.unshift(hist_prices, best_ask_wall_p)
            array.unshift(hist_strengths, ask_wall_ratio)
            array.unshift(hist_ages, 0)
            array.unshift(hist_sides, -1)
            array.unshift(hist_touches, 1)
            array.unshift(hist_rejects, close < best_ask_wall_p ? 1 : 0)
        else
            float os = array.get(hist_strengths, merge_ask)
            float op = array.get(hist_prices, merge_ask)
            float ns = math.max(os + ask_wall_ratio * 0.35, ask_wall_ratio)
            array.set(hist_prices, merge_ask, (op * os + best_ask_wall_p * ask_wall_ratio) / math.max(os + ask_wall_ratio, 0.0001))
            array.set(hist_strengths, merge_ask, ns)
            array.set(hist_ages, merge_ask, 0)
            array.set(hist_touches, merge_ask, array.get(hist_touches, merge_ask) + 1)
            array.set(hist_rejects, merge_ask, array.get(hist_rejects, merge_ask) + (close < best_ask_wall_p ? 1 : 0))

    while array.size(hist_prices) > i_hist_max
        array.pop(hist_prices)
        array.pop(hist_strengths)
        array.pop(hist_ages)
        array.pop(hist_sides)
        array.pop(hist_touches)
        array.pop(hist_rejects)

float nearest_hist_bid = na
float nearest_hist_ask = na
float hist_bid_strength = 0.0
float hist_ask_strength = 0.0
int hist_bid_touches = 0
int hist_ask_touches = 0
int hist_count = array.size(hist_prices)
if hist_count > 0
    for z = 0 to hist_count - 1
        float hp = array.get(hist_prices, z)
        float hs = array.get(hist_strengths, z)
        int side = array.get(hist_sides, z)
        if side == 1 and hp <= close and hs > hist_bid_strength
            nearest_hist_bid := hp
            hist_bid_strength := hs
            hist_bid_touches := array.get(hist_touches, z)
        if side == -1 and hp >= close and hs > hist_ask_strength
            nearest_hist_ask := hp
            hist_ask_strength := hs
            hist_ask_touches := array.get(hist_touches, z)

// ═══════════════════════════════════════════════════════════════════════════════
// ABSORPTION / SWEEP ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
bool near_bid_wall = math.abs(low - best_bid_wall_p) <= atr14 * i_abs_zone_atr or (not na(nearest_hist_bid) and math.abs(low - nearest_hist_bid) <= atr14 * i_abs_zone_atr)
bool near_ask_wall = math.abs(high - best_ask_wall_p) <= atr14 * i_abs_zone_atr or (not na(nearest_hist_ask) and math.abs(high - nearest_hist_ask) <= atr14 * i_abs_zone_atr)
bool strong_volume = volume >= vol_sma * i_abs_vol_mult
bool bid_absorption = near_bid_wall and strong_volume and lower_wick > body * 0.85 and close > low + bar_range * 0.45
bool ask_absorption = near_ask_wall and strong_volume and upper_wick > body * 0.85 and close < high - bar_range * 0.45
float absorption_score = bid_absorption ? f_clamp((lower_wick / bar_range) * 100.0 + (vol_rel - 1.0) * 20.0, 0.0, 100.0) : ask_absorption ? f_clamp((upper_wick / bar_range) * 100.0 + (vol_rel - 1.0) * 20.0, 0.0, 100.0) : 0.0
string absorption_txt = bid_absorption ? "BID ACTIVE" : ask_absorption ? "ASK ACTIVE" : "NONE"

bool bullish_sweep = (low < best_bid_wall_p - atr14 * i_sweep_zone_atr and close > best_bid_wall_p) or (not na(nearest_hist_bid) and low < nearest_hist_bid - atr14 * i_sweep_zone_atr and close > nearest_hist_bid)
bool bearish_sweep = (high > best_ask_wall_p + atr14 * i_sweep_zone_atr and close < best_ask_wall_p) or (not na(nearest_hist_ask) and high > nearest_hist_ask + atr14 * i_sweep_zone_atr and close < nearest_hist_ask)
string sweep_txt = bullish_sweep ? "BULL SWEEP" : bearish_sweep ? "BEAR SWEEP" : "NONE"

// ═══════════════════════════════════════════════════════════════════════════════
// PRO SCORE / CONFIDENCE
// ═══════════════════════════════════════════════════════════════════════════════
float imbalance_score = f_norm_ratio(bid_ask_ratio, i_alert_imb)
float wall_score = f_clamp((bid_wall_ratio - ask_wall_ratio) / math.max(math.max(bid_wall_ratio, ask_wall_ratio), 1.0), -1.0, 1.0)
float pressure_score = f_clamp(pressure, -1.0, 1.0)
float obv_score = obv_bull ? 0.35 : -0.35
float rsi_score = rsi_val < 35 ? 0.20 : rsi_val > 65 ? -0.20 : 0.0
float absorption_bias = bid_absorption ? 0.35 : ask_absorption ? -0.35 : 0.0
float sweep_bias = bullish_sweep ? 0.30 : bearish_sweep ? -0.30 : 0.0
float regime_bias = trending ? (di_plus > di_minus ? 0.12 : -0.12) : 0.0

float score_raw = f_clamp(pressure_score * 0.30 + imbalance_score * 0.20 + wall_score * 0.18 + trend_score * 0.08 + obv_score * 0.06 + rsi_score * 0.03 + absorption_bias * 0.08 + sweep_bias * 0.05 + regime_bias * 0.02, -1.0, 1.0)
float pro_score = 50.0 + score_raw * 50.0

float agreement = 0.0
agreement += math.sign(pressure_score) == math.sign(score_raw) ? 15.0 : 0.0
agreement += math.sign(imbalance_score) == math.sign(score_raw) ? 13.0 : 0.0
agreement += math.sign(wall_score) == math.sign(score_raw) ? 13.0 : 0.0
agreement += math.sign(trend_score) == math.sign(score_raw) ? 8.0 : 0.0
agreement += obv_bull == (score_raw > 0) ? 8.0 : 0.0
agreement += intrabar_n > 0 ? 10.0 * ltf_quality : 3.0
agreement += bid_absorption or ask_absorption ? 8.0 : 0.0
agreement += bullish_sweep or bearish_sweep ? 6.0 : 0.0
agreement += regime_quality * 19.0
float confidence = f_clamp(agreement, 0.0, 100.0)

string bias_txt = pro_score >= i_score_long ? "LONG BIAS" : pro_score <= i_score_short ? "SHORT BIAS" : "NEUTRAL"
string imb_txt = bid_ask_ratio > i_alert_imb ? "BID HEAVY" : bid_ask_ratio < 1.0 / i_alert_imb ? "ASK HEAVY" : "BALANCED"
string pressure_txt = bs_ratio > 1.30 ? "BUY DOMINANT" : bs_ratio < 0.70 ? "SELL DOMINANT" : "NEUTRAL"

// ═══════════════════════════════════════════════════════════════════════════════
// ANTI-NOISE / SETUP STATES
// ═══════════════════════════════════════════════════════════════════════════════
bool valid_bar_for_signal = i_confirm_close ? barstate.isconfirmed : true
bool base_long = pro_score >= i_score_long and confidence >= i_conf_min
bool base_short = pro_score <= i_score_short and confidence >= i_conf_min
bool filter_long = not i_noise_filter or (volume >= vol_sma * i_min_vol_mult and pressure > -0.10 and (bid_wall_stable or bid_absorption or bullish_sweep) and not low_liquidity)
bool filter_short = not i_noise_filter or (volume >= vol_sma * i_min_vol_mult and pressure < 0.10 and (ask_wall_stable or ask_absorption or bearish_sweep) and not low_liquidity)
bool long_setup = valid_bar_for_signal and base_long and filter_long
bool short_setup = valid_bar_for_signal and base_short and filter_short
bool long_early = pro_score >= i_score_long - 8 and confidence >= i_conf_min - 12 and not long_setup
bool short_early = pro_score <= i_score_short + 8 and confidence >= i_conf_min - 12 and not short_setup
bool long_exhausted = long_setup and rsi_val > i_exhaust_rsi_hi and upper_wick > body
bool short_exhausted = short_setup and rsi_val < i_exhaust_rsi_lo and lower_wick > body
bool long_invalidated = close < best_bid_wall_p - atr14 * i_bt_stop_atr and bid_wall_confirmed
bool short_invalidated = close > best_ask_wall_p + atr14 * i_bt_stop_atr and ask_wall_confirmed
string setup_state = long_invalidated or short_invalidated ? "INVALIDATED" : long_exhausted or short_exhausted ? "EXHAUSTED" : long_setup or short_setup ? "CONFIRMED" : long_early or short_early ? "EARLY" : "WAIT"

// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL BACKTEST STATS
// ═══════════════════════════════════════════════════════════════════════════════
var bool bt_active = false
var int bt_dir = 0
var int bt_entry_bar = na
var float bt_entry = na
var float bt_target = na
var float bt_stop = na
var int bt_total = 0
var int bt_wins = 0
var int bt_losses = 0
var float bt_last_result_atr = 0.0
var string bt_last_txt = "NONE"

bool new_long = i_bt_enable and long_setup and not long_setup[1]
bool new_short = i_bt_enable and short_setup and not short_setup[1]

if i_bt_enable and valid_bar_for_signal
    if not bt_active and (new_long or new_short)
        bt_active := true
        bt_dir := new_long ? 1 : -1
        bt_entry_bar := bar_index
        bt_entry := close
        bt_target := close + bt_dir * atr14 * i_bt_target_atr
        bt_stop := close - bt_dir * atr14 * i_bt_stop_atr
        bt_total += 1
        bt_last_txt := bt_dir == 1 ? "LONG OPEN" : "SHORT OPEN"

    if bt_active
        bool hit_target = bt_dir == 1 ? high >= bt_target : low <= bt_target
        bool hit_stop = bt_dir == 1 ? low <= bt_stop : high >= bt_stop
        bool timed_out = bar_index - bt_entry_bar >= i_bt_max_bars
        if hit_target
            bt_wins += 1
            bt_last_result_atr := math.abs(bt_target - bt_entry) / math.max(atr14, syminfo.mintick)
            bt_last_txt := "WIN +" + str.tostring(bt_last_result_atr, "#.##") + " ATR"
            bt_active := false
        else if hit_stop or timed_out
            bt_losses += 1
            float exit_p = timed_out ? close : bt_stop
            bt_last_result_atr := (exit_p - bt_entry) * bt_dir / math.max(atr14, syminfo.mintick)
            bt_last_txt := timed_out ? "TIME " + str.tostring(bt_last_result_atr, "#.##") + " ATR" : "LOSS " + str.tostring(bt_last_result_atr, "#.##") + " ATR"
            bt_active := false

float bt_hit_rate = bt_total > 0 ? float(bt_wins) / float(bt_total) * 100.0 : na

// ═══════════════════════════════════════════════════════════════════════════════
// WALL ZONES / MARKERS
// ═══════════════════════════════════════════════════════════════════════════════
var box bidWallBox = na
var box askWallBox = na

if barstate.islast
    if not na(bidWallBox)
        box.delete(bidWallBox)
    if not na(askWallBox)
        box.delete(askWallBox)

    if i_show_zones and bid_wall_stable
        bidWallBox := box.new(left = bar_index, top = best_bid_wall_p + tick_size * 0.50, right = bar_index + i_zone_bars, bottom = best_bid_wall_p - tick_size * 0.50, xloc = xloc.bar_index, bgcolor = color.new(i_c_bid, 86), border_color = color.new(i_c_bid, 10), border_width = 1)
    if i_show_zones and ask_wall_stable
        askWallBox := box.new(left = bar_index, top = best_ask_wall_p + tick_size * 0.50, right = bar_index + i_zone_bars, bottom = best_ask_wall_p - tick_size * 0.50, xloc = xloc.bar_index, bgcolor = color.new(i_c_ask, 86), border_color = color.new(i_c_ask, 10), border_width = 1)

plotshape(i_show_signals and long_setup, title = "WOB Long Setup", style = shape.triangleup, location = location.belowbar, color = i_c_bid, text = "L", textcolor = color.white, size = size.tiny)
plotshape(i_show_signals and short_setup, title = "WOB Short Setup", style = shape.triangledown, location = location.abovebar, color = i_c_ask, text = "S", textcolor = color.white, size = size.tiny)
plotshape(i_show_signals and bid_absorption, title = "Bid Absorption", style = shape.circle, location = location.belowbar, color = i_c_accent, text = "ABS", textcolor = color.white, size = size.tiny)
plotshape(i_show_signals and ask_absorption, title = "Ask Absorption", style = shape.circle, location = location.abovebar, color = i_c_warning, text = "ABS", textcolor = color.black, size = size.tiny)
plotshape(i_show_signals and bullish_sweep, title = "Bullish Sweep", style = shape.diamond, location = location.belowbar, color = i_c_bid, text = "SW", textcolor = color.white, size = size.tiny)
plotshape(i_show_signals and bearish_sweep, title = "Bearish Sweep", style = shape.diamond, location = location.abovebar, color = i_c_ask, text = "SW", textcolor = color.white, size = size.tiny)
plotshape(i_show_signals and (long_invalidated or short_invalidated), title = "Wall Invalidated", style = shape.xcross, location = location.top, color = i_c_warning, text = "X", textcolor = color.black, size = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// PANEL COMPACT / FULL / DEBUG
// ═══════════════════════════════════════════════════════════════════════════════
var table pnl = na

if i_show_panel
    if na(pnl)
        pnl := table.new(f_pos(i_panel_pos), 3, 42, bgcolor = color.new(i_c_panel_bg, 0), border_color = color.new(i_c_accent, 35), border_width = 1, frame_color = color.new(i_c_accent, 15), frame_width = 2)

    if barstate.islast
        table.clear(pnl, 0, 0, 2, 41)

        color cA = color.new(i_c_accent, 0)
        color cT = color.new(#ECEFF1, 0)
        color cD = color.new(i_c_neutral, 0)
        color cW = color.new(i_c_warning, 0)
        color cG = color.new(i_c_bid, 0)
        color cR = color.new(i_c_ask, 0)
        color cP = color.new(#7C4DFF, 0)
        color cBG = color.new(#0A1220, 0)
        color cHdr = color.new(#001A2E, 0)
        color score_col = pro_score >= i_score_long ? cG : pro_score <= i_score_short ? cR : cW
        color conf_col = confidence >= 70 ? cG : confidence >= i_conf_min ? cW : cR
        color imb_col = bid_ask_ratio > i_alert_imb ? cG : bid_ask_ratio < 1.0 / i_alert_imb ? cR : cD
        color pressure_col = bs_ratio > 1.30 ? cG : bs_ratio < 0.70 ? cR : cD
        color state_col = setup_state == "CONFIRMED" ? score_col : setup_state == "EARLY" ? cW : setup_state == "EXHAUSTED" or setup_state == "INVALIDATED" ? cR : cD

        f_cell(pnl, 0, 0, "⚡ WIZARD", cA, cHdr)
        f_cell(pnl, 1, 0, "ORDER BOOK ULTIMATE", cW, cHdr)
        table.cell(pnl, 2, 0, syminfo.ticker + " " + timeframe.period, text_color = cT, text_size = size.tiny, bgcolor = cHdr, text_halign = text.align_right)

        float chgPct = close[1] != 0 ? (close - close[1]) / close[1] * 100.0 : 0.0
        f_cell(pnl, 0, 1, "PRICE", cD, cBG)
        f_cell(pnl, 1, 1, str.tostring(close, format.mintick), cT, cBG)
        f_cell(pnl, 2, 1, (close >= close[1] ? "+" : "") + str.tostring(chgPct, "#.##") + "%", close >= close[1] ? cG : cR, cBG)

        f_cell(pnl, 0, 2, "SCORE", cD, cBG)
        f_cell(pnl, 1, 2, str.tostring(pro_score, "#.0") + "/100", score_col, cBG)
        f_cell(pnl, 2, 2, bias_txt, score_col, cBG)

        f_cell(pnl, 0, 3, "CONFIDENCE", cD, cBG)
        f_cell(pnl, 1, 3, str.tostring(confidence, "#.0") + "/100", conf_col, cBG)
        f_cell(pnl, 2, 3, setup_state, state_col, cBG)

        f_cell(pnl, 0, 4, "REGIME", cD, cBG)
        f_cell(pnl, 1, 4, market_mode, market_mode == "LOW LIQ" ? cR : market_mode == "HIGH VOL" ? cW : cA, cBG)
        f_cell(pnl, 2, 4, profile, cD, cBG)

        f_cell(pnl, 0, 5, "BID / ASK", cD, cBG)
        f_cell(pnl, 1, 5, f_fmt_k(total_bid_depth) + " / " + f_fmt_k(total_ask_depth), bid_ask_ratio >= 1 ? cG : cR, cBG)
        f_cell(pnl, 2, 5, str.tostring(bid_ask_ratio, "#.##") + "x", imb_col, cBG)

        f_cell(pnl, 0, 6, "PRESSURE", cD, cBG)
        f_cell(pnl, 1, 6, pressure_txt, pressure_col, cBG)
        f_cell(pnl, 2, 6, str.tostring(pressure * 100.0, "#.0") + "%", pressure >= 0 ? cG : cR, cBG)

        f_cell(pnl, 0, 7, "WALLS", cD, cBG)
        f_cell(pnl, 1, 7, bid_wall_state + " / " + ask_wall_state, bid_wall_stable ? cG : ask_wall_stable ? cR : cD, cBG)
        f_cell(pnl, 2, 7, "B" + str.tostring(bid_wall_age) + " A" + str.tostring(ask_wall_age), cD, cBG)

        f_cell(pnl, 0, 8, "ABS / SWEEP", cD, cBG)
        f_cell(pnl, 1, 8, absorption_txt, bid_absorption ? cG : ask_absorption ? cR : cD, cBG)
        f_cell(pnl, 2, 8, sweep_txt, bullish_sweep ? cG : bearish_sweep ? cR : cD, cBG)

        f_cell(pnl, 0, 9, "BT STATS", cD, cBG)
        f_cell(pnl, 1, 9, bt_last_txt, bt_last_result_atr >= 0 ? cG : cR, cBG)
        f_cell(pnl, 2, 9, bt_total > 0 ? str.tostring(bt_hit_rate, "#.0") + "% " + str.tostring(bt_wins) + "/" + str.tostring(bt_total) : "n/a", cD, cBG)

        if i_ui_mode == "Compact"
            f_cell(pnl, 0, 10, "MODE", color.new(cA, 35), cHdr)
            f_cell(pnl, 1, 10, i_engine_mode, color.new(cT, 45), cHdr)
            f_cell(pnl, 2, 10, "COMPACT", color.new(cA, 45), cHdr)
        else
            f_cell(pnl, 0, 10, "SPREAD", cD, cBG)
            f_cell(pnl, 1, 10, str.tostring(spread_proxy, format.mintick), cP, cBG)
            f_cell(pnl, 2, 10, str.tostring(spread_pct, "#.###") + "%", cD, cBG)

            f_cell(pnl, 0, 11, "DELTA", cD, cBG)
            f_cell(pnl, 1, 11, f_fmt_k(delta_sum), delta_sum >= 0 ? cG : cR, cBG)
            f_cell(pnl, 2, 11, "LTF " + str.tostring(intrabar_n), intrabar_n > 0 ? cA : cD, cBG)

            f_cell(pnl, 0, 12, "OBV FLOW", cD, cBG)
            f_cell(pnl, 1, 12, obv_bull ? "INFLOW" : "OUTFLOW", obv_bull ? cG : cR, cBG)
            f_cell(pnl, 2, 12, f_pct_bar(obv_bull ? 70.0 : 30.0, 10), obv_bull ? cG : cR, cBG)

            f_cell(pnl, 0, 13, "VOLUME", cD, cBG)
            f_cell(pnl, 1, 13, f_fmt_k(volume), volume > vol_sma * 1.3 ? cW : cT, cBG)
            f_cell(pnl, 2, 13, str.tostring(vol_rel, "#.##") + "x", vol_rel > 1.3 ? cW : cD, cBG)

            f_cell(pnl, 0, 14, "RSI / ADX", cD, cBG)
            f_cell(pnl, 1, 14, str.tostring(rsi_val, "#.0"), rsi_val > 70 ? cR : rsi_val < 30 ? cG : cT, cBG)
            f_cell(pnl, 2, 14, str.tostring(adx_val, "#.0"), trending ? cA : cD, cBG)

            f_cell(pnl, 0, 15, "ATR", cD, cBG)
            f_cell(pnl, 1, 15, str.tostring(atr14, format.mintick), cT, cBG)
            f_cell(pnl, 2, 15, close > 0 ? str.tostring(atr14 / close * 100.0, "#.##") + "%" : "n/a", cD, cBG)

            f_cell(pnl, 0, 16, "BID WALL", cG, cBG)
            f_cell(pnl, 1, 16, str.tostring(best_bid_wall_p, format.mintick), bid_wall_stable ? cG : cD, cBG)
            f_cell(pnl, 2, 16, f_fmt_k(max_bid) + " " + str.tostring(bid_wall_ratio, "#.1") + "x", bid_wall_stable ? cG : cD, cBG)

            f_cell(pnl, 0, 17, "ASK WALL", cR, cBG)
            f_cell(pnl, 1, 17, str.tostring(best_ask_wall_p, format.mintick), ask_wall_stable ? cR : cD, cBG)
            f_cell(pnl, 2, 17, f_fmt_k(max_ask) + " " + str.tostring(ask_wall_ratio, "#.1") + "x", ask_wall_stable ? cR : cD, cBG)

            f_cell(pnl, 0, 18, "WALL POWER", cD, cBG)
            f_cell(pnl, 1, 18, "B " + str.tostring(bid_wall_power_chg, "#.0") + "%", bid_wall_power_chg >= 0 ? cG : cR, cBG)
            f_cell(pnl, 2, 18, "A " + str.tostring(ask_wall_power_chg, "#.0") + "%", ask_wall_power_chg >= 0 ? cR : cG, cBG)

            f_cell(pnl, 0, 19, "HIST BID", cD, cBG)
            f_cell(pnl, 1, 19, na(nearest_hist_bid) ? "n/a" : str.tostring(nearest_hist_bid, format.mintick), cG, cBG)
            f_cell(pnl, 2, 19, str.tostring(hist_bid_touches) + " touches", cD, cBG)

            f_cell(pnl, 0, 20, "HIST ASK", cD, cBG)
            f_cell(pnl, 1, 20, na(nearest_hist_ask) ? "n/a" : str.tostring(nearest_hist_ask, format.mintick), cR, cBG)
            f_cell(pnl, 2, 20, str.tostring(hist_ask_touches) + " touches", cD, cBG)

            f_cell(pnl, 0, 21, "TOP BIDS", color.new(cG, 30), cBG)
            f_cell(pnl, 1, 21, str.tostring(array.get(bid_prices, 0), format.mintick) + " | " + f_fmt_k(array.get(bid_depths, 0)), cG, cBG)
            f_cell(pnl, 2, 21, f_pct_bar(array.get(bid_depths, 0) / max_depth * 100.0, 8), cG, cBG)

            f_cell(pnl, 0, 22, "", cD, cBG)
            f_cell(pnl, 1, 22, str.tostring(array.get(bid_prices, 1), format.mintick) + " | " + f_fmt_k(array.get(bid_depths, 1)), cG, cBG)
            f_cell(pnl, 2, 22, f_pct_bar(array.get(bid_depths, 1) / max_depth * 100.0, 8), cG, cBG)

            f_cell(pnl, 0, 23, "", cD, cBG)
            f_cell(pnl, 1, 23, str.tostring(array.get(bid_prices, 2), format.mintick) + " | " + f_fmt_k(array.get(bid_depths, 2)), cG, cBG)
            f_cell(pnl, 2, 23, f_pct_bar(array.get(bid_depths, 2) / max_depth * 100.0, 8), cG, cBG)

            f_cell(pnl, 0, 24, "TOP ASKS", color.new(cR, 30), cBG)
            f_cell(pnl, 1, 24, str.tostring(array.get(ask_prices, 0), format.mintick) + " | " + f_fmt_k(array.get(ask_depths, 0)), cR, cBG)
            f_cell(pnl, 2, 24, f_pct_bar(array.get(ask_depths, 0) / max_depth * 100.0, 8), cR, cBG)

            f_cell(pnl, 0, 25, "", cD, cBG)
            f_cell(pnl, 1, 25, str.tostring(array.get(ask_prices, 1), format.mintick) + " | " + f_fmt_k(array.get(ask_depths, 1)), cR, cBG)
            f_cell(pnl, 2, 25, f_pct_bar(array.get(ask_depths, 1) / max_depth * 100.0, 8), cR, cBG)

            f_cell(pnl, 0, 26, "", cD, cBG)
            f_cell(pnl, 1, 26, str.tostring(array.get(ask_prices, 2), format.mintick) + " | " + f_fmt_k(array.get(ask_depths, 2)), cR, cBG)
            f_cell(pnl, 2, 26, f_pct_bar(array.get(ask_depths, 2) / max_depth * 100.0, 8), cR, cBG)

            f_cell(pnl, 0, 27, "DEPTH MAP", cD, cBG)
            f_cell(pnl, 1, 27, f_pct_bar(bid_pct, 7), cG, cBG)
            f_cell(pnl, 2, 27, f_pct_bar(ask_pct, 7), cR, cBG)

            f_cell(pnl, 0, 28, "ROUND STEP", cD, cBG)
            f_cell(pnl, 1, 28, str.tostring(round_step, format.mintick), cW, cBG)
            f_cell(pnl, 2, 28, str.tostring(eff_round_mag, "#.##") + "x", cD, cBG)

            f_cell(pnl, 0, 29, "ENGINE", cD, cBG)
            f_cell(pnl, 1, 29, i_engine_mode, cA, cBG)
            f_cell(pnl, 2, 29, i_ltf_tf + " LTF", cD, cBG)

            if i_ui_mode == "Debug"
                f_cell(pnl, 0, 30, "DEBUG pressure", cD, cBG)
                f_cell(pnl, 1, 30, "syn " + str.tostring(pressure_syn, "#.###"), cT, cBG)
                f_cell(pnl, 2, 30, "ltf " + str.tostring(ltf_pressure_raw, "#.###"), cT, cBG)

                f_cell(pnl, 0, 31, "DEBUG hybrid", cD, cBG)
                f_cell(pnl, 1, 31, "w " + str.tostring(hybrid_w, "#.##"), cT, cBG)
                f_cell(pnl, 2, 31, "q " + str.tostring(ltf_quality, "#.##"), cT, cBG)

                f_cell(pnl, 0, 32, "DEBUG ratios", cD, cBG)
                f_cell(pnl, 1, 32, "B/A " + str.tostring(bid_ask_ratio, "#.##"), cT, cBG)
                f_cell(pnl, 2, 32, "B/S " + str.tostring(bs_ratio, "#.##"), cT, cBG)

                f_cell(pnl, 0, 33, "DEBUG thresh", cD, cBG)
                f_cell(pnl, 1, 33, "wall " + str.tostring(eff_wall_thr, "#.##"), cT, cBG)
                f_cell(pnl, 2, 33, "conf " + str.tostring(i_conf_min), cT, cBG)

                f_cell(pnl, 0, 34, "DEBUG regime", cD, cBG)
                f_cell(pnl, 1, 34, "atrRel " + str.tostring(atr_rel, "#.##"), cT, cBG)
                f_cell(pnl, 2, 34, "volRel " + str.tostring(vol_rel, "#.##"), cT, cBG)

                f_cell(pnl, 0, 35, "DEBUG memory", cD, cBG)
                f_cell(pnl, 1, 35, "zones " + str.tostring(hist_count), cT, cBG)
                f_cell(pnl, 2, 35, "mem " + str.tostring(eff_memory_bars), cT, cBG)

        int footer_row = i_ui_mode == "Compact" ? 11 : i_ui_mode == "Debug" ? 36 : 30
        f_cell(pnl, 0, footer_row, "RISK NOTE", cD, cBG)
        f_cell(pnl, 1, footer_row, "SYNTHETIC", cW, cBG)
        f_cell(pnl, 2, footer_row, "NOT L2", cW, cBG)

        f_cell(pnl, 0, footer_row + 1, "DELUXE", color.new(cA, 15), cHdr)
        f_cell(pnl, 1, footer_row + 1, "01..18 MODES", color.new(cT, 35), cHdr)
        f_cell(pnl, 2, footer_row + 1, "ULTIMATE v8", color.new(cA, 35), cHdr)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bid_wall_stable, "WOB ULTIMATE - Stable Bid Wall", "Stable synthetic BID wall confirmed on {{ticker}} {{interval}}")
alertcondition(ask_wall_stable, "WOB ULTIMATE - Stable Ask Wall", "Stable synthetic ASK wall confirmed on {{ticker}} {{interval}}")
alertcondition(bid_ask_ratio > i_alert_imb, "WOB ULTIMATE - Bid Heavy Imbalance", "Synthetic depth is BID heavy on {{ticker}} {{interval}}")
alertcondition(bid_ask_ratio < 1.0 / i_alert_imb, "WOB ULTIMATE - Ask Heavy Imbalance", "Synthetic depth is ASK heavy on {{ticker}} {{interval}}")
alertcondition(long_setup, "WOB ULTIMATE - Long Setup Confirmed", "Long setup confirmed on {{ticker}} {{interval}}")
alertcondition(short_setup, "WOB ULTIMATE - Short Setup Confirmed", "Short setup confirmed on {{ticker}} {{interval}}")
alertcondition(bid_absorption, "WOB ULTIMATE - Bid Absorption", "Bid absorption detected on {{ticker}} {{interval}}")
alertcondition(ask_absorption, "WOB ULTIMATE - Ask Absorption", "Ask absorption detected on {{ticker}} {{interval}}")
alertcondition(bullish_sweep, "WOB ULTIMATE - Bullish Sweep", "Bullish liquidity sweep detected on {{ticker}} {{interval}}")
alertcondition(bearish_sweep, "WOB ULTIMATE - Bearish Sweep", "Bearish liquidity sweep detected on {{ticker}} {{interval}}")
alertcondition(long_invalidated or short_invalidated, "WOB ULTIMATE - Setup Invalidated", "WOB setup invalidated on {{ticker}} {{interval}}")
````
