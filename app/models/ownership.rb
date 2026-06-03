class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum status: { unread: 0, reading: 1, finished: 2 }
  
  after_initialize :set_default_status, if: :new_record?

  def status_label
    I18n.t("enums.ownership.status.#{status}")
  end

  private

  def set_default_status
    self.status ||= "unread"
  end
end
