class JournalStatus < BackpackResource
  OUT_PATTERN = /^\[?out\]?\s*\(?(.*?)\)?$/i

  attr_accessor :userID
  attribute :message

  def self.attributesFromXmlSimple(xml)
    message = xml["message"]
    message = "" if message.is_a?(Hash)

    { message: message }
  end
  
  def message
    combinedAttributes[:message].to_s
  end
  
  def displayMessage
    if out?
      message[OUT_PATTERN, 1]
    else
      message
    end
  end
  
  def out?
    message.match(OUT_PATTERN)
  end
  
  def out!
    message = displayMessage.strip
    message = " (#{message})" unless message.length.zero?
    update(message: "out#{message}")
  end

  def in?
    !out?
  end
  
  def in!
    update(message: displayMessage)
  end
  
  def attributesAsXML
    XmlSimple.xml_out({ "message" => [message] }, "RootName" => "status")
  end

  def location
    "users/#{userID}/status.xml"
  end
  
  def methodForSave
    :put
  end
end
