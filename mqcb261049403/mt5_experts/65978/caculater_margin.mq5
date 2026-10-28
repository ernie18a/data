//+------------------------------------------------------------------+
//|                                            Caculater Margin.mq5  |
//|                                                          HNT919  |
//|                                    https://www.homnaytradegi.com |
//+------------------------------------------------------------------+
#property copyright "COPYRIGHT 2024,HOMNAYTRADEGI.COM"
#property link      "https://homnaytradegi.com/"
#property version   "1.1"
#property description "EA.Tool Caculater Margin Use || Full Active For MT5."
#property description "===================================================="
#property description "Thank you for using our EA! We offer many products on our website: https://homnaytradegi.com/service."
#property description " "
#property description "Wish you success in trading! Please contact us if you need advice."
#property strict

// Thêm input chọn góc panel
enum ENUM_PANEL_CORNER
  {
   CORNER_TOP_LEFT  = 0,
   CORNER_TOP_RIGHT = 1,
   CORNER_BOTTOM_LEFT = 2,
   CORNER_BOTTOM_RIGHT = 3
  };

input group "=== RISK MANAGEMENT ==="
input double MaxLot = 100.0;
input double MinLot = 0.01;

input group "=== MARGIN SETTINGS ==="
input int Leverage = 500;
input bool UseAutoLeverage = true;

ENUM_PANEL_CORNER PanelCorner = CORNER_TOP_LEFT; // Góc hiển thị panel
int Panel_X = 25;
int Panel_Y = 25;

// Tên đối tượng
#define BTN_UPDATE     "BTN_UPDATE_INFO"
#define EDIT_LOT       "EDIT_LOT_INPUT"
#define PANEL_PREFIX   "INFO_PANEL_"

//+------------------------------------------------------------------+
enum ENUM_SYMBOL_TYPE { SYMBOL_FOREX, SYMBOL_METAL, SYMBOL_OIL_CFD };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_SYMBOL_TYPE GetSymbolType(string symbol)
  {
   string s=symbol;
   StringToUpper(s);
   string forex[]= {"EURUSD","GBPUSD","USDJPY","USDCHF","USDCAD","AUDUSD","NZDUSD"};
   for(int i=0;i<ArraySize(forex);i++)
      if(StringFind(s,forex[i])>=0)
         return SYMBOL_FOREX;
   if(StringFind(s,"XAU")>=0 || StringFind(s,"GOLD")>=0)
      return SYMBOL_METAL;
   if(StringFind(s,"OIL")>=0 || StringFind(s,"SP500")>=0 || StringFind(s,"US30")>=0 || StringFind(s,"NAS100")>=0)
      return SYMBOL_OIL_CFD;
   return SYMBOL_FOREX;
  }

//+------------------------------------------------------------------+
double CalculateMarginRequirement(string symbol,double lot,double price)
  {
   ENUM_SYMBOL_TYPE type=GetSymbolType(symbol);
   double cs=SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   long lev=UseAutoLeverage?AccountInfoInteger(ACCOUNT_LEVERAGE):Leverage;
   if(lev<=0)
      lev=100;
   switch(type)
     {
      case SYMBOL_FOREX:
      case SYMBOL_METAL:
         return lot*cs*price/lev;
      case SYMBOL_OIL_CFD:
         return lot*cs*price*2.0/lev;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+
double NormalizeLotSize(double lot)
  {
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   minlot=fmax(minlot,MinLot);
   maxlot=fmin(maxlot,MaxLot);
   if(lot<minlot)
      lot=minlot;
   if(lot>maxlot)
      lot=maxlot;
   if(step>0)
      lot=MathRound(lot/step)*step;
   return NormalizeDouble(lot,2);
  }

//+------------------------------------------------------------------+
/*void CreateUI()
  {
// 🔹 Nút Update
   if(ObjectFind(0,BTN_UPDATE)<0)
     {
      ObjectCreate(0,BTN_UPDATE,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_XDISTANCE,45);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_YDISTANCE,40);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_XSIZE,100);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_YSIZE,25);
      ObjectSetString(0,BTN_UPDATE,OBJPROP_TEXT,"Caculate");
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_BGCOLOR,clrDodgerBlue);
      ObjectSetInteger(0,BTN_UPDATE,OBJPROP_FONTSIZE,10);
     }

// 🔹 Ô nhập Lot
   if(ObjectFind(0,EDIT_LOT)<0)
     {
      ObjectCreate(0,EDIT_LOT,OBJ_EDIT,0,0,0);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_XDISTANCE,150);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_YDISTANCE,40);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_XSIZE,80);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_YSIZE,25);
      ObjectSetString(0,EDIT_LOT,OBJPROP_TEXT,DoubleToString(MinLot,2));
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,EDIT_LOT,OBJPROP_FONTSIZE,10);
     }
  }

//+------------------------------------------------------------------+
void DrawInfoPanel(double lot,double margin_req,double margin_free,double usage)
  {
// Xóa panel cũ
   ObjectsDeleteAll(0,PANEL_PREFIX);

   int x0=50,y0=75;
   color textColor=clrWhite;
   color bgColor=(usage>80)?clrDarkRed:clrMidnightBlue;

   string rect=PANEL_PREFIX+"BG";
   ObjectCreate(0,rect,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,rect,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,rect,OBJPROP_XDISTANCE,x0-5);
   ObjectSetInteger(0,rect,OBJPROP_YDISTANCE,y0-5);
   ObjectSetInteger(0,rect,OBJPROP_XSIZE,250);
   ObjectSetInteger(0,rect,OBJPROP_YSIZE,120);
   ObjectSetInteger(0,rect,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,rect,OBJPROP_COLOR,clrWhite);

   string info[];
   ArrayResize(info,5);
   info[0]="Symbol: "+Symbol();
   info[1]="Lot Size: "+DoubleToString(lot,2);
   info[2]="Margin: "+DoubleToString(margin_req,2);
   info[3]="Free margin: "+DoubleToString(margin_free,2);
   info[4]="Margin %: "+DoubleToString(usage,5)+"%";

   for(int i=0;i<ArraySize(info);i++)
     {
      string name=PANEL_PREFIX+"LINE_"+(string)i;
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x0+5);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y0+i*20);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetString(0,name,OBJPROP_TEXT,info[i]);
     }
  }*/
//+------------------------------------------------------------------+
void CreateUI()
  {
   AdjustPanelPosition();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AdjustPanelPosition()
  {
   int baseX = Panel_X;
   int baseY = Panel_Y;

// 🔹 Nút tính toán
   if(ObjectFind(0, BTN_UPDATE) < 0)
      ObjectCreate(0, BTN_UPDATE, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_XSIZE, 90);
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_YSIZE, 22);
   ObjectSetString(0, BTN_UPDATE, OBJPROP_TEXT, "Calculate");
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, BTN_UPDATE, OBJPROP_BGCOLOR, clrDodgerBlue);

// 🔹 Ô nhập Lot
   if(ObjectFind(0, EDIT_LOT) < 0)
      ObjectCreate(0, EDIT_LOT, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, EDIT_LOT, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, EDIT_LOT, OBJPROP_XSIZE, 60);
   ObjectSetInteger(0, EDIT_LOT, OBJPROP_YSIZE, 22);
   ObjectSetInteger(0, EDIT_LOT, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, EDIT_LOT, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, EDIT_LOT, OBJPROP_TEXT, DoubleToString(MinLot, 2));

  }

//+------------------------------------------------------------------+
//| Hiển thị panel thông tin tính toán                              |
//+------------------------------------------------------------------+
void DrawInfoPanel(double lot, double margin_req, double margin_free, double usage)
{
    ObjectsDeleteAll(0, PANEL_PREFIX);

    int baseX = Panel_X;
    int baseY = Panel_Y + 30; // Dưới hàng nút
    color textColor = clrWhite;
    color bgColor = (usage > 80) ? clrDarkRed : clrMidnightBlue;

    // 🔹 Lấy thông tin đòn bẩy thực tế
    int leverage_used = UseAutoLeverage ? (int)AccountInfoInteger(ACCOUNT_LEVERAGE) : Leverage;
    string lev_source = UseAutoLeverage ? "(Auto)" : "(Manual)";

    // 🔹 Thông tin panel
    string info[];
    ArrayResize(info, 7);
    info[0] = "Symbol: " + Symbol();
    info[1] = "Lot: " + DoubleToString(lot, 2);
    info[2] = "Margin: " + DoubleToString(margin_req, 2);
    info[3] = "Free: " + DoubleToString(margin_free, 2);
    info[4] = "Usage: " + DoubleToString(usage, 1) + "%";
    info[5] = "Leverage: 1:" + IntegerToString(leverage_used);
    info[6] = "Source: " + lev_source;

    // 🔹 Tính toán vị trí dựa trên góc
    long panelX = baseX;
    long panelY = baseY;
    long panelWidth = 230;
    long panelHeight = 150;

    switch(PanelCorner)
    {
        case CORNER_TOP_LEFT:
            panelX = baseX;
            panelY = baseY;
            break;

        case CORNER_TOP_RIGHT:
            panelX = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - panelWidth - baseX;
            panelY = baseY;
            break;

        case CORNER_BOTTOM_LEFT:
            panelX = baseX;
            panelY = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - panelHeight - baseY;
            break;

        case CORNER_BOTTOM_RIGHT:
            panelX = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - panelWidth - baseX;
            panelY = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - panelHeight - baseY;
            break;
    }

    // 🔹 Tạo background panel
    string rect = PANEL_PREFIX + "BG";
    ObjectCreate(0, rect, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, rect, OBJPROP_CORNER, PanelCorner);
    ObjectSetInteger(0, rect, OBJPROP_XDISTANCE, panelX);
    ObjectSetInteger(0, rect, OBJPROP_YDISTANCE, panelY);
    ObjectSetInteger(0, rect, OBJPROP_XSIZE, panelWidth);
    ObjectSetInteger(0, rect, OBJPROP_YSIZE, panelHeight);
    ObjectSetInteger(0, rect, OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, rect, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, rect, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, rect, OBJPROP_BACK, false);

    // 🔹 Hiển thị từng dòng text
    for(int i = 0; i < ArraySize(info); i++)
    {
        string name = PANEL_PREFIX + "LINE_" + (string)i;
        ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, panelX + 10);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, panelY + 10 + i * 18);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
        ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
        ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, name, OBJPROP_TEXT, info[i]);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);
    }

    // 🔹 Cập nhật vị trí cho các control khác (nếu cần)
    UpdateControlPositions(panelX, panelY, panelWidth, panelHeight);
}

// Hàm phụ để cập nhật vị trí các control khác
void UpdateControlPositions(long panelX, long panelY, long panelWidth, long panelHeight)
{
    switch(PanelCorner)
    {
        case CORNER_TOP_LEFT:
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_XDISTANCE, panelX);
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_YDISTANCE, panelY + panelHeight + 5);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_XDISTANCE, panelX + 70);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_YDISTANCE, panelY + panelHeight + 5);
            break;

        case CORNER_TOP_RIGHT:
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_XDISTANCE, panelX);
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_YDISTANCE, panelY + panelHeight + 100);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_XDISTANCE, panelX + 70);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_YDISTANCE, panelY + panelHeight + 100);
            break;

        case CORNER_BOTTOM_LEFT:
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_XDISTANCE, panelX);
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_YDISTANCE, panelY - 25);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_XDISTANCE, panelX + 70);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_YDISTANCE, panelY - 25);
            break;

        case CORNER_BOTTOM_RIGHT:
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_XDISTANCE, panelX);
            ObjectSetInteger(0, EDIT_LOT, OBJPROP_YDISTANCE, panelY - 25);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_XDISTANCE, panelX + 70);
            ObjectSetInteger(0, BTN_UPDATE, OBJPROP_YDISTANCE, panelY - 25);
            break;
    }
}


//+------------------------------------------------------------------+
void UpdatePanel()
  {
   string lot_str = ObjectGetString(0,EDIT_LOT,OBJPROP_TEXT);
   double inputLot = StringToDouble(lot_str);
   if(inputLot<=0)
     {
      MessageBox("Giá trị lot không hợp lệ!","Lỗi nhập liệu",MB_OK|MB_ICONERROR);
      return;
     }

   inputLot = NormalizeLotSize(inputLot);

   string symbol = Symbol();
   double price  = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double margin_req = CalculateMarginRequirement(symbol,inputLot,price);
   double margin_free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double usage = (margin_free>0)?(margin_req/margin_free*100.0):0.0;


   DrawInfoPanel(inputLot,margin_req,margin_free,usage);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   CreateUI();
   UpdatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==BTN_UPDATE)
     {
      UpdatePanel();
     }
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,BTN_UPDATE);
   ObjectsDeleteAll(0,EDIT_LOT);
   ObjectsDeleteAll(0,PANEL_PREFIX);
  }
//+------------------------------------------------------------------+
