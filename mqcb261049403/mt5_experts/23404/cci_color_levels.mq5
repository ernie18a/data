//+------------------------------------------------------------------+
//|                                             CCI Color Levels.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "The indicator displays the color histogram sites of the chart above \"Level UP\" and below \"Level DOWN\""
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- Level UP
#property indicator_label1  "Level UP"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- CCI
#property indicator_label2  "CCI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- Level DOWN
#property indicator_label3  "Level DOWN"
#property indicator_type3   DRAW_HISTOGRAM2
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input int      Inp_CCI_ma_period = 14;    // Averaging period 
input double   Inp_CCI_LevelUP   = 90;    // Level UP
input double   Inp_CCI_LevelDOWN =-90;    // Level DOWN
//--- indicator buffers
double         BufferUpHigh[];            // when you call from the Expert Advisor, you must specify the number of the buffer 0
double         BufferUpLow[];
double         BufferCCI[];               // when you call from the Expert Advisor, you must specify the number of the buffer 2
double         BufferDownHigh[];
double         BufferDownLow[];           // when you call from the Expert Advisor, you must specify the number of the buffer 4
//--- variable for storing the handle of the iCCI indicator 
int    handle_iCCI;
//--- we will keep the number of values in the Commodity Channel Index indicator 
int    bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+                    
int OnInit()
  {
//--- check for input value of period
   if(Inp_CCI_ma_period<=0)
     {
      printf("Incorrect value for input variable \"Averaging period\"=%d.",Inp_CCI_ma_period);
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpHigh,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUpLow,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCCI,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDownHigh,INDICATOR_DATA);
   SetIndexBuffer(4,BufferDownLow,INDICATOR_DATA);
//--- set levels 
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_CCI_LevelUP);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_CCI_LevelDOWN);
//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI Color Levels("+string(14)+")");
//--- indexes draw begin settings
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_CCI_ma_period-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_CCI_ma_period-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,Inp_CCI_ma_period-1);
//--- sets drawing line to empty value 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(Symbol(),Period(),Inp_CCI_ma_period,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
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
//--- number of values copied from the iCCI indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle_iCCI);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iCCI indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the CCI array is greater than the number of values in the iCCI indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the CCI array with values of the Commodity Channel Index indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(BufferCCI,handle_iCCI,values_to_copy)) return(0);
   int d=0;
   int limit=rates_total-values_to_copy;
   for(int i=limit;i<rates_total;i++)
     {
      if(BufferCCI[i]<=Inp_CCI_LevelDOWN)
        {
         BufferUpHigh[i]   = 0.0;
         BufferUpLow[i]    = 0.0;
         BufferDownHigh[i] = Inp_CCI_LevelDOWN;
         BufferDownLow[i]  = BufferCCI[i];
        }
      else if(BufferCCI[i]>=Inp_CCI_LevelUP)
        {
         BufferUpHigh[i]   = BufferCCI[i];
         BufferUpLow[i]    = Inp_CCI_LevelUP;
         BufferDownHigh[i] = 0.0;
         BufferDownLow[i]  = 0.0;
        }
      else
        {
         BufferUpHigh[i]   = 0.0;
         BufferUpLow[i]    = 0.0;
         BufferDownHigh[i] = 0.0;
         BufferDownLow[i]  = 0.0;
        }
     }
//--- memorize the number of values in the Commodity Channel Index indicator 
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iCCI indicator                | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],  // indicator buffer of Commodity Channel Index values 
                         int ind_handle,    // handle of the iCCI indicator 
                         int amount         // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the CCI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
