//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Schaff trend cycle - of CCI"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "Schaff trend cycle CCI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//-----------------
//

input int                inpPeriod       = 32;            // Schaff period
input int                inpCciPeriod    = 50;            // CCI period
input double             inpSmoothPeriod = 10;            // Smoothing period (<=1 for no smoothing)
input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Price

double val[],valc[],data[],stoch1[],stoch2[],stoch3[],ª_alpha;
int ª_cciHandle;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,data  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,stoch1,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,stoch2,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,stoch3,INDICATOR_CALCULATIONS);
            ª_alpha     = 2.0/(1.0+(inpSmoothPeriod>1?inpSmoothPeriod:1));         
            ª_cciHandle = iCCI(_Symbol,0,inpCciPeriod,inpPrice);          if (!_checkHandle(ª_cciHandle,"CCI"))    { return(INIT_FAILED); }
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Schaff trend cycle CCI ("+(string)inpPeriod+","+(string)inpCciPeriod+","+(string)inpSmoothPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_cciHandle,0,0,_copyCount,data)!=_copyCount) return(prev_calculated);
   
   //
   //
   //
   
   double hh,ll;
   int i=prev_calculated-1; if (i<0) i = 0; for(; i<rates_total && !_StopFlag; i++)
   {
      if (data[i]==EMPTY_VALUE) data[i] = 0;

         //
         //
         //

         static int _i=-1,_start=0; static double _lowData=0,_highData=0,_lowStoch=0,_highStoch=0;
            if (_i!=i && inpPeriod>1)
            {
                  _start    = i-inpPeriod+1; if (_start<0) _start = 0;
                  _lowData  = data[ArrayMinimum(data,_start,inpPeriod-1)];
                  _highData = data[ArrayMaximum(data,_start,inpPeriod-1)];
            }

                  ll        = (data[i]<_lowData)  ? data[i] : _lowData;
                  hh        = (data[i]>_highData) ? data[i] : _highData;
                  stoch1[i] = (hh>ll) ? 100.0*((data[i]-ll)/(hh-ll)) : (i>0) ? stoch1[i-1] : 0;
                  stoch2[i] = (i>0) ? stoch2[i-1]+ª_alpha*(stoch1[i]-stoch2[i-1]) : stoch1[i];

            if (_i!=i && inpPeriod>1)
            {
                  _lowStoch  = stoch2[ArrayMinimum(stoch2,_start,inpPeriod-1)];
                  _highStoch = stoch2[ArrayMaximum(stoch2,_start,inpPeriod-1)];
                  _i         = i;
            }

                  ll        = (stoch2[i]<_lowStoch)  ? stoch2[i] : _lowStoch;
                  hh        = (stoch2[i]>_highStoch) ? stoch2[i] : _highStoch;
                  stoch3[i] = (hh>ll) ? 100.0*((stoch2[i]-ll)/(hh-ll)) : (i>0) ? stoch3[i-1] : 0;

            //
            //
            //
                                 
            val[i]  = (i>0) ?  val[i-1]+ª_alpha*(stoch3[i]-val[i-1]) : stoch3[i];
            valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// custom functions
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
//------------------------------------------------------------------
