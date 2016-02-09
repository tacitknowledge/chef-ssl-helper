# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

actions :process

default_action :process

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :cn, :kind_of => String, :required => true
attribute :owner, :kind_of => String, :default => "root"
attribute :group, :kind_of => String, :default => "root"
attribute :mode, :kind_of => Integer, :default => 0400
attribute :certs_dbag_name, :kind_of => String, :default => "certificates"

action :process do

  def create_ssl_pem(data)
    @f = file name do
      content data
      owner owner
      group group
      mode mode
      backup false
    end 
  end 

  dbag_data = SSL_HELPER.new(certs_dbag_name, cn)
  pem = nil 

  Chef::Log.info("Processing certificate")
  if dbag_data.check("certificate")
    Chef::Log.info("Found valid entry in data bag for certificate #{cn}")
    cert = dbag_data.fetch("certificate")
  end 

  Chef::Log.info("Processing keyfile")
  if dbag_data.check("keyfile")
    Chef::Log.info("Found valid entry in data bag for key #{cn}")
    key = dbag_data.fetch("keyfile")
  end 

  Chef::Log.info("Creating PEM file")

  pem = cert + "\n" + key 
  create_ssl_pem(pem)

  updated_by_last_action(@f.updated_by_last_action?)
end

