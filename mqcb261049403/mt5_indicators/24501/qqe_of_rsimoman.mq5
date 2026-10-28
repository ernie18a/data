//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "QQE of Rsi(oma)"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "QQE fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "QQE slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_label3  "QQE"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width3  2
//
//--- input parameters
//
input int                inpRsiPeriod          = 14;         // RSI period
input int                inpMaPeriod           = 32;         // Average period
input ENUM_MA_METHOD     inpMaMethod           = MODE_EMA;   // Average method
input int                inpRsiSmoothingFactor =  5;         // RSI smoothing factor
input double             inpWPFast             = 2.618;      // Fast period
input double             inpWPSlow             = 4.236;      // Slow period
input ENUM_APPLIED_PRICE inpPrice=PRICE_CLOSE; // Price 
//
//--- buffers declarations
//

double val[],valc[],levs[],levf[],ema[],emm[],rsi[],_alphaS,_alphaR;
int  _rsiHandle,_maHandle,_rsiPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function                         
//------------------------------------------------------------------
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levf,INDICATOR_DATA);
         SetIndexBuffer(1,levs,INDICATOR_DATA);
         SetIndexBuffer(2,val ,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,ema ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,emm ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,rsi ,INDICATOR_CALCULATIONS);
            _rsiPeriod = (inpRsiPeriod>1) ? inpRsiPeriod : 1;
            _maHandle  = iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice);  if (!_checkHandle(_maHandle,"average")) return(INIT_FAILED);
            _rsiHandle = iRSI(_Symbol,0,_rsiPeriod,_maHandle);               if (!_checkHandle(_rsiHandle,"RSI"))    return(INIT_FAILED);
            _alphaS    = 2.0 / (1.0+ (inpRsiSmoothingFactor>1 ? inpRsiSmoothingFactor : 1));
            _alphaR    = 2.0 / (1.0+ _rsiPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"QQE ("+(string)inpRsiPeriod+","+(string)inpRsiSmoothingFactor+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
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
         if (CopyBuffer(_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsi[i] == EMPTY_VALUE) rsi[i] = 0;
      if (i>0) 
      {
         val[i] = val[i-1] + _alphaS*(rsi[i]-val[i-1]);
         
            //
            //---
            //
            
            double _diff = val[i-1]-val[i]; if (_diff<0) _diff = -_diff;
                  ema[i] = ema[i-1] + _alphaR*(_diff -ema[i-1]);
                  emm[i] = emm[i-1] + _alphaR*(ema[i]-emm[i-1]);
            double _iEmf = emm[i]*inpWPFast;
            double _iEms = emm[i]*inpWPSlow;
         
            //
            //---
            //
        
            {
               double tr = levs[i-1];
               double dv = tr;
               if(val[i] < tr) { tr = val[i] + _iEms; if((i>0 && val[i-1] < dv) && (tr > dv)) tr = dv; }
               if(val[i] > tr) { tr = val[i] - _iEms; if((i>0 && val[i-1] > dv) && (tr < dv)) tr = dv; }
                  levs[i]=tr;
            }
            {
               double tr = levf[i-1];
               double dv = tr;
               if(val[i] < tr) { tr = val[i] + _iEmf; if((i>0 && val[i-1] < dv) && (tr > dv)) tr = dv; }
               if(val[i] > tr) { tr = val[i] - _iEmf; if((i>0 && val[i-1] > dv) && (tr < dv)) tr = dv; }
                  levf[i]=tr;
            }
         }
         else val[i] = levf[i] = levs[i] = 0;            
      valc[i]=(val[i]>levf[i] && val[i]>levs[i]) ? 1 :(val[i]<levf[i] && val[i]<levs[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
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