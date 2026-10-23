#!/usr/bin/env python3
"""
BGC Grid Trading EA — Parameter Calibration Script
Derives optimal parameters from Taranto & Khan research formulas
using actual backtest CSV data + MT5 historical price data.

Usage:
    python calibrate_parameters.py [csv_dir] [--no-mt5]

Default CSV directory: %APPDATA%/MetaQuotes/Terminal/Common/Files
Loads ALL BGCGrid CSV files found, merges across periods.

Calibrations performed:
  1. Variance Age Curve      → MaxCycleHours recommendation
  2. Theorem 53 Kill Switch  → RuinThreshold recommendation
  3. σ/μ Threshold           → SigmaMuMin & TGTSigmaMuThreshold
  4. Profitability Condition  → Zone analysis (fraction of time profitable)
  5. Expected Steps           → Cycle duration validation
  6. Multi-TF Regime Detection→ Optimal timeframe for σ/μ (requires MT5)
"""

import sys
import os
import glob
import argparse
import warnings
from datetime import datetime, timedelta

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore", category=FutureWarning)

# ── Defaults ─────────────────────────────────────────────────────────
DEFAULT_CSV_DIR = os.path.join(
    os.environ.get("APPDATA", ""), "MetaQuotes", "Terminal", "Common", "Files"
)

SYMBOL = "XAUUSD"
POINT_VALUE = 1.0       # XAUUSD: 1 standard lot = $1 per point (0.01 move)
CONTRACT_SIZE = 100.0   # XAUUSD: 100 oz per lot

# Current EA defaults (for comparison)
CURRENT_PARAMS = {
    "MaxCycleHours":       72,
    "RuinThreshold":       0.25,
    "WarningThreshold":    0.15,
    "MinSigmaMuRatio":     5.0,
    "TGTSigmaMuThreshold": 5.0,
    "ProfitTargetPct":     3.0,
    "GridLevels":          8,
    "ATRSpacingMultiplier": 0.12,
    "RegimeTF":            "H4",
}


# ═══════════════════════════════════════════════════════════════════════
#  HELPERS
# ═══════════════════════════════════════════════════════════════════════

def read_csv_robust(path):
    for enc in ("utf-8", "utf-16", "latin-1"):
        try:
            return pd.read_csv(path, encoding=enc)
        except (UnicodeDecodeError, UnicodeError):
            continue
    raise RuntimeError(f"Cannot read {path} with any encoding")


def load_all_csvs(csv_dir):
    """Load and merge ALL BGCGrid CSV files across all dates."""
    bar_files = sorted(glob.glob(os.path.join(csv_dir, "BGCGrid_BarSnapshots_*.csv")))
    cycle_files = sorted(glob.glob(os.path.join(csv_dir, "BGCGrid_CycleSummary_*.csv")))
    event_files = sorted(glob.glob(os.path.join(csv_dir, "BGCGrid_EventLog_*.csv")))

    if not bar_files:
        print(f"Error: no BGCGrid_BarSnapshots_*.csv files found in {csv_dir}")
        sys.exit(1)

    print(f"Found {len(bar_files)} bar snapshot files:")
    for f in bar_files:
        print(f"  {os.path.basename(f)}")
    print(f"Found {len(cycle_files)} cycle summary files")
    print(f"Found {len(event_files)} event log files")
    print()

    # Merge bar snapshots
    bar_dfs = []
    for f in bar_files:
        df = read_csv_robust(f)
        df["Time"] = pd.to_datetime(df["Time"], format="mixed", errors="coerce")
        bar_dfs.append(df)
    bars = pd.concat(bar_dfs, ignore_index=True).sort_values("Time").reset_index(drop=True)

    # Merge cycle summaries — renumber cycles sequentially
    cycle_dfs = []
    cycle_offset = 0
    for f in cycle_files:
        df = read_csv_robust(f)
        df["StartTime"] = pd.to_datetime(df["StartTime"], format="mixed", errors="coerce")
        df["EndTime"] = pd.to_datetime(df["EndTime"], format="mixed", errors="coerce")
        df["CycleNumber"] = df["CycleNumber"] + cycle_offset
        cycle_offset = df["CycleNumber"].max() + 1
        cycle_dfs.append(df)
    cycles = pd.concat(cycle_dfs, ignore_index=True).sort_values("StartTime").reset_index(drop=True)

    # Merge events
    event_dfs = []
    for f in event_files:
        df = read_csv_robust(f)
        df["Time"] = pd.to_datetime(df["Time"], format="mixed", errors="coerce")
        event_dfs.append(df)
    events = pd.concat(event_dfs, ignore_index=True).sort_values("Time").reset_index(drop=True)

    return bars, cycles, events


def compute_v(base_lot, grid_spacing_price):
    """Compute v = profit per grid level closure in dollars.
    v = lot_size × contract_size × grid_spacing_price
    For XAUUSD: 0.03 lots × 100 oz × $10 spacing = $30 per level
    """
    return base_lot * CONTRACT_SIZE * grid_spacing_price


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 1: VARIANCE AGE CURVE → MaxCycleHours
# ═══════════════════════════════════════════════════════════════════════

def calibrate_variance_age(bars, cycles):
    """
    Research formula: Var[Et] ∝ exp(4v²σt²/g² · t)
    Find time t* where variance reaches 5× initial value.
    Using per-cycle actual v, σt, g values from the CSV data.
    """
    print("=" * 70)
    print("  CALIBRATION 1: VARIANCE AGE CURVE → MaxCycleHours")
    print("=" * 70)
    print()

    # Filter to completed cycles with valid data
    valid = cycles.dropna(subset=["GridSpacing", "BaseLot", "ATRAtStart", "DurationHours"])
    valid = valid[valid["GridSpacing"] > 0]
    valid = valid[valid["ATRAtStart"] > 0]

    if len(valid) == 0:
        print("  No valid cycles for variance age computation.")
        return None

    results = []
    for _, row in valid.iterrows():
        v = compute_v(row["BaseLot"], row["GridSpacing"])
        sigma = row["ATRAtStart"]    # σt proxy (ATR in price units)
        g = row["GridSpacing"]       # grid spacing in price units

        if g <= 0 or v <= 0 or sigma <= 0:
            continue

        # Variance growth exponent: k = 4v²σt²/g²
        # Var[Et] = C · exp(k · t)
        # We want t* where exp(k·t*) = 5 → t* = ln(5) / k
        k = 4.0 * (v ** 2) * (sigma ** 2) / (g ** 2)
        if k <= 0:
            continue

        # t is in the same units as the SDE — we treat it as hours
        # since the EA ticks on M1 and cycle durations are in hours
        t_star_hours = np.log(5.0) / k

        results.append({
            "cycle": row["CycleNumber"],
            "mode": row.get("GridMode", "BGT"),
            "v": v,
            "sigma": sigma,
            "g": g,
            "k_exponent": k,
            "t_star_5x": t_star_hours,
            "actual_duration": row["DurationHours"],
            "exit": row.get("ExitReason", "?"),
            "profit_pct": row.get("ProfitPct", 0),
        })

    if not results:
        print("  No valid variance computations.")
        return None

    df = pd.DataFrame(results)

    print(f"  Analyzed {len(df)} cycles across all periods")
    print()

    # The t* values are in abstract SDE time units, not directly hours.
    # But the relative ordering and distribution tell us where 72h sits.
    # More useful: compare actual durations of winning vs losing cycles
    # against the variance growth rate.

    # Approach: For each cycle, compute how much variance grew during its lifetime
    # var_growth = exp(k * duration_hours)
    df["var_growth"] = np.exp(df["k_exponent"] * df["actual_duration"])
    df["var_growth_clipped"] = df["var_growth"].clip(upper=1e15)

    winners = df[df["profit_pct"] > 0]
    losers = df[df["profit_pct"] <= 0]

    print("  --- Variance Growth Factor at Cycle End ---")
    print(f"  Winning cycles (n={len(winners)}):")
    if len(winners) > 0:
        print(f"    Median duration:       {winners['actual_duration'].median():.1f}h")
        print(f"    Median var growth:     {winners['var_growth_clipped'].median():.2e}")
        print(f"    P90 duration:          {winners['actual_duration'].quantile(0.9):.1f}h")
        print(f"    P90 var growth:        {winners['var_growth_clipped'].quantile(0.9):.2e}")

    print(f"  Losing cycles (n={len(losers)}):")
    if len(losers) > 0:
        print(f"    Median duration:       {losers['actual_duration'].median():.1f}h")
        print(f"    Median var growth:     {losers['var_growth_clipped'].median():.2e}")
        print(f"    P90 duration:          {losers['actual_duration'].quantile(0.9):.1f}h")
        print(f"    P90 var growth:        {losers['var_growth_clipped'].quantile(0.9):.2e}")

    # Find the duration threshold where most losses cluster
    if len(losers) > 0:
        print()
        print("  --- Duration Threshold Analysis ---")
        for hours in [24, 36, 48, 60, 72, 96, 120]:
            n_win = len(winners[winners["actual_duration"] <= hours])
            n_lose = len(losers[losers["actual_duration"] <= hours])
            pct_wins_captured = n_win / len(winners) * 100 if len(winners) > 0 else 0
            pct_losses_captured = n_lose / len(losers) * 100 if len(losers) > 0 else 0
            print(f"    ≤{hours:3d}h: captures {pct_wins_captured:5.1f}% wins, {pct_losses_captured:5.1f}% losses")

    # Per-mode analysis
    print()
    print("  --- Per-Mode Duration vs Outcome ---")
    for mode in df["mode"].unique():
        mode_df = df[df["mode"] == mode]
        mw = mode_df[mode_df["profit_pct"] > 0]
        ml = mode_df[mode_df["profit_pct"] <= 0]
        print(f"  {mode}: {len(mw)} wins (med {mw['actual_duration'].median():.1f}h), "
              f"{len(ml)} losses (med {ml['actual_duration'].median():.1f}h)" if len(ml) > 0
              else f"  {mode}: {len(mw)} wins (med {mw['actual_duration'].median():.1f}h), 0 losses")

    # Recommendation
    print()
    if len(losers) > 0 and len(winners) > 0:
        # Find duration where we'd lose least profit while cutting most losses
        best_cutoff = 72
        best_score = -999
        for hours in range(12, 145, 6):
            wins_kept = len(winners[winners["actual_duration"] <= hours]) / len(winners)
            losses_cut = len(losers[losers["actual_duration"] > hours]) / len(losers)
            # Also count age-exit winners we'd keep
            score = wins_kept * 0.6 + losses_cut * 0.4
            if score > best_score:
                best_score = score
                best_cutoff = hours

        print(f"  RECOMMENDATION: MaxCycleHours = {best_cutoff}")
        print(f"    (current: {CURRENT_PARAMS['MaxCycleHours']})")
    else:
        print(f"  RECOMMENDATION: Insufficient loss data; keep MaxCycleHours = {CURRENT_PARAMS['MaxCycleHours']}")
        best_cutoff = CURRENT_PARAMS["MaxCycleHours"]

    print()
    return best_cutoff


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 2: THEOREM 53 → Kill Switch Threshold
# ═══════════════════════════════════════════════════════════════════════

def theorem53_pruin(n, N, x):
    """
    Theorem 53: P(ruin) = [(x+1/2)^n - (x+1/2)^N] / [1 - (x+1/2)^N]
    n = current equity in discrete coin units
    N = total coins (trader + broker)
    x = current grid level reached
    Uses log-space computation to handle large exponents.
    """
    base = (x + 0.5)
    if base <= 1.0 or N <= 0 or n <= 0 or n > N:
        return 0.0

    log_base = np.log(base)

    # In log space: base^n = exp(n * log(base))
    log_base_n = n * log_base
    log_base_N = N * log_base

    # When exponents are large, base^N >> base^n >> 1
    # P(ruin) ≈ base^n / base^N = base^(n-N) → approaches 0 as N-n grows
    # But when n ≈ N (trader has most coins), P(ruin) ≈ 0
    # When n << N (trader has lost most coins), P(ruin) → 1

    # For numerical stability, factor out base^n from numerator, base^N from denominator
    # P(ruin) = [base^n(1 - base^(N-n))] / [1 - base^N]
    # = [base^n - base^N] / [1 - base^N]

    if log_base_N > 500:
        # base^N is astronomically large → denominator ≈ -base^N
        # P(ruin) ≈ (base^n - base^N) / (-base^N) = 1 - base^(n-N)
        return 1.0 - np.exp((n - N) * log_base)

    try:
        base_n = np.exp(log_base_n)
        base_N = np.exp(log_base_N)
        denom = 1.0 - base_N
        if abs(denom) < 1e-15:
            return 1.0 - (n / N)  # degenerate case
        return (base_n - base_N) / denom
    except (OverflowError, FloatingPointError):
        return 1.0 - np.exp((n - N) * log_base)


def calibrate_kill_switch(cycles):
    """
    Theorem 53 backwards derivation.

    The thesis models the grid as a Gambler's Ruin with N total coins.
    The key question: at what equity drawdown % does P(ruin) cross 25%?

    Mapping from EA to theorem:
    - v = profit per grid level closure (lot × contractSize × spacing)
    - N = cycleStartEquity / v (total coins at cycle start)
    - As the cycle runs and equity drops, n = currentEquity / v < N
    - x = max(Dt_levels, Ut_levels) = current grid level reached

    We sweep (x, n/N) pairs to build the P(ruin) surface, then find
    the equity DD% contour where P(ruin) = 25%.
    """
    print("=" * 70)
    print("  CALIBRATION 2: THEOREM 53 → Kill Switch Threshold")
    print("=" * 70)
    print()

    total_levels = CURRENT_PARAMS["GridLevels"]  # 8 per side

    valid = cycles.dropna(subset=["GridSpacing", "BaseLot", "StartEquity"])
    valid = valid[valid["GridSpacing"] > 0]
    valid = valid[valid["BaseLot"] > 0]

    if len(valid) == 0:
        print("  No valid cycles for Theorem 53 computation.")
        return None

    # Compute typical v and N for the dataset
    vs = []
    Ns = []
    for _, row in valid.iterrows():
        v = compute_v(row["BaseLot"], row["GridSpacing"])
        if v > 0:
            vs.append(v)
            Ns.append(row["StartEquity"] / v)

    v_med = np.median(vs)
    N_med = np.median(Ns)
    eq_med = np.median(valid["StartEquity"])

    print(f"  Median v (profit per level): ${v_med:.2f}")
    print(f"  Median N (equity in coin units): {N_med:.0f}")
    print(f"  Median cycle start equity: ${eq_med:.0f}")
    print()

    # Build P(ruin) table: for each grid level x, sweep equity loss
    # from 0% to 50% in 1% steps. At each step, n = N × (1 - dd%).
    print(f"  --- P(ruin) at Grid Level x, by Equity DD% ---")
    print(f"  {'DD%':>6}", end="")
    for x in range(1, total_levels + 1):
        print(f"  {'x='+str(x):>8}", end="")
    print()
    print(f"  {'─'*6}", end="")
    for _ in range(total_levels):
        print(f"  {'─'*8}", end="")
    print()

    # Track where P(ruin) crosses 25% for each x
    dd_at_25_by_x = {}
    for dd_pct in range(0, 51):
        dd_frac = dd_pct / 100.0
        n = N_med * (1.0 - dd_frac)
        if n <= 0:
            break
        row_str = f"  {dd_pct:5d}%"
        for x in range(1, total_levels + 1):
            p_ruin = theorem53_pruin(n, N_med, x)
            marker = ""
            if x not in dd_at_25_by_x and p_ruin >= 0.25:
                dd_at_25_by_x[x] = dd_pct
                marker = "*"
            row_str += f"  {p_ruin:7.1%}{marker}"
        if dd_pct % 5 == 0:
            print(row_str)

    print()
    print(f"  --- DD% Where P(ruin) First Crosses 25% (by grid level) ---")
    for x in sorted(dd_at_25_by_x.keys()):
        dd = dd_at_25_by_x[x]
        lt = 0.5 * (x ** 2 + x)
        lt_dd = (lt * v_med) / eq_med * 100
        marker = " ← current kill switch region" if 23 <= dd <= 27 else ""
        print(f"    x={x}: equity must drop {dd}% before P(ruin) hits 25%  "
              f"(Lt={lt:.0f}, Lt-based DD={lt_dd:.1f}%){marker}")

    if not dd_at_25_by_x:
        print("    P(ruin) never reaches 25% within 50% DD at any level ≤ 8")
        print("    This means the account is well-capitalized relative to grid exposure")

    # The practical question: what's the DD% where ruin becomes likely
    # at the MAXIMUM grid level (x = total_levels)?
    if total_levels in dd_at_25_by_x:
        recommended = dd_at_25_by_x[total_levels] / 100.0
    else:
        # P(ruin) never hits 25% at max level within 50% DD — check higher
        recommended = None
        for dd_pct in range(50, 100):
            n = N_med * (1.0 - dd_pct / 100.0)
            if n <= 0:
                break
            p_ruin = theorem53_pruin(n, N_med, total_levels)
            if p_ruin >= 0.25:
                recommended = dd_pct / 100.0
                break
        if recommended is None:
            recommended = CURRENT_PARAMS["RuinThreshold"]

    # Compare against actual kill exits
    kill_cycles = valid[valid["ExitReason"].str.contains("KILL", na=False)]
    if len(kill_cycles) > 0:
        print()
        print(f"  --- Actual KILL Exits ({len(kill_cycles)} cycles) ---")
        print(f"    Avg max DD at kill: {kill_cycles['MaxCycleDD_Pct'].mean():.2f}%")
        print(f"    Median DD at kill:  {kill_cycles['MaxCycleDD_Pct'].median():.2f}%")

    print()
    print(f"  RECOMMENDATION: RuinThreshold = {recommended:.0%}")
    print(f"    (current: {CURRENT_PARAMS['RuinThreshold']:.0%})")
    print(f"    (at max grid level x={total_levels}, P(ruin)≥25% when equity down {recommended:.0%})")
    print()
    return recommended


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 3: σ/μ THRESHOLD DERIVATION
# ═══════════════════════════════════════════════════════════════════════

def calibrate_sigma_mu(cycles):
    """
    Separate cycles by outcome. Compare σ/μ at cycle start for:
    - Winning BGT vs Losing BGT → InpMinSigmaMuRatio
    - Conditions where TGT would have helped → InpTGTSigmaMuThreshold
    """
    print("=" * 70)
    print("  CALIBRATION 3: σ/μ THRESHOLD → SigmaMuMin & TGTThreshold")
    print("=" * 70)
    print()

    # Filter valid cycles
    valid = cycles.dropna(subset=["SigmaMuAtStart", "ProfitPct"])
    # Filter out σ/μ = 999 (sentinel for no drift)
    valid = valid[valid["SigmaMuAtStart"] < 900]

    if len(valid) == 0:
        print("  No valid cycles with real sigma/mu values.")
        return None, None

    # Split by mode and outcome
    bgt = valid[valid["GridMode"] == "BGT"]
    tgt = valid[valid["GridMode"] == "TGT"]
    mgt = valid[valid["GridMode"] == "MGT"]

    bgt_win = bgt[bgt["ProfitPct"] > 0]
    bgt_lose = bgt[bgt["ProfitPct"] <= 0]
    tgt_win = tgt[tgt["ProfitPct"] > 0]
    tgt_lose = tgt[tgt["ProfitPct"] <= 0]

    print(f"  Total valid cycles: {len(valid)}")
    print(f"  BGT: {len(bgt)} ({len(bgt_win)} win, {len(bgt_lose)} lose)")
    print(f"  TGT: {len(tgt)} ({len(tgt_win)} win, {len(tgt_lose)} lose)")
    print(f"  MGT: {len(mgt)}")
    print()

    # BGT σ/μ distributions
    print("  --- BGT σ/μ at Cycle Start ---")
    if len(bgt_win) > 0:
        print(f"    Winners (n={len(bgt_win)}):  mean={bgt_win['SigmaMuAtStart'].mean():.2f}  "
              f"median={bgt_win['SigmaMuAtStart'].median():.2f}  "
              f"P10={bgt_win['SigmaMuAtStart'].quantile(0.1):.2f}  "
              f"P90={bgt_win['SigmaMuAtStart'].quantile(0.9):.2f}")
    if len(bgt_lose) > 0:
        print(f"    Losers  (n={len(bgt_lose)}):  mean={bgt_lose['SigmaMuAtStart'].mean():.2f}  "
              f"median={bgt_lose['SigmaMuAtStart'].median():.2f}  "
              f"P10={bgt_lose['SigmaMuAtStart'].quantile(0.1):.2f}  "
              f"P90={bgt_lose['SigmaMuAtStart'].quantile(0.9):.2f}")

    # TGT σ/μ distributions
    if len(tgt) > 0:
        print()
        print("  --- TGT σ/μ at Cycle Start ---")
        if len(tgt_win) > 0:
            print(f"    Winners (n={len(tgt_win)}):  mean={tgt_win['SigmaMuAtStart'].mean():.2f}  "
                  f"median={tgt_win['SigmaMuAtStart'].median():.2f}  "
                  f"P10={tgt_win['SigmaMuAtStart'].quantile(0.1):.2f}  "
                  f"P90={tgt_win['SigmaMuAtStart'].quantile(0.9):.2f}")
        if len(tgt_lose) > 0:
            print(f"    Losers  (n={len(tgt_lose)}):  mean={tgt_lose['SigmaMuAtStart'].mean():.2f}  "
                  f"median={tgt_lose['SigmaMuAtStart'].median():.2f}  "
                  f"P10={tgt_lose['SigmaMuAtStart'].quantile(0.1):.2f}  "
                  f"P90={tgt_lose['SigmaMuAtStart'].quantile(0.9):.2f}")

    # Exit-based analysis: what σ/μ ranges produce kills?
    print()
    print("  --- σ/μ by Exit Reason ---")
    for reason in ["PROFIT", "KILL", "AGE", "REGIME"]:
        subset = valid[valid["ExitReason"].str.contains(reason, na=False)]
        if len(subset) > 0:
            print(f"    {reason:12s} (n={len(subset):3d}): "
                  f"mean={subset['SigmaMuAtStart'].mean():6.2f}  "
                  f"median={subset['SigmaMuAtStart'].median():6.2f}  "
                  f"range=[{subset['SigmaMuAtStart'].min():.2f}, {subset['SigmaMuAtStart'].max():.2f}]")

    # Find optimal separating threshold for BGT
    print()
    print("  --- Threshold Sweep (BGT win/loss separation) ---")
    print(f"    Threshold  BGT_WinRate  Cycles_Above  Cycles_Below")
    print(f"    {'─'*55}")

    best_threshold = 5.0
    best_separation = 0

    for thresh in np.arange(3.0, 20.1, 0.5):
        above = bgt[bgt["SigmaMuAtStart"] >= thresh]
        below = bgt[bgt["SigmaMuAtStart"] < thresh]
        win_rate_above = len(above[above["ProfitPct"] > 0]) / len(above) * 100 if len(above) > 0 else 0
        win_rate_below = len(below[below["ProfitPct"] > 0]) / len(below) * 100 if len(below) > 0 else 0
        separation = win_rate_above - win_rate_below
        # Require at least 10% of samples on each side to avoid noise
        min_samples = max(5, int(len(bgt) * 0.10))
        if separation > best_separation and len(above) >= min_samples and len(below) >= min_samples:
            best_separation = separation
            best_threshold = thresh
        if thresh % 2 == 0 or thresh == best_threshold:
            print(f"    {thresh:6.1f}     {win_rate_above:6.1f}%       {len(above):4d}          {len(below):4d}")

    # For TGT threshold: find where BGT consistently loses
    tgt_threshold = best_threshold
    if len(bgt_lose) >= 3:
        # TGT should activate where BGT loses — the P75 of losing BGT σ/μ
        tgt_threshold = bgt_lose["SigmaMuAtStart"].quantile(0.75)
        if tgt_threshold < 3.0:
            tgt_threshold = 3.0

    print()
    print(f"  RECOMMENDATION: MinSigmaMuRatio (drift gate) = {best_threshold:.1f}")
    print(f"    (current: {CURRENT_PARAMS['MinSigmaMuRatio']:.1f})")
    print(f"  RECOMMENDATION: TGTSigmaMuThreshold = {tgt_threshold:.1f}")
    print(f"    (current: {CURRENT_PARAMS['TGTSigmaMuThreshold']:.1f})")
    print()
    return best_threshold, tgt_threshold


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 4: PROFITABILITY CONDITION
# ═══════════════════════════════════════════════════════════════════════

def calibrate_profitability(bars, cycles):
    """
    Research formula: vt + 2vμt/g > vσt²/g + 2v²σt²/g²
    Evaluate this condition at every bar. Compare against actual equity.
    """
    print("=" * 70)
    print("  CALIBRATION 4: PROFITABILITY CONDITION → Zone Analysis")
    print("=" * 70)
    print()

    # Need bars with valid σ, μ, v, g
    df = bars.copy()
    df = df.dropna(subset=["ATR", "Drift", "GridSpacing", "BaseLot"])
    df = df[(df["GridSpacing"] > 0) & (df["ATR"] > 0) & (df["BaseLot"] > 0)]

    if len(df) == 0:
        print("  No valid bars for profitability condition.")
        return

    # Compute per-bar
    df["v"] = df["BaseLot"] * CONTRACT_SIZE * df["GridSpacing"]
    df["sigma"] = df["ATR"]
    df["mu"] = df["Drift"]
    df["g"] = df["GridSpacing"]

    # Profitability condition from the equity SDE (Paper 3):
    #   vt + 2vμt/g > vσt²/g + 2v²σt²/g²
    #
    # Divide both sides by v:
    #   t + 2μt/g > σt²/g + 2vσt²/g²
    #
    # The time variable t is hours elapsed since cycle start.
    # As t grows, LHS grows (more time = more winning trades accumulated).
    # RHS is constant for given σt, μt, v, g — it's the variance penalty.
    #
    # Instead of checking instantaneously (t=1), we compute the BREAK-EVEN
    # time t* where LHS = RHS, and compare it against actual cycle durations:
    #   t* = σt²/g + 2vσt²/g² - 2μt/g
    # If t* < 0, the condition is satisfied immediately (always profitable).
    # If t* > MaxCycleHours, the condition is NEVER met within a cycle.
    df["rhs_minus_mu"] = df["sigma"]**2 / df["g"] + 2.0 * df["v"] * df["sigma"]**2 / df["g"]**2 - 2.0 * df["mu"] / df["g"]
    df["t_breakeven"] = df["rhs_minus_mu"]  # hours until profitability
    df["is_profitable_zone"] = df["t_breakeven"] <= 0  # immediately profitable

    total_bars = len(df)
    imm_profitable = df["is_profitable_zone"].sum()
    pct_imm = imm_profitable / total_bars * 100

    print(f"  Total bars analyzed: {total_bars:,}")
    print(f"  Immediately profitable (t*≤0): {imm_profitable:,} ({pct_imm:.1f}%)")
    print()

    # Break-even time distribution
    t_be = df["t_breakeven"]
    t_be_positive = t_be[t_be > 0]
    print("  --- Break-Even Time t* Distribution (hours until profitability) ---")
    print(f"    t* ≤ 0 (always profitable):  {pct_imm:.1f}%")
    if len(t_be_positive) > 0:
        print(f"    t* > 0 (needs time):         {len(t_be_positive)/total_bars*100:.1f}%")
        print(f"    Median t*:                   {t_be_positive.median():.1f}h")
        print(f"    P25 t*:                      {t_be_positive.quantile(0.25):.1f}h")
        print(f"    P75 t*:                      {t_be_positive.quantile(0.75):.1f}h")
        for hours in [12, 24, 36, 48, 72]:
            pct = (t_be <= hours).sum() / total_bars * 100
            print(f"    Profitable within {hours:3d}h:       {pct:.1f}%")
    print()

    # Per grid mode
    if "GridMode" in df.columns:
        print("  --- Break-Even Time by Grid Mode ---")
        for mode in df["GridMode"].unique():
            mode_df = df[df["GridMode"] == mode]
            if len(mode_df) > 0:
                pct_imm = mode_df["is_profitable_zone"].sum() / len(mode_df) * 100
                med_t = mode_df["t_breakeven"].median()
                print(f"    {mode:4s}: {pct_imm:5.1f}% immediately profitable, "
                      f"median t*={med_t:.1f}h ({len(mode_df):,} bars)")
    print()

    # Which variable dominates the variance penalty (RHS)?
    print("  --- Variance Penalty Decomposition ---")
    sigma_term = (df["sigma"] ** 2 / df["g"]).mean()
    v_sigma_term = (2.0 * df["v"] * df["sigma"] ** 2 / df["g"] ** 2).mean()
    mu_term = (2.0 * df["mu"] / df["g"]).mean()

    print(f"    σt²/g term (avg):     {sigma_term:.4f}")
    print(f"    2v·σt²/g² term (avg): {v_sigma_term:.4f}")
    print(f"    2μt/g benefit (avg):  {mu_term:.4f}")
    print(f"    Net penalty (avg t*): {sigma_term + v_sigma_term - mu_term:.4f}h")
    dominant = "σt²/g" if sigma_term > v_sigma_term else "2v·σt²/g²"
    print(f"    Dominant penalty:     {dominant}")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 5: EXPECTED STEPS TO ABSORPTION
# ═══════════════════════════════════════════════════════════════════════

def calibrate_expected_steps(cycles):
    """
    Compare actual cycle durations (in grid level crossings / TPs) against
    the theoretical expected number of steps to absorption from Theorem 55.
    """
    print("=" * 70)
    print("  CALIBRATION 5: EXPECTED STEPS → Cycle Duration Validation")
    print("=" * 70)
    print()

    valid = cycles.dropna(subset=["GridSpacing", "BaseLot", "StartEquity", "TpHits", "DurationHours"])
    valid = valid[valid["GridSpacing"] > 0]

    if len(valid) == 0:
        print("  No valid cycles.")
        return

    results = []
    for _, row in valid.iterrows():
        v = compute_v(row["BaseLot"], row["GridSpacing"])
        if v <= 0:
            continue

        n = row["StartEquity"] / v  # equity in profit units
        N = n  # total = starting equity for single-cycle

        # Expected steps for GTP (simplified): E[steps] ≈ n × (N - n)
        # At start of cycle, we target profit of ~3% → target_n = n * 1.03
        # So effective N for target = n * 1.03, and expected steps ≈ n * 0.03 * n
        # But the kill switch sets a lower bound too.
        # Simple approximation: E[steps] = n for symmetric walk
        expected_steps = n  # simplified — actual formula is more complex

        actual_steps = row["TpHits"]  # TP hits ≈ grid level crossings
        actual_hours = row["DurationHours"]

        results.append({
            "cycle": row["CycleNumber"],
            "mode": row.get("GridMode", "BGT"),
            "exit": row.get("ExitReason", "?"),
            "n_units": n,
            "expected_steps": expected_steps,
            "actual_tp_hits": actual_steps,
            "duration_hours": actual_hours,
            "profit_pct": row.get("ProfitPct", 0),
            "steps_per_hour": actual_steps / actual_hours if actual_hours > 0 else 0,
        })

    df = pd.DataFrame(results)

    print(f"  Analyzed {len(df)} cycles")
    print()

    # Steps per hour by exit type
    print("  --- TP Hits (Grid Level Crossings) by Exit Reason ---")
    for reason in ["PROFIT", "KILL", "AGE", "REGIME"]:
        subset = df[df["exit"].str.contains(reason, na=False)]
        if len(subset) > 0:
            print(f"    {reason:12s}: n={len(subset):3d}  "
                  f"mean_TPs={subset['actual_tp_hits'].mean():6.1f}  "
                  f"median_TPs={subset['actual_tp_hits'].median():5.0f}  "
                  f"mean_dur={subset['duration_hours'].mean():6.1f}h  "
                  f"TPs/h={subset['steps_per_hour'].mean():.2f}")

    print()
    print("  --- Steps/Hour by Mode ---")
    for mode in df["mode"].unique():
        mode_df = df[df["mode"] == mode]
        if len(mode_df) > 0:
            print(f"    {mode}: mean={mode_df['steps_per_hour'].mean():.2f} TPs/h  "
                  f"median={mode_df['steps_per_hour'].median():.2f} TPs/h")

    # Are kills happening with many or few TPs?
    kills = df[df["exit"].str.contains("KILL", na=False)]
    profits = df[df["exit"].str.contains("PROFIT", na=False)]
    if len(kills) > 0 and len(profits) > 0:
        print()
        print("  --- Kill vs Profit Comparison ---")
        print(f"    Profit exits: {profits['actual_tp_hits'].mean():.0f} avg TPs in {profits['duration_hours'].mean():.1f}h")
        print(f"    Kill exits:   {kills['actual_tp_hits'].mean():.0f} avg TPs in {kills['duration_hours'].mean():.1f}h")
        if kills['actual_tp_hits'].mean() > profits['actual_tp_hits'].mean():
            print("    Observation: kill exits have more TP hits than profit exits.")
            print("    This suggests the grid remains active during kill exits,")
            print("    with fills and TPs continuing while losses accumulate faster than wins.")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  CALIBRATION 6: MULTI-TIMEFRAME REGIME DETECTION (MT5 data pull)
# ═══════════════════════════════════════════════════════════════════════

def calibrate_multi_tf(cycles, use_mt5=True):
    """
    Pull ATR and drift from MT5 across multiple timeframes for the same
    1.5-year period. Evaluate σ/μ and the profitability condition on each TF.
    Determine which TF best separates winning from losing conditions.
    """
    print("=" * 70)
    print("  CALIBRATION 6: MULTI-TIMEFRAME REGIME DETECTION")
    print("=" * 70)
    print()

    if not use_mt5:
        print("  Skipped (--no-mt5 flag). Requires MetaTrader5 terminal running.")
        print()
        return None

    try:
        import MetaTrader5 as mt5
    except ImportError:
        print("  MetaTrader5 library not available. Skipping.")
        print()
        return None

    if not mt5.initialize():
        print(f"  MT5 initialize failed: {mt5.last_error()}")
        print("  Make sure MetaTrader5 terminal is running.")
        print()
        return None

    # Date range from cycle data
    date_from = cycles["StartTime"].min()
    date_to = cycles["EndTime"].max()
    if pd.isna(date_from) or pd.isna(date_to):
        print("  Cannot determine date range from cycle data.")
        mt5.shutdown()
        return None

    # Convert to datetime
    date_from = date_from.to_pydatetime()
    date_to = date_to.to_pydatetime() + timedelta(days=1)

    print(f"  Data range: {date_from.strftime('%Y-%m-%d')} to {date_to.strftime('%Y-%m-%d')}")
    print(f"  Symbol: {SYMBOL}")
    print()

    timeframes = {
        "H1":  mt5.TIMEFRAME_H1,
        "H2":  mt5.TIMEFRAME_H2,
        "H3":  mt5.TIMEFRAME_H3,
        "H4":  mt5.TIMEFRAME_H4,
        "H6":  mt5.TIMEFRAME_H6,
        "H8":  mt5.TIMEFRAME_H8,
        "H12": mt5.TIMEFRAME_H12,
        "D1":  mt5.TIMEFRAME_D1,
    }

    atr_period = 14
    ma_period = 20

    tf_results = {}

    for tf_name, tf_enum in timeframes.items():
        rates = mt5.copy_rates_range(SYMBOL, tf_enum, date_from, date_to)
        if rates is None or len(rates) < ma_period + atr_period + 1:
            print(f"  {tf_name}: insufficient data ({0 if rates is None else len(rates)} bars)")
            continue

        df = pd.DataFrame(rates)
        df["time"] = pd.to_datetime(df["time"], unit="s")

        # Compute ATR (σt proxy)
        df["tr"] = np.maximum(
            df["high"] - df["low"],
            np.maximum(
                abs(df["high"] - df["close"].shift(1)),
                abs(df["low"] - df["close"].shift(1))
            )
        )
        df["atr"] = df["tr"].rolling(atr_period).mean()

        # Compute SMA for drift
        df["sma"] = df["close"].rolling(ma_period).mean()

        # Compute drift using the SAME formula as the fixed EA:
        # Average absolute bar-by-bar MA change over the window
        abs_changes = df["sma"].diff().abs()
        df["drift"] = abs_changes.rolling(ma_period).mean()

        # σ/μ ratio
        df["sigma_mu"] = np.where(df["drift"] > 0.001, df["atr"] / df["drift"], 999.0)
        df["sigma_mu"] = df["sigma_mu"].clip(upper=999.0)

        df = df.dropna(subset=["atr", "drift", "sigma_mu"])

        # For each cycle, find the σ/μ value at cycle start on this TF
        cycle_sm = []
        for _, cycle in cycles.iterrows():
            start = cycle["StartTime"]
            if pd.isna(start):
                continue
            # Find the nearest bar before/at cycle start
            mask = df["time"] <= start
            if mask.sum() == 0:
                continue
            nearest = df[mask].iloc[-1]
            cycle_sm.append({
                "cycle": cycle["CycleNumber"],
                "sigma_mu": nearest["sigma_mu"],
                "atr": nearest["atr"],
                "drift": nearest["drift"],
                "profit_pct": cycle["ProfitPct"],
                "exit": cycle.get("ExitReason", "?"),
                "mode": cycle.get("GridMode", "BGT"),
            })

        if not cycle_sm:
            continue

        csm = pd.DataFrame(cycle_sm)
        csm_valid = csm[csm["sigma_mu"] < 900]

        # Score this TF: how well does σ/μ separate winners from losers?
        winners = csm_valid[csm_valid["profit_pct"] > 0]
        losers = csm_valid[csm_valid["profit_pct"] <= 0]

        if len(winners) == 0 or len(losers) == 0:
            tf_results[tf_name] = {
                "bars": len(df),
                "valid_cycles": len(csm_valid),
                "win_median_sm": winners["sigma_mu"].median() if len(winners) > 0 else np.nan,
                "lose_median_sm": losers["sigma_mu"].median() if len(losers) > 0 else np.nan,
                "separation": 0,
                "sm_mean": csm_valid["sigma_mu"].mean(),
                "sm_std": csm_valid["sigma_mu"].std(),
                "best_threshold": 5.0,
                "best_accuracy": 0,
            }
            continue

        # Sweep thresholds and find best accuracy
        best_acc = 0
        best_thresh = 5.0
        for thresh in np.arange(2.0, 30.1, 0.5):
            # Above threshold → BGT (should be winners)
            # Below threshold → would trigger TGT (should catch losers)
            correct = len(winners[winners["sigma_mu"] >= thresh]) + len(losers[losers["sigma_mu"] < thresh])
            acc = correct / len(csm_valid) * 100
            if acc > best_acc:
                best_acc = acc
                best_thresh = thresh

        separation = (winners["sigma_mu"].median() - losers["sigma_mu"].median()) if len(losers) > 0 else 0

        tf_results[tf_name] = {
            "bars": len(df),
            "valid_cycles": len(csm_valid),
            "win_median_sm": winners["sigma_mu"].median(),
            "lose_median_sm": losers["sigma_mu"].median(),
            "separation": separation,
            "sm_mean": csm_valid["sigma_mu"].mean(),
            "sm_std": csm_valid["sigma_mu"].std(),
            "best_threshold": best_thresh,
            "best_accuracy": best_acc,
        }

    mt5.shutdown()

    if not tf_results:
        print("  No timeframe data available.")
        return None

    # Display comparison table
    print(f"  {'TF':<6} {'Bars':>7} {'Cycles':>7} {'Win σ/μ':>9} {'Lose σ/μ':>10} {'Separation':>11} "
          f"{'BestThresh':>11} {'Accuracy':>9}")
    print(f"  {'─'*80}")

    best_tf = None
    best_score = 0
    for tf_name in ["H1", "H2", "H3", "H4", "H6", "H8", "H12", "D1"]:
        if tf_name not in tf_results:
            continue
        r = tf_results[tf_name]
        print(f"  {tf_name:<6} {r['bars']:7d} {r['valid_cycles']:7d} {r['win_median_sm']:9.2f} "
              f"{r['lose_median_sm']:10.2f} {r['separation']:11.2f} "
              f"{r['best_threshold']:11.1f} {r['best_accuracy']:8.1f}%")
        if r["best_accuracy"] > best_score:
            best_score = r["best_accuracy"]
            best_tf = tf_name

    print()
    if best_tf:
        r = tf_results[best_tf]
        print(f"  RECOMMENDATION: RegimeTF = {best_tf}")
        print(f"    Best classification accuracy: {r['best_accuracy']:.1f}%")
        print(f"    Optimal σ/μ threshold at this TF: {r['best_threshold']:.1f}")
        print(f"    (current: {CURRENT_PARAMS['RegimeTF']}, threshold={CURRENT_PARAMS['TGTSigmaMuThreshold']:.1f})")
    print()
    return best_tf


# ═══════════════════════════════════════════════════════════════════════
#  SUMMARY TABLE
# ═══════════════════════════════════════════════════════════════════════

def print_summary(recommendations):
    print()
    print("=" * 70)
    print("  PARAMETER CALIBRATION SUMMARY")
    print("=" * 70)
    print()
    print(f"  {'Parameter':<25} {'Current':>12} {'Recommended':>14} {'Source':<30}")
    print(f"  {'─'*85}")

    rows = [
        ("MaxCycleHours",       f"{CURRENT_PARAMS['MaxCycleHours']}",
         f"{recommendations.get('MaxCycleHours', '?')}", "Variance Age Curve"),
        ("RuinThreshold",       f"{CURRENT_PARAMS['RuinThreshold']:.0%}",
         f"{recommendations.get('RuinThreshold', 0.25):.0%}" if isinstance(recommendations.get('RuinThreshold'), (int, float)) else "?",
         "Theorem 53"),
        ("MinSigmaMuRatio",     f"{CURRENT_PARAMS['MinSigmaMuRatio']:.1f}",
         f"{recommendations.get('MinSigmaMuRatio', '?'):.1f}" if isinstance(recommendations.get('MinSigmaMuRatio'), float) else "?",
         "σ/μ distribution"),
        ("TGTSigmaMuThreshold", f"{CURRENT_PARAMS['TGTSigmaMuThreshold']:.1f}",
         f"{recommendations.get('TGTSigmaMuThreshold', '?'):.1f}" if isinstance(recommendations.get('TGTSigmaMuThreshold'), float) else "?",
         "σ/μ distribution"),
        ("RegimeTF",            CURRENT_PARAMS['RegimeTF'],
         str(recommendations.get('RegimeTF', '?')), "Multi-TF analysis"),
    ]

    for param, current, recommended, source in rows:
        match = "  ✓" if current.strip() == recommended.strip() else ""
        print(f"  {param:<25} {current:>12} {recommended:>14} {source:<30}{match}")

    print()
    print("  Notes:")
    print("  - These are data-driven recommendations from 1.5 years of XAUUSD backtests")
    print("  - Theorem 53 provides a theoretical bound; equity-based kill switch remains primary")
    print("  - σ/μ thresholds are specific to the new drift formula (avg absolute bar-by-bar MA change)")
    print("  - CPD parameters (delta, threshold) should be recalibrated AFTER the above are applied")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(description="BGC Grid EA Parameter Calibration")
    parser.add_argument("csv_dir", nargs="?", default=DEFAULT_CSV_DIR,
                        help="Path to CSV directory (default: MT5 Common Files)")
    parser.add_argument("--no-mt5", action="store_true",
                        help="Skip Calibration 6 (multi-TF, requires MT5 terminal)")
    args = parser.parse_args()

    csv_dir = args.csv_dir
    if not os.path.isdir(csv_dir):
        print(f"Error: directory not found: {csv_dir}")
        sys.exit(1)

    print(f"CSV directory: {csv_dir}")
    print()

    bars, cycles, events = load_all_csvs(csv_dir)
    print(f"Loaded {len(bars):,} bar snapshots, {len(cycles)} cycles, {len(events):,} events")
    print(f"Date range: {bars['Time'].min()} to {bars['Time'].max()}")
    print()

    recommendations = {}

    # Calibration 1
    max_hours = calibrate_variance_age(bars, cycles)
    if max_hours is not None:
        recommendations["MaxCycleHours"] = max_hours

    # Calibration 2
    kill_thresh = calibrate_kill_switch(cycles)
    if kill_thresh is not None:
        recommendations["RuinThreshold"] = kill_thresh

    # Calibration 3
    sm_min, tgt_thresh = calibrate_sigma_mu(cycles)
    if sm_min is not None:
        recommendations["MinSigmaMuRatio"] = sm_min
    if tgt_thresh is not None:
        recommendations["TGTSigmaMuThreshold"] = tgt_thresh

    # Calibration 4
    calibrate_profitability(bars, cycles)

    # Calibration 5
    calibrate_expected_steps(cycles)

    # Calibration 6
    best_tf = calibrate_multi_tf(cycles, use_mt5=not args.no_mt5)
    if best_tf is not None:
        recommendations["RegimeTF"] = best_tf

    # Final summary
    print_summary(recommendations)


if __name__ == "__main__":
    main()
