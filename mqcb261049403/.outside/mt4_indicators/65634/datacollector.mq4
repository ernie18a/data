//+------------------------------------------------------------------+
//|                                                DataCollector.mq4 |
//|                                          Copyright © 2025, bialy |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright     "Nash Equilibrium by bialy, Copyright © 2025"
#property link          "https://www.mql5.com/en/market/product/154150"
#property description   "NashEquilibrium data collector"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrGreen
#property indicator_color2 clrLimeGreen
#property indicator_color3 clrRed

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID

#property indicator_width1 2
#property indicator_width2 1

#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT
enum enRecognize
  {
   byOrderComment,      //by OrderComment()
   byMagicNumber,       //by OrderMagicNumber()
   byMagicRange,        //by OrderMagicNumber() range
   byCommentAndMagic,   //by OrderComment() & OrderMagic()
   byCommentAndRange    //by OrderComment() & OrderMagic() range
  };
enum enDrawingStyle
  {
   line=0,        //Line
   histogram=2    //Histogram
  };

//_____________________________Settings____________________________
input enRecognize               Recognize          = 0;                            //Recognizing method
input string                    oComment           = "NashEquilibrium(dual)";      //OrderComment
input int                       Magic_start        = 1000;                         //MagicNumber start
input int                       Magic_end          = 1999;                         //MagicNumber end
input string                    Date_start         = "2025.07.01";                 //Start History Date [yyyy.mm.dd] for ClosedProfit
input string                    folder             = "NashEquilibrium_profits";    //Folder data
input string                    filename           = "dual.bin";                   //Filename data (.bin file different for each instance)
input enDrawingStyle            DrawingStyle       = 0;                            //Drawing Style
input bool                      AutoScale          = false;
input bool                      Controls           = false;                        //Draw Controls
//__________________________________________________________________

double ClosedBuffer[];
double ProfitBuffer[];
double MarginBuffer[];

int history_total,prev_history_total;
double closed_profit;
datetime start_history;

datetime LastBar;
int range = 1500, diff = 50;
double min,max;
bool IsStarting = true;

struct EA_data
  {
   float             Closed;
   float             Profit;
   float             Margin;
   datetime          Datetime;
  };
EA_data data[1];
//========================================================================================================================================================================================================
int OnInit(void)
  {
   MakeCleanChart();
   string data_name = " ("+filename+")";
   IndicatorDigits(2);
   IndicatorShortName("");

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ClosedBuffer);
   SetIndexEmptyValue(0,NULL);
   SetIndexLabel(0,"Closed"+data_name);

   SetIndexStyle(1,DrawingStyle);
   SetIndexBuffer(1,ProfitBuffer);
   SetIndexEmptyValue(1,NULL);
   SetIndexLabel(1,"Profit"+data_name);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MarginBuffer);
   SetIndexEmptyValue(2,NULL);
   SetIndexLabel(2,"Margin"+data_name);

   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,false);
   ObjectCreate(0,"0_Line",OBJ_HLINE,1,0,0);
   ObjectSetInteger(0,"0_Line",OBJPROP_WIDTH,2);
   ObjectSetInteger(0,"0_Line",OBJPROP_COLOR,clrAqua);

   LastBar = (datetime)SeriesInfoInteger(_Symbol,PERIOD_M5,SERIES_LASTBAR_DATE);
   for(short LvL=31, P=-1500; LvL>=0; LvL--,P+=500)
      SetLevelValue(LvL,P);
   start_history = StringToTime(Date_start);
   if(Controls)
      DrawControls();
   IsStarting = true;
   return(INIT_SUCCEEDED);
  }
//========================================================================================================================================================================================================
void OnDeinit(const int reason)     //EventKillTimer();
  {
   if(Controls)
     {
      ObjectDelete(0,"M5");
      ObjectDelete(0,"M15");
      ObjectDelete(0,"M30");
      ObjectDelete(0,"H1");
      ObjectDelete(0,"H4");
      ObjectDelete(0,"D1");
      ObjectDelete(0,"ExportToCSV");
     }
  }
//========================================================================================================================================================================================================
void ReadData(const bool mode)
  {
   int handle = FileOpen(StringFormat("%s\\%d_%s",folder,AccountInfoInteger(ACCOUNT_LOGIN),filename),FILE_READ|FILE_BIN|FILE_SHARE_READ);
   if(handle != INVALID_HANDLE)
     {
      FileReadArray(handle,data);
      FileClose(handle);
     }
   if(mode)
     {
      int j;
      for(int i=0; i<ArraySize(data); i++)
        {
         j = iBarShift(NULL,PERIOD_CURRENT,data[i].Datetime,false);
         if(j<0)
            continue;
         ClosedBuffer[j] = (double)data[i].Closed;
         ProfitBuffer[j] = (double)data[i].Profit;
         MarginBuffer[j] = (double)data[i].Margin;
        }
     }
  }
//========================================================================================================================================================================================================
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

   if(IsStarting && AccountInfoInteger(ACCOUNT_LOGIN) != 0)
     {
      ReadData(true);
      if(AutoScale)
         SetScale(100,0);
      ChartRedraw();
      IsStarting = false;
     }

   double profit = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
            continue;
         if(Recognize == 0)
           {
            if(OrderComment() != oComment)
               continue;
           }
         if(Recognize == 1)
           {
            if(OrderMagicNumber() != Magic_start)
               continue;
           }
         if(Recognize == 2)
           {
            if(OrderMagicNumber() < Magic_start || OrderMagicNumber() > Magic_end)
               continue;
           }
         if(Recognize == 3)
           {
            if((OrderComment() != oComment) || OrderMagicNumber() != Magic_start)
               continue;
           }
         if(Recognize == 4)
           {
            if((OrderComment() != oComment) || (OrderMagicNumber() < Magic_start || OrderMagicNumber() > Magic_end))
               continue;
           }
         profit += (OrderProfit() + OrderSwap() + OrderCommission());
        }
     }
   prev_history_total = history_total;
   history_total = OrdersHistoryTotal();
   if(history_total != prev_history_total)
     {
      closed_profit = 0;
      for(int h=history_total-1; h>=0; h--)
        {
         if(OrderSelect(h,SELECT_BY_POS,MODE_HISTORY))
           {
            if(OrderOpenTime() < start_history)
               continue;
            if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
               continue;
            if(Recognize == 0)
              {
               if(OrderComment() != oComment)
                  continue;
              }
            if(Recognize == 1)
              {
               if(OrderMagicNumber() != Magic_start)
                  continue;
              }
            if(Recognize == 2)
              {
               if(OrderMagicNumber() < Magic_start || OrderMagicNumber() > Magic_end)
                  continue;
              }
            if(Recognize == 3)
              {
               if((OrderComment() != oComment) || OrderMagicNumber() != Magic_start)
                  continue;
              }
            if(Recognize == 4)
              {
               if((OrderComment() != oComment) || (OrderMagicNumber() < Magic_start || OrderMagicNumber() > Magic_end))
                  continue;
              }
            closed_profit += (OrderProfit() + OrderSwap() + OrderCommission());
           }
        }
     }
   ClosedBuffer[0] = closed_profit;
   ProfitBuffer[0] = closed_profit+profit;
   MarginBuffer[0] = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
//--------------------------------------------------------------------------------------------------------------------------------
   if(LastBar != (datetime)SeriesInfoInteger(_Symbol,PERIOD_M5,SERIES_LASTBAR_DATE))
     {
      data[0].Datetime = LastBar;
      int handle = FileOpen(StringFormat("%s\\%d_%s",folder,AccountInfoInteger(ACCOUNT_LOGIN),filename),FILE_READ|FILE_WRITE|FILE_BIN);
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle,0,SEEK_END);
         FileWriteArray(handle,data,0,1);
         FileClose(handle);
        }
      LastBar = (datetime)SeriesInfoInteger(_Symbol,PERIOD_M5,SERIES_LASTBAR_DATE);
     }
   data[0].Closed = (float)ClosedBuffer[0];
   data[0].Profit = (float)ProfitBuffer[0];
   data[0].Margin = (float)MarginBuffer[0];
//--------------------------------------------------------------------------------------------------------------------------------
   if(AutoScale)
     {
      //if(ProfitBuffer[0] < min + diff || ClosedBuffer[0] > max - diff || MarginBuffer[0] > max - diff)
      if(ProfitBuffer[0] < min + diff || ClosedBuffer[0] > max - diff)
        {
         SetScale(2*diff,diff);
        }
     }
//--------------------------------------------------------------------------------------------------------------------------------
   return(rates_total);
  }
//========================================================================================================================================================================================================
void MakeCleanChart()
  {
   ChartSetInteger(0,CHART_AUTOSCROLL,1);
   ChartSetInteger(0,CHART_FOREGROUND,0);
   ChartSetInteger(0,CHART_SHOW_OHLC,0);
   ChartSetInteger(0,CHART_SHOW_BID_LINE,0);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,1);
   ChartSetInteger(0,CHART_SHOW_VOLUMES,0);
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,0);
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0);
   ChartSetInteger(0,CHART_SHOW_GRID,0);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'40,40,40');
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrDarkGray);
   ChartSetInteger(0,CHART_COLOR_GRID,clrDarkGray);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);
   ChartSetInteger(0,CHART_COLOR_VOLUME,clrNONE);
   ChartSetInteger(0,CHART_COLOR_ASK,clrNONE);
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,clrNONE);
   ChartRedraw();
  }
//========================================================================================================================================================================================================
void SetScale(const int fix_max, const int fix_min)
  {
   int arr_max, arr_min;
   double maxClosed, maxMargin;
   arr_max = ArrayMaximum(ClosedBuffer,range,0);
   maxClosed = ClosedBuffer[arr_max];
   //arr_max = ArrayMaximum(MarginBuffer,range,0); //doesn't work well for margin
   //maxMargin = MarginBuffer[arr_max];            //doesn't work well for margin
   maxMargin = 0;
   max = MathMax(maxClosed,maxMargin);
   arr_min = ArrayMinimum(ProfitBuffer,range,0);
   min = ProfitBuffer[arr_min];
//-----------------------------------
   min -= 100+(int)min%100+fix_min;
   min = MathMin(min,-100);
   max += (100-(int)max%100)+fix_max;
//-----------------------------------
   IndicatorSetDouble(INDICATOR_MAXIMUM,(int)max);
   IndicatorSetDouble(INDICATOR_MINIMUM,(int)min);
   if((fix_max & fix_min) != 0)
      PrintFormat("(%.2f) max %d -> max %d | (%.2f) min %d -> %d",ClosedBuffer[0],(int)max-fix_max,(int)max,ProfitBuffer[0],(int)min-fix_min,(int)min);
  }
//========================================================================================================================================================================================================
void DrawControls()
  {
   string timeframes[6] = {"M5", "M15", "M30", "H1", "H4", "D1"};
   int periods[6]    = {5, 15, 30, 60, 240, 1440};
   int sub_window = ChartWindowFind();
   int X = 2;
   for(char tf=0; tf<ArraySize(timeframes); tf++)
     {
      ObjectCreate(0,timeframes[tf],OBJ_BUTTON,sub_window,0,0);
      ObjectSetString(0,timeframes[tf],OBJPROP_TEXT,timeframes[tf]);
      ObjectSetString(0,timeframes[tf],OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,timeframes[tf],OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_BGCOLOR,clrDarkGray);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_XSIZE,40);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_YSIZE,18);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_XDISTANCE,X);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_YDISTANCE,20);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,timeframes[tf],OBJPROP_HIDDEN,true);
      if(_Period == periods[tf])
        {
         ObjectSetInteger(0,timeframes[tf],OBJPROP_COLOR,clrLime);
         ObjectSetInteger(0,timeframes[tf],OBJPROP_STATE,true);
        }
      X+=42;
     }
   ObjectCreate(0,"ExportToCSV",OBJ_BUTTON,sub_window,0,0);
   ObjectSetString(0,"ExportToCSV",OBJPROP_TEXT,"to CSV");
   ObjectSetString(0,"ExportToCSV",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_BGCOLOR,clrDarkGray);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_XSIZE,60);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_YSIZE,18);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"ExportToCSV",OBJPROP_HIDDEN,true);
  }
//========================================================================================================================================================================================================
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      string clickedObjectName = sparam;
      if(StringFind(clickedObjectName,"ExportToCSV") == -1 && ObjectGetInteger(0,clickedObjectName,OBJPROP_TYPE) == OBJ_BUTTON)
        {
         string timeframes[6] = {"M5", "M15", "M30", "H1", "H4", "D1" };
         int periods[6]       = {  5,   15,    30,    60,  240,  1440 };
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_STATE))
           {
            ObjectSetInteger(0,clickedObjectName,OBJPROP_COLOR,clrLime);
            for(char tf=0; tf<ArraySize(timeframes); tf++)
              {
               if(clickedObjectName != timeframes[tf])
                 {
                  ObjectSetInteger(0,timeframes[tf],OBJPROP_COLOR,clrBlack);
                  ObjectSetInteger(0,timeframes[tf],OBJPROP_STATE,false);
                 }
               else
                 {
                  ChartSetSymbolPeriod(0,NULL,periods[tf]);
                 }
              }
           }
         else
           {
            ObjectSetInteger(0,clickedObjectName,OBJPROP_COLOR,clrBlack);
           }
        }
      else
         if(clickedObjectName == "ExportToCSV")
           {
            ObjectSetInteger(0,clickedObjectName,OBJPROP_COLOR,clrLime);
            if(ObjectGetInteger(0,clickedObjectName,OBJPROP_STATE))
              {
               ReadData(false);
               string CSV;
               for(int c=0; c<ArraySize(data); c++)
                 {
                  CSV += StringFormat("%s,%.2f,%.2f,%.2f\n",TimeToString(data[c].Datetime,TIME_DATE|TIME_MINUTES),data[c].Closed,data[c].Profit,data[c].Margin);
                 }
               int handle = FileOpen(StringFormat("%s\\%d_%s.csv",folder,AccountInfoInteger(ACCOUNT_LOGIN),filename),FILE_WRITE|FILE_CSV);
               if(handle != INVALID_HANDLE)
                 {
                  FileWriteString(handle,CSV);
                  FileClose(handle);
                 }
               ObjectSetString(0,clickedObjectName,OBJPROP_TEXT,".csv saved");
              }
            else
              {
               ObjectSetString(0,clickedObjectName,OBJPROP_TEXT,"to CSV");
               ObjectSetInteger(0,clickedObjectName,OBJPROP_COLOR,clrBlack);
               ObjectSetInteger(0,clickedObjectName,OBJPROP_STATE,false);
              }
           }
     }
  }
//========================================================================================================================================================================================================
