class User
  attr_accessor :uid, :email, :password, :roles, :new_record
  
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