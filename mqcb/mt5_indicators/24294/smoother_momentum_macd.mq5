//+------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Smoother momentum MACD"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Smoother momentum MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2

//
//--- input parameters
//

input int                inpMomPeriodFast = 12;           // Fast momentum period
input int                inpMomPeriodSlow = 50;           // Slow momentum period
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE; // Price

//
//--- buffers and global variables declarations
//

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//---
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //         
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoother momentum MACD ("+(string)inpMomPeriodFast+","+(string)inpMomPeriodSlow+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//


#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iSmoothMomentum(_price,inpMomPeriodSlow,i,0)-iSmoothMomentum(_price,inpMomPeriodFast,i,1);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//


double iSmoothMomentum(double price, double period, int i, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 2
   #define _functionRingSize 32
  
      class cSmoothEmaMomentumCoeffs
      {
         public : 
            double period;
            double alphaRegular;
            double alphaDouble;
         
            //
            //---
            //
            
            cSmoothEmaMomentumCoeffs() { period=DBL_EPSILON; }
           ~cSmoothEmaMomentumCoeffs() {}
      };
      struct sSmoothEmaMomentumArray
      {
         double ema;
         double ema21;
         double ema22;
      };
      static cSmoothEmaMomentumCoeffs m_coeffs[_functionInstances];
      static sSmoothEmaMomentumArray  m_array[_functionRingSize][_functionInstances];
             if (m_coeffs[¤].period!=period)
             {
               double _period = (period>1) ? period : 1;
                  m_coeffs[¤].period       = period;
                  m_coeffs[¤].alphaRegular = 2.0/(1.0+_period);
                  m_coeffs[¤].alphaDouble  = 2.0/(1.0+MathSqrt(_period));
             }
   
   //
   //---
   //
   
   int _indC = (i)%_functionRingSize;
   if(i>0)
   {
      int _indP = _indC-1; if (_indP<0) _indP += _functionRingSize;
         #define alphar m_coeffs[¤].alphaRegular
         #define alphad m_coeffs[¤].alphaDouble
      
            m_array[_indC][¤].ema   = m_array[_indP][¤].ema  +alphar*(price                  -m_array[_indP][¤].ema  );
            m_array[_indC][¤].ema21 = m_array[_indP][¤].ema21+alphad*(price                  -m_array[_indP][¤].ema21);
            m_array[_indC][¤].ema22 = m_array[_indP][¤].ema22+alphad*(m_array[_indC][¤].ema21-m_array[_indP][¤].ema22);
            
         #undef alphad #undef alphar            
     }
   else   m_array[_indC][¤].ema = m_array[_indC][¤].ema21 = m_array[_indC][¤].ema22 = price;
   return(m_array[_indC][¤].ema22-m_array[_indC][¤].ema);
   
   //
   //---
   //
   
   #undef ¤ #undef _functionInstances #undef _functionRingSize  
}
//------------------------------------------------------------------