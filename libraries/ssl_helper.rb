# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

class SSL_HELPER
  def initialize(dbag, id, secret)
    @id = id
    @dbag = dbag
    @secret = secret
    ssl_data
  end

  def ssl_data
    secret = Chef::EncryptedDataBagItem.load_secret(@secret)
    @ssl_data = Chef::EncryptedDataBagItem.load(@dbag, @id, secret)
  rescue
    raise "No such data bag,data bag item #{@id} or node doesn't have encrypted_data_bag_secret key!"
  end

  def check(type, data = SSL_PROCESSER)
    data.check(type, @ssl_data)
  end

  def fetch(type, data = SSL_PROCESSER)
    data.fetch(type, @ssl_data)
  end

  def self.check_if_should_be_processed(data)
    if data.nil? || !data || data.eql?('')
      false
    else
      true
    end
  end
end

class SSL_PROCESSER
  def self.check(type, ssl_data)
    if ssl_data[type].nil? || ssl_data[type].empty? || !ssl_data[type]
      raise "No such #{type} in data_bag file. Please add it first!"
    end
    true
  end

  def self.fetch(type, ssl_data)
    ssl_data[type]
  end
end
