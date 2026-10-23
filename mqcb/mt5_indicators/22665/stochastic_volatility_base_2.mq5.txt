//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#resource "Stochastic volatility base.ex5"
#property indicator_separate_window
#property indicator_buffers 15
#property indicator_plots   1
#property indicator_label1  "Stochastic"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
//
//--- input parameters
//

input int                Length             =  30;            // Stochastic period
input int                Slowing            =   5;            // Stochastic slowing
input ENUM_APPLIED_PRICE Price              = PRICE_CLOSE;    // Price
input bool               OriginalStoch      = true;           // Calculate using original stochastic
input bool               OriginalVolatility = true;           // Calculate using original volatility
//
//---
//
double val[],ma1[],ma2[],ma3[],ma4[],ma5[],sd1[],sd2[],sd3[],sd4[],sd5[],vol[],whi[],wlo[];
int _hma1,_hma2,_hma3,_hma4,_hma5,_hsd1,_hsd2,_hsd3,_hsd4,_hsd5,_hbp;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer( 0,val,INDICATOR_DATA);
   SetIndexBuffer( 1,ma1,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 2,ma2,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 3,ma3,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 4,ma4,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 5,ma5,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 6,sd1,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 7,sd2,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 8,sd3,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 9,sd4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,sd5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,vol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,whi,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,wlo,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,vol,INDICATOR_CALCULATIONS);
   
   //
   //---
   //
   
      _hbp  = iCustom(_Symbol,0,"::Stochastic volatility base.ex5",Price); if (!_checkHandle(_hbp,"Base indicator")) return(INIT_FAILED);
      _hma1 =     iMA(_Symbol,0,10,0,MODE_SMA,_hbp); if (!_checkHandle(_hma1,"Moving average 10"))     return(INIT_FAILED);
      _hma2 =     iMA(_Symbol,0,21,0,MODE_SMA,_hbp); if (!_checkHandle(_hma2,"Moving average 21"))     return(INIT_FAILED);
      _hma3 =     iMA(_Symbol,0,34,0,MODE_SMA,_hbp); if (!_checkHandle(_hma3,"Moving average 34"))     return(INIT_FAILED);
      _hma4 =     iMA(_Symbol,0,55,0,MODE_SMA,_hbp); if (!_checkHandle(_hma4,"Moving average 55"))     return(INIT_FAILED);
      _hma5 =     iMA(_Symbol,0,89,0,MODE_SMA,_hbp); if (!_checkHandle(_hma5,"Moving average 89"))     return(INIT_FAILED);
      _hsd1 = iStdDev(_Symbol,0,10,0,MODE_SMA,_hbp); if (!_checkHandle(_hsd1,"Standard deviation 10")) return(INIT_FAILED);
      _hsd2 = iStdDev(_Symbol,0,21,0,MODE_SMA,_hbp); if (!_checkHandle(_hsd2,"Standard deviation 10")) return(INIT_FAILED);
      _hsd3 = iStdDev(_Symbol,0,34,0,MODE_SMA,_hbp); if (!_checkHandle(_hsd3,"Standard deviation 10")) return(INIT_FAILED);
      _hsd4 = iStdDev(_Symbol,0,55,0,MODE_SMA,_hbp); if (!_checkHandle(_hsd4,"Standard deviation 10")) return(INIT_FAILED);
      _hsd5 = iStdDev(_Symbol,0,89,0,MODE_SMA,_hbp); if (!_checkHandle(_hsd5,"Standard deviation 10")) return(INIT_FAILED);
   
   return(INIT_SUCCEEDED);
}
//
//---
//
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
   if(BarsCalculated(_hbp) <rates_total) return(prev_calculated);
   if(BarsCalculated(_hma1)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hma2)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hma3)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hma4)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hma5)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd1)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd2)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd3)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd4)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd5)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
            if (CopyBuffer(_hma1,0,0,_copyCount,ma1)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hma2,0,0,_copyCount,ma2)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hma3,0,0,_copyCount,ma3)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hma4,0,0,_copyCount,ma4)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hma5,0,0,_copyCount,ma5)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hsd1,0,0,_copyCount,sd1)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hsd2,0,0,_copyCount,sd2)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hsd3,0,0,_copyCount,sd3)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hsd4,0,0,_copyCount,sd4)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_hsd5,0,0,_copyCount,sd5)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   double _mul = MathSqrt(252);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      if (ma1[i]==EMPTY_VALUE || sd1[i]==EMPTY_VALUE) { whi[i] = wlo[i] = vol[i] = val[i] = 0; continue; }
      if (ma2[i]==EMPTY_VALUE || sd2[i]==EMPTY_VALUE) { whi[i] = wlo[i] = vol[i] = val[i] = 0; continue; }
      if (ma3[i]==EMPTY_VALUE || sd3[i]==EMPTY_VALUE) { whi[i] = wlo[i] = vol[i] = val[i] = 0; continue; }
      if (ma4[i]==EMPTY_VALUE || sd4[i]==EMPTY_VALUE) { whi[i] = wlo[i] = vol[i] = val[i] = 0; continue; }
      if (ma5[i]==EMPTY_VALUE || sd5[i]==EMPTY_VALUE) { whi[i] = wlo[i] = vol[i] = val[i] = 0; continue; }
   
      //
      //---
      //
         
      #define _volatility(_ma,_sd) ((OriginalVolatility) ? (_ma[i]+_sd[i])*_mul : _sd[i])
         double vol1   = _volatility(ma1,sd1)*3.0;
         double vol2   = _volatility(ma2,sd2)*3.0;
         double vol3   = _volatility(ma3,sd3)*2.0;
         double vol4   = _volatility(ma4,sd4);
         double vol5   = _volatility(ma5,sd5);
                vol[i] = (vol1+vol2+vol3+vol4+vol5);

         //
         //---
         //

         int _start = (i>Length) ? i-Length+1 : 0;
               wlo[i] = vol[ArrayMinimum(vol,_start,Length)];
               whi[i] = vol[ArrayMaximum(vol,_start,Length)];

               double stoc=0;
               if(OriginalStoch)
               {
                  double sumRng = 0;
                  double sumLow = 0;
                  for(int k=0; k<Slowing && (i-k)>=0; k++)
                  {
                     sumRng += whi[i-k]-wlo[i-k];
                     sumLow += vol[i-k]-wlo[i-k];
                  }
                  if(sumRng!=0) stoc=100*sumLow/sumRng;
               }
               else
               {
                  double stov = ((whi[i]-wlo[i])!=0) ? 100*(vol[i]-wlo[i])/(whi[i]-wlo[i]) : 0;
                         stoc = (i>0) ? val[i-1]+(2.0/(1.0+Slowing))*(stov-val[i-1]) :  0;
               }

         //
         //---
         //           
        
         val[i] = stoc;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}    
//+------------------------------------------------------------------+
