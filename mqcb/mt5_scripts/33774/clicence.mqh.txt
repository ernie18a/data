//+------------------------------------------------------------------+
//|                                                      Licence.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

struct Account   // Account Details
   {
    string           Server;
    string           No;
   };
//+------------------------------------------------------------------+
//|                          Licence Class                           |
//+------------------------------------------------------------------+
class CLicence
   {
private:
    string           m_key;
    char             m_hashkey[];
    string           m_file;
    bool             m_inCommon;
    int              m_FHandle;
    string           m_Path;
    Account          m_licences[];
    bool             m_Read();
    bool             m_GetHashKey();

protected:

public:
    int              m_Count;
    string           m_ErrorTxt;
    void             CLicence(string m_File, string m_Key="", bool m_InCommon = false);
    string           m_Encode(string m_String);
    string           m_Decode(string m_String);

    void             ~CLicence();
    bool             m_Write(string m_Acc="", string m_Server="");
    bool             m_LicenceFound(string m_Acc="", string m_Server="");
   };


//+------------------------------------------------------------------+
//|   Constructor                                                    |
//+------------------------------------------------------------------+
void  CLicence :: CLicence(string m_File, string m_Key="", bool m_InCommon = false)
   {
    m_file = m_File;
    m_key = m_Key;
    m_inCommon = m_InCommon;
    m_Count = 0;
    m_ErrorTxt = "";

    if(m_GetHashKey())   // Generates the 256bit Hash Key from Key...
        if(!m_Read())     // Reads the Licence file if it exists... and places encrypted values into an array of account struct.
           {
            m_ErrorTxt = "No Licences Found in Licence File...";
            Print(m_ErrorTxt);
           }
        else
           {
            for(int x = 0; x < m_Count; x++)
               {
                m_licences[x].Server = m_Decode(m_licences[x].Server); //Decrypt Accounts in array...
                m_licences[x].No = m_Decode(m_licences[x].No);
               }
           }

    return;
   };


//+------------------------------------------------------------------+
//| Read Through Licence Array To Return if Product Licence Found    |
//+------------------------------------------------------------------+
bool CLicence :: m_LicenceFound(string m_Acc="", string m_Server="")
   {
    if(m_Acc =="")
        m_Acc = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
    if(m_Server == "")
        m_Server = AccountInfoString(ACCOUNT_SERVER);


    StringToUpper(m_Acc);
    StringToUpper(m_Server); // make search case insensitive
    for(int x = 0; x < m_Count; x++)
       {
        StringToUpper(m_licences[x].No);
        StringToUpper(m_licences[x].Server);
        if(m_licences[x].No==m_Acc && m_licences[x].Server==m_Server)
            return true;
       }

    return false;
   }

//+------------------------------------------------------------------+
//|   Add, Encode & Write New Licence to file                        |
//+------------------------------------------------------------------+
bool CLicence::m_Write(string m_Acc  = "", string m_Server = "")
   {
    FileClose(m_FHandle);
    if(m_inCommon)
       {
        m_FHandle=FileOpen(m_file, FILE_WRITE | FILE_BIN | FILE_COMMON | FILE_UNICODE);
        m_Path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
       }
    else
       {
        m_FHandle=FileOpen(m_file, FILE_WRITE | FILE_BIN | FILE_UNICODE);
        m_Path=TerminalInfoString(TERMINAL_DATA_PATH);
       }

    if(m_FHandle==INVALID_HANDLE)
       {
        m_ErrorTxt = "File: " + m_file + " ("+ m_Path +") Write failed with code "+ (string)GetLastError();
        Print(m_ErrorTxt);
        return false;
       }
    else
       {
        m_Count++;
        ArrayResize(m_licences,m_Count);

        if(m_Acc =="")
            m_Acc = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
        if(m_Server == "")
            m_Server = AccountInfoString(ACCOUNT_SERVER);

        m_licences[m_Count-1].No=m_Acc;
        m_licences[m_Count-1].Server=m_Server;

        for(int x = 0; x < m_Count; x++)
           {
            if(m_licences[x].No!="")
               {
                m_licences[x].No = m_Encode(m_licences[x].No);
                FileWriteString(m_FHandle, m_licences[x].No, 64);
                m_licences[x].Server = m_Encode(m_licences[x].Server);
                FileWriteString(m_FHandle, m_licences[x].Server, 64);
               }
           }
        FileClose(m_FHandle);
        return true;
       }
    return false;
   };


//+------------------------------------------------------------------+
//|   Read & Decode Licences into Account Struct  / String Array     |
//+------------------------------------------------------------------+
bool CLicence::m_Read()
   {
    if(m_inCommon)
       {
        m_FHandle=FileOpen(m_file, FILE_SHARE_READ | FILE_BIN | FILE_COMMON | FILE_UNICODE);
        m_Path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
       }
    else
       {
        m_FHandle=FileOpen(m_file, FILE_SHARE_READ | FILE_BIN | FILE_UNICODE);
        m_Path=TerminalInfoString(TERMINAL_DATA_PATH);
       }

    if(m_FHandle==INVALID_HANDLE)
       {
        m_ErrorTxt = "File: " + m_file + " ("+ m_Path +") Read failed with code "+ (string)GetLastError();
        Print(m_ErrorTxt);
        return false;
       }
    else
       {
        m_Count = 0;
        ArrayResize(m_licences,m_Count+1);
        do
           {
            m_licences[m_Count].No = FileReadString(m_FHandle, 64);
            m_licences[m_Count].Server = FileReadString(m_FHandle, 64);
            if(m_licences[m_Count].No !="")
               {
                m_Count++;
                ArrayResize(m_licences,m_Count+1);
               }
           }
        while(!FileIsEnding(m_FHandle));
        if(m_Count == 0)
            return false;
       }
    FileClose(m_FHandle);
    return true;
   };

//+------------------------------------------------------------------+
//|    Encode a String to 256bit Encryption                          |
//+------------------------------------------------------------------+
string  CLicence::m_Encode(string m_String)
   {
    uchar m_src[],m_dst[];
    m_String+="Endof";
    StringToCharArray(m_String, m_src,0, StringLen(m_String));

    string m_Encoded = "";
    ResetLastError();
    if(CryptEncode(CRYPT_AES256,m_src,m_hashkey,m_dst))
        m_Encoded=CharArrayToString(m_dst);
    else
       {
        m_ErrorTxt = "Failed to Encrypt: "+(string)GetLastError();
        Print(m_ErrorTxt);
       };
    return m_Encoded;
   };

//+------------------------------------------------------------------+
//|    Decode a String from 256bit Encryption                        |
//+------------------------------------------------------------------+
string  CLicence::m_Decode(string m_String)
   {
    uchar m_src[],m_dst[];

    StringToCharArray(m_String, m_src, 0, StringLen(m_String));

    string m_Decoded = "";
    int m_result = CryptDecode(CRYPT_AES256, m_src, m_hashkey, m_dst);
    if(m_result)
       {
        m_Decoded=CharArrayToString(m_dst);
        StringReplace(m_Decoded,"Endof","");
       }
    else
       {
        m_ErrorTxt = "Failed to Decrypt: "+(string)GetLastError();
        Print(m_ErrorTxt);
       }

    return m_Decoded;
   };

//+------------------------------------------------------------------+
//|        Creating the Encrypted Hash Key                           |
//+------------------------------------------------------------------+
bool CLicence::m_GetHashKey()
   {
    uchar m_src[],m_dst[],m_hkey[],m_mkey[];


    ArrayResize(m_hkey,32);
    for(int i=0; i<32; i++)
        m_hkey[i]=uchar((i*17)%59);

    StringToCharArray(m_key,m_mkey, 0, StringLen(m_key));

    ResetLastError();
    if(!CryptEncode(CRYPT_DES, m_hkey, m_mkey, m_hashkey))
       {
        m_ErrorTxt = "Failed to Create Hashkey: "+(string)GetLastError();
        Print(m_ErrorTxt);
        return false;
       };
    return true;
   }

//+------------------------------------------------------------------+
//|   Destructor                                                     |
//+------------------------------------------------------------------+
void  CLicence :: ~CLicence()
   {
    FileClose(m_FHandle);
    return;
   };
//+------------------------------------------------------------------+
