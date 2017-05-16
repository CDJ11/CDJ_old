require 'rails_helper'

describe Valuator do

  describe "#description_or_email" do
    it "should return description if present" do
      valuator = create(:valuator, description: "Urbanism manager")

      expect(valuator.description_or_email).to eq("Urbanism manager")
    end

    it "should return email if not description present" do
      valuator = create(:valuator)

      expect(valuator.description_or_email).to eq(valuator.email)
    end
  end
end
