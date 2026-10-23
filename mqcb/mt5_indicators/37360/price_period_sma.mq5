//+------------------------------------------------------------------+
//|                                             Price period SMA.mq5 |
//|                                 Copyright 2021, Lilita Bogackova |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Lilita Bogackova"
#property link      "https://forge.mql5.io"
#property strict
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot symbolPrice
#property indicator_label1  "symbolPrice"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot symbolSMA
#property indicator_label2  "symbolSMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
enum ENUM_USE_SMA
  {
   HOUR_SMA,                                                // Hourly moving average
   DAY_SMA                                                  // Daily moving average
  };
input string               _symbolName    ="0";             // Symbol, 0 = take a symbol from the chart
input ENUM_USE_SMA         _useSMA        =DAY_SMA;         // Use moving average
input ENUM_APPLIED_PRICE   _appliedPrice  =PRICE_WEIGHTED;  // Price
input bool                 _createVLine   =true;            // Create a period dividing line
//---
int      barsCalculated=0;
int      symbolHandle=-1;
int      currDateTime=0;
int      seperator=0;
int      dateTime=0;
int      settPeriod=1;
long     timeStatic=0;
string   shortName="";
string   symbolName="";
bool     chartSetSymbolPeriod;
ENUM_TIMEFRAMES period;
//--- indicator buffers
double   symbolPriceBuffer[];
double   symbolSMABuffer[];
double   symbolPriceHandleBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,symbolPriceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,symbolSMABuffer,INDICATOR_DATA);
   SetIndexBuffer(2,symbolPriceHandleBuffer,INDICATOR_CALCULATIONS);
//---
   period=PERIOD_CURRENT;
//---
   symbolName=_symbolName;
   if(StringLen(_symbolName)<=1)
      //--- takes a symbol from the chart on which the indicator works
      symbolName=_Symbol;
//--- select the period
   switch(_useSMA)
     {
      case HOUR_SMA:
         seperator=1;
         shortName=StringFormat("PP SMA (%s, %s)",symbolName,"HOUR SMA");
         if(Period()>=PERIOD_H1)
            period=PERIOD_M1;
         break;
      case DAY_SMA:
         seperator=10;
         shortName=StringFormat("PP SMA (%s, %s)",symbolName,"DAY SMA");
         if(Period()>=PERIOD_D1)
            period=PERIOD_M15;
     }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
//--- create an indicator handle
   symbolHandle=iMA(symbolName,PERIOD_CURRENT,settPeriod,0,MODE_SMA,_appliedPrice);
//--- if it was not possible to create a symbolHandle
   if(symbolHandle==INVALID_HANDLE)
     {
      //--- the indicator ends prematurely
      return(INIT_FAILED);
     }
//---
   chartSetSymbolPeriod=false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
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
   int i,limit;
//---
   static int calculated_min=INT_MAX;
   double periodSeperatorValue=0.0;
   if(calculated_min==INT_MAX)
     {
      //--- determine the number of values calculated in the indicator
      int calculated=BarsCalculated(symbolHandle);
      if(calculated<=settPeriod)
        {
         calculated_min=INT_MAX;
         return(0);
        }
      if(calculated_min>calculated-settPeriod)
         calculated_min=calculated-settPeriod;
      //--- determine the number of values calculated on the graph
      calculated=Bars(Symbol(),PERIOD_CURRENT);
      if(calculated<=settPeriod)
        {
         calculated_min=INT_MAX;
         return(0);
        }
      if(calculated_min>calculated-settPeriod)
         calculated_min=calculated-settPeriod;
     }
//--- number of values copied from the iMA indicator
   int values_to_copy=0;
//--- if this is the first start of the indicator calculation or if the number of values in the iMA indicator has changed
//--- or if you need to calculate the indicator for two or more bars (it means that something has changed in the history of the price)
   if(prev_calculated==0 || calculated_min!=barsCalculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for the symbol/period, then we do not copy everything
      //--- otherwise we copy less than the size of the indicator buffers
      if(calculated_min>=rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated_min;
     }
   else
     {
      //--- this means that this is not the first time the indicator has been calculated, but since the last call to OnCalculate()
      //--- no more than two bars are added for calculation
      values_to_copy=(rates_total-prev_calculated)+2;
     }
//--- remember the number of values in the indicator
   barsCalculated=calculated_min;
//---
   limit=rates_total-values_to_copy;
//--- fill in the elements in the buffer array
   FillArrayFromBuffer(symbolPriceHandleBuffer,symbolHandle,values_to_copy);
//---
   static int SMAperiod=0;
//--- main cycle
   for(i=limit+1; i<rates_total && !IsStopped(); i++)
     {
      //--- fill the price buffer
      symbolPriceBuffer[i]=symbolPriceHandleBuffer[i];
      //--- check whether the specified period has changed
      dateTime=DateTime(time[i],seperator);
      if(dateTime!=currDateTime)
        {
         SMAperiod=-1;
         currDateTime=dateTime;
         //--- drawing vertical lines
         if(_createVLine&&i>=rates_total-(1440/(PeriodSeconds(PERIOD_CURRENT)/60)*seperator))
           {
            if(!VLineCreate(time[i]))
               Print("Error creating object: ",GetLastError());
           }
        }
      //--- if a new bar arrives, extend the SMA period
      if((long)time[i]!=timeStatic)
        {
         SMAperiod++;
         timeStatic=(long)time[i];
        }
      //--- calculate SMA
      symbolSMABuffer[i]=symbolPriceBuffer[i]*2.0/(1.0+SMAperiod)+symbolSMABuffer[i-1]*(1.0-2.0/(1.0+SMAperiod));
     }
//--- update the chart
   if(!chartSetSymbolPeriod)
     {
      chartSetSymbolPeriod=ChartSetSymbolPeriod(ChartID(),Symbol(),period);
      ChartRedraw();
     }
//--- the return value of the prev_calculated for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Returns the hour of the day, or day                              |
//+------------------------------------------------------------------+
int DateTime(const datetime time, int sep)
  {
   MqlDateTime dt;
   TimeToStruct(time,dt);
//---
   if(sep==1)
      return dt.hour;
   else
      return dt.day_of_week;
  }
//+------------------------------------------------------------------+
//| Create a vertical line                                           |
//+------------------------------------------------------------------+
bool VLineCreate(datetime time=0)
  {
   static int count=0;
   ResetLastError();
   if(ObjectFind(ChartID(),"PP SMA"+IntegerToString(++count))<0)
     {
      if(!ObjectCreate(ChartID(),"PP SMA"+IntegerToString(count),OBJ_VLINE,0,time,0))
        {
         return(false);
        }
      else
        {
         ObjectSetInteger(ChartID(),"PP SMA"+IntegerToString(count),OBJPROP_COLOR,clrGreen);
         ChartRedraw(ChartID());
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Filling the indicator buffer from the indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &ind_buffer[],  // indicator value buffer
                         int ind_handle,        // indicator handle
                         int amount             // number of values to be copied
                        )
  {
//--- reset the error code
   ResetLastError();
//--- fill part of the array with ind_buffer values from the indicator buffer under index 0
   if(CopyBuffer(ind_handle,0,0,amount,ind_buffer)<0)
     {
      //--- if the copy failed, we will report an error code
      PrintFormat("Failed to copy data from indicator, error code %d",GetLastError());
      //--- will complete with a zero result - this means that the indicator will be considered uncalculated
      return(false);
     }
//--- everything worked out
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"PP SMA");
  }
//+------------------------------------------------------------------+