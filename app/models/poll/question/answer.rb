class Poll::Question::Answer < ActiveRecord::Base
  include Galleryable
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ "application/pdf" ]
  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'
  has_many :videos, class_name: 'Poll::Question::Answer::Video'

  validates :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  before_validation :set_order, on: :create

  def description
    super.try :html_safe
  end

  def self.order_answers(ordered_array)
    ordered_array.each_with_index do |answer_id, order|
      find(answer_id).update_attribute(:given_order, (order + 1))
    end
  end

  def set_order
    self.given_order = self.class.last_position(question_id) + 1
  end

  def self.last_position(question_id)
    where(question_id: question_id).maximum('given_order') || 0
  end
end
