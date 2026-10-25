"""Сверяет сделки советника с переворотами индикатора.

verify.py доказывает, что порт считает как оригинал. Этот файл доказывает вторую
половину: что советник торгует ровно то, что показывает индикатор, без пропущенных
сигналов и без сделок из ниоткуда.

Советник пишет в журнал направление на КАЖДОМ закрытом баре, а не только на
переворотах. Это принципиально. Если сверять сделки с экспортом индикатора из
другого места, наборы баров разойдутся (у живого терминала история M5 бывает
дырявой, а тестер строит бары из минуток) и половина сигналов превратится
в мнимые расхождения.

    python audit_trades.py --log supertrend_ea_log.csv
    python audit_trades.py --log supertrend_ea_log.csv --indicator supertrend_mt5.csv

Второй вызов дополнительно сверяет направление с экспортом индикатора на тех барах,
которые есть в обоих файлах. Разный охват истории ошибкой не считается, расхождение
направления на общем баре считается.

Код возврата ноль только если каждому перевороту соответствует ровно одна сделка
нужной стороны и ни одной лишней.
"""
from __future__ import annotations

import argparse
import csv
import sys


def read_log(path):
    """Возвращает (серия направлений по барам, входы, закрытия, отказы закрытия)."""
    bars, entries, closes, close_failed, stale, no_margin = [], [], [], [], [], []
    with open(path, newline="", encoding="utf-8-sig") as fh:
        for row in csv.DictReader(fh):
            t = (row.get("bar_time") or "").strip()
            action = (row.get("action") or "").strip().lower()
            if not t or not action:
                continue
            try:
                direction = int(float(row.get("direction") or 0))
            except ValueError:
                direction = 0
            if action == "bar":
                bars.append((t, direction))
            elif action in ("buy", "sell", "failed"):
                entries.append((t, direction, action))
            elif action == "close":
                closes.append(t)
            elif action == "close_failed":
                close_failed.append(t)
            elif action == "stale":
                stale.append(t)
            elif action == "no_margin":
                no_margin.append(t)
    return bars, entries, closes, close_failed, stale, no_margin


def read_indicator(path):
    out = {}
    with open(path, newline="", encoding="utf-8-sig") as fh:
        for row in csv.DictReader(fh):
            raw = (row.get("direction") or "").strip()
            if raw:
                try:
                    out[row["time"].strip()] = int(float(raw))
                except (ValueError, KeyError):
                    pass
    return out


def flips(bars):
    """Бары со сменой направления. Прогрев с нулевым направлением пропускаем."""
    out = []
    for i in range(1, len(bars)):
        (_, prev), (t, cur) = bars[i - 1], bars[i]
        if prev and cur and prev != cur:
            out.append((t, prev, cur))
    return out


def show(label, items, limit=5):
    print("  {:<30}: {}".format(label, len(items)))
    for item in items[:limit]:
        print("      {}".format(item))
    if len(items) > limit:
        print("      ... ещё {}".format(len(items) - limit))


def main():
    ap = argparse.ArgumentParser(description="Сверка сделок советника с сигналами индикатора")
    ap.add_argument("--log", required=True, help="журнал советника")
    ap.add_argument("--indicator", help="необязательно: CSV от ExportSuperTrendTV")
    a = ap.parse_args()

    bars, entries, closes, close_failed, stale, no_margin = read_log(a.log)
    if not bars:
        sys.exit("в журнале нет строк с action=bar, нечего сверять: " + a.log)

    signals = flips(bars)
    flip_at = {t: (prev, cur) for t, prev, cur in signals}

    trade_at, duplicates = {}, []
    for t, direction, action in entries:
        if t in trade_at:
            duplicates.append(t)
        trade_at[t] = (direction, action)

    # Сигнал, отброшенный как протухший, это осознанный отказ от входа, а не потеря.
    # Он записан в журнал отдельной строкой, поэтому пропуском не считается.
    dropped = set(stale) | set(no_margin)
    missed = sorted(t for t in flip_at if t not in trade_at and t not in dropped)
    phantom = sorted(t for t in trade_at if t not in flip_at)
    failed = sorted(t for t, (_, act) in trade_at.items() if act == "failed")

    # -1 это рост, значит покупка. +1 это падение, значит продажа.
    wrong_side = []
    for t, (direction, action) in trade_at.items():
        if action == "failed" or t not in flip_at:
            continue
        expected = "buy" if flip_at[t][1] == -1 else "sell"
        if action != expected:
            wrong_side.append("{} ждали {}, в журнале {}".format(t, expected, action))

    print("\nСверка сделок с сигналами")
    print("  журнал     : {}".format(a.log))
    print("  баров      : {} ({} .. {})".format(len(bars), bars[0][0], bars[-1][0]))
    print("  переворотов: {}".format(len(signals)))
    print("  входов     : {}".format(len(entries)))
    print("  закрытий   : {}".format(len(closes)))
    print("  отброшено: протухших {}, без маржи {}".format(len(stale), len(no_margin)))
    print()

    problems = []
    for label, items in (("сигнал был, сделки нет", missed),
                         ("сделка без сигнала", phantom),
                         ("две сделки на одном баре", duplicates),
                         ("ордер не прошёл", failed),
                         ("закрытие отклонено сервером", close_failed),
                         ("сторона не та", wrong_side)):
        show(label, items)
        if items:
            problems.append(label)

    if a.indicator:
        ind = read_indicator(a.indicator)
        both = [(t, d) for t, d in bars if t in ind]
        disagree = ["{} советник {}, индикатор {}".format(t, d, ind[t])
                    for t, d in both if d and d != ind[t]]
        print("\n  Сверка с экспортом индикатора")
        print("  {:<30}: {}".format("общих баров", len(both)))
        print("  {:<30}: {}".format("только в журнале", len(bars) - len(both)))
        show("направление разошлось", disagree)
        if disagree:
            problems.append("направление разошлось с индикатором")
        elif both:
            print("      на всех общих барах направление совпало")

    print()
    if problems:
        print("РЕЗУЛЬТАТ: расхождения — " + "; ".join(problems))
        return 1
    print("РЕЗУЛЬТАТ: каждый переворот дал ровно одну сделку нужной стороны, лишних нет")
    return 0


if __name__ == "__main__":
    sys.exit(main())
