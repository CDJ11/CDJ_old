class Poll
  class Voter < ActiveRecord::Base
    belongs_to :poll
    belongs_to :user
    belongs_to :geozone
    belongs_to :booth_assignment
    belongs_to :officer_assignment

    validates :poll_id, presence: true
    validates :user_id, presence: true

    validates :document_number, presence: true, uniqueness: { scope: [:poll_id, :document_type], message: :has_voted }

    before_validation :set_demographic_info, :set_document_info

    def set_demographic_info
      return unless user.present?

      self.gender  = user.gender
      self.age     = user.age
      self.geozone = user.geozone
    end

    def set_document_info
      return unless user.present?

      self.document_type   = user.document_type
      self.document_number = user.document_number
    end

    private

      def in_census?
        census_api_response.valid?
      end

      def census_api_response
        @census_api_response ||= CensusApi.new.call(document_type, document_number)
      end

      def fill_stats_fields
        if in_census?
          self.gender = census_api_response.gender
          self.geozone_id = Geozone.select(:id).where(census_code: census_api_response.district_code).first.try(:id)
          self.age = voter_age(census_api_response.date_of_birth)
        end
      end

      def voter_age(dob)
        if dob.blank?
          nil
        else
          now = Time.now.utc.to_date
          now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
        end
      end

  end
end