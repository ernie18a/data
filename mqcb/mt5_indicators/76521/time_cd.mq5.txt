//+------------------------------------------------------------------+
//|                                              CandleCountdown.mq5 |
//|                                    Copyright 2026, Mr. H (Coder) |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Mr. H - Professional MQL5 Coder"
#property version   "1.10"
#property indicator_chart_window

//--- INPUTS
input group             "--- Cấu hình Hiển thị ---"
input color             InpTextColor   = clrYellow;        // Màu chữ đếm ngược
input int               InpFontSize    = 10;               // Cỡ chữ
input string            InpFontName    = "Arial Bold";     // Font chữ
input ENUM_ANCHOR_POINT InpAnchor      = ANCHOR_LEFT;      // Điểm mỏ neo chữ (Mặc định: Bắt đầu từ nến kéo sang phải)

//--- GLOBAL CONSTANTS
#define OBJ_NAME "Candle_Countdown_Text_Candle"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// Tạo Timer cập nhật mỗi 1 giây
   EventSetTimer(1);

// Khởi tạo Object Text bám theo biểu đồ
   if(ObjectFind(0, OBJ_NAME) < 0)
     {
      ObjectCreate(0, OBJ_NAME, OBJ_TEXT, 0, 0, 0);
      ObjectSetInteger(0, OBJ_NAME, OBJPROP_COLOR, InpTextColor);
      ObjectSetInteger(0, OBJ_NAME, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, OBJ_NAME, OBJPROP_FONT, InpFontName);
      ObjectSetInteger(0, OBJ_NAME, OBJPROP_ANCHOR, InpAnchor);
      ObjectSetInteger(0, OBJ_NAME, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, OBJ_NAME, OBJPROP_HIDDEN, true);
     }

   UpdateCountdown();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, OBJ_NAME);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   UpdateCountdown();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer event function                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateCountdown();
  }

//+------------------------------------------------------------------+
//| Hàm tính toán và cập nhật vị trí chữ cạnh nến                    |
//+------------------------------------------------------------------+
void UpdateCountdown()
  {
// Lấy thời gian mở nến hiện tại
   datetime barTime = iTime(_Symbol, _Period, 0);
   if(barTime == 0)
      return;

// Tính thời gian đếm ngược
   datetime nextBarTime = barTime + PeriodSeconds(_Period);
   datetime currentTime = TimeCurrent();

   int remainingSeconds = (int)(nextBarTime - currentTime);
   if(remainingSeconds < 0)
      remainingSeconds = 0;

   int hours   = remainingSeconds / 3600;
   int minutes = (remainingSeconds % 3600) / 60;
   int seconds = remainingSeconds % 60;

// Định dạng chuỗi hiển thị
   string textStr = "";
   if(hours > 0)
      textStr = StringFormat("  ⏳ %02d:%02d:%02d", hours, minutes, seconds);
   else
      textStr = StringFormat("  ⏳ %02d:%02d", minutes, seconds);

// Lấy giá Bid hiện tại
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

// Cập nhật tọa độ (Thời gian nến [0], Giá Bid hiện tại) và Nội dung
   ObjectMove(0, OBJ_NAME, 0, barTime, currentPrice);
   ObjectSetString(0, OBJ_NAME, OBJPROP_TEXT, textStr);

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
