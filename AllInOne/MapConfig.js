/*
 * @Descripttion: 
 * @version: 
 * @Author: SC
 * @Date: 2021-10-09 13:56:03
 * @LastEditors: SC
 * @LastEditTime: 2022-03-22 14:44:50
 */

// 色值
export const SMapColorConfig = {
   wallColor: [0, 0, 0, 0],
   bgColor: [255, 255, 255, 255],
   discoverColor: [196, 215, 249, 255],
   coverColor: [0, 215, 249, 255], // 显示路径时
   roomColor: [196, 215, 249, 255], // patch color
   // 54B4CC', '#5197C5', '#8183B7', '#6FC5B7', '#869ACC
   roomColorsS1: [
         [84, 180, 204, 255],
         [81, 151, 197, 255],
         [129, 131, 183, 255],
         [111, 197, 183, 255],
         [134, 154, 204, 255],
   ],
   //["#83B2FF", "#67CFE5", "#F5C942", "#FF9B65"];// 1S
   roomColors1S: [
         [131, 178, 255, 255],
         [103, 207, 229, 255],
         [245, 201, 66, 255],
         [255, 155, 101, 255],
   ],
   carpetColor: [127,127,127,255]
};
export const SMapValueType = { simple:0, cover:1, negative:2 }; // 地图值的类型
// 房间颜色值
export const SCCMapColor = {  obstacle: -9, patch_carpet: -4, carpet: -3, patch: -2, wall: -1, background: 0, discover: 1, cover: 2, deepCover: 3, roomBegin: 10, roomEnd: 59, coverRoomBegin: 60, coverRoomEnd: 109, deepCoverRoomBegin: -109, deepCoverRoomEnd: -60, carpetRoomBegin: -109, carpetRoomEnd: -60, };