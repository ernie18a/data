//------------------------------------------------------------------
#property copyright "© mladen, 2021"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_label1  "State high"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_label2  "State down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCoral
#property indicator_style2  STYLE_SOLID
#property indicator_label3  "Level up 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
#property indicator_label4  "Level up 2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_DASHDOTDOT
#property indicator_width4  1
#property indicator_label5  "Level up 1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLimeGreen
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Level down 1"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrCoral
#property indicator_style6  STYLE_DOT
#property indicator_label7  "Level down 2"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrCoral
#property indicator_style7  STYLE_DASHDOTDOT
#property indicator_width7  1
#property indicator_label8  "Level down 3"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrCoral
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
#property strict

//
//
//

input int    inpAtrPeriod    = 50; // ATR period
input double inpAtrMultiplier = 5; // ATR multiplier
      enum enUseWhat
         {
            use_level3, // Use level 3 (slowest)
            use_level2, // Use level 2 (middle)
            use_level1, // Use level 1 (fastest)
         };
input enUseWhat inpUseWhat = use_level3; // "States" using :          

//
//
//

double up1[],up2[],up3[],down1[],down2[],down3[],histoup[],histodn[],histoc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0,histoup,INDICATOR_DATA);
   SetIndexBuffer(1,histodn,INDICATOR_DATA);
   SetIndexBuffer(2,up3    ,INDICATOR_DATA);
   SetIndexBuffer(3,up2    ,INDICATOR_DATA);
   SetIndexBuffer(4,up1    ,INDICATOR_DATA);
   SetIndexBuffer(5,down1  ,INDICATOR_DATA);
   SetIndexBuffer(6,down2  ,INDICATOR_DATA);
   SetIndexBuffer(7,down3  ,INDICATOR_DATA);
   SetIndexBuffer(8,histoc ,INDICATOR_CALCULATIONS);
   
   //
   //
   //
   
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;
                     
   //
   //
   //
                                 
      struct sWorkStruct   
            {
               double tr;  
               double trSum;
               double mid;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
          
   //
   //
   //

   for (int i=limit, r=rates_total-i-1; i>=0  && !_StopFlag; i--, r++)
      {
         m_work[r].tr = (r>0) ? (high[i]>close[i+1] ? high[i] : close[i+1]) - (low[i]<close[i+1] ? low[i] : close[i+1]) : high[i] - low[i];
         if (r>inpAtrPeriod)
               { m_work[r].trSum = m_work[r-1].trSum + m_work[r].tr - m_work[r-inpAtrPeriod].tr; }
         else  { m_work[r].trSum = m_work[r].tr; for (int k=1; k<inpAtrPeriod && r>=k; k++)  m_work[r].trSum += m_work[r-k].tr; }
         
         //
         //
         //
                  
         if (r==0)
               {
                  up1[i]   = up2[i]   = up3[i]   = high[i];
                  down1[i] = down2[i] = down3[i] = low[i];
               }
         else
               {
                  double _atr = inpAtrMultiplier*m_work[r-1].trSum/(double)inpAtrPeriod;
                     if (high[i] > up3[i+1])   up3[i]   = high[i]; else if (high[i] < up3[i+1])   up3[i]   = MathMin(high[i] + _atr*1.0, up3[i+1]);   else up3[i]   = up3[i+1];
                     if (high[i] > up2[i+1])   up2[i]   = high[i]; else if (high[i] < up2[i+1])   up2[i]   = MathMin(high[i] + _atr*0.5, up2[i+1]);   else up2[i]   = up2[i+1];
                     if (high[i] > up1[i+1])   up1[i]   = high[i]; else if (high[i] < up1[i+1])   up1[i]   = MathMin(high[i] + _atr*0.1, up1[i+1]);   else up1[i]   = up1[i+1];
                     if (low[i]  < down1[i+1]) down1[i] = low[i];  else if (low[i]  > down1[i+1]) down1[i] = MathMax(low[i]  - _atr*0.1, down1[i+1]); else down1[i] = down1[i+1];
                     if (low[i]  < down2[i+1]) down2[i] = low[i];  else if (low[i]  > down2[i+1]) down2[i] = MathMax(low[i]  - _atr*0.5, down2[i+1]); else down2[i] = down2[i+1];
                     if (low[i]  < down3[i+1]) down3[i] = low[i];  else if (low[i]  > down3[i+1]) down3[i] = MathMax(low[i]  - _atr*1.0, down3[i+1]); else down3[i] = down3[i+1];
               }
         switch (inpUseWhat)
               {
                     case use_level3 : m_work[r].mid = (up3[i]+down3[i])/2; break;
                     case use_level2 : m_work[r].mid = (up2[i]+down2[i])/2; break;
                     case use_level1 : m_work[r].mid = (up1[i]+down3[i])/2; break;
                }                        
         histoc[i]  = (r>0) ? (m_work[r].mid>m_work[r-1].mid) ? 1 : (m_work[r].mid<m_work[r-1].mid) ? 2 : histoc[i+1] : 0;
         histoup[i] = (histoc[i]==1) ? high[i] : low[i];
         histodn[i] = (histoc[i]==1) ? low[i] : high[i];
   }
   return(rates_total);
}