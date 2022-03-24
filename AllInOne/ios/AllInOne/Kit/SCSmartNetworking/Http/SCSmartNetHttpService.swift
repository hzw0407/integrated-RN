//
//  SCSmartNetHttpService.swift
//  AllInOne
//
//  Created by 3i_yang on 2021/11/1.
//

import UIKit
import Alamofire
import AliyunOSSiOS
import AWSCore
import AWSS3

class SCSmartNetHttpService {
    private var requests: [String: Request] = [:]
    private (set) var baseUrl: String = ""
    private (set) var token: String = ""
    private (set) var userId: String = ""
    
    let config: SCSmartHttpServiceConfig = SCSmartHttpServiceConfig()
    
    let isIpad: Bool = SCAppInformation.phoneModel.hasPrefix("iPad")
        
    /// 通用管理器
    private let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.sharedContainerIdentifier = "com.smart.request.alamofire"
        let manager = SessionManager(configuration: configuration)
        SCSmartNetHttpAuthentication.setup(manager: manager)
        return manager
    }()
    
    /// 下载管理器
    private let downloadManager: SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.smart.download.background")
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.sharedContainerIdentifier = "com.smart.download.alamofire"
        let manager = SessionManager(configuration: configuration)
        SCSmartNetHttpAuthentication.setup(manager: manager)
        return manager
    }()
    
    /// 配置信息
    /// - Parameters:
    ///   - projectType: 工程类型
    ///   - tenantId: 租户ID
    ///   - version: APP版本
    ///   - zone: 地区
    func set(projectType: String, tenantId: String, version: String, zone: String) {
        self.config.projectType = projectType
        self.config.tenantId = tenantId
        self.config.version = version
        self.config.zone = zone
    }
    
    /// 设置基础地址
    /// - Parameter url: 基地址
    func set(baseUrl url: String) {
        self.config.baseUrl = url
    }
    
    /// 设置token和uid
    /// - Parameters:
    ///   - token: 用户token
    ///   - userId: 用户ID
    func set(authToken token: String, userId: String) {
        self.token = token
        self.userId = userId
    }
    
    func set(isReachable: Bool) {
        if isReachable {
            self.manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }
        else {
            self.manager.session.configuration.requestCachePolicy = .returnCacheDataElseLoad
        }
    }
    
    /// 通用网络请求
    /// - Parameters:
    ///   - api: 接口类型
    ///   - params: 参数
    ///   - headers: 头部信息
    ///   - callback: 回调
    public func request(api: SCSmartHttpServiceApi, params: [String: Any]?, pathParam: String? = nil, headers: SCSmartNetHttpServiceHeaders = SCSmartNetHttpDefaultHeaders, isCache: Bool = false, callback: @escaping SCSmartNetHttpServiceResponseBlock) {
        guard var url = self.getUrl(api: api, pathParam: pathParam) else { return }
        if api.isQueryParam && api.method != .get {
            if let u = self.getUrl(api: api, queryParams: params) {
                url = u
            }
        }
        var finalHeaders =  headers
        finalHeaders["tenantId"] = self.config.tenantId
        finalHeaders["Content-Type"] = api.contentType
        finalHeaders["User_Agent"] = "IOS_\(self.config.tenantId)"
        if self.isIpad {
            finalHeaders["User_Agent"] = "IOSipad_\(self.config.tenantId)"
        }
        
        let traceId = Int64(Date().timeIntervalSince1970 * 1000) + (Int64(arc4random()) % 1000)
        finalHeaders["traceId"] = String(traceId)
        
        // 有token时，头部加入token
        if self.token.count > 0 {
            finalHeaders["authorization"] = self.token
        }
        // 有uid时，头部加入uid
        if self.userId.count > 0 {
            finalHeaders["id"] = self.userId
        }
        var encoding: ParameterEncoding = JSONEncoding.default
        if api.method == .get {
            encoding = URLEncoding.default
        }
        else {
            encoding = JSONEncoding.default
        }
        
        if isCache {
            var cacheParam = params
            if cacheParam == nil {
                cacheParam = [String: Any]()
            }
            cacheParam?["pathParam"] = pathParam
            var response = SCSmartNetHttpServiceResponse()
            response.isCache = true
            response.code = 0
            response.json = SCSmartNetHttpCache.get(apiPath: api.path, uid: self.userId, traceId: String(traceId), param: cacheParam)
            SCSDKLog("res cache url: \(url),\n json:\(response.json ?? [:])")
            callback(response)
        }
        
        SCSDKLog("req url: \(url),\n headers:\(finalHeaders)\n param:\(params ?? [:])")
        let request = self.manager.request(url, method: api.method, parameters: params, encoding: encoding, headers: finalHeaders).responseJSON { [weak self] response in
            guard let `self` = self else { return }
            self.requests[api.path] = nil
            switch response.result {
            case .success(let data):
                var response = SCSmartNetHttpServiceResponse()
                if let json = data as? [String: Any], let code = json["code"] as? Int {
                    response.code = code
                    response.json = json
                    SCSDKLog("res url: \(url),\n json:\(json)")
                    
                    if code != 0 {
                        response.error = SCSmartNetworkingError(code: code)
                        response.error?.msg = json["msg"] as? String
                        if code == 609 {
                            SCSmartNetworking.sharedInstance.loginRequestWithToken { _ in
                                
                            } failure: { error in
                                
                            }
                        }
                    }
                    else {
                        var cacheParam = params
                        if cacheParam == nil {
                            cacheParam = [String: Any]()
                        }
                        cacheParam?["pathParam"] = pathParam
                        SCSmartNetHttpCache.save(apiPath: api.path, uid: self.userId, traceId: String(traceId), param: cacheParam ?? [:], content: json)
                    }
                }
                else {
                    let error = SCSmartNetworkingError(code: -1, type: .codeError)
                    response.error = error
                    SCSDKLog("res url: \(url),\n json:\(data)")
                }
                callback(response)
                break
                
            case .failure(let err):
                var response = SCSmartNetHttpServiceResponse()
                let error = SCSmartNetworkingError(code: -1, type: .netError)
                response.error = error
                SCSDKLog("res url: \(url),\n error:\(err.localizedDescription)")
                callback(response)
                break
            }
        }
        self.requests[api.path] = request
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - api: 接口类型
    ///   - params: 参数
    ///   - fileData: 文件数据
    ///   - progress: 进度回调
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func upload(api: SCSmartHttpServiceApi, params: [String: Any]?, fileName: String, headers: SCSmartNetHttpServiceHeaders = SCSmartNetHttpDefaultHeaders, callback: @escaping SCSmartNetHttpServiceResponseBlock) {
        guard let url = self.getUrl(api: api) else { return }
        var finalHeaders =  headers
        finalHeaders["tenantId"] = self.config.tenantId
        finalHeaders["Content-Type"] = api.contentType
        // 有token时，头部加入token
        if self.token.count > 0 {
            finalHeaders["authorization"] = self.token
        }
        // 有uid时，头部加入uid
        if self.userId.count > 0 {
            finalHeaders["id"] = self.userId
        }
        SCSDKLog("req url: \(url),\n headers:\(finalHeaders)\n param:\(params ?? [:])")
        
        self.manager.upload(multipartFormData: { formaData in
            for (key, value) in (params ?? [:]) {
                if let content = value as? String {
                    formaData.append(content.data(using: .utf8)!, withName: key)
                }
                if let content = value as? Data {
                    formaData.append(content, withName: key, fileName: fileName, mimeType: fileName.mimeTypeByFileName)
                }
            }
        }, to: url, method: api.method, headers: finalHeaders) { [weak self] result in
            guard let `self` = self else { return }
            self.requests[api.path] = nil
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        var response = SCSmartNetHttpServiceResponse()
                        if let json = data as? [String: Any], let code = json["code"] as? Int {
                            response.code = code
                            response.json = json
                            SCSDKLog("res url: \(url),\n json:\(json)")
                            
                            if code != 0 {
                                response.error = SCSmartNetworkingError(code: code)
                                response.error?.msg = json["msg"] as? String
                            }
                        }
                        else {
                            let error = SCSmartNetworkingError(code: -1, type: .codeError)
                            response.error = error
                            SCSDKLog("res url: \(url),\n json:\(data)")
                        }
                        callback(response)
                        break
                    case .failure(let err):
                        var response = SCSmartNetHttpServiceResponse()
                        let error = SCSmartNetworkingError(code: -1, type: .netError)
                        response.error = error
                        SCSDKLog("res url: \(url),\n error:\(err.localizedDescription)")
                        callback(response)
                        break
                    }
                    
                }
                break
            case .failure(let err):
                var response = SCSmartNetHttpServiceResponse()
                let error = SCSmartNetworkingError(code: -1, type: .netError)
                response.error = error
                SCSDKLog("res url: \(url),\n error:\(err.localizedDescription)")
                callback(response)
                break
            }
        }
        
//        self.requests[api.path] = request
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - url: 接口类型
    ///   - outFilePath: 输出地址
    ///   - params: 参数
    ///   - needBackgroundDownload: 是否需要后台下载
    ///   - progress: 进度回调
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func download(url: String, outFilePath: String? = nil, params: [String: Any]? = nil, needBackgroundDownload: Bool = false, progress: @escaping SCProgressHandler, success: @escaping SCSuccessData, failure: @escaping SCFailureError) {
        let headers = ["authorization": self.token]
        var manager = self.manager
        if needBackgroundDownload {
            manager = self.downloadManager
        }
        //指定下载路径
        var destination: DownloadRequest.DownloadFileDestination?
        if outFilePath != nil {
            destination = { _, response in
                let fileURL = URL(fileURLWithPath: outFilePath!)
                return (fileURL,[.removePreviousFile,.createIntermediateDirectories])
            }
        }
        
        SCSDKLog("req download url: \(url),\n outPath:\(outFilePath), headers:\(headers)\n param:\(params ?? [:])")
        
        let request = manager.download(url, to: destination).responseData { [weak self] downloadResponse in
            guard let `self` = self else { return }
            let data = downloadResponse.result.value
            if let data = data {
                self.requests[url] = nil
                SCSDKLog("res download success url:\(url)")
                success(data)
            }
            else {
                SCSDKLog("res download fail url: \(url),\n error")
                failure(NSError())
            }
        }
//
//        let request = manager.download(url, to: destination)
//            .response(completionHandler: { [weak self] response in
//                guard let `self` = self else { return }
//                self.requests[url] = nil
//                if let error = response.error {
//                    SCSDKLog("res url: \(url),\n error:\(error.localizedDescription)")
//                    failure(error)
//                }
//                else {
//                    SCSDKLog("res download success url:\(url)")
//                    success(response.resumeData ?? Data())
//                }
//
//            })
//            .downloadProgress { downloadProgress in
//                let value = Float(Double(downloadProgress.completedUnitCount) / Double(downloadProgress.totalUnitCount))
//                SCSDKLog("res download progress:\(value)")
//                progress(value)
//            }
        self.requests[url] = request
    }
    
    func uploadDataByAliyun(accessId: String, secret: String, endPoint: String, bucketName: String, objectKey: String, expirationTimeInGMTFormat: String, data: Data, progress: @escaping SCProgressHandler, success: @escaping SCSuccessString, failure: @escaping SCFailureError) {
        SCGlobalAsyncQueue {
            let fileName = objectKey.components(separatedBy: "/").last ?? ""
            SCSDKLog("start aws upload name:\(fileName), size:\(data.count)")
            let provider = OSSFederationCredentialProvider { () ->OSSFederationToken? in
                let token = OSSFederationToken()
                token.tAccessKey = accessId
                token.tSecretKey = secret
    //                token.tToken = "eyJleHBpcmF0aW9uIjoiMjAyMi0wMS0xMlQwMjo1MDo0NS43OThaIiwiY29uZGl0aW9ucyI6W1siY29udGVudC1sZW5ndGgtcmFuZ2UiLDAsMTA0ODU3NjAwMF0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCJ0ZXN0MDEvdGV4dG5hbWUudGV4dCJdXX0="
                token.expirationTimeInGMTFormat = expirationTimeInGMTFormat
                return token
            }

    //        let timestr = self.userId + String(Int(Date().timeIntervalSince1970))
            let client = OSSClient(endpoint: endPoint, credentialProvider: provider)
            let put = OSSPutObjectRequest()
            put.bucketName = bucketName
            put.objectKey = objectKey
            put.uploadingData = data
            put.uploadProgress = { (bytesSent, totalByteSent, totalBytesExpectedToSend) in
                SCSDKLog("bytesSent: \(bytesSent), bytesSent:\(bytesSent), totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
                progress(Float(bytesSent) / Float(totalByteSent))
            }
            let task = client.putObject(put)
            task.continue({ t -> Void in
                if (t.error != nil) {
                    let error: NSError = (t.error)! as NSError
                    SCSDKLog("oss upload fail name:\(fileName) error:\(error.description)")
                    SCMainAsyncQueue {
                        failure(error as Error)
                    }
                }
                else {
                    let url = "https://" + bucketName + "." + endPoint + "/" + objectKey
                    SCSDKLog("oss upload success name:\(fileName) success url:\(url)")
                    SCMainAsyncQueue {
                        success(url)
                    }
                }
            }).waitUntilFinished()
        }
    }
    
    func uploadFileByAliyun(accessId: String, secret: String, endPoint: String, bucketName: String, objectKey: String, expirationTimeInGMTFormat: String, dataFileURL: URL, progress: @escaping SCProgressHandler, success: @escaping SCSuccessString, failure: @escaping SCFailureError) {
        SCGlobalAsyncQueue {
            let fileName = objectKey.components(separatedBy: "/").last ?? ""
            let fileSize = ((try? FileManager.default.attributesOfItem(atPath: dataFileURL.path))?[FileAttributeKey.size] as? Int) ?? 0
            
            SCSDKLog("start aws upload name:\(fileName), size:\(fileSize)")
            let provider = OSSFederationCredentialProvider { () ->OSSFederationToken? in
                let token = OSSFederationToken()
                token.tAccessKey = accessId
                token.tSecretKey = secret
//                token.expirationTimeInGMTFormat = expirationTimeInGMTFormat
                token.expirationTimeInGMTFormat = "32400"
                return token
            }

            let client = OSSClient(endpoint: endPoint, credentialProvider: provider)
            let request = OSSMultipartUploadRequest()
            request.bucketName = bucketName
            request.objectKey = objectKey
            request.partSize = 256 * 1024
            request.uploadingFileURL = dataFileURL
            request.uploadProgress = { (bytesSent, totalByteSent, totalBytesExpectedToSend) in
                SCSDKLog("bytesSent: \(bytesSent), bytesSent:\(bytesSent), totalBytesExpectedToSend:\(totalBytesExpectedToSend)")
                progress(Float(bytesSent) / Float(totalByteSent))
            }
            
            let task = client.multipartUpload(request)
            task.continue({ t -> Void in
                if (t.error != nil) {
                    let error: NSError = (t.error)! as NSError
                    SCSDKLog("oss upload fail name:\(fileName) error:\(error.description)")
                    SCMainAsyncQueue {
                        failure(error as Error)
                    }
                }
                else {
                    let url = "https://" + bucketName + "." + endPoint + "/" + objectKey
                    SCSDKLog("oss upload success name:\(fileName) success url:\(url)")
                    SCMainAsyncQueue {
                        success(url)
                    }
                }
            }).waitUntilFinished()
        }
    }
    
    func uploadDataByAmazon(accessId: String, secret: String, endPoint: String, bucketName: String, objectKey: String, contentType: String, expirationTimeInGMTFormat: String, data: Data, progress: @escaping SCProgressHandler, success: @escaping SCSuccessString, failure: @escaping SCFailureError) {
        SCGlobalAsyncQueue {
            let fileName = objectKey.components(separatedBy: "/").last ?? ""
            SCSDKLog("start aws upload name:\(fileName), size:\(data.count)")
            let provider = AWSStaticCredentialsProvider(accessKey: accessId, secretKey: secret)
            let areaType = AWSRegionType.type(endPoint: endPoint)
            let config = AWSServiceConfiguration(region: areaType, credentialsProvider: provider)
            AWSServiceManager.default().defaultServiceConfiguration = config
            
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = { (task, prog) in
                progress(Float(prog.fractionCompleted))
                SCSDKLog("aws upload name:\(fileName), progress:\(prog.fractionCompleted)")
            }
            expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
            
            AWSS3TransferUtility.default().uploadData(data, bucket: bucketName, key: objectKey, contentType: contentType, expression: expression, completionHandler: { task, error in
                if let error = task.error {
                    SCSDKLog("aws upload fail name:\(fileName), error:\(error.localizedDescription)")
                    SCMainAsyncQueue {
                        failure(error as Error)
                    }
                }
                else {
                    let uploadUrl = task.response?.url?.absoluteString ?? ""
                    let range = (uploadUrl as NSString).range(of: objectKey)
                    var url = (uploadUrl as NSString).substring(to: range.location + range.length)
                    if !url.hasPrefix("http") {
                        url = "https://" + bucketName + ".s3." + AWSEndpoint.regionName(from: areaType) + ".amazonaws.com/" + objectKey
                    }
                    SCSDKLog("aws upload start name:\(fileName), url:\(url)")
                    SCMainAsyncQueue {
                        success(url)
                    }
                }
            }).continueWith(block: { (task) -> Void in
                if let error = task.error {
                    SCSDKLog("aws upload fail name:\(fileName), error:\(error.localizedDescription)")
                    SCMainAsyncQueue {
                        failure(error as Error)
                    }
                }
                else if let result = task.result {
                    SCSDKLog("aws upload start name:\(fileName), url:\(result.responseData)")
                }
            })
        }
    }
    
    func downloadByAliyun(accessId: String, secret: String, endPoint: String, bucketName: String, objectKey: String, expirationTimeInGMTFormat: String, progress: @escaping SCProgressHandler, success: @escaping SCSuccessData, failure: @escaping SCFailureError) {
        SCGlobalAsyncQueue {
            let fileName = objectKey.components(separatedBy: "/").last ?? ""
            let getObjectReq: OSSGetObjectRequest = OSSGetObjectRequest()
            getObjectReq.bucketName = bucketName
            getObjectReq.objectKey = objectKey
            getObjectReq.downloadProgress = { (bytesWritten: Int64,totalBytesWritten : Int64, totalBytesExpectedToWrite: Int64) -> Void in
                SCSDKLog("bytesWritten: \(bytesWritten), totalBytesWritten:\(totalBytesWritten), totalBytesExpectedToWrite:\(totalBytesExpectedToWrite)")
                progress(Float(bytesWritten) / Float(totalBytesWritten))
            }
            
            let provider = OSSFederationCredentialProvider { () ->OSSFederationToken? in
                let token = OSSFederationToken()
                token.tAccessKey = accessId
                token.tSecretKey = secret
                token.expirationTimeInGMTFormat = expirationTimeInGMTFormat
                return token
            }
            
            let client = OSSClient(endpoint: endPoint, credentialProvider: provider)
            
            SCSDKLog("oss download start name:\(fileName)")
            let task: OSSTask = client.getObject(getObjectReq);
            task.continue({ t -> Void in
                if (t.error != nil) {
                    let error: NSError = (t.error)! as NSError
                    SCSDKLog("oss download fail name:\(fileName) error:\(error.description)")
                    SCMainAsyncQueue {
                        failure(error as Error)
                    }
                }
                else {
                    SCMainAsyncQueue {
                        let result = t.result
                        let data = result?.downloadedData
                        SCSDKLog("oss download success name:\(fileName), data length:\(data?.count ?? 0)")
                        success(data ?? Data())
                    }
                }
            }).waitUntilFinished()
        }
    }
    
    /// 取消某个请求
    /// - Parameter api: 接口类型
    public func cancel(api: SCSmartHttpServiceApi) {
        let request = self.requests[api.path]
        request?.cancel()
    }
    
    /// 取消所有请求
    public func cancelAll() {
        for (_, request) in self.requests {
            request.cancel()
        }
    }
    
    /// 获取地址
    /// - Parameter api: 接口类型
    /// - Returns: 返回URL
    private func getUrl(api: SCSmartHttpServiceApi, pathParam: String? = nil) -> URL? {
        var baseUrl = self.config.baseUrl
        if api == .domainsList {
            baseUrl = self.config.domainBaseUrl
        }
        var url = baseUrl + api.path
        if pathParam != nil {
            url += "/" + pathParam!
        }
        
        return URL(string: url)
    }
    
    private func getUrl(api: SCSmartHttpServiceApi, queryParams: [String: Any]?) -> URL? {
        guard let param = queryParams else { return self.getUrl(api: api) }
        var queryItems = [URLQueryItem]()
        for (key, value) in param {
            var stringValue = ""
            if let value = value as? Int {
                stringValue = String(value)
            }
            else if let value = value as? Int64 {
                stringValue = String(value)
            }
            else if let value = value  as? UInt32 {
                stringValue = String(value)
            }
            else if let value = value as? CGFloat {
                stringValue = String(format: "%0.2f", value)
            } else if let value = value as? String {
                stringValue = value
            }
            let item = URLQueryItem(name: key, value: stringValue)
            queryItems.append(item)
        }
        var path = self.getUrl(api: api)?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: path)
        urlComponents?.queryItems = queryItems
        path = urlComponents?.url?.absoluteString ?? path
        let url = URL(string: path)
        return url
    }
    
    private func getUrl(path: String) -> URL? {
        
        return URL(string: path)
    }
}
