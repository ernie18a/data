//+------------------------------------------------------------------+
//|                                               TradingPanelEA.mq5 |
//|  EA Panel giao dịch: Buy/Sell, Quản lý Lot, Đóng lệnh,           |
//|  Trung bình giá + Set TP trung bình, Breakeven                   |
//+------------------------------------------------------------------+
#property copyright "COPYRIGHT 2024,HOMNAYTRADEGI.COM"
#property version   "1.00"
#property description "Thank you for using our EA! We offer many products on our website: https://homnaytradegi.com/service."
#property description " "
#property description "Wish you success in trading! Please contact us if you need advice."

#include <Trade\Trade.mqh>
CTrade trade;

//================= INPUT =================
input group "=== Cài đặt chung ==="
input long   InpMagic          = 20260729;   // Magic Number
input int    InpSlippage       = 20;         // Slippage (points)

input group "=== Lot ==="
input double InpLotDefault     = 0.01;       // Lot mặc định
input double InpLotStep        = 0.01;       // Bước nhảy Lot khi bấm +/-
input double InpLotMin         = 0.01;       // Lot tối thiểu
input double InpLotMax         = 100.0;      // Lot tối đa

input group "=== Trung bình giá ==="
input double InpAvgPipDefault  = 200;         // Pip lãi mục tiêu mặc định (trung bình giá)

input group "=== Breakeven ==="
input double InpBEPipDefault   = 100;         // Pip lãi mặc định khi Breakeven

input group "=== Auto DCA ==="
input double InpDcaDistancePip = 200;         // Khoảng cách pip giữa các lệnh DCA
input double InpDcaLotMulti    = 1.0;        // Hệ số nhân Lot mỗi lần DCA
double       InpDcaLotStep     = 0.1;
double       InpDCAMin         = 0.1;
double       InpDCAMax         = 100;
input int    InpDcaMaxOrders   = 15;         // Số lệnh DCA tối đa mỗi chiều (an toàn)

input group "=== Vị trí Panel ==="
input int    InpPanelX         = 20;         // Toạ độ X góc trên trái
input int    InpPanelY         = 20;         // Toạ độ Y góc trên trái

//================= GLOBAL =================
string PFX = "TPEA_";
double g_lot;
double g_lotMT;
double g_avgPip;
double g_bePip;
double g_dcaDist;
double g_dcaMulti;
bool   g_dcaActive = false;   // trạng thái Auto DCA: false = no-DCA, true = ac-DCA
bool   g_loaded    = false;   // đánh dấu đã nạp giá trị lần đầu (chỉ set 1 lần)
color  clrBg      = C'33,33,33';
color  clrBtn     = C'60,60,60';
color  clrBtnBuy  = clrDodgerBlue;
color  clrBtnSell = clrCrimson;
color  clrText    = clrWhite;
color  clrDcaOn   = clrLimeGreen;
color  clrDcaOff  = C'90,90,90';
color  clrInfoBg  = C'22,32,48';    // nền nổi bật cho khối thông tin tài khoản
color  clrInfoBorder = C'0,140,220';
int    g_x, g_y;

//+------------------------------------------------------------------+
//| Tiện ích tính pip size (chuẩn hoá theo 3/5 số lẻ)                 |
//+------------------------------------------------------------------+
double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(digits == 3 || digits == 5)
      return point * 10;
   return point;
  }

//+------------------------------------------------------------------+
//| Helper tạo object                                                 |
//+------------------------------------------------------------------+
void CreateLabel(string name,int x,int y,string text,int size=9,color clr=clrWhite,string font="Arial Bold")
  {
   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateRect(string name,int x,int y,int w,int h,color bg,color border=clrNONE)
  {
   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR, border==clrNONE?bg:border);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton(string name,int x,int y,int w,int h,string text,color bg,int size=9)
  {
   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,C'20,20,20');
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateEdit(string name,int x,int y,int w,int h,string text,int size=8)
  {
   if(ObjectFind(0,name) < 0)
      ObjectCreate(0,name,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Xây dựng Panel                                                    |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   g_x = InpPanelX;
   g_y = InpPanelY;
   int x = g_x, y = g_y;
   int w = 220;

   CreateRect(PFX+"bg", x, y, w, 400, clrBg, C'10,10,10');
   CreateLabel(PFX+"title", x+10, y+6, "PANEL ES", 10, clrYellow);
   CreateButton(PFX+"btn_reset", x+160, y+5, 50, 18, "Reset", clrBtn, 7);

// ---- Khối thông tin tài khoản: làm nổi bật bằng nền + viền riêng ----
   int infoY = y+24;
   int infoH = 84;
   CreateRect(PFX+"info_bg", x+6, infoY, w-12, infoH, clrInfoBg, clrInfoBorder);
   CreateLabel(PFX+"lbl_infotitle", x+12, infoY+4, "TÀI KHOẢN", 8, clrInfoBorder);

   int iy = infoY+18;
   CreateLabel(PFX+"lbl_be", x+12, iy, "Bal: - | Eq: -", 9, clrWhite);
   iy+=15;
   CreateLabel(PFX+"lbl_mf", x+12, iy, "Mar: - | FM: -", 9, C'200,200,200');
   iy+=15;
   CreateLabel(PFX+"lbl_orders", x+12, iy, "BUY: 0 SELL: 0", 9, clrAqua);
   iy+=15;
   CreateLabel(PFX+"lbl_floating", x+12, iy, "P/L: 0.00 || Plb/s: 0", 9, clrYellow);

   iy = infoY + infoH + 8;

// ---- Lot control ----
   CreateLabel(PFX+"lbl_lot", x+10, iy+4, "Lot", 8, clrText);
   CreateButton(PFX+"btn_lotminus", x+40, iy, 22, 22, "-", clrBtn, 9);
   CreateEdit(PFX+"edit_lot", x+64, iy, 76, 22, DoubleToString(g_lot,2), 9);
   CreateButton(PFX+"btn_lotplus", x+142, iy, 22, 22, "+", clrBtn, 9);
   iy += 28;

// ---- Buy / Sell ----
   CreateButton(PFX+"btn_sell", x+10,  iy, 95, 26, "SELL", clrBtnSell, 9);
   CreateButton(PFX+"btn_buy",  x+115, iy, 95, 26, "BUY", clrBtnBuy, 9);
   iy += 32;

// ---- Close functions ----
   CreateLabel(PFX+"sep1", x+10, iy, "— Đóng lệnh —", 8, clrSilver);
   iy += 14;
   CreateButton(PFX+"btn_closeall",   x+10,  iy, 95, 20, "All", clrBtn, 8);
   CreateButton(PFX+"btn_closeprofit",x+115, iy, 95, 20, "Profit", clrBtn, 8);
   iy += 24;
   CreateButton(PFX+"btn_closebuy",  x+10,  iy, 95, 20, "Buy", clrBtn, 8);
   CreateButton(PFX+"btn_closesell", x+115, iy, 95, 20, "Sell", clrBtn, 8);
   iy += 28;

// ---- Trung bình giá (chỉ còn Set TP theo giá trung bình) ----
   CreateLabel(PFX+"sep2", x+10, iy, "— Trung bình giá —", 8, clrSilver);
   iy += 14;
   CreateLabel(PFX+"lbl_avgpip", x+10, iy+4, "Point:", 8, clrText);
   CreateEdit(PFX+"edit_avgpip", x+45, iy, 50, 20, DoubleToString(g_avgPip,0), 9);
   CreateButton(PFX+"btn_settpavg", x+100, iy, 110, 20, "Set TP", clrBtn, 8);
   iy += 24;

// ---- Breakeven ----
   CreateLabel(PFX+"sep3", x+10, iy, "— Breakeven —", 8, clrSilver);
   iy += 14;
   CreateLabel(PFX+"lbl_bepip", x+10, iy+4, "Point:", 8, clrText);
   CreateEdit(PFX+"edit_bepip", x+45, iy, 50, 20, DoubleToString(g_bePip,0), 9);
   CreateButton(PFX+"btn_breakeven", x+100, iy, 110, 20, "Breakeven", clrBtn, 8);
   iy += 24;

// ---- Auto DCA ----
   CreateLabel(PFX+"sep4", x+10, iy, "— Auto DCA —", 8, clrSilver);
   iy += 14;
   CreateButton(PFX+"btn_dca_toggle", x+10, iy, 200, 22, "DCA: OFF", clrDcaOff, 9);
   iy += 26;
   CreateLabel(PFX+"lbl_dcadist", x+10, iy+4, "D:", 8, clrText);
   CreateEdit(PFX+"edit_dcadistance", x+28, iy, 70, 20, DoubleToString(g_dcaDist,0), 9);
   CreateLabel(PFX+"lbl_dcamulti", x+108, iy+4, "M:", 8, clrText);
   CreateEdit(PFX+"edit_dcamulti", x+126, iy, 70, 20, DoubleToString(g_dcaMulti,2), 9);
   CreateButton(PFX+"btndca_lotminus", x+131, iy+21, 30, 15, "-", clrBtn, 8);
   CreateButton(PFX+"btndca_lotplus", x+161, iy+21, 30, 15, "+", clrBtn, 8);
   iy += 24;

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Cập nhật giao diện nút Auto DCA theo trạng thái                   |
//+------------------------------------------------------------------+
void UpdateDcaButton()
  {
   if(g_dcaActive)
     {
      ObjectSetString(0,PFX+"btn_dca_toggle",OBJPROP_TEXT,"DCA: ON");
      ObjectSetInteger(0,PFX+"btn_dca_toggle",OBJPROP_BGCOLOR,clrDcaOn);
     }
   else
     {
      ObjectSetString(0,PFX+"btn_dca_toggle",OBJPROP_TEXT,"DCA: OFF");
      ObjectSetInteger(0,PFX+"btn_dca_toggle",OBJPROP_BGCOLOR,clrDcaOff);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemovePanel()
  {
   ObjectsDeleteAll(0, PFX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Đếm & tính toán lệnh (theo symbol + magic hiện tại)                |
//+------------------------------------------------------------------+
int CountByType(ENUM_POSITION_TYPE type)
  {
   int cnt = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         cnt++;
     }
   return cnt;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FloatingTotal(double &floatAll, double &floatBuy, double &floatSell)
  {
   floatAll  = 0;
   floatBuy  = 0;
   floatSell = 0;

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      long   type   = PositionGetInteger(POSITION_TYPE);

      floatAll += profit;

      if(type == POSITION_TYPE_BUY)
         floatBuy += profit;
      else
         if(type == POSITION_TYPE_SELL)
            floatSell += profit;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcAvgPrice(ENUM_POSITION_TYPE type)
  {
   double sumPV = 0, sumV = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type)
         continue;
      double vol = PositionGetDouble(POSITION_VOLUME);
      double price = PositionGetDouble(POSITION_PRICE_OPEN);
      sumPV += vol*price;
      sumV  += vol;
     }
   if(sumV <= 0)
      return 0;
   return sumPV/sumV;
  }

// Lấy lệnh mở gần nhất (theo thời gian) của 1 chiều - dùng làm mốc tính khoảng cách DCA
ulong GetLastPositionTicket(ENUM_POSITION_TYPE type, double &outLot, double &outPrice)
  {
   ulong  lastTicket = 0;
   datetime lastTime = 0;
   outLot = 0;
   outPrice = 0;

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type)
         continue;

      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t >= lastTime)
        {
         lastTime  = t;
         lastTicket = ticket;
         outLot    = PositionGetDouble(POSITION_VOLUME);
         outPrice  = PositionGetDouble(POSITION_PRICE_OPEN);
        }
     }
   return lastTicket;
  }

//+------------------------------------------------------------------+
//| Cập nhật thông tin panel                                          |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double mar = AccountInfoDouble(ACCOUNT_MARGIN);
   double fm  = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

   ObjectSetString(0,PFX+"lbl_be", OBJPROP_TEXT, StringFormat("Bal: %.2f | Eq: %.2f", bal, eq));
   ObjectSetString(0,PFX+"lbl_mf", OBJPROP_TEXT, StringFormat("Mar: %.2f | FM: %.2f", mar, fm));

   int buyCnt  = CountByType(POSITION_TYPE_BUY);
   int sellCnt = CountByType(POSITION_TYPE_SELL);
   ObjectSetString(0,PFX+"lbl_orders",OBJPROP_TEXT, StringFormat("BUY: %d SELL: %d", buyCnt, sellCnt));

   double all, buy, sell;
   FloatingTotal(all, buy, sell);
   ObjectSetString(0,PFX+"lbl_floating",OBJPROP_TEXT, StringFormat("P/L: %.2f || Plb/s: %.2f / %.2f", all,buy,sell));
   ObjectSetInteger(0,PFX+"lbl_floating",OBJPROP_COLOR, all >= 0 ? clrLime : clrOrangeRed);
  }

//+------------------------------------------------------------------+
//| Đọc giá trị từ Edit box                                           |
//+------------------------------------------------------------------+
double ReadEditDouble(string name, double def)
  {
   string s = ObjectGetString(0,name,OBJPROP_TEXT);
   if(StringLen(s) == 0)
      return def;
   double v = StringToDouble(s);
   if(v <= 0)
      return def;
   return v;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLotEdit()
  {
   ObjectSetString(0,PFX+"edit_lot",OBJPROP_TEXT, DoubleToString(g_lot,2));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateLMEdit()
  {
   ObjectSetString(0,PFX+"edit_dcamulti",OBJPROP_TEXT, DoubleToString(g_dcaMulti,2));
  }

// Lưu lại toàn bộ giá trị đang nhập trong panel vào biến global,
// gọi trước khi panel bị xoá (OnDeinit) để không bị mất khi đổi timeframe/symbol
void SaveEditValues()
  {
   g_lot      = ReadEditDouble(PFX+"edit_lot", g_lot);
   g_avgPip   = ReadEditDouble(PFX+"edit_avgpip", g_avgPip);
   g_bePip    = ReadEditDouble(PFX+"edit_bepip", g_bePip);
   g_dcaDist  = ReadEditDouble(PFX+"edit_dcadistance", g_dcaDist);
   g_dcaMulti = ReadEditDouble(PFX+"edit_dcamulti", g_dcaMulti);
  }

// Đưa toàn bộ tham số (Lot, Pip TB, Pip BE, khoảng cách DCA, lot multi, trạng thái DCA)
// về đúng giá trị mặc định đã khai báo trong mục Input, và cập nhật lại các ô trên panel
void ResetToDefaults()
  {
   g_lot       = InpLotDefault;
   g_avgPip    = InpAvgPipDefault;
   g_bePip     = InpBEPipDefault;
   g_dcaDist   = InpDcaDistancePip;
   g_dcaMulti  = InpDcaLotMulti;
   g_dcaActive = false;

   ObjectSetString(0,PFX+"edit_lot",OBJPROP_TEXT, DoubleToString(g_lot,2));
   ObjectSetString(0,PFX+"edit_avgpip",OBJPROP_TEXT, DoubleToString(g_avgPip,0));
   ObjectSetString(0,PFX+"edit_bepip",OBJPROP_TEXT, DoubleToString(g_bePip,0));
   ObjectSetString(0,PFX+"edit_dcadistance",OBJPROP_TEXT, DoubleToString(g_dcaDist,0));
   ObjectSetString(0,PFX+"edit_dcamulti",OBJPROP_TEXT, DoubleToString(g_dcaMulti,2));

   UpdateDcaButton();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Chức năng giao dịch                                               |
//+------------------------------------------------------------------+
void DoOpen(ENUM_ORDER_TYPE type, double lot)
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                  : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   lot = NormalizeDouble(lot, 2);
   if(type == ORDER_TYPE_BUY)
      trade.Buy(lot, _Symbol, price, 0, 0, "PanelEA Buy");
   else
      trade.Sell(lot, _Symbol, price, 0, 0, "PanelEA Sell");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      trade.PositionClose(ticket, InpSlippage);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitPositions()
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(profit > 0)
         trade.PositionClose(ticket, InpSlippage);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseByTypeFunc(ENUM_POSITION_TYPE type)
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type)
         continue;
      trade.PositionClose(ticket, InpSlippage);
     }
  }

// Set TP theo giá trung bình cho toàn bộ lệnh cùng chiều
void SetTPAverage(double pips)
  {
   double pipsz = PipSize();

// BUY
   double avgBuy = CalcAvgPrice(POSITION_TYPE_BUY);
   if(avgBuy > 0)
     {
      double tp = avgBuy + pips*pipsz;
      for(int i = PositionsTotal()-1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
            continue;
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY)
            continue;
         double sl = PositionGetDouble(POSITION_SL);
         trade.PositionModify(ticket, sl, tp);
        }
     }

// SELL
   double avgSell = CalcAvgPrice(POSITION_TYPE_SELL);
   if(avgSell > 0)
     {
      double tp = avgSell - pips*pipsz;
      for(int i = PositionsTotal()-1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
            continue;
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL)
            continue;
         double sl = PositionGetDouble(POSITION_SL);
         trade.PositionModify(ticket, sl, tp);
        }
     }
  }

// Breakeven: dời SL về giá mở + số pip lãi nhập vào (áp dụng cho từng lệnh)
void SetBreakeven(double pips)
  {
   double pipsz = PipSize();
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;

      ENUM_POSITION_TYPE ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double curTP = PositionGetDouble(POSITION_TP);
      double newSL;

      if(ptype == POSITION_TYPE_BUY)
        {
         newSL = openPrice + pips*pipsz;
         // Chỉ áp dụng nếu hợp lệ (SL phải thấp hơn giá hiện tại - khoảng cách tối thiểu)
         if(newSL < bid - stopLevel)
            trade.PositionModify(ticket, newSL, curTP);
        }
      else
         if(ptype == POSITION_TYPE_SELL)
           {
            newSL = openPrice - pips*pipsz;
            if(newSL > ask + stopLevel)
               trade.PositionModify(ticket, newSL, curTP);
           }
     }
  }

// Auto DCA: khi kích hoạt (ac-DCA), tự động mở thêm lệnh trung bình giá
// mỗi khi giá đi ngược đủ "khoảng cách pip dca" so với lệnh gần nhất,
// lot lệnh mới = lot lệnh gần nhất * "lot mutil", và tự set TP theo
// ô "Pip lãi TB" đang có sẵn ở khu vực Trung bình giá.
void CheckAutoDCA()
  {
// Luôn đồng bộ giá trị input mới nhất vào biến global (đảm bảo không mất khi rebuild panel)
   g_dcaDist = ReadEditDouble(PFX+"edit_dcadistance", g_dcaDist);
   g_dcaMulti = ReadEditDouble(PFX+"edit_dcamulti", g_dcaMulti);
   g_avgPip = ReadEditDouble(PFX+"edit_avgpip", g_avgPip);

   if(!g_dcaActive)
      return;

   double distPips = g_dcaDist;
   double multi    = g_dcaMulti;
   double pipsz    = PipSize();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bool   opened = false;

// ---- Chiều BUY: giá giảm đủ xa so với lệnh Buy gần nhất => DCA thêm Buy ----
   double lastLot = 0, lastPrice = 0;
   ulong lastBuyTicket = GetLastPositionTicket(POSITION_TYPE_BUY, lastLot, lastPrice);
   if(lastBuyTicket != 0)
     {
      int buyCount = CountByType(POSITION_TYPE_BUY);
      if(buyCount < InpDcaMaxOrders && bid <= lastPrice - distPips*pipsz)
        {
         double newLot = NormalizeDouble(lastLot * multi, 2);
         newLot = MathMin(MathMax(newLot, InpLotMin), InpLotMax);
         DoOpen(ORDER_TYPE_BUY, newLot);
         opened = true;
        }
     }

// ---- Chiều SELL: giá tăng đủ xa so với lệnh Sell gần nhất => DCA thêm Sell ----
   double lastLotS = 0, lastPriceS = 0;
   ulong lastSellTicket = GetLastPositionTicket(POSITION_TYPE_SELL, lastLotS, lastPriceS);
   if(lastSellTicket != 0)
     {
      int sellCount = CountByType(POSITION_TYPE_SELL);
      if(sellCount < InpDcaMaxOrders && ask >= lastPriceS + distPips*pipsz)
        {
         double newLot = NormalizeDouble(lastLotS * multi, 2);
         newLot = MathMin(MathMax(newLot, InpLotMin), InpLotMax);
         DoOpen(ORDER_TYPE_SELL, newLot);
         opened = true;
        }
     }

// Sau khi vừa DCA thêm lệnh, tự động set lại TP trung bình theo pip lãi TB đang nhập
   if(opened)
     {
      SetTPAverage(g_avgPip);
     }
  }

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
// Chỉ gán giá trị mặc định từ Input 1 LẦN DUY NHẤT (lần chạy đầu tiên).
// Các lần OnInit tiếp theo (do đổi timeframe/symbol) sẽ giữ nguyên giá trị
// đã lưu trong biến global, không bị reset về mặc định.
   if(!g_loaded)
     {
      g_lot       = InpLotDefault;
      g_avgPip    = InpAvgPipDefault;
      g_bePip     = InpBEPipDefault;
      g_dcaDist   = InpDcaDistancePip;
      g_dcaMulti  = InpDcaLotMulti;
      g_dcaActive = false;
      g_loaded    = true;
     }

   BuildPanel();
   UpdatePanel();
   UpdateDcaButton();
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SaveEditValues();   // lưu lại giá trị đang nhập trước khi panel bị xoá
   EventKillTimer();
   RemovePanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   UpdatePanel();
   CheckAutoDCA();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| OnChartEvent - xử lý click nút & nhập liệu                        |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      // Lot -
      if(sparam == PFX+"btn_lotminus")
        {
         g_lot = MathMax(InpLotMin, NormalizeDouble(g_lot - InpLotStep, 2));
         UpdateLotEdit();
         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
        }
      // Lot +
      else
         if(sparam == PFX+"btn_lotplus")
           {
            g_lot = MathMin(InpLotMax, NormalizeDouble(g_lot + InpLotStep, 2));
            UpdateLotEdit();
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
           }
         else
            if(sparam == PFX+"btndca_lotminus")
              {
               g_dcaMulti = MathMax(InpDCAMin, NormalizeDouble(g_dcaMulti - InpDcaLotStep,2));
               UpdateLMEdit();
               ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
              }
            else
               if(sparam == PFX+"btndca_lotplus")
                 {
                  g_dcaMulti = MathMin(InpDCAMax, NormalizeDouble(g_dcaMulti + InpDcaLotStep,2));
                  UpdateLMEdit();
                  ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                 }
               // Buy
               else
                  if(sparam == PFX+"btn_buy")
                    {
                     g_lot = ReadEditDouble(PFX+"edit_lot", g_lot);
                     DoOpen(ORDER_TYPE_BUY, g_lot);
                     ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                    }
                  // Sell
                  else
                     if(sparam == PFX+"btn_sell")
                       {
                        g_lot = ReadEditDouble(PFX+"edit_lot", g_lot);
                        DoOpen(ORDER_TYPE_SELL, g_lot);
                        ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                       }
                     // Close All
                     else
                        if(sparam == PFX+"btn_closeall")
                          {
                           CloseAllPositions();
                           ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                          }
                        // Close Profit
                        else
                           if(sparam == PFX+"btn_closeprofit")
                             {
                              CloseProfitPositions();
                              ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                             }
                           // Close Buy
                           else
                              if(sparam == PFX+"btn_closebuy")
                                {
                                 CloseByTypeFunc(POSITION_TYPE_BUY);
                                 ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                }
                              // Close Sell
                              else
                                 if(sparam == PFX+"btn_closesell")
                                   {
                                    CloseByTypeFunc(POSITION_TYPE_SELL);
                                    ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                   }
                                 // Set TP trung bình
                                 else
                                    if(sparam == PFX+"btn_settpavg")
                                      {
                                       g_avgPip = ReadEditDouble(PFX+"edit_avgpip", g_avgPip);
                                       SetTPAverage(g_avgPip);
                                       ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                      }
                                    // Breakeven
                                    else
                                       if(sparam == PFX+"btn_breakeven")
                                         {
                                          g_bePip = ReadEditDouble(PFX+"edit_bepip", g_bePip);
                                          SetBreakeven(g_bePip);
                                          ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                         }
                                       // Toggle Auto DCA: no-DCA <-> ac-DCA
                                       else
                                          if(sparam == PFX+"btn_dca_toggle")
                                            {
                                             g_dcaActive = !g_dcaActive;
                                             UpdateDcaButton();
                                             ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                            }
                                          // Reset: đưa toàn bộ tham số về mặc định trong Input
                                          else
                                             if(sparam == PFX+"btn_reset")
                                               {
                                                ResetToDefaults();
                                                ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
                                               }

      ChartRedraw(0);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
