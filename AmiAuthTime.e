  OPT MODULE

   MODULE 'dos/dos','dos/datetime','socket','net/netdb','net/in','net/socket','timezone'
   MODULE '*AmiAuthPrefs'

EXPORT OBJECT timedata
  utcOffset:LONG
  oldtime:LONG
ENDOBJECT

OBJECT ntpTimeStamp
  seconds:LONG
  fraction:LONG
ENDOBJECT

OBJECT ntpMessage
  flags:CHAR
  stratum:CHAR
  poll:CHAR
  precision:CHAR
  rootDelay:LONG
  rootDispersion:LONG
  referenceIdentifier:LONG
  referenceTimestamp:ntpTimeStamp
  originateTimestamp:ntpTimeStamp
	receiveTimestamp:ntpTimeStamp
	transmitTimestamp:ntpTimeStamp
ENDOBJECT

EXPORT PROC ntpTime(server:PTR TO CHAR)

  DEF serverAddr=0:PTR TO sockaddr_in
  DEF hostEnt: PTR TO hostent
  DEF clientNTPMessage:ntpMessage
  DEF serverNTPMessage:ntpMessage

  DEF addr:LONG
  DEF sock
  DEF s,f
  
  socketbase:=OpenLibrary('bsdsocket.library',2)
  IF (socketbase=0) 
    RETURN 0
  ENDIF
  
  hostEnt:=GetHostByName(server)
  IF hostEnt=NIL 
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF
  
  NEW serverAddr
  
  addr:=Long(hostEnt.h_addr_list)
  addr:=Long(addr)

  serverAddr.sin_len:=SIZEOF sockaddr_in
  serverAddr.sin_family:=AF_INET
  serverAddr.sin_port:=123
  serverAddr.sin_addr:=addr  
  
  sock:=Socket(PF_INET,SOCK_DGRAM,0)
  IF sock=-1
    END serverAddr
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF
  
  IF (Connect(sock,serverAddr,SIZEOF sockaddr_in)<>0) 
    END serverAddr
    CloseSocket(sock)
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF
  
	clientNTPMessage.flags:=$1b
  s,f:=getSysTimeAsNTPTimestamp()
	clientNTPMessage.transmitTimestamp.seconds:=s
  clientNTPMessage.transmitTimestamp.fraction:=f 

  IF Send(sock,clientNTPMessage,SIZEOF clientNTPMessage,0)=-1
    END serverAddr
    CloseSocket(sock)
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF
  
  IF Recv(sock,serverNTPMessage,SIZEOF serverNTPMessage, MSG_WAITALL)=-1
    END serverAddr
    CloseSocket(sock)
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF
  
  s,f:=getSysTimeAsNTPTimestamp()
  clientNTPMessage.receiveTimestamp.seconds:=s
  clientNTPMessage.receiveTimestamp.fraction:=f
  
  IF validateResponse(clientNTPMessage,serverNTPMessage)=FALSE 
    END serverAddr
    CloseSocket(sock)
    CloseLibrary(socketbase)
    RETURN 0
  ENDIF

  END serverAddr
  CloseSocket(sock)
  CloseLibrary(socketbase)  
ENDPROC serverNTPMessage.transmitTimestamp.seconds-2208988800

PROC getSysTimeAsNTPTimestamp()
  DEF currDate: datestamp
  DEF s,t

  DateStamp(currDate)
  s:=2461449600+(Mul(Mul(currDate.days,1440),60)+(currDate.minute*60)+(currDate.tick/50))
  t:=Mod(currDate.tick,50)
ENDPROC s,Mul(t,85899345)

PROC validateResponse(clientNTPMessage:PTR TO ntpMessage, serverNTPMessage:PTR TO ntpMessage)
  DEF serverFlags
  DEF modeMask=7
  DEF serverMode=4
  DEF versionMask=$1c
  
  serverFlags:=serverNTPMessage.flags
  
	IF ((serverFlags AND modeMask) <> serverMode)
		->Printf("Not a server NTP message!\n");
		RETURN FALSE
  ENDIF
  
	IF ((serverFlags AND versionMask) <> (serverFlags AND versionMask))
		->Printf("Not the same version in the server NTP message!\n");
		RETURN FALSE
	ENDIF
  
	IF (clientNTPMessage.transmitTimestamp.seconds <> serverNTPMessage.originateTimestamp.seconds) OR (clientNTPMessage.transmitTimestamp.fraction <> serverNTPMessage.originateTimestamp.fraction)
		->Printf("Originate timestamp in server message is wrong!\n");
		RETURN FALSE
	ENDIF
ENDPROC TRUE

EXPORT PROC getSystemTime(utcOffset)
  DEF currDate: datestamp

  DateStamp(currDate)
  ->2922 days between 1/1/70 and 1/1/78

ENDPROC (Mul(Mul(currDate.days+2922,1440),60)+(currDate.minute*60)+(currDate.tick/50))-utcOffset,Mod(currDate.tick,50)

EXPORT PROC dateTimeToDateStamp(dateVal,datestamp:PTR TO datestamp)
  datestamp.tick:=(dateVal-Mul(Div(dateVal,60),60))
  datestamp.tick:=Mul(datestamp.tick,50)
  dateVal:=Div(dateVal,60)
  datestamp.days:=Div((dateVal),1440)-2922   ->-2922 days between 1/1/70 and 1/1/78
  datestamp.minute:=dateVal-(Mul(datestamp.days+2922,1440))
ENDPROC

EXPORT PROC formatCDateTime(cDateVal,outDateStr)
  DEF d : PTR TO datestamp
  DEF dt : datetime
  DEF datestr[10]:STRING
  DEF daystr[10]:STRING
  DEF timestr[10]:STRING
  DEF dateVal

  d:=dt.stamp
  dateTimeToDateStamp(cDateVal,d)

  dt.format:=FORMAT_DOS
  dt.flags:=0
  dt.strday:=0
  dt.strdate:=datestr
  dt.strtime:=timestr

  IF DateToStr(dt)
    StringF(outDateStr,'\s[3] \s[2] \d\s \s ',datestr+3,datestr,IF dt.stamp.days>=8035 THEN 20 ELSE 19,datestr+7,timestr)
    RETURN TRUE
  ENDIF
ENDPROC FALSE

EXPORT PROC calcUTCOffset(timedata:PTR TO timedata, prefs:PTR TO prefs)
  DEF ti
  DEF rawtime[2]:ARRAY OF LONG
  IF (prefs.readNtpTime=1) ANDALSO ((ti:=ntpTime('time.windows.com'))<>0)
  timedata.utcOffset:=getSystemTime(0)-ti
  ELSEIF (prefs.useTimezone=1) ANDALSO (timezonebase:=OpenLibrary('tz.library',0))
    Time(rawtime)
    ti:=rawtime[1]
    timedata.utcOffset:=getSystemTime(0)-ti
    CloseLibrary(timezonebase)
  ELSE
    timedata.utcOffset:=Mul(prefs.userOffset,60)
  ENDIF
ENDPROC
