# EDGE GLI Global Liquidity and Market Rotation

- url: https://www.tradingview.com/script/118gnzkd-EDGE-GLI-Global-Liquidity-and-Market-Rotation/
- type: indicator
- pine_id: PUB;e367bf0204594ec382dafde82a210035
- version: 2.0

## Description

EDGE GLI — Global Liquidity & Market Rotation

EDGE GLI is a macro-liquidity and market-rotation indicator designed to answer two practical questions:

1. Is global liquidity becoming more supportive or less supportive for risk assets?
2. Where is capital currently being favored — equities, bonds, growth, semiconductors, or the broader market?

The indicator intentionally separates the slow macro-liquidity layer from the faster market-rotation layer.

This is useful because markets can continue rising even while liquidity is weakening, or semiconductors can continue outperforming even when overall market breadth is deteriorating.

--------------------------------------------------
GLOBAL LIQUIDITY — WEEKLY
--------------------------------------------------

The macro portion of EDGE GLI uses four liquidity inputs:

Fed = Federal Reserve balance sheet
ECB = European Central Bank balance sheet
BOJ = Bank of Japan balance sheet
M2 = U.S. Money Supply M2

ECB and BOJ data are adjusted through the relevant FX rates.

By default, EDGE GLI measures the percentage change in each component over approximately 4 weeks and averages the enabled components into the Global Liquidity Indicator.

Example:

GLI +0.40%
= Average liquidity impulse is approximately 0.40% higher than 4 weeks ago.

GLI -0.40%
= Average liquidity impulse is approximately 0.40% lower than 4 weeks ago.

The 0% line is an important reference point, but direction and acceleration matter as much as whether GLI is positive or negative.

--------------------------------------------------
LIQUIDITY REGIME
--------------------------------------------------

EXPANDING ↑
Liquidity impulse is positive and the faster GLI trend is above the slower trend.

CONTRACTING ↓
Liquidity impulse is negative and the faster GLI trend is below the slower trend.

IMPROVING ↗
Liquidity is not yet fully expanding, but the impulse is positive.

WEAKENING ↘
Liquidity is not yet fully confirmed as contracting, but the impulse is negative.

--------------------------------------------------
ACCELERATION
--------------------------------------------------

Liquidity level and liquidity acceleration are different.

Example:

LIQUIDITY: EXPANDING ↑
ACCELERATION: WEAKENING ↓

This means liquidity is still expanding, but it is expanding more slowly than before.

Think of it as:
The car is still moving forward, but the driver is easing off the accelerator.

--------------------------------------------------
MARKET ROTATION — DAILY
--------------------------------------------------

The rotation portion of EDGE GLI runs on daily data by default.

Each ratio uses:

EMA = Exponential Moving Average
ROC = Rate of Change

Default rotation logic:

IN / Risk-On
Ratio > EMA20 and ROC14 > 0

OUT / Risk-Off
Ratio < EMA20 and ROC14 < 0

NEUTRAL
Signals are mixed.

These ratios measure relative performance and rotation.
They do not measure literal dollar fund flows.

--------------------------------------------------
DASHBOARD CHEAT SHEET
--------------------------------------------------

HYG / IEF = Credit Risk Appetite

HYG = iShares iBoxx $ High Yield Corporate Bond ETF
IEF = iShares 7–10 Year Treasury Bond ETF

RISK-ON ↑
High-yield bonds are outperforming Treasuries.
Investors are showing greater willingness to take credit risk.

RISK-OFF ↓
Treasuries are outperforming high-yield bonds.
Investors are becoming more defensive.

--------------------------------------------------

SPY / IEF = Stocks vs Treasuries

SPY = SPDR S&P 500 ETF Trust
IEF = iShares 7–10 Year Treasury Bond ETF

EQUITIES ↑
Stocks are outperforming Treasuries.

TREASURIES ↑
Treasuries are outperforming stocks.

--------------------------------------------------

SPY / AGG = Stocks vs Broad Bonds

AGG = iShares Core U.S. Aggregate Bond ETF

EQUITIES ↑
Stocks are outperforming broad bonds.

BONDS ↑
Broad bonds are outperforming equities.

--------------------------------------------------

QQQ / SPY = Growth Rotation

QQQ = Invesco QQQ Trust

IN ↑
Growth and technology-heavy stocks are outperforming the broader market.

OUT ↓
Growth is losing relative strength.

--------------------------------------------------

SMH / QQQ = Semiconductor Rotation

SMH = VanEck Semiconductor ETF

IN ↑
Semiconductors are outperforming QQQ.

OUT ↓
Semiconductors are losing relative strength versus growth.

This is one of the most important signals for traders focused

--------------------------------------------------
IWM / SPY = Market Breadth
--------------------------------------------------

IWM = iShares Russell 2000 ETF
SPY = SPDR S&P 500 ETF Trust

IN ↑
Small-cap stocks are participating and the market advance is becoming broader.

OUT ↓
Small caps are lagging the broader market.

When IWM / SPY is OUT while QQQ / SPY and SMH / QQQ are IN, leadership is concentrated in fewer areas of the market.

EDGE GLI describes this as:

NARROW

A narrow market can still rise, but it is generally less broadly supported than one where small caps and the wider market are also participating.

--------------------------------------------------
HOW TO READ THE FINAL MESSAGE
--------------------------------------------------

The READ line combines the major layers into one plain-English summary.

Example:

LIQUIDITY EXPANDING ↑
CAPITAL → EQUITIES
MONEY → GROWTH → SEMIS
NARROW

This means:

- Global liquidity is still supportive.
- Equities are outperforming Treasuries and bonds.
- Growth is outperforming the broader stock market.
- Semiconductors are outperforming growth.
- Small caps are lagging, so participation is narrow.

Another example:

LIQUIDITY WEAKENING ↘
CAPITAL → BONDS / TREASURIES
MONEY → DEFENSIVE
NARROW

This means:

- Macro liquidity is becoming less supportive.
- Bonds and Treasuries are outperforming equities.
- Risk appetite is weakening.
- Market participation is narrow.

--------------------------------------------------
IMPORTANT DIVERGENCES TO WATCH
--------------------------------------------------

One of the main purposes of EDGE GLI is to identify situations where different layers disagree.

These divergences can be more useful than looking at price alone.

--------------------------------------------------
EXAMPLE 1:
SEMIS STRONG, LIQUIDITY WEAKENING
--------------------------------------------------

GLI = negative or weakening
QQQ / SPY = IN
SMH / QQQ = IN

Interpretation:

Growth and semiconductors are still leading, but they are doing so while the macro liquidity backdrop is becoming less supportive.

This does not mean semiconductors must immediately fall.

It means leadership is still intact, but the environment is becoming more fragile.

--------------------------------------------------
EXAMPLE 2:
SEMIS STRONG, BUT TREASURIES START WINNING
--------------------------------------------------

SMH / QQQ = IN
SPY / IEF = TREASURIES ↑

Interpretation:

Semiconductors may still be outperforming within equities, while Treasuries are beginning to outperform stocks overall.

This can be an early warning that investors are becoming more defensive even though semiconductor leadership has not yet broken.

--------------------------------------------------
EXAMPLE 3:
STRONG RISK-ON ENVIRONMENT
--------------------------------------------------

A broadly supportive configuration could look like:

LIQUIDITY = EXPANDING ↑
ACCELERATION = IMPROVING ↑
HYG / IEF = RISK-ON ↑
SPY / IEF = EQUITIES ↑
SPY / AGG = EQUITIES ↑
QQQ / SPY = IN ↑
SMH / QQQ = IN ↑
IWM / SPY = IN ↑

Interpretation:

- Liquidity is supportive.
- Liquidity momentum is improving.
- Credit markets are risk-on.
- Stocks are outperforming Treasuries.
- Stocks are outperforming broad bonds.
- Growth is leading.
- Semiconductors are leading growth.
- Small caps are also participating.

This is a much broader and healthier risk-on configuration.

--------------------------------------------------
EXAMPLE 4:
RISK-OFF ENVIRONMENT
--------------------------------------------------

A more defensive configuration could look like:

LIQUIDITY = CONTRACTING ↓
ACCELERATION = WEAKENING ↓
HYG / IEF = RISK-OFF ↓
SPY / IEF = TREASURIES ↑
SPY / AGG = BONDS ↑
QQQ / SPY = OUT ↓
SMH / QQQ = OUT ↓
IWM / SPY = OUT ↓

Interpretation:

- Liquidity is deteriorating.
- Credit markets are becoming defensive.
- Treasuries and bonds are outperforming stocks.
- Growth is losing leadership.
- Semiconductors are losing leadership.
- Market breadth is weak.

This represents a much more defensive market regime.

--------------------------------------------------
TIMEFRAMES
--------------------------------------------------

EDGE GLI intentionally uses two different speeds.

WEEKLY:
Used for the macro-liquidity layer.

This includes:

Fed
ECB
BOJ
M2
GLI
Liquidity regime
Liquidity acceleration

If TradingView shows:

EDGE GLI W

the W means Weekly.

DAILY:
Used for the market-rotation layer.

This includes:

HYG / IEF
SPY / IEF
SPY / AGG
QQQ / SPY
SMH / QQQ
IWM / SPY

The idea is simple:

Macro liquidity changes relatively slowly.
Market rotation can change much faster.

Using weekly macro data and daily rotation data allows EDGE GLI to monitor both.

--------------------------------------------------
DEFAULT SETTINGS
--------------------------------------------------

Liquidity timeframe:
Weekly

Liquidity impulse lookback:
4 periods

Fast GLI EMA:
4

Slow GLI EMA:
13

Acceleration smoothing:
2

Rotation timeframe:
Daily

Ratio EMA:
20

Ratio ROC:
14

The default settings are intentionally simple and are not heavily optimized.

The goal is to create a readable market-regime framework rather than an overfit trading system.

--------------------------------------------------
ABBREVIATION GUIDE
--------------------------------------------------

GLI = Global Liquidity Indicator

Fed = Federal Reserve

ECB = European Central Bank

BOJ = Bank of Japan

M2 = Money Supply M2

HYG = iShares iBoxx $ High Yield Corporate Bond ETF

IEF = iShares 7–10 Year Treasury Bond ETF

SPY = SPDR S&P 500 ETF Trust

AGG = iShares Core U.S. Aggregate Bond ETF

QQQ = Invesco QQQ Trust

SMH = VanEck Semiconductor ETF

IWM = iShares Russell 2000 ETF

ROC = Rate of Change

EMA = Exponential Moving Average

--------------------------------------------------
IMPORTANT LIMITATIONS
--------------------------------------------------

EDGE GLI does not measure literal dollar fund flows.

For example:

If SPY / IEF favors Treasuries, it means Treasuries are outperforming stocks.

It does NOT prove that a specific dollar amount moved directly from stocks into Treasuries.

Similarly:

NARROW does not necessarily mean retail or institutional investors have completely stopped participating.

It means market leadership is concentrated rather than broadly distributed.

Macro data also updates at different frequencies.

Some central-bank data updates weekly, while other series such as M2 or BOJ data may update more slowly.

Because of this, the GLI line can sometimes appear stair-stepped.

--------------------------------------------------
HOW TO USE EDGE GLI
--------------------------------------------------

EDGE GLI is best used as a market-regime and rotation framework.

It is not designed to be a stand-alone buy or sell signal.

The indicator is designed to help answer:

Is liquidity becoming more supportive or less supportive?

Are investors favoring risk or safety?

Are stocks outperforming bonds and Treasuries?

Is growth leading?

Are semiconductors leading growth?

Is the market advance broad or narrow?

The most useful information often comes from the relationship between these signals rather than from any single reading.

The core idea is:

LIQUIDITY
↓
ASSET ALLOCATION
↓
RISK APPETITE
↓
GROWTH
↓
SEMICONDUCTORS
↓
BREADTH

EDGE GLI helps visualize that chain in one place. 

--------------------------------------------------
EDUCATIONAL USE ONLY
--------------------------------------------------

This indicator is provided for educational and informational purposes only.

It is not financial, investment, tax, or trading advice and should not be relied upon as a recommendation to buy, sell, or hold any security or financial instrument.

EDGE GLI is intended only as a framework for studying global liquidity, market rotation, relative strength, risk appetite, and market breadth.

All trading and investment decisions remain the responsibility of the individual user.

## Source Code

````pine
//@version=6
indicator(
     "EDGE GLI — Global Liquidity + Market Rotation",
     shorttitle="EDGE GLI",
     overlay=false,
     dynamic_requests=true
)

//=============================================================================
// INPUTS — GLOBAL LIQUIDITY
//=============================================================================

groupGLI = "1 — Global Liquidity"

liqTF = input.timeframe("W", "Liquidity timeframe", group=groupGLI)

useFed = input.bool(true, "Federal Reserve Balance Sheet", group=groupGLI)
useECB = input.bool(true, "ECB Balance Sheet", group=groupGLI)
useBOJ = input.bool(true, "BOJ Balance Sheet", group=groupGLI)
useM2  = input.bool(true, "U.S. M2", group=groupGLI)

liqImpulseLen = input.int(
     4,
     "Liquidity impulse lookback",
     minval=1,
     group=groupGLI,
     tooltip="Number of periods on the selected liquidity timeframe used to measure the change in each liquidity component. Lower values react faster; higher values produce a smoother, slower signal."
)
liqFastLen    = input.int(4, "Fast GLI EMA", minval=1, group=groupGLI)
liqSlowLen    = input.int(13, "Slow GLI EMA", minval=2, group=groupGLI)

accelSmooth = input.int(2, "Acceleration smoothing", minval=1, group=groupGLI)
accelBand   = input.float(0.02, "Acceleration neutral band", minval=0.0, step=0.01, group=groupGLI)


//=============================================================================
// INPUTS — ROTATION
//=============================================================================

groupROT = "2 — Rotation + Asset Allocation"

rotTF = input.timeframe("D", "Rotation timeframe", group=groupROT)

rotEmaLen = input.int(20, "Ratio EMA", minval=1, group=groupROT)
rotRocLen = input.int(14, "Ratio ROC", minval=1, group=groupROT)


//=============================================================================
// INPUTS — DISPLAY
//=============================================================================

groupDISPLAY = "3 — Display"

showBackground = input.bool(true, "Shade liquidity regime", group=groupDISPLAY)
showGLIPlot    = input.bool(true, "Plot GLI impulse", group=groupDISPLAY)

showGuide = input.bool(
     true,
     "Show GLI Cheat Sheet",
     group=groupDISPLAY
)

dashTextChoice = input.string(
     "Small",
     "Dashboard text size",
     options=["Tiny", "Small", "Normal"],
     group=groupDISPLAY
)

guideTextChoice = input.string(
     "Tiny",
     "Cheat sheet text size",
     options=["Tiny", "Small"],
     group=groupDISPLAY
)

dashTextSize =
     dashTextChoice == "Tiny" ? size.tiny :
     dashTextChoice == "Small" ? size.small :
     size.normal

guideTextSize =
     guideTextChoice == "Small" ? size.small :
     size.tiny


//=============================================================================
// COLORS
//=============================================================================

colorIn      = color.rgb(0, 190, 120)
colorOut     = color.rgb(225, 70, 70)
colorNeutral = color.rgb(225, 170, 45)

colorPanel   = color.rgb(22, 24, 29)
colorHeader  = color.rgb(38, 42, 50)
colorGuide   = color.rgb(17, 20, 25)

colorWhite = color.white
colorGray  = color.rgb(170, 175, 185)


//=============================================================================
// GLOBAL LIQUIDITY ENGINE
//=============================================================================

f_macro_pack() =>

    usCB = request.economic(
         "US",
         "CBBS",
         gaps=barmerge.gaps_off,
         ignore_invalid_symbol=true
    )

    euCB = request.economic(
         "EU",
         "CBBS",
         gaps=barmerge.gaps_off,
         ignore_invalid_symbol=true
    )

    jpCB = request.economic(
         "JP",
         "CBBS",
         gaps=barmerge.gaps_off,
         ignore_invalid_symbol=true
    )

    usM2 = request.economic(
         "US",
         "M2",
         gaps=barmerge.gaps_off,
         ignore_invalid_symbol=true
    )

    eurusd = request.security(
         "FX_IDC:EURUSD",
         "",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
    )

    usdjpy = request.security(
         "FX_IDC:USDJPY",
         "",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
    )

    fedUSD = usCB
    ecbUSD = euCB * eurusd
    bojUSD = jpCB / usdjpy
    m2USD  = usM2

    fedImpulse = ta.roc(fedUSD, liqImpulseLen)
    ecbImpulse = ta.roc(ecbUSD, liqImpulseLen)
    bojImpulse = ta.roc(bojUSD, liqImpulseLen)
    m2Impulse  = ta.roc(m2USD, liqImpulseLen)

    fedValue = useFed and not na(fedImpulse) ? fedImpulse : 0.0
    ecbValue = useECB and not na(ecbImpulse) ? ecbImpulse : 0.0
    bojValue = useBOJ and not na(bojImpulse) ? bojImpulse : 0.0
    m2Value  = useM2 and not na(m2Impulse) ? m2Impulse : 0.0

    fedCount = useFed and not na(fedImpulse) ? 1.0 : 0.0
    ecbCount = useECB and not na(ecbImpulse) ? 1.0 : 0.0
    bojCount = useBOJ and not na(bojImpulse) ? 1.0 : 0.0
    m2Count  = useM2 and not na(m2Impulse) ? 1.0 : 0.0

    componentCount =
         fedCount +
         ecbCount +
         bojCount +
         m2Count

    gli =
         componentCount > 0 ?
         (fedValue + ecbValue + bojValue + m2Value) / componentCount :
         na

    fast = ta.ema(gli, liqFastLen)
    slow = ta.ema(gli, liqSlowLen)

    accelerationRaw = ta.change(gli)

    acceleration =
         ta.ema(
              accelerationRaw,
              accelSmooth
         )

    [gli, fast, slow, acceleration]


//=============================================================================
// RUN LIQUIDITY ENGINE
//=============================================================================

[gliImpulse, gliFast, gliSlow, gliAcceleration] = request.security(
     syminfo.tickerid,
     liqTF,
     f_macro_pack(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)


//=============================================================================
// DATA STATUS
//=============================================================================

usCBNow = request.economic(
     "US",
     "CBBS",
     gaps=barmerge.gaps_off,
     ignore_invalid_symbol=true
)

euCBNow = request.economic(
     "EU",
     "CBBS",
     gaps=barmerge.gaps_off,
     ignore_invalid_symbol=true
)

jpCBNow = request.economic(
     "JP",
     "CBBS",
     gaps=barmerge.gaps_off,
     ignore_invalid_symbol=true
)

usM2Now = request.economic(
     "US",
     "M2",
     gaps=barmerge.gaps_off,
     ignore_invalid_symbol=true
)

eurusdNow = request.security(
     "FX_IDC:EURUSD",
     "",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

usdjpyNow = request.security(
     "FX_IDC:USDJPY",
     "",
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

fedOK =
     not useFed or
     not na(usCBNow)

ecbOK =
     not useECB or
     (not na(euCBNow) and not na(eurusdNow))

bojOK =
     not useBOJ or
     (not na(jpCBNow) and not na(usdjpyNow))

m2OK =
     not useM2 or
     not na(usM2Now)

gliDataOK =
     fedOK and
     ecbOK and
     bojOK and
     m2OK


fedStatus =
     not useFed ? "FED OFF" :
     fedOK ? "FED ✓" :
     "FED ✕"

ecbStatus =
     not useECB ? "ECB OFF" :
     ecbOK ? "ECB ✓" :
     "ECB ✕"

bojStatus =
     not useBOJ ? "BOJ OFF" :
     bojOK ? "BOJ ✓" :
     "BOJ ✕"

m2Status =
     not useM2 ? "M2 OFF" :
     m2OK ? "M2 ✓" :
     "M2 ✕"

dataStatus =
     fedStatus +
     " | " +
     ecbStatus +
     " | " +
     bojStatus +
     " | " +
     m2Status


//=============================================================================
// LIQUIDITY REGIME
//=============================================================================

liqState =
     gliImpulse > 0 and gliFast > gliSlow ? 1 :
     gliImpulse < 0 and gliFast < gliSlow ? -1 :
     0

accelState =
     gliAcceleration > accelBand ? 1 :
     gliAcceleration < -accelBand ? -1 :
     0


//=============================================================================
// RATIO ENGINE
//=============================================================================

f_ratio_pack(string denominator) =>

    denominatorClose = request.security(
         denominator,
         "",
         close,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         ignore_invalid_symbol=true
    )

    ratio =
         close /
         denominatorClose

    ratioEMA =
         ta.ema(
              ratio,
              rotEmaLen
         )

    ratioROC =
         ta.roc(
              ratio,
              rotRocLen
         )

    [ratio, ratioEMA, ratioROC]


//=============================================================================
// HYG / IEF — CREDIT RISK APPETITE
//=============================================================================

[riskRatio, riskEMA, riskROC] = request.security(
     "AMEX:HYG",
     rotTF,
     f_ratio_pack("NASDAQ:IEF"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

riskState =
     riskRatio > riskEMA and riskROC > 0 ? 1 :
     riskRatio < riskEMA and riskROC < 0 ? -1 :
     0


//=============================================================================
// SPY / IEF — STOCKS VS TREASURIES
//=============================================================================

[stockTreasRatio, stockTreasEMA, stockTreasROC] = request.security(
     "AMEX:SPY",
     rotTF,
     f_ratio_pack("NASDAQ:IEF"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

stockTreasState =
     stockTreasRatio > stockTreasEMA and stockTreasROC > 0 ? 1 :
     stockTreasRatio < stockTreasEMA and stockTreasROC < 0 ? -1 :
     0


//=============================================================================
// SPY / AGG — STOCKS VS BONDS
//=============================================================================

[stockBondRatio, stockBondEMA, stockBondROC] = request.security(
     "AMEX:SPY",
     rotTF,
     f_ratio_pack("AMEX:AGG"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

stockBondState =
     stockBondRatio > stockBondEMA and stockBondROC > 0 ? 1 :
     stockBondRatio < stockBondEMA and stockBondROC < 0 ? -1 :
     0


//=============================================================================
// QQQ / SPY — GROWTH
//=============================================================================

[growthRatio, growthEMA, growthROC] = request.security(
     "NASDAQ:QQQ",
     rotTF,
     f_ratio_pack("AMEX:SPY"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

growthState =
     growthRatio > growthEMA and growthROC > 0 ? 1 :
     growthRatio < growthEMA and growthROC < 0 ? -1 :
     0


//=============================================================================
// SMH / QQQ — SEMICONDUCTORS
//=============================================================================

[semiRatio, semiEMA, semiROC] = request.security(
     "NASDAQ:SMH",
     rotTF,
     f_ratio_pack("NASDAQ:QQQ"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

semiState =
     semiRatio > semiEMA and semiROC > 0 ? 1 :
     semiRatio < semiEMA and semiROC < 0 ? -1 :
     0


//=============================================================================
// IWM / SPY — BREADTH
//=============================================================================

[breadthRatio, breadthEMA, breadthROC] = request.security(
     "AMEX:IWM",
     rotTF,
     f_ratio_pack("AMEX:SPY"),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

breadthState =
     breadthRatio > breadthEMA and breadthROC > 0 ? 1 :
     breadthRatio < breadthEMA and breadthROC < 0 ? -1 :
     0


//=============================================================================
// WORDING
//=============================================================================

liqText =
     not gliDataOK ? "DATA INCOMPLETE" :
     liqState == 1 ? "EXPANDING ↑" :
     liqState == -1 ? "CONTRACTING ↓" :
     gliImpulse < 0 ? "WEAKENING ↘" :
     gliImpulse > 0 ? "IMPROVING ↗" :
     "FLAT →"

accelText =
     not gliDataOK ? "DATA INCOMPLETE" :
     accelState == 1 ? "IMPROVING ↑" :
     accelState == -1 ? "WEAKENING ↓" :
     "STEADY →"

riskText =
     riskState == 1 ? "RISK-ON ↑" :
     riskState == -1 ? "RISK-OFF ↓" :
     "NEUTRAL →"

stockTreasText =
     stockTreasState == 1 ? "EQUITIES ↑" :
     stockTreasState == -1 ? "TREASURIES ↑" :
     "NEUTRAL →"

stockBondText =
     stockBondState == 1 ? "EQUITIES ↑" :
     stockBondState == -1 ? "BONDS ↑" :
     "NEUTRAL →"

growthText =
     growthState == 1 ? "IN ↑" :
     growthState == -1 ? "OUT ↓" :
     "NEUTRAL →"

semiText =
     semiState == 1 ? "IN ↑" :
     semiState == -1 ? "OUT ↓" :
     "NEUTRAL →"

breadthText =
     breadthState == 1 ? "IN ↑" :
     breadthState == -1 ? "OUT ↓" :
     "NEUTRAL →"


//=============================================================================
// COLORS BY STATE
//=============================================================================

liqColor =
     liqState == 1 ? colorIn :
     liqState == -1 ? colorOut :
     colorNeutral

accelColor =
     accelState == 1 ? colorIn :
     accelState == -1 ? colorOut :
     colorNeutral

riskColor =
     riskState == 1 ? colorIn :
     riskState == -1 ? colorOut :
     colorNeutral

stockTreasColor =
     stockTreasState == 1 ? colorIn :
     stockTreasState == -1 ? colorOut :
     colorNeutral

stockBondColor =
     stockBondState == 1 ? colorIn :
     stockBondState == -1 ? colorOut :
     colorNeutral

growthColor =
     growthState == 1 ? colorIn :
     growthState == -1 ? colorOut :
     colorNeutral

semiColor =
     semiState == 1 ? colorIn :
     semiState == -1 ? colorOut :
     colorNeutral

breadthColor =
     breadthState == 1 ? colorIn :
     breadthState == -1 ? colorOut :
     colorNeutral


//=============================================================================
// CAPITAL ALLOCATION SUMMARY
//=============================================================================

capitalFlow =
     stockTreasState == 1 and stockBondState == 1 ?
         "CAPITAL → EQUITIES" :

     stockTreasState == -1 and stockBondState == -1 ?
         "CAPITAL → BONDS / TREASURIES" :

     stockTreasState == -1 ?
         "CAPITAL → TREASURIES" :

     stockBondState == -1 ?
         "CAPITAL → BONDS" :

     stockTreasState == 1 or stockBondState == 1 ?
         "CAPITAL → EQUITIES" :

         "CAPITAL → MIXED"


//=============================================================================
// EQUITY ROTATION SUMMARY
//=============================================================================

moneyFlow =
     growthState == 1 and semiState == 1 ?
         "MONEY → GROWTH → SEMIS" :

     semiState == 1 ?
         "MONEY → SEMIS" :

     growthState == 1 ?
         "MONEY → GROWTH" :

     riskState == -1 ?
         "MONEY → DEFENSIVE" :

     breadthState == 1 ?
         "MONEY → BROAD MARKET" :

         "MONEY → MIXED"

breadthQualifier =
     breadthState == 1 ?
         " | BROAD" :

     breadthState == -1 ?
         " | NARROW" :

         ""


//=============================================================================
// FINAL SUMMARY
//=============================================================================

liquiditySummary =
     not gliDataOK ?
         "LIQUIDITY ?" :

     liqState == 1 ?
         "LIQUIDITY EXPANDING ↑" :

     liqState == -1 ?
         "LIQUIDITY CONTRACTING ↓" :

     gliImpulse < 0 ?
         "LIQUIDITY WEAKENING ↘" :

     gliImpulse > 0 ?
         "LIQUIDITY IMPROVING ↗" :

         "LIQUIDITY FLAT →"

finalRead =
     liquiditySummary +
     " | " +
     capitalFlow +
     " | " +
     moneyFlow +
     breadthQualifier


//=============================================================================
// PLOT
//=============================================================================

plot(
     showGLIPlot ? gliImpulse : na,
     title="Global Liquidity Impulse",
     color=liqColor,
     linewidth=3
)

hline(
     0,
     "Neutral Liquidity",
     color=color.new(colorGray, 55),
     linestyle=hline.style_dashed
)

regimeBackground =
     not gliDataOK ?
         na :

     liqState == 1 ?
         color.new(colorIn, 91) :

     liqState == -1 ?
         color.new(colorOut, 91) :

         color.new(colorNeutral, 94)

bgcolor(
     showBackground ?
         regimeBackground :
         na
)


//=============================================================================
// ONE COMBINED TABLE
//
// LIVE DASHBOARD ON TOP
// CHEAT SHEET DIRECTLY UNDER IT
//=============================================================================

var table dash = table.new(
     position.top_right,
     2,
     32,
     border_width=1,
     border_color=color.rgb(65, 70, 80)
)

if barstate.islast

    //=========================================================================
    // LIVE DASHBOARD
    //=========================================================================

    table.cell(dash, 0, 0, "EDGE GLI",
         text_color=colorWhite,
         bgcolor=colorHeader,
         text_size=dashTextSize)

    table.cell(dash, 1, 0,
         gliDataOK ? "GLI " + str.tostring(gliImpulse, "#.00") + "%" : "PARTIAL DATA",
         text_color=gliDataOK ? colorWhite : colorNeutral,
         bgcolor=colorHeader,
         text_size=dashTextSize)


    table.cell(dash, 0, 1, "MACRO DATA",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 1, dataStatus,
         text_color=gliDataOK ? colorIn : colorNeutral,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 2, "LIQUIDITY",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 2, liqText,
         text_color=liqColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 3, "ACCELERATION",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 3, accelText,
         text_color=accelColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 4, "RISK  HYG / IEF",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 4, riskText,
         text_color=riskColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 5, "STOCKS / TREAS",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 5, stockTreasText,
         text_color=stockTreasColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 6, "STOCKS / BONDS",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 6, stockBondText,
         text_color=stockBondColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 7, "GROWTH  QQQ / SPY",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 7, growthText,
         text_color=growthColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 8, "SEMIS  SMH / QQQ",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 8, semiText,
         text_color=semiColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 9, "BREADTH  IWM / SPY",
         text_color=colorGray,
         bgcolor=colorPanel,
         text_size=dashTextSize)

    table.cell(dash, 1, 9, breadthText,
         text_color=breadthColor,
         bgcolor=colorPanel,
         text_size=dashTextSize)


    table.cell(dash, 0, 10, "READ",
         text_color=colorWhite,
         bgcolor=colorHeader,
         text_size=size.tiny)

    table.cell(dash, 1, 10, finalRead,
         text_color=liqColor,
         bgcolor=colorHeader,
         text_size=size.tiny)


    //=========================================================================
    // CHEAT SHEET
    //=========================================================================

    if showGuide

        table.cell(dash, 0, 11, "GLI CHEAT SHEET",
             text_color=colorWhite,
             bgcolor=colorHeader,
             text_size=guideTextSize)

        table.cell(dash, 1, 11, "FULL FORMS",
             text_color=colorGray,
             bgcolor=colorHeader,
             text_size=guideTextSize)


        table.cell(dash, 0, 12, "GLI",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 12, "Global Liquidity Indicator",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 13, "Fed",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 13, "Federal Reserve",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 14, "ECB / BOJ",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 14, "European Central Bank / Bank of Japan",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 15, "M2",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 15, "Money Supply M2",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 16, "HYG / IEF",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 16, "High Yield Corp Bond ETF / 7–10Y Treasury ETF",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 17, "SPY / AGG",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 17, "S&P 500 ETF / U.S. Aggregate Bond ETF",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 18, "QQQ / SMH",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 18, "Invesco QQQ / Semiconductor ETF",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 19, "IWM",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 19, "Russell 2000 ETF",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 20, "ROC / EMA",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 20, "Rate of Change / Exponential Moving Average",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        //=====================================================================
        // RATIO MEANINGS
        //=====================================================================

        table.cell(dash, 0, 21, "RATIO GUIDE",
             text_color=colorWhite,
             bgcolor=colorHeader,
             text_size=guideTextSize)

        table.cell(dash, 1, 21, "WHAT IT MEANS",
             text_color=colorGray,
             bgcolor=colorHeader,
             text_size=guideTextSize)


        table.cell(dash, 0, 22, "HYG / IEF",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 22, "Risky credit vs U.S. Treasuries",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 23, "SPY / IEF",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 23, "Stocks vs U.S. Treasuries",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 24, "SPY / AGG",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 24, "Stocks vs broad U.S. bonds",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 25, "QQQ / SPY",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 25, "Growth / technology vs broad stocks",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 26, "SMH / QQQ",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 26, "Semiconductors vs growth",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 27, "IWM / SPY",
             text_color=colorIn,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 27, "Small caps vs broad stocks",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        //=====================================================================
        // TIMEFRAME REMINDER
        //=====================================================================

        table.cell(dash, 0, 28, "TIMEFRAME",
             text_color=colorWhite,
             bgcolor=colorHeader,
             text_size=guideTextSize)

        table.cell(dash, 1, 28, "CALCULATION",
             text_color=colorGray,
             bgcolor=colorHeader,
             text_size=guideTextSize)


        table.cell(dash, 0, 29, "MACRO / GLI",
             text_color=colorNeutral,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 29, "Weekly",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


        table.cell(dash, 0, 30, "ROTATION",
             text_color=colorNeutral,
             bgcolor=colorGuide,
             text_size=guideTextSize)

        table.cell(dash, 1, 30, "Daily",
             text_color=colorWhite,
             bgcolor=colorGuide,
             text_size=guideTextSize)


    else

        table.clear(
             dash,
             0,
             11,
             1,
             31
        )


//=============================================================================
// ALERTS
//=============================================================================

alertcondition(
     liqState == 1 and liqState[1] != 1,
     title="GLI Liquidity Expanding",
     message="EDGE GLI: Global liquidity moved to EXPANDING."
)

alertcondition(
     liqState == -1 and liqState[1] != -1,
     title="GLI Liquidity Contracting",
     message="EDGE GLI: Global liquidity moved to CONTRACTING."
)

alertcondition(
     stockTreasState == -1 and stockTreasState[1] != -1,
     title="Treasuries Gaining vs Stocks",
     message="EDGE GLI: SPY/IEF moved in favor of Treasuries."
)

alertcondition(
     stockBondState == -1 and stockBondState[1] != -1,
     title="Bonds Gaining vs Stocks",
     message="EDGE GLI: SPY/AGG moved in favor of Bonds."
)

alertcondition(
     semiState == 1 and semiState[1] != 1,
     title="Semiconductor Rotation IN",
     message="EDGE GLI: Semiconductor rotation moved IN."
)

alertcondition(
     semiState == -1 and semiState[1] != -1,
     title="Semiconductor Rotation OUT",
     message="EDGE GLI: Semiconductor rotation moved OUT."
)
````
