# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

actions :process

default_action :process

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :authority, kind_of: String, required: true
attribute :owner, kind_of: String, default: 'root'
attribute :group, kind_of: String, default: 'root'
attribute :mode, kind_of: Integer, default: 0400
attribute :certs_dbag_name, kind_of: String, default: 'certificates'
attribute :secret_file, kind_of: String, default: Chef::Config[:encrypted_data_bag_secret]

action :process do
  dbag_data = SSL_HELPER.new(certs_dbag_name, authority, secret_file)

  Chef::Log.info('Processing CA certificate')
  if dbag_data.check('certificate')
    Chef::Log.info("Found valid entry in data bag for CA #{authority}")
    @ca = file name do
      content dbag_data.fetch('certificate')
      owner owner
      group group
      mode mode
      backup false
    end
  end

  updated_by_last_action(@ca.updated_by_last_action?)
end
