require "xmlsimple"

class BackpackResource
  class ResourceBusyError < ::StandardError; end

  class << self
    def attribute(name)
      attribute_names << name
      define_method(name) do
        attributes[name]
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
  
  attr_reader :attributes
  attr_accessor :delegate
  
  def load
    unless @loading
      request(:get) do |response, body|
        begin
          if response.statusCode == 200
            self.attributes = self.class.attributesFromXML(body)
          elsif response.statusCode == 404
            self.attributes = {}
          end
        ensure
          @loading = false
        end
      end
      
      @loading = true
    end
  end
  
  def update(newAttributes)
    unless @updating
      existingAttributes = attributes
      self.attributes = attributes.merge(newAttributes)

      request(:put, attributesAsXML) do |response|
         if response.statusCode != 200
           self.attributes = existingAttributes
         end
         @updating = false
      end
      
      @updating = true
    end
  end

  def request(method, body = "", &handler)
    raise ResourceBusyError if loading?
    @request = BackpackRequest.requestLocation(location, usingMethod: method, withBody: body, delegate: self)
    @handler = handler
    NSLog("request(#{method.inspect}, #{body.inspect})")
    
    begin
      delegate.backpackResourceStartedLoading(self)
    rescue NoMethodError
    end
  end
  
  def attributes=(newAttributes)
    @attributes = newAttributes
    @lastModified = Time.now

    begin
      delegate.backpackResource(self, didChangeAttributesTo: attributes)
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
