//
//  KCUtilNet.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "KCUtilNet.h"



@implementation KCUtilNet


/************************************************************/
/*
 IMSI 共有 15 位，其结构如下：
 　　 MCC+MNC+MSIN ，（ MNC+MSIN=NMSI ）
 　　 MCC ： Mobile Country Code ，移动国家码， MCC 的资源由国际电联（ ITU ）统一分配和管理，唯一识别移动用户所属的国家，共 3 位，中国为 460;
 　　 MNC:Mobile Network Code ，移动网络码，共 2 位，中国移动 TD 系统使用 00 ，中国联通 GSM 系统使用 01 ，中国移动 GSM 系统使用 02 ，中国电信 CDMA 系统使用 03 ，一个典型的 IMSI 号码为 460030912121001;
 　　 MSIN:Mobile Subscriber Identification Number 共有 10 位，其结构如下：
 　　 09+M0M1M2M3+ABCD
 其中的 M0M1M2M3 和 MDN 号码中的 H0H1H2H3 可存在对应关系， ABCD 四位为自由分配。
 这样就可以依据 IMSI 中的 MCC 和 MNC 来确定运营商了。当然知道编码规则同时还是需要知道对应编码的的国家和网络了。
 */
/* China - CN
 * MCC    MNC    Brand    Operator                Status        Bands (MHz)                                    References and notes
 * 460    00            China Mobile            Operational    GSM 900/GSM 1800 UMTS (TD-SCDMA) 1880/2010
 * 460    01            China Unicom            Operational    GSM 900/GSM 1800/ UMTS 2100                    CDMA network sold to China Telecom, WCDMA commercial trial started in May 2009 and in full commercial operation as of October 2009.
 * 460    02            China Mobile            Operational    GSM 900/GSM 1800/ UMTS (TD-SCDMA) 1880/2010
 * 460    03            China Telecom            Operational    CDMA 800/cdma evdo 2100
 * 460    05            China Telecom            Operational
 * 460    06            China Unicom            Operational    GSM 900/GSM 1800/UMTS 2100
 * 460    07            China Mobile            Operational    GSM 900/GSM 1800/UMTS (TD-SCDMA) 1880/2010
 * 460    20            China Tietong            Operational    GSM-R
 * NA    NA            China Telecom&China Unicom    Operational
 */
/************************************************************/

+(NSString*)getCarrier:(NSString*)aIMSI
{
    if (aIMSI == nil || aIMSI.length == 0 || [aIMSI isEqualToString:@"SIM Not Inserted"] )
    {
        return @"Unknown";
    }
    else
    {
        if ([[aIMSI substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"460"])
        {
            NSInteger MNC = [[aIMSI substringWithRange:NSMakeRange(3, 2)] intValue];
            switch (MNC)
            {
                case 00:
                case 02:
                case 07:
                    return @"China Mobile";
                    break;
                case 01:
                case 06:
                    return @"China Unicom";
                    break;
                case 03:
                case 05:
                    return @"China Telecom";
                    break;
                case 20:
                    return @"China Tietong";
                    break;
                default:
                    break;
            }
        }
    }
    return @"Unknown";
}


@end
