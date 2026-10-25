//+------------------------------------------------------------------+
//|                               BarTimerCLineRoundedVerticalUp.mq5 |
//|                               Copyright © 2008, Art Royal s.r.o. |
//|                                           Author: Vasyl Gumenyak |  
//|                                           http://www.jiport.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2008, Art Royal s.r.o."
//---- ссылка на сайт автора
#property link      "http://www.jiport.com/"
//---- номер версии индикатора
#property version   "1.0"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- в индикаторе нет индикаторных буферов
#property indicator_buffers 0 
//---- в индикаторе нет графических построений
#property indicator_plots  0 
//+----------------------------------------------+
//|  Описание классов графических объектов       |
//+----------------------------------------------+ 
#include <CustomGUI\CustomGUI.mqh>
//+----------------------------------------------+
//---- объявление переменных класса CLineRounded из файла CustomGUI.mqh
CLineRoundedVerticalUp BarTimer;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string Ind_Sirname="BarTimerCLineRoundedVerticalUp_";  // Название для объектов индикатора
input int FontSize=20;        //размер шрифта
input color FontColor=clrBlack;    //цвет текста
input color ScaleColor=clrOrange;    //цвет шкалы
input int XDistance=80;// x расстояние от опорного левого верхнего угла
input int YDistance=150;// y расстояние от опорного левого верхнего угла
input int XSize=40;// ширина
input int YSize=200;// высота
input uchar Alpha=100;    //прозрачность индикатора
input color BgColor=clrLavender;    //цвет заднего фона
input color BorderColor=clrDeepPink;    //цвет рамки индикатора
input int Border=4;  //толщина рамки индикатора
input bool SoundSignal=true;// разрешение на подачу звукового сигнала при смене бара
input string Sound="Alert";  // название звукового файла для сигнала
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- размеры шкалы индикатора
   BarTimer.XSizeInd(XSize);
   BarTimer.YSizeInd(YSize);
   //--- цвет шкалы индикатора
   BarTimer.ScaleColor(ScaleColor);
   //--- цвет шрифта численного значения
   BarTimer.ValueColor(FontColor);
   //--- размер шрифта численного значения
   BarTimer.FontSize(FontSize);
   //--- прозрачность
   BarTimer.Alpha(Alpha);
   //--- толщина рамки
   BarTimer.Border(Border);   
   //--- цвет заднего фона
   BarTimer.BgColor(BgColor);
   //--- цвет рамки индикатора
   BarTimer.BorderColor(BorderColor);
   //--- создание индикатора
   BarTimer.Create(Ind_Sirname,XDistance,YDistance);  
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   BarTimer.Delete();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- 
   int sec=0;
   double pc=0.0;
   sec=int(TimeCurrent()-time[rates_total-1]);// время в секундах от начала бара
   pc=100.0*sec/(PeriodSeconds());// время от начала бара в процентах
   BarTimer.NewValue(pc,100,1);
   if(SoundSignal && rates_total!=prev_calculated) PlaySound(Sound);  
//----
   ChartRedraw(0);   
   return(rates_total);
  }
//+------------------------------------------------------------------+
