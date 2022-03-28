import { SCCMapColor,SMapColorConfig,SMapValueType } from './MapConfig';
import { Buffer } from 'buffer';
import base64 from 'react-native-base64';
let robotMap = null; // 总的解析模型
let map_base64 = ''; // 地图的base64字符串

let doors = []; // 门列表  { doorid: 0, points:[{x:1,y:1}]}
let showChainIndex = 0; // 显示链条的索引
let showPathNotCover = true; // 显示路径非覆盖
let roomsCountIsS1 = 1;  // 默认房间个数+颜色使用S1的，否则使用1S的
let miVersion = 10000;
let miDate = '200615'
let author = 'ding';
const uConfig = { enRenderRunloop: 0, highShow: 0 };
let renderer, scene, camera, controls, earthGeometry, mapGeometry, spotLight, p1, threeElement, robotMesh, chargeMesh;
let isThree = 1; let allRotateX = 0; let allRotateY = 0; let allRotateZ = 0; let rotateInterval; let cameraR = 150; let cameraIsPerspective = true; let threeDeubugInt = 0; const lightNames = ['aLight', 'mLight', 'mLightHelper', 'fLight', 'fLightHelper'];
let defaultMeshs = {}; // 加载完成后的家具模型，用于拷贝
const furnitureMeshReal = 1 / 100.0;
const furnitureScale = furnitureMeshReal * 20.0;  // UI同事的模型是按照cm，1m=20个格子
let imageScale = 1;
let forceShowCarpet = 0; // 强制显示地毯
let showDotted = false;


let isProto = false;
let is30V = false;
let isEncrypt = false;
let key = null;

let robotMapManger = null; // 总的解析模型

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

// 处理地图的数据缓存，拼接地图图片
export const convert = (data) => {
   robotMap = data;
   convertMapImage(robotMap.mapData.mapData);
}

// 处理旧地图的数据缓存，拼接地图图片
export const oldConvert = (data) => {
    robotMap = data;
    parseBase64Map(robotMap.mapData.mapData);
 }
 

// 处理地图的数据缓存，拼接地图图片
export const convert_recordHistory = (data) => {
    robotMap = data;
    convertMapImage(robotMap);
 }
 
export const getMapBase64 = () => {
    return map_base64;
}


// 转换地图数据
const convertMapImage = (mapData) => {
    // return;
    // "Cannot read properties of undefined (reading 'sizeX')"
    var rgbaArrayT = new Array(mapData.length * 4);

    let test = true;
    let colorDic = {};
    // let newMapData = new Array();
    
    const roomColors = SMapColorConfig.roomColors1S;
    const colorIdDic = getRoomColorMap(roomColors.length);  // 所有房间的colorId集合
    const isSupportCarpet = robotMap && robotMap.mapExtInfo.mapValueType == 1
    try {
        for (var i = 0; i < mapData.length; i++) {
            let x = i % robotMap.mapHead.sizeX;
            let y = Math.floor(i / robotMap.mapHead.sizeX);
            
            let valueT = mapData[i];
            let tTalue = valueT > 127 ? (valueT - 256) : valueT; // uint8->int8
            const ob = getMapValue(tTalue);
            let value = ob.value;
            if (value != SCCMapColor.background) {
                // updateValidInfo(y, x);
            }
            if (value == SCCMapColor.patch) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.roomColor);
            } else if (value == SCCMapColor.patch_carpet || value == SCCMapColor.carpet) { // 毛毯
                if(isSupportCarpet){
                    if (checkShowCarpet(x, y)){
                        _setRGBA(rgbaArrayT, i, SMapColorConfig.carpetColor); // 毛毯产生斑点
                    } else {
                        _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor);
                    }
                } else if (value == SCCMapColor.patch_carpet) {
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.roomColor); // 毛毯产生斑点
                } else if (value == SCCMapColor.carpet) {
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor); // 毛毯产生斑点
                }
            } 
            else if (value == SCCMapColor.wall || value == SCCMapColor.obstacle) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.wallColor);
            } else if (value == SCCMapColor.background) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.bgColor);
            } else if (value == SCCMapColor.discover) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor);
            } else if (value == SCCMapColor.cover) {
                // let color = showPathNotCover ? SMapColorConfig.discoverColor : SMapColorConfig.coverColor;
                _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor);
            } else if (value >= SCCMapColor.roomBegin && value <= SCCMapColor.roomEnd) {
                if ((ob.type == SMapValueType.negative) 
                && checkShowCarpet(x, y)){
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.carpetColor); // 毛毯产生斑点
                    continue;
                }
                let roomId = value;
                let colorIdx = (roomId - 10) % roomColors.length;
                if(colorIdDic[value + '']){
                    colorIdx = Number(colorIdDic[value + '']) - 1;  
                }
                let color = roomColors[colorIdx];
                _setRGBA(rgbaArrayT, i, color);
            } else {
                
            }
            colorDic[tTalue + ''] = tTalue;
        }

        // console.log("rgbaArrayT0==" + rgbaArrayT.length)
        // console.log("rgbaArrayT1==" + mapHeadInfo.size_x)
        // console.log("rgbaArrayT2==" + mapHeadInfo.size_y)

        // // 计算距离中间的便宜
        // validInfo.offsetX = (validInfo.vMaxX + validInfo.vMinX - mapHeadInfo.size_x) / 2;
        // validInfo.offsetY = -(validInfo.vMaxY + validInfo.vMinY - mapHeadInfo.size_y) / 2;

        // console.log('计算所得的地图边界：', validInfo);
    } catch (error) {
        console.log(`error:${JSON.stringify(error)}`);
    }

    console.log(`--色值:`, Object.keys(colorDic));
    // console.log(`地图数据:`, newMapData.join(','));

    const rgbaArray = new Uint8Array(rgbaArrayT);
    var base64 = Uint8ToBase64(robotMap.mapHead.sizeX, robotMap.mapHead.sizeY, rgbaArray);
    console.log('imageBase64.length:', base64.length);
    map_base64 = base64;
}

//旧的地图数据转换
const parseBase64Map = (mapData) => {
    // return;
    var rgbaArrayT = new Array(mapData.length * 4);

    let test = true;
    let colorDic = {};
    // let newMapData = new Array();
    const roomColors = roomsCountIsS1 ? SMapColorConfig.roomColorsS1 : SMapColorConfig.roomColors1S;
    const colorIdDic = getRoomColorMap(roomColors.length);  // 所有房间的colorId集合
    const isSupportCarpet = (robotMap && robotMap.mapExtInfo.mapValueType == 1) || forceShowCarpet; // 协议是否支持毛毯
    try {
        for (var i = 0; i < mapData.length; i++) {
            let x = i % mapHeadInfo.size_x;
            let y = Math.floor(i / mapHeadInfo.size_x);
            if (showDotted && x % 4 == 0 && y % 4 == 0) { // 4个格子 = 20cm 
                _setRGBA(rgbaArrayT, i, [0, 255, 0, 255]);
                continue;
            }

            let valueT = mapData[i];
            let tTalue = valueT > 127 ? (valueT - 256) : valueT; // uint8->int8
            const ob = getMapValue(tTalue);
            let value = ob.value;
            if (value != SCCMapColor.background) {
                updateValidInfo(y, x);
            }
            if (value == SCCMapColor.patch) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.roomColor);
            } else if (value == SCCMapColor.patch_carpet || value == SCCMapColor.carpet) { // 毛毯
                if (isSupportCarpet) {
                    if (x % 2 == 0 && y % 2 == 0) {
                        _setRGBA(rgbaArrayT, i, SMapColorConfig.carpetColor); // 毛毯产生斑点
                    } else {
                        _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor);
                    }
                } else if (value == SCCMapColor.patch_carpet) {
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.roomColor); // 毛毯产生斑点
                } else if (value == SCCMapColor.carpet) {
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor); // 毛毯产生斑点
                }
            }
            else if (value == SCCMapColor.wall || value == SCCMapColor.obstacle) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.wallColor);
            } else if (value == SCCMapColor.background) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.bgColor);
            } else if (value == SCCMapColor.discover) {
                _setRGBA(rgbaArrayT, i, SMapColorConfig.discoverColor);
            } else if (value == SCCMapColor.cover) {
                let color = showPathNotCover ? SMapColorConfig.discoverColor : SMapColorConfig.coverColor;
                _setRGBA(rgbaArrayT, i, color);
            } else if (value >= SCCMapColor.roomBegin && value <= SCCMapColor.roomEnd) {
                if (isSupportCarpet
                    && (ob.type == SMapValueType.negative)
                    && checkShowCarpet(x, y)) {
                    _setRGBA(rgbaArrayT, i, SMapColorConfig.carpetColor); // 毛毯产生斑点
                    continue;
                }
                let roomId = value;
                let colorIdx = (roomId - 10) % roomColors.length;
                if (colorIdDic[value + '']) {
                    colorIdx = Number(colorIdDic[value + '']) - 1;
                }
                let color = roomColors[colorIdx];
                _setRGBA(rgbaArrayT, i, color);
            } else {

            }
            // console.log(`i:${i} value:${value}`);
            colorDic[tTalue + ''] = tTalue;
        }

        // console.log("rgbaArrayT0==" + rgbaArrayT.length)
        // console.log("rgbaArrayT1==" + mapHeadInfo.size_x)
        // console.log("rgbaArrayT2==" + mapHeadInfo.size_y)

        // 计算距离中间的便宜
        validInfo.offsetX = (validInfo.vMaxX + validInfo.vMinX - mapHeadInfo.size_x) / 2;
        validInfo.offsetY = -(validInfo.vMaxY + validInfo.vMinY - mapHeadInfo.size_y) / 2;

        console.log('计算所得的地图边界：', validInfo);
    } catch (error) {
        console.log(`error:${JSON.stringify(error)}`);
    }

    console.log(`--色值:`, Object.keys(colorDic));
    // console.log(`地图数据:`, newMapData.join(','));

    const rgbaArray = new Uint8Array(rgbaArrayT);
    // var base64 = Uint8ToBase64(mapHeadInfo.size_x, mapHeadInfo.size_y, rgbaArray);
    var base64 = Uint8ToBase64(robotMap.mapHead.sizeX, robotMap.mapHead.sizeY, rgbaArray);

    //isGyroDevice = false;
  
    console.log('imageBase64.length:', base64.length);
    map_base64 = base64;
}

 
// 获取当前地图的房间id:颜色id的键值对集合
const getRoomColorMap = (roomColorCount) => {
    let colorIdDic = {};  // 所有房间的colorId集合
    if (robotMap && robotMap.roomDataInfo && robotMap.roomDataInfo.length > 0){      
        for(let i = 0; i < robotMap.roomDataInfo.length; i++){
            let colorId = robotMap.roomDataInfo[i].colorId;
            if (colorId){
                if (colorId > 0 && colorId <= roomColorCount){
                    let roomId =  robotMap.roomDataInfo[i].roomId;
                    colorIdDic[roomId + ''] = colorId;
                } else {
                    console.log(`colorID不为空且非法，弃用这个地图的colorID，非法:`, colorId);
                    return {};
                }
            }
        }
    }
    // colorIdDic = { '10':5, '12':5, '11': 5  };  // test
    // colorIdDic = {  };
    return colorIdDic;
}

const getMapValue = (value) => {
    if (value >= SCCMapColor.coverRoomBegin && value <= SCCMapColor.coverRoomEnd) {
        return { value:value - 50, type: SMapValueType.cover };
    } 
    if (value >= SCCMapColor.deepCoverRoomBegin && value <= SCCMapColor.deepCoverRoomEnd) {
        return { value:-value - 50, type: SMapValueType.negative };
    }
    return { value:value, type: SMapValueType.simple };
}

 // 更新地图边界
 const updateValidInfo = (row, col) => {
    // validInfo.vMinX = (col < validInfo.vMinX) ? col : validInfo.vMinX;
    // validInfo.vMaxX = (col > validInfo.vMaxX) ? col : validInfo.vMaxX;
    // let tRow = this.isProto ? (robotMap.mapHead.sizeY - row) : (mapHeadInfo.size_y - row);
    // validInfo.vMinY = (tRow < validInfo.vMinY) ? tRow : validInfo.vMinY;
    // validInfo.vMaxY = (tRow > validInfo.vMaxY) ? tRow : validInfo.vMaxY;
}


const _setRGBA = (rgba, i, color, four = true) =>{
    if (color == undefined) {
        console.log(`666`);
        return;
    }
    if (rgba.length < i * 4 + 3) {
        console.log(`_setRGBA index error`);
        return;
    }
    if (four) {
        rgba[i * 4 + 0] = color[0];
        rgba[i * 4 + 1] = color[1];
        rgba[i * 4 + 2] = color[2];
        rgba[i * 4 + 3] = color[3];
    } else {
        rgba[i * 3 + 0] = color[0];
        rgba[i * 3 + 1] = color[1];
        rgba[i * 3 + 2] = color[2];
    }

}

const checkShowCarpet = (x, y) => {  // 判断是否显示毛毯。毛毯的显示逻辑
    if (x % 2 == 0 && y % 2 == 0){
        return true;
    } 
    if (x % 2 == 1 && y % 2 == 1){
        return true;
    } 
    return false;
}

const Uint8ToBase64 = (width, height, u8Arr) => {
    var aHeader = [];
    var iWidth = width;
    var iHeight = height;
    aHeader.push(0x42); // magic 1
    aHeader.push(0x4D);
    var baseHeaderSize = 54;  // total header size = 54 bytes
    var fileLength = iWidth * iHeight * 4 + baseHeaderSize;
    // bd.setUint32(2, fileLength, Endian.little); // file length 
    aHeader.push(fileLength % 256); fileLength = Math.floor(fileLength / 256); // file length
    aHeader.push(fileLength % 256); fileLength = Math.floor(fileLength / 256);
    aHeader.push(fileLength % 256); fileLength = Math.floor(fileLength / 256);
    aHeader.push(fileLength % 256);
    aHeader.push(0); // reserved
    aHeader.push(0);
    aHeader.push(0); // reserved
    aHeader.push(0);
    // console.log('aHeader:', aHeader.length, aHeader);
    // return "";
    // bd.setUint32(
    //     10, _totalHeaderSize, Endian.little); // start of the bitmap  共8字节
    aHeader.push(baseHeaderSize); // dataoffset
    aHeader.push(0);
    aHeader.push(0);
    aHeader.push(0);

    // bd.setUint32(14, 40, Endian.little); // info header size  共4个字节
    aHeader.push(40); // info header size
    aHeader.push(0);
    aHeader.push(0);
    aHeader.push(0);
    // bd.setUint32(18, _width, Endian.little); // 共4字节

    var iImageWidth = iWidth;
    aHeader.push(iImageWidth % 256); iImageWidth = Math.floor(iImageWidth / 256);
    aHeader.push(iImageWidth % 256); iImageWidth = Math.floor(iImageWidth / 256);
    aHeader.push(iImageWidth % 256); iImageWidth = Math.floor(iImageWidth / 256);
    aHeader.push(iImageWidth % 256);

    // bd.setUint32(22, _height, Endian.little); // 共4字节
    var iImageHeight = iHeight;
    aHeader.push(iImageHeight % 256); iImageHeight = Math.floor(iImageHeight / 256);
    aHeader.push(iImageHeight % 256); iImageHeight = Math.floor(iImageHeight / 256);
    aHeader.push(iImageHeight % 256); iImageHeight = Math.floor(iImageHeight / 256);
    aHeader.push(iImageHeight % 256);

    // bd.setUint16(26, 1, Endian.little); // planes  // 实际使用的调色板索引数，0：使用所有的调色板索引
    aHeader.push(1); // num of planes
    aHeader.push(0);
    // bd.setUint32(28, 32, Endian.little); // 8/16:索引 24:BGR 32:BGRA   BGRA
    aHeader.push(32); // num of bits per pixel
    aHeader.push(0);
    // bd.setUint32(30, 0, Endian.little); // compression 0:不压缩
    aHeader.push(0); // compression = none
    aHeader.push(0);
    aHeader.push(0);
    aHeader.push(0);
    // bd.setUint32(
    //     34, _width * _height * 4, Endian.little); // bitmap size  共4个
    var iDataSize = iWidth * iHeight * 3;
    aHeader.push(iDataSize % 256); iDataSize = Math.floor(iDataSize / 256);
    aHeader.push(iDataSize % 256); iDataSize = Math.floor(iDataSize / 256);
    aHeader.push(iDataSize % 256); iDataSize = Math.floor(iDataSize / 256);
    aHeader.push(iDataSize % 256);
    // 上面是38个了， 补足54
    for (var i = 0; i < 16; i++) {
        aHeader.push(0);    // these bytes not used
    }
    var strPixelData = "";
    var y = iHeight;
    do {
        var iOffsetY = iWidth * (y - 1) * 4;
        var strPixelRow = "";
        for (var x = 0; x < iWidth; x++) {
            var iOffsetX = 4 * x; // bgra
            strPixelRow += String.fromCharCode(u8Arr[iOffsetY + iOffsetX + 2]);
            strPixelRow += String.fromCharCode(u8Arr[iOffsetY + iOffsetX + 1]);
            strPixelRow += String.fromCharCode(u8Arr[iOffsetY + iOffsetX + 0]);
            strPixelRow += String.fromCharCode(u8Arr[iOffsetY + iOffsetX + 3]);
        }
        strPixelData = strPixelRow + strPixelData;  // 每次新的一行，插在前面，实现图像的上下镜像
    } while (--y);
    let headerCoded = encodeData(aHeader);
    let bodyCoded = encodeData(strPixelData);
    var strEncoded = headerCoded + bodyCoded;
    return "data:image/bmp;base64," + strEncoded;
}

const encodeData = (data) => {
    var strData = "";
    if (typeof data == "string") {
        strData = data;
        // console.log(`编码之前 = ${strData}`);
        // console.log(`编码之后 = ${new Buffer(strData, 'latin1').toString('base64')}`);
        // return new Buffer(strData, 'latin1').toString('base64');
    } else {
        var aData = data;
        for (var i = 0; i < aData.length; i++) {
            strData += String.fromCharCode(aData[i]);
        }
        //Qk02ECcAAAAAADYAAAAoAAAAIAMAACADAAABACAAAAAAAABMHQAAAAAAAAAAAAAAAAAAAAAA   6819870
        // console.log(`编码之前 = ${strData} 编码之后 = ${btoa(strData)}`);
        // console.log(`编码之后 = ${new Buffer(strData).toString('base64')}`);
        // return new Buffer(strData).toString('base64');
    }
    // return btoa(strData);
    return base64.encode(strData);

    
    
}

