//+------------------------------------------------------------------+
//|                                                         iVAR.mq5 |
//|                                          Copyright © 2008, Ilnur |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
/* Индикатор отображает индекс вариации ценового ряда, вычисленного
* на минимальном предшествующем интервале длины 2^n. Индекс вариации
* показывает, что преобладает во временном ряду – трендовая или
* флетовая составляющая, или же ряд ведет себя случайно.
 *
 * М.М. Дубовиков и др. - Размерность минимального покрытия и
* локальный анализ фрактальных временных рядов.
 */
//---- авторство индикатора
#property copyright "Copyright © 2008, Ilnur"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.20"
#property description "Индекс вариации"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии использован красный цвет
#property indicator_color1 clrRed
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "iVAR"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.5
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int N=5; // период индикатора  
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[];

//---- Объявление переменной для хранения значения номера
int Num;
//---- Объявление переменной для хранения значения логарифма
double MathLogX2;
//---- Объявление целых переменных начала отсчёта данных
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   StartBars=int(MathPow(2,N));
//---- Инициализация переменных 
   Num=N+1;
   MathLogX2=MathLog(2.0);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"iVAR(",N,")");
//---- создание метки для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<StartBars) return(0);

//---- объявления локальных переменных 
   int limit,ihigh,ilow,nInterval;
   double Delta,Xc,Yc,Sx,Sy,Sxx,Sxy;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=rates_total-StartBars-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0; bar--)
     {
      Sx=Sy=Sxx=Sxy=NULL;

      for(int iii=0; iii<=N; iii++)
        {
         Delta=NULL;
         nInterval=int(MathPow(2,N-iii));
         double res=MathPow(2,iii);
         //---- суммируем разницы максимальной и минимальной цен на интервале
         for(int kkk=0; kkk<res; kkk++)
           {
            int barx=bar+nInterval*kkk;
            ihigh=ArrayMaximum(high,barx,nInterval);
            ilow=ArrayMinimum(low,barx,nInterval);
            Delta+=high[ihigh]-low[ilow];
           }
         //---- вычисляем координаты вариации в двойном логарифмическом масштабе
         Xc = (N-iii)*MathLogX2;
         Yc = MathLog(Delta);

         //---- накапливаем данные для нахождения коэффициентов линии регрессии с помощью МНК
         Sx += Xc;
         Sy += Yc;
         Sxx += Xc*Xc;
         Sxy += Xc*Yc;
        }
      //---- вычисляем индекс вариации (коэффициент наклона линии регрессии)
      ExtLineBuffer[bar]=-(Sx*Sy-Num*Sxy)/(Sx*Sx-Num*Sxx);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

   