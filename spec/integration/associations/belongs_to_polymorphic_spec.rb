require 'spec_helper'

describe 'belongs_to polymorphic' do
  before do
    load_belongs_to_polymorphic_models
    NoBrainer.sync_indexes
  end

  let(:event) { Event.create }
  let(:restaurant) { Restaurant.create }

  context 'creating a polymorphic model document' do
    it 'saves the model class as type and model id' do
      picture = Picture.create(imageable: restaurant)

      expect(picture.imageable_type).to eql(restaurant.class.name)
      # `imageable__id_` instead of imageable_id since the primary key
      # has been changed for Rspec, see spec/spec_helper.rb line 32-33.
      expect(picture.imageable__id_).to eql(restaurant._id_)
    end
  end

  context 'accessing a has_one polymorphic model document' do
    it 'returns the associated document' do
      logo = Logo.create(imageable: restaurant)

      expect(restaurant.logo).to eql(logo)
    end
  end

  context 'accessing a has_many polymorphic model document' do
    it 'returns the associated documents' do
      picture1 = Picture.create(imageable: restaurant)
      picture2 = Picture.create(imageable: restaurant)

      expect(restaurant.pictures.to_a).to eql([picture1, picture2])

      picture3 = Picture.create(imageable: event)

      expect(event.pictures.to_a).to eql([picture3])
    end
  end
end
