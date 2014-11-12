require 'securerandom'

module Petergate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../templates", __FILE__)
      class_option :orm

      desc "Sets up rails project for Petergate Authorizations"
      def self.next_migration_number(path)
        sleep 1
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def insert_into_user_model
        inject_into_file "app/models/user.rb", after: /^\s{2,}devise[^\n]+\n[^\n]+\n/ do
          <<-'RUBY'

  ################################################################################ 
  ## PeterGate Roles
  ################################################################################

  serialize :roles

  # The :user role is added by default and shouldn't be included in this list.
  Roles = [:admin] 

  after_initialize do
    self[:roles] = []
  end

  def roles=(v)
    self[:roles] = v.map(&:to_sym).to_a.select{|r| r.size > 0 && Roles.include?(r)}
  end

  def roles
    self[:roles] + [:user]
  end

  def role
    roles.first
  end

  ################################################################################ 
  ## End PeterGate Roles
  ################################################################################

          RUBY
        end
      end

      def create_migrations
        Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
          name = File.basename(filepath)
          migration_template "migrations/#{name}", "db/migrate/#{name}"
        end
      end
    end
  end
end