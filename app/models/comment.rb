class Comment < ActiveRecord::Base
  include Flaggable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  acts_as_votable
  has_ancestry touch: true

  attr_accessor :as_moderator, :as_administrator

  validates :body, presence: true
  validates :user, presence: true

  validates_inclusion_of :commentable_type, in: ["Debate", "Proposal", "Budget::Investment", "Poll::Question"]

  validate :validate_body_length

  belongs_to :commentable, -> { with_hidden }, polymorphic: true, counter_cache: true
  belongs_to :user, -> { with_hidden }

  before_save :calculate_confidence_score

  scope :for_render, -> { with_hidden.includes(user: :organization) }
  scope :with_visible_author, -> { joins(:user).where("users.hidden_at IS NULL") }
  scope :not_as_admin_or_moderator, -> { where("administrator_id IS NULL").where("moderator_id IS NULL")}
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }

  scope :sort_by_most_voted, -> { order(confidence_score: :desc, created_at: :desc) }
  scope :sort_descendants_by_most_voted, -> { order(confidence_score: :desc, created_at: :asc) }

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_descendants_by_newest, -> { order(created_at: :desc) }

  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_descendants_by_oldest, -> { order(created_at: :asc) }

  after_create :call_after_commented

  def self.build(commentable, user, body, p_id=nil)
    new commentable: commentable,
        user_id:     user.id,
        body:        body,
        parent_id:   p_id
  end

  def self.find_commentable(c_type, c_id)
    c_type.constantize.find(c_id)
  end

  def author_id
    user_id
  end

  def author
    user
  end

  def author=(author)
    self.user= author
  end

  def total_votes
    cached_votes_total
  end

  def total_likes
    cached_votes_up
  end

  def total_dislikes
    cached_votes_down
  end

  def as_administrator?
    administrator_id.present?
  end

  def as_moderator?
    moderator_id.present?
  end

  def after_hide
    commentable_type.constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  def after_restore
    commentable_type.constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  def reply?
    !root?
  end

  def call_after_commented
    self.commentable.try(:after_commented)
  end

  def self.body_max_length
    Setting['comments_body_max_length'].to_i
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  private

    def validate_body_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :body,
        maximum: Comment.body_max_length)
      validator.validate(self)
    end

end
