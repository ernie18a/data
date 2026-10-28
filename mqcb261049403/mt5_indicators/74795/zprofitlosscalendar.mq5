//+------------------------------------------------------------------+
//|                                 FoxWave_PL_Calendar.mq5          |
//|                    Monthly P/L Calendar - panel indicator        |
//|                    Fox Wave (foxwavetrading.top)                 |
//+------------------------------------------------------------------+
#property copyright "Fox Wave"
#property link      "https://foxwavetrading.top"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

#define OBJ_PREFIX "FWCal_"

//--- Inputs
input ENUM_BASE_CORNER InpCorner        = CORNER_LEFT_UPPER;
input int              InpOffsetX       = 20;
input int              InpOffsetY       = 40;
input string           InpSymbolFilter  = "";        // empty = all symbols on the account
input color            InpAccentColor   = C'255,140,0';
input int              InpRefreshSec    = 20;        // how often history is re-scanned

//--- Layout constants
#define CELL_W      74
#define CELL_H      56
#define GAP         3
#define PAD         14
#define ACCOUNT_H   20
#define TITLEBAR_H  32
#define HEADER_H    24
#define SUMMARY_H   50
#define FOOTER_H    22
#define MAX_ROWS    6
#define COLS        7

//--- Colors
color COL_BG_PANEL   = C'10,12,16';
color COL_BG_HEADER  = C'16,18,24';
color COL_TXT_MAIN   = C'230,230,232';
color COL_TXT_DIM    = C'110,112,120';
color COL_CELL_EMPTY = C'22,24,30';
color COL_PROFIT_LO  = C'22,42,28';
color COL_PROFIT_HI  = C'46,190,96';
color COL_LOSS_LO    = C'42,22,24';
color COL_LOSS_HI    = C'214,58,58';
color COL_GREEN_TXT  = C'80,210,120';
color COL_RED_TXT    = C'230,90,90';

//--- State
int      g_monthOffset = 0;
string   g_dayCellBg[MAX_ROWS*COLS];
string   g_dayCellNum[MAX_ROWS*COLS];
string   g_dayCellVal[MAX_ROWS*COLS];
int      g_panelW;
int      g_gridTop;    // y where the day grid starts (fixed, never changes)

//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,OBJ_PREFIX);   // wipe any stale objects from a previous version/run
   CreatePanel();
   RebuildCalendar();
   EventSetTimer(MathMax(InpRefreshSec,5));
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,OBJ_PREFIX);
   ChartRedraw();
  }

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   return(rates_total);
  }

void OnTimer()
  {
   RebuildCalendar();
  }

//+------------------------------------------------------------------+
//| Panel construction - fixed objects created once, at MAX_ROWS     |
//| worth of positions. RebuildCalendar() hides the rows a given     |
//| month doesn't need and shrinks the panel to fit.                 |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   g_panelW = PAD*2 + COLS*CELL_W + (COLS-1)*GAP;
   int maxPanelH = PAD*2 + ACCOUNT_H + TITLEBAR_H + HEADER_H
                   + MAX_ROWS*CELL_H + (MAX_ROWS-1)*GAP + SUMMARY_H + FOOTER_H;

   MakeRect(OBJ_PREFIX+"BG",InpOffsetX,InpOffsetY,g_panelW,maxPanelH,COL_BG_PANEL,1,COL_BG_HEADER);

   //--- Account info line
   string acc = StringFormat("%s  #%d  %s  (%s)",
                  AccountInfoString(ACCOUNT_NAME),
                  (int)AccountInfoInteger(ACCOUNT_LOGIN),
                  AccountInfoString(ACCOUNT_SERVER),
                  AccountInfoString(ACCOUNT_CURRENCY));
   MakeLabel(OBJ_PREFIX+"Account",acc,InpOffsetX+PAD,InpOffsetY+PAD-2,COL_TXT_DIM,8,false,ANCHOR_LEFT);

   //--- Title bar: nav buttons + month/year label
   int titleY = InpOffsetY+PAD+ACCOUNT_H;
   MakeButton(OBJ_PREFIX+"BtnPrev","<",InpOffsetX+PAD,titleY,28,TITLEBAR_H-4);
   MakeButton(OBJ_PREFIX+"BtnNext",">",InpOffsetX+g_panelW-PAD-28,titleY,28,TITLEBAR_H-4);
   MakeLabel(OBJ_PREFIX+"Title"," ",InpOffsetX+g_panelW/2,titleY+7,COL_TXT_MAIN,13,true,ANCHOR_CENTER);

   //--- Weekday headers (English) - position never changes
   string wd[7] = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"};
   g_gridTop = titleY+TITLEBAR_H;
   for(int c=0;c<COLS;c++)
     {
      int x = InpOffsetX+PAD+c*(CELL_W+GAP)+CELL_W/2;
      MakeLabel(OBJ_PREFIX+"WD"+IntegerToString(c),wd[c],x,g_gridTop+5,COL_TXT_DIM,9,false,ANCHOR_CENTER);
     }

   //--- Day cells - create the full MAX_ROWS pool once; RebuildCalendar toggles
   //--- visibility and the summary/footer position depending on the real month.
   int cellsTop = g_gridTop+HEADER_H;
   for(int r=0;r<MAX_ROWS;r++)
     {
      for(int c=0;c<COLS;c++)
        {
         int i = r*COLS+c;
         int x = InpOffsetX+PAD+c*(CELL_W+GAP);
         int y = cellsTop+r*(CELL_H+GAP);

         string bgName  = OBJ_PREFIX+"Cell"+IntegerToString(i);
         string numName = OBJ_PREFIX+"CellNum"+IntegerToString(i);
         string valName = OBJ_PREFIX+"CellVal"+IntegerToString(i);

         MakeRect(bgName,x,y,CELL_W,CELL_H,COL_CELL_EMPTY,0,COL_CELL_EMPTY);
         MakeLabel(numName," ",x+6,y+4,COL_TXT_DIM,9,false,ANCHOR_LEFT_UPPER);
         MakeLabel(valName," ",x+CELL_W/2,y+CELL_H-16,COL_TXT_DIM,9,true,ANCHOR_CENTER);

         g_dayCellBg[i]  = bgName;
         g_dayCellNum[i] = numName;
         g_dayCellVal[i] = valName;
        }
     }

   //--- Summary + branding footer - Y position gets corrected every rebuild
   MakeLabel(OBJ_PREFIX+"SumTotal"," ",InpOffsetX+PAD,0,COL_TXT_MAIN,11,true,ANCHOR_LEFT);
   MakeLabel(OBJ_PREFIX+"SumDays"," ",InpOffsetX+PAD,0,COL_TXT_DIM,9,false,ANCHOR_LEFT);
   MakeLabel(OBJ_PREFIX+"SumBestWorst"," ",InpOffsetX+PAD,0,COL_TXT_DIM,9,false,ANCHOR_LEFT);
   MakeLabel(OBJ_PREFIX+"Brand","Fox Wave  |  foxwavetrading.top",InpOffsetX+g_panelW/2,0,InpAccentColor,9,true,ANCHOR_CENTER);
  }

//+------------------------------------------------------------------+
//| Recompute daily P/L for the currently selected month and redraw  |
//+------------------------------------------------------------------+
void RebuildCalendar()
  {
   datetime now = TimeCurrent();
   MqlDateTime nowStruct;
   TimeToStruct(now,nowStruct);

   int year  = nowStruct.year;
   int month = nowStruct.mon + g_monthOffset;
   while(month<1)  { month+=12; year--; }
   while(month>12) { month-=12; year++; }

   int daysInMonth = DaysInMonth(year,month);

   double dailyPL[31];
   ArrayInitialize(dailyPL,0.0);
   bool hasTrade[31];
   for(int i=0;i<31;i++) hasTrade[i]=false;

   ComputeMonthPL(year,month,daysInMonth,dailyPL,hasTrade,InpSymbolFilter);

   //--- Normalize for color intensity
   double maxProfit=0.0, maxLoss=0.0;
   for(int d=0;d<daysInMonth;d++)
     {
      if(dailyPL[d]>maxProfit) maxProfit=dailyPL[d];
      if(-dailyPL[d]>maxLoss)  maxLoss=-dailyPL[d];
     }
   if(maxProfit<=0) maxProfit=1;
   if(maxLoss<=0)   maxLoss=1;

   //--- First weekday of month, Monday-indexed (0=Mon..6=Sun)
   MqlDateTime first; TimeToStruct(StringToTime(StringFormat("%04d.%02d.01 00:00",year,month)),first);
   int firstIdx = (first.day_of_week+6)%7;

   //--- Exactly how many weeks does THIS month need? (4, 5 or 6 - never a fixed 6)
   int usedRows = (int)MathCeil((firstIdx+daysInMonth)/7.0);
   if(usedRows<1) usedRows=1;
   if(usedRows>MAX_ROWS) usedRows=MAX_ROWS;

   double totalPL=0; int profitDays=0, lossDays=0;
   int bestDay=-1; double bestVal=-1e18;
   int worstDay=-1; double worstVal=1e18;
   bool isCurrentMonth = (g_monthOffset==0);

   for(int i=0;i<MAX_ROWS*COLS;i++)
     {
      int row = i/COLS;
      bool rowVisible = (row<usedRows);

      //--- Hide entire unused rows outright instead of drawing empty cells
      ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_TIMEFRAMES, rowVisible?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);
      ObjectSetInteger(0,g_dayCellNum[i],OBJPROP_TIMEFRAMES,rowVisible?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);
      ObjectSetInteger(0,g_dayCellVal[i],OBJPROP_TIMEFRAMES,rowVisible?OBJ_ALL_PERIODS:OBJ_NO_PERIODS);
      if(!rowVisible) continue;

      int d = i-firstIdx; // day index (0-based) this cell would represent
      if(d<0 || d>=daysInMonth)
        {
         //--- Blank cell within a visible week (e.g. days before the 1st)
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_BGCOLOR,COL_CELL_EMPTY);
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_COLOR,COL_CELL_EMPTY);
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_WIDTH,0);
         ObjectSetString(0,g_dayCellNum[i],OBJPROP_TEXT," ");
         ObjectSetString(0,g_dayCellVal[i],OBJPROP_TEXT," ");
         continue;
        }

      double pl = dailyPL[d];
      color bg = COL_CELL_EMPTY;
      color valCol = COL_TXT_DIM;
      color numCol = COL_TXT_DIM;
      string valTxt = " ";
      double intensity = 0.0;

      if(hasTrade[d])
        {
         totalPL += pl;
         if(pl>0) profitDays++;
         else if(pl<0) lossDays++;
         if(pl>bestVal)  { bestVal=pl;  bestDay=d+1; }
         if(pl<worstVal) { worstVal=pl; worstDay=d+1; }

         if(pl>=0)
           {
            intensity = MathMin(pl/maxProfit,1.0);
            bg = BlendColor(COL_PROFIT_LO,COL_PROFIT_HI,intensity);
           }
         else
           {
            intensity = MathMin((-pl)/maxLoss,1.0);
            bg = BlendColor(COL_LOSS_LO,COL_LOSS_HI,intensity);
           }
         valTxt = FormatMoneyCompact(pl);

         //--- The background color already tells profit vs. loss (green vs red)
         //--- so the text does NOT repeat that color - it only needs to contrast
         //--- against however bright that background currently is. Bright cell
         //--- -> near-black text; dark cell -> near-white text. Always legible.
         if(intensity>0.45)
           {
            numCol = C'15,16,18';
            valCol = C'10,10,12';
           }
         else
           {
            numCol = C'170,172,178';
            valCol = C'240,242,245';
           }
        }

      ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_BGCOLOR,bg);
      ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_COLOR,bg);
      ObjectSetString(0,g_dayCellNum[i],OBJPROP_TEXT,IntegerToString(d+1));
      ObjectSetInteger(0,g_dayCellNum[i],OBJPROP_COLOR,numCol);
      ObjectSetString(0,g_dayCellVal[i],OBJPROP_TEXT,valTxt);
      ObjectSetInteger(0,g_dayCellVal[i],OBJPROP_COLOR,valCol);

      if(isCurrentMonth && (d+1)==nowStruct.day)
        {
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_WIDTH,2);
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_COLOR,InpAccentColor);
        }
      else
        {
         ObjectSetInteger(0,g_dayCellBg[i],OBJPROP_WIDTH,0);
        }
     }

   //--- Panel now shrinks/grows to exactly fit usedRows worth of weeks
   int cellsTop  = g_gridTop+HEADER_H;
   int gridBottom = cellsTop + usedRows*CELL_H + (usedRows-1)*GAP;
   int sumY      = gridBottom+8;
   int panelH    = (sumY-InpOffsetY) + SUMMARY_H + FOOTER_H;

   ObjectSetInteger(0,OBJ_PREFIX+"BG",OBJPROP_YSIZE,panelH);
   ObjectSetInteger(0,OBJ_PREFIX+"SumTotal",OBJPROP_YDISTANCE,sumY);
   ObjectSetInteger(0,OBJ_PREFIX+"SumDays",OBJPROP_YDISTANCE,sumY+18);
   ObjectSetInteger(0,OBJ_PREFIX+"SumBestWorst",OBJPROP_YDISTANCE,sumY+32);
   ObjectSetInteger(0,OBJ_PREFIX+"Brand",OBJPROP_YDISTANCE,InpOffsetY+panelH-PAD-4);

   //--- Update header/footer text (English, currency-aware)
   string monthNames[12]={"January","February","March","April","May","June",
                           "July","August","September","October","November","December"};
   ObjectSetString(0,OBJ_PREFIX+"Title",OBJPROP_TEXT,monthNames[month-1]+" "+IntegerToString(year));

   color totalCol = (totalPL>=0) ? COL_GREEN_TXT : COL_RED_TXT;
   ObjectSetString(0,OBJ_PREFIX+"SumTotal",OBJPROP_TEXT,"Total: "+FormatMoneyFull(totalPL));
   ObjectSetInteger(0,OBJ_PREFIX+"SumTotal",OBJPROP_COLOR,totalCol);

   ObjectSetString(0,OBJ_PREFIX+"SumDays",OBJPROP_TEXT,
      "Profit days: "+IntegerToString(profitDays)+"    Loss days: "+IntegerToString(lossDays));

   string bestWorstTxt = "Best: "+(bestDay>0?IntegerToString(bestDay)+" "+FormatMoneyFull(bestVal):"-")+
                          "    Worst: "+(worstDay>0?IntegerToString(worstDay)+" "+FormatMoneyFull(worstVal):"-");
   ObjectSetString(0,OBJ_PREFIX+"SumBestWorst",OBJPROP_TEXT,bestWorstTxt);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Sum realized P/L (profit+swap+commission) per day from history   |
//+------------------------------------------------------------------+
void ComputeMonthPL(int year,int month,int daysInMonth,double &dailyPL[],bool &hasTrade[],string symbolFilter)
  {
   datetime from = StringToTime(StringFormat("%04d.%02d.01 00:00:00",year,month));
   datetime to   = from + (daysInMonth*86400) - 1;

   if(!HistorySelect(from,to))
      return;

   int total = HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;

      if(symbolFilter!="")
        {
         string dealSymbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
         if(dealSymbol!=symbolFilter) continue;
        }

      double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT)
                     + HistoryDealGetDouble(ticket,DEAL_SWAP)
                     + HistoryDealGetDouble(ticket,DEAL_COMMISSION);

      if(profit==0.0) continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      MqlDateTime dt; TimeToStruct(dealTime,dt);
      int dayIdx = dt.day-1;
      if(dayIdx<0 || dayIdx>=daysInMonth) continue;

      dailyPL[dayIdx] += profit;
      hasTrade[dayIdx] = true;
     }
  }

//+------------------------------------------------------------------+
//| Chart events - month navigation                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK) return;

   if(sparam==OBJ_PREFIX+"BtnPrev")
     {
      g_monthOffset--;
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      RebuildCalendar();
     }
   else if(sparam==OBJ_PREFIX+"BtnNext")
     {
      g_monthOffset++;
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      RebuildCalendar();
     }
  }

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
int DaysInMonth(int year,int month)
  {
   int days[12]={31,28,31,30,31,30,31,31,30,31,30,31};
   bool leap = (year%4==0 && (year%100!=0 || year%400==0));
   if(month==2 && leap) return 29;
   return days[month-1];
  }

color BlendColor(color c1,color c2,double t)
  {
   t = MathMax(0.0,MathMin(1.0,t));
   int r1=(int)(c1&0xFF), g1=(int)((c1>>8)&0xFF), b1=(int)((c1>>16)&0xFF);
   int r2=(int)(c2&0xFF), g2=(int)((c2>>8)&0xFF), b2=(int)((c2>>16)&0xFF);
   int r=(int)(r1+(r2-r1)*t);
   int g=(int)(g1+(g2-g1)*t);
   int b=(int)(b1+(b2-b1)*t);
   return (color)(r|(g<<8)|(b<<16));
  }

//--- Compact form used INSIDE a day cell - no currency suffix (there isn't
//--- room for it), shortened to whole numbers once the value gets large.
string FormatMoneyCompact(double v)
  {
   string cur    = AccountInfoString(ACCOUNT_CURRENCY);
   string sign   = (v>=0)?"+":"-";
   double absv   = MathAbs(v);
   string amount = (absv>=1000) ? DoubleToString(absv,0) : DoubleToString(absv,2);
   if(cur=="USD") return sign+"$"+amount;
   return sign+amount;
  }

//--- Full form used in the header/summary lines, where there's room to
//--- actually state which currency the number is in.
string FormatMoneyFull(double v)
  {
   string cur    = AccountInfoString(ACCOUNT_CURRENCY);
   string sign   = (v>=0)?"+":"-";
   string amount = DoubleToString(MathAbs(v),2);

   if(cur=="USD") return sign+"$"+amount;
   if(cur=="JPY") return sign+"JPY "+amount;
   if(cur=="CZK") return sign+amount+" CZK";
   if(cur=="EUR") return sign+amount+" EUR";
   if(cur=="GBP") return sign+"GBP "+amount;
   if(cur=="")    return sign+amount;
   return sign+amount+" "+cur;
  }

void MakeRect(string name,int x,int y,int w,int h,color bg,int border,color borderColor)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,borderColor);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void MakeLabel(string name,string text,int x,int y,color clr,int fontSize,bool bold,ENUM_ANCHOR_POINT anchor)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,bold?"Consolas Bold":"Consolas");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void MakeButton(string name,string text,int x,int y,int w,int h)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,"Consolas Bold");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpAccentColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'20,22,28');
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,InpAccentColor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
  }
//+------------------------------------------------------------------+