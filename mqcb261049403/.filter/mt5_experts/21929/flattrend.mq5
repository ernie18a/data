//+------------------------------------------------------------------+
//|                           FlatTrend(barabashkakvn's edition).mq5 |
//|                                                       Kirk Sloan |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Kirk Sloan"
#property link      "https://www.metaquotes.net"
#property version   "1.002"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
//--- plot Histogram "Sell"
#property indicator_label1  "Sell"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Histogram "Buy"
#property indicator_label2  "Buy"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Histogram ""End Sell"
#property indicator_label3  "End Sell"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Histogram "End Buy"
#property indicator_label4  "End Buy"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input ENUM_TIMEFRAMES   InpSignalTimeframe=PERIOD_CURRENT; // signal timeframe
//---
double ExtMapBuffer0[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//---
double ADXBuffer[];              // adx indicator buffer
double DI_plusBuffer[];          // adx plus DI buffer
double DI_minusBuffer[];         // adx minus DI buffer
int    handle_iADX;              // variable for storing the handle of the iADX indicator 
int    bars_calculated_adx=0;    // we will keep the number of values in the Average Directional Movement Index indicator 
//---
double SARBuffer[];              // sar indicator buffer
int    handle_iSAR;              // variable for storing the handle of the iSAR indicator 
int    bars_calculated_sar=0;    // we will keep the number of values in the Parabolic SAR indicator 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer0,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMapBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMapBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtMapBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ADXBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,DI_plusBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,DI_minusBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,SARBuffer,INDICATOR_CALCULATIONS);
//--- set accuracy 
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- create handle of the indicator iADX
   handle_iADX=iADX(Symbol(),InpSignalTimeframe,14);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(InpSignalTimeframe),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),InpSignalTimeframe,0.02,0.2);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(InpSignalTimeframe),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(ExtMapBuffer0,0.0);
   ArrayInitialize(ExtMapBuffer1,0.0);
   ArrayInitialize(ExtMapBuffer2,0.0);
   ArrayInitialize(ExtMapBuffer3,0.0);
   ArrayInitialize(ADXBuffer,0.0);
   ArrayInitialize(DI_plusBuffer,0.0);
   ArrayInitialize(DI_minusBuffer,0.0);
   ArrayInitialize(SARBuffer,0.0);
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
//--- ADX
//--- number of values copied from the iADX indicator 
   int values_to_copy_adx;
//--- determine the number of values calculated in the indicator 
   int calculated_adx=BarsCalculated(handle_iADX);
   if(calculated_adx<=0)
     {
      PrintFormat("BarsCalculated(ADX) returned %d, error code %d",calculated_adx,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iADX indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated_adx!=bars_calculated_adx || rates_total>prev_calculated+1)
     {
      //--- if the iADXBuffer array is greater than the number of values in the iADX indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated_adx>rates_total)   values_to_copy_adx=rates_total;
      else                             values_to_copy_adx=calculated_adx;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy_adx=(rates_total-prev_calculated)+1;
     }
//--- fill the array with values of the Average Directional Movement Index indicator 
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArraysFromBuffersADX(ADXBuffer,DI_plusBuffer,DI_minusBuffer,handle_iADX,values_to_copy_adx))
      return(0);
//--- memorize the number of values in the Average Directional Movement Index indicator 
   bars_calculated_adx=calculated_adx;
//--- SAR
//--- number of values copied from the iSAR indicator 
   int values_to_copy_sar;
//--- determine the number of values calculated in the indicator 
   int calculated_sar=BarsCalculated(handle_iSAR);
   if(calculated_sar<=0)
     {
      PrintFormat("BarsCalculated(SAR) returned %d, error code %d",calculated_sar,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iSAR indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated_sar!=bars_calculated_sar || rates_total>prev_calculated+1)
     {
      //--- if the iSARBuffer array is greater than the number of values in the iSAR indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated_sar>rates_total)   values_to_copy_sar=rates_total;
      else                             values_to_copy_sar=calculated_sar;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy_sar=(rates_total-prev_calculated)+1;
     }
//--- fill the arrays with values of the iSAR indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBufferSAR(SARBuffer,handle_iSAR,values_to_copy_sar))
      return(0);
//--- memorize the number of values in the Parabolic SAR indicator 
   bars_calculated_sar=calculated_sar;
//---
//---
   if(values_to_copy_adx!=values_to_copy_sar)
     {
      Alert("Ахтунг");
      return(0);
     }
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit;i<rates_total;i++)
     {
      ExtMapBuffer0[i]=0.0;
      ExtMapBuffer1[i]=0.0;
      ExtMapBuffer2[i]=0.0;
      ExtMapBuffer3[i]=0.0;

      if(SARBuffer[i]<close[i])
        {
         if(DI_plusBuffer[i]>DI_minusBuffer[i])
            ExtMapBuffer1[i]=1.0;
         else
            ExtMapBuffer3[i]=1.0;
        }
      else
        {
         if(DI_plusBuffer[i]>DI_minusBuffer[i])
            ExtMapBuffer2[i]=1.0;
         else
            ExtMapBuffer0[i]=1.0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iADX indicator                | 
//+------------------------------------------------------------------+ 
bool FillArraysFromBuffersADX(double &adx_values[],      // indicator buffer of the ADX line 
                              double &DIplus_values[],   // indicator buffer for DI+ 
                              double &DIminus_values[],  // indicator buffer for DI- 
                              int ind_handle,            // handle of the iADX indicator 
                              int amount                 // number of copied values 
                              )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,adx_values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- fill a part of the DI_plusBuffer array with values from the indicator buffer that has index 1 
   if(CopyBuffer(ind_handle,1,0,amount,DIplus_values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- fill a part of the DI_minusBuffer array with values from the indicator buffer that has index 2 
   if(CopyBuffer(ind_handle,2,0,amount,DIminus_values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iSAR indicator                | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBufferSAR(double &sar_buffer[],  // indicator buffer of Parabolic SAR values 
                            int ind_handle,        // handle of the iSAR indicator 
                            int amount             // number of copied values 
                            )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,sar_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
