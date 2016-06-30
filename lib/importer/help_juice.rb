#  id               :integer          not null, primary key
#  title            :string
#  body             :text
#  keywords         :string
#  title_tag        :string
#  meta_description :string
#  category_id      :integer
#  user_id          :integer
#  active           :boolean          default(TRUE)
#  rank             :integer
#  permalink        :string
#  version          :integer
#  front_page       :boolean          default(FALSE)
#  cheatsheet       :boolean          default(FALSE)
#  points           :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  topics_count     :integer          default(0)
#  allow_comments   :boolean          default(TRUE)

# Table name: categories
#
#  id               :integer          not null, primary key
#  name             :string
#  icon             :string
#  keywords         :string
#  title_tag        :string
#  meta_description :string
#  rank             :integer
#  front_page       :boolean          default(FALSE)
#  active           :boolean          default(TRUE)
#  permalink        :string
#  section          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null

require 'net/http'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

module Importer
  class HelpJuice

    PATHS = {
      docs: '/api/all-questions',
      doc: '/api/questions/:id'
    }

    # Initialize with the HelpJuice URL for your app
  	def initialize(url)
  	  @url = url
  	end

    # Import the models from HelpJuice
    def import!
      Category.where('id > 10').destroy_all
      Doc.where('id > 10').destroy_all

      uri = URI([@url, PATHS[:docs]].join())
      response = Net::HTTP.get(uri)
      docs = JSON.parse(response)

      docs.each do |document|
        # Can only get the category from the docs list
        category = document[remap(:doc, :category)]

        # Get the doc
        path = PATHS[:doc].gsub(':id', document[remap(:doc, :id)].to_s)
        uri = URI([@url, path].join())
        response = Net::HTTP.get(uri)
        doc = JSON.parse(response)

        # Build local version
        d = Doc.new
        d.id = doc[remap(:doc, :id)]
        d.title = doc[remap(:doc, :title)]
        d.body = doc[remap(:doc, :body)]
        d.rank = doc[remap(:doc, :rank)]
        d.meta_description = doc[remap(:doc, :meta_description)]
        d.active = true

        # Create categories and asssign        
        if category.is_a?(Array)
          category.each do |category|
            c = Category.find_by(id: category[remap(:category, :id)])
            puts category.inspect
            unless c.present?
              cat = Category.new
              cat.id = category[remap(:category, :id)]
              cat.name = category[remap(:category, :name)]
              cat.rank = category[remap(:category, :rank)]
              cat.front_page = true
              cat.active = true
              cat.save!
              d.category = cat
            else
              d.category = c
            end
          end
        end
        # Check validity and save
        if d.valid?
          d.save!
          puts d 
        else
          puts "#{d} was not valid"
        end
      end
    end

    # Map from legacy model to new model
    def remap(model, key)
      field_mapping[model][key]
    end

    # Field mappings assignment
    def field_mapping
      {
        category: {
          id: 'id',
          name: 'name',
          rank: 'position'
        },
        doc: {
          id: 'id',
          title: 'name',
          body: 'answer',
          rank: 'position',
          meta_description: 'description',
          category: 'categories'
        }
      }
    end
  end
end