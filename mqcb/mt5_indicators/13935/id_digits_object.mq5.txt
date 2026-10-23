//+------------------------------------------------------------------+
//|                                             id_digits_object.mq5 |
//|                                                2016, Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
#property copyright   "2016, Dina Paches"
#property link        "https://www.mql5.com/ru/users/dipach"
#property version     "1.20"
#property description "When you click on a graphical object, this indicator"
#property description "shows in the tab of the trading terminal \"Experts\":"
#property description "- name and type the object;"
#property description "- time its anchor points;"
#property description "- the values of its anchor points;"
#property description "- the number of decimal digits in the anchor points."
#property indicator_chart_window
#property indicator_plots   0
//---
#define CHART_ID                   (0)
#define OBJ_TYPES_NUMBER           (34)
#define TRANSLATE_NUMBER           (6)
//+------------------------------------------------------------------+
int  OnInit(){return(INIT_SUCCEEDED);}
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
int  OnCalculate(const int    rates_total,
                 const int    prev_calculated,
                 const int    begin,
                 const double &price[])
  {return(rates_total);}
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)//id = 1
     {
      ActionsDependingOnTheObjectType(CHART_ID,sparam);
      return;
     }
   return;
  }
//+------------------------------------------------------------------+
void ActionsDependingOnTheObjectType(const long   chart_id,
                                     const string name_obj)
  {
//--- type ---
   int    index=-1;
   string text=TranslatedText(0);
//---
   InitTypeObj(chart_id,name_obj,index,text);
//---
   if(index==-1){Print(text);return;}
//--- price ------------------------------
   int number=LocalKeysPriceArray(index);
//---
   static double price_arr[];
   static int    digits_arr[];
//---
   ArrayResizeAndSetAsSeries(price_arr,number);
   ArrayResizeAndSetAsSeries(digits_arr,number);
//---
   PreparePriceData(chart_id,name_obj,price_arr,digits_arr);
//--- time -------------------------------
   number=LocalKeysTimeArray(index);
//---
   static datetime time_arr[];
   ArrayResizeAndSetAsSeries(time_arr,number);
//---
   PrepareTimeData(chart_id,name_obj,time_arr);
//--- text -------------------------------
   MessagePrint(time_arr,price_arr,digits_arr,text);
//--- clear ------------------------------
   ArrayFree(price_arr);
   ArrayFree(digits_arr);
   ArrayFree(time_arr);
//---
   return;
  }
//+------------------------------------------------------------------+
int  InitTypeObj(const long   chart_id,
                 const string name,
                 int          &index,
                 string       &text)
  {
   ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(chart_id,name,OBJPROP_TYPE);
//---
   StringConcatenate(text,text,name,TranslatedText(1),EnumToString(type));
//---
   index=LocalIndexTypeObjWithTimeAndPrice(type);
//---
   return(index);
  }
//+------------------------------------------------------------------+
void PrepareTimeData(const long   chart_id,
                     const string name,
                     datetime     &time_arr[])
  {
   for(int i=ArraySize(time_arr)-1;i>=0;i--)
     {time_arr[i]=(datetime)ObjectGetInteger(chart_id,name,OBJPROP_TIME,i);}
//---
   return;
  }
//+------------------------------------------------------------------+
void PreparePriceData(const long   chart_id,
                      const string name,
                      double       &price_arr[],
                      int          &digits_arr[])

  {
   int size=ArraySize(price_arr);
//---
   for(int i=size-1;i>=0;i--){price_arr[i]=ObjectGetDouble(chart_id,name,OBJPROP_PRICE,i);}
//---
   for(int i=size-1;i>=0;i--){digits_arr[i]=NumberOfDigitsGet(price_arr[i]);}
//---
   return;
  }
//+------------------------------------------------------------------+
//|NumberOfDigitsGet - number of digits after decimal point          |
//+------------------------------------------------------------------+
//|2015, Dina Paches (Updated: 2016.12.12)                           |
//|dipaches.blogspot.com                                             |
//|https://login.mql5.com/ru/users/dipach                            |
//+------------------------------------------------------------------+
int NumberOfDigitsGet(const double value,
                      const int   digits=8)//<= F1: NormalizeDouble() to 8
  {
   int dig=(digits<1 || digits>8) ? 8 : digits;
//---
   if(NormalizeDouble(value,dig)==0){return(0);}
//---
   double val=value;
//---
   if(NormalizeDouble(val,dig)<0){val=MathAbs(val);}
//---
   double int_value=MathFloor(val);
//---
   val=NormalizeDouble(val-int_value,dig);
//---
   if(NormalizeDouble(val,dig)==0){return(0);}
//---
   int point_pow=(int)MathPow(10,dig);
   int variable=(int)(NormalizeDouble(val*point_pow,0));
//---
   string text  =IntegerToString(variable);
   variable     =StringLen(text);
//---
   for(int i=variable-1;i>=0;i--)
     {
      if(StringFind(text,"0",i)==i){dig--;}
      else {return(dig);}
     }
//---
   return(dig);
  }
//+------------------------------------------------------------------+
template<typename T>
//+------------------------------------------------------------------+
void ArrayResizeAndSetAsSeries(T          &array[],
                               const int  new_size,
                               const int  reserve_size=-1,
                               const bool flag=true)
  {
   ArrayResize(array,new_size,reserve_size);
   if(new_size>1){ArraySetAsSeries(array,flag);}
   return;
  }
//+------------------------------------------------------------------+
//|Messages:                                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void TextTimeSet(const datetime time,const int index,string &text)
  {
   StringConcatenate(text,TranslatedText(2),"(",IntegerToString(index),"): ",
                     TimeToString(time,TIME_DATE|TIME_SECONDS),". ");
   return;
  }
//+------------------------------------------------------------------+
string TextPriceAndDigitsSet(const double price,
                             const int    digits,
                             const int    index)
  {
   string text=TranslatedText(4);
//---
   DigitsTextSet(digits,text);
//---
   StringConcatenate(text,TranslatedText(3),"(",IntegerToString(index),"): ",
                     DoubleToString(price,digits),text,IntegerToString(digits));
//---
   return(text);
  }
//+------------------------------------------------------------------+
string DigitsTextSet(const int digits,string &text)
  {
//---
   if(digits>=8){StringAdd(text,">= ");}
   else{StringAdd(text,"= ");}
//---
   return(text);
  }
//+------------------------------------------------------------------+
void MessagePrint(const datetime &time_arr[],
                  const double   &price_arr[],
                  const int      &digits_arr[],
                  string         &text)
  {
   int time_size  =ArraySize(time_arr);
   int price_size =ArraySize(price_arr);
//---
   Print(text);
//---
   for(int i=0;i<time_size;i++)
     {
      TextTimeSet(time_arr[i],i,text);
      //---
      if(price_size>0)
        {
         string add=TextPriceAndDigitsSet(price_arr[i],digits_arr[i],i);
         //---
         StringAdd(text,add);
         //---
         price_size--;
        }
      //---
      Print(text);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
string TranslatedText(const int index)
  {
   static string text_arr[TRANSLATE_NUMBER];
   static bool   first=true;
//---
   if(first){TerminalLanguage(text_arr); first=false;}
   return(text_arr[index]);
  }
//+------------------------------------------------------------------+
void  TerminalLanguage(string &text_arr[])
  {
   string language=TerminalInfoString(TERMINAL_LANGUAGE);
//---
   if(language=="Russian")
     {
      text_arr[0]="Имя объекта: ";
      text_arr[1]=", тип: ";
      text_arr[2]="Дата";
      text_arr[3]="Значение";
      text_arr[4]=", digits ";
      text_arr[5]="Я не работаю с таким типом объектов:";
     }
   else
     {
      text_arr[0]="Object name: ";
      text_arr[1]=", type: ";
      text_arr[2]="Date";
      text_arr[3]="Value";
      text_arr[4]=", digits ";
      text_arr[5]="I don't work with this type of objects:";
     }
   return;
  }
//+------------------------------------------------------------------+
//|Local keys:                                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int LocalIndexTypeObjWithTimeAndPrice(const ENUM_OBJECT type)
  {
   static long  type_arr[OBJ_TYPES_NUMBER]=
     {
      OBJ_HLINE,OBJ_TREND,OBJ_TRENDBYANGLE,OBJ_CYCLES,OBJ_ARROWED_LINE,
      OBJ_CHANNEL,OBJ_PITCHFORK,OBJ_GANNLINE,OBJ_GANNFAN,OBJ_GANNGRID,
      OBJ_FIBO,OBJ_FIBOTIMES,OBJ_FIBOFAN,OBJ_FIBOARC,OBJ_FIBOCHANNEL,
      OBJ_EXPANSION,OBJ_ELLIOTWAVE5,OBJ_ELLIOTWAVE3,OBJ_RECTANGLE,OBJ_TRIANGLE,
      OBJ_ELLIPSE,OBJ_ARROW_THUMB_UP,OBJ_ARROW_THUMB_DOWN,OBJ_ARROW_UP,OBJ_ARROW_DOWN,
      OBJ_ARROW_STOP,OBJ_ARROW_CHECK,OBJ_ARROW_LEFT_PRICE,OBJ_ARROW_RIGHT_PRICE,OBJ_ARROW_BUY,
      OBJ_ARROW_SELL,OBJ_ARROW,OBJ_TEXT,-1
     };
//---
   int i=0;
//---
   while(i<OBJ_TYPES_NUMBER)
     {
      if(type==type_arr[i]){break;}
      i++;
     }
//---
   if(i<OBJ_TYPES_NUMBER-1){return(i);}
   else{Print(TranslatedText(5));}
//---
   return(-1);
  }
//+------------------------------------------------------------------+
int LocalKeysPriceArray(const int index)
  {
   static int price_number_arr[OBJ_TYPES_NUMBER-1]=
     {1,2,2,2,2,3,3,1,1,1,2,2,2,2,3,3,5,3,2,3,3,1,1,1,1,1,1,1,1,1,1,1,1};
   return(price_number_arr[index]);
  }
//+------------------------------------------------------------------+
int LocalKeysTimeArray(const int index)
  {
   static int  time_number_arr[OBJ_TYPES_NUMBER-1]=
     {1,2,2,2,2,3,3,2,2,2,2,2,2,2,3,3,5,3,2,3,3,1,1,1,1,1,1,1,1,1,1,1,1};
   return(time_number_arr[index]);
  }
//+------------------------------------------------------------------+
