//+------------------------------------------------------------------+
//|                                                     ATR Dual.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "ATR Dual"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_DOT
#property indicator_color1  clrDarkTurquoise
#property indicator_label1  "ATR Master"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrDarkOrange
#property indicator_label2  "ATR Slave"
//--- input parameters
input int   Inp_ATR_Master_ma_period   = 14; // ATR "Master" averaging period
input int   Inp_ATR_Slave_ma_period    = 1;  // ATR "Slave" averaging period
//--- indicator buffers
double iATRBuffer_Master[];
double iATRBuffer_Slave[];
int    handle_iATR_Master;                   // variable for storing the handle of the iATR indicator 
int    handle_iATR_Slave;                    // variable for storing the handle of the iATR indicator 
//--- we will keep the number of values in the Average True Range indicator 
int    bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,iATRBuffer_Master,INDICATOR_DATA);
   SetIndexBuffer(1,iATRBuffer_Slave,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- create handle of the indicator iATR
   handle_iATR_Master=iATR(Symbol(),Period(),Inp_ATR_Master_ma_period);
//--- if the handle is not created 
   if(handle_iATR_Master==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator (\"Master\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iATR
   handle_iATR_Slave=iATR(Symbol(),Period(),Inp_ATR_Slave_ma_period);
//--- if the handle is not created 
   if(handle_iATR_Slave==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator (\"Slave\") for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Average True Range indicator is calculated_master for
   string short_name=StringFormat("ATR Dual(%d,%d)",Inp_ATR_Master_ma_period,Inp_ATR_Slave_ma_period);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- normal initialization of the indicator 
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
//--- number of values copied from the iATR indicator 
   int values_to_copy;
//--- determine the number of values calculated_master in the indicator 
   int calculated_master=BarsCalculated(handle_iATR_Master);
   int calculated_slave=BarsCalculated(handle_iATR_Slave);
   if(calculated_master<=0 || calculated_slave<=0 || calculated_master!=calculated_slave)
     {
      PrintFormat("BarsCalculated(\"Master\") returned %d, BarsCalculated(\"Slave\") returned %d,",calculated_master,calculated_slave);
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iATR indicator changed 
//---or if it is necessary to calculated_master the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated_master!=bars_calculated || calculated_slave!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iATRBuffer array is greater than the number of values in the iATR indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated_master>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated_master;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iATRBuffer array with values of the Average True Range indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iATRBuffer_Master,handle_iATR_Master,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(iATRBuffer_Slave,handle_iATR_Slave,values_to_copy))
      return(0);
//--- memorize the number of values in the Average True Range indicator 
   bars_calculated=calculated_master;
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iATR indicator                | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],  // indicator buffer for ATR values 
                         int ind_handle,    // handle of the iATR indicator 
                         int amount         // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATRBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated_master 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
