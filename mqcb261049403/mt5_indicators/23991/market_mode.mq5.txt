//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Market mode"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3 2

//
//
//

input int                 inpPeriod    = 20;           // Period
input double              inpDelta     = 0.5;          // Delta
input double              inpFraction  = 0.1;          // Fraction 
input ENUM_APPLIED_PRICE  inpPrice     = PRICE_MEDIAN; // Price

double mode[],modec[],fractionUp[],fractionDn[];
double g_alpha,g_alphal,g_beta; int g_dPeriod;

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
         SetIndexBuffer(0,fractionUp);
         SetIndexBuffer(1,fractionDn);
         SetIndexBuffer(2,mode);
         SetIndexBuffer(3,modec,INDICATOR_COLOR_INDEX);
               
            double gamma     = 1.0 / MathCos(4.0*M_PI*inpDelta/inpPeriod);
                   g_beta    = MathCos(2.0*M_PI/inpPeriod);
                   g_alpha   = gamma -MathSqrt(gamma*gamma-1.0);
                   g_dPeriod = 2*inpPeriod;
   
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Market mode "+(string)inpPeriod+","+(string)inpDelta+","+(string)inpFraction+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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

struct sMarketModeStruct
{
   double price;
   double bandpass;
   double peak;
   double valey;
   double sumbp;
   double sumpeak;
   double sumvaley;
};
sMarketModeStruct m_array[];

//
//
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
   static int m_arraySize = -1;
          if (m_arraySize<rates_total)
          {
              m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
          }

   //
   //---
   //
                                    
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,m_array[i].price,i);
         if (i>1) 
         {
            m_array[i].bandpass = 0.5*(1.0-g_alpha)*(m_array[i].price-m_array[i-2].price)+g_beta*(1.0+g_alpha)*m_array[i-1].bandpass-g_alpha*m_array[i-2].bandpass;
            m_array[i].peak     = m_array[i-1].peak;
            m_array[i].valey    = m_array[i-1].valey;
                  if (m_array[i-1].bandpass>m_array[i].bandpass && m_array[i-1].bandpass>m_array[i-2].bandpass) m_array[i].peak  = m_array[i-1].bandpass;
                  if (m_array[i-1].bandpass<m_array[i].bandpass && m_array[i-1].bandpass<m_array[i-2].bandpass) m_array[i].valey = m_array[i-1].bandpass;
         }
         else m_array[i].peak = m_array[i].valey = m_array[i].bandpass = m_array[i].price;
         
         //
         //---
         //
            
         if (i>g_dPeriod)
                  m_array[i].sumbp = m_array[i-1].sumbp+m_array[i].bandpass-m_array[i-g_dPeriod].bandpass;
         else  {  m_array[i].sumbp = m_array[i].bandpass; for (int k=1; k<(g_dPeriod) && (i-k)>=0; k++) m_array[i].sumbp += m_array[i-k].bandpass; }
         if (i>50)
               {
                  m_array[i].sumpeak  = m_array[i-1].sumpeak  + m_array[i].peak  - m_array[i-50].peak;
                  m_array[i].sumvaley = m_array[i-1].sumvaley + m_array[i].valey - m_array[i-50].valey;
               }
         else
               {
                  m_array[i].sumpeak  = m_array[i].peak;
                  m_array[i].sumvaley = m_array[i].valey;
                  for (int k=1; k<50 && (i-k)>=0; k++)
                  {
                     m_array[i].sumpeak  += m_array[i-k].peak;
                     m_array[i].sumvaley += m_array[i-k].valey;
                  }
               }                                 
  
         //
         //---
         //
            
         fractionUp[i] = inpFraction*m_array[i].sumpeak /50.0;
         fractionDn[i] = inpFraction*m_array[i].sumvaley/50.0;
         mode[i]       = m_array[i].sumbp/(double)g_dPeriod;
         modec[i]      = (mode[i]>fractionUp[i]) ? 1 : (mode[i]<fractionDn[i]) ? 2 : 0;
   }               
   return(i);        
}