//+------------------------------------------------------------------+
//|                                             PASSWORD MANAGER.mq5 |
//|                                  Copyright 2023, Igor Gerasimov. |
//|                                                 tgwls2@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Igor Gerasimov."
#property link      "tgwls2@gmail.com"
#property version   "1.00"
#property script_show_inputs
input string      PFX="PSW_";             // File Prefix
input const uchar LGT=8,                  // Passw Length
                  STP=10,                 // Randm Step
                  SIZ=10;                 // Text Size
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    MathSrand(GetTickCount());
    {
        const double R=GetRand();
        MathSrand((int)MathRound((R>=0?(R<=1?R:1):0)*INT_MAX));
    }
    const int w=(int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/(double)5),
              h=(int)(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0)/(double)4),
              ws=w-1,
              hs=h-1;
    string olx="",oly="",cux="",cuy="",nex="",ney="";
    if(FileIsExist(PFX+(string)AccountInfoInteger(ACCOUNT_LOGIN)+".csv"))
        {
            const int fle=FileOpen(PFX+(string)AccountInfoInteger(ACCOUNT_LOGIN)+".csv",FILE_READ|FILE_CSV);
            olx=FileReadString(fle);
            oly=FileReadString(fle);
            cux=FileReadString(fle);
            cuy=FileReadString(fle);
            nex=FileReadString(fle);
            ney=FileReadString(fle);
            FileClose(fle);
        }
    EditCreate(PFX+"AcN",1,1,ws,hs,"ACCOUNT",SIZ,true,clrRed,clrOrange,clrBlue);
    EditCreate(PFX+"AcC",w,1,ws,hs,(string)AccountInfoInteger(ACCOUNT_LOGIN),SIZ,true,clrLime,clrOrange,clrRed);
    ButtonCreate(PFX+"Nxt",w*2,1,(int)(w*1.5-1),hs,"NEXT",SIZ,false,clrBlue,clrOrange,clrRed);
    ButtonCreate(PFX+"Sve",(int)(w*3.5),1,(int)(w*1.5-1),hs,"SAVE",SIZ,false,clrRed,clrOrange,clrBlue);
    EditCreate(PFX+"OlN",1,h,ws,hs,"OLD",SIZ,true,clrBlue,clrRed,clrLime);
    EditCreate(PFX+"OlT",w,h,ws,hs,"TRADER",SIZ,true,clrBlack,clrRed,clrLime);
    EditCreate(PFX+"OlX",w*2,h,ws,hs,olx,SIZ,false,clrBlue,clrRed,clrLime);
    EditCreate(PFX+"OlI",w*3,h,ws,hs,"INVESTOR",SIZ,true,clrBlack,clrRed,clrLime);
    EditCreate(PFX+"OlY",w*4,h,ws,hs,oly,SIZ,false,clrBlue,clrRed,clrLime);
    EditCreate(PFX+"CuN",1,h*2,ws,hs,"CUR",SIZ,true,clrRed,clrLime,clrBlue);
    EditCreate(PFX+"CuT",w,h*2,ws,hs,"TRADER",SIZ,true,clrBlack,clrLime,clrBlue);
    EditCreate(PFX+"CuX",w*2,h*2,ws,hs,cux,SIZ,false,clrRed,clrLime,clrBlue);
    EditCreate(PFX+"CuI",w*3,h*2,ws,hs,"INVESTOR",SIZ,true,clrBlack,clrLime,clrBlue);
    EditCreate(PFX+"CuY",w*4,h*2,ws,hs,cuy,SIZ,false,clrRed,clrLime,clrBlue);
    ButtonCreate(PFX+"NeN",1,h*3,ws,hs,"NEW",SIZ,true,clrLime,clrBlue,clrRed);
    ButtonCreate(PFX+"NeT",w,h*3,ws,hs,"TRADER",SIZ,true,clrBlack,clrBlue,clrRed);
    nex=GetRstr();
    EditCreate(PFX+"NeX",w*2,h*3,ws,hs,nex,SIZ,false,clrLime,clrBlue,clrRed);
    ButtonCreate(PFX+"NeI",w*3,h*3,ws,hs,"INVESTOR",SIZ,true,clrBlack,clrBlue,clrRed);
    ney=GetRstr();
    EditCreate(PFX+"NeY",w*4,h*3,ws,hs,ney,SIZ,false,clrLime,clrBlue,clrRed);
    ChartRedraw(0);
    string cgx=cux,cgy=cuy;
    while(!IsStopped())
        {
            if(ObjectGetInteger(0,PFX+"NeN",OBJPROP_STATE))
                {
                    nex=GetRstr();
                    ney=GetRstr();
                    ObjectSetString(0,PFX+"NeX",OBJPROP_TEXT,nex);
                    ObjectSetString(0,PFX+"NeY",OBJPROP_TEXT,ney);
                    ObjectSetInteger(0,PFX+"NeN",OBJPROP_STATE,false);
                    ChartRedraw(0);
                }
            else if(ObjectGetInteger(0,PFX+"NeT",OBJPROP_STATE))
                {
                    nex=GetRstr();
                    ObjectSetString(0,PFX+"NeX",OBJPROP_TEXT,nex);
                    ObjectSetInteger(0,PFX+"NeT",OBJPROP_STATE,false);
                    ChartRedraw(0);
                }
            else if(ObjectGetInteger(0,PFX+"NeI",OBJPROP_STATE))
                {
                    ney=GetRstr();
                    ObjectSetString(0,PFX+"NeY",OBJPROP_TEXT,ney);
                    ObjectSetInteger(0,PFX+"NeI",OBJPROP_STATE,false);
                    ChartRedraw(0);
                }
            else if(ObjectGetInteger(0,PFX+"Nxt",OBJPROP_STATE))
                {
                    cux=ObjectGetString(0,PFX+"CuX",OBJPROP_TEXT);
                    cuy=ObjectGetString(0,PFX+"CuY",OBJPROP_TEXT);
                    if(cux!="" && cuy!="")
                        {
                            olx=cux;
                            oly=cuy;
                            cux=nex;
                            cuy=ney;
                            nex=GetRstr();
                            ney=GetRstr();
                            ObjectSetString(0,PFX+"OlX",OBJPROP_TEXT,olx);
                            ObjectSetString(0,PFX+"OlY",OBJPROP_TEXT,oly);
                            ObjectSetString(0,PFX+"CuX",OBJPROP_TEXT,cux);
                            ObjectSetString(0,PFX+"CuY",OBJPROP_TEXT,cuy);
                            ObjectSetString(0,PFX+"NeX",OBJPROP_TEXT,nex);
                            ObjectSetString(0,PFX+"NeY",OBJPROP_TEXT,ney);
                        }
                    else
                        {
                            MessageBox("FILL CURRENT PASSWORDS","!!!WARNING!!!",MB_OK);
                        }
                    ObjectSetInteger(0,PFX+"Nxt",OBJPROP_STATE,false);
                    ChartRedraw(0);
                }
            else if(ObjectGetInteger(0,PFX+"Sve",OBJPROP_STATE))
                {
                    cux=ObjectGetString(0,PFX+"CuX",OBJPROP_TEXT);
                    cuy=ObjectGetString(0,PFX+"CuY",OBJPROP_TEXT);
                    if(cux!="" && cuy!="")
                        {
                            olx=ObjectGetString(0,PFX+"OlX",OBJPROP_TEXT);
                            oly=ObjectGetString(0,PFX+"OlY",OBJPROP_TEXT);
                            nex=ObjectGetString(0,PFX+"NeX",OBJPROP_TEXT);
                            ney=ObjectGetString(0,PFX+"NeY",OBJPROP_TEXT);
                            const int fle=FileOpen(PFX+(string)AccountInfoInteger(ACCOUNT_LOGIN)+".csv",FILE_WRITE|FILE_CSV);
                            FileWriteString(fle,olx+"\n");
                            FileWriteString(fle,oly+"\n");
                            FileWriteString(fle,cux+"\n");
                            FileWriteString(fle,cuy+"\n");
                            FileWriteString(fle,nex+"\n");
                            FileWriteString(fle,ney+"\n");
                            FileClose(fle);
                        }
                    else
                        {
                            MessageBox("FILL CURRENT PASSWORDS","!!!WARNING!!!",MB_OK);
                        }
                    cgx=cux;
                    cgy=cuy;
                    ObjectSetInteger(0,PFX+"Sve",OBJPROP_COLOR,clrRed);
                    ObjectSetInteger(0,PFX+"Sve",OBJPROP_BGCOLOR,clrOrange);
                    ObjectSetInteger(0,PFX+"Sve",OBJPROP_STATE,false);
                    ChartRedraw(0);
                }
            if(cgx!=ObjectGetString(0,PFX+"CuX",OBJPROP_TEXT) ||
                    cgy!=ObjectGetString(0,PFX+"CuY",OBJPROP_TEXT))
                {
                    ObjectSetInteger(0,PFX+"Sve",OBJPROP_COLOR,clrOrange);
                    ObjectSetInteger(0,PFX+"Sve",OBJPROP_BGCOLOR,clrRed);
                    ChartRedraw(0);
                }
            Sleep(99);
        }
    if(cgx!=ObjectGetString(0,PFX+"CuX",OBJPROP_TEXT) ||
            cgy!=ObjectGetString(0,PFX+"CuY",OBJPROP_TEXT))
        {
            const uchar msg=(uchar)MessageBox("Would you like to save the changes?","UNSAVED CHANGES",MB_YESNO);
            while(true)
                {
                    if(msg==6)
                        {
                            cux=ObjectGetString(0,PFX+"CuX",OBJPROP_TEXT);
                            cuy=ObjectGetString(0,PFX+"CuY",OBJPROP_TEXT);
                            if(cux!="" && cuy!="")
                                {
                                    olx=ObjectGetString(0,PFX+"OlX",OBJPROP_TEXT);
                                    oly=ObjectGetString(0,PFX+"OlY",OBJPROP_TEXT);
                                    nex=ObjectGetString(0,PFX+"NeX",OBJPROP_TEXT);
                                    ney=ObjectGetString(0,PFX+"NeY",OBJPROP_TEXT);
                                    const int fle=FileOpen(PFX+(string)AccountInfoInteger(ACCOUNT_LOGIN)+".csv",FILE_WRITE|FILE_CSV);
                                    FileWriteString(fle,olx+"\n");
                                    FileWriteString(fle,oly+"\n");
                                    FileWriteString(fle,cux+"\n");
                                    FileWriteString(fle,cuy+"\n");
                                    FileWriteString(fle,nex+"\n");
                                    FileWriteString(fle,ney+"\n");
                                    FileClose(fle);
                                }
                            else
                                {
                                    MessageBox("FILL CURRENT PASSWORDS","!!!WARNING!!!",MB_OK);
                                }
                            break;
                        }
                    else break;
                    Sleep(99);
                }
        }
    ObjectsDeleteAll(0,PFX);
    ChartRedraw(0);
}
//+------------------------------------------------------------------+
//| GetRstr                                                          |
//+------------------------------------------------------------------+
string GetRstr()
{
    const string A[300]= {",",".","\'","~","!","@","#","$","%","^","&","*","(",")","_","+","-","=","{","[","}","]",":",";","\"","'","|","\\","<",">","?","/",
                          "0","1","2","3","4","5","6","7","8","9","8","7","6","5","4","3","2","1","0","9",
                          "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                          "9","8","7","6","5","4","3","2","1","0","1","2","3","4","5","6","7","8","9","0",
                          "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
                          "/","?",">","<","\\","|","'","\"",";",":","]","}","[","{","=","-","+","_",")","(","*","&","^","%","$","#","@","!","~","\'",".",",",
                          "0","1","2","3","4","5","6","7","8","9","8","7","6","5","4","3","2","1","0","9",
                          "Z","Y","X","W","V","U","T","S","R","Q","P","O","N","M","L","K","J","I","H","G","F","E","D","C","B","A",
                          "9","8","7","6","5","4","3","2","1","0","1","2","3","4","5","6","7","8","9","0",
                          "z","y","x","w","v","u","t","s","r","q","p","o","n","m","l","k","j","i","h","g","f","e","d","c","b","a",
                          "0","1","2","3","4","5","6","7","8","9","8","7","6","5","4","3","2","1","0","9",
                          ",",".","\'","~","!","@","#","$","%","^","&","*","(",")","_","+","-","=","{","[","}","]",":",";","\"","'","|","\\","<",">","?","/"
                         };
    string B[300][300];
    for(ushort x=0; x<300 && !IsStopped(); x++)
        {
            for(ushort y=0; y<300 && !IsStopped(); y++)
                {
                    const double R=GetRand();
                    B[x][y]=A[(ushort)MathRound((R>=0?(R<=1?R:1):0)*299)];
                }
        }
    string C="";
    for(uchar z=0; z<LGT && !IsStopped(); z++)
        {
            const double x=GetRand(),
                         y=GetRand();
            C+=B[(ushort)MathRound((x>=0?(x<=1?x:1):0)*299)][(ushort)MathRound((y>=0?(y<=1?y:1):0)*299)];
        }
    return(C);
}
//+------------------------------------------------------------------+
//| GetRand                                                          |
//+------------------------------------------------------------------+
double GetRand()
{
    int u=MathRand(),
        v=MathRand();
    if(STP<1) return((MathMod(u,2)>0?(u*3+1)/(double)98302:u/(double)65534)+((MathMod(v,2)>0?(v*3+1)/(double)98302:v/(double)65534)-0.5)*0.2);
    else
        {
            double m=32767,
                   n=32767;
            for(uchar z=0; z<STP && !IsStopped(); z++)
                {
                    if(u>1)
                        {
                            const bool a=MathMod(u,2)>0;
                            u=a?u*3+1:u/2;
                            m=a?m*3+1:m/2;
                        }
                    else
                        {
                            u=MathRand();
                            m=32767;
                        }
                    if(v>1)
                        {
                            const bool a=MathMod(v,2)>0;
                            v=a?v*3+1:v/2;
                            n=a?n*3+1:n/2;
                        }
                    else
                        {
                            v=MathRand();
                            n=32767;
                        }
                }
            return(u/m+(v/n-0.5)*0.2);
        }
}
//+------------------------------------------------------------------+
//| EditCreate                                                       |
//+------------------------------------------------------------------+
bool EditCreate(const string           n="Edit",
                const int              x=0,
                const int              y=0,
                const int              w=50,
                const int              h=18,
                const string           t="Text",
                const int              s=10,
                const bool             r=false,
                const color            c=clrBlack,
                const color            b=clrWhite,
                const color            l=clrNONE)
{
    if(ObjectCreate(0,n,OBJ_EDIT,0,0,0))
        {

            ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
            ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
            ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
            ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
            ObjectSetString(0,n,OBJPROP_TEXT,t);
            ObjectSetString(0,n,OBJPROP_FONT,"Arial Black");
            ObjectSetInteger(0,n,OBJPROP_FONTSIZE,s);
            ObjectSetInteger(0,n,OBJPROP_ALIGN,ALIGN_CENTER);
            ObjectSetInteger(0,n,OBJPROP_READONLY,r);
            ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
            ObjectSetInteger(0,n,OBJPROP_COLOR,c);
            ObjectSetInteger(0,n,OBJPROP_BGCOLOR,b);
            ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,l);
            ObjectSetInteger(0,n,OBJPROP_BACK,false);
            ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,n,OBJPROP_SELECTED,false);
            ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,n,OBJPROP_ZORDER,LONG_MAX);
            return(true);
        }
    else return(false);
}
//+------------------------------------------------------------------+
//| ButtonCreate                                                     |
//+------------------------------------------------------------------+
bool ButtonCreate(const string           n="Button",
                  const int              x=0,
                  const int              y=0,
                  const int              w=50,
                  const int              h=18,
                  const string           t="Text",
                  const int              s=10,
                  const bool             r=false,
                  const color            c=clrBlack,
                  const color            b=clrWhite,
                  const color            l=clrNONE)
{
    if(ObjectCreate(0,n,OBJ_BUTTON,0,0,0))
        {

            ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
            ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
            ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
            ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
            ObjectSetString(0,n,OBJPROP_TEXT,t);
            ObjectSetString(0,n,OBJPROP_FONT,"Arial Black");
            ObjectSetInteger(0,n,OBJPROP_FONTSIZE,s);
            ObjectSetInteger(0,n,OBJPROP_ALIGN,ALIGN_CENTER);
            ObjectSetInteger(0,n,OBJPROP_STATE,r);
            ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
            ObjectSetInteger(0,n,OBJPROP_COLOR,c);
            ObjectSetInteger(0,n,OBJPROP_BGCOLOR,b);
            ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,l);
            ObjectSetInteger(0,n,OBJPROP_BACK,false);
            ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,n,OBJPROP_SELECTED,false);
            ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,n,OBJPROP_ZORDER,LONG_MAX);
            return(true);
        }
    else return(false);
}
//+------------------------------------------------------------------+
