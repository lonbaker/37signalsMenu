class Identity < BackpackResource
  attribute :userID
  
  def self.attributesFromXmlSimple(xml)
    { userID: xml["id"]["content"].to_i }
  end
  
  def location
    "me.xml"
  end
end
