//
//  UpdateModel.swift
//  ValorantStoreChecker
//
//  Created by Gordon on 2022-09-10.
//  From https://stackoverflow.com/a/68942888

import Foundation

class UpdateModel: ObservableObject{
    
    @Published var update : Bool = false
    
    init() {
        let _ = try? isUpdateAvailable {[self] (update, error) in
            if let error = error {
                print(error)
            } else if update ?? false {
                // show alert
                DispatchQueue.main.async{
                    self.update = true
                }
                
            }
        }
    }
    

    @discardableResult
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }

        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error { throw error }
                
                guard let data = data else { throw VersionError.invalidResponse }
                            
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                            
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let lastVersion = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                
                completion(lastVersion > currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
        return task
    }

}
