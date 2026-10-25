//------------------------------------------------------------------
#property copyright   "Copyright 2017, mladen"
#property link        "mladenfx@gmail.com"
#property description "Schaff trend cycle - of Hull"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "Schaff trend cycle"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//-----------------
//

input int                inpSchaffPeriod = 32;          // Schaff period
input int                inpFastPeriod   = 23;          // Fast period
input int                inpSlowPeriod   = 50;          // Slow period
input double             inpSmoothPeriod = 1;           // Smoothing period (<=1 for no smoothing)
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price

double  val[],valc[],macd[],fastk1[],fastd1[],fastk2[], _alpha;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

void OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,macd  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,fastk1,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,fastk2,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,fastd1,INDICATOR_CALCULATIONS);
               _alpha=2.0/(1.0+(inpSmoothPeriod>1?inpSmoothPeriod:1));         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Schaff trend cycle Hull ("+(string)inpSchaffPeriod+","+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSmoothPeriod+")");
}

//------------------------------------------------------------------
//
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
   int i=prev_calculated-1; if (i<0) i = 0; for(; i<rates_total && !_StopFlag; i++)
   {
      double price; _setPrice(inpPrice,price,i);
      
      //
      //
      //
         
      macd[i] = iHull(price,inpFastPeriod,2.0,i,rates_total,0)-iHull(price,inpSlowPeriod,2.0,i,rates_total,1);
      
         int start = i-inpSchaffPeriod+1; if (start<0) start = 0;
         double lowMacd  = macd[ArrayMinimum(macd,start,inpSchaffPeriod)];
         double highMacd = macd[ArrayMaximum(macd,start,inpSchaffPeriod)]-lowMacd;
      
            fastk1[i] = (highMacd > 0) ? 100.0*((macd[i]-lowMacd)/highMacd) : (i>0) ? fastk1[i-1] : 0;
            fastd1[i] = (i>0) ? fastd1[i-1]+_alpha*(fastk1[i]-fastd1[i-1]) : fastk1[i];
      
         double lowStoch  = fastd1[ArrayMinimum(fastd1,start,inpSchaffPeriod)];
         double highStoch = fastd1[ArrayMaximum(fastd1,start,inpSchaffPeriod)]-lowStoch;
      
            fastk2[i] = (highStoch > 0) ? 100*((fastd1[i]-lowStoch)/highStoch) : (i>0) ? fastk2[i-1] : 0;
            val[i]    = (i>0) ?  val[i-1]+_alpha*(fastk2[i]-val[i-1]) : fastk2[i];
            valc[i]   = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
//
//
//
double iHull(double price, int period, double divisor, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 2
      struct sHullCoeffStruct
         {
            int    OriginalPeriod;
            double OriginalDivisor;
            int    FullPeriod;
            int    HalfPeriod;
            int    SqrtPeriod;
         };
      static sHullCoeffStruct m_coeff[_functionInstances];
      struct sHullArrayStruct
         {
            double price;
            double price3;
            double wsum1;
            double wsum2;
            double wsum3;
            double lsum1;
            double lsum2;
            double lsum3;
            double weight1;
            double weight2;
            double weight3;
         };
      static sHullArrayStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<=bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }
             if (m_coeff[¤].OriginalPeriod != period || m_coeff[¤].OriginalDivisor!=divisor)
             {
                  m_coeff[¤].OriginalPeriod  = period;
                  m_coeff[¤].OriginalDivisor = divisor;
                  m_coeff[¤].FullPeriod      = (int)(period>1 ? period : 1);   
                  m_coeff[¤].HalfPeriod      = (int)(m_coeff[¤].FullPeriod>1 ? m_coeff[¤].FullPeriod/(divisor>1 ? divisor : 1) : 1);
                  m_coeff[¤].SqrtPeriod      = (int) MathSqrt(m_coeff[¤].FullPeriod);
            }
            #define _pfull m_coeff[¤].FullPeriod
            #define _phalf m_coeff[¤].HalfPeriod
            #define _psqrt m_coeff[¤].SqrtPeriod
   
      //
      //---
      //

         m_array[i][¤].price=price;
         if (i>_pfull)
         {
            m_array[i][¤].weight1 = m_array[i-1][¤].weight1;
            m_array[i][¤].wsum1   = m_array[i-1][¤].wsum1+price*_phalf-m_array[i-1][¤].lsum1;
            m_array[i][¤].lsum1   = m_array[i-1][¤].lsum1+price-m_array[i-_phalf][¤].price;
            m_array[i][¤].weight2 = m_array[i-1][¤].weight2;
            m_array[i][¤].wsum2   = m_array[i-1][¤].wsum2+price*_pfull-m_array[i-1][¤].lsum2;
            m_array[i][¤].lsum2   = m_array[i-1][¤].lsum2+price-m_array[i-_pfull][¤].price;
         }
         else
         {
            m_array[i][¤].wsum1   = m_array[i][¤].wsum2   =
            m_array[i][¤].lsum1   = m_array[i][¤].lsum2   =
            m_array[i][¤].weight1 = m_array[i][¤].weight2 = 0;
            for(int k=0, w1=_phalf, w2=_pfull; w2>0 && i>=k; k++, w1--, w2--)
            {
               if (w1>0)
               {
                  m_array[i][¤].wsum1   += m_array[i-k][¤].price*w1;
                  m_array[i][¤].lsum1   += m_array[i-k][¤].price;
                  m_array[i][¤].weight1 += w1;
               }                  
               m_array[i][¤].wsum2   += m_array[i-k][¤].price*w2;
               m_array[i][¤].lsum2   += m_array[i-k][¤].price;
               m_array[i][¤].weight2 += w2;
            }
         }
         m_array[i][¤].price3=2.0*m_array[i][¤].wsum1/m_array[i][¤].weight1-m_array[i][¤].wsum2/m_array[i][¤].weight2;
         
         // 
         //---
         //
         
         if (i>_psqrt)
         {
            m_array[i][¤].weight3 = m_array[i-1][¤].weight3;
            m_array[i][¤].wsum3   = m_array[i-1][¤].wsum3+m_array[i][¤].price3*_psqrt-m_array[i-1][¤].lsum3;
            m_array[i][¤].lsum3   = m_array[i-1][¤].lsum3+m_array[i][¤].price3-m_array[i-_psqrt][¤].price3;
         }
         else
         {
            m_array[i][¤].wsum3   =
            m_array[i][¤].lsum3   =
            m_array[i][¤].weight3 = 0;
            for(int k=0, w3=_psqrt; w3>0 && i>=k; k++, w3--)
            {
               m_array[i][¤].wsum3   += m_array[i-k][¤].price3*w3;
               m_array[i][¤].lsum3   += m_array[i-k][¤].price3;
               m_array[i][¤].weight3 += w3;
            }
         }         
      return(m_array[i][¤].wsum3/m_array[i][¤].weight3);

   //
   //---
   //
            
   #undef ¤ #undef _pfull  #undef _phalf #undef _psqrt #undef _functionInstances
}
//------------------------------------------------------------------
