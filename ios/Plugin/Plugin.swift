import Foundation
import Capacitor

@objc(FileTransfer)
public class FileTransfer: CAPPlugin {

    struct DownloadArguments {
        var sourceUrl: URL
        var targetUrl: URL
        var refresh: Bool
    }
    
    @objc func downloadRelative(_ call: CAPPluginCall) {
        // Retrieve download arguments
        var arguments: DownloadArguments
        do {
            try arguments = getDownloadArguments(call: call)
        } catch {
            return
        }
        
        // Determine Documents path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Concatinate relative to absolute path
        arguments.targetUrl = documentsPath.appendingPathComponent(arguments.targetUrl.path)
        
        download(call: call, arguments: arguments)
    }
    
    @objc func downloadAbsolute(_ call: CAPPluginCall) {
        // Retrieve download arguments
        var arguments: DownloadArguments
        do {
            try arguments = getDownloadArguments(call: call)
        } catch {
            return
        }
        
        download(call: call, arguments: arguments)
    }
    
    enum ArgumentError: Error {
        case notProvided
        case failedToConvertToUrl
    }
    
    func getDownloadArguments(call: CAPPluginCall) throws -> DownloadArguments {
        // Source url argument
        guard let source = call.getString("source") else {
            call.error("Source argument not provided")
            throw ArgumentError.notProvided
        }
        guard let sourceUrl = URL(string: source) else {
            call.error("Failed to convert Source argument to Url")
            throw ArgumentError.failedToConvertToUrl
        }
        
        // Target url argument
        guard let target = call.getString("target") else {
            call.error("Target argument not provided")
            throw ArgumentError.notProvided
        }
        guard let targetUrl = URL(string: target) else {
            call.error("Failed to convert Target argument to Url")
            throw ArgumentError.failedToConvertToUrl
        }
        
        // Refresh argument
        let refresh = call.getBool("refresh", false)
        
        return DownloadArguments(sourceUrl: sourceUrl, targetUrl: targetUrl, refresh: refresh ?? false)
    }
    
    func download(call: CAPPluginCall, arguments: DownloadArguments) {
        
        // Determine if the target file exists
        if FileManager.default.fileExists(atPath: arguments.targetUrl.path) {
            if arguments.refresh {
                do {
                    try FileManager.default.removeItem(at: arguments.targetUrl)
                } catch(let error) {
                    call.error("Error deleting previously downloaded target file \(arguments.targetUrl) : \(error)")
                    return
                }
            } else {
                call.success(["url":arguments.targetUrl.absoluteString, "path": arguments.targetUrl.path])
                return
            }
        }
        
        // Setup file download
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: arguments.sourceUrl)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {

                // Create destination directory
                let filePath = arguments.targetUrl.deletingLastPathComponent();
                do {
                    try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true)
                } catch(let error) {
                    call.error("Error creating target directory \(filePath) : \(error)")
                    return
                }
                
                // Copy file
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: arguments.targetUrl)
                    call.success(["url":arguments.targetUrl.absoluteString, "path": arguments.targetUrl.path])
                } catch (let error) {
                    call.error("Error writing file \(arguments.targetUrl) : \(error)")
                    return
                }

            } else {
                call.error("File download failure: \(error!.localizedDescription)");
            }
        }
        task.resume()
    }
}
