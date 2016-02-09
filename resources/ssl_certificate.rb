# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

actions :process

default_action :process

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :cn, :kind_of => String, :required => true
attribute :key, :kind_of => String, :default => nil
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :mode, :kind_of => Integer, :default => 0400
attribute :certs_dbag_name, :kind_of => String, :default => "certificates"

action :process do

  def create_ssl_crt(data)
  @crt = file name do
      content data
      owner owner
      group group
      mode mode
      backup false
    end 
  end 

  def create_ssl_key(data)
    @key = file key do
      content data
      owner owner
      group group
      mode mode
      backup false
    end 
  end 

  dbag_data = SSL_HELPER.new(certs_dbag_name, cn)

  Chef::Log.info("Processing certificate")
  if dbag_data.check("certificate")
    Chef::Log.info("Found valid entry in data bag for certificate #{cn}")
    create_ssl_crt(dbag_data.fetch("certificate"))
    updated_by_last_action(@crt.updated_by_last_action?)
  end 

  if SSL_HELPER.check_if_should_be_processed(key)
    Chef::Log.info("Processing keyfile")
    if dbag_data.check("keyfile")
      Chef::Log.info("Found valid entry in data bag for keyfile #{cn}")
      create_ssl_key(dbag_data.fetch("keyfile"))
      updated_by_last_action(@key.updated_by_last_action?)
    else
      raise "Failed to find an entry keyfile for #{cn}"
    end
  end
end

