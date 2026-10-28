//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Discontinued signal lines version of smoothed Chandes momentum oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
#property indicator_label1  "CMO no trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "CMO"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int            inpCmoPeriod       = 20;        // CMO period
input int            inpCmoSignalPeriod =  9;        // CMO signal period
input int            inpMaPeriod        =  7;        // Smoothing period (<= 1 for no smoothing)
input ENUM_MA_METHOD inpMaMetod         = MODE_LWMA; // Smoothing method
//
//--- buffers and global variables declarations
//
double cmo[],cmoc[],dslup[],dsldn[],cmo1[],cmo2[],cmo3[],cmo4[],avg[];
int _mac;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0,dslup,INDICATOR_DATA);
   SetIndexBuffer(1,dsldn,INDICATOR_DATA);
   SetIndexBuffer(2,cmo  ,INDICATOR_DATA);
   SetIndexBuffer(3,cmoc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,cmo1 ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,cmo2 ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,cmo3 ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,cmo4 ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,avg  ,INDICATOR_CALCULATIONS);
   //---
      int _maPeriod = inpMaPeriod>0 ? inpMaPeriod : 1;
          _mac      = iMA(_Symbol,0,_maPeriod,0,inpMaMetod,PRICE_CLOSE ); if (!_checkHandle(_mac,"Moving average"))  return(INIT_FAILED);
   //---
   IndicatorSetString(INDICATOR_SHORTNAME,"Dsl Chandes momentum oscillator ("+(string)inpCmoPeriod+","+(string)inpCmoSignalPeriod+","+(string)_maPeriod+")");
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
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
   if(BarsCalculated(_mac)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = prev_calculated>0 ? rates_total-prev_calculated+1 : rates_total;
            if (CopyBuffer(_mac,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
      double _alpha=2.0/(1+inpCmoSignalPeriod);
   
   //
   //---
   //
         
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (avg[i]==EMPTY_VALUE) avg[i] = close[i];
         cmo[i]   = iCmo(inpCmoPeriod,avg,cmo1,cmo2,cmo3,cmo4,i)*100.0;
         dslup[i] = (i>0) ? (cmo[i]>0) ? dslup[i-1]+_alpha*(cmo[i]-dslup[i-1]) : dslup[i-1] : 0;
         dsldn[i] = (i>0) ? (cmo[i]<0) ? dsldn[i-1]+_alpha*(cmo[i]-dsldn[i-1]) : dsldn[i-1] : 0;
         cmoc[i]  = (cmo[i]>dslup[i]) ? 2 : (cmo[i]<dsldn[i]) ? 1 : 0;
   }
   return (i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//
//---
//
template<typename T>
double iCmo(int period, T& price[], double& diffu[], double& diffd[], double& cumu[], double& cumd[], int i)
{
   double diff = (i>0?price[i]-price[i-1]:0);
   if (diff>0) 
         { diffu[i] =  diff; diffd[i] = 0; }
   else  { diffd[i] = -diff; diffu[i] = 0; }
   if (i<period)
   {
      cumu[i] = cumd[i] = 0; 
      for(int k=0; k<period && (i-k)>=0; k++) 
      { 
         cumu[i] += diffu[i-k]; 
         cumd[i] += diffd[i-k]; 
      }
   }
   else  
   { 
      cumu[i] = cumu[i-1]-diffu[i-period]+diffu[i];
      cumd[i] = cumd[i-1]-diffd[i-period]+diffd[i];
   }
   return((cumu[i]+cumd[i])!=0 ? (cumu[i]-cumd[i])/(cumu[i]+cumd[i]) : 0);   
}
//
//----
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
