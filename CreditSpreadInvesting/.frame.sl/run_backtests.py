# /// script
# requires-python = ">=3.12,<3.15"
# dependencies = [
#     "numba>=0.60.0",
#     "numpy>=1.26.0,<2.3.0",
#     "polars>=1.0.0",
# ]
# [tool.uv]
# exclude-newer = "2026-08-25T00:00:00Z"
# ///

from __future__ import annotations

import argparse
import json
import re
import sys
import time
from collections.abc import Callable, Iterable, Iterator, Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np
import polars as pl

FRAME_ROOT = Path("/g/hedge/frame")
SCRIPT_ROOT = Path(__file__).resolve().parent
if str(FRAME_ROOT) not in sys.path:
    sys.path.insert(0, str(FRAME_ROOT))

from engine import BatchEngine, FeatureStore, MarketData, load_market
from strategies import STRATEGIES

SignalGenerator = Callable[
    [FeatureStore, Mapping[str, Any]],
    tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray],
]
StrategyRecord = dict[str, Any]

SUMMARY_SCHEMA: dict[str, Any] = {
    "variant_idx": pl.Int64,
    "source_logic_id": pl.String,
    "strategy_id": pl.String,
    "hypothesis": pl.String,
    "position": pl.String,
    "entry_conversion": pl.String,
    "required_bar_interval": pl.String,
    "source_refs": pl.String,
    "source_summary": pl.String,
    "source_requirements": pl.String,
    "proxy_assumptions": pl.String,
    "entry_origin": pl.String,
    "exit_origin": pl.String,
    "signal_parameter_names": pl.String,
    "signal_params": pl.String,
    "risk_params": pl.String,
    "stop_atr": pl.Float64,
    "target_r": pl.Float64,
    "max_bars": pl.Int64,
    "atr_length": pl.Int64,
    "slippage": pl.Float64,
    "fee": pl.Float64,
    "bar_interval": pl.String,
    "net_pnl": pl.Float64,
    "trades": pl.Int64,
    "win_rate": pl.Float64,
    "max_drawdown": pl.Float64,
    "sharpe": pl.Float64,
}

FILE_STATUSES = ("processed", "ignored", "duplicate", "skipped", "failed")
INTERVAL_PATTERN = re.compile(
    r"^(?P<count>[0-9]+(?:\.[0-9]+)?)\s*(?P<unit>m|min|mins|minute|minutes|h|hr|hour|hours|d|day|days|w|week|weeks)$",
    re.IGNORECASE,
)


@dataclass(frozen=True, slots=True)
class VariantSpec:
    variant_idx: int
    strategy: StrategyRecord
    signal_params: dict[str, Any]
    risk_params: dict[str, float | int]


def _json_text(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, default=str)


def _canonical_interval(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip().lower()
    if not text or text in {"none", "any", "unspecified", "unspecified_by_source"}:
        return None
    if "unspecified" in text or "preserve_dataset" in text:
        return None
    aliases = {
        "minute": "1m",
        "minutes": "1m",
        "hour": "1h",
        "hours": "1h",
        "daily": "1d",
        "day": "1d",
        "days": "1d",
        "weekly": "1w",
        "week": "1w",
        "weeks": "1w",
    }
    text = aliases.get(text, text)
    match = INTERVAL_PATTERN.fullmatch(text)
    if match is None:
        return text
    count = float(match.group("count"))
    unit = match.group("unit").lower()
    if unit in {"m", "min", "mins", "minute", "minutes"}:
        minutes = count
    elif unit in {"h", "hr", "hour", "hours"}:
        minutes = count * 60.0
    elif unit in {"d", "day", "days"}:
        minutes = count * 1440.0
    else:
        minutes = count * 10080.0
    if minutes.is_integer():
        return f"{int(minutes)}m"
    return f"{minutes:g}m"


def _source_required_interval(strategy: Mapping[str, Any]) -> str | None:
    direct = strategy.get("required_bar_interval")
    if direct not in (None, ""):
        return _canonical_interval(direct)
    requirements = strategy.get("source_requirements")
    if isinstance(requirements, Mapping):
        return _canonical_interval(requirements.get("required_bar_interval"))
    return None


def _is_proxy(strategy: Mapping[str, Any]) -> bool:
    conversion = str(strategy.get("entry_conversion", "")).strip().lower()
    classification = str(strategy.get("classification", "")).strip().lower()
    return conversion == "proxy" or classification == "proxy"


def _normalise_registry() -> list[StrategyRecord]:
    if not isinstance(STRATEGIES, Sequence) or isinstance(STRATEGIES, (str, bytes)):
        raise TypeError("strategies.STRATEGIES must be a sequence")
    records: list[StrategyRecord] = []
    seen_ids: set[str] = set()
    for raw in STRATEGIES:
        if not isinstance(raw, Mapping):
            raise TypeError("each strategy registry item must be a mapping")
        record = dict(raw)
        for field in ("source_logic_id", "strategy_id", "hypothesis"):
            if not str(record.get(field, "")).strip():
                raise ValueError(f"strategy missing {field}")
        strategy_id = str(record["strategy_id"])
        if strategy_id in seen_ids:
            raise ValueError(f"duplicate strategy_id: {strategy_id}")
        seen_ids.add(strategy_id)
        conversion = str(record.get("entry_conversion", "")).strip().lower()
        classification = str(record.get("classification", "")).strip().lower()
        if conversion not in {"faithful", "proxy"} and classification not in {"faithful", "proxy"}:
            raise ValueError(f"strategy {strategy_id} must declare faithful or proxy conversion")
        if conversion not in {"faithful", "proxy"}:
            conversion = classification
            record["entry_conversion"] = conversion
        generator = record.get("generate_signals")
        if not callable(generator):
            raise TypeError(f"strategy {strategy_id} has no callable generate_signals")
        names_raw = record.get("signal_parameter_names", [])
        if not isinstance(names_raw, Sequence) or isinstance(names_raw, (str, bytes)):
            raise TypeError(f"strategy {strategy_id} signal_parameter_names must be a sequence")
        names = [str(name) for name in names_raw]
        if len(names) > 5:
            raise ValueError(f"strategy {strategy_id} has more than five signal parameters")
        record["signal_parameter_names"] = names
        sets_raw = record.get("signal_parameter_sets", [{}])
        if sets_raw is None or sets_raw == []:
            sets_raw = [{}]
        if not isinstance(sets_raw, Sequence) or isinstance(sets_raw, (str, bytes)):
            raise TypeError(f"strategy {strategy_id} signal_parameter_sets must be a sequence")
        if len(sets_raw) > 243:
            raise ValueError(f"strategy {strategy_id} has more than 243 signal parameter sets")
        signal_sets: list[dict[str, Any]] = []
        for params in sets_raw:
            if not isinstance(params, Mapping):
                raise TypeError(f"strategy {strategy_id} has a non-mapping signal parameter set")
            signal_sets.append(dict(params))
        record["signal_parameter_sets"] = signal_sets
        risk_raw = record.get("risk_grid")
        if not isinstance(risk_raw, Mapping):
            raise TypeError(f"strategy {strategy_id} risk_grid must be a mapping")
        risk: dict[str, list[float | int]] = {}
        for name in ("stop_atr", "target_r", "max_bars"):
            values_raw = risk_raw.get(name)
            if not isinstance(values_raw, Sequence) or isinstance(values_raw, (str, bytes)):
                raise TypeError(f"strategy {strategy_id} risk_grid.{name} must be a sequence")
            if len(values_raw) == 0 or len(values_raw) > 3:
                raise ValueError(f"strategy {strategy_id} risk_grid.{name} must contain one to three values")
            values: list[float | int] = []
            for value in values_raw:
                if isinstance(value, bool) or not isinstance(value, (int, float)):
                    raise TypeError(f"strategy {strategy_id} risk_grid.{name} contains a non-numeric value")
                values.append(value)
            risk[name] = values
        if any(float(value) <= 0.0 for value in risk["stop_atr"]):
            raise ValueError(f"strategy {strategy_id} contains stop_atr <= 0")
        if any(float(value) < 0.0 for value in risk["target_r"]):
            raise ValueError(f"strategy {strategy_id} contains target_r < 0")
        if any(int(value) < 1 or float(value) != int(value) for value in risk["max_bars"]):
            raise ValueError(f"strategy {strategy_id} contains invalid max_bars")
        record["risk_grid"] = risk
        record["source_refs"] = list(record.get("source_refs", []))
        record["source_requirements"] = record.get("source_requirements", {})
        record["proxy_assumptions"] = list(record.get("proxy_assumptions", []))
        record["position"] = str(record.get("position", ""))
        record["hypothesis"] = str(record["hypothesis"])
        record["source_logic_id"] = str(record["source_logic_id"])
        record["strategy_id"] = strategy_id
        records.append(record)
    return records


def _risk_combinations(strategy: Mapping[str, Any]) -> Iterator[dict[str, float | int]]:
    risk = strategy["risk_grid"]
    for stop_atr in risk["stop_atr"]:
        for target_r in risk["target_r"]:
            for max_bars in risk["max_bars"]:
                yield {
                    "stop_atr": float(stop_atr),
                    "target_r": float(target_r),
                    "max_bars": int(max_bars),
                }


def _variant_specs(strategies: Iterable[StrategyRecord], mode: str) -> Iterator[VariantSpec]:
    variant_idx = 0
    for strategy in strategies:
        signal_sets = strategy["signal_parameter_sets"]
        if mode == "smoke":
            if signal_sets:
                yield VariantSpec(
                    variant_idx,
                    strategy,
                    dict(signal_sets[0]),
                    next(_risk_combinations(strategy)),
                )
                variant_idx += 1
            continue
        for signal_params in signal_sets:
            for risk_params in _risk_combinations(strategy):
                yield VariantSpec(variant_idx, strategy, dict(signal_params), dict(risk_params))
                variant_idx += 1


def _eligible_strategies(
    strategies: Sequence[StrategyRecord], mode: str, bar_interval: str
) -> tuple[list[StrategyRecord], list[str]]:
    if mode == "smoke":
        return list(strategies), []
    eligible: list[StrategyRecord] = []
    excluded: list[str] = []
    requested = _canonical_interval(bar_interval)
    for strategy in strategies:
        required = _source_required_interval(strategy)
        if required is not None and requested is not None and required != requested and not _is_proxy(strategy):
            excluded.append(strategy["strategy_id"])
        else:
            eligible.append(strategy)
    return eligible, excluded


def _empty_summary() -> pl.DataFrame:
    return pl.DataFrame(schema=SUMMARY_SCHEMA)


def _validate_signal_tuple(
    generated: Any, size: int, strategy_id: str
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    if not isinstance(generated, tuple) or len(generated) != 4:
        raise TypeError(f"strategy {strategy_id} must return four signal arrays")
    checked: list[np.ndarray] = []
    for signal in generated:
        if not isinstance(signal, np.ndarray) or signal.ndim != 1:
            raise TypeError(f"strategy {strategy_id} returned a non-1D ndarray")
        if signal.shape[0] != size or signal.dtype != np.bool_:
            raise TypeError(f"strategy {strategy_id} must return bool arrays of market length")
        checked.append(signal)
    return checked[0], checked[1], checked[2], checked[3]


def _metadata_frame(
    results: pl.DataFrame,
    specs: Sequence[VariantSpec],
    atr_length: int,
    slippage: float,
    fee: float,
    bar_interval: str,
) -> pl.DataFrame:
    if results.height != len(specs):
        raise RuntimeError("BatchEngine returned an unexpected variant count")
    metadata = {
        "variant_idx": [spec.variant_idx for spec in specs],
        "source_logic_id": [str(spec.strategy["source_logic_id"]) for spec in specs],
        "strategy_id": [str(spec.strategy["strategy_id"]) for spec in specs],
        "hypothesis": [str(spec.strategy["hypothesis"]) for spec in specs],
        "position": [str(spec.strategy.get("position", "")) for spec in specs],
        "entry_conversion": [str(spec.strategy["entry_conversion"]) for spec in specs],
        "required_bar_interval": [
            str(_source_required_interval(spec.strategy) or "") for spec in specs
        ],
        "source_refs": [_json_text(spec.strategy.get("source_refs", [])) for spec in specs],
        "source_summary": [str(spec.strategy.get("source_summary", "")) for spec in specs],
        "source_requirements": [
            _json_text(spec.strategy.get("source_requirements", {})) for spec in specs
        ],
        "proxy_assumptions": [
            _json_text(spec.strategy.get("proxy_assumptions", [])) for spec in specs
        ],
        "entry_origin": [str(spec.strategy.get("entry_origin", "")) for spec in specs],
        "exit_origin": [str(spec.strategy.get("exit_origin", "")) for spec in specs],
        "signal_parameter_names": [
            _json_text(spec.strategy.get("signal_parameter_names", [])) for spec in specs
        ],
        "signal_params": [_json_text(spec.signal_params) for spec in specs],
        "risk_params": [_json_text(spec.risk_params) for spec in specs],
        "stop_atr": [float(spec.risk_params["stop_atr"]) for spec in specs],
        "target_r": [float(spec.risk_params["target_r"]) for spec in specs],
        "max_bars": [int(spec.risk_params["max_bars"]) for spec in specs],
        "atr_length": [atr_length for _ in specs],
        "slippage": [slippage for _ in specs],
        "fee": [fee for _ in specs],
        "bar_interval": [bar_interval for _ in specs],
    }
    metadata_frame = pl.DataFrame(metadata)
    joined = pl.concat([metadata_frame, results.drop("variant_idx")], how="horizontal")
    return joined.select(list(SUMMARY_SCHEMA))


def _execute(
    engine: BatchEngine,
    strategies: Sequence[StrategyRecord],
    mode: str,
    batch_size: int,
    atr_length: int,
    slippage: float,
    fee: float,
    bar_interval: str,
) -> tuple[pl.DataFrame, int]:
    market_size = engine.market.size
    if market_size == 0:
        return _empty_summary(), 0
    frames: list[pl.DataFrame] = []
    pending: list[VariantSpec] = []
    executed = 0
    for spec in _variant_specs(strategies, mode):
        pending.append(spec)
        if len(pending) < batch_size:
            continue
        frames.append(
            _execute_batch(
                engine,
                pending,
                market_size,
                atr_length,
                slippage,
                fee,
                bar_interval,
            )
        )
        executed += len(pending)
        pending = []
    if pending:
        frames.append(
            _execute_batch(
                engine,
                pending,
                market_size,
                atr_length,
                slippage,
                fee,
                bar_interval,
            )
        )
        executed += len(pending)
    if not frames:
        return _empty_summary(), executed
    return pl.concat(frames, how="vertical"), executed


def _execute_batch(
    engine: BatchEngine,
    specs: Sequence[VariantSpec],
    market_size: int,
    atr_length: int,
    slippage: float,
    fee: float,
    bar_interval: str,
) -> pl.DataFrame:
    count = len(specs)
    long_entries = np.empty((market_size, count), dtype=np.bool_)
    long_exits = np.empty((market_size, count), dtype=np.bool_)
    short_entries = np.empty((market_size, count), dtype=np.bool_)
    short_exits = np.empty((market_size, count), dtype=np.bool_)
    stop_atr = np.empty(count, dtype=np.float64)
    target_r = np.empty(count, dtype=np.float64)
    max_bars = np.empty(count, dtype=np.int64)
    for column, spec in enumerate(specs):
        generated = spec.strategy["generate_signals"](engine.features, spec.signal_params)
        signals = _validate_signal_tuple(generated, market_size, spec.strategy["strategy_id"])
        long_entries[:, column] = signals[0]
        long_exits[:, column] = signals[1]
        short_entries[:, column] = signals[2]
        short_exits[:, column] = signals[3]
        stop_atr[column] = float(spec.risk_params["stop_atr"])
        target_r[column] = float(spec.risk_params["target_r"])
        max_bars[column] = int(spec.risk_params["max_bars"])
    results = engine.run_variants(
        long_entries=long_entries,
        long_exits=long_exits,
        short_entries=short_entries,
        short_exits=short_exits,
        stop_atr_multiples=stop_atr,
        target_rs=target_r,
        max_holdings=max_bars,
        atr_length=atr_length,
        slippage=slippage,
        fee=fee,
    )
    return _metadata_frame(results, specs, atr_length, slippage, fee, bar_interval)


def _read_json(path: Path, default: Any) -> Any:
    if not path.is_file():
        return default
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _file_status_counts(path: Path) -> dict[str, int]:
    counts = {status: 0 for status in FILE_STATUSES}
    data = _read_json(path, None)
    records: Any = None
    if isinstance(data, list):
        records = data
    elif isinstance(data, Mapping):
        for key in ("files", "inventory", "records", "entries", "items"):
            candidate = data.get(key)
            if isinstance(candidate, list):
                records = candidate
                break
        if records is None:
            for key in ("file_status_counts", "counts"):
                nested = data.get(key)
                if isinstance(nested, Mapping):
                    for status in FILE_STATUSES:
                        value = nested.get(status)
                        if isinstance(value, int):
                            counts[status] = value
                        elif isinstance(value, Sequence) and not isinstance(value, (str, bytes)):
                            counts[status] = len(value)
                    break
        if records is None and sum(counts.values()) == 0:
            for status in FILE_STATUSES:
                value = data.get(status)
                if isinstance(value, int):
                    counts[status] = value
                elif isinstance(value, Sequence) and not isinstance(value, (str, bytes)):
                    counts[status] = len(value)
    if records is not None:
        for record in records:
            if isinstance(record, Mapping):
                status = str(record.get("status", "")).strip().lower()
                if status in counts:
                    counts[status] += 1
    counts["discovered"] = sum(counts.values())
    return counts


def _record_count(path: Path, key: str) -> int:
    data = _read_json(path, None)
    if isinstance(data, list):
        return len(data)
    if isinstance(data, Mapping):
        records = data.get(key)
        if isinstance(records, Sequence) and not isinstance(records, (str, bytes)):
            return len(records)
        if isinstance(records, int):
            return records
    return 0


def _planned_count(strategies: Sequence[StrategyRecord], mode: str) -> int:
    total = 0
    for strategy in strategies:
        signal_count = 1 if mode == "smoke" else len(strategy["signal_parameter_sets"])
        if mode == "smoke":
            risk_count = 1
        else:
            risk = strategy["risk_grid"]
            risk_count = len(risk["stop_atr"]) * len(risk["target_r"]) * len(risk["max_bars"])
        total += signal_count * risk_count
    return total


def _load_market(path: Path) -> MarketData:
    try:
        header = pl.read_csv(path, n_rows=0)
    except Exception as error:
        raise ValueError(f"unable to read market CSV header: {path}") from error
    required = {"open", "high", "low", "close", "volume", "amount"}
    missing = sorted(required.difference(header.columns))
    if missing:
        raise ValueError(f"market CSV missing required columns: {', '.join(missing)}")
    return load_market(path)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--market", type=Path, required=True)
    parser.add_argument("--bar-interval", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--mode", choices=("smoke", "full"), required=True)
    parser.add_argument("--atr-length", type=int, default=14)
    parser.add_argument("--slippage", type=float, default=1.0)
    parser.add_argument("--fee", type=float, default=0.5)
    parser.add_argument("--batch-size", type=int, default=128)
    return parser.parse_args()


def main() -> None:
    args = _parse_args()
    if args.atr_length < 1:
        raise ValueError("--atr-length must be >= 1")
    if args.slippage < 0.0:
        raise ValueError("--slippage must be >= 0")
    if args.fee < 0.0:
        raise ValueError("--fee must be >= 0")
    if args.batch_size < 1:
        raise ValueError("--batch-size must be >= 1")
    bar_interval = str(args.bar_interval).strip()
    if not bar_interval:
        raise ValueError("--bar-interval must not be empty")
    args.output.mkdir(parents=True, exist_ok=True)
    strategies = _normalise_registry()
    eligible, excluded = _eligible_strategies(strategies, args.mode, bar_interval)
    planned = _planned_count(eligible, args.mode)
    market = _load_market(args.market)
    started = time.perf_counter()
    if planned > 0 and market.size > 0:
        engine = BatchEngine(market)
        summary, executed = _execute(
            engine,
            eligible,
            args.mode,
            args.batch_size,
            args.atr_length,
            args.slippage,
            args.fee,
            bar_interval,
        )
        cpu_threads: int | None = engine.cpu_cores
    else:
        summary = _empty_summary()
        executed = 0
        cpu_threads = None
    summary_name = "smoke_summary.parquet" if args.mode == "smoke" else "summary.parquet"
    manifest_name = "smoke_manifest.json" if args.mode == "smoke" else "manifest.json"
    summary_path = args.output / summary_name
    manifest_path = args.output / manifest_name
    summary.write_parquet(summary_path)
    inventory_counts = _file_status_counts(SCRIPT_ROOT / "source_inventory.json")
    risk_count = _record_count(SCRIPT_ROOT / "risk_modules.json", "risk_only_rules")
    skipped_count = _record_count(SCRIPT_ROOT / "skipped.json", "candidates")
    source_logic_count = len({strategy["source_logic_id"] for strategy in strategies})
    faithful_count = sum(
        str(strategy["entry_conversion"]).lower() == "faithful" for strategy in strategies
    )
    proxy_count = sum(
        str(strategy["entry_conversion"]).lower() == "proxy" for strategy in strategies
    )
    manifest = {
        "schema_version": "1.0",
        "status": "success",
        "mode": args.mode,
        "market": str(args.market),
        "market_bars": market.size,
        "bar_interval": bar_interval,
        "atr_length": args.atr_length,
        "slippage": args.slippage,
        "fee": args.fee,
        "file_status_counts": inventory_counts,
        "source_logic_count": source_logic_count,
        "risk_only_rule_count": risk_count,
        "faithful_hypothesis_count": faithful_count,
        "proxy_hypothesis_count": proxy_count,
        "hypothesis_count": len(strategies),
        "planned_variant_count": planned,
        "executed_variant_count": executed,
        "skipped_candidate_count": skipped_count,
        "excluded_incompatible_strategy_count": len(excluded),
        "excluded_incompatible_strategy_ids": excluded,
        "cpu_threads": cpu_threads,
        "elapsed_seconds": round(time.perf_counter() - started, 6),
        "output_summary": str(summary_path),
    }
    with manifest_path.open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, ensure_ascii=False, indent=2)
    print(json.dumps(manifest, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
