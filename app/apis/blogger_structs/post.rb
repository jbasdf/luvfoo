module BloggerStructs
  class Post < ActionWebService::Struct
    member :userId,      :string
    member :postId,      :string
    member :dateCreated, :string
    member :content,     :string
  end
end
