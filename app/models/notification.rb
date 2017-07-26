# -*- encoding : utf-8 -*-
class Notification < ActiveRecord::Base
  belongs_to :info_request_event,
             :inverse_of => :notifications
  belongs_to :user,
             :inverse_of => :notifications

  INSTANTLY = :instantly
  DAILY = :daily
  enum frequency: [ INSTANTLY, DAILY ]

  validates_presence_of :info_request_event, :user, :frequency, :send_after

  before_validation :calculate_send_after

  scope :unseen, -> { where(seen_at: nil) }

  # Set the send_at timestamp based on the chosen frequency
  def calculate_send_after
    unless self.persisted? || self.send_after.present?
      if self.daily?
        self.send_after = self.user.next_daily_summary_time
      else
        self.send_after = Time.zone.now
      end
    end
  end

  # Return an Enumerable without expired notifications in it, saving the new
  # expired status at the same time
  def self.reject_and_mark_expired(notifications)
    expired_ids = notifications.select(&:expired).map(&:id)
    if expired_ids.empty?
      return notifications
    else
      Notification.where(id: expired_ids).update_all(expired: true)
      return notifications.reject { |n| expired_ids.include?(n.id) }
    end
  end

  # Overriden #expired? so that we can check against the actual current state
  # of our request (or whatever else might expire a notification)
  def expired
    send("#{info_request_event.event_type}_expired".to_sym)
  end

  def expired?
    expired
  end

  private

  def response_expired
    # New response notifications never expire
    false
  end

  def embargo_expiring_expired
    # If someone has changed the embargo date on the request, or published it,
    # they might not need this notification any more.
    !self.info_request_event.info_request.embargo_expiring?
  end
end
