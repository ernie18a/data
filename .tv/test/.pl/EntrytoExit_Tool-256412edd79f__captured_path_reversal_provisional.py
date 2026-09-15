import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    closes = market.closes
    highs = market.highs
    lows = market.lows
    capture_pct = 20.0
    max_delay = 1

    path_ready = False
    pivot_price = np.nan
    pivot_bar = -1
    leg = 0
    candidate_price = np.nan
    candidate_bar = -1
    previous_ref_dir = 0

    pending_active = False
    pending_dir = 0
    pending_pivot_bar = -1
    pending_terminal = np.nan
    pending_created_bar = -1

    filtered_active = False
    filtered_dir = 0
    filtered_pivot_bar = -1
    filtered_terminal = np.nan

    active_dir = 0
    active_entry_bar = -1
    active_entry_price = np.nan
    active_terminal = np.nan

    for t in range(size):
        close = closes[t]
        if not np.isfinite(close):
            path_ready = False
            previous_ref_dir = 0
            pending_active = False
            filtered_active = False
            continue

        if not path_ready:
            path_ready = True
            pivot_price = close
            pivot_bar = t
            leg = 0
            candidate_price = close
            candidate_bar = t
            previous_ref_dir = 0
            continue

        if leg == 0:
            if close > pivot_price:
                leg = 1
                candidate_price = close
                candidate_bar = t
            elif close < pivot_price:
                leg = -1
                candidate_price = close
                candidate_bar = t
        elif leg > 0:
            if close >= candidate_price:
                candidate_price = close
                candidate_bar = t
            else:
                captured = (
                    pivot_price != 0.0
                    and 100.0 * (candidate_price - pivot_price) / abs(pivot_price)
                    >= capture_pct
                )
                if captured:
                    pivot_price = candidate_price
                    pivot_bar = candidate_bar
                    leg = -1
                    candidate_price = close
                    candidate_bar = t
                elif close < pivot_price:
                    leg = -1
                    candidate_price = close
                    candidate_bar = t
        else:
            if close <= candidate_price:
                candidate_price = close
                candidate_bar = t
            else:
                captured = (
                    pivot_price != 0.0
                    and 100.0 * (pivot_price - candidate_price) / abs(pivot_price)
                    >= capture_pct
                )
                if captured:
                    pivot_price = candidate_price
                    pivot_bar = candidate_bar
                    leg = 1
                    candidate_price = close
                    candidate_bar = t
                elif close > pivot_price:
                    leg = 1
                    candidate_price = close
                    candidate_bar = t

        if close > pivot_price:
            ref_dir = 1
        elif close < pivot_price:
            ref_dir = -1
        else:
            ref_dir = leg

        event_dir = 0
        event_terminal = np.nan

        if pending_active:
            age = t - pending_created_bar
            gate = (
                age <= max_delay
                and pending_dir == ref_dir
                and ref_dir != 0
                and pending_pivot_bar == pivot_bar
            )
            if gate:
                event_dir = pending_dir
                event_terminal = pending_terminal
                pending_active = False
            elif age >= max_delay:
                filtered_active = True
                filtered_dir = pending_dir
                filtered_pivot_bar = pending_pivot_bar
                filtered_terminal = pending_terminal
                pending_active = False

        if event_dir == 0 and filtered_active:
            gate = (
                filtered_dir == ref_dir
                and ref_dir != 0
                and filtered_pivot_bar == pivot_bar
            )
            if gate:
                event_dir = filtered_dir
                event_terminal = filtered_terminal
                filtered_active = False

        up_transition = previous_ref_dir < 0 and ref_dir > 0
        down_transition = previous_ref_dir > 0 and ref_dir < 0
        if up_transition or down_transition:
            candidate_dir = 1 if up_transition else -1
            if 0 <= pivot_bar < size:
                terminal = lows[pivot_bar] if candidate_dir > 0 else highs[pivot_bar]
                if np.isfinite(terminal):
                    pending_active = True
                    pending_dir = candidate_dir
                    pending_pivot_bar = pivot_bar
                    pending_terminal = terminal
                    pending_created_bar = t
                    filtered_active = False

                    gate = (
                        candidate_dir == ref_dir
                        and ref_dir != 0
                        and pivot_bar == pending_pivot_bar
                    )
                    if gate:
                        event_dir = candidate_dir
                        event_terminal = terminal
                        pending_active = False
                    else:
                        filtered_active = True
                        filtered_dir = candidate_dir
                        filtered_pivot_bar = pivot_bar
                        filtered_terminal = terminal
                        pending_active = False

        previous_ref_dir = ref_dir

        if event_dir > 0:
            long_entries[t] = True
        elif event_dir < 0:
            short_entries[t] = True

        if event_dir == 0 and active_dir != 0 and t > active_entry_bar:
            if (
                active_dir > 0
                and np.isfinite(active_terminal)
                and close < active_terminal
            ):
                long_exits[t] = True
                active_dir = 0
                active_entry_bar = -1
                active_entry_price = np.nan
                active_terminal = np.nan
            elif (
                active_dir < 0
                and np.isfinite(active_terminal)
                and close > active_terminal
            ):
                short_exits[t] = True
                active_dir = 0
                active_entry_bar = -1
                active_entry_price = np.nan
                active_terminal = np.nan

        if event_dir != 0:
            if active_dir != 0 and event_dir == -active_dir:
                profit_ready = False
                if np.isfinite(active_entry_price) and active_entry_price != 0.0:
                    if active_dir > 0:
                        return_pct = (
                            (close - active_entry_price)
                            * 100.0
                            / abs(active_entry_price)
                        )
                    else:
                        return_pct = (
                            (active_entry_price - close)
                            * 100.0
                            / abs(active_entry_price)
                        )
                    profit_ready = return_pct >= 0.0

                if profit_ready:
                    if active_dir > 0:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    active_dir = 0
                    active_entry_bar = -1
                    active_entry_price = np.nan
                    active_terminal = np.nan

            if active_dir == 0 and np.isfinite(event_terminal):
                active_dir = event_dir
                active_entry_bar = t
                active_entry_price = close
                active_terminal = event_terminal

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'captured_path_reversal_provisional',
    'hypothesis': '以因果收盤路徑捕捉達到 20% 的轉折，於方向一致的 trough 或 peak 形成 provisional 反轉訊號，並以反向訊號或確認收盤突破保留終端出場。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}