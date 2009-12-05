class JournalEntry < BackpackResource
  attr_accessor :identity

  attribute :body
  
  def methodForSave
    :post
  end
  
  def location
    "users/#{identity.userID}/journal_entries.xml"
  end
  
  def attributesAsXML
    XmlSimple.xml_out({ "body" => [body] }, "RootName" => "journal-entry")
  end
end
