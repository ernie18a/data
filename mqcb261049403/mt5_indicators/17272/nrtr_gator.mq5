//+------------------------------------------------------------------+
//|                          NRTR GATOR(barabashkakvn's edition).mq5 |
//|                                                             Rosh |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5 
#property indicator_color1 clrTomato
#property indicator_type1 DRAW_ARROW

#property indicator_color2 clrDeepSkyBlue
#property indicator_type2 DRAW_ARROW

#property indicator_color3 clrDeepSkyBlue
#property indicator_type3 DRAW_ARROW

#property indicator_color4 clrTomato
#property indicator_type4 DRAW_ARROW

#property indicator_color5 clrYellowGreen,clrRed
#property indicator_type5 DRAW_COLOR_HISTOGRAM2 
#property indicator_width5 3 

//#property indicator_color6 clrRed
//---- input parameters
input int       PerATR=40;
input double    kATR=2.0;
input bool      useSendMail=false;
//---- buffers
double SellBuffer[];
double BuyBuffer[];
double Ceil[];
double Floor[];
double UpBar[];
double DownBar[];
double ColorHistogram_2Colors[];
double Trend[];
double GatorTrend[];
//---
int    handle_iATR;                          // variable for storing the handle of the iATR indicator 
int    handle_iAlligator;                    // variable for storing the handle of the iAlligator indicator 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping 

   PlotIndexSetInteger(0,PLOT_ARROW,251);
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(0,PLOT_LABEL,"Линия продажи");

   PlotIndexSetInteger(1,PLOT_ARROW,251);
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(1,PLOT_LABEL,"Линия покупки");

   PlotIndexSetInteger(2,PLOT_ARROW,159);
   SetIndexBuffer(2,Ceil,INDICATOR_DATA);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(2,PLOT_LABEL,"Потолок");

   PlotIndexSetInteger(3,PLOT_ARROW,159);
   SetIndexBuffer(3,Floor,INDICATOR_DATA);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(3,PLOT_LABEL,"Пол");

   SetIndexBuffer(4,UpBar,INDICATOR_DATA);
//PlotIndexSetString(4,PLOT_LABEL,"Верх бара");

   SetIndexBuffer(5,DownBar,INDICATOR_DATA);
//PlotIndexSetString(4,PLOT_LABEL,"Низ бара");

   SetIndexBuffer(6,ColorHistogram_2Colors,INDICATOR_COLOR_INDEX);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,2);

   SetIndexBuffer(7,Trend,INDICATOR_CALCULATIONS);

   SetIndexBuffer(8,GatorTrend,INDICATOR_CALCULATIONS);

//--- create handle of the indicator iATR
   handle_iATR=iATR(Symbol(),Period(),PerATR);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(Symbol(),Period(),13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   ArraySetAsSeries(SellBuffer,true);
   ArraySetAsSeries(BuyBuffer,true);
   ArraySetAsSeries(Ceil,true);
   ArraySetAsSeries(Floor,true);
   ArraySetAsSeries(UpBar,true);
   ArraySetAsSeries(DownBar,true);
   ArraySetAsSeries(ColorHistogram_2Colors,true);
   ArraySetAsSeries(Trend,true);
   ArraySetAsSeries(GatorTrend,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| пробитие верха ДАУНтренда                                        |
//+------------------------------------------------------------------+
bool BreakDown(int shift,const double close_value)
  {
   bool result=false;
   if(close_value>SellBuffer[shift+1])
      result=true;
   return(result);
  }
//+------------------------------------------------------------------+
//| пробитие дна АПтренда                                            |
//+------------------------------------------------------------------+
bool BreakUp(int shift,const double close_value)
  {
   bool result=false;
   if(close_value<BuyBuffer[shift+1])
      result=true;
   return(result);
  }
//+------------------------------------------------------------------+
//| взятие нового минимума по ДАУНтренду                             |
//+------------------------------------------------------------------+
bool BreakFloor(int shift,const double high_value)
  {
   bool result=false;
   if(high_value<Floor[shift+1])
      result=true;
   return(result);
  }
//+------------------------------------------------------------------+
//| взятие нового максимума по АПтренду                              |
//+------------------------------------------------------------------+
bool BreakCeil(int shift,const double low_value)
  {
   bool result=false;
   if(low_value>Ceil[shift+1])
      result=true;
   return(result);
  }
//+------------------------------------------------------------------+
//| определение предыдущего тренда                                   |
//+------------------------------------------------------------------+
bool Uptrend(int shift)
  {
   bool result=false;
   if(Trend[shift+1]==1.0)
      result=true;
   if(Trend[shift+1]==-1.0)
      result=false;
   if((Trend[shift+1]!=1.0) && (Trend[shift+1]!=-1))
      Print("Внимание! Тренд не определен, такого быть не может. Бар # ",shift);
   return(result);
  }
////+------------------------------------------------------------------+
////| вычисление волатильности                                         |
////+------------------------------------------------------------------+
//double ATR(int iPer,int shift)
//  {
//   double result;
//   result=iATR(NULL,0,iPer,shift);
//   return(result);
//
//
//
//
//  }
//+------------------------------------------------------------------+
//| установка нового уровня потолка                                  |
//+------------------------------------------------------------------+
void NewCeil(int shift,const double close_value)
  {
   Ceil[shift]=close_value;
   Floor[shift]=0.0;
  }
//+------------------------------------------------------------------+
//| установка нового уровня пола                                     |
//+------------------------------------------------------------------+
void NewFloor(int shift,const double close_value)
  {
   Floor[shift]=close_value;
   Ceil[shift]=0.0;
  }
//+------------------------------------------------------------------+
//| установка уровня поддержки АПтренда                              |
//+------------------------------------------------------------------+
void SetBuyBuffer(int shift,const double close_value)
  {
   BuyBuffer[shift]=close_value-kATR*iATRGet(shift);
   SellBuffer[shift]=0.0;
  }
//+------------------------------------------------------------------+
//| установка уровня поддержки ДАУНтренда                            |
//+------------------------------------------------------------------+
void SetSellBuffer(int shift,const double close_value)
  {
   SellBuffer[shift]=close_value+kATR*iATRGet(shift);
   BuyBuffer[shift]=0.0;
  }
//+------------------------------------------------------------------+
//| реверс тренда и установка новых уровней                          |
//+------------------------------------------------------------------+
void NewTrend(int shift,const double close_value)
  {
   if(Trend[shift+1]==1.0)
     {
      Trend[shift]=-1.0;
      NewFloor(shift,close_value);
      SetSellBuffer(shift,close_value);
     }
   else
     {
      Trend[shift]=1.0;
      NewCeil(shift,close_value);
      SetBuyBuffer(shift,close_value);
     }
   if((Trend[shift+1]!=1) && (Trend[shift+1]!=-1))
      Print("Внимание! Тренд не определен, такого быть не может");
  }
//+------------------------------------------------------------------+
//| продолжение тренда                                               |
//+------------------------------------------------------------------+
void CopyLastValues(int shift)
  {
   SellBuffer[shift]=SellBuffer[shift+1];
   BuyBuffer[shift]=BuyBuffer[shift+1];
   Ceil[shift]=Ceil[shift+1];
   Floor[shift]=Floor[shift+1];
   Trend[shift]=Trend[shift+1];
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
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
//---
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
////--- узнаем количество рассчитанных значений в индикаторе 
//   Comment(time[0],"Всего посчитано: \n",
//           "rates_total: ",rates_total,"\n",
//           "ATR: ",BarsCalculated(handle_iATR),"\n",
//           "Alligator: ",BarsCalculated(handle_iAlligator));
//return(rates_total);
//Print(rates_total,", ",BarsCalculated(handle_iATR),", ",BarsCalculated(handle_iAlligator));
//--- на "4" бар "0" - самый правый бар на графике
//int    counted_bars=IndicatorCounted();
   int limit=0;
   if(prev_calculated>0)
      limit=rates_total-prev_calculated+1;
   if(prev_calculated==0)
     {
      ArrayInitialize(SellBuffer,0.0);
      ArrayInitialize(BuyBuffer,0.0);
      ArrayInitialize(Ceil,0.0);
      ArrayInitialize(Floor,0.0);;
      ArrayInitialize(UpBar,0.0);
      ArrayInitialize(DownBar,0.0);
      ArrayInitialize(ColorHistogram_2Colors,2);
      ArrayInitialize(Trend,0.0);
      ArrayInitialize(GatorTrend,0.0);
      //---
      limit=rates_total-PerATR-1;
      if(close[limit+1]>open[limit+1])
        {
         Trend[limit+1]=1.0;
         Ceil[limit+1]=close[limit+1];
         BuyBuffer[limit+1]=close[limit+1]-kATR*iATRGet(limit+1);
        }
      if(close[limit+1]<open[limit+1])
        {
         Trend[limit+1]=-1.0;
         Floor[limit+1]=close[limit+1];
         SellBuffer[limit+1]=close[limit+1]+kATR*iATRGet(limit+1);
        }
      if(close[limit+1]==open[limit+1])
        {
         Trend[limit+1]=1.0;
         Ceil[limit+1]=close[limit+1];
         BuyBuffer[limit+1]=close[limit+1]-kATR*iATRGet(limit+1);
        }
     }
//---
//--- на "4" бар "0" - самый правый бар на графике
//--- на "5" бар "0" - самый левый бар на графике
   for(int cnt=limit;cnt>=0;cnt--)
     {
      if((iAlligatorGet(GATORJAW_LINE,cnt)<iAlligatorGet(GATORTEETH_LINE,cnt)) && 
         (iAlligatorGet(GATORTEETH_LINE,cnt)<iAlligatorGet(GATORLIPS_LINE,cnt)))
         GatorTrend[cnt]=1.0;
      if((iAlligatorGet(GATORJAW_LINE,cnt)>iAlligatorGet(GATORTEETH_LINE,cnt)) && 
         (iAlligatorGet(GATORTEETH_LINE,cnt)>iAlligatorGet(GATORLIPS_LINE,cnt)))
         GatorTrend[cnt]=-1.0;

      if(GatorTrend[cnt]==1.0)
        {
         UpBar[cnt]=high[cnt];
         DownBar[cnt]=low[cnt];
        }
      if(GatorTrend[cnt]==-1.0)
        {
         UpBar[cnt]=low[cnt];
         DownBar[cnt]=high[cnt];
        }
      if(UpBar[cnt]>DownBar[cnt])
         ColorHistogram_2Colors[cnt]=0;
      else
         ColorHistogram_2Colors[cnt]=1;

      if(Uptrend(cnt))
        {
         if(BreakCeil(cnt,low[cnt]))
           {
            NewCeil(cnt,close[cnt]);
            SetBuyBuffer(cnt,close[cnt]);
            Trend[cnt]=1.0;
            continue;
           }
         if(BreakUp(cnt,close[cnt]))
           {
            NewTrend(cnt,close[cnt]);
            continue;
           }
         CopyLastValues(cnt);
        }
      else
        {
         if(BreakFloor(cnt,high[cnt]))
           {
            NewFloor(cnt,close[cnt]);
            SetSellBuffer(cnt,close[cnt]);
            Trend[cnt]=-1.0;
            continue;
           }
         if(BreakDown(cnt,close[cnt]))
           {
            NewTrend(cnt,close[cnt]);
            continue;
           }
         CopyLastValues(cnt);
        }
     }

//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,index,1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAlligator                          |
//|  the buffer numbers are the following:                           |
//|   0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE     |
//+------------------------------------------------------------------+
double iAlligatorGet(const int buffer,const int index)
  {
   double Alligator[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAlligator,buffer,index,1,Alligator)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAlligator indicator, error code %d, buffer %d , index %d ",GetLastError(),buffer,index);
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Alligator[0]);
  }
//+------------------------------------------------------------------+
