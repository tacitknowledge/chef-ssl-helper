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
