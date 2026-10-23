#property copyright "© 2005-2007 RickD"
#property link      "www.e2e-fx.net"

#define major   1
#define minor   0

#import "user32.dll"
int SendMessageW(int hWnd,int Msg,int wParam,int lParam);
int FindWindowW(int lpClassName,string lpWindowName);

#import "kernel32.dll"
int GlobalAddAtomW(string str);
int GlobalDeleteAtom(int atom);
int GlobalGetAtomNameW(int atom,int &buf[],int size);
#import

#define FormClass NULL
#define WND_NAME  "MT4.DDE.2"

#define WM_USER         0x0400
#define WM_CHECKITEM    0x0401
#define WM_ADDITEM      0x0402
#define WM_SETITEM      0x0403

double      MA[];        // array for the indicator iMA
int         MA_handle;  // handle of the indicator iMA
//-----------------------------------------------------------------------------

void OnInit()
  {
    EventSetTimer(1);
    
//--- creation of the indicator iMA
   MA_handle=iMA(NULL,0,21,0,MODE_EMA,PRICE_CLOSE);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- filling an array MA[] with current values of iMA
//--- Copying 100 elements
   CopyBuffer(MA_handle,0,0,100,MA);
   ArraySetAsSeries(MA,true);

// Check & Add Item DDE
   if(!CheckItem("A","B")) 
     {
      if(!AddItem("A","B")) return; 
     }

   if(!CheckItem("COMPANY","Value")) AddItem("COMPANY","Value");
   if(!CheckItem("TIME","Value")) AddItem("TIME","Value");

// Set Item Value DDE  
   SetItem("COMPANY","Value",(string)AccountInfoString(ACCOUNT_COMPANY));
   SetItem("TIME","Value",(string)TimeCurrent());

   SetItem("A","B","EMA(21): "+DoubleToString(MA[0],6));

  }
  
void OnDeinit(const int reason)
      {
       EventKillTimer();
      }  
//-------------------------------------------------------------------------------

bool CheckItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0) 
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_CHECKITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[CheckItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AddItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0) 
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_ADDITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[AddItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetItem(string topic,string item,string val)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item= GlobalAddAtomW(topic+"!"+item);
   if(_item == 0)
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int _val= GlobalAddAtomW(val);
   if(_val == 0)
     {
      Alert("Cannot create "+val+" atom!");
      GlobalDeleteAtom(_item);
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_SETITEM,_item,_val);
   GlobalDeleteAtom(_val);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[SetItem] "+str);
     }

   return(false);
  }
//-----------------------------------------------------------------------------

int LOWORD(int val)
  {
   return((val>>16)  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HIWORD(int val)
  {
   return(val  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MakeStr(int &buf[],int cnt)
  {
   string str="";
   int ch=-1;

   for(int i=0; i<cnt; i++) 
     {
      if(i%4 == 0) ch = buf[i/4] & 0xFF;
      if(i%4 == 1) ch = (buf[i/4] >> 8) & 0xFF;
      if(i%4 == 2) ch = (buf[i/4] >> 16) & 0xFF;
      if(i%4 == 3) ch = (buf[i/4] >> 24) & 0xFF;

      str=str+CharToString((uchar)ch);
     }

   return(str);
  }
//+------------------------------------------------------------------+
