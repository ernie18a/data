//+------------------------------------------------------------------+
//|                                                    CCI Color.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- CCI
#property indicator_label1  "CCI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      Inp_CCI_ma_period = 14;    // Averaging period
input double   Inp_CCI_LevelUP   = 100;   // Level UP
input double   Inp_CCI_LevelDOWN =-100;   // Level DOWN
//--- indicator buffers
double   CCI_Buffer[];
double   CCC_Colors[];
//---
int      handle_iCCI;               // variable for storing the handle of the iCCI indicator
int      bars_calculated   = 0;     // we will keep the number of values in the Commodity Channel Index indicator
bool     m_init_error      = false; // error on InInit
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
   SetIndexBuffer(0,CCI_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,CCC_Colors,INDICATOR_COLOR_INDEX);
//--- set levels
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_CCI_LevelUP);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_CCI_LevelDOWN);
//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI Color("+IntegerToString(Inp_CCI_ma_period)+")");
//--- indexes draw begin settings
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_CCI_ma_period-1);
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
      m_init_error=true;
      return(INIT_SUCCEEDED);
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
   if(m_init_error)
      return(0);
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
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the CCI array with values of the Commodity Channel Index indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(CCI_Buffer,handle_iCCI,values_to_copy))
      return(0);
   if(rates_total<3)
      return(0);
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=1;
   for(int i=limit; i<rates_total; i++)
     {
      //--- zero crossing
      if(CCI_Buffer[i-1]<0.0 && CCI_Buffer[i]>=0.0)
         CCC_Colors[i]=1.0;
      if(CCI_Buffer[i-1]>0.0 && CCI_Buffer[i]<=0.0)
         CCC_Colors[i]=0.0;
      //---
      if(CCI_Buffer[i]>=0.0)
         CCC_Colors[i]=1.0;
      else
         CCC_Colors[i]=0.0;
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
