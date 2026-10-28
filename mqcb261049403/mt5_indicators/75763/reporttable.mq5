//+------------------------------------------------------------------+
//|                                                  ReportTable.mq5 |
//|                      Trade Report Statistics Table               |
//|                                                                  |
//|  A standalone informational indicator that displays a trading    |
//|  statistics table on the chart (inspired by the MT5 report       |
//|  generated when exporting history to XML/HTML).                  |
//|                                                                  |
//|  PURELY INFORMATIONAL — this indicator does not trade.           |
//|  It scans the full account deal history (all symbols, all time)  |
//|  and shows performance statistics. Free for general use.         |
//+------------------------------------------------------------------+
#property copyright "CahyoHP"
#property link      "https://www.mql5.com/en/users/cahyohp"
#property version   "1.03"
#property description "Trade report statistics table (informational, non-trading)"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_NONE

//+------------------------------------------------------------------+
//| Default color palette (dark theme)                               |
//+------------------------------------------------------------------+
#define RT_BG_DEFAULT        C'18,22,28'      // Panel background
#define RT_HEADER_BG         C'28,35,45'      // Header / footer background
#define RT_ACCENT_DEFAULT    C'0,180,240'     // Title accent
#define RT_LABEL_DEFAULT     C'180,190,200'   // Label text color
#define RT_VALUE_DEFAULT     clrWhite         // Neutral value color
#define RT_POS_DEFAULT       C'0,220,120'     // Positive value color
#define RT_NEG_DEFAULT       C'255,90,90'     // Negative value color
#define RT_FONT_NORMAL       "Segoe UI"       // Default font
#define RT_FONT_BOLD         "Segoe UI Bold"  // Bold font
#define RT_ROWS_CONTENT      17               // Number of content rows (2..18)
#define RT_ROW_HEADER        1                // Title row
#define RT_ROW_FOOTER        1                // Broker footer row


//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Display ==="
input int              Inp_XOffset       = 20;                // X offset (px)
input int              Inp_YOffset       = 30;                // Y offset (px)
input ENUM_BASE_CORNER Inp_Corner        = CORNER_LEFT_UPPER; // Position on chart
input int              Inp_FontSize      = 9;                 // Body font size (8-10)
input bool             Inp_ShowHeader    = true;              // Show panel title
input bool             Inp_ShowFooter    = true;              // Show broker name
input bool             Inp_ShowColorCode = true;              // Color values (+ green / - red)

input group "=== Refresh ==="
input int              Inp_RefreshSec    = 30;                // Auto refresh (seconds)

input group "=== Colors ==="
input color            Inp_BgColor       = RT_BG_DEFAULT;     // Panel background
input color            Inp_HeaderBgColor = RT_HEADER_BG;      // Header background
input color            Inp_AccentColor   = RT_ACCENT_DEFAULT; // Title accent
input color            Inp_LabelColor    = RT_LABEL_DEFAULT;  // Label color
input color            Inp_ValueColor    = RT_VALUE_DEFAULT;  // Neutral value color
input color            Inp_PosColor      = RT_POS_DEFAULT;    // Positive value color
input color            Inp_NegColor      = RT_NEG_DEFAULT;    // Negative value color
input color            Inp_BtnHideOnColor = C'220,60,60';     // Hide button (panel visible)
input color            Inp_BtnHideOffColor = C'40,160,80';    // Hide button (panel hidden)

//+------------------------------------------------------------------+
//| Class CReportTable — statistics calculation & table rendering   |
//+------------------------------------------------------------------+
class CReportTable
{
private:
    string  m_prefix;          // Unique object prefix of this instance
    bool    m_is_visible;      // Panel visibility state (hide/show)
    int     m_font_size;       // Body font size (clamped 8-10)
    double  m_dpi_scale;       // DPI scale factor (dpi/96)
    int     m_total_width;     // Total panel width
    int     m_row_height;      // Height of one content row
    int     m_header_height;   // Height of the title row
    int     m_offset_x;        // X padding
    int     m_offset_y;        // Y padding

    //--- Calculated statistics
    double  m_total_net_profit;
    double  m_gross_profit;
    double  m_gross_loss;
    double  m_profit_factor;
    double  m_expected_payoff;
    double  m_recovery_factor;
    double  m_sharpe_ratio;
    double  m_bal_drawdown_abs;
    double  m_bal_drawdown_max;
    double  m_bal_drawdown_max_pct;
    double  m_bal_drawdown_rel;
    double  m_bal_drawdown_rel_pct;
    int     m_total_trades;
    int     m_short_trades;
    int     m_win_short_trades;
    int     m_long_trades;
    int     m_win_long_trades;
    int     m_profit_trades;
    int     m_loss_trades;
    double  m_largest_profit_trade;
    double  m_largest_loss_trade;
    double  m_average_profit_trade;
    double  m_average_loss_trade;
    int     m_max_con_wins_count;
    int     m_max_con_loss_count;
    double  m_max_con_wins_money;
    double  m_max_con_loss_money;
    int     m_max_con_profit_count;
    int     m_max_con_loss2_count;
    double  m_max_con_profit_money;
    double  m_max_con_loss_money2;
    int     m_avg_con_wins;
    int     m_avg_con_losses;

    //--- Additional statistics (inspired by the MT5 XML/HTML report)
    double  m_win_rate;              // Percentage of profitable trades
    double  m_payoff_ratio;          // Avg win / |avg loss|
    double  m_total_commission_swap; // Total commission + swap (costs)
    double  m_total_deposits;        // Total deposits
    double  m_total_withdrawals;     // Total withdrawals

    //--- Private helpers
    int      SignOf(const double value) const;
    int      GetTextWidth(const string text, const string font, const int font_size) const;
    void     CreateEdit(const string name, const int x, const int y, const int w, const int h,
                        const string text, const string font, const int font_size,
                        const ENUM_ALIGN_MODE align, const color txt_color,
                        const color bg_color, const color border_color);
    void     CreateButton(const string name, const int x, const int y, const int w, const int h,
                          const string text, const string font, const int font_size,
                          const color txt_color, const color bg_color);
    void     CalcLayout(void);
    void     UpdateVisibility(void) const;
    string   GetCellText(const int row, const int col, int &sign) const;

public:
    //--- Constructor
    CReportTable(void);

    //--- Lifecycle
    void Calculate(void);
    void MakeUniquePrefix(void);
    void RenderAll(void);
    void RefreshValues(void);
    void ToggleVisibility(void);
    void CleanUp(void) const;
    string GetPrefix(void) const;
};

//+------------------------------------------------------------------+
//| SignOf: sign of a value (-1 / 0 / +1) for color coding           |
//+------------------------------------------------------------------+
int CReportTable::SignOf(const double value) const
{
    if (value > 0.0)
        return (1);
    if (value < 0.0)
        return (-1);
    return (0);
}

//+------------------------------------------------------------------+
//| GetTextWidth: measure text width (px) for layout calculation     |
//+------------------------------------------------------------------+
int CReportTable::GetTextWidth(const string text, const string font, const int font_size) const
{
    uint w = 0, h = 0;
    TextSetFont(font, -(font_size * 10), FW_NORMAL);
    TextGetSize(text, w, h);
    return ((int)w);
}

//+------------------------------------------------------------------+
//| CreateEdit: create/update a read-only label object (OBJ_EDIT)    |
//| ObjectCreate() is always called to force property refresh.       |
//+------------------------------------------------------------------+
void CReportTable::CreateEdit(const string name, const int x, const int y, const int w, const int h,
                              const string text, const string font, const int font_size,
                              const ENUM_ALIGN_MODE align, const color txt_color,
                              const color bg_color, const color border_color)
{
    string obj_name = m_prefix + name;
    if (!ObjectCreate(0, obj_name, OBJ_EDIT, 0, 0, 0))
    {
        int err = GetLastError();
        if (err != 0 && err != 4200)   // 4200 = object already exists (normal here)
            PrintFormat("ReportTable: ObjectCreate %s error: %d", obj_name, err);
    }
    ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, h);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetString(0, obj_name, OBJPROP_FONT, font);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, obj_name, OBJPROP_ALIGN, align);
    ObjectSetInteger(0, obj_name, OBJPROP_READONLY, true);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, txt_color);
    ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, bg_color);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_COLOR, border_color);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| CreateButton: create/update a clickable button (OBJ_BUTTON)      |
//+------------------------------------------------------------------+
void CReportTable::CreateButton(const string name, const int x, const int y, const int w, const int h,
                                const string text, const string font, const int font_size,
                                const color txt_color, const color bg_color)
{
    string obj_name = m_prefix + name;
    if (!ObjectCreate(0, obj_name, OBJ_BUTTON, 0, 0, 0))
    {
        int err = GetLastError();
        if (err != 0 && err != 4200)   // 4200 = object already exists (normal here)
            PrintFormat("ReportTable: ObjectCreate %s error: %d", obj_name, err);
    }
    ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, h);
    ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
    ObjectSetString(0, obj_name, OBJPROP_FONT, font);
    ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
    ObjectSetInteger(0, obj_name, OBJPROP_COLOR, txt_color);
    ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, bg_color);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_COLOR, clrNONE);
    ObjectSetInteger(0, obj_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| CalcLayout: calculate panel geometry                              |
//+------------------------------------------------------------------+
void CReportTable::CalcLayout(void)
{
    m_dpi_scale = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
    m_font_size = MathMax(8, MathMin(10, Inp_FontSize));

    //--- Panel width: 3 label columns + 3 value columns
    int col_odd = GetTextWidth("Maximal consecutive profit (count):", RT_FONT_NORMAL, m_font_size)
                  + (int)(20 * m_dpi_scale);
    m_total_width   = (col_odd * 3) + ((int)(col_odd * 0.75) * 3);
    m_row_height    = (int)((m_font_size + 12) * m_dpi_scale);
    m_header_height = (int)(m_row_height * 1.5);
    m_offset_x      = (int)(10 * m_dpi_scale);
    m_offset_y      = (int)(2 * m_dpi_scale);
}

//+------------------------------------------------------------------+
//| MakeUniquePrefix: generate an instance-unique object prefix so   |
//| multiple instances can coexist without conflicting               |
//+------------------------------------------------------------------+
void CReportTable::MakeUniquePrefix(void)
{
    string candidate;
    int attempts = 0;
    do
    {
        candidate = StringFormat("RT_%d_", (int)MathRand());
        attempts++;
        if (attempts > 100)
        {
            candidate = StringFormat("RT_%d_", (int)(GetTickCount() % 100000));
            break;
        }
    }
    while (ObjectFind(0, candidate + "Bg") >= 0);
    m_prefix = candidate;
}

//+------------------------------------------------------------------+
//| Calculate: compute all statistics from the account deal history  |
//| plus Win Rate, Payoff Ratio, Commission+Swap, Deposit/Withdrawal |
//+------------------------------------------------------------------+
void CReportTable::Calculate(void)
{
    //--- Load the full deal history before accessing it (required in MQL5)
    HistorySelect(0, TimeCurrent());

    //--- Reset all fields
    m_total_net_profit      = 0.0;
    m_gross_profit          = 0.0;
    m_gross_loss            = 0.0;
    m_profit_factor         = 0.0;
    m_expected_payoff       = 0.0;
    m_recovery_factor       = 0.0;
    m_sharpe_ratio          = 0.0;
    m_bal_drawdown_abs      = 0.0;
    m_bal_drawdown_max      = 0.0;
    m_bal_drawdown_max_pct  = 0.0;
    m_bal_drawdown_rel      = 0.0;
    m_bal_drawdown_rel_pct  = 0.0;
    m_total_trades          = 0;
    m_short_trades          = 0;
    m_win_short_trades      = 0;
    m_long_trades           = 0;
    m_win_long_trades       = 0;
    m_profit_trades         = 0;
    m_loss_trades           = 0;
    m_largest_profit_trade  = 0.0;
    m_largest_loss_trade    = 0.0;
    m_average_profit_trade  = 0.0;
    m_average_loss_trade    = 0.0;
    m_max_con_wins_count    = 0;
    m_max_con_loss_count    = 0;
    m_max_con_wins_money    = 0.0;
    m_max_con_loss_money    = 0.0;
    m_max_con_profit_count  = 0;
    m_max_con_loss2_count   = 0;
    m_max_con_profit_money  = 0.0;
    m_max_con_loss_money2   = 0.0;
    m_avg_con_wins          = 0;
    m_avg_con_losses        = 0;
    m_win_rate              = 0.0;
    m_payoff_ratio          = 0.0;
    m_total_commission_swap = 0.0;
    m_total_deposits        = 0.0;
    m_total_withdrawals     = 0.0;

    int total = HistoryDealsTotal();
    if (total == 0)
        return;

    //--- Pass 1: compute the initial deposit from balance deals
    double initial_deposit = 0.0;
    for (int i = 0; i < total; i++)
    {
        ulong tkt = HistoryDealGetTicket(i);
        if (HistoryDealGetInteger(tkt, DEAL_TYPE) == DEAL_TYPE_BALANCE)
        {
            double dp = HistoryDealGetDouble(tkt, DEAL_PROFIT);
            initial_deposit += dp;
            if (dp > 0.0)
                m_total_deposits += dp;
            else if (dp < 0.0)
                m_total_withdrawals += -dp;
        }
    }
    if (initial_deposit == 0.0)
        initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);

    double balance     = initial_deposit;
    double maxpeak     = balance;
    double minpeak     = balance;
    double maxloss_level = balance;
    int    sequence    = 0;
    int    profitseqs  = 0;
    int    lossseqs    = 0;
    double sequential  = 0.0;
    double prevprofit  = EMPTY_VALUE;
    double profit_array[];
    ArrayResize(profit_array, total);
    int trade_idx = 0;

    //--- Pass 2: scan closing deals (OUT / OUT_BY)
    for (int i = 0; i < total; i++)
    {
        ulong ticket = HistoryDealGetTicket(i);
        long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
        if (entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY)
            continue;

        double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                        + HistoryDealGetDouble(ticket, DEAL_SWAP)
                        + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
        long deal_type = HistoryDealGetInteger(ticket, DEAL_TYPE);
        balance += profit;
        profit_array[trade_idx++] = profit;
        m_total_net_profit += profit;
        m_total_trades++;
        m_total_commission_swap += HistoryDealGetDouble(ticket, DEAL_COMMISSION)
                                   + HistoryDealGetDouble(ticket, DEAL_SWAP);

        //--- Drawdown tracking
        if (maxpeak < balance)
        {
            double drawdown = maxpeak - minpeak;
            if (maxpeak != 0.0)
            {
                double dd_pct = (drawdown / maxpeak) * 100.0;
                if (m_bal_drawdown_rel_pct < dd_pct)
                {
                    m_bal_drawdown_rel_pct = dd_pct;
                    m_bal_drawdown_rel = drawdown;
                }
            }
            if (m_bal_drawdown_max < drawdown)
            {
                m_bal_drawdown_max = drawdown;
                m_bal_drawdown_max_pct = (maxpeak != 0) ? (m_bal_drawdown_max / maxpeak * 100.0) : 100.0;
            }
            maxpeak = balance;
            minpeak = balance;
        }
        if (minpeak > balance)
            minpeak = balance;
        if (maxloss_level > balance)
            maxloss_level = balance;

        //--- Trade type tracking
        if (deal_type == DEAL_TYPE_SELL)
        {
            m_long_trades++;
            if (profit > 0)
                m_win_long_trades++;
        }
        else if (deal_type == DEAL_TYPE_BUY)
        {
            m_short_trades++;
            if (profit > 0)
                m_win_short_trades++;
        }

        //--- Consecutive win/loss tracking
        if (profit < 0)
        {
            m_loss_trades++;
            m_gross_loss += profit;
            if (m_largest_loss_trade > profit)
                m_largest_loss_trade = profit;
            if (prevprofit != EMPTY_VALUE && prevprofit >= 0)
            {
                if (m_max_con_wins_count < sequence || (m_max_con_wins_count == sequence && m_max_con_wins_money < sequential))
                {
                    m_max_con_wins_count = sequence;
                    m_max_con_wins_money = sequential;
                }
                if (m_max_con_profit_money < sequential || (m_max_con_profit_money == sequential && m_max_con_profit_count < sequence))
                {
                    m_max_con_profit_money = sequential;
                    m_max_con_profit_count = sequence;
                }
                profitseqs++;
                m_avg_con_wins += sequence;
                sequence = 0;
                sequential = 0.0;
            }
        }
        else
        {
            m_profit_trades++;
            m_gross_profit += profit;
            if (m_largest_profit_trade < profit)
                m_largest_profit_trade = profit;
            if (prevprofit != EMPTY_VALUE && prevprofit < 0)
            {
                if (m_max_con_loss_count < sequence || (m_max_con_loss_count == sequence && m_max_con_loss_money > sequential))
                {
                    m_max_con_loss_count = sequence;
                    m_max_con_loss_money = sequential;
                }
                if (m_max_con_loss_money2 > sequential || (m_max_con_loss_money2 == sequential && m_max_con_loss2_count < sequence))
                {
                    m_max_con_loss_money2 = sequential;
                    m_max_con_loss2_count = sequence;
                }
                lossseqs++;
                m_avg_con_losses += sequence;
                sequence = 0;
                sequential = 0.0;
            }
        }
        sequence++;
        sequential += profit;
        prevprofit = profit;
    }

    //--- Final drawdown
    double final_drawdown = maxpeak - minpeak;
    if (maxpeak != 0.0)
    {
        double dd_pct = (final_drawdown / maxpeak) * 100.0;
        if (m_bal_drawdown_rel_pct < dd_pct)
        {
            m_bal_drawdown_rel_pct = dd_pct;
            m_bal_drawdown_rel = final_drawdown;
        }
    }
    if (m_bal_drawdown_max < final_drawdown)
    {
        m_bal_drawdown_max = final_drawdown;
        m_bal_drawdown_max_pct = (maxpeak != 0) ? (m_bal_drawdown_max / maxpeak * 100.0) : 100.0;
    }

    //--- Averages
    if (profitseqs > 0)
        m_avg_con_wins = (int)MathRound((double)m_avg_con_wins / profitseqs);
    if (lossseqs > 0)
        m_avg_con_losses = (int)MathRound((double)m_avg_con_losses / lossseqs);

    //--- Derived metrics
    if (m_gross_loss < 0)
        m_profit_factor = MathAbs(m_gross_profit / m_gross_loss);
    if (m_profit_trades > 0)
        m_average_profit_trade = m_gross_profit / m_profit_trades;
    if (m_loss_trades > 0)
        m_average_loss_trade = m_gross_loss / m_loss_trades;
    m_expected_payoff = (m_total_trades > 0) ? m_total_net_profit / m_total_trades : 0.0;
    m_bal_drawdown_abs = initial_deposit - maxloss_level;
    if (m_bal_drawdown_abs < 0)
        m_bal_drawdown_abs = 0.0;
    if (m_bal_drawdown_max > 0)
        m_recovery_factor = m_total_net_profit / m_bal_drawdown_max;

    //--- Sharpe ratio
    if (m_total_trades > 1)
    {
        double variance = 0.0;
        for (int i = 0; i < m_total_trades; i++)
            variance += MathPow(profit_array[i] - m_expected_payoff, 2);
        double std_dev = MathSqrt(variance / (m_total_trades - 1));
        if (std_dev > 0)
            m_sharpe_ratio = m_expected_payoff / std_dev;
    }

    //--- Additional metrics
    m_win_rate = (m_total_trades > 0) ? ((double)m_profit_trades / m_total_trades) * 100.0 : 0.0;
    m_payoff_ratio = (m_average_loss_trade < 0.0) ? MathAbs(m_average_profit_trade / m_average_loss_trade) : 0.0;
}

//+------------------------------------------------------------------+
//| GetCellText: cell content for a given row & column               |
//| Row layout:                                                      |
//|   2  Total Net Profit | Gross Profit | Gross Loss                |
//|   3  Profit Factor | Expected Payoff                             |
//|   4  Recovery Factor | Sharpe Ratio                              |
//|   5  (empty spacer)                                              |
//|   6  Win Rate (%) | Payoff Ratio                                 |
//|   7  Commission+Swap | Deposits | Withdrawals                    |
//|   8  (empty spacer)                                              |
//|   9  Balance Drawdown:                                           |
//|  10  Balance Drawdown Abs | Max | Rel                            |
//|  11  (empty spacer)                                              |
//|  12  Total Trades | Short (won %) | Long (won %)                 |
//|  13  Profit Trades (%) | Loss Trades (%)                         |
//|  14  Largest profit | Largest loss                               |
//|  15  Average profit | Average loss                               |
//|  16  Max consecutive wins ($) | Max consecutive loss ($)         |
//|  17  Max consecutive profit (c) | Max consecutive loss (c)       |
//|  18  Average consecutive wins | Average consecutive losses       |
//+------------------------------------------------------------------+
string CReportTable::GetCellText(const int row, const int col, int &sign) const
{
    sign = 0;
    switch (row)
    {
    case 2:
        if (col == 1) return "Total Net Profit:";
        if (col == 2)
        {
            sign = SignOf(m_total_net_profit);
            return DoubleToString(m_total_net_profit, 2);
        }
        if (col == 3) return "Gross Profit:";
        if (col == 4)
        {
            sign = (m_gross_profit > 0.0) ? 1 : 0;
            return DoubleToString(m_gross_profit, 2);
        }
        if (col == 5) return "Gross Loss:";
        if (col == 6)
        {
            sign = (m_gross_loss < 0.0) ? -1 : 0;
            return DoubleToString(m_gross_loss, 2);
        }
        break;

    case 3:
        if (col == 1) return "Profit Factor:";
        if (col == 2)
        {
            sign = (m_profit_factor >= 1.0) ? 1 : ((m_profit_factor == 0.0) ? 0 : -1);
            return DoubleToString(m_profit_factor, 2);
        }
        if (col == 3) return "Expected Payoff:";
        if (col == 4)
        {
            sign = SignOf(m_expected_payoff);
            return DoubleToString(m_expected_payoff, 2);
        }
        break;

    case 4:
        if (col == 1) return "Recovery Factor:";
        if (col == 2)
        {
            sign = (m_recovery_factor >= 1.0) ? 1 : ((m_recovery_factor == 0.0) ? 0 : -1);
            return DoubleToString(m_recovery_factor, 2);
        }
        if (col == 3) return "Sharpe Ratio:";
        if (col == 4)
        {
            sign = SignOf(m_sharpe_ratio);
            return DoubleToString(m_sharpe_ratio, 2);
        }
        break;

    case 6:
        if (col == 1) return "Win Rate (%):";
        if (col == 2)
        {
            sign = (m_win_rate >= 50.0) ? 1 : ((m_win_rate == 0.0) ? 0 : -1);
            return DoubleToString(m_win_rate, 2) + "%";
        }
        if (col == 3) return "Payoff Ratio:";
        if (col == 4)
        {
            sign = (m_payoff_ratio >= 1.0) ? 1 : ((m_payoff_ratio == 0.0) ? 0 : -1);
            return DoubleToString(m_payoff_ratio, 2);
        }
        break;

    case 7:
        if (col == 1) return "Total Commission+Swap:";
        if (col == 2)
        {
            sign = (m_total_commission_swap < 0.0) ? -1 : 0;
            return DoubleToString(m_total_commission_swap, 2);
        }
        if (col == 3) return "Total Deposits:";
        if (col == 4)
        {
            sign = (m_total_deposits > 0.0) ? 1 : 0;
            return DoubleToString(m_total_deposits, 2);
        }
        if (col == 5) return "Total Withdrawals:";
        if (col == 6)
        {
            sign = (m_total_withdrawals > 0.0) ? -1 : 0;
            return DoubleToString(m_total_withdrawals, 2);
        }
        break;

    case 9:
        if (col == 1) return "Balance Drawdown:";
        break;

    case 10:
        if (col == 1) return "Balance Drawdown Absolute:";
        if (col == 2) return DoubleToString(m_bal_drawdown_abs, 2);
        if (col == 3) return "Balance Drawdown Maximal:";
        if (col == 4) return DoubleToString(m_bal_drawdown_max, 2) + " (" + DoubleToString(m_bal_drawdown_max_pct, 2) + "%)";
        if (col == 5) return "Balance Drawdown Relative:";
        if (col == 6) return DoubleToString(m_bal_drawdown_rel_pct, 2) + "% (" + DoubleToString(m_bal_drawdown_rel, 2) + ")";
        break;

    case 12:
        if (col == 1) return "Total Trades:";
        if (col == 2) return IntegerToString(m_total_trades);
        if (col == 3) return "Short Trades (won %):";
        if (col == 4) return IntegerToString(m_short_trades) + " (" +
                                 DoubleToString((m_short_trades > 0) ?
                                                ((double)m_win_short_trades / m_short_trades) * 100 : 0, 2) + "%)";
        if (col == 5) return "Long Trades (won %):";
        if (col == 6) return IntegerToString(m_long_trades) + " (" +
                                 DoubleToString((m_long_trades > 0) ?
                                                ((double)m_win_long_trades / m_long_trades) * 100 : 0, 2) + "%)";
        break;

    case 13:
        if (col == 3) return "Profit Trades (%):";
        if (col == 4) return IntegerToString(m_profit_trades) + " (" +
                                 DoubleToString((m_total_trades > 0) ?
                                                ((double)m_profit_trades / m_total_trades) * 100 : 0, 2) + "%)";
        if (col == 5) return "Loss Trades (%):";
        if (col == 6) return IntegerToString(m_loss_trades) + " (" +
                                 DoubleToString((m_total_trades > 0) ?
                                                ((double)m_loss_trades / m_total_trades) * 100 : 0, 2) + "%)";
        break;

    case 14:
        if (col == 3) return "Largest profit trade:";
        if (col == 4)
        {
            sign = SignOf(m_largest_profit_trade);
            return DoubleToString(m_largest_profit_trade, 2);
        }
        if (col == 5) return "Largest loss trade:";
        if (col == 6)
        {
            sign = (m_largest_loss_trade < 0.0) ? -1 : 0;
            return DoubleToString(m_largest_loss_trade, 2);
        }
        break;

    case 15:
        if (col == 3) return "Average profit trade:";
        if (col == 4)
        {
            sign = SignOf(m_average_profit_trade);
            return DoubleToString(m_average_profit_trade, 2);
        }
        if (col == 5) return "Average loss trade:";
        if (col == 6)
        {
            sign = (m_average_loss_trade < 0.0) ? -1 : 0;
            return DoubleToString(m_average_loss_trade, 2);
        }
        break;

    case 16:
        if (col == 3) return "Max consecutive wins ($):";
        if (col == 4)
        {
            sign = SignOf(m_max_con_wins_money);
            return IntegerToString(m_max_con_wins_count) + " (" +
                   DoubleToString(m_max_con_wins_money, 2) + ")";
        }
        if (col == 5) return "Max consecutive loss ($):";
        if (col == 6)
        {
            sign = (m_max_con_loss_money < 0.0) ? -1 : 0;
            return IntegerToString(m_max_con_loss_count) + " (" +
                   DoubleToString(m_max_con_loss_money, 2) + ")";
        }
        break;

    case 17:
        if (col == 3) return "Max consecutive profit (c):";
        if (col == 4)
        {
            sign = SignOf(m_max_con_profit_money);
            return DoubleToString(m_max_con_profit_money, 2) + " (" +
                   IntegerToString(m_max_con_profit_count) + ")";
        }
        if (col == 5) return "Max consecutive loss (c):";
        if (col == 6)
        {
            sign = (m_max_con_loss_money2 < 0.0) ? -1 : 0;
            return DoubleToString(m_max_con_loss_money2, 2) + " (" +
                   IntegerToString(m_max_con_loss2_count) + ")";
        }
        break;

    case 18:
        if (col == 3) return "Average consecutive wins:";
        if (col == 4) return IntegerToString(m_avg_con_wins);
        if (col == 5) return "Average consecutive losses:";
        if (col == 6) return IntegerToString(m_avg_con_losses);
        break;
    }
    return ("");
}

//+------------------------------------------------------------------+
//| RenderAll: full redraw (delete old objects, draw new ones)       |
//+------------------------------------------------------------------+
void CReportTable::RenderAll(void)
{
    CleanUp();
    CalcLayout();

    int bg_w = m_total_width + (m_offset_x * 2);
    int total_h = (RT_ROW_HEADER * m_header_height)
                  + (RT_ROWS_CONTENT * m_row_height)
                  + (RT_ROW_FOOTER * m_row_height)
                  + (m_offset_y * 2);

    int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

    //--- Base position follows the selected corner
    int x_base = Inp_XOffset;
    int y_base = Inp_YOffset;
    if (Inp_Corner == CORNER_RIGHT_UPPER || Inp_Corner == CORNER_RIGHT_LOWER)
        x_base = chart_w - bg_w - Inp_XOffset;
    if (Inp_Corner == CORNER_LEFT_LOWER || Inp_Corner == CORNER_RIGHT_LOWER)
        y_base = chart_h - total_h - Inp_YOffset;

    int bg_x = x_base - m_offset_x;
    int bg_y = y_base - m_offset_y;

    //--- Panel background
    CreateEdit("Bg", bg_x, bg_y, bg_w, total_h, "", RT_FONT_NORMAL, m_font_size,
               ALIGN_CENTER, clrNONE, Inp_BgColor, Inp_BgColor);

    int cur_y = y_base;
    int w_odd  = (int)((m_total_width / 3) / 1.75);
    int w_even = (int)(w_odd * 0.75);

    //--- Title row
    if (Inp_ShowHeader)
    {
        CreateEdit("Header", bg_x, cur_y, bg_w, m_header_height,
                   "Trade History Report", RT_FONT_BOLD, m_font_size + 1,
                   ALIGN_CENTER, Inp_AccentColor, Inp_HeaderBgColor, Inp_HeaderBgColor);
        cur_y += m_header_height;
    }

    //--- Content rows 2..18 (RT_ROWS_CONTENT rows)
    for (int r = 2; r <= RT_ROWS_CONTENT + 1; r++)
    {
        int cur_x = x_base;
        for (int k = 1; k <= 6; k++)
        {
            int col_width = (k % 2 == 1) ? w_odd : w_even;
            int sign = 0;
            string text = GetCellText(r, k, sign);
            color txt_color = Inp_ValueColor;
            if (Inp_ShowColorCode && (k % 2 == 0) && sign != 0)
                txt_color = (sign > 0) ? Inp_PosColor : Inp_NegColor;
            CreateEdit("B" + IntegerToString(r) + "_K" + IntegerToString(k),
                       cur_x, cur_y, col_width, m_row_height,
                       text, RT_FONT_NORMAL, m_font_size, ALIGN_RIGHT,
                       txt_color, Inp_BgColor, Inp_BgColor);
            cur_x += col_width;
        }
        cur_y += m_row_height;
    }

    //--- Footer row (broker name)
    if (Inp_ShowFooter)
    {
        CreateEdit("Footer", bg_x, cur_y, bg_w, m_row_height,
                   TerminalInfoString(TERMINAL_COMPANY), RT_FONT_BOLD, m_font_size,
                   ALIGN_CENTER, Inp_LabelColor, Inp_HeaderBgColor, Inp_HeaderBgColor);
    }

    //--- Hide/show button (top-right, ABOVE the panel — never covered by panel objects)
    int btn_w = (int)(25 * m_dpi_scale);
    int btn_h = (int)(25 * m_dpi_scale);
    int btn_x = bg_x + bg_w - btn_w;
    int btn_y = bg_y - btn_h;
    CreateButton("Btn_Hide", btn_x, btn_y, btn_w, btn_h,
                 m_is_visible ? "✕" : "☰", RT_FONT_BOLD, m_font_size + 1,
                 clrWhite, m_is_visible ? Inp_BtnHideOnColor : Inp_BtnHideOffColor);

    //--- Apply the current visibility state
    UpdateVisibility();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| RefreshValues: update texts & colors WITHOUT full redraw         |
//| (CPU friendly — only ObjectSet*, no ObjectCreate)                |
//+------------------------------------------------------------------+
void CReportTable::RefreshValues(void)
{
    //--- Skip work while the panel is hidden
    if (!m_is_visible)
        return;

    //--- If objects do not exist (e.g. new chart), do a full redraw
    if (ObjectFind(0, m_prefix + "B2_K1") < 0)
    {
        RenderAll();
        return;
    }

    for (int r = 2; r <= RT_ROWS_CONTENT + 1; r++)
    {
        for (int k = 1; k <= 6; k++)
        {
            int sign = 0;
            string text = GetCellText(r, k, sign);
            color txt_color = Inp_ValueColor;
            if (Inp_ShowColorCode && (k % 2 == 0) && sign != 0)
                txt_color = (sign > 0) ? Inp_PosColor : Inp_NegColor;
            string obj = m_prefix + "B" + IntegerToString(r) + "_K" + IntegerToString(k);
            ObjectSetString(0, obj, OBJPROP_TEXT, text);
            ObjectSetInteger(0, obj, OBJPROP_COLOR, txt_color);
        }
    }
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| UpdateVisibility: show/hide panel objects (button stays visible) |
//+------------------------------------------------------------------+
void CReportTable::UpdateVisibility(void) const
{
    long pt = m_is_visible ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS;

    //--- The hide/show button is always visible
    ObjectSetInteger(0, m_prefix + "Btn_Hide", OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);

    //--- Panel elements follow the visibility state
    ObjectSetInteger(0, m_prefix + "Bg", OBJPROP_TIMEFRAMES, pt);
    ObjectSetInteger(0, m_prefix + "Header", OBJPROP_TIMEFRAMES, pt);
    ObjectSetInteger(0, m_prefix + "Footer", OBJPROP_TIMEFRAMES, pt);

    for (int r = 2; r <= RT_ROWS_CONTENT + 1; r++)
    {
        for (int k = 1; k <= 6; k++)
        {
            ObjectSetInteger(0, m_prefix + "B" + IntegerToString(r) + "_K" + IntegerToString(k),
                             OBJPROP_TIMEFRAMES, pt);
        }
    }
}

//+------------------------------------------------------------------+
//| ToggleVisibility: flip panel visibility on button click          |
//+------------------------------------------------------------------+
void CReportTable::ToggleVisibility(void)
{
    //--- If the button is missing (e.g. deleted externally), rebuild the panel
    if (ObjectFind(0, m_prefix + "Btn_Hide") < 0)
    {
        RenderAll();
        return;
    }

    m_is_visible = !m_is_visible;

    //--- Update button look: ✕ (visible) / ☰ (hidden)
    ObjectSetString(0, m_prefix + "Btn_Hide", OBJPROP_TEXT, m_is_visible ? "✕" : "☰");
    ObjectSetInteger(0, m_prefix + "Btn_Hide", OBJPROP_BGCOLOR,
                     m_is_visible ? Inp_BtnHideOnColor : Inp_BtnHideOffColor);
    UpdateVisibility();
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| CleanUp: delete all graphic objects owned by the panel           |
//+------------------------------------------------------------------+
void CReportTable::CleanUp(void) const
{
    ObjectsDeleteAll(0, m_prefix);
}

//+------------------------------------------------------------------+
//| GetPrefix: return the unique object prefix of this instance      |
//+------------------------------------------------------------------+
string CReportTable::GetPrefix(void) const
{
    return (m_prefix);
}

//+------------------------------------------------------------------+
//| Constructor — set graphic object prefix                          |
//+------------------------------------------------------------------+
CReportTable::CReportTable(void)
{
    m_prefix = "RT_";
    m_is_visible = true;
}

//+------------------------------------------------------------------+
//| Indicator global state                                           |
//+------------------------------------------------------------------+
CReportTable g_table;
double g_dummy_buf[];       // Dummy DRAW_NONE buffer (not plotted, plot requirement only)
datetime g_last_refresh = 0;
int      g_last_deals   = 0;
int      g_chart_w      = 0;
int      g_chart_h      = 0;

//+------------------------------------------------------------------+
//| OnInit — initial calculation & table rendering                   |
//+------------------------------------------------------------------+
int OnInit(void)
{

    SetIndexBuffer(0, g_dummy_buf, INDICATOR_DATA);
    g_table.MakeUniquePrefix();
    g_table.Calculate();
    g_table.RenderAll();
    g_last_refresh = TimeCurrent();
    g_last_deals   = HistoryDealsTotal();
    g_chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    g_chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    EventSetTimer(1);
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit — kill timer & clean up graphic objects                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    g_table.CleanUp();
}

//+------------------------------------------------------------------+
//| OnChartEvent — toggle panel visibility on button click           |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    //--- Toggle panel visibility when the hide/show button is clicked
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == g_table.GetPrefix() + "Btn_Hide")
        g_table.ToggleVisibility();
}

//+------------------------------------------------------------------+
//| OnTimer — fallback refresh for charts without ticks              |
//+------------------------------------------------------------------+
void OnTimer(void)
{
    MaybeRefresh();
}

//+------------------------------------------------------------------+
//| OnCalculate — detect chart resize + periodic refresh             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
    //--- Chart resize → redraw so the corner position stays correct
    int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
    int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
    if (cw != g_chart_w || ch != g_chart_h)
    {
        g_chart_w = cw;
        g_chart_h = ch;
        g_table.RenderAll();
    }

    MaybeRefresh();
    return (rates_total);
}

//+------------------------------------------------------------------+
//| MaybeRefresh: refresh when the deal count changes / periodically |
//+------------------------------------------------------------------+
void MaybeRefresh(void)
{
    //--- Keep the deal history selection current before counting
    HistorySelect(0, TimeCurrent());
    int deals = HistoryDealsTotal();
    if (deals != g_last_deals || (TimeCurrent() - g_last_refresh) >= Inp_RefreshSec)
    {
        g_table.Calculate();
        g_table.RefreshValues();
        g_last_deals   = deals;
        g_last_refresh = TimeCurrent();
    }
}
//+------------------------------------------------------------------+
