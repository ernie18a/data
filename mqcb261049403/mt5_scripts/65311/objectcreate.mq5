//+------------------------------------------------------------------+
//|                                                 ObjectCreate.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property script_show_inputs

#define   OBJ_NAME   "TestObjectCreate"   // Имя объекта
#define   WND        0                    // Подокно графика
#define   DISTANCE   300                  // Дистанция между линиями

input ENUM_OBJECT InpObjectToCreate = OBJ_VLINE;   /* Object type to create */ // тип объекта для построения на графике

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- идентификатор текущего графика
   long chart_id=ChartID();

//--- удаляем ранее созданный объект
   ObjectDelete(chart_id, OBJ_NAME);

//--- если объект успешно создан, установим остальные параметры объекта,
//--- например, сделаем объект доступным для выделения и выберем его;
//--- обновим график для отображения изменений
   if(CreateObject(chart_id, InpObjectToCreate))
     {
      ObjectSetInteger(chart_id, OBJ_NAME, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(chart_id, OBJ_NAME, OBJPROP_SELECTED, true);
      ChartRedraw(chart_id);
     }
  }
//+------------------------------------------------------------------+
//| Устанавливает значения координатной точки объекта (цена/время)   |
//+------------------------------------------------------------------+
bool SetObjectDatePrice(const long chart_id, const string object_name, const int point_num, const datetime time, const double price)
  {
   ResetLastError();
//--- устанавливаем время
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_TIME, point_num, time))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем цену
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_PRICE, point_num, price))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Устанавливает значения координатной точки объекта (X/Y)          |
//+------------------------------------------------------------------+
bool SetObjectCoordinates(const long chart_id, const string object_name, const int point_num, const int x, const int y)
  {
   ResetLastError();
//--- устанавливаем координату X
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_XDISTANCE, point_num, x))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем координату Y
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_YDISTANCE, point_num, y))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт указанный графический объект                             |
//+------------------------------------------------------------------+
bool CreateGraphObject(const long chart_id, const int subwindow, const ENUM_OBJECT object_type, const string object_name)
  {
   ResetLastError();
   if(!ObjectCreate(chart_id, object_name, object_type, subwindow, 0, 0, 0, 0, 0, 0, 0, 0))
     {
      Print("ObjectCreate() failed. Error ", GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Вертикальная линия"                  |
//+------------------------------------------------------------------+
bool CreateVLine(const long chart_id, const int subwindow, const string object_name, const datetime time)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_VLINE, object_name))
      return(false);
//--- устанавливаем значение времени
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, 0))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Горизонтальная линия"                |
//+------------------------------------------------------------------+
bool CreateHLine(const long chart_id, const int subwindow, const string object_name, const double price)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_HLINE, object_name))
      return(false);
//--- устанавливаем значение цены
   if(!SetObjectDatePrice(chart_id, object_name, 0, 0, price))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Трендовая линия"                     |
//+------------------------------------------------------------------+
bool CreateTrend(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_TREND, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Трендовая линия по углу"             |
//+------------------------------------------------------------------+
bool CreateTrendByAngle(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const double angle)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_TRENDBYANGLE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем угол
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_ANGLE, angle))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Циклические линии"                   |
//+------------------------------------------------------------------+
bool CreateCycles(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_CYCLES, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Линия со стрелкой"                   |
//+------------------------------------------------------------------+
bool CreateArrowedLine(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROWED_LINE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Равноудаленный канал"                |
//+------------------------------------------------------------------+
bool CreateChannel(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_CHANNEL, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Канал стандартного отклонения"       |
//+------------------------------------------------------------------+
bool CreateStdDevChannel(const long chart_id, const int subwindow, const string object_name, const datetime time1, const datetime time2, const double deviation)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_STDDEVCHANNEL, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, 0))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, 0))
      return(false);
//--- устанавливаем отклонение
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_DEVIATION, deviation))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Канал на линейной регрессии"         |
//+------------------------------------------------------------------+
bool CreateRegression(const long chart_id, const int subwindow, const string object_name, const datetime time1, const datetime time2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_REGRESSION, object_name))
      return(false);
//--- устанавливаем время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, 0))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, 0))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Вилы Эндрюса"                         |
//+------------------------------------------------------------------+
bool CreatePitchfork(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_PITCHFORK, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Линия Ганна"                         |
//+------------------------------------------------------------------+
bool CreateGannLine(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double angle, const double scale)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_GANNLINE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, 0))
      return(false);
//--- устанавливаем угол
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_ANGLE, angle))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем масштаб
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_SCALE, scale))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Веер Ганна"                          |
//+------------------------------------------------------------------+
bool CreateGannFan(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double scale, const ENUM_GANN_DIRECTION direction)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_GANNFAN, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, 0))
      return(false);
//--- устанавливаем масштаб
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_SCALE, scale))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем направление тренда
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_DIRECTION, direction))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Сетка Ганна"                         |
//+------------------------------------------------------------------+
bool CreateGannGrid(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double scale, const ENUM_GANN_DIRECTION direction)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_GANNGRID, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, 0))
      return(false);
//--- устанавливаем масштаб
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_SCALE, scale))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем направление тренда
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_DIRECTION, direction))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Уровни Фибоначчи"                    |
//+------------------------------------------------------------------+
bool CreateFibo(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_FIBO, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Временные зоны Фибоначчи"            |
//+------------------------------------------------------------------+
bool CreateFiboTimes(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_FIBOTIMES, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Веер Фибоначчи"                      |
//+------------------------------------------------------------------+
bool CreateFiboFan(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_FIBOFAN, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Дуги Фибоначчи"                      |
//+------------------------------------------------------------------+
bool CreateFiboArc(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const double scale, const bool ellipse)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_FIBOARC, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем масштаб
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_SCALE, scale))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем флаг отображения полного эллипса
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ELLIPSE, ellipse))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Канал Фибоначчи"                     |
//+------------------------------------------------------------------+
bool CreateFiboChannel(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_FIBOCHANNEL, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Расширение Фибоначчи"                |
//+------------------------------------------------------------------+
bool CreateExpansion(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_EXPANSION, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "5-волновка Эллиота"                  |
//+------------------------------------------------------------------+
bool CreateElliotWave5(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3, const datetime time4, const double price4, const datetime time5, const double price5, const bool lines=true)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ELLIOTWAVE5, object_name))
      return(false);
//--- устанавливаем цену/время первой точки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- устанавливаем цену/время четвёртой точки
   if(!SetObjectDatePrice(chart_id, object_name, 3, time4, price4))
      return(false);
//--- устанавливаем цену/время пятой точки
   if(!SetObjectDatePrice(chart_id, object_name, 4, time5, price5))
      return(false);
//--- устанавливаем флаг рисования линий между точками
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_DRAWLINES, lines))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "3-волновка Эллиота"                  |
//+------------------------------------------------------------------+
bool CreateElliotWave3(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3, const bool lines=true)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ELLIOTWAVE3, object_name))
      return(false);
//--- устанавливаем цену/время первой точки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- устанавливаем флаг рисования линий между точками
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_DRAWLINES, lines))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Прямоугольник"                       |
//+------------------------------------------------------------------+
bool CreateRectangle(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_RECTANGLE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Треугольник"                         |
//+------------------------------------------------------------------+
bool CreateTriangle(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_TRIANGLE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Эллипс"                              |
//+------------------------------------------------------------------+
bool CreateEllipse(const long chart_id, const int subwindow, const string object_name, const datetime time1, const double price1, const datetime time2, const double price2, const datetime time3, const double price3)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ELLIPSE, object_name))
      return(false);
//--- устанавливаем цену/время первой точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time1, price1))
      return(false);
//--- устанавливаем цену/время второй точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 1, time2, price2))
      return(false);
//--- устанавливаем цену/время третьей точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 2, time3, price3))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Хорошо" (большой палец вверх)" |
//+------------------------------------------------------------------+
bool CreateArrowThumbUp(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_THUMB_UP, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Плохо" (большой палец вниз)"   |
//+------------------------------------------------------------------+
bool CreateArrowThumbDown(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_THUMB_DOWN, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Стрелка вверх"                 |
//+------------------------------------------------------------------+
bool CreateArrowUp(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_UP, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Стрелка вниз"                  |
//+------------------------------------------------------------------+
bool CreateArrowDown(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_DOWN, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Стоп"                          |
//+------------------------------------------------------------------+
bool CreateArrowStop(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_STOP, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Птичка" (галка)"               |
//+------------------------------------------------------------------+
bool CreateArrowCheck(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_CHECK, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Левая ценовая метка"                 |
//+------------------------------------------------------------------+
bool CreateArrowLeftPrice(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_LEFT_PRICE, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Правая ценовая метка"                |
//+------------------------------------------------------------------+
bool CreateArrowRightPrice(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_RIGHT_PRICE, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Buy"                           |
//+------------------------------------------------------------------+
bool CreateArrowBuy(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_BUY, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Знак "Sell"                          |
//+------------------------------------------------------------------+
bool CreateArrowSell(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW_SELL, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Стрелка"                             |
//+------------------------------------------------------------------+
bool CreateArrow(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const uchar arrow_code, const ENUM_ARROW_ANCHOR anchor=ANCHOR_TOP)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_ARROW, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем код значка стрелки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ARROWCODE, arrow_code))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Текст"                               |
//+------------------------------------------------------------------+
bool CreateText(const long chart_id, const int subwindow, const string object_name, const string text, const datetime time, const double price, const string font_name, const int font_size, const double angle)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_TEXT, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем текст
   if(!ObjectSetString(chart_id, object_name, OBJPROP_TEXT, text))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем имя фонта
   if(!ObjectSetString(chart_id, object_name, OBJPROP_FONT, font_name))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем размер фонта
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE, font_size))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем угол
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_ANGLE, angle))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Текстовая метка"                     |
//+------------------------------------------------------------------+
bool CreateLabel(const long chart_id, const int subwindow, const string object_name, const string text, const int x, const int y, const string font_name, const int font_size, const double angle, const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_LABEL, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем текст
   if(!ObjectSetString(chart_id, object_name, OBJPROP_TEXT, text))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем имя фонта
   if(!ObjectSetString(chart_id, object_name, OBJPROP_FONT, font_name))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем размер фонта
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE, font_size))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем угол
   if(!ObjectSetDouble(chart_id, object_name, OBJPROP_ANGLE, angle))
     {
      PrintFormat("%s: ObjectSetDouble() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Кнопка"                              |
//+------------------------------------------------------------------+
bool CreateButton(const long chart_id, const int subwindow, const string object_name, const string text, const int x, const int y, const int width, const int height, const bool state, const string font_name, const int font_size)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_BUTTON, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем ширину
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_XSIZE, width))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем высоту
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_YSIZE, height))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем состояние
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_STATE, state))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем текст
   if(!ObjectSetString(chart_id, object_name, OBJPROP_TEXT, text))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем имя фонта
   if(!ObjectSetString(chart_id, object_name, OBJPROP_FONT, font_name))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем размер фонта
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE, font_size))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "График"                              |
//+------------------------------------------------------------------+
bool CreateChart(const long chart_id, const int subwindow, const string object_name, const string symbol, const ENUM_TIMEFRAMES timeframe, const int x, const int y, const int width, const int height)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_CHART, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем ширину
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_XSIZE, width))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем высоту
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_YSIZE, height))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем таймфрейм
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_PERIOD, timeframe))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем символ
   if(!ObjectSetString(chart_id, object_name, OBJPROP_SYMBOL, symbol))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Рисунок"                             |
//+------------------------------------------------------------------+
bool CreateBitmap(const long chart_id, const int subwindow, const string object_name, const datetime time, const double price, const string file_name, const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_BITMAP, object_name))
      return(false);
//--- устанавливаем цену/время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, price))
      return(false);
//--- устанавливаем имя файла изображения
   if(!ObjectSetString(chart_id, object_name, OBJPROP_BMPFILE, file_name))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Графическая метка"                   |
//+------------------------------------------------------------------+
bool CreateBitmapLabel(const long chart_id, const int subwindow, const string object_name, const int x, const int y, const string file_name_on, const string file_name_off, const bool state, const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_BITMAP_LABEL, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем имя файла изображения для состояния On
   if(!ObjectSetString(chart_id, object_name, OBJPROP_BMPFILE, 0, file_name_on))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем имя файла изображения для состояния Off
   if(!ObjectSetString(chart_id, object_name, OBJPROP_BMPFILE, 1, file_name_off))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем состояние
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_STATE, state))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем способ привязки
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_ANCHOR, anchor))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Поле ввода"                          |
//+------------------------------------------------------------------+
bool CreateEdit(const long chart_id, const int subwindow, const string object_name, const string text, const int x, const int y, const int width, const int height, const string font_name, const int font_size, const color bg_color, const bool readonly=false)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_EDIT, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем ширину
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_XSIZE, width))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем высоту
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_YSIZE, height))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем состояние
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_READONLY, readonly))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем текст
   if(!ObjectSetString(chart_id, object_name, OBJPROP_TEXT, text))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем имя фонта
   if(!ObjectSetString(chart_id, object_name, OBJPROP_FONT, font_name))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем размер фонта
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_FONTSIZE, font_size))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем цвет фона
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_BGCOLOR, bg_color))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Событие",                            |
//| соответствующий событию в экономическом календаре"               |
//+------------------------------------------------------------------+
bool CreateEvent(const long chart_id, const int subwindow, const string object_name, const datetime time, const string text, const color colour)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_EVENT, object_name))
      return(false);
//--- устанавливаем время точки привязки
   if(!SetObjectDatePrice(chart_id, object_name, 0, time, 0))
      return(false);
//--- устанавливаем текст
   if(!ObjectSetString(chart_id, object_name, OBJPROP_TEXT, text))
     {
      PrintFormat("%s: ObjectSetString() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем цвет
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, colour))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт графический объект "Прямоугольная метка" для создания    |
//| и оформления пользовательского графического интерфейса"          |
//+------------------------------------------------------------------+
bool CreateRectangleLabel(const long chart_id, const int subwindow, const string object_name, const int x, const int y, const int width, const int height, const color bg_color)
  {
//--- создаём графический объект
   if(!CreateGraphObject(chart_id, subwindow, OBJ_RECTANGLE_LABEL, object_name))
      return(false);
//--- устанавливаем X/Y точки привязки
   if(!SetObjectCoordinates(chart_id, object_name, 0, x, y))
      return(false);
//--- устанавливаем ширину
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_XSIZE, width))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем высоту
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_YSIZE, height))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- устанавливаем цвет фона
   if(!ObjectSetInteger(chart_id, object_name, OBJPROP_BGCOLOR, bg_color))
     {
      PrintFormat("%s: ObjectSetInteger() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
//| Создаёт указанный графический объект с параметрами по умолчанию  |
//+------------------------------------------------------------------+
bool CreateObject(const long chart_id, const ENUM_OBJECT object_type)
  {
//--- значение символа и Point графика с указанным идентификатором
   string symbol=ChartSymbol(chart_id);
   double point=SymbolInfoDouble(symbol, SYMBOL_POINT);
   
//--- переменные, необходимые для расчёта координат и параметров объекта
   bool     res=false;
   int      first=0, count=0, w=0, h=0, cw=0, ch=0, x=0, y=0;
   double   p1=0, p2=0, p3=0, p4=0, p5=0;
   datetime t1=0, t2=0, t3=0, t4=0, t5=0;
   
//--- создаём объект, указанный в настройках
   switch(InpObjectToCreate)
     {
      //--- Вертикальная линия
      case OBJ_VLINE :
        first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
        count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
        t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
        res=CreateVLine(chart_id, WND, OBJ_NAME, t1);
        break;
      
      //--- Горизонтальная линия
      case OBJ_HLINE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateHLine(chart_id, WND, OBJ_NAME, (p1+p2)/2.0);
        else
           res=false;
        break;
      
      //--- Трендовая линия
      case OBJ_TREND :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateTrend(chart_id, WND, OBJ_NAME, t1, p1, t2, p2);
        else
           res=false;
        break;
      
      //--- Трендовая линия по углу
      case OBJ_TRENDBYANGLE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateTrendByAngle(chart_id, WND, OBJ_NAME,
                                  (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), (t1<t2 ? -20.0 : 20));
        else
           res=false;
        break;
      
      //--- Циклические линии
      case OBJ_CYCLES :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateCycles(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1));
        else
           res=false;
        break;
      
      //--- Объект "Линия со стрелкой"
      case OBJ_ARROWED_LINE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateArrowedLine(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1));
        else
           res=false;
        break;
      
      //--- Равноудаленный канал
      case OBJ_CHANNEL :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           if(t1<t2)
              p3=p1-DISTANCE*point;
           else
              p3=p2+DISTANCE*point;
           t3=(t1<t2 ? t1 : t2);
           res=CreateChannel(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), t3, p3);
          }
        else
           res=false;
        break;
      
      //--- Канал стандартного отклонения
      case OBJ_STDDEVCHANNEL :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateStdDevChannel(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? t2 : t1), 1.0);
        else
           res=false;
        break;
      
      //--- Канал на линейной регрессии
      case OBJ_REGRESSION :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateRegression(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? t2 : t1));
        else
           res=false;
        break;
      
      //--- Вилы Эндрюса
      case OBJ_PITCHFORK :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           if(t1<t2)
             {
              t3=t2;
              p3=p2;
              p2+=DISTANCE*point;
             }
           else
             {
              t3=t1;
              p3=p1;
              p1-=DISTANCE*point;
             }
           res=CreatePitchfork(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), t3, p3);
          }
        else
           res=false;
        break;
      
      //--- Линия Ганна
      case OBJ_GANNLINE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateGannLine(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 :p2), (t1<t2 ? t2 : t1), (t1<t2 ? -45.0 : 45.0), 1.0);
        else
           res=false;
        break;
      
      //--- Веер Ганна
      case OBJ_GANNFAN :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateGannFan(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), 1.0, (t1<t2 ? GANN_DOWN_TREND : GANN_UP_TREND));
        else
           res=false;
        break;
      
      //--- Сетка Ганна
      case OBJ_GANNGRID :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateGannGrid(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), 1.0, (t1<t2 ? GANN_DOWN_TREND : GANN_UP_TREND));
        else
           res=false;
        break;
      
      //--- Уровни Фибоначчи
      case OBJ_FIBO :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateFibo(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1));
        else
           res=false;
        break;
      
      //--- Временные зоны Фибоначчи
      case OBJ_FIBOTIMES :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateFiboTimes(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1));
        else
           res=false;
        break;
      
      //--- Веер Фибоначчи
      case OBJ_FIBOFAN :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateFiboFan(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1));
        else
           res=false;
        break;
      
      //--- Дуги Фибоначчи
      case OBJ_FIBOARC :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateFiboArc(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), 1.0, false);
        else
           res=false;
        break;
      
      //--- Канал Фибоначчи
      case OBJ_FIBOCHANNEL :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           if(t1<t2)
             {
              t3=t1;
              p3=p1+DISTANCE*point;
             }
           else
             {
              t3=t2;
              p3=p2+DISTANCE*point;
             }
           res=CreateFiboChannel(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), t3, p3);
          }
        else
           res=false;
        break;
      
      //--- Расширение Фибоначчи
      case OBJ_EXPANSION :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           if(t1<t2)
              t3=t2+PeriodSeconds()*6;
           else
              t3=t1+PeriodSeconds()*6;
           p3=(p1+p2)/2.0;
           res=CreateExpansion(chart_id, WND, OBJ_NAME, (t1<t2 ? t1 : t2), (t1<t2 ? p1 : p2), (t1<t2 ? t2 : t1), (t1<t2 ? p2 : p1), t3, p3);
          }
        else
           res=false;
        break;
      
      //--- 5-волновка Эллиота
      case OBJ_ELLIOTWAVE5 :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_BARS);
        x=cw/6;
        first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR)-x;
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           p1=(p1+p2)/2.0;
        t1=GetTime(symbol, PERIOD_CURRENT, first);
        t2=GetTime(symbol, PERIOD_CURRENT, first-x);
        t3=GetTime(symbol, PERIOD_CURRENT, first-x*2);
        t4=GetTime(symbol, PERIOD_CURRENT, first-x*3);
        t5=GetTime(symbol, PERIOD_CURRENT, first-x*4);
        res=CreateElliotWave5(chart_id, WND, OBJ_NAME, t1, p1+DISTANCE*point, t2, p1-DISTANCE*point, t3, p1+DISTANCE*point, t4, p1-DISTANCE*point, t5, p1+DISTANCE*point);
        break;
      
      //--- 3-волновка Эллиота
      case OBJ_ELLIOTWAVE3 :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_BARS);
        x=cw/4;
        first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR)-x;
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           p1=(p1+p2)/2.0;
        t1=GetTime(symbol, PERIOD_CURRENT, first);
        t2=GetTime(symbol, PERIOD_CURRENT, first-x);
        t3=GetTime(symbol, PERIOD_CURRENT, first-x*2);
        res=CreateElliotWave3(chart_id, WND, OBJ_NAME, t1, p1+DISTANCE*point, t2, p1-DISTANCE*point, t3, p1+DISTANCE*point);
        break;
      
      //--- Прямоугольник
      case OBJ_RECTANGLE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
           res=CreateRectangle(chart_id, WND, OBJ_NAME, t1, p1, t2, p2);
        else
           res=false;
        break;
      
      //--- Треугольник
      case OBJ_TRIANGLE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           t3=t1;
           p3=p2;
           res=CreateTriangle(chart_id, WND, OBJ_NAME, t1, p1, t2, p2, t3, p3);
          }
        else
           res=false;
        break;
      
      //--- Эллипс
      case OBJ_ELLIPSE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           t3=t1;
           p3=p2;
           res=CreateEllipse(chart_id, WND, OBJ_NAME, t1, p1, t2, p2, t3, p3);
          }
        else
           res=false;
        break;
      
      //--- Знак "Хорошо" (большой палец вверх)
      case OBJ_ARROW_THUMB_UP :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowThumbUp(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Плохо" (большой палец вниз)
      case OBJ_ARROW_THUMB_DOWN :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowThumbDown(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Стрелка вверх"
      case OBJ_ARROW_UP :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowUp(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Стрелка вниз"
      case OBJ_ARROW_DOWN :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowDown(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Стоп"
      case OBJ_ARROW_STOP :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowStop(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Птичка" (галка)
      case OBJ_ARROW_CHECK :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowCheck(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Левая ценовая метка
      case OBJ_ARROW_LEFT_PRICE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowLeftPrice(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Правая ценовая метка
      case OBJ_ARROW_RIGHT_PRICE :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowRightPrice(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Buy"
      case OBJ_ARROW_BUY :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowBuy(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Знак "Sell"
      case OBJ_ARROW_SELL :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrowSell(chart_id, WND, OBJ_NAME, t1, p1);
          }
        else
           res=false;
        break;
      
      //--- Объект "Стрелка"
      case OBJ_ARROW :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateArrow(chart_id, WND, OBJ_NAME, t1, p1, 181);
          }
        else
           res=false;
        break;
      
      //--- Объект "Текст"
      case OBJ_TEXT :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateText(chart_id, WND, OBJ_NAME, OBJ_NAME, t1, p1, "Arial", 10, 0.0);
          }
        else
           res=false;
        break;
      
      //--- Объект "Текстовая метка"
      case OBJ_LABEL :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        x=cw/2;
        y=ch/2;
        res=CreateLabel(chart_id, WND, OBJ_NAME, OBJ_NAME, x, y, "Arial", 10, 0.0);
        break;
      
      //--- Объект "Кнопка"
      case OBJ_BUTTON :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        x=cw/2;
        y=ch/2;
        w=StringLen(OBJ_NAME)*8;
        h=26;
        res=CreateButton(chart_id, WND, OBJ_NAME, OBJ_NAME, x, y, w, h, false, "Arial", 10);
        break;
      
      //--- Объект "График"
      case OBJ_CHART :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        w=cw/2;
        h=ch/2;
        x=w-w/2;
        y=h-h/2;
        res=CreateChart(chart_id, WND, OBJ_NAME, symbol, PERIOD_CURRENT, x, y, w, h);
        break;
      
      //--- Объект "Рисунок"
      case OBJ_BITMAP :
        if(GetChartExtremums(chart_id, p1, p2, t1, t2))
          {
           first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
           count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
           t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
           p1=(p1+p2)/2.0;
           res=CreateBitmap(chart_id, WND, OBJ_NAME, t1, p1, "\\Images\\dollar.bmp");
          }
        else
           res=false;
        break;
      
      //--- Объект "Графическая метка"
      case OBJ_BITMAP_LABEL :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        x=cw/2;
        y=ch/2;
        res=CreateBitmapLabel(chart_id, WND, OBJ_NAME, x, y, "\\Images\\dollar.bmp", "\\Images\\euro.bmp", false);
        break;
      
      //--- Объект "Поле ввода"
      case OBJ_EDIT :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        x=cw/2;
        y=ch/2;
        w=StringLen(OBJ_NAME)*8;
        h=26;
        res=CreateEdit(chart_id, WND, OBJ_NAME, OBJ_NAME, x, y, w, h, "Arial", 10, clrWhiteSmoke);
        break;
      
      //--- Объект "Событие", соответствующий событию в экономическом календаре
      case OBJ_EVENT :
        first=(int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
        count=(int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
        t1=GetTime(symbol, PERIOD_CURRENT, first-count/2);
        res=CreateEvent(chart_id, WND, OBJ_NAME, t1, OBJ_NAME, clrAliceBlue);
        break;
      
      //--- Объект "Прямоугольная метка"для создания и оформления пользовательского графического интерфейса
      case OBJ_RECTANGLE_LABEL :
        cw=(int)ChartGetInteger(chart_id, CHART_WIDTH_IN_PIXELS);
        ch=(int)ChartGetInteger(chart_id, CHART_HEIGHT_IN_PIXELS);
        w=cw/2;
        h=ch/2;
        x=w-w/2;
        y=h-h/2;
        res=CreateRectangleLabel(chart_id, WND, OBJ_NAME, x, y, w, h, clrAliceBlue);
        break;
      
      //--- по умолчанию ничего не создаём
      default:
        break;
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Возвращает время по индексу бара                                 |
//+------------------------------------------------------------------+
datetime GetTime(const string symbol, const ENUM_TIMEFRAMES timeframe, const int index)
  {
   datetime array[1]={};
   ResetLastError();
   if(CopyTime(symbol, timeframe, index, 1, array)!=1)
      PrintFormat("%s: CopyTime() failed. Error %d",__FUNCTION__, GetLastError());
   return(array[0]);
  }
//+------------------------------------------------------------------+
//| Возвращает максимальную и минимальную цены на графике и их время |
//+------------------------------------------------------------------+
bool GetChartExtremums(const long chart_id, double &price_high, double &price_low, datetime &time_high, datetime &time_low)
  {
//--- обнуляем переменные
   price_high=price_low=0;
   time_high =time_low =0;
//--- символ графика
   string symbol = ChartSymbol(chart_id);

//--- по номеру первого видимого бара и количеству баров на графике рассчитываем начало диапазона копируемых таймсерий
   int first = (int)ChartGetInteger(chart_id, CHART_FIRST_VISIBLE_BAR);
   int count = (int)ChartGetInteger(chart_id, CHART_VISIBLE_BARS);
   int start = first+1-count;
   
//--- массивы, куда будут скопированы таймсерии
   double   array_high[];
   double   array_low[];
   datetime array_time[];
   int      index;
   
//--- копируем в массивы три таймсерии в количестве count и начиная от start
   ResetLastError();
   if(CopySeries(symbol, PERIOD_CURRENT, start, count, COPY_RATES_TIME|COPY_RATES_HIGH|COPY_RATES_LOW, array_time, array_high, array_low)!=count)
     {
      PrintFormat("%s: CopySeries() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
   
//--- ищем индекс максимальной цены в массиве array_high
   index=ArrayMaximum(array_high);
   if(index<0)
     {
      PrintFormat("%s: ArrayMaximum() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- запомним наивысшую цену на видимом графике и значение времени бара, на которм находится эта цена
   price_high=array_high[index];
   time_high=array_time[index];
   
//--- ищем индекс минимальной цены в массиве array_low
   index=ArrayMinimum(array_low);
   if(index<0)
     {
      PrintFormat("%s: ArrayMinimum() failed. Error %d",__FUNCTION__, GetLastError());
      return(false);
     }
//--- запомним наименьшую цену на видимом графике и значение времени бара, на которм находится эта цена
   price_low=array_low[index];
   time_low=array_time[index];
   
//--- всё успешно
   return(true);
  }
//+------------------------------------------------------------------+
   