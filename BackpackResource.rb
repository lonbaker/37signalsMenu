require "xmlsimple"

class BackpackResource
  class ResourceBusyError < ::StandardError; end

  class << self
    def attribute(name)
      attribute_names << name
      define_method(name) do
        combinedAttributes[name]
      end
    end
    
    def attribute_names
      @attribute_names ||= []
    end

    def attributesFromXML(xml)
      attributesFromXmlSimple(XmlSimple.xml_in(xml, "ForceArray" => false))
    end
    
    def resourceWithDelegate(delegate)
      new.tap { |resource| resource.delegate = delegate }
    end
  end
  
  attr_accessor :delegate

  def load
    unless @loading
      request(:get) do |response, body|
        if (200..299).include?(response.statusCode)
          self.remoteAttributes = self.class.attributesFromXML(body)
        end
        @loading = false
      end
      
      @loading = true
    end
  end
  
  def save
    unless @saving
      attributesAtSaveTime = combinedAttributes

      request(methodForSave, attributesAsXML) do |response|
        if (200..299).include?(response.statusCode)
          self.remoteAttributes = attributesAtSaveTime
        end
        @saving = false
      end
      
      @saving = true
    end
  end

  def update(newAttributes)
    self.attributes = newAttributes
    save
  end

  def request(method, body = "", &handler)
    raise ResourceBusyError if loading?
    @request = BackpackRequest.requestLocation(location, usingMethod: method, withBody: body, delegate: self)
    @handler = handler
    
    begin
      delegate.backpackResourceStartedLoading(self)
    rescue NoMethodError
    end
  end
  
  def remoteAttributes
    @remoteAttributes ||= {}
  end
  
  def attributes
    @attributes ||= {}
  end
  
  def combinedAttributes
    remoteAttributes.merge(attributes)
  end
  
  def remoteAttributes=(newAttributes)
    @remoteAttributes = newAttributes || {}
    @remoteTimestamp = Time.now

    begin
      delegate.backpackResource(self, receivedRemoteAttributes: remoteAttributes)
    rescue NoMethodError
    end
  end
  
  def attributes=(newAttributes)
    @attributes = combinedAttributes.merge(newAttributes)
    @timestamp = Time.now

    begin
      delegate.backpackResource(self, changedAttributesTo: attributes)
    rescue NoMethodError
    end
  end

  def backpackRequest(request, completedWithResponse: response, body: body)
    @handler.call(response, body)
  ensure
    disconnect
  end
  
  def backpackRequest(request, failedWithError: error)
    delegate.backpackResource(self, failedToLoadWithError: error)
  rescue NoMethodError
  end
  
  def loading?
    @request
  end
  
  def disconnect
    @request = nil
    
    begin
      delegate.backpackResourceFinishedLoading(self)
    rescue NoMethodError
    end
  end
end
