//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Averages composite trend"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 232
#property indicator_plots   3
#property indicator_label1  "CT trending"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrHotPink
#property indicator_width1  2
#property indicator_label2  "CT reverting"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrDarkGray,clrMediumSeaGreen,clrHotPink
#property indicator_width2  0
#property indicator_label3  "CT"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrGreen,clrDeepPink
#property indicator_width3  2
#property indicator_level1   30
#property indicator_level2  -30

//
//--- input parameters
//

input string             inpMaPeriods  = "10;15;20;25;30;40;50;60"; // Averages periods (separated by ";")
input ENUM_MA_METHOD     inpMethod     = MODE_EMA;                  // Averages method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;               // Averages price
input double             inpSmooth     =  3;                        // Smoothing/slowing period (<= 1 for no smoothing)

//
//--- indicator buffers
//

double val[],valc[],valht[],valhtc[],valhr[],valhrc[],ª_alpha;
int _handles[],_handlesSize,_maxPeriod;
struct simpleBuff { double buffer[]; };
       simpleBuff _buffers[256];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,valht ,INDICATOR_DATA);
         SetIndexBuffer(1,valhtc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valhr ,INDICATOR_DATA);
         SetIndexBuffer(3,valhrc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,val   ,INDICATOR_DATA);
         SetIndexBuffer(5,valc  ,INDICATOR_COLOR_INDEX);
            
         //
         //---
         //
            
         ushort _sep = StringGetCharacter(";",0); _handlesSize = 0;
         string _periods[]; int _periodsSize = StringSplit(inpMaPeriods,_sep,_periods);
         int    _periodi[];
                       for (int i=0; i<_periodsSize; i++)
                       {
                          int period = (int)StringToInteger(_periods[i]);
                          if (period>0)
                          {
                              int _size = ArraySize(_periodi); ArrayResize(_periodi,_size+1);
                                                                           _periodi[_size] = period;        
                          }                                          
                       }
                       ArraySort(_periodi);
                       _periodsSize = ArraySize(_periodi);
                       for (int i=0; i<_periodsSize; i++)
                       {
                           int period = _periodi[i];
                           int handle = iMA(NULL,0,period,0,inpMethod,inpPrice);
                           if (!_checkHandle(handle,"Average : "+(string)period)) return(INIT_FAILED);
                                       ArrayResize(_handles,_handlesSize+1); 
                                                   _handles[_handlesSize] = handle;
                                                             _handlesSize++;
                       }
         if (_handlesSize<2)   { Alert("Error : at least 2 averages must be specified"); _checkHandle(INVALID_HANDLE,"cleanig handles,"); return(INIT_FAILED); }
         if (_handlesSize>256) { Alert("Error : maximum 256 averages exceeded");         _checkHandle(INVALID_HANDLE,"cleanig handles,"); return(INIT_FAILED); }
               for (int i=0; i<_handlesSize; i++) SetIndexBuffer(i+6,_buffers[i].buffer,INDICATOR_CALCULATIONS);

   //
   //---
   //

       _maxPeriod = _periodi[_periodsSize-1];
      ª_alpha     = 2.0/(1.0+MathSqrt(inpSmooth>1 ? inpSmooth : 1));
            
   //
   //--- indicator short name assignment
   //

   IndicatorSetString(INDICATOR_SHORTNAME,StringSubstr(EnumToString(inpMethod),5)+" composite trend ("+string(inpSmooth>1 ? inpSmooth : 1)+")("+inpMaPeriods+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
      for (int i=0; i<_handlesSize; i++) if (CopyBuffer(_handles[i],0,0,_copyCount,_buffers[i].buffer)!=_copyCount) return(prev_calculated);
      
   //
   //---
   //
         
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
     double first = _buffers[0].buffer[i];
         double sum = 0;
            for (int k=1; k<_handlesSize; k++) sum += (first-_buffers[k].buffer[i]);
                                               sum /= (double)(_handlesSize-1);
            val[i] = (i>_maxPeriod) ? val[i-1] + ª_alpha*(sum-val[i-1]) : 0; ;
         
      //
      //---
      //
         
      int slope = (i>0) ? (val[i]>0) ? (val[i]>val[i-1]) ? 1 : 0 : (val[i]<val[i-1]) ? 1 : 0 : 0;
         valht[i]  = ( slope==1) ? val[i] : EMPTY_VALUE;
         valhr[i]  = ( slope==0) ? val[i] : EMPTY_VALUE;
         valc[i]   = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
         valhtc[i] = (val[i]>0) ? 1 : 2;
         valhrc[i] = (val[i]>0) ? 1 : 2;
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
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}
//------------------------------------------------------------------