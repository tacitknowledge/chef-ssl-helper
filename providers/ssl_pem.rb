# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

def whyrun_supported?
        true
end

use_inline_resources

action :process do

  def create_ssl_pem(data)
    @f = file new_resource.name do
      content data
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      backup false
    end
  end

  dbag_data = SSL_HELPER.new(new_resource.certs_dbag_name, new_resource.cn)
  pem = nil

  Chef::Log.info("Processing certificate")
  if dbag_data.check("certificate")
    Chef::Log.info("Found valid entry in data bag for certificate #{new_resource.cn}")
    cert = dbag_data.fetch("certificate")
  end

  Chef::Log.info("Processing keyfile")
  if dbag_data.check("keyfile")
    Chef::Log.info("Found valid entry in data bag for key #{new_resource.cn}")
    key = dbag_data.fetch("keyfile")
  end

  Chef::Log.info("Creating PEM file")

  pem = cert + "\n" + key
  create_ssl_pem(pem)

  new_resource.updated_by_last_action(@f.updated_by_last_action?)
end
