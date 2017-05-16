class Poll::PartialResult < ActiveRecord::Base

  VALID_ORIGINS = %w{ web booth }

  belongs_to :question, -> { with_hidden }
  belongs_to :author, ->   { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :booth_assignment
  belongs_to :officer_assignment

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true
  validates :answer, inclusion: {in: ->(a) { a.question.valid_answers }}
  validates :origin, inclusion: {in: VALID_ORIGINS}

  scope :by_author, -> (author_id) { where(author_id: author_id) }
  scope :by_question, -> (question_id) { where(question_id: question_id) }

  before_save :update_logs

  def update_logs
    if self.amount_changed? && self.amount_was.present?
      self.amount_log += ":#{self.amount_was.to_s}"
      self.officer_assignment_id_log += ":#{self.officer_assignment_id_was.to_s}"
      self.author_id_log += ":#{self.author_id_was.to_s}"
    end
  end
end