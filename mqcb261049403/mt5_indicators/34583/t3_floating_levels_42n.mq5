//------------------------------------------------------------------
#property copyright   "©mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "This T3 uses two methods for calculating T3"
#property description " "
#property description "    1 - The original Tim Tillson way"
#property description "    2 - The modified Bob Fulks / Alex Matulich way"
#property description " "
#property description "Modified version is a bit 'faster' in response to price changes"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "T3 zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "T3 middle"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrGray
#property indicator_label3  "T3"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width3  3

//
//
//

input double             T3Period        = 25;             // T3 period
input double             T3Hot           = 0.7;            // T3 volume factor
   enum enT3Type
   {
      t3_tillson  = (int)true,  // Tim Tillson way of calculation
      t3_fulksmat = int(false), // Fulks/Matulich way of calculation
   };
input enT3Type           T3Original      = t3_fulksmat;    // T3 calculation mode
input ENUM_APPLIED_PRICE T3Price         = PRICE_CLOSE;    // Average price
      enum chgColor
         {
            chg_onSlope,  // change color on slope change
            chg_onLevel,  // Change color on outer levels cross
            chg_onMiddle  // Change color on middle level cross
         };
input chgColor           ColorOn         = chg_onLevel;    // Color change on :
input int                FlPeriod        = 25;             // Period for finding floating levels
input double             FlUp            = 90;             // Upper level %
input double             FlDown          = 10;             // Lower level %

//
//
//

double t3[],t3c[],mid[],fup[],fdn[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fup,INDICATOR_DATA);
   SetIndexBuffer(1,fdn,INDICATOR_DATA);
   SetIndexBuffer(2,mid,INDICATOR_DATA);
   SetIndexBuffer(3,t3 ,INDICATOR_DATA);
   SetIndexBuffer(4,t3c,INDICATOR_COLOR_INDEX);
   
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,"T3 floating levels ("+(string)T3Period+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

#define _setPrice(_priceType,_target,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE    : _target = close[_index];                                              break; \
      case PRICE_OPEN     : _target = open[_index];                                               break; \
      case PRICE_HIGH     : _target = high[_index];                                               break; \
      case PRICE_LOW      : _target = low[_index];                                                break; \
      case PRICE_MEDIAN   : _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL  : _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED : _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{ 
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //
   
   for(int i=limit; i<rates_total && !_StopFlag; i++)
   {
      double price; _setPrice(T3Price,price,i);
         
         //
         //
         //
                  
            t3[i] = iT3(price,T3Period,T3Hot,T3Original,i,rates_total);
            int _start = i-FlPeriod+1; if (_start<0) _start=0;
            
            double hi = t3[ArrayMaximum(t3,_start,FlPeriod)];
            double lo = t3[ArrayMinimum(t3,_start,FlPeriod)];
            double rn = hi-lo;
               fup[i] = lo+rn*FlUp  /100.0;
               fdn[i] = lo+rn*FlDown/100.0;
               mid[i] = (fup[i]+fdn[i])/2;
               switch (ColorOn)
               {
                  case chg_onLevel :  t3c[i] = (t3[i]>fup[i]) ? 1 : (t3[i]<fdn[i]) ? 2 : 0; break;
                  case chg_onMiddle : t3c[i] = (t3[i]>mid[i]) ? 1 : (t3[i]<mid[i]) ? 2 : 0; break;
                  default :           t3c[i] = (i>0) ? (t3[i]>t3[i-1]) ? 1 : (t3[i]<t3[i-1]) ? 2 : 0 : 0;
               }                  
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

#define _maInstances 1
double iT3(double value, double period, double volumeFactor, bool original, int r, int bars, int instanceNo=0)
{
   struct sCoeffStruct
         {
            double volumeFactor;
            double volumePlus;
            double period;
            double alpha;
            double result;
            bool   original;
               sCoeffStruct() : period(EMPTY_VALUE) {}
         };
   static sCoeffStruct m_coeffs[_maInstances];
   struct sDataStruct
         {
            double val[7];
         };
   struct sWorkStruct { sDataStruct data[_maInstances]; };
   static sWorkStruct m_array[];
   static int         m_arraySize = -1;
                  if (m_arraySize<=bars) m_arraySize = ArrayResize(m_array,bars+500,2000);
                  if (m_coeffs[instanceNo].period       != (period)  ||
                      m_coeffs[instanceNo].volumeFactor != volumeFactor)
                      {
                        m_coeffs[instanceNo].period       = (period > 1) ? period : 1;
                        m_coeffs[instanceNo].alpha        = (original) ? 2.0/(1.0+m_coeffs[instanceNo].period) : 2.0/(2.0+(m_coeffs[instanceNo].period-1.0)/2.0);
                        m_coeffs[instanceNo].volumeFactor = (volumeFactor>0) ? (volumeFactor>1) ? 1 : volumeFactor : DBL_MIN;
                        m_coeffs[instanceNo].volumePlus   = (volumeFactor+1);
                      }

      //
      //
      //

         if (r>0)
         {
               #define _gdema(_part1,_part2) (m_array[r].data[instanceNo].val[_part1]*m_coeffs[instanceNo].volumePlus - m_array[r].data[instanceNo].val[_part2]*m_coeffs[instanceNo].volumeFactor)
                     m_array[r].data[instanceNo].val[0] = m_array[r-1].data[instanceNo].val[0]+m_coeffs[instanceNo].alpha*(value                             -m_array[r-1].data[instanceNo].val[0]);
                     m_array[r].data[instanceNo].val[1] = m_array[r-1].data[instanceNo].val[1]+m_coeffs[instanceNo].alpha*(m_array[r].data[instanceNo].val[0]-m_array[r-1].data[instanceNo].val[1]);
                     m_array[r].data[instanceNo].val[2] = m_array[r-1].data[instanceNo].val[2]+m_coeffs[instanceNo].alpha*(_gdema(0,1)                       -m_array[r-1].data[instanceNo].val[2]);
                     m_array[r].data[instanceNo].val[3] = m_array[r-1].data[instanceNo].val[3]+m_coeffs[instanceNo].alpha*(m_array[r].data[instanceNo].val[2]-m_array[r-1].data[instanceNo].val[3]);
                     m_array[r].data[instanceNo].val[4] = m_array[r-1].data[instanceNo].val[4]+m_coeffs[instanceNo].alpha*(_gdema(2,3)                       -m_array[r-1].data[instanceNo].val[4]);
                     m_array[r].data[instanceNo].val[5] = m_array[r-1].data[instanceNo].val[5]+m_coeffs[instanceNo].alpha*(m_array[r].data[instanceNo].val[4]-m_array[r-1].data[instanceNo].val[5]);
                     m_array[r].data[instanceNo].val[6] =                             _gdema(4,5);
               #undef _gdema
         }
         else   ArrayInitialize(m_array[r].data[instanceNo].val,value);
         return(m_array[r].data[instanceNo].val[6]);
}