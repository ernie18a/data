//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Hull quad"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   6
#property indicator_label1  "Hull 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Hull 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Hull 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Hull 4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Arrow up"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrDodgerBlue
#property indicator_width5  1
#property indicator_label6  "Arrow down"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrOrangeRed
#property indicator_width6  1

//
//--- input parameters
//

input int                inpPeriod1 =   8;         // Period 1
input int                inpPeriod2 =  55;         // Period 2
input int                inpPeriod3 = 144;         // Period 3
input int                inpPeriod4 = 377;         // Period 4
input double             inpDivisor = 2.0;         // Divisor ("speed")
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double hull1[],hull2[],hull3[],hull4[],arrowup[],arrowdn[],trend[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,hull1  ,INDICATOR_DATA);
         SetIndexBuffer(1,hull2  ,INDICATOR_DATA);
         SetIndexBuffer(2,hull3  ,INDICATOR_DATA);
         SetIndexBuffer(3,hull4  ,INDICATOR_DATA);
         SetIndexBuffer(4,arrowup,INDICATOR_DATA); PlotIndexSetInteger(4,PLOT_ARROW,241); PlotIndexSetInteger(4,PLOT_ARROW_SHIFT, 10);
         SetIndexBuffer(5,arrowdn,INDICATOR_DATA); PlotIndexSetInteger(5,PLOT_ARROW,242); PlotIndexSetInteger(5,PLOT_ARROW_SHIFT,-10);
         SetIndexBuffer(6,trend,INDICATOR_CALCULATIONS);
         
   //
   //--- indicator short name assignment
   //
         IndicatorSetString(INDICATOR_SHORTNAME,"Hull quad ("+(string)inpPeriod1+","+(string)inpPeriod2+","+(string)inpPeriod3+","+(string)inpPeriod4+","+")");
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
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
      hull1[i]   = iHull(_price,inpPeriod1,inpDivisor,i,rates_total,0);
      hull2[i]   = iHull(_price,inpPeriod2,inpDivisor,i,rates_total,1);
      hull3[i]   = iHull(_price,inpPeriod3,inpDivisor,i,rates_total,2);
      hull4[i]   = iHull(_price,inpPeriod4,inpDivisor,i,rates_total,3);
      arrowup[i] = EMPTY_VALUE;
      arrowdn[i] = EMPTY_VALUE;
      trend[i]   = 0;
            if (i>1)
            {
                  if (hull1[i]>hull4[i] && hull2[i]>hull4[i] && hull1[i]>hull1[i-1] && hull1[i]>hull1[i-2] && hull3[i]>hull3[i-1]) trend[i] =  1;
                  if (hull1[i]<hull4[i] && hull2[i]<hull4[i] && hull1[i]<hull1[i-1] && hull1[i]<hull1[i-2] && hull3[i]<hull3[i-1]) trend[i] = -1;
                  if (trend[i] != 0 && trend[i]!=trend[i-1])
                     if (trend[i]==1)
                           arrowup[i] = low[i];
                     else  arrowdn[i] = high[i];      
            }                     
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iHull(double price, int period, double divisor, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 4
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
