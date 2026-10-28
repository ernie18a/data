# Volatility Targeting: Single Asset [BackQuant]

- url: https://www.tradingview.com/script/qLoyrr8s-Volatility-Targeting-Single-Asset-BackQuant/
- type: indicator
- pine_id: PUB;471c6b9f09e94784b77428662401e2c2
- version: 1.0

## Description

[b]Volatility Targeting: Single Asset [BackQuant][/b]
[i]An educational example that demonstrates how volatility targeting can scale exposure up or down on one symbol, then applies a simple EMA cross for long or short direction and a higher timeframe style regime filter to gate risk. It builds a synthetic equity curve and compares it to buy and hold and a benchmark.[/i]

[b]Important disclaimer[/b]
This script is a [b]concept and education example only[/b]. It is [b]not[/b] a complete trading system and it is [b]not[/b] meant for live execution. It does not model many real world constraints, and its equity curve is only a simplified simulation. If you want to trade any idea like this, you need a proper [b]strategy()[/b] implementation, realistic execution assumptions, and robust backtesting with out of sample validation.

[b]Single asset vs the full portfolio concept[/b]
This indicator is the single asset, long short version of the broader volatility targeted momentum portfolio concept. The original multi asset concept and full portfolio implementation is here:
https://www.tradingview.com/script/HdwxExCw-Volatility-Targeted-Momentum-Portfolio-BackQuant/

That portfolio script is about allocating across multiple assets with a portfolio view. This script is intentionally simpler and focuses on one symbol so you can clearly see how volatility targeting behaves, how the scaling interacts with trend direction, and what an equity curve comparison looks like.

[b]What this indicator is trying to demonstrate[/b]
Volatility targeting is a risk scaling framework. The core idea is simple:
[list]
[*]If realized volatility is low relative to a target, you can scale position size up so the strategy behaves like it has a stable risk budget.
[*]If realized volatility is high relative to a target, you scale down to avoid getting blown around by the market.
[/list]

Instead of always being 1x long or 1x short, exposure becomes dynamic. This is often used in risk parity style systems, trend following overlays, and volatility controlled products.

This script combines that risk scaling with a simple trend direction model:
[list]
[*]Fast and slow EMA cross determines whether the strategy is long or short.
[*]A second, longer EMA cross acts as a regime filter that decides whether the system is ACTIVE or effectively in CASH.
[*]An equity curve is built from the scaled returns so you can visualize how the framework behaves across regimes.
[/list]

[b]How the logic works step by step[/b]

[b]1) Returns and simple momentum[/b]
The script uses log returns for the base return stream:
[list]
[*][i]ret = log(price / price[1])[/i]
[/list]

It also computes a simple momentum value:
[list]
[*][i]mom = price / price[lookback] - 1[/i]
[/list]

In this version, momentum is mainly informational since the directional signal is the EMA cross. The lookback input is shared with volatility estimation to keep the concept compact.

[b]2) Realized volatility estimation[/b]
Realized volatility is estimated as the standard deviation of returns over the lookback window, then annualized:
[list]
[*][i]vol = stdev(ret, lookback) * sqrt(tradingdays)[/i]
[/list]

The [i]Trading Days/Year[/i] input controls annualization:
[list]
[*]252 is typical for traditional markets.
[*]365 is typical for crypto since it trades daily.
[/list]

[b]3) Volatility targeting multiplier[/b]
Once realized vol is estimated, the script computes a scaling factor that tries to push realized volatility toward the target:
[list]
[*][i]volMult = targetVol / vol[/i]
[/list]

This is then clamped into a reasonable range:
[list]
[*]Minimum 0.1 so exposure never goes to zero just because vol spikes.
[*]Maximum 5.0 so exposure is not allowed to lever infinitely during ultra low volatility periods.
[/list]

This clamp is one of the most important “sanity rails” in any volatility targeted system. Without it, very low volatility regimes can create unrealistic leverage.

[b]4) Scaled return stream[/b]
The per bar return used for the equity curve is the raw return multiplied by the volatility multiplier:
[list]
[*][i]sr = ret * volMult[/i]
[/list]

Think of this as the return you would have earned if you scaled exposure to match the volatility budget.

[b]5) Long short direction via EMA cross[/b]
Direction is determined by a fast and slow EMA cross on price:
[list]
[*]If fast EMA is above slow EMA, direction is long.
[*]If fast EMA is below slow EMA, direction is short.
[/list]

This produces [i]dir[/i] as either +1 or -1. The scaled return stream is then signed by direction:
[list]
[*][i]avgRet = dir * sr[/i]
[/list]

So the strategy return is volatility targeted and directionally flipped depending on trend.

[b]6) Regime filter: ACTIVE vs CASH[/b]
A second EMA pair acts as a top level regime filter:
[list]
[*]If fast regime EMA is above slow regime EMA, the system is ACTIVE.
[*]If fast regime EMA is below slow regime EMA, the system is considered CASH, meaning it does not compound equity.
[/list]

This is designed to reduce participation in long bear phases or low quality environments, depending on how you set the regime lengths. By default it is a classic 50 and 200 EMA cross structure.

Important detail, the script applies [i]regime_filter[1][/i] when compounding equity, meaning it uses the prior bar regime state to avoid ambiguous same bar updates.

[b]7) Equity curve construction[/b]
The script builds a synthetic equity curve starting from [i]Initial Capital[/i] after [i]Start Date[/i]. Each bar:
[list]
[*]If regime was ACTIVE on the previous bar, equity compounds by (1 + netRet).
[*]If regime was CASH, equity stays flat.
[/list]

Fees are modeled very simply as a per bar penalty on returns:
[list]
[*][i]netRet = avgRet - (fee_rate * avgRet)[/i]
[/list]

This is not realistic execution modeling, it is just a simple turnover penalty knob to show how friction can reduce compounded performance. Real backtesting should model trade based costs, spreads, funding, and slippage.

[b]Benchmark and buy and hold comparison[/b]
The script pulls a benchmark symbol via [i]request.security[/i] and builds a buy and hold equity curve starting from the same date and initial capital. The buy and hold curve is based on benchmark price appreciation, not the strategy’s asset price, so you can compare:
[list]
[*]Strategy equity on the chart symbol.
[*]Buy and hold equity for the selected benchmark instrument.
[/list]

By default the benchmark is TVC:SPX, but you can set it to anything, for crypto you might set it to BTC, or a sector index, or a dominance proxy depending on your study.

[b]What it plots[/b]
If enabled, the indicator plots:
[list]
[*][i]Strategy Equity[/i] as a line, colored by recent direction of equity change, using [i]Positive Equity Color[/i] and [i]Negative Equity Color[/i].
[*][i]Buy and Hold Equity[/i] for the chosen benchmark as a line.
[*]Optional labels that tag each curve on the right side of the chart.
[/list]

This makes it easy to visually see when volatility targeting and regime gating change the shape of the equity curve relative to a simple passive hold.

[b]Metrics table explained[/b]
If [i]Show Metrics Table[/i] is enabled, a table is built and populated with common performance statistics based on the simulated daily returns of the strategy equity curve after the start date. These include:

[list]
[*][i]Net Profit (%)[/i] total return relative to initial capital.
[*][i]Max DD (%)[/i] maximum drawdown computed from equity peaks, stored over time.
[*][i]Win Rate[/i] percent of positive return bars.
[*][i]Annual Mean Returns (% p/y)[/i] mean daily return annualized.
[*][i]Annual Stdev Returns (% p/y)[/i] volatility of daily returns annualized.
[*][i]Variance[/i] of annualized returns.
[*][i]Sortino Ratio[/i] annualized return divided by downside deviation, using negative return stdev.
[*][i]Sharpe Ratio[/i] risk adjusted return using the risk free rate input.
[*][i]Omega Ratio[/i] positive return sum divided by negative return sum.
[*][i]Gain to Pain[/i] total return sum divided by absolute loss sum.
[*][i]CAGR (% p/y)[/i] compounded annual growth rate based on time since start date.
[*][i]Portfolio Alpha (% p/y)[/i] alpha versus benchmark using beta and the benchmark mean.
[*][i]Portfolio Beta[/i] covariance of strategy returns with benchmark returns divided by benchmark variance.
[*][i]Skewness of Returns[/i] actually the script computes a conditional value based on the lower 5 percent tail of returns, so it behaves more like a simple CVaR style tail loss estimate than classic skewness.
[/list]

Important note, these are calculated from the synthetic equity stream in an indicator context. They are useful for concept exploration, but they are not a substitute for professional backtesting where trade timing, fills, funding, and leverage constraints are accurately represented.

[b]How to interpret the system conceptually[/b]

[b]Vol targeting effect[/b]
When volatility rises, [i]volMult[/i] falls, so the strategy de risks and the equity curve typically becomes smoother. When volatility compresses, [i]volMult[/i] rises, so the system takes more exposure and tries to maintain a stable risk budget.

This is why volatility targeting is often used as a “risk equalizer”, it can reduce the “biggest drawdowns happen only because vol expanded” problem, at the cost of potentially under participating in explosive upside if volatility rises during a trend.

[b]Long short directional effect[/b]
Because direction is an EMA cross:
[list]
[*]In strong trends, the direction stays stable and the scaled return stream compounds in that trend direction.
[*]In choppy ranges, the EMA cross can flip and create whipsaws, which is where fees and regime filtering matter most.
[/list]

[b]Regime filter effect[/b]
The 50 and 200 style filter tries to:
[list]
[*]Keep the system active in sustained up regimes.
[*]Reduce exposure during long down regimes or extended weakness.
[/list]

It will always be late at turning points, by design. It is a slow filter meant to reduce deep participation, not to catch bottoms.

[b]Common applications[/b]
This script is mainly for understanding and research, but conceptually, volatility targeting overlays are used for:
[list]
[*][i]Risk budgeting[/i] normalize risk so your exposure is not accidentally huge in high vol regimes.
[*][i]System comparison[/i] see how a simple trend model behaves with and without vol scaling.
[*][i]Parameter exploration[/i] test how target volatility, lookback length, and regime lengths change the shape of equity and drawdowns.
[*][i]Framework building[/i] as a reference blueprint before implementing a proper strategy() version with trade based execution logic.
[/list]

[b]Tuning guidance[/b]
[list]
[*][i]Lookback[/i] lower values react faster to vol shifts but can create unstable scaling, higher values smooth scaling but react slower to regime changes.
[*][i]Target volatility[/i] higher targets increase exposure and drawdown potential, lower targets reduce exposure and usually lower drawdowns, but can under perform in strong trends.
[*][i]Signal EMAs[/i] tighter EMAs increase trade frequency, wider EMAs reduce churn but react slower.
[*][i]Regime EMAs[/i] slower regime filters reduce false toggles but will miss early trend transitions.
[*][i]Fees[/i] if you crank this up you will see how sensitive higher turnover parameter sets are to friction.
[/list]

[b]Final note[/b]
This is a compact educational demonstration of a volatility targeted, long short single asset framework with a regime gate and a synthetic equity curve. If you want a production ready implementation, the correct next step is to convert this concept into a strategy() script, add realistic execution and cost modeling, test across multiple timeframes and market regimes, and validate out of sample before making any decision based on the results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant
// Original multi-asset concept, this was made for people to understand the concept better:
// https://www.tradingview.com/script/HdwxExCw-Volatility-Targeted-Momentum-Portfolio-BackQuant/

// This version shows volatility targeting on a single asset:
// 1) Estimate realized volatility over a lookback window
// 2) Scale position size so realized vol moves toward a chosen annualized target
// 3) Use a fast/slow EMA cross for long/short direction
// 4) Use a long-term EMA cross as a regime filter (ACTIVE vs CASH)
// 5) Build an equity curve and compare it to benchmark buy & hold

//@version=6
indicator("Volatility Targeting: Single Asset [BackQuant]", overlay=false)

// Groups
const string disclaimer  = "Concept example only. This is not a complete trading system and is not meant for live execution. For real trading, use proper strategy() scripts and robust testing."
const string settings    = "Strategy Settings"
const string backtesting = "Backtesting and Metrics"
const string pv          = "Plotting"

// Strategy settings
disclaimer_ = input.string("", "Please read the tooltip", tooltip=disclaimer)

int initial_cap   = input.int(10000, "Initial Capital ($)", group=settings, tooltip="Starting portfolio value used to build the synthetic equity curve.")
int tradingdays   = input.int(365, "Trading Days/Year", options=[252, 365], group=settings, tooltip="Used to annualize volatility and returns.\n252 for traditional markets, 365 for crypto.")
int lookback      = input.int(25, "Momentum & Vol Lookback", group=settings, tooltip="Bars used for realized volatility and simple momentum.\nShorter = more reactive, longer = smoother.")

// Signal EMA lengths (direction long/short)
int fast_len      = input.int(12, "Fast EMA (Signal)", group=settings, tooltip="Short-term EMA used for long/short direction.\nPrice above fast > slow → long, below → short.")
int slow_len      = input.int(21, "Slow EMA (Signal)", group=settings, tooltip="Longer EMA used for long/short direction.\nWider gap between fast/slow = stronger trend.")

// Regime EMA lengths (ACTIVE vs CASH)
int fast_reg_len  = input.int(50, "Fast EMA (Regime)", group=settings, tooltip="Medium-term EMA for regime filter.\nAbove slow regime EMA = ACTIVE regime.")
int slow_reg_len  = input.int(200, "Slow EMA (Regime)", group=settings, tooltip="Long-term EMA for regime filter.\nBelow this from the fast regime EMA = CASH regime.")

// Volatility target (annualized)
float targetVol   = input.float(50, "Target Volatility (%)", group=settings, tooltip="Annualized volatility target.\nThe script scales position size so realized volatility moves toward this level.\nHigher = more aggressive, lower = more conservative.") / 100

// Fees
float fee_rate    = input.float(0.001, "Transaction Fees", group=settings, tooltip="Per-bar fee applied to the scaled return.\n0.001 = 0.1% per bar. This penalizes turnover in the equity curve.", step=0.001)

// Backtest settings
int   startDate   = input.time(timestamp("1 Jan 2018"), "Start Date", group=backtesting, tooltip="Equity and metrics start from this date.")
float rfr         = input.float(5.0, "Risk-Free Rate (%)", group=backtesting, tooltip="Annual risk-free rate for Sharpe and alpha.") / 100
string bench      = input.symbol("TVC:SPX", "Benchmark", group=backtesting, tooltip="Symbol used for buy-and-hold comparison and benchmark statistics.")

// Plotting and metrics toggles
bool show_eq      = input.bool(true, "Show Strategy Equity", group=pv)
bool show_bh      = input.bool(true, "Show Buy & Hold", group=pv)
bool show_lbls    = input.bool(true, "Show Curve Labels", group=pv)
bool show_metrics = input.bool(true, "Show Metrics Table", group=backtesting)

// Equity color controls
color pos_col     = input.color(#00ff00, "Positive Equity Color", group=pv, tooltip="Color for the equity line when recent equity change is positive.")
color neg_col     = input.color(#ff0000, "Negative Equity Color", group=pv, tooltip="Color for the equity line when recent equity change is negative.")

// Core single-asset volatility targeting and signal logic

price = close
ret   = math.log(price / price[1])
mom   = price / price[lookback] - 1.0

vol      = ta.stdev(ret, lookback) * math.sqrt(tradingdays)
volMult  = math.min(math.max(targetVol / vol, 0.1), 5.0)
sr       = ret * volMult

// Signal EMAs (direction)
fast     = ta.ema(price, fast_len)
slow     = ta.ema(price, slow_len)
dir      = fast > slow ? 1.0 : -1.0

float avgRet = dir * sr

// Regime EMAs (ACTIVE vs CASH)
fast_regime = ta.ema(price, fast_reg_len)
slow_regime = ta.ema(price, slow_reg_len)
var bool regime_filter = true

if fast_regime > slow_regime
    regime_filter := true
else
    regime_filter := false

// Equity curve
var float equity = na

if time >= startDate
    if na(equity)
        equity := initial_cap
    else
        if regime_filter[1]
            float netRet = avgRet - (fee_rate * avgRet)
            equity := equity * (1 + netRet)
        else
            equity := equity

// Benchmark buy & hold

[benchmark, bhseries] = request.security(bench, "", [close / close[1] - 1, close])

bh_eq(float p, int start, int capital) =>
    var float eq = na
    if year(time) == year(start) and month(time) == month(start) and dayofmonth(time) == dayofmonth(start)
        eq := capital
    else if na(eq[1])
        eq := capital
    else if time >= start
        eq := eq[1] * p / p[1]
    eq

bh_benchmark = bh_eq(bhseries, startDate, initial_cap)

// Metrics plumbing

var float peakEq = na
var float mdd    = 0.0
var float dd     = 0.0

var r          = array.new<float>()
var rb         = array.new<float>()
var pos_ret    = array.new<float>()
var neg_ret    = array.new<float>()
var sorted_ret = array.new<float>()
var dds        = array.new<float>()
var cVaR       = 0.0

if barstate.isconfirmed and time >= startDate
    peakEq := na(peakEq) ? equity : math.max(peakEq, equity)
    dd := (equity - peakEq) / peakEq * 100

    array.push(dds, dd)
    mdd := array.min(dds)

    daily_r = equity / equity[1] - 1
    rb.push(benchmark)
    r.push(daily_r)
    sorted_ret.push(daily_r)

    sorted_ret.sort(order.ascending)
    nloss   = math.floor(sorted_ret.size() * 0.05)
    sumloss = 0.0
    for x = 0 to nloss - 1
        sumloss += sorted_ret.get(x)
    cVaR := nloss > 0 ? sumloss / nloss : na

    if daily_r > 0
        pos_ret.push(daily_r)
    else
        neg_ret.push(daily_r)

skewness(ret) =>
    n = ret.size()
    if n < 3
        na
    else
        mean_val  = ret.sum() / n
        std_val   = ret.stdev()
        sum_cubed = 0.0
        for i = 0 to n - 1
            dev = ret.get(i) - mean_val
            sum_cubed += math.pow(dev / std_val, 3)
        skew = (n / ((n - 1) * (n - 2))) * sum_cubed
        skew 

net_profit   = (equity - initial_cap) / initial_cap * 100
mean         = r.sum() / r.size()
bm_mean      = rb.sum() / rb.size()
bm_ann_mean  = bm_mean * tradingdays
std          = r.stdev()
ann_mean     = mean * tradingdays
ann_std      = std * math.sqrt(tradingdays)
variance     = math.pow(ann_std, 2)
ann_mean_pct = ann_mean * 100
ann_std_pct  = ann_std * 100
sharpe       = (mean - rfr / tradingdays) / std * math.sqrt(tradingdays)
sortino      = mean / neg_ret.stdev() * math.sqrt(tradingdays)
omega        = pos_ret.sum() / neg_ret.sum() * -1
gaintopain   = r.sum() / (-neg_ret.sum())
cagr         = (math.pow(equity / initial_cap, 1 / ((time - startDate) / 31536000000)) - 1) * 100
beta         = r.covariance(rb) / rb.variance()
alpha        = ((ann_mean - rfr) - beta * (bm_ann_mean - rfr)) * 100
pf           = pos_ret.sum() / neg_ret.sum()
calmar       = cagr / math.abs(mdd)
winrate      = (pos_ret.size() / r.size()) * 100

labels = array.from(
 "Net Profit (%)","Max DD (%)","Win Rate", "Annual Mean Returns (% p/y)","Annual Stdev Returns (% p/y)","Variance","Sortino Ratio","Sharpe Ratio",
 "Omega Ratio","Gain-to-Pain","CAGR (% p/y)","Portfolio Alpha (% p/y)","Portfolio Beta","Skewness of Returns")

values = array.from(net_profit, mdd, winrate, ann_mean_pct, ann_std_pct, variance, sortino, sharpe, omega, gaintopain, cagr, alpha, beta, cVaR)

if show_metrics
    var table metricTable = table.new(position.top_right, 10, array.size(labels) + 1, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
    metricTable.cell(0, 0, "Portfolio Metrics", text_color=color.white, bgcolor=color.gray)
    metricTable.merge_cells(0, 0, 1, 0)
    for i = 0 to array.size(labels) - 1
        s = i + 1
        lbl = labels.get(i)
        val = values.get(i)
        strVal = na(val) ? "NaN" : str.tostring(val, "#.###")
        metricTable.cell(0, s, lbl, text_color=color.white)
        metricTable.cell(1, s, strVal, text_color=color.white)

// Plot equity and benchmark

equity_col = color.new(color.white, 0)
equity_ret = not na(equity[5]) ? math.log(equity - equity[5]) : 0.0

if equity>equity[1]
    equity_col := pos_col
else if equity<equity[1]
    equity_col := neg_col

plot_eq = plot(show_eq and not na(equity) ? equity : na, "Strategy Equity", color=equity_col, linewidth=2)
plot_bh = plot(show_bh ? bh_benchmark : na, "Buy & Hold Equity", color=color.blue, linewidth=2)

var label eq_lbl = na
var label bh_lbl = na

if show_lbls
    if not na(eq_lbl)
        label.delete(eq_lbl)
    if not na(bh_lbl)
        label.delete(bh_lbl)

    if show_eq and not na(equity)
        eq_lbl := label.new(bar_index + 3, equity, "Strategy", style=label.style_label_left, color=color.white, textcolor=color.black, size=size.normal)

    if show_bh and not na(bh_benchmark)
        bh_lbl := label.new(bar_index + 3, bh_benchmark, "Buy & Hold", style=label.style_label_left, color=color.blue, textcolor=color.black, size=size.normal)
````
