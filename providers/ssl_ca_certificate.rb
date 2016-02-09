# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

def whyrun_supported?
        true
end

use_inline_resources

action :process do

  def create_ssl_ca(data)
    @ca = file new_resource.name do
      content data
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      backup false
    end
  end

  dbag_data = SSL_HELPER.new(new_resource.certs_dbag_name, new_resource.authority)

  Chef::Log.info("Processing CA certificate")
  if dbag_data.check("certificate")
    Chef::Log.info("Found valid entry in data bag for CA #{new_resource.authority}")
    create_ssl_ca(dbag_data.fetch("certificate"))
  end

  new_resource.updated_by_last_action(@ca.updated_by_last_action?)
end
