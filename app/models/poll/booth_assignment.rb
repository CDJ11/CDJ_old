class Poll
  class BoothAssignment < ActiveRecord::Base
    belongs_to :booth
    belongs_to :poll

    has_many :officer_assignments, class_name: "Poll::OfficerAssignment", dependent: :destroy
    has_many :recounts, class_name: "Poll::Recount", dependent: :destroy
    has_many :final_recounts, class_name: "Poll::FinalRecount", dependent: :destroy
    has_many :officers, through: :officer_assignments
    has_many :voters
    has_many :partial_results
    has_many :white_results
    has_many :null_results
  end
end
