# Copyright (c) 2016 Tacit Knowledge, All Rights Reserved.

actions :process

default_action :process

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :cn, kind_of: String, required: true
attribute :key, kind_of: String, default: nil
attribute :owner, kind_of: String, default: 'root'
attribute :group, kind_of: String, default: 'root'
attribute :mode, kind_of: Integer, default: 0400
attribute :certs_dbag_name, kind_of: String, default: 'certificates'

action :process do

  dbag_data = SSL_HELPER.new(certs_dbag_name, cn)

  Chef::Log.info('Processing certificate')
  if dbag_data.check('certificate')
    Chef::Log.info("Found valid entry in data bag for certificate #{cn}")
    @crt = file name do
      content dbag_data.fetch('certificate')
      owner owner
      group group
      mode mode
      backup false
    end
    updated_by_last_action(@crt.updated_by_last_action?)
  end

  if SSL_HELPER.check_if_should_be_processed(key)
    Chef::Log.info('Processing keyfile')
    fail "Failed to find an entry keyfile for #{cn}" unless dbag_data.check('keyfile')
    Chef::Log.info("Found valid entry in data bag for keyfile #{cn}")
    @key = file key do
      content dbag_data.fetch('keyfile')
      owner owner
      group group
      mode mode
      backup false
    end
    updated_by_last_action(@key.updated_by_last_action?)
  end
end
