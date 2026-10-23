//+------------------------------------------------------------------+
//|                                            DeleteTradeArrows.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window

//--- input parameters
input bool     del_pending=true;             // удалять отложенники?
input datetime del_before_date;              // удалять объекты до даты
input datetime del_after_date;               // удалять объекты после даты
input bool     print_every_deletion=false;   // сообщать об удаленных объектах?
bool bool_del_before=false;
bool bool_del_after=false;

string object_names[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   PrintFormat("%s: удалять отложенные - %s",__FUNCTION__,string(del_pending));
   PrintFormat("%s:  del_before_date=%s",__FUNCTION__,TimeToString(del_before_date));
   PrintFormat("%s:  del_after_date=%s",__FUNCTION__,TimeToString(del_after_date));
//--- отладка
//PrintFormat("del_before_date=%d",long(del_before_date));
//PrintFormat("del_after_date=%d",long(del_after_date));
   Comment("Objects on chart=",ObjectsTotal(0));
//--- создадим флаги для удаления по дате
   bool_del_before=(long(del_before_date));
   bool_del_after=(long(del_after_date));
   Print("bool_del_before=",bool_del_before);
   Print("bool_del_after=",bool_del_after);
   ArrayResize(object_names,ObjectsTotal(0));
   ZeroMemory(object_names);
//---   
   return(INIT_SUCCEEDED);
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
//---
   static bool first_run=true;
//--- гарантируем запуск/удаление только в первый вызов
   if(first_run)
      first_run=false;
   else
      return(0);
//--- удаляем отложенники
   int pending_deleted=0;
   int to_delete_object_name_count=0;
   int total=ObjectsTotal(0);
   string name;
   if(del_pending)
     {
      for(int i=total;i>-0;i--)
        {
         name=ObjectName(0,i);
         ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(0,name,OBJPROP_TYPE);
         if(type==OBJ_ARROW)
           {
            if((StringFind(name,"buy limit")!=-1) || (StringFind(name,"buy stop")!=-1) || (StringFind(name,"sell limit")!=-1) || (StringFind(name,"sell stop")!=-1))
              {
               string order_id=GetOrderID(name);
               //Print(i," - объект ",name,"   type=",type,"   id=",order_id);
               //--- добавим в массив еще один префикс для удаления объектов с таким же order_id  
               if(order_id!="")
                 {
                  object_names[to_delete_object_name_count]=order_id;
                  to_delete_object_name_count++;
                 }
               //---
               if(ObjectDelete(0,name))
                 {
                  if(print_every_deletion)
                     Print(__FUNCTION__,": ",pending_deleted,". deleted ",name,"   type=",type,"   id=",order_id);
                  pending_deleted++;
                 }
              }
           }
        }
      PrintFormat("Deleted %d arrows",pending_deleted);
      //--- теперь удалим линии,  которые идут к отложенникам
      pending_deleted=0;
      //Print("to_delete_object_name_count=",to_delete_object_name_count);
      if(to_delete_object_name_count>0)
        {
         for(int i=to_delete_object_name_count;i>=0;i--)
           {
            if(DeleteObjectByPrefix(object_names[i]))
              {
               pending_deleted++;
              }
           }
         PrintFormat("Deleted %d trendlines",pending_deleted);
        }
     }

//--- удаляем стрелки до указанной даты
   if(bool_del_before)
     {
      int arrow_deleted=0;
      total=ObjectsTotal(0);
      datetime arrow_time;
      for(int i=total;i>-0;i--)
        {
         name=ObjectName(0,i);
         arrow_time=(datetime)ObjectGetInteger(0,name,OBJPROP_TIME);
         if(arrow_time<del_before_date)
           {
            if(ObjectDelete(0,name))
              {
               if(print_every_deletion)
                 {
                  //PrintFormat(__FUNCTION__,": ",arrow_deleted,". deleted ",name,"   type=",type,"   id=",order_id);
                  PrintFormat("%s: %d. deleted %s - %s",__FUNCTION__,i,TimeToString(arrow_time),name);
                  arrow_deleted++;
                 }
              }
           }
        }
      PrintFormat("Deleted before %s => %d objects",TimeToString(del_before_date),arrow_deleted);
     }
//--- удаляем стрелки после указанной даты
   if(bool_del_after)
     {
      int arrow_deleted=0;
      total=ObjectsTotal(0);
      datetime arrow_time;
      for(int i=total;i>-0;i--)
        {
         name=ObjectName(0,i);
         arrow_time=(datetime)ObjectGetInteger(0,name,OBJPROP_TIME);
         if(arrow_time>del_after_date)
           {
            if(ObjectDelete(0,name))
              {
               if(print_every_deletion)
                 {
                  //PrintFormat(__FUNCTION__,": ",arrow_deleted,". deleted ",name,"   type=",type,"   id=",order_id);
                  PrintFormat("%s: %d. deleted %s - %s",__FUNCTION__,i,TimeToString(arrow_time),name);
                  arrow_deleted++;
                 }
              }
           }
        }
      PrintFormat("Deleted after %s => %d objects",TimeToString(del_before_date),arrow_deleted);
     }
   string comment=StringFormat("Objects on chart=%d",ObjectsTotal(0));
   comment=comment+"\r\n"+StringFormat("delete pending==%s",(string)del_pending);
   if(bool_del_before)
      comment=comment+"\r\n"+StringFormat("delete before %s",TimeToString(del_before_date));
   if(bool_del_after)
      comment=comment+"\r\n"+StringFormat("delete after %s",TimeToString(del_after_date));
   comment=comment+"\r\n"+StringFormat("delete pending==%s",(string)del_pending);
   Comment(comment);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| находит в имени объекта ID ордера                                |
//+------------------------------------------------------------------+
string GetOrderID(string arrow_name)
  {
   string id="";
   int id_pos=-1;
//--- имя объекта-стрелки с номеров ордера всегда начинается с символа решетки #
   if((id_pos=StringFind(arrow_name,"#"))!=-1)
     {
      int pos=StringFind(arrow_name," ",id_pos);
      id=StringSubstr(arrow_name,0,pos);
     }
   return id;
  }
//+------------------------------------------------------------------+
//| удаляет объекты с указанным префиксом в имени                    |
//+------------------------------------------------------------------+
bool DeleteObjectByPrefix(string prefix)
  {
   bool res=false;
//---
   int total=ObjectsTotal(0);
   string name;
   for(int i=total;i>-0;i--)
     {
      name=ObjectName(0,i);
      if(StringFind(name,prefix)==0)
        {
         if(res=ObjectDelete(0,name))
           {
            if(print_every_deletion)
               Print(__FUNCTION__,":  deleted ",name);
           }
        }
     }
   return res;
  }
//+------------------------------------------------------------------+
