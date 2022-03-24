//
//  SCSwepperFaultType.swift
//  AllInOne
//
//  Created by 3i_yang on 2022/2/16.
//

import UIKit

enum SCSwepperFaultType: Int {
    case FAULT_NONE = 0
    case FAULT_HWDRIVER = 100
    /// 雷达超时
    case FAULT_LIDAR_TIME_OUT = 500
    /// 机器抬起
    case FAULT_WHEEL_UP = 501
    /// 低电量启动
    case FAULT_LOW_START_BATTERY = 502
    /// 尘盒未安装
    case FAULT_DUSTBOX_NOT_EXIST = 503
    /// 地磁异常
    case FAULT_GEOMAGETISM_STRUCT = 504
    /// 启动失败
    case FAULT_START_DOCK_FAILED = 505
    /// 沿边红外异常
    case FAULT_CODE_506 = 506
    /// 重定位失败
    case FAULT_RELOCALIZATION_FAILED = 507
    /// 水平地面启动失败
    case FAULT_SLOPE_START_FAILED = 508
    /// 地检异常
    case FAULT_CLIFF_IR_STRUCT = 509
    /// 碰撞异常
    case FAULT_BUMPER_STRUCT = 510
    /// 回充失败
    case FAULT_GO_DOCK_FAILED = 511
    /// 请将主机返回充电座
    case FAULT_PUT_MACHINE_DOCK = 512
    /// 导航失败
    case FAULT_NAVIGATION_FAILED = 513
    /// 脱困失败
    case FAULT_ESCAPE_FAILED = 514
    /// 充电异常
    case FAULT_DOCK_CLIP_EXCEPTION = 515
    /// 电池温度异常
    case FAULT_BATTERY_TEMPATURE = 516
    /// 系统升级中
    case FAULT_SYSTEM_UPGRADE = 517
    /// 等待充电完成(断点时电量未满足启动条件)
    case FAULT_WAIT_CHARGE_FINISH = 518
    /// 滚刷失速
    case FAULT_ROLL_BRUSH_STALL = 519
    /// 边刷失速
    case FAULT_SIDE_BRUSH_STALL = 520
    /// 水箱未安装
    case FAULT_WATERBOX_NOT_EXIST = 521
    /// 拖布未安装
    case FAULT_MOPPINT_NOT_EXIST = 522
    /// 尘盒已满
    case FAULT_HANDPPEN_DUSTBOX_FULL        = 523
    /// 沿墙传感器被灰尘遮挡
    case FAULT_POWER_SWITCH_NOT_OPEN        = 524
    /// 水箱空
    case FAULT_WATERTUNK_EMPTY = 525
    /// 拖布脏
    case FAULT_DISHCLOTH_DIRTY = 526
    ///  请取消拖布
    case FAULT_PLS_REMOVE_MOP = 527
    /// 请安装尘盒和取下拖布
    case FAULT_PLS_INSTALL_DUSTBOX_AND_REMOVE_MOP = 528
    /// 请确认二合一水箱和拖布已装好
    case FAULT_PLS_INSTALL_MOP_AND_WATERBOX = 529
    /// 请确认二合一水箱和拖布已装好
    case FAULT_PLS_INSTALL_DUSTBIN_AND_MOP = 530
    /// 请确认水箱已装好
    case FAULT_PLS_INSTALL_DUSTBIN = 531
    /// 充电中，请取下拖布和水箱
    case FAULT_CHARGE_WITH_MOP = 532
    /// 主机待机时间过长，关机
    case FAULT_WAITING_SHUTDOWN = 533
    /// 主机电量低，关机
    case FAULT_LOW_BATTERY_SHUTDOWN = 534
    /// 充电中，建议取下拖布和水箱，及时清洁保养
    case FAULT_CHARGING_PLS_REMOVE_BOTH_MOP = 535
    /// 充电中，建议取下拖布与550Ml水箱，及时清洁保养
    case FAULT_CHARGING_PLS_REMOVE_WATER_MOP = 536
    /// 没有安装水箱和尘盒，启动扫拖
    case FAULT_PLS_INSTALL_DUST_BOX_AND_WATERBOX = 540
    /// 带尘盒完成回充成功
    case FAULT_CHARGE_WITH_DUST_BOX = 541
    /// 带水箱完成回充成功
    case FAULT_CHARGE_WITH_WATER_BOX = 542
    /// 电池温度异常
    case FAULT_BATTERY_TEMPERATURE_EXCEPTION = 550
    /// 电池温度恢复正常
    case FAULT_BATTERY_TEMPERATURE_TO_NORMAL = 551
    /// 建图失败
    case FAULT_ROBOT_MAP_CREATE_FAIL = 559
    
    /// 边扫卡死报警
    case FAULT_SIDE_BRUSH_STUCK = 560
    /// 摄像头遮档
    case FAULT_RGB_COVERED = 561 // 210714
    /// 沿边红外灰尘遮档
    case FAULT_FOLLOW_IR_DUST = 562 // 210714
    /// 尘盒脱落
    case FAULT_DUSTBOX_FALL = 563 // 210714
    /// 二合一水箱脱落
    case FAULT_DUSTBIN_FALL = 564 // 210714
    /// 雷达遮档异常
    case FAULT_LIDAR_SHELTER = 565
    /// 水箱脱落
    case FAULT_WATERBOX_FALL = 566 // 210714
    /// 中扫过流保护
    case FAULT_ROLL_BRUSH_ENTANGLED = 567
    
    /// 左轮异常
    case FAULT_LEFT_WHELL_EXCEPTION = 568
    /// 右轮异常
    case FAULT_RIGHT_WHELL_EXCEPTION = 569
    /// 主刷异常
    case FAULT_MAIN_BRUSH_EXCEPTION = 570
    
    /// 机器在虚拟墙内启动 260新增 1021
    case FAULT_START_IN_VIRTUAL_WALL = 572
    
    /// 风机异常
    case FAULT_BLOWER_EXCEPTION = 573
    
    /// 雷达被缠绕或卡住
    case FAULT_CODE_574                     = 574
    case FAULT_CODE_581                     = 581  //清水不足，请添加
    case FAULT_CODE_582                     = 582  //请及时清理污水箱
    case FAULT_CODE_583                     = 583  //请确认清水箱已装好
    case FAULT_CODE_584                     = 584  //请确认污水箱已装好
    case FAULT_CODE_585                     = 585  //请确认污水网已装好
    case FAULT_CODE_586                     = 586  //请及时清理污水槽
    case FAULT_CODE_587                     = 587  //主机和水站连接异常
    case FAULT_CODE_588                     = 588 //毛毯检测异常
    case FAULT_CODE_589                     = 589
    case FAULT_CODE_590                     = 590 //集尘失败-顶盖打开/未安装尘袋
    case FAULT_CODE_591                     = 591 //尘袋已满
    
    case FAULT_CODE_592                     = 592 // 清洁HEPA中
    
    case FAULT_CODE_593                     = 593 // 集尘失败-顶盖打开
    
    case FAULT_CODE_594                     = 594 // 集尘失败-未安装尘袋
    
    case FAULT_CODE_595                     = 595 // 集尘失败-通信超时
    
    case FAULT_CODE_596                     = 596 // 集尘失败-集尘中断电
    
    /// 定位失败，请搬到充电座后重新建图 260新增 1021
    case FAULT_CODE_611                     = 611 //AULT_BUILD_MAP_RELOCALIZATION_FAILED = 611
    
    /// 指哪划区定位失败 260新增 1021
    case FAULT_CODE_612                     = 612 //FAULT_SPECIFY_ZONE_RELOCALIZATION_FAILED = 612
    
    /// 尘盒已满
    case FAULT_DUSBOX_FULL                  = 2000
    /// 左刷卡住
    case FAULT_BRUSH_LEFT_BLOCK             = 2001
    /// 右刷卡住
    case FAULT_BRUSH_RIGHT_BLOCK            = 2002
    /// 低电量预约启动失败
    case FAULT_LOW_POWER_RESERVATION_FAILURE = 2003
    
    case FAULT_PATH_PLAN_FAIL               = 2007
    
    /// 部分区域不可达,清扫未完成 260新增 1021
    case FAULT_CODE_2012                    = 2012 //FAULT_PART_AREA_NAVI_FAIL = 2012
    case FAULT_CODE_2013                    = 2013
    case FAULT_CODE_2014                    = 2014
    case FAULT_CODE_2015                    = 2015
    case FAULT_CODE_2017                    = 2017
    
    /// 断点回充中
    case FAULT_BROKEN_GO_HOME               = 2100
    /// 断点充电中
    case FAULT_BROKEN_CHARING               = 2101
    /// 回充中
    case FAULT_ROBOT_GLOBAL_GO_HOME         = 2102
    /// 正在充电
    case FAULT_ROBOT_CHAGING                = 2103
    /// 手动回充中
    case FAULT_ROBOT_USER_GO_HOME = 2104
    /// 充电完成
    case FAULT_ROBOT_CHARGE_FINISH = 2105
    /// 断点，等待充电完成
    case FAULT_BROKEN_CHARGING_WAIT     = 2106
    /// 预约清扫中
    case FAULT_GLOBAL_APPOINT_CLEAN     = 2107
    /// 重定位中，请等待
    case FAULT_ROBOT_RELOCALIZATION_ING = 2108
    /// 二次清扫中
    case FAULT_ROBOT_REPEAT_CLEAN_ING = 2109
    /// 设备自检中
    case FAULT_ROBOT_SELF_CHECK_ING = 2110
    /// 地图生成中
    case FAULT_ROBOT_MAP_GENERATING = 2111
    /// 建图中
    case FAULT_ROBOT_MAP_CREATING = 2112
    /// 机器已经连续清扫15小时 尘满提醒
    case FAULT_ROBOT_DUST_FULL = 2114
    
    /// 算法线程退出
    case FAULT_THREAD_EXIT = 2200
    /// 算法硬件线程退出
    case FAULT_THREAD_EVEREST_HWDRIVER = 2201
    /// 算法交互线程退出
    case FAULT_THREAD_EVEREST_APP = 2202
    /// 算法逻辑线程退出
    case FAULT_THREAD_EVEREST_CONTROLLER = 2203
    /// 算法动作线程退出
    case FAULT_THREAD_EVEREST_MOTION = 2204
    /// 算法SLAM线程退出
    case FAULT_THREAD_SLAM_MOTION = 2205
    
    func subtitle(batteryType: SCSweeperLowBatteryType = .default) -> String? {
        switch self {
        case .FAULT_LOW_START_BATTERY:
            switch batteryType {
            case .charging:
                return tempLocalize("fault_wait_charge_finish")
            case .recharging:
                return tempLocalize("fault_back_to_charge")
            case .default:
                return tempLocalize("fault_low_start_battery")
            }
        case .FAULT_BROKEN_GO_HOME:
            return tempLocalize("fault_broken_back_to_charge")
        case .FAULT_BROKEN_CHARING:
            return tempLocalize("fault_broken_robot_charging")
        case .FAULT_ROBOT_CHARGE_FINISH:
            return tempLocalize("fault_robot_charge_finish")
        case .FAULT_ROBOT_RELOCALIZATION_ING:
            return tempLocalize("fault_robot_relocalization_ing")
        case .FAULT_ROBOT_REPEAT_CLEAN_ING:
            return tempLocalize("fault_robot_repeat_clean_ing")
        case .FAULT_ROBOT_SELF_CHECK_ING:
            return tempLocalize("fault_robot_self_check_ing")
        case .FAULT_ROBOT_MAP_GENERATING:
            return tempLocalize("fault_robot_map_generating")
        case .FAULT_ROBOT_MAP_CREATING:
            return tempLocalize("fault_robot_map_building_map")
        default:
            return nil
        }
    }
   
    /// 故障卡片标题
    var cardTitle: String {
        switch self {
        case .FAULT_LIDAR_TIME_OUT: // 500
            return tempLocalize("fault_lidar_time_out")
        case .FAULT_WHEEL_UP:                       //501
            return tempLocalize("fault_wheel_up")
        case .FAULT_LOW_START_BATTERY:            // 502
            return tempLocalize("fault_low_start_battery")
        case .FAULT_DUSTBOX_NOT_EXIST:            // 503
            return tempLocalize("fault_dustbox_not_exist")
        case .FAULT_CODE_506:                      // 506
            return tempLocalize("fault_title_506")
        case .FAULT_SLOPE_START_FAILED:            // 508
            return tempLocalize("fault_slope_start_failed")
        case .FAULT_CLIFF_IR_STRUCT:                // 509
            return tempLocalize("fault_cliff_ir_struct")
        case .FAULT_BUMPER_STRUCT:                  // 510
            return tempLocalize("fault_bumper_struct")
        case .FAULT_GO_DOCK_FAILED:               // 511
            return tempLocalize("fault_go_dock_failed")
        case .FAULT_PUT_MACHINE_DOCK:             // 512
            return tempLocalize("fault_put_machine_dock")
        case .FAULT_NAVIGATION_FAILED:            // 513
            return tempLocalize("fault_navigation_failed")
        case .FAULT_ESCAPE_FAILED:                // 514
            return tempLocalize("fault_escape_failed")
            
        case .FAULT_SYSTEM_UPGRADE:                // 517
            return tempLocalize("fault_code_517_card_title")
        case .FAULT_WAIT_CHARGE_FINISH:           // 518
            return tempLocalize("fault_wait_charge_finish")
        case .FAULT_WATERBOX_NOT_EXIST:           // 521
            return tempLocalize("fault_waterbox_not_exist")
        case .FAULT_MOPPINT_NOT_EXIST:            // 522
            return tempLocalize("fault_mopping_not_exist")
        case .FAULT_WATERTUNK_EMPTY:             // 525
            return tempLocalize("fault_watertunk_empty")
        case .FAULT_PLS_INSTALL_MOP_AND_WATERBOX:                   // 529 // 请安装拖布和水箱 201113
            return tempLocalize("fault_pls_install_mop_and_waterbox")
        case .FAULT_WAITING_SHUTDOWN:            // 533 // 机器人待机时间过长，已关机 201113
            return tempLocalize("fault_auto_power_atfer_12_hours_idle")
        case .FAULT_LOW_BATTERY_SHUTDOWN:            // 534 // 机器人电量低，已关机 201113
            return tempLocalize("fault_auot_power_below_15_battery_percent")
        case .FAULT_BATTERY_TEMPERATURE_EXCEPTION: // 550
            return tempLocalize("fault_battery_temperature_exception")
        case .FAULT_BATTERY_TEMPERATURE_TO_NORMAL: // 551
            return tempLocalize("fault_battery_temperature_to_normal")
        case .FAULT_ROBOT_MAP_CREATE_FAIL: // 559
            return tempLocalize("fault_create_map_fail")
        /// 边扫卡死报警
        case .FAULT_SIDE_BRUSH_STUCK:           // 560
            return tempLocalize("fault_side_brush_entangled")
        case .FAULT_RGB_COVERED:        // 561
            return tempLocalize("fault_rgb_covered")
        case .FAULT_FOLLOW_IR_DUST:     // 562
            return tempLocalize("fault_follow_ir_dust")
        case .FAULT_DUSTBOX_FALL: // 563
            return tempLocalize("fault_dustbox_fall")
        case .FAULT_DUSTBIN_FALL:
            return tempLocalize("fault_dustbin_fall")
        /// 雷达遮档异常
        case .FAULT_LIDAR_SHELTER:              // 565
            return tempLocalize("fault_lidar_shelter")    // 210714
        case .FAULT_WATERBOX_FALL:
            return tempLocalize("fault_waterbox_fall")
            
        case .FAULT_ROLL_BRUSH_ENTANGLED:       // 567
            return tempLocalize("fault_rool_brush_entangled")
        case .FAULT_LEFT_WHELL_EXCEPTION:       // 568
            return tempLocalize("fault_title_568")
        case .FAULT_RIGHT_WHELL_EXCEPTION:       // 569
            return tempLocalize("fault_title_569")
        case .FAULT_MAIN_BRUSH_EXCEPTION: // 570
            return tempLocalize("fault_main_brush_exception")
        case .FAULT_START_IN_VIRTUAL_WALL:       // 572
            return tempLocalize("fault_start_in_virtual_wall")
        case .FAULT_BLOWER_EXCEPTION: // 573
            return tempLocalize("fault_blower_exception")
        case .FAULT_CODE_574:
            return tempLocalize("fault_code_574_card_title")
        case .FAULT_CODE_581:
            return tempLocalize("fault_code_581_card_title")
        case .FAULT_CODE_582:
            return tempLocalize("fault_code_582_card_title")
        case .FAULT_CODE_583:
            return tempLocalize("fault_code_583_card_title")
        case .FAULT_CODE_584:
            return tempLocalize("fault_code_584_card_title")
        case .FAULT_CODE_585:
            return tempLocalize("fault_code_585_card_title")
        case .FAULT_CODE_586:
            return tempLocalize("fault_code_586_card_title")
        case .FAULT_CODE_587:
            return tempLocalize("fault_code_587_card_title")
        case .FAULT_CODE_588:
            return tempLocalize("fault_code_588_card_title")
        case .FAULT_CODE_589:
            return tempLocalize("fault_code_589_card_title")
        case .FAULT_CODE_590: //集尘失败-顶盖打开/未安装尘袋
            return tempLocalize("fault_code_590_card_title")
        case .FAULT_CODE_591: //尘袋已满
            return tempLocalize("fault_code_591_card_title")
        case .FAULT_CODE_592: // 清洁HEPA中
            return tempLocalize("fault_code_592_card_title")
        case .FAULT_CODE_593:
            return tempLocalize("fault_code_593_card_title")
        case .FAULT_CODE_594:
            return tempLocalize("fault_code_594_card_title")
        case .FAULT_CODE_595:
            return tempLocalize("fault_code_595_card_title")
        case .FAULT_CODE_596:
            return tempLocalize("fault_code_596_card_title")
        case .FAULT_CODE_611:
            return tempLocalize("fault_code_611_card_title")
        case .FAULT_CODE_612:
            return tempLocalize("fault_code_612_card_title")
        case .FAULT_CODE_2012:
            return tempLocalize("fault_code_2012_card_title")
        case .FAULT_CODE_2013:
            return tempLocalize("fault_code_2013_card_title")
        case .FAULT_CODE_2014:
            return tempLocalize("fault_title_2014")
        case .FAULT_CODE_2015:
            return tempLocalize("fault_code_2015_card_title")
        case .FAULT_CODE_2017:
            return tempLocalize("fault_code_2017_card_title")
        case .FAULT_DUSBOX_FULL:                // 2000
            return tempLocalize("fault_dusbox_full")
        case .FAULT_PATH_PLAN_FAIL:             // 2007
            return tempLocalize("fault_path_plan_fail")
        case .FAULT_ROBOT_DUST_FULL:
            return tempLocalize("fault_robot_dust_full")
        default:
            return ""
        }
    }
    
    var exceptionType: SCSweeperDeviceFaultExceptionType {
        switch self {
        case .FAULT_LIDAR_TIME_OUT: // 500
            return .warn
        case .FAULT_WHEEL_UP:                       //501
            return .warn
        case .FAULT_LOW_START_BATTERY:            // 502
            return .warn
        case .FAULT_DUSTBOX_NOT_EXIST:            // 503
            return .warn
        case .FAULT_SLOPE_START_FAILED:            // 508
            return .warn
        case .FAULT_CLIFF_IR_STRUCT:                // 509
            return .warn
        case .FAULT_BUMPER_STRUCT:                  // 510
            return .warn
        case .FAULT_GO_DOCK_FAILED:               // 511
            return .warn
        case .FAULT_PUT_MACHINE_DOCK:             // 512
            return .warn
        case .FAULT_NAVIGATION_FAILED:            // 513
            return .warn
        case .FAULT_ESCAPE_FAILED:                // 514
            return .warn
        case .FAULT_WAIT_CHARGE_FINISH:           // 518
            return .warn
        case .FAULT_WATERBOX_NOT_EXIST:           // 521
            return .warn
        case .FAULT_MOPPINT_NOT_EXIST:            // 522
            return .warn
        case .FAULT_WATERTUNK_EMPTY:             // 525
            return .warn
        case .FAULT_PLS_INSTALL_MOP_AND_WATERBOX: // 529 // 请安装拖布和水箱 201113
            return .warn
        case .FAULT_WAITING_SHUTDOWN:            // 533 // 机器人待机时间过长，已关机 201113
            return .warn
        case .FAULT_LOW_BATTERY_SHUTDOWN:            // 534 // 机器人电量低，已关机 201113
            return .warn
        case .FAULT_BATTERY_TEMPERATURE_EXCEPTION: // 550
            return .warn
        case .FAULT_BATTERY_TEMPERATURE_TO_NORMAL: // 551
            return .warn
        case .FAULT_ROBOT_MAP_CREATE_FAIL: // 559
            return .warn
        /// 边扫卡死报警
        case .FAULT_SIDE_BRUSH_STUCK:           // 560
            return .warn
        case .FAULT_RGB_COVERED:        // 561
            return .warn
        case .FAULT_FOLLOW_IR_DUST:     // 562
            return .warn
        case .FAULT_DUSTBOX_FALL: // 563
            return .warn
        case .FAULT_DUSTBIN_FALL:
            return .warn
        /// 雷达遮档异常
        case .FAULT_LIDAR_SHELTER:              // 565
            return .warn    // 210714
        case .FAULT_WATERBOX_FALL:
            return .warn
        case .FAULT_ROLL_BRUSH_ENTANGLED:       // 567
            return .warn
        case .FAULT_LEFT_WHELL_EXCEPTION:       // 568
            return .warn
        case .FAULT_RIGHT_WHELL_EXCEPTION:       // 569
            return .warn
        case .FAULT_MAIN_BRUSH_EXCEPTION:
            return .warn
        case .FAULT_START_IN_VIRTUAL_WALL:      //572
            return .warn
        case .FAULT_BLOWER_EXCEPTION: // 573
            return .warn
        case .FAULT_DUSBOX_FULL:                // 2000
            return .warn
        case .FAULT_PATH_PLAN_FAIL:             // 2007
            return .warn
        case .FAULT_ROBOT_DUST_FULL:
            return .bell
        case .FAULT_SYSTEM_UPGRADE, .FAULT_CODE_574, .FAULT_CODE_581, .FAULT_CODE_582, .FAULT_CODE_583, .FAULT_CODE_584, .FAULT_CODE_585, .FAULT_CODE_586, .FAULT_CODE_587, .FAULT_CODE_588, .FAULT_CODE_589, .FAULT_CODE_590, .FAULT_CODE_591, .FAULT_CODE_592, .FAULT_CODE_593, .FAULT_CODE_594, .FAULT_CODE_595, .FAULT_CODE_596, .FAULT_CODE_611, .FAULT_CODE_612, .FAULT_CODE_2012, .FAULT_CODE_2013, .FAULT_CODE_2014, .FAULT_CODE_2015, .FAULT_CODE_2017, .FAULT_CODE_506:
            return .warn
        default:
            return .none
        }
    }
    
    /// 故障卡片描述
    var cardDescription: String {
        switch self {
        case .FAULT_LIDAR_TIME_OUT:             // 500
            return kLocalize("fault_lidar_time_out_msg")
        case .FAULT_WHEEL_UP:                   // 501
            return kLocalize("fault_wheel_up_msg")
        case .FAULT_LOW_START_BATTERY:            // 502
            return kLocalize("fault_low_start_battery_msg")
        case .FAULT_DUSTBOX_NOT_EXIST:            // 503
            return kLocalize("fault_dustbox_not_exist_msg")
        case .FAULT_SLOPE_START_FAILED:            // 508
            return kLocalize("fault_slope_start_failed_msg")
        case .FAULT_CLIFF_IR_STRUCT:                // 509
            return kLocalize("fault_cliff_ir_struct_msg")
        case .FAULT_BUMPER_STRUCT:                  // 510
            return kLocalize("fault_bumper_struct_msg")
        case .FAULT_GO_DOCK_FAILED:               // 511
            return kLocalize("fault_go_dock_failed_msg")
        case .FAULT_PUT_MACHINE_DOCK:             // 512
            return kLocalize("fault_put_machine_dock_msg")
        case .FAULT_NAVIGATION_FAILED:            // 513
            return kLocalize("fault_navigation_failed_msg")
        case .FAULT_ESCAPE_FAILED:                // 514
            return kLocalize("fault_escape_failed_msg")
        case .FAULT_WAIT_CHARGE_FINISH:           // 518
            return kLocalize("fault_wait_charge_finish_msg")
        case .FAULT_WATERBOX_NOT_EXIST:           // 521
            return kLocalize("fault_waterbox_not_exist")
        case .FAULT_MOPPINT_NOT_EXIST:            // 522
            return kLocalize("fault_mopping_not_exist")
        case .FAULT_WATERTUNK_EMPTY:             // 525
            return kLocalize("fault_watertunk_empty")
        case .FAULT_PLS_INSTALL_MOP_AND_WATERBOX:                   // 529 // 请安装拖布和水箱 201113
            return kLocalize("fault_pls_install_mop_and_waterbox_msg")
        case .FAULT_WAITING_SHUTDOWN:            // 533 // 机器人待机时间过长，已关机 201113
            return kLocalize("fault_auto_power_atfer_12_hours_idle_msg")
        case .FAULT_LOW_BATTERY_SHUTDOWN:            // 534 // 机器人电量低，已关机 201113
            return kLocalize("fault_auot_power_below_15_battery_percent_msg")
        case .FAULT_ROBOT_MAP_CREATE_FAIL: // 559
            return kLocalize("fault_robot_map_create_fail")
        /// 边扫卡死报警
        case .FAULT_SIDE_BRUSH_STUCK:           // 560
            return kLocalize("fault_side_brush_entangled_msg")
        case .FAULT_RGB_COVERED:
            return kLocalize("fault_rgb_covered_msg")
        case .FAULT_FOLLOW_IR_DUST:
            return kLocalize("fault_follow_ir_dust_msg")
        case .FAULT_DUSBOX_FULL:
            return kLocalize("fault_dustbox_fall_msg")
        case .FAULT_DUSTBIN_FALL:
            return kLocalize("fault_dustbin_fall_msg")
        /// 雷达遮挡异常
        case .FAULT_LIDAR_SHELTER:              // 565
            return kLocalize("fault_lidar_shelter_msg") // 210714
        case .FAULT_WATERBOX_FALL:              // 566
            return kLocalize("fault_waterbox_fall_msg")
        case .FAULT_MAIN_BRUSH_EXCEPTION:
            return kLocalize("fault_main_brush_exception_msg")
        case .FAULT_BLOWER_EXCEPTION: // 573
            return kLocalize("fault_blower_exception_msg")
        
        case .FAULT_PATH_PLAN_FAIL:             // 2007
            return kLocalize("fault_path_plan_fail")
        default:
            return ""
        }
    }
}

enum SCSweeperLowBatteryType: Int {
    ///  待机中、清扫中、扫拖中、拖地中
    case `default`
    /// 充电中
    case charging
    /// 回充中
    case recharging
}


enum SCSweeperDeviceFaultExceptionType: Int {
    /// 无状态
    case none
    /// 警告
    case warn
    /// 铃铛
    case bell
}
