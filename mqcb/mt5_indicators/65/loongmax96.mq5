//+------------------------------------------------------------------+
//|                                                   LoongMAx96.mq5 |
//|                             Copyright 2010, Loong@forum.mql4.com |
//|                                             Loong@forum.mql4.com |
//+------------------------------------------------------------------+
#property copyright "2010, Loong@forum.mql4.com"
#property link      "Loong@forum.mql4.com"
#property version   "1.01"
/*
History:
The idea is got from Rosh's topic
http://forum.mql4.com/ru/6100/page6
http://forum.mql4.com/c/codebase/2007/06/6_1.gif
http://forum.mql4.com/c/forum/2007/06/ma_1200.zip  (seem be uploaded by 'dimontus')
http://forum.mql4.com/cn/6108/page2
http://forum.mql4.com/6130/page4
http://forum.mql4.com/6130/page5
http://forum.mql4.com/c/forum/2007/08/ma_1200.zip  ('Rosh' copy and paste )
And the idea in Chinese name, called 'jun xian liu'.(That means "Moving Average Line Flow".)
I wanted to simplify the multi-indicator template with a multi-line indicator.
But it means many repetitive codes.
Or I need two-dimensional array, one dimensional for time index, another dimensional for MAs[] index.
In MQL4, it is impossible. (And MQL4 support only 8 line indicator.)
Then we had MT5 and MQL5, them support class.
And class can hide one dimensional.
So I achieved the first version, at http://forum.mql4.com/27267
(notice: the old class name 'CIndicatorBuffer' conflicts with same name in Indicator.mqh)
Later, a newer version be discussed at http://www.mql5.com/en/forum/331/
(Thank 'Rosh' and 'investeo'!)
And now, the newest version is here.
*/
/*
Chinese Comment
历史：
原始思想来自 Rosh 的帖子。
http://forum.mql4.com/ru/6100/page6
http://forum.mql4.com/c/codebase/2007/06/6_1.gif
http://forum.mql4.com/c/forum/2007/06/ma_1200.zip  (好象是由 'dimontus'先生上传的)
http://forum.mql4.com/cn/6108/page2
http://forum.mql4.com/6130/page4
http://forum.mql4.com/6130/page5
http://forum.mql4.com/c/forum/2007/08/ma_1200.zip  ('Rosh'先生从俄文版复制过来的 )
后来查到这种思路在中文中有个名字，叫做“均线流”，好象是青木先生提出来的，不知道是否有更早的起源。
上面给出的链接可以下载到一个模板，里面用了很多均线指标来实现。
我想把它简化成一个多线的指标。但是如果不能用二维数组做循环的话，就要写很多大同小异的代码。
在MQL4里，Buffer系列函数不支持二维数组，所以这东西做起来很累赘，
而且MQL4每个指标只支持8条线，要做“均线流”还是需要好几个指标。
后来我们有了MT5和MQL5。Buffer系列函数仍然不支持二维数组，不过它们支持类。
所以我写了这个指标的第一个版本，你可以在以下地址找到。http://forum.mql4.com/27267
这个指标使用一个设计粗糙简单的类，是为了能把主要的对象当成一个数组，放在循环中处理。
（注意：当时用的类名 'CIndicatorBuffer' 与 Indicator.mqh 中的同名类冲突了。不过编译使用是没问题的。）
后来一个更新的版本在讨论后完成，你可以在以下地址看到讨论的过程。http://www.mql5.com/en/forum/331/
感谢 'Rosh'先生 和 'investeo'先生的参与。
现在发到 Code Base 的就是最新版了。
*/

#include "CMyBuffer.mqh"   //a simple class
#include "fColorInc.mqh"   //color increase well-distributed
//should be in the same fold with this mq5 file

#define iNum 96

#property indicator_chart_window
#property indicator_buffers iNum
#property indicator_plots   iNum
//---- plot MA
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input ENUM_MA_METHOD     smootMode=MODE_EMA;
input ENUM_APPLIED_PRICE price=PRICE_CLOSE;
input int                shift=0;
//---- indicator parameters
int iParam[iNum];
//--- indicator buffers
CMyBuffer MAA[iNum];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
bool SequenceQuadratic(int& iReturnValue[], const int iSize, const int i0, const int im)
{
   if(ArraySize(iReturnValue)<2)   return false;
   if(iSize<2)   return false;
   iReturnValue[0]=2;
   for(int i=1;i<iSize;i++) iReturnValue[i]=(i+1)*(i+1);
   return true;
}
int OnInit()
  {

  int MaxBarsinChart=TerminalInfoInteger(TERMINAL_MAXBARS);
  
  if (MaxBarsinChart>50000)
  {
   Print("Max bars in chart is too large:",MaxBarsinChart);
   Print("Please reduce the number of max bars in chart in the Options to 50000 and restart client terminal");
   return(-1);
  }

   IndicatorSetString(INDICATOR_SHORTNAME,"LoongMAx96");//+IntegerToString(AsSeries)
//--- indicator buffers mapping
   color iColor = Red;
   bool bReturn = SequenceQuadratic(iParam,iNum,2,2);  
   int iTmp;               //temporary variable for bug of MT5
   for(int i=0; i<iNum; i++)
   {
      MAA[i].Init();
      iTmp=iParam[i];      //You CANNOT assign a array member with a member of another array, 
      MAA[i].mParam=iTmp;  //so you need a temporary variable.
      iColor = color(ColorInc96(i));
      MAA[i].mSetIndexBuffer(i,INDICATOR_DATA);
      MAA[i].mPlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);
      MAA[i].mPlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_SOLID);
      MAA[i].mPlotIndexSetInteger(i,PLOT_COLOR_INDEXES,1); //Add by Loong 20100112
      MAA[i].mPlotIndexSetInteger(i,PLOT_LINE_COLOR,iColor);
      MAA[i].mPlotIndexSetString(i,PLOT_LABEL,"MA"+IntegerToString(i,2,'0')+"(color:"+IntegerToString(iColor)+")");//Print(IntegerToString())
      MAA[i].mhandle=iMA(NULL,0,MAA[i].mParam,shift,smootMode,price); //Symbol()
   }
   return(0);
  }
void OnDeinit(const int reason)
{
      for(int i=0; i<iNum; i++)
      {
         MAA[i].Deinit();
      }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//--- Copy the values of the moving average in the buffer MABuffer
   int copied;
   for(int i=0; i<iNum; i++)
   {
      copied=MAA[i].mCopyBuffer(prev_calculated,rates_total);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+