//+------------------------------------------------------------------+
//|                               SaveAndShowTestingChartObjects.mq5 |
//|                                           Copyright 2018,fxMeter |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
//https://www.mql5.com/en/code/22163
#property copyright "Copyright 2018,fxMeter"
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "1.00"
#property  script_show_inputs
#include <ChartObjects\ChartObject.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SAVE_SHOW  {SAVE,SHOW};
input string FileName="Testing Chart Objects";
input ENUM_SAVE_SHOW SaveOrShow=SAVE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TestingChartObject :public CChartObject
  {
public:
                     TestingChartObject(void){};
                    ~TestingChartObject(void){};
   bool              SaveObj(const int file_handle,string objName,int type);
   bool              LoadObj(const int file_handle);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TestingChartObject::SaveObj(const int file_handle,string objName,int type)
  {
   m_name=objName;
   FileWriteString(file_handle,m_name,64);
   FileWriteInteger(file_handle,type);
   CChartObject::Save(file_handle);
//--selected,fill
   FileWriteInteger(file_handle,Selected());
   FileWriteInteger(file_handle,Fill());

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TestingChartObject::LoadObj(const int file_handle)
  {
   m_chart_id=ChartID();
   m_name=FileReadString(file_handle,64);
   int type=FileReadInteger(file_handle);
   ObjectCreate(m_chart_id,m_name,(ENUM_OBJECT)type,0,0,0);
   CChartObject::Load(file_handle);
//--selected,fill
   Selected(FileReadInteger(file_handle));
   Fill(FileReadInteger(file_handle));
   return(true);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string fileName=FileName+".bin";
   int handle=-1;
   if(SaveOrShow==0)handle=FileOpen(fileName,FILE_WRITE|FILE_ANSI|FILE_BIN);
   else handle=FileOpen(fileName,FILE_READ|FILE_ANSI|FILE_BIN);
   if(handle==-1)return;

//-------------------------------------------------------------------------------------- SHOW
   if(SaveOrShow==SHOW)
     {
      TestingChartObject *chart_obj=new TestingChartObject();
      while(!FileIsEnding(handle))
        {
         chart_obj.LoadObj(handle);
        }
      //Do NOT delete chart_obj;
      FileClose(handle);
      return;
     }

//-------------------------------------------------------------------------------------- SAVE

   CArrayObj *obj=new CArrayObj();

   for(int i=ObjectsTotal(0)-1;i>=0;i--)
     {
      TestingChartObject *chart_obj=new TestingChartObject();
      string name=ObjectName(0,i);
      chart_obj.Attach(0,name,0,3);
      obj.Add(chart_obj);
     }

   int total=obj.Total();

   for(int i=0;i<total;i++)
     {
      string name=((TestingChartObject*)obj.At(i)).Name();
      int type=(int)ObjectGetInteger(0,name,OBJPROP_TYPE);
      ((TestingChartObject*)obj.At(i)).SaveObj(handle,name,type);
     }
   FileClose(handle);

//Do NOT delete obj;

  }
//+------------------------------------------------------------------+
