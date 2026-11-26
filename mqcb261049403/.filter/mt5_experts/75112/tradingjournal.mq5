//+------------------------------------------------------------------+
//|                                     TradingJournalMonolith.mq5   |
//|                                  Institutional Trading Journal   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://www.mql5.com/en/users/searchmixed"
#property version   "1.00"
#property description "Institutional-Grade Trading Performance Intelligence Journal"
#property indicator_chart_window

// Include native MetaTrader Canvas library for high-speed direct bitmap rendering
#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| CONSTANTS & MACROS                                               |
//+------------------------------------------------------------------+
#define SCHEDULER_INTERVAL_MS 16   // Target ~60 FPS update interval
#define CACHE_FILE_NAME "TradingJournal_Data.bin"
#define BACKUP_FILE_NAME "TradingJournal_Data.bak"
#define RECORDS_PER_PAGE 15        // Tabular/Card records shown per page

//+------------------------------------------------------------------+
//| ENUMERATED TYPES                                                 |
//+------------------------------------------------------------------+
enum ENUM_APP_THEME
  {
   THEME_LIGHT, // Set Light mode as default to match input_file_11
   THEME_DARK,
   THEME_BLUE,
   THEME_MIDNIGHT
  };

enum ENUM_APP_PAGE
  {
   PAGE_DASHBOARD,
   PAGE_DEEP_ANALYSIS,
   PAGE_BEHAVIOR_LAB,
   PAGE_CALENDAR
  };

enum ENUM_TASK_TYPE
  {
   TASK_LIVE_SYNC,
   TASK_INCREMENTAL_SCAN,
   TASK_CANVAS_REDRAW,
   TASK_QUANT_STATS,
   TASK_BEHAVIOR_ANALYSIS,
   TASK_DISK_FLUSH,
   TASK_COUNT
  };

//+------------------------------------------------------------------+
//| SYSTEM STRUCTURES                                                |
//+------------------------------------------------------------------+
struct TradeRecord
  {
   ulong             ticket;
   ulong             position_id;
   long              magic;
   string            symbol;
   ENUM_DEAL_TYPE    type;
   datetime          open_time;
   datetime          close_time;
   double            open_price;
   double            close_price;
   double            sl;
   double            tp;
   double            volume;
   double            profit;
   double            commission;
   double            swap;
   double            net_profit;
   string            behavior_tag;
   string            emotion_tag;
   string            discipline_tag;
   string            setup_name;
   string            notes;
  };

struct DailyBucket
  {
   datetime          date_midnight;
   double            net_profit;
   int               trade_count;
  };

struct AppRect
  {
   int               left;
   int               top;
   int               right;
   int               bottom;

   int               Width()  { return right - left; }
   int               Height() { return bottom - top; }
   bool              Contains(int x, int y) { return (x >= left && x <= right && y >= top && y <= bottom); }
  };

struct ThemeColors
  {
   uint              bg_main;
   uint              bg_card;
   uint              text_primary;
   uint              text_secondary;
   uint              accent;
   uint              profit_green;
   uint              loss_red;
   uint              border;
  };

struct SymbolCount
  {
   string            symbol;
   int               count;
  };

//+------------------------------------------------------------------+
//| THEME ENGINE                                                     |
//+------------------------------------------------------------------+
class ThemeEngine
  {
private:
   ThemeColors       m_current_colors;
   ENUM_APP_THEME    m_current_theme;

public:
                     ThemeEngine() { SetTheme(THEME_LIGHT); }
                    ~ThemeEngine() {}

   void              SetTheme(ENUM_APP_THEME theme)
     {
      m_current_theme = theme;
      switch(theme)
        {
         case THEME_LIGHT:
            m_current_colors.bg_main        = ColorToARGB((color)0xECEFF1, 255); // Premium off-white
            m_current_colors.bg_card        = ColorToARGB((color)0xFFFFFF, 255); // Pure white card
            m_current_colors.text_primary   = ColorToARGB((color)0x0F172A, 255); // Dark slate
            m_current_colors.text_secondary = ColorToARGB((color)0x475569, 255); // Cool grey
            m_current_colors.accent         = ColorToARGB((color)0x0284C7, 255); // Sky Blue Accent
            m_current_colors.profit_green   = ColorToARGB((color)0x0EA5E9, 255); // Aesthetic Cyan/Teal Profit
            m_current_colors.loss_red       = ColorToARGB((color)0xE11D48, 255); // Vibrant Rose Loss
            m_current_colors.border         = ColorToARGB((color)0xCBD5E1, 255); // Muted slate borders
            break;

         case THEME_BLUE:
            m_current_colors.bg_main        = ColorToARGB((color)0x0F172A, 255);
            m_current_colors.bg_card        = ColorToARGB((color)0x1E293B, 255);
            m_current_colors.text_primary   = ColorToARGB((color)0xF8FAFC, 255);
            m_current_colors.text_secondary = ColorToARGB((color)0x94A3B8, 255);
            m_current_colors.accent         = ColorToARGB((color)0x3B82F6, 255);
            m_current_colors.profit_green   = ColorToARGB((color)0x10B981, 255);
            m_current_colors.loss_red       = ColorToARGB((color)0xEF4444, 255);
            m_current_colors.border         = ColorToARGB((color)0x334155, 255);
            break;

         case THEME_MIDNIGHT:
            m_current_colors.bg_main        = ColorToARGB((color)0x020617, 255);
            m_current_colors.bg_card        = ColorToARGB((color)0x0F172A, 255);
            m_current_colors.text_primary   = ColorToARGB((color)0xF1F5F9, 255);
            m_current_colors.text_secondary = ColorToARGB((color)0x64748B, 255);
            m_current_colors.accent         = ColorToARGB((color)0x6366F1, 255);
            m_current_colors.profit_green   = ColorToARGB((color)0x22C55E, 255);
            m_current_colors.loss_red       = ColorToARGB((color)0xEF4444, 255);
            m_current_colors.border         = ColorToARGB((color)0x1E293B, 255);
            break;

         case THEME_DARK:
         default:
            m_current_colors.bg_main        = ColorToARGB((color)0x121212, 255);
            m_current_colors.bg_card        = ColorToARGB((color)0x1E1E1E, 255);
            m_current_colors.text_primary   = ColorToARGB((color)0xE0E0E0, 255);
            m_current_colors.text_secondary = ColorToARGB((color)0x888888, 255);
            m_current_colors.accent         = ColorToARGB((color)0xFF9800, 255);
            m_current_colors.profit_green   = ColorToARGB((color)0x4CAF50, 255);
            m_current_colors.loss_red       = ColorToARGB((color)0xF44336, 255);
            m_current_colors.border         = ColorToARGB((color)0x2D2D2D, 255);
            break;
        }
     }

   ThemeColors       GetColors() { return m_current_colors; }
   ENUM_APP_THEME    GetTheme() { return m_current_theme; }
  };

//+------------------------------------------------------------------+
//| LAYOUT ENGINE (RESPONSIVE GRID & INTERACTION DETECTORS)          |
//+------------------------------------------------------------------+
class LayoutEngine
  {
private:
   int               m_width;
   int               m_height;

public:
   AppRect           Header;
   AppRect           NavTabs[4];
   AppRect           ThemeToggle;
   AppRect           KPI_Container;
   AppRect           KPI_Cards[11];
   AppRect           MainArea;
   AppRect           ColumnHeaders[10];
   AppRect           BottomCoach;

   // Page 4: Interactive Monthly Calendar Layout Rectangles
   AppRect           CalendarGrid;
   AppRect           CalPrevMonth;
   AppRect           CalNextMonth;
   AppRect           CalToday;

                     LayoutEngine() : m_width(0), m_height(0) {}
                    ~LayoutEngine() {}

   void              Recalculate(int width, int height)
     {
      m_width = width;
      m_height = height;

      // 1. Header calculation (5% height, minimum 50px)
      Header.left = 0;
      Header.top = 0;
      Header.right = width;
      Header.bottom = MathMax(50, (int)(height * 0.05));

      // Navigation Tabs placement (Header left-aligned offset)
      int tab_width = 120;
      for(int i = 0; i < 4; i++)
        {
         NavTabs[i].left = 320 + (i * (tab_width + 5));
         NavTabs[i].top = 10;
         NavTabs[i].right = NavTabs[i].left + tab_width;
         NavTabs[i].bottom = Header.bottom - 10;
        }

      // Theme toggle placement (Header right-aligned offset)
      ThemeToggle.left = width - 130;
      ThemeToggle.top = 10;
      ThemeToggle.right = width - 20;
      ThemeToggle.bottom = Header.bottom - 10;

      // 2. KPI Cards Panel (10% height, minimum 80px)
      KPI_Container.left = 10;
      KPI_Container.top = Header.bottom + 10;
      KPI_Container.right = width - 10;
      KPI_Container.bottom = KPI_Container.top + MathMax(80, (int)(height * 0.10));

      int kpi_width = (KPI_Container.Width() - 100) / 11;
      for(int i = 0; i < 11; i++)
        {
         KPI_Cards[i].left = KPI_Container.left + (i * (kpi_width + 10));
         KPI_Cards[i].top = KPI_Container.top;
         KPI_Cards[i].right = KPI_Cards[i].left + kpi_width;
         KPI_Cards[i].bottom = KPI_Container.bottom;
        }

      // 3. Bottom AI Coach Panel (15% height, anchored at bottom)
      BottomCoach.left = 10;
      BottomCoach.top = height - MathMax(120, (int)(height * 0.15));
      BottomCoach.right = width - 10;
      BottomCoach.bottom = height - 10;

      // 4. Main Display Area (Dynamic remainder)
      MainArea.left = 10;
      MainArea.top = KPI_Container.bottom + 10;
      MainArea.right = width - 10;
      MainArea.bottom = BottomCoach.top - 10;

      // Tabular layout columns inside MainArea
      int col_width = MainArea.Width() / 10;
      for(int i = 0; i < 10; i++)
        {
         ColumnHeaders[i].left = MainArea.left + (i * col_width);
         ColumnHeaders[i].top = MainArea.top + 10;
         ColumnHeaders[i].right = ColumnHeaders[i].left + col_width;
         ColumnHeaders[i].bottom = ColumnHeaders[i].top + 30;
        }

      // Calendar controls coordinates (top-right of MainArea)
      CalPrevMonth.left = MainArea.right - 260;
      CalPrevMonth.top = MainArea.top + 15;
      CalPrevMonth.right = MainArea.right - 180;
      CalPrevMonth.bottom = MainArea.top + 45;

      CalToday.left = MainArea.right - 170;
      CalToday.top = MainArea.top + 15;
      CalToday.right = MainArea.right - 110;
      CalToday.bottom = MainArea.top + 45;

      CalNextMonth.left = MainArea.right - 100;
      CalNextMonth.top = MainArea.top + 15;
      CalNextMonth.right = MainArea.right - 20;
      CalNextMonth.bottom = MainArea.top + 45;
     }
  };

//+------------------------------------------------------------------+
//| STORAGE ENGINE (LOCAL BINARY I/O WITH ERROR RECOVERY)            |
//+------------------------------------------------------------------+
class StorageEngine
  {
private:
   void              WriteBinaryString(int handle, const string text)
     {
      int len = StringLen(text);
      FileWriteInteger(handle, len, INT_VALUE);
      if(len > 0)
        {
         FileWriteString(handle, text, len);
        }
     }

   string            ReadBinaryString(int handle)
     {
      int len = FileReadInteger(handle, INT_VALUE);
      if(len > 0)
        {
         return FileReadString(handle, len);
        }
      return "";
     }

public:
                     StorageEngine() {}
                    ~StorageEngine() {}

   bool              SaveToDisk(TradeRecord &records[])
     {
      ResetLastError();
      int handle = FileOpen(CACHE_FILE_NAME, FILE_WRITE|FILE_BIN);
      if(handle == INVALID_HANDLE)
        {
         PrintFormat("[ERROR] StorageEngine: Failed to open file for write: %d", GetLastError());
         return false;
        }

      int size = ArraySize(records);
      FileWriteInteger(handle, size, INT_VALUE);

      for(int i = 0; i < size; i++)
        {
         FileWriteLong(handle, (long)records[i].ticket);
         FileWriteLong(handle, (long)records[i].position_id);
         FileWriteLong(handle, records[i].magic);
         WriteBinaryString(handle, records[i].symbol);
         FileWriteInteger(handle, records[i].type, INT_VALUE);
         FileWriteLong(handle, (long)records[i].open_time);
         FileWriteLong(handle, (long)records[i].close_time);
         FileWriteDouble(handle, records[i].open_price);
         FileWriteDouble(handle, records[i].close_price);
         FileWriteDouble(handle, records[i].sl);
         FileWriteDouble(handle, records[i].tp);
         FileWriteDouble(handle, records[i].volume);
         FileWriteDouble(handle, records[i].profit);
         FileWriteDouble(handle, records[i].commission);
         FileWriteDouble(handle, records[i].swap);
         FileWriteDouble(handle, records[i].net_profit);
         WriteBinaryString(handle, records[i].behavior_tag);
         WriteBinaryString(handle, records[i].emotion_tag);
         WriteBinaryString(handle, records[i].discipline_tag);
         WriteBinaryString(handle, records[i].setup_name);
         WriteBinaryString(handle, records[i].notes);
        }

      FileClose(handle);
      return true;
     }

   bool              LoadFromDisk(TradeRecord &records[])
     {
      ResetLastError();
      int handle = FileOpen(CACHE_FILE_NAME, FILE_READ|FILE_BIN);
      if(handle == INVALID_HANDLE)
        {
         PrintFormat("[WARNING] StorageEngine: Cache file missing or invalid: %d. Relying on raw execution history.", GetLastError());
         return false;
        }

      int size = FileReadInteger(handle, INT_VALUE);
      if(size < 0)
        {
         FileClose(handle);
         return false;
        }

      ArrayResize(records, size);
      for(int i = 0; i < size; i++)
        {
         records[i].ticket      = (ulong)FileReadLong(handle);
         records[i].position_id = (ulong)FileReadLong(handle);
         records[i].magic       = FileReadLong(handle);
         records[i].symbol      = ReadBinaryString(handle);
         records[i].type        = (ENUM_DEAL_TYPE)FileReadInteger(handle, INT_VALUE);
         records[i].open_time   = (datetime)FileReadLong(handle);
         records[i].close_time  = (datetime)FileReadLong(handle);
         records[i].open_price  = FileReadDouble(handle);
         records[i].close_price = FileReadDouble(handle);
         records[i].sl          = FileReadDouble(handle);
         records[i].tp          = FileReadDouble(handle);
         records[i].volume      = FileReadDouble(handle);
         records[i].profit      = FileReadDouble(handle);
         records[i].commission  = FileReadDouble(handle);
         records[i].swap        = FileReadDouble(handle);
         records[i].net_profit  = FileReadDouble(handle);
         records[i].behavior_tag   = ReadBinaryString(handle);
         records[i].emotion_tag    = ReadBinaryString(handle);
         records[i].discipline_tag = ReadBinaryString(handle);
         records[i].setup_name     = ReadBinaryString(handle);
         records[i].notes          = ReadBinaryString(handle);
        }

      FileClose(handle);
      return true;
     }
  };

//+------------------------------------------------------------------+
//| GRAPHIC ENGINE (DIRECT DYNAMIC FRAMEBUFFER)                      |
//+------------------------------------------------------------------+
class GraphicEngine
  {
private:
   CCanvas           m_canvas;
   string            m_canvas_name;
   bool              m_initialized;

public:
                     GraphicEngine() : m_canvas_name("Journal_Canvas_FB"), m_initialized(false) {}
                    ~GraphicEngine() { Shutdown(); }

   bool              Initialize(int width, int height)
     {
      if(m_initialized)
        {
         Shutdown();
        }

      if(!m_canvas.CreateBitmapLabel(m_canvas_name, 0, 0, width, height, COLOR_FORMAT_ARGB_NORMALIZE))
        {
         PrintFormat("[ERROR] GraphicEngine: Canvas initialization failed: %d", GetLastError());
         return false;
        }

      // Configure pass-through mouse click properties
      ObjectSetInteger(0, m_canvas_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_canvas_name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, m_canvas_name, OBJPROP_READONLY, true);

      m_initialized = true;
      return true;
     }

   void              Shutdown()
     {
      if(m_initialized)
        {
         m_canvas.Destroy();
         m_initialized = false;
        }
     }

   CCanvas*          GetCanvas() { return GetPointer(m_canvas); }

   void              Clear(uint bg_clr)
     {
      if(!m_initialized)
         return;
      m_canvas.Erase(bg_clr);
     }

   void              RenderRect(AppRect &rect, uint fill_color, uint border_color)
     {
      if(!m_initialized)
         return;
      m_canvas.FillRectangle(rect.left, rect.top, rect.right, rect.bottom, fill_color);
      m_canvas.Rectangle(rect.left, rect.top, rect.right, rect.bottom, border_color);
     }

   // Dynamic modern rounded rectangle primitive renderer
   void              RenderRoundedRect(AppRect &rect, int radius, uint fill_color, uint border_color)
     {
      if(!m_initialized)
         return;
      if(radius <= 0)
        {
         RenderRect(rect, fill_color, border_color);
         return;
        }
      m_canvas.FillRectangle(rect.left + radius, rect.top, rect.right - radius, rect.bottom, fill_color);
      m_canvas.FillRectangle(rect.left, rect.top + radius, rect.left + radius, rect.bottom - radius, fill_color);
      m_canvas.FillRectangle(rect.right - radius, rect.top + radius, rect.right, rect.bottom - radius, fill_color);
      m_canvas.FillCircle(rect.left + radius, rect.top + radius, radius, fill_color);
      m_canvas.FillCircle(rect.right - radius, rect.top + radius, radius, fill_color);
      m_canvas.FillCircle(rect.left + radius, rect.bottom - radius, radius, fill_color);
      m_canvas.FillCircle(rect.right - radius, rect.bottom - radius, radius, fill_color);

      // Outline
      m_canvas.Line(rect.left + radius, rect.top, rect.right - radius, rect.top, border_color);
      m_canvas.Line(rect.left + radius, rect.bottom, rect.right - radius, rect.bottom, border_color);
      m_canvas.Line(rect.left, rect.top + radius, rect.left, rect.bottom - radius, border_color);
      m_canvas.Line(rect.right, rect.top + radius, rect.right, rect.bottom - radius, border_color);
      m_canvas.Circle(rect.left + radius, rect.top + radius, radius, border_color);
      m_canvas.Circle(rect.right - radius, rect.top + radius, radius, border_color);
      m_canvas.Circle(rect.left + radius, rect.bottom - radius, radius, border_color);
      m_canvas.Circle(rect.right - radius, rect.bottom - radius, radius, border_color);
     }

   void              RenderText(int x, int y, string text, uint text_clr, uint alignment = TA_LEFT, string font = "Consolas", int size = 13)
     {
      if(!m_initialized)
         return;
      m_canvas.FontSet(font, size * -10);
      m_canvas.TextOut(x, y, text, text_clr, alignment);
     }

   void              DrawGridLine(int x1, int y1, int x2, int y2, uint grid_clr)
     {
      if(!m_initialized)
         return;
      m_canvas.Line(x1, y1, x2, y2, grid_clr);
     }

   void              UpdateScreen()
     {
      if(!m_initialized)
         return;
      m_canvas.Update();
     }
  };

//+------------------------------------------------------------------+
//| CALENDAR ENGINE (TRAILING 365-DAY TEMPORAL PROFILE)              |
//+------------------------------------------------------------------+
class CalendarEngine
  {
private:
   DailyBucket       m_buckets[365];
   datetime          m_start_date;

   datetime          GetMidnight(datetime t)
     {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      return t - (dt.hour * 3600 + dt.min * 60 + dt.sec);
     }

public:
                     CalendarEngine() { Reset(); }
                    ~CalendarEngine() {}

   void              Reset()
     {
      m_start_date = GetMidnight(TimeCurrent()) - (364 * 86400); // Sequence anchors exactly 365 days ago
      for(int i = 0; i < 365; i++)
        {
         m_buckets[i].date_midnight = m_start_date + (i * 86400);
         m_buckets[i].net_profit = 0.0;
         m_buckets[i].trade_count = 0;
        }
     }

   void              MapTradeHistory(const TradeRecord &records[])
     {
      Reset();
      int total_trades = ArraySize(records);
      if(total_trades == 0)
         return;

      for(int i = 0; i < total_trades; i++)
        {
         datetime midnight = GetMidnight(records[i].close_time);
         long diff_seconds = (long)(midnight - m_start_date);
         int index = (int)(diff_seconds / 86400);

         if(index >= 0 && index < 365)
           {
            m_buckets[index].net_profit += records[i].net_profit;
            m_buckets[index].trade_count++;
           }
        }
     }

   DailyBucket       GetBucket(int idx)
     {
      DailyBucket empty_bucket = {0, 0.0, 0};
      if(idx >= 0 && idx < 365)
         return m_buckets[idx];
      return empty_bucket;
     }

   datetime          GetStartDate() { return m_start_date; }
  };

//+------------------------------------------------------------------+
//| MONTE CARLO ENGINE (BOOTSTRAPPING & PROBABILISTIC MODELS)        |
//+------------------------------------------------------------------+
class MonteCarloEngine
  {
public:
   double            MedianEndingEquity;
   double            SimulatedMaxDrawdownPct;
   double            RiskOfRuinPct;

                     MonteCarloEngine() { Reset(); }
                    ~MonteCarloEngine() {}

   void              Reset()
     {
      MedianEndingEquity = 0.0;
      SimulatedMaxDrawdownPct = 0.0;
      RiskOfRuinPct = 0.0;
     }

   void              RunSimulation(const TradeRecord &records[], double initial_balance = 10000.0)
     {
      Reset();
      int total_trades = ArraySize(records);
      if(total_trades < 5)
         return;

      MathSrand(GetTickCount());
      double ending_equities[1000];
      double run_max_drawdowns[1000];
      int ruin_violations = 0;

      for(int r = 0; r < 1000; r++)
        {
         double current_equity = initial_balance;
         double peak = initial_balance;
         double max_dd_pct = 0.0;
         bool breached_ruin = false;

         for(int t = 0; t < total_trades; t++)
           {
            int random_idx = MathRand() % total_trades;
            double trade_outcome = records[random_idx].net_profit;
            current_equity += trade_outcome;

            if(current_equity > peak)
              {
               peak = current_equity;
              }

            double drawdown = peak - current_equity;
            double dd_pct = (peak > 0.0) ? (drawdown / peak) * 100.0 : 0.0;
            if(dd_pct > max_dd_pct)
              {
               max_dd_pct = dd_pct;
              }

            if(current_equity <= (initial_balance * 0.50))
              {
               breached_ruin = true;
              }
           }

         ending_equities[r] = current_equity;
         run_max_drawdowns[r] = max_dd_pct;
         if(breached_ruin)
            ruin_violations++;
        }

      ArraySort(ending_equities);
      ArraySort(run_max_drawdowns);

      MedianEndingEquity = ending_equities[500];
      SimulatedMaxDrawdownPct = run_max_drawdowns[500];
      RiskOfRuinPct = ((double)ruin_violations / 1000.0) * 100.0;
     }
  };

//+------------------------------------------------------------------+
//| STATS ENGINE (INSTITUTIONAL QUANTITATIVE METRICS)               |
//+------------------------------------------------------------------+
class StatsEngine
  {
public:
   // Dashboard Primary Stats Table
   int               TotalBuy;
   int               TotalSell;
   double            AverageLot;
   double            GrossProfit;
   double            GrossLoss;
   double            PNL;

   // Excel Metrics Secondary Grid
   double            AverageWin;
   double            AverageLoss;
   double            BiggestWin;
   double            BiggestLoss;
   double            Mean;
   double            StandardDeviation;
   double            DownsideDeviation;
   double            SharpeRatio;
   double            SortinoRatio;
   double            CalmarRatio;
   double            MaxDrawdownAbsolute;
   double            MaxDrawdownPercent;
   double            UlcerIndex;
   double            SQN;
   double            KellyCriterion;
   double            Skewness;
   double            Kurtosis;
   double            WinRate;
   double            ProfitFactor;
   long              AverageTradeDurationSeconds;

   // Long/Short Specific Performance
   int               LongTrades;
   int               ShortTrades;
   double            LongProfit;
   double            ShortProfit;
   double            LongLoss;
   double            ShortLoss;
   double            LongPNL;
   double            ShortPNL;
   int               LongWins;
   int               ShortWins;
   double            LongWinRate;
   double            ShortWinRate;
   long              LongTotalDuration;
   long              ShortTotalDuration;
   long              AvgLongDurationSeconds;
   long              ShortAvgDurationSeconds;

   // Streak Performance
   int               MaxConsecutiveWins;
   int               MaxConsecutiveLosses;
   double            PeakWinRunValue;
   double            PeakLossRunValue;

                     StatsEngine() { Reset(); }
                    ~StatsEngine() {}

   void              Reset()
     {
      TotalBuy = 0;
      TotalSell = 0;
      AverageLot = 0.0;
      GrossProfit = 0.0;
      GrossLoss = 0.0;
      PNL = 0.0;
      AverageWin = 0.0;
      AverageLoss = 0.0;
      BiggestWin = 0.0;
      BiggestLoss = 0.0;
      Mean = 0.0;
      StandardDeviation = 0.0;
      DownsideDeviation = 0.0;
      SharpeRatio = 0.0;
      SortinoRatio = 0.0;
      CalmarRatio = 0.0;
      MaxDrawdownAbsolute = 0.0;
      MaxDrawdownPercent = 0.0;
      UlcerIndex = 0.0;
      SQN = 0.0;
      KellyCriterion = 0.0;
      Skewness = 0.0;
      Kurtosis = 0.0;
      WinRate = 0.0;
      ProfitFactor = 0.0;
      AverageTradeDurationSeconds = 0;
      MaxConsecutiveWins = 0;
      MaxConsecutiveLosses = 0;
      PeakWinRunValue = 0.0;
      PeakLossRunValue = 0.0;

      LongTrades = 0;
      ShortTrades = 0;
      LongProfit = 0.0;
      ShortProfit = 0.0;
      LongLoss = 0.0;
      ShortLoss = 0.0;
      LongPNL = 0.0;
      ShortPNL = 0.0;
      LongWins = 0;
      ShortWins = 0;
      LongWinRate = 0.0;
      ShortWinRate = 0.0;
      LongTotalDuration = 0;
      ShortTotalDuration = 0;
      AvgLongDurationSeconds = 0;
      ShortAvgDurationSeconds = 0;
     }

   void              Calculate(const TradeRecord &records[])
     {
      Reset();
      int total_trades = ArraySize(records);
      if(total_trades == 0)
         return;

      int win_count = 0;
      int loss_count = 0;
      double total_lots = 0.0;
      long total_duration = 0;
      double net_profits[];
      ArrayResize(net_profits, total_trades);

      double cumulative_equity = 0.0;
      double peak_equity = 0.0;
      double sum_drawdown_squares = 0.0;

      int cur_wins = 0;
      int cur_losses = 0;
      double cur_win_run_val = 0.0;
      double cur_loss_run_val = 0.0;

      for(int i = 0; i < total_trades; i++)
        {
         net_profits[i] = records[i].net_profit;
         cumulative_equity += net_profits[i];
         total_lots += records[i].volume;
         long d_sec = (long)(records[i].close_time - records[i].open_time);
         if(d_sec < 0)
            d_sec = 0;
         total_duration += d_sec;

         if(records[i].type == DEAL_TYPE_BUY)
           {
            TotalBuy++;
            LongTrades++;
            LongTotalDuration += d_sec;
            if(net_profits[i] >= 0)
              {
               LongWins++;
               LongProfit += net_profits[i];
              }
            else
              {
               LongLoss += MathAbs(net_profits[i]);
              }
           }
         else
           {
            TotalSell++;
            ShortTrades++;
            ShortTotalDuration += d_sec;
            if(net_profits[i] >= 0)
              {
               ShortWins++;
               ShortProfit += net_profits[i];
              }
            else
              {
               ShortLoss += MathAbs(net_profits[i]);
              }
           }

         if(net_profits[i] >= 0.0)
           {
            win_count++;
            GrossProfit += net_profits[i];
            if(net_profits[i] > BiggestWin)
               BiggestWin = net_profits[i];

            cur_wins++;
            cur_win_run_val += net_profits[i];
            if(cur_wins > MaxConsecutiveWins)
               MaxConsecutiveWins = cur_wins;
            if(cur_win_run_val > PeakWinRunValue)
               PeakWinRunValue = cur_win_run_val;

            cur_losses = 0;
            cur_loss_run_val = 0.0;
           }
         else
           {
            loss_count++;
            GrossLoss += MathAbs(net_profits[i]);
            if(net_profits[i] < BiggestLoss)
               BiggestLoss = net_profits[i];

            cur_losses++;
            cur_loss_run_val += MathAbs(net_profits[i]);
            if(cur_losses > MaxConsecutiveLosses)
               MaxConsecutiveLosses = cur_losses;
            if(cur_loss_run_val > PeakLossRunValue)
               PeakLossRunValue = cur_loss_run_val;

            cur_wins = 0;
            cur_win_run_val = 0.0;
           }

         if(cumulative_equity > peak_equity)
           {
            peak_equity = cumulative_equity;
           }

         double drawdown_abs = peak_equity - cumulative_equity;
         if(drawdown_abs > MaxDrawdownAbsolute)
           {
            MaxDrawdownAbsolute = drawdown_abs;
           }

         double dd_pct = 0.0;
         if(peak_equity > 0.0)
           {
            dd_pct = (drawdown_abs / peak_equity) * 100.0;
           }
         else
            if(peak_equity == 0.0 && cumulative_equity < 0.0)
              {
               dd_pct = 100.0;
              }

         if(dd_pct > MaxDrawdownPercent)
           {
            MaxDrawdownPercent = dd_pct;
           }

         sum_drawdown_squares += MathPow(dd_pct, 2.0);
        }

      PNL = GrossProfit - GrossLoss;
      AverageLot = total_lots / total_trades;
      AverageTradeDurationSeconds = total_duration / total_trades;
      WinRate = (double)win_count / (double)total_trades;
      ProfitFactor = (GrossLoss > 0.0) ? (GrossProfit / GrossLoss) : GrossProfit;

      AverageWin = (win_count > 0) ? (GrossProfit / win_count) : 0.0;
      AverageLoss = (loss_count > 0) ? ((GrossLoss * -1.0) / loss_count) : 0.0;

      LongPNL = LongProfit - LongLoss;
      ShortPNL = ShortProfit - ShortLoss;
      LongWinRate = (LongTrades > 0) ? (double)LongWins / LongTrades : 0.0;
      ShortWinRate = (ShortTrades > 0) ? (double)ShortWins / ShortTrades : 0.0;
      AvgLongDurationSeconds = (LongTrades > 0) ? LongTotalDuration / LongTrades : 0;
      ShortAvgDurationSeconds = (ShortTrades > 0) ? ShortTotalDuration / ShortTrades : 0;

      double sum_profits = 0.0;
      for(int i = 0; i < total_trades; i++)
        {
         sum_profits += net_profits[i];
        }
      Mean = sum_profits / total_trades;

      double sum_variance_squares = 0.0;
      double sum_downside_squares = 0.0;

      for(int i = 0; i < total_trades; i++)
        {
         sum_variance_squares += MathPow(net_profits[i] - Mean, 2.0);
         if(net_profits[i] < 0.0)
           {
            sum_downside_squares += MathPow(net_profits[i], 2.0);
           }
        }

      StandardDeviation = (total_trades > 1) ? MathSqrt(sum_variance_squares / (total_trades - 1)) : 0.0;
      DownsideDeviation = (total_trades > 0) ? MathSqrt(sum_downside_squares / total_trades) : 0.0;

      SharpeRatio = (StandardDeviation > 0.0) ? (Mean / StandardDeviation) : 0.0;
      SortinoRatio = (DownsideDeviation > 0.0) ? (Mean / DownsideDeviation) : 0.0;
      UlcerIndex = (total_trades > 0) ? MathSqrt(sum_drawdown_squares / total_trades) : 0.0;

      double total_return_pct = 0.0;
      double initial_balance = AccountInfoDouble(ACCOUNT_BALANCE) - cumulative_equity;
      if(initial_balance > 0.0)
        {
         total_return_pct = (cumulative_equity / initial_balance) * 100.0;
        }
      CalmarRatio = (MaxDrawdownPercent > 0.0) ? (total_return_pct / MaxDrawdownPercent) : 0.0;

      SQN = (StandardDeviation > 0.0) ? (Mean / StandardDeviation) * MathSqrt(total_trades) : 0.0;

      double skew_sum = 0.0;
      double kurt_sum = 0.0;
      for(int i = 0; i < total_trades; i++)
        {
         double diff = net_profits[i] - Mean;
         skew_sum += MathPow(diff, 3.0);
         kurt_sum += MathPow(diff, 4.0);
        }

      if(StandardDeviation > 0.0)
        {
         Skewness = (skew_sum / total_trades) / MathPow(StandardDeviation, 3.0);
         Kurtosis = ((kurt_sum / total_trades) / MathPow(StandardDeviation, 4.0)) - 3.0;
        }

      double r_ratio = (MathAbs(AverageLoss) > 0.0) ? (AverageWin / MathAbs(AverageLoss)) : 0.0;
      if(r_ratio > 0.0)
        {
         KellyCriterion = WinRate - ((1.0 - WinRate) / r_ratio);
        }
     }
  };

//+------------------------------------------------------------------+
//| BEHAVIOR ENGINE (AUTOMATED PERFORMANCE PATTERN DETECTION)        |
//+------------------------------------------------------------------+
class BehaviorEngine
  {
private:
   bool              WasStopLossWidened(ulong position_id, ENUM_DEAL_TYPE deal_type)
     {
      if(!HistorySelectByPosition(position_id))
         return false;

      int total_orders = HistoryOrdersTotal();
      if(total_orders <= 1)
         return false;

      double initial_sl = 0.0;
      bool initial_sl_captured = false;

      for(int i = 0; i < total_orders; i++)
        {
         ulong order_ticket = HistoryOrderGetTicket(i);
         if(order_ticket == 0)
            continue;

         double order_sl = HistoryOrderGetDouble(order_ticket, ORDER_SL);
         if(order_sl == 0.0)
            continue;

         if(!initial_sl_captured)
           {
            initial_sl = order_sl;
            initial_sl_captured = true;
            continue;
           }

         if(deal_type == DEAL_TYPE_BUY)
           {
            if(order_sl < initial_sl)
               return true;
           }
         else
            if(deal_type == DEAL_TYPE_SELL)
              {
               if(order_sl > initial_sl && initial_sl > 0.0)
                  return true;
              }
        }
      return false;
     }

public:
   int               RevengeTradeCount;
   int               FOMOTradeCount;
   int               PanicCloseCount;
   int               MissingSLCount;
   int               SlWidenedCount;

                     BehaviorEngine() { Reset(); }
                    ~BehaviorEngine() {}

   void              Reset()
     {
      RevengeTradeCount = 0;
      FOMOTradeCount = 0;
      PanicCloseCount = 0;
      MissingSLCount = 0;
      SlWidenedCount = 0;
     }

   void              AuditBehavior(TradeRecord &records[])
     {
      Reset();
      int total_trades = ArraySize(records);
      if(total_trades == 0)
         return;

      for(int i = 0; i < total_trades; i++)
        {
         if(records[i].sl == 0.0)
           {
            records[i].discipline_tag = "No SL";
            MissingSLCount++;
           }

         if(WasStopLossWidened(records[i].position_id, records[i].type))
           {
            records[i].discipline_tag = "SL Widened";
            SlWidenedCount++;
           }

         if(i == 0)
            continue;

         double prev_profit = records[i - 1].net_profit;
         datetime prev_close_time = records[i - 1].close_time;
         datetime curr_open_time = records[i].open_time;

         if(prev_profit < 0.0)
           {
            long minutes_between = (long)(curr_open_time - prev_close_time) / 60;
            if(minutes_between >= 0 && minutes_between <= 30)
              {
               if(records[i].volume >= (records[i - 1].volume * 1.5))
                 {
                  records[i].behavior_tag = "Revenge";
                  RevengeTradeCount++;
                 }
              }
           }

         MqlRates rates[];
         ArraySetAsSeries(rates, true);
         if(CopyRates(records[i].symbol, PERIOD_H1, records[i].open_time, 14, rates) > 0)
           {
            double high_range = rates[0].high;
            double low_range = rates[0].low;
            for(int k = 1; k < 14; k++)
              {
               if(rates[k].high > high_range)
                  high_range = rates[k].high;
               if(rates[k].low < low_range)
                  low_range = rates[k].low;
              }

            double channel_midpoint = (high_range + low_range) / 2.0;
            double distance_limit = (high_range - low_range) * 1.5;

            if(MathAbs(records[i].open_price - channel_midpoint) > distance_limit)
              {
               records[i].behavior_tag = "FOMO Chase";
               FOMOTradeCount++;
              }
           }

         long holding_duration_sec = (long)(records[i].close_time - records[i].open_time);
         if(holding_duration_sec > 0 && holding_duration_sec < 300)
           {
            if(records[i].close_price != records[i].sl && records[i].close_price != records[i].tp)
              {
               records[i].behavior_tag = "Panic Exit";
               PanicCloseCount++;
              }
           }
        }
     }
  };

//+------------------------------------------------------------------+
//| TIME-SLICED COOPERATIVE TASK SCHEDULER                           |
//+------------------------------------------------------------------+
class TaskScheduler
  {
private:
   int               m_current_slice;
   uint              m_last_execution_ticks;
   bool              m_task_dirty_flags[TASK_COUNT];

public:
                     TaskScheduler() : m_current_slice(0), m_last_execution_ticks(0)
     {
      ArrayInitialize(m_task_dirty_flags, true);
     }
                    ~TaskScheduler() {}

   void              MarkDirty(ENUM_TASK_TYPE task) { m_task_dirty_flags[task] = true; }
   bool              IsDirty(ENUM_TASK_TYPE task)   { return m_task_dirty_flags[task]; }
   void              Clean(ENUM_TASK_TYPE task)     { m_task_dirty_flags[task] = false; }

   ENUM_TASK_TYPE    GetNextTask()
     {
      m_current_slice = (m_current_slice + 1) % TASK_COUNT;
      return (ENUM_TASK_TYPE)m_current_slice;
     }
  };

//+------------------------------------------------------------------+
//| HISTORY ENGINE (INCREMENTAL COOPERATIVE DISCOVERY)               |
//+------------------------------------------------------------------+
class HistoryEngine
  {
private:
   ulong             m_last_processed_ticket;
   int               m_current_scan_index;

public:
                     HistoryEngine() : m_last_processed_ticket(0), m_current_scan_index(0) {}
                    ~HistoryEngine() {}

   bool              ProcessIncremental(TradeRecord &out_records[], int chunk_size = 500)
     {
      if(!HistorySelect(0, TimeCurrent()))
        {
         return false;
        }

      int total_deals = HistoryDealsTotal();
      if(m_current_scan_index >= total_deals)
        {
         return false;
        }

      int limit = MathMin(m_current_scan_index + chunk_size, total_deals);
      for(int i = m_current_scan_index; i < limit; i++)
        {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket <= m_last_processed_ticket)
            continue;

         long entry_type = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         if(entry_type != DEAL_ENTRY_OUT)
            continue;

         int arr_size = ArraySize(out_records);
         ArrayResize(out_records, arr_size + 1);

         out_records[arr_size].ticket       = ticket;
         out_records[arr_size].position_id = (ulong)HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
         out_records[arr_size].magic       = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         out_records[arr_size].symbol      = HistoryDealGetString(ticket, DEAL_SYMBOL);
         out_records[arr_size].type        = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
         out_records[arr_size].close_time  = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         out_records[arr_size].close_price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         out_records[arr_size].volume      = HistoryDealGetDouble(ticket, DEAL_VOLUME);
         out_records[arr_size].profit      = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         out_records[arr_size].commission  = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
         out_records[arr_size].swap        = HistoryDealGetDouble(ticket, DEAL_SWAP);
         out_records[arr_size].net_profit  = out_records[arr_size].profit + out_records[arr_size].commission + out_records[arr_size].swap;

         if(HistorySelectByPosition(out_records[arr_size].position_id))
           {
            int pos_deals = HistoryDealsTotal();
            for(int d = 0; d < pos_deals; d++)
              {
               ulong d_ticket = HistoryDealGetTicket(d);
               long entry_dir = HistoryDealGetInteger(d_ticket, DEAL_ENTRY);
               if(entry_dir == DEAL_ENTRY_IN)
                 {
                  out_records[arr_size].open_time  = (datetime)HistoryDealGetInteger(d_ticket, DEAL_TIME);
                  out_records[arr_size].open_price = HistoryDealGetDouble(d_ticket, DEAL_PRICE);
                  break;
                 }
              }
           }

         out_records[arr_size].sl             = HistoryDealGetDouble(ticket, DEAL_SL);
         out_records[arr_size].tp             = HistoryDealGetDouble(ticket, DEAL_TP);
         out_records[arr_size].behavior_tag   = "Trend Pull";
         out_records[arr_size].emotion_tag    = "Calm";
         out_records[arr_size].discipline_tag = "Disciplined";
         out_records[arr_size].setup_name     = "Breakout";
         out_records[arr_size].notes          = "VWAP retest with momentum continuation.";

         m_last_processed_ticket = ticket;
        }

      m_current_scan_index = limit;
      return (m_current_scan_index < total_deals);
     }

   void              Reset()
     {
      m_last_processed_ticket = 0;
      m_current_scan_index = 0;
     }
  };

//+------------------------------------------------------------------+
//| CORE ENGINE (ORCHESTRATOR & APPLICATION ENTRY POINT)             |
//+------------------------------------------------------------------+
class CoreEngine
  {
private:
   ThemeEngine       Theme;
   LayoutEngine      Layout;
   GraphicEngine     Graphics;
   StorageEngine     Storage;
   TaskScheduler     Scheduler;
   HistoryEngine     History;
   StatsEngine       Stats;
   BehaviorEngine    Behavior;
   CalendarEngine    Calendar;
   MonteCarloEngine  MonteCarlo;

   TradeRecord       m_records[];
   ENUM_APP_PAGE     m_current_page;
   bool              m_is_scanning;
   int               m_current_page_idx;
   int               m_sort_column_idx;
   bool              m_sort_ascending;

   // Smooth scrollable parameters (clamped strictly)
   int               m_calendar_scroll_offset;
   int               m_log_scroll_offset;
   int               m_calendar_lookback_offset; // Declared here to resolve compilation issue [1]

   // Notes Inline Editor State tracking variables
   ulong             m_editing_ticket;

   // Shell Sort algorithm for custom structures to prevent recursion crashes
   void              SortRecords(int column_idx, bool ascending)
     {
      int n = ArraySize(m_records);
      if(n <= 1)
         return;

      for(int gap = n / 2; gap > 0; gap /= 2)
        {
         for(int i = gap; i < n; i++)
           {
            TradeRecord temp = m_records[i];
            int j;
            for(j = i; j >= gap && CompareRecords(m_records[j - gap], temp, column_idx, ascending) > 0; j -= gap)
              {
               m_records[j] = m_records[j - gap];
              }
            m_records[j] = temp;
           }
        }
     }

   int               CompareRecords(const TradeRecord &a, const TradeRecord &b, int column_idx, bool ascending)
     {
      int result = 0;
      switch(column_idx)
        {
         case 0: // Date
            result = (a.close_time < b.close_time) ? -1 : ((a.close_time > b.close_time) ? 1 : 0);
            break;
         case 1: // Symbol
            result = StringCompare(a.symbol, b.symbol);
            break;
         case 2: // Type
            result = (a.type < b.type) ? -1 : ((a.type > b.type) ? 1 : 0);
            break;
         case 3: // Net Profit
            result = (a.net_profit < b.net_profit) ? -1 : ((a.net_profit > b.net_profit) ? 1 : 0);
            break;
         case 4: // Volume
            result = (a.volume < b.volume) ? -1 : ((a.volume > b.volume) ? 1 : 0);
            break;
         case 5: // Setup
            result = StringCompare(a.setup_name, b.setup_name);
            break;
         case 6: // Entry
            result = (a.open_price < b.open_price) ? -1 : ((a.open_price > b.open_price) ? 1 : 0);
            break;
         case 7: // Exit
            result = (a.close_price < b.close_price) ? -1 : ((a.close_price > b.close_price) ? 1 : 0);
            break;
         case 8: // Net SL
            result = (a.sl < b.sl) ? -1 : ((a.sl > b.sl) ? 1 : 0);
            break;
         case 9: // Tags
            result = StringCompare(a.behavior_tag, b.behavior_tag);
            break;
         default:
            result = 0;
            break;
        }
      return ascending ? result : -result;
     }

   int               GetDayOfWeek(datetime t)
     {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      return dt.day_of_week;
     }

   string            FormatDuration(long seconds)
     {
      if(seconds < 0)
         seconds = 0;
      long days = seconds / 86400;
      long rem = seconds % 86400;
      long h = rem / 3600;
      long m = (rem % 3600) / 60;
      long s = rem % 60;
      if(days > 0)
         return StringFormat("%d d %02d:%02d:%02d", days, h, m, s);
      return StringFormat("%02d:%02d:%02d", h, m, s);
     }

   datetime          GetMonthStart(int offset)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      int target_month = dt.mon + offset;
      int target_year = dt.year;
      while(target_month < 1)
        {
         target_month += 12;
         target_year--;
        }
      while(target_month > 12)
        {
         target_month -= 12;
         target_year++;
        }
      MqlDateTime target_dt;
      target_dt.year = target_year;
      target_dt.mon = target_month;
      target_dt.day = 1;
      target_dt.hour = 0;
      target_dt.min = 0;
      target_dt.sec = 0;
      return StructToTime(target_dt);
     }

   int               GetDaysInMonth(int month, int year)
     {
      if(month == 2)
        {
         if((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
            return 29;
         return 28;
        }
      if(month == 4 || month == 6 || month == 9 || month == 11)
         return 30;
      return 31;
     }

   string            GetMonthName(int m)
     {
      string names[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
      if(m >= 1 && m <= 12)
         return names[m - 1];
      return "";
     }

   // Consolidates circular indicators to display stats cleanly
   void              DrawTradeStatisticsGauges(int cx, int cy, int radius, double percentage, string label, uint fill_color)
     {
      ThemeColors colors = Theme.GetColors();

      // Draw background ring
      Graphics.DrawGridLine(cx, cy - radius, cx, cy + radius, colors.border);
      Graphics.DrawGridLine(cx - radius, cy, cx + radius, cy, colors.border);

      // Inner circle masking
      AppRect inner_rect = {cx - radius + 15, cy - radius + 15, cx + radius - 15, cy + radius - 15};
      Graphics.RenderRoundedRect(inner_rect, (radius - 15), colors.bg_main, colors.border);

      string pct_str = StringFormat("%.1f%%", percentage * 100.0);
      Graphics.RenderText(cx, cy - 8, pct_str, colors.text_primary, TA_CENTER, "Segoe UI Bold", 13);
      Graphics.RenderText(cx, cy + 12, label, colors.text_secondary, TA_CENTER, "Segoe UI Bold", 8);
     }

   void              HandleTaskSlice()
     {
      ENUM_TASK_TYPE task = Scheduler.GetNextTask();
      switch(task)
        {
         case TASK_INCREMENTAL_SCAN:
            if(m_is_scanning)
              {
               m_is_scanning = History.ProcessIncremental(m_records, 1000);
               Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
               Scheduler.MarkDirty(TASK_QUANT_STATS);
               if(!m_is_scanning)
                 {
                  PrintFormat("[INFO] History scan finalized. Total trades found: %d", ArraySize(m_records));
                  Storage.SaveToDisk(m_records);
                 }
              }
            break;

         case TASK_LIVE_SYNC:
            break;

         case TASK_QUANT_STATS:
            if(Scheduler.IsDirty(TASK_QUANT_STATS))
              {
               Stats.Calculate(m_records);
               Behavior.AuditBehavior(m_records);
               Calendar.MapTradeHistory(m_records);

               double bal = AccountInfoDouble(ACCOUNT_BALANCE);
               MonteCarlo.RunSimulation(m_records, bal);

               Scheduler.Clean(TASK_QUANT_STATS);
               Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
              }
            break;

         case TASK_BEHAVIOR_ANALYSIS:
            break;

         case TASK_CANVAS_REDRAW:
            if(Scheduler.IsDirty(TASK_CANVAS_REDRAW))
              {
               Render();
               Scheduler.Clean(TASK_CANVAS_REDRAW);
              }
            break;

         case TASK_DISK_FLUSH:
            break;

         default:
            break;
        }
     }

   void              Render()
     {
      ThemeColors colors = Theme.GetColors();
      Graphics.Clear(colors.bg_main);

      // 1. Render Header Area
      Graphics.RenderRect(Layout.Header, colors.bg_card, colors.border);
      Graphics.RenderText(20, 15, "PERFORMANCE INTELLIGENCE JOURNAL", colors.accent, TA_LEFT, "Segoe UI Semibold", 16);

      // Render Interactive Tab Controls
      string tab_names[4] = {"DASHBOARD", "DETAILED LOG", "BEHAVIOR LAB", "CALENDAR"};
      for(int i = 0; i < 4; i++)
        {
         uint bg_clr = (m_current_page == (ENUM_APP_PAGE)i) ? colors.accent : colors.bg_main;
         uint txt_clr = (m_current_page == (ENUM_APP_PAGE)i) ? ColorToARGB(clrWhite, 255) : colors.text_secondary;
         Graphics.RenderRect(Layout.NavTabs[i], bg_clr, colors.border);
         Graphics.RenderText(Layout.NavTabs[i].left + 15, Layout.NavTabs[i].top + 5, tab_names[i], txt_clr, TA_LEFT, "Segoe UI Bold", 10);
        }

      // Render Theme Toggle button
      Graphics.RenderRect(Layout.ThemeToggle, colors.bg_main, colors.border);
      Graphics.RenderText(Layout.ThemeToggle.left + 22, Layout.ThemeToggle.top + 5, "CYCLE THEME", colors.text_primary, TA_LEFT, "Segoe UI Bold", 10);

      // 2. Render KPI Summary Row
      for(int i = 0; i < 11; i++)
        {
         Graphics.RenderRect(Layout.KPI_Cards[i], colors.bg_card, colors.border);
        }

      // Update data within the summary KPI cards
      if(ArraySize(m_records) > 0)
        {
         string kpi_labels[11] = {"Win Rate", "Prof. Factor", "Sharpe", "Sortino", "Calmar", "SQN", "Kelly", "Mean Return", "Max DD (Abs)", "Max DD (%)", "Ulcer Index"};
         string kpi_vals[11];
         kpi_vals[0]  = StringFormat("%.1f%%", Stats.WinRate * 100.0);
         kpi_vals[1]  = StringFormat("%.2f", Stats.ProfitFactor);
         kpi_vals[2]  = StringFormat("%.2f", Stats.SharpeRatio);
         kpi_vals[3]  = StringFormat("%.2f", Stats.SortinoRatio);
         kpi_vals[4]  = StringFormat("%.2f", Stats.CalmarRatio);
         kpi_vals[5]  = StringFormat("%.2f", Stats.SQN);
         kpi_vals[6]  = StringFormat("%.2f", Stats.KellyCriterion);
         kpi_vals[7]  = StringFormat("%.2f", Stats.Mean);
         kpi_vals[8]  = StringFormat("%.2f", Stats.MaxDrawdownAbsolute);
         kpi_vals[9]  = StringFormat("%.1f%%", Stats.MaxDrawdownPercent);
         kpi_vals[10] = StringFormat("%.2f", Stats.UlcerIndex);

         for(int i = 0; i < 11; i++)
           {
            Graphics.RenderText(Layout.KPI_Cards[i].left + 10, Layout.KPI_Cards[i].top + 8, kpi_labels[i], colors.text_secondary, TA_LEFT, "Segoe UI Semibold", 9);
            Graphics.RenderText(Layout.KPI_Cards[i].left + 10, Layout.KPI_Cards[i].top + 28, kpi_vals[i], colors.text_primary, TA_LEFT, "Segoe UI Bold", 13);
           }
        }

      // 3. Render Main View Areas based on Active Navigation Tab
      Graphics.RenderRect(Layout.MainArea, colors.bg_card, colors.border);

      if(m_is_scanning)
        {
         Graphics.RenderText(Layout.MainArea.left + 50, Layout.MainArea.top + 50, "Processing terminal execution history. Please hold...", colors.text_secondary, TA_LEFT, "Segoe UI Semibold", 13);
        }
      else
        {
         switch(m_current_page)
           {
            case PAGE_DASHBOARD:
               RenderDashboardView(colors);
               break;
            case PAGE_DEEP_ANALYSIS:
               RenderDetailedLogView(colors);
               break;
            case PAGE_BEHAVIOR_LAB:
               RenderBehaviorView(colors);
               break;
            case PAGE_CALENDAR:
               RenderCalendarView(colors);
               break;
           }
        }

      // 4. Render Bottom AI Advisor Section
      Graphics.RenderRect(Layout.BottomCoach, colors.bg_card, colors.border);
      Graphics.RenderText(Layout.BottomCoach.left + 20, Layout.BottomCoach.top + 15, "AI PERFORMANCE ADVISOR", colors.accent, TA_LEFT, "Segoe UI Bold", 11);

      string coach_tip = "Diagnostic complete. Maintaining active discipline controls. No current execution over-leveraging observed.";
      if(Behavior.RevengeTradeCount > 0)
        {
         coach_tip = "WARNING: Active Revenge Trading detected! Avoid initiating recovery positions within 30 minutes of a loss.";
        }
      else
         if(Behavior.SlWidenedCount > 0)
           {
            coach_tip = "WARNING: Stop Loss widening detected. Expanding risk limits mid-trade degrades long-term expectancy.";
           }
         else
            if(Behavior.MissingSLCount > 0)
              {
               coach_tip = "WARNING: Positions found without initial stop-losses. Standardize protective structures.";
              }
      Graphics.RenderText(Layout.BottomCoach.left + 20, Layout.BottomCoach.top + 45, coach_tip, colors.text_primary, TA_LEFT, "Consolas", 12);

      Graphics.UpdateScreen();
     }

   // PAGE 1: Excel-style Report & Diagnostic Visual Data Dashboard (input_file_3)
   void              RenderDashboardView(ThemeColors &colors)
     {
      int content_x = Layout.MainArea.left + 20;
      int content_y = Layout.MainArea.top + 15;

      // Primary Stats Row
      AppRect top_tbl;
      top_tbl.left = content_x;
      top_tbl.top = content_y;
      top_tbl.right = Layout.MainArea.right - 20;
      top_tbl.bottom = content_y + 60;
      Graphics.RenderRect(top_tbl, colors.bg_main, colors.border);

      int top_cols = 6;
      int top_col_w = top_tbl.Width() / top_cols;
      string top_lbls[6] = {"TOTAL BUY", "TOTAL SELL", "Average Lot", "PROFIT", "LOSS", "PNL"};
      string top_vals[6];
      top_vals[0] = IntegerToString(Stats.TotalBuy);
      top_vals[1] = IntegerToString(Stats.TotalSell);
      top_vals[2] = DoubleToString(Stats.AverageLot, 2);
      top_vals[3] = DoubleToString(Stats.GrossProfit, 2);
      top_vals[4] = DoubleToString(Stats.GrossLoss * -1.0, 2);
      top_vals[5] = DoubleToString(Stats.PNL, 2);

      for(int i = 0; i < top_cols; i++)
        {
         int col_x = top_tbl.left + (i * top_col_w);
         Graphics.DrawGridLine(col_x, top_tbl.top, col_x, top_tbl.bottom, colors.border);
         Graphics.RenderText(col_x + (top_col_w / 2), top_tbl.top + 10, top_lbls[i], colors.accent, TA_CENTER, "Segoe UI Bold", 10);
         uint v_clr = colors.text_primary;
         if(i == 3)
            v_clr = colors.profit_green;
         if(i == 4)
            v_clr = colors.loss_red;
         if(i == 5)
            v_clr = (Stats.PNL >= 0.0) ? colors.profit_green : colors.loss_red;
         Graphics.RenderText(col_x + (top_col_w / 2), top_tbl.top + 32, top_vals[i], v_clr, TA_CENTER, "Consolas", 14);
        }

      // Secondary Details Row
      AppRect sec_tbl;
      sec_tbl.left = content_x;
      sec_tbl.top = top_tbl.bottom + 15;
      sec_tbl.right = Layout.MainArea.right - 20;
      sec_tbl.bottom = sec_tbl.top + 50;
      Graphics.RenderRect(sec_tbl, colors.bg_main, colors.border);

      int sec_col_w = sec_tbl.Width() / 3;
      Graphics.DrawGridLine(sec_tbl.left + sec_col_w, sec_tbl.top, sec_tbl.left + sec_col_w, sec_tbl.bottom, colors.border);
      Graphics.DrawGridLine(sec_tbl.left + (2 * sec_col_w), sec_tbl.top, sec_tbl.left + (2 * sec_col_w), sec_tbl.bottom, colors.border);

      // Average Win / Loss Metrics
      Graphics.RenderText(sec_tbl.left + 15, sec_tbl.top + 8, "Average Win: " + DoubleToString(Stats.AverageWin, 2), colors.profit_green, TA_LEFT, "Segoe UI Bold", 10);
      Graphics.RenderText(sec_tbl.left + sec_col_w + 15, sec_tbl.top + 8, "Average Loss: " + DoubleToString(Stats.AverageLoss, 2), colors.loss_red, TA_LEFT, "Segoe UI Bold", 10);
      string win_loss_note = (Stats.AverageWin > MathAbs(Stats.AverageLoss)) ? "Good job, Avr win is bigger than Avr loss" : "Pay attention: Avr loss exceeds Avr win";
      Graphics.RenderText(sec_tbl.left + (2 * sec_col_w) + 15, sec_tbl.top + 8, "Note: " + win_loss_note, colors.text_secondary, TA_LEFT, "Segoe UI Italic", 10);

      // Biggest Win / Loss Metrics
      Graphics.RenderText(sec_tbl.left + 15, sec_tbl.top + 28, "Biggest Win: " + DoubleToString(Stats.BiggestWin, 2), colors.profit_green, TA_LEFT, "Segoe UI Bold", 10);
      Graphics.RenderText(sec_tbl.left + sec_col_w + 15, sec_tbl.top + 28, "Biggest Loss: " + DoubleToString(Stats.BiggestLoss, 2), colors.loss_red, TA_LEFT, "Segoe UI Bold", 10);
      string biggest_note = (Stats.BiggestWin > MathAbs(Stats.BiggestLoss)) ? "Good job, Biggest win is bigger than Biggest loss" : "Risk alert: Biggest loss is bigger than Biggest win";
      Graphics.RenderText(sec_tbl.left + (2 * sec_col_w) + 15, sec_tbl.top + 28, "Note: " + biggest_note, colors.text_secondary, TA_LEFT, "Segoe UI Italic", 10);

      // Third Details Row: Profit Factor, Average Trade Duration, and Long/Short Durations
      AppRect thr_tbl;
      thr_tbl.left = content_x;
      thr_tbl.top = sec_tbl.bottom + 15;
      thr_tbl.right = Layout.MainArea.right - 20;
      thr_tbl.bottom = thr_tbl.top + 55;
      Graphics.RenderRect(thr_tbl, colors.bg_main, colors.border);

      int thr_col_w = thr_tbl.Width() / 3;
      Graphics.DrawGridLine(thr_tbl.left + thr_col_w, thr_tbl.top, thr_tbl.left + thr_col_w, thr_tbl.bottom, colors.border);
      Graphics.DrawGridLine(thr_tbl.left + (2 * thr_col_w), thr_tbl.top, thr_tbl.left + (2 * thr_col_w), thr_tbl.bottom, colors.border);

      Graphics.RenderText(thr_tbl.left + 20, thr_tbl.top + 8, "Profit Factor: " + DoubleToString(Stats.ProfitFactor, 2), colors.text_primary, TA_LEFT, "Segoe UI Bold", 10);
      Graphics.RenderText(thr_tbl.left + 20, thr_tbl.top + 28, "Avg PNL: " + DoubleToString(Stats.Mean, 2), colors.text_secondary, TA_LEFT, "Segoe UI", 10);

      Graphics.RenderText(thr_tbl.left + thr_col_w + 20, thr_tbl.top + 8, "Avg Duration: " + FormatDuration(Stats.AverageTradeDurationSeconds), colors.text_primary, TA_LEFT, "Segoe UI Bold", 10);
      string dur_metrics = StringFormat("Long: %s | Short: %s", FormatDuration(Stats.AvgLongDurationSeconds), FormatDuration(Stats.ShortAvgDurationSeconds));
      Graphics.RenderText(thr_tbl.left + thr_col_w + 20, thr_tbl.top + 28, dur_metrics, colors.text_secondary, TA_LEFT, "Consolas", 9);

      // Dynamic Long/Short trades count statistics summary
      string l_s_str = StringFormat("Long: %d (%.1f%% WR) | Short: %d (%.1f%% WR)", Stats.LongTrades, Stats.LongWinRate * 100.0, Stats.ShortTrades, Stats.ShortWinRate * 100.0);
      Graphics.RenderText(thr_tbl.left + (2 * thr_col_w) + 20, thr_tbl.top + 8, "Long vs Short Trades Count", colors.accent, TA_LEFT, "Segoe UI Bold", 10);
      Graphics.RenderText(thr_tbl.left + (2 * thr_col_w) + 20, thr_tbl.top + 28, l_s_str, colors.text_primary, TA_LEFT, "Segoe UI", 9);

      // Visual Bar Charts Rendering Area
      int chart_w = (Layout.MainArea.Width() - 50) / 2;
      int chart_y1 = thr_tbl.bottom + 20;
      int chart_y2 = Layout.MainArea.bottom - 20;

      // Chart 1: Dynamic history Asset Trades Count Chart
      AppRect c1_rect;
      c1_rect.left = content_x;
      c1_rect.top = chart_y1;
      c1_rect.right = content_x + chart_w;
      c1_rect.bottom = chart_y2;
      Graphics.RenderRect(c1_rect, colors.bg_main, colors.border);

      SymbolCount sys_counts[];
      PopulateSymbolCounts(sys_counts);
      int counts_size = ArraySize(sys_counts);
      string sys_labels[];
      double sys_values[];
      ArrayResize(sys_labels, MathMin(counts_size, 5));
      ArrayResize(sys_values, MathMin(counts_size, 5));
      for(int i = 0; i < MathMin(counts_size, 5); i++)
        {
         sys_labels[i] = sys_counts[i].symbol;
         sys_values[i] = (double)sys_counts[i].count;
        }
      DrawBarChart(c1_rect, "Asset Trades Count", sys_labels, sys_values, colors.accent, colors.text_primary, colors.border);

      // Chart 2: Dynamic history Month Profit Distribution Chart
      AppRect c2_rect;
      c2_rect.left = c1_rect.right + 10;
      c2_rect.top = chart_y1;
      c2_rect.right = Layout.MainArea.right - 20;
      c2_rect.bottom = chart_y2;
      Graphics.RenderRect(c2_rect, colors.bg_main, colors.border);

      double rolling_monthly_pnl[6];
      string rolling_month_labels[6];
      ArrayInitialize(rolling_monthly_pnl, 0.0);
      PopulateMonthlyPnL(rolling_monthly_pnl, rolling_month_labels);
      DrawBarChart(c2_rect, "Profit Distribution / Month", rolling_month_labels, rolling_monthly_pnl, colors.profit_green, colors.text_primary, colors.border);
     }

   // Dynamic Generic Bar Chart Renderer Primitive
   void              DrawBarChart(AppRect &rect, string title, const string &labels[], const double &values[], uint bar_color, uint text_color, uint grid_color)
     {
      int size = ArraySize(labels);
      if(size == 0)
         return;

      Graphics.RenderText(rect.left + 15, rect.top + 10, title, text_color, TA_LEFT, "Segoe UI Bold", 10);

      int chart_y1 = rect.top + 40;
      int chart_y2 = rect.bottom - 25;
      int chart_x1 = rect.left + 40;
      int chart_x2 = rect.right - 20;

      int chart_w = chart_x2 - chart_x1;
      int chart_h = chart_y2 - chart_y1;

      Graphics.DrawGridLine(chart_x1, chart_y2, chart_x2, chart_y2, grid_color);
      Graphics.DrawGridLine(chart_x1, chart_y1, chart_x1, chart_y2, grid_color);

      double max_val = 0.00001;
      double min_val = 0.0;
      for(int i = 0; i < size; i++)
        {
         if(values[i] > max_val)
            max_val = values[i];
         if(values[i] < min_val)
            min_val = values[i];
        }

      double range = max_val - min_val;
      int col_w = chart_w / size;

      for(int i = 0; i < size; i++)
        {
         int bar_x1 = chart_x1 + (i * col_w) + 10;
         int bar_x2 = bar_x1 + col_w - 20;

         int zero_y = chart_y2;
         if(min_val < 0)
           {
            zero_y = chart_y2 - (int)((MathAbs(min_val) / range) * chart_h);
           }

         int val_y = zero_y;
         if(values[i] >= 0)
           {
            int height = (int)((values[i] / range) * chart_h);
            val_y = zero_y - height;
            AppRect bar_rect = {bar_x1, val_y, bar_x2, zero_y};
            Graphics.RenderRoundedRect(bar_rect, 4, bar_color, grid_color);
           }
         else
           {
            int height = (int)((MathAbs(values[i]) / range) * chart_h);
            val_y = zero_y + height;
            AppRect bar_rect = {bar_x1, zero_y, bar_x2, val_y};
            Graphics.RenderRoundedRect(bar_rect, 4, ColorToARGB(clrRed, 255), grid_color);
           }

         // Text Labels below bars
         Graphics.RenderText((bar_x1 + bar_x2) / 2, chart_y2 + 5, labels[i], text_color, TA_CENTER, "Segoe UI", 9);
        }
     }

   // Generates historical symbol trades statistics
   void              PopulateSymbolCounts(SymbolCount &out_counts[])
     {
      ArrayFree(out_counts);
      for(int i = 0; i < ArraySize(m_records); i++)
        {
         string sym = m_records[i].symbol;
         bool found = false;
         for(int j = 0; j < ArraySize(out_counts); j++)
           {
            if(out_counts[j].symbol == sym)
              {
               out_counts[j].count++;
               found = true;
               break;
              }
           }
         if(!found)
           {
            int size = ArraySize(out_counts);
            ArrayResize(out_counts, size + 1);
            out_counts[size].symbol = sym;
            out_counts[size].count = 1;
           }
        }
      // Simple bubble sort descending
      int n = ArraySize(out_counts);
      for(int i = 0; i < n - 1; i++)
        {
         for(int j = 0; j < n - i - 1; j++)
           {
            if(out_counts[j].count < out_counts[j + 1].count)
              {
               SymbolCount temp = out_counts[j];
               out_counts[j] = out_counts[j + 1];
               out_counts[j + 1] = temp;
              }
           }
        }
     }

   // Generates rolling monthly profit/loss curves from actual trade history
   void              PopulateMonthlyPnL(double &out_monthly_pnl[], string &out_month_labels[])
     {
      for(int m = 0; m < 6; m++)
        {
         datetime month_start = GetMonthStart(-5 + m);
         MqlDateTime dt;
         TimeToStruct(month_start, dt);
         out_month_labels[m] = GetMonthName(dt.mon);
         out_monthly_pnl[m] = 0.0;

         for(int i = 0; i < ArraySize(m_records); i++)
           {
            MqlDateTime t_dt;
            TimeToStruct(m_records[i].close_time, t_dt);
            if(t_dt.mon == dt.mon && t_dt.year == dt.year)
              {
               out_monthly_pnl[m] += m_records[i].net_profit;
              }
           }
        }
     }

   // PAGE 2: Modern Scrollable Unified Card Log with Inline Notes Editing (input_file_16)
   void              RenderDetailedLogView(ThemeColors &colors)
     {
      int total_records = ArraySize(m_records);
      int card_h = 110;
      int card_gap = 10;

      // Establish visibility scissoring coordinates based on dynamic wheel offsets
      int viewport_top = Layout.MainArea.top + 20;
      int viewport_bottom = Layout.MainArea.bottom - 40;

      int cur_card_y = viewport_top - m_log_scroll_offset;

      for(int i = 0; i < total_records; i++)
        {
         AppRect card_rect;
         card_rect.left = Layout.MainArea.left + 20;
         card_rect.top = cur_card_y;
         card_rect.right = Layout.MainArea.right - 20;
         card_rect.bottom = cur_card_y + card_h;

         // Check if card falls within visibility limits before rendering
         if(card_rect.bottom > viewport_top && card_rect.top < viewport_bottom)
           {
            Graphics.RenderRoundedRect(card_rect, 6, colors.bg_main, colors.border);

            // Row 1: Direction Badge, setup, and performance grading tags
            string dir_str = (m_records[i].type == DEAL_TYPE_BUY) ? "BUY" : "SELL";
            uint dir_clr = (m_records[i].type == DEAL_TYPE_BUY) ? colors.profit_green : colors.loss_red;

            Graphics.RenderText(card_rect.left + 15, card_rect.top + 15, m_records[i].symbol, colors.text_primary, TA_LEFT, "Segoe UI Bold", 13);

            AppRect dir_rect = {card_rect.left + 85, card_rect.top + 15, card_rect.left + 125, card_rect.top + 33};
            Graphics.RenderRoundedRect(dir_rect, 3, dir_clr, colors.border);
            Graphics.RenderText(dir_rect.left + 8, dir_rect.top + 2, dir_str, ColorToARGB(clrWhite, 255), TA_LEFT, "Segoe UI Bold", 9);

            AppRect pill_rect1 = {dir_rect.right + 10, card_rect.top + 15, dir_rect.right + 90, card_rect.top + 33};
            Graphics.RenderRoundedRect(pill_rect1, 3, colors.accent, colors.border);
            Graphics.RenderText(pill_rect1.left + 10, pill_rect1.top + 2, m_records[i].behavior_tag, ColorToARGB(clrWhite, 255), TA_LEFT, "Segoe UI Bold", 9);

            uint grade_clr = colors.profit_green;
            string grade_text = "A+ - 92";
            if(m_records[i].net_profit < 0.0)
              {
               grade_clr = colors.loss_red;
               grade_text = "D - 40";
              }
            AppRect grade_rect = {pill_rect1.right + 10, card_rect.top + 15, pill_rect1.right + 80, card_rect.top + 33};
            Graphics.RenderRoundedRect(grade_rect, 3, grade_clr, colors.border);
            Graphics.RenderText(grade_rect.left + 12, grade_rect.top + 2, grade_text, ColorToARGB(clrWhite, 255), TA_LEFT, "Segoe UI Bold", 9);

            // Display editable Note. If clicked, the engine prompts the inline modal editor.
            string current_note = m_records[i].notes;
            if(m_records[i].ticket == m_editing_ticket)
              {
               current_note = "[Editing note below...]";
              }
            Graphics.RenderText(card_rect.left + 15, card_rect.top + 45, current_note, colors.text_primary, TA_LEFT, "Segoe UI Semibold", 11);

            // Bottom metadata info row
            string metadata = StringFormat("#%d | Closed: %s", m_records[i].ticket, TimeToString(m_records[i].close_time, TIME_DATE|TIME_MINUTES));
            Graphics.RenderText(card_rect.left + 15, card_rect.top + 73, metadata, colors.text_secondary, TA_LEFT, "Consolas", 10);

            uint profit_clr = (m_records[i].net_profit >= 0.0) ? colors.profit_green : colors.loss_red;
            string profit_str = StringFormat("%+.2f", m_records[i].net_profit);
            Graphics.RenderText(card_rect.right - 140, card_rect.top + 72, profit_str, profit_clr, TA_RIGHT, "Consolas Bold", 11);

            // Render Interactive Edit Pencil icon and Delete trash icon
            Graphics.RenderText(card_rect.right - 60, card_rect.top + 20, "✏️", colors.text_secondary, TA_CENTER, "Segoe UI", 12);
            Graphics.RenderText(card_rect.right - 30, card_rect.top + 20, "🗑️", colors.loss_red, TA_CENTER, "Segoe UI", 12);
           }
         cur_card_y += card_h + card_gap;
        }

      // Bottom Scissored layout panel mask to isolate scroll items
      AppRect cover_pane = {Layout.MainArea.left, Layout.MainArea.bottom - 40, Layout.MainArea.right, Layout.MainArea.bottom};
      Graphics.RenderRect(cover_pane, colors.bg_card, colors.border);

      string scroll_str = StringFormat("Mouse Wheel: Scroll Log | Displaying %d total trades", total_records);
      Graphics.RenderText(Layout.MainArea.left + 20, Layout.MainArea.bottom - 25, scroll_str, colors.text_secondary, TA_LEFT, "Segoe UI Semibold", 9);
     }

   void              RenderBehaviorView(ThemeColors &colors)
     {
      Graphics.RenderText(Layout.MainArea.left + 30, Layout.MainArea.top + 30, "BEHAVIORAL RISK ANALYSIS PROFILE", colors.accent, TA_LEFT, "Segoe UI Semibold", 14);

      string b_lbls[5] = {"1. Revenge Entry Counts:", "2. FOMO Pursuit Cases:", "3. Panic Position Liquidations:", "4. Unprotected Initial Entries (No SL):", "5. Retrospective Stop Loss Widening (Discipline):"};
      string b_vals[5];
      b_vals[0] = StringFormat("%d events (Opened < 30m after loss with elevated volume scale)", Behavior.RevengeTradeCount);
      b_vals[1] = StringFormat("%d events (Position executions at extreme standard deviation extensions)", Behavior.FOMOTradeCount);
      b_vals[2] = StringFormat("%d events (Positions exited within 5 minutes under high volatility)", Behavior.PanicCloseCount);
      b_vals[3] = StringFormat("%d events (Initial execution orders processed without protective stop-losses)", Behavior.MissingSLCount);
      b_vals[4] = StringFormat("%d events (Stop-losses moved wider mid-trade to delay termination)", Behavior.SlWidenedCount);

      int y_pos = Layout.MainArea.top + 80;
      for(int i = 0; i < 5; i++)
        {
         Graphics.RenderText(Layout.MainArea.left + 50, y_pos, b_lbls[i], colors.text_secondary, TA_LEFT, "Segoe UI Bold", 11);
         uint clr = (i < 5) ? colors.loss_red : colors.text_primary;
         Graphics.RenderText(Layout.MainArea.left + 450, y_pos, b_vals[i], clr, TA_LEFT, "Consolas", 11);
         y_pos += 30;
        }

      // Actionable Optimization Guides based on behavioral metrics (input_file_17 requested guides)
      int gy = y_pos + 15;
      Graphics.DrawGridLine(Layout.MainArea.left + 30, gy, Layout.MainArea.right - 30, gy, colors.border);

      gy += 15;
      Graphics.RenderText(Layout.MainArea.left + 30, gy, "PSYCHOLOGICAL GUIDELINES & REMEDIES", colors.accent, TA_LEFT, "Segoe UI Bold", 12);
      gy += 25;

      // Determine what requires structural correction
      string correction_tip = "DASHBOARD FEEDBACK: System performance profile indicates stable rule compliance. Maintain protective limits.";
      if(Behavior.RevengeTradeCount > 5)
        {
         correction_tip = "EMOTION CORRECTION ALERT: High revenge index suggests loss chasing. Enforce a hard 24-hour terminal lockout after 2 consecutive losses.";
        }
      else
         if(Behavior.SlWidenedCount > 3)
           {
            correction_tip = "RISK MANAGEMENT WARNING: Pattern of Stop-Loss widening detected. Optimize risk allocation size per trade rather than widening SL mid-trade.";
           }
         else
            if(Stats.WinRate < 0.40)
              {
               correction_tip = "STRATEGY OPTIMIZATION: Win rate is below 40%. Consider optimizing entry criteria, scaling down position size, or tightening asset correlation checks.";
              }
      Graphics.RenderText(Layout.MainArea.left + 50, gy, correction_tip, colors.text_primary, TA_LEFT, "Segoe UI Semibold", 10);

      gy += 25;
      Graphics.RenderText(Layout.MainArea.left + 30, gy, "RISK MANAGEMENT PARAMETERS FOR OPTIMIZATION", colors.accent, TA_LEFT, "Segoe UI Bold", 11);
      gy += 20;

      string rm_params = StringFormat("Kelly Criterion Recommendation: %.1f%% | Max Capital Risk per Trade: 1.0%% | Position Size Bet Scale: %.2f Lots", Stats.KellyCriterion * 100.0, Stats.AverageLot);
      Graphics.RenderText(Layout.MainArea.left + 50, gy, rm_params, colors.text_secondary, TA_LEFT, "Consolas", 10);
     }

   // PAGE 4: Scrollable Monthly Calendar Matrix (input_file_10 style)
   void              RenderCalendarView(ThemeColors &colors)
     {
      Graphics.RenderText(Layout.MainArea.left + 30, Layout.MainArea.top + 15, "SCROLLABLE ACTIVITY CALENDAR", colors.accent, TA_LEFT, "Segoe UI Bold", 14);
      Graphics.RenderText(Layout.MainArea.left + 30, Layout.MainArea.top + 35, "Use your Mouse Wheel to scroll vertically through historical months.", colors.text_secondary, TA_LEFT, "Segoe UI Italic", 9);

      // Grid position configurations
      int cell_w = 110;
      int cell_h = 50;
      int cell_gap = 4;
      int grid_start_x = Layout.MainArea.left + 30;
      int base_start_y = Layout.MainArea.top + 60;

      // Filter and pre-aggregate monthly trades for daily buckets
      double daily_pnl[32];
      int daily_trade_count[32];

      // Draw three consecutive stacked months (vertical calendar scroll list)
      // Render coordinate adjusts dynamically based on the scroll wheel offset 'm_calendar_scroll_offset'
      int visual_y_offset = -m_calendar_scroll_offset;
      int start_month_offset = -3; // Start lookup 3 months back

      for(int m = 0; m < 5; m++)   // Stack up to 5 months vertically
        {
         datetime cur_month_start = GetMonthStart(start_month_offset + m);
         MqlDateTime m_dt;
         TimeToStruct(cur_month_start, m_dt);

         int days_in_month = GetDaysInMonth(m_dt.mon, m_dt.year);
         int first_day_dow = GetDayOfWeek(cur_month_start);
         int start_cell_idx = (first_day_dow == 0) ? 6 : (first_day_dow - 1);

         int month_block_height = ((start_cell_idx + days_in_month + 6) / 7) * (cell_h + cell_gap) + 40;
         int block_top_y = base_start_y + visual_y_offset;

         // Check layout boundaries to scissor/prevent overflow rendering
         if(block_top_y + month_block_height > Layout.MainArea.top + 40 && block_top_y < Layout.MainArea.bottom - 10)
           {

            // Draw Month Section Title inside visibility bounds
            string month_header = StringFormat("%s %d", GetMonthName(m_dt.mon), m_dt.year);
            Graphics.RenderText(grid_start_x, block_top_y + 5, month_header, colors.accent, TA_LEFT, "Segoe UI Bold", 11);

            // Draw Day of Week Header labels
            string dow_lbls[7] = {"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"};
            for(int i = 0; i < 7; i++)
              {
               int header_x = grid_start_x + (i * (cell_w + cell_gap)) + (cell_w / 2);
               Graphics.RenderText(header_x, block_top_y + 25, dow_lbls[i], colors.text_secondary, TA_CENTER, "Segoe UI Bold", 8);
              }

            // Group transactions for current target month
            ArrayInitialize(daily_pnl, 0.0);
            ArrayInitialize(daily_trade_count, 0);

            for(int i = 0; i < ArraySize(m_records); i++)
              {
               MqlDateTime t_dt;
               TimeToStruct(m_records[i].close_time, t_dt);
               if(t_dt.mon == m_dt.mon && t_dt.year == m_dt.year)
                 {
                  daily_pnl[t_dt.day] += m_records[i].net_profit;
                  daily_trade_count[t_dt.day]++;
                 }
              }

            int cell_idx = start_cell_idx;
            int days_start_y = block_top_y + 40;

            for(int d = 1; d <= days_in_month; d++)
              {
               int row = cell_idx / 7;
               int col = cell_idx % 7;

               AppRect cell_rect;
               cell_rect.left = grid_start_x + (col * (cell_w + cell_gap));
               cell_rect.top = days_start_y + (row * (cell_h + cell_gap));
               cell_rect.right = cell_rect.left + cell_w;
               cell_rect.bottom = cell_rect.top + cell_h;

               // Render day cells only if they sit within the primary main panel viewport bounds
               if(cell_rect.bottom < Layout.MainArea.bottom - 10 && cell_rect.top > Layout.MainArea.top + 80)
                 {
                  uint tile_clr = colors.bg_main; // default empty
                  uint border_clr = colors.border;

                  if(daily_trade_count[d] > 0)
                    {
                     tile_clr = (daily_pnl[d] >= 0.0) ? colors.profit_green : colors.loss_red;
                     tile_clr = ColorToARGB((color)tile_clr, 55); // Alpha card overlay
                    }

                  Graphics.RenderRoundedRect(cell_rect, 4, tile_clr, border_clr);
                  Graphics.RenderText(cell_rect.left + 6, cell_rect.top + 4, IntegerToString(d), colors.text_secondary, TA_LEFT, "Segoe UI Bold", 9);

                  if(daily_trade_count[d] > 0)
                    {
                     string p_str = StringFormat("%+.2f", daily_pnl[d]);
                     Graphics.RenderText(cell_rect.left + (cell_w / 2), cell_rect.top + 18, p_str, colors.text_primary, TA_CENTER, "Consolas Bold", 9);

                     string tc_str = StringFormat("%d Trades", daily_trade_count[d]);
                     Graphics.RenderText(cell_rect.left + (cell_w / 2), cell_rect.top + 33, tc_str, colors.text_secondary, TA_CENTER, "Segoe UI", 8);
                    }
                  else
                    {
                     Graphics.RenderText(cell_rect.left + (cell_w / 2), cell_rect.top + 18, "-", colors.text_secondary, TA_CENTER, "Consolas Bold", 9);
                    }
                 }
               cell_idx++;
              }
           }
         visual_y_offset += month_block_height;
        }
     }

   // Processes temporary text input edit updates
   void              UpdateTradeRecordNote(ulong ticket, string note)
     {
      for(int i = 0; i < ArraySize(m_records); i++)
        {
         if(m_records[i].ticket == ticket)
           {
            m_records[i].notes = note;
            Storage.SaveToDisk(m_records);
            PrintFormat("[INFO] Trade Note updated for Ticket #%d: %s", ticket, note);
            break;
           }
        }
     }

public:
                     CoreEngine() : m_current_page(PAGE_DASHBOARD), m_is_scanning(true), m_current_page_idx(0), m_sort_column_idx(0), m_sort_ascending(false), m_calendar_scroll_offset(0), m_log_scroll_offset(0), m_calendar_lookback_offset(0), m_editing_ticket(0) {}
                    ~CoreEngine() {}

   bool              Initialize()
     {
      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, false);
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, false);
      ChartSetInteger(0, CHART_SHOW_GRID, false);
      ChartSetInteger(0, CHART_MODE, CHART_LINE);

      int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

      if(!Graphics.Initialize(width, height))
         return false;

      Layout.Recalculate(width, height);

      if(Storage.LoadFromDisk(m_records))
        {
         m_is_scanning = false;
         PrintFormat("[INFO] Successfully recovered trade profile state from local database: %d records.", ArraySize(m_records));
        }
      else
        {
         m_is_scanning = true;
         History.Reset();
        }

      EventSetMillisecondTimer(SCHEDULER_INTERVAL_MS);

      // Explicitly mark calculation tasks dirty on load to populate summaries
      Scheduler.MarkDirty(TASK_QUANT_STATS);
      Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
      return true;
     }

   void              OnResize(int width, int height)
     {
      Graphics.Initialize(width, height);
      Layout.Recalculate(width, height);
      Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
     }

   void              OnScroll(int delta)
     {
      if(m_current_page == PAGE_CALENDAR)
        {
         m_calendar_scroll_offset -= (delta * 3);
         m_calendar_scroll_offset = MathMax(0, MathMin(m_calendar_scroll_offset, 1200));
         Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
        }
      else
         if(m_current_page == PAGE_DEEP_ANALYSIS)
           {
            m_log_scroll_offset -= (delta * 4);
            int total_cards_height = ArraySize(m_records) * 112;
            int max_scroll = MathMax(0, total_cards_height - Layout.MainArea.Height() + 80);
            m_log_scroll_offset = MathMax(0, MathMin(m_log_scroll_offset, max_scroll));
            Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
           }
     }

   void              OnClick(int x, int y)
     {
      // 1. Navigation Tab selections
      for(int i = 0; i < 4; i++)
        {
         if(Layout.NavTabs[i].Contains(x, y))
           {
            m_current_page = (ENUM_APP_PAGE)i;
            m_current_page_idx = 0;
            m_calendar_scroll_offset = 0;
            m_log_scroll_offset = 0;

            // Clean up note text inputs if active on page transition
            ObjectDelete(0, "Journal_Note_Editor");
            m_editing_ticket = 0;

            Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
            return;
           }
        }

      // 2. Cycle Theme selections
      if(Layout.ThemeToggle.Contains(x, y))
        {
         int next_theme = (int)Theme.GetTheme() + 1;
         if(next_theme > 3)
            next_theme = 0;
         Theme.SetTheme((ENUM_APP_THEME)next_theme);
         Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
         return;
        }

      // 3. Process Page specific Click handlers
      if(m_current_page == PAGE_DASHBOARD)
        {
         for(int i = 0; i < 10; i++)
           {
            if(Layout.ColumnHeaders[i].Contains(x, y))
              {
               if(m_sort_column_idx == i)
                 {
                  m_sort_ascending = !m_sort_ascending;
                 }
               else
                 {
                  m_sort_column_idx = i;
                  m_sort_ascending = true;
                 }
               SortRecords(m_sort_column_idx, m_sort_ascending);
               Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
               return;
              }
           }
        }
      else
         if(m_current_page == PAGE_DEEP_ANALYSIS)   // Detailed scrollable card log
           {
            int viewport_top = Layout.MainArea.top + 20;
            int cur_card_y = viewport_top - m_log_scroll_offset;

            for(int i = 0; i < ArraySize(m_records); i++)
              {
               AppRect card_rect;
               card_rect.left = Layout.MainArea.left + 20;
               card_rect.top = cur_card_y;
               card_rect.right = Layout.MainArea.right - 20;
               card_rect.bottom = cur_card_y + 110;

               if(card_rect.bottom > viewport_top && card_rect.top < Layout.MainArea.bottom - 40)
                 {
                  // Hit target check for Pencil Icon (✏️) [card_rect.right - 70 to card_rect.right - 50]
                  if(x >= card_rect.right - 70 && x <= card_rect.right - 50 && y >= card_rect.top + 15 && y <= card_rect.top + 35)
                    {

                     // Reset previous editor objects if active
                     ObjectDelete(0, "Journal_Note_Editor");

                     m_editing_ticket = m_records[i].ticket;

                     // Spawn MQL5 Native Edit input overlay right at the Notes section of the card
                     ObjectCreate(0, "Journal_Note_Editor", OBJ_EDIT, 0, 0, 0);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_XDISTANCE, card_rect.left + 15);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_YDISTANCE, card_rect.top + 45);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_XSIZE, card_rect.Width() - 250);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_YSIZE, 22);
                     ObjectSetString(0, "Journal_Note_Editor", OBJPROP_TEXT, m_records[i].notes);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_FONTSIZE, 9);
                     ObjectSetInteger(0, "Journal_Note_Editor", OBJPROP_SELECTABLE, true);

                     // Force Focus on input object
                     ChartRedraw();
                     Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
                     return;
                    }

                  // Hit target check for Delete Trash Icon (🗑️) [card_rect.right - 40 to card_rect.right - 20]
                  if(x >= card_rect.right - 40 && x <= card_rect.right - 20 && y >= card_rect.top + 15 && y <= card_rect.top + 35)
                    {
                     // Delete trade logic
                     ArrayRemove(m_records, i, 1);
                     Storage.SaveToDisk(m_records);
                     Scheduler.MarkDirty(TASK_QUANT_STATS);
                     return;
                    }
                 }
               cur_card_y += 120;
              }

            // Clicked outside active input boundaries terminates editing mode
            if(m_editing_ticket != 0 && x < Layout.MainArea.left + 15)
              {
               ObjectDelete(0, "Journal_Note_Editor");
               m_editing_ticket = 0;
               Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
              }
           }
     }

   // Captures modal input modifications on editing
   void              OnNoteEditFinalize()
     {
      if(m_editing_ticket != 0)
        {
         string updated_text = ObjectGetString(0, "Journal_Note_Editor", OBJPROP_TEXT);
         UpdateTradeRecordNote(m_editing_ticket, updated_text);
         ObjectDelete(0, "Journal_Note_Editor");
         m_editing_ticket = 0;
         Scheduler.MarkDirty(TASK_CANVAS_REDRAW);
        }
     }

   void              Update()
     {
      HandleTaskSlice();
     }

   void              Shutdown()
     {
      EventKillTimer();
      Graphics.Shutdown();
      ObjectDelete(0, "Journal_Note_Editor");

      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, true);
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, true);
      ChartSetInteger(0, CHART_SHOW_GRID, true);
     }
  };

//+------------------------------------------------------------------+
//| GLOBAL INSTANCE AND MT5 DELEGATE HANDLERS                        |
//+------------------------------------------------------------------+
CoreEngine *G_CoreInstance = NULL;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   G_CoreInstance = new CoreEngine();
   if(G_CoreInstance == NULL)
     {
      return INIT_FAILED;
     }
   if(!G_CoreInstance.Initialize())
     {
      delete G_CoreInstance;
      G_CoreInstance = NULL;
      return INIT_FAILED;
     }
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(G_CoreInstance != NULL)
     {
      G_CoreInstance.Shutdown();
      delete G_CoreInstance;
      G_CoreInstance = NULL;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(G_CoreInstance != NULL)
     {
      G_CoreInstance.Update();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(G_CoreInstance != NULL)
     {
      G_CoreInstance.Update();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(G_CoreInstance == NULL)
      return;

   if(id == CHARTEVENT_CHART_CHANGE)
     {
      int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      G_CoreInstance.OnResize(width, height);
     }
   else
      if(id == CHARTEVENT_CLICK)
        {
         G_CoreInstance.OnClick((int)lparam, (int)dparam);
        }
      else
         if(id == CHARTEVENT_OBJECT_CLICK)
           {
            if(sparam == "Journal_Canvas_FB")
              {
               G_CoreInstance.OnClick((int)lparam, (int)dparam);
              }
           }
         // Catch mouse wheel scrollers
         else
            if(id == CHARTEVENT_MOUSE_WHEEL)
              {
               G_CoreInstance.OnScroll((int)lparam);
              }
            // Catch native Modal Input Note editing finalize event
            else
               if(id == CHARTEVENT_OBJECT_ENDEDIT)
                 {
                  if(sparam == "Journal_Note_Editor")
                    {
                     G_CoreInstance.OnNoteEditFinalize();
                    }
                 }
  }
//+------------------------------------------------------------------+
