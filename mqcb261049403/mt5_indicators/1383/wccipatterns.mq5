//+------------------------------------------------------------------+
//|                                                 WcciPatterns.mq5 |
//|                                   Copyright © 2009, Yuri Ershtad |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuri Ershtad"
#property link      ""
#property description "The Woodies CCI Paterns indicator"
#property description "Detailed description of the indicator work is in the code of this indicator!!!"
#property description "The indicator signals identified by numbers from 1 to 8;"
#property description "the green color palette is used for the uptrend trading signals,"
#property description "the red for the downtrend, the blue for the TLB and HTLB;"

//---- drawing the indicator in the main window
#property indicator_chart_window
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- ten buffers are used for calculation and drawing the indicator
#property indicator_buffers 10
//---- 8 graphical plots are used
#property indicator_plots   8
//+----------------------------------------------+
//| Indicators drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicators as labels
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_type5   DRAW_ARROW
#property indicator_type6   DRAW_ARROW
#property indicator_type7   DRAW_ARROW
#property indicator_type8   DRAW_ARROW
//---- the following colors are used for the indicators
#property indicator_color1 clrMediumSeaGreen
#property indicator_color2 clrOrangeRed
#property indicator_color3 clrDeepSkyBlue
#property indicator_color4 clrIndianRed
#property indicator_color5 clrTomato
#property indicator_color6 clrLimeGreen
#property indicator_color7 clrCoral
#property indicator_color8 clrRed
//---- width of the indicator lines
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property indicator_width8  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Zero-line Reject (ZLR), trend"
#property indicator_label2  "Shamu Trade, counter-trend"
#property indicator_label3  "Trend Line Break (TLB), both"
#property indicator_label4  "Vegas Trade (VT), counter-trend"
#property indicator_label5  "Ghost Trade, counter-trend"
#property indicator_label6  "Reverse Divergence, trend"
#property indicator_label7  "Hook from Extremes (HFE), counter-trend"
#property indicator_label8  "Exit signal"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint fastPeriod=6;
input uint slowPeriod=14;
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ZlrBuffer[];     // 1. Zero-line Reject (ZLR)      -- trend
double ShamuBuffer[];   // 2. Shamu Trade                 -- counter
double TlbBuffer[];     // 3. Trend Line Break (TLB/HTLB) -- both
double VegasBuffer[];   // 4. Vegas Trade (VT)			         -- counter
double GhostBuffer[];   // 5. Ghost Trade                 -- counter
double RevdevBuffer[];  // 6. Reverse Divergence          -- trend
double HooksBuffer[];   // 7. Hook from Extremes (HFE)    -- counter
double ExitBuffer[];    // 8. Exit signals
double FCCIBuffer[];    // 9. Буфер для быстрого CCI
double SCCIBuffer[];    // 10. Буфер для медленного CCI
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int FCCI_Handle,SCCI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(fastPeriod,slowPeriod)+20);

//---- getting handle of the iCCI fast indicator
   FCCI_Handle=iCCI(NULL,0,fastPeriod,PRICE_CLOSE);
   if(FCCI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iCCI fast indicator");

//---- getting handle of the iCCI slow indicator
   SCCI_Handle=iCCI(NULL,0,slowPeriod,PRICE_CLOSE);
   if(SCCI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iCCI slow indicator");

//---- initialization of indicators
   IndicatorInit(0,Shift,min_rates_total,EMPTY_VALUE,140,ZlrBuffer);
   IndicatorInit(1,Shift,min_rates_total,EMPTY_VALUE,141,ShamuBuffer);
   IndicatorInit(2,Shift,min_rates_total,EMPTY_VALUE,142,TlbBuffer);
   IndicatorInit(3,Shift,min_rates_total,EMPTY_VALUE,143,VegasBuffer);
   IndicatorInit(4,Shift,min_rates_total,EMPTY_VALUE,144,GhostBuffer);
   IndicatorInit(5,Shift,min_rates_total,EMPTY_VALUE,145,RevdevBuffer);
   IndicatorInit(6,Shift,min_rates_total,EMPTY_VALUE,146,HooksBuffer);
   IndicatorInit(7,Shift,min_rates_total,EMPTY_VALUE,251,ExitBuffer);

//---- set dynamic array as a data buffer
   SetIndexBuffer(8,FCCIBuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(FCCIBuffer,true);

//---- set dynamic array as a data buffer
   SetIndexBuffer(9,SCCIBuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SCCIBuffer,true);

   string short_name="Woodies CCI Paterns ("+
                     string(fastPeriod)+","+string(slowPeriod)+","+string(Shift)+")";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//|  Indicator initialization                                        |
//+------------------------------------------------------------------+
void IndicatorInit
(
 uint   number,
 int    shift,
 uint   drawbegin,
 double empty_value,
 uint   arrow,
 double &Arrow[]
 )
//---- 
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(number,Arrow,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(number,PLOT_SHIFT,shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(number,PLOT_DRAW_BEGIN,drawbegin);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(number,PLOT_ARROW,arrow);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(Arrow,true);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the calculation of indicator
                const double& Low[],      // price array of minimums of price for the calculation of indicator
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(SCCI_Handle)<rates_total
      || BarsCalculated(FCCI_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

//---- declaration of local variables 
   int to_copy,limit,bar;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total;                 // calculated number of all bars
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated; // calculated number of new bars only
      limit=rates_total-prev_calculated;   // starting index for calculation of new bars
     }

//---- copy newly appeared data into the arrays
   if(CopyBuffer(FCCI_Handle,0,0,to_copy,FCCIBuffer)<=0) return(RESET);
   if(CopyBuffer(SCCI_Handle,0,0,to_copy,SCCIBuffer)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //----	Filling array of points and detection of trend
      int delta=25;
      int level=100;
      double slowCCI[20];
      double fastCCI[20];
      int up=0;
      int dn=0;
      int upnt=5;
      int dpnt=5;

      ArrayCopy(fastCCI,FCCIBuffer,0,bar,20);
      ArrayCopy(slowCCI,SCCIBuffer,0,bar,20);

      for(int a=0; a<9; a++)
        {
         if(slowCCI[a]>0) up++;
         else dn++;
        }

/*
      * Pattern № 1 - Rebound from zero line (ZLR)
      * -----------------------------------------------------------
      * Pattern "Rebound from zero line" (ZLR)" is a
      * strong rebound of CCI from the zero line (ZL) or from a level,
      * located close to it. Herewith the CCI can rebound from the
      * values in the range from +100 to -100  for the long,
      * and short positions. Some traders like to narrow
      * the range to +/-50, considering that it can provide the best
      * rebound. The position opens on the first bar, which deviates
      * or rebounds from the zero line.
      * The market psychology of the ZLR pattern using by the
      * Woodies CCI system is that this pattern allows
      * to buy on the falling and sell on the rise. None of the
      * indicators (used in trading) can not do this,
      * except CCI.
      * For greater efficiency, to enhance the input signal,
      * You can join the ZLR pattern with the
      * "Trend Line Breakthrough (TLB)" pattern. When used the ZLR with
      * TLB to open a position You waiting the intersection of the CCI
      * and the TLB pattern. The traiding using the
      * ZLR pattern - trading by trend. In fact, this type of trading
      * can be be the only trading pattern of Woodies CCI system
      * which used by trader and brings the excellent
      * profit.
      */

      delta=20;  // filter (|ССI[1]-ССI[2]|>delta)
      level=80; // module of pattern boundaries
      ZlrBuffer[bar]=EMPTY_VALUE;
      // ---- ZLR in downtrend
      if(dn>=6 && 
         slowCCI[0]<slowCCI[1] && slowCCI[2]<slowCCI[1] && 
         MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level && 
         MathAbs(slowCCI[1]-slowCCI[2])>delta)
        {
         ZlrBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }
      //---- ZLR in uptrend
      if(up>=6
         && slowCCI[0]>slowCCI[1] && slowCCI[2]>slowCCI[1] && 
         MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level && 
         MathAbs(slowCCI[1]-slowCCI[2])>delta)
        {
         ZlrBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }

/*
      * Pattern № 2 - Shamu (shamu trade)
      * -----------------------------------------------------------
      * The "Shamu (shamu trade)" pattern is formed when the CCI crosses
      * the zero line (ZL), then turns back and again
      * crosses the zero line (ZL) in the opposite direction,
      * and finally turns and crosses the zero line
      * continuing to move in the initial direction.
      * This is the kind of zigzag pattern around the ZL.
      * It does not necessarily arise directly on the zero line,
      * but the best Shamu patterns are formed when the
      * the CCI zigzag in the range of +/-50.
      * The Shamu trading pattern is an unsuccessful ZLR pattern.
      *  Initially, it was a ZLR pattern. But the ZLR turned in
      * the opposite direction and was not formed, so that we
      * must out of the market. Therefore you do not expect a reversal in the hope
      * that the trade come back in the right direction. If in all of these trade
      * cases You initially open position by the ZLR pattern,
      * that you are responsible, and if You did not come out of trade, You can incur
      * a potentially large losses.
      * Trading with the Shamu pattern is a
      * contr-trend trading, which was developed as a way to trade on the basis of
      * stop-and-reverse (SAR) to the unsuccessful ZLR. Beginners, who
      * began to study the Woodies CCI system,should not use
      * this type of trading. However, pay attention to it and
      * learn as you progress in the system development.
      */

      delta=15; level=50;
      ShamuBuffer[bar]=EMPTY_VALUE;
      //---- Shamu in the downtrend
      if(dn>=6 && 
         slowCCI[0]>slowCCI[1]+delta && 
         slowCCI[1]<slowCCI[2] && slowCCI[2]>slowCCI[3] && 
         slowCCI[1]<=level && slowCCI[1]>=-level &&
         slowCCI[2]<=level && slowCCI[2]>=-level)
        {
         ShamuBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }
      //---- Shamu in the uptrend
      if(up>=6 && 
         slowCCI[0]<slowCCI[1]-delta && 
         slowCCI[1]>slowCCI[2] && slowCCI[2]<slowCCI[3] && 
         slowCCI[1]>=-level && slowCCI[1]<=level &&
         slowCCI[2]>=-level && slowCCI[2]<=level)
        {
         ShamuBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }

/*
      * Pattern № 3 - Trend Line Breakthrough (TLB)
      * -----------------------------------------------------------
      * The "Trend Line Breakthrough (TLB)" uses two or more
      * peaks and cavities formed by the CCI or TCCI
      * to build the trendline on them. When the CCI
      * crossing or breakthrough this trend line (tl), there is a signal to
      * open position. Herewith, that the signal to be valid,
      * the one end of the trend line should be placed at the level of +/-100
      * CCI or more. The more points of contact has a trend line,
      * the more important it is. Using only two points
      * of contact is normal and creates a well-run
      * TLB pattern. It is also possible to joint use of the
      * CCI and TCCI contact for the each trend line. This pattern is also used
      * as a one of the output signals or as a CCI confirmation signal.
      * This is very convenient and widely used in the Woodies CCI system.
      * Trading with the TLB pattern can be carried
      * by trend and contr-trend. Beginners, who utilizing
      * the Woodies CCI system, should trade with the TLB pattern only by
      * trend. However take a closer look to it and study as
      * You progress in the system development.
      * You can join the using of "Zero Line
      * Rebound (ZLR)" and "Reverse Divergence (rev diver)" patterns
      * with the "Trend Line Breakthrough (TLB)" pattern to enhance the signal and
      * get the greater probability of success. At their sharing You
      * open a position at the trend line breakthrough, because it
      * happens in the last turn.
      * Another method to entry in trade by the TLB is using
      * of the CCI confirmation signal - its intersection of the +/-100 level.
      * In this case the deal success chance is greater. If you not use
      * this method you also can get a big profit when trading
      * by the TLB, if You enter the market before this level. However, if you
      * do not add the confirmation of the CCI as it crosses the level of +/-100,
      * then you trading by TLB can often not work. Choose
      * the input method and stick with it. Do not change it daily.
      * You'll notice that the TLB and ZLR patterns often occur
      * together. Sometimes together with them will also appear the "rev diver" pattern.
      * You must be able to distinguish, when the CCI patterns follow one another
      * and when formed together, that amplifies the signals. Let this not confuse
      * You. You need only one CCI pattern to open a position.
      * However, if there is a combination of multiple signals, the success probability
      * of this deal is growing.
      * -----------------------------------------------------------
      * Horizontal Trend Line Breakthrough (HTLB)
      * -----------------------------------------------------------
      * When trading on the horizontal trend line breakthrough (HTLB) -
      * the trend line is drawn horizontally across the top of the
      * CCI and TCCI rebounds from the zero horizontal line, which are built
      * into a nice straight row. But the CCI is used more often in 
      * this patterns.
      * The trend line can be built using the input or output points
      * on either side of the zero line. However, all of this point
      * must be located on one side of the zero line. The best
      * result can be achieved in the horizontal trend line
      * breakthrough, located in the range of +/-50.
      * In an ideal variant the horizontal trend line is built by three or more points 
      * , but can also be built by the two points.
      * Each point shift on the same horizontal level shows
      * that the support or resistance zone is located
      * in this area. If there is a breakthrough of this line, then we can expect
      * the strong movement and a good profit. This pattern is often
      * can be found on the consolidating market.
      * The trading on the horizontal trend line breakthrough can be conducted
      * by trend and contr-trend. The exit signals are the same
      * as with any other type of trade.
      */

      delta=25; level=100;
      //---- ----
      TlbBuffer[bar]=EMPTY_VALUE;
      double min1=0,min2=0,min3=0,max1=0,max2=0,max3=0;       // min/max values
      datetime tmin1=0,tmin2=0,tmin3=0,tmax1=0,tmax2=0,tmax3=0; // min/max time
      double kmin=0,kmax=0;// linear coefficient
      double line;
      //----	Definition of the min/max and construction of the trend line
      for(int a=0; a<18; a++)
        {
         //---- definition of maximums
         if(slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
           {
            if(max1!=0 && max2==0)
              {
               max2=slowCCI[a+1];
               tmax2=Time[a+1+bar];
               kmax=100*(max2-max1)/(tmax2-tmax1);
              }
            if(max1==0)
              {
               max1=slowCCI[a+1];
               tmax1=Time[a+1+bar];
              }
           }
         //---- definition of minimums
         if(slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
           {
            if(min1!=0 && min2==0)
              {
               min2=slowCCI[a+1];
               tmin2=Time[a+1+bar];
               kmin=100*(min2-min1)/(tmin2-tmin1);
              }
            if(min1==0)
              {
               min1=slowCCI[a+1];
               tmin1=Time[a+1+bar];
              }
           }
        }
      //---- TLB ctr in downtrend
      if(kmax!=0 && dn>=6 && (max1<-level || max2<-level))
        {
         line=(Time[bar]-tmax1)*kmax/100+max1;
         if(slowCCI[1]<line && slowCCI[0]>=line)
           {
            TlbBuffer[bar]=Low[bar]-dpnt*_Point;
            dpnt+=5;
           }
        }
      //----  TLB ctr in uptrend
      if(kmin!=0 && up>=6 && (min1>level || min2>level))
        {
         line=(Time[bar]-tmin1)*kmin/100+min1;
         if(slowCCI[1]>line && slowCCI[0]<=line)
           {
            TlbBuffer[bar]=High[bar]+upnt*_Point;
            upnt+=5;
           }
        }
      //---- TLB tr in downtrend
      if(kmin!=0 && dn>=6 && (min1<-level || min2<-level))
        {
         line=(Time[bar]-tmin1)*kmin/100+min1;
         if(slowCCI[1]>line && slowCCI[0]<line)
           {
            TlbBuffer[bar]=High[bar]+upnt*_Point;
            upnt=+5;
           }
        }
      //----  TLB tr in uptrend
      if(kmax!=0 && up>=6 && (max1>level || max2>level))
        {
         line=(Time[bar]-tmax1)*kmax/100+max1;
         if(slowCCI[1]<line && slowCCI[0]>line)
           {
            TlbBuffer[bar]=Low[bar]-dpnt*_Point;
            dpnt=+5;
           }
        }
/*
      * Pattern № 4 - Vegas (VT)
      * -----------------------------------------------------------
      * The Vegas (VT) pattern is a combination of several things.
      * First, there must be a CCI pattern "Hook from Extremes (HFE)",
      * and thereafter the set of CCI bars should be appear in the form of partially
      * rounded or circular pattern. Such round bars must
      * be at least 3 burs in the direction to the zero line or from it.
      * In other words, the rounding may be in any direction
      * depending on what side of the zero line (ZL) the input
      * pattern is formed. However, the VT input pattern should be formed
      * only on one side of the zero line. This means that the first
      * part (from CCI hook) of the high/low pattern oscillation is not the rounded
      * part of pattern. The more stronger signal occurs, when the oscillation
      * of high/low pattern becomes as a rounded part. Also, the pattern can
      * can have a several high/low oscillations. The rounding is very important for
      * the pattern in general and points to the struggle, which could well lead
      * to a strong trend reversal.
      * The last part of the pattern is a trend line which passing through
      * the top or bottom of the recent oscillation. The up or down breakthrough of this level is
      * our entry in trading.
      * ----
      * Usually the full "Vegas (VT)" pattern is formed somewhere in the period
      * from 8 to 12 bars and more, but if it becomes too large before
      * the entry signal, then the success probability decreases, and the power
      * of movement may be reduced. The "Vegas (VT)" pattern indicates
      * the opportunity of potential very strong changing of trend.
      * Woodie strongly recommends using the 25-lsma indicator
      * as an additional criterion of entry by the "Vegas (VT)" pattern.
      * When the 25-lsma indicator shows that the price located on the side
      * of the direction of entry by the "Vegas (VT)" pattern, there is a large
      * probability that the trading will be success. The LSMA
      * moving average (Least Squares Moving Average),
      * can be found in some
      * graphic packages with name as "Linear Regression Curve"
      * (Linear Regression Curve).
      * In other words, if the "Vegas (VT)" pattern is formed for
      * the buy entry, it is necessary that the price will be higher than the 25-lsma indicator
      * and, if possible, that the 25-lsma also will be upwards. If pattern
      * VT is formed for the sell entry, it is necessary that the price will be
      * lower than the 25-lsma and, if possible, that the 25-lsma also will be downwards.
      * We do not use the prices to trade in Woodies CCI,
      * so it is recommended to display only the 25-lsma indicator on the price chart.
      * And even better to use the 25-lsma indicator with the CCI on the same
      * chart to show these four conditions using a separate color.
      * The trading using the "Vegas" pattern in fact is a
      * contr-trend trading.
      */

      delta=10; limit=200;
      //---- ----
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      VegasBuffer[bar]=EMPTY_VALUE;
      //---- points definition
      if(dn>=6)
        {
         for(int a=13; a>=1; a--)
           {
            if(slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
               min1!=0 && max1==0)
              {
               max1=slowCCI[a+1];
               tmax1=a+1;
              }
            if(slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] && 
               min1==0 && slowCCI[a+1]<=-limit && a+1>=5)
              {
               min1=slowCCI[a+1];
               tmin1=a+1;
              }
           }
        }
      //----  Points definition.
      if(up>=6)
        {
         for(int a=13; a>=1; a--)
           {
            if(slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] && 
               min2!=0 && max2==0)
              {
               min2=slowCCI[a+1];
               tmin2=a+1;
              }
            if(slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
               max2==0 && slowCCI[a+1]>=limit && a+1>=5)
              {
               max2=slowCCI[a+1];
               tmax2=a+1;
              }
           }
        }
      //---- Vegas in the downtrend
      if(dn>=6 && max1!=0 && slowCCI[1]<max1 && slowCCI[0]>=max1 && 
         slowCCI[0]-delta>slowCCI[1]/* && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>slowCCI[2]) */)
        {
         VegasBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }
      //----  Vegas in the uptrend
      if(up>=6 && min2!=0 && slowCCI[1]>min2 && slowCCI[0]<=min2 && 
         slowCCI[0]+delta<slowCCI[1]
         /* && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<slowCCI[2]) */)
        {
         VegasBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }
/*
      * Pattern № 5 - Ghost (Ghost)
      * -----------------------------------------------------------
      * The "Ghost" pattern is formed by 3 vertex, which are sequentially
      * forms: one arm, head and then the other arm. (Probably,
      * more precise to say: "Head and shoulders"). This figures can be
      * formed by CCI or TCCI. However, most
      * of the traders use the CCI to determine this pattern.
      * It's desirable that the head will be more than the shoulders. To determine the
      * entry points by the bottom points of the "Ghost" pattern (neck line)
      * the trend line is build.
      * You can calculate the expected movement of the CCI for the "Ghost" pattern
      * measuring the distance from the head top to the neck line, and it will
      * be equal to the distance from the neck line to the head in the opposite
      * direction. In general it is not necessary to calculate the possible
      * potential movement of CCI from the neck line, because You should
      * close the position as soon as the CCI will give a signal to the output. All,
      * what do you have to do is follow the exit signals,
      * which identified by the Woodies CCI system.
      * Note, that when you build the neck line (trend line)
      * on the "Ghost" pattern, You join the "Trend Line
      * Breakthrough (TLB)" pattern with the "Ghost" pattern, that reinforces the signal and
      * increases the success probability. Sometimes the neck line is tilted
      * towards the zero line. This is the more preferred
      * variant of the "Ghost" pattern compared to the variant
      * in which the neck line is rejected from the xero line. In any case,
      * both variants can be used to trading.
      * The trading using the "Ghost" pattern in fact is a
      * contr-trend trading.
      */

      delta=15; level=50;
      max1=0; max2=0; max3=0; tmax1=0; tmax2=0; tmax3=0;
      min1=0; min2=0; min3=0; tmin1=0; tmin2=0; tmin3=0;
      //---- -----
      GhostBuffer[bar]=EMPTY_VALUE;
      //---- definition of maximums
      if(up>=6) for(int a=0; a<18; a++)
        {
         if(slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
           {
            if(max2!=0 && max3==0) max3=slowCCI[a+1];
            if(max1!=0 && max2==0) max2=slowCCI[a+1];
            if(max1==0) max1=slowCCI[a+1];
           }
        }
      //---- definition of minimums
      if(dn>=6) for(int a=0; a<18; a++)
        {
         if(slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
           {
            if(min2!=0 && min3==0) min3=slowCCI[a+1];
            if(min1!=0 && min2==0) min2=slowCCI[a+1];
            if(min1==0) min1=slowCCI[a+1];
           }
        }
      //---- Ghost in the downtrend
      if(dn>=6 && 
         min3!=0 && min1>min2 && min3>min2+delta && min1<0 && 
         slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && 
         /* min3<0 && max1<=0 && max1>=-level && max2<=level && max2>=-level */
         !(slowCCI[1]-delta>min1))
        {
         GhostBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }
      //---- Ghost in the uptrend
      if(up>=6 && 
         max3!=0 && max1<max2 && max3<max2-delta && max1>0 && 
         slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && 
         /* max3>0 && min1<=level && min1>=0 && min2<=level && min2>=-level */
         !(slowCCI[1]+delta<max1))
        {
         GhostBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }

/*
      * Pattern № 6 - Reverse Divergence of the Woodies CCI (Rev Diver)
      * -----------------------------------------------------------
      * Reverse Divergence of the Woodies CCI (Rev Diver) is a very simple
      * pattern of trading by trend, which determines by two
      * CCI rebounds, the latter of which is closer to the zero line.
      * The word "rebound" means the peaks and cavities, which formed
      * by the CCI movement up and down. The "internal rebounds" means,
      * the peaks and cavities, which located nearer to the zero line.
      * We never use the extremums to determine the Rev Diver pattern.
      * ----
      * The following two rules - that is all that is necessary to determine
      * the Rev Diver pattern:
      * * Rev Diver for buy - the CCI above the zero line in the last
      *   6 or more bars, two of which - lower peak cavities
      * * Rev Diver for sell - CCI below the zero line in the last
      *   6 or more bars, two of which - upper peaks to the zero line
      * ----
      *  The "Reverse Divergence" is a pattern to trading by trend.
      * You can join the Rev Diver pattern
      * with the "Zero Line Rebound (ZLR)" or "Trend Line Breakthrough (TLB)"
      * to get more confidence and profitability of the deal. You will almost
      * always find a combination of ZLR pattern with Rev Diver.
      * In fact, You will usually have two ZLR patterns, which forms the Rev Diver,
      * because usually the peaks or cavities formed within +/-100 CCI scale.
      * The internal peaks and cavities is a CCI ZLR pattern.
      * Take a close look on the charts, and Вы you Will see both of them on each chart.
      */

      delta=20; level=70;
      //----
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      //----
      RevdevBuffer[bar]=EMPTY_VALUE;
      //---- definition of maximums
      if(dn>=6) for(int a=0; a<18; a++)
        {
         if(slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
           {
            if(max1!=0 && tmax1<3 && max2==0)
              {
               max2=slowCCI[a+1];
               tmax2=a+1;
              }
            if(max1==0)
              {
               max1=slowCCI[a+1];
               tmax1=a+1;
              }
           }
        }
      //---- definition of minimums
      if(up>=6) for(int a=0; a<18; a++)
        {
         if(slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
           {
            if(min1!=0 && tmin1<3 && min2==0)
              {
               min2=slowCCI[a+1];
               tmin2=a+1;
              }
            if(min1==0)
              {
               min1=slowCCI[a+1];
               tmin1=a+1;
              }
           }
        }
      //---- Revdiv in the downtrend
      if(dn>=6 && 
         max1<=0 && max2!=0 && max1>max2 && max1>=-level && tmax2-tmax1>=3 && 
         /* max2<=level && max2>=-level && */
         slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<max1))
        {
         RevdevBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }
      //---- Revdiv in the uptrend
      if(up>=6 && 
         min1>=0 && min2!=0 && min1<min2 && min1<=level && tmin2-tmin1>=3 && 
         /* pmn2<=level && pmn2>=-level && */
         slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>min1))
        {
         RevdevBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }

/*
      * Pattern № 7 - Hook from Extremes (HFE)
      * -----------------------------------------------------------
      * This pattern is formed then the CCI indicator value is without +/-200,
      * and then turns back to the zero line. This is very
      * hard way of trend. The HFE pattern is also one of the
      * Woodies CCI entry signals.
      * ----
      * The trading using this pattern is too fast. As soon as
      * the hook is set back to the zero line, enter the market. Set
      * near the stop loss orders when entering the market, because
      * the trade signal can be reversed very fast. As soon as
      * the exit signal - exit from the market immediately.
      * The trading will be stoped often and this can happen,
      * Even if there is no signal at the output of CCI. The probability of success
      * trading is about 50%, when trading on
      * each HFE signal. However, the potential pfofit will be more
      * than losses, if You will use near the stop loss orders.
      * The trading on the reversal from extremums is a
      * contr-trend trading, so use these pattern
      * very carefully.
      * ----
      * For greater efficiency You can join
      * the HFE-pattern trading with the trend line breakthrough or with the CCI intersection
      * of +/-100 level, which is a confirmation signals.
      */

      delta=10; level=200;
      HooksBuffer[bar]=EMPTY_VALUE;
      //---- HFE in the downtrend
      if(dn>=6 && 
         slowCCI[1]<=-level && slowCCI[0]>-level && slowCCI[1]<slowCCI[0]-delta)
        {
         HooksBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
        }
      //---- HFE in the uptrend
      if(up>=6 && 
         slowCCI[1]>=level && slowCCI[0]<level && slowCCI[1]>slowCCI[0]-delta)
        {
         HooksBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
        }

/*
      * The exit signal
      * -----------------------------------------------------------
      * 1. The reversal (CCI(14) forms a hook) or horizontal CCI movement
      * 2. The trend line breakthrough by CCI (TLB)
      * 3. CCI(6) crosses the CCI(14) inside
      * 4. CCI crosses the zero line (ZLC).
      * 5. When the CCI 14 formes a hook near the level of +/-200 or behind it
      * 6. CCI (no success without movement)
      * -----------------------------------------------------------
      * 1. The reversal (CCI(14) forms a hook) or horizontal CCI movement
      */

      if(HooksBuffer[bar]!=EMPTY_VALUE)
        {
         if(up>=6)
           {
            ExitBuffer[bar]=High[bar]+upnt*_Point;
            upnt+=5;
           }
         if(dn>=6)
           {
            ExitBuffer[bar]=Low[bar]-dpnt*_Point;
            dpnt+=5;
           }
        }

      //---- 2. The trend line breakthrough by CCI (against the trend)
      if(TlbBuffer[bar]!=EMPTY_VALUE)
        {
         if(up>=6 && TlbBuffer[bar]>High[bar])
           {
            ExitBuffer[bar]=High[bar]+upnt*_Point;
            upnt+=5;
           }
         if(dn>=6 && TlbBuffer[bar]<Low[bar])
           {
            ExitBuffer[bar]=Low[bar]-dpnt*_Point;
            dpnt+=5;
           }
        }
/*
     //---- 3. CCI(6) crosses the CCI(14) inside
      if (up>=6 && fastCCI[1]>=slowCCI[1] && fastCCI[0]<=slowCCI[0])
	   {
		   ExitBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
		}
	   if (dn>=6 && TlbBuffer[bar]<Low[bar])
	   {
		   ExitBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
		}
*/

/*
      delta=10; level=100;
     //---- ----
      ExitBuffer[bar]=EMPTY_VALUE;
      min1=0; max1=0;//---- min/max values
     //----	Definition of the min/max and construction of the trend line
      for (a=0;a<=17;a++)
      {
        //---- definition of maximums
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max1==0) max1=slowCCI[a+1];
			}
        //---- definition of minimums
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1==0) min1=slowCCI[a+1];
			}
      }
     //---- exit in the downtrend
	   if (min1!=0 && slowCCI[0]-delta>min1 && !(slowCCI[1]-delta>min1) && MathAbs(slowCCI[0])>level)
      {
		   ExitBuffer[bar]=Low[bar]-dpnt*_Point;
         dpnt+=5;
	   }
     //---- exit in the uptrend
      if (max1!=0 && slowCCI[0]+delta<max1 && !(slowCCI[1]+delta<max1) && MathAbs(slowCCI[0])>level)
      {
		   ExitBuffer[bar]=High[bar]+upnt*_Point;
         upnt+=5;
      }
*/
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
