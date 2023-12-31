# About this program
AmiAuthenticator is a 2FA code generator for the Amiga compatible with many sites out there that use 2FA. It generates TOTP (Time based one time passwords) codes using SHA1 or SHA256. Similar (non-Amiga) applications are Google Authenticator, Microsoft Authenticator and  FreeOTP. You can use these codes to secure your access to various sites eg GitHub, LastPass, Amazon, Facebook, Instagram.

The application is very simple to use and comes in 3 different versions depending on your Amiga setup.

* MUI based version 
* Reaction based version
* Gadtools based version.

In order to generate the 2FA codes it requires a UTC time source. It can either take this from the internet or if you have tz.library installed it can calculate the current UTC time based on your current timezone settings and clock. Finally if neither of these are available you can configure the timezone offset manually.

# System requirements
All versions of this application require an Amiga with Kickstart/Workbench 2.0 as a minimum. 

As mentioned above it also requires a UTC time source so it is important that your system clock is set accurately and it is preferable to have a realtime clock installed or have your system synchronised with the internet.

The basic Gadtools version will run on any machine with at least 512K of RAM.

The MUI and Reaction versions will require minimum of 1MB to use and will also require the relevant UI system to be available. 

The Reaction version is recommended only for people running OS 3.2 however ClassAct can be used on systems where Reaction is not available but ClassAct is known to be buggy so if you are using an older Amiga OS then the MUI or Gadtools version might work better for you.

# Using the application
Simply launch the application from Workbench by clicking the icon.  Upon loading this application for the first time you will be asked to set a master password.


It is highly recommended that you set a secure password for this as it is your main protection against anyone getting access to your 2FA codes. You can select cancel at this stage and choose not to enter a password in which case the secrets you enter will be stored unencrypted and anyone with access to your machine will be able to see and steal them. If you do set a password you will need to enter this each time you launch the application in order to get access to your 2FA codes.

Once you have completed this initial setup the main application window will be displayed (this will be blank if you are launching the application for the first itme). You will see the current UTC time displayed at the top of the form. If this is incorrect you may want to edit the configuration settings (see section below).

Select the "Edit Items" option from the pulldown menu and you will see the screen where you can manage your 2FA code list.



Selecting 'Add' or 'Edit' will allow you to configure the individual 2FA item settings

 

You can give the item a name and enter the secret key.  Your secret key should be in base32 format (eg only using characters A-Z and 2-9) and the recommended minimum length of the secret is 32 characters although the application will accept shorter. You can also choose between SHA1 and SHA256. The secret may well be generated automatically for you by whatever service you are wanting to access.  It may be initially given to you as a barcode but you can usually choose to view the text version.

Some other authenticator applications allow you to change the update period and number of digits. This application is currently not able to handle these codes and these settings are currently fixed at 6 digits and 30 second updates. 

# Configuration Options
The settings page allows you to configure the options related to how the current UTC time is obtained. This is required as the TOTP codes are based on UTC time.



1) Get time from internet

If this is enabled the program will query an internet time server at startup and determine the time difference between your current system time and the UTC time reported by the time server. After the initial startup the program will then use the current system clock alongside the time difference previously calculated to keep track of the current UTC time. Using this open is the preferred method if you have internet access on your Amiga since it will work even if your system time is not set accurately.

2) Use tz.library to get time

If you have tz.library installed and configured correctly with your countries timezone then the program will use the tz.library to determine your offset from UTC and apply that offset to the current system clock. This option does not require any system connectivity but does require that your system clock is set accurately and you have the tz.library installed and set up.

3) Manual timezone offset

Using this option you can manually specify the current offset from UTC for your country. If your country observes daylight savings then it will need to be updated after a clock change. It also requires that your system clock be set accurately.

The system will check which of these settings is enabled and attempt to calculate the current UTC time at system startup in preference order (1) (2) and (3). If option (1) is disabled or no internet connectivity is available it will move onto option (2) . If no tz.library is installed or the option is disabled then it will default to option (3).

The current UTC time will be refreshed after any changes are made in the settings page.

# Change Your Master Password
You can update your master password at any time using the menu option. If you have already set up a master password you will need to enter this as well as the new passowrd.


You cannot however remove your password once one has been set - it can only be updated but not removed.

# Future enhancements
I have a few ideas for things I would like to add to the tool in the future. These include adding a preview for the next number in the cycle once it gets close to the switchover. I would like to expand the capability to include varying time options and varying numbers of digits. Finally I would like to have an option where the codes are not initially displayed to the user but they have to click to reveal each of the codes (this would be switchable as a configuration setting).

# Known Issues
Currently the program saves the 2FA information to a file called totp.cfg alongside the application. This file currently contains the 2FA secrets in an encrypted form. The encryption used is based on an sha hash of your passcode. Given the processing power of modern PC's this encryption is almost certainly not able to withstand a concentrated effort to decrypt your keys. It is certainly recommended that you take additional measures to protect your data and do not use this program if the machine you are using is open to being abused.

This program has been tested on various OS versions and machine types, however I was not able to get ClassAct to install correctly on OS 2.x and so the Reaction version of the application has not been tested on anything below OS 3.x

The led.image class in Amiga OS 3.2 appears to have a memory leak. If you are running the affected version then you will lose around 3k of memory each time you run the application. This has been reported to the devs.

In MUI 5 there also appears to be a memory leak when handing bitmap objects. This means that when running the application you will experience increasing memory usage over time as the 2fa codes are updated. MUI 3.8 does not suffer from this so if you are using MUI 5 you should be aware of this memory leakage and potentially use a different version of the tool.

# Technical Information
This program was written in Amiga E  (Using the E-VO compiler http://aminet.net/package/dev/e/evo)

ClassMate (http://aminet.net/package/dev/gui/ClassMate and MuiBuilder (http://aminet.net/package/dev/mui/muibuilder.os3) were used to assist with the GUI creation.

Link to timezone library (tz.library) http://aminet.net/package/util/time/tz8
