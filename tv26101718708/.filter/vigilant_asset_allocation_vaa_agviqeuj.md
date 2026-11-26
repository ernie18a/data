# Vigilant Asset Allocation (VAA)

- url: https://www.tradingview.com/script/AGViqeuJ-Vigilant-Asset-Allocation-VAA/
- type: indicator
- pine_id: PUB;e3658d33fc674d0d997e04ca74b53d4a
- version: 1.0

## Description

1. Where VAA comes from

The basic observation behind VAA is not new. Jegadeesh and Titman showed in 1993 that stocks with strong recent returns keep outperforming for roughly three to twelve months. That finding was initially confined to equities, but Asness, Moskowitz and Pedersen (2013) later confirmed that the same pattern holds across bonds, currencies and commodities. Momentum, it turns out, is not just a stock-picking anomaly. It works at the asset-class level too.

Moskowitz, Ooi and Pedersen (2012) took this one step further. They looked at time-series momentum rather than cross-sectional momentum. The distinction matters: cross-sectional momentum asks "which asset is doing best?", while time-series momentum asks "is this asset going up at all?". VAA uses both questions, but the time-series version is what drives the breadth filter.

Faber (2007) probably deserves credit for bringing momentum into mainstream tactical allocation. His rule was simple: hold an asset when it trades above its ten-month average, sell when it drops below. Crude, but it cut drawdowns significantly. Antonacci (2014) refined this into dual momentum, combining trend direction with relative strength across two universes.

Keller and Keuning (2017) built on all of this but added something the earlier models lacked: a breadth dimension. Instead of looking at each asset independently, they count how many offensive assets carry positive momentum. If even one drops below zero (in the aggressive B=1 variant), the entire allocation goes defensive. The reasoning is straightforward. When breadth deteriorates, trouble is usually on the way. Waiting for every asset to turn negative is waiting too long.

In their original backtest (1970-2016, using Shiller extended data for the early period and ETF prices from inception), VAA-G4 produced roughly 17.7% annualised with a maximum drawdown of about 16.1% (Keller and Keuning, 2017, Table 2). These are in-sample numbers. They tell you what happened, not what will happen.


2. How the model works

2.1 Momentum scoring

Every asset gets a 13612W score, a weighted combination of four return lookbacks:

mom = 12 * r1 + 4 * r3 + 2 * r6 + r12

The r values are simple returns: r1 = close / close[21] - 1, and so on for 63, 126 and 252 bars. The one-month return gets the heaviest weight (12), the twelve-month return the lightest (1). Recent momentum matters more, but the yearly anchor keeps the score from overreacting to short-term noise.

There is no normalisation. The raw score is used only for two things: ranking assets within each universe, and checking whether it is positive or negative for the breadth count.

2.2 The two universes

Keller and Keuning specified these defaults:

Offensive (growth):
- SPY (S&P 500)
- EFA (international developed)
- EEM (emerging markets)
- AGG (US aggregate bonds)

Defensive (preservation):
- LQD (investment-grade corporate bonds)
- IEF (7-10 year treasuries)
- SHY (1-3 year treasuries)

All seven are changeable in the settings. If you swap in other ETFs, make sure they have enough history.

2.3 The breadth rule

Each day the indicator counts how many offensive assets have positive momentum. Call the count of non-positive ones n_negative. The rule:

- n_negative >= B (default 1): go to the top defensive asset
- n_negative < B: go to the top offensive asset

With B=1, one single negative asset triggers the switch. That is aggressive in the sense of being quick to flee. Keller and Keuning argue this is the right trade-off. Breadth erosion tends to precede broader sell-offs, so early rotation is worth the occasional whipsaw.

2.4 Rebalancing

The paper prescribes monthly rebalancing. The indicator locks the allocation at the close of the last trading day of each month. Everything that happens between rebalances is monitoring only. The dashboard shows both the locked position ("held") and what the model would do today ("live").

Daily rebalancing is available as an option. It is not what the paper tested.

2.5 Ties

When two assets have the exact same momentum score, the one listed first wins. Sounds arbitrary because it is. But four overlapping return windows make exact ties rare in practice.


3. What you need

- TradingView, any plan (free works, Pro lifts the alert cap)
- A daily chart. The lookbacks assume daily bars. On weekly or intraday charts the periods are wrong and the dashboard flags it.
- 252 bars of history for every symbol. Until that is available, the model shows "warming up".


4. Setup and settings

4.1 Getting started

Add the indicator to any daily chart via the TradingView indicator search. It loads with the Keller/Keuning defaults. The status row at the bottom of the dashboard tells you when the model is ready.

4.2 Strategy

Breadth Threshold (B): 1 matches the paper. Raising it to 2 means two assets have to go negative before the model rotates. Fewer whipsaws, slower reaction.

Monthly Rebalancing: On by default. Off gives you daily updates, which is useful for experimentation but not what the literature tested.

4.3 Symbols

Offensive and defensive universes are fully configurable. If you replace an ETF, check that TradingView has daily data going back at least a year.

4.4 Visuals

Background Mode: "Position" tints the background green (offensive) or red (defensive). "Off" removes it.

Candle Colouring: Paints candles by breadth strength. Full green at 4/4 positive, full red at 0/4, faded tones in between. Transparency is adjustable.

Color Theme: Eight palettes. All of them work in both dark and light mode.

Glow Effect: Adds layered transparent lines behind the main plot. Useful if the signal gets lost in a busy chart. Off by default.

4.5 Dashboard

The table in the top right (moveable) shows:

- Regime: offensive or defensive, with the breadth count
- Allocate: which specific ETF to hold (100% always)
- Live: intra-month reading (only visible in monthly mode)
- Individual asset rows: 13612W scores and a trend arrow (up, down, or flat compared to 5 bars ago)
- Status: "active", "warming up", or "wrong timeframe"

4.6 Alerts

Five conditions, all behind a master switch:

- Regime switches to offensive at month-end
- Regime switches to defensive at month-end
- Held asset changed (same regime, different pick)
- Live breadth dropped between rebalances
- Live breadth recovered between rebalances

The live alerts are early warnings, not trade signals. They tell you the next rebalance might produce a change.


5. Reading the chart

The step line maps the breadth count to a 0-10 scale:

| Breadth | Value | What it means |

| 4/4 positive | 0.0 | Everything trending up |
| 3/4 positive | 2.5 | One weak link, still offensive with B=1 |
| 2/4 positive | 5.0 | Defensive if B is 2 or below |
| 1/4 positive | 7.5 | Broad weakness |
| 0/4 positive | 10.0 | Nothing working |

The threshold line sits at B * 2.5. Above it means defensive. The zone fill below the threshold marks the offensive region.

One thing to keep in mind: the distances between these steps do not mean anything quantitative. 5.0 is not "twice as bad" as 2.5. It is an ordinal display, not a risk score.


6. How to actually use it

The simplest workflow: check the dashboard on the last trading day of the month. Look at the "Allocate" row. Buy that ETF at the open of the next session. Done until next month.

If you want a heads-up, turn on the live alerts. A "breadth dropped" alert mid-month tells you the next rebalance might flip regimes. That gives you time to plan, not to act early. The month-end values are what count.

VAA does not know about your taxes, your broker fees, or your risk tolerance. Treat it as one input to your decision process, not the whole process.


7. What the model does not do

It does not model execution. There is no bid-ask spread, no slippage, no market impact.

It cannot protect you from whipsaws. Momentum systems by nature struggle in choppy, directionless markets. The breadth filter helps, but a month where sentiment flips back and forth will still produce unnecessary trades.

Monthly rebalancing is both a feature and a weakness. It keeps you from overtrading, but it also means a crash in the middle of a month does not trigger any action until month-end.

The backtests in the paper used extended data that goes back to 1970. The actual ETFs (EEM, AGG) only started trading in 2003. TradingView data will not replicate the full historical period.

The model is always invested. There is no cash option. You are either in the top offensive or the top defensive ETF.

Momentum can stop working. Correlations change. What the academic literature documents as a persistent anomaly can go through multi-year stretches of underperformance. The 2009 recovery, for instance, was fast enough to catch most trend-following systems off-guard.


8. Common questions

Why does it say "warming up"?
The model needs 252 daily bars per symbol. Loading the indicator on a chart without enough history means it cannot compute the twelve-month return component.

Can I run this on a 4-hour chart?
You can, but 21 bars on a 4-hour chart is not a month. The lookbacks will be wrong. The dashboard will flag this.

I changed the symbols and the readings look off.
Make sure the replacement ETFs actually have a year of daily data on TradingView. Some regional ETFs or newer funds do not.

The live reading disagrees with the held position.
That is expected in monthly mode. The held position only updates at month-end. The live reading shows what would happen if you rebalanced today. They diverge by design.

Should I trade every time the live reading changes?
No. Unless you deliberately turned off monthly rebalancing, the live reading is for awareness, not for execution.


References

Antonacci, G. (2014) Dual Momentum Investing: An Innovative Strategy for Higher Returns with Lower Risk. New York: McGraw-Hill.

Asness, C.S., Moskowitz, T.J. and Pedersen, L.H. (2013) 'Value and Momentum Everywhere', The Journal of Finance, 68(3), pp. 929-985. doi:10.1111/jofi.12021.

Faber, M.T. (2007) 'A Quantitative Approach to Tactical Asset Allocation', The Journal of Wealth Management, 9(4), pp. 69-79.

Jegadeesh, N. and Titman, S. (1993) 'Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency', The Journal of Finance, 48(1), pp. 65-91. doi:10.1111/j.1540-6261.1993.tb04702.x.

Keller, W. and Keuning, J.W. (2017) 'Breadth Momentum and Vigilant Asset Allocation (VAA): Winning More by Losing Less', SSRN Electronic Journal. doi:10.2139/ssrn.3002624.

Moskowitz, T.J., Ooi, Y.H. and Pedersen, L.H. (2012) 'Time series momentum', Journal of Financial Economics, 104(2), pp. 228-250. doi:10.1016/j.jfineco.2011.11.003.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) EdgeTools

indicator("Vigilant Asset Allocation (VAA)", shorttitle="VAA", overlay=false, max_bars_back=5000)

// Vigilant Asset Allocation (VAA) is a rules-based tactical allocation model
// developed by Keller and Keuning (2017). It uses breadth momentum across a
// multi-asset universe to switch between an offensive and a defensive portfolio.
// The core idea builds on earlier work in cross-sectional momentum (Jegadeesh
// and Titman, 1993), time-series momentum (Moskowitz, Ooi and Pedersen, 2012),
// and trend-following tactical allocation (Faber, 2007). Keller and Keuning's
// contribution is the breadth filter: instead of applying momentum to single
// assets in isolation, the model monitors how many assets carry positive
// momentum and treats any deterioration as a warning to rotate defensively.
//
// This indicator implements the VAA-G4 aggressive variant (T=1, B=1). Each
// asset receives a 13612W weighted momentum score:
//   mom = 12 * r1 + 4 * r3 + 2 * r6 + r12
// where r_n is the simple return (p0/p_n - 1) over lookbacks of 21, 63, 126,
// and 252 trading days. The weighting scheme emphasises recent performance
// while retaining a twelve-month anchor, consistent with the intermediate-term
// momentum horizon identified by Jegadeesh and Titman (1993).
//
// Offensive universe: SPY, EFA, EEM, AGG (configurable)
// Defensive universe: LQD, IEF, SHY (configurable)
//
// Allocation rule, rebalanced monthly at month-end close:
//   Count offensive assets with momentum <= 0 as n_negative.
//   If n_negative >= B (default 1), allocate 100% to the top defensive asset.
//   Otherwise, allocate 100% to the top offensive asset.
//
// The model is binary: at any point in time the portfolio is either fully
// offensive or fully defensive. There is no partial allocation or blending.
// Between monthly rebalances the dashboard shows a live reading next to the
// locked held position so the user can monitor intra-month shifts.
//
// Tie-breaking: when two assets share identical momentum, the asset listed
// first in the respective universe is selected. This is deterministic.
//
// How to use this indicator:
//   1. Apply to any chart on the daily timeframe.
//   2. The step line shows the breadth count mapped to 0-10. Lower values
//      mean more offensive assets have positive momentum. When the line
//      crosses above the regime threshold, the model switches to defensive.
//   3. The dashboard shows the held allocation, the live state, and all
//      individual momentum scores. Green means positive momentum, red means
//      negative.
//   4. Set alerts for regime changes and breadth shifts to get notified
//      before the next monthly rebalance.
//
// Limitations:
//   - This is an indicator, not a strategy. There is no equity curve,
//     drawdown, or transaction cost modeling.
//   - Momentum-based systems can whipsaw in range-bound markets. The breadth
//     filter reduces but does not eliminate false signals.
//   - Monthly rebalancing means the model reacts slowly to sudden regime
//     changes within a month.
//   - Data from request.security requires sufficient history. The indicator
//     needs at least 252 daily bars to initialise.
//
// References:
//   Keller, W. and Keuning, J.W. (2017) 'Breadth Momentum and Vigilant
//     Asset Allocation (VAA)', SSRN Electronic Journal. doi:10.2139/ssrn.3002624.
//   Jegadeesh, N. and Titman, S. (1993) 'Returns to Buying Winners and
//     Selling Losers', The Journal of Finance, 48(1), pp. 65-91.
//   Moskowitz, T.J., Ooi, Y.H. and Pedersen, L.H. (2012) 'Time series
//     momentum', Journal of Financial Economics, 104(2), pp. 228-250.
//   Faber, M.T. (2007) 'A Quantitative Approach to Tactical Asset
//     Allocation', The Journal of Wealth Management, 9(4), pp. 69-79.
//   Antonacci, G. (2014) Dual Momentum Investing. New York: McGraw-Hill.
//
// Disclaimer: educational and analysis purposes only. Past performance does
// not guarantee future results. This is not investment advice.

// Lookbacks per the original paper specification.
MOM_1M  = 21
MOM_3M  = 63
MOM_6M  = 126
MOM_12M = 252

// Strategy parameters

breadth_threshold = input.int(1, "Breadth Threshold (B)", minval=1, maxval=4,
    group="Strategy",
    tooltip="Original paper: B=1. Any single negative asset triggers defensive. B=2 reduces whipsaws but deviates from paper.")

monthly_rebalance = input.bool(true, "Monthly Rebalancing",
    group="Strategy",
    tooltip="Lock allocation at month-end per original VAA. Disable for daily live updates (not per paper).")

// Symbol configuration

grp_off = "Offensive Universe"
off1_sym = input.symbol("SPY", "US Equity",      group=grp_off)
off2_sym = input.symbol("EFA", "Intl Equity",    group=grp_off)
off3_sym = input.symbol("EEM", "EM Equity",      group=grp_off)
off4_sym = input.symbol("AGG", "US Bonds",       group=grp_off)

grp_def = "Defensive Universe"
def1_sym = input.symbol("LQD", "IG Corporate",   group=grp_def)
def2_sym = input.symbol("IEF", "7-10Y Treasury", group=grp_def)
def3_sym = input.symbol("SHY", "1-3Y Treasury",  group=grp_def)

// Display options

background_mode = input.string("Position", "Background Mode",
    options=["Off", "Position"], group="Display",
    tooltip="Position: Green in offensive regime, red in defensive regime.")
background_intensity = input.int(88, "Background Intensity (%)", minval=70, maxval=95, step=5, group="Display")
show_bar_coloring = input.bool(true, "Color Candles by Regime", group="Display",
    tooltip="Colors candles based on held regime and breadth strength")
bar_base_transparency = input.int(20, "Candle Base Transparency", minval=0, maxval=60, step=5, group="Display")
show_dashboard = input.bool(true, "Show Dashboard", group="Dashboard")
dashboard_position = input.string("Top Right", "Dashboard Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Dashboard")
show_watermark = input.bool(true, "Show Watermark", group="Watermark")
watermark_position = input.string("Bottom Right", "Watermark Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Watermark")

color_scheme = input.string("EdgeTools", "Color Theme",
    options=["Gold", "EdgeTools", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"],
    group="Appearance")
use_dark_mode = input.bool(true, "Optimize for Dark Theme", group="Appearance")
main_line_width = input.int(2, "Main Line Width", minval=1, maxval=5, group="Appearance")
enable_glow = input.bool(false, "Enable Glow Effect", group="Appearance")
enable_alerts = input.bool(false, "Enable Alerts", group="Alert System")

// Color definitions. The defaults below act as fallback when no theme matches.
var color col_bull    = #22c55e
var color col_bear    = #ef4444
var color col_caution = #f59e0b
var color col_signal  = #3b82f6
var color col_neutral = #737373
var color col_text    = #fafafa
var color col_bg      = #171717
var color col_header  = #262626

switch color_scheme
    "Gold" =>
        col_bull    := use_dark_mode ? #FFA500 : #FF8C00
        col_bear    := use_dark_mode ? #FF5252 : #D32F2F
        col_caution := use_dark_mode ? #C0C0C0 : #808080
        col_signal  := use_dark_mode ? #FFD700 : #DAA520
        col_neutral := use_dark_mode ? #C0C0C0 : #808080
        col_text    := use_dark_mode ? color.white : color.black
        col_bg      := use_dark_mode ? #1A1A00 : #FFFEF0
        col_header  := use_dark_mode ? #2D2600 : #F5F5DC

    "EdgeTools" =>
        col_bull    := use_dark_mode ? #4CAF50 : #388E3C
        col_bear    := use_dark_mode ? #FF5252 : #D32F2F
        col_caution := use_dark_mode ? #708090 : #696969
        col_signal  := use_dark_mode ? #4682B4 : #1E90FF
        col_neutral := use_dark_mode ? #708090 : #696969
        col_text    := use_dark_mode ? color.white : color.black
        col_bg      := use_dark_mode ? #0F1419 : #F0F8FF
        col_header  := use_dark_mode ? #1E2A3A : #E6F3FF

    "Behavioral" =>
        col_bull    := #00FF00
        col_bear    := #8B0000
        col_caution := #FFBF00
        col_signal  := #808080
        col_neutral := #FFBF00
        col_text    := use_dark_mode ? color.white : color.black
        col_bg      := use_dark_mode ? #1A1A1A : #F8F8F8
        col_header  := use_dark_mode ? #2D2D2D : #E8E8E8

    "Quant" =>
        col_bull    := #FFA500
        col_bear    := #8B0000
        col_caution := #4682B4
        col_signal  := #808080
        col_neutral := #4682B4
        col_text    := use_dark_mode ? color.white : color.black
        col_bg      := use_dark_mode ? #0D0D0D : #FAFAFA
        col_header  := use_dark_mode ? #1A1A1A : #F0F0F0

    "Ocean" =>
        col_bull    := use_dark_mode ? #00CED1 : #4682B4
        col_bear    := use_dark_mode ? #FF4500 : #B22222
        col_caution := use_dark_mode ? #87CEEB : #2F4F4F
        col_signal  := use_dark_mode ? #20B2AA : #008B8B
        col_neutral := use_dark_mode ? #87CEEB : #2F4F4F
        col_text    := use_dark_mode ? #F0F8FF : #191970
        col_bg      := use_dark_mode ? #001A2E : #E6F7FF
        col_header  := use_dark_mode ? #002A47 : #CCF2FF

    "Fire" =>
        col_bull    := use_dark_mode ? #FFD700 : #FF8C00
        col_bear    := use_dark_mode ? #8B0000 : #800000
        col_caution := use_dark_mode ? #FFA500 : #CD853F
        col_signal  := use_dark_mode ? #FF6347 : #DC143C
        col_neutral := use_dark_mode ? #FFA500 : #CD853F
        col_text    := use_dark_mode ? #FFFAF0 : #2F1B14
        col_bg      := use_dark_mode ? #261611 : #FFF8F0
        col_header  := use_dark_mode ? #3D241A : #FFE4CC

    "Matrix" =>
        col_bull    := use_dark_mode ? #39FF14 : #228B22
        col_bear    := use_dark_mode ? #FF073A : #8B0000
        col_caution := use_dark_mode ? #00FFFF : #008B8B
        col_signal  := use_dark_mode ? #00FF41 : #006400
        col_neutral := use_dark_mode ? #00FFFF : #008B8B
        col_text    := use_dark_mode ? #C0FF8C : #003300
        col_bg      := use_dark_mode ? #0A1A0A : #E8FFF0
        col_header  := use_dark_mode ? #112B11 : #CCFFCC

    "Arctic" =>
        col_bull    := use_dark_mode ? #00BFFF : #0000CD
        col_bear    := use_dark_mode ? #FF1493 : #8B008B
        col_caution := use_dark_mode ? #B0E0E6 : #483D8B
        col_signal  := use_dark_mode ? #87CEFA : #4169E1
        col_neutral := use_dark_mode ? #B0E0E6 : #483D8B
        col_text    := use_dark_mode ? #F8F8FF : #191970
        col_bg      := use_dark_mode ? #141B47 : #F0F8FF
        col_header  := use_dark_mode ? #1E2A5C : #E0F0FF

// Helper functions

f_get_table_position(string pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_ticker(string sym) =>
    int p = str.pos(sym, ":")
    na(p) ? sym : str.substring(sym, p + 1)

// 13612W momentum using simple returns as specified in the original paper.
// Returns na when any of the required lookback closes is missing or invalid.
f_13612w() =>
    float result = na
    bool ok = not na(close) and close > 0
              and not na(close[MOM_12M]) and close[MOM_12M] > 0
              and not na(close[MOM_6M])  and close[MOM_6M] > 0
              and not na(close[MOM_3M])  and close[MOM_3M] > 0
              and not na(close[MOM_1M])  and close[MOM_1M] > 0
    if ok
        r1  = close / close[MOM_1M]  - 1.0
        r3  = close / close[MOM_3M]  - 1.0
        r6  = close / close[MOM_6M]  - 1.0
        r12 = close / close[MOM_12M] - 1.0
        result := 12.0 * r1 + 4.0 * r3 + 2.0 * r6 + r12
    result

// One request.security call per symbol since Pine does not support
// dynamic symbol iteration at compile time. Seven calls is the minimum.

off1_mom = request.security(off1_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
off2_mom = request.security(off2_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
off3_mom = request.security(off3_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
off4_mom = request.security(off4_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

def1_mom = request.security(def1_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
def2_mom = request.security(def2_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
def3_mom = request.security(def3_sym, "D", f_13612w(), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

has_off_data = not na(off1_mom) and not na(off2_mom) and not na(off3_mom) and not na(off4_mom)
has_def_data = not na(def1_mom) and not na(def2_mom) and not na(def3_mom)
has_data     = has_off_data and has_def_data

// Ticker names derived from input symbols for consistent display.
string off1_name = f_ticker(off1_sym)
string off2_name = f_ticker(off2_sym)
string off3_name = f_ticker(off3_sym)
string off4_name = f_ticker(off4_sym)
string def1_name = f_ticker(def1_sym)
string def2_name = f_ticker(def2_sym)
string def3_name = f_ticker(def3_sym)

// Breadth count. The regime decision only depends on offensive data so
// it can work even when defensive data is temporarily missing.
int n_positive = 0
if has_off_data
    n_positive := (off1_mom > 0 ? 1 : 0) + (off2_mom > 0 ? 1 : 0)
               + (off3_mom > 0 ? 1 : 0) + (off4_mom > 0 ? 1 : 0)

int n_negative = 4 - n_positive
bool is_offensive_live = has_off_data and n_negative < breadth_threshold

// Best offensive asset by raw momentum. No normalization applied.
float best_off_mom = na
int   best_off_idx = 0
if has_off_data
    best_off_mom := off1_mom
    if off2_mom > best_off_mom
        best_off_mom := off2_mom
        best_off_idx := 1
    if off3_mom > best_off_mom
        best_off_mom := off3_mom
        best_off_idx := 2
    if off4_mom > best_off_mom
        best_off_mom := off4_mom
        best_off_idx := 3

string best_off_name = best_off_idx == 0 ? off1_name :
                       best_off_idx == 1 ? off2_name :
                       best_off_idx == 2 ? off3_name : off4_name

// Best defensive asset.
float best_def_mom = na
int   best_def_idx = 0
if has_def_data
    best_def_mom := def1_mom
    if def2_mom > best_def_mom
        best_def_mom := def2_mom
        best_def_idx := 1
    if def3_mom > best_def_mom
        best_def_mom := def3_mom
        best_def_idx := 2

string best_def_name = best_def_idx == 0 ? def1_name :
                       best_def_idx == 1 ? def2_name : def3_name

// Asset selection. An empty string signals that data is insufficient
// to determine an allocation.
string live_selected = ""
if is_offensive_live and has_off_data
    live_selected := best_off_name
else if not is_offensive_live and has_def_data
    live_selected := best_def_name

// Monthly rebalancing. is_new_month fires on the first bar of a new month,
// so the allocation uses the previous bar's data (month-end close) via [1]
// references to avoid lookahead bias.

is_new_month = ta.change(time("M")) != 0

var bool   initialized    = false
var bool   held_offensive = false
var string held_asset     = ""
var int    held_breadth   = 0

// Tracking previous bar's live_selected through a var since the history
// operator on strings is unreliable.
var string prev_live_selected = ""

// Skip rebalancing when live_selected is empty to prevent inconsistent
// state such as a defensive regime paired with an offensive asset.
if not initialized and has_data and live_selected != ""
    held_offensive := is_offensive_live
    held_asset     := live_selected
    held_breadth   := n_positive
    initialized    := true
else if initialized
    if monthly_rebalance
        if is_new_month and has_data[1] and prev_live_selected != ""
            held_offensive := is_offensive_live[1]
            held_asset     := prev_live_selected
            held_breadth   := n_positive[1]
    else
        if has_data and live_selected != ""
            held_offensive := is_offensive_live
            held_asset     := live_selected
            held_breadth   := n_positive

prev_live_selected := live_selected

// Signal value maps the breadth count to a 0-10 display range as ordinal
// steps: 4/4 positive = 0.0, 3/4 = 2.5, 2/4 = 5.0, 1/4 = 7.5, 0/4 = 10.0.
// The distances between steps carry no metric meaning. Only the regime
// threshold at B * 2.5 drives the actual allocation decision.
signal_value = has_off_data ? (4.0 - n_positive) * 2.5 : na

regime_line_level = breadth_threshold * 2.5

// Regime change detection for alerts.
regime_to_offensive = held_offensive and not held_offensive[1]
regime_to_defensive = not held_offensive and held_offensive[1]
held_asset_changed  = held_asset != held_asset[1]

// Momentum direction change for trend symbols in the dashboard.
// Compares current momentum to the value 5 bars ago.
float off1_mom_prev = off1_mom[5]
float off2_mom_prev = off2_mom[5]
float off3_mom_prev = off3_mom[5]
float off4_mom_prev = off4_mom[5]
float def1_mom_prev = def1_mom[5]
float def2_mom_prev = def2_mom[5]
float def3_mom_prev = def3_mom[5]

f_trend_symbol(float current, float prev) =>
    na(current) or na(prev) ? "  " :
     current > prev ? "▲" :
     current < prev ? "▼" : "■"

// Background coloring by held regime.
color bg_col = na
if background_mode == "Position" and initialized
    bg_col := held_offensive ?
         color.new(col_bull, background_intensity) :
         color.new(col_bear, background_intensity)
bgcolor(bg_col, title="Regime Background")

// Bar coloring scales transparency with breadth strength.
f_get_bar_color() =>
    color result = na
    if not has_off_data
        result := na
    else if n_positive == 4
        result := color.new(col_bull, bar_base_transparency)
    else if n_positive == 3
        result := color.new(col_bull, bar_base_transparency + 25)
    else if n_positive == 2
        result := color.new(col_caution, bar_base_transparency + 15)
    else if n_positive == 1
        result := color.new(col_bear, bar_base_transparency + 25)
    else
        result := color.new(col_bear, bar_base_transparency)
    result

barcolor(show_bar_coloring ? f_get_bar_color() : na, title="Regime Bar Color")

// Plotting

zone_color = not has_off_data ? col_neutral :
     n_positive == 4 ? col_bull :
     n_positive == 3 ? color.new(col_bull, 40) :
     n_positive == 2 ? col_caution :
     n_positive == 1 ? color.new(col_bear, 40) : col_bear

// Glow effect: layered transparent plots behind the main line.
plot(enable_glow ? signal_value : na, title="Glow 3", color=color.new(zone_color, 95),
    linewidth=main_line_width + 6, style=plot.style_stepline)
plot(enable_glow ? signal_value : na, title="Glow 2", color=color.new(zone_color, 90),
    linewidth=main_line_width + 4, style=plot.style_stepline)
plot(enable_glow ? signal_value : na, title="Glow 1", color=color.new(zone_color, 80),
    linewidth=main_line_width + 2, style=plot.style_stepline)

plot(signal_value, "Breadth Signal", color=zone_color, linewidth=main_line_width, style=plot.style_stepline)

regime_plot = plot(regime_line_level, "Regime Threshold (B)",
    color=color.new(col_bear, 40), linewidth=2, style=plot.style_line)
zero_plot   = plot(0.0, "Zero", color=color.new(col_neutral, 85), linewidth=1)
fill(zero_plot, regime_plot, color=color.new(col_bull, 95), title="Offensive Zone")

// Watermark

var table wm_table = table.new(f_get_table_position(watermark_position), 1, 4,
    border_width=0, bgcolor=color.new(color.black, 100))

if show_watermark and barstate.islast
    table.clear(wm_table, 0, 0, 0, 3)
    color wm_col = use_dark_mode ? color.new(color.white, 30) : color.new(color.black, 40)

    bool data_missing = not has_data and bar_index > MOM_12M
    bool partial_data = has_off_data and not has_def_data

    table.cell(wm_table, 0, 0, syminfo.ticker + ", " + timeframe.period,
        bgcolor=color.new(color.black, 100), text_color=wm_col,
        text_size=size.large, text_halign=text.align_right)

    if data_missing and not partial_data
        table.cell(wm_table, 0, 1, "VAA: no data",
            bgcolor=color.new(color.black, 100), text_color=color.new(col_bear, 20),
            text_size=size.normal, text_halign=text.align_right)
        table.cell(wm_table, 0, 2, "invalid data",
            bgcolor=color.new(color.black, 100), text_color=color.new(col_bear, 20),
            text_size=size.small, text_halign=text.align_right)
        table.cell(wm_table, 0, 3, "",
            bgcolor=color.new(color.black, 100), text_color=wm_col,
            text_size=size.normal, text_halign=text.align_right)
    else
        string breadth_str = has_off_data ? str.tostring(n_positive) + "/4" : "no data"
        table.cell(wm_table, 0, 1, "VAA: " + breadth_str,
            bgcolor=color.new(color.black, 100),
            text_color=has_off_data ? wm_col : color.new(col_bear, 20),
            text_size=size.normal, text_halign=text.align_right)

        string regime_str = held_offensive ? "offensive" : "defensive"
        table.cell(wm_table, 0, 2, regime_str,
            bgcolor=color.new(color.black, 100), text_color=wm_col,
            text_size=size.small, text_halign=text.align_right)

        color alloc_col = held_offensive ? col_bull : col_bear
        string wm_asset = held_asset == "" ? "no data" : held_asset
        table.cell(wm_table, 0, 3, wm_asset,
            bgcolor=color.new(color.black, 100), text_color=color.new(alloc_col, 20),
            text_size=size.normal, text_halign=text.align_right)

// Dashboard

if show_dashboard and barstate.islast
    int n_rows = monthly_rebalance ? 14 : 13
    var table dash = table.new(f_get_table_position(dashboard_position), 3, n_rows,
        border_width=1, bgcolor=color.new(col_bg, 20))
    table.clear(dash, 0, 0, 2, n_rows - 1)

    color hdr = color.new(col_header, 20)
    int row = 0

    bool is_daily = timeframe.isdaily
    color tf_col = is_daily ? col_neutral : col_bear
    table.cell(dash, 0, row, "VAA aggressive", text_color=col_text, bgcolor=hdr, text_size=size.normal)
    table.cell(dash, 1, row, monthly_rebalance ? "monthly" : "daily", text_color=tf_col, bgcolor=hdr, text_size=size.small)
    table.cell(dash, 2, row, is_daily ? "B=" + str.tostring(breadth_threshold) : "use daily", text_color=tf_col, bgcolor=hdr, text_size=size.small)
    row += 1

    color r_col = held_offensive ? col_bull : col_bear
    color r_bg  = color.new(r_col, 85)
    table.cell(dash, 0, row, "Regime", text_color=col_text, bgcolor=r_bg, text_size=size.small)
    table.cell(dash, 1, row, held_offensive ? "offensive" : "defensive", text_color=r_col, bgcolor=r_bg, text_size=size.small)
    table.cell(dash, 2, row, str.tostring(held_breadth) + "/4", text_color=r_col, bgcolor=r_bg, text_size=size.small)
    row += 1

    color a_col = held_offensive ? col_bull : col_caution
    color a_bg  = color.new(a_col, 85)
    string dash_asset = held_asset == "" ? "no data" : held_asset
    color  dash_asset_col = held_asset == "" ? col_bear : a_col
    table.cell(dash, 0, row, "Allocate", text_color=col_text, bgcolor=a_bg, text_size=size.small)
    table.cell(dash, 1, row, dash_asset, text_color=dash_asset_col, bgcolor=a_bg, text_size=size.small)
    table.cell(dash, 2, row, held_asset == "" ? "" : "100%", text_color=a_col, bgcolor=a_bg, text_size=size.small)
    row += 1

    if monthly_rebalance
        color l_col = is_offensive_live ? col_bull : col_bear
        color l_bg  = color.new(l_col, 90)
        table.cell(dash, 0, row, "Live", text_color=col_text, bgcolor=l_bg, text_size=size.small)
        table.cell(dash, 1, row, is_offensive_live ? "offensive" : "defensive", text_color=l_col, bgcolor=l_bg, text_size=size.small)
        table.cell(dash, 2, row, str.tostring(n_positive) + "/4", text_color=l_col, bgcolor=l_bg, text_size=size.small)
        row += 1

    table.cell(dash, 0, row, "offensive", text_color=col_text, bgcolor=hdr, text_size=size.small)
    table.cell(dash, 1, row, "13612W", text_color=col_text, bgcolor=hdr, text_size=size.small)
    table.cell(dash, 2, row, "trend", text_color=col_text, bgcolor=hdr, text_size=size.small)
    row += 1

    color o1_col = na(off1_mom) ? col_neutral : off1_mom > 0 ? col_bull : col_bear
    color o1_bg  = color.new(o1_col, 90)
    table.cell(dash, 0, row, off1_name, text_color=col_text, bgcolor=o1_bg, text_size=size.small)
    table.cell(dash, 1, row, na(off1_mom) ? "n/a" : str.tostring(off1_mom, "#.##"), text_color=o1_col, bgcolor=o1_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(off1_mom, off1_mom_prev), text_color=o1_col, bgcolor=o1_bg, text_size=size.small)
    row += 1

    color o2_col = na(off2_mom) ? col_neutral : off2_mom > 0 ? col_bull : col_bear
    color o2_bg  = color.new(o2_col, 90)
    table.cell(dash, 0, row, off2_name, text_color=col_text, bgcolor=o2_bg, text_size=size.small)
    table.cell(dash, 1, row, na(off2_mom) ? "n/a" : str.tostring(off2_mom, "#.##"), text_color=o2_col, bgcolor=o2_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(off2_mom, off2_mom_prev), text_color=o2_col, bgcolor=o2_bg, text_size=size.small)
    row += 1

    color o3_col = na(off3_mom) ? col_neutral : off3_mom > 0 ? col_bull : col_bear
    color o3_bg  = color.new(o3_col, 90)
    table.cell(dash, 0, row, off3_name, text_color=col_text, bgcolor=o3_bg, text_size=size.small)
    table.cell(dash, 1, row, na(off3_mom) ? "n/a" : str.tostring(off3_mom, "#.##"), text_color=o3_col, bgcolor=o3_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(off3_mom, off3_mom_prev), text_color=o3_col, bgcolor=o3_bg, text_size=size.small)
    row += 1

    color o4_col = na(off4_mom) ? col_neutral : off4_mom > 0 ? col_bull : col_bear
    color o4_bg  = color.new(o4_col, 90)
    table.cell(dash, 0, row, off4_name, text_color=col_text, bgcolor=o4_bg, text_size=size.small)
    table.cell(dash, 1, row, na(off4_mom) ? "n/a" : str.tostring(off4_mom, "#.##"), text_color=o4_col, bgcolor=o4_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(off4_mom, off4_mom_prev), text_color=o4_col, bgcolor=o4_bg, text_size=size.small)
    row += 1

    table.cell(dash, 0, row, "defensive", text_color=col_text, bgcolor=hdr, text_size=size.small)
    table.cell(dash, 1, row, "13612W", text_color=col_text, bgcolor=hdr, text_size=size.small)
    table.cell(dash, 2, row, "trend", text_color=col_text, bgcolor=hdr, text_size=size.small)
    row += 1

    color d1_col = na(def1_mom) ? col_neutral : def1_mom > 0 ? col_bull : col_bear
    color d1_bg  = color.new(d1_col, 90)
    table.cell(dash, 0, row, def1_name, text_color=col_text, bgcolor=d1_bg, text_size=size.small)
    table.cell(dash, 1, row, na(def1_mom) ? "n/a" : str.tostring(def1_mom, "#.##"), text_color=d1_col, bgcolor=d1_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(def1_mom, def1_mom_prev), text_color=d1_col, bgcolor=d1_bg, text_size=size.small)
    row += 1

    color d2_col = na(def2_mom) ? col_neutral : def2_mom > 0 ? col_bull : col_bear
    color d2_bg  = color.new(d2_col, 90)
    table.cell(dash, 0, row, def2_name, text_color=col_text, bgcolor=d2_bg, text_size=size.small)
    table.cell(dash, 1, row, na(def2_mom) ? "n/a" : str.tostring(def2_mom, "#.##"), text_color=d2_col, bgcolor=d2_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(def2_mom, def2_mom_prev), text_color=d2_col, bgcolor=d2_bg, text_size=size.small)
    row += 1

    color d3_col = na(def3_mom) ? col_neutral : def3_mom > 0 ? col_bull : col_bear
    color d3_bg  = color.new(d3_col, 90)
    table.cell(dash, 0, row, def3_name, text_color=col_text, bgcolor=d3_bg, text_size=size.small)
    table.cell(dash, 1, row, na(def3_mom) ? "n/a" : str.tostring(def3_mom, "#.##"), text_color=d3_col, bgcolor=d3_bg, text_size=size.small)
    table.cell(dash, 2, row, f_trend_symbol(def3_mom, def3_mom_prev), text_color=d3_col, bgcolor=d3_bg, text_size=size.small)
    row += 1

    // Model status row at the bottom.
    string status_text = not initialized ? "warming up" : is_daily ? "active" : "wrong timeframe"
    color status_col = not initialized ? col_caution : is_daily ? col_bull : col_bear
    table.cell(dash, 0, row, "Status", text_color=col_text, bgcolor=hdr, text_size=size.tiny)
    table.cell(dash, 1, row, status_text, text_color=status_col, bgcolor=hdr, text_size=size.tiny)
    table.cell(dash, 2, row, "(c) EdgeTools", text_color=col_neutral, bgcolor=hdr, text_size=size.tiny)

// Alerts

alertcondition(regime_to_offensive and enable_alerts, title="Rebalance: offensive",
    message="VAA: monthly rebalance to offensive. Fewer than B assets negative at month-end.")
alertcondition(regime_to_defensive and enable_alerts, title="Rebalance: defensive",
    message="VAA: monthly rebalance to defensive. B or more assets negative at month-end.")
alertcondition(held_asset_changed and enable_alerts, title="Rebalance: asset changed",
    message="VAA: monthly rebalance changed held asset. Check dashboard.")

live_breadth_dropped = has_off_data and n_positive < n_positive[1]
live_breadth_recovered = has_off_data and n_positive > n_positive[1]
alertcondition(live_breadth_dropped and enable_alerts, title="Live: breadth dropped",
    message="VAA: live breadth dropped. Possible regime change at next rebalance.")
alertcondition(live_breadth_recovered and enable_alerts, title="Live: breadth recovered",
    message="VAA: live breadth improved. Check dashboard for current state.")
````
