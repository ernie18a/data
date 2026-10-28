#!/usr/bin/env python3
"""
BGC Grid Trading EA — Backtest Analysis Script
Reads CSV files produced by DiagnosticLog.mqh, runs bug detection,
detailed text analysis, generates 8 chart PNGs, and prints
diagnostics for manual review.

Usage:
    python analyze_backtest.py [path_to_csv_directory]

Default CSV directory: %APPDATA%/MetaQuotes/Terminal/Common/Files
Output: ./analysis_output/ (8 PNG charts + analysis text)
"""

import sys
import os
import glob
import argparse
import warnings
from pathlib import Path
from datetime import datetime

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore", category=FutureWarning)

def _import_matplotlib():
    """Lazy-import matplotlib only when charts are needed."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    from matplotlib.patches import Patch
    from matplotlib.lines import Line2D
    return plt, mdates, Patch, Line2D

# ── Defaults ─────────────────────────────────────────────────────────
DEFAULT_CSV_DIR = os.path.join(
    os.environ.get("APPDATA", ""), "MetaQuotes", "Terminal", "Common", "Files"
)
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "analysis_output")
KILL_THRESHOLD_PCT = 25.0
WARNING_THRESHOLD_PCT = 15.0


# ═══════════════════════════════════════════════════════════════════════
#  HELPERS
# ═══════════════════════════════════════════════════════════════════════

def find_latest(directory, pattern, date_suffix=None):
    matches = glob.glob(os.path.join(directory, pattern))
    if not matches:
        return None
    if date_suffix:
        matches = [m for m in matches if date_suffix in os.path.basename(m)]
        if not matches:
            return None
    return max(matches, key=os.path.getmtime)

def read_csv_robust(path):
    for enc in ("utf-8", "utf-16", "latin-1"):
        try:
            return pd.read_csv(path, encoding=enc)
        except (UnicodeDecodeError, UnicodeError):
            continue
    raise RuntimeError(f"Cannot read {path} with any encoding")

def parse_datetime_col(df, col):
    if col not in df.columns:
        return df
    df[col] = pd.to_datetime(df[col], format="mixed", dayfirst=False, errors="coerce")
    return df

def state_color(state):
    m = {"ACTIVE": "#d4edda", "PAUSED": "#f8d7da", "IDLE": "#e2e3e5", "CLOSING": "#fff3cd"}
    return m.get(str(state).strip(), "#ffffff")

def exit_color(reason):
    m = {"PROFIT": "green", "KILL": "red", "AGE": "orange", "REGIME_RESTART": "purple", "REGIME": "purple", "WEEKEND": "blue"}
    return m.get(str(reason).strip(), "gray")

def mode_color(mode):
    m = {"BGT": "#1f77b4", "TGT": "#ff7f0e", "MGT": "#2ca02c"}
    return m.get(str(mode).strip(), "gray")

def safe_corr(s1, s2):
    """Compute correlation, returning NaN if insufficient data."""
    valid = s1.notna() & s2.notna()
    if valid.sum() < 3:
        return float("nan")
    return s1[valid].corr(s2[valid])

def pct_str(count, total):
    if total == 0:
        return "0 (0.0%)"
    return f"{count} ({count/total*100:.1f}%)"

def fmt_table(headers, rows, col_widths=None):
    """Format a simple text table."""
    if col_widths is None:
        col_widths = []
        for i, h in enumerate(headers):
            w = len(str(h))
            for row in rows:
                if i < len(row):
                    w = max(w, len(str(row[i])))
            col_widths.append(w + 2)
    lines = []
    header_line = "  ".join(str(h).ljust(w) for h, w in zip(headers, col_widths))
    lines.append("  " + header_line)
    lines.append("  " + "-" * len(header_line))
    for row in rows:
        line = "  ".join(str(v).ljust(w) for v, w in zip(row, col_widths))
        lines.append("  " + line)
    return "\n".join(lines)


# ═══════════════════════════════════════════════════════════════════════
#  DATA LOADING
# ═══════════════════════════════════════════════════════════════════════

def load_data(csv_dir, date_suffix=None):
    bar_path = find_latest(csv_dir, "BGCGrid_BarSnapshots_*.csv", date_suffix)
    cycle_path = find_latest(csv_dir, "BGCGrid_CycleSummary_*.csv", date_suffix)
    event_path = find_latest(csv_dir, "BGCGrid_EventLog_*.csv", date_suffix)

    if not bar_path:
        print(f"Error: no BGCGrid_BarSnapshots_*.csv files found in {csv_dir}")
        sys.exit(1)

    print(f"Bar snapshots: {bar_path}")
    print(f"Cycle summary: {cycle_path}")
    print(f"Event log:     {event_path}")

    bars = read_csv_robust(bar_path)
    bars = parse_datetime_col(bars, "Time")

    cycles = None
    if cycle_path:
        cycles = read_csv_robust(cycle_path)
        cycles = parse_datetime_col(cycles, "StartTime")
        cycles = parse_datetime_col(cycles, "EndTime")

    events = None
    if event_path:
        events = read_csv_robust(event_path)
        events = parse_datetime_col(events, "Time")

    return bars, cycles, events


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 1: VALIDATION CHECKS (10 checks)
# ═══════════════════════════════════════════════════════════════════════

def run_bug_detection(bars, cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 1: VALIDATION CHECKS")
    print("=" * 70)
    bugs_found = 0

    # 1. Lt Refraction Principle violations
    if "Lt_Error" in bars.columns and "GridState" in bars.columns:
        active = bars[bars["GridState"] == "ACTIVE"]
        violations = active[active["Lt_Error"] < -0.5]
        if len(violations) > 0:
            bugs_found += 1
            print(f"\n  [Issue 1] Lt Refraction Principle violations: {len(violations)} bars")
            print(f"     Worst Lt_Error: {violations['Lt_Error'].min():.2f}")
            worst5 = violations.nsmallest(5, "Lt_Error")
            for _, r in worst5.iterrows():
                print(f"     {r['Time']}  Lt_Error={r['Lt_Error']:.2f}  Formula={r['Lt_Formula']:.1f}  PathAware={r['Lt_PathAware']:.1f}  Cycle={r['CycleNumber']}")
        else:
            print(f"\n  [Pass 1] Lt Refraction Principle: no violations ({len(active)} ACTIVE bars checked)")

    # 2. Kill switch breach
    if "CycleDD_Pct" in bars.columns and "GridState" in bars.columns:
        active = bars[bars["GridState"] == "ACTIVE"]
        breaches = active[active["CycleDD_Pct"] > KILL_THRESHOLD_PCT]
        if len(breaches) > 0:
            bugs_found += 1
            print(f"  [Issue 2] Kill switch breach: {len(breaches)} bars with CycleDD > {KILL_THRESHOLD_PCT}% during ACTIVE")
            print(f"     Max CycleDD: {breaches['CycleDD_Pct'].max():.2f}%")
        else:
            print(f"  [Pass 2] Kill switch: CycleDD never exceeded {KILL_THRESHOLD_PCT}% during ACTIVE")

    # 3. Open positions during IDLE/CLOSING
    if all(c in bars.columns for c in ["GridState", "OpenBuys", "OpenSells"]):
        bad_states = bars[bars["GridState"].isin(["IDLE", "CLOSING"])]
        bad_pos = bad_states[(bad_states["OpenBuys"] + bad_states["OpenSells"]) > 0]
        if len(bad_pos) > 1:
            bugs_found += 1
            print(f"  [Issue 3] Positions during IDLE/CLOSING: {len(bad_pos)} bars")
        else:
            print("  [Pass 3] No stale positions during IDLE/CLOSING")

    # 4. Stale/zombie cycles
    #    Exclude TGT (basket close, 0 TPs is expected) and WEEKEND (force-closed by Friday timer)
    if cycles is not None and "TpHits" in cycles.columns and "WarningCloses" in cycles.columns:
        candidates = cycles
        if "GridMode" in candidates.columns:
            candidates = candidates[candidates["GridMode"] != "TGT"]
        if "ExitReason" in candidates.columns:
            candidates = candidates[candidates["ExitReason"] != "WEEKEND"]
        zombies = candidates[(candidates["TpHits"] == 0) & (candidates["WarningCloses"] == 0) & (candidates["DurationHours"] > 24)]
        if len(zombies) > 0:
            bugs_found += 1
            print(f"  [Issue 4] Zombie cycles (0 TPs, 0 warns, >24h, excl TGT/WEEKEND): {len(zombies)}")
            for _, z in zombies.iterrows():
                print(f"     Cycle {z['CycleNumber']}: {z['DurationHours']:.1f}h, P/L=${z['Profit']:.2f}, Exit={z.get('ExitReason','?')}, Mode={z.get('GridMode','?')}")
        else:
            print("  [Pass 4] No zombie cycles detected (TGT and WEEKEND exits excluded)")

    # 5. Drift gate oscillation
    if events is not None:
        drift_events = events[events["EventType"].isin(["DRIFT_PAUSE", "DRIFT_RESUME"])].copy()
        if len(drift_events) > 1:
            drift_events = drift_events.sort_values("Time")
            drift_events["TimeDiff"] = drift_events["Time"].diff()
            fast_flickers = drift_events[drift_events["TimeDiff"] < pd.Timedelta(hours=2)]
            if len(fast_flickers) > 0:
                bugs_found += 1
                print(f"  [Issue 5] Drift gate oscillation: {len(fast_flickers)} events < 2h apart")
            else:
                print("  [Pass 5] No drift gate oscillation")
        else:
            print("  [Pass 5] Insufficient drift events to check oscillation")

    # 6. CycleDD vs SnapshotRPR extreme divergence
    if all(c in bars.columns for c in ["CycleDD_Pct", "SnapshotRPR_Pct"]):
        active = bars[(bars["GridState"] == "ACTIVE") & (bars["SnapshotRPR_Pct"] > 1)]
        if len(active) > 0:
            ratios = active["CycleDD_Pct"] / active["SnapshotRPR_Pct"]
            extreme = ratios[ratios > 2]
            if len(extreme) > 0:
                bugs_found += 1
                print(f"  [Issue 6] CycleDD/RPR divergence > 2x: {len(extreme)} bars (max ratio {ratios.max():.2f})")
            else:
                print("  [Pass 6] CycleDD/RPR divergence within normal range")
        else:
            print("  [Pass 6] No active bars with significant RPR to check")

    # 7. Negative profit on PROFIT exit
    if cycles is not None and "ExitReason" in cycles.columns and "Profit" in cycles.columns:
        profit_exits = cycles[cycles["ExitReason"] == "PROFIT"]
        neg_profit = profit_exits[profit_exits["Profit"] < 0]
        if len(neg_profit) > 0:
            bugs_found += 1
            print(f"  [Issue 7] Negative profit on PROFIT exit: {len(neg_profit)} cycles")
            for _, c in neg_profit.iterrows():
                print(f"     Cycle {c['CycleNumber']}: P/L=${c['Profit']:.2f}")
        else:
            print(f"  [Pass 7] All PROFIT exits have positive profit ({len(profit_exits)} checked)")

    # 8. Zero-duration cycles
    if cycles is not None and "DurationHours" in cycles.columns:
        zero_dur = cycles[cycles["DurationHours"] < 0.01]
        if len(zero_dur) > 0:
            bugs_found += 1
            print(f"  [Issue 8] Zero-duration cycles: {len(zero_dur)}")
        else:
            print("  [Pass 8] No zero-duration cycles")

    # 9. Event storm detection
    if events is not None and cycles is not None:
        event_counts = events.groupby(["CycleNumber", "EventType"]).size().reset_index(name="Count")
        storms = event_counts[event_counts["Count"] > 50]
        if len(storms) > 0:
            bugs_found += 1
            print(f"  [Issue 9] Event storms (>50 per type per cycle):")
            for _, s in storms.iterrows():
                print(f"     Cycle {s['CycleNumber']}: {s['EventType']} x{s['Count']}")
        else:
            print("  [Pass 9] No event storms detected")

    # 10. Mode never activating
    if cycles is not None and "GridMode" in cycles.columns:
        modes = cycles["GridMode"].unique()
        if len(modes) == 1 and modes[0] == "BGT" and len(cycles) > 5:
            bugs_found += 1
            print(f"  [Issue 10] Mode never activating: all {len(cycles)} cycles are BGT (TGT/MGT may be broken)")
        else:
            mode_counts = cycles["GridMode"].value_counts().to_dict()
            print(f"  [Pass 10] Grid modes used: {mode_counts}")

    print(f"\n  Total issues found: {bugs_found}")
    return bugs_found


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 2: SUMMARY STATISTICS
# ═══════════════════════════════════════════════════════════════════════

def print_summary(bars, cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 2: SUMMARY STATISTICS")
    print("=" * 70)

    # --- Bar data ---
    print("\n  --- Bar Data ---")
    print(f"  Total bars:     {len(bars)}")
    if "Time" in bars.columns and bars["Time"].notna().any():
        print(f"  Date range:     {bars['Time'].min()} to {bars['Time'].max()}")
        duration = bars["Time"].max() - bars["Time"].min()
        print(f"  Duration:       {duration.days} days ({duration.days / 30.44:.1f} months)")
    if "Equity" in bars.columns:
        start_eq = bars["Equity"].iloc[0]
        end_eq = bars["Equity"].iloc[-1]
        peak_eq = bars["Equity"].max()
        trough_eq = bars["Equity"].min()
        total_return = (end_eq / start_eq - 1) * 100
        max_dd_abs = peak_eq - trough_eq
        max_dd_pct = max_dd_abs / peak_eq * 100 if peak_eq > 0 else 0
        print(f"  Start equity:   ${start_eq:.2f}")
        print(f"  End equity:     ${end_eq:.2f}")
        print(f"  Peak equity:    ${peak_eq:.2f}")
        print(f"  Trough equity:  ${trough_eq:.2f}")
        print(f"  Total return:   {total_return:+.2f}%")
        print(f"  Max equity DD:  ${max_dd_abs:.2f} ({max_dd_pct:.1f}%)")

    if "GridState" in bars.columns:
        state_counts = bars["GridState"].value_counts()
        total_bars = len(bars)
        print(f"\n  --- Grid State Distribution ---")
        for state in ["ACTIVE", "PAUSED", "IDLE", "CLOSING"]:
            count = state_counts.get(state, 0)
            print(f"  {state:10s}: {pct_str(count, total_bars)}")

    # --- Cycle data ---
    if cycles is not None and len(cycles) > 0:
        print(f"\n  --- Cycle Data ---")
        print(f"  Total cycles:     {len(cycles)}")
        profitable = (cycles["Profit"] > 0).sum()
        losing = (cycles["Profit"] <= 0).sum()
        print(f"  Profitable:       {pct_str(profitable, len(cycles))}")
        print(f"  Losing:           {pct_str(losing, len(cycles))}")
        print(f"  Win rate:         {profitable/len(cycles)*100:.1f}%")
        print(f"  Avg profit:       ${cycles['Profit'].mean():.2f}")
        print(f"  Median profit:    ${cycles['Profit'].median():.2f}")
        print(f"  Std dev profit:   ${cycles['Profit'].std():.2f}")
        print(f"  Best cycle:       ${cycles['Profit'].max():.2f}")
        print(f"  Worst cycle:      ${cycles['Profit'].min():.2f}")
        if profitable > 0 and losing > 0:
            avg_win = cycles[cycles["Profit"] > 0]["Profit"].mean()
            avg_loss = abs(cycles[cycles["Profit"] <= 0]["Profit"].mean())
            profit_factor = avg_win * profitable / (avg_loss * losing) if avg_loss > 0 else float("inf")
            print(f"  Avg win:          ${avg_win:.2f}")
            print(f"  Avg loss:         ${avg_loss:.2f}")
            print(f"  Profit factor:    {profit_factor:.2f}")
            print(f"  Expectancy:       ${cycles['Profit'].mean():.2f} per cycle")
        if "DurationHours" in cycles.columns:
            print(f"  Avg duration:     {cycles['DurationHours'].mean():.1f}h")
            print(f"  Median duration:  {cycles['DurationHours'].median():.1f}h")
            print(f"  Min duration:     {cycles['DurationHours'].min():.2f}h")
            print(f"  Max duration:     {cycles['DurationHours'].max():.1f}h")

        # Exit reasons with detail
        if "ExitReason" in cycles.columns:
            print(f"\n  --- Exit Reasons ---")
            reason_counts = cycles["ExitReason"].value_counts()
            for reason in ["PROFIT", "KILL", "AGE", "REGIME", "WEEKEND", "REGIME_RESTART", "OTHER"]:
                if reason in reason_counts.index:
                    count = reason_counts[reason]
                    subset = cycles[cycles["ExitReason"] == reason]
                    avg_pl = subset["Profit"].mean()
                    med_pl = subset["Profit"].median()
                    avg_dur = subset["DurationHours"].mean() if "DurationHours" in subset else 0
                    print(f"  {reason:18s}: {pct_str(count, len(cycles)):15s} avg=${avg_pl:+.2f}  med=${med_pl:+.2f}  avg_dur={avg_dur:.1f}h")

        # Grid mode breakdown
        if "GridMode" in cycles.columns:
            print(f"\n  --- Grid Mode ---")
            mode_counts = cycles["GridMode"].value_counts()
            for mode in ["BGT", "TGT", "MGT"]:
                if mode in mode_counts.index:
                    count = mode_counts[mode]
                    subset = cycles[cycles["GridMode"] == mode]
                    avg_pl = subset["Profit"].mean()
                    win_rate = (subset["Profit"] > 0).mean() * 100
                    print(f"  {mode}: {pct_str(count, len(cycles)):15s} avg=${avg_pl:+.2f}  win_rate={win_rate:.0f}%")

        # Risk stats
        print(f"\n  --- Risk ---")
        if "MaxCycleDD_Pct" in cycles.columns:
            print(f"  Max cycle DD:     {cycles['MaxCycleDD_Pct'].max():.2f}%")
            print(f"  Avg max cycle DD: {cycles['MaxCycleDD_Pct'].mean():.2f}%")
            print(f"  Median max DD:    {cycles['MaxCycleDD_Pct'].median():.2f}%")
        if "PeakPathLt" in cycles.columns:
            print(f"  Max path Lt:      {cycles['PeakPathLt'].max():.1f}")
            print(f"  Avg peak Lt:      {cycles['PeakPathLt'].mean():.1f}")
        if "PeakPRuin" in cycles.columns:
            print(f"  Max P(ruin):      {cycles['PeakPRuin'].max()*100:.2f}%")
            print(f"  Avg peak P(ruin): {cycles['PeakPRuin'].mean()*100:.2f}%")

        # Drift gate
        if "DriftPauses" in cycles.columns:
            total_pauses = int(cycles["DriftPauses"].sum())
            print(f"\n  --- Drift Gate ---")
            print(f"  Total pauses:     {total_pauses}")
            print(f"  Avg per cycle:    {cycles['DriftPauses'].mean():.1f}")
            print(f"  Max in one cycle: {cycles['DriftPauses'].max()}")
            if "GridState" in bars.columns:
                paused_bars = (bars["GridState"] == "PAUSED").sum()
                print(f"  % time paused:    {paused_bars/len(bars)*100:.1f}%")

        # CPD
        if "CPDFires" in cycles.columns:
            print(f"\n  --- CPD (CUSUM) ---")
            print(f"  Total fires:      {int(cycles['CPDFires'].sum())}")
            print(f"  Avg per cycle:    {cycles['CPDFires'].mean():.1f}")
            print(f"  Max in one cycle: {cycles['CPDFires'].max()}")

        # Warning closer
        if "WarningCloses" in cycles.columns:
            print(f"\n  --- Warning Closer ---")
            print(f"  Total closes:     {int(cycles['WarningCloses'].sum())}")
            print(f"  Avg per cycle:    {cycles['WarningCloses'].mean():.1f}")
            print(f"  Max in one cycle: {cycles['WarningCloses'].max()}")

        # TP stats
        if "TpHits" in cycles.columns:
            print(f"\n  --- Take Profit ---")
            print(f"  Total TP hits:    {int(cycles['TpHits'].sum())}")
            print(f"  Avg per cycle:    {cycles['TpHits'].mean():.1f}")
            print(f"  Max in one cycle: {cycles['TpHits'].max()}")
            zero_tp = (cycles["TpHits"] == 0).sum()
            print(f"  Cycles with 0 TP: {pct_str(zero_tp, len(cycles))}")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 3: DISTRIBUTION ANALYSIS (percentiles, no charts needed)
# ═══════════════════════════════════════════════════════════════════════

def print_distributions(bars, cycles):
    print("\n" + "=" * 70)
    print("  SECTION 3: DISTRIBUTION ANALYSIS (Percentiles)")
    print("=" * 70)

    pct_list = [5, 10, 25, 50, 75, 90, 95]

    # Bar-level distributions
    bar_metrics = {
        "CycleDD_Pct": "Cycle DD %",
        "SnapshotRPR_Pct": "Snapshot RPR %",
        "Lt_Formula": "Lt Formula",
        "Lt_PathAware": "Lt Path-Aware",
        "Lt_Error": "Lt Error",
        "SigmaMu": "sigma/mu (capped 999→NaN)",
        "OpenBuys": "Open Buys",
        "OpenSells": "Open Sells",
    }
    print(f"\n  --- Bar-Level Distributions ({len(bars)} bars) ---")
    headers = ["Metric", "Mean", "Std"] + [f"P{p}" for p in pct_list]
    rows = []
    for col, label in bar_metrics.items():
        if col not in bars.columns:
            continue
        s = bars[col].copy()
        if col == "SigmaMu":
            s = s.replace(999, np.nan).clip(upper=100)
        rows.append([
            label,
            f"{s.mean():.2f}",
            f"{s.std():.2f}",
        ] + [f"{s.quantile(p/100):.2f}" for p in pct_list])
    print(fmt_table(headers, rows))

    # Cycle-level distributions
    if cycles is not None and len(cycles) > 0:
        cycle_metrics = {
            "Profit": "Profit ($)",
            "ProfitPct": "Profit %",
            "DurationHours": "Duration (h)",
            "MaxCycleDD_Pct": "Max Cycle DD %",
            "MaxRPR_Pct": "Max RPR %",
            "PeakPRuin": "Peak P(ruin)",
            "PeakPathLt": "Peak Path Lt",
            "TpHits": "TP Hits",
            "WarningCloses": "Warning Closes",
            "DriftPauses": "Drift Pauses",
            "CPDFires": "CPD Fires",
            "SessionRange": "Session Range",
            "SigmaMuAtStart": "sigma/mu at Start",
        }
        print(f"\n  --- Cycle-Level Distributions ({len(cycles)} cycles) ---")
        headers = ["Metric", "Mean", "Std"] + [f"P{p}" for p in pct_list]
        rows = []
        for col, label in cycle_metrics.items():
            if col not in cycles.columns:
                continue
            s = cycles[col].copy()
            if col == "SigmaMuAtStart":
                s = s.replace(999, np.nan).clip(upper=100)
            rows.append([
                label,
                f"{s.mean():.3f}",
                f"{s.std():.3f}",
            ] + [f"{s.quantile(p/100):.3f}" for p in pct_list])
        print(fmt_table(headers, rows))


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 4: CORRELATION ANALYSIS
# ═══════════════════════════════════════════════════════════════════════

def print_correlations(bars, cycles):
    print("\n" + "=" * 70)
    print("  SECTION 4: CORRELATION ANALYSIS")
    print("=" * 70)

    # Bar-level correlations (key pairs)
    print(f"\n  --- Bar-Level Correlations (ACTIVE bars only) ---")
    active = bars[bars["GridState"] == "ACTIVE"] if "GridState" in bars.columns else bars
    pairs = [
        ("Lt_Formula", "Lt_PathAware", "Lt Formula vs Path-Aware (should be ~1.0)"),
        ("Lt_Formula", "CycleDD_Pct", "Lt Formula vs Cycle DD"),
        ("CycleDD_Pct", "SnapshotRPR_Pct", "Cycle DD vs Snapshot RPR (should correlate)"),
        ("SigmaMu", "CycleDD_Pct", "sigma/mu vs Cycle DD (low sigma/mu = danger)"),
        ("OpenBuys", "OpenSells", "Open Buys vs Sells (hedging)"),
        ("Lt_Formula", "RuinProb_T53", "Lt vs P(ruin)"),
        ("ATR", "GridSpacing", "ATR vs Grid Spacing (ATR-dynamic check)"),
    ]
    for c1, c2, desc in pairs:
        if c1 in active.columns and c2 in active.columns:
            s1 = active[c1].copy()
            s2 = active[c2].copy()
            if c1 == "SigmaMu":
                s1 = s1.replace(999, np.nan)
            if c2 == "SigmaMu":
                s2 = s2.replace(999, np.nan)
            r = safe_corr(s1, s2)
            print(f"  r={r:+.3f}  {desc}")

    # Cycle-level correlations
    if cycles is not None and len(cycles) > 2:
        print(f"\n  --- Cycle-Level Correlations ---")
        cycle_pairs = [
            ("DurationHours", "Profit", "Duration vs Profit"),
            ("DurationHours", "MaxCycleDD_Pct", "Duration vs Max DD"),
            ("MaxCycleDD_Pct", "Profit", "Max DD vs Profit"),
            ("TpHits", "Profit", "TP Hits vs Profit"),
            ("WarningCloses", "Profit", "Warning Closes vs Profit"),
            ("DriftPauses", "Profit", "Drift Pauses vs Profit"),
            ("PeakPathLt", "Profit", "Peak Lt vs Profit"),
            ("PeakPRuin", "Profit", "Peak P(ruin) vs Profit"),
            ("SigmaMuAtStart", "Profit", "sigma/mu at Start vs Profit"),
            ("CPDFires", "Profit", "CPD Fires vs Profit"),
            ("TpHits", "DurationHours", "TP Hits vs Duration"),
            ("WarningCloses", "MaxCycleDD_Pct", "Warning Closes vs Max DD"),
            ("BaseLot", "Profit", "Base Lot vs Profit (dynamic lot check)"),
            ("GridSpacing", "Profit", "Grid Spacing vs Profit (ATR-dynamic check)"),
        ]
        for c1, c2, desc in cycle_pairs:
            if c1 in cycles.columns and c2 in cycles.columns:
                s1 = cycles[c1].copy()
                s2 = cycles[c2].copy()
                if "SigmaMu" in c1:
                    s1 = s1.replace(999, np.nan)
                r = safe_corr(s1, s2)
                print(f"  r={r:+.3f}  {desc}")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 5: PER-CYCLE DETAIL TABLES
# ═══════════════════════════════════════════════════════════════════════

def print_cycle_tables(cycles):
    if cycles is None or len(cycles) == 0:
        return

    print("\n" + "=" * 70)
    print("  SECTION 5: PER-CYCLE DETAIL TABLES")
    print("=" * 70)

    # Full cycle table (all cycles)
    headers = ["#", "Mode", "Exit", "Profit$", "Profit%", "Dur(h)", "MaxDD%",
               "TPs", "Warns", "DriftP", "CPD", "PkLt", "P(ruin)%", "sig/mu", "CumProfit$"]
    rows = []
    for _, c in cycles.iterrows():
        sm = c.get("SigmaMuAtStart", 0)
        sm_str = "999+" if sm >= 999 else f"{sm:.1f}"
        rows.append([
            c.get("CycleNumber", "?"),
            c.get("GridMode", "?"),
            c.get("ExitReason", "?"),
            f"{c.get('Profit', 0):+.2f}",
            f"{c.get('ProfitPct', 0):+.2f}",
            f"{c.get('DurationHours', 0):.1f}",
            f"{c.get('MaxCycleDD_Pct', 0):.1f}",
            c.get("TpHits", 0),
            c.get("WarningCloses", 0),
            c.get("DriftPauses", 0),
            c.get("CPDFires", 0),
            f"{c.get('PeakPathLt', 0):.0f}",
            f"{c.get('PeakPRuin', 0)*100:.1f}",
            sm_str,
            f"{c.get('CumulativeProfit', 0):+.2f}",
        ])

    print(f"\n  --- All Cycles ({len(cycles)}) ---")
    print(fmt_table(headers, rows))

    # Top 5 best
    best = cycles.nlargest(min(5, len(cycles)), "Profit")
    print(f"\n  --- Top {len(best)} Best Cycles ---")
    for _, c in best.iterrows():
        print(f"  Cycle {c['CycleNumber']}: ${c['Profit']:+.2f} ({c.get('ProfitPct',0):+.2f}%) "
              f"Mode={c.get('GridMode','?')} Exit={c.get('ExitReason','?')} "
              f"Dur={c.get('DurationHours',0):.1f}h TPs={c.get('TpHits',0)} "
              f"MaxDD={c.get('MaxCycleDD_Pct',0):.1f}% PkLt={c.get('PeakPathLt',0):.0f}")

    # Top 5 worst
    worst = cycles.nsmallest(min(5, len(cycles)), "Profit")
    print(f"\n  --- Top {len(worst)} Worst Cycles ---")
    for _, c in worst.iterrows():
        print(f"  Cycle {c['CycleNumber']}: ${c['Profit']:+.2f} ({c.get('ProfitPct',0):+.2f}%) "
              f"Mode={c.get('GridMode','?')} Exit={c.get('ExitReason','?')} "
              f"Dur={c.get('DurationHours',0):.1f}h TPs={c.get('TpHits',0)} "
              f"MaxDD={c.get('MaxCycleDD_Pct',0):.1f}% PkLt={c.get('PeakPathLt',0):.0f} "
              f"Warns={c.get('WarningCloses',0)}")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 6: REGIME & MODE TRANSITION ANALYSIS
# ═══════════════════════════════════════════════════════════════════════

def print_regime_analysis(cycles, bars, events=None):
    if cycles is None or len(cycles) < 2:
        return

    print("\n" + "=" * 70)
    print("  SECTION 6: REGIME & MODE TRANSITION ANALYSIS")
    print("=" * 70)

    if "GridMode" not in cycles.columns or "ExitReason" not in cycles.columns:
        print("  Insufficient data for transition analysis")
        return

    # Mode transition matrix
    print(f"\n  --- Mode Transition Matrix (from cycle N to N+1) ---")
    transitions = {}
    for i in range(len(cycles) - 1):
        from_mode = cycles.iloc[i]["GridMode"]
        to_mode = cycles.iloc[i + 1]["GridMode"]
        key = f"{from_mode} -> {to_mode}"
        transitions[key] = transitions.get(key, 0) + 1
    for k, v in sorted(transitions.items(), key=lambda x: -x[1]):
        print(f"  {k}: {v} times")

    # Exit → Next mode analysis (does KILL trigger MGT as designed?)
    print(f"\n  --- Exit Reason → Next Cycle Mode ---")
    exit_next = {}
    for i in range(len(cycles) - 1):
        exit_r = cycles.iloc[i]["ExitReason"]
        next_mode = cycles.iloc[i + 1]["GridMode"]
        key = f"{exit_r} → {next_mode}"
        exit_next[key] = exit_next.get(key, 0) + 1
    for k, v in sorted(exit_next.items(), key=lambda x: -x[1]):
        print(f"  {k}: {v} times")

    # Check research-specific: TGT kill should trigger MGT
    tgt_kills = cycles[(cycles["GridMode"] == "TGT") & (cycles["ExitReason"] == "KILL")]
    if len(tgt_kills) > 0:
        tgt_kill_indices = tgt_kills.index.tolist()
        mgt_follows = 0
        for idx in tgt_kill_indices:
            iloc_pos = cycles.index.get_loc(idx)
            if iloc_pos + 1 < len(cycles):
                if cycles.iloc[iloc_pos + 1]["GridMode"] == "MGT":
                    mgt_follows += 1
        print(f"\n  Research check: TGT kills={len(tgt_kills)}, followed by MGT={mgt_follows}")
        if mgt_follows < len(tgt_kills):
            print(f"  Warning: {len(tgt_kills) - mgt_follows} TGT kills were not followed by MGT (expected 100%)")
    else:
        print(f"\n  No TGT kill-switch exits to validate MGT trigger")

    # sigma/mu at cycle start vs actual mode decision
    if "SigmaMuAtStart" in cycles.columns:
        print(f"\n  --- sigma/mu at Cycle Start vs Mode Decision ---")
        for mode in ["BGT", "TGT", "MGT"]:
            subset = cycles[cycles["GridMode"] == mode]
            if len(subset) == 0:
                continue
            sm = subset["SigmaMuAtStart"].replace(999, np.nan)
            if sm.notna().sum() > 0:
                print(f"  {mode}: n={len(subset)}, sigma/mu mean={sm.mean():.2f}, "
                      f"median={sm.median():.2f}, range=[{sm.min():.2f}, {sm.max():.2f}]")
            else:
                print(f"  {mode}: n={len(subset)}, all sigma/mu values are 999 (sentinel/unavailable)")

    # Consecutive losing cycles (drawdown sequences)
    print(f"\n  --- Consecutive Losing Cycle Sequences ---")
    max_streak = 0
    cur_streak = 0
    streaks = []
    for _, c in cycles.iterrows():
        if c["Profit"] <= 0:
            cur_streak += 1
        else:
            if cur_streak > 0:
                streaks.append(cur_streak)
            cur_streak = 0
    if cur_streak > 0:
        streaks.append(cur_streak)
    if streaks:
        print(f"  Max consecutive losses: {max(streaks)}")
        print(f"  Losing streaks: {sorted(streaks, reverse=True)[:10]}")
    else:
        print(f"  No losing streaks (all cycles profitable)")

    # Weekend close/resume and price-level filter events
    if events is not None and "EventType" in events.columns:
        print(f"\n  --- Weekend Close & Price-Level Filter ---")
        wknd_close = events[events["EventType"] == "WEEKEND_CLOSE"]
        wknd_resume = events[events["EventType"] == "WEEKEND_RESUME"]
        pl_blocks = events[events["EventType"] == "PRICELEVEL_BLOCK"]
        pl_clears = events[events["EventType"] == "PRICELEVEL_CLEAR"]

        print(f"  Weekend closes:      {len(wknd_close):,}")
        print(f"  Weekend resumes:     {len(wknd_resume):,}")
        print(f"  Price-level blocks:  {len(pl_blocks):,}")
        print(f"  Price-level clears:  {len(pl_clears):,}")

        if len(wknd_close) != len(wknd_resume):
            print(f"  Warning: weekend close/resume count mismatch ({len(wknd_close)} vs {len(wknd_resume)})")

    if cycles is not None and "ExitReason" in cycles.columns:
        wknd_exits = cycles[cycles["ExitReason"] == "WEEKEND"]
        if len(wknd_exits) > 0:
            avg_pnl = wknd_exits["Profit"].mean() if "Profit" in wknd_exits.columns else 0
            tot_pnl = wknd_exits["Profit"].sum() if "Profit" in wknd_exits.columns else 0
            avg_dur = wknd_exits["DurationHours"].mean() if "DurationHours" in wknd_exits.columns else 0
            win_rate = (wknd_exits["Profit"] > 0).mean() * 100 if "Profit" in wknd_exits.columns else 0
            print(f"  Weekend exit cycles: {len(wknd_exits):,}  avg P/L=${avg_pnl:+.2f}  "
                  f"total=${tot_pnl:+,.2f}  avg dur={avg_dur:.1f}h  win rate={win_rate:.0f}%")
        else:
            print(f"  Weekend exit cycles: 0")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 7: EQUITY CURVE HEALTH
# ═══════════════════════════════════════════════════════════════════════

def print_equity_health(bars, cycles):
    print("\n" + "=" * 70)
    print("  SECTION 7: EQUITY CURVE HEALTH")
    print("=" * 70)

    if "Equity" not in bars.columns or "Time" not in bars.columns:
        print("  Insufficient data")
        return

    equity = bars["Equity"]
    time = bars["Time"]

    # Running max drawdown analysis
    running_max = equity.expanding().max()
    drawdown = (running_max - equity)
    drawdown_pct = drawdown / running_max * 100

    print(f"\n  --- Account-Level Drawdown ---")
    print(f"  Max drawdown:     ${drawdown.max():.2f} ({drawdown_pct.max():.2f}%)")
    max_dd_idx = drawdown_pct.idxmax()
    if pd.notna(max_dd_idx):
        peak_idx = running_max[:max_dd_idx + 1].idxmax()
        print(f"  Peak at:          {time.iloc[peak_idx]} (${equity.iloc[peak_idx]:.2f})")
        print(f"  Trough at:        {time.iloc[max_dd_idx]} (${equity.iloc[max_dd_idx]:.2f})")

    # Recovery analysis
    peak_val = running_max.max()
    recovered = equity >= peak_val * 0.999  # within 0.1% of peak
    if recovered.any():
        last_peak_idx = running_max.idxmax()
        recovery_after = recovered[last_peak_idx:]
        if not recovery_after.all() and recovery_after.any():
            first_loss_after_peak = (~recovery_after).idxmax()
            # Find next recovery
            after_loss = recovery_after[first_loss_after_peak:]
            if after_loss.any():
                recovery_bar = after_loss.idxmax()
                recovery_time = time.iloc[recovery_bar] - time.iloc[first_loss_after_peak]
                print(f"  Recovery time:    {recovery_time}")

    # Equity trend by thirds
    third = len(bars) // 3
    if third > 0:
        eq_1 = equity.iloc[:third]
        eq_2 = equity.iloc[third:2*third]
        eq_3 = equity.iloc[2*third:]
        ret_1 = (eq_1.iloc[-1] / eq_1.iloc[0] - 1) * 100
        ret_2 = (eq_2.iloc[-1] / eq_2.iloc[0] - 1) * 100
        ret_3 = (eq_3.iloc[-1] / eq_3.iloc[0] - 1) * 100
        print(f"\n  --- Equity Trend by Period ---")
        print(f"  First third:  {ret_1:+.2f}% ({time.iloc[0]} to {time.iloc[third-1]})")
        print(f"  Middle third: {ret_2:+.2f}% ({time.iloc[third]} to {time.iloc[2*third-1]})")
        print(f"  Last third:   {ret_3:+.2f}% ({time.iloc[2*third]} to {time.iloc[-1]})")

    # Time underwater (equity below previous peak)
    underwater = drawdown_pct > 0.1  # more than 0.1% below peak
    pct_underwater = underwater.mean() * 100
    print(f"\n  --- Time Underwater ---")
    print(f"  % time below peak: {pct_underwater:.1f}%")

    # Drawdown duration (longest period below peak)
    if underwater.any():
        uw_groups = (underwater != underwater.shift()).cumsum()
        uw_durations = bars[underwater].groupby(uw_groups[underwater])["Time"].agg(["first", "last"])
        if len(uw_durations) > 0:
            uw_durations["duration"] = uw_durations["last"] - uw_durations["first"]
            longest = uw_durations.loc[uw_durations["duration"].idxmax()]
            print(f"  Longest underwater: {longest['duration']} ({longest['first']} to {longest['last']})")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 8: GRID EFFICIENCY ANALYSIS
# ═══════════════════════════════════════════════════════════════════════

def print_grid_efficiency(bars, cycles):
    print("\n" + "=" * 70)
    print("  SECTION 8: GRID EFFICIENCY ANALYSIS")
    print("=" * 70)

    # Position utilization
    if all(c in bars.columns for c in ["OpenBuys", "OpenSells", "ArmedBuys", "ArmedSells"]):
        total_pos = bars["OpenBuys"] + bars["OpenSells"]
        total_armed = bars["ArmedBuys"] + bars["ArmedSells"]
        active_bars = bars[bars["GridState"] == "ACTIVE"] if "GridState" in bars.columns else bars

        print(f"\n  --- Position Utilization (ACTIVE bars) ---")
        if len(active_bars) > 0:
            ap = active_bars["OpenBuys"] + active_bars["OpenSells"]
            aa = active_bars["ArmedBuys"] + active_bars["ArmedSells"]
            print(f"  Avg open positions:   {ap.mean():.1f}")
            print(f"  Max open positions:   {ap.max()}")
            print(f"  Avg armed orders:     {aa.mean():.1f}")
            print(f"  Max armed orders:     {aa.max()}")
            print(f"  Bars with 0 open:     {pct_str((ap == 0).sum(), len(active_bars))}")
            print(f"  Bars with 0 armed:    {pct_str((aa == 0).sum(), len(active_bars))}")

            # Buy/sell balance
            avg_buys = active_bars["OpenBuys"].mean()
            avg_sells = active_bars["OpenSells"].mean()
            if avg_buys + avg_sells > 0:
                buy_ratio = avg_buys / (avg_buys + avg_sells) * 100
                print(f"  Buy/sell ratio:       {buy_ratio:.0f}% buys / {100-buy_ratio:.0f}% sells")

    # TP efficiency from cycle data
    if cycles is not None and len(cycles) > 0:
        if "TpHits" in cycles.columns and "DurationHours" in cycles.columns:
            print(f"\n  --- TP Efficiency ---")
            tp_per_hour = cycles["TpHits"] / cycles["DurationHours"].replace(0, np.nan)
            print(f"  Avg TPs per hour:  {tp_per_hour.mean():.2f}")
            print(f"  Max TPs per hour:  {tp_per_hour.max():.2f}")

            # Compare TP rate for profitable vs losing cycles
            profit_cycles = cycles[cycles["Profit"] > 0]
            loss_cycles = cycles[cycles["Profit"] <= 0]
            if len(profit_cycles) > 0 and len(loss_cycles) > 0:
                tp_rate_profit = profit_cycles["TpHits"].mean()
                tp_rate_loss = loss_cycles["TpHits"].mean()
                print(f"  Avg TPs (profitable cycles): {tp_rate_profit:.1f}")
                print(f"  Avg TPs (losing cycles):     {tp_rate_loss:.1f}")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 9: DRIFT GATE EFFECTIVENESS
# ═══════════════════════════════════════════════════════════════════════

def print_drift_effectiveness(bars, cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 9: DRIFT GATE EFFECTIVENESS")
    print("=" * 70)

    if "GridState" not in bars.columns:
        print("  Insufficient data")
        return

    active_bars = bars[bars["GridState"] == "ACTIVE"]
    paused_bars = bars[bars["GridState"] == "PAUSED"]

    if len(active_bars) == 0 or len(paused_bars) == 0:
        print(f"  ACTIVE bars: {len(active_bars)}, PAUSED bars: {len(paused_bars)}")
        print("  Cannot compare — need both ACTIVE and PAUSED bars")
        return

    # Compare what happens during ACTIVE vs PAUSED
    print(f"\n  --- Market Conditions: ACTIVE vs PAUSED ---")
    for col, label in [("SigmaMu", "sigma/mu"), ("ATR", "ATR"), ("Drift", "Drift"),
                        ("CycleDD_Pct", "Cycle DD %")]:
        if col not in bars.columns:
            continue
        a_vals = active_bars[col].replace(999, np.nan)
        p_vals = paused_bars[col].replace(999, np.nan)
        if a_vals.notna().sum() > 0 and p_vals.notna().sum() > 0:
            print(f"  {label:15s}: ACTIVE mean={a_vals.mean():.4f}  PAUSED mean={p_vals.mean():.4f}")

    # Drift gate pause durations from events
    if events is not None:
        pauses = events[events["EventType"] == "DRIFT_PAUSE"].sort_values("Time")
        resumes = events[events["EventType"] == "DRIFT_RESUME"].sort_values("Time")

        if len(pauses) > 0:
            durations = []
            for _, p in pauses.iterrows():
                matching = resumes[resumes["Time"] > p["Time"]]
                if len(matching) > 0:
                    dur_h = (matching.iloc[0]["Time"] - p["Time"]).total_seconds() / 3600
                    durations.append(dur_h)
            if durations:
                print(f"\n  --- Drift Pause Durations ---")
                print(f"  Count:        {len(durations)}")
                print(f"  Mean:         {np.mean(durations):.1f}h")
                print(f"  Median:       {np.median(durations):.1f}h")
                print(f"  Min:          {np.min(durations):.2f}h")
                print(f"  Max:          {np.max(durations):.1f}h")
                short_pauses = sum(1 for d in durations if d < 1)
                long_pauses = sum(1 for d in durations if d > 24)
                print(f"  < 1h (noise): {short_pauses}")
                print(f"  > 24h (long): {long_pauses}")

    # Key question: do cycles with more drift pauses perform better or worse?
    if cycles is not None and "DriftPauses" in cycles.columns and len(cycles) > 3:
        print(f"\n  --- Drift Pause Impact on Cycle Performance ---")
        no_pause = cycles[cycles["DriftPauses"] == 0]
        has_pause = cycles[cycles["DriftPauses"] > 0]
        many_pause = cycles[cycles["DriftPauses"] > 5]

        for label, subset in [("No pauses", no_pause), ("Has pauses", has_pause), (">5 pauses", many_pause)]:
            if len(subset) > 0:
                print(f"  {label:15s}: n={len(subset):3d}  avg_profit=${subset['Profit'].mean():+.2f}  "
                      f"win_rate={((subset['Profit']>0).mean()*100):.0f}%  "
                      f"avg_DD={subset['MaxCycleDD_Pct'].mean():.1f}%")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 10: WARNING CLOSER EFFECTIVENESS
# ═══════════════════════════════════════════════════════════════════════

def print_warning_effectiveness(cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 10: WARNING CLOSER EFFECTIVENESS")
    print("=" * 70)

    if cycles is None or len(cycles) == 0:
        print("  Insufficient data")
        return

    if "WarningCloses" not in cycles.columns:
        print("  No warning close data")
        return

    no_warn = cycles[cycles["WarningCloses"] == 0]
    has_warn = cycles[cycles["WarningCloses"] > 0]

    print(f"\n  --- Warning Closer Impact ---")
    for label, subset in [("No warns", no_warn), ("Has warns", has_warn)]:
        if len(subset) > 0:
            kill_rate = ((subset["ExitReason"] == "KILL").mean() * 100) if "ExitReason" in subset.columns else 0
            print(f"  {label:15s}: n={len(subset):3d}  avg_profit=${subset['Profit'].mean():+.2f}  "
                  f"avg_DD={subset['MaxCycleDD_Pct'].mean():.1f}%  "
                  f"kill_rate={kill_rate:.0f}%")

    # Did warning closes prevent kills?
    if "ExitReason" in cycles.columns and len(has_warn) > 0:
        warn_profit = has_warn[has_warn["ExitReason"] == "PROFIT"]
        warn_kill = has_warn[has_warn["ExitReason"] == "KILL"]
        print(f"\n  Cycles with warnings that ended PROFIT: {len(warn_profit)}")
        print(f"  Cycles with warnings that ended KILL:   {len(warn_kill)}")
        if len(warn_kill) > 0:
            print(f"  → Warning closer saved {len(warn_profit)} cycles from potential kill")
            print(f"  → But {len(warn_kill)} cycles hit kill switch despite warnings")

    # Warning close events detail
    if events is not None:
        warns = events[events["EventType"] == "WARN_CLOSE"]
        if len(warns) > 0 and "Value1" in warns.columns:
            dd_at_warn = warns["Value1"].astype(float) * 100
            print(f"\n  --- DD at Warning Close ---")
            print(f"  Mean DD:    {dd_at_warn.mean():.1f}%")
            print(f"  Median DD:  {dd_at_warn.median():.1f}%")
            print(f"  Min DD:     {dd_at_warn.min():.1f}%")
            print(f"  Max DD:     {dd_at_warn.max():.1f}%")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 11: RESEARCH VALIDATION (Taranto & Khan)
# ═══════════════════════════════════════════════════════════════════════

def print_research_validation(bars, cycles):
    print("\n" + "=" * 70)
    print("  SECTION 11: RESEARCH VALIDATION (Taranto & Khan Papers)")
    print("=" * 70)

    # 1. Lt Refraction Principle: Path-aware Lt should always <= Formula Lt
    if all(c in bars.columns for c in ["Lt_Formula", "Lt_PathAware", "GridState"]):
        active = bars[bars["GridState"] == "ACTIVE"]
        if len(active) > 0:
            lt_err = active["Lt_Formula"] - active["Lt_PathAware"]
            violations = (lt_err < -0.5).sum()
            total = len(active)
            corr = safe_corr(active["Lt_Formula"], active["Lt_PathAware"])
            print(f"\n  --- Refraction Principle ---")
            print(f"  Formula >= PathAware? {pct_str(total - violations, total)} bars OK")
            print(f"  Lt correlation:       r={corr:.4f}")
            print(f"  Mean Lt_Error:        {lt_err.mean():.3f}")
            print(f"  Std Lt_Error:         {lt_err.std():.3f}")
            if violations > 0:
                print(f"  Observed violation: {violations} bars where PathAware > Formula")
                print(f"  This means more losing positions exist than the formula predicts")
                print(f"  Possible cause: re-arming creates paths not captured by the formula")

    # 2. Gambler's Ruin calibration: P(ruin) should predict kill rate
    if cycles is not None and len(cycles) > 5:
        if "PeakPRuin" in cycles.columns and "ExitReason" in cycles.columns:
            actual_kill_rate = (cycles["ExitReason"] == "KILL").mean()
            avg_p_ruin = cycles["PeakPRuin"].mean()
            print(f"\n  --- Gambler's Ruin Calibration ---")
            print(f"  Actual kill rate:     {actual_kill_rate*100:.1f}%")
            print(f"  Avg peak P(ruin):     {avg_p_ruin*100:.2f}%")
            print(f"  Ratio (actual/pred):  {actual_kill_rate/avg_p_ruin:.2f}x" if avg_p_ruin > 0 else "  Cannot compute ratio")
            if actual_kill_rate > avg_p_ruin * 2:
                print(f"  Warning: actual kill rate is >2x predicted; the P(ruin) formula may understate risk")
                print(f"  This is expected with re-arming (levels can fill/TP/fill again)")

    # 3. Variance accumulation: longer cycles should have worse outcomes
    if cycles is not None and len(cycles) > 5 and "DurationHours" in cycles.columns:
        corr = safe_corr(cycles["DurationHours"], cycles["Profit"])
        corr_dd = safe_corr(cycles["DurationHours"], cycles["MaxCycleDD_Pct"])
        print(f"\n  --- Variance Accumulation ---")
        print(f"  Duration vs Profit:   r={corr:+.3f}")
        print(f"  Duration vs Max DD:   r={corr_dd:+.3f}")
        if corr_dd > 0.3:
            print(f"  Observation: longer cycles accumulate more drawdown (r={corr_dd:+.3f})")
            print(f"  This validates the research: restart resets variance")
        else:
            print(f"  Duration-DD correlation is weak — age limit may be too aggressive")

    # 4. Kill switch: does restarting after kill actually help?
    if cycles is not None and len(cycles) > 3 and "ExitReason" in cycles.columns:
        print(f"\n  --- Kill Switch Restart Effectiveness ---")
        for i in range(len(cycles) - 1):
            if cycles.iloc[i]["ExitReason"] == "KILL":
                next_profit = cycles.iloc[i + 1]["Profit"]
                # Collect all post-kill cycle profits
        post_kill = []
        post_profit = []
        post_age = []
        post_weekend = []
        post_regime = []
        for i in range(len(cycles) - 1):
            exit_r = cycles.iloc[i]["ExitReason"]
            next_p = cycles.iloc[i + 1]["Profit"]
            if exit_r == "KILL":
                post_kill.append(next_p)
            elif exit_r == "PROFIT":
                post_profit.append(next_p)
            elif exit_r == "AGE":
                post_age.append(next_p)
            elif exit_r == "WEEKEND":
                post_weekend.append(next_p)
            elif exit_r == "REGIME":
                post_regime.append(next_p)
        for label, data in [("After KILL", post_kill), ("After PROFIT", post_profit),
                            ("After AGE", post_age), ("After WEEKEND", post_weekend),
                            ("After REGIME", post_regime)]:
            if data:
                avg = np.mean(data)
                win = sum(1 for d in data if d > 0)
                print(f"  {label:15s}: n={len(data):3d}  avg_next=${avg:+.2f}  next_win_rate={win/len(data)*100:.0f}%")

    # 5. Dynamic lots: do lots shrink under stress?
    if "BaseLot" in bars.columns and "CycleDD_Pct" in bars.columns:
        print(f"\n  --- Dynamic Lot Sizing ---")
        unique_lots = bars["BaseLot"].nunique()
        print(f"  Unique base lot values: {unique_lots}")
        if unique_lots > 1:
            corr = safe_corr(bars["BaseLot"], bars["Equity"])
            print(f"  BaseLot vs Equity:    r={corr:+.3f}")
            print(f"  Lot range:            {bars['BaseLot'].min():.4f} to {bars['BaseLot'].max():.4f}")
            if corr > 0.5:
                print(f"  Observation: lot size compounds with equity (r={corr:+.3f})")
        else:
            print(f"  Base lot is fixed at {bars['BaseLot'].iloc[0]:.4f}; dynamic lot sizing may be disabled")

    # 6. ATR-dynamic spacing: does spacing adapt?
    if "GridSpacing" in bars.columns:
        print(f"\n  --- ATR-Dynamic Spacing ---")
        unique_spacings = bars["GridSpacing"].nunique()
        print(f"  Unique spacing values: {unique_spacings}")
        if unique_spacings > 1:
            if "ATR" in bars.columns:
                corr = safe_corr(bars["GridSpacing"], bars["ATR"])
                print(f"  Spacing vs ATR:       r={corr:+.3f}")
            print(f"  Spacing range:        {bars['GridSpacing'].min():.5f} to {bars['GridSpacing'].max():.5f}")
        else:
            print(f"  Spacing is fixed at {bars['GridSpacing'].iloc[0]:.5f}; ATR-based spacing may be disabled")


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 12: ANOMALY DETECTION & WORST MOMENTS
# ═══════════════════════════════════════════════════════════════════════

def print_anomalies(bars, cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 12: ANOMALY DETECTION & WORST MOMENTS")
    print("=" * 70)

    # Top 10 worst drawdown bars
    if "CycleDD_Pct" in bars.columns:
        print(f"\n  --- Top 10 Worst Drawdown Bars ---")
        worst = bars.nlargest(10, "CycleDD_Pct")
        headers = ["Time", "DD%", "RPR%", "Equity", "OpenPos", "Lt", "Cycle", "State"]
        rows = []
        for _, r in worst.iterrows():
            rows.append([
                str(r.get("Time", "?")),
                f"{r['CycleDD_Pct']:.2f}",
                f"{r.get('SnapshotRPR_Pct', 0):.2f}",
                f"${r.get('Equity', 0):.2f}",
                f"{r.get('OpenBuys', 0)+r.get('OpenSells', 0)}",
                f"{r.get('Lt_Formula', 0):.1f}",
                r.get("CycleNumber", "?"),
                r.get("GridState", "?"),
            ])
        print(fmt_table(headers, rows))

    # Bars with highest Lt (most losing positions)
    if "Lt_PathAware" in bars.columns:
        print(f"\n  --- Top 10 Highest Lt (Path-Aware) Bars ---")
        worst_lt = bars.nlargest(10, "Lt_PathAware")
        headers = ["Time", "PathLt", "FormulaLt", "Error", "DD%", "OpenPos", "Cycle", "Mode"]
        rows = []
        for _, r in worst_lt.iterrows():
            rows.append([
                str(r.get("Time", "?")),
                f"{r['Lt_PathAware']:.1f}",
                f"{r.get('Lt_Formula', 0):.1f}",
                f"{r.get('Lt_Error', 0):.1f}",
                f"{r.get('CycleDD_Pct', 0):.2f}",
                f"{r.get('OpenBuys', 0)+r.get('OpenSells', 0)}",
                r.get("CycleNumber", "?"),
                r.get("GridMode", "?"),
            ])
        print(fmt_table(headers, rows))

    # Equity drops: largest bar-to-bar equity changes
    if "Equity" in bars.columns and len(bars) > 1:
        equity_change = bars["Equity"].diff()
        worst_drops = equity_change.nsmallest(10)
        print(f"\n  --- Top 10 Worst Bar-to-Bar Equity Drops ---")
        headers = ["Time", "Drop$", "Equity After", "Cycle", "State", "OpenPos"]
        rows = []
        for idx in worst_drops.index:
            r = bars.iloc[idx]
            rows.append([
                str(r.get("Time", "?")),
                f"${equity_change.iloc[idx]:.2f}",
                f"${r.get('Equity', 0):.2f}",
                r.get("CycleNumber", "?"),
                r.get("GridState", "?"),
                f"{r.get('OpenBuys', 0)+r.get('OpenSells', 0)}",
            ])
        print(fmt_table(headers, rows))

    # State transition anomalies (ACTIVE → IDLE without CLOSING)
    if "GridState" in bars.columns and len(bars) > 1:
        state_changes = bars[bars["GridState"] != bars["GridState"].shift()]
        bad_transitions = []
        for i in range(1, len(state_changes)):
            prev = state_changes.iloc[i-1]["GridState"]
            curr = state_changes.iloc[i]["GridState"]
            if prev == "ACTIVE" and curr == "IDLE":
                bad_transitions.append((state_changes.iloc[i]["Time"], prev, curr))
        if bad_transitions:
            print(f"\n  --- Suspicious State Transitions ---")
            for t, p, c in bad_transitions[:10]:
                print(f"  {t}: {p} → {c} (should go through CLOSING)")

    # Cycles with 0 TPs (grid not engaging)
    if cycles is not None and "TpHits" in cycles.columns:
        zero_tp = cycles[cycles["TpHits"] == 0]
        if len(zero_tp) > 0:
            print(f"\n  --- Cycles With Zero TP Hits ({len(zero_tp)}) ---")
            headers = ["Cycle", "Mode", "Exit", "Dur(h)", "Profit$", "DD%", "DriftP", "OpenAtEnd"]
            rows = []
            for _, c in zero_tp.iterrows():
                rows.append([
                    c.get("CycleNumber", "?"),
                    c.get("GridMode", "?"),
                    c.get("ExitReason", "?"),
                    f"{c.get('DurationHours', 0):.1f}",
                    f"${c.get('Profit', 0):+.2f}",
                    f"{c.get('MaxCycleDD_Pct', 0):.1f}",
                    c.get("DriftPauses", 0),
                    c.get("PositionsAtEnd", 0),
                ])
            print(fmt_table(headers, rows))


# ═══════════════════════════════════════════════════════════════════════
#  SECTION 13: RAW DATA SAMPLES
# ═══════════════════════════════════════════════════════════════════════

def print_raw_samples(bars, cycles, events):
    print("\n" + "=" * 70)
    print("  SECTION 13: RAW DATA SAMPLES")
    print("=" * 70)

    # First 5 bars
    print(f"\n  --- First 5 Bars ---")
    if len(bars) > 0:
        sample = bars.head(5)
        for _, r in sample.iterrows():
            print(f"  {r.get('Time','')} | Bid={r.get('Bid',0):.2f} Eq=${r.get('Equity',0):.2f} "
                  f"DD={r.get('CycleDD_Pct',0):.2f}% Lt={r.get('Lt_Formula',0):.1f}/{r.get('Lt_PathAware',0):.1f} "
                  f"Open={r.get('OpenBuys',0)}B/{r.get('OpenSells',0)}S "
                  f"State={r.get('GridState','')} Mode={r.get('GridMode','')} "
                  f"s/m={r.get('SigmaMu',0):.1f} Cycle={r.get('CycleNumber','')}")

    # Last 5 bars
    print(f"\n  --- Last 5 Bars ---")
    if len(bars) > 0:
        sample = bars.tail(5)
        for _, r in sample.iterrows():
            print(f"  {r.get('Time','')} | Bid={r.get('Bid',0):.2f} Eq=${r.get('Equity',0):.2f} "
                  f"DD={r.get('CycleDD_Pct',0):.2f}% Lt={r.get('Lt_Formula',0):.1f}/{r.get('Lt_PathAware',0):.1f} "
                  f"Open={r.get('OpenBuys',0)}B/{r.get('OpenSells',0)}S "
                  f"State={r.get('GridState','')} Mode={r.get('GridMode','')} "
                  f"s/m={r.get('SigmaMu',0):.1f} Cycle={r.get('CycleNumber','')}")

    # First 10 events
    if events is not None and len(events) > 0:
        print(f"\n  --- First 10 Events ---")
        for _, e in events.head(10).iterrows():
            print(f"  {e.get('Time','')} | Cycle {e.get('CycleNumber','')} | "
                  f"{e.get('EventType',''):15s} | v1={e.get('Value1',0):.2f} v2={e.get('Value2',0):.2f} "
                  f"| {e.get('Detail','')}")

    # Last 10 events
    if events is not None and len(events) > 0:
        print(f"\n  --- Last 10 Events ---")
        for _, e in events.tail(10).iterrows():
            print(f"  {e.get('Time','')} | Cycle {e.get('CycleNumber','')} | "
                  f"{e.get('EventType',''):15s} | v1={e.get('Value1',0):.2f} v2={e.get('Value2',0):.2f} "
                  f"| {e.get('Detail','')}")


# ═══════════════════════════════════════════════════════════════════════
#  CHARTS (kept as optional visual output)
# ═══════════════════════════════════════════════════════════════════════

def make_charts(bars, cycles, events, output_dir):
    plt, mdates, Patch, Line2D = _import_matplotlib()
    os.makedirs(output_dir, exist_ok=True)
    time = bars["Time"] if "Time" in bars.columns else bars.index

    # 01: Lt Verification
    try:
        fig, axes = plt.subplots(3, 1, figsize=(16, 12), sharex=True)
        fig.suptitle("01 — Lt Verification (Refraction Principle)", fontsize=14, fontweight="bold")
        active_mask = bars["GridState"] == "ACTIVE"
        active = bars[active_mask]
        at = active["Time"]
        axes[0].plot(at, active["Lt_Formula"], label="Lt Formula", alpha=0.8)
        axes[0].plot(at, active["Lt_PathAware"], label="Lt Path-Aware", alpha=0.8)
        axes[0].set_ylabel("Lt (levels)"); axes[0].legend(); axes[0].set_title("Lt Formula vs Path-Aware (ACTIVE)")
        colors = ["green" if e >= -0.5 else "red" for e in active["Lt_Error"]]
        axes[1].bar(at, active["Lt_Error"], color=colors, alpha=0.7, width=0.02)
        axes[1].axhline(0, color="black", linewidth=0.5); axes[1].set_ylabel("Lt Error")
        axes[1].set_title("Lt Error (red = violation)")
        axes[2].scatter(active["Lt_Formula"], active["Lt_PathAware"], alpha=0.3, s=10, c="steelblue")
        if len(active) > 0:
            ml = max(active["Lt_Formula"].max(), active["Lt_PathAware"].max())
            axes[2].plot([0, ml], [0, ml], "r--", alpha=0.5, label="y=x")
        axes[2].set_xlabel("Lt Formula"); axes[2].set_ylabel("Lt Path-Aware"); axes[2].legend()
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "01_lt_verification.png"), dpi=150); plt.close()
        print("  Saved chart: 01_lt_verification.png")
    except Exception as e:
        print(f"  Skipped chart 01: {e}")

    # 02: Equity Curve
    try:
        fig, axes = plt.subplots(3, 1, figsize=(16, 14), sharex=True)
        fig.suptitle("02 — Equity Curve & Position Analysis", fontsize=14, fontweight="bold")
        ax1 = axes[0]; ax1_r = ax1.twinx()
        if "GridState" in bars.columns:
            prev_s, bs = None, 0
            for idx in range(len(bars)):
                cs = bars.iloc[idx]["GridState"]
                if cs != prev_s and prev_s is not None:
                    ax1.axvspan(time.iloc[bs], time.iloc[idx-1], alpha=0.15, color=state_color(prev_s), lw=0)
                    bs = idx
                prev_s = cs
            if prev_s: ax1.axvspan(time.iloc[bs], time.iloc[-1], alpha=0.15, color=state_color(prev_s), lw=0)
        ax1.plot(time, bars["Equity"], label="Equity", color="blue", linewidth=1)
        ax1.plot(time, bars["Balance"], label="Balance", color="gray", linewidth=0.8, alpha=0.7)
        ax1.set_ylabel("Account ($)"); ax1.legend(loc="upper left")
        ax1_r.plot(time, bars["Bid"], label="Price", color="orange", linewidth=0.5, alpha=0.6)
        ax1_r.set_ylabel("Price"); ax1_r.legend(loc="upper right")
        if cycles is not None and "EndTime" in cycles.columns:
            for _, c in cycles.iterrows():
                if pd.notna(c["EndTime"]):
                    ax1.axvline(c["EndTime"], color=exit_color(c.get("ExitReason","")), linewidth=0.8, alpha=0.5)
        ax1.set_title("Equity, Balance & Price (background = GridState)")
        axes[1].fill_between(time, bars["OpenBuys"], alpha=0.5, color="green", label="Open Buys")
        axes[1].fill_between(time, -bars["OpenSells"], alpha=0.5, color="red", label="Open Sells")
        axes[1].axhline(0, color="black", linewidth=0.5); axes[1].set_ylabel("Positions"); axes[1].legend()
        axes[1].set_title("Open Positions (buys+, sells-)")
        ax3 = axes[2]; ax3r = ax3.twinx()
        ax3.bar(time, bars["DtLevels"], alpha=0.5, color="salmon", label="Dt", width=0.02)
        ax3.bar(time, -bars["UtLevels"], alpha=0.5, color="skyblue", label="Ut", width=0.02)
        ax3.set_ylabel("Levels"); ax3r.plot(time, bars["Lt_Formula"], color="purple", linewidth=0.8, alpha=0.7, label="Lt")
        ax3r.set_ylabel("Lt"); ax3.legend(loc="upper left"); ax3r.legend(loc="upper right")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "02_equity_curve.png"), dpi=150); plt.close()
        print("  Saved chart: 02_equity_curve.png")
    except Exception as e:
        print(f"  Skipped chart 02: {e}")

    # 03: Cycle Analysis
    if cycles is not None and len(cycles) > 0:
        try:
            fig, axes = plt.subplots(2, 2, figsize=(16, 12))
            fig.suptitle("03 — Cycle Analysis", fontsize=14, fontweight="bold")
            ax = axes[0,0]; colors = [mode_color(m) for m in cycles["GridMode"]]
            ax.bar(range(len(cycles)), cycles["Profit"], color=colors, alpha=0.7)
            ax2 = ax.twinx(); ax2.plot(range(len(cycles)), cycles["CumulativeProfit"], color="black", linewidth=1.5)
            ax.set_xlabel("Cycle"); ax.set_ylabel("Profit ($)"); ax2.set_ylabel("Cumulative ($)")
            ax.set_title("Per-Cycle Profit (color = mode)")
            ax = axes[0,1]
            if "ExitReason" in cycles.columns:
                rc = cycles["ExitReason"].value_counts()
                ax.pie(rc, labels=rc.index, colors=[exit_color(r) for r in rc.index], autopct="%1.0f%%", startangle=90)
            ax.set_title("Exit Reasons")
            ax = axes[1,0]
            if "ExitReason" in cycles.columns and "ProfitPct" in cycles.columns:
                reasons = sorted(cycles["ExitReason"].unique())
                grps = [cycles[cycles["ExitReason"]==r]["ProfitPct"].dropna() for r in reasons]
                ne = [(r,g) for r,g in zip(reasons,grps) if len(g)>0]
                if ne:
                    bp = ax.boxplot([g for _,g in ne], labels=[r for r,_ in ne], patch_artist=True)
                    for p,(r,_) in zip(bp["boxes"],ne): p.set_facecolor(exit_color(r)); p.set_alpha(0.6)
            ax.set_ylabel("Profit %"); ax.axhline(0, color="gray", linewidth=0.5); ax.set_title("Profit % by Exit Reason")
            ax = axes[1,1]
            if "PeakPathLt" in cycles.columns:
                sc = ax.scatter(cycles["PeakPathLt"], cycles["ProfitPct"], c=cycles["Profit"], cmap="RdYlGn", alpha=0.7, s=40)
                plt.colorbar(sc, ax=ax, label="Profit ($)")
                ax.set_xlabel("Peak Lt"); ax.set_ylabel("Profit %")
            ax.set_title("Peak Lt vs Profit %")
            plt.tight_layout(); plt.savefig(os.path.join(output_dir, "03_cycle_analysis.png"), dpi=150); plt.close()
            print("  Saved chart: 03_cycle_analysis.png")
        except Exception as e:
            print(f"  Skipped chart 03: {e}")

    # 04: Regime/Mode
    try:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle("04 — Regime & Mode Analysis", fontsize=14, fontweight="bold")
        ax = axes[0,0]; sm = bars["SigmaMu"].clip(upper=20)
        ax.plot(time, sm, linewidth=0.8, alpha=0.8, label="sigma/mu")
        ax.axhline(1.5, color="red", linestyle="--", alpha=0.7, label="TGT (1.5)")
        ax.axhline(2.0, color="orange", linestyle="--", alpha=0.5, label="Drift gate (2.0)")
        ax.set_ylabel("sigma/mu"); ax.legend(fontsize=8); ax.set_title("sigma/mu Ratio")
        ax = axes[0,1]
        if cycles is not None and "GridMode" in cycles.columns:
            mc = cycles["GridMode"].value_counts()
            ax.bar(mc.index, mc.values, color=[mode_color(m) for m in mc.index], alpha=0.7)
        ax.set_ylabel("Count"); ax.set_title("Cycles by Mode")
        ax = axes[1,0]
        if cycles is not None and "GridMode" in cycles.columns and "ProfitPct" in cycles.columns:
            mp = sorted(cycles["GridMode"].unique())
            grps = [cycles[cycles["GridMode"]==m]["ProfitPct"].dropna() for m in mp]
            ne = [(m,g) for m,g in zip(mp,grps) if len(g)>0]
            if ne:
                bp = ax.boxplot([g for _,g in ne], labels=[m for m,_ in ne], patch_artist=True)
                for p,(m,_) in zip(bp["boxes"],ne): p.set_facecolor(mode_color(m)); p.set_alpha(0.6)
        ax.set_ylabel("Profit %"); ax.axhline(0, color="gray", linewidth=0.5); ax.set_title("Profit % by Mode")
        ax = axes[1,1]
        if cycles is not None and "SigmaMuAtStart" in cycles.columns:
            sm2 = cycles["SigmaMuAtStart"].clip(upper=20)
            ax.scatter(sm2, cycles["ProfitPct"], c=[mode_color(m) for m in cycles["GridMode"]], alpha=0.6, s=40)
            ax.set_xlabel("sigma/mu at Start"); ax.set_ylabel("Profit %")
        ax.set_title("sigma/mu at Start vs Profit %")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "04_regime_mode_analysis.png"), dpi=150); plt.close()
        print("  Saved chart: 04_regime_mode_analysis.png")
    except Exception as e:
        print(f"  Skipped chart 04: {e}")

    # 05: Risk
    try:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle("05 — Risk Analysis", fontsize=14, fontweight="bold")
        ax = axes[0,0]; ax.plot(time, bars["CycleDD_Pct"], linewidth=0.8, color="crimson", alpha=0.8)
        ax.axhline(KILL_THRESHOLD_PCT, color="red", linestyle="--", label=f"Kill ({KILL_THRESHOLD_PCT}%)")
        ax.axhline(WARNING_THRESHOLD_PCT, color="orange", linestyle="--", label=f"Warn ({WARNING_THRESHOLD_PCT}%)")
        ax.set_ylabel("Cycle DD %"); ax.legend(); ax.set_title("Cycle Drawdown %")
        ax = axes[0,1]
        if "RuinProb_T53" in bars.columns:
            act = bars[bars["GridState"]=="ACTIVE"]
            ax.plot(act["Time"], act["RuinProb_T53"]*100, linewidth=0.8, color="darkred", alpha=0.8)
        ax.set_ylabel("P(ruin) %"); ax.set_title("P(ruin) T53 (ACTIVE)")
        ax = axes[1,0]
        if "Lt_Formula" in bars.columns and "RuinProb_T53" in bars.columns:
            act = bars[bars["GridState"]=="ACTIVE"]
            sc = ax.scatter(act["Lt_Formula"], act["CycleDD_Pct"], c=act["RuinProb_T53"]*100, cmap="Reds", alpha=0.3, s=10)
            plt.colorbar(sc, ax=ax, label="P(ruin) %")
        ax.set_xlabel("Lt"); ax.set_ylabel("DD %"); ax.set_title("Lt vs DD (color=P(ruin))")
        ax = axes[1,1]
        if cycles is not None and "MaxCycleDD_Pct" in cycles.columns:
            colors = ["red" if d>KILL_THRESHOLD_PCT else "orange" if d>WARNING_THRESHOLD_PCT else "green" for d in cycles["MaxCycleDD_Pct"]]
            ax.bar(range(len(cycles)), cycles["MaxCycleDD_Pct"], color=colors, alpha=0.7)
            ax.axhline(KILL_THRESHOLD_PCT, color="red", linestyle="--")
            ax.axhline(WARNING_THRESHOLD_PCT, color="orange", linestyle="--")
            ax.set_xlabel("Cycle"); ax.set_ylabel("Max DD %")
        ax.set_title("Max DD per Cycle")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "05_risk_analysis.png"), dpi=150); plt.close()
        print("  Saved chart: 05_risk_analysis.png")
    except Exception as e:
        print(f"  Skipped chart 05: {e}")

    # 06: Drift/CPD
    try:
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle("06 — Drift Gate & CPD CUSUM", fontsize=14, fontweight="bold")
        ax = axes[0,0]; ax.plot(time, bars["ATR"], label="ATR", color="blue", linewidth=0.8, alpha=0.8)
        axr = ax.twinx(); axr.plot(time, bars["Drift"], label="Drift", color="red", linewidth=0.8, alpha=0.6)
        ax.set_ylabel("ATR"); axr.set_ylabel("Drift"); ax.legend(loc="upper left"); axr.legend(loc="upper right")
        ax.set_title("ATR & Drift")
        ax = axes[0,1]; ax.plot(time, bars["Bid"], color="gray", linewidth=0.5, alpha=0.5, label="Price")
        if events is not None:
            p = events[events["EventType"]=="DRIFT_PAUSE"]; r = events[events["EventType"]=="DRIFT_RESUME"]
            med = bars["Bid"].median()
            if len(p)>0: ax.scatter(p["Time"], [med]*len(p), marker="v", color="red", s=30, alpha=0.7, label="Pause", zorder=5)
            if len(r)>0: ax.scatter(r["Time"], [med]*len(r), marker="^", color="green", s=30, alpha=0.7, label="Resume", zorder=5)
        ax.legend(fontsize=8); ax.set_title("Drift Events on Price")
        ax = axes[1,0]
        if "CUSUM_SHigh" in bars.columns:
            ax.plot(time, bars["CUSUM_SHigh"], label="SHigh", color="crimson", linewidth=0.8)
            ax.plot(time, bars["CUSUM_SLow"], label="SLow", color="navy", linewidth=0.8)
            if events is not None:
                cpd = events[events["EventType"]=="CPD_FIRE"]
                if len(cpd)>0:
                    mx = max(bars["CUSUM_SHigh"].max(), bars["CUSUM_SLow"].max())
                    ax.scatter(cpd["Time"], [mx*0.9]*len(cpd), marker="*", color="gold", s=50, alpha=0.8, label="Fire", zorder=5)
        ax.set_ylabel("CUSUM"); ax.legend(fontsize=8); ax.set_title("CUSUM + Fire Markers")
        ax = axes[1,1]
        if events is not None:
            paus = events[events["EventType"]=="DRIFT_PAUSE"].sort_values("Time")
            resu = events[events["EventType"]=="DRIFT_RESUME"].sort_values("Time")
            durs = []
            for _, pp in paus.iterrows():
                mm = resu[resu["Time"]>pp["Time"]]
                if len(mm)>0: durs.append((mm.iloc[0]["Time"]-pp["Time"]).total_seconds()/3600)
            if durs:
                ax.hist(durs, bins=min(20,len(durs)), color="salmon", alpha=0.7, edgecolor="black")
                ax.set_xlabel("Duration (h)"); ax.set_ylabel("Count")
                ax.set_title(f"Pause Durations (n={len(durs)}, med={np.median(durs):.1f}h)")
            else: ax.set_title("No pause/resume pairs")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "06_drift_cpd_analysis.png"), dpi=150); plt.close()
        print("  Saved chart: 06_drift_cpd_analysis.png")
    except Exception as e:
        print(f"  Skipped chart 06: {e}")

    # 07: Warning Closer
    try:
        fig, axes = plt.subplots(3, 1, figsize=(16, 12))
        fig.suptitle("07 — Warning Closer Analysis", fontsize=14, fontweight="bold")
        ax = axes[0]; ax.plot(time, bars["CycleDD_Pct"], color="crimson", linewidth=0.8, alpha=0.7)
        ax.axhline(WARNING_THRESHOLD_PCT, color="orange", linestyle="--", label=f"Warn ({WARNING_THRESHOLD_PCT}%)")
        if events is not None:
            w = events[events["EventType"]=="WARN_CLOSE"]
            if len(w)>0: ax.scatter(w["Time"], [WARNING_THRESHOLD_PCT+1]*len(w), marker="x", color="purple", s=40, alpha=0.8, label="Warn Close", zorder=5)
        ax.set_ylabel("DD %"); ax.legend(); ax.set_title("Warning Closes on DD Timeline")
        ax = axes[1]
        if cycles is not None and "WarningCloses" in cycles.columns:
            ax.scatter(cycles["WarningCloses"], cycles["ProfitPct"], c=[exit_color(r) for r in cycles["ExitReason"]], alpha=0.6, s=40)
            ax.set_xlabel("Warning Closes"); ax.set_ylabel("Profit %")
        ax.set_title("Warning Closes vs Profit %")
        ax = axes[2]
        if events is not None:
            w = events[events["EventType"]=="WARN_CLOSE"]
            if len(w)>0 and "Value1" in w.columns:
                dv = w["Value1"].astype(float)*100
                ax.hist(dv, bins=min(20,len(dv)), color="purple", alpha=0.7, edgecolor="black")
                ax.set_xlabel("DD % at Close"); ax.set_ylabel("Count")
                ax.set_title(f"DD at Warning Close (n={len(w)}, med={dv.median():.1f}%)")
            else: ax.set_title("No warning events")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "07_warning_closer.png"), dpi=150); plt.close()
        print("  Saved chart: 07_warning_closer.png")
    except Exception as e:
        print(f"  Skipped chart 07: {e}")

    # 08: Event Timeline
    try:
        fig, ax = plt.subplots(figsize=(16, 6))
        fig.suptitle("08 — Event Timeline", fontsize=14, fontweight="bold")
        if events is not None and len(events) > 0:
            et = sorted(events["EventType"].unique()); ty = {t:i for i,t in enumerate(et)}
            cmap = plt.cm.get_cmap("tab20", len(et))
            for _, row in events.iterrows():
                ax.scatter(row["Time"], ty[row["EventType"]], color=cmap(ty[row["EventType"]]), s=8, alpha=0.6)
            ax.set_yticks(range(len(et))); ax.set_yticklabels(et, fontsize=8); ax.set_xlabel("Time")
            if cycles is not None and "EndTime" in cycles.columns:
                for _, c in cycles.iterrows():
                    if pd.notna(c["EndTime"]): ax.axvline(c["EndTime"], color="gray", linewidth=0.3, alpha=0.5)
        ax.set_title("All Events (vertical lines = cycle boundaries)")
        plt.tight_layout(); plt.savefig(os.path.join(output_dir, "08_event_timeline.png"), dpi=150); plt.close()
        print("  Saved chart: 08_event_timeline.png")
    except Exception as e:
        print(f"  Skipped chart 08: {e}")


# ═══════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(description="BGC Grid EA Backtest Analysis")
    parser.add_argument("csv_dir", nargs="?", default=DEFAULT_CSV_DIR,
                        help="Path to CSV directory (default: MT5 Common Files)")
    parser.add_argument("--no-charts", action="store_true",
                        help="Skip chart generation (text-only output, much faster)")
    parser.add_argument("--date", type=str, default=None,
                        help="Date suffix to select specific CSV files (e.g. 20260129)")
    args = parser.parse_args()

    csv_dir = args.csv_dir

    if not os.path.isdir(csv_dir):
        print(f"Error: directory not found: {csv_dir}")
        sys.exit(1)

    print(f"CSV directory: {csv_dir}")
    if not args.no_charts:
        print(f"Output dir:    {OUTPUT_DIR}")
    print()

    bars, cycles, events = load_data(csv_dir, args.date)

    # Text analysis sections (primary output for detailed review)
    run_bug_detection(bars, cycles, events)        # Section 1
    print_summary(bars, cycles, events)            # Section 2
    print_distributions(bars, cycles)              # Section 3
    print_correlations(bars, cycles)               # Section 4
    print_cycle_tables(cycles)                     # Section 5
    print_regime_analysis(cycles, bars, events)     # Section 6
    print_equity_health(bars, cycles)              # Section 7
    print_grid_efficiency(bars, cycles)            # Section 8
    print_drift_effectiveness(bars, cycles, events)# Section 9
    print_warning_effectiveness(cycles, events)    # Section 10
    print_research_validation(bars, cycles)        # Section 11
    print_anomalies(bars, cycles, events)          # Section 12
    print_raw_samples(bars, cycles, events)        # Section 13

    # Charts (optional — skip with --no-charts)
    if not args.no_charts:
        print(f"\nWriting charts to {OUTPUT_DIR}...")
        make_charts(bars, cycles, events, OUTPUT_DIR)

    print("\nAnalysis finished.")


if __name__ == "__main__":
    main()
