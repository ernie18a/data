//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Nonlinear Kalman filter with floating levels"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Nonlinear Kalman filter"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//---
//

enum enOrder
{
   ord_1=0, // First order (EMA)
   ord_2=1, // Second order
   ord_3=2, // Third order
};

input int                Length         = 14;           // Filter period 
input enOrder            Order          = ord_3;        // Filter order
input ENUM_APPLIED_PRICE Price          = PRICE_CLOSE;  // Price
input int                PreSmooth      = 3;            // Pre-smoothing period
input ENUM_MA_METHOD     PreSmoothMode  = MODE_LWMA;    // Pre-smoothing MA Mode
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],levu[],levd[],levm[],smoother[];
int ª_maHandle,ª_maPeriod;

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
         SetIndexBuffer(0,levu    ,INDICATOR_DATA);
         SetIndexBuffer(1,levm    ,INDICATOR_DATA);
         SetIndexBuffer(2,levd    ,INDICATOR_DATA);
         SetIndexBuffer(3,val     ,INDICATOR_DATA);
         SetIndexBuffer(4,valc    ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,smoother,INDICATOR_CALCULATIONS);
   //
   //---
   //         
   
   ª_maPeriod = (PreSmooth>0) ? PreSmooth : 1;
   ª_maHandle = iMA(_Symbol,0,ª_maPeriod,0,PreSmoothMode,Price); if (!_checkHandle(ª_maHandle,"Average")) { return(INIT_FAILED); }
   iKalman.init(Length,Order);
   return(0);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,smoother)!=_copyCount) return(prev_calculated);
         static int    prev_i=-1;
         static double prev_max,prev_min;

   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (smoother[i]==EMPTY_VALUE) smoother[i]=getPrice(Price,open,close,high,low,i);
      
      //
      //---
      //
      
      val[i]  = iKalman.calculate(smoother[i],i,rates_total);
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpFlPeriod+1; if (start<0) start=0;
                prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
         }
         double max = (val[i] > prev_max) ? val[i] : prev_max;
         double min = (val[i] < prev_min) ? val[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i] = min+inpFlLevelUp*range;
            levd[i] = min+inpFlLevelDn*range;
            levm[i] = (levu[i]+levd[i])/2;
         
         //
         //---
         //
         
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }
   return(i);
}

//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CNonLinearKalmanFilter
{
   private :
      int    m_period;
      int    m_order;
      int    m_arraySize;
      double m_a;
      double m_b;
      double m_c;
      struct sNonLinearKalmanFilterStruct
      {
         double lowpass;
         double delta;
      };
      sNonLinearKalmanFilterStruct m_array[];

   public :
      CNonLinearKalmanFilter() : m_period(1), m_order(0), m_arraySize(-1), m_a(0), m_b(0), m_c(0) { };
     ~CNonLinearKalmanFilter()                                                                    { ArrayFree(m_array); };
     
     //
     //
     //
     
     bool init(int period, int order)
     {
         m_period    = (period>0) ? period : 1;
         m_order     = order;
         m_arraySize = -1;
         switch(m_order)
         {
            case 0 :    m_a = 2.0/(1+m_period);
                        break;
            case 1 :    m_a = MathExp(-MathSqrt(2)*M_PI/m_period);
                        m_b = 2*m_a*MathCos(MathSqrt(2)*M_PI/m_period);
                        break;
            default :   m_a = MathExp(-M_PI/m_period);
                        m_b = 2*m_a*MathCos(MathSqrt(3)*M_PI/m_period);
                        m_c = MathExp(-2*M_PI/m_period);
         }
         return(true);
     }
     
     double calculate(double price, int i, int bars)
     {
         if (m_arraySize<bars)
         {
            m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0);
         }
         
         //
         //
         //
         
         double detrend = 0;
         switch(m_order)
         {
            case 0 :
                  if (i>0)
                  {
                     m_array[i].lowpass = (1-m_a)*m_array[i-1].lowpass + m_a*price;
                     detrend            = price - m_array[i].lowpass;
                     m_array[i].delta   = (1-m_a)*m_array[i-1].delta + m_a*detrend;
                  }
                  else { m_array[i].lowpass = price; m_array[i].delta = 0; }
                  break;
            case 1 :
                  if (i>1)
                  {
                     m_array[i].lowpass = m_b*m_array[i-1].lowpass - m_a*m_a*m_array[i-2].lowpass + (1-m_b+m_a*m_a)*price;
                     detrend            = price - m_array[i].lowpass;
                     m_array[i].delta   = m_b*m_array[i-1].delta - m_a*m_a*m_array[i-2].delta + (1-m_b+m_a*m_a)*detrend;
                  }
                  else { m_array[i].lowpass = price; m_array[i].delta = 0; }
                  break;
            default :
                  if (i>2)
                  {
                     m_array[i].lowpass = (m_b+m_c)*m_array[i-1].lowpass - (m_c+m_b*m_c)*m_array[i-2].lowpass + m_c*m_c*m_array[i-3].lowpass + (1-m_b+m_c)*(1-m_c)*price;
                     detrend            = price - m_array[i].lowpass;
                     m_array[i].delta   = (m_b+m_c)*m_array[i-1].delta - (m_c+m_b*m_c)*m_array[i-2].delta + m_c*m_c*m_array[i-3].delta + (1-m_b+m_c)*(1-m_c)*detrend;
                  }
                  else { m_array[i].lowpass = price; m_array[i].delta = 0; }
         }
         return(m_array[i].lowpass+m_array[i].delta);
     }
};
CNonLinearKalmanFilter iKalman;

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

//
//---
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T &open[], T &close[], T &high[], T &low[], int i)
{
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
}
//------------------------------------------------------------------
