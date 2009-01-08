module BloggerStructs
  class Blog < ActionWebService::Struct
    member :url,      :string
    member :blogId,   :string
    member :blogName, :string
  end
end
