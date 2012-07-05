class User
  attr_accessor :uid, :email, :password, :affiliations, :new_record

  def initialize(params={})
    self.email = params[:email] if params[:email]
  end
  
  def user_key
    uid
  end
  
  def new_record?
    new_record == true
  end
  
  def is_being_superuser?(session)
    # do nothing -- stubbing deprecated behavior
  end
  
  def save
    # do nothing!
  end
  
  def save!
    save
    return self
  end
  
end
