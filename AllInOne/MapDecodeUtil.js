import protobuf from 'protobufjs';
const pako = require('./pako.min'); // 项目外的js

// 处理地图的解压，解析逻辑
let robotMapManger = null; // 总的解析模型
let is30V = false;
let robotMap = null; // proto最终的数据模型
let maskInfo = {}; // 掩码信息
let validInfo = { vMinX: 400, vMaxX: 400, vMinY: 400, vMaxY: 400 };
let mapHeadInfo = {}; // 地图头
let historyInfo = {}; // 历史记录头信息
let chargeInfo = {}; // 充电座位置
let wallsInfo = {}; // 虚拟墙
let areasInfo = {}; // 划区
let spotInfo = {}; // 指哪点
let pointInfo = {}; // 位置点
let planInfo = {}; // 方案
let matrixInfo = []; // 矩阵
let cleanRoomsInfo = []; // 清扫中的房间
let chainsInfo = {}; // 链条

let values = []; // 解压后的字节数组
let mapData = []; // 地图的64万个
let rgbaArray = []; // rgba数组
let offset = 0;  // 解析的偏移量
let log = [];//缓存日志信息

export const mapDecode = (result) => {
    // 如果是使用十六进制数据需要进行以下数据组装后再解压 否则直接使用传进来的数据进行解压
    /*
    test.json里面如果使用十六进制数据如下所示
    “789c eddd 5b8c 1d75.....”
    test.json里面如果使用十进制的数据如下所示
    [ 120, 156, 237, 221, 127, 144, 156...... ]
    */
    let byteArray = new Array();
    for (let i = 0; i < result.length; i += 5) {
      let value1 = result.substr(i, 2);
      byteArray.push(stringToHex(value1));
      if (i + 2 <= result.length) {
        let value2 = result.substr(i + 2, 2);
        byteArray.push(stringToHex(value2));
      }
    }
    let uint8Array = new Uint8Array(byteArray);

    
    console.log('-------------------解压前长度111:', result.length);  
    const values = pako.inflate(uint8Array);
    console.log('-------------------解压后:', values.length);
    // console.log('数据 = ', values);
    if (values.length == 0 || values == undefined || values == null) {
        console.log('解压失败');
        return null;
    }
    // const values = result;
    // 解析工具使用库解析，已验证
    if (!robotMapManger){
        setupProto();
    }
    let robotMap = null;
    // console.log('解析新数据格式:', robotMapManger);
    try {
        robotMap = robotMapManger.decode(values);
        if (robotMap == undefined || robotMap == null) {
            console.log('解析新数据解析失败');
            return null;
        }
        logRobotMap(robotMap);
    } catch (error) {
        console.log('robotMapManger.decode error:', error);
    }
    return robotMap;
}

// 处理旧地图的解压，解析逻辑
export const parseTxtData = (result) => {
   
    console.log('-------------------解压前长度2222:', result.length);  
    const values = pako.inflate(result);
    console.log('-------------------解压后:', values.length);
    if (values.length == 0 || values == undefined || values == null) {
        console.log('解压失败');
        return null;
    }
    
    var is32 = true;
            var isConnitue = true; // 先解析32位，不对的话再解析16位
            var testCount = 5;
            while (isConnitue && testCount > 0) {
                let mask = getDataInt4(is32 ? 4 : 2);
                console.log('mask:', mask);
                parseMaskData(mask);
                if (maskInfo.hasStatus) {
                    offset += 11 * 4;
                }
                parseMapHeader();
                if (mapHeadInfo.resolution != 0.05 &&
                    mapHeadInfo.resolution != 0.02) {
                    console.log('解析不对，再来:', mapHeadInfo.resolution, is32);
                    is32 = !is32;
                    offset = 0;
                    testCount -= 1;
                } else {
                    isConnitue = false;
                }
            }
            if (testCount == 0) {
                console.log('数据不对，停止解析');
                return null;
            }
            console.log('掩码位数:', is32 ? '32' : '16');
            let mapDataLength = mapHeadInfo.size_x * mapHeadInfo.size_y;
            mapData = getDataSome(mapDataLength);
            offset += mapDataLength;
           // parseBase64Map();
           mapHeadInfo.mapData = mapData;
           return mapHeadInfo;
            // console.log(`drawUtil.mapHead:`, drawUtil.mapHead);
  

    
}

function stringToHex(str) {
    const c = str.substr(0, 1);
    const high = parseInt(c, 16);

    const b = str.substr(1, 1);
    const low = parseInt(b, 16);
    const num = (high << 4) | low;
    return num;
  }

 // 获取前4个字节，返回Int32值
 function getDataInt4(length = 4) {
    var value = 0;
    if (length == 4) {
        value = values[offset] | (values[offset + 1] << 8) | (values[offset + 2] << 16) | (values[offset + 3] << 24);
    } else if (length == 2) {
        value = values[offset] | (values[offset + 1] << 8);
    } else if (length == 1) {
        value = values[offset];
    }
    offset += length;
    return value;
}

 // 获取前4个字节，返回Float值
 function getDataFloat4(length = 4) {
    try {
        let value = values[offset + 0] | (values[offset + 1] << 8) | (values[offset + 2] << 16) | (values[offset + 3] << 24);
        var sign = (value & 0x80000000) ? -1 : 1;
        var exponent = ((value >> 23) & 0xFF) - 127;
        var significand = (value & ~(-1 << 23));
        if (exponent == 128)
            return sign * ((significand) ? Number.NaN : Number.POSITIVE_INFINITY);
        if (exponent == -127) {
            if (significand == 0) return sign * 0.0;
            exponent = -126;
            significand /= (1 << 22);
        } else significand = (significand | (1 << 23)) / (1 << 23);
    } catch (error) {
        console.log('error:', JSON.stringify(error));
    } finally {
        offset += length;
    }
    return sign * significand * Math.pow(2, exponent);
}

  //解析掩码信息
  function parseMaskData(mapMaskInt32) {
    maskInfo.hasStatus = (mapMaskInt32 >> 0) & 0x01 == 1;
    maskInfo.hasMap = (mapMaskInt32 >> 1) & 0x01 == 1;
    maskInfo.hasHistory = (mapMaskInt32 >> 2) & 0x01 == 1;
    maskInfo.hasCharge = (mapMaskInt32 >> 3) & 0x01 == 1;

    maskInfo.hasDpWall = (mapMaskInt32 >> 4) & 0x01 == 1;
    maskInfo.hasZone = (mapMaskInt32 >> 5) & 0x01 == 1;
    maskInfo.hasWhich = (mapMaskInt32 >> 6) & 0x01 == 1;
    maskInfo.hasPostion = (mapMaskInt32 >> 7) & 0x01 == 1;

    maskInfo.hasPlanRoom = (mapMaskInt32 >> 11) & 0x01 == 1;
    maskInfo.hasRoomMatrix = (mapMaskInt32 >> 12) & 0x01 == 1;
    maskInfo.hasCleaningRoom = (mapMaskInt32 >> 13) & 0x01 == 1;
    maskInfo.hasRoomChain = (mapMaskInt32 >> 14) & 0x01 == 1;
    console.log('maskInfo = ' + JSON.stringify(maskInfo));
}

function parseMapHeader() {
    mapHeadInfo.map_head_id = getDataInt4();
    mapHeadInfo.room_clean_plan_id = getDataInt4();
    mapHeadInfo.map_type = getDataInt4();
    mapHeadInfo.size_x = getDataInt4();
    mapHeadInfo.size_y = getDataInt4();
    mapHeadInfo.min_x = getDataFloat4();
    mapHeadInfo.min_y = getDataFloat4();
    mapHeadInfo.max_x = getDataFloat4();
    mapHeadInfo.max_y = getDataFloat4();
    mapHeadInfo.resolution = getDataFloat4().toFixed(2);
    console.log(`map_head_id = ${mapHeadInfo.map_head_id}, room_clean_plan_id = ${mapHeadInfo.room_clean_plan_id}, map_type = ${mapHeadInfo.map_type}, size_x:${mapHeadInfo.size_x}, size_y:${mapHeadInfo.size_y}, min_x:${mapHeadInfo.min_x}, min_y:${mapHeadInfo.min_y}, max_x:${mapHeadInfo.max_x}, max_y:${mapHeadInfo.max_y}, resolution:${mapHeadInfo.resolution}`);
}

  // 获取前4个字节，返回Int32值
  function getDataSome(length) {
    let data = values.slice(offset, offset + length);
    return data;
}
//处理历史清扫记录的map数据
export const mapDecode_listMapHis = (values) => {
    // 这里使用地图工具中的JS文件，后续再改

  
    if (values.length == 0 || values == undefined || values == null) {
        console.log('解压失败');
        return null;
    }
    // 解析工具使用库解析，已验证
    if (!robotMapManger){
        setupProto();
    }
    // console.log('解析新数据格式:', robotMapManger);
    const robotMap = robotMapManger.decode(values);
    if (robotMap == undefined || robotMap == null) {
        console.log('解析新数据解析失败');
        return null;
    }
    logRobotMap(robotMap);
    return robotMap;
}

const logRobotMap = (robotMap) => {
    
    // // WLLog.log(`是当前图?`)
    // const mapType = allData.mapType;
    // // WLLog.log(`MAPDATA1-->mapType:`, mapType);
    // // 上一次的地图有效值
    // let o_mapValid = mapExtInfo == null ? 2 : mapExtInfo.mapValid;
    // mapValid = mapExtInfo != null ? mapExtInfo.mapValid : 2;
    // newMapExtInfo = allData.mapExtInfo;

    // // 是否清扫路径状态 cleanPath 
    // // 兼容没有这个属性的版本
    // if (newMapExtInfo && newMapExtInfo.cleanPath != undefined && newMapExtInfo.cleanPath != null &&
    //   mapExtInfo && mapExtInfo.cleanPath != undefined && mapExtInfo.cleanPath != null &&
    //   mapExtInfo.cleanPath == 0 && newMapExtInfo.cleanPath == 1) {
    //   WLLog.leftLog('200ms后触发5分钟后清除路径');
    //   // 抛出事件
    //   setTimeout(() => {
    //     DeviceEventEmitter.emit('ZNNOTIFY', ['S10E7_cleanPath', 2]);
    //   }, 800);
    // }
    // // 赋值给上次  防止probuf对象不能赋值新属性
    // lastMapExtInfo = JSON.parse(JSON.stringify(mapExtInfo));
    // mapExtInfo = JSON.parse(JSON.stringify(newMapExtInfo));

    // // WLLog.log(`全图Ext数据1-->task:${ mapExtInfo.taskBeginDate } ${ new Date(mapExtInfo.taskBeginDate * 1000).Format("yyyy-MM-dd hh:mm:ss") } upload:${ mapExtInfo.mapUploadDate } ${ new Date(mapExtInfo.mapUploadDate * 1000).Format("yyyy-MM-dd hh:mm:ss") }`);
    // // WLLog.log(`全图Ext数据 mapValid:${ o_mapValid } -> ${ mapExtInfo.mapValid }`);
    // WLLog.log(`全图Ext数据 mapValid:${ mapExtInfo.boudaryInfo && mapExtInfo.boudaryInfo.vMinX },${ mapExtInfo.boudaryInfo && mapExtInfo.boudaryInfo.vMaxX },${ mapExtInfo.boudaryInfo && mapExtInfo.boudaryInfo.vMinY },${ mapExtInfo.boudaryInfo && mapExtInfo.boudaryInfo.vMaxY }`);

    // checkMapReactChange(allData.mapHead);

    // if (mapInfo && allData.mapHead) {
    //   // 比较当前地图mapId与上一张地图mapId不一致，则切换到普通清扫模式 0218
    //   if (mapInfo.mapHeadId != allData.mapHead.mapHeadId) {
    //     DeviceEventEmitter.emit('CHANGE_HOME_MAP');
    //   }
    // }

    // mapInfo = allData.mapHead;
    // // WLLog.log('全图数据2-->mapHeadId:', mapInfo);

    // allMapInfo = allData.mapInfo;
    // // WLLog.log('全图数据22-->allMapInfo:', allMapInfo);

    // // 清扫轨迹
    // cleanPaths = allData.historyPose && allData.historyPose.points;
    // if (cleanPaths != null) {
    //   cleanPaths = JSON.parse(JSON.stringify(cleanPaths));
    // }
    // // WLLog.log('全图数据32-->cleanPaths:', !cleanPaths ? 'null' : cleanPaths.length);
    // // WLLog.log('全图中的轨迹个数为:', cleanPaths.length, cleanPaths);

    // chargePosition = allData.chargeStation;

    // robotPosition = allData.currentPose;
    // // WLLog.log('全图数据5-->机器人位置:', robotPosition);


    // // 2 无效  1 有效
    // if (o_mapValid == 2 && mapExtInfo.mapValid == 1) {
    //   WLLog.log(`全图Ext数据 地图：无效->有效`);
    //   emitMapValidEvent(true);
    // } else if (mapValid == 1 && mapExtInfo.mapValid == 2) {
    //   WLLog.log(`全图Ext数据 地图：有效->无效`);
    //   emitMapValidEvent(false);
    // }
    // const curRooms = handleRoomData(allData.roomDataInfo);// allData.roomDataInfo;
    // WLLog.log('全图数据6-->rooms  :', rooms);
    // // if(curRooms.length > 0 && rooms.length == 0 && !isCache){
    // //   DeviceEventEmitter.emit('BUILD_COMPETE');
    // // }
    // rooms = curRooms;

    // // CleanPerferenceDataInfo
    // // WLLog.log('全图数据6-->rooms:', rooms.map((one) => one.roomId).join('.'));
    // // WLLog.log(`yyyyyTTT ->1 ${allData}`);
    // roomMatrix = allData.roomMatrix && allData.roomMatrix.matrix;
    // // WLLog.log('全图数据7-->roomMatrix:', roomMatrix);

    // roomChains = allData.roomChain;
    // // WLLog.log('全图数据8-->roomChains:', roomChains.length);
    let logChains = {};
    if(robotMap.roomChains){
        for (let chain of robotMap.roomChains) {
            logChains[chain.roomId] = chain.points.length;
          }
    }
    
    // WLLog.log('全图数据888-->roomChain:', logChains);

    // virtualWalls = handleVirtualData(allData.virtualWalls);// allData.virtualWalls;
    // WLLog.log('虚拟墙坐标数组 = ', WLConfig.toJSON(virtualWalls));
		
	// 	// // ----- 这里是测试代码，用于添加假家具
	// 	// // virtualWalls = [];
    // // // console.log('全图数据9-->virtualWalls:', virtualWalls);
	// 	// let a67 = []; // 存放非地毯类型的家居
	// 	// let a68 = []; // 存放地毯
	// 	// for(let i = 0; i < virtualWalls.length; i++){
	// 	// 	let ps = virtualWalls[i];
	// 	// 	let isT = ps.type != 6;
	// 	// 	let array = [];
	// 	// 	for(let j = 0; j < ps.points.length; j++){
	// 	// 		let p = ps.points[j];
	// 	// 		array.push(p.x)
	// 	// 		array.push(p.y);
	// 	// 	}
	// 	// 	if (isT)
	// 	// 		a67.push(array);
	// 	// 	else 
	// 	// 		a68.push(array);
	// 	// }
	// 	// console.log('全图数据9-->virtualWalls:1:', a67);
	// 	// console.log('全图数据9-->virtualWalls:2:', a68);

    // if (allData && allData.navigationPoints && allData.navigationPoints.length > 0) {
    //   locationPoint = allData.navigationPoints[0];
    // } else {
    //   locationPoint = null;
    // }
    // // WLLog.log('全图数据10-->指哪点:', locationPoint);

    // if (allData.areasInfo && allData.areasInfo.length > 0) {
    //   const element = allData.areasInfo[0];
    //   cleanZone = element.points;
    // } else {
    //   cleanZone = [];
    // }
    // // WLLog.log('全图数据11-->划区:', cleanZone.length);
    // // AI物体
    // if (allData.objects) {
    //   AIObjects = JSON.parse(JSON.stringify(allData.objects));
    // } else {
    //   AIObjects = [];
    // }
    // // WLLog.log('全图数据12-->AIObjects:', AIObjects.length);
    // // AI家具
    // AIFurnitures = handleAIFurnitureData(allData.furnitureInfo);
    // // console.log(`全图数据15-->AI家具:${ AIFurnitures.length }:   data = `,AIFurnitures);

    const backupAreas = robotMap.backupAreas == null ? [] : robotMap.backupAreas;
    // WLLog.log('全图数据17-->backupAreas:', backupAreas.length, backupAreas);
    // 10宠物补扫矩形区域  11垃圾重点清扫区域
    const petBackupAreas = backupAreas.filter((area) => {
      return area.type == 10;
    });
    const rubbishBackupAreas = backupAreas.filter((area) => {
      return area.type == 11;
    });

    // // TODO: 测试
    // // petBackupAreas = virtualWalls;
    // // rubbishBackupAreas = virtualWalls;
    // // virtualWalls = [];
    // // WLLog.log('全图数据13-->petBackupAreas:', petBackupAreas.length, petBackupAreas);
    // // WLLog.log('全图数据14-->rubishBackupAreas:', rubbishBackupAreas.length, rubbishBackupAreas);

    // // 全图byte数组
    // mapData = allData.mapData && allData.mapData.mapData;
    // setMapIo(mapInfo, mapExtInfo);

    // WLLog.log(`全图数据11 ------>${mapData.length} ${mapInfo.sizeX}`);
    // const nArray = perfectMapData(mapData, mapInfo);
    // mapData = nArray[0];
    // mapInfo = nArray[1];
    // WLLog.log(`-=5551------>${mapData.length} ${mapInfo.sizeX}`);

    // WLLog.leftLog(`全图Ext数据1-->ExtInfo:${ JSON.stringify(mapExtInfo) }`);
    // WLLog.log(`MAPDATA mapValid:${ o_mapValid } -> ${ mapExtInfo.mapValid }`);
    // WLLog.log('MAPDATA2-->mapHeadId:', mapInfo);
    // WLLog.log('MAPDATA22-->allMapInfo:', allMapInfo);
    // WLLog.log('MAPDATA32-->cleanPaths:', !cleanPaths ? 'null' : cleanPaths.length);
    // WLLog.log('MAPDATA4-->充电座位置:', chargePosition);
    // WLLog.log('MAPDATA5-->机器人位置:', robotPosition);
    // WLLog.log('MAPDATA6-->rooms  :', rooms.length);
    // WLLog.log('MAPDATA7-->roomMatrix:', roomMatrix);
    // WLLog.log('MAPDATA8-->roomChains:', roomChains.length);

    // WLLog.log('MAPDATA888-->roomChain:', logChains);
    // WLLog.log('MAPDATA9-->virtualWalls:', virtualWalls.length);
    // WLLog.log('MAPDATA10-->指哪点:', locationPoint);
    // WLLog.log('MAPDATA11-->划区:', cleanZone.length);
    // WLLog.log('MAPDATA12-->AIObjects:', AIObjects.length);
    // WLLog.log(`MAPDATA15-->AIFurnitures:${ AIFurnitures.length }:`);
    // WLLog.log('MAPDATA13-->petBackupAreas:', petBackupAreas.length);
    // WLLog.log('MAPDATA14-->rubishBackupAreas:', rubbishBackupAreas.length);
    console.log(`MAPDATA ALL:mapExtInfo:${ JSON.stringify(robotMap.mapExtInfo) } \n mapType:${robotMap.mapType} ExtInfo:${ JSON.stringify(robotMap.mapExtInfo) } \n 路径:${ !robotMap.historyPose.points.length} \n 充电座位置:${ JSON.stringify(robotMap.chargeStation) } \n 机器人位置:${ JSON.stringify(robotMap.currentPose) } \n 房间:${ JSON.stringify(robotMap.roomDataInfo)}  \n 链条:${ JSON.stringify(logChains) } \n 指哪点:${ JSON.stringify(robotMap.navigationPoints) }  \n 虚拟墙个数:${ JSON.stringify(robotMap.virtualWalls) }  \n 划区坐标:${ JSON.stringify(robotMap.areasInfo) } \n 物体:${ JSON.stringify(robotMap.objects) } \n 家居:${ JSON.stringify(robotMap.furnitureInfo) } \n 宠物:${ JSON.stringify(petBackupAreas) } \n 脏污:${ JSON.stringify(rubbishBackupAreas) }`);
}

const setupProto = ()=> {
    // 默认是S1, 30V是7090
    let json = `{\"nested\":{\"SCMap\":{\"options\":{\"optimize_for\":\"LITE_RUNTIME\"},\"nested\":{\"MapHeadInfo\":{\"fields\":{\"mapHeadId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"sizeX\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"sizeY\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3},\"minX\":{\"rule\":\"required\",\"type\":\"float\",\"id\":4},\"minY\":{\"rule\":\"required\",\"type\":\"float\",\"id\":5},\"maxX\":{\"rule\":\"required\",\"type\":\"float\",\"id\":6},\"maxY\":{\"rule\":\"required\",\"type\":\"float\",\"id\":7},\"resolution\":{\"rule\":\"required\",\"type\":\"float\",\"id\":8}}},\"MapDataInfo\":{\"fields\":{\"mapData\":{\"rule\":\"required\",\"type\":\"bytes\",\"id\":1}}},\"AllMapInfo\":{\"fields\":{\"mapHeadId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"mapName\":{\"rule\":\"required\",\"type\":\"string\",\"id\":2}}},\"DeviceCoverPointDataInfo\":{\"fields\":{\"update\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":2},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":3}}},\"DeviceHistoryPoseInfo\":{\"fields\":{\"poseId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"points\":{\"rule\":\"repeated\",\"type\":\"DeviceCoverPointDataInfo\",\"id\":2}}},\"DevicePoseDataInfo\":{\"fields\":{\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":1},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":2},\"phi\":{\"rule\":\"required\",\"type\":\"float\",\"id\":3},\"roomId\":{\"type\":\"uint32\",\"id\":4}}},\"DeviceCurrentPoseInfo\":{\"fields\":{\"poseId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"update\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":3},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":4},\"phi\":{\"rule\":\"required\",\"type\":\"float\",\"id\":5}}},\"DevicePointInfo\":{\"fields\":{\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":1},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":2}}},\"DeviceAreaDataInfo\":{\"fields\":{\"status\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"type\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"areaIndex\":{\"type\":\"uint32\",\"id\":3},\"points\":{\"rule\":\"repeated\",\"type\":\"DevicePointInfo\",\"id\":4}}},\"DeviceNavigationPointDataInfo\":{\"fields\":{\"pointId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"status\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"pointType\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3},\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":4},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":5},\"phi\":{\"type\":\"float\",\"id\":6}}},\"CleanPerferenceDataInfo\":{\"fields\":{\"cleanMode\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"waterLevel\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"windPower\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3},\"twiceClean\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":4}}},\"RoomDataInfo\":{\"fields\":{\"roomId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"roomName\":{\"rule\":\"required\",\"type\":\"string\",\"id\":2},\"roomTypeId\":{\"type\":\"uint32\",\"id\":3},\"meterialId\":{\"type\":\"uint32\",\"id\":4},\"cleanState\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":5},\"roomClean\":{\"type\":\"uint32\",\"id\":6},\"roomCleanIndex\":{\"type\":\"uint32\",\"id\":7},\"roomNamePost\":{\"rule\":\"required\",\"type\":\"DevicePointInfo\",\"id\":8},\"cleanPerfer\":{\"type\":\"CleanPerferenceDataInfo\",\"id\":9},\"colorId\":{\"type\":\"uint32\",\"id\":10}}},\"DeviceRoomMatrix\":{\"fields\":{\"matrix\":{\"rule\":\"required\",\"type\":\"bytes\",\"id\":1}}},\"DeviceChainPointDataInfo\":{\"fields\":{\"x\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"y\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"value\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3}}},\"DeviceRoomChainDataInfo\":{\"fields\":{\"roomId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"points\":{\"rule\":\"repeated\",\"type\":\"DeviceChainPointDataInfo\",\"id\":2}}},\"ObjectDataInfo\":{\"fields\":{\"objectId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"objectTypeId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"objectName\":{\"rule\":\"required\",\"type\":\"string\",\"id\":3},\"confirm\":{\"type\":\"uint32\",\"id\":4},\"x\":{\"rule\":\"required\",\"type\":\"float\",\"id\":5},\"y\":{\"rule\":\"required\",\"type\":\"float\",\"id\":6},\"url\":{\"type\":\"string\",\"id\":7},\"notShow\":{\"type\":\"uint32\",\"id\":8}}},\"FurnitureDataInfo\":{\"fields\":{\"id\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"typeId\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"points\":{\"rule\":\"repeated\",\"type\":\"DevicePointInfo\",\"id\":3},\"url\":{\"type\":\"string\",\"id\":4},\"status\":{\"type\":\"uint32\",\"id\":5},\"react\":{\"rule\":\"repeated\",\"type\":\"DevicePointInfo\",\"id\":6}}},\"MapExtInfo\":{\"fields\":{\"taskBeginDate\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"mapUploadDate\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"mapValid\":{\"type\":\"uint32\",\"id\":3},\"radian\":{\"type\":\"uint32\",\"id\":4},\"force\":{\"type\":\"uint32\",\"id\":5},\"cleanPath\":{\"type\":\"uint32\",\"id\":6},\"boudaryInfo\":{\"type\":\"MapBoundaryInfo\",\"id\":7},\"mapVersion\":{\"type\":\"uint32\",\"id\":8},\"mapValueType\":{\"type\":\"uint32\",\"id\":9},\"carpetOffsetInfo\":{\"type\":\"CarpetOffsetInfo\",\"id\":10}}},\"CarpetOffsetInfo\":{\"fields\":{\"phi\":{\"rule\":\"required\",\"type\":\"float\",\"id\":1},\"dist\":{\"rule\":\"required\",\"type\":\"float\",\"id\":2}}},\"MapBoundaryInfo\":{\"fields\":{\"mapMd5\":{\"rule\":\"required\",\"type\":\"string\",\"id\":1},\"vMinX\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":2},\"vMaxX\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3},\"vMinY\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":4},\"vMaxY\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":5}}},\"HouseInfo\":{\"fields\":{\"id\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"name\":{\"rule\":\"required\",\"type\":\"string\",\"id\":2},\"curMapCount\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":3},\"maxMapSize\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":4},\"maps\":{\"rule\":\"repeated\",\"type\":\"AllMapInfo\",\"id\":5}}},\"RobotMap\":{\"fields\":{\"mapType\":{\"rule\":\"required\",\"type\":\"uint32\",\"id\":1},\"mapExtInfo\":{\"rule\":\"required\",\"type\":\"MapExtInfo\",\"id\":2},\"mapHead\":{\"type\":\"MapHeadInfo\",\"id\":3},\"mapData\":{\"type\":\"MapDataInfo\",\"id\":4},\"mapInfo\":{\"rule\":\"repeated\",\"type\":\"AllMapInfo\",\"id\":5},\"historyPose\":{\"type\":\"DeviceHistoryPoseInfo\",\"id\":6},\"chargeStation\":{\"type\":\"DevicePoseDataInfo\",\"id\":7},\"currentPose\":{\"type\":\"DeviceCurrentPoseInfo\",\"id\":8},\"virtualWalls\":{\"rule\":\"repeated\",\"type\":\"DeviceAreaDataInfo\",\"id\":9},\"areasInfo\":{\"rule\":\"repeated\",\"type\":\"DeviceAreaDataInfo\",\"id\":10},\"navigationPoints\":{\"rule\":\"repeated\",\"type\":\"DeviceNavigationPointDataInfo\",\"id\":11},\"roomDataInfo\":{\"rule\":\"repeated\",\"type\":\"RoomDataInfo\",\"id\":12},\"roomMatrix\":{\"type\":\"DeviceRoomMatrix\",\"id\":13},\"roomChain\":{\"rule\":\"repeated\",\"type\":\"DeviceRoomChainDataInfo\",\"id\":14},\"objects\":{\"rule\":\"repeated\",\"type\":\"ObjectDataInfo\",\"id\":15},\"furnitureInfo\":{\"rule\":\"repeated\",\"type\":\"FurnitureDataInfo\",\"id\":16},\"houseInfos\":{\"rule\":\"repeated\",\"type\":\"HouseInfo\",\"id\":17},\"backupAreas\":{\"rule\":\"repeated\",\"type\":\"DeviceAreaDataInfo\",\"id\":18}}}}}}}`;
    if (is30V) {
        json = `{"nested":{"SCMap":{"options":{"optimize_for":"LITE_RUNTIME"},"nested":{"MapHeadInfo":{"fields":{"mapHeadId":{"rule":"required","type":"uint32","id":1},"sizeX":{"rule":"required","type":"uint32","id":2},"sizeY":{"rule":"required","type":"uint32","id":3},"minX":{"rule":"required","type":"float","id":4},"minY":{"rule":"required","type":"float","id":5},"maxX":{"rule":"required","type":"float","id":6},"maxY":{"rule":"required","type":"float","id":7},"resolution":{"rule":"required","type":"float","id":8}}},"MapDataInfo":{"fields":{"mapData":{"rule":"required","type":"bytes","id":1}}},"AllMapInfo":{"fields":{"mapHeadId":{"rule":"required","type":"uint32","id":1},"mapName":{"rule":"required","type":"string","id":2}}},"DeviceCoverPointDataInfo":{"fields":{"update":{"rule":"required","type":"uint32","id":1},"x":{"rule":"required","type":"float","id":2},"y":{"rule":"required","type":"float","id":3}}},"DeviceHistoryPoseInfo":{"fields":{"poseId":{"rule":"required","type":"uint32","id":1},"points":{"rule":"repeated","type":"DeviceCoverPointDataInfo","id":2}}},"DevicePoseDataInfo":{"fields":{"x":{"rule":"required","type":"float","id":1},"y":{"rule":"required","type":"float","id":2},"phi":{"rule":"required","type":"float","id":3}}},"DeviceCurrentPoseInfo":{"fields":{"poseId":{"rule":"required","type":"uint32","id":1},"update":{"rule":"required","type":"uint32","id":2},"x":{"rule":"required","type":"float","id":3},"y":{"rule":"required","type":"float","id":4},"phi":{"rule":"required","type":"float","id":5}}},"DevicePointInfo":{"fields":{"x":{"rule":"required","type":"float","id":1},"y":{"rule":"required","type":"float","id":2}}},"DeviceAreaDataInfo":{"fields":{"status":{"rule":"required","type":"uint32","id":1},"type":{"rule":"required","type":"uint32","id":2},"areaIndex":{"type":"uint32","id":3},"points":{"rule":"repeated","type":"DevicePointInfo","id":4},"name":{"type":"string","id":5},"areaType":{"type":"uint32","id":6}}},"DeviceNavigationPointDataInfo":{"fields":{"pointId":{"rule":"required","type":"uint32","id":1},"status":{"rule":"required","type":"uint32","id":2},"pointType":{"rule":"required","type":"uint32","id":3},"x":{"rule":"required","type":"float","id":4},"y":{"rule":"required","type":"float","id":5},"phi":{"type":"float","id":6}}},"CleanPerferenceDataInfo":{"fields":{"cleanMode":{"rule":"required","type":"uint32","id":1},"waterLevel":{"rule":"required","type":"uint32","id":2},"windPower":{"rule":"required","type":"uint32","id":3},"twiceClean":{"rule":"required","type":"uint32","id":4},"carpet":{"type":"uint32","id":5}}},"RoomDataInfo":{"fields":{"roomId":{"rule":"required","type":"uint32","id":1},"roomName":{"rule":"required","type":"string","id":2},"roomTypeId":{"type":"uint32","id":3},"meterialId":{"type":"uint32","id":4},"cleanState":{"rule":"required","type":"uint32","id":5},"roomClean":{"type":"uint32","id":6},"roomCleanIndex":{"type":"uint32","id":7},"roomNamePost":{"rule":"required","type":"DevicePointInfo","id":8},"cleanPerfer":{"type":"CleanPerferenceDataInfo","id":9}}},"DeviceRoomMatrix":{"fields":{"matrix":{"rule":"required","type":"bytes","id":1}}},"DeviceChainPointDataInfo":{"fields":{"x":{"rule":"required","type":"uint32","id":1},"y":{"rule":"required","type":"uint32","id":2},"value":{"rule":"required","type":"uint32","id":3}}},"DeviceRoomChainDataInfo":{"fields":{"roomId":{"rule":"required","type":"uint32","id":1},"points":{"rule":"repeated","type":"DeviceChainPointDataInfo","id":2}}},"ObjectDataInfo":{"fields":{"objectId":{"rule":"required","type":"uint32","id":1},"objectTypeId":{"rule":"required","type":"uint32","id":2},"objectName":{"rule":"required","type":"string","id":3},"confirm":{"type":"uint32","id":4},"x":{"rule":"required","type":"float","id":5},"y":{"rule":"required","type":"float","id":6},"url":{"type":"string","id":7},"property":{"type":"uint32","id":8}}},"FurnitureDataInfo":{"fields":{"id":{"rule":"required","type":"uint32","id":1},"typeId":{"rule":"required","type":"uint32","id":2},"points":{"rule":"repeated","type":"DevicePointInfo","id":3},"url":{"type":"string","id":4}}},"MapExtInfo":{"fields":{"taskBeginDate":{"rule":"required","type":"uint32","id":1},"mapUploadDate":{"rule":"required","type":"uint32","id":2},"mapValid":{"type":"uint32","id":3},"angle":{"type":"float","id":4}}},"HouseInfo":{"fields":{"id":{"rule":"required","type":"uint32","id":1},"name":{"rule":"required","type":"string","id":2},"curMapCount":{"rule":"required","type":"uint32","id":3},"maxMapSize":{"rule":"required","type":"uint32","id":4},"maps":{"rule":"repeated","type":"AllMapInfo","id":5}}},"RobotMap":{"fields":{"mapType":{"rule":"required","type":"uint32","id":1},"mapExtInfo":{"rule":"required","type":"MapExtInfo","id":2},"mapHead":{"type":"MapHeadInfo","id":3},"mapData":{"type":"MapDataInfo","id":4},"mapInfo":{"rule":"repeated","type":"AllMapInfo","id":5},"historyPose":{"type":"DeviceHistoryPoseInfo","id":6},"chargeStation":{"type":"DevicePoseDataInfo","id":7},"currentPose":{"type":"DeviceCurrentPoseInfo","id":8},"virtualWalls":{"rule":"repeated","type":"DeviceAreaDataInfo","id":9},"areasInfo":{"rule":"repeated","type":"DeviceAreaDataInfo","id":10},"navigationPoints":{"rule":"repeated","type":"DeviceNavigationPointDataInfo","id":11},"roomDataInfo":{"rule":"repeated","type":"RoomDataInfo","id":12},"roomMatrix":{"type":"DeviceRoomMatrix","id":13},"roomChain":{"rule":"repeated","type":"DeviceRoomChainDataInfo","id":14},"objects":{"rule":"repeated","type":"ObjectDataInfo","id":15},"furnitureInfo":{"rule":"repeated","type":"FurnitureDataInfo","id":16},"houseInfos":{"rule":"repeated","type":"HouseInfo","id":17}}}}}}}`;
    }

    let root = protobuf.Root.fromJSON(JSON.parse(json));
    robotMapManger = root.lookupType("SCMap.RobotMap");
}




