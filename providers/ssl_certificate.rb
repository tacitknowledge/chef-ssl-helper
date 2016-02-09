# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

def whyrun_supported?
        true
end

use_inline_resources

action :process do

  def create_ssl_crt(data)
  @crt = file new_resource.name do
      content data
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      backup false
    end
  end

  def create_ssl_key(data)
    @key = file new_resource.key do
      content data
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      backup false
    end
  end

  dbag_data = SSL_HELPER.new(new_resource.certs_dbag_name, new_resource.cn)

  Chef::Log.info("Processing certificate")
  if dbag_data.check("certificate")
    Chef::Log.info("Found valid entry in data bag for certificate #{new_resource.cn}")
    create_ssl_crt(dbag_data.fetch("certificate"))
    new_resource.updated_by_last_action(@crt.updated_by_last_action?)
  end

  if SSL_HELPER.check_if_should_be_processed(new_resource.key)
    Chef::Log.info("Processing keyfile")
    if dbag_data.check("keyfile")
      Chef::Log.info("Found valid entry in data bag for keyfile #{new_resource.cn}")
      create_ssl_key(dbag_data.fetch("keyfile"))
      new_resource.updated_by_last_action(@key.updated_by_last_action?)
    else
      raise "Failed to find an entry keyfile for #{new_resource.cn}"
    end
  end

end
