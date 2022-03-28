/*
 * @Descripttion: 
 * @version: 
 * @Author: SC
 * @Date: 2022-03-09 15:28:33
 * @LastEditors: SC
 * @LastEditTime: 2022-03-28 14:28:24
 */
/**
 * @format
 */

// import {AppRegistry} from 'react-native';
// import App from './App';
// import {name as appName} from './app.json';

// AppRegistry.registerComponent(appName, () => App);


import React from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    Dimensions,
    NativeModules,
    TouchableOpacity,
    Image
} from 'react-native';

import { mapDecode, parseTxtData } from './MapDecodeUtil';
import { convert, oldConvert, getMapBase64 } from './MapManager';

const { width, height } = Dimensions.get('window')

var Modules = NativeModules.Module

class RNView extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            mapBase64: '',
            isShowImage: false
        };
    }

    render() {
        let {
            mapBase64,
            isShowImage
        } = this.state;

        return (
            // <View style={styles.center}>
            //     <Text >
            //         {this.props.content}
            //     </Text>
            // </View>

            <View style={styles.tempView}>
                <TouchableOpacity
                    style={styles.touchView}
                    onPress={() => {
                        // Modules.navigateBack();
                        const start = new Date().getTime();
                        console.log(`开始操作 = ${ new Date().getTime() / 1000 } ${ new Date().toLocaleString('zh', { hour12: true }) }`);
                        let json = require('./test.json');
                        let robotMap = mapDecode(json.data);
                        const jieya = new Date().getTime();
                        console.log(`解压完成 = ${ new Date().getTime() / 1000 } ${ new Date().toLocaleString('zh', { hour12: true }) } 耗时 = ${jieya - start}`);
                        // console.log('robotMap = ',robotMap);
                        if (robotMap) {
                            oldConvert(robotMap);
                            const base64 = getMapBase64();
                            const map = new Date().getTime();
                            console.log(`生成图完成 = ${ new Date().getTime() / 1000 } ${ new Date().toLocaleString('zh', { hour12: true }) } 耗时 = ${map - jieya}`);
                            // console.log('base64 = ',base64);
                            if (base64 && base64.length > 0) {
                                this.setState({
                                    mapBase64: base64,
                                    isShowImage: true
                                });
                            }
                        }
                    }}>
                    <Text style={styles.textStyle}>加载地图</Text>
                </TouchableOpacity>

                <Image source={{uri:mapBase64}} style={styles.imageStyle}/>
            </View>

        );
    }
}

const styles = StyleSheet.create({
    tempView: {
        flex: 1,
        flexDirection: 'column'
    },
    center: {
        marginTop: 150,
        marginLeft: (width - 120) / 2,
        width: 120,
        height: 60,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: "red"
    },
    touchView: {
        marginTop: 100,
        marginLeft: 100,
        width: 200,
        height: 100,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'green'
    },
    textStyle: {
        fontSize: 20,
        color: 'pink'
    },
    imageStyle: {
        flex: 1
    }
});

// 整体js模块的名称
AppRegistry.registerComponent('RNView', () => RNView);


