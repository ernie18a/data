//------------------------------------------------------------------------------------
//                                                                   CLinDrawMulti.mqh
//                                                                       2012, victorg
//                                                                 http://www.mql5.com
//------------------------------------------------------------------------------------

#include <Object.mqh>
#import "shell32.dll"
int ShellExecuteW(int hwnd,string lpOperation,string lpFile,string lpParameters,
                  string lpDirectory,int nShowCmd);
#import
#import "kernel32.dll"
int DeleteFileW(string lpFileName);
int MoveFileW(string lpExistingFileName,string lpNewFileName);
#import
//------------------------------------------------------------------------------------
// type = "line","spline","scatter"
// col  = "r,g,b,y"
// Leg  = "true","false"
// Reference: http://www.highcharts.com/
//------------------------------------------------------------------------------------
class CLinDrawMu:public CObject
  {
protected:
  int     Fhandle;           // File handle
  int     Num;               // Internal number of chart line
  string  Tit;               // Title chart
  string  SubTit;            // Subtitle chart
  string  Leg;               // Legend enable/disable
  string  Ytit;              // Title Y scale
  string  Xtit;              // Title X scale
  string  Fnam;              // File name
  
public:
  int     SpTop;
  int     SpBot;
  string  XLab;
  double  YMax;
  double  YMin;

  void    CLinDrawMu(void);
  void    Title(string s)      { Tit=s; }
  void    SubTitle(string s)   { SubTit=s; }
  void    Legend(string s)     { Leg=s; }
  void    YTitle(string s)     { Ytit=s; }
  void    XTitle(string s)     { Xtit=s; }
  int     AddGraph(double &x[],double &y[],string type,string name,int w=0,string col="");
  int     LDraw(int ashow=1);
  };
//------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------
void CLinDrawMu::CLinDrawMu(void)
  {
  YMax=0;
  YMin=0;
  XLab="false";
  SpTop=0;
  SpBot=0;
  Num=0;
  Tit="";
  SubTit="";
  Leg="true";
  Ytit="";
  Xtit="";
  Fnam="CLinDraw.txt";
  Fhandle=FileOpen(Fnam,FILE_WRITE|FILE_TXT|FILE_ANSI);
  if(Fhandle<0)
    {
    Print(__FUNCTION__,": Error! FileOpen() error.");
    return;
    }
  FileSeek(Fhandle,0,SEEK_SET);                               // if file exist
  }
//------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------
int CLinDrawMu::AddGraph(double &x[],double &y[],string type,string name,int w=0,string col="")
  {
  int i,k,n;
  string str,gnam;
  
  if(Fhandle<0)return(-1);
  str="";
  gnam="Gr"+(string)Num;
  if(Num==0)str="$(document).ready(function(){\n";
  str+="var lp=new Highcharts.Chart({\n"
  "chart:{renderTo:'"+gnam+"'";
  if(SpTop!=0)str+=",spacingTop:"+(string)SpTop;
  if(SpBot!=0)str+=",spacingBottom:"+(string)SpBot;
  str+="},\n"
  "exporting:{enabled:false},\n"
  "title:{text:''},\n"
  "subtitle:{text:''},\n"
  "legend:{enabled:"+Leg+"},\n";
  if(YMin==0&&YMax==0)
  str+="yAxis:{labels:{enabled:false},title:{text:'"+Ytit+"'}},\n";
  else
  str+="yAxis:{labels:{enabled:false},title:{text:'"+Ytit+"'},min:"+(string)YMin+",max:"+(string)YMax+"},\n";
  str+="xAxis:{labels:{enabled:"+XLab+"},title:{text:'"+Xtit+"'},showLastLabel:true},\n"
  "series:[\n";
  FileWriteString(Fhandle,str);

  n=ArraySize(x);
  str="{type:'"+type+"',name:'"+name+"',";
  if(col!="")str+="color:'rgba("+col+")',";
  if(w!=0)str+="lineWidth:"+(string)w+",";
  str+="data:[";
  k=0;
  for(i=0;i<n-1;i++)
    {
    str+=StringFormat("[%.5g,%.5g],",x[i],y[i]);
    if(20<k++){k=0; str+="\n";}
    }
  str+=StringFormat("[%.5g,%.5g]]}\n",x[n-1],y[n-1]);
  str+="]});\n";
  FileWriteString(Fhandle,str);
  Num++;
  return(0);
  }
//------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------
int CLinDrawMu::LDraw(int ashow=1)
  {
  int i,k;
  string str,pfnam,to,p[];
  
  str="var lp=new Highcharts.Chart({\n"
  "chart:{renderTo:'Empty'";
  str+="},\n"
  "exporting:{enabled:false},\n"
  "title:{text:'"+Tit+"'},\n"
  "subtitle:{text:'"+SubTit+"'},\n"
  "legend:{enabled:"+Leg+"}\n";
  str+="});\n";
  FileWriteString(Fhandle,str);
  
  FileWriteString(Fhandle,"\n});");
  if(Fhandle<0)return(-1);
  FileClose(Fhandle);
  
  pfnam=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+Fnam;
  k=StringSplit(MQL5InfoString(MQL5_PROGRAM_PATH),StringGetCharacter("\\",0),p);
  to="";
  for(i=0;i<k-1;i++)to+=p[i]+"\\";
  to+="ChartTools\\";                          // Folder name
  DeleteFileW(to+Fnam);
  MoveFileW(pfnam,to+Fnam);
  if(ashow==1)ShellExecuteW(NULL,"open",to+"LinDraw2.htm",NULL,NULL,1);
  return(0);
  }
//------------------------------------------------------------------------------------
