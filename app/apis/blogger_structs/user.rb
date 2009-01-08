module BloggerStructs
  class User < ActionWebService::Struct
    member :userId, :string
    member :username, :string
    member :email, :string
    member :url, :string
  end
end
