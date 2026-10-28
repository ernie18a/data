//+------------------------------------------------------------------+
//|                                                   读写EA测试图表对象.mq4 |
//|                                          Copyright 2017,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
//2018-02-13 13:05:24 submit to code base
//https://www.mql5.com/en/code/20001
/*
This script is designed to save the objects of testing chart into a bin file
and read the bin file to show these objects on another chart.
object type: trend line and arrow(4 arrow types:open order,close order,TP,SL)
*/

//2017-11-20 01:29:54 EA测试完后把图表上的箭头,线等保存到文件,再另外的图表上展示出来。
/*
trend line
arrow(开仓,平仓,止盈,止损)
*/
#property copyright "Copyright 2017,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "1.00"
#property strict
#property show_inputs
input string FileName="TestingChart Objects";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SAVE_SHOW
  {
   SAVE,
   SHOW
  };

input ENUM_SAVE_SHOW SaveOrShow=SAVE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TestingChartObjects
  {
   string            name;            //object name
   string            descriptions;    //object description
   int               type;        //object type: arrow or trend line
   int               code;          //arrow code: OBJPROP_ARROWCODE
   int               t1;
   int               t2;
   int               clr;
   double            p1;
   double            p2;
  };

TestingChartObjects obj[];
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string fileName=FileName+".bin";
   int handle=-1;

//----save objects into file
   if(SaveOrShow==0)
     {
      //--- analyse objects 
      int cnt=ObjectsTotal();
      ArrayResize(obj,cnt);
      for(int i=0;i<cnt;i++)
        {
         string n=ObjectName(i);
         obj[i].name=n;
         obj[i].descriptions=ObjectDescription(n);
         obj[i].type=ObjectType(n);
         if(obj[i].type==OBJ_ARROW)
            obj[i].code=(int)ObjectGetInteger(0,n,OBJPROP_ARROWCODE);
         else obj[i].code=-1;
         obj[i].t1=(int)ObjectGetInteger(0,n,OBJPROP_TIME1);
         obj[i].t2=(int)ObjectGetInteger(0,n,OBJPROP_TIME2);
         obj[i].clr=(int)ObjectGetInteger(0,n,OBJPROP_COLOR);
         obj[i].p1=ObjectGetDouble(0,n,OBJPROP_PRICE1);
         obj[i].p2=ObjectGetDouble(0,n,OBJPROP_PRICE2);
        }

      // save obj[] into file
      handle=FileOpen(fileName,FILE_BIN|FILE_WRITE);
      if(handle==-1)
        {
         Alert("Open file error,file name:",fileName);
         return;
        }

      for(int i=0;i<cnt;i++)
        {
         //---Write bin file
         FileWriteString(handle,obj[i].name,64);
         FileWriteString(handle,obj[i].descriptions,64);
         FileWriteInteger(handle,obj[i].type);
         FileWriteInteger(handle,obj[i].code);
         FileWriteInteger(handle,obj[i].t1);
         FileWriteInteger(handle,obj[i].t2);
         FileWriteInteger(handle,obj[i].clr);
         FileWriteDouble(handle,obj[i].p1);
         FileWriteDouble(handle,obj[i].p2);
        }
      FileClose(handle);

      return;
     }//SaveOrShow==SAVE

//--- SaveOrShow==SHOW : read bin file and draw objects on chart
   handle=FileOpen(fileName,FILE_BIN|FILE_READ);
   if(handle==-1)
     {
      Alert("Open file error,file name:",fileName);
      return;
     }

   while(!FileIsEnding(handle))
     {
      string            name=FileReadString(handle,64);
      string            descriptions=FileReadString(handle,64);
      int               type=FileReadInteger(handle);
      int               code=FileReadInteger(handle);
      int               t1=FileReadInteger(handle);
      int               t2=FileReadInteger(handle);
      int               clr=FileReadInteger(handle);
      double            p1=FileReadDouble(handle);
      double            p2=FileReadDouble(handle);
      if(type==OBJ_TREND)CreateTrendLine(name,t1,t2,p1,p2,clr);
      if(type==OBJ_ARROW)CreateArrow(name,descriptions,t1,p1,code,clr);

     }

   FileClose(handle);

  }
//+------------------------------------------------------------------+
void CreateTrendLine(string name,int t1,int t2,double p1,double p2,int clr)
  {
   ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,(color)clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateArrow(string name,string desc,int t1,double p1,int code,int clr)
  {
   ObjectCreate(0,name,OBJ_ARROW,0,t1,p1);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,code);
   ObjectSetInteger(0,name,OBJPROP_COLOR,(color)clr);
//arrow code==1: this arrow is for opening order, it has a description text
   if(code==1)
     {
      ObjectSetString(0,name,OBJPROP_TEXT,desc);
     }
  }
//+------------------------------------------------------------------+
