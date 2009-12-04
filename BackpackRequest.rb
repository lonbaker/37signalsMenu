class BackpackRequest
  class << self
    attr_accessor :accountName
  end
  
  def self.requestLocation(location, usingMethod: method, withBody: body, delegate: delegate)
    alloc.initWithLocation(location, usingMethod: method, withBody: body, delegate: delegate)
  end
  
  def initWithLocation(location, usingMethod: method, withBody: body, delegate: delegate)
    @location = location
    @method = method.to_s.upcase
    @body = body.to_s
    @delegate = delegate
    connect
    self
  end
  
  def connect
    return if loading?
    
    @request = NSMutableURLRequest.requestWithURL(url)
    @request.HTTPMethod = @method
    @request.HTTPBody = @body.dataUsingEncoding(NSUTF8StringEncoding)
    @request.addValue("text/xml", forHTTPHeaderField: "Content-Type")

    @connection = NSURLConnection.connectionWithRequest(@request, delegate: self)
    @responseBody = NSMutableData.data
  end
  
  def url
    NSURL.URLWithString("https://#{self.class.accountName}.backpackit.com/#{@location}")
  end

  def loading?
    @request
  end
  
  def connection(connection, didReceiveResponse: response)
    NSLog("connection:didReceiveResponse:")
    @response = response
    @responseBody.length = 0
  end
  
  def connection(connection, didReceiveData: data)
    NSLog("connection:didReceiveData:")
    @responseBody.appendData(data)
  end
  
  def connectionDidFinishLoading(connection)
    NSLog("connectionDidFinishLoading:")
    responseBody = NSString.alloc.initWithData(@responseBody, encoding: NSUTF8StringEncoding)
    @delegate.backpackRequest(self, completedWithResponse: @response, body: responseBody)
  ensure
    reset
  end
  
  def connection(connection, didFailWithError: error)
    NSLog("connection:didFailWithError:")
    @delegate.backpackRequest(self, failedWithError: error)
  ensure
    reset
  end
  
  def reset
    @request = @response = @connection = @responseBody = nil
  end
end
