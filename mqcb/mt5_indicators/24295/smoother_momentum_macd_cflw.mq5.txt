//+------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Smoother momentum MACD"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
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
#property indicator_label4  "Smoother momentum MACD"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//--- input parameters
//
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onMiddle, // Change color on middle level cross
   cchange_onZero    // Change color on zero cross
};
input int                inpMomPeriodFast = 12;               // Fast momentum period
input int                inpMomPeriodSlow = 50;               // Slow momentum period
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE;     // Price
input int                inpFlPeriod      = 25;               // Floating levels period
input double             inpFlLevelUp     = 90;               // Floating levels up %
input double             inpFlLevelDn     = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange   = cchange_onLevels; // Color change type

//
//--- buffers and global variables declarations
//

double val[],valc[],levu[],levd[],levm[]; 

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
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   //         
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoother momentum MACD ("+(string)inpMomPeriodFast+","+(string)inpMomPeriodSlow+")("+(string)inpFlPeriod+")");
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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iSmoothMomentum(_price,inpMomPeriodSlow,i,0)-iSmoothMomentum(_price,inpMomPeriodFast,i,1);
            if (prev_i!=i)
            {
               prev_i = i; 
               int start    = i-inpFlPeriod+1; if (start<0) start=0;
                   prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                   prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
            }
            double max   = (val[i] > prev_max) ? val[i] : prev_max;
            double min   = (val[i] < prev_min) ? val[i] : prev_min;
            double range = (max-min)/100.0;

         levu[i] = min+inpFlLevelUp*range;
         levd[i] = min+inpFlLevelDn*range;
         levm[i] = min+          50*range;
   
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onMiddle : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0; break;
         }         
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