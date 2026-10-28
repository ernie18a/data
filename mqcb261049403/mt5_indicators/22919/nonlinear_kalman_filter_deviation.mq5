//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Deviation based on Ehlers nonlinear Kalman filter"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   1
#property indicator_label1  "Deviation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//---
//

enum enOrder
{
   ord_1, // First order (EMA)
   ord_2, // Second order
   ord_3, // Third order
};
input int                Length         = 14;           // Filter Period 
input enOrder            Order          =  ord_3;       // Filter Order
input ENUM_APPLIED_PRICE Price          = PRICE_CLOSE;  // Price
input int                PreSmooth      =  3;           // Pre-smoothing period
input ENUM_MA_METHOD     PreSmoothMode  = MODE_LWMA;    // Pre-smoothing MA method

//
//---
//

double val[],valc[],lowpass[],delta[],flt[],avg[],dev_diff[],dev_summ[];
double ª_a=0,ª_b=0,ª_c=0; int ª_maHandle;

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   ª_maHandle  = iMA(_Symbol,0,PreSmooth,0,PreSmoothMode,Price); if (!_checkHandle(ª_maHandle,"average")) { return(INIT_FAILED); }

   //
   //---
   //
   
      SetIndexBuffer(0,val     ,INDICATOR_DATA); 
      SetIndexBuffer(1,valc    ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(2,flt     ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,avg     ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(4,delta   ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(5,lowpass ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,dev_diff,INDICATOR_CALCULATIONS);
      SetIndexBuffer(7,dev_summ,INDICATOR_CALCULATIONS);

   //
   //---
   //
      
      switch(Order)
      {
         case ord_1 : ª_a = 2.0/(1+Length);      break;
         case ord_2 : ª_a = MathExp(-MathSqrt(2)*M_PI/Length);
                      ª_b = 2*ª_a*MathCos(MathSqrt(2)*M_PI/Length);  break;
         default :    ª_a=MathExp(-M_PI/Length);
                      ª_b = 2*ª_a*MathCos(MathSqrt(3)*M_PI/Length);
                      ª_c = MathExp(-2*M_PI/Length);
      }
   IndicatorSetString(INDICATOR_SHORTNAME,"NL Kalman filter deviation ("+(string)Length+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
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
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(Price,_price,i);
      if (avg[i]==EMPTY_VALUE) avg[i] = _price;
         #define _smoother avg[i]
         #define _detrend (_smoother - lowpass[i])
         switch(Order)
         {
            case ord_1 :
               lowpass[i] = (i>0) ? (1-ª_a)*lowpass[i-1] + ª_a*_smoother : _smoother;
               delta[i]   = (i>0) ? (1-ª_a)*delta[i-1] + ª_a*_detrend : 0;
               break;
            case ord_2 :
               lowpass[i] = (i>1) ? ª_b*lowpass[i-1] - ª_a*ª_a*lowpass[i-2] + (1-ª_b+ª_a*ª_a)*_smoother : _smoother;
               delta[i]   = (i>1) ? ª_b*delta[i-1] - ª_a*ª_a*delta[i-2] + (1-ª_b+ª_a*ª_a)*_detrend : 0;
               break;
            default :
               lowpass[i] = (i>2) ? (ª_b+ª_c)*lowpass[i-1] - (ª_c+ª_b*ª_c)*lowpass[i-2] + ª_c*ª_c*lowpass[i-3] + (1-ª_b+ª_c)*(1-ª_c)*_smoother : _smoother;
               delta[i]   = (i>2) ? (ª_b+ª_c)*delta[i-1] - (ª_c+ª_b*ª_c)*delta[i-2] + ª_c*ª_c*delta[i-3] + (1-ª_b+ª_c)*(1-ª_c)*_detrend : 0;
         }
      
         //
         //---
         //   
            
         flt[i] = lowpass[i]+delta[i];
         
            //
            //---
            //
               
                  dev_diff[i] = (_smoother-flt[i])*(_smoother-flt[i]);
                  if (i>Length)
                           dev_summ[i] = dev_summ[i-1]+dev_diff[i]-dev_diff[i-Length];
                  else  {  dev_summ[i] = dev_diff[i]; for(int k=1; k<Length && i>=k; k++) dev_summ[i] += dev_diff[i-k]; }
            
            //
            //---
            //

         val[i]  = MathSqrt(dev_summ[i]/Length);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 0 : 1 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
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
