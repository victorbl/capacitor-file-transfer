import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(FileTransfer)
public class FileTransfer: CAPPlugin {

    @objc func download(_ call: CAPPluginCall) {
        let source = call.getString("source") ?? ""
        let sourceUrl = URL(string: source)!
        
        let target = call.getString("target") ?? ""
        let targetUrl = URL(string: target)!
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: sourceUrl)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    
                    try FileManager.default.copyItem(at: tempLocalUrl, to: targetUrl)
                    call.success()
                } catch (let writeError) {
                    call.error("error writing file \(targetUrl) : \(writeError)")
                }

            } else {
                print("Failure: %@", error!.localizedDescription);
            }
        }
        task.resume()
    }
}
