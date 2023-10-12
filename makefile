# Compile ACP and EXPRESS and any dependencies

debugoptions=DEBUG IGNORECACHE NILCHECK SYM SHOWFNAME ADDBUF 50
releaseoptions=IGNORECACHE OPTI SHOWFNAME ADDBUF 50
compiler=EVO

ifeq ($(build),release)
options=$(releaseoptions)
else
options=$(debugoptions)
endif

all:					AmiAuthGad AmiAuthMui AmiAuthReaction

release:				options=$(releaseoptions)
release:				AmiAuthGad AmiAuthMui AmiAuthReaction

AmiAuthGad:			AmiAuth.e AmiAuthTotp.m AmiAuthTime.m AmiAuthUI.m
							$(compiler) AmiAuth EXENAME AmiAuthGad UI_GAD $(options)

AmiAuthMui:			AmiAuth.e AmiAuthTotp.m AmiAuthTime.m AmiAuthMui.m AmiAuthReaction.m
							$(compiler) AmiAuth EXENAME AmiAuthMui UI_MUI $(options)

AmiAuthReaction:			AmiAuth.e AmiAuthTotp.m AmiAuthTime.m  AmiAuthReaction.m
							$(compiler) AmiAuth EXENAME AmiAuthReaction UI_REACTION $(options)

AmiAuthTime.m:	AmiAuthTime.e AmiAuthPrefs.m
							$(compiler) AmiAuthTime $(options)

AmiAuthTotp.m:	AmiAuthTotp.e sha256.m
							$(compiler) AmiAuthTotp $(options)

AmiAuthPrefs.m:	AmiAuthPrefs.e
							$(compiler) AmiAuthPrefs $(options)

AmiAuthMui.m:	AmiAuthMui.e AmiAuthTotp.m AmiAuthPrefs.m AmiAuthTime.m sha256.m
							$(compiler) AmiAuthMui $(options)

AmiAuthReaction.m:	AmiAuthReaction.e AmiAuthTotp.m AmiAuthPrefs.m AmiAuthTime.m sha256.m
							$(compiler) AmiAuthReaction $(options)

AmiAuthUI.m:	AmiAuthUI.e AmiAuthTotp.m AmiAuthPrefs.m AmiAuthTime.m sha256.m
							$(compiler) AmiAuthUI $(options)

sha256.m:			sha256.e
							$(compiler) sha256 $(options)

clean:
							delete sha256.m AmiAuthUI.m AmniAuthPrefs.m AmiAuthTotp.m AmiAuthTime.m AmiAuthGad AmiAuthMui AmiAuthReaction AmiAuthMui.m AmiAuthReaction.m AmiAuthPrefs.m
