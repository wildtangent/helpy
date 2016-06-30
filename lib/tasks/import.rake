require 'importer'

namespace :db do
  namespace :import do	
    desc "Task to import content from HelpJuice FAQ platform"
    task helpjuice: :environment do

      importer = Importer::HelpJuice.new('https://asdamobile.helpjuice.com')
      importer.import!

    end
  end
end