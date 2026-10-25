//+------------------------------------------------------------------+  
//|                                   ToClearObjectsByTypeByTime.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Скрипт очищает все графики терминала от объектов выбранного типа, которые старше количества дней, определяемых уровнем срабатывания"
#property script_show_confirm //потверждение действия скрипта трейдером
#property script_show_inputs //показывать входные параметры
//+-----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ СКРИПТА                    |
//+-----------------------------------------------+
input ENUM_OBJECT OBJ_TYPE=-1;    //Тип удаляемых объектов
input uint TimeLevel=10;          //уровень срабатывания в днях
//+-----------------------------------------------+

//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//---- Удаление всех объектов выбранного типа со всех графиков
   int TimeLevelSecond=int(TimeLevel)*60*60*24;
   long currChart=ChartFirst();
   while(currChart>-1)
     {
      int total=ObjectsTotal(currChart,-1,OBJ_TYPE);

      for(int pos=total-1; pos>=0; pos--)
        {
         string name=ObjectName(currChart,pos,-1,OBJ_TYPE);
         datetime time=NULL;
         for(int count=29; count>=0; count--) time=MathMax(datetime(ObjectGetInteger(currChart,name,OBJPROP_TIME,count)),time);
         if(TimeCurrent()-time>TimeLevelSecond) ObjectDelete(currChart,name);
        }
      currChart=ChartNext(currChart); //на основании предыдущего получим новый график 
      if(currChart<0) break;          //достигли конца списка графиков      
     }
//----
  }
//+------------------------------------------------------------------+
