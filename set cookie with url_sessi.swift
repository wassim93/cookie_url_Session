func setOnlineCoupons(status:Bool, completion: ((String) -> Void)? = nil) {
        let url = URL(string: Constants.SERVER_URL+"/set_online_coupons")
        guard let requestUrl = url else { fatalError() }
        let cookieStorage = HTTPCookieStorage.shared
        let tokenValue = UserDefaults.standard.string(forKey: "tokenValue")
        let tokenName = UserDefaults.standard.string(forKey: "tokenName")
        let cookie = tokenName!+"="+tokenValue!+"; Path=/; Domain="+Constants.COOKIE_URL+"; HttpOnly;"
        let cookieHeaderField = ["Set-Cookie": cookie]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: requestUrl)
        cookieStorage.setCookies(cookies, for: url, mainDocumentURL: url)
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let params = ["api_key": Constants.TEST_API_KEY,
                      "status": status] as [String : Any]
        let postString = getPostString(params: params)
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
        let task = session.dataTask(with: request, completionHandler: { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    // Check for Error
                    print("response code = \(httpResponse.statusCode)")
                    print("coupon not set online ")
                } else {
                    print("response code = \(httpResponse.statusCode)")
                    completion!("coupon online status changed successfully")
                    //print("coupon online status changed successfully")
                }
            }
        })
        task.resume()
    }
    
  func getPostString(params:[String:Any]) -> String {
        var data = [String]()
        for(key, value) in params {
            if value is String {
                let urlEncoded = (value as? String)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "+", with: "%2B")
                data.append(String.init(format: "%@=%@", key, urlEncoded ?? ""))
            } else {
                data.append(key + "=\(value)")
            }
        }
        return data.map { String($0) }.joined(separator: "&")
    }
