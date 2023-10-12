  OPT MODULE
  
  MODULE 'exec/nodes'
  MODULE '*sha256'

EXPORT OBJECT totp
  name:PTR TO CHAR
  secret:PTR TO CHAR
  decrypted:PTR TO CHAR
  k:PTR TO CHAR
  type:INT
  digits:INT
  interval:INT
  ledvalues[5]:ARRAY OF INT
  ticks:INT
  node:PTR TO ln
  lastvals[2]:ARRAY OF LONG
  lastcolour:INT
ENDOBJECT

EXPORT PROC create() OF totp
  self.secret:=String(100)
  self.decrypted:=String(100)
  self.name:=String(100)
  self.digits:=6
  self.interval:=30
  self.k:=String(100)
  self.type:=0
  self.lastvals[0]:=0
  self.lastvals[1]:=0
  self.lastcolour:=-1
ENDPROC

EXPORT PROC end() OF totp
  DisposeLink(self.secret)
  DisposeLink(self.decrypted)
  DisposeLink(self.name)
  DisposeLink(self.k)
ENDPROC

EXPORT PROC decrypt(key:PTR TO CHAR) OF totp
  DEF pos=0,i
  StrCopy(self.decrypted,self.secret)
  IF StrLen(key)>0
    FOR i:=0 TO EstrLen(self.decrypted)-1
      self.decrypted[i]:=Char({base32_chars}+And(Eor(Char({base32_vals}+self.decrypted[i]),key[pos]),31))
      pos++
      IF pos>=StrLen(key) THEN pos:=0
    ENDFOR
  ENDIF
ENDPROC

EXPORT PROC encrypt(key:PTR TO CHAR) OF totp
  DEF pos=0,i
  StrCopy(self.secret,self.decrypted)
  IF StrLen(key)>0
    FOR i:=0 TO EstrLen(self.secret)-1
      self.secret[i]:=Char({base32_chars}+And(Eor(Char({base32_vals}+self.secret[i]),key[pos]),31))
      pos++
      IF pos>=StrLen(key) THEN pos:=0
    ENDFOR
  ENDIF
ENDPROC

EXPORT PROC makeKey() OF totp
  DEF len,keylen,pos
  DEF m,k
  
  
  k:=self.k
  StrCopy(k,self.secret,100)
  len:=StrLen(k)
/* validates base32 key */
  IF (((len AND $f) <> 0) AND ((len AND $f) <> 8)) 
    ->WriteF('\s: invalid base32 secret\n', arg)
    RETURN 0
  ENDIF
  FOR pos:= 0 TO len-1
    IF (Char({base32_vals}+k[pos]) = -1)
      ->WriteF('\s: invalid base32 secret\n', arg)
      RETURN 0
    ENDIF
    IF (k[pos] = "=") 
      IF (((pos AND $F) = 0) OR ((pos AND $F) = 8))
        ->WriteF('\s: invalid base32 secret\n', arg)
        RETURN 0
      ENDIF
      IF ((len - pos) > 6)
        ->WriteF('\s: invalid base32 secret\n', arg)
        RETURN 0
      ENDIF
      m:=Mod(pos,8) 
      IF (m<>2) AND (m<>4) AND (m<>5) AND (m<>7)
        ->WriteF('\s: invalid base32 secret\n', arg)
        RETURN 0
      ENDIF

      WHILE (pos<len)
        pos++
        IF (k[pos] <> "=")
          ->WriteF('\s: invalid base32 secret\n', arg)
          RETURN 0
        ENDIF
      ENDWHILE
    ENDIF
  ENDFOR

  /* decodes base32 secret key */
  keylen:=0
  pos:=0
  WHILE (pos<=(len-8))
    /* MSB is Most Significant Bits  (0x80 == 10000000 ~= MSB)
     * MB is middle bits             (0x7E == 01111110 ~= MB)
     * LSB is Least Significant Bits (0x01 == 00000001 ~= LSB)
     */

    /* byte 0 */
    k[keylen + 0]:=(Shl(Char({base32_vals}+k[pos + 0]),3)) AND $F8  /* 5 MSB */
    k[keylen + 0]:=k[keylen + 0] OR ((Shr(Char({base32_vals}+k[pos + 1]),2)) AND $7) /* 3 LSB */
    IF (k[pos + 2] = "=") 
      keylen++
      EXIT TRUE
    ENDIF

    /* byte 1 */
    k[keylen + 1]:=(Shl(Char({base32_vals}+k[pos + 1]),6)) AND $C0  /* 2 MSB */
    k[keylen + 1]:=k[keylen + 1] OR ((Shl(Char({base32_vals}+k[pos + 2]),1)) AND $3E) /* 5  MB */
    k[keylen + 1]:=k[keylen + 1] OR ((Shr(Char({base32_vals}+k[pos + 3]),4)) AND $01) /* 1 LSB */
    IF (k[pos + 4] = "=")
      keylen+=2
      EXIT TRUE
    ENDIF

    /* byte 2 */
    k[keylen + 2]:=(Shl(Char({base32_vals}+k[pos + 3]),4)) AND $F0;  /* 4 MSB */
    k[keylen + 2]:=k[keylen + 2] OR ((Shr(Char({base32_vals}+k[pos + 4]),1)) AND $F) /* 4 LSB */
    IF (k[pos + 5] = "=")
      keylen+=3
      EXIT TRUE
    ENDIF

    /* byte 3 */
    k[keylen + 3]:=(Shl(Char({base32_vals}+k[pos + 4]),7)) AND $80  /* 1 MSB */
    k[keylen + 3]:=k[keylen + 3] OR ((Shl(Char({base32_vals}+k[pos + 5]),2)) AND $7C) /* 5  MB */
    k[keylen + 3]:=k[keylen + 3] OR ((Shr(Char({base32_vals}+k[pos + 6]),3)) AND $03) /* 2 LSB */
    IF (k[pos + 7] = "=")
      keylen+=4
      EXIT TRUE
    ENDIF
   
    /* byte 4 */
    k[keylen + 4]:=(Shl(Char({base32_vals}+k[pos + 6]),5)) AND $E0  /* 3 MSB */
    k[keylen + 4]:=k[keylen + 4] OR ((Char({base32_vals}+k[pos + 7])) AND $1F) /* 5 LSB */
    keylen+=5
    pos+=8
  ENDWHILE
  k[keylen]:=0
ENDPROC keylen

EXPORT PROC updateValues(t1,t2,t3,force) OF totp
  DEF keylen
  DEF sv[2]:STRING
  DEF hmac_result[32]:ARRAY OF CHAR
  DEF bin_code
  DEF offset
  DEF i
  DEF t[2]:ARRAY OF LONG
  DEF tempStr[10]:STRING
  DEF digitStr[10]:STRING
  DEF newcolour
  
  self.ticks:=t3
  IF t3>1250
    newcolour:=(Div(t3,50) AND 1)+1
  ELSE
    newcolour:=1
  ENDIF

  IF (force=FALSE) AND (self.lastvals[0]=t1) AND (self.lastvals[1]=t2) AND (newcolour=self.lastcolour) THEN RETURN FALSE
  
  self.lastvals[0]:=t1
  self.lastvals[1]:=t2
  self.lastcolour:=newcolour
  
  t[0]:=t1
  t[1]:=t2
 
  AstrCopy(hmac_result,'')

  IF (keylen:=self.makeKey())=0
    self.ledvalues[0]:=0
    self.ledvalues[1]:=0
    self.ledvalues[2]:=0
    self.ledvalues[3]:=0
    self.ledvalues[4]:=0
    RETURN FALSE
  ENDIF

  IF self.type=1
    hmac_sha256(t,8, self.k, keylen, hmac_result)

    -> dynamically truncates hash 
    offset:=hmac_result[31] AND $f
    bin_code:= ((hmac_result[offset] AND $7f) << 24) OR
               ((hmac_result[offset + 1] AND $ff) << 16) OR
               ((hmac_result[offset + 2] AND $ff) << 8) OR
               (hmac_result[offset + 3] AND $ff)

  ELSE
    hmac_sha1(t,8, self.k, keylen, hmac_result)
    /* dynamically truncates hash */
    offset:=hmac_result[19] AND $f
    bin_code:= ((hmac_result[offset] AND $7f) << 24) OR
               ((hmac_result[offset + 1] AND $ff) << 16) OR
               ((hmac_result[offset + 2] AND $ff) << 8) OR
               (hmac_result[offset + 3] AND $ff)

  ENDIF
  -> truncates code to correct number of digits 
  StringF(tempStr,'\r\z\d[10]',bin_code)
  RightStr(digitStr,tempStr,self.digits)
  i:=0
  WHILE i<EstrLen(digitStr)
    StrCopy(sv,digitStr+i,2)
    self.ledvalues[Shr(i,1)]:=Val(sv)
    i+=2
  ENDWHILE
ENDPROC TRUE

base32_vals:
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0x00 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0x10 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0x20 */
  CHAR 14, 11, 26, 27, 28, 29, 30, 31, 1,  -1, -1, -1, -1, 0,  -1, -1 /* 0x30 */
  CHAR -1, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14 /* 0x40 */
  CHAR 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1 /* 0x50 */
  CHAR -1, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14 /* 0x60 */
  CHAR 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1, -1, -1, -1 /* 0x70 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0x80 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0x90 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xA0 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xB0 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xC0 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xD0 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xE0 */
  CHAR -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 /* 0xF0 */

base32_chars:
  CHAR 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
