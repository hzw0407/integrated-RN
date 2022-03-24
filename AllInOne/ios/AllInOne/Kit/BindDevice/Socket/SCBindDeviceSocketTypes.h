//
//  SCBindDeviceSocketTypes.h
//  AllInOne
//
//  Created by 3i_yang on 2021/11/29.
//

#ifndef SCSocketTypes_h
#define SCSocketTypes_h

/*
 头部数据
 */
typedef struct {
    /// 头部标记位 0x51589158
    unsigned int head_flag;
    /// 命令组 默认为0
    unsigned int cmd_group;
    /// 命令ID 发送WiFi信息给设备时为101，获取设备sn信息时为102，停止通信为105
    unsigned int cmd_id;
    /// body数据长度
    unsigned int len;
    unsigned int reserved;
} SCBindDeviceAccessPointHeadData;

typedef struct {
    char ssid[32];
    char password[32];
    char key[16];
    int  userId;
    char host[32]; 
    int  port;
} SCDeviceAccessPointWifiData;

#endif /* SCSocketTypes_h */
