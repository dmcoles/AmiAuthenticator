-> Cbio.e
->
-> Provide standard clipboard device interface routines
->            such as Open, Close, Post, Read, Write, etc.
->
-> NOTES: These functions are useful for writing and reading simple FTXT. 
-> Writing and reading complex FTXT, ILBM, etc., requires more work.  You
-> should use the iffparse.library to write and read FTXT, ILBM and other IFF
-> file types.  When this code is used with older versions of the Amiga OS
-> (i.e., before V36) a memory loss of 536 bytes will occur due to bugs in the
-> clipboard device.

->>> Header (globals)
OPT MODULE

MODULE 'devices/clipboard',
       'exec/io',
       'exec/memory',
       'exec/ports',
       'amigalib/ports',
       'amigalib/io'

ENUM ERR_NONE, ERR_DERR, ERR_DEV, ERR_DLEN, ERR_DOIO, ERR_IO, ERR_PORT

RAISE ERR_DEV  IF OpenDevice()<>0,
      ERR_DOIO IF DoIO()<>0

-> E-Note: don't need size field since using NewM()/Dispose()
OBJECT cbbuf
  count  -> Number of characters after stripping
  mem
ENDOBJECT

CONST ID_FORM="FORM", ID_FTXT="FTXT", ID_CHRS="CHRS"
->>>

->>> EXPORT PROC cbOpen(unit)
->
->  FUNCTION
->      Opens the clipboard.device.  A clipboard unit number must be passed in
->      as an argument.  By default, the unit number should be 0 (currently
->      valid unit numbers are 0-255).
->
->  RESULTS
->      A pointer to an initialised IOClipReq structure.  An exception is
->      raised if the function fails ("CBOP")
PROC cbOpen(unit) HANDLE
  DEF mp=NIL, ior=NIL
  IF NIL=(mp:=createPort(0,0)) THEN Raise(ERR_PORT)
  IF NIL=(ior:=createExtIO(mp, SIZEOF ioclipreq)) THEN Raise(ERR_IO)
  OpenDevice('clipboard.device', unit, ior, 0)
EXCEPT
  IF ior THEN deleteExtIO(ior)
  IF mp THEN deletePort(mp)
  Raise("CBOP")
ENDPROC ior
->>>

->>> EXPORT PROC cbClose(ior:PTR TO ioclipreq)
->
->  FUNCTION
->      Close the clipboard.device unit which was opened via cbOpen().
->
PROC cbClose(ior:PTR TO ioclipreq)
  DEF mp
  mp:=ior.message.replyport
  CloseDevice(ior)
  deleteExtIO(ior)
  deletePort(mp)
ENDPROC
->>>

->>> EXPORT PROC cbWriteFTXT(ior:PTR TO ioclipreq, string)
->
->  FUNCTION
->      Write a NIL terminated string of text to the clipboard.  The string
->      will be written in simple FTXT format.
->
->      Note that this function pads odd length strings automatically to
->      conform to the IFF standard.
->
->  RESULTS
->      If the write did not succeed an exception is raised ("CBWR")
->
PROC cbWriteFTXT(ior:PTR TO ioclipreq, string) HANDLE
  DEF length, slen, odd
  slen:=StrLen(string)
  odd:=Odd(slen)  -> Pad byte flag
  length:=IF odd THEN slen+1 ELSE slen

  -> Initial set-up for offset, error, and clipid
  ior.offset:=0
  ior.error:=0
  ior.clipid:=0

  -> Create the IFF header information
  writeLong(ior, 'FORM')    -> 'FORM'
  length:=length+12         -> + length '[size]FTXTCHRS'
  writeLong(ior, {length})  -> Total length
  writeLong(ior, 'FTXT')    -> 'FTXT'
  writeLong(ior, 'CHRS')    -> 'CHRS'
  writeLong(ior, {slen})    -> String length

  -> Write string
  ior.data:=string
  ior.length:=slen
  ior.command:=CMD_WRITE
  DoIO(ior)

  -> Pad if needed
  IF odd
    ior.data:=''
    ior.length:=1
    DoIO(ior)
  ENDIF

  -> Tell the clipboard we are done writing
  ior.command:=CMD_UPDATE
  DoIO(ior)
  -> Check if error was set by any of the preceding IO requests
  IF ior.error THEN Raise(ERR_DERR)
EXCEPT
  Raise("CBWR")
ENDPROC
->>>

->>> PROC writeLong(ior:PTR TO ioclipreq, ldata)
PROC writeLong(ior:PTR TO ioclipreq, ldata)
  ior.data:=ldata
  ior.length:=4
  ior.command:=CMD_WRITE
  DoIO(ior)
  IF ior.actual<>4 THEN Raise(ERR_DLEN)
ENDPROC
->>>

EXPORT PROC writeToClip(text)
  DEF ior
  ior:=cbOpen(0)
  IF ior 
    cbWriteFTXT(ior,text)
    cbClose(ior)
  ENDIF
ENDPROC
