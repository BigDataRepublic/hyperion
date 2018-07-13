Introduction
------------

We have a simple ES 700G backup power supply. Configured with the help of the [Arch Linux wiki page on APC UPS configuration](https://wiki.archlinux.org/index.php/APC_UPS).

After installation, without any jobs running, we get the following status:

    $ apcaccess status
    APC      : 001,034,0824
    DATE     : 2018-05-20 13:36:42 +0200  
    HOSTNAME : hyperion
    VERSION  : 3.14.14 (31 May 2016) redhat
    UPSNAME  : hyperion
    CABLE    : USB Cable
    DRIVER   : USB UPS Driver
    UPSMODE  : Stand Alone
    STARTTIME: 2018-05-20 13:36:40 +0200  
    MODEL    : Back-UPS ES 700G
    STATUS   : ONLINE
    LINEV    : 238.0 Volts
    LOADPCT  : 54.0 Percent
    BCHARGE  : 100.0 Percent
    TIMELEFT : 10.9 Minutes
    MBATTCHG : 5 Percent
    MINTIMEL : 3 Minutes
    MAXTIME  : 0 Seconds
    SENSE    : Medium
    LOTRANS  : 180.0 Volts
    HITRANS  : 266.0 Volts
    ALARMDEL : 30 Seconds
    BATTV    : 13.6 Volts
    LASTXFER : Low line voltage
    NUMXFERS : 0
    TONBATT  : 0 Seconds
    CUMONBATT: 0 Seconds
    XOFFBATT : N/A
    STATFLAG : 0x05000008
    SERIALNO : 5B1414T05263  
    BATTDATE : 2014-04-03
    NOMINV   : 230 Volts
    NOMBATTV : 12.0 Volts
    FIRMWARE : 871.O3 .I USB FW:O3
    END APC  : 2018-05-20 13:36:44 +0200

Slack integration
--------------
This is still a _TODO_.
